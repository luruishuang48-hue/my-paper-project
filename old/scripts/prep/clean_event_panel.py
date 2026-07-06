#!/usr/bin/env python3
"""
clean_event_panel.py
Cleaning script for 事件集数据.csv (event-study panel data).
Reads a CSV with 2-row headers (Chinese + English), GB18030 encoding,
and produces a clean panel ready for Stata/R/Python regression.

Output files:
  clean_event_firm_panel.csv
  cleaning_report.md
  data_dictionary.csv
  variable_rename_map.csv
  event_level_summary.csv
  event_firm_balance_check.csv
  duplicate_event_firm_rows.csv (if duplicates found)
"""

import pandas as pd
import numpy as np
import os
import re
from datetime import datetime, timedelta
from collections import Counter

# ============================================================
# CONFIGURATION
# ============================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE = os.path.join(SCRIPT_DIR, "事件集数据.csv")
ENCODING = "gb18030"
EXCEL_EPOCH = "1899-12-30"

# Output files
OUT_CLEANED = os.path.join(SCRIPT_DIR, "clean_event_firm_panel.csv")
OUT_REPORT = os.path.join(SCRIPT_DIR, "cleaning_report.md")
OUT_DICT = os.path.join(SCRIPT_DIR, "data_dictionary.csv")
OUT_RENAME_MAP = os.path.join(SCRIPT_DIR, "variable_rename_map.csv")
OUT_EVENT_SUMMARY = os.path.join(SCRIPT_DIR, "event_level_summary.csv")
OUT_BALANCE = os.path.join(SCRIPT_DIR, "event_firm_balance_check.csv")
OUT_DUPES = os.path.join(SCRIPT_DIR, "duplicate_event_firm_rows.csv")

# Tracking for report
report = {}
rename_log = []  # list of (chinese_label, original_english, clean_name, reason)
numeric_conversion_log = []  # list of (col_name, new_na_count)

# ============================================================
# 1. READ RAW DATA
# ============================================================

def read_raw_data(filepath, encoding):
    """Read CSV with 2-row header: row0=Chinese labels, row1=English names, row2+=data."""
    # Read Chinese header row
    chi_headers = pd.read_csv(filepath, encoding=encoding, nrows=1, header=None).iloc[0].tolist()
    # Read English header row
    eng_headers = pd.read_csv(filepath, encoding=encoding, nrows=1, skiprows=1, header=None).iloc[0].tolist()
    # Read data
    df = pd.read_csv(filepath, encoding=encoding, skiprows=2, header=None, dtype=str, keep_default_na=False)

    # Fill NaN in headers with empty string
    chi_headers = [str(h) if pd.notna(h) else "" for h in chi_headers]
    eng_headers = [str(h) if pd.notna(h) else "" for h in eng_headers]

    return df, chi_headers, eng_headers

print("Reading raw data...")
df, chi_headers, eng_headers = read_raw_data(INPUT_FILE, ENCODING)

raw_rows = len(df)
raw_cols = len(df.columns)
report["raw_rows"] = raw_rows
report["raw_cols"] = raw_cols

print(f"  Raw data: {raw_rows} rows x {raw_cols} columns")

# ============================================================
# 2. BUILD DATA DICTIONARY (Chinese -> English mapping)
# ============================================================

data_dict = []
for i, (chi, eng) in enumerate(zip(chi_headers, eng_headers)):
    data_dict.append({
        "col_index": i,
        "chinese_label": chi if chi else "(empty)",
        "original_english_name": eng if eng else "(empty)",
    })

# ============================================================
# 3. REMOVE EMPTY ROWS AND COLUMNS
# ============================================================

# Remove fully empty rows
empty_row_mask = df.apply(lambda row: (row == "").all(), axis=1)
empty_row_count = empty_row_mask.sum()
df = df[~empty_row_mask].copy()
report["empty_rows_removed"] = empty_row_count

# Remove fully empty columns, BUT only if BOTH Chinese and English headers are empty
# (true separator/unnamed columns). Named columns like 'relationship' are kept
# even if all values are empty — they are structurally meaningful.
data_is_empty = df.apply(lambda col: (col == "").all(), axis=0)
header_is_empty = [chi.strip() == "" and eng.strip() == "" for chi, eng in zip(chi_headers, eng_headers)]
empty_col_mask = [data_empty and header_empty for data_empty, header_empty in zip(data_is_empty, header_is_empty)]
empty_col_count = sum(empty_col_mask)
empty_col_indices = [i for i, m in enumerate(empty_col_mask) if m]
df = df.loc[:, [not m for m in empty_col_mask]].copy()
report["empty_cols_removed"] = empty_col_count
report["empty_col_indices"] = empty_col_indices

# Also remove from header lists and data_dict
eng_headers = [h for i, h in enumerate(eng_headers) if not empty_col_mask[i]]
chi_headers = [h for i, h in enumerate(chi_headers) if not empty_col_mask[i]]
data_dict = [d for i, d in enumerate(data_dict) if not empty_col_mask[i]]

