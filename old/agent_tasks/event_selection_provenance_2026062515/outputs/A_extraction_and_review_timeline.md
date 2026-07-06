# A段溯源：抓取与人工审核阶段时间线

负责范围：从 AI Timeline 原始抓取，到"模型候选池"形成，到136条人工审核，到审核后的结果数量。
本文档只覆盖这一段；脚本层面的最终面板清洗逻辑（60个事件怎么来的）由子代理B负责，AA匹配/公司映射由子代理C负责。

## 0. 证据来源清单（先说清楚我看了什么）

直接读取并完整看过全文的文件：
1. `data/source_reports/aitimeline_extraction_report.md`（172行，全文）
2. `data/source_reports/aitimeline_model_events_enriched_report.md`（55行，全文）
3. `data/source_reports/aitimeline_model_events_enriched_codebook.md`（166行，全文，含118列字段逐列说明）

对比验证：
- `diff reports/aitimeline_extraction_report.md data/source_reports/aitimeline_extraction_report.md` → **完全一致**（无任何差异输出）
- `diff reports/aitimeline_model_events_enriched_report.md data/source_reports/aitimeline_model_events_enriched_report.md` → **完全一致**
- `diff reports/aitimeline_model_events_enriched_codebook.md data/source_reports/aitimeline_model_events_enriched_codebook.md` → **完全一致**
- `ls -la` 显示：`reports/` 目录下三个文件的 mtime 是 Apr 27（抓取/生成当天），`data/source_reports/` 下同名文件 mtime 是 Jun 14（项目整理时统一复制/搬移产生的新时间戳，内容未变）。结论：两处是同一份文件的两个副本，**没有版本分歧**，`data/source_reports/` 应该是后来整理项目结构时从 `reports/` 复制过去的归档位置，内容上谁更权威没有意义（完全相同）。

搜索但未发现新证据的路径：
- `grep -rliE "产品.*模型|模型.*产品|product.*model.*distinct" --include="*.md" .` → 命中的文件里**没有一个**是专门讲"产品 vs 模型"判定标准的；命中原因都是字面上同时出现"产品"和"模型"两个字但语境不同（例如关系编码报告里讨论"AI 是核心产品"的下游暴露分类，跟事件筛选的产品/模型判定无关）。**没有找到任何文档化的"产品 vs 模型"判定规则**。
- `find agent_tasks -maxdepth 1 -iname "*aitimeline*" -o -iname "*timeline*"` → **无结果**。项目里不存在一个专门做"AI Timeline 抓取/筛选"的历史 agent_tasks 工作区。现有的 `agent_tasks/event_data_cleaning_202606021351/` 工作区经检查与 AI Timeline 抓取无关（处理的是面板结构/日期/数值缺失审计，不涉及产品模型判定）。
- `find archive -iname "*aitimeline*" -o -iname "*timeline*"` → **无结果**，`archive/` 下没有相关旧工作区或旧脚本。
- 全项目 `find . -iname "*aitimeline*"`：只命中 `reports/`、`data/source_reports/`（三份报告md）和 `data/raw/aitimeline/`（空目录）。**没有第四处藏匿位置**。
- `data/raw/aitimeline/` 目录确认为空（`ls -la` 只有 `.` 和 `..`），抓取时提到的本地缓存 `timeline_2026-04-27.md` 已不存在，无法回头看原始抓取文本。
- 报告里提到的整合数据集 `data/processed/aitimeline_model_events_enriched.csv`（codebook 描述的主表，136行人工审核结果应该就记录在这个文件的 `review_decision_notes`、`exclusion_reason`、`review_main_sample_action` 等列里）**已经不存在**：`data/processed/` 目录本身就不存在于当前项目结构里（`ls data/` 只有 `canonical, intermediate, panel, quality_checks, raw, raw_external_paths, relationships, results_tables, source_reports, README.md` 十项，没有 `processed`）。
- 生成该数据集的脚本 `scripts/build_aitimeline_enriched_dataset.py`（codebook 第3行点名的脚本）**也不存在**：`find . -iname "build_aitimeline*"` 无结果，`grep -rl "build_aitimeline_enriched_dataset" scripts/` 无结果。
- `git log --all --oneline -- "scripts/build_aitimeline_enriched_dataset.py"` 和 `git log --all --oneline -- "*aitimeline*"` 均无该脚本的提交记录——这个脚本从未被纳入版本控制，现在已经物理删除且无法从 git 历史恢复。

