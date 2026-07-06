# SEC companyfacts 可用性与字段口径核对

生成时间：2026-07-02 22:52:13，北京时间。

## 任务边界

本报告只核对 SEC companyfacts API 对 `CAR/metadata/firm_universe_for_car.csv` 中 108 家股票的可用性和字段定义。不修改 `Fundamentals/` 下任何文件。

输入文件：

- `CAR/metadata/firm_universe_for_car.csv`
- `CAR/README.md`

官方来源：

- SEC ticker-CIK 映射：https://www.sec.gov/files/company_tickers.json
- SEC EDGAR API 说明：https://www.sec.gov/search-filings/edgar-application-programming-interfaces
- SEC companyfacts 模板：`https://data.sec.gov/api/xbrl/companyfacts/CIK##########.json`

SEC 官方说明要点。`companyfacts` 端点按单个 CIK 返回该公司全部 XBRL concept 数据。每个 concept 按单位分组，事实项通常含 `end`、`val`、`accn`、`fy`、`fp`、`form`、`filed`、`frame`，部分期间型字段还含 `start`。SEC 文档还说明，`frames` 端点按日历期聚合；公司财年日期可能不完全等同自然季度，使用 `frame` 时要留意。

## 总体结论

- 公司池共 108 家。
- SEC ticker-CIK 映射命中 108 个股票代码，对应 107 个唯一 CIK。GOOG 和 GOOGL 共用 Alphabet 的 CIK。
- companyfacts 端点 HTTP 200 返回 108 家。
- 资产类字段可用 108 家。
- 权益类字段可用 108 家。
- 股数字段可用 108 家。
- `DocumentFiscalYearFocus` 或 `DocumentFiscalPeriodFocus` 可用 0 家。

结论是，SEC companyfacts 可以作为本项目季度财务数据的主来源。美国公司基本可直接用 `us-gaap` 字段。外资发行人和 ADR 也能通过 SEC 获取数据，但 ASX、CCEP、FER、TRI、TSM、UMC 使用 `ifrs-full` taxonomy，不能只写死 `us-gaap`。

## 字段口径

- `us-gaap:Assets` 表示报告主体资产总额，是资产负债表瞬时项。样本中单位为 `USD`。
- `ifrs-full:Assets` 是 IFRS 发行人的资产总额。ASX、CCEP、FER、TRI、TSM、UMC 使用该口径。
- `us-gaap:StockholdersEquity` 表示股东权益。样本中 102 家 US-GAAP 公司可用。
- `us-gaap:StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest` 可作为权益备选口径，但包含非控制性权益，不能与普通股东权益静默混用。
- `ifrs-full:Equity` 和 `ifrs-full:EquityAttributableToOwnersOfParent` 是 IFRS 权益口径。后者更接近归属于母公司股东的权益。
- `dei:EntityCommonStockSharesOutstanding` 是封面披露的普通股或相关权益单位数量，单位通常为 `shares`。它更适合估算季末市值。
- `us-gaap:CommonStockSharesOutstanding` 是普通股股数备选项。本轮覆盖低于 `dei:EntityCommonStockSharesOutstanding`。
- `us-gaap:WeightedAverageNumberOfSharesOutstandingBasic` 和 `us-gaap:WeightedAverageNumberOfDilutedSharesOutstanding` 是期间平均股数，适合 EPS 口径，不等同季末流通股数。
- `dei:DocumentFiscalYearFocus` 和 `dei:DocumentFiscalPeriodFocus` 是报告封面的财年和期间焦点 concept。本轮 108 家的 companyfacts JSON 中未观察到这两个 concept；后续季度面板应使用每条 fact 自带的 `fy` 和 `fp`。
- `fy`、`fp`、`end`、`filed`、`form`、`frame` 是 companyfacts fact 层字段。`fy/fp` 是申报财年和期间，`end` 是事实截止日，`filed` 是文件提交日，`form` 是申报类型，`frame` 是 SEC 对齐自然日历期后的框架标签。

推荐后续取数顺序：

1. 总资产优先用 `us-gaap:Assets`。若公司只含 IFRS taxonomy，则用 `ifrs-full:Assets`，并标记 `taxonomy=ifrs-full`。
2. 股东权益优先用 `us-gaap:StockholdersEquity`。若缺失，再用 `us-gaap:StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest` 或 `us-gaap:StockholdersEquityAttributableToParent`。IFRS 发行人优先用 `ifrs-full:EquityAttributableToOwnersOfParent`，再用 `ifrs-full:Equity`。
3. 季末股数优先用 `dei:EntityCommonStockSharesOutstanding`。若缺失，可考虑 `us-gaap:CommonStockSharesOutstanding` 或公司披露的 IFRS 股数字段。加权平均股数只能作为补充。
4. 不建议依赖 `DocumentFiscalYearFocus` 和 `DocumentFiscalPeriodFocus`。本轮 companyfacts 未观察到这两个字段。季度面板主键应使用 fact 层 `fy`、`fp`、`end`、`filed`、`form`、`frame`。

