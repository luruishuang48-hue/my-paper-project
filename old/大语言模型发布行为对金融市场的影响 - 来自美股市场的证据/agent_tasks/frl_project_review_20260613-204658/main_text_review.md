# FRL 主文诊断

任务时间 20260613-204850，北京时间。阅读范围包括 `Tex/frl_draft_main_text.tex`、`Tex/llm_pricing_regime_full.tex`、`proposal.md`、`result.md` 和 `agent_tasks/frl-draft_20260611-134549/frl_draft_main_text.md`。本报告只诊断，不修改主文。

## 总体判断

当前 FRL 短稿的方向是对的。它已经从完整稿的多结果探索，收束到一个更适合 Finance Research Letters 的问题，即市场是否为 AI 模型能力定价，以及这种定价是否取决于闭源带来的可占有性。这个版本比完整中文稿更像投稿稿件，也更接近短文所需的单一贡献。

但目前还不能直接投稿。最大问题不是没有结果，而是主线仍被几条次要叙事牵扯。闭源能力定价是唯一足够稳的核心发现，开源衰减、媒体情感、owner 短窗效应只能服务这条主线。若它们被写成并列发现，审稿人会觉得文章仍是从一组探索性结果中挑出若干有趣现象，而不是一篇围绕单一假说设计的短文。

## 现在的问题

### 研究问题基本清楚，但还可以更硬

短稿摘要和引言已经明确提出 “Do financial markets price the capability of LLMs, or do they merely react to AI hype?”，并进一步落到 closed-source 与 open-source 的可占有性差异。这是可投稿的研究问题。

问题在于问题表述仍有两个中心。一个中心是能力是否被定价，另一个中心是 hype 与 sentiment 是否解释价格反应。对 FRL 来说，最好把 hype 改成识别威胁或替代解释，而不是并列研究问题。文章应让读者在第一页就明白，真正的论文问题是 “appropriable capability 是否被定价”。媒体情感只是排除 “这只是 AI 叙事热度” 的检验。

### 贡献基本单一，但仍有分散风险

短稿相对于完整稿已经删掉规格曲线、季度体制转换、Tier 2 信息惊喜、Mag7 分化、investor/cloud 交互等大量内容，这一步是必要的。当前贡献可以概括为一句话，市场定价 AI 能力，但只在能力具有商业可占有性时稳定定价。

需要警惕的是，主文仍保留三个看似并列的发现。第一是闭源能力正向定价，第二是开源斜率衰减，第三是媒体情感负向预测。再加上稳健性中的 owner 短窗负向效应，读者可能会问，文章到底是可占有性论文、媒体叙事论文，还是 AI 发布事件异质性论文。

建议只把闭源能力定价作为主贡献。开源交互是机制证据，但要用 “attenuation” 和 “suggestive” 的语言。媒体情感是排除 hype 的辅助证据。owner 短窗效应最好进入附录，主文最多一句。

### 摘要和引言给结果很直接，这是优点

摘要已经在前半段给出样本、变量、主结果和经济量级。引言第 3 段交代数据与方法，第 4 段列出三个结果，符合短文的读者预期。这个版本没有把结果埋到后文，这是明显优点。

但摘要仍略微拥挤。它同时说 closed-source、open-source、sentiment，并在很短空间内给了系数、p 值和机制解释。FRL 摘要最好只保留最强句子。可改为，闭源模型中一标准差能力提升对应 3.0 个百分点更高的 20 日 CAR，开源发布显著削弱这一斜率，媒体情感检验表明结果不是简单的 hype。这样会更聚焦。

引言的问题是第 5 段文献定位仍然像压缩版文献综述，而不是直接服务贡献。现有写法连接 technology shocks、patent appropriability、media sentiment 三组文献，逻辑没错，但对短文略重。建议只保留最接近的两条。第一是技术信息进入资产价格，第二是创新收益取决于可占有性。媒体文献只作为替代解释处理，篇幅不宜与前两者相当。

### 理论机制不算过重，但独立假说章节可压缩

