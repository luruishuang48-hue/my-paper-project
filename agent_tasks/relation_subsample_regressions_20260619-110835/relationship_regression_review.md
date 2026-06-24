# 关系分组回归审阅建议

生成时间 20260619-110951，Asia/Shanghai。

本文若要做深关系机制，主线应从“不同关系组平均 CAR 是否不同”推进到“同一模型能力、开源和成本信号在不同关系路径上的定价斜率是否不同”。这比单纯分组均值更接近 `proposal.md` 的设计，也更能解释非上市模型发布者如何影响美股公司。

## 一、总体判断

当前数据可以支持一版关系分组回归，但需要保守呈现。

现有关系旗标不是互斥分类。`owner`、`investor`、`cloud`、`business_upstream`、`real_upstream`、`business_downstream`、`real_downstream` 和 `competitor` 可以同时为 1。直接按每个旗标拆样本回归，结果可以作为附录机制检验，但不适合在正文中写成彼此排斥的产业链组。

主文应使用一个互斥主关系口径。建议按证据清晰度和经济含义排序，先识别 `owner`，再识别 `investor`、`cloud`、`upstream`、`competitor`、`downstream`，剩余观测作为弱关联或 AI 篮子。这样每个事件-公司对只进入一个主关系组，表格和叙述更清楚。

当前样本规模也决定了主文不能把每个细分类都讲成独立发现。`owner` 只有 29 个观测和 4 家公司，`investor` 只有 37 个观测和 4 家公司，`cloud` 只有 29 个观测和 3 家公司。这些组更适合描述方向，不适合承担强结论。`upstream`、`downstream` 和 `competitor` 的覆盖更充分，适合主文重点讨论。

## 二、建议估计的模型

### 模型 1，关系组平均反应

目的在于回答 H1 和 `to_do_align_proposal.md` 中 P0 的产业链异质性要求。

建议估计式如下。

\[
CAR_{ij,w}=\alpha+\sum_r \theta_r Role_{ij}^{r}+\gamma Z_{ij}+\lambda_q+\epsilon_{ij}
\]

其中 \(w\) 至少包括 `mkt_car_1` 和 `mkt_car_20`。正文可报告 `mkt_car_20`，附录补 `mkt_car_1`、`mkt_car_5`、`mkt_car_10` 和 `ff3_car_20`。

表格应报告每组观测数、事件数、公司数、平均 CAR、标准误或 bootstrap 区间，以及相对 `owner` 或相对弱关联组的差异检验。现有均值显示，上游算力 `CAR[0,+20]` 约为 2.28%，并且较稳定。发布方或所有者约为 1.28%，但不显著。下游应用和竞争者接近零。

正文可写的结论是，显著平均反应主要集中在上游算力暴露。不能写成“所有正向商业暴露均显著上涨”。

### 模型 2，关系分组内的能力定价

目的在于回答同一个模型能力信号是否被不同关系组差异化定价。

建议在每个关系组内分别估计。

\[
CAR_{ij,w}=\alpha+\beta_r Capability_i+\gamma Z_{ij}+\lambda_q+\epsilon_{ij}
\]

首选 `aa_intelligence_index` 的标准化变量。备选指标用 `hle` 和 `livecodebench`，因为前一轮结果显示这两个指标在 `CAR[0,+20]` 中更强。不要在同一个小样本回归里同时塞入多个高度相关能力指标。

正文表可以只放三组，分别是上游、下游和竞争者。`owner`、`investor`、`cloud` 的分组内回归放附录，原因是事件数和公司数太小。

### 模型 3，统一样本中的关系交互

分组回归容易受样本差异影响。主文最好同时报告一个统一交互模型。

\[
CAR_{ij,w}=\alpha+\beta Capability_i+\sum_r \theta_r Role_{ij}^{r}
+\sum_r \delta_r Capability_i \times Role_{ij}^{r}
+\gamma Z_{ij}+\lambda_q+\epsilon_{ij}
\]

这个模型是最适合正文的“关系机制表”。它保持同一套控制变量和同一基准样本，系数差异也更容易解释。若正文篇幅有限，应优先展示该表，而不是展示过多分样本表。

建议把 `upstream`、`downstream` 和 `competitor` 作为主要交互项。`owner`、`investor`、`cloud` 可以合并为 `direct_commercial_exposure` 或只放附录。若保留小组交互，表注必须说明这些估计样本很小。

### 模型 4，开源调节与关系的三向交互

该模型对应 `proposal.md` 中“高能力闭源模型可能利好战略伙伴和压制竞争者，高质量开源模型可能改变扩散与商业捕获方式”的机制。

