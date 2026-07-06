# 归档审计子代理 B 报告

审计时间为 20260703-151507，北京时间。

本次只读取目录结构、文件名、任务计划和当前归档脚本。未移动、删除或重命名任何项目文件。唯一写入内容是本报告。

## 审计范围

覆盖以下目录和对象。

| 对象 | 观察结果 |
| --- | --- |
| `agent_tasks/` | 约 22M，一级项目 35 个，主要是 2026-05 到 2026-06 的历史任务产物，另有 2026-07 新数据任务 |
| `archive/` | 约 147M，只有 `old_relationship_20260625/`，已经是旧关系链路归档 |
| 嵌套同名项目目录 | `大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/`，约 135M，含旧版 `data/`、`scripts/`、`output/`、`task/` 和旧 `agent_tasks/` |
| `task/` | 约 80K，根目录下只剩旧 prompt 和 `merge_regression_202606110558` 任务 |
| `Tex/Old/` | 旧 TeX 快照和编译产物 |
| `new data set/* 2` | 五个空目录，分别为 `agent_tasks 2`、`processed 2`、`raw 2`、`reports 2`、`scripts 2` |
| 当前归档任务脚本 | `agent_tasks/archive-old-data_20260703-151110/archive_old_files.py` 已列出大部分旧链路迁移项 |

## 总体判断

建议把旧数据链路和历史任务产物统一归入 `old/`，但保留 2026-07 新数据链路。当前根目录已经形成两套体系。旧体系集中在 `data/`、`scripts/`、`reports/`、`output/`、`task/`、`archive/old_relationship_20260625/` 和嵌套同名目录。新体系集中在 `new data set/`、`Analysis/`、`CAR/`、`Fundamentals/`、`事件标签/`、`关系标签/`、`企业列表/`、`事件集筛选/`。

当前归档脚本的方向基本正确。它会保留新数据链路，并把多数旧目录按原相对路径移动到 `old/`。但脚本遗漏了几个顶层历史任务说明文件，也没有处理空的 `new data set/* 2` 冲突目录。

## 建议归档

