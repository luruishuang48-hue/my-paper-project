# 子代理 B 数据风险审计

输入文件 `Analysis/processed/event_firm_panel.csv`。本审计只读取数据，并只写入本文件。

## 总体判断

面板本身是平衡的，125 个事件乘 108 家公司，共 13,500 行。Specr 显著结果的主要风险不来自缺行，而来自关系变量的稀疏性、公司组固定、变量重叠，以及事件标签集中在少数年份或少数发布者。

最高风险变量是 `rel_downstream_enabler`、`rel_is_owner`、`rel_is_investor`、`rel_competitor` 和 `rel_upstream_cloud`。其中 enabler 全零，owner 和 investor 观测很少，competitor 和 cloud 高度重叠且都由少数大科技公司构成。

事件标签里，`is_cross_modality_release` 和 `is_coding_model` 都只有 4 个事件，任何交互显著都应优先当作少数事件结果。`is_chinese_model` 与 `is_reasoning_model` 的事件数更多，但高度集中在 2025 年。

## 面板覆盖

- 行数 13500
- 事件数 125
- 公司数 108
- 每个事件公司数最小值 108，最大值 108
- 每家公司事件数最小值 125，最大值 125

事件年份分布

| 年份 | 事件数 |
| --- | --- |
| 2022 | 3 |
| 2023 | 8 |
| 2024 | 45 |
| 2025 | 59 |
| 2026 | 10 |

发布者事件数前列

| 发布者 | 事件数 |
| --- | --- |
| OpenAI | 21 |
| Google | 21 |
| Anthropic | 12 |
| DeepSeek | 8 |
| Alibaba | 8 |
| Stability.ai | 7 |
| xAI | 7 |
| Meta | 6 |
| Mistral | 6 |
| Midjourney | 3 |
| Microsoft | 3 |
| Black Forest Labs | 3 |
| Suno | 3 |
| Kimi | 3 |
| Z AI | 3 |

覆盖风险说明。2022 年只有 3 个事件，2023 年只有 8 个事件，2026 年只有 10 个事件。凡是按年份切分或依赖年份交互的 SPECR，都要先做 leave-one-year 或至少报告逐年贡献。

## 关系变量风险

| 变量 | 标记行 | 公司 | 事件 | 年份 | 变动形态 | 主要风险 |
| --- | --- | --- | --- | --- | --- | --- |
| rel_upstream_hardware | 3750 | 30 | 125 | 5 | 完全随公司固定 | 公司组固定；SOX/半导体暴露 |
| rel_upstream_cloud | 750 | 6 | 125 | 5 | 完全随公司固定 | 少数公司；公司组固定 |
| rel_downstream_integrator | 1997 | 16 | 125 | 5 | 几乎随公司固定，变动公司 1 家 | 中等风险 |
| rel_downstream_deployer | 3000 | 24 | 125 | 5 | 完全随公司固定 | 公司组固定 |
| rel_downstream_enabler | 0 | 0 | 0 | 0 | 空变量 | 不可用于 SPECR |
| rel_competitor | 759 | 7 | 125 | 5 | 事件内也变动，变动公司 6 家 | 少数公司 |
| rel_is_investor | 91 | 5 | 46 | 5 | 事件内也变动，变动公司 5 家 | 少数公司；事件覆盖少；单公司集中；事件特定且稀疏 |
| rel_is_owner | 53 | 5 | 32 | 4 | 事件内也变动，变动公司 5 家 | 少数公司；事件覆盖少；单公司集中；事件特定且稀疏 |

解释。`rel_upstream_hardware`、`rel_upstream_cloud`、`rel_downstream_deployer` 基本是公司组固定变量。它们不会被单一事件直接驱动，但很容易吸收行业、规模、成长股暴露和固定公司特征。带公司固定效应时，这类主效应无法识别；不带公司固定效应时，必须把结论写成公司组差异而不是事件冲击的精细关系效应。

## 行业和指数重叠

