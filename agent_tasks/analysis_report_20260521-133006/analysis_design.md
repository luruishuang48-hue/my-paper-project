# 子代理 C：实证设计报告

生成时间：20260521-133125（Asia/Shanghai）

## 1. 数据可用性判断

本报告基于 `proposal.md` 和 `事件集数据.csv` 的字段结构设计实证框架。当前 CSV 可直接支撑“事件-公司面板”的短期事件研究、事件特征异质性、AA 能力机制和媒体情感机制；但不能完整支撑 proposal 中最核心的“公司与模型发布事件之间的经济暴露关系”检验，因为 `relationship` 字段在 5160 条实际观测中全部缺失。

### 1.1 样本结构

`事件集数据.csv` 使用 GB18030 编码。第一行是英文变量名，实际观测从第二行开始。清理后数据结构如下：

- 实际观测：5160 条。
- 事件数量：60 个模型发布事件。
- 公司数量：86 家。
- 面板结构：每个事件对应 86 家公司，基本是 60 × 86 的平衡事件-公司面板。
- 事件时间：2024 年 4 月 18 日至 2026 年 3 月 17 日。`FMR-0060` 的 `release_date` 中有 82 行显示为 Excel 序列值 `46098`，另有 4 行显示为 `2026/3/17`，需统一清洗为 `2026/3/17`。
- 公司范围：不完全是美股样本。86 个公司代码中有 21 个带交易所后缀，例如 `005930 KS`、`700 HK`、`SIE GR`、`6701 JP`、`TEMN SW` 等。若论文标题强调“美股市场”，主样本应剔除非美股代码，或把这些公司改为“全球 AI 暴露公司”扩展样本。

### 1.2 事件层字段

当前数据已经包含较完整的事件特征，可直接用于异质性分析：

- 事件标识：`final_event_id`、`event_name`、`release_date`、`release_year`、`release_month`、`release_quarter`、`trend_month_since_2022_11`。
- 发布者：`true_model_creator`、`creator_country`、`creator_type`。
- 模型属性：`model_names`、`representative_model_name`、`model_family`、`model_variants`、`model_modality`、`model_modalities`。
- 事件标记：`is_cross_modality_release`、`is_model_family`、`is_multimodal`、`is_reasoning_model`、`is_coding_model`、`is_media_generation_model`、`is_open_weight_or_open_source`、`is_chinese_model`。
- 重要性与市场相关性：`candidate_tier`、`likely_us_market_relevance`。
- 能力样本：`llm_capability_sample_flag`、`media_capability_sample_flag`、`representative_aa_source_table`。
- 日期证据：`release_date_confidence`、`release_source_urls`、`release_source_titles`。

事件层分布如下：

- 发布者国家：美国 46 个，中国 11 个，法国 2 个，英国 1 个。
- 模态：text LLM 21 个，reasoning LLM 17 个，image generation 6 个，video generation 6 个，multimodal LLM 5 个，coding LLM 4 个，image editing 1 个。
- Tier：Tier 1 为 27 个，Tier 2 为 31 个，Tier 3 为 2 个。
- 开源或开放权重：13 个事件为 1，47 个为 0。
- 中国模型体系：13 个事件为 1，47 个为 0。
- LLM 能力样本：47 个事件。
- media 能力补充样本：13 个事件。

### 1.3 公司层与结果变量字段

公司层字段包括：

- 公司标识：`company`、`company_id`。
- 行业：`industry`、`industry_2`。
- 公司控制变量：`size (log_assets)`、`BM_Ratio`、`volatility`、`Momentum`。
- 事件前异常收益：`异常收益[?10,?2]`，应解释为事件前窗口 CAR，但字段名乱码，建议重命名为 `car_pre_m10_m2`。
- 事件窗口异常收益：`car_1`、`car_2`、`car_3`、`car_5`、`car_10`、`car_15`、`car_20`。

目前 `car_1` 至 `car_20` 可用于事件窗口检验。字段名没有直接说明窗口是否为 `[-1,+1]`、`[-2,+2]` 等对称窗口，但媒体字段使用 `windows-2`、`windows-3`、`windows-5` 等命名，建议在主报告中统一说明为“以原数据构造口径为准的 1/2/3/5/10/15/20 日 CAR”，并在复现代码中确认窗口定义。

