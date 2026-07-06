# 已有实证结果盘点

本文件按 `proposal.md` 的研究设计盘点项目中已经完成的实证分析。重点读取了 `data/results_tables/`、`output/tables/`、`agent_tasks/*/final_report.md`、`agent_tasks/*/*report*.md` 和 `Tex/*.tex`。`data/results_tables/` 与 `output/tables/` 中的同名表基本一致，以下以 `output/tables/` 和 `data/results_tables/` 共同作为结果表来源。

## 一、总体判断

项目已经完成一套可以支撑短文的核心实证结果。最稳的主线是闭源或专有 AI 模型发布中，AA Intelligence Index 与 CAR[0,+20] 显著正相关。开源或开放权重发布削弱这条能力定价斜率，方向清楚，但小聚类和 wild bootstrap 下应保守表述。

项目也已经完成若干重要稳健性分析，包括 firm fixed effects、事件聚类、公司聚类、双向聚类、Fama-French 三因子异常收益、发布前 CAR、事件层聚合、leave-one-creator-out、美国交易标的粗筛和事件窗口重叠诊断。

从 `proposal.md` 的完整设计看，仍没有完全完成 ASVI 关注度机制、严格 placebo event date、日度多事件重叠控制、正式证券样本识别、发布日可观察能力 proxy、事件纯净性标记和更系统的事件-公司关系强度编码。

## 二、已完成分析

### 1. 样本清洗与事件公司面板

已完成内容

- 清洗后样本为 60 个 AI 模型发布事件、86 家 AI 相关上市公司、5,160 个事件-公司观测。
- 当前主回归样本为 47 个有 AA Intelligence Index 的事件、约 3,780 个观测。
- 闭源主样本为 36 个事件、约 2,899 个观测。
- 开源或开放权重样本为 11 个事件、约 881 个观测。
- 已生成事件层摘要、变量字典、事件公司平衡检查和变量重命名表。

对应文件

- `output/data/clean_event_firm_panel.csv`
- `output/data/specr_input_clean.csv`
- `output/data/specr_rel_clean.csv`
- `output/tables/event_level_summary.csv`
- `output/tables/event_firm_balance_check.csv`
- `output/tables/data_dictionary.csv`
- `output/tables/variable_rename_map.csv`
- `agent_tasks/event_data_cleaning_202606021351/review_report.md`

主要结论

- 项目已经从早期的 5,160 行平衡面板，推进到可用于能力定价回归的 47 个 intelligence 事件样本。
- 事件层变量、公司层 CAR 和主要控制变量已经整理成可回归格式。
- 早期 `relationship` 全缺失的问题后来已有修补，`specr_rel_clean.csv` 和关系回归表中已出现 owner、investor、cloud、upstream、downstream、competitor 等关系变量。

仍缺风险

- 关系变量的补充过程需要在附录中透明说明，否则容易被认为是事后编码。
- 正式证券口径尚不够严格。当前有美国交易标的粗筛，但还不是 CRSP PERMNO 或正式 exchange country 口径。
- 事件是否存在财报、并购、监管、宏观或同日重大新闻混淆，还没有形成系统标记。

### 2. 早期平均 CAR 与描述性事件研究

已完成内容

- 对各 CAR 窗口做了均值检验。
- 比较了美股或 ADR 近似样本和非美国交易所后缀样本。
- 做了事件层平均 CAR 聚合。
- 做了按模态、行业、开源、中国模型、模型家族、代码模型和推理模型的分组比较。

对应文件

- `agent_tasks/analysis_report_20260521-133006/final_report.md`
- `agent_tasks/analysis_report_20260521-133006/table_car_window_tests.csv`
- `agent_tasks/analysis_report_20260521-133006/table_group_car1_tests.csv`
- `agent_tasks/analysis_report_20260521-133006/table_event_level_regressions.csv`
- `agent_tasks/analysis_report_20260521-133006/table_market_bucket_car_tests.csv`

主要结论