## 关键缺口

- 未命中 SEC ticker-CIK 映射：无。
- companyfacts 未返回 HTTP 200：无。
- 有 companyfacts 但未观察到资产类字段：无。
- 有 companyfacts 但未观察到权益类字段：无。
- 有 companyfacts 但未观察到股数字段：无。
- 有 companyfacts 但未观察到 `DocumentFiscalYearFocus` 或 `DocumentFiscalPeriodFocus`：AAPL、ABNB、ADBE、ADI、ADP、ADSK、AEP、ALAB、ALNY、AMAT、AMD、AMGN、AMZN、APP、ARM、ASML、ASX、AVGO、AXON、BKNG、BKR、CCEP、CDNS、CEG、CMCSA、COST、CPRT、CRDO、CRWD、CRWV、CSCO、CSX、CTAS、DASH、DDOG、DXCM、EA、ENTG、EXC、FANG、FAST、FER、FTNT、GEHC、GILD、GOOG、GOOGL、HON、IDXX、INTC、INTU、ISRG、KDP、KHC、KLAC、LIN、LITE、LRCX、MAR、MCHP、MDLZ、MELI、META、MNST、MPWR、MRVL、MSFT、MSTR、MTSI、MU、NBIS、NFLX、NVDA、NXPI、ODFL、ON、ORLY、PANW、PAYX、PCAR、PDD、PEP、PLTR、PYPL、QCOM、REGN、RKLB、ROP、ROST、SBUX、SHOP、SNDK、SNPS、STX、TER、TMUS、TRI、TSLA、TSM、TTWO、TXN、UMC、VRTX、WBD、WDAY、WDC、WMT、XEL。
- 含 `ifrs-full` taxonomy 的公司：ASX、CCEP、FER、TRI、TSM、UMC。
- 有 companyfacts 但不含 `us-gaap` namespace 的公司：ASX、CCEP、FER、TRI、TSM、UMC。

## 精确字段覆盖

| 字段 | 覆盖家数 |
|---|---:|
| `us-gaap:Assets` | 102 |
| `ifrs-full:Assets` | 6 |
| `us-gaap:StockholdersEquity` | 102 |
| `ifrs-full:Equity` | 6 |
| `ifrs-full:EquityAttributableToOwnersOfParent` | 6 |
| `dei:EntityCommonStockSharesOutstanding` | 95 |
| `us-gaap:CommonStockSharesOutstanding` | 91 |
| `us-gaap:WeightedAverageNumberOfSharesOutstandingBasic` | 101 |
| `us-gaap:WeightedAverageNumberOfDilutedSharesOutstanding` | 102 |
| `dei:DocumentFiscalYearFocus` | 0 |
| `dei:DocumentFiscalPeriodFocus` | 0 |

## 对后续季度面板的建议

后续可以直接写下载脚本，按 CIK 保存完整 companyfacts JSON。标准化时保留原始事实层字段，至少包括 `taxonomy`、`tag`、`unit`、`val`、`start`、`end`、`accn`、`fy`、`fp`、`form`、`filed`、`frame`。不要只保留一个宽表数值，否则后面很难复核 fiscal quarter 与 calendar quarter 的差异。

季度数据筛选建议：

- 资产和权益用瞬时项，优先选择 `form` 为 `10-Q`、`10-K`、`20-F`、`40-F`、`6-K` 的事实。
- 同一 ticker、字段、`end`、`fy`、`fp` 有多条事实时，优先保留较晚 `filed`，但保留原始 `accn` 供审计。
- `frame` 可用于对齐自然季度，但不能替代 `fy/fp/end`。主面板建议用公司财年季度，回归时再按事件日向前匹配最近一期已披露财务。
- 外资发行人保留 taxonomy 标记。IFRS 权益字段与 US-GAAP 股东权益不是完全同名口径，不能静默混为一个变量。

## 公司级可用性表

