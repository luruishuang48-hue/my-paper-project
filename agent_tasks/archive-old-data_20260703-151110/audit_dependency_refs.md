# 依赖引用扫描审计

扫描时间：20260703-151249，Asia/Shanghai。

身份：归档审计子代理 C。

任务边界：只扫描引用，不移动、不修改项目文件。除本审计文件外未写入项目内容。

## 扫描范围

重点目录如下。

- `new data set/`
- `Analysis/`
- `CAR/`
- `Fundamentals/`
- `Tex/`
- `事件标签/`
- `关系标签/`
- `企业列表/`

重点旧候选路径和关键词如下。

- `data/`
- `scripts/`
- `reports/`
- `output/`
- `relationship_data_final`
- `6.21事件集数据`
- `main_model_release_events`
- `final_60_event_sample`
- `old60_vs_ai_timeline61`
- `aitimeline_model_events_enriched`
- `archive/old_relationship_20260625`
- `processed 2`、`raw 2`、`scripts 2`、`reports 2`、`figures 2`、`tables 2`

## 结论

新主链路没有发现对旧 `data/` 面板、旧 `scripts/`、旧 `reports/` 的运行依赖。

当前仍读旧数据的明确位置只有新旧样本对比脚本。这个脚本是诊断和回溯用途，不是新主样本、CAR、Fundamentals、Analysis 面板的必要输入。

需要保留或打包处理的风险点有三个。

- 新旧对比脚本读旧面板。
- 事件标签目录中有一份旧 codebook 指向过时的 `data/processed` 产物。
- `Tex/long_new.tex` 仍读顶层旧输出图形目录。

## 风险引用

### 1. 新旧对比脚本仍读旧面板

文件：`new data set/scripts/compare_old60_new61.py`

关键位置如下。

- 第 16 行，`OLD_PANEL = BASE.parent / "data" / "panel" / "clean_event_firm_panel.csv"`
- 第 124 行，`rows = read_csv(OLD_PANEL)`
- 第 361 行，报告文本写入 `data/panel/clean_event_firm_panel.csv`

依赖对象如下。

- `data/panel/clean_event_firm_panel.csv`

判断如下。

这是旧 60 事件样本和新 AI Timeline 样本的对比脚本。它不参与新主样本构造，不被 `CAR/scripts/`、`Fundamentals/scripts/`、`Analysis/scripts/` 调用。若把旧 `data/` 移走，此脚本单独重跑会失败。

处理建议如下。

- 若不再重跑旧新对比，把该脚本和对应 `old60_vs_*` 产物一起归档。
- 若仍要保留可复跑性，把旧面板随同该脚本一起归档，并在脚本中改为相对归档路径，或保留一个说明文件指向归档位置。

关联输出如下。

- `new data set/reports/old60_vs_ai_timeline61_comparison_report.md`
- `new data set/reports/old60_new61_two_groups.md`
- `new data set/processed/old60_vs_ai_timeline61_comparison.xlsx`
- `new data set/processed/old60_vs_ai_timeline61_objective_pairs.csv`
- `new data set/processed/old60_vs_ai_timeline61_old_view.csv`
- `new data set/processed/old60_vs_ai_timeline61_new_view.csv`
- `new data set/processed/ai_timeline_61_event_level.csv`

### 2. 事件标签目录有旧 codebook

文件：`事件标签/aitimeline_model_events_enriched_codebook.md`

关键位置如下。

- 第 3 行，说明旧脚本 `scripts/build_aitimeline_enriched_dataset.py`
- 第 7 行，指向 `data/processed/aitimeline_model_events_enriched.csv`
- 第 8 行，指向 `data/processed/aitimeline_model_events_enriched_media_categories_long.csv`

依赖对象如下。

- `scripts/build_aitimeline_enriched_dataset.py`
- `data/processed/aitimeline_model_events_enriched.csv`
- `data/processed/aitimeline_model_events_enriched_media_categories_long.csv`

判断如下。

