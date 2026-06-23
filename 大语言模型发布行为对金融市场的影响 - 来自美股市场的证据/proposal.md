# 重大 AI 模型发布对美股 AI 相关公司的资本市场影响——基于事件研究与模型能力数据的证据

## 一、引言

### （一）研究背景

2022 年 11 月 ChatGPT 公开发布之后，生成式 AI 迅速从技术社区议题转变为资本市场定价对象。此后，OpenAI、Anthropic、Google、Meta、xAI、Microsoft、Amazon、DeepSeek、Alibaba、Mistral 等模型发布者持续推出文本、推理、代码、多模态、图像、视频和语音模型。每一次重大模型发布都可能改变市场对 AI 技术前沿、商业化速度、算力需求、云服务竞争、应用替代风险和产业利润分配的预期。

本研究关注的对象不是一般 AI 产品发布，也不是办公软件、浏览器、搜索、agent 产品或功能集成，而是“重大 AI 模型发布事件”。模型发布与产品发布在金融含义上不同。模型发布通常代表基础能力、成本效率、推理能力或模态边界的变化，可能重估整个 AI 产业链；产品发布更多反映既有模型能力在特定场景中的包装、分发或应用落地。若将二者混在同一主样本中，事件冲击的来源会变得模糊，模型能力变量也难以解释资本市场反应。

同时，模型发布者与美股上市受影响公司并不总是同一主体。OpenAI 发布模型，并不等于 Microsoft 发布模型；xAI 发布模型，并不等于 Tesla 发布模型；Anthropic 发布模型，也不等于 Amazon 或 Google 发布模型。中国、欧洲或私营模型发布者即使没有美股股票，也可能通过竞争冲击、云合作、算力需求、开源扩散或应用替代影响美股 AI 相关公司。因此，本研究将研究对象拆分为两个层级：第一是模型发布事件本身，第二是与该事件存在经济暴露关系的美股上市公司。

### （二）研究问题

本文围绕以下五个问题展开：

1. 重大 AI 模型发布事件是否导致美股 AI 相关上市公司在短事件窗口内出现显著累计异常收益率（CAR）？
2. 资本市场反应是否沿着不同经济暴露关系异质性传导？例如发布者、母公司、战略伙伴、主要投资者、云服务方、分发方、直接竞争者、算力供应商和应用层暴露公司是否反应不同？
3. 模型发布事件的技术特征，例如能力水平、能力跃迁、开源程度、模态、推理能力、成本效率和速度，是否解释 CAR 的强度与方向？
4. 投资者关注度 ASVI 与媒体情感是否放大或调节模型发布冲击？市场是否不仅反应“模型是什么”，也反应“市场是否注意到”和“媒体如何理解”？
5. 随着生成式 AI 从早期关注热潮进入商业化和成本竞争阶段，资本市场是否从 attention-driven / hype-driven 逻辑逐渐转向 capability-driven / cost-efficiency-driven / commercialization-driven 逻辑？

与旧设计不同，本文不再把“发布者自身股价上涨”作为核心假设。许多重要模型发布者不是美股上市公司。本文真正关心的是：当一个重大模型发布改变技术竞争格局时，美股资本市场如何重新定价具有不同经济暴露关系的上市公司。

### （三）核心贡献

本文拟在三个方面作出贡献。

第一，本文把 AI 模型发布事件与美股上市公司暴露关系分开编码，避免把模型发布者误当作股票标的。事件层记录真实模型发布者、模型名称、发布日期、模态、开源状态和能力指标；公司层记录美股公司与事件之间的经济关系，例如战略伙伴、云服务方、算力供应商、直接竞争者或弱关联实体。该设计更符合当代 AI 产业组织结构，也能处理 OpenAI、Anthropic、xAI、DeepSeek 等非美股上市发布者对美股公司的溢出影响。

第二，本文引入 Artificial Analysis 官方 API 数据构建模型能力数据库。当前项目已形成本地 master database，包括 `aa_llm_models.csv`、`aa_media_models.csv` 和 `aa_media_categories.csv`。其中 LLM 表含 496 条模型记录，media 表含 401 条任务级模型记录，media category 表含 5962 条类别级记录。该数据库使事件研究不再只依赖人工 SOTA 标记，而能纳入模型能力、代码能力、数学能力、价格、速度和媒体模型 Elo/rank 等结构化指标。