| 变量 | 公司数 | SOX 公司数 | 行业分布 | 指数标签 | 公司列表 |
| --- | --- | --- | --- | --- | --- |
| rel_upstream_hardware | 30 | 25 | Technology 23；Semiconductors 7 | both 18；sox_only 7；ndx_only 5 | ADI, ALAB, AMAT, AMD, ARM, ASML, ASX, AVGO, CRDO, ENTG, INTC, KLAC, LITE, LRCX, MCHP, MPWR, MRVL, MTSI, MU, NVDA, NXPI, ON, QCOM, SNDK, STX, TER, TSM, TXN, UMC, WDC |
| rel_upstream_cloud | 6 | 0 | Technology 5；Consumer Discretionary 1 | ndx_only 6 | AMZN, CRWV, GOOG, GOOGL, MSFT, NBIS |
| rel_downstream_integrator | 16 | 0 | Technology 15；Industrials 1 | ndx_only 16 | ADBE, ADSK, APP, AXON, CDNS, CRWD, DDOG, FTNT, INTU, MSFT, PANW, PLTR, SHOP, SNPS, TRI, WDAY |
| rel_downstream_deployer | 24 | 0 | Consumer Discretionary 10；Industrials 4；Health Care 4；Technology 3；Telecommunications 3 | ndx_only 24 | AAPL, ABNB, ADP, BKNG, CMCSA, CSCO, DASH, DXCM, EA, GEHC, HON, IDXX, ISRG, MELI, NFLX, PAYX, PDD, PYPL, SBUX, TMUS, TSLA, TTWO, WBD, WMT |
| rel_competitor | 7 | 0 | Technology 6；Consumer Discretionary 1 | ndx_only 7 | AAPL, ADBE, AMZN, GOOG, GOOGL, META, MSFT |
| rel_is_investor | 5 | 1 | Technology 4；Consumer Discretionary 1 | ndx_only 4；both 1 | AMZN, GOOG, GOOGL, MSFT, NVDA |
| rel_is_owner | 5 | 0 | Technology 4；Consumer Discretionary 1 | ndx_only 5 | AMZN, GOOG, GOOGL, META, MSFT |

特别注意。`rel_upstream_hardware` 中 25 家是 SOX 样本，公司层面几乎就是半导体暴露。若硬件关系显著，稳健解释应优先表述为 AI 发布对半导体或硬件互补资产的相对定价，而不是一般意义上的上游关系。

## 关系变量重叠

| 变量 A | 变量 B | 交集行 | Jaccard | 交集占 A | 交集占 B |
| --- | --- | --- | --- | --- | --- |
| rel_upstream_cloud | rel_competitor | 453 | 42.9% | 60.4% | 59.7% |
| rel_upstream_cloud | rel_is_investor | 63 | 8.1% | 8.4% | 69.2% |
| rel_competitor | rel_is_investor | 63 | 8.0% | 8.3% | 69.2% |
| rel_downstream_integrator | rel_competitor | 184 | 7.2% | 9.2% | 24.2% |
| rel_upstream_cloud | rel_is_owner | 47 | 6.2% | 6.3% | 88.7% |
| rel_upstream_cloud | rel_downstream_integrator | 122 | 4.6% | 16.3% | 6.1% |
| rel_downstream_integrator | rel_is_investor | 27 | 1.3% | 1.4% | 29.7% |
| rel_upstream_hardware | rel_is_investor | 28 | 0.7% | 0.7% | 30.8% |

重叠风险最强的是 `rel_upstream_cloud` 和 `rel_competitor`。两者交集 453 行，约占 cloud 的 60.4%，也约占 competitor 的 59.7%。`rel_is_owner` 有 88.7% 同时落在 cloud，`rel_is_investor` 有 69.2% 同时落在 cloud 或 competitor。若 SPECR 在这些变量间切换，系数变化可能只是同一批大科技公司的不同命名方式。

## 事件标签风险

| 标签 | 事件数 | 年份数 | 发布者数 | 年份分布 | 主要风险 |
| --- | --- | --- | --- | --- | --- |
| is_cross_modality_release | 4 | 2 | 3 | 2025 3；2024 1 | 极少事件；2025 年集中；发布者集中 |
| is_model_family | 29 | 4 | 11 | 2024 14；2025 12；2026 2；2023 1 | 中等风险 |
| is_multimodal | 52 | 4 | 10 | 2025 28；2024 17；2026 5；2023 2 | 中等风险 |
| is_reasoning_model | 42 | 3 | 10 | 2025 31；2026 7；2024 4 | 2025 年集中 |
| is_coding_model | 4 | 3 | 4 | 2024 2；2025 1；2026 1 | 极少事件 |
| is_media_generation_model | 41 | 5 | 16 | 2025 18；2024 14；2022 3；2023 3；2026 3 | 中等风险 |
| is_open_weight_or_open_source | 47 | 5 | 13 | 2024 20；2025 20；2026 3；2022 2；2023 2 | 中等风险 |
| is_chinese_model | 25 | 3 | 7 | 2025 18；2024 5；2026 2 | 事件偏少；2025 年集中 |
| multi_component_date_flag | 6 | 3 | 4 | 2025 3；2026 2；2024 1 | 极少事件；发布者集中；更像日期质量标记 |
| event_excluded_identity | 1 | 1 | 1 | 2026 1 | 极少事件；2026 年集中；发布者集中；更像日期质量标记 |
| official_date_is_trading_day | 121 | 5 | 23 | 2025 56；2024 44；2026 10；2023 8；2022 3 | 更像日期质量标记 |
| official_date_month_matches_ai_month | 123 | 5 | 23 | 2025 58；2024 45；2026 9；2023 8；2022 3 | 更像日期质量标记 |

