# Proposal Rewrite Notes

Generated: 2026-04-26

## 备份

- 原 `proposal.md` 已备份为 `proposal_old.md`。
- 新版 `proposal.md` 已按“重大 AI 模型发布事件对美股 AI 相关公司资本市场反应”的研究设计重写。

## 相比旧 proposal 删除了什么

- 删除了“发布主体须为美股七大 AI 巨头”的样本纳入规则。
- 删除了把 LLM 发布方、上游、下游、竞对粗略混在一起的产业链标签设计。
- 删除了将“发布者自身股价上涨”作为 H1 中心的写法。
- 删除了把产品发布、功能集成、搜索/办公/浏览器/agent 产品与模型发布混合进入主样本的设计。
- 删除了过强的 PSM-DID、工具变量和因果识别承诺，改为短期事件研究、机制解释和异质性分析。

## 保留了什么

- 保留事件研究法、市场模型、Fama-French 三因子或五因子稳健性。
- 保留主事件窗口 `[-1,+1]`，稳健窗口 `[-3,+3]`、`[-5,+5]`，估计窗口 `[-200,-10]`。
- 保留 `CARpre`、混淆事件排除、媒体情感、ASVI 和市场学习/时间演变分析。
- 保留事件-公司面板框架，但重新定义了事件、公司和关系变量。

## 新增了什么

- 新增“事件层”和“公司层”双层研究对象定义。
- 新增 `true_model_creator`、`creator_country`、`creator_listed_status`、`model_modality`、`model_family_or_single_model`、`open_weight`、`frontier_or_not` 等事件层字段。
- 新增美股暴露公司池字段：`relationship_to_event`、`exposure_strength`、`exposure_source`、`manual_exposure_confidence`。
- 新增完整关系类型：`publisher`、`parent_company`、`strategic_partner`、`major_investor`、`cloud_provider`、`distribution_partner`、`direct_competitor`、`compute_supplier`、`application_exposed_firm`、`ai_basket_member`、`weak_related_entity`。
- 新增四层样本结构：Main Model Release Sample、LLM Capability Sample、Media Model Capability Sample、Excluded Product/Event Sample。
- 新增对 Artificial Analysis master database 的说明，包括 LLM 指标、media 指标和 category-level Elo。
- 新增不同模态能力变量不可直接合并的处理原则。

## 为什么不再把 OpenAI 直接等同于 Microsoft

OpenAI 是真实模型发布者。Microsoft 可能是 OpenAI 模型事件中的战略伙伴、主要投资者、Azure 云服务方和分发方，但不是模型发布者本身。若把 OpenAI 事件记为 Microsoft 发布，会混淆技术来源和资本市场暴露关系，导致 `publisher` 变量含义错误。

## 为什么不再把 xAI 直接等同于 Tesla

xAI 是独立模型发布者。Tesla 与 xAI 的关系不能自动等同于发布者、母公司或直接受益方。除非某个 xAI 模型明确进入 Tesla 产品或服务，否则 Tesla 最多应标为 `weak_related_entity`，并且只能进入扩展分析。

## 为什么产品事件不再进入主样本

本文研究的是模型发布对资本市场的冲击。产品发布、功能集成、搜索产品、办公套件、浏览器和 agent 产品往往反映分发或应用层包装，而不是基础模型能力边界变化。把 Apple Intelligence、AI Overviews、ChatGPT Atlas、ChatGPT Agent、Operator、Jules、NotebookLM、SearchGPT 等放入主样本，会使模型能力变量和事件冲击来源失真。

## 为什么不同模态模型不能直接共用同一个原始能力分数

LLM 的 Artificial Analysis Intelligence Index、Coding Index、Math Index 与图像、视频、语音模型的 Elo/rank 不是同一量纲，也不是同一任务空间。直接合并为一个原始 `Capability` 变量会制造伪比较。新版 proposal 要求采用分样本回归、modality-specific capability、within-modality z-score 或 within-modality rank percentile。

## 下一步需要人工确认的数据表

- `data/events_match_diagnosed.csv`：确认哪些事件进入 Main Model Release Sample，哪些进入 Excluded Product/Event Sample。
- `Event_data.csv`：同步更新最终人工匹配结果、产品重分类和 AA 指标填充结果。
- 待建 `data/processed/model_release_main_sample.csv`：主模型发布事件表。
- 待建 `data/processed/event_company_exposure.csv`：事件-公司经济暴露关系表。
- 待建 `data/processed/excluded_product_event_sample.csv`：产品、agent、研究系统和其他排除事件附录表。
- 待建 `data/processed/manual_creator_country.csv`：模型发布者国家和上市状态人工确认表。
- 待建 `data/processed/manual_exposure_sources.csv`：公司暴露关系来源和人工置信度表。