第三，本文在事件研究框架中加入投资者关注、媒体情感和时间演变机制。ASVI 用于捕捉市场是否注意到事件，媒体情感用于捕捉市场如何理解事件，时间趋势和分阶段分析用于检验资本市场是否从早期情绪定价逐渐转向能力、成本效率和商业化潜力定价。

本文的研究边界也较为明确。第一，本文研究短期资本市场反应，不直接声称模型发布会导致公司长期基本面变化。长期收入、利润率、市场份额和研发效率属于后续研究问题。第二，本文不把所有 AI 相关新闻都视为技术冲击，只研究能够定位到具体模型或模型家族的发布事件。第三，本文不把“模型发布者是否上市”作为事件纳入条件。上市状态只影响是否能构造 `publisher` CAR，不影响事件是否可能对美股 AI 暴露公司产生冲击。第四，本文对“重大”的定义采取可审计标准：官方发布、媒体覆盖、leaderboard 收录、可访问性或 flagship/frontier 定位至少需要形成可验证证据链。

## 二、理论机制与研究假设

### （一）模型发布作为技术竞争格局冲击

重大模型发布不仅是研发进展披露，也是技术竞争格局冲击。一个高能力模型可能改变市场对以下变量的预期：模型服务毛利率、应用层自动化能力、云算力需求、GPU 和数据中心资本开支、搜索与办公软件竞争格局、开源生态扩散速度，以及既有闭源模型厂商的技术溢价。

模型发布的冲击不必局限于发布者本身。若发布者是私营企业，市场仍可能重新评估其主要投资者、云服务伙伴、算力供应商、分发渠道、直接竞争者和应用层公司。例如，OpenAI 发布模型时，Microsoft 的角色更接近战略伙伴、主要投资者、Azure 云服务方和分发方，而不是模型发布者。类似地，Anthropic 发布模型时，Amazon 和 Google 应作为投资者、云服务或战略伙伴处理；xAI 发布模型时，Tesla 不能被默认视为发布者或直接受益方，除非该模型明确进入 Tesla 产品或服务。

这一机制类似技术竞争中的公共信号冲击。模型发布向市场披露某一实验室或生态的能力边界，也改变投资者对其他公司的相对位置判断。若新模型显著提升推理、代码、数学或多模态能力，市场可能上调合作方和云服务方的商业化预期，同时下调能力落后的模型厂商或容易被替代的应用公司的估值。若新模型大幅降低推理价格或提升输出速度，市场可能重新评估 API 毛利率、应用开发成本、AI 功能渗透率和算力需求弹性。因而，模型技术特征必须与公司暴露关系一起解释，不能只看事件平均效应。

### （二）经济暴露关系与资本市场传导

模型发布事件通过不同关系向上市公司传导。正向暴露关系包括：上市公司本身发布模型、发布者是其控股子公司、公司是战略合作方、主要投资者、云服务供应商、分发渠道或算力供应商。负向或不确定暴露关系包括：公司是直接模型竞争者、存在应用层替代风险、依赖被新模型削弱的既有技术路径。弱关联实体只应进入扩展分析，不能被当作发布者。

因此，本文的核心单位是事件-公司对。对于每个模型发布事件 \(i\)，可以构造多个美股上市公司 \(j\) 的暴露观测。被解释变量是公司 \(j\) 在事件 \(i\) 窗口内的 CAR，而不是发布者本身的收益率。若模型发布者没有美股上市股票，则不构造 publisher CAR，但仍可构造战略伙伴、云服务方、算力供应商、竞争者等公司的 CAR。

暴露关系还具有方向和强度。方向指公司从事件中可能获得正向、负向还是不确定影响；强度指关系是否足以在短窗口内被投资者定价。例如，明确的云独占合作、重大股权投资、模型 API 分发协议或芯片采购关系属于高强度证据；媒体推测、创始人个人关系或同一产业概念下的弱联系属于低强度证据。本文将把关系证据来源写入数据表，避免事后根据股价表现反推关系。

### （三）模型能力、开源与成本效率

模型技术特征影响市场反应，但方向并非单一。高能力闭源模型可能利好发布者、母公司和战略伙伴，也可能压制直接竞争者。高质量开源模型可能利好生态、开发者工具、云部署和算力需求，但压缩闭源模型服务商的溢价。低成本高能力模型可能提升应用层公司利润预期，同时降低既有 API 服务商和高价模型厂商估值。

