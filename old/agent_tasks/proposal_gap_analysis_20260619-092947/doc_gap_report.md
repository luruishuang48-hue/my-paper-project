# Proposal 实证承诺缺口报告

生成时间 2026-06-19 09:30 CST  
任务性质为文档梳理。未运行新的回归或数据处理脚本。

## 一、读取范围

本报告以 `proposal.md` 为主准绳，并对照以下文件。

- `research proposal.md`
- `to_do_align_proposal.md`
- `result.md`
- `Tex/frl_draft_main_text.tex`
- `Tex/llm_pricing_regime_full.tex`
- `output/data/clean_event_firm_panel.csv` 的字段清单
- `output/tables/`、`output/figures/`、`data/source_reports/` 的文件清单

## 二、总体判断

当前项目已经完成一条较完整的工作稿主线。主线围绕 2024 到 2026 年 60 个重大模型发布事件、86 家 AI 相关上市公司、5161 条事件公司观测，重点检验 AA Intelligence Index、开源闭源、关系类型、媒体情感、年份或季度学习、行业和 Mag7 异质性。

但这条主线与 `proposal.md` 的完整承诺仍有明显差距。差距主要集中在六类。

1. 样本时间没有覆盖 proposal 所写的 2022 年 11 月以来早期事件。
2. ASVI 和多口径搜索关注度基本没有进入实证。
3. 成本效率、价格、速度、TTFT、能力跃迁、frontier gap 等机制变量尚未系统检验。
4. 媒体情感只做了情感均值和一个情感与智能指数交互，尚未完成情感分歧、非对称效应、媒体渠道和人工验证。
5. 事件筛选、混淆事件、低置信匹配、高置信暴露关系、产品事件附录等透明度材料没有完整进入正文。
6. 正文图形使用不足。项目已有若干图形文件，但 TeX 正文没有 `includegraphics`，FRL 版本也只保留三张表。

## 三、proposal 承诺项与当前完成度

### 1. 样本构建与事件筛选

**承诺内容**

- 建立候选事件池，来源包括 AI Timeline、AA leaderboard、官方公告、技术博客、主流媒体等。
- 从 `events_match_diagnosed.csv` 等候选事件中人工确认 Main Model Release Sample、LLM Capability Sample、Media Model Capability Sample 和 Excluded Product/Event Sample。
- 主样本只保留重大模型或模型家族发布，排除产品集成、agent 产品、搜索、办公套件、研究系统等。
- 对同日多个模型发布采用家族事件或代表变体规则。
- 记录 `true_model_creator`、发布日期来源、AA 匹配方式、低置信匹配、人工复核标记。
- 事件窗口内如有财报、并购、监管、诉讼等混淆事件，应剔除或标记事件公司对。

**已完成迹象**

- `result.md` 和 `Tex/llm_pricing_regime_full.tex` 已报告 60 个重大 AI 或 LLM 发布事件，时间为 2024 到 2026 年。
- 数据列包含 `true_model_creator`、`creator_country`、`creator_type`、`model_family`、`merged_model_count`、`merge_rule`、`representative_selection_rule`、`release_source_urls`、`release_date_confidence`、`llm_capability_sample_flag`、`media_capability_sample_flag`。
- `data/source_reports/` 中有 `final_60_event_sample_report.md`、`main_model_release_events_clean_report.md`、`match_failure_summary.md`、`low_confidence_matches.csv`、`manual_review_needed.csv` 等文件。

**部分完成或可能未完成**

- 正文只概括 S.A.F.E. 标准，尚未完整展示主样本、LLM 能力样本、Media 能力样本、排除样本的筛选流。
- `proposal.md` 要求保留 Excluded Product/Event Sample 并说明产品事件、agent 事件、研究系统的排除逻辑。当前正文没有看到对应附录表。
- 混淆事件检查没有形成主文或附录结果。`proposal.md` 要求事件公司对层面剔除或标记，当前结果只笼统说事件筛选遵循纯净原则。
- 早期事件缺口明显。`proposal.md` 和 `research proposal.md` 均强调 2022 年 11 月或 2022 到 2025 年样本，当前结果为 2024 到 2026 年 60 事件。`to_do_align_proposal.md` 已将“补充 2022 年 11 月到 2024 年 1 月早期 LLM 事件”列为 P0。