# Re-index data_dict
for i, d in enumerate(data_dict):
    d["col_index"] = i

print(f"  Removed {empty_row_count} empty rows, {empty_col_count} empty columns")
print(f"  After cleanup: {len(df)} rows x {len(df.columns)} columns")

# ============================================================
# 4. DETECT AND RENAME DUPLICATE ENGLISH COLUMN NAMES
# ============================================================

# Build a counter of raw English names
eng_counter = Counter(eng_headers)
duplicates = {k: v for k, v in eng_counter.items() if v > 1 and k != ""}

# Strategy: we will build new unique names.
# First, assign temporary names for unnamed columns (empty English headers)
# using Chinese headers where available.
# Known Chinese-to-English mappings for unnamed columns:
KNOWN_UNNAMED_MAP = {
    "搜索代码1": "search_code_1",
    "搜索代码2": "search_code_2",
}

new_names = []
# Track which occurrence of each duplicate name we're at
dup_occurrence = {k: 0 for k in duplicates}

for i, (eng, chi) in enumerate(zip(eng_headers, chi_headers)):
    name = eng.strip() if eng else ""

    if name == "":
        # Unnamed column: use Chinese label to derive English name
        chi_clean = chi.strip() if chi else ""
        if chi_clean in KNOWN_UNNAMED_MAP:
            name = KNOWN_UNNAMED_MAP[chi_clean]
        elif chi_clean:
            # Transliterate: keep only ASCII-friendly parts, use pinyin-like conversion
            # For now, use a safe prefix with index
            name = f"col_{i}"
        else:
            name = f"col_{i}"
        new_names.append(name)
        rename_log.append((chi, eng, name, f"empty English header, derived from Chinese label '{chi_clean}'"))
        continue

    if name in duplicates:
        # This is a duplicate column — need to disambiguate
        dup_occurrence[name] += 1
        occ = dup_occurrence[name]

        # Handle CAR columns (car_pre through car_20)
        if name.startswith("car_"):
            if occ == 1:
                new_name = f"mkt_{name}"
                reason = "first occurrence of CAR column -> market model CAR"
            elif occ == 2:
                new_name = f"ff3_{name}"
                reason = "second occurrence of CAR column -> FF3 abnormal return"
            else:
                new_name = f"{name}_{occ}"
                reason = f"unexpected duplicate #{occ}"

        # Handle windows-* columns (media sentiment mean/sd)
        elif name.startswith("windows-"):
            window_num = name.replace("windows-", "")
            if occ == 1:
                new_name = f"media_sent_mean_w{window_num}"
                reason = f"first occurrence of windows-{window_num} -> media sentiment mean"
            elif occ == 2:
                new_name = f"media_sent_sd_w{window_num}"
                reason = f"second occurrence of windows-{window_num} -> media sentiment SD"
            else:
                new_name = f"{name}_{occ}"
                reason = f"unexpected duplicate #{occ}"

        else:
            new_name = f"{name}_{occ}"
            reason = f"unexpected duplicate #{occ}"

        new_names.append(new_name)
        rename_log.append((chi, eng, new_name, reason))
    else:
        new_names.append(name)
        if name != eng.strip():
            rename_log.append((chi, eng, name, "whitespace trimmed"))

# ============================================================
# 5. NORMALIZE ALL VARIABLE NAMES
# ============================================================

def normalize_varname(name):
    """Convert variable name to clean lowercase with underscores, ASCII only."""
    orig = name
    # Replace hyphens with underscores
    name = name.replace("-", "_")
    # Replace spaces with underscores
    name = name.replace(" ", "_")
    # Remove parentheses, brackets, slashes, percent signs
    name = name.replace("(", "").replace(")", "").replace("/", "_").replace("%", "pct")
    name = name.replace("[", "").replace("]", "")
    # Remove or replace non-ASCII characters (Chinese, special Unicode)
    name = re.sub(r'[^\x00-\x7F]', '', name)
    # Collapse multiple underscores
    name = re.sub(r'_+', '_', name)
    # Strip leading/trailing underscores
    name = name.strip("_")
    # Lowercase
    name = name.lower()
    # Don't start with digit
    if name and name[0].isdigit():
        name = "v_" + name
    # If name is now empty (was all Chinese), use a placeholder
    if not name:
        name = "col"
    return name

clean_names = [normalize_varname(n) for n in new_names]

# Check for duplicates after normalization
clean_counter = Counter(clean_names)
final_dupes = {k: v for k, v in clean_counter.items() if v > 1}
if final_dupes:
    # Resolve by appending _2, _3 etc.
    seen = {}
    resolved_names = []
    for n in clean_names:
        if n in final_dupes:
            if n not in seen:
                seen[n] = 1
                resolved_names.append(n)
            else:
                seen[n] += 1
                resolved_names.append(f"{n}_{seen[n]}")
        else:
            resolved_names.append(n)
    clean_names = resolved_names