- 在早期版本中，事件-公司展开样本的 `car_1` 均值约为 0.195%，t 值为 2.34，p 值为 0.019。
- 更长窗口 `car_2`、`car_3`、`car_5`、`car_10`、`car_15` 和 `car_20` 的均值不显著。
- 按 60 个事件聚合后，`mean_car_1` 方向仍为正，但不显著。
- 美股或 ADR 近似样本中的短窗口正反应更强，非美国交易所后缀样本不明显。

仍缺风险

- 这些结果属于早期探索性分析，不应作为当前论文主结果。
- 早期报告明确指出当时关系编码缺失、ASVI 缺失、财务控制变量缺失较多。
- 早期短窗口均值结果与后续 FRL 主线的 CAR[0,+20] 能力定价不是同一识别重点。

### 3. 核心能力定价回归

已完成内容

- 以 AA Intelligence Index 解释 CAR[0,+20]。
- 分别估计全样本、闭源样本和开放权重交互模型。
- 使用 CR0、CR2 和 wild cluster bootstrap 报告显著性。

对应文件

- `output/tables/core_table_results.csv`
- `output/tables/main_regression_results.csv`
- `data/results_tables/core_table_results.csv`
- `data/results_tables/main_regression_results.csv`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `Tex/frl_draft_main_text.tex`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 全样本中，AA Intelligence Index 对 CAR[0,+20] 的系数为 0.001521，CR0 p 值为 0.0271，CR2 p 值约为 0.0541，wild p 值约为 0.0526。全样本结果方向为正，但小聚类推断下只是边际。
- 闭源样本中，系数为 0.002317，CR0 p 值为 0.00064，CR2 p 值约为 0.0069，wild p 值约为 0.0082。这是当前最稳的主结果。
- 按样本标准差换算，一标准差 AA Intelligence Index 提升约对应 3.0 个百分点更高的 20 日累计异常收益。

仍缺风险

- 主结果依赖 CAR[0,+20]，该窗口较长，容易受到其他 AI 发布、科技板块行情和公司新闻影响。
- AA Intelligence Index 可能是事后标准化能力指标，不一定完全等同于发布日投资者可观察信息。
- 全样本结果边际，主文应强调闭源专有能力定价，而不是泛化为所有 AI 能力都会被市场定价。

### 4. 开源或开放权重的调节效应

已完成内容

- 构造 AA Intelligence Index 与 open-weight 的交互项。
- 在基准模型和 firm FE 稳健性中检验开源削弱能力斜率。

对应文件