短稿第 3 节 Hypothesis Development 只有约 30 行，比完整稿轻很多。它的问题不是过长，而是位置和功能。对于 FRL 短文，单独理论章节会让文章显得比实际贡献更重，也会占用有限篇幅。可占有性机制已经在引言第 2 段讲过，H1 和 H2 也能自然接在引言或数据之后。

建议把第 3 节压缩并并入引言末尾或结果前的一小段，保留 H1 和 H2 的可检验形式即可。不要把它写成完整理论发展。FRL 读者更关心一个清楚的识别设计和一个稳健表格，而不是较长机制铺垫。

### 结构适合短文，但还可以更像 letter

主文约 2,650 words，三张主表，结构上接近 FRL 短文。章节安排是 Introduction、Data、Hypothesis、Results、Robustness、Conclusion，基本可行。

但 Results 里仍有三个子节，加上 Robustness 里的四个段落，文章读感接近压缩后的 working paper。短文可以更锐利。建议主结果只围绕三张表组织。表 1 是闭源能力定价。表 2 是开源交互。表 3 是 sentiment 作为替代解释。Robustness 只保留最必要内容，其余放 appendix。

尤其是 owner short-window effects 不应成为主文稳健性重点。虽然 result.md 显示 owner 短窗 Wild p 值较稳，但它与 “appropriable capability” 主线并不完全一致，容易引出新问题。为什么所有权方短期下跌，闭源能力又正向定价。若主文没有空间解释，会削弱核心贡献。

### 统计表述需要更保守

全样本结果在 CR2 和 Wild 下只是 10% 左右边际显著，开源交互在 Wild 下为 0.086，联合 sentiment 模型中 intelligence 和 sentiment 在 CR2 下分别为 0.087 和 0.057。短稿已经多处使用 cautious、suggestive、exploratory，这是对的。

仍建议进一步降低开源反向和 sentiment 独立性的语气。开源结果应写成 “open-source releases attenuate the capability-pricing slope” 而不是 “open-source releases reverse it”，反转只能说 point estimates。sentiment 结果可以说它不吸收 capability effect，但不要说 “confirming” 或 “decompose returns” 太强。当前引言和结论里 “decompose LLM event returns into...” 可能超出证据强度。

### 技术性未完成项会直接影响送审

短稿还有明显未完成项。标题页仍有 `[ACKNOWLEDGMENTS]`。引言文献段存在 `\citep[CITATION]{})`，这既是占位引用，也可能是 LaTeX 语法问题。参考文献后还有三条 citation placeholder。投稿前必须清理。

这些不是小问题。FRL 审稿人很可能先看摘要、引言、表格和引用。如果第一页出现占位符，会传递未完成稿的信号。

## 当前最需要修的段落或章节

第一，摘要。保留一个问题、一个设计、一个主结果、一个辅助机制。删去会让读者觉得有三篇论文的内容。

第二，引言第 2 段到第 5 段。第 2 段可占有性机制要保留并更直接。第 4 段结果要把闭源结果放到绝对中心。第 5 段文献定位要缩短，删掉宽泛 technology shocks 占位，补上最贴近 AI、技术发布、创新可占有性和媒体情绪的正式引用。

第三，Hypothesis Development。建议并入引言，或压缩成 “Predictions” 小段。H1 和 H2 足够，不需要再展开媒体情感假说。

第四，Results 4.2。开源交互要继续保守，标题可从 “Open-source attenuation” 保留，但正文避免让读者理解为开源必然毁灭价值。核心是边际能力定价斜率降低。

第五，Results 4.3。媒体情感段应改成替代解释检验。不要让它抢走主线。机制解释如 pre-pricing、mean reversion 可以保留一句，但不要扩展。

第六，Robustness。建议删除 owner 段或移至附录。主文只保留 alternative windows、FF3、Mag7/industry 一两句。若必须保留 owner，应该明确说它不是主机制，只是说明发布者自身并非唯一受益者。

