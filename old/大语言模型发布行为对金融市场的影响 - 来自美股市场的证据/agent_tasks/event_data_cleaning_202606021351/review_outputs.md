# Data Cleaning Output Review

**Review date:** 2026-06-02
**Reviewer:** Automated data quality check (Python/pandas)

---

## 1. Main Cleaned Data: `clean_event_firm_panel.csv`

### 1.1 Basic Load & Shape

- Loads successfully with UTF-8 encoding.
- Shape: **5160 rows x 106 columns**.
- 60 unique events x 86 unique companies = 5,160 rows. Consistent: all events have exactly 86 companies. Zero duplicate rows.
- Data is properly sorted by `final_event_id` then `company_id`.

### 1.2 Column Name Conventions

- **PASS.** All column names are lowercase, no spaces, no hyphens, no special ASCII characters.
- **MINOR ISSUE:** Two columns contain Chinese characters in their names: `unnamed_搜索代码1` and `unnamed_搜索代码2`. While no other special chars are present, the presence of Chinese in column names deviates from a pure-ASCII convention. These are leftover columns from the source data that were not given clean English names.

### 1.3 CAR Column Renaming

- **PASS.** 8 `mkt_car_*` columns: `mkt_car_pre`, `mkt_car_1`, `mkt_car_2`, `mkt_car_3`, `mkt_car_5`, `mkt_car_10`, `mkt_car_15`, `mkt_car_20`.
- **PASS.** 8 `ff3_car_*` columns: `ff3_car_pre`, `ff3_car_1`, `ff3_car_2`, `ff3_car_3`, `ff3_car_5`, `ff3_car_10`, `ff3_car_15`, `ff3_car_20`.
- All correctly prefixed. Ranges are reasonable (mkt_car mostly in [-3, +2], ff3_car similar).

### 1.4 Media Sentiment Column Renaming

- **PASS.** 6 `media_sent_mean_w*` columns: w2, w3, w5, w10, w15, w20.
- **PASS.** 6 `media_sent_sd_w*` columns: w2, w3, w5, w10, w15, w20.
- All correctly named and suffixed by window length.

### 1.5 Date Parsing

- **PASS.** `release_date` for **FMR-0060** is `2026-03-17` -- correct.
- **PASS.** All 60 unique events have `release_date` values in consistent `YYYY-MM-DD` string format.
- **NOTE:** `release_date` is stored as `str` (object dtype), not `datetime64`. This is acceptable for a cleaned CSV since the format is invariant, but downstream scripts will need `pd.to_datetime()`.
- **ISSUE (data quality, not cleaning script):** The `release_date_raw` column has corrupted data for FMR-0060. 82 out of 86 rows contain the Excel serial date number `46098` instead of a date string. Only 4 rows have the correct `2026/3/17`. The serial number `46098` corresponds to 2026-03-17 in Excel's 1900 date system, so this is an upstream Excel serial date leak that was not caught or normalized during cleaning. Similarly, `release_month_raw` has `46107` (another Excel serial number) for these 82 rows instead of `26-Mar`.

### 1.6 Numeric Column Types

- **PASS.** 53 `float64` columns + 14 `int64` columns. All numeric variables have correct types.
- No object columns that should be numeric were found.
- 39 `str` (object) columns, all appropriate (IDs, names, labels, URLs).

### 1.7 Missing Values

- Missing values are **structurally correct**:
  - `aa_media_*` columns (6 columns) are non-null only for the 13 media-capability events (1,118 rows).
  - `aa_intelligence_index`, `mmlu_pro`, `gpqa`, `hle`, `livecodebench`, `scicode` are non-null only for the 47 LLM-capability events (3,354-4,042 rows).
  - `size_log_assets`: 85 missing (1.6%), `bm_ratio`: 130 missing (2.5%), `volatility`: 227 missing (4.4%), `momentum`: 268 missing (5.2%) -- consistent with firms lacking Compustat/CRSP coverage.
  - CAR columns: ~80-130 missing each, consistent with financial data availability.

