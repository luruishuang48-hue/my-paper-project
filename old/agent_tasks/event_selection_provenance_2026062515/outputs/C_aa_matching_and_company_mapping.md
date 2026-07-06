# C. AA数据库匹配与上市公司映射 —— 溯源结果

任务范围：`data/intermediate/` 下6个文件、`data/raw/artificial_analysis/`、`data/canonical/` 6个文件。
方法：用pandas逐个打开实际内容，并用 `grep -rl` 反查脚本，不依赖文件名猜测。

---

## 0. 核心结论先行

1. **这6个 `data/intermediate/*.csv` 文件不是由 `scripts/` 目录下任何现存脚本生成或读取的。**
   `grep -rl "<文件名>" scripts/` 全部无匹配（生成这些文件的原始脚本已不在本仓库中，可能在
   sibling 项目"Matrix I - Bandit与研发竞赛"里，也可能是一次性脚本未保留）。
   这6个文件是2026-06-14的一次"数据归拢"操作从 `reports/` **逐字节复制**过来的
   （已用 `diff` 逐个验证，6个文件与 `reports/` 下同名文件完全一致）。
2. **AA = Artificial Analysis 已确认**，是一个第三方模型能力评测API（不是公司内部数据库）。
   证据：`reports/aa_master_database_codebook.md` 明确写"Source: Official Artificial Analysis API only"，
   认证方式是 `ARTIFICIAL_ANALYSIS_API_KEY` 环境变量 + `x-api-key` 请求头。
3. **`data/raw/artificial_analysis/` 目录在本仓库中是空的。** 原始API响应JSON不在当前项目里。
   `data/raw_external_paths/missing_raw_files.csv` 记录了5个被引用但找不到的AA原始json文件，
   报告的路径指向另一个sibling项目：
   `.../Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/llms_models_2026-04-26.json` 等。
   也就是说**AA原始数据的获取和初步处理发生在另一个项目目录里**，本项目只继承了处理结果。
4. **关键修正（重要）**：原计划文档（plan.md）猜测 `scripts/prep/clean_event_panel.py`
   是把候选事件从236条收窄到60个的"主清洗脚本"。**这个猜测不成立。**
   `reports/cleaning_report.md` 第1节明确写该脚本的输入文件是
   `.../Matrix I - Bandit与研发竞赛/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/事件集数据.csv`，
   原始行数5161（清洗后5160），**输入文件本身就已经是 60 个事件 × 86 家公司的平衡面板**，
   `final_event_id`、`company_id`、`relationship`、`potential_us_exposure_type`、
   `possible_us_exposed_tickers` 等核心字段都已经存在于这个输入文件里。
   `clean_event_panel.py` 只做格式清洗（编码转换、日期标准化、列重命名、缺失值统计），
   **不做事件筛选、不做AA匹配、不做公司映射**——这些工作全部发生在 `事件集数据.csv` 形成之前，
   且发生在当前项目看不到代码的更早阶段（很可能在sibling "Matrix I" 项目里，用Excel人工操作或
   一次性脚本完成，未留痕）。
5. `data/canonical/` 6个文件的生成逻辑**确认了原计划的猜测**：它们确实是从已经清洗好的最终面板
   反向导出的描述性表，不是筛选过程的中间产物。证据见第3节。

---

## 1. data/intermediate/ 六个文件逐一核实

### 1.1 反查脚本结果

```
grep -rl "<文件名>" scripts/ reports/ data/source_reports/
```

| 文件 | scripts/ 命中 | reports/ 或 data/source_reports/ 命中 |
|---|---|---|
| `aa_match_report.csv` | 无 | 无（仅作为复制源本身存在于 `reports/`） |
| `manual_match_review.csv` | 无 | `reports/match_failure_summary.md`、`data/source_reports/match_failure_summary.md` |
| `unmatched_models.csv` | 无 | 无 |
| `main_model_release_events_date_review.csv` | 无 | 无 |
| `manual_review_needed.csv` | 无 | `reports/data_quality_report.md`、`data/source_reports/data_quality_report.md` |
| `low_confidence_matches.csv` | 无 | 无 |

