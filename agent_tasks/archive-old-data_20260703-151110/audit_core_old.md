# 归档审计子代理 A

生成时间 20260703-151403，时区 Asia/Shanghai。

审计范围为根目录一层、`data/`、`task/`、`scripts/`、`reports/`。本次没有移动、删除或改写项目文件，只写入本审计文件。

## 判断基准

高置信旧数据链路的主要特征如下。

- 样本口径为 60 个模型发布事件、86 家公司、5,160 条事件公司观测。
- 文件名或报告指向 `事件集数据.csv`、`事件集数据-new.csv`、`事件集数据-relationships.csv`、`final_60_event_sample`、AI Timeline 与 Artificial Analysis 旧匹配流程。
- 关系编码来自旧样本，包含 owner、investor、cloud、business_upstream、real_upstream、business_downstream、real_downstream、competitor，或旧样本上的 8 维仲裁结果。
- `data/README.md` 明确写明当前 panel 为 5,160 observations、60 events、86 companies。
- `reports/cleaning_report.md` 和 `data/source_reports/cleaning_report.md` 明确写明旧面板 5,160 行，并说明每个事件覆盖 86 家公司、共 60 个事件。

## 高置信归档候选

| 候选路径 | 判断理由 | 建议归档路径 |
| --- | --- | --- |
| `data/` | 整个目录是旧数据层整合。README 写明从 `reports/`、`task/`、`output/data/`、`output/tables/` 汇总而来，核心 panel 为 60 事件、86 公司、5,160 行。 | `old/data/` |
| `data/canonical/` | 从旧 panel 抽取的 company、event、relationship、metric、manifest 表。 | `old/data/canonical/` |
| `data/intermediate/` | 旧 AI Timeline 与 AA 匹配流程的人工复核、中间匹配、低置信和未匹配清单。 | `old/data/intermediate/` |
| `data/panel/` | 旧回归面板和 specr 输入，包括 `clean_event_firm_panel.csv`、`specr_input_clean.csv`、`specr_rel_clean.csv`，均为 5,161 行含表头，对应旧 5,160 条观测。 | `old/data/panel/` |
| `data/relationships/` | 旧样本上的 Coder A/B、kappa、仲裁结果和关系 codebook。`adjudicated_event_level.csv` 为 5,161 行含表头，`adjudicated_company_creator.csv` 为旧发布方公司关系表。 | `old/data/relationships/` |
| `data/results_tables/` | 旧 panel 的回归结果、规格曲线结果、异质性表、季度结果、事件层汇总和 HTML 表。 | `old/data/results_tables/` |
| `data/source_reports/` | 旧数据链路报告的镜像，内容覆盖 AA 抓取、AI Timeline 抽取、最终 60 事件样本、清洗、官方日期核验、specr 报告等。 | `old/data/source_reports/` |
| `data/quality_checks/` | 旧数据层 consolidation check。 | `old/data/quality_checks/` |
| `data/raw/` | 旧链路的 raw 占位目录，包含 `aitimeline/` 与 `artificial_analysis/`。未见新数据集专用内容。 | `old/data/raw/` |
| `data/raw_external_paths/` | 旧整合时记录缺失 raw 文件的清单。 | `old/data/raw_external_paths/` |
| `reports/` | 旧数据链路的原始报告目录。多数文件在 `data/source_reports/` 有镜像，内容指向 AI Timeline、AA、最终 60 事件、旧清洗和旧 specr。 | `old/reports/` |
| `scripts/analysis/` | 旧回归脚本目录。脚本读取 `specr_input_clean.csv`、`specr_rel_clean.csv`、`事件集数据-new.csv` 等旧输入。 | `old/scripts/analysis/` |
| `scripts/prep/` | 旧清洗和转换脚本目录。脚本输入包括 `事件集数据.csv`、`事件集数据-new.csv`、`task/事件集数据-relationships.csv`，输出旧 panel 或旧 specr 输入。 | `old/scripts/prep/` |
| `scripts/analysis 2/` | 空的复制副本目录。 | `old/scripts/analysis 2/` |
| `scripts/prep 2/` | 空的复制副本目录。 | `old/scripts/prep 2/` |
| `task/agent_tasks/merge_regression_202606110558/` | 旧合并任务。`merge_engine.py` 明确合并 `事件集数据-new 2.csv` 和 `firm_model_relationships.csv`，输出 `事件集数据-relationships.csv`。 | `old/task/agent_tasks/merge_regression_202606110558/` |
| `task/agent_tasks/merge_regression_202606110558 2/` | 旧合并任务的复制目录，目录名显示为副本。 | `old/task/agent_tasks/merge_regression_202606110558 2/` |
| `task/prompt.md` | 旧关系重编码提示，引用旧关系文件与旧分类变动。 | `old/task/prompt.md` |
| `task/prompt 2.md` | 上一项的复制副本。 | `old/task/prompt 2.md` |
| `6.21事件集数据.csv` | 根目录旧事件公司面板，5,162 行含中文表头和英文表头，旧链路核心输入。 | `old/root/6.21事件集数据.csv` |
| `6.21事件集数据(1).csv` | 上一项的复制副本，5,162 行。 | `old/root/6.21事件集数据(1).csv` |
| `relationship_data_final.csv` | 根目录旧关系合并数据，5,161 行含表头。 | `old/root/relationship_data_final.csv` |
| `relationship_data_final 2.csv` | 上一项的复制副本。 | `old/root/relationship_data_final 2.csv` |
| `result.md` | 旧结果汇总，开头写明数据为 `事件集数据-relationships.csv`，正文为 60 事件、5,161 条配对观测、旧 8 类关系。 | `old/root/result.md` |
| `result 2.md` | 上一项的复制副本。 | `old/root/result 2.md` |
| `relationship_specr_newrel_report.md` | 基于旧 `data/panel/specr_rel_clean.csv` 的新关系 specr 报告，仍是 60 事件旧样本。 | `old/root/relationship_specr_newrel_report.md` |

