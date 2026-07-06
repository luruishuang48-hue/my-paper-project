# Proposal 解读简报

## 1. 研究定位

本研究关注“重大 AI 模型发布事件”对美股 AI 相关公司的短期资本市场影响。核心不是检验模型发布者自身股价是否上涨，而是检验模型发布作为技术竞争格局冲击，如何通过经济暴露关系传导到美股上市公司。

研究单位应设为“事件-公司对”而非单一事件或单一发布者。每个模型发布事件可以对应多个美股上市公司，每家公司与事件之间的关系、方向和强度不同。被解释变量是公司在事件窗口内的 CAR。

该设计的关键必要性在于：OpenAI、Anthropic、xAI、DeepSeek、Mistral 等关键模型发布者未必是美股上市公司；但它们的模型发布仍会影响 Microsoft、Amazon、Google、NVIDIA、云服务商、算力供应商、竞争者和应用层公司。

## 2. 研究问题

报告应围绕五个问题展开：

1. 重大 AI 模型发布是否使美股 AI 相关上市公司在短事件窗口内出现显著 CAR。
2. 市场反应是否随经济暴露关系变化，例如发布者、母公司、战略伙伴、主要投资者、云服务方、分发方、直接竞争者、算力供应商和应用层公司是否存在不同反应。
3. 模型技术特征是否解释 CAR 的强度和方向，包括能力水平、能力跃迁、开源程度、模态、推理能力、成本效率和速度。
4. 投资者关注度 ASVI 与媒体情感是否放大或调节模型发布冲击。
5. 随着生成式 AI 从早期热潮进入商业化和成本竞争阶段，市场定价逻辑是否从 attention-driven / hype-driven 转向 capability-driven / cost-efficiency-driven / commercialization-driven。

## 3. 核心假设

H1：重大 AI 模型发布会使美股 AI 相关公司在事件窗口内产生显著 CAR，但方向取决于公司与事件的经济暴露关系。

H2：正向商业暴露公司更可能获得正向 CAR，例如发布者、母公司、战略伙伴、主要投资者、云服务方、分发方和算力供应商；直接竞争者或替代风险较高的应用公司可能获得负向或不显著 CAR。

H3：模型能力越强、能力跃迁越大、开源程度越高、成本效率越高、推理能力越强，市场反应越显著。但技术特征的方向取决于关系类型。高能力闭源模型可能利好发布者和战略伙伴并压制竞争者；高质量开源模型可能利好生态和算力需求，也可能削弱闭源厂商溢价；低成本高能力模型可能利好应用层，也可能压低模型服务商估值。

H4：ASVI 和媒体情感影响 CAR。ASVI 捕捉市场是否注意到事件，媒体情感捕捉市场如何理解事件。

H5：市场学习会导致定价机制随时间变化。早期更可能由关注度和叙事驱动，后期更可能由能力、成本效率和商业化关系驱动。

## 4. 样本口径

### 4.1 主样本定义

主样本为 Main Model Release Sample，只纳入重大 AI 模型发布事件。模型可以是文本、推理、代码、多模态、图像、视频或语音模型，但必须满足模型发布标准。

纳入标准包括：

1. 事件对象是模型或模型家族，不是纯产品、功能集成、浏览器、搜索、办公套件或 agent 产品。
2. 可以确认真实模型发布者 `true_model_creator`。
3. 可以确认官方发布日或首次广泛公开日，并记录 `source_of_release_date`。
4. 模型对外可访问、可测试、可调用、开源、API 可用，或被明确作为重大 frontier / flagship model 发布。
5. 事件至少获得两家主流财经或科技媒体报道，或被权威模型数据库/leaderboard 收录。
6. 能够构造至少一类美股上市公司经济暴露关系。
7. 事件窗口内没有明显混淆事件；若混淆事件只影响某家公司，应剔除或标记该事件-公司对，而不是机械删除整个事件。

### 4.2 排除与扩展样本

纯产品发布原则上不进入主样本，例如 Apple Intelligence、AI Overviews、ChatGPT Atlas、ChatGPT Agent、Operator、Jules、NotebookLM、SearchGPT 等。若保留，只能进入附录的产品事件扩展样本或稳健性说明。

研究系统原则上不进入主样本，例如 AlphaProof、AlphaGeometry、AlphaEvolve 等，除非其被明确作为模型发布且具有可验证发布日期、媒体关注和金融含义。

### 4.3 分层样本

报告应明确区分四层样本：