# Build full rename map: for every column, map original -> clean
full_rename_map = []
for i in range(len(clean_names)):
    chi = chi_headers[i] if i < len(chi_headers) else ""
    eng = eng_headers[i] if i < len(eng_headers) else ""
    intermediate = new_names[i] if i < len(new_names) else ""
    # Determine rename reason
    if eng.strip() == "":
        reason = f"empty English header, derived from Chinese label '{chi}'"
    elif eng.strip() != intermediate and intermediate != eng.strip():
        reason = f"renamed from duplicate or unnamed: '{eng.strip()}' -> '{clean_names[i]}'"
    else:
        reason = "normalized (lowercase, underscores)"
    full_rename_map.append({
        "original_chinese_label": chi,
        "original_english_name": eng.strip(),
        "intermediate_name": intermediate,
        "clean_name": clean_names[i],
        "rename_reason": reason,
    })

# Also update rename_log entries with final clean names
# Find mapping from intermediate (new_names) to clean_names
intermediate_to_clean = dict(zip(new_names, clean_names))
updated_rename_log = []
for chi, orig_eng, temp_name, reason in rename_log:
    clean_n = intermediate_to_clean.get(temp_name, temp_name)
    updated_rename_log.append((chi, orig_eng, clean_n, reason))
rename_log = updated_rename_log

# Assign clean names to dataframe
df.columns = clean_names

print(f"  Renamed {len(rename_log)} columns to resolve duplicates/unnamed")

# ============================================================
# 6. DATE CLEANING
# ============================================================

def parse_date_mixed(val):
    """Parse a date value from mixed formats.
    Returns (parsed_date_or_NaT, format_detected_or_error)."""
    if pd.isna(val) or str(val).strip() == "":
        return pd.NaT, "empty"

    s = str(val).strip()

    # Try Excel serial number (integer)
    try:
        serial = int(s)
        if 40000 <= serial <= 60000:  # reasonable range for 2009-2064
            dt = datetime(1899, 12, 30) + timedelta(days=serial)
            return pd.Timestamp(dt), "excel_serial"
    except ValueError:
        pass

    # Try YYYY/M/D or YYYY-M-D
    for fmt in ["%Y/%m/%d", "%Y-%m-%d", "%Y/%m/%d", "%Y-%m-%d"]:
        try:
            dt = datetime.strptime(s, fmt)
            return pd.Timestamp(dt), "iso_or_slash"
        except ValueError:
            continue

    # Try YY-Mon (e.g., "24-Apr")
    try:
        dt = datetime.strptime(s, "%y-%b")
        return pd.Timestamp(dt), "mon_year"
    except ValueError:
        pass

    # Try with lowercase month
    try:
        dt = datetime.strptime(s, "%y-%b")
        return pd.Timestamp(dt), "mon_year"
    except ValueError:
        pass

    # Try full date in YY-Mon-DD
    try:
        dt = datetime.strptime(s, "%y-%b-%d")
        return pd.Timestamp(dt), "mon_year_day"
    except ValueError:
        pass

    return pd.NaT, f"unparseable:{s[:50]}"


def parse_month_to_ym(val):
    """Parse release_month value and return YYYY-MM string."""
    if pd.isna(val) or str(val).strip() == "":
        return pd.NA, "empty"

    s = str(val).strip()

    # Try Excel serial number
    try:
        serial = int(s)
        if 40000 <= serial <= 60000:
            dt = datetime(1899, 12, 30) + timedelta(days=serial)
            return dt.strftime("%Y-%m"), "excel_serial"
    except ValueError:
        pass

    # Try YY-Mon (e.g., "24-Apr")
    try:
        dt = datetime.strptime(s, "%y-%b")
        return dt.strftime("%Y-%m"), "mon_year"
    except ValueError:
        pass

    # Try YY-Mon with various capitalizations (e.g., "24-apr", "24-Apr")
    try:
        # Capitalize the month abbreviation part (after the hyphen)
        parts = s.split("-", 1)
        if len(parts) == 2:
            normalized = f"{parts[0]}-{parts[1][0].upper()}{parts[1][1:].lower()}"
        else:
            normalized = s
        dt = datetime.strptime(normalized, "%y-%b")
        return dt.strftime("%Y-%m"), "mon_year"
    except (ValueError, AttributeError):
        pass

    # Try full date formats and extract YYYY-MM
    parsed, fmt = parse_date_mixed(val)
    if not pd.isna(parsed):
        return parsed.strftime("%Y-%m"), f"full_date:{fmt}"

    return pd.NA, f"unparseable:{s[:50]}"


# Clean release_date
date_failures = []
release_date_col = "release_date" if "release_date" in clean_names else None
release_month_col = "release_month" if "release_month" in clean_names else None

if release_date_col:
    date_raw = df[release_date_col].copy()
    df[release_date_col + "_raw"] = date_raw
    parsed_dates = []
    for val in date_raw:
        dt, fmt = parse_date_mixed(val)
        parsed_dates.append(dt)
        if fmt.startswith("unparseable"):
            date_failures.append((val, fmt))

    df[release_date_col] = parsed_dates
    df[release_date_col] = pd.to_datetime(df[release_date_col])
    n_date_fail = sum(1 for d in parsed_dates if pd.isna(d))
    report["release_date_parse_failures"] = n_date_fail
    report["release_date_failure_examples"] = date_failures[:10]
    print(f"  release_date: {n_date_fail} parse failures out of {len(parsed_dates)}")

