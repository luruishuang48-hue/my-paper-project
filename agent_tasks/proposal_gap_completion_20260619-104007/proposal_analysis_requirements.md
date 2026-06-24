# proposal.md 与 research proposal.md 的研究承诺清单

本清单以 `proposal.md` 为主，`research proposal.md` 作为早期方案补充。若两者冲突，以新版 `proposal.md` 为准。新版方案已把研究对象从“美股七大 AI 巨头发布的 LLM 产品或模型”改为“重大 AI 模型发布事件对美股暴露公司的影响”，所以旧版中只围绕发布方自身的设计，应降级为历史方案或附录说明。

“是否需要外部新数据”指完成该项分析是否需要在现有项目文件之外继续取得数据。若现有项目可能已有部分数据，但仍需补齐新闻、搜索、金融因子或人工核验，则标为“部分需要”。

## 一、研究问题承诺

| 编号 | 承诺内容 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| RQ1 | 检验重大 AI 模型发布事件是否使美股 AI 相关上市公司在短窗口内产生显著 CAR | `proposal.md` | 否，若现有 CAR 已完整计算 | 需要覆盖全样本、关系分组和不同窗口 |
| RQ2 | 检验资本市场反应是否沿经济暴露关系传导，例如发布者、母公司、战略伙伴、主要投资者、云服务方、分发方、直接竞争者、算力供应商和应用层暴露公司 | `proposal.md` | 部分需要 | 若关系证据、置信度或弱关联标记不完整，需要继续人工核验 |
| RQ3 | 检验模型技术特征是否解释 CAR 强度和方向，特征包括能力水平、能力跃迁、开源程度、模态、推理能力、成本效率和速度 | `proposal.md` | 部分需要 | AA 指标若已在本地可用，则主要缺口是事件匹配、能力跃迁和时点口径 |
| RQ4 | 检验 ASVI 与媒体情感是否放大或调节模型发布冲击 | `proposal.md` | 是 | 需要 Google Trends 或同类搜索数据，以及事件窗口新闻文本和情感打分 |
| RQ5 | 检验市场定价逻辑是否从早期 attention-driven / hype-driven 转向后期 capability-driven / cost-efficiency-driven / commercialization-driven | `proposal.md` | 部分需要 | 需要时间交互、分阶段回归或滚动窗口。若 ASVI 和情感缺失，则无法完整执行 |
| RQ6 | 检验不同事件窗口下市场反应的时效性、持续性和反转效应 | `research proposal.md` | 否，若日度收益率和 CAR 窗口已完整 | 新版保留稳健窗口，但旧版还承诺长窗口反转分析 |
| RQ7 | 区分“技术本身的价值”与“媒体的信息传播”对股价反应的作用 | 两个提案 | 是 | 需要技术特征与媒体情感同时进入模型 |

## 二、研究假设承诺

| 编号 | 假设内容 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| H1 | 重大 AI 模型发布事件会使美股 AI 相关公司在事件窗口内产生显著 CAR，但方向取决于经济暴露关系 | `proposal.md` | 否或部分需要 | 取决于现有事件-公司面板和 CAR 是否已完整 |
| H2 | 正向商业暴露公司更可能获得正向 CAR，直接竞争者或替代风险较高的应用公司可能获得负向或不显著 CAR | `proposal.md` | 部分需要 | 依赖关系编码和证据强度 |
| H3 | 能力更强、能力跃迁更大、开源程度更高、成本效率更高、推理能力更强的模型会引起更显著反应，但方向随关系类型变化 | `proposal.md` | 部分需要 | 需要能力指标、跃迁变量、成本效率和交互项 |
| H4 | 事件窗口 ASVI 和媒体情感会影响 CAR | `proposal.md` | 是 | 搜索数据和新闻情感是关键新增数据 |
| H5 | 随着生成式 AI 进入商业化和成本竞争阶段，市场反应从关注度和叙事驱动转向能力、成本效率和商业化驱动 | `proposal.md` | 部分需要 | 需要时间变量、阶段划分和机制变量 |
| H2a 旧版 | 正面媒体情感提升 CAR，负面情感抑制 CAR，且负面情感边际影响更强 | `research proposal.md` | 是 | 新版没有明确保留“负面更强”的非对称承诺，但可作为机制扩展 |
| H2b 旧版 | 媒体情感分歧度削弱正向 CAR 的显著性，并放大负向 CAR | `research proposal.md` | 是 | 需要新闻层面情感标准差 |
| H2c 旧版 | 媒体情感影响在产业链角色之间存在异质性 | `research proposal.md` | 是 | 可并入新版关系异质性框架 |

