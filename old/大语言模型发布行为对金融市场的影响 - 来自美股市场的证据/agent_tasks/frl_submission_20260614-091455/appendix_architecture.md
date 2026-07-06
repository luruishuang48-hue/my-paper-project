# FRL 投稿稿 online appendix 结构与内容清单

生成时间 2026-06-14，北京时间。

本文件服务于一篇短正文、长附录的 Finance Research Letters 投稿稿。正文只保留最稳的闭源模型能力定价结果，online appendix 承担三项任务。第一，交代样本、变量和人工关系标注。第二，完整展示推断稳健性。第三，把有信息量但不宜支撑主线的机制和异质性结果集中放置，并明确标为 exploratory。

## 总体安排

建议采用 A 至 J 的附录结构。A 到 D 放主要稳健性，正文应直接引用。E 到 G 放规格空间、机制和异质性，正文可选择性引用。H 到 J 放诊断、数据限制和可复现材料，主要用于回应审稿人。

建议正文最多引用 5 张附录表。

- Table A2，变量与样本构造。
- Table B1，CR0、CR2 和 wild cluster bootstrap 的核心推断。
- Table C1，firm fixed effects、two-way clustering、FF3 CAR 和 pre-event CAR。
- Table D1，事件层聚合结果。
- Table D2，leave-one-creator-out。

## Appendix A 样本构造、变量定义与数据口径

本节回答读者对样本来源和变量定义的基本问题。它应放在附录最前面，因为正文篇幅有限，不可能完整解释 60 个事件、47 个 intelligence 事件和 86 家公司之间的关系。

### 应包含的内容

- 事件集的构造流程。
- 60 个重大 AI 模型发布事件的原始口径。
- 进入 AA Intelligence Index 回归的 47 个事件。
- 5,161 条原始公司事件配对观测。
- 3,780 条核心 intelligence 回归观测。
- 闭源样本的 36 个事件和 2,899 条观测。
- 开源样本的 11 个事件。
- CAR 窗口定义，包括 CAR[0,+1]、CAR[0,+5]、CAR[0,+20] 和 pre-event CAR。
- 市场模型 CAR 与 FF3 CAR 的差异。
- AA Intelligence Index、AA Coding Index、AA Math Index、AA Media Elo 的来源、覆盖率和含义。
- open-weight、closed-source、owner、investor、cloud、upstream、downstream 和 competitor 的编码规则。
- 年份固定效应、公司控制变量和均值中心化 intelligence 的定义。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 用途 |
|---|---|---|---|
| Table A1 | Event sample construction | 从 60 个事件到 47 个 intelligence 事件的筛选流程 | 主要数据说明 |
| Table A2 | Variable definitions | CAR、能力指标、关系变量、控制变量和固定效应 | 主要数据说明 |
| Table A3 | Coverage of capability measures | 四个能力指标的覆盖观测数、事件数和缺失情况 | 主要数据说明 |
| Table A4 | Relationship coding categories | owner、investor、cloud、upstream、downstream、competitor 的定义和数量 | 主要数据说明 |
| Table A5 | Summary statistics | 核心变量的 N、均值、标准差、分位数 | 主要数据说明 |

### 需要保守说明的点

- 样本不是纯文本 LLM。它包含图像、视频、多模态、代码和推理模型。正文若使用 LLM 表述，需要改为 AI model releases 或 frontier AI model releases。
- 47 个事件才有 AA Intelligence Index。主回归的有效事件数不是 60。
- 关系变量来自人工标注，适合机制探索和异质性描述，不适合做强因果解释。

## Appendix B 核心推断与小聚类修正

本节是 online appendix 中最重要的稳健性模块。它展示同一组核心估计在 CR0、CR2 和 wild cluster bootstrap 下的结果。正文只需要报告闭源主结果和开源衰减结果，但附录必须展示完整推断。

### 应包含的内容