模型模态也会改变冲击路径。文本、推理和代码模型更多影响软件、云服务、搜索、办公和企业应用；图像、视频和语音模型更多影响创意工具、广告、媒体、影视、游戏和内容平台。不同模态不能用同一个原始能力分数直接合并回归。本文将采用分样本回归、modality-specific capability、within-modality z-score 和 within-modality rank percentile 进行统一化处理，避免把 LLM Intelligence Index 与图像/视频 Elo 机械合成为一个 Capability 变量。

能力变量的经济含义也要分层解释。绝对能力水平代表模型处于技术前沿的程度；能力跃迁代表该模型相对前代或同一发布者既有模型的增量信息；成本效率代表能力单位价格或速度的改善；开源状态代表技术扩散路径和商业捕获方式。四类变量可能产生不同方向的市场反应。闭源 frontier 模型更可能被市场解读为发布者或战略伙伴的专有优势；高质量开源模型更可能被解读为行业公共技术供给增加；低价高能力模型则可能同时扩大应用需求并压缩模型服务利润率。

### （四）投资者关注、媒体情感与市场学习

资本市场对模型发布的反应取决于信息内容，也取决于信息传播。ASVI 衡量投资者是否主动搜索相关公司、模型或发布者；媒体情感衡量财经和科技媒体如何解释事件。对于非上市模型发布者，不能简单使用发布者 ticker 的 Google Trends。本文将构造多口径关注变量，包括 firm-level ASVI、model-level search intensity、creator-level search intensity 和 event-level attention index。

随着生成式 AI 发展阶段推进，市场学习机制也可能变化。早期事件可能由关注度、叙事和媒体情绪主导；后期市场可能更关注能力跃迁、成本效率、推理能力、API 定价、上下文窗口、商业化路径和算力需求。本文将用时间趋势、分阶段回归和交互项检验这种变化。

### （五）研究假设

H1：重大 AI 模型发布事件会使美股 AI 相关公司在事件窗口期内产生显著 CAR，但反应方向取决于公司与事件的经济暴露关系。

H2：与模型发布事件存在正向商业暴露的公司，例如发布者、母公司、战略伙伴、主要投资者、云服务方、分发方和算力供应商，更可能获得正向 CAR；直接竞争者或被替代风险较高的应用公司，可能获得负向或不显著 CAR。

H3：模型能力越强、能力跃迁越大、开源程度越高、成本效率越高、推理能力越强，市场反应越显著。但不同特征对不同关系类型公司的影响方向可能不同。高能力闭源模型可能利好发布者和战略伙伴并压制竞争者；高质量开源模型可能利好生态与算力需求但削弱闭源厂商溢价；低成本高能力模型可能提升应用层预期，同时压低既有模型服务商估值。

H4：事件窗口内异常搜索量 ASVI 和媒体情感会影响 CAR。ASVI 捕捉市场是否注意到事件，媒体情感捕捉市场如何理解事件。

H5：随着生成式 AI 发展阶段推进，资本市场对模型发布的反应可能从早期的 attention-driven / hype-driven 逻辑，逐渐转向 capability-driven / cost-efficiency-driven / commercialization-driven 逻辑。

## 三、样本构建与数据来源

### （一）候选事件池

候选事件池来自多类来源：AI Timeline、Artificial Analysis leaderboard、公司官方公告、技术博客、模型卡、technical report、主流财经和科技媒体，以及其他权威 AI benchmark / leaderboard。AI Timeline 只作为候选事件发现来源，不是样本纳入标准。最终样本必须经过人工审核和可复现编码。

当前项目已有 `data/events_match_diagnosed.csv`，包含 94 条候选事件，并对事件类型进行了二次诊断。诊断结果显示，候选事件中既有 text LLM、reasoning LLM、coding LLM、multimodal model、image model、video model 和 audio model，也混有 product integration、agent product 和 research system。该诊断结果说明，主样本必须进一步过滤，不能把产品事件与模型发布事件混合使用。

候选事件池的作用是提高召回率，而不是直接决定主样本。数据清洗阶段可以保留较宽口径事件，以便记录为何排除；实证阶段必须采用窄口径主样本。对于同一天同一发布者发布多个模型的情形，本文将区分“模型家族发布”和“单一模型发布”。若模型家族内多个变体同时发布，主样本事件仍可保留为一个事件，但能力机制检验需要明确代表变体选择规则，例如选择同批发布中能力最强、最旗舰或官方主推的模型，并在匹配方法中标记 `manual_family_strongest_variant` 或类似字段。

