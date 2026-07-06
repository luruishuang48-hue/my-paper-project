# 代码和结果梳理报告

任务时间 20260619-093056，Asia/Shanghai。

本报告根据 `proposal.md`，读取 `scripts/analysis`、`scripts/prep`、`output`、`data/results_tables`、`reports`，以及历史 `agent_tasks` 中与 regression、robustness、submission、analysis 相关的文件后整理。当前环境没有可调用的子代理工具，因此本轮由主线程完成梳理。

## 一、总判断

项目已经完成一条较完整的短文型实证链条。

已完成的主线是，使用 60 个重大 AI 模型发布事件和约 5,160 条事件公司观测，检验 AA Intelligence Index 与 CAR 的关系，并重点展示闭源模型中的能力定价。已有结果支持闭源样本中 `aa_intelligence_index` 对 CAR[0,+20] 为正，且在 firm fixed effects、FF3 CAR、pre-event CAR、leave-one-creator-out、事件层聚合等检验下总体稳健。

已有结果更接近 *Finance Research Letters* 短文版本。它围绕 “市场是否定价可占有的 AI 模型能力” 展开，而不是完整执行新版 `proposal.md` 中的所有承诺。

主要缺口集中在五类。

- ASVI 和搜索关注度没有构造，也没有进入任何回归。
- 成本效率、价格、速度、TTFT、能力跃迁、frontier rank、within-modality percentile 没有进入当前主回归。
- 媒体情感已经做了均值机制，但分歧度、报道数量、媒体类别和多情感模型稳健性没有系统完成。
- 事件纯净性、混淆事件剔除、低置信匹配剔除、高置信暴露关系剔除没有形成可复现回归表。
- 20 日窗口重叠已经诊断为严重，但尚未用日度收益面板做 calendar-time 或多事件控制。

## 二、proposal 承诺与当前完成度

