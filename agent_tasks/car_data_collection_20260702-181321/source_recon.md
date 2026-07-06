# CAR 数据源可用性核对

核对时间：2026-07-02 18:31，北京时间

## 任务范围

输入文件：

- `new data set/decisions/firm_universe_decisions.csv`
- `企业列表/nasdaq100_sox_raw.csv`
- `to_do_rebuild_regression_20260702.md`

样本口径：

- 公司池共 108 个 ticker。
- Nasdaq-100 主样本为 101 个 ticker。
- SOX/SOXX 稳健性样本为 25 个 ticker。
- SOX-only ticker 为 ASX、CRDO、ENTG、MTSI、ON、TSM、UMC。
- 事件样本为 125 个事件，官方日期范围为 2022-04-06 至 2026-03-26。
- 按 `to_do_rebuild_regression_20260702.md`，日度收益建议覆盖 2021-07 至 2026-04。为估计窗留余量，实际下载可从 2021-01-01 开始。

## 总体结论

公开可批量获取的日度数据基本足够支撑本项目 CAR 计算。建议采用以下主路径。

1. 股票、ETF 和指数日度价格用 Yahoo Finance chart JSON 端点。
2. Fama-French 3 因子日度数据用 Kenneth French Data Library 官方 zip。
3. Stooq 可作为备选核验源，但当前直接 CSV 请求会触发浏览器验证，不适合作为自动批量主路径。

不要购买或导入第三方已经算好的 CAR。应保留原始日度价格、因子数据和下载状态，再由项目脚本统一计算 market model CAR 和 FF3 CAR。

## 股票日度价格

首选来源为 Yahoo Finance chart JSON。

可用端点格式：

```text
https://query2.finance.yahoo.com/v8/finance/chart/{SYMBOL}?period1={unix_start}&period2={unix_end}&interval=1d&events=history&includeAdjustedClose=true
```

关键字段：

- `timestamp`
- `indicators.quote.open`
- `indicators.quote.high`
- `indicators.quote.low`
- `indicators.quote.close`
- `indicators.quote.volume`
- `indicators.adjclose.adjclose`
- `meta.currency`
- `meta.exchangeName`
- `meta.instrumentType`

可用性判断：

- `query1.finance.yahoo.com` 在本次测试中返回 `Edge: Too Many Requests`，不宜作为主端点。
- `query2.finance.yahoo.com` 搭配常规浏览器 User-Agent 可以返回完整 JSON。
- AAPL、QQQ、`^IXIC` 小样本测试均成功返回 JSON。
- 108 个股票加 7 个基准的批量可用性在本地测试中均可返回，未发现 ticker 级不可识别问题。
- 需要注意，ALAB、ARM、CEG、CRDO、CRWV、GEHC、NBIS、SNDK 等公司存在上市较晚或样本期内才有可交易数据的问题。这不是下载失败，而是面板构造时需要按上市日期和估计窗可得性处理。

公开说明来源：

