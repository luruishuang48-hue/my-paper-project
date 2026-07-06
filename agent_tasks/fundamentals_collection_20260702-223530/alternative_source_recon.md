# 季度财务数据公开备选源核对报告

核对时间：2026-07-02，北京时间。

输入文件：`CAR/metadata/firm_universe_for_car.csv`。

样本规模：108 家公司。其中 Nasdaq-100 主样本 101 家，SOX/SOXX 稳健性样本 25 家，SOX-only 7 家。

本报告只核对 Yahoo Finance 和其他公开备选源，不修改 `Fundamentals/` 下任何文件。

## 核心结论

首选补源应当是 StockAnalysis，而不是 Yahoo Finance。

Yahoo Finance 经过 cookie 和 crumb 后，可以批量返回当前 `marketCap` 和当前 `sharesOutstanding`。本轮 108/108 成功。但它不能补 2022Q1 到 2026Q1 的季度 `total assets` 和 `stockholders equity`。`quoteSummary` 的 `balanceSheetHistoryQuarterly` 在 108 家公司上都只返回 4 个季度日期，未返回资产和权益数值字段。

StockAnalysis 的公开 HTML 页面更适合作为 SEC companyfacts 缺口补源。本轮核对显示，108/108 的季度资产负债表页面都能解析出 `Total Assets` 和 `Shareholders' Equity`，108/108 的季度利润表页面都能解析出 `Shares Outstanding (Basic)` 和 `Shares Outstanding (Diluted)`。页面标注单位为 millions USD。

直接的季度期末市值公开源没有找到稳定无密钥方案。建议使用已有日度价格与季度股数计算。股数优先取 SEC `EntityCommonStockSharesOutstanding`。SEC 缺失时，可用 StockAnalysis 的季度 `Shares Outstanding (Basic)` 做近似，但不能把它命名为 ordinary shares outstanding。

## 推荐使用顺序

1. 主源仍用 SEC companyfacts。美国发行人、10-Q/10-K 披露主体的资产、权益、普通股数优先来自 SEC。
2. SEC 缺失的 `total_assets` 和 `stockholders_equity` 用 StockAnalysis 季度资产负债表补。
3. SEC 缺失的普通股数不要直接用 Yahoo 当前股数补历史季度。可先用 StockAnalysis 季度基本股数生成 `shares_basic_avg`，再用它计算近似市值，并保留来源标记。
4. 季度市值用 `CAR/processed/prices_daily_long.csv` 中的季末最近交易日价格乘以股数。若使用基本加权平均股数，变量名建议写成 `market_cap_est_basic_shares`。
5. Yahoo 当前 `marketCap` 和 `sharesOutstanding` 只作核验或最新截面补充，不用于历史季度面板主口径。

## Yahoo Finance 核对

测试端点：

- `https://query1.finance.yahoo.com/v7/finance/quote?symbols=AAPL,MSFT&fields=marketCap,sharesOutstanding,regularMarketPrice`
- `https://query2.finance.yahoo.com/v10/finance/quoteSummary/AAPL?modules=balanceSheetHistoryQuarterly,defaultKeyStatistics,price`
- `https://query1.finance.yahoo.com/v8/finance/chart/AAPL?period1=1640995200&period2=1643673600&interval=1d&events=history`
- `https://query1.finance.yahoo.com/v1/test/getcrumb`

未带 cookie/crumb 时，`v7/finance/quote` 返回 401，错误说明为 user unable to access this feature。`quoteSummary` 返回 401，错误说明为 invalid crumb。

用 `https://fc.yahoo.com` 种下 cookie 后，再取 `getcrumb`，`quote` 和 `quoteSummary` 可以访问。

全样本结果：

| 字段 | 覆盖率 | 结论 |
|---|---:|---|
| 当前 `price.marketCap` | 108/108 | 可拿，但只代表当前点 |
| 当前 `defaultKeyStatistics.sharesOutstanding` | 108/108 | 可拿，但只代表当前点 |
| `balanceSheetHistoryQuarterly` 记录数 | 108/108，每家公司 4 期 | 只有最近 4 期，不覆盖研究期 |
| `totalAssets` | 0/108 | 未返回可用字段 |
| `totalStockholderEquity` | 0/108 | 未返回可用字段 |