这份文档属于旧整合表说明。当前 `事件标签/coder_A_make_labels.py` 和 `事件标签/coder_B_make_labels.py` 实际读取的是 `new data set/processed/` 下的新表。此 codebook 不构成运行依赖，但会误导后续复核人员。

处理建议如下。

- 可归档到 `old/`。
- 或替换为指向 `new data set/processed/final_event_sample_main.csv`、`event_aa_metrics.csv`、`ai_timeline_aa_model_matches.csv` 的新 codebook。

### 3. TeX 旧论文源仍读旧输出图

文件：`Tex/long_new.tex`

关键位置如下。

- 第 19 行，`\graphicspath{{../output/paper_plan_core/figures/}{output/paper_plan_core/figures/}}`
- 第 317、441、634、689、735 行分别引用 `figure1_position_effects.pdf` 到 `figure5_media_sentiment_effects.pdf`

依赖对象如下。

- `output/paper_plan_core/figures/figure1_position_effects.pdf`
- `output/paper_plan_core/figures/figure2_open_closed_effects.pdf`
- `output/paper_plan_core/figures/figure3_reasoning_code_effects.pdf`
- `output/paper_plan_core/figures/figure4_origin_effects.pdf`
- `output/paper_plan_core/figures/figure5_media_sentiment_effects.pdf`

判断如下。

如果 `output/paper_plan_core/` 是旧结果并被移动，`Tex/long_new.tex` 会无法编译。这个风险不影响新数据链路，但影响旧稿件复现。

处理建议如下。

- 若 `Tex/long_new.tex` 也归档，就把 `output/paper_plan_core/` 和它一起移动。
- 若保留 `Tex/long_new.tex`，不要单独移动 `output/paper_plan_core/figures/`，或先把图路径改到归档后的稳定位置。

## 非风险命中

这些命中不是旧数据依赖。

- `CAR/README.md` 中的 `scripts/fetch_car_inputs.py` 和 `reports/...` 指的是 `CAR/` 内部相对路径。
- `Fundamentals/README.md` 中的 `scripts/fetch_fundamentals.py` 和 `reports/...` 指的是 `Fundamentals/` 内部相对路径。
- `Analysis/README.md` 中的 `scripts/build_event_firm_panel.py` 和 `reports/...` 指的是 `Analysis/` 内部相对路径。
- `new data set/reports/data_rebuild_report.md` 中的 `/api/v2/data/...` 是 Artificial Analysis API 端点，不是本地旧 `data/` 目录。
- `new data set/agent_tasks/.../ai_timeline_probe.md` 中的 `scripts/convert_timeline_events.py` 是上游 GitHub 仓库路径，不是本地旧 `scripts/` 目录。
- `Analysis/reports/frl_capability_pricing_review_20260703.md` 写到 87 个有智能指数的 LLM 事件，是新面板的子样本描述，没有旧路径引用。

## 新主链路确认

以下可复跑脚本未发现旧 `data/` 读取依赖。

- `new data set/scripts/build_dataset.py`
- `new data set/scripts/build_strict_matches.py`
- `new data set/scripts/resolve_entities.py`
- `new data set/scripts/build_final_sample.py`
- `new data set/scripts/build_event_dates.py`
- `new data set/scripts/build_event_aa_metrics.py`
- `CAR/scripts/fetch_car_inputs.py`
- `CAR/scripts/validate_car_inputs.py`
- `Fundamentals/scripts/fetch_fundamentals.py`
- `Analysis/scripts/build_event_firm_panel.py`
- `Analysis/scripts/t9_main_regressions.R`
- `Analysis/scripts/t9_robustness_matrix.R`
- `Analysis/scripts/frl_capability_pricing.R`
- `事件标签/coder_A_make_labels.py`
- `事件标签/coder_B_make_labels.py`
- `关系标签/coder_A_make_relationship_codes.py`
- `关系标签/coder_B_make_relationship_codes.py`

主链路输入关系如下。