**建议补做**

- 输出一个样本筛选表，列出候选事件数、剔除产品事件数、研究系统数、日期不可靠事件数、混淆事件公司对数、最终主样本数。
- 补做或明确放弃 2022 年 11 月到 2024 年 1 月事件。若不补，应在正文中说明 FRL 版聚焦 2024 到 2026 年。
- 将 Excluded Product/Event Sample 放入附录。
- 对混淆事件至少做一个敏感性检验，剔除高风险事件公司对后重复核心闭源回归。

### 2. 描述统计

**承诺内容**

- 报告事件发布者、模型模态、开源状态、能力覆盖、关系类型、公司层控制变量、CAR 和媒体变量的描述统计。
- 报告变量均值、标准差、分位数和相关性分析。
- 报告多重共线性诊断。

**已完成迹象**

- `result.md` 报告 60 事件、5161 观测、发布者类型、模型模态、Tier、AA 指标覆盖、CAR 有效观测、8 类关系观测数。
- `Tex/llm_pricing_regime_full.tex` 的表 1 报告事件特征描述统计。
- 早期 `agent_tasks/analysis_report_20260521-133006/` 里存在 `table_correlations.csv`、`table_missingness.csv`、`table_relationship_counts.csv`、`table_creator_country_counts.csv` 等。

**部分完成或可能未完成**

- 主文未系统展示公司控制变量的均值、标准差、分位数。
- 主文未展示 CAR 的均值、分布、极端值。
- 主文未展示媒体情感均值和标准差以外的完整描述。
- 未看到 VIF 或多重共线性诊断进入结果。
- FRL 版本只保留三张核心表，描述统计更简化。

**建议补做**

- 增加一张附录描述统计表，覆盖 CAR、AA 指标、价格、速度、情感、公司控制变量、关系 dummy。
- 增加相关性矩阵和 VIF 表，至少放入附录。
- 报告样本缺失率，说明为什么主回归从 5161 条降到 3780 条。

### 3. 主效应和事件研究

**承诺内容**

- 用市场模型计算 CAR，估计窗口为事件日前约 `[-200,-10]`。
- 主窗口在新版 `proposal.md` 中为 `[-1,+1]`，稳健性包括 `[-3,+3]`、`[-5,+5]`。旧版 `research proposal.md` 也强调短期和中期影响。
- 同步计算事件前 `CARpre[-10,-2]` 控制预趋势。
- 检验重大模型发布是否引发显著 CAR。

**已完成迹象**

- 数据含 `mkt_car_pre`、`mkt_car_1`、`mkt_car_2`、`mkt_car_3`、`mkt_car_5`、`mkt_car_10`、`mkt_car_15`、`mkt_car_20` 以及 FF3 版本。
- `result.md` 完成多窗口规格曲线，报告 `car_1` 到 `car_20`。
- 当前主线把 `CAR[0,+20]` 作为主因变量，发现 AA Intelligence Index 在全样本和闭源样本中正向。
- `Tex/frl_draft_main_text.tex` 和 `Tex/llm_pricing_regime_full.tex` 都报告闭源样本长窗口能力定价。

**部分完成或可能未完成**

- 新版 `proposal.md` 的主窗口是 `[-1,+1]`，当前稿件的主窗口实际为 `[0,+20]`。这不是错误，但需要在论文中解释研究焦点已经从短窗口公告效应转向长窗口能力消化。
- 事件前 `CARpre` 在数据里存在，但主文主回归表没有明确列出它作为控制变量。`proposal.md` 明确要求用它控制预期反应和信息泄露。
- 尚未看到全样本平均 CAR 是否显著异于零的传统事件研究表。当前更多是能力指数解释 CAR 的回归。
- 尚未看到按关系角色的平均 CAR 对比表。`to_do_align_proposal.md` 也把 H1 的平均 CAR 对比列为 P0。