事件窗口 CAR 的可用观测数和粗略分布为：

| 变量 | 可用观测 | 均值 | 标准差 | 最小值 | 最大值 |
|---|---:|---:|---:|---:|---:|
| `car_1` | 5030 | 0.00195 | 0.05915 | -0.39463 | 1.64479 |
| `car_2` | 5036 | 0.00060 | 0.06553 | -0.57327 | 1.52173 |
| `car_3` | 5045 | 0.00000 | 0.07194 | -0.57327 | 1.30606 |
| `car_5` | 5049 | -0.00074 | 0.09172 | -0.86680 | 1.50601 |
| `car_10` | 5053 | -0.00115 | 0.14435 | -2.37458 | 2.13949 |
| `car_15` | 5053 | -0.00010 | 0.17735 | -2.76782 | 2.27135 |
| `car_20` | 5053 | -0.00014 | 0.20533 | -3.08052 | 2.09848 |
| `car_pre_m10_m2` | 5029 | -0.00295 | 0.08106 | -1.18319 | 1.41196 |

### 1.4 媒体情感字段

当前数据已有多窗口媒体情感字段：

- `媒体态度均值(1,1)`、`媒体态度标准差`。
- `windows-2`、`windows-2_1`。
- `windows-3`、`windows-3_1`。
- `windows-5`、`windows-5_1`。
- `windows-10`、`windows-10_1`。
- `windows-15`、`windows-15_1`。
- `windows-20`、`windows-20_1`。

这些字段可支持媒体情感机制分析。需要注意，情感变量看起来更像事件层或事件窗口层变量，在同一事件的 86 家公司中可能重复。正式回归前应检查同一事件内是否完全相同。如果完全相同，不能解释公司间差异，只能解释事件间差异，并且标准误必须按事件聚类。

### 1.5 AA 能力字段

当前数据已把 AA 能力指标合并到事件-公司面板，可直接用于机制检验：

- LLM 指标：`aa_intelligence_index`、`aa_coding_index`、`aa_math_index`、`mmlu_pro`、`gpqa`、`hle`、`livecodebench`、`scicode`、`math_500`、`aime`。
- 成本与速度：`price_1m_input_tokens`、`price_1m_output_tokens`、`price_1m_blended_3_to_1`、`median_output_tokens_per_second`、`median_time_to_first_token_seconds`、`median_time_to_first_answer_token`。
- media 指标：`aa_media_task`、`aa_media_elo`、`aa_media_rank`、`aa_media_ci95`、`aa_media_appearances`、`aa_media_category_rows`。
- 匹配信息：`representative_aa_model_id`、`representative_aa_model_name`、`representative_aa_creator_name`、`representative_aa_source_table`、`representative_selection_rule`、`aa_model_ids`、`aa_model_names`。

AA 样本分布：

- LLM 能力样本：47 个事件、4042 条事件-公司观测。
- media 能力样本：13 个事件、1118 条事件-公司观测。
- LLM 指标可用性不完全一致，例如 `aa_intelligence_index` 有 4042 条观测，`aa_math_index` 有 1978 条观测，`aa_coding_index` 有 3010 条观测。
- media 指标有 1118 条观测，`aa_media_task` 包括 `text_to_image`、`image_to_video`、`image_editing`。

## 2. 分析框架总览

建议把实证部分分为三层。

第一层是当前数据可直接完成的主分析。以 5160 条事件-公司观测为单位，检验重大模型发布事件是否在 AI 相关公司股票中引发短期 CAR，并按事件层特征解释反应差异。

第二层是当前数据可完成但需要谨慎解释的机制分析。包括媒体情感机制、AA 能力机制、模态、开源、国家、Tier 和能力样本异质性。这些变量多数是事件层变量，在同一事件下对所有公司相同，因此有效识别来自事件间差异，而不是同一事件内公司间差异。

第三层是 proposal 提出的理想分析，但当前数据不能直接完成。主要包括公司-事件关系暴露异质性、ASVI 关注机制、混淆事件剔除、严格美股样本、财报/并购/诉讼等事件纯净性检查、Fama-French 正常收益模型复算。若主报告要声称完成这些分析，需要补充数据或重新构造变量。