## 三、数据承诺

| 编号 | 数据或字段承诺 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| D1 | 候选事件池来自 AI Timeline、AA leaderboard、官方公告、技术博客、模型卡、technical report、财经和科技媒体，以及权威 benchmark / leaderboard | `proposal.md` | 部分需要 | 若候选事件已完成，仍需保留可复核来源链 |
| D2 | 主样本只纳入重大 AI 模型发布事件，排除纯产品、功能集成、浏览器、搜索、办公套件、agent 产品和多数 research system | `proposal.md` | 否 | 主要是样本筛选和人工复核 |
| D3 | 每个事件记录 true_model_creator、model_name、release_date、model_modality、open_weight、frontier_or_not、source_of_release_date 等字段 | `proposal.md` | 部分需要 | 发布日和官方来源可能仍需外部核验 |
| D4 | 构造四层事件样本，分别为 Main Model Release Sample、LLM Capability Sample、Media Model Capability Sample、Excluded Product/Event Sample | `proposal.md` | 否或部分需要 | 取决于现有事件分类和 AA 匹配状态 |
| D5 | 为每个事件构造美股暴露公司池，单位为事件-公司对 | `proposal.md` | 部分需要 | 暴露证据可能需要公告、媒体、合作协议和供应链资料 |
| D6 | 关系字段至少包括 publisher、parent_company、strategic_partner、major_investor、cloud_provider、distribution_partner、direct_competitor、compute_supplier、application_exposed_firm、ai_basket_member、weak_related_entity | `proposal.md` | 部分需要 | 需要 evidence source 和 confidence |
| D7 | 关系强度字段包括 exposure_strength、exposure_source、manual_exposure_confidence | `proposal.md` | 部分需要 | 证据不足时需人工核验 |
| D8 | AA LLM 数据包含 Intelligence Index、Coding Index、Math Index、MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME、token price、output speed、latency / TTFT | `proposal.md` | 否或部分需要 | 本地已有 AA master database，但低置信匹配需人工处理 |
| D9 | AA media 数据包含 media task、Elo、rank、confidence interval、appearances、release date raw、category-level Elo 等 | `proposal.md` | 否或部分需要 | 需要保证图像、视频、语音事件进入 media 子样本 |
| D10 | 股价、市场收益率、市值、成交量和行业分类用于 CAR、控制变量和描述统计 | `proposal.md` | 部分需要 | 若 Yahoo Finance 或 CRSP 数据已完整，则无需新增 |
| D11 | 财务数据包括总资产、账面市值比、盈利能力、研发强度、杠杆、动量和波动率 | `proposal.md` | 是或部分需要 | Compustat、年报或等价数据库可能仍需补齐 |
| D12 | 搜索数据用于构造 firm-level ASVI、model-level search intensity、creator-level search intensity 和 event-level attention index | `proposal.md` | 是 | 这是主要新增数据 |
| D13 | 媒体数据来自 Factiva、Reuters、Bloomberg、WSJ、CNBC、TechCrunch、The Verge、官方博客和主流科技媒体 | `proposal.md` | 是 | 需要新闻正文、报道数量和窗口对齐 |
| D14 | 旧版股票池承诺使用 Artificial Intelligence & Technology ETF 成分股，并按 GICS 与产业链环节分类 | `research proposal.md` | 部分需要 | 新版转为事件暴露公司池，ETF 股票池可作为 AI basket 扩展 |
| D15 | 旧版承诺 5000+ 条事件-公司级观测和 106 个字段 | `research proposal.md` | 否或部分需要 | 新版不再依赖该口径，若继续引用需核对当前样本规模 |

