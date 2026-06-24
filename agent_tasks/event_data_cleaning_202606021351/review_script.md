# Review of `clean_event_panel.py`

## Overall Assessment

The script is generally well-structured with good defensive coding (column existence checks throughout). However, several definite bugs, dead code blocks, and fragile assumptions were found that should be addressed before trusting the output.

---

## 1. GB18030 Encoding

**PASS** — The script uses `ENCODING = "gb18030"` consistently for input (`pd.read_csv` with `encoding=encoding`). GB18030 is a proper superset of GBK/GB2312 and handles all Chinese characters. Output files use `utf-8-sig` which is the correct choice for cross-tool compatibility (Stata, R, Excel all read UTF-8-BOM correctly).

---

## 2. Two-Row Header Structure

**PASS** — The `read_raw_data()` function correctly reads row 0 as Chinese headers, row 1 as English headers, and rows 2+ as data. Three separate `pd.read_csv` calls are used, which is correct for this header layout. `keep_default_na=False` ensures empty cells are preserved as empty strings rather than being auto-converted to NaN (important for distinguishing missing data from empty-string sentinels).

---

## 3. Duplicate Column Name Removal (CAR and Media Windows)

**PASS with caveat** — The logic to disambiguate `car_*` into `mkt_car_*` (market model) and `ff3_car_*` (FF3 model), and `windows-*` into `media_sent_mean_w*` (mean) and `media_sent_sd_w*` (SD), is correct in principle. However, it relies on **ordinal position** (first occurrence = market model, second = FF3). If the columns were reordered in the source CSV (e.g., during data entry), this mapping would silently produce wrong assignments. The Chinese header text is read but never used to verify the assignment. A more robust approach would parse the Chinese headers to confirm which set is market-model vs. FF3.

---

## 4. Date Parser

**MIXED** — Several issues found:

### 4a. Duplicate format entries (harmless dead code)
Line 287: the format list `["%Y/%m/%d", "%Y-%m-%d", "%Y/%m/%d", "%Y-%m-%d"]` contains duplicated entries. The second pair is dead code.

### 4b. Duplicate `%y-%b` lowercase block (dead code)
Lines 302-306 are byte-for-byte identical to lines 295-299. The second block will never execute (the first would succeed or fail identically). This was probably meant to handle a different case.

### 4c. `parse_month_to_ym` lowercase handling is INEFFECTIVE
Line 343: `s.capitalize()` on `"24-apr"` produces `"24-apr"` (unchanged, because the first character `2` is not a letter). The correct fix for a fully-lowercase month abbreviation would be something like:
```python
parts = s.split('-')
if len(parts) == 2:
    s = parts[0] + '-' + parts[1].capitalize()  # "24-apr" -> "24-Apr"
```
As written, fully-lowercase month abbreviations in `release_month` (e.g., `"24-apr"`) will fail parsing and produce `pd.NA`.

### 4d. Missing format: `%Y-%b` and `%Y-%b-%d`
Neither `parse_date_mixed` nor `parse_month_to_ym` handles 4-digit year with abbreviated month (e.g., `"2024-Apr"`, `"2024-Apr-15"`). Only 2-digit year (`%y`) is handled. If the source data contains 4-digit years with month abbreviations, they will fail parsing.

### 4e. Missing format: datetime with time component
If any date field contains a time component (e.g., `"2024/03/17 10:30:00"` from a database export), it will fail all parsing attempts.

### 4f. Excel serial range is reasonable but could truncate
Lines 280, 328: The range `40000 <= serial <= 60000` covers 2009-07-05 to 2064-04-03. If any event predates July 2009 (e.g., older financial data joined in), its Excel serial would be silently treated as unparseable.

### 4g. Unused constant
Line 31: `EXCEL_EPOCH = "1899-12-30"` is defined as a constant but never used; the epoch is hardcoded as `datetime(1899, 12, 30)` on lines 281, 329, 365. This is dead configuration.

---

## 5. Edge Cases Not Covered

### 5a. Chinese characters in normalized column names
Line 202 has a comment: `# Replace Chinese characters with a placeholder (rare, but handle)` — but there is **no code** following the comment that actually removes or transliterates Chinese characters. Chinese characters survive normalization intact. If the English header was empty and the Chinese label was used (line 140: `f"unnamed_{chi.strip()}"`), the resulting clean name will contain Chinese characters (e.g., `unnamed_搜索代码2`). This may cause issues in Stata (which limits variable names to ASCII) or when column names are used as dictionary keys.