## 3. 描述统计设计

### 3.1 样本构造表

建议第一张表展示样本筛选过程：

| 步骤 | 事件数 | 公司数 | 事件-公司观测 | 说明 |
|---|---:|---:|---:|---|
| 原始 CSV 清理后样本 | 60 | 86 | 5160 | 删除第一行变量名，统一日期编码 |
| 可计算主窗口 CAR 样本 | 60 | 86 | 约 5030 | 取决于 `car_1` 非缺失 |
| LLM 能力样本 | 47 | 86 | 4042 | `llm_capability_sample_flag=1` |
| media 能力样本 | 13 | 86 | 1118 | `media_capability_sample_flag=1` |
| 美股主样本 | 待定 | 待定 | 待定 | 需剔除非美股交易代码 |
| 高置信日期样本 | 待定 | 86 | 待定 | 按 `release_date_confidence` 筛选 |

这里应明确：当前 CSV 中有 21 家非美股公司，若论文定位为“美股市场证据”，主样本不能直接使用全部 86 家公司。

### 3.2 事件描述统计

建议第二张表以事件为单位统计：

- 按发布者国家：美国、中国、法国、英国。
- 按发布者类型：`private_us_company`、`listed_us_company`、`public_non_us_company`、`private_non_us_company`。
- 按模态：text LLM、reasoning LLM、coding LLM、multimodal LLM、image generation、video generation、image editing。
- 按 Tier：Tier 1、Tier 2、Tier 3。
- 按开源或开放权重：0/1。
- 按中国模型体系：0/1。
- 按能力样本：LLM sample、media sample。

这张表回答“本文研究了什么事件”。它应使用 `drop_duplicates(final_event_id)` 后的事件层数据，不能直接用 5160 条公司层观测，否则会把每个事件重复 86 次。

### 3.3 公司描述统计

建议第三张表以公司为单位或事件-公司为单位报告：

- 行业分布：`industry`、`industry_2`。
- 公司规模：`size (log_assets)`。
- 账面市值比：`BM_Ratio`。
- 前期波动率：`volatility`。
- 动量：`Momentum`。
- 事件前异常收益：`car_pre_m10_m2`。

由于公司控制变量在事件之间可能随季度变化，应确认这些变量是否为公司-季度层变量。如果是公司-季度层变量，可以用事件-公司观测报告；如果是静态公司变量，则应以公司层去重报告。

### 3.4 CAR 描述统计

建议第四张表报告各窗口 CAR 的均值、标准差、分位数和极值：

- 主窗口：`car_1`。如果确认是 `[-1,+1]`，在文中称为 `CAR[-1,+1]`。
- 稳健窗口：`car_2`、`car_3`、`car_5`、`car_10`、`car_15`、`car_20`。
- 事件前窗口：`car_pre_m10_m2`。

同时报告 winsorize 前后的结果。当前数据中 `car_10` 至 `car_20` 极值较大，例如 `car_20` 最小值约 -3.08，最大值约 2.10，长窗口更容易被非模型事件污染，主文应以短窗口为主。

## 4. 事件窗口检验

### 4.1 基础事件研究

当前数据已经提供 CAR，不必重新估计市场模型即可完成第一版事件窗口检验。建议先做如下检验：

\[
H_0: E(CAR_{ij,w})=0
\]

其中 \(i\) 为事件，\(j\) 为公司，\(w\) 为窗口。对每个窗口报告：

- 平均 CAR。
- 中位数 CAR。
- 横截面 t 检验。
- Wilcoxon 符号秩检验。
- 正 CAR 比例及 binomial sign test。
- 按事件聚类或事件层聚合后的 t 检验。

必须避免把 5160 条观测当作完全独立样本。因为同一事件下 86 家公司共享同一个模型发布冲击和事件层变量，标准误至少应按 `final_event_id` 聚类。更稳健的方式是先对每个事件求平均 CAR，再在 60 个事件层面检验平均值是否为 0。

### 4.2 事件层平均效应

建议构造事件层结果：