- 全样本 CAR[0,+20] 的 intelligence 斜率。
- 闭源样本 CAR[0,+20] 的 intelligence 斜率。
- intelligence × open-weight 交互模型。
- investor、cloud、owner 的交互项结果，但放在同表的后半部分或单独表中。
- CR2 的 Bell-McCaffrey 小聚类修正。
- wild cluster bootstrap 的实现说明，事件为聚类单位，Rademacher 扰动，B = 4,999。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table B1 | Small-cluster inference for the main estimates | 全样本、闭源、open-weight 交互的 CR0、CR2、wild p 值 | 主要稳健性 |
| Table B2 | Small-cluster inference for relationship interactions | investor、cloud、owner 短窗口交互 | exploratory |
| Table B3 | Wild cluster bootstrap implementation | 受限模型、扰动方式、重复次数和聚类层级 | 方法说明 |

### 可作为主要稳健性的结果

- 闭源 CAR[0,+20]，系数 0.002317，CR2 p = 0.0069，wild p = 0.0082。
- open-weight 交互项，系数 -0.003734，CR2 p = 0.0475，wild p = 0.0858。它可作为机制性稳健结果，但正文应写成 attenuation，而不是强因果机制。

### 应标为 exploratory 的结果

- investor 交互项，CR2 p = 0.0498，但 wild p = 0.1256。
- cloud 交互项，CR2 p = 0.1003，wild p = 0.1374。
- owner 的短窗口负向交互较稳定，但窗口和样本较窄，适合标为 short-window exploratory evidence。

## Appendix C 替代规格、固定效应和替代 CAR

本节展示核心结果不依赖公司间固定差异、单一标准误口径和市场模型 CAR。它应紧跟 Appendix B。

### 应包含的内容

- 加入 firm fixed effects 后的全样本和闭源结果。
- event cluster、firm cluster 和 event firm two-way cluster 的并列表。
- FF3 CAR[0,+20] 替代市场模型 CAR。
- pre-event CAR 作为因变量的提前定价检验。
- 美国交易标的粗口径检验，需注明只是 ticker 后缀规则近似。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table C1 | Firm fixed effects and alternative clustering | firm FE，event、firm、two-way clustering | 主要稳健性 |
| Table C2 | FF3 abnormal returns | 全样本和闭源样本的 FF3 CAR[0,+20] | 主要稳健性 |
| Table C3 | Pre-event abnormal returns | pre-event CAR 的全样本和闭源回归 | 主要稳健性 |
| Table C4 | U.S.-listed sample approximation | 无交易所后缀 ticker 口径下的结果 | 补充稳健性 |

### 可作为主要稳健性的结果

- 闭源样本加入 firm FE 后，系数 0.002260，event-cluster p = 0.0010，two-way cluster p = 0.0138。
- 闭源 FF3 CAR[0,+20]，系数 0.001176，p = 0.0274。
- 全样本 pre-event CAR，p = 0.576。
- 闭源 pre-event CAR，p = 0.119。

### 写作注意

pre-event 结果只能说明没有强证据显示发布前系统性定价。不要写成完全排除信息泄露。美国交易标的粗口径只能作为补充检验，不应写成正式美国上市公司样本。

## Appendix D 有效样本量、事件层聚合和发布者集中度

本节回应一个关键计量质疑。虽然主数据有数千条 firm-event 观测，核心解释变量是在事件层变化的。附录必须说明结果不是靠堆公司观测制造显著性。

### 应包含的内容

- 事件层 equal-weighted 平均 CAR 回归。
- 闭源事件层全体公司均值结果。
- 显性关系公司均值结果。
- leave-one-creator-out。
- 主要 creator 包括 Google、OpenAI、Anthropic、Alibaba、Meta、xAI、Microsoft。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table D1 | Event-level aggregated returns | 全体公司均值和显性关系公司均值 | 主要稳健性 |
| Table D2 | Leave-one-creator-out estimates | 逐一剔除主要发布者后的闭源结果 | 主要稳健性 |
| Figure D1 | Event-level scatter plot | 闭源事件平均 CAR 与 AA Intelligence Index 的散点图 | 主要稳健性 |

### 可作为主要稳健性的结果