### （二）模型发布事件纳入标准

主样本只纳入重大 AI 模型发布事件，需同时满足以下条件：

1. 事件对象是模型或模型家族，而不是纯产品、功能集成、浏览器、搜索、办公套件或 agent 产品。
2. 可以确认真实模型发布者，即 `true_model_creator`。真实发布者可以是 OpenAI、Anthropic、xAI、Google、Meta、Microsoft、Amazon、DeepSeek、Alibaba、Mistral 等，不要求其自身是美股上市公司。
3. 可以确认官方发布日或首次广泛公开日，并记录 `source_of_release_date`。
4. 模型对外可访问、可测试、可调用、开源、API 可用，或被发布者明确作为重大 frontier / flagship model 发布。
5. 事件在短窗口内获得至少两家主流财经或科技媒体报道，或被权威模型数据库/leaderboard 收录。
6. 能够构造至少一类美股上市公司经济暴露关系。
7. 事件窗口内没有明显混淆事件，例如财报、并购、监管处罚、重大诉讼、高管变动或同日其他足以主导股价的大事件。

纯产品发布原则上不进入主样本。例如 Apple Intelligence、AI Overviews、ChatGPT Atlas、ChatGPT Agent、Operator、Jules、NotebookLM、SearchGPT 等，若保留，只能进入附录中的产品事件扩展样本或稳健性说明，不能与模型发布主样本混合。

研究系统原则上也不进入主样本，除非它被明确作为模型发布，并且有可验证发布日期、媒体关注和市场金融含义。AlphaProof、AlphaGeometry、AlphaEvolve 等更适合标为 research system，并在主样本外说明。

主样本还需进行事件纯净性检查。事件窗口内若相关公司发布财报、并购公告、监管处罚、重大诉讼、管理层变动、融资分红或其他足以主导股价的信息，应对该事件-公司对进行剔除或标记，而不是机械删除整个模型事件。这样可以保留事件层信息，同时避免个别公司混淆事件污染面板估计。

### （三）事件分层：主样本、LLM 能力样本、Media 能力样本、排除样本

本文将事件分为四层。

第一，Main Model Release Sample。该样本只包含重大模型发布事件，用于主事件研究。模型可以是文本、推理、代码、多模态、图像、视频或语音模型，但必须满足模型发布纳入标准。

第二，LLM Capability Sample。该样本包含可以匹配到 Artificial Analysis LLM 指标的文本、推理、代码或多模态 LLM 事件，用于能力机制检验。若事件只是模型家族发布，应人工选择同批发布中最强或最具代表性的模型，并记录匹配方法。

第三，Media Model Capability Sample。该样本包含可以匹配到图像、视频、语音模型 Elo/rank 的事件，用于非文本生成模型补充分析。媒体模型不使用 LLM Intelligence Index。

第四，Excluded Product/Event Sample。该样本记录产品发布、agent 产品、搜索产品、办公套件集成、研究系统和无法确认模型对象的事件。它们不进入主样本，可作为附录、样本筛选透明度材料或扩展稳健性分析。

### （四）美股暴露公司池与关系编码

本文将为每个模型发布事件构造美股暴露公司池。公司层数据以事件-公司为单位，字段包括：

- `event_id`
- `ticker`
- `company_name`
- `relationship_to_event`
- `exposure_strength`
- `exposure_source`
- `manual_exposure_confidence`

`relationship_to_event` 至少包括：

- `publisher`：模型发布者本身就是上市公司；
- `parent_company`：发布者是上市公司控股子公司；
- `strategic_partner`：战略合作方；
- `major_investor`：主要投资者；
- `cloud_provider`：云服务或算力合作方；
- `distribution_partner`：模型商业化或产品分发方；
- `direct_competitor`：直接模型竞争者；
- `compute_supplier`：芯片、服务器、数据中心、电力、网络设备等算力供应商；
- `application_exposed_firm`：应用层受影响公司；
- `ai_basket_member`：AI ETF 或 AI 相关股票池成员；
- `weak_related_entity`：弱关联实体，只能用于扩展分析。

