# 实证材料诊断

任务时间 20260613-204846，北京时间。

本诊断基于指定回归表、清洗报告、事件样本报告、分析脚本和当前 FRL 草稿。另核对了 Finance Research Letters 官方作者指南。该刊强调短文应少于 2500 词，要求清晰呈现新颖发现，也欢迎能显示方法依赖性的研究。见 [ScienceDirect Guide for Authors](https://www.sciencedirect.com/journal/finance-research-letters/publish/guide-for-authors)。

## 总体判断

当前项目有一个适合 FRL 的短文主线。最有说服力的发现不是“市场普遍定价大语言模型能力”，而是“闭源或可占有的模型能力更容易被市场定价”。这个主线与 FRL 的短文定位相符，因为问题明确，结果有新意，表格可以压缩。

但现在不能按草稿中的强表述直接投稿。主要风险是样本定义、变量口径和证据强度还没有完全对齐。最严重的问题有三点。

第一，事件样本被写成 LLM releases，但 60 个事件包含图像、视频和图像编辑模型。主回归又依赖 AA Intelligence Index，因此实际进入主估计的只有 47 个事件。13 个媒体生成事件没有 intelligence 指标。这会让读者质疑样本到底是 LLM 发布、AI 模型发布，还是一组混合 AI 发布事件。

第二，基准因变量 `car_1` 和 `car_20` 是市场模型 CAR，而不是 FF3 CAR。清洗报告中同时保留了市场模型和 FF3 两套异常收益，当前主表没有把两套口径摆在一起。对金融期刊读者来说，异常收益模型选择是关键稳健性。

第三，显著性在保守推断下明显变弱。全样本 CAR[0,+20] 的 CR0 p 值为 0.027，但 CR2 p 值为 0.054，wild p 值为 0.053。只有闭源样本在 CR2 和 wild 下仍然较稳健。因而主张必须从全样本效应转为闭源或可占有性机制。

## 现在的问题

### 事件定义和样本清楚度

事件构造本身有较好的基础。`final_60_event_sample_report.md` 说明最终合并事件为 60 个，时间覆盖 2024 年 20 个、2025 年 35 个、2026 年 5 个。每个事件匹配 86 家公司，`event_firm_balance_check.csv` 显示所有事件都有 86 家公司，面板是平衡的。

但论文叙述需要重写。当前草稿标题、摘要和引言都倾向于说 LLM release，而事件表里包含 SORA、Imagen、Stable Diffusion、Runway Gen-4、Veo、Kling、Vidu、Qwen-Image、Nano Banana 等媒体生成模型。若继续使用 LLM 说法，审稿人会认为样本选择和指标选择不一致。

更稳妥的写法有两种。

一是把样本定义改成 major frontier AI model releases，并明确主机制样本是 47 个有 AA Intelligence Index 的文本、推理、代码或多模态模型事件，媒体生成模型只作为补充分析。

二是直接把主样本收窄到 47 个有 intelligence 指标的事件，60 个事件只用于样本构建背景和媒体能力补充。这样主张更干净，也更适合 2500 词短文。

还有一个数据清理细节需要修正。`clean_event_firm_panel.csv` 是 5,160 行，但 `specr_input_clean.csv` 和 `specr_rel_clean.csv` 是 5,161 行，其中有一条全空事件行。回归会因关键变量缺失自动排除它，但主文现在写 5,161 条公司事件观测，容易被复现检查抓住。建议统一写 5,160 条清洗后观测，回归样本另报 3,780 条、47 个事件。

### 因变量和核心解释变量一致性

核心解释变量基本一致。主回归、核心表和规格曲线都围绕 `aa_intelligence_index`，核心表将其中心化为 `intel_c`。这有助于解释交互项。

但因变量口径需要更明确。`scripts/prep/specr_rel_prep.py` 显示 `car_1` 至 `car_20` 映射自市场模型异常收益。FF3 异常收益另存为 `ff3_car_1` 至 `ff3_car_20`。草稿正文只说 market-model CAR，方向是对的，但稳健性里写“Replacing the market model with FF3 leaves the main coefficients unchanged”，当前指定主表没有直接展示这组结果。`result.md` 提到 FF3 CAR[0,+20] 系数从 0.001521 降至 0.001010，仍然显著。这个证据应进入附录表，或者在主表脚注中报告。

核心解释变量还有一个样本选择问题。AA Intelligence Index 缺失 1,118 条观测，全部集中在媒体生成样本。若主文使用 60 个事件叙述，却用 47 个事件估计 intelligence 效应，读者会追问被排除事件是否系统不同。必须在数据节明确，主结果使用 LLM capability sample，media events 不进入 intelligence 回归。

### 基准回归是否支持主张

支持，但只支持较窄的主张。

全样本结果方向为正。`main_regression_results.csv` 中 CAR[0,+20] 的系数为 0.001521，CR0 p 值为 0.027，样本为 3,780 条、47 个事件。问题是核心表显示同一结果的 CR2 p 值为 0.054，wild p 值为 0.053。这个结果只能写成边际显著，不能写成强证据。

闭源样本是当前最强结果。CAR[0,+20] 的系数为 0.002317，CR0 p 值为 0.0006，CR2 p 值为 0.0069，wild p 值为 0.0082，样本为 2,899 条、36 个事件。这个结果足以支撑“闭源模型能力被正向定价”。

开源交互项支持机制但不够强。`intel_c × open_weight` 的系数为 -0.003734，CR0 p 值为 0.0032，CR2 p 值为 0.0475，wild p 值为 0.0858。应写成“与开源削弱可占有性机制一致，但证据为 suggestive”，而不是强机制检验。

投资者和云服务交互项更弱。`intel_c × investor` 的 wild p 值为 0.1256，`intel_c × cloud` 的 CR2 p 值为 0.1003，wild p 值为 0.1374。它们不适合放在主文作为核心机制。

所有者短窗口效应有趣但不宜承担主叙事。`intel_c × owner` 在 CAR[0,+1] 和 CAR[0,+2] 的 wild p 值分别为 0.0338 和 0.0456，但 owner 关系样本很小，只有 21 条有效观测、21 个事件、4 家公司。可以作为附录或讨论中的探索性发现。

### 稳健性和异质性是否足够

稳健性目前“数量多、主线不够集中”。规格曲线很好地说明 intelligence 指标比 coding、math、media elo 更适合主变量。`specr_summary.csv` 显示 intelligence 的 252 条规格中 23.8% 在 5% 水平显著，66.3% 为正。这个证据可以支持变量选择，但不能替代正式稳健性。

最该保留的稳健性有三类。

第一，保守标准误。主文必须同时展示 CR0、CR2 和 wild p 值，因为事件聚类数只有 47 个，闭源样本只有 36 个，开源只有 11 个。没有 CR2 和 wild，FRL 审稿人很容易认为显著性夸大。

第二，异常收益口径。市场模型 CAR 是主因变量，FF3 CAR 应作为附录表或主表附加列。金融读者会自然要求这个检验。

第三，规格曲线。建议放一张小型规格曲线图或附录表，核心信息是 intelligence 的方向和显著率相对稳健，math 不稳健，media elo 是不同机制。

异质性应大幅压缩。行业异质性结果有一定信息量，互联网服务和基础设施在 CR2 下显著，软件和半导体在 CR2 下只是 10% 附近。Mag7 和 non-Mag7 都只是边际。关系异质性里，real downstream、competitor、US creator 等单列表都不够强，不能放太多。FRL 只需要一个主机制表，即闭源与开源交互。其他异质性进附录即可。

### 内生性风险

当前设计更像事件研究加横截面解释变量，不是强因果识别。应避免使用 causal impact、drive、determine 等强因果词。可以使用 associated with、priced by markets、consistent with appropriability。

主要内生性有五类。

第一，事件选择内生。重大模型发布不是随机事件，高能力模型也更可能伴随开发者声誉、媒体覆盖、市场预期和宏观 AI 叙事。

第二，预期泄露和提前定价。媒体情绪对后续 CAR 为负，可能说明事件前已经涨过。若没有 CAR[-20,-1] 或公告前成交量、媒体热度控制，不能排除 anticipatory run-up。

第三，模型能力和发布者质量混同。AA Intelligence Index 不只是技术能力，也可能代理 Google、OpenAI、Anthropic 等开发者声誉、产品生态和投资者关注度。年固定效应不够，发布者固定效应又可能因事件数少而难以估计。至少要做 creator concentration 描述和 leave-one-creator-out 检验，尤其是 Google 和 OpenAI。

第四，公司暴露关系可能是研究者事后编码。原始 `relationship` 列完全为空，关系分析来自 `specr_rel_clean.csv` 中的 owner、investor、cloud、upstream、downstream、competitor 标记。`relationship_notes` 显示很多 firm-event 对被标为 No identified relationship，也有大量 narrowed definition 调整。主文若说“through public filings, investment records, and product documentation”必须有清楚的编码规则、可复核来源和一致性检查。

第五，样本公司不是纯美股。公司代码包含 005930 KS、000660 KS、700 HK、SIE GR 等非美股或非美国上市标的。论文题目写“来自美股市场的证据”，正文写 86 AI-related listed companies。若目标是美股市场，应明确是否包含 ADR、海外上市公司，或者把公司样本限定为美国交易标的。

### 多重检验风险

多重检验风险明显。项目已经运行了 966 条常规规格、672 条关系规格，还包括行业、Mag7、媒体情绪、季度 regime、owner 窗口、tier 分组等大量探索。若主文从这些结果中挑最显著的模式，审稿人会担心 p-hacking。

解决方法不是隐藏规格曲线，而是反过来把它纳入研究设计。建议把主假设预先收束为两条。

H1，闭源模型中 intelligence 与 CAR[0,+20] 正相关。

H2，开源模型削弱 intelligence 的 CAR[0,+20] 斜率。

然后把其他窗口、关系、行业、Mag7、媒体能力、季度转变全部作为探索性或附录稳健性。主文中不要同时声称 owner、investor、Tier 2、季度 regime、媒体情绪和行业差异都是核心发现。

## 下一步前进方向

### 先收缩论文主张

建议把论文主张改成下面这个版本。

金融市场并不普遍奖励 AI 模型能力。只有当模型能力较可占有，尤其是闭源或专有发布时，市场才更明显地把能力转化为相关公司的异常收益。

这个版本能被当前数据支撑，也能解释为什么全样本结果只在保守推断下边际显著。相反，若继续写“markets price AI capability”，证据强度不够。

### 重新定义样本

数据节应分三层写。

第一层是 60 个主要 AI 模型发布事件和 86 家相关上市公司，构成 5,160 条清洗后 firm-event 观测。

第二层是主回归样本，47 个有 AA Intelligence Index 的事件，3,780 条有效观测。

第三层是闭源机制样本，36 个闭源事件，2,899 条有效观测。

媒体生成模型应作为补充样本。若不想展开 media elo，就直接说明其不进入 intelligence 主回归。

### 重排主文表格

建议主文最多放三张表。

表 1 放样本和变量描述。应报告 60 个事件、47 个 intelligence 事件、36 个闭源事件、11 个开源事件、86 家公司、5,160 条清洗后观测、3,780 条主回归观测。还应报告 AA Intelligence Index 的均值和标准差，以及 CAR[0,+1]、CAR[0,+20] 的基本统计。

表 2 放核心结果。列应包括全样本 CAR[0,+20]、闭源 CAR[0,+20]、开源交互模型。每列至少展示系数、CR0 标准误、CR2 p 值和 wild p 值。重点突出闭源结果稳健，全样本边际，开源交互为 suggestive。

表 3 放机制区分。可以用媒体情绪和 FF3 合并成一张稳健性表。若篇幅不够，建议主文放媒体情绪，FF3 放附录。媒体情绪结论要降调，因为 joint model 下 intelligence 的 CR2 p 值为 0.0866，sentiment 的 CR2 p 值为 0.0568，都是边际。

### 附录表安排

附录 A 放事件清单。列出 60 个事件，同时标明是否进入 intelligence 主样本、是否媒体生成、是否开源、发布者类型和事件层级。

附录 B 放异常收益口径。市场模型 CAR 与 FF3 CAR 并列，至少覆盖 CAR[0,+1]、CAR[0,+5]、CAR[0,+20]。

附录 C 放规格曲线摘要。用 `specr_summary.csv` 和 `specr_rel_summary.csv` 的核心摘要即可，不必把全部 966 条规格放主文。

附录 D 放关系变量编码说明。尤其要解释 owner、investor、cloud、business_upstream、real_upstream、business_downstream、real_downstream、competitor 如何生成，如何处理 No identified relationship，以及为什么关系变量不是事后选择。

附录 E 放行业、Mag7、owner、investor、cloud 等探索性异质性。主文不要承载这些结果。

### 补做最少但高价值的检验

建议优先补四个检验。

一是 leave-one-creator-out。逐一排除 Google、OpenAI、Anthropic、Alibaba 后重估闭源 CAR[0,+20] 和开源交互。这个检验能直接回应开发者集中度风险。

二是 pre-event run-up。报告 CAR[-20,-1] 或 CAR[-10,-1] 与 intelligence 的关系。若 intelligence 已经预测事件前收益，主结果就更像提前定价而不是发布后定价。

三是 calendar-time placebo。把事件日平移到发布前 30 个交易日或随机同季度日期，重复核心回归。这个检验适合 FRL，简短但有说服力。

四是公司样本口径检验。只保留美国交易标的或美股 ADR 后重估核心结果。当前“美股市场”题目需要这个检验。

### 写作降调建议

摘要中的 strong statistical support 可以保留给闭源样本，但全样本和开源交互必须降调。建议写成“closed-source releases exhibit a robust positive capability-pricing slope, while the open-source interaction is negative and suggestive under conservative inference”。

“Media sentiment is negatively associated with post-release returns”可以保留，但不要写成已经确认“narrative-driven pre-pricing”。当前数据只能说 consistent with anticipatory pricing or post-event reversal。

“Financial markets price the economic ownership of AI performance”是很好的结论句，但前面需要加 appear to 或 consistent with。否则因果和机制强度过高。

## 投稿风险排序

最高风险是样本标签不清。LLM、AI model、media model、主回归 47 事件之间必须统一。

第二风险是推断强度。全样本和交互项都在保守标准误下边际，不能按强结果写。

第三风险是多重检验。必须把主假设收缩到闭源和开源可占有性机制。

第四风险是关系编码。若要使用 relationship heterogeneity，编码来源和规则必须透明。

第五风险是 FRL 篇幅。当前材料太多，主文只能容纳一个核心机制、两三个关键表和少量稳健性。

## 可投性结论

项目有投稿 FRL 的潜力，但当前版本应先做一次“主线收缩”和“证据降调”。最可投的版本是短文式结构，标题围绕 appropriability，主结果围绕 closed-source capability pricing，开源交互写成探索性机制，媒体情绪和 FF3 作为辅助稳健性。若补上 leave-one-creator-out、pre-event run-up、placebo date 和美国交易标的口径检验，可信度会明显提高。
