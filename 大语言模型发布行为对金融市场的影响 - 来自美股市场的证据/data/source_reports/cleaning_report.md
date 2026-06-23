# Cleaning Report

## 1. Input File

- Path: `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/事件集数据.csv`
- Encoding: gb18030
- Raw rows: 5161
- Raw columns: 106
- Empty rows removed: 1
- Empty columns removed: 1 (indices: [13])
- Cleaned rows: 5160
- Cleaned columns: 107

## 2. Header Structure

The CSV uses a 2-row header structure:
- Row 1 (index 0): Chinese variable descriptions
- Row 2 (index 1): English variable names
- Row 3+ (index 2+): Data

The Chinese labels are preserved in `data_dictionary.csv`.

## 3. Column Renaming

Removed 1 fully empty column(s) that had no Chinese or English header: indices [13].
Note: Named columns with all-empty data (e.g., `relationship`) were **retained** — only truly unnamed separator columns were removed.

### Duplicate CAR Columns

Two sets of CAR columns (car_pre through car_20) were detected. Based on the Chinese headers:
- First set: Market model abnormal return → renamed to `mkt_car_*`
- Second set: FF3 abnormal return → renamed to `ff3_car_*`

### Duplicate Media Window Columns

Six pairs of windows-* columns (windows-2 through windows-20) were detected. Based on Chinese headers:
- First occurrence of each window: Media sentiment mean → renamed to `media_sent_mean_w*`
- Second occurrence: Media sentiment standard deviation → renamed to `media_sent_sd_w*`

### Unnamed Columns

Three columns had empty English headers and were manually named:
- Col 7 (no label in either header): renamed to `col_7` (model+code concatenation artifact)
- Col 14 (Chinese: 搜索代码1): renamed to `search_code_1`
- Col 15 (Chinese: 搜索代码2): renamed to `search_code_2`

Total columns renamed: 31. See `variable_rename_map.csv` for full details.

## 4. Date Cleaning

### release_date

- Parse failures: 0 out of 5160
- Original formats detected: YYYY/M/D (majority), Excel serial number (event FMR-0060 only)
- Excel serial 46098 → 2026-03-17 (FMR-0060 GPT-5.4 family, 82 rows)
- All values now in ISO format: YYYY-MM-DD

### release_month

- Parse failures: 0 out of 5160
- Original formats detected: YY-Mon (majority), Excel serial number (event FMR-0060 only)
- Excel serial 46107 encodes the full date 2026-03-26; truncated to YYYY-MM → 2026-03
  (The day component 26 coincidentally matches the year digits; the serial was correctly
  converted using the Excel epoch and the month-level portion extracted.)
- All values now in format: YYYY-MM

Original values preserved in `release_date_raw` and `release_month_raw` columns for traceability.

## 5. Missing Values

### Key Variable Missingness

| Variable | Total | Missing | % Missing |
|----------|-------|---------|-----------|
| final_event_id | 5160 | 0 | 0.0% |
| event_name | 5160 | 0 | 0.0% |
| release_date | 5160 | 0 | 0.0% |
| release_month | 5160 | 0 | 0.0% |
| company_id | 5160 | 0 | 0.0% |
| company | 5160 | 0 | 0.0% |
| relationship | 5160 | 0 | 0.0% |
| potential_us_exposure_type | 5160 | 0 | 0.0% |
| possible_us_exposed_tickers | 5160 | 0 | 0.0% |
| mkt_car_1 | 5160 | 130 | 2.5% |
| mkt_car_2 | 5160 | 124 | 2.4% |
| mkt_car_3 | 5160 | 115 | 2.2% |
| mkt_car_5 | 5160 | 111 | 2.2% |
| mkt_car_10 | 5160 | 107 | 2.1% |
| ff3_car_1 | 5160 | 107 | 2.1% |
| ff3_car_2 | 5160 | 101 | 2.0% |
| ff3_car_3 | 5160 | 92 | 1.8% |
| ff3_car_5 | 5160 | 88 | 1.7% |
| ff3_car_10 | 5160 | 83 | 1.6% |