1. Main Model Release Sample：主事件研究样本。
2. LLM Capability Sample：可匹配 Artificial Analysis LLM 指标的文本、推理、代码或多模态 LLM 事件，用于能力机制检验。
3. Media Model Capability Sample：可匹配图像、视频、语音模型 Elo/rank 的事件，用于非文本生成模型补充分析。
4. Excluded Product/Event Sample：记录被排除的产品事件、agent 产品、搜索产品、办公套件集成、研究系统和无法确认模型对象的事件，用于透明披露和附录。

## 5. 经济暴露关系编码

公司层数据应以事件-公司为单位，核心字段包括：

- `event_id`
- `ticker`
- `company_name`
- `relationship_to_event`
- `exposure_strength`
- `exposure_source`
- `manual_exposure_confidence`

`relationship_to_event` 至少包括：

- `publisher`：模型发布者本身就是上市公司。
- `parent_company`：发布者是上市公司控股子公司。
- `strategic_partner`：战略合作方。
- `major_investor`：主要投资者。
- `cloud_provider`：云服务或算力合作方。
- `distribution_partner`：模型商业化或产品分发方。
- `direct_competitor`：直接模型竞争者。
- `compute_supplier`：芯片、服务器、数据中心、电力、网络设备等算力供应商。
- `application_exposed_firm`：应用层受影响公司。
- `ai_basket_member`：AI ETF 或 AI 相关股票池成员。
- `weak_related_entity`：弱关联实体，只能用于扩展分析。

编码原则是证据优先、宁严勿宽。每个关系至少需要一条可追溯证据，例如公司公告、投资协议、云合作披露、模型 API 文档、产品集成说明、供应链报道或权威媒体报道。若只能找到概念关联或市场传言，应降低置信度，并将其放入弱关联或扩展样本。

报告必须特别强调几类容易误判的关系：

- Microsoft 在 OpenAI 事件中不是 `publisher`，而是战略伙伴、主要投资者、云服务方或分发方。
- Amazon 和 Google 在 Anthropic 事件中不是发布者，而是投资者、云服务或战略伙伴。
- Tesla 不能在 xAI 事件中默认视为发布者或直接受益方；除非模型明确进入 Tesla 产品或服务，否则最多作为弱关联实体。
- 中国、欧洲或私营模型发布者即使没有美股股票，也可能通过竞争冲击、云合作、开源扩散或算力需求影响美股公司。

## 6. 变量设定

### 6.1 被解释变量

被解释变量为 `CAR_ij`，即公司 `j` 在模型发布事件 `i` 的事件窗口内累计异常收益率。

主窗口：`[-1,+1]`。

稳健性窗口：`[-3,+3]`、`[-5,+5]`。

事件日 `T0` 以官方发布日或首次广泛公开日为准。若发布日为美股非交易日，顺延至下一个交易日，并在稳健性检验中使用替代事件日。

### 6.2 事件特征变量

事件层字段包括：

- `event_id`
- `model_name`
- `true_model_creator`
- `creator_country`
- `creator_listed_status`
- `release_date`
- `model_modality`
- `model_family_or_single_model`
- `open_weight`
- `frontier_or_not`
- `capability_score_if_available`
- `source_of_release_date`

核心事件特征包括 model capability、capability leap、open-weight / open-source、modality、reasoning model、cost efficiency、speed、price、frontier rank、model family dummy、creator country 和 creator listed status。

能力变量应分为三类：

1. 绝对能力：AA Intelligence Index、Coding Index、Math Index 或 media Elo。
2. 相对能力：同模态 rank percentile、frontier gap、相对同一发布者上一代模型的能力跃迁。
3. 效率变量：capability divided by blended price、output speed、TTFT、低价高能力 dummy。

### 6.3 能力数据库口径

本研究使用 Artificial Analysis 官方 API 构建模型能力数据库。已有规范化表包括：

- `data/processed/aa_llm_models.csv`
- `data/processed/aa_media_models.csv`
- `data/processed/aa_media_categories.csv`

LLM 指标包括 Artificial Analysis Intelligence Index、Coding Index、Math Index、MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME、input/output/blended token price、output speed、latency / TTFT 等。

Media 指标包括 media task、Elo、rank、confidence interval、appearances、release date raw，以及 category-level Elo、category-level confidence interval 和 category-level appearances。

不同模态的原始能力分数不可直接合并。LLM 能力机制应在 LLM Capability Sample 中估计；图像、视频、语音模型应使用 Media Model Capability Sample 单独估计。跨模态描述只能使用 within-modality z-score 或 within-modality rank percentile。

AA 指标可能是事后标准化能力，不完全等于事件日市场可得信息。报告应把它解释为事后标准化技术能力度量，而不是投资者在事件日完全掌握的信息。