标签风险说明。`is_cross_modality_release` 和 `is_coding_model` 样本太小，不适合作为核心异质性。`is_reasoning_model` 有 42 个事件，但 31 个在 2025 年。`is_chinese_model` 有 25 个事件，其中 18 个在 2025 年，且 DeepSeek 与 Alibaba 合计 16 个事件。

## 高风险关系乘事件标签组合

| 关系 | 标签 | 行数 | 公司 | 事件 | 年份 | 年份分布 | 公司分布前列 | 风险 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| rel_is_investor | is_coding_model | 2 | 2 | 1 | 1 | 2026 2 | MSFT 1；NVDA 1 | 事件少于等于 5；公司少于等于 5；观测少于 100；单公司占比高；年份集中 |
| rel_is_investor | is_cross_modality_release | 4 | 2 | 2 | 2 | 2024 2；2025 2 | MSFT 2；NVDA 2 | 事件少于等于 5；公司少于等于 5；观测少于 100；单公司占比高 |
| rel_is_owner | is_cross_modality_release | 3 | 3 | 2 | 1 | 2025 3 | AMZN 1；GOOG 1；GOOGL 1 | 事件少于等于 5；公司少于等于 5；观测少于 100；年份集中 |
| rel_upstream_cloud | is_cross_modality_release | 24 | 6 | 4 | 2 | 2025 18；2024 6 | AMZN 4；CRWV 4；GOOG 4 | 事件少于等于 5；观测少于 100；年份集中 |
| rel_upstream_cloud | is_coding_model | 24 | 6 | 4 | 3 | 2024 12；2025 6；2026 6 | AMZN 4；CRWV 4；GOOG 4 | 事件少于等于 5；观测少于 100 |
| rel_competitor | is_cross_modality_release | 25 | 7 | 4 | 2 | 2025 18；2024 7 | AAPL 4；ADBE 4；META 4 | 事件少于等于 5；观测少于 100；年份集中 |
| rel_competitor | is_coding_model | 25 | 7 | 4 | 3 | 2024 12；2026 7；2025 6 | AAPL 4；AMZN 4；GOOG 4 | 事件少于等于 5；观测少于 100 |
| rel_downstream_integrator | is_cross_modality_release | 64 | 16 | 4 | 2 | 2025 48；2024 16 | ADBE 4；ADSK 4；APP 4 | 事件少于等于 5；观测少于 100；年份集中 |
| rel_downstream_integrator | is_coding_model | 64 | 16 | 4 | 3 | 2024 32；2025 16；2026 16 | ADBE 4；ADSK 4；APP 4 | 事件少于等于 5；观测少于 100 |
| rel_downstream_deployer | is_cross_modality_release | 96 | 24 | 4 | 2 | 2025 72；2024 24 | AAPL 4；ABNB 4；ADP 4 | 事件少于等于 5；观测少于 100；年份集中 |
| rel_downstream_deployer | is_coding_model | 96 | 24 | 4 | 3 | 2024 48；2025 24；2026 24 | AAPL 4；ABNB 4；ADP 4 | 事件少于等于 5；观测少于 100 |
| rel_upstream_hardware | is_cross_modality_release | 120 | 30 | 4 | 2 | 2025 90；2024 30 | ADI 4；ALAB 4；AMAT 4 | 事件少于等于 5；年份集中 |
| rel_upstream_hardware | is_coding_model | 120 | 30 | 4 | 3 | 2024 60；2025 30；2026 30 | ADI 4；ALAB 4；AMAT 4 | 事件少于等于 5 |
| rel_is_investor | multi_component_date_flag | 10 | 5 | 5 | 3 | 2026 5；2025 3；2024 2 | MSFT 4；NVDA 3；AMZN 1 | 事件少于等于 5；公司少于等于 5；观测少于 100；单公司占比高 |
| rel_upstream_cloud | multi_component_date_flag | 36 | 6 | 6 | 3 | 2025 18；2026 12；2024 6 | AMZN 6；CRWV 6；GOOG 6 | 观测少于 100 |
| rel_competitor | multi_component_date_flag | 39 | 7 | 6 | 3 | 2025 19；2026 13；2024 7 | AAPL 6；AMZN 6；GOOG 6 | 观测少于 100 |
| rel_downstream_integrator | multi_component_date_flag | 96 | 16 | 6 | 3 | 2025 48；2026 32；2024 16 | ADBE 6；ADSK 6；APP 6 | 观测少于 100 |
| rel_is_investor | is_open_weight_or_open_source | 8 | 2 | 7 | 3 | 2024 4；2025 3；2026 1 | MSFT 7；NVDA 1 | 公司少于等于 5；观测少于 100；单公司占比高 |
| rel_is_owner | is_reasoning_model | 13 | 3 | 7 | 2 | 2025 11；2024 2 | GOOG 6；GOOGL 6；AMZN 1 | 公司少于等于 5；观测少于 100；单公司占比高；年份集中 |
| rel_is_investor | is_media_generation_model | 14 | 2 | 8 | 5 | 2025 7；2022 2；2023 2 | NVDA 8；MSFT 6 | 公司少于等于 5；观测少于 100；单公司占比高 |
| rel_is_owner | is_media_generation_model | 15 | 3 | 8 | 3 | 2025 9；2024 4；2026 2 | GOOG 7；GOOGL 7；AMZN 1 | 公司少于等于 5；观测少于 100；单公司占比高；年份集中 |
| rel_is_owner | is_open_weight_or_open_source | 11 | 4 | 10 | 3 | 2024 6；2025 4；2023 1 | META 6；MSFT 3；GOOG 1 | 公司少于等于 5；观测少于 100；单公司占比高 |
| rel_is_owner | is_model_family | 14 | 5 | 11 | 3 | 2024 8；2025 5；2023 1 | META 5；GOOG 3；GOOGL 3 | 公司少于等于 5；观测少于 100 |
| rel_is_investor | is_model_family | 22 | 5 | 11 | 3 | 2025 9；2024 8；2026 5 | NVDA 7；MSFT 6；AMZN 3 | 公司少于等于 5；观测少于 100 |
| rel_is_owner | is_multimodal | 33 | 5 | 19 | 3 | 2025 17；2024 14；2023 2 | GOOG 14；GOOGL 14；META 2 | 公司少于等于 5；观测少于 100；单公司占比高 |
| rel_is_investor | is_reasoning_model | 48 | 5 | 23 | 3 | 2025 35；2026 9；2024 4 | NVDA 15；MSFT 12；AMZN 7 | 公司少于等于 5；观测少于 100；年份集中 |
| rel_upstream_cloud | is_chinese_model | 150 | 6 | 25 | 3 | 2025 108；2024 30；2026 12 | AMZN 25；CRWV 25；GOOG 25 | 年份集中 |
| rel_competitor | is_chinese_model | 152 | 7 | 25 | 3 | 2025 110；2024 30；2026 12 | AAPL 25；AMZN 25；GOOG 25 | 年份集中 |
| rel_downstream_integrator | is_chinese_model | 400 | 16 | 25 | 3 | 2025 288；2024 80；2026 32 | ADBE 25；ADSK 25；APP 25 | 年份集中 |
| rel_downstream_deployer | is_chinese_model | 600 | 24 | 25 | 3 | 2025 432；2024 120；2026 48 | AAPL 25；ABNB 25；ADP 25 | 年份集中 |
| rel_upstream_hardware | is_chinese_model | 750 | 30 | 25 | 3 | 2025 540；2024 150；2026 60 | ADI 25；ALAB 25；AMAT 25 | 年份集中 |
| rel_is_investor | is_multimodal | 64 | 5 | 31 | 4 | 2025 36；2024 19；2026 7 | NVDA 18；MSFT 16；AMZN 10 | 公司少于等于 5；观测少于 100 |
| rel_upstream_cloud | is_reasoning_model | 252 | 6 | 42 | 3 | 2025 186；2026 42；2024 24 | AMZN 42；CRWV 42；GOOG 42 | 年份集中 |
| rel_competitor | is_reasoning_model | 257 | 7 | 42 | 3 | 2025 188；2026 44；2024 25 | AAPL 42；META 42；MSFT 42 | 年份集中 |
| rel_downstream_integrator | is_reasoning_model | 672 | 16 | 42 | 3 | 2025 496；2026 112；2024 64 | ADBE 42；ADSK 42；APP 42 | 年份集中 |
| rel_downstream_deployer | is_reasoning_model | 1008 | 24 | 42 | 3 | 2025 744；2026 168；2024 96 | AAPL 42；ABNB 42；ADP 42 | 年份集中 |
| rel_upstream_hardware | is_reasoning_model | 1260 | 30 | 42 | 3 | 2025 930；2026 210；2024 120 | ADI 42；ALAB 42；AMAT 42 | 年份集中 |