**建议补做**

- 增加一张传统事件研究表，按全样本和关系角色报告平均 CAR、t 检验、bootstrap CI、正收益比例。
- 在主回归中加入或说明 `CARpre`。若已在脚本中控制，应在表注中说明。
- 明确 `[0,+20]` 作为主窗口的依据，并把 `[-1,+1]` 或 `[0,+1]` 作为短窗口稳健性。

### 4. 关系暴露异质性

**承诺内容**

- 事件公司为核心单位，关系类型包括 `publisher`、`parent_company`、`strategic_partner`、`major_investor`、`cloud_provider`、`distribution_partner`、`direct_competitor`、`compute_supplier`、`application_exposed_firm`、`ai_basket_member`、`weak_related_entity`。
- 关系有方向和强度，应记录证据来源和人工置信度。
- 主回归使用关系虚拟变量和能力关系交互。
- H2 要求正向商业暴露公司获得正向 CAR，直接竞争者或替代风险公司为负或不显著。

**已完成迹象**

- 当前数据和结果使用 8 类关系，包括 owner、investor、cloud、business_upstream、real_upstream、business_downstream、real_downstream、competitor。
- `result.md` 和 `Tex/llm_pricing_regime_full.tex` 报告关系子样本规格曲线、关系类型异质性表、investor 交互、cloud 交互、owner 短期负向调节。
- 行业组异质性与 Mag7 分化也已完成。

**部分完成或可能未完成**

- 当前关系体系与 `proposal.md` 的关系体系不完全一致。`publisher`、`parent_company`、`strategic_partner`、`distribution_partner`、`compute_supplier`、`application_exposed_firm`、`ai_basket_member`、`weak_related_entity` 没有以同名口径进入主文。
- `exposure_strength`、`manual_exposure_confidence` 和证据来源没有作为主文变量或筛选条件出现。
- 弱关联实体是否从主样本剔除、Tesla-xAI 等典型案例如何处理，正文只做概念说明不足。
- 关系异质性主文目前更偏能力斜率差异，不足以直接回应 H1/H2 的“平均 CAR 排序”和“发布方、上游、下游、竞对”四分法。
- `real_downstream` 样本很小，结果不显著，仍需谨慎。

**建议补做**

- 建立 proposal 口径关系与当前 8 类关系的映射表。
- 增加平均 CAR 角色对比表，最少包含发布方、投资方、云服务、上游、下游、竞争者。
- 加入高置信关系样本稳健性，只保留有明确证据来源的事件公司对。
- 若数据允许，补充 `exposure_strength` 分组或连续评分回归。

### 5. 能力机制

**承诺内容**

- LLM 样本使用 AA Intelligence Index、Coding Index、Math Index、MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME。
- Media 样本单独使用 media Elo、rank、ci95、appearances、category-level Elo。
- 构造绝对能力、相对能力、能力跃迁、frontier rank、rank percentile、price efficiency、speed-adjusted capability。
- 检验能力与关系类型交互。
- 不把不同模态原始分数直接合并。

**已完成迹象**

- `result.md` 已对 AA Intelligence、Coding、Math、Media Elo 做规格曲线。
- 主回归以 AA Intelligence Index 为核心。
- `aa_media_elo` 的短窗口效应已报告。
- 数据列包含 MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME、价格、速度、TTFT、media Elo、rank、CI、appearances。
- 正文区分 LLM 指标和 media 指标，避免直接混合原始分数。

**部分完成或可能未完成**

- MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME 只作为字段存在，没有看到单独回归或替代指标表。
- 价格、速度、TTFT、成本效率、speed-adjusted capability 没有进入结果。
- 能力跃迁、同一 creator 前代比较、frontier gap、rank percentile 没有进入结果。
- Media Model Capability Sample 只做 `aa_media_elo`，没有 rank、ci95、appearances、category-level Elo 的完整补充分析。
- `proposal.md` 要求逐步机制模型。当前有部分逐步思想，但没有明确四步表，即关系变量、能力成本、能力关系交互、ASVI 和媒体情感。

**建议补做**

- 补一张能力机制扩展表，列包括 Intelligence、Coding、Math、MMLU-Pro、GPQA、LiveCodeBench、price、speed、TTFT、price efficiency。
- 构造 `capability_leap`、`frontier_gap` 或 `creator_best_to_date` 中至少一种变量。
- 对 media 样本单独报告 Elo、rank、appearances，并说明其经济含义。
- 形成逐步机制表，便于直接对应 proposal。

### 6. 开源闭源和可占有性

**承诺内容**

- `proposal.md` 把开源作为能力机制的一部分，讨论高质量开源对生态、算力需求、闭源溢价和应用层的不同影响。

**已完成迹象**

- 这是当前项目完成度最高的部分。
- `result.md`、FRL 稿和完整中文稿都报告闭源能力定价、开源负向或斜率衰减、`intel_c × open_weight` 交互。
- FRL 版已经把可占有性作为核心理论主线。

**部分完成或可能未完成**

- `proposal.md` 进一步要求开源与关系类型方向联动。例如高质量开源模型可能利好生态、云部署和算力需求，但压缩闭源厂商溢价。当前尚未看到 `intelligence × relationship × open_weight` 三向交互。
- `to_do_align_proposal.md` 也把 `intelligence × relationship_role × is_open_weight` 列为 P2。

**建议补做**

- 补做或至少附录报告开源闭源与关系角色的三向交互。
- 若样本量不足，应明确三向交互仅探索性展示。

### 7. 投资者关注 ASVI

**承诺内容**

- 构造 firm-level ASVI、model-level search intensity、creator-level search intensity、event-level attention index。
- 基准期可设为事件日前 56 个自然日或 8 周中位数，事件期聚合为 `[-1,+1]` 平均值或最大值。
- 对低搜索量、通用词和歧义 ticker 做人工标记。
- 在机制分析中加入 ASVI，检验关注从事件本身传导到相关公司股票。

**已完成迹象**

- `proposal.md` 写得很完整。
- `Tex/llm_pricing_regime_full.tex` 第六节标题含“投资者关注”，但内容实际主要是 FinBERT 情感。
- 文末后续研究明确写“引入 Google Trends ASVI 作为事件级投资者关注度指标”。
- `data/source_reports/aa_trends_variable_plan.md` 和 `aa_trends_data_source_inventory.md` 讨论的是 Artificial Analysis trends 数据，不是 Google Trends ASVI。

**可能未完成**

- 未看到 ASVI 变量列。
- 未看到 ASVI 回归、ASVI 与能力或情感交互、不同 ASVI 口径比较。
- 未看到搜索词歧义、低搜索量标记或 Google Trends 数据处理结果。

**建议补做**

- 这是 proposal 与当前结果的最大机制缺口之一。
- 最低可行版本是 event-level attention index，加到核心模型中，并报告是否削弱能力和媒体情感系数。
- 更完整版本应按 firm、model、creator、event 四口径构造，并分别检验。

### 8. 媒体情感机制

**承诺内容**

- 构造事件级、公司级和事件公司级媒体情感。
- 使用 FinBERT 或人工校验金融情感模型，LLM 情感可作为补充。
- 报告情感均值、情感标准差、报道数量。
- 检验 ASVI 和媒体情感是否放大或调节模型发布冲击。
- 旧版 `research proposal.md` 更具体地承诺 H2a、H2b、H2c，即情感正负非对称、情感分歧调节、媒体情感的产业链异质性。