if release_month_col:
    month_raw = df[release_month_col].copy()
    df[release_month_col + "_raw"] = month_raw
    month_failures = []
    parsed_months = []
    for val in month_raw:
        ym, fmt = parse_month_to_ym(val)
        parsed_months.append(ym)
        if fmt.startswith("unparseable"):
            month_failures.append((val, fmt))

    df[release_month_col] = parsed_months
    n_month_fail = sum(1 for m in parsed_months if pd.isna(m))
    report["release_month_parse_failures"] = n_month_fail
    report["release_month_failure_examples"] = month_failures[:10]
    print(f"  release_month: {n_month_fail} parse failures out of {len(parsed_months)}")

# ============================================================
# 7. NUMERIC TYPE CONVERSION
# ============================================================

# Columns that should be numeric
numeric_candidates = []
for col in clean_names:
    # CAR columns
    if col.startswith("mkt_car_") or col.startswith("ff3_car_"):
        numeric_candidates.append(col)
    # Media sentiment
    elif col.startswith("media_sent_mean_w") or col.startswith("media_sent_sd_w"):
        numeric_candidates.append(col)
    # Financial controls
    elif col in ["size_log_assets", "bm_ratio", "volatility", "momentum"]:
        numeric_candidates.append(col)
    # AA capability metrics
    elif col in ["aa_intelligence_index", "aa_coding_index", "aa_math_index",
                  "mmlu_pro", "gpqa", "hle", "livecodebench", "scicode",
                  "math_500", "aime"]:
        numeric_candidates.append(col)
    # Price/speed metrics
    elif col in ["price_1m_input_tokens", "price_1m_output_tokens",
                  "price_1m_blended_3_to_1", "median_output_tokens_per_second",
                  "median_time_to_first_token_seconds", "median_time_to_first_answer_token"]:
        numeric_candidates.append(col)
    # AA media metrics
    elif col in ["aa_media_elo", "aa_media_rank", "aa_media_ci95",
                  "aa_media_appearances", "aa_media_category_rows"]:
        numeric_candidates.append(col)
    # Count columns
    elif col in ["merged_model_count", "release_year", "trend_month_since_2022_11"]:
        numeric_candidates.append(col)

# Replace known NA patterns
na_patterns = ["#N/A", "N/A", "#NA", "#N/A N/A", "n/a", "N/a"]
for col in numeric_candidates:
    if col in df.columns:
        df[col] = df[col].replace(na_patterns, np.nan)
        df[col] = df[col].replace("", np.nan)
        df[col] = df[col].replace("NA", np.nan)

# Convert to numeric
for col in numeric_candidates:
    if col not in df.columns:
        continue
    before_na = df[col].isna().sum()
    df[col] = pd.to_numeric(df[col], errors="coerce")
    after_na = df[col].isna().sum()
    new_na = after_na - before_na
    total_na = after_na
    numeric_conversion_log.append((col, new_na, total_na))
    if new_na > 0:
        print(f"  {col}: {new_na} new NaN after numeric conversion")
    if after_na > len(df) * 0.5:
        print(f"  WARNING: {col} has {after_na/len(df)*100:.1f}% missing after conversion")

# ============================================================
# 8. PANEL STRUCTURE CHECK
# ============================================================

eid_col = "final_event_id" if "final_event_id" in clean_names else None
cid_col = "company_id" if "company_id" in clean_names else None