| 路径 | 建议 | 原因 | 风险 |
| --- | --- | --- | --- |
| `archive/old_relationship_20260625/` | 归档到 `old/archive/old_relationship_20260625/` | 已在 `archive/` 内，内容是 2026-06-25 旧关系链路和旧回归产物 | 低。保留原相对路径即可回溯 |
| `大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/` | 整体归档 | 嵌套同名项目目录，约 135M，结构像旧项目副本，含旧 `data/`、`scripts/`、`task/` 和旧任务 | 中。可能有人把它当备份用，移动前应确认不作为当前工作目录 |
| `task/` | 整体归档 | 只含旧 prompt 和 `merge_regression_202606110558`，未见新数据链路依赖 | 低 |
| `Tex/Old/` | 归档 | 目录名已标明旧版，含 `llm_paper` 和编译中间文件 | 低 |
| `agent_tasks/analysis_report_20260521-133006` | 归档 | 旧分析报告和旧样本输出 | 低到中。可作为旧结论追溯材料 |
| `agent_tasks/event_data_cleaning_202606021351` | 归档 | 旧事件数据清洗审计 | 低 |
| `agent_tasks/data_consolidation_20260614-122508` | 归档 | 旧数据整合任务 | 低 |
| `agent_tasks/econometric_robustness_20260613-210000` | 归档 | 旧稳健性结果和脚本 | 低到中。旧论文结果复现会用到 |
| `agent_tasks/frl-draft_20260611-134549` | 归档 | 旧 FRL 草稿任务，含 LaTeX 中间文件和重复副本 | 低 |
| `agent_tasks/frl_project_review_20260613-204658` | 归档 | 旧项目审阅任务 | 低 |
| `agent_tasks/frl_project_review_20260613-204850` | 归档 | 旧项目审阅任务，内容很小 | 低 |
| `agent_tasks/frl_submission_20260614-091455` | 归档 | 旧投稿包和编译产物 | 低到中。若还要追溯旧投稿版本，需要从 `old/` 找回 |
| `agent_tasks/latex_paper_2026061100` | 归档 | 旧 LaTeX 任务 | 低 |
| `agent_tasks/proposal_gap_analysis_20260619-092947` | 归档 | 旧 proposal 缺口分析和补充脚本 | 低 |
| `agent_tasks/proposal_gap_completion_20260619-104007` | 归档 | 旧 proposal 补全任务 | 低 |
| `agent_tasks/publishable_results_inventory_20260613-233641.md` | 归档 | 旧可发表结果盘点 | 低 |
| `agent_tasks/publishable_results_inventory_20260613-233641 2.md` | 归档 | 同名冲突副本 | 低 |
| `agent_tasks/full_length_data_collection_todo_20260614.md` | 归档 | 旧长文数据收集清单 | 低 |
| `agent_tasks/full_length_data_collection_todo_20260614 2.md` | 归档 | 同名冲突副本 | 低 |
| `agent_tasks/full_length_paper_gap_assessment_20260614.md` | 归档 | 旧长文缺口评估 | 低 |
| `agent_tasks/ref_audit_20260625-233637` | 归档 | 旧参考文献审计任务 | 低 |
| `agent_tasks/lit_review_long_new_20260625-194602` | 归档 | 旧长文文献综述任务 | 低 |
| `agent_tasks/paper_b_robustness_2026062514` | 归档 | 旧 Paper B 稳健性任务 | 低到中 |
| `agent_tasks/car_pre_control_20260627` | 归档 | 旧 CAR 预控制任务，不是 2026-07 新 CAR 数据收集 | 中。若新面板仍引用其中输出，需先确认引用 |
| `agent_tasks/specr_star_scan_20260627` | 归档 | 旧 specification scan 任务 | 低到中 |
| `agent_tasks/relationship_coding_20260624-184054` | 归档 | 空目录，历史关系编码任务残留 | 低 |
| `agent_tasks/relationship_coding_20260624-184413` | 归档 | 旧 Coder B 关系编码任务 | 低 |
| `agent_tasks/relationship_coding_20260624-205216` | 归档 | 旧分批关系编码任务 | 低 |
| `agent_tasks/coder_a_relationship_coding_2026062418` | 归档 | 旧 Coder A 关系编码任务 | 低 |
| `agent_tasks/coder_ab_discrepancy_audit_20260624-211116` | 归档 | 旧 A/B 分歧审计 | 低 |
| `agent_tasks/relationship_merge_20260625-0005` | 归档 | 旧关系合并验证任务 | 低 |
| `agent_tasks/relationship_recode_switch_2026062500` | 归档 | 旧关系口径切换任务 | 低 |
| `agent_tasks/relationship_specr_newrel_20260625-005125` | 归档 | 旧关系口径下的 specification 任务 | 低到中 |
| `agent_tasks/event_selection_provenance_2026062515` | 归档，但保留在 `old/` 中 | 旧事件选择来源追踪。可能对理解旧 60 事件有用，但不应留在当前链路根目录 | 中。它可能解释旧新样本差异，所以不要删除 |
| `new data set/agent_tasks 2` | 归档或删除空目录 | 0B 空冲突目录 | 低 |
| `new data set/processed 2` | 归档或删除空目录 | 0B 空冲突目录 | 低 |
| `new data set/raw 2` | 归档或删除空目录 | 0B 空冲突目录 | 低 |
| `new data set/reports 2` | 归档或删除空目录 | 0B 空冲突目录 | 低 |
| `new data set/scripts 2` | 归档或删除空目录 | 0B 空冲突目录 | 低 |

## 建议保留

| 路径 | 建议 | 原因 | 风险 |
| --- | --- | --- | --- |
| `agent_tasks/archive-old-data_20260703-151110` | 保留 | 当前归档任务工作区，含计划、脚本和本报告 | 低 |
| `agent_tasks/car_data_collection_20260702-181321` | 保留 | 新 CAR 数据收集任务证据 | 中。移动会削弱新 CAR 可追溯性 |
| `agent_tasks/fundamentals_collection_20260702-223530` | 保留 | 新财务数据收集任务证据 | 中 |
| `agent_tasks/timestamp_events_20260702-110203` | 保留 | 新事件日期核证任务，和 2026-07 新样本有关 | 中 |
| `new data set/` | 保留 | 新事件重建主链路，含 raw、processed、decisions、evidence、reports、scripts | 高。移动会破坏标签和分析链路 |
| `Analysis/` | 保留 | 新面板和新回归结果，引用 `new data set/`、`CAR/` 和 `Fundamentals/` | 高 |
| `CAR/` | 保留 | 新 CAR 输入、行情数据和检查报告 | 高 |
| `Fundamentals/` | 保留 | 新财务控制变量数据 | 高 |
| `事件标签/` | 保留 | 2026-07 新事件标签和 A/B 分歧结果 | 高 |
| `关系标签/` | 保留 | 2026-07 新关系标签和 A/B 分歧结果 | 高 |
| `企业列表/` | 保留 | 新公司 universe 源文件 | 中 |
| `事件集筛选/` | 保留 | 新 134 事件交付和原始 AA/AI Timeline 资料 | 中到高 |
| `Tex/` 除 `Tex/Old/` 外 | 暂保留 | 当前论文草稿和编译产物在这里。旧稿是否迁移应由写作主线判断 | 中 |
| `Literature/` | 保留 | 文献资料，不属于旧数据产物 | 低 |
| `README.md`、`Long_prompt.md`、`to_do_rebuild_regression_20260702.md`、`数据问题与欠缺清单_20260703.md` | 保留 | 当前说明、提示和 2026-07 任务清单 | 低到中 |