这种编码要求特别谨慎。Microsoft 在 OpenAI 事件中不是 `publisher`，而应编码为 `strategic_partner`、`major_investor`、`cloud_provider` 或 `distribution_partner`。Tesla 在 xAI 事件中不能默认作为发布者或直接受益方，最多是 `weak_related_entity`；只有当模型明确进入 Tesla 产品或服务时，才可提高关系强度。Amazon 和 Google 在 Anthropic 事件中不是发布者，而是投资者、云服务合作方或战略伙伴。

关系编码应遵循“证据优先、宁严勿宽”的原则。每个 `relationship_to_event` 至少需要一条可追溯证据，例如公司公告、投资协议、云合作披露、模型 API 文档、产品集成说明、供应链报道或权威媒体报道。若只能找到市场传言或概念性关联，应降低 `manual_exposure_confidence`，并把该公司放入弱关联或扩展样本。关系编码完成后，还需要人工复核若干典型案例，尤其是 OpenAI-Microsoft、Anthropic-Amazon/Google、xAI-Tesla、DeepSeek-NVIDIA/云服务商、中国模型事件与美国竞争者等容易误判的组合。

### （五）Artificial Analysis 模型能力数据库

当前项目已基于 Artificial Analysis 官方 API 构建本地 master model database。原始 response 保存在 `data/raw/artificial_analysis/`，规范化表包括：

- `data/processed/aa_llm_models.csv`
- `data/processed/aa_media_models.csv`
- `data/processed/aa_media_categories.csv`

根据 `reports/aa_api_fetch_report.md`，本地缓存包含 496 条 LLM 模型、401 条 media 模型任务记录和 5962 条 media category 记录。所有请求结果均来自官方 API，API key 从环境变量读取，未写入代码或输出文件。抓取报告显示没有 endpoint error；字段缺失被保留为空，不进行编造。

LLM 模型指标包括 Artificial Analysis Intelligence Index、Coding Index、Math Index、MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME、input/output/blended token price、output speed、latency / TTFT 等。media 模型指标包括 media task、Elo、rank、confidence interval、appearances、release date raw，以及 category-level Elo、category-level confidence interval 和 category-level appearances。

本文不会把不同模态的原始分数直接合并为一个统一 Capability 变量。主文的 LLM 能力机制使用 LLM 子样本；图像、视频、语音模型作为补充分析或异质性分析。若需要跨模态描述能力强弱，将使用 within-modality z-score 或 within-modality rank percentile，而不是直接比较 LLM Intelligence Index 与 media Elo。

AA 匹配结果也需要区分“确认匹配”和“人工审核匹配”。已有 `match_failure_summary.md` 显示，模型标注事件中存在 unmatched、matched_low_confidence 和 matched_confirmed 等状态，低置信匹配不应自动回填能力指标。本文将在主样本构建阶段保留 `match_score`、`match_method`、`failure_reason` 和 `manual_match_review_required` 字段。对于 image/video/audio 事件，应优先使用 media endpoint；对于 LLM 事件，才使用 LLM endpoint。对于模型家族、别名和变体不明确的事件，应记录人工选择依据。

### （六）股价、财务、媒体与搜索数据

股价和市场数据拟来自 CRSP、Yahoo Finance 或其他可复现金融数据库。日度收益率、市值、成交量和行业分类用于计算 CAR、控制变量和样本描述。财务数据拟来自 Compustat、公司年报或等价数据库，包括总资产、账面市值比、盈利能力、研发强度、杠杆、动量和波动率等。

媒体数据来自 Factiva、Reuters、Bloomberg、Wall Street Journal、CNBC、TechCrunch、The Verge、公司官方博客和主流科技媒体等可追溯来源。搜索数据用于构造 ASVI，关键词不再只使用发布者或股票代码，而是根据事件-公司结构构造多口径搜索词，包括 ticker、公司名、模型名、真实发布者名和事件关键词。

## 四、变量定义

### （一）被解释变量：CAR

被解释变量为 \(CAR_{ij}\)，即公司 \(j\) 在模型发布事件 \(i\) 的事件窗口内累计异常收益率。主窗口为 \([-1,+1]\)，稳健性窗口包括 \([-3,+3]\) 和 \([-5,+5]\)。事件日 \(T_0\) 以官方发布日或首次广泛公开日为准；若发布日为美股非交易日，则顺延至下一个交易日，并在稳健性检验中使用替代事件日。

### （二）核心事件特征变量

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