**结论（有明确依据）**：这6个CSV不是当前 `scripts/` 目录下任何脚本的输出。它们的"生成说明书"
以Markdown报告的形式留在了 `reports/`（=`data/source_reports/`，两边内容逐字节相同），
但产生这些报告/CSV的实际Python代码**在本仓库中不存在**——既不在 `scripts/prep/`，
也不在 `task/agent_tasks/` 下能找到的脚本里。

### 1.2 `aa_match_report.csv`（79行，12列）

- 列：`source_row_number, release_date, event_name, creator, event_type, aa_match_status,
  needs_manual_review, aa_model_id, aa_model_name, aa_creator, match_score, match_method`
- **这是模型候选与AA数据库做模糊匹配的主表**，记录每个候选模型尝试匹配AA LLM排行榜后的结果。
- `aa_match_status` 实际取值分布（不是猜测，是 `.value_counts()` 实测）：
  - `unmatched`：31
  - `matched_low_confidence`：27
  - `matched_confirmed`：21
  - 合计79，与 `data/source_reports/match_failure_summary.md` 报告的
    "Match Status For Model-Labeled Events"表格（unmatched 31 / matched_low_confidence 27 /
    matched_confirmed 21）**完全一致**，互相印证。
- `match_method` 分布：`no_confident_candidate`(30)、`fuzzy_name+creator`(24)、
  `exact_base_name+creator`(8)、`exact_base_name+creator+release_date`(6)、
  `ambiguous_base_name+creator`(4)、`exact_normalized_name+creator`(4)、
  `ambiguous_fuzzy_match`(2)、`creator_not_found_in_aa`(1)。
- 这个文件**同时包含保留（matched_confirmed）和被标记需要复核/排除（unmatched、low_confidence）
  的候选**，是一份混合状态表，不是单纯"被剔除清单"。

### 1.3 `manual_match_review.csv`（58行，15列）

- 58 = `unmatched`(31) + `matched_low_confidence`(27)，即 `aa_match_report.csv` 中所有
  **非confirmed** 的候选，被单独抽出做人工复核。
- 列里有 `failure_reason`（实测分布）：`ambiguous_variant`(15)、`non_llm_endpoint_mismatch`(14)、
  `name_alias_issue`(13)、`genuinely_missing_from_aa`(6)、`research_system_not_on_leaderboard`(4)、
  `model_family_not_specific`(4)、`product_event_mislabeled_as_model`(2)。
- 有 `recommended_action` 列（实测分布）：`manual_select_specific_variant`(19)、
  `use_aa_media_endpoint`(14)、`manual_alias_confirm_then_backfill`(13)、
  `leave_metrics_blank_until_aa_adds_model`(6)、`exclude_from_llm_leaderboard_merge`(4)、
  `reclassify_as_product_event`(2)。
- **关键发现（有明确数据依据）**：`manual_confirmed_model_id` 列和 `manual_notes` 列
  **全部58行均为空值**（`.notna().sum()` = 0）。也就是说**这份人工复核队列被生成出来了，
  但实际的人工复核动作（填回确认的model_id或备注）在这个文件里没有留下任何完成痕迹**。
  无法从这个文件判断这58条候选最终是被纳入还是剔除——如果复核确实发生过，结果被记录在了
  别的地方（很可能直接写入了后来的 `事件集数据.csv`），而不是回填进这个CSV本身。
- `refined_event_type` 分布：`text_llm`(20)、`multimodal_model`(15)、`image_model`(7)、
  `video_model`(6)、`research_system`(4)、`reasoning_llm`(3)、`agent_product`(2)、`audio_model`(1)。

### 1.4 `unmatched_models.csv`（31行，8列）

- 就是 `aa_match_report.csv` 中 `aa_match_status == 'unmatched'` 的31行子集，列也是该表的子集
  （去掉了 `aa_model_id/aa_model_name/aa_creator/match_score`，因为这些本来就是空的）。
