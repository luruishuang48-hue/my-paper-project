# 财务数据收集报告

生成时间：2026-07-27T17:06:56

## 范围

- 公司数：45
- 目标季度：2022Q1 至 2026Q1，共 17 个季度
- 理论 ticker × quarter 行数：765
- 实际标准化行数：760

## 主要来源

- 主财务数据来自 StockAnalysis 页面嵌入的 Fiscal.ai 季度资产负债表和损益表数据。
- SEC `company_tickers.json` 用于 CIK 映射。
- 市值由 `CAR/processed/prices_daily_long.csv` 中的季末或季末前最近交易日收盘价乘以股数估算。

## 覆盖率

- `total_assets` 非缺失数：760
- `stockholders_equity` 非缺失数：759
- `shares_for_market_cap` 非缺失数：754
- `quarter_end_market_cap_usd` 非缺失数：746
- `total_assets_usd` 非缺失数：760
- `stockholders_equity_usd` 非缺失数：759
- `bm_ratio` 非缺失数：745

## 重要口径

- `financial_currency` 是财务报表币种。非 USD 公司已用 Yahoo FX 日线换算为 USD，汇率字段为 `financial_fx_to_usd`。
- `quarter_end_market_cap_usd` 是估算值，优先使用 diluted shares，其次 basic shares，最后用 book value / book value per share 反推股数。
- 晚上市公司天然缺少早期季度，不做外推。

## 覆盖不足或字段缺失公司

| ticker   | company         |   rows | first_quarter   | last_quarter   |   total_assets_nonmissing |   equity_nonmissing |   shares_nonmissing |   market_cap_nonmissing |   total_assets_usd_nonmissing |   equity_usd_nonmissing |   bm_ratio_nonmissing | financial_currency   |   expected_quarters |   missing_quarters |
|:---------|:----------------|-------:|:----------------|:---------------|--------------------------:|--------------------:|--------------------:|------------------------:|------------------------------:|------------------------:|----------------------:|:---------------------|--------------------:|-------------------:|
| ARM      | Arm Holdings    |     15 | 2022Q1          | 2026Q1         |                        15 |                  15 |                  15 |                      11 |                            15 |                      15 |                    11 | USD                  |                  17 |                  2 |
| KLAC     | KLA Corporation |     17 | 2022Q1          | 2026Q1         |                        17 |                  16 |                  17 |                      17 |                            17 |                      16 |                    16 | USD                  |                  17 |                  0 |
| MSTR     | MicroStrategy   |     16 | 2022Q1          | 2026Q1         |                        16 |                  16 |                  16 |                      16 |                            16 |                      16 |                    16 | USD                  |                  17 |                  1 |
| SNDK     | Sandisk         |     15 | 2022Q1          | 2026Q1         |                        15 |                  15 |                   9 |                       5 |                            15 |                      15 |                     5 | USD                  |                  17 |                  2 |