\[
\overline{CAR}_{i,w}=\frac{1}{N_i}\sum_j CAR_{ij,w}
\]

然后检验 \(\overline{CAR}_{i,w}\) 的均值。事件层分析更适合解释模型发布本身是否引发 AI 股票篮子重定价，也能避免公司重复观测夸大显著性。

可进一步构造加权平均：

\[
\overline{CAR}^{VW}_{i,w}=\sum_j weight_{ij} CAR_{ij,w}
\]

当前数据没有市值权重字段，`size (log_assets)` 不是市值。如果需要价值加权结果，应补充事件日前市值；否则主文使用等权平均。

### 4.3 公司层暴露篮子反应

在 `relationship` 缺失的情况下，当前 86 家公司更像固定 AI 暴露股票篮子。可设计以下检验：

- 全部公司等权 CAR。
- 按行业分组的等权 CAR：`industry`、`industry_2`。
- 按公司类型手工分组，例如云服务、芯片、平台、应用软件、互联网、内容媒体。但这需要新增公司分类，不能直接声称来自当前 CSV。
- 剔除非美股后的美股篮子 CAR。

这一路径能支撑“模型发布是否影响 AI 相关股票篮子”，但不能支撑“不同经济暴露关系如何传导”。

## 5. 分组与异质性分析

### 5.1 按模态分组

可直接使用：

- `model_modality`。
- `model_modalities`。
- `is_multimodal`。
- `is_reasoning_model`。
- `is_coding_model`。
- `is_media_generation_model`。

建议做两类分析：

1. 事件层均值比较：比较不同模态事件的 \(\overline{CAR}_{i,w}\)。
2. 面板回归：在事件-公司面板中加入模态虚拟变量，并按事件聚类标准误。

解释时要强调：模态变量是事件层变量，它解释的是不同模型发布事件之间的平均差异，而不是同一事件内不同公司的反应差异。

### 5.2 按开源或开放权重分组

使用 `is_open_weight_or_open_source`。可比较开源/开放权重事件与闭源事件的 CAR 差异。

建议同时控制 `creator_country` 和 `model_modality`。原因是当前数据中开源变量与中国模型、media/LLM 样本可能高度相关。若直接比较开源与闭源，可能把国家、模态、发布者类型差异误解释为开源效应。

### 5.3 按发布者国家分组

使用 `creator_country` 或 `is_chinese_model`。可检验中国模型发布是否引发不同方向的美股 AI 篮子反应。

建议分两步：

- 粗分组：`is_chinese_model=1` vs `0`。
- 细分组：United States、China、France、United Kingdom。

由于法国和英国事件数量很少，主文不宜过度解释细分国家结果。可把非美国非中国样本合并为 `Other`。

### 5.4 按 Tier 分组

使用 `candidate_tier`。Tier 是重要性分层，适合作为事件强度变量。

可检验：

- Tier 1 事件是否带来更大绝对 CAR。
- Tier 1 事件是否带来更大媒体情感波动。
- Tier 1 与能力变量是否重叠。

建议结果变量不仅使用 CAR 水平，也使用 `abs(CAR)`。重大模型发布可能同时利好部分公司、压制另一部分公司，平均 CAR 可能接近 0，但绝对重定价幅度更大。

### 5.5 按能力样本分组

使用 `llm_capability_sample_flag` 和 `media_capability_sample_flag`。这不是经济机制变量，而是可观测能力指标来源的样本标签。

建议用途：

- 主样本：全部 60 个事件。
- LLM 机制样本：47 个事件。
- media 机制样本：13 个事件。
- 不把 LLM 指标和 media Elo 原始值放在同一回归中直接比较。

## 6. 媒体情感机制

### 6.1 可执行变量

当前数据有多个窗口的媒体态度均值和标准差。建议重命名为：

- `media_sent_mean_1`、`media_sent_sd_1`。
- `media_sent_mean_2`、`media_sent_sd_2`。
- `media_sent_mean_3`、`media_sent_sd_3`。
- `media_sent_mean_5`、`media_sent_sd_5`。
- `media_sent_mean_10`、`media_sent_sd_10`。
- `media_sent_mean_15`、`media_sent_sd_15`。
- `media_sent_mean_20`、`media_sent_sd_20`。

