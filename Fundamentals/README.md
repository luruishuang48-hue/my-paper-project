# Fundamentals 财务数据说明

本文件夹保存股票集的季度财务数据，范围为 2022Q1 至 2026Q1。股票集来自 `CAR/metadata/firm_universe_for_car.csv`，共 108家公司。

## 可直接使用的文件

- `processed/fundamentals_quarterly_wide.csv`
  公司-季度宽表。建议作为后续回归和匹配 CAR 的主表。
- `processed/fundamentals_quarterly_long.csv`
  长表版本，适合画图或批量检查变量。
- `processed/fx_rates_to_usd.csv`
  非美元报表币种换算美元时使用的日汇率。
- `reports/fundamentals_collection_report.md`
  总体覆盖率、字段口径和缺口公司。
- `reports/fundamentals_coverage_report.csv`
  每家公司逐项覆盖率。
- `reports/financial_currency_summary.csv`
  财务报表币种分布。

## 主要变量

- `total_assets`
  总资产，原始财务报表币种。
- `stockholders_equity`
  股东权益，原始财务报表币种。
- `total_assets_usd`
  总资产美元值。
- `stockholders_equity_usd`
  股东权益美元值。
- `size_log_assets`
  `log(total_assets_usd)`。
- `shares_for_market_cap`
  估算季末市值使用的股数，优先使用 diluted shares，其次 basic shares，最后用 book value / book value per share 反推。
- `quarter_end_market_cap_usd`
  季末或季末前最近交易日收盘价乘以股数得到的估算市值。
- `bm_ratio`
  `stockholders_equity_usd / quarter_end_market_cap_usd`。
- `financial_currency`
  财务报表币种。
- `financial_fx_to_usd`
  报表币种换算美元的日汇率。USD 公司为 1。

## 数据来源与口径

主财务数据来自 StockAnalysis 页面嵌入的 Fiscal.ai 季度资产负债表和损益表数据。SEC `company_tickers.json` 用于补充 CIK 映射。季末价格来自 `CAR/processed/prices_daily_long.csv`。

季度口径按财报期末日向前 15 天确定日历季度，目的是处理部分公司财报期末日落在季度边界附近的情况。若同一公司同一日历季度出现多条记录，保留离该日历季度末最近的一条。

非美元报表币种包括 CNY、EUR、TWD，已用 Yahoo Finance 日线汇率按财报期末日或此前最近交易日换算为美元。

## 当前覆盖情况

- 理论公司-季度行数为 1836。
- 实际标准化行数为 1799。
- 公司数为 108。
- 目标季度为 17 个，覆盖 2022Q1 至 2026Q1。
- `total_assets_usd` 非缺失 1799 行。
- `stockholders_equity_usd` 非缺失 1798 行。
- `bm_ratio` 非缺失 1764 行。
- 公司-季度无重复行。

覆盖不足主要来自晚上市公司或披露频率差异。重点缺口公司见 `reports/fundamentals_collection_report.md`。

## 复现方式

运行 `scripts/fetch_fundamentals.py` 可重新抓取并生成全部 processed、metadata 和 reports 文件。脚本会缓存原始网页和汇率 JSON，重复运行时通常会更快。