## 四、核心模型承诺

| 编号 | 模型或估计承诺 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| M1 | 使用市场模型估计正常收益率，估计窗口为事件日前 [-200,-10] 个交易日 | 两个提案 | 否，若收益率数据已完整 | 需要保证估计窗口有效交易日充足 |
| M2 | 主 CAR 窗口为 [-1,+1] | 两个提案 | 否 | 新版主窗口明确 |
| M3 | 稳健窗口包括 [-3,+3] 和 [-5,+5] | `proposal.md` | 否 | 旧版还提到 [-2,+2]、[-10,+10]、[-20,+20] |
| M4 | 若官方发布日为非交易日，则顺延至下一个交易日，并使用替代事件日做稳健性检验 | 两个提案 | 部分需要 | 需要官方发布日、首次公开日和媒体首次报道日 |
| M5 | 计算事件前 [-10,-2] 窗口 CARpre，用于控制事件前趋势、信息泄露或预期反应 | 两个提案 | 否 | 需要纳入面板回归 |
| M6 | 事件-公司面板回归以 CAR 为被解释变量，加入事件特征、关系变量、交互项、公司控制变量、行业固定效应和时间固定效应 | `proposal.md` | 部分需要 | 取决于控制变量和固定效应字段完整性 |
| M7 | 标准误按事件或公司聚类，并在稳健性中使用双向聚类 | `proposal.md` | 否 | 需要在回归脚本中落实 |
| M8 | Fama-French 三因子或五因子模型用于重新估计正常收益率 | `proposal.md` | 是或部分需要 | 需要 Kenneth French 因子数据，若本地已有则无需新增 |
| M9 | 能力机制采用逐步模型，先加入关系变量，再加入能力和成本效率，再加入能力与关系交互，最后加入 ASVI 和媒体情感 | `proposal.md` | 部分需要 | 后两步依赖新增 ASVI 和情感 |
| M10 | Media Model Capability Sample 单独估计，不把 media Elo 与 LLM Intelligence Index 混合 | `proposal.md` | 否或部分需要 | 需要分样本脚本 |
| M11 | 跨模态比较仅使用 within-modality z-score 或 rank percentile | `proposal.md` | 否 | 需要避免直接合并原始能力分数 |
| M12 | 旧版承诺双向固定效应模型含 Sentiment_Mean、Sentiment_Std、CARpre、事件特征、企业特征和 Relationship | `research proposal.md` | 是或部分需要 | 可作为新版机制模型的子模型 |
| M13 | 旧版提到 PSM-DID 处理自选择偏差 | `research proposal.md` | 是 | 新版明确不把 PSM-DID 作为主识别策略，应只作为可选扩展或不做 |
| M14 | 旧版承诺 VIF 检验，多重共线变量剔除或中心化 | `research proposal.md` | 否 | 可作为回归诊断 |

## 五、异质性分析承诺