### relationship Column

The `relationship` column has **0 missing values out of 5160 rows (100%)**.

**CRITICAL: The `relationship` column is completely empty.** This means firm-event relationship heterogeneity analysis cannot be performed without first supplementing the firm-event relationship mapping. You will need to manually code or merge the relationship type (e.g., competitor, supplier, customer, partner) for each event-firm pair before running heterogeneity regressions.

## 6. Numeric Conversion

Methodology: Before calling `pd.to_numeric(errors='coerce')`, all known NA patterns
(`#N/A`, `N/A`, `NA`, empty strings) were replaced with NaN. The table below reports both
the total NaN count after conversion and new NaN introduced during the `pd.to_numeric` step.

| Column | Total NaN | New NaN from conversion | % Missing |
|--------|-----------|------------------------|-----------|
| release_year | 0 | 0 | 0.0% |
| trend_month_since_2022_11 | 0 | 0 | 0.0% |
| size_log_assets | 85 | 0 | 1.6% |
| bm_ratio | 130 | 0 | 2.5% |
| volatility | 227 | 0 | 4.4% |
| momentum | 268 | 0 | 5.2% |
| mkt_car_pre | 131 | 0 | 2.5% |
| mkt_car_1 | 130 | 0 | 2.5% |
| mkt_car_2 | 124 | 0 | 2.4% |
| mkt_car_3 | 115 | 0 | 2.2% |
| mkt_car_5 | 111 | 0 | 2.2% |
| mkt_car_10 | 107 | 0 | 2.1% |
| mkt_car_15 | 107 | 0 | 2.1% |
| mkt_car_20 | 107 | 0 | 2.1% |
| ff3_car_pre | 83 | 0 | 1.6% |
| ff3_car_1 | 107 | 0 | 2.1% |
| ff3_car_2 | 101 | 0 | 2.0% |
| ff3_car_3 | 92 | 0 | 1.8% |
| ff3_car_5 | 88 | 0 | 1.7% |
| ff3_car_10 | 83 | 0 | 1.6% |
| ff3_car_15 | 83 | 0 | 1.6% |
| ff3_car_20 | 82 | 0 | 1.6% |
| media_sent_mean_w2 | 1462 | 0 | 28.3% |
| media_sent_sd_w2 | 1634 | 0 | 31.7% |
| media_sent_mean_w3 | 1375 | 0 | 26.6% |
| media_sent_sd_w3 | 1548 | 0 | 30.0% |
| media_sent_mean_w5 | 1204 | 0 | 23.3% |
| media_sent_sd_w5 | 1291 | 0 | 25.0% |
| media_sent_mean_w10 | 1117 | 0 | 21.6% |
| media_sent_sd_w10 | 1204 | 0 | 23.3% |
| media_sent_mean_w15 | 859 | 0 | 16.6% |
| media_sent_sd_w15 | 945 | 0 | 18.3% |
| media_sent_mean_w20 | 687 | 0 | 13.3% |
| media_sent_sd_w20 | 945 | 0 | 18.3% |
| merged_model_count | 0 | 0 | 0.0% |
| aa_intelligence_index | 1118 | 0 | 21.7% |
| aa_coding_index | 2150 | 0 | 41.7% |
| aa_math_index | 3182 | 0 | 61.7% *** >50% *** |
| mmlu_pro | 1806 | 0 | 35.0% |
| gpqa | 1376 | 0 | 26.7% |
| hle | 1376 | 0 | 26.7% |
| livecodebench | 1720 | 0 | 33.3% |
| scicode | 1376 | 0 | 26.7% |
| math_500 | 2150 | 0 | 41.7% |
| aime | 2322 | 0 | 45.0% |
| price_1m_input_tokens | 1118 | 0 | 21.7% |
| price_1m_output_tokens | 1118 | 0 | 21.7% |
| price_1m_blended_3_to_1 | 1118 | 0 | 21.7% |
| median_output_tokens_per_second | 1118 | 0 | 21.7% |
| median_time_to_first_token_seconds | 1118 | 0 | 21.7% |
| median_time_to_first_answer_token | 1118 | 0 | 21.7% |
| aa_media_elo | 4042 | 0 | 78.3% *** >50% *** |
| aa_media_rank | 4042 | 0 | 78.3% *** >50% *** |
| aa_media_ci95 | 4042 | 0 | 78.3% *** >50% *** |
| aa_media_appearances | 4042 | 0 | 78.3% *** >50% *** |
| aa_media_category_rows | 4042 | 0 | 78.3% *** >50% *** |