- 抽样显示前几行是 Google 的 AlphaEvolve / AlphaGeometry 2 / AlphaProof，
  `match_method` 全部是 `no_confident_candidate`——这些是研究系统/科研工具类条目，
  在AA的LLM排行榜里天然找不到对应条目（呼应 `failure_reason` 里的
  `research_system_not_on_leaderboard`）。
- 是 `aa_match_report.csv` 的纯派生视图，不是独立信息源。

### 1.5 `main_model_release_events_date_review.csv`（仅1行，12列）

- 列：`event_id, model_name, true_model_creator, event_month, official_release_date,
  official_release_date_confidence, date_conflict_with_aitimeline_month,
  official_release_date_source_title, official_release_date_source_url,
  manual_review_reason, manual_confirmed_release_date, manual_notes`
- 唯一一行记录：`MMR-0001 | Midjourney v1 | Midjourney | 2022-02`，
  `official_release_date_confidence = manual_confirmed_month_only`，
  `manual_review_reason = manual_confirmed_month_only`。
- **这是日期精度审核表**，跟AA匹配无关，是"发布日期只能精确到月、无法精确到日"的标记表。
  这个事件（Midjourney v1）只有1行，说明绝大多数候选的日期问题已经在别处（很可能是
  `reports/official_release_date_crawl_report.md` 描述的官方日期爬取+人工覆盖流程）解决，
  只剩这一条悬而未决留在这个review文件里。
- 这个文件命名里的 `main_model_release_events` 前缀（MMR-编号）与最终面板的 `FMR-` 编号体系不同，
  说明存在一个中间的"main model release events"候选编号体系（MMR），后续才映射/重新编号为
  最终面板的 `final_event_id`（FMR-0001 ~ FMR-0060 等）。`reports/manual_release_date_override_report.md`
  和 `reports/manual_event_metadata_override_report.md` 都用的是MMR编号，证实了这一中间阶段存在。

### 1.6 `manual_review_needed.csv`（21行，12列）

- 列：`source_row_number, event_name, creator_original, creator, release_date_raw, release_date,
  release_month_original, release_month, manual_sota, manual_reason, duplicate_group_size,
  manual_review_issues`
- **这跟AA匹配无关，是另一条独立的清洗管线**——`data/source_reports/data_quality_report.md`
  明确写来源是 `Event_2.xlsx`（94行输入，94行保留，0行删除），跟AI Timeline抓取管线是不同的源。
  这是个**重要的发现**：项目里至少存在两条独立的数据整理支线，一条是AI Timeline抓取+AA匹配，
  另一条是某个 `Event_2.xlsx` 表格的清洗，二者用了相似命名的"manual_review"文件，容易混淆。
- `manual_review_issues` 实测分布：`missing_manual_sota; missing_manual_reason`(17)、
  `missing_manual_reason`(3)、`release_date_month_conflict`(1)，合计21。
- `manual_sota`（人工判定是否SOTA）实际只填了4行，`manual_reason` 只填了1行——
  说明这份人工复核队列同样**基本没有被实际填写完成**，跟1.3节的 `manual_match_review.csv` 情况类似。
- **没有删除任何行**（`data_quality_report.md`："Total input rows: 94, Rows retained: 94,
  Rows deleted: 0"）。这21条是"被标记需要人工判断但保留在数据集里"，不是"被剔除"。

### 1.7 `low_confidence_matches.csv`（27行，12列）

- 是 `aa_match_report.csv` 中 `aa_match_status == 'matched_low_confidence'` 的27行子集，
  列结构跟 `aa_match_report.csv` 一致。
- `match_score` 实测分布：均值0.722，标准差0.082，最小0.603，最大0.840（中位数0.714）。
  抽样：Amazon Nova↔AA"Nova Micro"（score 0.6733）、ChatGPT Agent↔AA"GPT-5 (ChatGPT)"
  （score 0.6068）、Gemini 1.5↔AA"Gemini 1.5 Flash-8B"（score 0.6989）——可以看出这些是
  "同一家族但具体型号对不上"的典型模糊匹配问题，跟 `manual_match_review.csv` 里
  `ambiguous_variant`(15)、`name_alias_issue`(13) 这两个失败原因吻合。