主机制变量建议使用与主 CAR 窗口匹配的媒体情感窗口。例如以 `car_1` 为主结果时，使用 `media_sent_mean_1` 和 `media_sent_sd_1`；以 `car_3` 为结果时，使用 `media_sent_mean_3` 和 `media_sent_sd_3`。

### 6.2 机制回归

基准形式：

\[
CAR_{ij,w}=\alpha+\beta_1 SentMean_{i,w}+\beta_2 SentSD_{i,w}+\gamma X_i+\delta Z_{ij}+\mu_j+\tau_t+\epsilon_{ij}
\]

其中：

- \(SentMean\) 衡量媒体态度方向。
- \(SentSD\) 衡量媒体分歧。
- \(X_i\) 包括模态、Tier、开源、国家、AA 能力等事件特征。
- \(Z_{ij}\) 包括规模、BM、波动率、动量、事件前 CAR。
- \(\mu_j\) 为公司固定效应，\(\tau_t\) 可用年份或季度固定效应。

由于媒体情感可能与 CAR 同时反应，不能把它解释为严格因果机制。更稳妥的表述是“媒体情感与市场反应相关，并可能反映信息传播和叙事解释路径”。

### 6.3 交互机制

可进一步检验：

\[
CAR_{ij,w}=\alpha+\beta_1 Capability_i+\beta_2 SentMean_{i,w}+\beta_3 Capability_i\times SentMean_{i,w}+Controls+FE+\epsilon_{ij}
\]

如果 \(\beta_3\) 显著，说明高能力模型的市场反应更依赖媒体正面解释或媒体关注。但当前数据没有新闻数量、媒体来源权重和事件前媒体情感，因此机制解释应保持克制。

## 7. AA 能力机制

### 7.1 LLM 能力机制样本

LLM 子样本使用 `llm_capability_sample_flag=1` 或 `representative_aa_source_table=aa_llm_models`。可分三组能力变量：

- 综合能力：`aa_intelligence_index`。
- 任务能力：`aa_coding_index`、`aa_math_index`、`mmlu_pro`、`gpqa`、`hle`、`livecodebench`、`scicode`、`math_500`、`aime`。
- 成本效率：`price_1m_input_tokens`、`price_1m_output_tokens`、`price_1m_blended_3_to_1`、`median_output_tokens_per_second`、`median_time_to_first_token_seconds`、`median_time_to_first_answer_token`。

建议主文优先使用少数核心变量，避免过多高度相关指标同时进入回归：

- `aa_intelligence_index`：综合能力。
- `aa_coding_index` 或 `livecodebench`：代码能力。
- `aa_math_index` 或 `aime`：数学/推理能力。
- `price_1m_blended_3_to_1`：综合价格。
- `median_output_tokens_per_second`：速度。

### 7.2 media 能力机制样本

media 子样本使用 `media_capability_sample_flag=1` 或 `representative_aa_source_table=aa_media_models`。可用变量：

- `aa_media_task`。
- `aa_media_elo`。
- `aa_media_rank`。
- `aa_media_appearances`。
- `aa_media_category_rows`。

media 样本只有 13 个事件，适合作为补充分析，不宜承载主结论。建议报告事件层散点图和简单回归，少放控制变量。

### 7.3 跨模态标准化

不能把 `aa_intelligence_index` 与 `aa_media_elo` 原始值合并。若确实需要全样本能力指标，建议在每个 `model_modality` 内构造标准化变量：

\[
CapabilityZ_i=\frac{Capability_i-\overline{Capability}_{m(i)}}{sd(Capability_{m(i)})}
\]

或构造模态内百分位：

\[
CapabilityPct_i=rank(Capability_i \mid modality=m(i)) / N_{m(i)}
\]

主文仍应以 LLM 子样本和 media 子样本分别报告。

### 7.4 能力与市场反应的回归

建议分步估计：

1. 只放能力变量：检验高能力模型是否对应更高或更强的 CAR。
2. 加入模态、Tier、国家、开源：检验能力是否仍有解释力。
3. 加入媒体情感：区分能力本身与媒体叙事。
4. 使用 `abs(CAR)` 作为结果：检验能力是否提高重定价幅度，而不限定方向。