| 编号 | 异质性维度 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| HET1 | 经济暴露关系异质性 | `proposal.md` | 部分需要 | 核心异质性，必须覆盖正向暴露、竞争、应用替代、弱关联等 |
| HET2 | 关系强度异质性，高、中、低或 0–3 分 | `proposal.md` | 部分需要 | 依赖 exposure_strength 和证据置信度 |
| HET3 | 模型能力与关系类型交互 | `proposal.md` | 部分需要 | 检验能力对伙伴、云服务、算力供应商和竞争者的方向差异 |
| HET4 | 低成本高能力模型与应用层暴露公司交互 | `proposal.md` | 部分需要 | 方向可能为正也可能为负 |
| HET5 | 开源或 open-weight 模型的关系异质性 | `proposal.md` | 否或部分需要 | 需要 open_weight 编码准确 |
| HET6 | 模态异质性，LLM、图像、视频、语音分样本或分指标处理 | `proposal.md` | 否或部分需要 | 不能直接混用原始能力分数 |
| HET7 | 推理、代码、数学、多模态等能力类型异质性 | `proposal.md` | 否或部分需要 | 依赖 AA LLM 指标匹配 |
| HET8 | 发布者国家、上市状态、模型家族与单模型发布 | `proposal.md` | 部分需要 | 需要事件元数据完整 |
| HET9 | 时间阶段异质性，2022 年 11 月至 2023 年末为早期关注阶段，2024 年以后为商业验证和成本竞争阶段 | `proposal.md` | 部分需要 | 需要阶段划分和交互项 |
| HET10 | 旧版产业链角色异质性，发布方、上游算力、下游应用、竞对 | `research proposal.md` | 部分需要 | 可映射到新版细分关系，但不应覆盖新版编码 |
| HET11 | 旧版事件特征分组，是否开源、是否刷新 SOTA、是否多模态 | `research proposal.md` | 部分需要 | SOTA 可用 AA frontier rank 或人工标记替代 |
| HET12 | 旧版企业特征分组，规模、账面市值比、前期波动率、行业板块 | `research proposal.md` | 是或部分需要 | 需要财务和行业数据 |

## 六、机制分析承诺

| 编号 | 机制 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| MECH1 | 技术竞争格局冲击。模型发布改变市场对前沿能力、竞争位置、云服务、算力需求和应用替代风险的预期 | `proposal.md` | 部分需要 | 可通过能力变量、关系变量和交互项实现 |
| MECH2 | 经济暴露关系传导。正向商业暴露、竞争暴露、应用替代和弱关联应分开估计 | `proposal.md` | 部分需要 | 这是论文主机制 |
| MECH3 | 能力机制。绝对能力、能力跃迁、frontier rank、同模态 percentile 解释事件间差异 | `proposal.md` | 部分需要 | 能力跃迁可能需要补算 |
| MECH4 | 成本效率机制。price efficiency、speed-adjusted capability、TTFT、低价高能力 dummy 解释商业化和利润率预期 | `proposal.md` | 否或部分需要 | 取决于 AA 价格和速度字段完整性 |
| MECH5 | 开源扩散机制。开源模型可能扩张生态和算力需求，也可能削弱闭源厂商溢价 | `proposal.md` | 部分需要 | 需要 open-weight 编码及关系交互 |
| MECH6 | 关注度机制。ASVI 衡量市场是否注意到事件 | `proposal.md` | 是 | 需要搜索数据 |
| MECH7 | 媒体情感机制。情感均值衡量报道方向，情感标准差衡量媒体分歧，报道数量衡量覆盖强度 | 两个提案 | 是 | 需要新闻数据和情感模型 |
| MECH8 | 市场学习机制。用时间趋势、分阶段回归和滚动事件窗口估计机制权重变化 | `proposal.md` | 部分需要 | 依赖机制变量的完整度 |
| MECH9 | 旧版技术特征 → 媒体情感 → 股价反应链条 | `research proposal.md` | 是 | 若要严格检验中介路径，需要额外建模，不只是把变量同时放入回归 |
| MECH10 | 旧版媒体情感非对称效应和分歧放大作用 | `research proposal.md` | 是 | 新版未强承诺，但可作为情感机制扩展 |

## 七、稳健性与诊断承诺