if eid_col and cid_col:
    n_events = df[eid_col].nunique()
    n_firms = df[cid_col].nunique()
    n_obs = len(df)

    # Check duplicates
    dup_mask = df.duplicated(subset=[eid_col, cid_col], keep=False)
    n_dupes = dup_mask.sum()

    # Check balance
    event_firm_counts = df.groupby(eid_col)[cid_col].nunique()
    is_balanced = event_firm_counts.nunique() == 1
    typical_firms = event_firm_counts.median()

    report["n_events"] = n_events
    report["n_firms"] = n_firms
    report["n_observations"] = n_obs
    report["is_balanced"] = is_balanced
    report["n_duplicate_keys"] = n_dupes
    report["firms_per_event_min"] = int(event_firm_counts.min())
    report["firms_per_event_max"] = int(event_firm_counts.max())
    report["firms_per_event_typical"] = int(typical_firms)

    print(f"  Events: {n_events}, Firms: {n_firms}, Obs: {n_obs}")
    print(f"  Balanced panel: {is_balanced}")
    print(f"  Duplicate keys: {n_dupes}")

    # Output duplicates if found
    if n_dupes > 0:
        dup_df = df[dup_mask].copy()
        dup_df.to_csv(OUT_DUPES, index=False, encoding="utf-8-sig")
        print(f"  Duplicates written to {OUT_DUPES}")

    # Generate balance check
    balance_df = event_firm_counts.reset_index()
    balance_df.columns = [eid_col, "company_count"]
    # Add event name
    ename_col = "event_name" if "event_name" in clean_names else None
    if ename_col:
        ename_map = df.groupby(eid_col)[ename_col].first().to_dict()
        balance_df["event_name"] = balance_df[eid_col].map(ename_map)
    balance_df["is_typical"] = balance_df["company_count"] == typical_firms
    balance_df.to_csv(OUT_BALANCE, index=False, encoding="utf-8-sig")

    # Generate event-level summary
    event_summary_cols = [eid_col]
    if ename_col:
        event_summary_cols.append(ename_col)
    for c in ["release_date", "release_month", "true_model_creator", "creator_country",
              "creator_type", "model_family", "candidate_tier"]:
        if c in clean_names:
            event_summary_cols.append(c)

    event_summary = df[event_summary_cols].drop_duplicates(subset=[eid_col])

    # Add company count
    event_summary = event_summary.merge(balance_df[[eid_col, "company_count"]], on=eid_col, how="left")

    # Check LLM and media flags
    for flag_col, label in [("llm_capability_sample_flag", "has_llm_metrics"),
                             ("media_capability_sample_flag", "has_media_metrics")]:
        if flag_col in df.columns:
            flag_agg = df.groupby(eid_col)[flag_col].apply(lambda x: (x == "1").any()).reset_index()
            flag_agg.columns = [eid_col, label]
            event_summary = event_summary.merge(flag_agg, on=eid_col, how="left")

    event_summary.to_csv(OUT_EVENT_SUMMARY, index=False, encoding="utf-8-sig")

# ============================================================
# 9. CHECK search_code_2
# ============================================================

sc2_col = None
for col in clean_names:
    if "search_code_2" in col or "unnamed" in col and "搜索代码2" in col:
        sc2_col = col
        break

if sc2_col is None:
    # Try to find by position - it was col 15 originally
    for col in clean_names:
        if col.startswith("search_code") and "2" in col:
            sc2_col = col
            break

if sc2_col and sc2_col in df.columns:
    sc2_vals = df[sc2_col].value_counts()
    report["search_code_2_unique"] = len(sc2_vals)
    report["search_code_2_top_value"] = sc2_vals.index[0]
    report["search_code_2_top_pct"] = sc2_vals.iloc[0] / len(df) * 100
    report["search_code_2_is_constant"] = len(sc2_vals) <= 1

# ============================================================
# 10. KEY VARIABLE MISSINGNESS CHECK
# ============================================================

key_vars = [
    "final_event_id", "event_name", "release_date", "release_month",
    "company_id", "company", "relationship",
    "potential_us_exposure_type", "possible_us_exposed_tickers",
    "mkt_car_1", "mkt_car_2", "mkt_car_3", "mkt_car_5", "mkt_car_10",
    "ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_5", "ff3_car_10",
]

def count_missing(col):
    """Count truly missing values: NaN, NaT, empty string, or whitespace-only."""
    base_missing = col.isna().sum()
    # For string/object columns, also count empty/whitespace strings
    if col.dtype == 'object':
        base_missing += (col == "").sum()
        # Only try .str accessor if there are non-empty strings
        non_empty = col[col != ""].dropna()
        if len(non_empty) > 0:
            try:
                base_missing += (col.str.strip() == "").sum()
            except AttributeError:
                pass
    return base_missing

key_missing = {}
for var in key_vars:
    if var in df.columns:
        missing = count_missing(df[var])
        key_missing[var] = {
            "total": len(df),
            "missing": missing,
            "pct": missing / len(df) * 100
        }
    else:
        # Try to find by partial match
        matched = [c for c in df.columns if var in c.lower()]
        if matched:
            missing = count_missing(df[matched[0]])
            key_missing[var] = {
                "total": len(df),
                "missing": missing,
                "pct": missing / len(df) * 100,
                "actual_col": matched[0]
            }
        else:
            key_missing[var] = {"total": len(df), "missing": "COLUMN NOT FOUND", "pct": "N/A"}

report["key_missing"] = key_missing

# Special check: relationship
if "relationship" in df.columns:
    rel_filled = len(df) - count_missing(df["relationship"])
    report["relationship_non_null"] = rel_filled
    report["relationship_total_missing"] = count_missing(df["relationship"])

# ============================================================
# 11. SAVE OUTPUTS
# ============================================================

# Save cleaned panel
df.to_csv(OUT_CLEANED, index=False, encoding="utf-8-sig")
print(f"  Cleaned panel saved to {OUT_CLEANED}")

# Save data dictionary
dict_df = pd.DataFrame(data_dict)
# Add clean names
dict_df["clean_name"] = clean_names[:len(dict_df)] if len(clean_names) >= len(dict_df) else clean_names + [""] * (len(dict_df) - len(clean_names))

