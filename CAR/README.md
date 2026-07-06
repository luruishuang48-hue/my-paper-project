# CAR 数据包说明

生成时间：2026-07-02，北京时间

## 数据口径

本目录保存本轮事件研究计算 CAR 所需的原始输入数据和校验报告。当前不保存第三方成品 CAR，后续 CAR 应由项目脚本从这里的日度收益、市场基准和 FF3 因子统一计算。

主样本为 Nasdaq-100，共 101 家。SOX/SOXX 稳健性样本共 25 家。合并去重后股票数为 108。

事件样本为 `new data set/processed/final_event_sample_main.csv` 中的 125 条事件。官方日期范围为 2022-04-06 至 2026-03-26。按 `[-200,-10]` 估计窗和 `[0,+20]` 最长事件窗，最低价格覆盖范围为 2021-06-21 至 2026-04-24。本次实际下载为 2021-01-01 至 2026-04-30。

## 已收集数据

- `processed/prices_daily_long.csv`：股票、ETF、指数日度价格长表。
- `processed/returns_daily_long.csv`：由 close 和 adjusted close 计算的简单收益与 log 收益。
- `processed/market_benchmarks_daily.csv`：SPY、QQQ、SOXX、^NDX、^IXIC、^GSPC、^SOX。
- `processed/ff3_daily.csv`：Fama-French 3 因子日度数据，含百分比和小数版本。
- `raw/yahoo_chart_json/`：Yahoo Finance Chart API 原始 JSON。
- `raw/factors/`：Kenneth French Data Library 原始 zip 和解压 CSV。

## 元数据

- `metadata/firm_universe_for_car.csv`：完整公司池和样本标签。
- `metadata/main_nasdaq100_tickers.csv`：主样本 ticker。
- `metadata/robustness_sox_tickers.csv`：SOX/SOXX 稳健性 ticker。
- `metadata/event_dates_for_car.csv`：官方事件日期。
- `metadata/event_dates_with_trading_day.csv`：美股首个可反应交易日。
- `metadata/event_window_requirements.csv`：每个事件的 t-200、t-10、t+20 等窗口边界。
- `metadata/download_universe_tickers.csv`：实际下载 symbol 清单。

## 校验结果

115 个 symbol 全部下载成功，含 108 只股票和 7 个市场基准。FF3 与 SPY 交易日完全对齐。

最大窗口可计算组合为 13,094 个，不可计算组合为 406 个。不可计算组合主要来自晚上市或样本期内才有可用价格的公司，包括 ALAB、ARM、CEG、CRDO、CRWV、GEHC、NBIS、SNDK。

4 条事件从非交易日顺延到下一美股交易日。8 条事件带日期复核标记，主要因为多组件事件、跨月事件或低置信度日期。

详见：

- `reports/data_collection_report.md`
- `reports/input_validation_report.md`
- `reports/yahoo_download_status.csv`
- `reports/coverage_report.csv`
- `reports/event_ticker_car_readiness.csv`
- `reports/car_readiness_by_ticker.csv`
- `reports/benchmark_coverage.csv`
- `reports/factor_market_date_alignment.csv`

## 脚本

- `scripts/fetch_car_inputs.py`：下载并标准化价格、基准和 FF3 因子。
- `scripts/validate_car_inputs.py`：检查事件窗口、ticker 覆盖和因子日期对齐。

推荐后续主 CAR 计算优先使用 adjusted close 收益。主市场基准可先固定 QQQ 或 ^NDX，SPY、^IXIC 做宽市场稳健性，SOXX 或 ^SOX 做半导体稳健性。