### 1.8 Data Integrity

- **PASS.** No duplicate rows.
- **PASS.** No apparent value shifting between columns (spot-checked row 0 against column meanings).
- **PASS.** All 60 `final_event_id` values are FMR-0001 through FMR-0060, matching the event summary file exactly.
- **PASS.** 86 companies per event, all events have identical company panel (balanced panel).

### 1.9 Numeric Range Sanity

- All ranges are reasonable for financial/benchmark data.
- **NOTABLE BUT NOT ERRORS:**
  - `momentum`: max 33.64 (QUBT in events FMR-0043-FMR-0050). Real but extreme.
  - `volatility`: max 7.80 (several semiconductor firms in FMR-0033). Real but extreme.
  - `aa_media_ci95`: ALL non-null values are exactly -1.0 (std=0). This is clearly a sentinel/placeholder value, not real confidence interval data.
  - `price_1m_input_tokens` and `price_1m_output_tokens`: min is 0.00 (likely for open-weight/free models).

### 1.10 Leftover / Unnamed Columns

- **`unnamed_col_7`** (column index 7): Contains `event_name` concatenated with what appears to be a source-data row index (e.g., "LLaMA 345400"). This is an artifact from the original dataset merge, not informative. 60 unique values, one per event.
- **`unnamed_搜索代码1`** and **`unnamed_搜索代码2`** (columns 13, 14): Search code fields still using their original Chinese-tagged names. These are populated (4,472 and 172 unique values respectively) and appear to be company-search-key strings.

---

## 2. `data_dictionary.csv`

### 2.1 Coverage

- 104 rows (1 header + 103 data rows).
- **ISSUE: Missing 2 columns** that exist in the actual data:
  - `release_date_raw` (column index 104 in data)
  - `release_month_raw` (column index 105 in data)
- All other 104 actual columns are documented.

### 2.2 Chinese-English Mapping Quality

- **PARTIAL PASS.** Core variables (columns 0-21) and CAR/media columns (22-49) have correct Chinese labels.
- **ISSUE: Incomplete Chinese labels.** Columns 72-103 (AA model IDs, benchmark scores, pricing, media metrics, date confidence, source URLs) have `(empty)` for their Chinese labels. This leaves 32 columns without Chinese descriptions, making the dictionary incomplete for Chinese-speaking users. Specific columns needing Chinese labels:
  - `representative_aa_model_id` through `representative_selection_rule` (columns 72-78)
  - All AA benchmark scores: `aa_coding_index` through `aime` (columns 80-88)
  - All pricing/speed metrics: `price_1m_input_tokens` through `median_time_to_first_answer_token` (columns 89-94)
  - All media metrics: `aa_media_task` through `aa_media_category_rows` (columns 95-100)
  - `release_date_confidence` through `release_source_titles` (columns 101-103)

---

## 3. `variable_rename_map.csv`

### 3.1 Coverage

- 104 rows (1 header + 103 data rows).
- **ISSUE: Same 2 columns missing** as data_dictionary: `release_date_raw` and `release_month_raw`.
- All other 104 actual columns have documented rename mappings.
- The `rename_reason` column correctly identifies CAR, media, and unnamed columns as "renamed from duplicate or unnamed" vs "normalized" for others.

### 3.2 Mapping Accuracy

- **PASS.** All CAR column renames documented (`car_pre` -> `mkt_car_pre`, etc.; `car_pre` -> `ff3_car_pre`, etc.).
- **PASS.** All media sentiment renames documented (`windows-2` -> `media_sent_mean_w2`, etc.).
- **PASS.** `unnamed_col_7`, `unnamed_搜索代码1`, `unnamed_搜索代码2` correctly marked as "renamed from duplicate or unnamed".

---

## 4. `event_level_summary.csv`

### 4.1 Event Counts

- **PASS.** Exactly 60 events (FMR-0001 through FMR-0060).
- **PASS.** All events show `company_count=86`, matching the panel data.
- **PASS.** Event IDs exactly match the panel's unique `final_event_id` values (set difference = empty).