**已完成迹象**

- `result.md` 和两份 TeX 均报告 FinBERT 情感均值与 CAR 的反向关系。
- 已报告情感与智能指数正交，联合模型中两者保留解释力。
- 已检验 `intel_c × sent_c5`，结果不显著。
- 数据列包含多窗口 `media_sent_mean_w2` 到 `w20` 和 `media_sent_sd_w2` 到 `w20`。

**部分完成或可能未完成**

- 情感标准差列存在，但主文没有报告 `sentiment_std` 主效应。
- 未检验 `sentiment_std × intelligence`。
- 未做正面情感和负面情感非对称，未做 `sentiment_mean × I(sentiment_negative)`。
- 未按关系角色估计情感效应差异。
- 未按媒体类型区分财经媒体和科技媒体。
- 未报告报道数量。
- 未做人工抽检 100 条新闻或与 VADER、TextBlob、LLM 打分对比。

**建议补做**

- P0 补做 H2a、H2b、H2c，直接回应旧 proposal 和 `to_do_align_proposal.md`。
- 增加情感分歧和报道数量表。
- 做一个情感工具稳健性表。若没有 VADER/TextBlob 数据，至少把人工验证列为未完成并说明限制。

### 9. 市场学习和时间演变

**承诺内容**

- 使用 `trend_month_since_2022_11` 及其与 ASVI、媒体情感、能力和成本效率的交互。
- 进行阶段划分，例如 2022 年 11 月到 2023 年末为早期关注阶段，2024 年以后为商业验证和成本竞争阶段。
- 使用滚动事件窗口估计 ASVI、能力和成本效率系数随时间变化。

**已完成迹象**

- 数据包含 `trend_month_since_2022_11`。
- `result.md` 报告 2024、2025、2026 年分组，线性趋势交互不显著。
- `Tex/llm_pricing_regime_full.tex` 进一步报告季度特定斜率、体制转换截断点搜索、季度构成调整和替代窗口。
- `output/figures/quarter_specific_slope_plot.png` 存在。

**部分完成或可能未完成**

- 因当前事件始于 2024，无法真正检验 proposal 所写的 2022 到 2023 早期关注阶段。
- 未看到 ASVI 与时间交互。
- 未看到成本效率与时间交互。
- 未看到滚动事件窗口估计。
- 体制转换分析较充分，但与 proposal 的 attention-driven 到 capability/cost-efficiency-driven 机制只完成了能力维度。

**建议补做**

- 若不扩展早期样本，应把 H5 改写为 2024 到 2026 年内的体制转换，而不是 2022 年后全周期学习。
- 补做 `trend × sentiment`、`trend × cost_efficiency`。ASVI 完成后再补 `trend × ASVI`。
- 将季度图正式纳入正文或附录。

### 10. 稳健性检验

**承诺内容**

- 替换事件窗口为 `[-3,+3]`、`[-5,+5]`。
- 使用 Fama-French 三因子或五因子模型。
- 剔除低置信匹配事件。
- 剔除混淆事件。
- 仅保留高媒体覆盖事件。
- 仅保留高置信暴露关系。
- 分别估计 LLM 与 media 子样本。
- 使用不同 ASVI 口径。
- 使用不同媒体情感模型。
- 连续变量 1% 和 99% 缩尾。
- `research proposal.md` 还曾承诺 PSM-DID、极端样本剔除、人工验证和多工具情感比较。

**已完成迹象**

- 多窗口规格曲线已完成。
- FF3 稳健性已报告。
- CR2 和 Wild Bootstrap 已报告。
- 行业和 Mag7 稳健性已报告。
- 构成调整、季度替代窗口、部分子样本分析已完成。
- 中文完整稿写明连续变量 1% 和 99% 缩尾。
- 新版 `proposal.md` 已弱化 PSM-DID，明确不把它作为主识别策略。