**这意味着**：136条人工审核的逐条具体决策内容（每一条候选模型当时是怎么被判定为"产品"还是"模型"、判定依据是什么原始文本）**已经永久丢失**，现在唯一留存的是两份汇总统计报告（extraction_report 的数量统计 + enriched_report 的状态计数 + codebook 的字段定义说明）。下面的时间线只能基于这些汇总统计和字段定义反推，**无法还原到逐条原始判断**。

## 1. 时间线重建

### 步骤1：抓取（有明确文档依据）

- 抓取时间：2026-04-27T01:36:32+08:00。
- 数据源：`https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.md`。
- 抓取方式：使用同日已存在的本地缓存（`used existing same-day cache`），缓存文件原路径 `data/raw/aitimeline/timeline_2026-04-27.md`（现已不存在）。
- 解析规则：只解析 Markdown 里的 `# Year: YYYY`、`## Month`、`- event text` 三类结构，**没有用网页 HTML**。
- 依据：`data/source_reports/aitimeline_extraction_report.md` 第3-10行。

### 步骤2：原始条目 → 模型候选行拆分（有明确文档依据）

- 原始条目（每条对应 AI Timeline 上一行 bullet）：**235条**。
- 自动分类后，模型候选行：**266条**（注意266>235，因为同一条原始记录如果提到多个模型，脚本会拆分成多条候选行，但保留同一个 `raw_entry_id` 以便回溯——这是 codebook 第37行 `split_from_multi_event` 字段的设计目的）。
- 非模型条目：**22条**（自动判定为不是模型发布，比如纯产品更新、政策新闻、人事变动等——但报告本身没有列出这22条具体是什么，只给数量）。
- ambiguous 条目：**14条**（自动分类无法确定是否为模型发布）。
- 依据：`data/source_reports/aitimeline_extraction_report.md` 第12-18行（数量概览）。
- **注意**：235 = 266(候选) + 22(非模型) + ... 这个加总关系报告里没有显式核对，14条ambiguous的归属（算不算在266个候选里）报告原文没有说清楚，**这是一个数字对不上的细节，没有找到解释**，不排除是分类体系有重叠（一条原始记录可能同时贡献多个候选行，也可能本身是ambiguous但又被拆出了候选）。

### 步骤3：266个候选中，136条进入人工审核（有明确文档依据，理由分类有文档，逐条理由记录已丢失）

进入人工审核的理由分布（报告原文数字）：
- multiple_models_in_raw_entry：108条（一条原始记录拆出多个模型候选，需要人工确认拆分是否正确）
- possible_duplicate：19条（可能与其他候选重复）
- mixed_product_or_agent_context：18条（**这是最接近用户记忆中"产品 vs 模型"区分的分类标签**——自动分类怀疑这条记录描述的是"产品"或"agent"而非单一模型本身，需要人工确认）
- low_classification_confidence：7条
- research_system_or_benchmark_without_clear_model_release：7条（疑似研究系统/benchmark而非正式模型发布）
- release_action_unclear：4条
- research_system_or_benchmark_context：4条
- model_mentioned_without_extractable_model_name：4条
- business_or_hardware_context：3条
- not_direct_model_release_for_main_sample：3条
- 依据：`data/source_reports/aitimeline_extraction_report.md` 第144-155行。

**关键诚实声明**：报告只给出了"理由标签"和"该标签下有多少条"，**没有给出这136条逐条对应的原始文本、自动判断结果、以及人工审核后的最终决定**。逐条记录本应存在于 `data/processed/aitimeline_model_events_enriched.csv` 的 `review_decision_notes`、`raw_entry_text`、`review_main_sample_action` 等列（codebook 第16、33、35、99行对这些列的说明），但该文件已不存在于当前项目目录，**无法回查任何一条的具体判断依据**。"删掉产品只留模型"这个用户记忆中的操作，最可能就是落在 `mixed_product_or_agent_context`（18条）以及一部分 `multiple_models_in_raw_entry`（拆分后判定某些拆分项是产品而不是模型）里被执行的，但**无法证明具体哪些候选被这样处理、判断标准是什么**。

### 步骤4：人工审核后的整合结果（有明确文档依据，是汇总统计层面）

`aitimeline_model_events_enriched_report.md` 给出的是**136条进入人工审核的候选**审核完成后的状态分布（不是266个候选的全部分布）：

核心计数（报告第5-12行）：
- 进入人工审核的行总数：136
- 有确认可用AA指标的行：82
- 有可能但未确认的AA别名指标的行：1
- **人工决定排除/删除的行：10**
- 标记为合并/重复变体的行：16