\[
CAR_{ij,w}=\alpha+\beta Capability_i+\eta Open_i+\theta Role_{ij}^{r}
+\delta Capability_i \times Role_{ij}^{r}
+\kappa Capability_i \times Open_i
+\phi Capability_i \times Role_{ij}^{r}\times Open_i
+\gamma Z_{ij}+\lambda_q+\epsilon_{ij}
\]

只建议对宽口径关系估计。宽口径关系包括 `upstream`、`downstream` 和 `competitor`。不要对 `owner`、`investor`、`cloud` 分别做三向交互，统计功率太弱。

前一轮结果已经显示，能力 × 开放权重交互在全样本中为负且显著。这是主线结果。关系三向交互若不稳，应放附录并写成探索性结果。

### 模型 5，成本效率和速度的关系异质性

成本效率机制适合做一张附录表，或在正文中只报告一个简短段落。

建议逐个估计 `z_low_price`、`z_speed`、`z_low_ttft`、`z_price_efficiency`，并与 `upstream`、`downstream`、`competitor` 交互。不要同时放入所有成本和速度变量。

前一轮结果显示，低价和低 TTFT 与 `CAR[0,+20]` 的关系为负，说明市场并没有简单奖励更便宜、更快的模型。关系分组可以检验这种负相关是否主要来自模型服务商、下游应用或竞争者。如果结果不稳，正文只保留“成本效率机制并不呈现单一正向定价”。

### 模型 6，媒体情感的关系异质性

该模型对应 `to_do_align_proposal.md` 中 H2c。

建议估计。

\[
CAR_{ij,20}=\alpha+\beta Sentiment_i+\theta Role_{ij}^{r}
+\delta Sentiment_i \times Role_{ij}^{r}
+\gamma Z_{ij}+\lambda_q+\epsilon_{ij}
\]

前一轮结果显示，媒体情感均值与 `CAR[0,+20]` 显著负相关，竞争者的情感交互项显著为正。这一结果适合放在机制或附录，不宜压过能力和关系主线。正文可以说，媒体叙事与关系路径存在差异，但更像辅助解释。

## 三、关系重叠的处理

关系重叠是这组分析的主要风险。建议同时保留两套口径。

第一套是互斥主关系。优先级建议如下。

| 优先级 | 主关系 | 规则 |
|---:|---|---|
| 1 | 发布方或所有者 | `owner == 1` |
| 2 | 主要投资者 | `investor == 1` 且未被更高优先级吸收 |
| 3 | 云服务方 | `cloud == 1` 且未被更高优先级吸收 |
| 4 | 上游算力 | `real_upstream == 1` 或 `business_upstream == 1` |
| 5 | 直接竞争者 | `competitor == 1` |
| 6 | 下游应用 | `real_downstream == 1` 或 `business_downstream == 1` |
| 7 | 弱关联或篮子 | 以上均不满足 |

这套口径用于正文。它牺牲一部分多重角色信息，换来可解释的互斥分组。

第二套是非互斥旗标。每个旗标单独定义子样本，或在统一模型中同时放入多个旗标。该口径用于附录，目的是说明正文结论不依赖互斥归类规则。

建议在表注中明确写出，OpenAI 事件中的 Microsoft 可能同时具有投资、云服务和分发关系。若正文必须给它一个主关系，优先按预先设定的层级处理，而不是根据结果方向事后选择。

## 四、表格呈现建议

正文最多放两张关系表。

表 1 建议命名为“模型发布事件的关系异质性”。行是互斥主关系组，列包括 `N`、事件数、公司数、`CAR[0,+1]`、`CAR[0,+20]`、`CAR[0,+20]` 的 bootstrap 区间、相对发布方或弱关联组的差异检验。该表用于建立事实。

表 2 建议命名为“模型能力定价的关系差异”。列按模型设定排列。第一列为全样本能力定价，第二至四列为 `Capability × Upstream`、`Capability × Downstream`、`Capability × Competitor`。若篇幅允许，最后一列加入 `Capability × Open Weight`，但不要在正文中堆太多三向交互。

附录可放四张表。

第一张是非互斥关系旗标的分样本回归。  
第二张是 FF3 CAR 和短窗口稳健性。  
第三张是开源三向交互和成本效率交互。  
第四张是媒体情感与关系交互。

图形方面，建议保留一张系数图。横轴为关系组，纵轴为 `Capability` 对 `CAR[0,+20]` 的边际效应，并标出 95% 置信区间。若小样本组置信区间很宽，这张图能自然传达不确定性。