### 5b. No handling of YYYYMMDD / YYYYMM integer date formats
Integer strings like `"20240317"` (8 digits) or `"202403"` (6 digits) are not handled. A value like `"20240317"` would fail `int(s)` and then fail all `strptime` format attempts. The Excel serial check would pass `int(s)` (since 20240317 is an integer) but would be rejected by the `40000 <= serial <= 60000` range check, so it falls through. This is correct behavior for now but means YYYYMMDD dates would be silently marked as unparseable rather than producing a useful error.

### 5c. Stale/misleading variable name normalization comment on Chinese characters
As noted in 5a, the comment on line 202 promises functionality that does not exist.

---

## 6. Hardcoded / Fragile Logic

### 6a. Hardcoded numeric candidate list (lines 400-427)
The list of columns to convert to numeric is hardcoded by exact name match. If any column name changes slightly (e.g., `size_log_assets` becomes `size_log_assets_2` due to duplicate resolution), it would silently be left as a string column. A pattern-based approach (e.g., checking if the name contains known numeric suffixes like `_car_`) would be more robust, combined with `pd.to_numeric(errors="coerce")` as a safety net.

### 6b. Hardcoded key_vars list (lines 554-559)
Expected CAR window names like `"mkt_car_1"`, `"ff3_car_5"` etc. are hardcoded. If the duplicate-resolution logic added suffixes (e.g., `mkt_car_1_2`), these would not be found by exact match. The partial-match fallback (line 573) helps but could match the wrong column.

### 6c. Hardcoded column index references in report (lines 661-663)
Lines 661-663 reference specific original column indices (7, 14, 15) with descriptions like "Col 7 (model+code concatenation)" and "Col 15 (搜索代码2)". These indices refer to the **original** column positions before empty-column removal. If the source CSV changes (columns added/removed), these hardcoded references become wrong but the report text will not update automatically.

### 6d. `search_code_2` detection uses confusing boolean logic (line 532)
```python
if "search_code_2" in col or "unnamed" in col and "搜索代码2" in col:
```
Due to Python operator precedence (`and` binds tighter than `or`), this is parsed as:
```python
if "search_code_2" in col or ("unnamed" in col and "搜索代码2" in col):
```
This happens to be the intended logic, but the lack of parentheses makes the code error-prone to future edits.

### 6e. `full_rename_map` reason uses a tautological condition (line 249)
```python
"rename_reason": "normalized" if eng and eng.strip() == eng.strip() and eng == new_names[i] else ...
```
`eng.strip() == eng.strip()` is **always True**. This is dead logic that masks what the actual intent was (likely: check if the English name was non-empty and unchanged from its original stripped form).

---

## 7. Output Completeness

**CONDITIONAL PASS** — Seven outputs are declared (lines 10-15). Six are always produced, and `duplicate_event_firm_rows.csv` is conditional on duplicates being found. This is correct. However:

- `OUT_DUPES` (line 40) is defined and conditionally written (line 488), but if no duplicates exist, it is silently skipped. This is fine.
- All 7 file paths use `os.path.join(SCRIPT_DIR, ...)` which resolves relative to the script's location. This is correct.
- Output encoding (`utf-8-sig`) is consistent and appropriate for Stata/R/Python interoperability.

---

## 8. Bugs and Logical Errors

### BUG 1 (Medium): `parse_month_to_ym` fails on lowercase month abbreviations
As described in 4c, `s.capitalize()` does not fix `"24-apr"`. If `release_month` contains fully-lowercase month abbreviations (common in some data exports), they will fail to parse. **Impact**: silent data loss (NA values) for those rows.