判断：

Yahoo Finance 不适合作为 SEC 缺口的季度资产和权益补源。其优势仅在当前行情、当前市值、当前股数核验。即使接口可通过 crumb 访问，也属于非官方、会话依赖接口，批量复现风险高。

Yahoo 页面参考：

- <https://finance.yahoo.com/quote/AAPL/balance-sheet/>

## StockAnalysis 核对

测试 URL 模式：

- 季度资产负债表：`https://stockanalysis.com/stocks/{ticker}/financials/balance-sheet/?p=quarterly`
- 季度利润表：`https://stockanalysis.com/stocks/{ticker}/financials/?p=quarterly`
- 当前统计页：`https://stockanalysis.com/stocks/{ticker}/statistics/`
- 市值页：`https://stockanalysis.com/stocks/{ticker}/market-cap/`

样本测试 URL：

- <https://stockanalysis.com/stocks/aapl/financials/balance-sheet/?p=quarterly>
- <https://stockanalysis.com/stocks/aapl/financials/?p=quarterly>
- <https://stockanalysis.com/stocks/tsm/financials/balance-sheet/?p=quarterly>
- <https://stockanalysis.com/stocks/arm/financials/balance-sheet/?p=quarterly>
- <https://stockanalysis.com/stocks/crwv/financials/balance-sheet/?p=quarterly>

全样本结果：

| 页面 | 可访问 | 关键字段覆盖 | 期数范围 |
|---|---:|---:|---|
| `financials/balance-sheet/?p=quarterly` | 108/108 | `Total Assets` 108/108，`Shareholders' Equity` 108/108 | 每家公司 9 到 20 个季度列 |
| `financials/?p=quarterly` | 108/108 | `Shares Outstanding (Basic)` 108/108，`Shares Outstanding (Diluted)` 108/108 | 每家公司 10 到 20 个季度列 |
| `statistics/` | 样本可访问 | 当前市值、当前股数 | 当前截面 |
| `market-cap/` | 样本可访问 | 当前及年末市值表 | 不是季度频率 |

字段和单位：

- 页面写明 `Financials in millions USD`。
- 资产字段可映射为 `total_assets_sa_musd`。
- 权益字段可映射为 `shareholders_equity_sa_musd`。
- 股数字段是 `Shares Outstanding (Basic)` 和 `Shares Outstanding (Diluted)`，口径更接近加权平均股数，单位为百万股。
- 不建议把 StockAnalysis 的股数字段命名为 `ordinary_shares_number`，除非只作为近似补值，并在变量名中说明 `basic_avg` 或 `diluted_avg`。

优点：

- 覆盖本项目 108 家公司，包括 ASML、ASX、TSM、UMC、ARM 等 SEC 季度披露可能不足的外资或 ADR 样本。
- 页内季度列包含明确 period ending date，便于转成统一季度面板。
- 资产、权益、股数三个核心控制变量都有可解析来源。

限制：

- 不是官方 API，是公开 HTML 页面。需要保留原始 HTML、抓取日期和 URL。
- 财年口径不统一。例如 Apple 财年为 10 月至 9 月，NVIDIA 财年季度结束日在 1 月、4 月、7 月、10 月附近。后续应按 period ending date 归入 calendar quarter，不能只按页面上的 fiscal quarter 标签合并。
- 晚上市公司期数较少。例如 CRWV 只有 2023Q4 之后的数据，不能人为补齐上市前季度。
- 股数不是期末普通股发行在外股数，市场价值计算时要标注近似口径。

判断：

StockAnalysis 可以作为本项目最实用的公开补源。它适合补 SEC 缺失的季度总资产和股东权益，也可以提供股数近似口径。建议用于稳健性或缺口补齐，并保留 source priority。

## 其他公开源核对

### Alpha Vantage

文档显示 `BALANCE_SHEET` API 返回年度和季度资产负债表，并映射 GAAP 和 IFRS 字段：

- <https://www.alphavantage.co/documentation/>