## 五、标准误和统计推断

主规格标准误应按事件聚类。理由是能力、开源和媒体情感多为事件层变量，同一事件下多个公司观测共享冲击。

稳健性中建议报告公司聚类和双向聚类。事件数约为 47 到 60，勉强可用，但小组回归的有效事件数可能更少。因此，关键正文结果最好补 wild cluster bootstrap 或事件层 bootstrap。若 bootstrap 与常规聚类不一致，应优先采用保守表述。

`owner`、`investor` 和 `cloud` 的小样本估计不要只看星号。表格必须同时报告事件数和公司数。若某组只有 3 到 4 家公司，正文应避免说“市场对云服务方显著反应”，除非 bootstrap 和 leave-one-firm-out 都稳定。

## 六、控制变量和固定效应

建议主规格沿用项目已有控制变量，至少包括 `size_log_assets`、`bm_ratio`、`volatility`、`momentum`、`car_pre`、行业固定效应和季度固定效应。若使用 `mkt_car_20`，`car_pre` 很重要，因为它能吸收事件前趋势和预期反应。

事件固定效应不适合与事件层能力变量同放，因为能力、开源、价格和媒体情感会被完全吸收。若要估计纯关系组平均 CAR，可以使用事件固定效应检验同一事件内不同关系公司的相对反应。若要估计能力机制，则改用季度固定效应或发布者国家、模态等控制。

建议分别设置两类表。

关系均值表可以加入事件固定效应，重点看同一事件内不同关系组的相对 CAR。能力机制表不能加入事件固定效应，重点看事件层技术信号如何被不同关系组定价。

## 七、哪些结论可进正文

以下结论可以进入正文，但表述要精确。

1. 模型发布事件的平均市场反应不是均匀传导，关系路径决定资本市场映射方式。
2. 当前样本中，上游算力暴露的 `CAR[0,+20]` 最清楚，平均约 2.28%，显著性和 bootstrap 区间均较支持。
3. 发布方或所有者的平均 `CAR[0,+20]` 为正但不显著，原因可能是样本小，也可能是上市发布者事件本身较少。
4. 下游应用和直接竞争者的平均反应接近零，说明模型发布并不自动利好所有 AI 概念公司。
5. 能力定价与开源调节仍是主机制。关系分组回归应服务于这一主线，而不是另起一条松散的产业链故事。

## 八、哪些只适合放附录

以下内容建议放附录。

1. `owner`、`investor`、`cloud` 的单独分组回归。样本太小，正文容易过度解释。
2. 非互斥关系旗标的全部分组回归。它适合做稳健性，不适合直接当成主分组。
3. `Capability × Role × Open Weight` 的细分三向交互。可作为机制补充，但主文不宜依赖。
4. 成本效率、速度和 TTFT 的关系异质性交互。结果可能有解释价值，但目前方向复杂。
5. 媒体情感与每个关系组的交互。竞争者交互较有意思，但更像探索性发现。
6. `real_downstream` 与 `business_downstream` 的内部拆分。当前 `real_downstream` 只有 81 个观测和 21 个事件，适合作为下游细分附录。

## 九、需要避免的写法

不要写“发布方、投资者、云服务方和上游算力均受益”。现有结果不支持这种宽泛判断。

不要把 Microsoft 在 OpenAI 事件中写成模型发布者，也不要把 Tesla 在 xAI 事件中默认写成发布者。`proposal.md` 已明确要求按真实模型发布者和经济暴露关系分开处理。

不要把关系分组结果写成强因果。本文的识别更适合称为短期事件研究和机制异质性证据。

不要在正文中报告太多显著性星号而不讨论经济量级。关系机制的核心是不同路径的经济含义，而不是哪一列多一颗星。

## 十、给主代理的执行建议

脚本应先生成互斥主关系变量，再生成非互斥旗标结果。每张表都应保留 `N`、事件数、公司数和固定效应说明。

建议输出文件包括。

- `outputs/relation_role_mean_table.csv`
- `outputs/relation_role_mean_table.md`
- `outputs/relation_capability_interactions.csv`
- `outputs/relation_capability_interactions.md`
- `outputs/relation_subsample_regressions.csv`
- `outputs/relation_robustness_ff3.csv`
- `outputs/figure_relation_capability_effects.png`

最终报告应把正文推荐结果和附录推荐结果分开。最稳的正文叙述是，上游算力暴露呈现最强平均反应，能力和开源仍是解释 `CAR[0,+20]` 的核心技术信号，关系分组说明这种技术信号不是平均地映射到所有 AI 相关公司。