最终样本状态分布（`final_sample_status`，报告第19-27行，这136行内部的细分）：
- excluded_or_deleted_candidate（排除/删除）：10
- kept_with_confirmed_aa_metrics（保留+有确认AA指标）：77
- kept_without_confirmed_aa_metrics（保留+无确认AA指标）：18
- merged_or_duplicate_without_direct_metrics（合并/重复，无直接指标）：8
- merged_variant_with_own_or_family_metrics（合并变体，有自身或家族指标）：8
- needs_manual_review_without_decision（仍待人工复核，未决）：14
- no_aa_candidate_score（无AA候选分数）：1

加总核验：10+77+18+8+8+14+1 = 136。✓ 与"进入人工审核的行总数=136"完全吻合，内部数字自洽。

**这一步的局限**：报告里的"保留"（kept_*，共77+18=95条）和"排除"（10条）、"合并"（8+8=16条）加总=136，是**136条审核候选**的最终去向，**不是**266个候选总体的去向（剩下266-136=130条没有进入人工审核的候选，报告没有交代它们各自的最终状态——理论上它们应该是自动分类置信度较高、直接进入候选池，但报告没有显式给出这130条最终是否全部保留）。

### 步骤5：模态分布（有文档依据，提示了"产品筛选"之外的另一道隐性筛选）

136条审核行的模态分布（报告第35-47行）：
text_llm 66、reasoning_llm 15、multimodal_llm 13、coding_llm 8、image_generation 8、video_generation 7、ambiguous 11、vision_language_model 3、image_editing 2、music_generation 2、audio_speech 1。

这说明：人工审核池本身并不是单一模态，**仍然包含大量非文本类模型**（image/video/music/audio 共约20条）。如果最终60个事件样本只剩文本/推理类LLM（需要子代理B用最终面板验证），那么"按模态筛选只留文本LLM"这一步**不是在A段（抓取与人工审核）阶段执行的**，应该是后续清洗脚本（`clean_event_panel.py`）的逻辑，需要交给子代理B确认。

## 2. 关于"产品 vs 模型"标准的诚实结论

- **没有找到任何独立的、专门说明"产品 vs 模型"判定规则的文档**。codebook 第53行提到字段 `exclusion_reason`（"自动或人工记录的排除原因，例如产品事件、研究系统、低置信度、不是直接模型发布等"）——这证实了"产品事件"确实是一个被使用过的排除理由类别，但codebook只是在解释这一列**可能取什么值**，并没有给出判定一条记录是"产品事件"还是"模型发布"的具体规则或决策树。
- 唯一可以确认的、与"产品"相关的量化痕迹是：
  - 抽取阶段：22条"非模型条目"（自动判定，规则未知）
  - 人工审核阶段：18条 `mixed_product_or_agent_context` 理由标签（送审，规则未知，审核结果未知，因为底层数据文件已丢失）
  - 整合阶段：10条被人工"排除/删除"（`is_excluded_or_deleted_candidate=1`，但具体哪10条、排除理由的逐条文字已经无法查到，原本应记录在已丢失的 `review_decision_notes` 列里）
- **结论：用户记忆中"删掉产品只留模型"这一步，确实在系统里留下了统计层面的痕迹（22+18+10这几个数字），但具体执行时用的判断标准、逐条决策记录，已经随着 `data/processed/aitimeline_model_events_enriched.csv` 和生成脚本 `scripts/build_aitimeline_enriched_dataset.py` 的物理删除而永久丢失，目前在项目里找不到任何可追溯的具体规则文本。这部分应被诚实地标记为"纯人工判断，标准已不可考"，不应在论文方法论部分编造一个具体规则。**

## 3. 给SYNTHESIS子代理的关键数字摘要

| 阶段 | 数量 | 文件依据 |
|---|---|---|
| AI Timeline原始条目 | 235 | aitimeline_extraction_report.md L14 |
| 自动分类出的模型候选行 | 266 | 同上 L15 |
| 自动判定非模型条目 | 22 | 同上 L16 |
| ambiguous条目 | 14 | 同上 L17（与235/266加总关系不完全清楚，未找到解释） |
| 进入人工审核的候选 | 136 | 同上 L18 |
| 人工审核后排除/删除 | 10 | aitimeline_model_events_enriched_report.md L10/21 |
| 人工审核后保留（含/不含确认AA指标） | 77+18=95 | 同上 L22-23 |
| 人工审核后标记合并/重复 | 16（8+8） | 同上 L11/24-25 |
| 人工审核后仍待复核未决 | 14 | 同上 L26 |
| 266个候选中本来就没送审、直接留在候选池的 | 266-136=130（最终状态未知，未在任何报告中交代） | 推算，非文档直接给出 |