- `output/tables/core_table_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 交互模型中，闭源基准斜率约为 0.002257，CR2 p 值约为 0.0051，wild p 值约为 0.0082。
- `intel_c × is_open_weight` 的系数约为 -0.003734，CR0 p 值约为 0.0032，CR2 p 值约为 0.0475，wild p 值约为 0.0858。
- firm FE 下，开源交互项仍为负，且 two-way cluster 下仍显著。
- 当前写法宜使用 attenuation 或 suggestive attenuation，不宜写成强开源反转结论。

仍缺风险

- 开源事件只有 11 个，事件数偏少。
- 开源状态可能与发布者、模态、发布时间和商业模式同时变化。
- 缺少更细的 license、开放权重质量、可商用限制、生态采用度变量。

### 5. Firm fixed effects 与聚类稳健性

已完成内容

- 加入 firm fixed effects。
- 分别报告 event cluster、firm cluster 和 event-firm two-way cluster。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/econometric_robustness_report.md`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`

主要结论

- 闭源样本加入 firm FE 后，AA Intelligence Index 系数约为 0.002260。
- event cluster p 值约为 0.0010，firm cluster p 值约为 0.0018，two-way cluster p 值约为 0.0138。
- 这说明闭源能力定价不是由公司间固定差异、长期 AI 暴露差异或规模层级机械驱动。

仍缺风险

- 事件层有效聚类数仍只有 36 或 47 个，推断应保持保守。
- 两维聚类在小样本下可能不稳定，宜与 CR2 和 wild bootstrap 一起报告。

### 6. Fama-French 异常收益稳健性

已完成内容

- 用 FF3 CAR[0,+20] 替代市场模型 CAR。
- 在全样本和闭源样本中重新估计能力定价。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 全样本 FF3 CAR[0,+20] firm FE 下系数约为 0.001018，p 值约为 0.0254。
- 闭源样本 FF3 CAR[0,+20] firm FE 下系数约为 0.001176，p 值约为 0.0274。
- FF3 后量级下降，但方向和显著性仍支持主结论。

仍缺风险

- 目前只看到 FF3，`proposal.md` 中提到的 FF5 和 momentum 因子还没有形成主结果。
- AI 行业因子、Nasdaq、SOX、软件云服务 ETF 等行业层面控制尚未系统纳入。

### 7. 发布前 CAR 检验

已完成内容

- 用 pre-event CAR 作为因变量，检验能力是否在发布前已经被系统定价。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 全样本 pre-event CAR 系数约为 0.000155，p 值约为 0.576。
- 闭源样本 pre-event CAR 系数约为 0.000474，p 值约为 0.119。
- 当前没有强证据表明模型能力在发布前已经系统性反映在股票价格中。

仍缺风险

- 这不是严格 placebo date。
- 闭源样本发布前系数为正但不显著，不能写成完全排除提前定价。
- 更强检验需要日度收益序列和随机或提前事件日。

### 8. 事件层聚合

已完成内容

- 将公司事件面板聚合到事件层，避免 86 家公司重复展开造成显著性膨胀。
- 分别聚合全体公司均值和显性关系公司均值。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/event_level_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 全样本全体公司均值事件层系数约为 0.000987，p 值约为 0.120，不显著。
- 闭源全体公司均值事件层系数约为 0.001715，p 值约为 0.0165，显著。
- 显性关系公司均值不显著。闭源相关公司均值系数约为 0.001420，p 值约为 0.178。
- 结果更像广义 AI 暴露股票池的重估，而不只是 owner、investor、cloud 或 downstream 公司被重新定价。

仍缺风险

- 显性关系公司不显著，弱化了 `proposal.md` 中关系传导机制的强版本。
- 如果完整论文要强调经济暴露关系，需要更强的关系强度和 firm-level AI exposure 数据。

### 9. Leave-one-creator-out

已完成内容

- 逐一剔除主要模型发布者后重新估计闭源能力定价。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/leave_one_creator_out_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 闭源样本剔除 Google、OpenAI、Anthropic、Alibaba、Meta、xAI、Microsoft 后，系数均保持为正。
- 典型结果包括剔除 Google 后系数约 0.002039，p 值约 0.0148；剔除 OpenAI 后系数约 0.004262，p 值小于 0.001；剔除 Anthropic 后系数约 0.001980，p 值约 0.0038。
- 闭源结果不是单一 creator 独自驱动。

仍缺风险

- 全样本 leave-one-creator-out 弱于闭源样本。
- creator 集中度仍然需要在样本描述中清楚呈现。

### 10. 美国交易标的粗口径检验

已完成内容

- 用无交易所后缀的 ticker 粗略识别美国交易标的，重估核心模型。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- 美国交易标的粗口径下，全样本系数约为 0.001932，p 值约为 0.0195。
- 闭源样本系数约为 0.002709，p 值约为 0.0006。
- 主结果不依赖海外交易所后缀股票。

仍缺风险

- 这只是规则近似，不是正式 US-listed common stocks 样本。
- 若标题强调美股市场，仍需正式证券 ID、交易所、ADR 和股票类型字段。

### 11. 事件窗口重叠诊断

已完成内容

- 诊断 intelligence 事件前后 20 个自然日内是否还有其他 intelligence 事件。

对应文件

- `agent_tasks/econometric_robustness_20260613-210000/event_window_overlap_diagnostic.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`

主要结论

- 47 个 intelligence 事件中，只有 4 个事件在前后 20 个自然日内没有其他 intelligence 事件。
- 重叠事件数中位数为 3，最大值为 6。
- AI 模型发布高度密集，简单剔除重叠事件会让样本几乎不可用。

仍缺风险

- 目前只是诊断，不是控制或修正。
- CAR[0,+20] 应解释为密集发布环境下的中期重估，而不是完全纯净的单事件反应。
- 更强方案需要 firm-day 日度面板、calendar-time 回归或多事件窗口控制。

### 12. 能力指标规格曲线与 horse race 初步比较

已完成内容

- 对 AA Intelligence Index、AA Coding Index、AA Math Index 和 AA Media Elo 做规格曲线。
- 比较不同指标在多个设定中的显著率、正向比例和中位系数。

对应文件

- `output/tables/specr_summary.csv`
- `output/tables/specr_results_all.csv`
- `output/figures/specr_curve_aa_intelligence_index.pdf`
- `output/figures/specr_curve_aa_coding_index.pdf`
- `output/figures/specr_curve_aa_math_index.pdf`
- `output/figures/specr_curve_aa_media_elo.pdf`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`