| proposal 承诺 | 当前状态 | 已有脚本或结果 | 缺口 |
|---|---|---|---|
| 重大模型发布主样本，不混入纯产品事件 | 部分完成 | `reports/final_60_event_sample_report.md`，`reports/main_model_release_events_clean_report.md`，`reports/aitimeline_model_events_enriched_report.md` | 当前可回归主样本从 2024 年开始，未覆盖 proposal 中 2022-11 至 2023 年早期事件。产品事件排除逻辑已有报告，但未形成完整排除样本回归或透明附录表 |
| 事件公司面板和关系暴露编码 | 部分完成 | `data/panel/specr_rel_clean.csv`，`data/results_tables/event_firm_balance_check.csv` | 已有 owner、investor、cloud、business_upstream、real_upstream、business_downstream、real_downstream、competitor 八类 0/1 变量，但没有 exposure_strength、exposure_source、manual_exposure_confidence，关系证据链未进入可复现表 |
| CAR 事件研究 | 已完成主版本 | `scripts/prep/clean_event_panel.py`，`output/data/clean_event_firm_panel.csv` | 已有市场模型 CAR 和 FF3 CAR，窗口覆盖 car_pre、car_1、car_2、car_3、car_5、car_10、car_15、car_20。尚未看到 FF5、行业因子、Nasdaq 或 AI basket 调整 CAR |
| 基准面板回归 | 已完成 | `scripts/analysis/main_regression.R`，`scripts/analysis/main_regression_rel.R`，`data/results_tables/main_regression_results.csv`，`data/results_tables/main_regression_rel_results.csv` | 主模型以 AA Intelligence 为核心，控制规模、BM、波动率、动量、年份 FE，事件聚类。未纳入全部 proposal 中的能力、关注度和媒体机制变量 |
| 能力机制检验 | 部分完成 | `scripts/analysis/specr_run.R`，`scripts/analysis/core_table.R`，`data/results_tables/specr_summary.csv`，`data/results_tables/core_table_results.csv` | 已比较 intelligence、coding、math、media Elo。尚未使用 MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500、AIME、价格、速度、TTFT、能力跃迁和成本效率 |
| 开源和可占有性机制 | 已完成短文主线 | `scripts/analysis/core_table.R`，`scripts/analysis/interaction_se_analysis.R`，`agent_tasks/econometric_robustness_20260613-210000/core_robustness_results.csv` | 交互项方向清楚，但开源事件只有 11 个，wild p 值较弱，应保守表述为削弱能力定价斜率 |
| 关系异质性 | 部分完成 | `scripts/analysis/specr_rel_run.R`，`data/results_tables/specr_rel_summary.csv`，`data/results_tables/main_regression_rel_results.csv` | 已做关系子样本和部分交互。缺少 proposal 要求的高置信关系、关系强度、方向性关系、关系证据来源，以及 relationship × sentiment 的完整机制 |
| 行业和 Mag7 异质性 | 已完成附录型结果 | `scripts/analysis/heterogeneity_analysis.R`，`data/results_tables/heterogeneity_results.csv`，`industry_car_summary.csv`，`mag7_company_car_summary.csv` | 适合附录。尚未细分云计算、芯片、电力、企业应用等更经济化分组 |
| 媒体情感机制 | 部分完成 | `scripts/analysis/heterogeneity_analysis.R`，`data/results_tables/heterogeneity_results.csv` | 已做 FinBERT 情感均值，结果为正面情感与 CAR[0,+20] 负相关。没有完整做情感分歧度、非对称正负情感、媒体类别、新闻数量、情感模型替换和人工标注验证 |
| ASVI 和关注度 | 未完成 | 没有 ASVI 变量或脚本 | `specr_rel_clean.csv` 中只有 `trend_month`，没有 firm-level ASVI、model-level search intensity、creator-level search intensity、event-level attention index |
| 市场学习和时间演变 | 部分完成 | `scripts/analysis/extended_analysis.R`，`scripts/analysis/quarter_pricing_regime.R`，`data/results_tables/quarter_specific_slopes.csv`，`regime_cutoff_tests.csv` | 已做年份分组、趋势项和季度斜率。未做 ASVI、媒体情感、成本效率随时间的交互，也没有滚动事件窗口 |
| 稳健性检验 | 部分完成且较强 | `agent_tasks/econometric_robustness_20260613-210000/run_econometric_robustness.R`，`core_robustness_results.csv` | 已做 firm FE、two-way cluster、FF3、pre-event CAR、event-level aggregation、leave-one-creator-out、美国交易标的粗口径。未做 placebo dates、FF5、低置信匹配剔除、混淆事件剔除、高媒体覆盖样本、高置信关系样本、不同 ASVI 口径和多情感模型 |
| 事件窗口重叠处理 | 只做诊断 | `agent_tasks/econometric_robustness_20260613-210000/event_window_overlap_diagnostic.csv` | 47 个 intelligence 事件中只有 4 个在前后 20 个自然日内无其他 intelligence 事件。严格处理需要日度收益层面的多事件控制 |
| 投稿材料 | 已有 FRL 版本 | `agent_tasks/frl_submission_20260614-091455/`，`Tex/frl_draft_main_text.tex` | 历史审阅指出短稿有占位符、引用和语气问题。投稿包服务于短文主线，不覆盖完整 proposal |

## 三、数据链条

### 1. 清洗后的主面板

`output/data/clean_event_firm_panel.csv` 和 `data/panel/clean_event_firm_panel.csv` 基本一致。

- 约 5,160 行，107 列。
- 关键字段包括 `final_event_id`、`release_date`、`true_model_creator`、`company`、`company_id`、公司控制变量、市场模型 CAR、FF3 CAR、媒体情感均值和标准差、模型模态、开源、candidate tier、AA 模型匹配和多项 AA 指标。
- `reports/cleaning_report.md` 说明原始 relationship 列曾为空，因此后续才引入关系版数据。

### 2. 规格曲线输入

`output/data/specr_input_clean.csv` 和 `data/panel/specr_input_clean.csv` 是第一版规格曲线输入。

- 约 5,161 行，106 列。
- 包含 `aa_intelligence_index`、`aa_coding_index`、`aa_math_index`、`aa_media_elo`。
- 关系变量仍不完整，主要用于全样本、开源闭源、creator type、模态分组。

### 3. 关系版回归输入

`output/data/specr_rel_clean.csv` 和 `data/panel/specr_rel_clean.csv` 是当前主结果常用底表。