### 6.4 关注度变量

ASVI 是公司-事件层面的市场关注变量。应采用多口径构造：

- firm-level ASVI：ticker 和公司名在事件窗口的异常搜索量。
- model-level search intensity：模型名搜索强度。
- creator-level search intensity：真实发布者搜索强度。
- event-level attention index：事件综合关注指数。

基准期可设为事件日前 56 个自然日或 8 周中位数，事件期聚合为 `[-1,+1]` 平均值或最大值。低搜索量、通用词和歧义 ticker 应人工标记。

主回归优先使用 firm-level ASVI；机制分析再分别加入 model-level、creator-level 和 event-level attention index。

### 6.5 媒体情感变量

媒体情感应从“针对发布方公司”改为“针对事件及相关公司”。可分为事件级情感、公司级情感和事件-公司级情感。

指标包括：

- 情感均值：报道方向。
- 情感标准差：媒体分歧。
- 报道数量：媒体覆盖强度。

主指标可使用 FinBERT 或人工校验的金融情感模型；大语言模型情感打分可作为补充或稳健性分析。语料窗口应与 CAR 窗口严格对齐，并可保留扩展窗口用于稳健性。

### 6.6 控制变量

公司层控制变量包括规模、市值、账面市值比、动量、波动率、行业分类、研发强度、AI 业务暴露、历史 beta 和事件前 CAR。

事件层控制变量包括发布者国家、事件年份/季度、模型模态、是否模型家族、媒体报道数量和是否存在低置信匹配。

固定效应包括行业固定效应和事件时间固定效应。

## 7. 实证模型

### 7.1 事件研究法

正常收益率使用市场模型估计，估计窗口为事件日前 `[-200,-10]` 个交易日：

```tex
R_{j,t}=\alpha_j+\beta_j R_{m,t}+\epsilon_{j,t}
```

异常收益率：

```tex
AR_{ij,t}=R_{j,t}-\hat{\alpha}_j-\hat{\beta}_jR_{m,t}
```

累计异常收益率：

```tex
CAR_{ij}[T_1,T_2]=\sum_{t=T_1}^{T_2}AR_{ij,t}
```

稳健性检验应使用 Fama-French 三因子或五因子模型重新估计正常收益率，并计算事件前 `[-10,-2]` 窗口的 `CARpre_ij`，用于控制事件前趋势、信息泄露或预期反应。

### 7.2 事件-公司面板回归

基准模型为：

```tex
CAR_{ij}
=
\beta_0
+\beta_1 X_i
+\beta_2 Relationship_{ij}
+\beta_3 X_i \times Relationship_{ij}
+\gamma Z_j
+\delta_{industry(j)}
+\lambda_{time(i)}
+\epsilon_{ij}
```

其中 `i` 表示模型发布事件，`j` 表示美股上市公司，`X_i` 为模型事件特征，`Relationship_ij` 为公司与事件的经济暴露关系，`Z_j` 为公司层控制变量。

标准误应按事件或公司聚类，稳健性分析使用双向聚类。

对非上市模型发布者不构造 publisher CAR。不能把合作方、投资方或关联方误当作模型发布者。

### 7.3 能力机制检验

能力机制检验建议采用逐步模型：

1. 只加入关系暴露变量，观察不同关系类型的平均反应。
2. 加入能力和成本效率变量，检验技术特征是否解释事件间差异。
3. 加入能力与关系类型交互项，检验同一技术特征是否对不同公司产生相反影响。
4. 加入 ASVI 和媒体情感，区分技术特征本身的解释力与信息传播的放大效应。

LLM Capability Sample 使用 AA Intelligence Index、Coding Index、Math Index、价格、速度、TTFT、frontier rank、capability percentile、price efficiency 和 speed-adjusted capability。

Media Model Capability Sample 单独估计，使用 media Elo、rank、ci95、appearances 和 category-level Elo。

### 7.4 关系异质性检验

用关系虚拟变量和交互项检验 H2 与 H3。预期方向包括：

- 模型能力与 `strategic_partner`、`cloud_provider`、`compute_supplier` 的交互项可能为正。
- 模型能力与 `direct_competitor` 的交互项可能为负。
- 低成本高能力模型与 `application_exposed_firm` 的交互项方向不确定，可能因成本下降利好应用层，也可能因替代风险造成负面影响。
- `weak_related_entity` 不进入主回归，只用于扩展分析。

### 7.5 市场学习与时间演变检验

市场学习检验可采用三种方式：