本轮用 demo key 测试 `BALANCE_SHEET`，返回提示要求申请免费 API key。它不是无密钥批量来源。即使申请免费 key，108 家公司至少需要 108 次资产负债表请求，若还要利润表或股数，请求量会翻倍，免费额度可能不够。

判断：

可作为有 key 情况下的备选 API，不适合作为本轮无密钥自动补源。

### Financial Modeling Prep

文档显示它提供季度和年度财务报表 API：

- <https://site.financialmodelingprep.com/developer/docs>
- <https://site.financialmodelingprep.com/developer/docs/stable/balance-sheet-statement>

本轮直接请求 `balance-sheet-statement/AAPL?period=quarter&apikey=demo` 返回 invalid API key。该源需要注册 key。

判断：

有 key 时可考虑。无 key 时不能用于批量补源。

### EODHD

文档说明 Fundamentals API 需要 Fundamentals package 或更高订阅：

- <https://eodhd.com/financial-apis/stock-etfs-fundamental-data-feeds>

本轮 demo token 对 AAPL.US 可返回数据，但 ASML.US、TSM.US、ARM.US、ALAB.US、CRWV.US、SNDK.US 返回 403。

判断：

demo 只适合样例验证，不能覆盖本项目样本。若购买或已有订阅，可作为备选 API。

### Macrotrends

样本页可返回 Apple 季度总资产：

- <https://www.macrotrends.net/stocks/charts/AAPL/apple/total-assets>
- <https://www.macrotrends.net/stocks/charts/AAPL/apple/balance-sheet>

限制是 URL 需要公司名称 slug，且常按单一指标组织页面。批量 108 家、多个字段时成本和失败率高。它也不直接解决普通股数和季度市值。

判断：

适合作为人工抽查或个别缺口兜底，不建议作为主补源。

### Stooq

测试页面：

- `https://stooq.com/q/d/l/?s=aapl.us&i=d&d1=20220101&d2=20220110`
- `https://stooq.com/q/i/?s=aapl.us`
- `https://stooq.com/q/f/?s=aapl.us`

本轮静态请求返回浏览器验证页，不返回可用财务数据。Stooq 更偏价格数据，不适合本任务。

判断：

不作为季度财务补源。

## 建议的后续变量口径

资产和权益：

- `total_assets` 优先 SEC，缺失时用 StockAnalysis `Total Assets`。
- `stockholders_equity` 优先 SEC，缺失时用 StockAnalysis `Shareholders' Equity`。
- StockAnalysis 单位为百万美元。与 SEC 原始美元单位合并时必须统一成美元或百万美元。

股数：

- `ordinary_shares_number` 只应用 SEC 的普通股期末发行在外口径。
- StockAnalysis 的 `Shares Outstanding (Basic)` 建议命名为 `shares_basic_avg`。
- StockAnalysis 的 `Shares Outstanding (Diluted)` 建议命名为 `shares_diluted_avg`。
- Yahoo 的 `sharesOutstanding` 建议命名为 `shares_outstanding_current_yahoo`，只用于当前截面核验。

季度市值：

- 首选计算式为季末最近交易日价格乘以 SEC 普通股期末股数。
- 如果 SEC 股数缺失，可用 StockAnalysis `shares_basic_avg` 生成近似市值。
- 不建议用 Yahoo 当前 `marketCap` 回填历史季度。

## 实施建议

下一步可以写一个独立补源脚本，但应先把变量层级定清楚：

1. SEC 主源先生成基础季度面板。
2. 对 SEC 缺失的 firm-quarter，用 StockAnalysis 补资产和权益。
3. 对股数缺失，先保留缺失；若回归必须要市值，再用 `shares_basic_avg` 计算近似市值。
4. 每个变量保留 `source`、`source_url`、`retrieved_at` 和 `unit`。
5. 对非 SEC 来源生成单独覆盖率报告，不把补源值静默并入主变量。

最终判断：

可以批量拿到本项目需要的公开补源数据。最可行的无密钥方案是 StockAnalysis。Yahoo Finance 只能补当前市值和当前股数，不能补季度资产、季度权益或历史季度普通股数。