- `needs_manual_review` 全部为1（27/27），是 `manual_match_review.csv` 的58行人工队列里
  按状态切出的另一个子集（与31行 `unmatched_models.csv` 互补，27+31=58）。

### 1.8 小结表

| 文件 | 行数 | 性质 | 是否独立信息源 |
|---|---:|---|---|
| `aa_match_report.csv` | 79 | AA匹配主表（混合保留+待复核状态） | 是（源头表） |
| `manual_match_review.csv` | 58 | 79行中非confirmed的人工复核队列；复核结果列全空 | 是（增加了failure_reason/候选项） |
| `unmatched_models.csv` | 31 | aa_match_report中unmatched子集 | 否（派生视图） |
| `low_confidence_matches.csv` | 27 | aa_match_report中matched_low_confidence子集 | 否（派生视图） |
| `main_model_release_events_date_review.csv` | 1 | 日期精度审核表（MMR编号体系），与AA匹配无关 | 是（但样本极小） |
| `manual_review_needed.csv` | 21 | 来自完全不同的`Event_2.xlsx`清洗管线，与AI Timeline/AA无关 | 是（独立支线） |

---

## 2. AA（Artificial Analysis）数据库的角色确认

### 2.1 AA身份确认（有明确依据）

`reports/aa_master_database_codebook.md`：
- "Source: Official Artificial Analysis API only"
- 认证：环境变量 `ARTIFICIAL_ANALYSIS_API_KEY`，请求头 `x-api-key`
- 原始响应理论上存于 `data/raw/artificial_analysis/`（当前项目里这个目录是空的）
- 处理后输出三张表：`data/processed/aa_llm_models.csv`（LLM排行榜，含
  `aa_intelligence_index/aa_coding_index/aa_math_index/mmlu_pro/gpqa/hle/livecodebench/scicode/
  math_500/aime` 等能力指标，以及价格、速度指标）、`data/processed/aa_media_models.csv`
  （图像/视频/语音模型排行榜，Elo/Rank等）、`data/processed/aa_media_categories.csv`
  （媒体模型的细分类别评分）。
- 这三个`data/processed/*.csv`文件**在当前项目里实际不存在**（已用find确认），
  只有codebook描述，没有数据本体——再次印证AA原始处理发生在sibling项目。

### 2.2 AA在筛选链路里的真实作用（有明确依据 + 合理推测）

- **有依据**：`reports/match_failure_summary.md` 明确说这一步是给"Model-Labeled Events"
  （已经被分类为"模型"的候选）做AA leaderboard匹配，目的是**判断该候选能否补充AA的能力指标**，
  失败原因里大量是 `non_llm_endpoint_mismatch`（候选是图像/视频/语音模型，但当时只查了LLM端点）、
  `research_system_not_on_leaderboard`（科研系统不在排行榜上）——这些更像是"指标补充能不能成功"
  的问题，不是"事件本身要不要保留"的问题。
- **有依据**：最终面板 `data/panel/clean_event_firm_panel.csv` 里确实带着AA指标列
  （`representative_aa_model_id, representative_aa_model_name, representative_aa_creator_name,
  representative_aa_source_table, aa_model_ids, aa_model_names, aa_intelligence_index,
  aa_coding_index, aa_math_index, aa_media_task, aa_media_elo, aa_media_rank, aa_media_ci95,
  aa_media_appearances, aa_media_category_rows`），且 `reports/cleaning_report.md` 第6节显示
  这些AA字段有结构性缺失（`aa_intelligence_index`缺失21.7%，`aa_media_elo`等缺失78.3%），
  报告明确说"这是预期的结构性缺失，因为AA能力指标只对特定模型类型可用，不要因为缺失率高就删列"。
  这说明**AA指标是作为事件的描述性/解释变量补充进面板的，不是纳入/排除事件的筛选门槛**——
  即便一个事件的AA匹配是unmatched，这个事件本身似乎仍可能保留在面板里（只是AA指标列留空）。