- 5,161 行，84 列。
- 60 个事件，86 家公司。
- `aa_intelligence_index` 有 4,042 个非缺失观测。
- CAR 有效观测较完整，`car_1` 为 5,030，`car_20` 为 5,053。
- 关系变量计数为 owner 29、investor 37、cloud 29、business_upstream 156、real_upstream 126、business_downstream 1,440、real_downstream 81、competitor 462。
- ASVI 类变量不存在。与关注度相关的列只有 `trend_month`，它是时间趋势，不是搜索关注度。
- 媒体情感列包括多个均值窗口和一个 `媒体态度标准差` 字段。关系版数据没有完整保留 clean panel 中的 `media_sent_sd_w2` 至 `media_sent_sd_w20` 系列。

## 四、脚本清单

### 1. `scripts/prep/clean_event_panel.py`

作用是清洗双表头中文 CSV。

输入是脚本目录下 `事件集数据.csv`。输出包括 `clean_event_firm_panel.csv`、`cleaning_report.md`、`data_dictionary.csv`、`variable_rename_map.csv`、`event_level_summary.csv`、`event_firm_balance_check.csv`，如有重复还输出 `duplicate_event_firm_rows.csv`。

关键处理包括英文列名去重、CAR 两套变量区分为市场模型和 FF3、媒体窗口均值和标准差重命名、日期清洗、数值转换、事件公司重复检查、缺失率报告。

当前项目的规范输出已经复制到 `output/data`、`data/panel`、`output/tables` 和 `data/results_tables`。

### 2. `scripts/prep/specr_prep.py`

作用是把 `事件集数据-new.csv` 转为 `specr_input_clean.csv`。

输入是 GB18030 编码的 `事件集数据-new.csv`。输出是 UTF-8 的 `specr_input_clean.csv`。

该脚本主要服务早期规格曲线分析，保留四个能力指标、CAR 窗口、creator type、模态和开源变量。

### 3. `scripts/prep/specr_rel_prep.py`

作用是把 `task/事件集数据-relationships.csv` 转为 `specr_rel_clean.csv`。

它把中文列名映射为回归友好的英文名，并保留八类关系变量。该文件是当前主回归、关系异质性、季度机制和稳健性任务的主要输入。

### 4. `scripts/analysis/specr_run.R`

作用是运行四个能力指标的规格曲线。

输入是 `specr_input_clean.csv`。核心 X 变量包括 `aa_intelligence_index`、`aa_coding_index`、`aa_math_index`、`aa_media_elo`。Y 变量为 `car_1` 至 `car_20` 七个窗口。控制组合为无控制、规模控制、完整控制。子样本包括 all、us_creator、non_us_creator、open_source、closed_source、text_or_reason、media_gen。标准误按事件聚类，聚类少于 5 时退为 OLS。

输出是 `specr_results_all.csv`、`specr_summary.csv` 和四张规格曲线图。

当前结果显示 AA Intelligence 最稳，252 条规格中 23.8% 在 5% 水平显著，66.3% 为正。AA Math 方向最不稳定。

### 5. `scripts/analysis/specr_rel_run.R`

作用是关系版规格曲线。

输入是 `specr_rel_clean.csv`。X 变量为 `aa_intelligence_index`。Y 变量为七个 CAR 窗口。子样本增加 owner、investor、cloud、business_upstream、real_upstream、business_downstream、real_downstream、competitor、positive_rel、downstream_comp。

输出是 `specr_rel_results_all.csv`、`specr_rel_summary.csv`、`specr_rel_curve_all.pdf`、`specr_rel_curve_relonly.pdf`。

当前结果显示 us_creator、open_source、owner、real_downstream、closed_source 的规格显著率较高。开源方向主要为负，闭源方向主要为正。

### 6. `scripts/analysis/main_regression.R`

作用是生成第一版主回归表。

输入是 `specr_input_clean.csv`。模型是 `CAR ~ aa_intelligence_index + size_log_assets + bm_ratio + volatility + momentum + year FE`，标准误按 `final_event_id` 聚类。

输出是 `main_regression_results.csv` 和 HTML 表。

关键结果如下。