- `CAR/scripts/fetch_car_inputs.py` 读取 `new data set/processed/final_event_sample_main.csv` 和 `new data set/decisions/firm_universe_decisions.csv`
- `Fundamentals/scripts/fetch_fundamentals.py` 读取 `CAR/metadata/firm_universe_for_car.csv` 和 `CAR/processed/prices_daily_long.csv`
- `Analysis/scripts/build_event_firm_panel.py` 读取 `CAR/`、`Fundamentals/`、`new data set/processed/event_aa_metrics.csv`、`new data set/decisions/event_label_decisions.csv`、`new data set/decisions/relationship_decisions.csv`
- `事件标签/` 当前 A/B 脚本读取 `new data set/processed/`
- `关系标签/` 当前 A/B 脚本读取 `new data set/decisions/` 和 `new data set/processed/final_event_sample_main.csv`

## 可安全移动的旧候选

以下候选在指定八个目录的新主链路扫描中没有发现必要引用。移动前仍建议主代理做一次全库最终 `rg`，尤其是如果还要保留旧稿件编译。

### 顶层旧数据和旧脚本

- `data/`
- `scripts/`
- `scripts 2/`，如果存在
- `reports/`
- 顶层重复旧文件，如 `relationship_data_final.csv`、`relationship_data_final 2.csv`
- 顶层旧事件表，如 `6.21事件集数据.csv`、`6.21事件集数据(1).csv`

说明如下。

这些是旧 60 事件链路、旧关系编码、旧回归表、旧 source reports 和旧 prep/analysis 脚本。新主链路的脚本已转向 `new data set/`、`CAR/`、`Fundamentals/`、`Analysis/`。

### 旧结果输出

- `output/figures/`
- `output/tables/`
- `output/paper_plan_core/`

条件如下。

`output/paper_plan_core/` 需要和 `Tex/long_new.tex` 成组处理。若旧 TeX 不归档，不能单独移动 `output/paper_plan_core/figures/`。

### 新目录内的新旧对比产物

- `new data set/scripts/compare_old60_new61.py`
- `new data set/reports/old60_vs_ai_timeline61_comparison_report.md`
- `new data set/reports/old60_new61_two_groups.md`
- `new data set/processed/old60_vs_ai_timeline61_comparison.xlsx`
- `new data set/processed/old60_vs_ai_timeline61_objective_pairs.csv`
- `new data set/processed/old60_vs_ai_timeline61_old_view.csv`
- `new data set/processed/old60_vs_ai_timeline61_new_view.csv`
- `new data set/processed/ai_timeline_61_event_level.csv`

说明如下。

这些文件服务于旧 60 事件和新候选集之间的对比，不是新主样本继续运行所需输入。

### 旧说明文件

- `事件标签/aitimeline_model_events_enriched_codebook.md`

说明如下。

它描述旧 `aitimeline_model_events_enriched` 表。当前事件标签工作流已不读取这些旧表。

### 已归档旧关系材料

- `archive/old_relationship_20260625/`

说明如下。

这个目录本来已经是旧关系归档。可继续保留原位，也可移动到新的 `old/` 总归档下。

## 不建议归档的当前链路目录

这些目录虽然包含数据，但属于新数据链路，不建议作为旧数据移动。

- `new data set/raw/`
- `new data set/processed/`，除 `old60_vs_*` 对比产物外
- `new data set/decisions/`
- `new data set/scripts/`，除 `compare_old60_new61.py` 外
- `CAR/`
- `Fundamentals/`
- `Analysis/`
- `事件标签/` 当前 A/B 标签和规则文件
- `关系标签/` 当前 A/B 关系标签和规则文件
- `企业列表/`

## 归档前检查建议

建议主代理移动前再做两件事。

- 对计划移动清单做一次全库引用扫描，排除非目标目录中的临时笔记或旧稿件仍引用这些文件。
- 若要保留旧稿件复现，把 `Tex/long_new.*`、`output/paper_plan_core/`、旧 `data/` 和旧 `scripts/analysis/paper_plan_core_outputs.R` 放在同一个归档分组里。
