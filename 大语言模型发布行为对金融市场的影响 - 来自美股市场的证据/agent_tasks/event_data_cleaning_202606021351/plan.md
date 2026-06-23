# Multi-Agent Execution Plan: Event Data Cleaning

## Task: Clean 事件集数据.csv for event-study regression analysis

## Data Summary (from initial exploration)
- **File**: `事件集数据.csv` (6.5MB, GB18030 encoding, Windows line endings)
- **Structure**: Row 0 = Chinese headers, Row 1 = English headers, Rows 2+ = data
- **Dimensions**: 106 columns × 5161 data rows
- **Key issues identified**:
  - 1 fully empty row at end
  - 2 fully empty columns (cols 7, 13, 74)
  - Duplicate CAR columns (market model vs FF3): cols 24-31 vs 32-39
  - Duplicate media window columns (mean vs sd): cols 40-51
  - Columns 14-15 (搜索代码1, 搜索代码2) missing English names
  - Mixed date formats (YYYY/MM/DD, YYYY-MM-DD, DD-Mon, Excel serial numbers)
  - Chinese company names with garbled encoding
  - Numeric columns with potential #N/A, N/A, NA values

---

## Phase 1: Parallel Deep Exploration (3 agents)

### Agent 1A: Date Column Audit
- **Input**: Raw CSV file
- **Output**: `agent_tasks/.../audit_dates.csv`
- **Task**: Sample all unique values of `release_date` and `release_month`, identify formats, Excel serial numbers

### Agent 1B: Numeric Column & Missing Value Audit  
- **Input**: Raw CSV file
- **Output**: `agent_tasks/.../audit_numeric_missing.csv`
- **Task**: For each numeric column, count non-numeric values, identify patterns (#N/A, NA, etc.)

### Agent 1C: Panel Structure & Key Variable Audit
- **Input**: Raw CSV file
- **Output**: `agent_tasks/.../audit_panel_structure.csv`
- **Task**: Count events, firms, check balance, check duplicates, check 搜索代码2 uniqueness

---

## Phase 2: Script Writing & Execution (main agent)

### Task: Write `clean_event_panel.py`
- **Script location**: Same directory as raw data
- **Script must**:
  1. Read with GB18030, handle 2-row header
  2. Build data_dictionary from Chinese + English headers
  3. Remove empty rows/cols
  4. Rename duplicate CAR columns → mkt_car_* / ff3_car_*
  5. Rename duplicate media windows → media_sent_mean_w* / media_sent_sd_w*
  6. Rename Unnamed columns to proper names (search_code_1, search_code_2)
  7. Clean all variable names (lowercase, underscores, no special chars)
  8. Parse dates (release_date, release_month) with mixed formats
  9. Convert numeric columns with coercion
  10. Check panel structure (event × firm)
  11. Generate all output files
  12. Print summary to terminal

### Execute script and verify outputs

---

## Phase 3: Parallel Review (3 agents)

### Agent 3A: Script Quality Review
- Review code for correctness, edge cases, error handling

### Agent 3B: Output Data Quality Review
- Verify cleaned CSV integrity, check for regressions

### Agent 3C: Report Completeness Review
- Verify cleaning_report.md covers all required sections

---

## Phase 4: Revision Based on Review
- Apply fixes from Phase 3 feedback
- Re-run script
- Final verification

---

## Output Files Expected
1. `clean_event_panel.py` — reproducible cleaning script
2. `clean_event_firm_panel.csv` — cleaned panel data
3. `cleaning_report.md` — detailed cleaning report
4. `data_dictionary.csv` — English-Chinese variable mapping
5. `variable_rename_map.csv` — renaming log
6. `event_level_summary.csv` — event-level summary
7. `event_firm_balance_check.csv` — balance check
8. `duplicate_event_firm_rows.csv` — duplicates (if any)