- 全样本 CAR[0,+20] 系数 0.001521，p = 0.027。
- 闭源样本 CAR[0,+20] 系数 0.002317，p = 0.00064。
- 短窗口 CAR[0,+1] 结果较弱。

### 7. `scripts/analysis/main_regression_rel.R`

作用是关系版主回归表。

输入是 `specr_rel_clean.csv`。模型形式与主回归一致，但用关系版数据估计全样本、real downstream、competitor、listed US creator、closed-source 子样本。

输出是 `main_regression_rel_results.csv` 和 HTML 表。

关键结果如下。

- 全样本 CAR[0,+20] 系数 0.001521，p = 0.0271。
- real downstream 系数 0.002004，但 p = 0.235。
- competitor 系数 0.000515，p = 0.352。
- listed US creator 系数 0.002449，p = 0.0813。
- closed-source 系数 0.002317，p = 0.00064。

### 8. `scripts/analysis/core_table.R`

作用是生成可投短文的核心表。

输入是 `specr_rel_clean.csv`。先中心化 `aa_intelligence_index` 得到 `intel_c`。核心模型包括全样本、闭源样本、`intel_c × is_open_weight`、`intel_c × investor`、`intel_c × cloud`、`intel_c × owner`。标准误同时报告 CR0、CR2 和 wild cluster bootstrap。

输出是 `core_table_results.csv`。

关键结果如下。

- 全样本 CAR[0,+20]，`intel_c` 系数 0.001521，CR0 p = 0.0271，CR2 p = 0.0541，wild p = 0.0526。
- 闭源 CAR[0,+20]，`intel_c` 系数 0.002317，CR0 p = 0.0006，CR2 p = 0.0069，wild p = 0.0082。
- `intel_c × is_open_weight` 系数 -0.003734，CR0 p = 0.0032，CR2 p = 0.0475，wild p = 0.0858。
- investor 和 cloud 交互方向为负，但 wild 支持较弱。
- owner 短窗口交互为负，在 car_1 和 car_2 上较稳。

### 9. `scripts/analysis/interaction_se_analysis.R`

作用是交互机制和小聚类稳健标准误比较。

输入是 `specr_rel_clean.csv`。分析包括 intelligence × open_weight、intelligence × tier1、intelligence × relationship、intelligence × tier1 × open_weight，并比较 CR0、CR2、CR3 和 wild bootstrap。

从结果用途看，它主要服务 `core_table_results.csv` 和后续短文稳健性解释。

### 10. `scripts/analysis/extended_analysis.R`

作用是扩展分析。

输入是 `specr_rel_clean.csv`。内容包括 owner 短长窗口逆转、`intelligence × trend_month`、按年份分组、中国和非中国模型、Tier 1、FF3 与市场模型比较。

该脚本主要输出到控制台或被整理进 `result.md`，未发现独立 CSV 写出语句。

关键结论已进入 `result.md` 和 `publishable_results_inventory_20260613-233641.md`。owner 短窗口为负，FF3 后方向一致但系数变小，年份分组显示 2025 年起能力定价更明显。

### 11. `scripts/analysis/heterogeneity_analysis.R`

作用是行业、Mag7 和媒体情感异质性。

输入是 `specr_rel_clean.csv`。模型使用 `intel_c`，控制公司变量和年份 FE，标准误报告 CR0 和 CR2。

输出是 `industry_car_summary.csv`、`mag7_company_car_summary.csv`、`heterogeneity_results.csv`。

关键结果如下。

- 软件、半导体、互联网服务和基础设施子样本中 `intel_c` 较强。
- Mag7 和 non-Mag7 斜率没有明显差异，但公司均值分化明显。
- `sent_w5` 和 `sent_w20` 单独预测 CAR[0,+20] 时为负且显著。
- 加入 `sent_c5` 后 `intel_c` 仍为正，CR2 p 约 0.087。
- `intelligence × sentiment` 不显著，情感更像独立或替代解释，而不是能力效应的调节项。

### 12. `scripts/analysis/quarter_pricing_regime.R`

作用是季度定价体制分析。

输入是 `specr_rel_clean.csv`。输出写到当前目录，现已同步到 `output/tables`、`data/results_tables`、`output/figures` 和 `reports`。

