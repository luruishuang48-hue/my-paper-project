# FRL 投稿风险审阅

生成时间 20260614-091551，北京时间。

审阅对象为 `Tex/frl_draft_main_text.tex`，并参考三份前期材料。

- `agent_tasks/frl_project_review_20260613-204658/final_assessment.md`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`

本审阅只从审稿人和编辑风险出发，不评价论文叙事优先级。核心判断是，当前证据足以支撑一篇 FRL short empirical letter，但主文必须把结论收窄为闭源或专有 AI 模型能力定价。全样本、开源反转、媒体情感机制、显性关系公司机制都应降调。

## 一、主文必须降调的点

### 1. 不要写成市场普遍定价 AI 能力

当前摘要和结论写作容易让读者理解为一个广泛命题，即金融市场系统性定价 AI 模型能力。实际证据更窄。全样本 `intel_c` 对 CAR[0,+20] 的结果在 CR2 和 wild bootstrap 下只是边际显著，p 值约为 0.054 和 0.053。真正稳健的是闭源样本。

高风险表述包括：

- `Markets appear to price AI capability primarily when it can be appropriated.`
- `Financial markets price AI model capability selectively.`
- `Financial markets appear to price the economic ownership of AI performance, not AI performance itself.`

建议改成：

- The evidence is strongest for closed-source releases.
- Financial markets appear to price proprietary AI model capability.
- The results are consistent with capability pricing when model performance is commercially appropriable.

中文判断。主文可以说资本市场对闭源模型能力有定价反应，不要说资本市场一般性定价 AI 能力。

### 2. 不要把 open-source 结果写成反转事实

开源交互项方向清楚，点估计为负，CR2 下边际显著，但 wild bootstrap p 值约为 0.086。开源事件只有 11 个，审稿人会很自然地质疑 cluster 数不足和少数事件驱动。

高风险表述包括：

- `This effect is absent for open-source releases.`
- `the capability slope is attenuated and reverses sign`
- `open-source status attenuates and in point estimates reverses the capability-pricing slope`

安全写法应保留两个限定。一是 point estimates，二是 suggestive。

建议改成：

- Open-weight releases show a weaker capability-return relation in point estimates.
- The interaction is consistent with attenuation, but inference is fragile under wild cluster bootstrap.
- We therefore treat the open-weight evidence as suggestive.

不要在摘要中写 `absent`。这个词太强，暗示已经证明开源没有能力定价。更安全的是 `weaker` 或 `attenuated in point estimates`。

### 3. 不要把媒体情感结果写成机制识别

FinBERT 情感与 CAR[0,+20] 负相关，这是有价值的辅助结果。但当前数据不能识别它为什么为负。主文现在写 positive narratives bring forward price gains，这只是一个可能解释，不是被识别出来的机制。

高风险表述包括：

- `narrative-driven pre-pricing`
- `events generating strong positive narratives have already experienced anticipatory price appreciation`
- `positive narratives bring forward price gains that subsequently dissipate`
- `a rough decomposition of LLM event returns into a fundamental-capability component and a narrative component`

安全写法应明确为相关性和解释可能性。

建议改成：

- Media sentiment is negatively associated with post-release abnormal returns.
- One possible interpretation is that highly positive coverage coincides with prior price pressure or attention-driven reversal.
- The current design does not identify the channel behind the negative sentiment coefficient.
- Sentiment controls do not absorb the closed-source capability result.

不要使用 `decomposition`。这个词会让金融审稿人期待正式分解、结构模型或至少明确的正交设计。当前只是 joint regression。

### 4. 不要说 sentiment 和 intelligence 正交

主文写 `confirming orthogonality` 风险较高。事件层 sentiment 对 intelligence 回归 p 值 0.317 只能说明没有显著线性相关证据，不能确认正交。尤其样本只有 47 个事件。

建议改成：

- We find no statistically significant event-level association between sentiment and intelligence.
- The two variables do not appear to proxy for the same event-level information in this sample.

不要写 `confirming they capture distinct information`。可以写 `suggesting that they capture different dimensions of releases`。

### 5. 不要把 CAR[0,+20] 写成干净公告效应

20 日窗口支持闭源主结果，但 AI 发布事件高度密集。47 个 intelligence 事件里只有 4 个在前后 20 个自然日内没有其他 intelligence 事件。这个结果不能被表述成单个发布公告的纯净因果冲击。

高风险表述包括：

- `post-announcement returns` 如果没有说明窗口重叠
- `fundamental revaluation rather than noise trading`
- `capability information takes time to be fully processed`

更安全的写法是：

- CAR[0,+20] captures medium-window repricing around release events.
- Because model releases cluster in calendar time, the estimate should be interpreted as market repricing in a dense AI news environment.
- Pre-event CAR tests show no strong evidence of systematic run-up, but they do not rule out all information leakage or overlapping news.

如果主文保留 20 日窗口，需要在稳健性段落中主动说明窗口重叠。不要等审稿人指出。

### 6. 不要把 firm-event 面板写得像有 3,780 个独立冲击

核心解释变量 AA Intelligence Index 是事件层变量。虽然回归有 3,780 条 firm-event 观测，有效 variation 主要来自 47 个事件，闭源主结果来自 36 个事件。主文必须让读者看到作者知道这一点。

建议在数据或方法段加入：

- The identifying variation in model capability is at the event level.
- We therefore cluster by event, use small-cluster corrections, and report event-level aggregation as a robustness check.

事件层聚合结果要如实写。闭源全体公司均值显著，p 值约为 0.0165。全样本事件层不显著，显性关系公司均值不显著。不要只报有利的一半。

### 7. 不要把显性关系公司作为主要机制

事件层聚合显示，闭源全体公司均值显著，但显性关系公司均值不显著。关系类型结果中 owner、investor、cloud、real downstream 等也各有统计脆弱性。

因此主文不宜写成 owner、investor、cloud、upstream 或 downstream 公司是明确渠道。更安全的解释是广义 AI 暴露股票池的重估。

建议写法：

- The evidence points to repricing among AI-exposed listed firms rather than a clean relation-specific channel.
- Relationship-level patterns are reported as exploratory appendix evidence.

### 8. 不要把闭源结果写成完全不受 creator 影响

leave-one-creator-out 支持闭源主结果。剔除 Google、OpenAI、Anthropic、Alibaba、Meta、xAI、Microsoft 后，闭源系数仍为正且大多显著。这是好结果。

但全样本 leave-one-creator-out 较弱，有些规格剔除 OpenAI、Anthropic、Microsoft 后只剩边际或不显著。主文应写闭源结果不由单一 creator 独自驱动，不要写 all results are robust to excluding any creator。

建议写法：

- In the closed-source subsample, the positive capability slope remains after dropping major model developers one at a time.

### 9. 不要把美国市场口径写得过实

当前美国交易标的检验用无交易所后缀 ticker 粗略识别。它支持结果，但不是正式的 exchange country 字段。若标题或摘要强调美股市场，审稿人会要求精确定义。

建议正文标题和摘要不要过度强调 U.S. market，除非后续补正式交易所国家字段。附录可以写：

- A coarse U.S.-ticker restriction yields similar estimates.

不要写：

- The result is robust in a U.S.-listed-firm sample.

除非数据里正式确认上市地。

### 10. 不要把假设写成被确认

主文中 `consistent with H1` 可以保留，但 `supports H1` 需少用。事件研究加 firm controls 不等于严格因果识别。建议多用 `consistent with`、`predicts`、`is associated with`。

替换建议：

- `supports H1` 改为 `is consistent with H1`
- `drive a positive effect` 改为 `predicts higher abnormal returns`
- `capability channel operates` 改为 `the estimates are consistent with a capability-pricing channel`
- `we identify` 改为 `we document`

## 二、应放附录的结果

### 1. 事件层聚合

建议放主附录，也可在正文用一句概述。原因是它直接回应有效样本量担忧，但结果混合，不适合作为主文核心表。

应报告四个口径：

- 全样本，全体公司均值，p 值约为 0.120
- 闭源，全体公司均值，p 值约为 0.0165
- 全样本，显性关系公司均值，p 值约为 0.437
- 闭源，显性关系公司均值，p 值约为 0.178

建议解读。闭源结果不只是 firm-event 面板堆观测数，但显性关系公司渠道未被事件层聚合支持。

### 2. Leave-one-creator-out

建议放附录稳健性表，正文一句话引用。该检验很有说服力，但会占正文空间。FRL 正文不宜堆过多行。

安全表述为：

- Appendix Table AX shows that the closed-source estimate remains positive when dropping major developers one at a time.

不要把全样本剔除结果包装成同等稳健。

### 3. FF3 CAR

建议放附录。FF3 后闭源系数仍为正且显著，但量级下降。它是金融审稿人期待的稳健性，不一定需要正文主表。

正文可写：

- The closed-source slope remains positive when abnormal returns are computed using a Fama-French three-factor model.

### 4. Pre-event CAR

建议正文保留一句，附录放表。这个结果很重要，可以缓解提前定价担忧。

安全表述为：

- We find no strong evidence that intelligence predicts pre-event CARs.

不要写：

- This rules out pre-pricing.

### 5. 美国交易标的粗口径

只能放附录，并明确是 coarse restriction。若要进入正文，需要补正式上市地变量。

### 6. 窗口重叠诊断

建议放附录，同时正文给一句限制。它不是结果贡献，但能显示作者诚实面对事件密集问题。

安全写法：

- Appendix Table AX documents substantial overlap in release windows, a feature of the 2024-2026 AI release cycle.

### 7. 规格曲线

AA Intelligence Index 是最稳能力指标、CAR[0,+20] 是最强窗口，这些可以放附录。正文不要展开，否则会显得像事后挑规格。

安全写法：

- Appendix Figure AX reports a specification curve over alternative windows and capability measures.

### 8. 行业、Mag7、Tier、owner、investor、cloud 和 downstream

这些都应放附录或删掉。原因有三点。第一，多重检验风险高。第二，部分结果在 CR2 或 wild 下不稳。第三，它们会抢走闭源能力定价主线。

具体建议如下：

- 行业异质性放附录，写 exploratory heterogeneity。
- Mag7 放附录，作为不是由 Mag7 驱动的辅助证据。
- Tier 2 结果放附录，不要在正文解释为正式 attention 或 surprise 机制。
- owner 短窗负向放附录，不要放正文。
- investor 和 cloud 交互放附录，标为 exploratory。
- real downstream 因样本小且不显著，除非附录很长，否则可不放。
- competitor 不显著可作为附录负结果，避免主文机制过度。

## 三、FRL 编辑可能 desk reject 的硬伤

### 1. 主文仍有明显占位符

当前稿件有 `[ACKNOWLEDGMENTS]`、`[Shandong University]`、`\citep[CITATION]{})` 和参考文献占位注释。这类问题可能直接导致 desk reject 或技术退稿。

必须清除：

- 标题页致谢占位
- 作者单位占位
- 文内 citation 占位
- bibliography 里的 citation TODO

### 2. 篇幅可能不符合 FRL short letter 预期

FRL 偏好短文。前期诊断记录的官方作者指南强调稿件少于 2500 words，并清楚呈现新的初步或实验性结果。当前主文包含假设发展、三张主表、稳健性、长参考文献和大量机制语言，可能过长。

建议把正文压成四个部分：

- Introduction
- Data and empirical design
- Results
- Conclusion

Hypothesis Development 可以并入 Introduction 或删成一小段 Predictions。

### 3. 样本口径不一致

摘要写 `60 major LLM release events`，但项目事件包含多模态和媒体生成模型，如 SORA、Imagen、Stable Diffusion、Runway、Veo 等。主回归又只用 47 个有 AA Intelligence Index 的事件。编辑或审稿人会认为样本定义不清。

必须统一为：

- 60 major AI model release events
- 47 events with non-missing AA Intelligence Index enter the main regressions
- 36 closed-source and 11 open-weight events identify the appropriability comparison

如果坚持 LLM，需要把非 LLM 事件删掉或单独解释。

### 4. 标题和证据范围可能不匹配

标题 `Appropriability and the Market Pricing of AI Model Capability` 尚可，但如果正文强调美股市场，样本里存在海外交易标的和粗略美国标的识别，会有范围问题。

更稳的标题方向：

- Proprietary AI Capability and Stock Market Repricing
- Appropriability and the Pricing of AI Model Capability

不要在标题里写 U.S. stock market，除非样本清洗完全支持。

### 5. 事件研究识别讲得不够防御

当前设计是相关性事件研究，不是准实验。AI 发布日期、媒体关注、公司预期和技术路线可能共同变化。若主文暗示因果，会被快速攻击。

必须补一句识别边界：

- The design documents conditional return associations around release events rather than causal effects of capability shocks.

这句话不会削弱文章，反而能降低审稿人防御。

### 6. 20 日窗口污染风险未充分处理

CAR[0,+20] 是主窗口，但窗口重叠严重，且没有严格 placebo date。FRL 审稿人很可能问为什么不用短窗，或为什么 20 日不是其他新闻。

至少需要正文说明：

- 短窗反应较弱，说明市场可能逐步吸收模型能力信息。
- 发布前 CAR 不显著，缓解但不消除提前定价担忧。
- 窗口重叠是 AI 发布周期的客观特征，附录报告诊断。

不要声称已解决窗口重叠。

### 7. 缺少投稿声明材料

投稿前应补齐：

- Highlights
- Data availability statement
- CRediT author statement
- Declaration of competing interest
- Funding statement
- Generative AI use statement
- Replication package 或至少代码与派生数据说明

这些不是学术问题，但会造成技术退稿。

### 8. 文献定位太薄且有幻觉风险

当前文献只有几篇经典文献和占位符。`technology shocks and asset pricing`、`AI/LLM event studies`、`biotech parallel for owner effect` 尚未补齐。若投稿稿仍有未核实引用，会显著降低可信度。

建议只引用已经核验的文献。宁可少，不要用未经确认的工作论文。

### 9. 表格星号和 p 值说明可能混乱

表格同时报告 CR0 标准误、CR2 p 值和 wild p 值。星号如果基于 CR0，而正文强调 CR2 或 wild，读者会困惑。

建议改成：

- 表中不放星号，直接列 CR0 p、CR2 p、wild p。
- 或星号明确基于 CR2，CR0 只作为补充。

FRL 短文里最好减少推断口径混乱。

## 四、建议的安全措辞

### 摘要可用句

原句：

`Closed-source model releases drive a positive capability-pricing effect.`

建议：

`In closed-source releases, higher model capability predicts higher 20-day abnormal returns among AI-exposed listed firms.`

原句：

`This effect is absent for open-source releases.`

建议：

`Open-weight releases show a weaker capability-return relation in point estimates, although inference is less precise because the open-weight sample is small.`

原句：

`Media sentiment is negatively associated with post-release returns, consistent with narrative-driven pre-pricing.`

建议：

`Media sentiment is negatively associated with subsequent abnormal returns and does not absorb the closed-source capability coefficient.`

原句：

`Markets appear to price AI capability primarily when it can be appropriated.`

建议：

`The evidence is consistent with market pricing of AI capability when model performance is commercially appropriable.`

### 引言可用句

建议主贡献句：

`This paper documents that the stock-market response to AI model releases depends on appropriability. The clearest evidence comes from closed-source releases, where a one-standard-deviation increase in the Artificial Analysis Intelligence Index predicts about 3 percentage points higher CAR[0,+20].`

建议识别边界句：

`Because model capability varies at the event level, the effective number of shocks is the number of releases rather than the number of firm-event observations. We therefore report event-clustered inference, small-cluster corrections, wild bootstrap p-values, and event-level aggregation checks.`

建议开源降调句：

`Open-weight releases attenuate the capability slope in point estimates. This evidence is suggestive rather than definitive because only 11 open-weight events identify the interaction.`

建议媒体情感句：

`Sentiment provides a useful falsification of a simple hype interpretation. It is negatively associated with subsequent CAR and does not eliminate the closed-source intelligence coefficient, but the current design does not identify the channel behind the sentiment coefficient.`

### 数据节可用句

`The starting sample contains 60 major AI model release events from January 2024 to March 2026. The main regressions use the 47 events with non-missing Artificial Analysis Intelligence Index scores.`

`The event list includes frontier language and multimodal model releases. We use the term AI model releases rather than LLM releases when referring to the full sample.`

`Firm-event observations are not independent capability shocks. The model capability variable is measured at the release-event level.`

### 结果节可用句

`Table 1 shows the strongest result in the paper. In the closed-source subsample, the Intelligence Index coefficient is 0.0023, with CR2 p = 0.007 and wild bootstrap p = 0.008.`

`The full-sample estimate is positive but only marginal under small-cluster inference. I therefore treat the closed-source estimate as the primary result.`

`The firm fixed effect estimate remains similar in magnitude, which suggests that the closed-source slope is not driven by time-invariant differences across firms.`

`Pre-event CARs are not significantly related to model capability. This result weakens the concern that the main estimate only captures systematic pre-release run-up, though it cannot rule out all forms of information leakage.`

### 附录引用可用句

`Appendix Table A1 reports event-level aggregation. The closed-source estimate remains positive when CAR is averaged across all firms within an event, while relation-specific event averages are imprecise.`

`Appendix Table A2 shows that the closed-source estimate remains positive after dropping major model developers one at a time.`

`Appendix Table A3 replaces market-model CAR with Fama-French three-factor CAR. The coefficient declines in magnitude but remains positive.`

`Appendix Table A4 documents substantial overlap in 20-day release windows, which is a feature of the dense AI release cycle during the sample period.`

### 结论可用句

`The results point to a narrow conclusion. Stock prices respond more strongly to high-capability AI releases when model performance is commercially appropriable.`

`The open-weight evidence is consistent with attenuation but remains less precise. Future work with more open-weight release events can test this margin more sharply.`

`The paper does not claim that markets fully or efficiently price AI technology. It documents a conditional association between measured model capability and medium-window abnormal returns around release events.`

## 五、建议删去或改写的具体句型

### 直接删去

- `This effect is absent for open-source releases`
- `confirming they capture distinct information`
- `providing a rough decomposition`
- `the appropriability channel we identify`
- `capability information takes time to be fully processed`
- `fundamental revaluation rather than noise trading`

### 改写后可保留

- `strongly and precisely priced` 改为 `precisely estimated in the closed-source subsample`
- `drive a positive capability-pricing effect` 改为 `predicts higher abnormal returns`
- `supports H1` 改为 `is consistent with H1`
- `reverses sign` 改为 `is negative in point estimates`
- `hype alternative` 改为 `sentiment-based interpretation`
- `operates independently` 改为 `remains separately associated`

## 六、最安全的主文结果组合

正文建议只保留四个事实。

1. 闭源模型能力定价。闭源样本系数 0.0023，一标准差约 3.0 个百分点，CR2 和 wild 均显著。
2. Firm FE 后闭源结果仍成立。说明不是公司固定差异机械驱动。
3. Pre-event CAR 不显著。说明没有强证据显示系统性提前定价。
4. 开源交互为负但降调。作为可占有性机制的 suggestive evidence。

媒体情感可作为一段辅助结果。如果正文篇幅紧，建议移到附录，并在正文一句话说明 sentiment controls do not absorb the closed-source coefficient。

## 七、投稿前最低修订清单

- 统一样本称谓为 AI model releases，除非删除非 LLM 事件。
- 摘要删掉 `absent`、`drive`、`pre-pricing` 等强词。
- 引言第一屏明确主结果是 closed-source subsample。
- 方法段说明 capability variation 在 event level。
- 主表加入或引用 firm fixed effects。
- 正文加入 pre-event CAR 不显著。
- 附录报告 event-level aggregation、leave-one-creator-out、FF3 CAR 和 window overlap。
- 删除或移出 owner、industry、Tier、Mag7、investor、cloud 等扩展结果。
- 清除所有占位符和未核验引用。
- 补齐 FRL 投稿声明材料。

## 八、底线判断

这篇稿件不能以“市场定价 AI 能力”这个宽命题投稿。体面期刊可接受的版本应更窄。

最稳的论文结论是：

`Closed-source AI model capability predicts medium-window abnormal returns among AI-exposed listed firms, and open-weight releases show suggestive attenuation.`

这句话与当前计量证据匹配，也能最大限度降低审稿风险。