Columns with >50% missing are expected:
- `aa_math_index` (61.7%): only available for models with math benchmarks
- `aa_media_*` (78.3%): only available for media generation models (images/video/audio)
Do NOT blindly delete these columns; they are structurally missing based on model type.
Use `llm_capability_sample_flag` and `media_capability_sample_flag` to subset appropriately.

## 7. Event-Firm Panel Check

- Events: 60
- Firms: 86
- Observations: 5160
- Balanced panel: True
- Firms per event: 86 – 86 (all events have exactly the same set of firms)
- Duplicate (event × firm) keys: 0

The panel is perfectly balanced: every event covers all 86 firms, and every firm appears in all 60 events.
No duplicates found. Ready for panel regression with event and firm fixed effects.

## 8. Suspicious Variables

### search_code_2

- Unique values: 172
- Most common value: `三星电子2024-Q2` (1.1%)
- Nearly constant: False

The column contains company name concatenated with a quarter label. Two format variants exist:
- `2024-Q2` (with hyphen): used in 59 of 60 events (5,074 rows)
- `2024Q2` (without hyphen): used in 1 event, FMR-0001 (86 rows)

The quarter '2024Q2' is a fixed financial reporting quarter used as a data snapshot reference,
not an event-specific quarter. It does NOT vary across events.

Recommendation: Retain but note in methodology as a fixed reference quarter. Do not include as
a time-varying regressor since it is constant for all observations.

## 9. Output Files

| File | Description |
|------|-------------|
| `clean_event_firm_panel.csv` | Cleaned panel data (5160 rows × 107 cols), ready for regression |
| `cleaning_report.md` | This report |
| `data_dictionary.csv` | English variable name → Chinese label mapping |
| `variable_rename_map.csv` | Full variable renaming log with reasons |
| `event_level_summary.csv` | Event-level summary with company counts and capability flags |
| `event_firm_balance_check.csv` | Panel balance check per event |

## 10. Remaining Issues Before Regression

1. **relationship column is empty (100% missing)**: Must be supplemented before firm-event
   heterogeneity analysis. Each (event, firm) pair needs a relationship type
   (e.g., competitor, supplier, customer, partner, unrelated). Without this, you can
   still run baseline event-study regressions, but cannot test heterogeneity by
   firm-event relationship type.

2. **search_code_2 is a fixed financial quarter**: All values reference 2024Q2. This
   should be noted as a data snapshot reference in the paper's data section, not used
   as a time-varying control variable.

3. **Chinese text in company/industry fields**: The `company`, `industry`, and
   `search_code_*` columns contain Chinese characters. Use `company_id` (ticker-style
   codes like 'AAPL', 'GOOGL') for reliable firm identification in regressions.

4. **AA media metrics (78.3% missing)**: Only media generation models have media
   capability metrics. When using `aa_media_elo`, `aa_media_rank`, etc., restrict to
   the `media_capability_sample_flag == 1` sub-sample.

5. **AA capability metrics with high missing rates**: `aa_math_index` (61.7%), `aime`
   (45.0%), `math_500` (41.7%), `aa_coding_index` (41.7%) are structurally missing
   based on model type. Use `llm_capability_sample_flag == 1` for LLM capability analyses.

6. **Encoding**: The cleaned CSV uses UTF-8 with BOM (`utf-8-sig`). When loading in
   Stata, use `import delimited` with appropriate encoding. In R/Python, `read.csv()`
   or `pd.read_csv()` will handle this automatically.