- Yahoo Help 说明历史价格、股息和拆股数据可在 Yahoo Finance 查看，离线 CSV 下载目前和 Gold 订阅相关，并提示部分工具会因数据许可限制没有下载选项。见 [Yahoo Help, Download historical data in Yahoo Finance](https://help.yahoo.com/kb/SLN2311.html)。

使用建议：

- 主下载源使用 Yahoo chart JSON，而不是 Yahoo 页面 CSV 下载。
- 原始 JSON 应完整保存，以便复查字段和修正解析逻辑。
- CAR 计算优先使用 `adj_close` 生成复权收益。
- 对 ADR 与海外上市主体，如 ASML、TSM、UMC、ASX，Yahoo 返回的是美股 ADR 交易序列，适合用于美股市场反应研究。

## 市场基准

建议同时下载以下基准，主回归先固定一个，其余用于稳健性。

- `QQQ`，Invesco QQQ Trust，贴近 Nasdaq-100 主样本。
- `^IXIC`，NASDAQ Composite，作为纳斯达克市场宽基。
- `SPY`，SPDR S&P 500 ETF Trust，流动性好，可作为宽市场 ETF 基准。
- `^GSPC`，S&P 500 Index，宽市场指数。
- `SOXX`，iShares Semiconductor ETF，适合 SOX/SOXX 稳健性口径。
- `^SOX`，PHLX Semiconductor Index，费城半导体指数本体。
- `^NDX`，Nasdaq-100 Index，主样本指数本体。

可用性判断：

- Yahoo chart JSON 能返回 ETF 和指数序列。
- QQQ、`^IXIC` 已做小样本测试，返回正常。
- 指数 ticker 需要 URL 编码，例如 `^IXIC` 写作 `%5EIXIC`。
- ETF 有复权价格字段，指数通常也会给出 `adjclose`，但实际计算时应检查是否等于 close。

推荐主基准：

- 主 CAR 用 `QQQ` 或 `^NDX` 二选一。若强调可交易和复权一致性，优先 `QQQ`。若强调指数定义，优先 `^NDX`。
- 稳健性用 `SPY` 或 `^IXIC`。
- 半导体子样本稳健性用 `SOXX` 或 `^SOX`。

## Fama-French 3 因子日度数据

首选来源为 Kenneth French Data Library 官方文件。

官方页面：

- [Kenneth R. French Data Library](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html)

官方日度 FF3 CSV zip：

```text
https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily_CSV.zip
```

可用性判断：

- 官方 Data Library 页面列出 `Fama/French 3 Factors [Daily]` 的 TXT、CSV 和 Details 下载项。
- 官方说明页显示日度收益覆盖 July 1, 1926 至 May 31, 2026。
- 本次核对时 zip 端点可访问，返回 `application/x-zip-compressed`。
- zip 中 CSV 可解析出 `Mkt-RF`、`SMB`、`HML`、`RF`。
- 因子值以百分比为单位，计算时需要除以 100 转为小数。

官方定义来源：

- [Description of Fama/French Factors](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/f-f_factors.html)

使用建议：

- 保存原始 zip 和解压 CSV。
- 标准化字段建议命名为 `Mkt_RF`、`SMB`、`HML`、`RF`，并同时生成 decimal 版本。
- FF3 模型中个股超额收益用个股收益减 `RF_decimal`，市场因子直接用 `Mkt_RF_decimal`。

## Stooq 备选源

公开页面：

- [Stooq Free Historical Market Data](https://stooq.com/db/h/)

常见 CSV 下载格式：

```text
https://stooq.com/q/d/l/?s=aapl.us&i=d&d1=20210701&d2=20260430
```

可用性判断：

- Stooq 提供免费历史市场数据和 CSV 下载入口。
- 本次直接请求 AAPL 与 QQQ CSV 时返回 JavaScript 浏览器验证页，而非 CSV。
- 因此 Stooq 不适合作为当前自动化批量下载主源。
- 若 Yahoo 后续限流，可用浏览器验证后的会话、人工下载、或延迟批量方式做备选核验。

## 数据完整性风险

需要在后续 CAR 脚本中显式处理以下问题。

1. 晚上市 ticker 的估计窗不足。
   ALAB、ARM、CEG、CRDO、CRWV、GEHC、NBIS、SNDK 等公司不能为早期事件提供完整估计窗。建议对事件 ticker 层面设置最小估计窗交易日数，不足则该 event-firm 观测不计算 CAR。

2. 当前成分股快照问题。
   当前公司池是 2026 年附近的 Nasdaq-100 和 SOX/SOXX 快照，不是 2022 年事件前历史成分股。主文需要说明，或后续补历史基准日成分股稳健性。

3. 事件反应日仍需精细化。
   当前只确认了官方日度日期。若能取得发布时间，应按美东盘前、盘中、盘后映射到首个可反应交易日。没有发布时间时，只能用官方日期顺延到最近美股交易日。

4. Yahoo 数据许可与稳定性。
   Yahoo 官方帮助页对离线 CSV 下载有订阅和许可说明。chart JSON 端点适合研究核对和可复现脚本，但应保存原始 JSON、下载日期和状态，避免未来端点变化导致不可追溯。

## 推荐落地方案

下载清单：

- 108 个股票 ticker。
- 市场基准 `QQQ`、`^NDX`、`^IXIC`、`SPY`、`^GSPC`、`SOXX`、`^SOX`。
- FF3 daily zip。

目录建议：

- 原始股票与基准 JSON 放入 `CAR/raw/yahoo_chart_json/`。
- 原始 FF3 zip 和 CSV 放入 `CAR/raw/factors/`。
- 标准化日度价格放入 `CAR/processed/prices_daily_long.csv`。
- 标准化日度收益放入 `CAR/processed/returns_daily_long.csv`。
- 下载状态和覆盖率报告放入 `CAR/reports/`。

主分析建议：

- 主样本为 Nasdaq-100。
- 主市场基准优先用 `QQQ` 或 `^NDX`，建议两者都保留。
- 稳健性一用 `SPY` 或 `^IXIC`。
- 稳健性二用 SOX/SOXX 样本，并用 `SOXX` 或 `^SOX`。
- FF3 CAR 使用 Kenneth French 日度因子，不再依赖第三方成品 CAR。

## 已核对来源

- [Yahoo Help, Download historical data in Yahoo Finance](https://help.yahoo.com/kb/SLN2311.html)
- [Kenneth R. French Data Library](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html)
- [Description of Fama/French Factors](https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/f-f_factors.html)
- [Stooq Free Historical Market Data](https://stooq.com/db/h/)