### BUG 2 (Low): `rename_log` is overwritten twice (lines 236-258)
The `rename_log` is first updated at lines 236-238, then immediately overwritten at lines 253-258. The second block extracts the third tuple element into variable `_` (overwriting Python's `_` convention) and then looks it up in `new_names` — but after the first update, this value is already the **clean name**. The lookup `new_names.index(_)` is searching for a clean name in the list of pre-normalization intermediate names, which will generally fail (return -1), causing `clean_names[-1]` to be used (the last clean name, not necessarily the correct one). This is a logic error that could produce wrong rename log entries.

### BUG 3 (Low): Operator precedence in `search_code_2` detection (line 532)
As described in 6d. While the current behavior happens to be correct (due to the structure of the conditions), this is fragile and should be parenthesized explicitly.

### BUG 4 (Low): Unused `EXCEL_EPOCH` constant
Line 31 defines `EXCEL_EPOCH` but the date parsers hardcode `datetime(1899, 12, 30)`. If the epoch were ever changed (e.g., some Excel versions use 1900-01-01 or 1904-01-01), the constant would need updating in multiple places.

### LOGIC ISSUE 5 (Low): `full_rename_map` reason field is always "normalized" for unnamed columns
For columns whose English header was empty, `eng` is `""`, so `eng` is falsy, and the reason becomes `"renamed from duplicate or unnamed"` — which is correct. But for columns that were disambiguated (duplicate CAR/windows), the reason is also `"renamed from duplicate or unnamed"`, which is vague. It would be more useful to distinguish between "renamed from duplicate", "renamed from unnamed", and "normalized".

---

## 9. Variable Normalization

**PASS with edge case** — The `normalize_varname()` function (lines 192-212) correctly:
- Replaces hyphens and spaces with underscores
- Removes parentheses, brackets, slashes
- Replaces `%` with `pct`
- Collapses multiple underscores
- Strips leading/trailing underscores
- Converts to lowercase
- Prefixes digit-starting names with `v_`

**Edge case**: Chinese characters are not removed (see 5a). This is inconsistent with the comment on line 202.

**Duplicate resolution**: Lines 217-233 correctly handle the edge case where normalization creates new collisions (e.g., two columns `car-1` and `car_1` both normalize to `car_1`). The second occurrence gets a `_2` suffix. This is good defensive coding.

---

## 10. Error Handling

**PASS** — The script does not crash on missing columns. Key patterns observed:

- `if release_date_col:` (line 361) checks before date parsing
- `if eid_col and cid_col:` (line 458) guards the panel structure check
- `if col in df.columns:` (lines 432, 439, 519) guards numeric conversion and flag aggregation
- `if sc2_col and sc2_col in df.columns:` (line 543) guards search_code_2 analysis
- Partial match fallback in key_missing (lines 572-582) provides graceful degradation

The script will produce a partial output even if many expected columns are absent, and the cleaning report will document what was found vs. missing. This is good defensive design.

**One gap**: If `empty_col_mask` has zero columns removed (i.e., no fully empty columns), the filtering on line 107-109 is a no-op. This is correct. However, if ALL columns were empty (pathological case), `df.loc[:, ~empty_col_mask]` would produce an empty DataFrame and the script would continue with 0 columns, eventually failing in confusing ways. Adding a guard for `len(df.columns) == 0` at line 103 would make this more robust.

---

## Summary of Issues by Severity

| # | Severity | Description | Location |
|---|----------|-------------|----------|
| 1 | Medium | `parse_month_to_ym` fails on lowercase month abbreviations (`"24-apr"`) | Line 343 |
| 2 | Medium | `rename_log` is overwritten twice; second pass has broken lookup logic | Lines 236-258 |
| 3 | Low | Comment promises Chinese character removal but no code does it | Line 202 |
| 4 | Low | Duplicate `%y-%b` parsing block (dead code) | Lines 302-306 |
| 5 | Low | Unused `EXCEL_EPOCH` constant | Line 31 |
| 6 | Low | Tautological condition `eng.strip() == eng.strip()` | Line 249 |
| 7 | Low | Operator precedence without parentheses in `search_code_2` search | Line 532 |
| 8 | Low | Missing `%Y-%b` and `%Y-%b-%d` date formats | Lines 287-313 |
| 9 | Info | Duplicate entries in date format list | Line 287 |
| 10 | Info | Hardcoded numeric candidate list is fragile to column name changes | Lines 400-427 |
| 11 | Info | Hardcoded column indices in report text won't auto-update | Lines 661-663 |
| 12 | Info | No guard for 0-column DataFrame after empty-column removal | Line 102 |

### Recommended Fixes (in priority order)

1. **Fix `parse_month_to_ym` lowercase handling** — replace `s.capitalize()` with proper month-abbreviation capitalization (split on `-`, capitalize only the month part).
2. **Remove the duplicate `rename_log` update** — delete lines 253-258, which undo the already-correct update at lines 236-238.
3. **Remove the dead `%y-%b` block** (lines 302-306) and add `%Y-%b` and `%Y-%b-%d` format support instead.
4. **Either implement Chinese character transliteration or remove the misleading comment** on line 202.
5. **Add time-component-tolerant date parsing** (try `"%Y/%m/%d %H:%M:%S"` and variants).
6. **Parenthesize the boolean expression** on line 532 for clarity.
7. **Either use `EXCEL_EPOCH` constant or remove it**.