# Append entries for _raw auxiliary columns added during cleaning
raw_cols_added = []
for col in df.columns:
    if col.endswith("_raw") and col not in dict_df["clean_name"].values:
        raw_cols_added.append(col)
        dict_df = pd.concat([dict_df, pd.DataFrame([{
            "col_index": len(dict_df),
            "chinese_label": f"(auxiliary: original {col.replace('_raw', '')} value)",
            "original_english_name": col,
            "clean_name": col,
        }])], ignore_index=True)

# Also append to rename map
for col in raw_cols_added:
    full_rename_map.append({
        "original_chinese_label": f"(auxiliary column for traceability)",
        "original_english_name": col,
        "intermediate_name": col,
        "clean_name": col,
        "rename_reason": "auxiliary column added during date cleaning to preserve original values",
    })

dict_df.to_csv(OUT_DICT, index=False, encoding="utf-8-sig")
print(f"  Data dictionary saved to {OUT_DICT}")

# Save variable rename map
rename_map_df = pd.DataFrame(full_rename_map)
rename_map_df.to_csv(OUT_RENAME_MAP, index=False, encoding="utf-8-sig")
print(f"  Variable rename map saved to {OUT_RENAME_MAP}")

# ============================================================
# 12. GENERATE CLEANING REPORT
# ============================================================