### 4.2 Content Quality

- Columns: `final_event_id`, `event_name`, `release_date`, `release_month`, `true_model_creator`, `creator_country`, `creator_type`, `model_family`, `candidate_tier`, `company_count`, `has_llm_metrics`, `has_media_metrics`.
- **PASS.** Dates are consistent with panel data.
- **PASS.** `has_llm_metrics` and `has_media_metrics` are mutually exclusive (no event has both True), which correctly matches the panel data (0 overlap between LLC and media capability samples).
- **NOTE:** Two event names appear twice (different release dates):
  - "Imagen 3": FMR-0002 (2024-05-14) and FMR-0007 (2024-08-28)
  - "Gemini 2.5 Pro": FMR-0036 (2025-05-06) and FMR-0042 (2025-06-17)
  - These are distinct releases sharing the same product name. Not an error, but worth noting for analysis that `event_name` is not a unique key.

---

## 5. `event_firm_balance_check.csv`

### 5.1 Structure

- 60 rows (1 header + 59 data rows = 60 events).
- Columns: `final_event_id`, `company_count`, `event_name`, `is_typical`.
- **PASS.** All events have `company_count=86`.
- **PASS.** All events have `is_typical=True` (boolean, parsed by pandas as `True`).
- Event IDs match 1:1 with the panel data.

### 5.2 Usefulness

- This file confirms the panel is balanced (identical company set across all events). It serves its purpose as a validation artifact.

---

## Summary of Issues

| # | Severity | File | Issue |
|---|----------|------|-------|
| 1 | **Medium** | `clean_event_firm_panel.csv` | `release_date_raw` for FMR-0060: 82/86 rows contain Excel serial number `46098` instead of date string. `release_month_raw` similarly corrupted with `46107`. The cleaned `release_date` column is correct; the `_raw` columns were not sanitized. |
| 2 | **Low** | `data_dictionary.csv` | Missing entries for `release_date_raw` and `release_month_raw`. Also, 32 columns lack Chinese labels (marked "(empty)"). |
| 3 | **Low** | `variable_rename_map.csv` | Missing entries for `release_date_raw` and `release_month_raw`. |
| 4 | **Low** | `clean_event_firm_panel.csv` | `unnamed_搜索代码1` and `unnamed_搜索代码2` contain Chinese characters in their column names, inconsistent with the otherwise clean lowercase ASCII convention. |
| 5 | **Info** | `clean_event_firm_panel.csv` | `unnamed_col_7` is an artifact column (event_name + source row index). Not harmful but should be documented or dropped if unused. |
| 6 | **Info** | `clean_event_firm_panel.csv` | `aa_media_ci95` is a constant -1.0 for all 1,118 non-null values -- a sentinel value, not real data. Analysts should be warned. |
| 7 | **Info** | `clean_event_firm_panel.csv` | `release_date` stored as `str` not `datetime64`. Format is consistent YYYY-MM-DD, so `pd.to_datetime()` works trivially. |
| 8 | **Info** | All files | Two events share the name "Imagen 3" and two share "Gemini 2.5 Pro" (distinct dates). `event_name` is not unique. |

---

## Overall Assessment

The cleaned dataset is **largely sound and analytically usable**. The core cleaning tasks (column renaming, CAR/media column standardization, event-firm panel construction, date parsing) were executed correctly. The main panel of 5,160 rows x 106 columns is well-structured with a proper balanced design (60 events x 86 firms).

**Actionable fixes recommended:**
1. Sanitize `release_date_raw` and `release_month_raw` to remove Excel serial number leakage.
2. Add the missing `release_date_raw` and `release_month_raw` entries to both `data_dictionary.csv` and `variable_rename_map.csv`.
3. Fill in the 32 missing Chinese labels in `data_dictionary.csv` for completeness.
4. Consider renaming `unnamed_搜索代码1` and `unnamed_搜索代码2` to ASCII-only names (e.g., `search_code_1`, `search_code_2`).