**部分完成或可能未完成**

- 未看到 FF5。
- 未看到低置信匹配剔除。
- 未看到混淆事件剔除。
- 未看到高媒体覆盖事件筛选。
- 未看到高置信暴露关系样本。
- 未看到不同 ASVI 口径，因为 ASVI 本身未完成。
- 未看到不同媒体情感模型。
- 未看到 Cook 距离、DFBetas 或极端样本剔除。
- 未看到 PSM-DID。新版 proposal 可不做，但旧版 `research proposal.md` 和 `to_do_align_proposal.md` 仍列为承诺或待办。

**建议补做**

- 优先补做低置信匹配剔除、高置信关系剔除、混淆事件剔除，这三项最贴合新版 proposal。
- 若篇幅有限，PSM-DID 可转入“未来研究或不适用说明”，但需要在 `to_do_align_proposal.md` 中清理。
- 补一个异常值稳健性表。

### 11. 图形

**承诺或合理期待**

- 规格曲线分析自然需要规格曲线图。
- 市场学习需要时间或季度斜率图。
- 事件样本构建可以有筛选流程图。
- 描述统计可有事件时间线、CAR 窗口均值图、模态分布图。

**已完成迹象**

- `output/figures/` 中已有 `specr_curve_aa_intelligence_index.pdf`、`specr_curve_aa_coding_index.pdf`、`specr_curve_aa_math_index.pdf`、`specr_curve_aa_media_elo.pdf`、`specr_rel_curve_all.pdf`、`quarter_specific_slope_plot.png` 等。
- 早期任务目录中有 `figure_car_window_means.png`、`figure_car1_by_modality.png`、`figure_event_timeline.png`。

**可能未完成**

- 两份 TeX 中未看到 `includegraphics`，说明当前正文没有正式纳入图形。
- FRL 版本尤其缺图，只保留三张表。
- 未看到样本筛选流程图。

**建议补做**

- 至少纳入三类图，规格曲线图、季度斜率图、样本筛选流程图。
- 若投短文，可把规格曲线和筛选流程放附录，正文保留季度图或核心机制图。

### 12. 待补写作和披露

**已完成迹象**

- 完整中文稿有解释边界，讨论小聚类、人工关系标注、AA 指标的事后度量、中国模型样本不足。
- FRL 稿把理论焦点压缩为 appropriability，逻辑更集中。

**可能未完成**

- FRL 稿仍有占位引用和 Appendix 引用，但文档中未见 Appendix A1、A2、A3 的实际表。
- 样本筛选规则、事件日认定规则、AA 匹配方法、排除样本尚未完整披露。
- 当前项目存在两个 proposal 版本。新版 `proposal.md` 与旧版 `research proposal.md` 在样本范围、主假设、PSM-DID 地位、事件窗口上不完全一致，需要统一口径。
- `to_do_align_proposal.md` 中许多任务仍是未勾选状态，且有些任务对应旧版 proposal。

**建议补做**

- 先决定论文版本。若是 FRL 版，应明确“本文不完整执行旧版全 proposal，而是聚焦可占有性机制”。
- 若是 working paper 版，应继续补齐 ASVI、成本效率、情感分歧、样本筛选附录。
- 清理 `to_do_align_proposal.md`，把已完成项勾掉，把已放弃项移入“版本取舍”。

## 四、最可能尚未完成的分析清单

以下清单按优先级排序。

### P0，直接影响 proposal 对齐

1. 2022 年 11 月到 2024 年 1 月早期模型发布事件补充。
2. 传统事件研究平均 CAR 表，按全样本和关系角色报告。
3. 关系角色平均 CAR 排序和差异检验，覆盖发布方、上游、下游、竞争者、投资方、云服务。
4. ASVI 或搜索关注度变量构造与回归。
5. 情感非对称检验，正面和负面情感分开估计。
6. 情感分歧度主效应和 `sentiment_std × intelligence`。
7. 情感效应的关系角色异质性。
8. 样本筛选和排除样本附录。
9. 混淆事件剔除或标记后的稳健性。
10. 高置信 AA 匹配和高置信关系暴露样本稳健性。