- **合理推测、无法在本仓库内完全证实**：这60个最终事件具体是不是因为AA匹配失败被剔除过一部分
  候选——这一点无法从当前能看到的文件里直接验证，因为：
  (a) `manual_match_review.csv` 的人工复核结果列全空，看不到复核后续动作；
  (b) `clean_event_panel.py` 的输入 `事件集数据.csv` 已经是收窄完成后的60事件面板，
  这之前的筛选逻辑（包括AA匹配结果具体怎样影响了纳入/排除决定）的代码不在本仓库中。
  **诚实结论：AA匹配更像是"指标补充流程"而非"事件纳入门槛"，但不能100%排除它也间接影响了
  candidate pool的某些剔除决定——这部分链路的决定性证据缺失。**

---

## 3. data/canonical/ 六个文件的真实生成逻辑确认

### 3.1 反查结果：原计划猜测成立

```
grep -rl "event_master_from_panel|company_master_from_panel|from_panel|from_report" scripts/
```
**无任何命中**——`scripts/` 目录下没有任何脚本生成或处理这些canonical文件。

进一步在全项目搜索（排除当前任务自身的plan.md），命中：
- `agent_tasks/full_length_data_collection_todo_20260614.md`
- `agent_tasks/data_consolidation_20260614-122508/plan.md`
- `data/README.md`

这三处全部是**文档**，不是代码。

### 3.2 真实生成过程（有明确依据）

`agent_tasks/data_consolidation_20260614-122508/plan.md`（创建于2026-06-14 12:25:08）
第15-22行 "Phase 2. Implementation" 明确写：

> - 复制已有原始和中间数据到 `data/source_reports/`、`data/intermediate/`、`data/panel/`、`data/results_tables/`。
> - **从现有面板导出** `data/canonical/event_master_from_panel.csv`。
> - **从现有面板导出** `data/canonical/company_master_from_panel.csv`。
> - 从现有关系表和 evidence 表复制到 `data/relationships/`。
> - 生成 `data/manifest.csv` 和 `data/README.md`。

同任务的 `review_summary.json` 记录了校验结果：
```
panel_rows: 5160, panel_columns: 107, events: 60, companies: 86,
data_files_total: 67, canonical_files: 6, official_source_rows: 47
```

`data/README.md`"Key canonical tables"一节逐一描述：
- `event_master_from_panel.csv`：从清洗后的event-firm面板去重得到的事件级表
- `company_master_from_panel.csv`：从同一面板去重得到的公司级表
- `event_firm_relationship_flags_from_panel.csv`：从面板中提取的关系标志位和备注
- `event_metric_snapshot_from_panel.csv`：从面板中提取的事件级AA和媒体指标快照
- `event_official_sources_from_report.csv`：**例外**——这个是从抓取报告（不是面板）解析出的
  47条官方发布日期来源行，文件名后缀 `_from_report` 准确反映了这一点
- `event_firm_panel_manifest.csv`：对当前面板的简短描述（行列数等元信息）

**结论确认（有明确依据，原计划猜测成立）**：这6个canonical文件确实是2026-06-14的一次
"数据归拢"操作里，从**已经清洗完成的最终面板** `data/panel/clean_event_firm_panel.csv`
（即`specr_rel_clean.csv`的源头面板，5160行/60事件/86公司）**反向去重/提取**生成的描述性表，
唯一例外是 `event_official_sources_from_report.csv` 来自抓取报告而非面板本身（但仍是"反向提取"，
不是清洗过程的中间产物）。这次归拢操作本身**没有留下可执行代码**（plan.md里没有贴脚本，
只有自然语言步骤描述），意味着具体的pandas去重/提取代码当时执行后未被保存为脚本文件。

### 3.3 与本任务相关的延伸事实

`data/README.md`"Important caveat"一节自己也承认：

> The project reports mention raw AI Timeline and Artificial Analysis files, but those raw files
> were not found in the current project folder during this consolidation pass.

以及"Next steps"第2-3条：

> 2. Build a stronger `event_master.csv` by merging `event_master_from_panel.csv`,
>    AA match diagnostics, official release-date crawl results, and AI Timeline raw IDs.
> 3. Build `event_filter_flow.csv` to document the path from AI Timeline universe to the final 60 events.

