# CAR 数据收集报告

生成时间：2026-07-02T18:31:30

## 输入范围

- 事件数：125
- 事件日期范围：2022-04-06 至 2026-03-26
- 公司池总数：108
- Nasdaq-100 主样本：101
- SOX/SOXX 稳健性样本：25
- 合并去重下载股票数：108
- 市场基准：SPY, QQQ, SOXX, ^NDX, ^IXIC, ^GSPC, ^SOX
- 下载日期范围：2021-01-01 至 2026-04-30
- CAR 最低价格覆盖起点：2021-06-21
- CAR 最长事件窗终点：2026-04-24

## 已生成数据

- `CAR/metadata/firm_universe_for_car.csv`
- `CAR/metadata/event_dates_for_car.csv`
- `CAR/metadata/event_dates_with_trading_day.csv`
- `CAR/metadata/event_window_requirements.csv`
- `CAR/metadata/main_nasdaq100_tickers.csv`
- `CAR/metadata/robustness_sox_tickers.csv`
- `CAR/processed/prices_daily_long.csv`
- `CAR/processed/returns_daily_long.csv`
- `CAR/processed/market_benchmarks_daily.csv`
- `CAR/processed/ff3_daily.csv`
- `CAR/reports/yahoo_download_status.csv`
- `CAR/reports/coverage_report.csv`

## 来源

- 股票、ETF 和指数日度价格来自 Yahoo Finance Chart API `query2`，原始 JSON 保存在 `CAR/raw/yahoo_chart_json/`。
- Fama-French 3 因子日度数据来自 Kenneth French Data Library，原始 zip 和解压 CSV 保存在 `CAR/raw/factors/`。

## 下载结果

- 成功下载 symbol 数：115
- 下载失败 symbol 数：0
- FF3 日度记录数：1337
- 价格长表记录数：148125
- 非交易日顺延事件数：4
- 日期复核标记事件数：8

## 需要注意

- 部分 2024 或 2025 年后上市公司没有覆盖早期事件的估计窗。报告中 `starts_after_first_event=true` 的股票需要在面板构造时按上市日期处理。
- `event_trading_date` 目前只按日期顺延到最近美股交易日，没有使用盘前、盘中、盘后发布时间。
- 当前股票池仍是当前成分股快照，不是历史基准日成分股。

## 非交易日顺延事件

| event_id        | official_date   | event_trading_date   | date_roll_rule             | model_names     |
|:----------------|:----------------|:---------------------|:---------------------------|:----------------|
| AIT-2024-11-001 | 2024-11-28      | 2024-11-29           | next_trading_day_nonmarket | QwQ 32B Preview |
| AIT-2025-01-003 | 2025-01-20      | 2025-01-21           | next_trading_day_nonmarket | R1              |
| AIT-2025-04-001 | 2025-04-05      | 2025-04-07           | next_trading_day_nonmarket | Llama 4         |
| AIT-2025-12-009 | 2025-12-20      | 2025-12-22           | next_trading_day_nonmarket | MiniMax-M2.1    |

## 日期复核标记

| event_id        | official_date   | event_trading_date   | date_confidence   | multi_component_date_flag   | official_date_month_matches_ai_month   | model_names                                |
|:----------------|:----------------|:---------------------|:------------------|:----------------------------|:---------------------------------------|:-------------------------------------------|
| AIT-2024-12-002 | 2024-12-05      | 2024-12-05           | medium            | True                        | True                                   | SORA; o1; o1 Pro                           |
| AIT-2025-04-007 | 2025-03-31      | 2025-03-31           | medium            | False                       | False                                  | Runway Gen-4; Vidu Q1; Kling 2.0           |
| AIT-2025-07-005 | 2025-07-21      | 2025-07-21           | medium            | True                        | True                                   | Qwen3-235B-A22B-Instruct-2507; Qwen3-Coder |
| AIT-2025-12-001 | 2025-12-02      | 2025-12-02           | high              | True                        | True                                   | Mistral 3; Devstral 2                      |
| AIT-2025-12-002 | 2025-12-11      | 2025-12-11           | medium            | True                        | True                                   | GPT-5.2; GPT-Image 1.5                     |
| AIT-2026-02-001 | 2026-02-05      | 2026-02-05           | high              | True                        | True                                   | Claude Opus 4.6; Claude Sonnet 4.6         |
| AIT-2026-02-006 | 2026-03-10      | 2026-03-10           | low               | False                       | False                                  | Grok 4.20                                  |
| AIT-2026-03-002 | 2026-03-05      | 2026-03-05           | medium            | True                        | True                                   | GPT-5.4; GPT-5.4 mini; GPT-5.4 nano        |

## 下载失败

无。

## 上市较晚或早期覆盖不足

| symbol   | first_date   | last_date   |   rows |
|:---------|:-------------|:------------|-------:|
| ALAB     | 2024-03-20   | 2026-04-30  |    530 |
| ARM      | 2023-09-14   | 2026-04-30  |    659 |
| CEG      | 2022-01-19   | 2026-04-30  |   1074 |
| CRDO     | 2022-01-27   | 2026-04-30  |   1068 |
| CRWV     | 2025-03-28   | 2026-04-30  |    274 |
| GEHC     | 2022-12-15   | 2026-04-30  |    845 |
| NBIS     | 2024-10-21   | 2026-04-30  |    382 |
| SNDK     | 2025-02-13   | 2026-04-30  |    304 |

## 末端覆盖不足

无。