| ticker | CIK | SEC title | HTTP | assets | equity | shares | document focus | taxonomies |
|---|---:|---|---:|---|---|---|---|---|
| AAPL | 0000320193 | Apple Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| ABNB | 0001559720 | Airbnb, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:WeightedAverageNumberOfSharesOutstandingBasic | - | dei;ecd;us-gaap |
| ADBE | 0000796343 | ADOBE INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;srt;us-gaap |
| ADI | 0000006281 | ANALOG DEVICES INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;srt;us-gaap |
| ADP | 0000008670 | AUTOMATIC DATA PROCESSING INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;us-gaap |
| ADSK | 0000769397 | Autodesk, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;invest;us-gaap |
| AEP | 0000004904 | AMERICAN ELECTRIC POWER CO INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;us-gaap |
| ALAB | 0001736297 | Astera Labs, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| ALNY | 0001178670 | ALNYLAM PHARMACEUTICALS, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| AMAT | 0000006951 | APPLIED MATERIALS INC /DE | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| AMD | 0000002488 | ADVANCED MICRO DEVICES INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;srt;us-gaap |
| AMGN | 0000318154 | AMGEN INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| AMZN | 0001018724 | AMAZON COM INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| APP | 0001751008 | AppLovin Corp | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| ARM | 0001973239 | ARM HOLDINGS PLC /UK | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;us-gaap |
| ASML | 0000937966 | ASML HOLDING NV | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| ASX | 0001122411 | ASE Technology Holding Co., Ltd. | 200 | ifrs-full:Assets | ifrs-full:Equity | dei:EntityCommonStockSharesOutstanding | - | dei;ifrs-full |
| AVGO | 0001730168 | Broadcom Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;srt;us-gaap |
| AXON | 0001069183 | AXON ENTERPRISE, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| BKNG | 0001075531 | Booking Holdings Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| BKR | 0001701605 | Baker Hughes Co | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;us-gaap |
| CCEP | 0001650107 | COCA-COLA EUROPACIFIC PARTNERS plc | 200 | ifrs-full:Assets | ifrs-full:Equity | dei:EntityCommonStockSharesOutstanding | - | dei;ifrs-full |
| CDNS | 0000813672 | CADENCE DESIGN SYSTEMS INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| CEG | 0001868275 | Constellation Energy Corp | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| CMCSA | 0001166691 | COMCAST CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| COST | 0000909832 | COSTCO WHOLESALE CORP /NEW | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;srt;us-gaap |
| CPRT | 0000900075 | COPART INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| CRDO | 0001807794 | Credo Technology Group Holding Ltd | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| CRWD | 0001535527 | CrowdStrike Holdings, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| CRWV | 0001769628 | CoreWeave, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:WeightedAverageNumberOfSharesOutstandingBasic | - | dei;ecd;ffd;us-gaap |
| CSCO | 0000858877 | CISCO SYSTEMS, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;us-gaap |
| CSX | 0000277948 | CSX CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| CTAS | 0000723254 | CINTAS CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;us-gaap |
| DASH | 0001792789 | DoorDash, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:WeightedAverageNumberOfSharesOutstandingBasic | - | dei;ecd;srt;us-gaap |
| DDOG | 0001561550 | Datadog, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| DXCM | 0001093557 | DEXCOM INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| EA | 0000712515 | ELECTRONIC ARTS INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| ENTG | 0001101302 | ENTEGRIS INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| EXC | 0001109357 | EXELON CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;srt;us-gaap |
| FANG | 0001539838 | Diamondback Energy, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;srt;us-gaap |
| FAST | 0000815556 | FASTENAL CO | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| FER | 0001468522 | Ferrovial N.V. | 200 | ifrs-full:Assets | ifrs-full:Equity | dei:EntityCommonStockSharesOutstanding | - | dei;ifrs-full |
| FTNT | 0001262039 | Fortinet, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;invest;us-gaap |
| GEHC | 0001932393 | GE HealthCare Technologies Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| GILD | 0000882095 | GILEAD SCIENCES, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;us-gaap |
| GOOG | 0001652044 | Alphabet Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| GOOGL | 0001652044 | Alphabet Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| HON | 0000773840 | HONEYWELL INTERNATIONAL INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;srt;us-gaap |
| IDXX | 0000874716 | IDEXX LABORATORIES INC /DE | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;srt;us-gaap |
| INTC | 0000050863 | INTEL CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;us-gaap |
| INTU | 0000896878 | INTUIT INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;srt;us-gaap |
| ISRG | 0001035267 | INTUITIVE SURGICAL INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;us-gaap |
| KDP | 0001418135 | Keurig Dr Pepper Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| KHC | 0001637459 | Kraft Heinz Co | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;srt;us-gaap |
| KLAC | 0000319201 | KLA CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| LIN | 0001707925 | LINDE PLC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;invest;us-gaap |
| LITE | 0001633978 | Lumentum Holdings Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| LRCX | 0000707549 | LAM RESEARCH CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| MAR | 0001048286 | MARRIOTT INTERNATIONAL INC /MD/ | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| MCHP | 0000827054 | MICROCHIP TECHNOLOGY INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| MDLZ | 0001103982 | Mondelez International, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| MELI | 0001099590 | MERCADOLIBRE INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;srt;us-gaap |
| META | 0001326801 | Meta Platforms, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:WeightedAverageNumberOfSharesOutstandingBasic | - | dei;ecd;ffd;srt;us-gaap |
| MNST | 0000865752 | Monster Beverage Corp | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| MPWR | 0001280452 | MONOLITHIC POWER SYSTEMS INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| MRVL | 0001835632 | Marvell Technology, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;srt;us-gaap |
| MSFT | 0000789019 | MICROSOFT CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| MSTR | 0001050446 | Strategy Inc | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:WeightedAverageNumberOfSharesOutstandingBasic | - | dei;ecd;invest;us-gaap |
| MTSI | 0001493594 | MACOM Technology Solutions Holdings, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| MU | 0000723125 | MICRON TECHNOLOGY INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;us-gaap |
| NBIS | 0001513845 | Nebius Group N.V. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | us-gaap |
| NFLX | 0001065280 | NETFLIX INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;srt;us-gaap |
| NVDA | 0001045810 | NVIDIA CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;invest;srt;us-gaap |
| NXPI | 0001413447 | NXP Semiconductors N.V. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;invest;srt;us-gaap |
| ODFL | 0000878927 | OLD DOMINION FREIGHT LINE, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| ON | 0001097864 | ON SEMICONDUCTOR CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;us-gaap |
| ORLY | 0000898173 | O REILLY AUTOMOTIVE INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| PANW | 0001327567 | Palo Alto Networks Inc | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;srt;us-gaap |
| PAYX | 0000723531 | PAYCHEX INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;srt;us-gaap |
| PCAR | 0000075362 | PACCAR INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| PDD | 0001737806 | PDD Holdings Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | us-gaap |
| PEP | 0000077476 | PEPSICO INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| PLTR | 0001321655 | Palantir Technologies Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | dei;ecd;srt;us-gaap |
| PYPL | 0001633917 | PayPal Holdings, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;invest;srt;us-gaap |
| QCOM | 0000804328 | QUALCOMM INC/DE | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;srt;us-gaap |
| REGN | 0000872589 | REGENERON PHARMACEUTICALS, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| RKLB | 0001819994 | Rocket Lab Corp | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| ROP | 0000882835 | ROPER TECHNOLOGIES INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;invest;us-gaap |
| ROST | 0000745732 | ROSS STORES, INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;srt;us-gaap |
| SBUX | 0000829224 | STARBUCKS CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;us-gaap |
| SHOP | 0001594805 | SHOPIFY INC. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | us-gaap:CommonStockSharesOutstanding | - | dei;srt;us-gaap |
| SNDK | 0002023554 | Sandisk Corp | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;us-gaap |
| SNPS | 0000883241 | SYNOPSYS INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;srt;us-gaap |
| STX | 0001137789 | Seagate Technology Holdings plc | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;us-gaap |
| TER | 0000097210 | TERADYNE, INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;us-gaap |
| TMUS | 0001283699 | T-Mobile US, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| TRI | 0001075124 | THOMSON REUTERS CORP /CAN/ | 200 | ifrs-full:Assets | ifrs-full:Equity | dei:EntityCommonStockSharesOutstanding | - | dei;ifrs-full |
| TSLA | 0001318605 | Tesla, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;us-gaap |
| TSM | 0001046179 | TAIWAN SEMICONDUCTOR MANUFACTURING CO LTD | 200 | ifrs-full:Assets | ifrs-full:Equity | dei:EntityCommonStockSharesOutstanding | - | dei;ifrs-full;srt |
| TTWO | 0000946581 | TAKE TWO INTERACTIVE SOFTWARE INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;invest;us-gaap |
| TXN | 0000097476 | TEXAS INSTRUMENTS INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;us-gaap |
| UMC | 0001033767 | UNITED MICROELECTRONICS CORP | 200 | ifrs-full:Assets | ifrs-full:Equity | dei:EntityCommonStockSharesOutstanding | - | dei;ifrs-full |
| VRTX | 0000875320 | VERTEX PHARMACEUTICALS INC / MA | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ffd;srt;us-gaap |
| WBD | 0001437107 | Warner Bros. Discovery, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;us-gaap |
| WDAY | 0001327811 | Workday, Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;us-gaap |
| WDC | 0000106040 | WESTERN DIGITAL CORP | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;invest;srt;us-gaap |
| WMT | 0000104169 | Walmart Inc. | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;invest;us-gaap |
| XEL | 0000072903 | XCEL ENERGY INC | 200 | us-gaap:Assets | us-gaap:StockholdersEquity | dei:EntityCommonStockSharesOutstanding | - | dei;ecd;ffd;invest;us-gaap |

## 附属输出

- `agent_tasks/fundamentals_collection_20260702-223530/sec_companyfacts_status.csv`
- `agent_tasks/fundamentals_collection_20260702-223530/sec_companyfacts_field_coverage.csv`
- `agent_tasks/fundamentals_collection_20260702-223530/sec_company_tickers.json`
- `agent_tasks/fundamentals_collection_20260702-223530/sec_companyfacts_samples/`