- 闭源事件层全体公司均值，系数 0.001715，p = 0.0165。
- leave-one-creator-out 下闭源系数均为正，剔除 Google、OpenAI、Anthropic 和 Alibaba 后仍显著。

### 应保守处理的结果

- 全样本事件层均值不显著，p = 0.120。
- 显性关系公司均值不显著，闭源 p = 0.178。
- 这些结果说明主结论更像广义 AI 暴露股票池的重估，而不是只由 owner、investor、cloud 或 downstream 公司驱动。

## Appendix E 规格曲线和窗口选择

本节为 CAR[0,+20] 和 AA Intelligence Index 的选择提供证据。它不应成为正文主线，但有助于证明作者没有只挑一个能显著的规格。

### 应包含的内容

- 四个能力指标的规格曲线摘要。
- 不同 CAR 窗口下的显著率和中位系数。
- AA Intelligence Index 在 CAR[0,+20] 中最强。
- AA Media Elo 更偏向 CAR[0,+1]。
- CAR[0,+5] 是共同低谷。
- coding 和 math 指标较弱或方向不稳。

### 表格与图编号建议

| 编号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table E1 | Specification curve summary by capability measure | 四个能力指标的显著率、正向比例和中位系数 | 补充稳健性 |
| Table E2 | Specification performance by event window | 各窗口的显著率和中位系数 | 补充稳健性 |
| Figure E1 | Specification curve for AA Intelligence Index | 按窗口、子样本和控制变量排序的系数图 | 补充稳健性 |
| Figure E2 | Window-specific median estimates | CAR[0,+1] 到 CAR[0,+20] 的中位系数 | 补充稳健性 |

### 可作为主要稳健性的结果

- AA Intelligence Index 的 252 个规格中，5% 显著率 23.8%，10% 显著率 34.5%，正向比例 66.3%。
- CAR[0,+20] 下 AA Intelligence Index 的显著率为 47.2%，中位系数为 0.000848。

### 应标为 exploratory 的结果

- 开源子样本规格曲线中的负向结果。方向很清楚，但开源事件只有 11 个。
- CAR[0,+5] 低谷可作为诊断，不宜单独形成机制结论。

## Appendix F 开源、闭源与可占有性机制

本节展示 open-weight 与 closed-source 的方向分叉。由于它是论文机制解释的核心，建议在正文简要呈现，附录给出完整证据。

### 应包含的内容

- 闭源样本的主斜率。
- open-weight 交互模型。
- 开源和闭源子样本的窗口异质性。
- open-weight 的小样本限制。
- 中心化前后 open-weight 主效应解释差异。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table F1 | Closed-source and open-weight slopes | 闭源斜率、open-weight 交互和推算开源斜率 | 主要机制性稳健性 |
| Table F2 | Window-specific open-weight and closed-source estimates | CAR[0,+1] 到 CAR[0,+20] 的分窗口结果 | exploratory |
| Figure F1 | Implied capability-pricing slopes | closed-source 与 open-weight 的推算斜率图 | 主要机制性稳健性 |

### 可作为主要稳健性的结果

- 闭源基准斜率 0.002257，CR2 p = 0.0051，wild p = 0.0082。
- intelligence × open-weight 交互项 -0.003734，CR2 p = 0.0475，wild p = 0.0858。

### 应标为 exploratory 的结果

- 开源模型在 CAR[0,+15] 和 CAR[0,+20] 的单独负向子样本结果。
- 开源事件只有 11 个，不宜写成独立强结论。

## Appendix G 关系类型、行业和平台异质性

本节集中放所有机制性和异质性结果。它应明确标为 exploratory heterogeneity，避免这些结果抢走正文主线。

### G1 关系类型结果

应包含 owner、investor、cloud、real downstream、competitor 等关系结果。

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table G1 | Relationship-type subsample estimates | owner、investor、cloud、downstream、competitor 子样本 | exploratory |
| Table G2 | Relationship-type interaction estimates | intelligence 与 investor、cloud、owner 的交互项 | exploratory |
| Table G3 | Competitor and downstream null results | competitor 与 real downstream 的负结果和置信区间 | exploratory |