1. 加入连续时间趋势 `trend_month_since_2022_11`，并与 ASVI、媒体情感、能力指标和成本效率交互。
2. 分阶段估计，例如 2022 年 11 月至 2023 年末为早期关注阶段，2024 年以后为商业验证和成本竞争阶段。
3. 使用滚动事件窗口估计 ASVI、能力和成本效率系数随时间的变化。

## 8. 报告应覆盖的重点

完整分析报告至少应覆盖以下内容：

1. 样本审计：事件数量、主样本与排除样本数量、事件类型分布、模态分布、发布者分布、年度分布。
2. 数据质量：`true_model_creator`、`release_date`、`relationship_to_event`、`exposure_strength`、AA 匹配状态、缺失值和低置信匹配情况。
3. 暴露关系分布：每类关系的事件-公司对数量，典型案例和容易误判案例。
4. 事件研究结果：主窗口 `[-1,+1]` 的 CAR 分布、均值、中位数、显著性、按关系类型分组结果。
5. 稳健性窗口：`[-3,+3]`、`[-5,+5]` 与替代正常收益模型结果。
6. 能力机制：LLM 样本与 Media 样本分开报告，不跨模态混用原始分数。
7. 关系异质性：能力、开源、成本效率、速度与关系类型交互项。
8. ASVI 与媒体情感：关注度和情感是否解释事件间差异，是否改变能力变量系数。
9. 时间演变：早期与后期机制差异，尤其关注从叙事定价到能力/成本/商业化定价的变化。
10. 混淆事件与样本限制：说明哪些事件-公司对被剔除或标记，避免过度因果解释。

## 9. 解释路径

如果全样本平均 CAR 不稳定或不显著，不应直接否定 H1。由于同一事件可能同时利好合作方和压制竞争者，平均效应可能相互抵消。报告应把重点放在是否存在超出正常波动的重新定价，以及这种重新定价是否沿经济暴露关系和技术特征系统性分化。

如果关系异质性显著，应解释为模型发布冲击通过产业组织关系传导，而不是发布者自身收益效应。

如果能力、成本效率或速度变量显著，应强调资本市场不仅反应事件新闻本身，也反应模型技术含量和商业化含义。

如果 ASVI 和媒体情感显著，应解释为信息传播与市场关注会放大或塑造技术冲击。

如果时间交互显著，应将其解释为市场学习：早期 AI 事件更受关注度和媒体叙事影响，后期更重视能力、成本效率和商业化落地。

## 10. 需要警惕的限制

1. 事件研究识别的是短期市场反应，不能直接声称模型发布导致公司长期基本面变化。
2. 模型发布事件不是随机发生，不能把结果解释为强因果效应。当前设计更适合定位为短期事件研究、机制解释和异质性分析。
3. ASVI 和媒体情感可能与 CAR 同时反应，存在内生性，不能简单解释为外生冲击。
4. 严格筛选模型发布主样本会减少事件数量。不能为了扩大样本而混入产品事件或研究系统。
5. 非上市发布者需要通过美股暴露公司映射，关系编码若证据不足会引入测量误差。
6. 不同模态能力指标不可比。LLM Intelligence Index 与图像、视频、语音 Elo 不能直接合成一个原始 Capability 变量。
7. AA 能力指标可能是事后标准化数据，不完全等于事件日投资者可得信息。
8. 事件日可能存在预告、技术报告、API 开放和媒体报道多日分布，需要替代事件日稳健性检验。
9. 事件窗口内财报、并购、监管、宏观冲击或公司重大公告会污染 CAR，应在事件-公司对层面剔除或标记。
10. `weak_related_entity` 只能用于扩展分析，不能支撑主结论。
11. 对 OpenAI-Microsoft、Anthropic-Amazon/Google、xAI-Tesla、DeepSeek-NVIDIA/美国云服务商等组合必须逐项审计，避免把商业关系、投资关系、供应链关系和发布者身份混为一谈。

## 11. 对主报告写法的建议

报告应采用“先结论、后机制、再限制”的结构。第一部分直接说明主样本数量、事件-公司对数量、主窗口 CAR 结果和最核心异质性发现。随后再解释数据构造、关系编码和能力指标。不要把大量样本清洗细节放在开头拖慢主线。

报告标题和摘要应避免写成“AI 模型发布利好/利空股价”的单向结论。更准确的表述是：重大模型发布引发美股 AI 相关公司的重新定价，方向和强度取决于经济暴露关系、模型技术特征和信息传播强度。

主结论应谨慎使用因果语言。建议使用“短期市场反应”“资本市场重新定价”“与……显著相关”“沿……异质性分化”等表述，避免使用“导致长期价值提升”“证明基本面改善”等超出设计范围的说法。