第七，Conclusion。结论第一段很好。第二段和第三段需更短。不要重新打开 open-source commodity wave、future prediction 或 broad implication 太多。结尾最好落在 “markets price economic ownership of AI performance”。

## 下一步的前进方向

### 方向一，把论文锁定为可占有性短文

下一版应执行一个硬规则。主文只回答一个问题，市场是否定价可占有的 AI 模型能力。所有内容都要服务这个问题。

保留主线如下。LLM 发布是可观察技术冲击。AA Intelligence Index 衡量能力。闭源发布让能力更可能转化为租金。开源发布扩散能力并削弱租金捕获。结果显示，闭源样本中能力被稳定正向定价，而开源发布削弱该斜率。媒体情感负向且不吸收能力结果，说明这不是单纯 hype。

### 方向二，把主文改成三表一图的紧结构

建议主文只放三张表和一张图。表 1 报告样本和闭源基准结果。表 2 报告 open-source interaction。表 3 报告 sentiment joint model 与关键稳健性。图 1 展示 closed-source 和 open-source 的 capability-pricing slopes。

附录承接所有探索性内容。规格曲线、Tier、季度体制、investor/cloud、owner、Mag7 个体分化、中国模型样本都放到 online appendix。主文只在稳健性中用一两句说明结论不由这些维度驱动。

### 方向三，补强识别和可复现叙述

数据部分需要更明确解释事件为何是 “major LLM releases”。最好给出三条可审计标准。官方发布、可访问或可测试、被模型数据库或主流媒体覆盖。还要说明同日多模型发布如何合并，模型家族如何选择代表能力，事件日如果是非交易日如何处理。

AA Intelligence Index 是事后能力指标，这一点要提前承认。最好的表述是，它是技术能力的标准化 ex post proxy，而不是投资者发布当日完全观察到的信息。这样可以避免审稿人质疑信息可得性时显得被动。

### 方向四，重写文献定位

当前文献定位应从 “三组文献并列” 改成 “一个缺口”。缺口是已有金融事件研究和媒体情绪研究能解释市场对公告和叙事的反应，但较少直接度量 AI 模型能力，也没有检验能力能否被商业可占有性调节。创新可占有性文献提供机制，AI 模型发布提供新场景，AA 指标提供直接测度。

文献段不宜超过 2 段。每段只服务一个功能。第一段说明资产价格如何处理技术信息。第二段说明本文把技术能力与可占有性结合起来，并用情感检验排除 hype。

### 方向五，先修硬伤，再做文字压缩

送审前优先级应是以下顺序。

1. 清除所有 citation placeholders 和 `[ACKNOWLEDGMENTS]`。
2. 检查 `Tex/frl_draft_main_text.tex` 的 LaTeX 语法，尤其是引言文献段的 `\citep[CITATION]{})`。
3. 把 Hypothesis Development 压缩或并入引言。
4. 删除或极度压缩 owner short-window 段。
5. 将 “decompose returns” 和 “confirming orthogonality” 改成更保守的说法。
6. 统一所有显著性语言，CR2 和 Wild 不支持的结果一律写成 suggestive。
7. 增加一张简洁的样本构成表或图，让 60 个事件、47 个可回归事件、36 个闭源事件和 11 个开源事件的关系一眼清楚。

## 建议的最终主线版本

一句话版本是，本文发现美股市场会为 AI 模型能力定价，但这种定价主要出现在闭源、可商业占有的模型发布中。

两句话版本是，使用 2024 至 2026 年 60 次 LLM 发布事件和 86 家 AI 相关上市公司的事件公司面板，文章发现闭源模型中 AA Intelligence Index 的一标准差提升对应约 3.0 个百分点更高的 20 日累计异常收益。开源发布显著削弱这一能力定价斜率，媒体情感检验表明结果不能简单归因于 AI 叙事热度。

这是最适合 FRL 的版本。它短、清楚、有一个新变量，有一个清楚机制，有一个可放进三张表的实证设计。下一步所有修改都应保护这条主线。