主要输出包括 `quarter_composition_table.csv`、`quarter_specific_slopes.csv`、`quarter_specific_slope_plot.png`、`regime_cutoff_tests.csv`、`composition_adjusted_quarter_results.csv`、`quarter_pricing_regime_summary.md`。

关键结果如下。

- 2025Q3 的 CAR[0,+20] 季度斜率显著为正。
- 2024Q4 的 CAR[0,+20] 季度斜率显著为负。
- 结果支持阶段性变化，但每个季度事件数都少，报告中明确建议将季度结果作为 suggestive。

### 13. `scripts/analysis/specr_analysis.R`

这是早期规格曲线脚本，直接读取 `事件集数据-new.csv` 并输出 `specr_results.csv`、`specr_summary.csv`。当前更规范的版本是 `specr_run.R` 和 `specr_rel_run.R`。

### 14. `scripts/analysis/specr_install.R`

只负责安装 `specr`、`estimatr`、`tidyverse`、`broom`，不是实证分析脚本。

## 五、当前结果文件清单

### 1. `data/results_tables` 和 `output/tables`

这两个目录里的结果表基本成对存在。

核心表包括：

- `main_regression_results.csv`
- `main_regression_rel_results.csv`
- `core_table_results.csv`
- `heterogeneity_results.csv`
- `specr_summary.csv`
- `specr_results_all.csv`
- `specr_rel_summary.csv`
- `specr_rel_results_all.csv`
- `quarter_specific_slopes.csv`
- `quarter_composition_table.csv`
- `regime_cutoff_tests.csv`
- `composition_adjusted_quarter_results.csv`
- `industry_car_summary.csv`
- `mag7_company_car_summary.csv`
- `event_firm_balance_check.csv`
- `event_level_summary.csv`

核心表格数值已经能支持一篇短文。最强结果是闭源样本 CAR[0,+20]，其次是开源削弱能力定价斜率。

### 2. `output/figures`

已有图形包括：

- `specr_curve_aa_intelligence_index.pdf`
- `specr_curve_aa_coding_index.pdf`
- `specr_curve_aa_math_index.pdf`
- `specr_curve_aa_media_elo.pdf`
- `specr_rel_curve_all.pdf`
- `specr_rel_curve_relonly.pdf`
- `quarter_specific_slope_plot.png`
- `specr_report.pdf`

这些图主要服务规格曲线和季度机制。

### 3. `reports`

数据来源和清洗报告包括：

- `aa_api_fetch_report.md`，说明 AA API 缓存和字段完整性。
- `aa_master_database_codebook.md`，说明 AA LLM、media、category 表字段。
- `aa_trends_data_source_inventory.md` 和 `aa_trends_variable_plan.md`，说明 AA trends 没有稳定公开 API，价格和速度趋势只能部分重构。
- `aitimeline_extraction_report.md`，说明 AI Timeline 候选事件抽取。
- `aitimeline_model_events_enriched_report.md` 和 codebook，说明候选事件与 AA 指标整合。
- `main_model_release_events_clean_report.md`，说明主模型发布事件表。
- `final_60_event_sample_report.md`，说明最终 60 事件样本。
- `official_release_date_crawl_report.md`，说明官方发布日期核查。
- `cleaning_report.md`，说明事件公司面板清洗、缺失、重复和变量重命名。
- `specr_report.md` 和 `quarter_pricing_regime_summary.md`，说明规格曲线和季度定价机制结果。

## 六、历史 agent_tasks 中的可用结果

### 1. `agent_tasks/analysis_report_20260521-133006`

这是早期分析包。包括数据审计、事件概况、CAR 窗口均值、事件层回归、行业和关系汇总、图形和最终报告。

可用文件包括 `final_report.md`、`final_report.pdf`、`table_regressions_compact.csv`、`table_event_level_regressions.csv`、`table_car_window_tests.csv`、`figure_event_timeline.png`、`figure_car_window_means.png`。

该版本有参考价值，但当前模型发布样本、AA 指标和关系编码已经迭代，主文不应直接混用旧结果。

### 2. `agent_tasks/econometric_robustness_20260613-210000`

这是目前最重要的历史稳健性任务。

输入为 `output/data/clean_event_firm_panel.csv` 和 `output/data/specr_rel_clean.csv`。输出包括：