### P1，影响机制完整性

1. 成本效率机制，价格、速度、TTFT、price efficiency、speed-adjusted capability。
2. 能力跃迁或 frontier gap。
3. MMLU-Pro、GPQA、LiveCodeBench 等替代能力指标。
4. Media 样本的 rank、appearances、category-level Elo。
5. 开源闭源与关系角色三向交互。
6. 发布者国家或中国模型分组的正式稳健性。
7. 多模态、模型家族、reasoning、coding 等事件特征异质性。
8. 报道数量和媒体类型异质性。
9. 异常值稳健性，如 Cook 距离或 DFBetas。
10. 不同情感工具或人工验证。

### P2，影响呈现完整度

1. 正式纳入规格曲线图。
2. 正式纳入季度体制转换图。
3. 增加样本筛选流程图。
4. 完成 FRL 稿中引用的 Appendix 表。
5. 写清事件日认定、非交易日处理和替代事件日稳健性。
6. 写清为什么主窗口从 proposal 的短窗口转为 `[0,+20]`。
7. 统一 `proposal.md`、`research proposal.md` 和当前稿件的假设编号。

## 五、已完成分析清单

为避免重复劳动，以下内容看起来已经做过。

1. 60 事件和 5161 事件公司观测的基础样本。
2. AA Intelligence Index 主回归。
3. 闭源样本能力定价。
4. 开源闭源方向分叉和 `intel_c × open_weight`。
5. AA Coding、Math、Media Elo 的规格曲线。
6. 关系类型规格曲线。
7. Owner 短期负向效应。
8. Investor 交互效应。
9. Cloud 交互的探索性结果。
10. Tier 1 和 Tier 2 信息惊喜比较。
11. 年份分组和季度体制转换。
12. FF3 稳健性。
13. CR2 和 Wild Bootstrap 标准误稳健性。
14. 行业组异质性。
15. Mag7 与非 Mag7 比较和 Mag7 内部分化。
16. FinBERT 情感均值与 CAR 的反向关系。
17. 情感与智能指数正交性。
18. `intel_c × sent_c5` 不显著。

## 六、建议下一步执行顺序

若目标是最快对齐 `proposal.md`，建议按以下顺序补。

1. 先做文档层面的口径统一。确定最终采用新版 `proposal.md`，还是兼容旧版 `research proposal.md`。
2. 做样本筛选附录。这个不一定需要新回归，但能修补方法透明度。
3. 补传统事件研究平均 CAR 表和关系角色平均 CAR 表。
4. 补情感非对称、情感分歧、关系角色情感异质性。
5. 补 ASVI。若时间不够，先做 event-level attention index。
6. 补成本效率变量。至少加入 price、speed、TTFT 和 price efficiency。
7. 补高置信匹配、高置信关系、混淆事件剔除三个稳健性。
8. 把已有规格曲线图和季度图正式纳入正文或附录。

## 七、结论

当前项目不是“没有做实证”。相反，已经形成一条较强的可占有性和能力定价主线，核心结果集中在闭源能力定价、开源闭源分叉、媒体情感反向、季度体制转换和行业异质性。

但若按 `proposal.md` 的完整承诺审查，尚未完成的部分仍不少。最关键的缺口是 ASVI、多口径关注度、成本效率机制、情感分歧和非对称、严格样本筛选披露、混淆事件稳健性、早期样本扩展，以及按关系角色平均 CAR 的传统事件研究表。

如果论文目标是短篇 FRL，建议把承诺收窄到“可占有性如何调节 AI 能力定价”，并把未完成机制作为后续研究。若目标是完整 working paper，则需要继续补齐上述 P0 和 P1 分析。