主要结论

- AA Intelligence Index 的 5% 显著率约为 23.8%，10% 显著率约为 34.5%，正向比例约为 66.3%。
- AA Media Elo 的 5% 显著率约为 20.3%，正向比例约为 62.3%。
- AA Coding Index 和 AA Math Index 明显较弱，尤其 Math Index 方向不稳。
- 投稿稿件进一步将 CAR[0,+20] 规格单独整理，显示 AA Intelligence 在长窗口上的表现最强。

仍缺风险

- 这还不是严格同样本、多指标联合 horse race。
- 多重检验风险明显，需要明确哪些是预注册式主假设，哪些是探索性规格曲线。
- 若写成长文，需在同一样本中联合放入多个能力指标，并做标准化或分位数化比较。

### 13. 时间演变、季度斜率与市场学习

已完成内容

- 做了季度特定斜率。
- 做了季度组合调整结果。
- 做了 regime cutoff tests。
- 生成了季度斜率图。

对应文件

- `output/tables/quarter_specific_slopes.csv`
- `output/tables/composition_adjusted_quarter_results.csv`
- `output/tables/quarter_composition_table.csv`
- `output/tables/regime_cutoff_tests.csv`
- `output/figures/quarter_specific_slope_plot.png`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_time_learning_interactions.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_rolling_event_window.csv`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`

主要结论

- 年份或季度结果提示 2025 年以后能力定价更明显，但线性趋势本身不稳。
- `publishable_results_inventory` 记录 2025 年 intelligence 与 CAR[0,+20] 显著为正，2024 年不显著，2026 年样本太小。
- `regime_cutoff_tests.csv` 显示部分 cutoff 交互显著，但部分早期 cutoff 存在事件数不足或不稳定问题。

仍缺风险

- `proposal.md` 中 H5 的市场学习机制还没有完全完成。ASVI 缺失，关注驱动到能力驱动的转换不能强写。
- 季度斜率受到事件组合、发布者、开源状态和模型模态变化影响。
- 若要作为主结果，需要明确阶段划分依据并处理多重检验。

### 14. 媒体情感机制

已完成内容

- 使用 FinBERT 媒体情感均值检验情感与 CAR 的关系。
- 做了 sentiment only 和 joint model。
- 检查情感是否吸收 AA Intelligence 的能力定价结果。

对应文件