推荐模型：

\[
CAR_{ij,w}=\alpha+\beta Capability_i+\theta Cost_i+\kappa Speed_i+\gamma EventControls_i+\delta FirmControls_{ij}+\mu_j+\tau_t+\epsilon_{ij}
\]

以及：

\[
|CAR_{ij,w}|=\alpha+\beta Capability_i+\theta Cost_i+\kappa Speed_i+\gamma EventControls_i+\delta FirmControls_{ij}+\mu_j+\tau_t+\epsilon_{ij}
\]

后者更贴合 proposal 中“同一事件可能利好一部分公司、压制另一部分公司”的机制。

## 8. 回归模型设计

### 8.1 当前数据可执行的基准模型

在 `relationship` 缺失前，建议把当前主模型定位为“AI 股票篮子对模型发布事件的平均反应与事件特征解释”。

\[
CAR_{ij,w}=\alpha+\beta X_i+\gamma Z_{ij}+\mu_j+\tau_q+\epsilon_{ij}
\]

其中：

- \(CAR_{ij,w}\)：`car_1`、`car_3`、`car_5` 等。
- \(X_i\)：模态、开源、国家、Tier、AA 能力、媒体情感。
- \(Z_{ij}\)：`size (log_assets)`、`BM_Ratio`、`volatility`、`Momentum`、`car_pre_m10_m2`。
- \(\mu_j\)：公司固定效应。
- \(\tau_q\)：发布季度固定效应或年份固定效应。
- 标准误：按 `final_event_id` 聚类；稳健性使用公司和事件双向聚类。

如果加入公司固定效应，公司层静态差异会被吸收，但事件层变量仍可识别，因为它们随事件变化。若同时加入很细的时间固定效应，例如具体发布日期固定效应，则所有事件层变量会被吸收，不能这么设定。

### 8.2 事件层回归

为了避免事件重复观测带来的显著性膨胀，建议把事件层平均 CAR 作为主稳健结果：

\[
\overline{CAR}_{i,w}=\alpha+\beta X_i+u_i
\]

样本只有 60 个事件，因此控制变量要少。建议每次只放一组核心解释变量：

- 模态 + Tier。
- 国家 + 开源。
- AA 能力 + 成本 + 速度。
- 媒体情感 + 媒体分歧。

事件层回归的优点是解释干净；缺点是样本小、统计功效有限。它适合作为主文核心表或附录稳健表。

### 8.3 公司行业异质性模型

当前没有公司-事件关系，但有行业字段。可用行业作为较粗的暴露异质性代理：

\[
CAR_{ij,w}=\alpha+\beta X_i+\sum_s \lambda_s Industry_{j,s}+\sum_s \rho_s X_i\times Industry_{j,s}+Controls+FE+\epsilon_{ij}
\]

可检验不同事件特征对半导体、软件、互联网服务、娱乐、专业服务等行业是否影响不同。该模型只能称为“行业异质性”，不能称为“经济暴露关系异质性”。

### 8.4 proposal 理想模型的可补充版本

若后续补齐 `relationship` 字段，可恢复 proposal 的核心模型：

\[
CAR_{ij,w}=\alpha+\beta X_i+\sum_r \lambda_r Relationship_{ij,r}+\sum_r \rho_r X_i\times Relationship_{ij,r}+\gamma Z_{ij}+\mu_j+\tau_q+\epsilon_{ij}
\]

这里 `Relationship` 至少应区分：publisher、parent company、strategic partner、major investor、cloud provider、distribution partner、direct competitor、compute supplier、application exposed firm、weak related entity。当前数据只有 `potential_us_exposure_type`，且它是事件层潜在暴露类型，不是每家公司与事件之间的关系，不能替代 `Relationship_{ij}`。

## 9. 稳健性检验

### 9.1 事件窗口稳健性

使用以下结果变量重复主分析：

- 短窗口：`car_1`、`car_2`、`car_3`。
- 中窗口：`car_5`。
- 长窗口：`car_10`、`car_15`、`car_20`。

主结论应以短窗口为准。长窗口可反映市场消化过程，但更容易混入财报、宏观新闻、产品发布、监管和行业事件。