核心 \(X_i\) 包括 model capability、capability leap、open-weight / open-source、modality、reasoning model、cost efficiency、speed、price、frontier rank、model family dummy、creator country 和 creator listed status。能力跃迁可定义为同一 creator 或同一模型家族相对前一代的能力提升；若缺少可比指标，则不强行填充。

在可行情况下，本文将构造三类能力变量。第一类是绝对能力，例如 AA Intelligence Index、Coding Index、Math Index 或 media Elo。第二类是相对能力，例如同模态 rank percentile、frontier gap 或相对同一发布者上一代模型的能力跃迁。第三类是效率变量，例如 capability divided by blended price、output speed、TTFT 以及低价高能力 dummy。这三类变量对应不同经济机制，不能混为一谈。

### （三）关系暴露变量

关系暴露变量 \(Relationship_{ij}\) 由事件-公司关系编码而来。主回归使用一组关系虚拟变量，并可进一步构造 `exposure_strength`。关系强度可分为 high、medium、low 或 0–3 分，依据公开合作关系、投资关系、云服务披露、产品集成、供应链证据和人工置信度确定。

### （四）投资者关注度变量

ASVI 是公司-事件层面的市场关注变量。对于每个事件-公司对，优先构造 firm-level ASVI，即 ticker 和公司名在事件窗口的异常搜索量。对于非上市发布者事件，还构造 model-level search intensity、creator-level search intensity 和 event-level attention index。ASVI 的基准期可设为事件日前 56 个自然日或 8 周中位数，事件期聚合为 \([-1,+1]\) 平均值或最大值。对低搜索量、通用词和歧义 ticker 进行人工标记。

多口径 ASVI 的目的不是制造更多解释变量，而是处理非上市发布者带来的测量问题。若发布者没有 ticker，单用发布者股票搜索量不可行；若模型名具有通用含义，单用模型名会引入噪声；若公司名过于常见，ticker 与公司名需要交叉验证。因此，本文将在主回归中优先使用 firm-level ASVI，并在机制分析中分别加入 model-level、creator-level 和 event-level attention index，检验市场关注从事件本身传导到相关公司股票的路径。

### （五）媒体情感变量

媒体情感从“针对发布方公司”改为“针对事件及相关公司”。情感指标包括事件级情感、公司级情感和事件-公司级情感。主指标可使用 FinBERT 或经人工校验的金融情感模型；大语言模型情感打分可作为补充或稳健性分析。情感均值衡量报道方向，情感标准差衡量媒体分歧，报道数量衡量媒体覆盖强度。

媒体情感的语料窗口应与 CAR 窗口严格对齐，但可保留扩展窗口用于稳健性分析。文本检索关键词应同时覆盖模型名、真实发布者名和相关公司名。对于非上市发布者事件，新闻可能主要讨论模型发布者而非美股暴露公司；此时事件级情感和 creator-level 情感更适合解释整体冲击，公司级情感则反映市场是否把冲击映射到某家上市公司。

### （六）控制变量

公司层控制变量 \(Z_j\) 包括规模、市值、账面市值比、动量、波动率、行业分类、研发强度、AI 业务暴露、历史 beta 和事件前 CAR。事件层控制变量包括发布者国家、事件年份/季度、模型模态、是否模型家族、媒体报道数量和是否存在低置信匹配。固定效应包括行业固定效应和事件时间固定效应。

## 五、实证设计

### （一）事件研究法

本文使用市场模型估计正常收益率。估计窗口为事件日前 \([-200,-10]\) 个交易日，主事件窗口为 \([-1,+1]\)。市场模型为：

\[
R_{j,t}=\alpha_j+\beta_j R_{m,t}+\epsilon_{j,t}
\]

异常收益率为：

\[
AR_{ij,t}=R_{j,t}-\hat{\alpha}_j-\hat{\beta}_jR_{m,t}
\]

累计异常收益率为：

\[
CAR_{ij}[T_1,T_2]=\sum_{t=T_1}^{T_2}AR_{ij,t}
\]

稳健性检验采用 Fama-French 三因子或五因子模型重新估计正常收益率。同步计算 \(CARpre_{ij}\)，即事件前 \([-10,-2]\) 窗口累计异常收益率，用于控制事件前趋势、信息泄露或预期反应。对事件窗口内存在重大混淆事件的事件-公司对进行剔除或单独标记。