- `run_econometric_robustness.R`
- `core_robustness_results.csv`
- `event_level_results.csv`
- `leave_one_creator_out_results.csv`
- `event_window_overlap_diagnostic.csv`
- `no_overlap_results.csv`
- `sample_summary.csv`
- `econometric_robustness_report.md`
- `final_interpretation.md`

完成的检验包括 firm FE、event cluster、firm cluster、two-way cluster、FF3 CAR、pre-event CAR、事件层聚合、leave-one-creator-out、美国交易标的粗口径和 20 日窗口重叠诊断。

关键结果如下。

- 全样本 firm FE 后 `intel_c` 系数 0.001537，event-cluster p = 0.0258，two-way p = 0.0520。
- 闭源 firm FE 后 `intel_c` 系数 0.002260，event-cluster p = 0.0010，two-way p = 0.0138。
- FF3 CAR[0,+20] 中，全样本系数 0.001018，p = 0.0254；闭源样本系数 0.001176，p = 0.0274。
- pre-event CAR 中，全样本 p = 0.576，闭源 p = 0.119，没有强证据显示发布前已被能力变量预测。
- 事件层聚合中，闭源全体公司均值显著，显性关系公司均值不显著。
- leave-one-creator-out 下闭源结果总体为正且多数显著。
- 20 日窗口重叠严重，47 个 intelligence 事件中只有 4 个没有前后 20 日内其他 intelligence 事件。

### 3. `agent_tasks/publishable_results_inventory_20260613-233641.md`

该文件是论文可用结果清单。它把当前最适合进正文和附录的结果排序。

建议正文主线为三点。

- 闭源模型能力定价。
- firm FE 和 FF3 后仍成立。
- 开源发布削弱能力定价斜率。

建议附录包括规格曲线、Tier、季度体制、owner 短窗口、行业、Mag7、FinBERT 情感、竞争者和 investor/cloud 交互。

### 4. `agent_tasks/full_length_paper_gap_assessment_20260614.md`

这是长文缺口评估。它指出当前结果足够支撑短文，但长文还需要更严格的事件库、发布时可观察信息、媒体关注和叙事强度、公司 AI 暴露和关系强度、更干净证券样本、更完整因子、事件窗口重叠处理、placebo 和日度事件时间回归。

该文件与本轮从 `proposal.md` 得出的缺口一致。

### 5. `agent_tasks/frl_submission_20260614-091455`

这是投稿包目录。包含 `frl_submission_main.tex`、`frl_online_appendix.tex`、cover letter、highlights、data availability statement、submission readme、submission risk review 和若干图形。

该目录服务 FRL 短文，不是 full proposal 的完整执行。

## 七、已经实现的分析

### 1. 样本构建和数据清洗

已完成。

包括 60 个事件、86 家公司、约 5,160 条事件公司观测的面板，清洗报告、数据字典、变量重命名表、事件层概况和事件公司平衡表均已产出。

### 2. 主回归

已完成。

核心模型为：

```text
CAR_ij = beta * aa_intelligence_index_i
       + firm controls_j
       + year fixed effects
       + error_ij
```

标准误按事件聚类。结果显示全样本和闭源样本的 CAR[0,+20] 都为正，闭源更强。

### 3. 规格曲线

已完成。

四个能力指标、七个 CAR 窗口、三组控制、多个子样本、年份 FE 有无都已跑。AA Intelligence Index 是最稳的能力指标。AA Media Elo 更偏短窗口即时效应。AA Math Index 不稳定。

### 4. 关系异质性

部分完成。

已有关系版规格曲线、real downstream、competitor、listed US creator 和 closed-source 子样本回归。结果表明 competitor 没有显著负向能力斜率，real downstream 点估计较大但样本太小。

### 5. 开源闭源机制

已完成短文版。

闭源斜率正且稳健。`intel_c × is_open_weight` 为负，表示开源发布削弱能力定价斜率。该结果是当前论文最清楚的机制。

### 6. owner、investor、cloud 交互

部分完成。

owner 短窗口为负且较稳。investor 和 cloud 交互在 CR0 或 CR2 中有一定信号，但 wild bootstrap 较弱，适合附录或探索性说明。