### 9.2 样本稳健性

建议做以下样本限制：

- 仅 Tier 1 和 Tier 2，剔除 Tier 3。
- 仅 `likely_us_market_relevance=high`。
- 仅高置信发布日期：剔除 `release_date_confidence` 较弱或二手来源事件。
- 仅美股代码：剔除 `company_id` 中带海外交易所后缀的公司。
- 仅 LLM 能力样本。
- 仅 media 能力样本。
- 剔除 `release_date` 格式异常或无法确认事件。
- 剔除 CAR 极端值，或对连续变量做 1%/99% 缩尾。

### 9.3 标准误稳健性

建议至少报告：

- 按事件聚类标准误。
- 按公司聚类标准误。
- 按事件和公司双向聚类标准误。
- 事件层平均 CAR 回归。

由于事件数量只有 60，聚类标准误可能不稳定。可在稳健性中使用 wild cluster bootstrap。

### 9.4 变量口径稳健性

- 能力变量替换：`aa_intelligence_index` 替换为 `mmlu_pro`、`gpqa`、`livecodebench`、`aa_math_index`。
- 成本变量替换：input price、output price、blended price。
- 速度变量替换：output speed、TTFT、time to first answer token。
- 媒体情感窗口替换：1/3/5 日窗口。
- 结果变量替换：CAR 水平与 `abs(CAR)`。

## 10. 当前数据不能支持或不能充分支持的 proposal 内容

### 10.1 公司-事件经济暴露关系主检验暂不支持

proposal 的核心贡献是把模型发布事件与美股上市公司的经济暴露关系分开编码。但当前 `relationship` 字段在全部 5160 条观测中缺失。`potential_us_exposure_type` 只是事件层潜在暴露类型，例如 publisher、strategic_partner、direct_competitor、major_investor，不是每个公司与事件的真实关系。

因此，当前不能直接检验：

- publisher、parent company、strategic partner、major investor、cloud provider、distribution partner、direct competitor、compute supplier、application exposed firm 的差异。
- 能力变量与具体关系类型的交互项。
- OpenAI 事件中 Microsoft 是否作为战略伙伴/投资方/云服务方获得正向 CAR。
- Anthropic 事件中 Amazon 和 Google 是否因投资或云服务关系反应更强。
- xAI 事件中 Tesla 是否只是弱关联实体。

若强行使用 `potential_us_exposure_type`，会把事件类别误当成公司关系，产生概念错误。

### 10.2 ASVI 投资者关注机制暂不支持

当前数据有 `搜索代码1` 和 `搜索代码2`，但它们看起来是搜索关键词或索引键，例如“公司名 + 日期/季度”，不是 ASVI 数值。数据中没有 Google Trends、百度指数或其他搜索强度变量。

因此，当前不能检验 proposal 中的：

- firm-level ASVI。
- model-level search intensity。
- creator-level search intensity。
- event-level attention index。
- ASVI 与能力、媒体情感、时间趋势的交互机制。

可在报告中把 ASVI 作为后续扩展，不应在现有数据实证结果中声称已经完成。

### 10.3 事件纯净性检查暂不支持

proposal 要求排除财报、并购、监管处罚、诉讼、高管变动等混淆事件。当前 CSV 没有混淆事件标记，也没有公司公告或财报日字段。

因此，当前不能严格支持“事件窗口内无重大混淆事件”的识别假设。可做短窗口稳健性和事件前 CAR 控制，但不能替代混淆事件审查。

### 10.4 正常收益模型复算暂不支持

当前 CSV 已有 CAR，但没有原始日收益率、市场收益率、Fama-French 因子或估计窗口收益序列。因此无法在现有数据内复算：

- 市场模型正常收益。
- Fama-French 三因子或五因子 CAR。
- 不同估计窗口下的 AR/CAR。
- 市值加权事件组合收益。

如果主文要详细描述市场模型估计，需要说明 CAR 已由前置流程计算；若要完全复现，则需补充日度收益率和因子数据。

### 10.5 能力跃迁机制暂不充分支持

