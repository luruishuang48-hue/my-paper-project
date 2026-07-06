# 财务数据收集执行计划

时间戳：20260702-223530，北京时间

## 目标

为本项目 108 家公司收集 2022Q1 到 2026Q1 的季度财务数据。最低目标变量为总资产、股东权益和季末市值。所有原始数据、标准化数据、脚本和校验报告放入根目录 `Fundamentals/`。

## 成功标准

- 复用 `CAR/metadata/firm_universe_for_car.csv` 中的 108 家公司池。
- 生成季度面板，覆盖 2022Q1 到 2026Q1。
- 尽量收集 `total_assets`、`stockholders_equity`、`shares_outstanding`、`quarter_end_market_cap`。
- 明确每个变量的数据源、单位、覆盖率和缺口。
- 对拿不到完整季度数据的 ticker 单独列出，不静默补值。

## 阶段一 规划与信息收集

主代理立即测试公开数据端点，确认 SEC、Yahoo 或其他公开源可用性。并行子任务负责调研备选源与字段定义。

拟采用主路径：

1. SEC companyfacts API 用于美国上市主体和 SEC 披露主体的季度资产、权益、股数。
2. Yahoo Finance 可作为补充源，用于部分 ADR 或 SEC 缺失字段。
3. 季末市值优先用 `CAR/processed/prices_daily_long.csv` 的复权或收盘价格与股数计算。

## 阶段二 实施与整合

在 `Fundamentals/scripts/` 写入脚本，下载原始 JSON 到 `Fundamentals/raw/`，输出标准化 CSV 到 `Fundamentals/processed/`。

核心输出：

- `Fundamentals/metadata/fundamentals_universe.csv`
- `Fundamentals/processed/fundamentals_quarterly_long.csv`
- `Fundamentals/processed/fundamentals_quarterly_wide.csv`
- `Fundamentals/reports/fundamentals_download_status.csv`
- `Fundamentals/reports/fundamentals_coverage_report.csv`

## 阶段三 审阅与反馈

检查：

- 是否覆盖 108 家公司。
- 每家公司 2022Q1 到 2026Q1 的季度数量。
- 总资产、股东权益、股数、市值的非缺失率。
- 单位是否一致。
- ADR、外资发行人、晚上市公司是否被正确标记。

## 阶段四 修订与交付

根据校验结果补拉备选源。若公开源无法完整覆盖，保留缺口报告，并在 `Fundamentals/README.md` 中说明限制和后续可选路径。

## 执行结果

- SEC companyfacts 完成可用性排查，但季度财年字段覆盖不足，不能作为 108 家公司统一主源。
- StockAnalysis 页面嵌入的 Fiscal.ai 数据覆盖更完整，最终作为季度财务数据主源。
- 已生成 `Fundamentals/processed/fundamentals_quarterly_wide.csv` 和 `Fundamentals/processed/fundamentals_quarterly_long.csv`。
- 已生成美元换算后的 `total_assets_usd`、`stockholders_equity_usd`、`size_log_assets` 和 `bm_ratio`。
- 非美元报表币种 CNY、EUR、TWD 已用 Yahoo Finance 日线汇率换算为美元。
- 最终宽表为 1799 行，覆盖 108家公司、2022Q1 至 2026Q1 共 17 个季度。
- 公司-季度无重复行，`total_assets_usd` 无缺失，`bm_ratio` 非缺失 1764 行。
- 缺口主要来自晚上市公司或披露频率差异，详见 `Fundamentals/reports/fundamentals_collection_report.md`。