**这两条"未完成的下一步"本身就是证据**：截至2026-06-14的这次归拢，研究团队自己也清楚
"从AI Timeline候选池到最终60事件的筛选路径文档"（`event_filter_flow.csv`）**当时还没有
被构建出来**——也就是说，即便在2026-06-14，AA匹配诊断和最终60事件之间的因果链条
就已经没有被系统整理成可读文档，本次考古任务面对的信息缺口在当时就已经存在，不是后来才丢失的。

---

## 4. 诚实的证据强度分级总结

### 4.1 有明确数据/代码依据的结论

- AA = Artificial Analysis，官方API来源，已用codebook文档和环境变量命名规则证实。
- `data/intermediate/`六文件与`reports/`同名文件逐字节相同（diff验证），且无任何`scripts/`脚本读写它们。
- `aa_match_report.csv`的79行匹配状态分布（unmatched 31 / low_confidence 27 / confirmed 21）
  与`match_failure_summary.md`报告数字完全吻合，互相印证非常可靠。
- `manual_match_review.csv`的`manual_confirmed_model_id`和`manual_notes`列100%为空——
  人工复核队列生成后没有留下完成痕迹。
- `clean_event_panel.py`的输入`事件集数据.csv`已经是60事件×86公司的成品面板，
  该脚本本身不做事件筛选、不做AA匹配、不做公司映射，只做格式清洗。
- `data/canonical/`六文件的生成逻辑（从最终面板反向导出，无独立脚本）已用
  `data_consolidation_20260614-122508/plan.md`和`data/README.md`双重确认。
- `manual_review_needed.csv`实际来自一条完全不同的`Event_2.xlsx`清洗支线，与AI Timeline/AA匹配无关。

### 4.2 合理推测、有部分间接证据支持

- AA匹配结果更像是"事件指标补充流程"而非"事件纳入/排除门槛"（因为最终面板里AA指标缺失是
  作为"结构性缺失"被保留和说明的，不是被用来删除整行）。但这只是基于面板缺失模式的推断，
  不是基于看到判断逻辑代码的直接证据。
- MMR编号体系（main_model_release_events候选）先于最终FMR编号体系存在，说明有一个中间的
  候选事件库阶段，这个阶段大概率发生在`事件集数据.csv`形成之前，很可能在sibling项目
  "Matrix I - Bandit与研发竞赛"里完成。

### 4.3 完全没有依据、无法确认的环节

- 58条`manual_match_review.csv`人工复核队列的candidate最终被人工判定为纳入还是排除——
  **复核结果列全空，本仓库内找不到任何记录复核结论的文件**。如果复核确实做过，
  结论被直接写入了`事件集数据.csv`（在sibling项目里），但写入的具体决策逻辑/对照表
  在当前项目中不可见。
- `possible_us_exposed_tickers`、`potential_us_exposure_type`这两个"公司映射"核心字段
  具体是怎么从模型创建者(creator)映射到具体上市公司ticker的——**当前项目里没有任何脚本
  或报告描述这个映射规则或映射表**。`clean_event_panel.py`只是把这两列当作已存在的输入列
  传递过去，`reports/manual_event_metadata_override_report.md`只记录了6处人工修正
  （且修正前后数值大部分相同，疑似确认而非改动），没有解释原始映射逻辑本身。
  **这是公司映射环节里最大的证据空白**：本任务找不到"creator→上市公司"映射规则的来源文件。
- `事件集数据.csv`本身（即`clean_event_panel.py`的输入文件）在当前项目目录里**不存在**
  （只存在于`Matrix I - Bandit与研发竞赛`的路径引用里），无法直接打开核实它在形成时
  到底应用了哪些筛选规则。
- AI Timeline抓取报告中提到的266个候选具体是怎样一步步收窄、AA匹配的79个"Model-Labeled Events"
  又是怎样对应到266个候选的子集——两份报告（`aitimeline_extraction_report.md`与
  `match_failure_summary.md`）之间的候选数量对应关系（266 vs 79）在当前材料里没有显式的
  桥接说明，无法精确复原。