当前数据有 AA 代表模型能力，但没有同一发布者上一代模型的自动匹配字段，也没有 `capability_leap`。因此可以检验绝对能力、价格、速度，但不能直接检验“能力跃迁”。

若要支持 capability leap，需要构造：

- 同一 `true_model_creator`、同一 `model_family` 的前代模型。
- 相同 AA 指标下的差值或百分比变化。
- 是否为 frontier jump 的人工标记。

### 10.6 成本效率机制只能部分支持

当前有价格和速度字段，可以构造简单成本效率变量，例如 `aa_intelligence_index / price_1m_blended_3_to_1`。但需要处理价格为 0 的开源模型，否则比值会无穷大。建议使用：

- `log(1 + price_1m_blended_3_to_1)`。
- 低价 dummy。
- 开源 dummy 与价格变量分开。
- 对价格为 0 的开放权重模型单独编码。

### 10.7 严格“美股市场”样本暂未完成

当前公司池包含韩国、香港、日本、德国、瑞士、英国、芬兰、荷兰、意大利等市场公司。若论文标题和假设坚持“美股市场”，需要先构造 `is_us_listed` 或 `exchange_country`，剔除非美股公司。否则实证对象应改称“全球 AI 相关上市公司”或“美股为主的 AI 相关公司池”。

## 11. 推荐执行顺序

### 11.1 当前数据立即可执行

1. 清洗 CSV：删除第一行英文变量名、用其重命名字段、统一日期、转换数值变量。
2. 生成样本构造表和事件描述统计。
3. 报告全样本 CAR 事件窗口检验。
4. 生成事件层平均 CAR，并做事件层检验。
5. 按模态、开源、国家、Tier、LLM/media 样本分组。
6. 做媒体情感机制回归。
7. 做 LLM AA 能力机制回归和 media 补充回归。
8. 做短窗口、样本限制、缩尾和聚类标准误稳健性。

### 11.2 需要补充后执行

1. 补齐 `relationship`：为每个事件-公司对编码真实经济暴露关系。
2. 标记美股样本：新增 `is_us_listed` 或交易所国家字段。
3. 构造 ASVI：用搜索强度数据替代当前搜索关键词字段。
4. 标记混淆事件：公司-事件层面标注财报、并购、诉讼、监管、宏观事件。
5. 构造 capability leap：按发布者和模型家族匹配前代模型。
6. 补充日度收益和因子数据：复算市场模型和 Fama-French CAR。

## 12. 建议写作口径

当前数据最稳妥的论文表述是：

“本文首先把模型发布事件映射到一组 AI 相关上市公司，检验模型发布是否引发该公司池的短期异常收益反应。随后，本文利用事件层模型特征、AA 能力指标和媒体情感变量，解释不同模型发布事件之间的市场反应差异。由于当前版本尚未完成公司-事件关系编码，关系暴露异质性结果作为后续扩展，不作为本文现阶段主结论。”

不建议在当前数据基础上直接写：

- “战略伙伴显著上涨”。
- “直接竞争者显著下跌”。
- “云服务方受益”。
- “ASVI 放大市场反应”。
- “Fama-French 模型稳健”。
- “剔除所有混淆事件后结果不变”。

这些结论需要额外字段支持。

## 13. 最小可发表实证结构

若不再补充数据，当前数据仍可形成一套完整但边界清楚的实证报告：

1. 数据与样本：60 个重大模型发布事件、86 家 AI 相关上市公司、5160 个事件-公司观测；说明非美股公司限制。
2. 事件研究：短窗口 CAR 是否显著偏离 0；同时报告事件层平均 CAR。
3. 事件异质性：按模态、开源、中国模型、Tier、LLM/media 样本分组。
4. 媒体机制：媒体态度均值和分歧是否与 CAR 或 `abs(CAR)` 相关。
5. 能力机制：AA 能力、价格、速度是否解释 LLM 事件市场反应；media Elo 作为补充。
6. 稳健性：不同窗口、缩尾、事件层回归、剔除非美股、剔除低 Tier、聚类标准误。
7. 局限性：关系暴露、ASVI、混淆事件、正常收益复算、能力跃迁尚未完全支持。

这套结构能与 proposal 保持一致，同时不会超出现有数据的识别能力。