### 7. 行业和 Mag7

已完成附录型分析。

软件、半导体、互联网服务和基础设施子样本中能力斜率更明显。Mag7 与 non-Mag7 的斜率差异不显著，但个体平均 CAR 分化很大。

### 8. 媒体情感

部分完成。

FinBERT 情感均值对 CAR[0,+20] 的系数为负且显著。加入情感后，intelligence 的结果没有完全消失。事件层上 intelligence 对 sentiment 的解释不显著，`intelligence × sentiment` 也不显著。

这支持“不是单纯 hype”的短文叙述，但还不能支持 proposal 中完整 H4。

### 9. 时间演变

部分完成。

已有年份分组、趋势交互和季度定价斜率。结果显示 2025 年之后能力定价更强，季度层面以 2025Q3 最明显。但季度事件数少，属于 suggestive。

### 10. 稳健性

已完成一批强稳健性。

包括 firm FE、event/firm/two-way cluster、FF3 CAR、pre-event CAR、event-level aggregation、leave-one-creator-out、美国交易标的粗口径、窗口重叠诊断。

## 八、尚未完成或不充分的分析

### 1. ASVI 和搜索关注度

未完成。

`proposal.md` 明确要求 firm-level ASVI、model-level search intensity、creator-level search intensity、event-level attention index。当前数据和脚本没有这些变量。`search_code_1` 和 `search_code_2` 只是公司搜索代码，不是异常搜索量。

需要补做的数据和脚本包括：

- 搜索词表，覆盖 ticker、公司名、模型名、真实发布者名、事件关键词。
- 基准期和事件期定义，建议先做事件日前 56 个自然日基准，事件期 [-1,+1] 和 [0,+2]。
- ASVI 变量表，按 event-firm、event、model、creator 四个口径输出。
- 回归表，加入 `aa_intelligence_index`、ASVI、媒体情感及其交互。

### 2. 媒体情感分歧和新闻数量

未完整完成。

已有 `media_sent_sd_w*` 曾在 clean panel 中出现，但关系版回归脚本主要使用情感均值，未系统检验 sentiment standard deviation。也没有新闻条数、媒体类别、Top-tier 媒体、财经媒体和科技媒体拆分。

需要补做：

- `sentiment_sd` 主效应。
- `sentiment_sd × intelligence`。
- `sentiment_mean × relationship_role`。
- 正面和负面情感非对称，或 `sentiment_mean × I(sentiment_negative)`。
- 新闻数量和媒体类型控制。
- FinBERT、VADER、TextBlob 或 LLM 情感打分对比。
- 人工抽检情感一致性。

### 3. 成本效率、价格、速度和 TTFT

未完成主回归。

AA 数据和报告中有 price、speed、latency 字段，`reports/aa_master_database_codebook.md` 和 `reports/aitimeline_model_events_enriched_codebook.md` 都说明了字段来源。但 `specr_rel_clean.csv` 和当前主回归表未使用这些变量。

需要补做：

- 把 `price_1m_input_tokens`、`price_1m_output_tokens`、`price_1m_blended_3_to_1`、`median_output_tokens_per_second`、TTFT 或 latency 并入关系版回归底表。
- 构造 `capability / price`、`speed_adjusted_capability`、low-price-high-capability dummy。
- 单独报告 LLM 子样本，避免与 media Elo 混用。

### 4. 能力跃迁和 frontier rank

未完成。

当前能力变量主要是绝对 AA 指标。proposal 要求相对能力、同发布者上一代跃迁、frontier gap、within-modality rank percentile。当前没有看到这些变量进入输出表。

需要补做：

- 按 creator 和 model family 排序，计算相邻代际能力差。
- 在同一 release quarter 或同一 modality 内计算 percentile。
- 生成 frontier gap。
- 处理模型家族发布时代表变体选择规则。

### 5. 事件纯净性和混淆事件剔除

未完成可复现回归。

proposal 要求事件窗口中财报、并购、监管、诉讼、高管、融资分红等混淆事件剔除或标记。当前没有看到 firm-event 层面 confounding event flag 的回归表。

需要补做：