## 当前脚本审计

`archive_old_files.py` 已覆盖这些重点旧项。

- 旧根目录数据和草稿文件，包括 `6.21事件集数据.csv`、`relationship_data_final.csv`、旧 proposal、旧 result 和旧 paper plan。
- 旧目录树，包括 `data/`、`scripts/`、`reports/`、`output/`、`task/`、`archive/`、`Tex/Old/`。
- 嵌套同名项目目录。
- 大部分旧 `agent_tasks/` 子目录。
- 新链路保留清单，包括 `new data set/`、`Analysis/`、`CAR/`、`Fundamentals/`、`事件标签/`、`关系标签/`、`企业列表/` 和三个 2026-07 新数据任务。

建议在执行前补充这些遗漏项。

- `agent_tasks/full_length_data_collection_todo_20260614.md`
- `agent_tasks/full_length_data_collection_todo_20260614 2.md`
- `agent_tasks/full_length_paper_gap_assessment_20260614.md`
- `agent_tasks/publishable_results_inventory_20260613-233641.md`
- `agent_tasks/publishable_results_inventory_20260613-233641 2.md`
- `new data set/agent_tasks 2`
- `new data set/processed 2`
- `new data set/raw 2`
- `new data set/reports 2`
- `new data set/scripts 2`

建议保留脚本当前的冲突保护逻辑。`unique_dest()` 会避免覆盖 `old/` 中已有同名路径。

## 主要风险

1. 嵌套同名项目目录体量大，像完整旧快照。整体移动是合理的，但执行前最好确认当前工作目录不是这个嵌套目录。
2. `data/`、`scripts/`、`reports/` 和 `output/` 是旧链路核心。移动后旧脚本会失效，但这正是归档目标。若还要跑旧结果，应从 `old/` 下运行或修路径。
3. `event_selection_provenance_2026062515` 可能有旧新样本对照价值。建议归档而不是删除。
4. `car_pre_control_20260627` 与 CAR 有关，但不是 7 月新 CAR 数据链路。若主代理担心遗漏引用，可先搜索 `car_pre_control` 和该目录下输出名。
5. 大量 ` 2` 文件和目录来自冲突副本。随父目录移动即可。空的 `new data set/* 2` 可以清理，但若未来要做严格审计，仍建议先记入 manifest。
6. `.DS_Store`、`__pycache__`、LaTeX 编译中间文件和 `.pyc` 属于清理项。若在旧目录内，跟随归档即可。当前新链路里的编译中间文件不必在这次旧数据归档中处理。

## 结论

建议主代理采用现有 `archive_old_files.py` 作为执行基础，并补上本报告列出的遗漏项。执行后应至少检查这些路径仍在原位。

- `new data set/processed/final_event_sample_main.csv`
- `new data set/decisions/event_label_decisions.csv`
- `new data set/decisions/relationship_decisions.csv`
- `Analysis/processed/event_firm_panel.csv`
- `CAR/processed/returns_daily_long.csv`
- `Fundamentals/processed/fundamentals_quarterly_wide.csv`
- `事件标签/coder_AB_discrepancies_20260703.csv`
- `关系标签/coder_AB_discrepancies_20260703.csv`

建议移动完成后生成 manifest，并在 `old/` 中保留原相对路径。这样既能清爽当前项目，也能保留旧结果复核入口。