### （二）事件-公司面板回归

基准模型为：

\[
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
\]

其中，\(i\) 表示模型发布事件，\(j\) 表示美股上市公司，\(X_i\) 为模型事件特征，\(Relationship_{ij}\) 为公司与模型事件的经济暴露关系，\(Z_j\) 为公司层面控制变量。标准误按事件或公司聚类，并在稳健性分析中使用双向聚类。

对非上市模型发布者，不构造 publisher CAR。对 OpenAI、Anthropic、xAI、中国模型发布者等事件，本文研究其对美股暴露公司的市场冲击，而不是把合作方或投资方错误地视为发布者。Tesla 不应默认作为 xAI 模型发布事件的发布者处理。

### （三）能力机制检验

能力机制检验在 LLM Capability Sample 中进行。核心解释变量包括 AA Intelligence Index、Coding Index、Math Index、MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME、价格、速度和 TTFT。可构造 frontier rank、capability percentile、price efficiency 和 speed-adjusted capability 等变量。

Media Model Capability Sample 单独估计，使用 media Elo、rank、ci95、appearances 和 category-level Elo。图像、视频、语音模型不进入 LLM Intelligence Index 回归。跨模态比较只使用 within-modality z-score 或 rank percentile。

能力机制检验将采用逐步模型。第一步只加入关系暴露变量，观察不同关系类型的平均反应。第二步加入能力和成本效率变量，检验技术特征是否解释事件间差异。第三步加入能力与关系类型交互项，检验同一技术特征是否对不同公司产生相反影响。第四步加入 ASVI 和媒体情感，区分技术特征本身的解释力与信息传播带来的放大效应。

### （四）关系暴露异质性检验

本文通过关系虚拟变量和交互项检验 H2 与 H3。例如，模型能力与 `strategic_partner`、`cloud_provider`、`compute_supplier` 的交互项预期为正；与 `direct_competitor` 的交互项可能为负；低成本高能力模型与 `application_exposed_firm` 的交互项可能为正，也可能因替代风险而为负。弱关联实体只用于扩展分析，不进入主回归或作为单独稳健性结果展示。

### （五）市场学习与时间演变检验

市场学习检验采用三种方法。第一，加入连续时间趋势 `trend_month_since_2022_11` 及其与 ASVI、媒体情感、能力指标和成本效率的交互项。第二，按阶段划分样本，例如 2022 年 11 月至 2023 年末作为早期关注阶段，2024 年以后作为商业验证和成本竞争阶段，比较系数差异。第三，使用滚动事件窗口估计 ASVI、能力和成本效率系数随时间的变化。

### （六）稳健性检验

稳健性检验包括：替换事件窗口为 \([-3,+3]\)、\([-5,+5]\)；替换市场模型为 Fama-French 三因子或五因子模型；剔除低置信匹配事件；剔除混淆事件；仅保留高媒体覆盖事件；仅保留高置信暴露关系；分别估计 LLM 与 media 子样本；使用不同 ASVI 口径；使用不同媒体情感模型；对连续变量进行 1% 和 99% 缩尾。

本文不把 PSM-DID 或复杂 IV 作为主识别策略。模型发布事件不是随机发生，ASVI 和媒体情感也可能与 CAR 同时反应，因此本文更适合定位为短期事件研究、机制解释和异质性分析。若未来能够找到清晰工具变量，可作为扩展分析，而不是当前主识别设计。

## 六、预期结果与解释路径

### （一）主效应

若 H1 成立，重大模型发布事件将在美股 AI 相关公司中引发显著平均 CAR，但全样本方向可能不稳定。原因是同一事件会同时利好部分公司并压制另一部分公司。主效应的解释重点不在于平均 CAR 是否统一为正，而在于事件是否引发超出正常波动的重新定价。

### （二）关系异质性

若 H2 成立，正向商业暴露关系公司更可能获得正向 CAR，直接竞争者和替代风险公司更可能获得负向或不显著 CAR。OpenAI 事件中，Microsoft 应被解释为合作、投资、云服务和分发暴露，而非发布者暴露；xAI 事件中，Tesla 若无明确产品集成证据，应主要作为弱关联实体处理。

### （三）能力与成本效率机制