应标为 exploratory 的结果包括 investor 交互、cloud 交互、real downstream 点估计和 competitor 零结果。

owner 短窗口负向结果可单独放入 Table G2。它在 wild bootstrap 下较稳，但因样本和窗口特殊，仍建议作为 short-window evidence。

### G2 行业、Mag7 和个股差异

应包含行业分组、Mag7 与非 Mag7、Mag7 内部均值。

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table G4 | Industry heterogeneity | 互联网服务、软件、半导体、硬件、IT 服务、零售和其他 | exploratory |
| Table G5 | Mag7 and non-Mag7 estimates | Mag7 与非 Mag7 子样本和交互项 | exploratory |
| Figure G1 | Mag7 average CAR by firm | NVIDIA、Meta、Microsoft、Alphabet、Apple、Amazon、Tesla 的平均 CAR | exploratory |

可强调但需谨慎的结果。

- 互联网服务和基础设施最稳，CR2 p = 0.0150。
- 软件和半导体为边际支持。
- Mag7 与非 Mag7 斜率无显著差异，交互项不显著。
- Mag7 内部分化明显，但样本不是为个股结论设计的。

### G3 Tier 和年份阶段

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table G6 | Event-tier heterogeneity | Tier 1 与 Tier 2 子样本结果，另列交互项 | exploratory |
| Table G7 | Calendar-year heterogeneity | 2024、2025、2026 分年结果和 trend interaction | exploratory |

应标为 exploratory 的原因。

- Tier 2 子样本结果很强，但 tier1 交互项不显著，正式调节效应不足。
- 2025 年结果支持阶段性变化，但 2026 年样本较小，trend_month 交互项不显著。

## Appendix H 媒体情感和替代能力指标

本节放 FinBERT 媒体情感和 AA Media Elo。它们对理解市场反应有帮助，但不应与 AA Intelligence Index 的主线混在一起。

### 应包含的内容

- AA Media Elo 在 CAR[0,+1] 中的即时反应。
- FinBERT 情感对 CAR[0,+20] 的反向预测。
- 情感与 intelligence 的联合模型。
- 情感与 intelligence 的事件层相关性检验。
- intelligence × sentiment 交互项不显著。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table H1 | Alternative capability measures | coding、math、media Elo 与 intelligence 的对比 | 补充稳健性 |
| Table H2 | Media Elo and short-window returns | AA Media Elo 对 CAR[0,+1] 的结果 | exploratory |
| Table H3 | FinBERT sentiment and CAR[0,+20] | sent_w5、sent_w20、joint model | exploratory |
| Table H4 | Sentiment, capability, and interactions | 情感与 intelligence 的相关性和交互项 | exploratory |

### 结果标注建议

AA Media Elo 的 CAR[0,+1] 结果应标为 short-window exploratory evidence。FinBERT 情感反向结果统计上强，但机制解释不唯一，应标为 exploratory channel evidence。可以写成媒体情感和技术能力捕捉不同信息，不应写成情感导致负收益。

## Appendix I 事件窗口重叠、placebo 限制和未完成检验

本节专门处理审稿人可能提出的识别限制。它应透明但不自毁。

### 应包含的内容

- 47 个 intelligence 事件中，只有 4 个在前后 20 个自然日内没有其他 intelligence 事件。
- 中位事件在前后 20 个自然日内有 3 个其他事件。
- 完全剔除重叠事件不可行。
- 当前面板只有既定事件窗口 CAR，没有非事件日的日收益序列。
- 严格 placebo event date 需要回到底层日度收益重新计算。
- 后续可做 calendar-time regression 或多事件控制。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table I1 | Event-window overlap diagnostic | 重叠事件数的均值、分位数、最大值和无重叠事件数 | 诊断 |
| Table I2 | Feasible and infeasible robustness checks | 已完成、未完成和需要新数据的检验清单 | 诊断 |

### 写作注意