## 需要主代理复核的根目录候选

这些文件明显引用旧样本或旧结果，但属于写作、计划或方法讨论，不是纯数据和脚本。若本轮目标是清空旧数据链路，可以归档。若仍需保留写作脉络，建议先不自动移动。

| 候选路径 | 判断理由 | 建议归档路径 |
| --- | --- | --- |
| `PAPER_B_WRITING_PLAN.md` | 多处写明 60 事件、86 公司、5,160 观测，并引用旧 `data/relationships/` 和旧稳健性任务。 | `old/root/PAPER_B_WRITING_PLAN.md` |
| `paper_plan.md` | 写明 60 events、86 家公司、AA 数据和旧编码被新 8 维替代。 | `old/root/paper_plan.md` |
| `paper_plan 2.md` | 上一项的复制副本。 | `old/root/paper_plan 2.md` |
| `prompt.md` | 旧英文写作提示，写明 sample 为 60 LLM release events、86 firms。 | `old/root/prompt.md` |
| `prompt 2.md` | 上一项的复制副本。 | `old/root/prompt 2.md` |
| `Long_prompt.md` | 明确引用 60 次模型发布、86 家公司、5,160 条观测，并指出旧稿问题。 | `old/root/Long_prompt.md` |
| `to_do_align_proposal.md` | 讨论从当前 60 事件扩至 100+ 事件，属于旧链路扩展计划。 | `old/root/to_do_align_proposal.md` |
| `to_do_align_proposal 2.md` | 上一项的复制副本。 | `old/root/to_do_align_proposal 2.md` |
| `long_tex_gap_analysis.md` | 旧稿差距分析，含旧表和旧 AA 结果脉络，但不是数据链路核心文件。 | `old/root/long_tex_gap_analysis.md` |
| `long_tex_gap_analysis 2.md` | 上一项的复制副本。 | `old/root/long_tex_gap_analysis 2.md` |
| `research proposal.md` | 旧研究计划草稿，围绕已构建事件集数据和旧产业链角色叙述。 | `old/root/research proposal.md` |
| `research proposal 2.md` | 上一项的复制副本或旧版。 | `old/root/research proposal 2.md` |
| `research proposal.docx` | 旧研究计划 Word 文档。 | `old/root/research proposal.docx` |
| `research proposal 2.docx` | 上一项的复制副本或旧版。 | `old/root/research proposal 2.docx` |
| `6.21research proposal.docx` | 日期命名的旧 proposal 文档。 | `old/root/6.21research proposal.docx` |
| `6.21research proposal(1).docx` | 上一项的复制副本。 | `old/root/6.21research proposal(1).docx` |
| `proposal.md` | 当前看更像方法设计文档，引用 AA master database 和候选事件流程。是否旧链路专属不如上面文件明确。 | `old/root/proposal.md`，仅在清理旧草稿时移动 |
| `proposal 2.md` | 上一项的复制副本或旧版。 | `old/root/proposal 2.md`，仅在清理旧草稿时移动 |