若 H3 成立，能力更强、成本更低、速度更快、推理能力更强或开源影响更大的模型发布，会带来更强资本市场反应。但方向取决于关系类型。低成本高能力模型可能利好应用层和云需求，也可能压低模型服务价格预期；开源模型可能扩张生态和算力需求，也可能削弱闭源厂商壁垒。

### （四）关注度、媒体情感与市场学习

若 H4 成立，ASVI 和媒体情感能够解释同类模型事件下市场反应差异。若 H5 成立，早期事件中 ASVI 和媒体情感的解释力更强，后期事件中能力、价格、速度和商业化关系的解释力增强。这将支持资本市场从 AI 叙事定价向模型基本面和商业化定价转变的解释路径。

## 七、潜在挑战与应对

### （一）事件样本规模

严格限定模型发布主样本会减少事件数量。本文将通过事件-公司面板提高观测数，但不会以牺牲事件定义为代价扩大样本。产品事件和研究系统可作为附录样本保留，帮助说明筛选边界。

### （二）非上市模型发布者的金融映射

许多关键发布者不是美股上市公司。应对方法是构建美股暴露公司池，明确每家公司与事件的关系和证据来源。对于关系不清或证据较弱的公司，标记为 `weak_related_entity`，不进入主结果或仅用于扩展分析。

### （三）不同模态能力不可比

LLM 的 Intelligence Index 与图像、视频、语音 Elo 不是同一量纲。本文将分样本处理，并使用 within-modality z-score 或 rank percentile 进行补充统一化。严禁把不同模态原始分数直接合并。

### （四）AA 指标的时间口径

AA 能力指标可能是 ex post standardized capability，不完全等于事件日市场可得信息。本文将明确其口径：AA 指标用于事后标准化衡量模型能力，不等同于事件日投资者完全掌握的信息。稳健性检验可使用人工 SOTA 标记、媒体报道强度或事件时点可得 benchmark 作为替代指标。

### （五）混淆事件与事件日模糊

部分模型发布存在预告、技术报告、API 开放和媒体报道多日分布。本文将记录官方发布日、首次公开日和主流媒体首次报道日，并做替代事件日稳健性检验。事件窗口内如出现财报、并购、监管、宏观冲击或公司重大公告，应剔除或标记。

## 八、研究计划

第一阶段，完成事件样本重构。基于现有 `events_match_diagnosed.csv` 和 `Event_data.csv`，人工确认 Main Model Release Sample、LLM Capability Sample、Media Model Capability Sample 和 Excluded Product/Event Sample。重点修正 true_model_creator、refined_event_type、产品事件排除、研究系统标记和 AA 匹配置信度。

第二阶段，构建美股暴露公司池。为每个事件编码 publisher、parent_company、strategic_partner、major_investor、cloud_provider、distribution_partner、direct_competitor、compute_supplier、application_exposed_firm、ai_basket_member 和 weak_related_entity，并记录 exposure_source 与 manual_exposure_confidence。

第三阶段，计算 CAR 与控制变量。收集美股日度收益率、市场因子、财务指标和行业分类，按 \([-200,-10]\) 估计窗口计算市场模型 CAR，并进行 Fama-French 稳健性计算。

第四阶段，构造 ASVI 与媒体情感。按事件-公司、模型、发布者和事件多口径构造关注度；收集事件窗口媒体报道并计算情感均值、分歧和报道数量。

第五阶段，完成实证检验。先报告事件研究结果，再估计事件-公司面板模型、关系异质性、能力机制、ASVI/情感机制和时间演变检验。

## 九、预期贡献

本文将 AI 模型发布事件研究从“发布者自身股价是否上涨”推进到“技术冲击如何通过经济暴露关系传导到美股 AI 相关公司”。这种设计更符合当前 AI 产业结构：最关键的模型发布者往往不是上市公司，而上市公司的价值暴露来自投资、合作、云服务、算力供应、分发、竞争和应用替代。

本文还将模型能力数据引入事件研究。通过 Artificial Analysis 官方 API 构建的 LLM 和 media master database，研究能够区分模型能力、成本效率、速度、模态、开源和媒体模型 Elo/rank 等特征，避免只依赖粗糙的“是否 SOTA”人工标签。

最后，本文将关注度、媒体情感和市场学习纳入同一框架。该设计能够解释为什么同样是重大模型发布，有些事件带来强烈资本市场反应，有些事件反应有限；也能检验资本市场是否从早期 AI 叙事驱动逐步转向能力、成本效率和商业化潜力驱动。