| 编号 | 稳健性或诊断内容 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| ROB1 | 替换事件窗口为 [-3,+3]、[-5,+5] | `proposal.md` | 否 | 旧版另含 [-2,+2] |
| ROB2 | 使用 Fama-French 三因子或五因子模型替代市场模型 | `proposal.md` | 是或部分需要 | 需要因子数据 |
| ROB3 | 剔除低置信匹配事件 | `proposal.md` | 否 | 需要 match_score 与 match_method |
| ROB4 | 剔除混淆事件，或对事件-公司对进行标记 | `proposal.md` | 部分需要 | 混淆事件搜索可能需外部公告和新闻 |
| ROB5 | 仅保留高媒体覆盖事件 | `proposal.md` | 是 | 需要媒体覆盖数量 |
| ROB6 | 仅保留高置信暴露关系 | `proposal.md` | 部分需要 | 依赖人工关系置信度 |
| ROB7 | 分别估计 LLM 与 media 子样本 | `proposal.md` | 否或部分需要 | 需要样本层级标记 |
| ROB8 | 使用不同 ASVI 口径 | `proposal.md` | 是 | firm、model、creator、event 多口径 |
| ROB9 | 使用不同媒体情感模型 | `proposal.md` | 是 | FinBERT、LLM 情感打分、人工校验或传统方法 |
| ROB10 | 连续变量进行 1% 和 99% 缩尾 | 两个提案 | 否 | 回归前处理即可 |
| ROB11 | 替代事件日稳健性，使用官方发布日、首次公开日和主流媒体首次报道日 | `proposal.md` | 部分需要 | 需要多口径事件日 |
| ROB12 | AA 指标的 ex post 口径稳健性，使用人工 SOTA 标记、媒体报道强度或事件时点可得 benchmark 作为替代 | `proposal.md` | 部分需要 | 事件时点 benchmark 可能需外部核验 |
| ROB13 | 参数 t 检验、BMP 检验、Bootstrap 聚类标准误 | `research proposal.md` | 否 | 若要完整复现旧版事件研究承诺，应补充 |
| ROB14 | VIF 检验 | `research proposal.md` | 否 | 用于多重共线性诊断 |
| ROB15 | PSM 检验或 PSM-DID | `research proposal.md` | 是 | 新版不主张作为主识别，除非主代理决定作为附录 |
| ROB16 | 人工抽检约 100 条新闻，比较两名研究者标注与 FinBERT 的一致性 | `research proposal.md` | 是 | 需要新闻样本和人工标注 |

## 八、图表与叙述承诺

| 编号 | 图表或叙述内容 | 主要来源 | 是否需要外部新数据 | 备注 |
|---|---|---|---|---|
| FIG1 | 样本筛选流程图，展示候选事件池、主样本、LLM 能力样本、media 能力样本和排除样本 | `proposal.md` | 否 | 需要样本分类统计 |
| FIG2 | 描述性统计表，含关键变量 N、均值、标准差、最小值、最大值 | `econ-write`规范和旧版结果承诺 | 否或部分需要 | 取决于控制变量完整性 |
| FIG3 | 事件层和事件-公司层样本构成表，按发布者、国家、模态、年份、关系类型统计 | `proposal.md` | 否或部分需要 | 需要事件元数据和关系编码 |
| FIG4 | 主事件研究结果表，全样本和关系分组 CAR 显著性 | 两个提案 | 否 | 主结果必需 |
| FIG5 | 多窗口 CAR 对比图或表，展示 [-1,+1]、[-3,+3]、[-5,+5]，可补充 [-2,+2] | 两个提案 | 否 | 也可加入长期反转窗口作为附录 |
| FIG6 | 事件-公司面板基准回归表 | `proposal.md` | 部分需要 | 需要控制变量完整 |
| FIG7 | 关系异质性回归表或系数图 | `proposal.md` | 部分需要 | 建议用系数图展示多关系类型 |
| FIG8 | 能力机制逐步回归表 | `proposal.md` | 部分需要 | 需要 AA 能力和成本效率变量 |
| FIG9 | 能力 × 关系类型交互项系数图 | `proposal.md` | 部分需要 | 直观展示同一能力冲击的方向差异 |
| FIG10 | ASVI 与媒体情感机制表 | `proposal.md` | 是 | 依赖新增数据 |
| FIG11 | 市场学习图，展示时间趋势、阶段系数或滚动窗口系数变化 | `proposal.md` | 部分需要 | 依赖时间交互和机制变量 |
| FIG12 | LLM 与 media 子样本分别估计的能力机制表 | `proposal.md` | 否或部分需要 | 需要分样本处理 |
| FIG13 | 数据质量和匹配质量表，展示 unmatched、matched_low_confidence、matched_confirmed、manual_review_required | `proposal.md` | 否 | 现有报告已提到这些状态 |
| FIG14 | 典型关系案例叙述，OpenAI-Microsoft、Anthropic-Amazon/Google、xAI-Tesla、DeepSeek-NVIDIA/云服务商、中国模型事件与美国竞争者 | `proposal.md` | 部分需要 | 需要证据来源，避免按股价结果反推关系 |
| FIG15 | 旧版产业链角色 CAR 对比与可视化 | `research proposal.md` | 否或部分需要 | 可作为新版关系图的粗分类版本 |
| FIG16 | 旧版相关性分析和 VIF 诊断表 | `research proposal.md` | 否 | 可放附录 |
| FIG17 | 旧版新闻情感人工验证表 | `research proposal.md` | 是 | 若没有人工标注，不应宣称已完成 |