这些组合最容易产生看起来显著但不稳的 SPECR 结果。尤其是 owner 或 investor 与任何事件标签的交互，通常只有个位数到几十个标记行。`rel_upstream_cloud`、`rel_competitor` 与 cross-modality 或 coding 的交互也只有 24 到 25 行，事件数只有 4 个。

## 控制变量导致的样本变化

| 样本定义 | 行数 | 事件 | 公司 | 年份 | 年份事件分布 |
| --- | --- | --- | --- | --- | --- |
| 全样本 | 13500 | 125 | 108 | 5 | 2025 59；2024 45；2026 10；2023 8；2022 3 |
| QQQ CAR[0,20] 非缺失 | 13173 | 125 | 108 | 5 | 2025 59；2024 45；2026 10；2023 8；2022 3 |
| QQQ CAR[0,20] 加规模、B/M、动量、波动率 | 12389 | 125 | 106 | 5 | 2025 59；2024 45；2026 10；2023 8；2022 3 |
| 再加 AA intelligence index | 8791 | 88 | 106 | 4 | 2025 44；2024 32；2026 7；2023 5 |

| 变量 | 缺失行 | 涉及事件 | 涉及公司 |
| --- | --- | --- | --- |
| size_log_assets | 101 | 9 | 91 |
| bm_ratio | 1027 | 125 | 91 |
| momentum | 335 | 100 | 8 |
| volatility | 327 | 99 | 8 |
| aa_intelligence_index | 3996 | 37 | 108 |
| car_mm_qqq_0_20 | 327 | 99 | 8 |