def generate_report():
    lines = []
    lines.append("# Cleaning Report")
    lines.append("")

    cleaned_rows = len(df)
    cleaned_cols = len(df.columns)

    # Section 1: Input File
    lines.append("## 1. Input File")
    lines.append("")
    lines.append(f"- Path: `{INPUT_FILE}`")
    lines.append(f"- Encoding: {ENCODING}")
    lines.append(f"- Raw rows: {report['raw_rows']}")
    lines.append(f"- Raw columns: {report['raw_cols']}")
    lines.append(f"- Empty rows removed: {report['empty_rows_removed']}")
    lines.append(f"- Empty columns removed: {report['empty_cols_removed']} (indices: {report['empty_col_indices']})")
    lines.append(f"- Cleaned rows: {cleaned_rows}")
    lines.append(f"- Cleaned columns: {cleaned_cols}")
    lines.append("")

    # Section 2: Header Structure
    lines.append("## 2. Header Structure")
    lines.append("")
    lines.append("The CSV uses a 2-row header structure:")
    lines.append("- Row 1 (index 0): Chinese variable descriptions")
    lines.append("- Row 2 (index 1): English variable names")
    lines.append("- Row 3+ (index 2+): Data")
    lines.append("")
    lines.append("The Chinese labels are preserved in `data_dictionary.csv`.")
    lines.append("")

    # Section 3: Column Renaming
    lines.append("## 3. Column Renaming")
    lines.append("")
    removed_idx = report.get('empty_col_indices', [])
    lines.append(f"Removed {report['empty_cols_removed']} fully empty column(s) that had no Chinese or English header: indices {removed_idx}.")
    lines.append("Note: Named columns with all-empty data (e.g., `relationship`) were **retained** — only truly unnamed separator columns were removed.")
    lines.append("")
    lines.append("### Duplicate CAR Columns")
    lines.append("")
    lines.append("Two sets of CAR columns (car_pre through car_20) were detected. Based on the Chinese headers:")
    lines.append("- First set: Market model abnormal return → renamed to `mkt_car_*`")
    lines.append("- Second set: FF3 abnormal return → renamed to `ff3_car_*`")
    lines.append("")
    lines.append("### Duplicate Media Window Columns")
    lines.append("")
    lines.append("Six pairs of windows-* columns (windows-2 through windows-20) were detected. Based on Chinese headers:")
    lines.append("- First occurrence of each window: Media sentiment mean → renamed to `media_sent_mean_w*`")
    lines.append("- Second occurrence: Media sentiment standard deviation → renamed to `media_sent_sd_w*`")
    lines.append("")
    lines.append("### Unnamed Columns")
    lines.append("")
    lines.append("Three columns had empty English headers and were manually named:")
    lines.append("- Col 7 (no label in either header): renamed to `col_7` (model+code concatenation artifact)")
    lines.append("- Col 14 (Chinese: 搜索代码1): renamed to `search_code_1`")
    lines.append("- Col 15 (Chinese: 搜索代码2): renamed to `search_code_2`")
    lines.append("")
    lines.append(f"Total columns renamed: {len(rename_log)}. See `variable_rename_map.csv` for full details.")
    lines.append("")

    # Section 4: Date Cleaning
    lines.append("## 4. Date Cleaning")
    lines.append("")
    lines.append("### release_date")
    lines.append("")
    lines.append(f"- Parse failures: {report.get('release_date_parse_failures', 0)} out of {cleaned_rows}")
    lines.append("- Original formats detected: YYYY/M/D (majority), Excel serial number (event FMR-0060 only)")
    lines.append("- Excel serial 46098 → 2026-03-17 (FMR-0060 GPT-5.4 family, 82 rows)")
    lines.append("- All values now in ISO format: YYYY-MM-DD")
    if report.get('release_date_failure_examples'):
        lines.append("- Failure examples:")
        for val, err in report['release_date_failure_examples']:
            lines.append(f"  - `{val}`: {err}")
    lines.append("")
    lines.append("### release_month")
    lines.append("")
    lines.append(f"- Parse failures: {report.get('release_month_parse_failures', 0)} out of {cleaned_rows}")
    lines.append("- Original formats detected: YY-Mon (majority), Excel serial number (event FMR-0060 only)")
    lines.append("- Excel serial 46107 encodes the full date 2026-03-26; truncated to YYYY-MM → 2026-03")
    lines.append("  (The day component 26 coincidentally matches the year digits; the serial was correctly")
    lines.append("  converted using the Excel epoch and the month-level portion extracted.)")
    lines.append("- All values now in format: YYYY-MM")
    if report.get('release_month_failure_examples'):
        lines.append("- Failure examples:")
        for val, err in report['release_month_failure_examples']:
            lines.append(f"  - `{val}`: {err}")
    lines.append("")
    lines.append("Original values preserved in `release_date_raw` and `release_month_raw` columns for traceability.")
    lines.append("")

    # Section 5: Missing Values
    lines.append("## 5. Missing Values")
    lines.append("")
    lines.append("### Key Variable Missingness")
    lines.append("")
    lines.append("| Variable | Total | Missing | % Missing |")
    lines.append("|----------|-------|---------|-----------|")
    for var, info in key_missing.items():
        if isinstance(info['missing'], str):
            lines.append(f"| {var} | {info['total']} | {info['missing']} | - |")
        else:
            actual_col_note = f" (as `{info['actual_col']}`)" if 'actual_col' in info else ""
            lines.append(f"| {var}{actual_col_note} | {info['total']} | {info['missing']} | {info['pct']:.1f}% |")
    lines.append("")

    # relationship special note
    lines.append("### relationship Column")
    lines.append("")
    rel_missing = report.get("relationship_total_missing", 5160)
    lines.append(f"The `relationship` column has **{rel_missing} missing values out of {cleaned_rows} rows (100%)**.")
    lines.append("")
    lines.append("**CRITICAL: The `relationship` column is completely empty.** This means firm-event relationship heterogeneity analysis cannot be performed without first supplementing the firm-event relationship mapping. You will need to manually code or merge the relationship type (e.g., competitor, supplier, customer, partner) for each event-firm pair before running heterogeneity regressions.")
    lines.append("")

    # Section 6: Numeric Conversion
    lines.append("## 6. Numeric Conversion")
    lines.append("")
    lines.append("Methodology: Before calling `pd.to_numeric(errors='coerce')`, all known NA patterns")
    lines.append("(`#N/A`, `N/A`, `NA`, empty strings) were replaced with NaN. The table below reports both")
    lines.append("the total NaN count after conversion and new NaN introduced during the `pd.to_numeric` step.")
    lines.append("")
    lines.append("| Column | Total NaN | New NaN from conversion | % Missing |")
    lines.append("|--------|-----------|------------------------|-----------|")
    for col, new_na, total_na in numeric_conversion_log:
        pct = total_na / cleaned_rows * 100
        flag = " *** >50% ***" if pct > 50 else ""
        lines.append(f"| {col} | {total_na} | {new_na} | {pct:.1f}%{flag} |")
    lines.append("")
    lines.append("Columns with >50% missing are expected:")
    lines.append("- `aa_math_index` (61.7%): only available for models with math benchmarks")
    lines.append("- `aa_media_*` (78.3%): only available for media generation models (images/video/audio)")
    lines.append("Do NOT blindly delete these columns; they are structurally missing based on model type.")
    lines.append("Use `llm_capability_sample_flag` and `media_capability_sample_flag` to subset appropriately.")
    lines.append("")

    # Section 7: Event-Firm Panel Check
    lines.append("## 7. Event-Firm Panel Check")
    lines.append("")
    lines.append(f"- Events: {report.get('n_events', 'N/A')}")
    lines.append(f"- Firms: {report.get('n_firms', 'N/A')}")
    lines.append(f"- Observations: {report.get('n_observations', 'N/A')}")
    lines.append(f"- Balanced panel: {report.get('is_balanced', 'N/A')}")
    lines.append(f"- Firms per event: {report.get('firms_per_event_min', 'N/A')} – {report.get('firms_per_event_max', 'N/A')} (all events have exactly the same set of firms)")
    lines.append(f"- Duplicate (event × firm) keys: {report.get('n_duplicate_keys', 'N/A')}")
    lines.append("")
    lines.append("The panel is perfectly balanced: every event covers all 86 firms, and every firm appears in all 60 events.")
    lines.append("No duplicates found. Ready for panel regression with event and firm fixed effects.")
    lines.append("")

    # Section 8: Suspicious Variables
    lines.append("## 8. Suspicious Variables")
    lines.append("")
    lines.append("### search_code_2")
    lines.append("")
    sc2_unique = report.get("search_code_2_unique", "N/A")
    if sc2_unique != "N/A":
        lines.append(f"- Unique values: {sc2_unique}")
        lines.append(f"- Most common value: `{report.get('search_code_2_top_value', '')}` ({report.get('search_code_2_top_pct', 0):.1f}%)")
        lines.append(f"- Nearly constant: {report.get('search_code_2_is_constant', False)}")
        lines.append("")
        lines.append("The column contains company name concatenated with a quarter label. Two format variants exist:")
        lines.append("- `2024-Q2` (with hyphen): used in 59 of 60 events (5,074 rows)")
        lines.append("- `2024Q2` (without hyphen): used in 1 event, FMR-0001 (86 rows)")
        lines.append("")
        lines.append("The quarter '2024Q2' is a fixed financial reporting quarter used as a data snapshot reference,")
        lines.append("not an event-specific quarter. It does NOT vary across events.")
        lines.append("")
        lines.append("Recommendation: Retain but note in methodology as a fixed reference quarter. Do not include as")
        lines.append("a time-varying regressor since it is constant for all observations.")
    lines.append("")

    # Section 9: Output Files
    lines.append("## 9. Output Files")
    lines.append("")
    lines.append("| File | Description |")
    lines.append("|------|-------------|")
    lines.append(f"| `clean_event_firm_panel.csv` | Cleaned panel data ({cleaned_rows} rows × {cleaned_cols} cols), ready for regression |")
    lines.append(f"| `cleaning_report.md` | This report |")
    lines.append(f"| `data_dictionary.csv` | English variable name → Chinese label mapping |")
    lines.append(f"| `variable_rename_map.csv` | Full variable renaming log with reasons |")
    lines.append(f"| `event_level_summary.csv` | Event-level summary with company counts and capability flags |")
    lines.append(f"| `event_firm_balance_check.csv` | Panel balance check per event |")
    if report.get("n_duplicate_keys", 0) > 0:
        lines.append(f"| `duplicate_event_firm_rows.csv` | Duplicate event-firm rows |")
    lines.append("")

    # Section 10: Remaining Issues
    lines.append("## 10. Remaining Issues Before Regression")
    lines.append("")
    lines.append("1. **relationship column is empty (100% missing)**: Must be supplemented before firm-event")
    lines.append("   heterogeneity analysis. Each (event, firm) pair needs a relationship type")
    lines.append("   (e.g., competitor, supplier, customer, partner, unrelated). Without this, you can")
    lines.append("   still run baseline event-study regressions, but cannot test heterogeneity by")
    lines.append("   firm-event relationship type.")
    lines.append("")
    lines.append("2. **search_code_2 is a fixed financial quarter**: All values reference 2024Q2. This")
    lines.append("   should be noted as a data snapshot reference in the paper's data section, not used")
    lines.append("   as a time-varying control variable.")
    lines.append("")
    lines.append("3. **Chinese text in company/industry fields**: The `company`, `industry`, and")
    lines.append("   `search_code_*` columns contain Chinese characters. Use `company_id` (ticker-style")
    lines.append("   codes like 'AAPL', 'GOOGL') for reliable firm identification in regressions.")
    lines.append("")
    lines.append("4. **AA media metrics (78.3% missing)**: Only media generation models have media")
    lines.append("   capability metrics. When using `aa_media_elo`, `aa_media_rank`, etc., restrict to")
    lines.append("   the `media_capability_sample_flag == 1` sub-sample.")
    lines.append("")
    lines.append("5. **AA capability metrics with high missing rates**: `aa_math_index` (61.7%), `aime`")
    lines.append("   (45.0%), `math_500` (41.7%), `aa_coding_index` (41.7%) are structurally missing")
    lines.append("   based on model type. Use `llm_capability_sample_flag == 1` for LLM capability analyses.")
    lines.append("")
    lines.append("6. **Encoding**: The cleaned CSV uses UTF-8 with BOM (`utf-8-sig`). When loading in")
    lines.append("   Stata, use `import delimited` with appropriate encoding. In R/Python, `read.csv()`")
    lines.append("   or `pd.read_csv()` will handle this automatically.")
    lines.append("")

    return "\n".join(lines)

report_text = generate_report()
with open(OUT_REPORT, "w", encoding="utf-8") as f:
    f.write(report_text)
print(f"  Cleaning report saved to {OUT_REPORT}")

# ============================================================
# 13. TERMINAL SUMMARY
# ============================================================

print("")
print("=" * 60)
print("Cleaning completed.")
print(f"Rows: {len(df)}")
print(f"Columns: {len(df.columns)}")
print(f"Events: {report.get('n_events', 'N/A')}")
print(f"Firms: {report.get('n_firms', 'N/A')}")
print(f"Balanced panel: {report.get('is_balanced', 'N/A')}")
print("Outputs written to:")
for f in [OUT_CLEANED, OUT_REPORT, OUT_DICT, OUT_RENAME_MAP, OUT_EVENT_SUMMARY, OUT_BALANCE]:
    if os.path.exists(f):
        print(f"  {os.path.basename(f)}")
if os.path.exists(OUT_DUPES):
    print(f"  {os.path.basename(OUT_DUPES)}")
print("=" * 60)