- 事件公司层的混淆事件标记表。
- 剔除混淆事件后的主回归和核心表。
- 把剔除比例和保留样本说明写入附录。

### 6. 低置信匹配和高置信暴露关系稳健性

未完成。

AA 匹配质量在 reports 中已有讨论，但主回归未看到剔除低置信 AA 匹配的表。关系暴露也缺少 `manual_exposure_confidence` 和证据来源，因此不能执行高置信关系样本检验。

需要补做：

- 低置信 AA 匹配剔除。
- 只保留 confirmed usable AA 指标。
- 只保留 high confidence exposure。
- `weak_related_entity` 排除或单独附录。

### 7. FF5、行业因子和 AI basket 因子

未完成。

已有 FF3，不见 FF5、momentum factor、Nasdaq-adjusted、industry-adjusted、SOX/software/cloud factor、AI basket factor。

对于短文，FF3 已经够用。对于完整 proposal 或长文，这仍是缺口。

### 8. Placebo 和日度多事件控制

未完成。

历史稳健性任务明确说明，当前只有既定事件窗口 CAR，没有底层日收益，因此无法做严格 placebo event date。20 日窗口重叠严重，严格处理需要回到底层日收益。

需要补做：

- 随机或提前 30 个交易日的 placebo event date。
- firm-day 日度事件时间面板。
- calendar-time portfolio regression。
- 多事件重叠控制，或同日同 creator 事件合并。

### 9. 2022 至 2023 年早期事件

未完成。

proposal 讲的是 2022 年 11 月 ChatGPT 之后的重大模型发布，但当前可回归 60 事件样本集中在 2024 至 2026 年。早期 GPT-4、Claude 1、Gemini 1 等事件不在当前主样本回归中。

需要补做：

- 2022-11 至 2023-12 的事件补录。
- 早期事件关系公司池。
- AA 指标可用性和历史可观察能力代理。
- 与现有 2024 至 2026 样本合并后的主回归。

### 10. 产品和研究系统排除样本的透明附录

部分完成但未形成最终表。

reports 中有候选事件和 clean report，但未看到最终 Excluded Product/Event Sample 表和附录回归。

需要补做：

- 主样本、LLM capability sample、media capability sample、excluded sample 的四层清单。
- 每个排除事件的排除理由。
- 产品事件扩展样本作为附录稳健性，而不混入主样本。

## 九、建议的后续执行顺序

如果目标是继续推进短文投稿，优先级如下。

1. 修正论文文本和引用占位符。
2. 把 firm FE、pre-event CAR、FF3 和 open-weight interaction 放进主表或附录表。
3. 对媒体情感结果降调，写成替代解释或辅助检验。
4. 明确说明 20 日窗口重叠是限制。
5. 不再扩展过多机制，避免短文失焦。

如果目标是完整兑现新版 `proposal.md`，优先级如下。

1. 补 ASVI 和 media volume。
2. 补 price、speed、TTFT 和 capability efficiency。
3. 补 high-confidence matching 和 high-confidence relationship 样本。
4. 补混淆事件标记和剔除回归。
5. 回到底层日收益做 placebo 和多事件控制。
6. 扩展 2022 至 2023 年事件。
7. 再补媒体分歧度、媒体类别、情感模型替换和人工验证。

## 十、最适合写进论文的现有结论

当前最稳的论文结论是：

金融市场并不平均奖励所有 AI 模型发布。市场更稳定地定价闭源模型中的可占有能力。AA Intelligence Index 在闭源样本中对 CAR[0,+20] 有显著正向关系，加入 firm FE、FF3 CAR、pre-event CAR 检验和 leave-one-creator-out 后总体仍成立。开源发布削弱这一能力定价斜率。媒体情感结果显示，正面叙事本身不能解释能力定价，甚至与后续 CAR 呈负相关，但该机制仍应保守表述。

当前不宜写成的强结论包括：

- 已完整检验 ASVI 或市场关注机制。
- 已识别媒体情感的因果机制。
- 已解决 20 日窗口重叠。
- 已证明直接竞争者系统性受损。
- 已证明所有关系暴露路径都符合 proposal 预测。
- 已证明市场从 hype-driven 线性转向 capability-driven。现有证据只支持阶段性变化的探索性说法。