- `output/tables/heterogeneity_results.csv`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `Tex/frl_draft_main_text.tex`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`
- `agent_tasks/analysis_report_20260521-133006/final_report.md`

主要结论

- FinBERT 情感越正面，后续 CAR[0,+20] 越低。`publishable_results_inventory` 中记录 sent_w5 单独预测系数约为 -0.0810，CR2 p 值约为 0.0033。
- joint model 中，情感仍为负，AA Intelligence 仍为正但在 CR2 下边际。
- 情感对 intelligence 的事件层回归不显著，intelligence 与 sentiment 的交互项不显著。
- 最合适的解释是媒体叙事热度和技术能力捕捉不同信息。正面媒体情感可能代表提前预期和公告后反转，而不是能力本身。

仍缺风险

- `proposal.md` 要求 ASVI 关注度机制，目前真实 Google Trends ASVI 还没有完成。
- 媒体情感不是关注度。新闻数量、新闻来源层级、财经媒体和科技媒体分拆仍缺。
- 早期旧稿将媒体分歧度视为 ASVI 代理，这个说法在当前投稿主线中应降调。

### 15. 关系类型与经济暴露异质性

已完成内容

- 已有 owner、investor、cloud、upstream、downstream、competitor 等关系变量或子样本。
- 已完成部分关系交互和关系子样本回归。
- 已生成关系规格曲线。

对应文件

- `output/tables/main_regression_rel_results.csv`
- `output/tables/core_table_results.csv`
- `output/tables/specr_rel_summary.csv`
- `output/tables/specr_rel_results_all.csv`
- `output/figures/specr_rel_curve_all.pdf`
- `output/figures/specr_rel_curve_relonly.pdf`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_relationship_interactions.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_joint_models.csv`

主要结论

- competitor 子样本中 intelligence 与 CAR[0,+20] 不显著，系数约为 0.000515，p 值约为 0.352。
- real downstream 点估计约为 0.002004，但样本只有 62 个观测、20 个事件，p 值约为 0.235。
- investor 交互项为负，CR2 约在 5% 边界附近，但 wild p 值约为 0.126，不稳。
- cloud 交互项为负，CR2 和 wild 均不够稳。
- 显性关系公司事件层均值不显著，说明当前关系机制证据弱于闭源能力定价主线。

仍缺风险

- `proposal.md` 的 H2 要求关系暴露决定反应方向，目前证据不足。
- 关系变量较稀疏，许多类别观测太少。
- 关系强度、关系来源、关系发生时间、人工置信度和 firm-level AI exposure 还没有充分进入主表。

### 16. 行业、Mag7 和公司层异质性

已完成内容

- 按行业估计能力定价斜率。
- 比较 Mag7 与非 Mag7。
- 计算 Mag7 个体平均 CAR。

对应文件