常见控制变量缺失最严重的公司

| ticker | 控制缺失占比 |
| --- | --- |
| ORLY | 100.0% |
| SBUX | 100.0% |
| STX | 95.2% |
| MAR | 94.4% |
| BKNG | 94.4% |
| CRWV | 80.0% |
| SNDK | 74.4% |
| NBIS | 62.4% |
| ALNY | 36.0% |
| ALAB | 32.8% |
| FTNT | 21.6% |
| KLAC | 15.2% |

样本变化风险。加入规模、B/M、动量和波动率后，样本仍保留 125 个事件，但只剩 106 家公司。再加入 AA intelligence index 后，样本降到 88 个事件，并且 2022 年全部消失。这会显著改变媒体模型、早期事件和低基准覆盖事件的权重。

## SPECR 解读建议

1. `rel_downstream_enabler` 不能进入有效 SPECR，因为全样本为零。
2. `rel_is_owner` 和 `rel_is_investor` 的显著性必须视为探索性结果。最低限度要做 leave-one-firm、leave-one-creator 和 leave-one-year。
3. `rel_competitor` 与 `rel_upstream_cloud` 的显著性需要联合呈现。单独显著不等于两个概念都独立存在。
4. `rel_upstream_hardware` 相对可靠，但它主要是 SOX 或半导体公司组。解释时应避免把半导体行业效应包装成普遍上游效应。
5. `is_cross_modality_release`、`is_coding_model`、`multi_component_date_flag` 不适合作为核心异质性标签。
6. `is_chinese_model` 和 `is_reasoning_model` 的显著性要报告年份集中问题，特别是 2025 年贡献。
7. 含 AA intelligence index 的规格不能和不含该变量的规格直接比较，因为事件覆盖从 125 个掉到 88 个，样本定义已经改变。

## 主代理优先核查清单

- 对所有显著项做 leave-one-year，重点看 2025 年。
- 对 owner、investor、cloud、competitor 做 leave-one-firm，重点看 MSFT、NVDA、AMZN、GOOG、GOOGL、META、AAPL、ADBE。
- 对发布者交互做 leave-one-creator，重点看 OpenAI、Google、Anthropic、DeepSeek、Alibaba。
- 对硬件结果分开报告 SOX 内外，或至少说明硬件变量与 SOX 暴露的对应关系。
- 对 cross-modality、coding、multi-component date 只做附录探索，不应进入主结论。
