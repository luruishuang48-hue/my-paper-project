# FRL 投稿诊断与下一步方向

任务时间 20260613-204658，北京时间。

## 总体判断

项目有投 Finance Research Letters 的潜力。最适合投稿的版本不是“大语言模型发布行为对金融市场的全面影响”，而是“资本市场是否定价可占有的 AI 模型能力”。

当前最稳的事实是闭源模型发布中，AA Intelligence Index 与 CAR[0,+20] 显著正相关。开源交互方向清楚，但 wild bootstrap 下只是边际证据。媒体情感结果有价值，但应作为排除 hype 的辅助检验，而不是第二篇论文。

FRL 官方作者指南强调稿件应少于 2500 words，并清楚呈现新的初步或实验性结果。当前项目的主题、事件研究方法和金融市场问题符合范围，但主线必须再收窄。

## 现在的问题

### 1. 主张略宽，证据最能支持的是闭源能力定价

全样本 CAR[0,+20] 的方向为正，但 CR2 p 值约为 0.054，wild p 值约为 0.053，只能算边际证据。闭源样本更稳，系数约为 0.002317，CR2 p 值约为 0.0069，wild p 值约为 0.0082。论文应把主结论改成闭源或专有模型能力被市场定价，而不是市场普遍定价 AI 能力。

开源交互项系数为负，CR2 p 值约为 0.0475，但 wild p 值约为 0.0858。它能支持 suggestive attenuation，不能支撑 decisive reversal。

### 2. 样本口径还不够统一

草稿多处写 LLM releases，但 60 个事件包含 SORA、Imagen、Stable Diffusion、Runway、Veo、Kling、Vidu 等媒体生成模型。主回归依赖 AA Intelligence Index，实际进入主估计的是 47 个有该指标的事件。

建议数据节分三层写清楚。第一层是 60 个主要 AI 模型发布事件。第二层是 47 个有 AA Intelligence Index 的主回归事件。第三层是 36 个闭源事件和 11 个开源事件构成的可占有性机制样本。

### 3. 当前叙事仍有多篇论文的痕迹

早期项目里有 Tier、季度体制转换、owner 短窗负向、investor、cloud、Mag7、行业分组、规格曲线等结果。英文 FRL 草稿已经删掉很多，但主文仍同时强调闭源能力、开源衰减、媒体情感和 owner 短窗效应。FRL 主文只能容纳一个核心机制。

建议主文只保留三件事。闭源能力定价。开源削弱能力斜率。媒体情感不吸收能力结果。其他内容进 online appendix。

### 4. 20 日窗口需要更强解释

主结果来自 CAR[0,+20]。这个窗口能捕捉慢速信息扩散，但也容易被财报、宏观新闻、行业消息和其他 AI 事件污染。草稿已经说明短窗口弱、长窗口强，但还需要补 pre-event run-up、placebo date 和 FF3 CAR，才能让金融期刊读者放心。

### 5. 关系编码和公司样本需要更透明

早期清洗报告显示原始 relationship 列曾为空，后续又通过补丁加入 owner、investor、cloud、upstream、downstream、competitor 等变量。这个过程必须在附录中清楚说明，否则审稿人会怀疑关系变量是事后编码。

此外，公司池里包含非美国交易代码和海外上市公司。若标题和摘要强调美股市场，至少要补一个只保留美国交易标的或 ADR 的稳健性检验。

### 6. 多重检验风险很明显

项目已经跑过大量规格曲线和异质性检验。解决办法不是隐藏这些探索，而是明确主假设只有两个。闭源模型中 intelligence 与 CAR[0,+20] 正相关。开源发布削弱这个斜率。其他窗口、行业、关系和时间分组全部标为探索性分析。

### 7. 投稿硬伤还没清完

当前 LaTeX 草稿还有 `[ACKNOWLEDGMENTS]`、`[Shandong University]`、`\citep[CITATION]{})` 和参考文献占位符。投稿前还缺 highlights、data availability statement、CRediT、利益冲突声明、资助声明和生成式 AI 使用声明。

## 下一步方向

### 1. 先把论文锁成一句话

建议下一版只服务这一句话。

资本市场会为闭源、可商业占有的 AI 模型能力定价，开源发布削弱这种能力溢价的证据方向明确但统计上应保守。

英文主张可写成。

Financial markets price proprietary AI model capability, while open-weight releases show suggestive attenuation.

### 2. 重构主文成三表结构

表 1 放样本和变量描述。报告 60 个事件、47 个 intelligence 事件、36 个闭源事件、11 个开源事件、86 家公司、5,160 条清洗后观测、3,780 条主回归观测。

表 2 放核心结果。包括全样本 CAR[0,+20]、闭源 CAR[0,+20]、open-source interaction。每列显示系数、CR0 标准误、CR2 p 值和 wild p 值。

表 3 放替代解释和稳健性。可以放媒体情感 joint model，并在附录放 FF3 CAR。若篇幅允许，可把 FF3 合并到表 3。

主文稳健性只保留一小段。其余规格曲线、行业、Mag7、owner、investor、cloud、Tier 和季度结果进附录。

### 3. 补四个高价值检验

第一，leave-one-creator-out。逐一排除 Google、OpenAI、Anthropic、Alibaba 后重估闭源主结果和开源交互。

第二，pre-event run-up。报告 CAR[-20,-1] 或 CAR[-10,-1] 与 intelligence 的关系，检验是否只是提前定价。

第三，calendar-time placebo。把事件日提前 30 个交易日，或随机换成同季度日期，重复核心回归。

第四，公司样本口径检验。只保留美国交易标的或 ADR 后重估核心表。

若时间只够做两个，优先做 leave-one-creator-out 和 pre-event run-up。

### 4. 重写摘要和引言

摘要只放一个问题、一个设计、一个主结果和一个辅助机制。不要同时展开开源反转、媒体预定价和 owner 短窗。

引言应压到三到四段。第一段提出金融学问题。第二段解释可占有性机制。第三段给数据和主结果。第四段做最小文献定位。Hypothesis Development 可并入引言，或改成很短的 Predictions 段。

### 5. 降调机制语言

建议替换几类表述。

- drive 改为 is associated with 或 predicts。
- confirming 改为 consistent with。
- reverse sign 改为 reverses sign in point estimates。
- decompose returns 改为 distinguish capability-related pricing from sentiment-related variation。
- markets price AI capability primarily when it can be appropriated 改为 markets appear to price proprietary AI capability。

### 6. 补齐投稿材料和数据透明度

准备一页 online appendix 说明事件纳入标准、AA 匹配规则、86 家公司池、关系编码原则、缺失值处理和 60 到 47 个事件的样本筛选。

准备可共享材料。事件清单、变量字典、回归代码、结果表可以放 OSF、Zenodo 或 GitHub release。若 AA 原始数据、新闻文本和股价数据受许可限制，在 data statement 中说明，并共享派生变量和复现脚本。

## 建议优先级

P0 是清除占位符、补文献、修 LaTeX、准备 highlights 和声明文件。

P1 是统一样本口径，把主张改为闭源专有能力定价，并把开源结果降调。

P2 是补 leave-one-creator-out、pre-event run-up、placebo date 和美国交易标的口径检验。

P3 是重排三张主表，把其他探索性结果移入附录。

P4 是润色摘要、引言和结论，让主文更像 FRL 的 short empirical letter。

## 可投性结论

项目适合投 FRL，但不是以当前“全景式 AI 发布影响”形态投稿。最可投的版本应围绕 proprietary AI capability pricing。只要把结论降调、样本口径讲清、补上几个关键稳健性，并清除投稿硬伤，FRL 是合理目标。