- `output/tables/heterogeneity_results.csv`
- `output/tables/industry_car_summary.csv`
- `output/tables/mag7_company_car_summary.csv`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`

主要结论

- 互联网服务和基础设施子样本结果最稳，系数约为 0.001899，CR2 p 值约为 0.0150。
- 软件和半导体方向为正，但在 CR2 下多为边际。
- Mag7 与非 Mag7 的 intelligence 斜率无显著差异。
- Mag7 内部差异大。NVIDIA 平均 CAR[0,+20] 为正，Tesla 为负。

仍缺风险

- 行业异质性属于探索性附录结果，不宜抢主线。
- 行业分类不是事件-公司经济暴露关系的充分替代。

### 17. Media Elo 与非 LLM 模型能力

已完成内容

- 对 AA Media Elo 做了规格曲线和部分回归。
- 早期分析也区分了 LLM 能力样本和 media 能力样本。

对应文件

- `output/tables/specr_summary.csv`
- `output/tables/specr_results_all.csv`
- `output/figures/specr_curve_aa_media_elo.pdf`
- `agent_tasks/analysis_report_20260521-133006/final_report.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`

主要结论

- AA Media Elo 更像短窗口即时反应或媒体生成模型展示冲击。
- 与 AA Intelligence Index 的长窗口定价模式不同。
- 非文本生成模型没有成为当前投稿主线。

仍缺风险

- LLM Intelligence Index 和 media Elo 不能直接混合解释。
- 如果后续写 full-length paper，需要按模态分样本或使用 within-modality z-score、rank percentile。

### 18. 旧版全文草稿中的发布方、自身 CAR、媒体关注和市场学习结果

已完成内容

- `Tex/Old/llm_paper.tex` 和 `Tex/Old/llm_paper_formal_rewrite.tex` 写过一版更宽的全文叙事。
- 旧版包含 94 个 LLM 事件、发布方自身、Microsoft 外溢、媒体关注反转、滚动窗口和竞争溢出等结果。

对应文件

- `Tex/Old/llm_paper.tex`
- `Tex/Old/llm_paper_formal_rewrite.tex`
- `Tex/llm_pricing_regime_full.tex`

主要结论

- 旧稿认为全样本短窗口 CAR 接近零，上市发布方在较长窗口获得正 CAR。
- 旧稿强调多模态和开源对发布方自身 CAR 为正，SOTA 不显著。
- 旧稿用媒体情感和分歧度刻画买预期、卖事实。
- 旧稿提出 Microsoft 发布带来更明显正向外溢，OpenAI 和 Google 没有类似平均效应。

仍缺风险

- 这些结果与当前 FRL 投稿主线不完全一致，且样本口径不同。
- 旧稿中部分事件延伸至 2022 到 2025，当前主表聚焦 2024 到 2026 的 60 个事件。
- 旧稿承认 relationship 字段尚未完整编码，且以 GICS 板块做代理。
- 不建议把旧稿结果直接并入当前主文，除非重新用当前清洗数据和当前口径复算。

## 三、按 proposal 五个研究问题的完成度

### 问题 1，重大 AI 模型发布是否产生显著 CAR

完成度较高，但结论已从平均 CAR 转向能力定价。

已完成

- 早期平均 CAR 窗口检验。
- 当前 CAR[0,+20] 能力定价回归。
- 事件层聚合。

主要结论

- 平均短窗口 CAR 证据弱。
- 最稳结果是闭源高能力发布对应更高 CAR[0,+20]。

剩余风险

- 事件窗口重叠严重。
- 需要更干净的事件日和混淆事件标记。

### 问题 2，经济暴露关系是否导致异质性

完成度中低。

已完成

- 已有关系变量的初步回归和规格曲线。
- competitor、investor、cloud、real downstream 等结果已有输出。

主要结论

- 当前关系机制没有形成稳健主结论。
- 显性关系公司事件层均值不显著。

剩余风险

- 关系编码透明度不足。
- 关系强度和 firm-level AI exposure 缺失。
- proposal 中的 publisher、parent、strategic partner、major investor、cloud provider、distribution partner、compute supplier、application exposed firm 等细分尚未全部稳健检验。

### 问题 3，技术特征是否解释 CAR

完成度高。

已完成

- AA Intelligence、Coding、Math、Media Elo 规格曲线。
- 闭源能力定价主回归。
- open-weight 交互。
- 行业和模态相关附录结果。

主要结论

- AA Intelligence 是最稳的长窗口能力指标。
- 闭源能力定价显著。
- 开源削弱能力斜率，证据方向明确但需保守。

剩余风险

- AA 指标的发布日可观察性仍需处理。
- 需要更严格同样本 horse race 和多重检验说明。
- 成本效率、价格、速度、TTFT、capability leap、frontier gap 等机制还没有形成同等强度主结果。

### 问题 4，ASVI 与媒体情感是否调节冲击

完成度中低。

已完成

- FinBERT 媒体情感结果。
- sentiment 与 intelligence 的 joint model。

主要结论

- 媒体情感越正面，后续 CAR 越低。
- 媒体情感不能完全吸收 intelligence 结果。

剩余风险

- 真实 ASVI 未完成。
- 新闻数量和关注度变量未系统加入。
- 事件级、公司级、事件公司级媒体文本没有完整区分。

### 问题 5，市场是否从关注驱动转向能力或商业化驱动

完成度中等。

已完成

- 季度斜率、regime cutoff、时间学习相关输出。
- 旧稿中有滚动窗口和媒体关注随时间衰减叙事。

主要结论

- 有阶段性变化迹象，2025 年后能力定价更明显。
- 线性趋势和 cutoff 结果不够稳定。

剩余风险

- 缺 ASVI，不能直接证明从 attention-driven 转向 capability-driven。
- 时间演变容易被样本构成、发布者变化和开源比例变化混淆。
- 需要更正式的滚动估计推断或预设阶段划分。

## 四、最适合进入当前论文的结果

建议作为正文主线

- 闭源模型能力定价。
- 开源削弱能力斜率，表述为 suggestive attenuation。
- firm fixed effects、CR2、wild bootstrap、FF3、pre-event CAR、event-level aggregation 和 leave-one-creator-out。
- 媒体情感作为竞争解释控制，而不是第二主机制。

建议放主附录

- 美国交易标的粗筛。
- 事件窗口重叠诊断。
- 能力指标规格曲线。
- 行业异质性。
- Mag7 与非 Mag7。
- relation 子样本和关系交互结果。
- Media Elo 短窗口结果。

建议暂不作为主要结果

- 严格 ASVI 机制。
- 严格 placebo event date。
- 完全剔除重叠事件后的检验。
- 中国模型单独结论。
- 旧版 94 事件全文中的发布方、自身 CAR 和 Microsoft 外溢叙事。

## 五、仍缺的高优先级分析

这些不是本文件要执行的任务，但它们是从已有结果反推出来的明显缺口。

1. 严格 placebo event date。需要回到底层日收益，把事件日前移 30 个交易日或随机换成同季度非事件日，重新计算 CAR。
2. 日度 firm-day 多事件控制。当前 20 日窗口重叠严重，应构造日度事件暴露面板。
3. 真实 ASVI 或 attention volume。至少补 Google Trends、新闻数量、财经媒体数量和技术媒体数量。
4. 发布日可观察能力 proxy。为 AA Intelligence 加入 benchmark observable by day 0 或 day 2 的子样本检验。
5. 正式 US-listed 样本。使用 CRSP PERMNO、exchange country、ADR 和 common stock 标记。
6. 关系强度和 AI 暴露。补 relationship intensity、source、confidence 和 firm-level AI exposure score。
7. 同样本能力指标 horse race。把 Intelligence、Coding、Math、Media Elo 或同模态指标标准化后在可比样本中比较。
8. 成本效率与价格机制。`proposal.md` 明确强调 cost efficiency、price、speed、TTFT，但当前主结果主要是 intelligence。

## 六、文件索引

核心结果表

- `output/tables/core_table_results.csv`
- `output/tables/main_regression_results.csv`
- `output/tables/main_regression_rel_results.csv`
- `output/tables/heterogeneity_results.csv`
- `output/tables/specr_summary.csv`
- `output/tables/specr_results_all.csv`
- `output/tables/specr_rel_summary.csv`
- `output/tables/specr_rel_results_all.csv`

稳健性任务目录

- `agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/event_level_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/leave_one_creator_out_results.csv`
- `agent_tasks/econometric_robustness_20260613-210000/event_window_overlap_diagnostic.csv`
- `agent_tasks/econometric_robustness_20260613-210000/final_interpretation.md`

综合盘点和审稿判断

- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/frl_project_review_20260613-204658/final_assessment.md`
- `agent_tasks/full_length_paper_gap_assessment_20260614.md`

正文草稿

- `Tex/frl_draft_main_text.tex`
- `agent_tasks/frl_submission_20260614-091455/frl_submission_main.tex`
- `Tex/Old/llm_paper.tex`
- `Tex/Old/llm_paper_formal_rewrite.tex`
- `Tex/llm_pricing_regime_full.tex`

proposal gap 相关输出

- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_capability_mechanisms.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_data_availability.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_joint_models.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_relationship_interactions.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_rolling_event_window.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_time_learning_interactions.csv`
- `agent_tasks/proposal_gap_analysis_20260619-092947/outputs/proposal_topline_capability_car20.csv`