## 不应移动的边界文件

以下不建议在本轮旧数据链路归档中移动。

- `agent_tasks/archive-old-data_20260703-151110/`，当前任务工作目录。
- `to_do_rebuild_regression_20260702.md`，明确说明新数据重建计划，且写明旧 60×86 面板不可复用。
- `数据问题与欠缺清单_20260703.md`，当前新数据问题清单，包含新旧结果对比和后续新链路任务。
- `new data set/`，根目录下的新数据集目录。未深入审计，但名称和当前用户语境指向新链路。
- `事件标签/`，当前新事件标签工作区，上一轮已生成 Coder B 标签。
- `关系标签/`，当前新公司发布方关系标签工作区，上一轮已生成 Coder B 标签。
- `事件集筛选/`、`企业列表/`，名称指向新事件筛选和新公司池，应由新链路审计确认后再处理。
- `.git/`、`.gitignore`，版本控制文件。
- `.claude/`、`.obsidian/`，本地工具配置。
- `task/.claude/settings.local.json`，任务目录内的本地工具配置，不是旧数据产物。
- `.DS_Store`、`data/.DS_Store`、`task/.DS_Store`，系统文件。它们可以清理，但不属于旧数据链路归档对象。
- `Tex/`、`Analysis/`、`CAR/`、`Exploration/`、`Fundamentals/`、`Literature/`、`output/`、`archive/`，不在本审计指定深度内，不能据此下归档结论。
- `可能需要修改的地方.docx`、`选择性关注、鸵鸟效应与市场异象_权小锋.pdf`，没有在本轮限定审计中看到明确旧数据链路证据。

## 建议执行顺序

1. 先归档高置信的数据和报告目录，也就是 `data/`、`reports/`。
2. 再归档旧脚本目录 `scripts/analysis/`、`scripts/prep/` 和空副本目录。
3. 然后归档旧任务产物 `task/agent_tasks/merge_regression_202606110558/`、`task/prompt.md`、`task/prompt 2.md`。
4. 最后处理根目录旧 CSV 和高置信旧结果报告。
5. 根目录写作草稿按“需要主代理复核”列表单独决定，避免误移仍有参考价值的新稿或方法设计文档。

## 归档后建议校验

- 检查根目录不再有 60×86 旧面板 CSV。
- 检查 `scripts/` 下不再有读取 `事件集数据-new.csv`、`specr_rel_clean.csv`、`task/事件集数据-relationships.csv` 的旧脚本。
- 检查 `data/` 和 `reports/` 已整体进入 `old/`，或在根目录被删除为空目录。
- 检查新链路目录 `new data set/`、`事件标签/`、`关系标签/`、`事件集筛选/`、`企业列表/` 未被移动。