## 九、需要特别避免的错配

1. 不应把 OpenAI 模型发布等同于 Microsoft 发布。Microsoft 在这类事件中应编码为战略伙伴、主要投资者、云服务方或分发方。
2. 不应把 Anthropic 模型发布等同于 Amazon 或 Google 发布。二者更适合编码为投资者、云服务合作方或战略伙伴。
3. 不应把 xAI 模型发布默认映射为 Tesla 发布。没有明确产品集成证据时，Tesla 至多属于弱关联实体。
4. 不应把产品发布、搜索产品、浏览器、办公套件集成和 agent 产品混入主模型发布样本。
5. 不应把 LLM Intelligence Index 与图像、视频、语音 Elo 原始值直接合成统一 Capability。
6. 不应把 AA 的事后标准化能力指标解释为事件日投资者已经完全掌握的信息。
7. 不应把 ASVI 和媒体情感作为强因果识别变量。新版提案把它们定位为信息传播和机制解释变量。
8. 不应把 PSM-DID 当作当前主识别设计。新版提案明确采用事件研究、机制解释和异质性分析。

## 十、按外部数据需求划分的待做分析

### 现有数据大概率足以推进的分析

1. 主样本和排除样本的筛选透明度表。
2. 主窗口与稳健窗口 CAR 的事件研究结果。
3. 关系暴露异质性回归，前提是现有关系编码和 CAR 已可用。
4. AA 能力机制中 LLM 子样本和 media 子样本的分开估计，前提是匹配状态足够可靠。
5. 低置信匹配剔除、高置信关系保留、LLM / media 分样本、缩尾等稳健性检验。
6. 时间趋势、阶段分组和滚动窗口的初步版本，前提是只使用现有能力和关系变量。

### 需要补充外部数据后才能完整兑现的分析

1. firm-level、model-level、creator-level 和 event-level ASVI。
2. 新闻报道正文、报道数量、媒体情感均值和情感分歧。
3. FinBERT 或其他情感模型的新闻级打分。
4. 人工抽检约 100 条新闻并计算一致性。
5. Fama-French 三因子或五因子 CAR，若本地没有 Kenneth French 因子数据。
6. 混淆事件系统搜索，尤其是财报、并购、监管处罚、重大诉讼、高管变动和融资分红。
7. 财务控制变量补齐，包括总资产、账面市值比、盈利能力、研发强度、杠杆、动量和波动率。
8. 事件时点可得 benchmark、人工 SOTA 标记或媒体报道强度，用于缓解 AA 指标事后口径问题。

## 十一、对子任务执行的结论

`proposal.md` 的核心承诺已经形成一个相对完整的实证框架。最重要的未完成方向通常不是再做一个平均 CAR，而是补齐三类分析。第一类是关系暴露的细分异质性，尤其是能力变量与关系类型的交互。第二类是能力、成本效率、开源和模态机制，且必须分 LLM 与 media 子样本处理。第三类是 ASVI、媒体情感和市场学习机制，这部分需要最多外部新增数据。

旧版 `research proposal.md` 中仍可保留的承诺主要是媒体情感的均值、分歧、非对称效应，事件窗口持续性和反转，以及 VIF、BMP、Bootstrap、人工情感验证等诊断。旧版“七大 AI 巨头发布方”样本口径与新版研究设计冲突，不宜再作为主样本承诺。