不要把本节写成缺陷清单。建议表述为 AI 模型发布在 2025 年高度密集，因此 CAR[0,+20] 捕捉的是连续技术发布环境下的市场重估。严格 placebo 和 calendar-time 检验需要日度收益层数据，当前版本不声称已经完成。

## Appendix J 可复现性、代码和表格映射

本节服务于投稿和未来 replication package。它也能帮助自己维护论文版本。

### 应包含的内容

- 每张正文表和附录表对应的输入文件。
- 当前已存在的结果文件索引。
- 主要脚本来源。
- 数据访问说明。
- AI 使用声明草稿位置。
- 未来 replication package 的目录建议。

### 表格编号建议

| 表号 | 标题建议 | 内容 | 分级 |
|---|---|---|---|
| Table J1 | Result-file map | 表格与 `output/tables`、`agent_tasks` 文件对应关系 | 可复现性 |
| Table J2 | Code and data provenance | 主要脚本、输入数据和输出文件 | 可复现性 |
| Table J3 | Submission checklist | highlights、data availability、CRediT、conflict of interest、AI use statement | 投稿材料 |

## 正文与附录的分工建议

正文建议保留三张表和一句附录引用。

- 正文 Table 1 展示样本与核心变量。
- 正文 Table 2 展示全样本、闭源样本和 open-weight 交互。
- 正文 Table 3 展示 firm FE、FF3 CAR 和 pre-event CAR 的精简稳健性。
- 正文结果段引用 Appendix D 的事件层聚合和 leave-one-creator-out。
- 正文机制段只简要说 open-weight releases attenuate the slope。

不要把 investor、cloud、Tier、年份、行业、Mag7、FinBERT 情感和 owner 短窗写成正文核心发现。它们适合在 online appendix 中支撑“结果边界”和“潜在机制”，但不适合承担 FRL 短文的主张。

## 结果分级清单

### 主要稳健性

- 闭源 CAR[0,+20]，CR2 和 wild cluster bootstrap 均显著。
- firm FE 后的闭源结果。
- two-way cluster 下的闭源结果。
- FF3 CAR[0,+20] 下的闭源结果。
- pre-event CAR 不显著。
- 事件层闭源全体公司均值。
- leave-one-creator-out 闭源结果。
- AA Intelligence Index 的规格曲线支持。

### 机制性但需保守

- intelligence × open-weight 为负，CR2 显著，wild 为 10% 边际。
- 开源子样本长窗口负向，但只有 11 个事件。
- owner 短窗口负向反应，适合说明发布者自身不一定短期受益。

### exploratory

- investor 交互项。
- cloud 交互项。
- real downstream 点估计。
- competitor 零结果。
- 行业异质性。
- Mag7 与非 Mag7。
- Mag7 个股均值。
- Tier 2 强结果。
- 年份阶段性变化。
- AA Media Elo 的短窗口结果。
- FinBERT 情感反向结果。
- CAR[0,+5] 低谷。

### 不应写成已完成结果

- 严格 placebo event date。
- 完全剔除重叠事件后的稳健性。
- 中国模型单独结论。
- 正式美国上市公司样本，除非补 exchange country 字段。

## 推荐附录目录

1. Appendix A. Sample construction and variable definitions
2. Appendix B. Small-cluster inference
3. Appendix C. Alternative specifications and abnormal returns
4. Appendix D. Event-level aggregation and creator concentration
5. Appendix E. Specification curves and window choice
6. Appendix F. Open-weight releases and appropriability
7. Appendix G. Relationship, industry, and platform heterogeneity
8. Appendix H. Media sentiment and alternative capability measures
9. Appendix I. Event-window overlap and unresolved placebo tests
10. Appendix J. Reproducibility and submission checklist

## 最小可交付版本

如果时间紧，online appendix 可以先写 6 节。

- Appendix A，样本和变量。
- Appendix B，小聚类推断。
- Appendix C，替代规格。
- Appendix D，事件层和 creator 剔除。
- Appendix E，规格曲线。
- Appendix I，窗口重叠和 placebo 限制。

这 6 节足以支撑 FRL 投稿。其余机制与异质性结果可以作为更长版本的 online supplement。
