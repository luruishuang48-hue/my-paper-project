# 任务计划：反推60个事件样本的筛选过程

**创建时间：** 2026-06-25 15:02（北京时间）
**工作目录：** `agent_tasks/event_selection_provenance_2026062515/`

## 任务背景

用户记得最初是从 AI Timeline (`https://nhlocal.github.io/AiTimeline/#2024`，对应抓取的是
`https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.md`) 抓取事件，
然后手动删掉"产品"只留"模型"。但后续具体经过哪些步骤、哪些规则，从原始236条记录收窄到
最终面板里的 **60 个事件**，用户已经记不清楚了。这是一个纯考古/溯源任务——不写新代码、
不跑新回归，只是从现有代码、报告、中间数据文件里反推出完整的筛选逻辑链条，写成一份可读的
时间线文档。

## 已确认的关键事实（主agent探索阶段已查证，子代理可直接引用，不需要重新验证这部分）

1. **最终面板规模**：`data/panel/specr_rel_clean.csv` 有 5,160 行，`unique(final_event_id)` = 60。
2. **抓取阶段报告**：`data/source_reports/aitimeline_extraction_report.md`（已读，完整内容如下）：
   - 抓取时间 2026-04-27，数据源 `raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.md`，
     本地缓存 `data/raw/aitimeline/timeline_2026-04-27.md`（**注意：当前 `data/raw/aitimeline/` 目录是空的，
     缓存文件已被删除或移动，子代理应在 `archive/` 或 `agent_tasks/` 历史目录里找一下有没有留存副本，
     找不到也不必强求，报告里的统计数字本身就是证据**）。
   - 原始条目 235 条，解析出模型候选行 266 条，非模型条目 22 条，ambiguous 14 条。
   - 266 个候选中有 **136 条进入人工审核**（理由分布：multiple_models_in_raw_entry 108、
     possible_duplicate 19、mixed_product_or_agent_context 18、low_classification_confidence 7、
     research_system_or_benchmark_without_clear_model_release 7、release_action_unclear 4、等）。
   - 与 AA master database 初步 fuzzy matching：263 个可匹配候选中找到 239 个候选匹配（90.9%），
     但报告明确说"这里只做 fuzzy matching 候选提示，不确认匹配，不回填任何 AA 指标"——
     说明这一步只是候选筛选用，不是最终纳入判断。
   - 报告也明确：AI Timeline 只是"候选事件发现来源，不是最终样本纳入标准"——
     说明后续一定还有别的脚本/人工步骤做了真正的纳入判断，需要子代理找到它。
3. **还有两份相关报告未读**（子代理需要读全文）：
   - `data/source_reports/aitimeline_model_events_enriched_report.md`（55行，可能是人工审核后的结果汇总）
   - `data/source_reports/aitimeline_model_events_enriched_codebook.md`（166行，可能是分类/编码规则说明）
   - 注意：`reports/` 目录下有同名文件（`reports/aitimeline_extraction_report.md` 等），
     需要 diff 一下 `reports/` 和 `data/source_reports/` 里的版本是否相同，如果不同要弄清楚哪个是更新版本。
4. **核心候选脚本**：`scripts/prep/clean_event_panel.py`（39,745 字节，是 `scripts/prep/` 目录下最大的脚本，
   极可能是把候选事件收窄、清洗、合并到最终面板的主脚本，子代理 B 需要完整读取并逐段理解其筛选逻辑）。
5. **中间数据痕迹文件**（位于 `data/intermediate/`，很可能是 `clean_event_panel.py` 或相关脚本运行过程中
   产生的审核轨迹，子代理需要逐一打开看内容，不要只看文件名猜测）：
   - `aa_match_report.csv`
   - `manual_match_review.csv`
   - `unmatched_models.csv`
   - `main_model_release_events_date_review.csv`
   - `manual_review_needed.csv`
   - `low_confidence_matches.csv`
6. **canonical 目录的产出文件**（`data/canonical/`，可能是清洗管线的下游产物，体现了最终保留的事件/公司集合）：
   - `event_master_from_panel.csv`
   - `company_master_from_panel.csv`
   - `event_firm_relationship_flags_from_panel.csv`
   - `event_metric_snapshot_from_panel.csv`
   - `event_official_sources_from_report.csv`
   - `event_firm_panel_manifest.csv`
   注意这些文件名都带 `_from_panel` 或 `_from_report` 后缀，说明它们是**从已经清洗好的面板反向导出**的
   描述性文件，不是清洗过程本身的中间产物——子代理应该核实这个猜测对不对，不要直接当结论用。
7. **其他可能记录筛选逻辑的脚本**（已找到但未读，按文件大小判断 `clean_event_panel.py` 最可能是主力）：
   `scripts/prep/specr_prep.py`（1.8KB，小）、`scripts/prep/specr_rel_prep.py`（4.9KB）、
   `scripts/prep/specr_rel_prep_v2.py`（5.4KB）、`scripts/prep/merge_adjudicated_relationships.py`（3.3KB，
   这个明确是关系编码合并用的，跟事件筛选大概率无关，可以快速排除）。
8. **git 历史价值有限**：`git log --oneline --all` 只有 9 条 commit，其中只有最早 5 条左右是"上传"性质的
   批量提交（如"上传论文相关数据与文档"），commit message 本身不包含筛选逻辑的细节描述，
   不要指望从 git log 里挖出叙事性说明，但可以用 `git show <commit>:<path>` 看某个文件在某次提交时的
   历史版本，如果怀疑某个文件被改过逻辑。
9. **用户提供的起点事实（不需要验证，直接采信）**：用户记得自己做过"删掉产品只留模型"这一步人工筛选；
   这对应抓取报告里 22 条"非模型条目"+ 部分 136 条人工审核条目中 `mixed_product_or_agent_context`
   （18条）的处理结果，子代理 A 需要在 enriched_report/codebook 里确认这一步具体是怎么执行、
   依据什么标准判断"产品 vs 模型"的。

## 范围边界

- 这是溯源/考古任务，**不修改任何现有文件**（脚本、数据、报告全部只读）。
- 不需要重新跑任何回归或清洗脚本，只需要**读代码逻辑**和**读中间数据文件的实际内容**来理解发生了什么。
- 如果某个环节确实找不到痕迹（比如人工筛选的主观判断标准没有留下文字记录），子代理必须明确写
  "这一步没有找到可追溯的代码/文档痕迹，可能是纯人工判断，无法精确复原标准"，**不能编造或猜测**
  一个听起来合理但没有证据支撑的规则。诚实地报告"未知"比编造一个错误的规则更有价值。
- 最终交付物是给用户本人看的中文说明文档，目的是帮用户"想起来"自己当时做了什么，
  所以语言要清楚、按时间顺序、给出每一步的具体依据文件和数字，不要写成日志体的技术报告。

## Phase 1：并行考古（3 个子代理，互相独立，可并行）

### 子代理 A — 抓取与人工审核阶段溯源

**任务**：完整读取以下文件，重建"原始235条记录 → 266个模型候选 → 136个人工审核 → 人工审核后的结果"
这一段的逻辑链条：
- `data/source_reports/aitimeline_extraction_report.md`（已读，可直接引用上面第2点摘要，但建议自己重读一遍原文确认无误）
- `data/source_reports/aitimeline_model_events_enriched_report.md`（55行，完整读取）
- `data/source_reports/aitimeline_model_events_enriched_codebook.md`（166行，完整读取，这份很可能包含
  分类/纳入排除标准的编码规则，是重点）
- 对比 `reports/aitimeline_extraction_report.md`、`reports/aitimeline_model_events_enriched_codebook.md`、
  `reports/aitimeline_model_events_enriched_report.md` 跟 `data/source_reports/` 下同名文件是否完全一致
  （用 `diff` 命令），如果不一致要说明差异并判断哪个版本更新/更权威（看文件修改时间）。
- 搜索整个项目里有没有其他提到"产品"vs"模型"区分标准的文档：
  `grep -rliE "产品.*模型|模型.*产品|product.*model.*distinct" --include="*.md" .`
- 搜索 `agent_tasks/` 历史目录下是否有更早的、专门做这个抓取/筛选任务的工作区
  （类似 `agent_tasks/aitimeline_xxx_2026xxxx/` 这种命名），如果找到要完整读取里面的 plan.md 和总结文档。

**交付物**（保存到本地，不要把全文返回给主agent）：
- `agent_tasks/event_selection_provenance_2026062515/outputs/A_extraction_and_review_timeline.md`：
  按时间顺序写清楚"抓取→分类→候选池→人工审核（用什么标准、谁审、留下了什么记录）→审核后的结果数量"，
  每一步标注依据的文件路径和具体数字，明确指出哪些环节有文档依据、哪些环节只能推测、哪些环节完全找不到痕迹。
- `agent_tasks/event_selection_provenance_2026062515/logs/A_status.md`：简短状态日志。

### 子代理 B — 清洗脚本逻辑溯源（最重要，预期信息量最大）

**任务**：完整读取 `scripts/prep/clean_event_panel.py`（39KB，逐段读，不要只读开头），
逐函数/逐段理解这个脚本做了哪些筛选、排除、合并、去重操作。重点关注：
- 脚本里任何 `drop`、`filter`、`exclude`、`dedup`、`drop_duplicates`、条件判断（`if ... continue`、
  `if ... skip`）等会减少事件数量的逻辑，记录每一处筛选条件的具体内容（不是泛泛说"做了筛选"，
  要写出具体的判断条件，比如"如果某模型没有对应上市公司则剔除"之类）。
- 脚本里是否有跟"模态"（text_llm vs image_generation vs video_generation 等）相关的筛选——
  抓取报告显示候选模型涉及 11 种模态，但最终面板应该只保留了文本/推理类 LLM（需要验证这个猜测，
  检查脚本逻辑或检查最终面板里 `event_name` 字段的内容是否确实只有文本类模型）。
- 脚本里是否有跟"是否能匹配到上市公司"相关的筛选逻辑（因为这是股票市场研究，发布者必须能映射到
  一个可交易的上市公司才有意义；检查脚本是否依赖 `data/intermediate/aa_match_report.csv` 或
  `unmatched_models.csv` 来做这层过滤）。
- 脚本里是否有跟"日期精度"相关的筛选（抓取报告提到很多条目只有"年-月"没有具体日，事件研究需要
  精确到日的发布日期才能算 CAR；检查脚本是否剔除了无法确定精确日期的候选）。
- 脚本里是否有跟"Tier"（Tier 1/2/3）相关的筛选（抓取报告显示 Tier 1 有134个、Tier 2 有125个、
  Tier 3 只有7个；检查最终面板是否只保留了 Tier 1，或者 Tier 1+2）。
- 也快速浏览（不需要逐段精读）`scripts/prep/specr_prep.py`、`scripts/prep/specr_rel_prep.py`、
  `scripts/prep/specr_rel_prep_v2.py` 这三个小脚本，确认它们是否也参与了事件筛选（按文件大小判断
  可能性较低，但要验证不是想当然），还是只是后续关系变量合并/格式转换，跟事件数量筛选无关。
- 如果脚本里有调用 `data/intermediate/` 下的任何 csv 文件作为输入或输出，打开对应的 csv 文件
  （用 `pandas` 读取，看列名、行数、关键字段的取值分布），验证脚本逻辑和实际数据是否吻合。

**交付物**：
- `agent_tasks/event_selection_provenance_2026062515/outputs/B_cleaning_script_logic.md`：
  逐项列出 `clean_event_panel.py` 里所有会减少/筛选事件数量的具体规则，每条规则注明：
  (1) 规则的具体内容，(2) 脚本里的大致行号/函数名，(3) 如果能验证，提供脚本逻辑对应的真实数据数字
  （比如"剔除无法匹配上市公司的候选，从 X 个减少到 Y 个"）。最后给出一个尽量完整的、
  从输入候选数到最终60个事件的"漏斗"表格（每一步剩余多少个事件）。
- `agent_tasks/event_selection_provenance_2026062515/logs/B_status.md`：简短状态日志。

**重要提示**：这个脚本很长（39KB），如果一次读不完，可以分多次用 Read 工具的 offset/limit
参数分段读取，确保读完整个文件，不要只读前几百行就下结论。

### 子代理 C — AA 数据库匹配与最终公司映射阶段溯源

**任务**：聚焦"模型候选如何匹配到 Artificial Analysis (AA) 数据库、又如何进一步匹配到具体的
上市公司"这一段。完整读取并理解以下中间文件的实际内容（用 pandas 打开看列名、行数、抽样几行实际数据）：
- `data/intermediate/aa_match_report.csv`
- `data/intermediate/manual_match_review.csv`
- `data/intermediate/unmatched_models.csv`
- `data/intermediate/main_model_release_events_date_review.csv`
- `data/intermediate/manual_review_needed.csv`
- `data/intermediate/low_confidence_matches.csv`

对每个文件回答：这个文件是什么阶段产生的（输入是什么、大概是哪个脚本生成的——可以用
`grep -rl "<文件名>" scripts/` 反查是哪个脚本读写了这个文件）、有多少行、记录的是"被保留"还是
"被剔除"的候选、有没有列能看出具体的剔除/保留理由（比如某一列是 `match_status` 或 `decision` 之类，
要看实际取值分布，不要只看列名猜测）。

然后追踪 `data/canonical/` 目录下的 6 个文件，确认上面笔记里第6点的猜测（这些是从最终面板反向导出的
描述性文件，不是清洗过程的中间产物）是否成立——如果不成立，要重新确认它们的真实生成逻辑
（用 `grep -rl "event_master_from_panel\|company_master_from_panel" scripts/` 反查生成脚本）。

**交付物**：
- `agent_tasks/event_selection_provenance_2026062515/outputs/C_aa_matching_and_company_mapping.md`：
  说明模型候选如何匹配到 AA 数据库指标、如何匹配/排除到具体上市公司，每个中间文件的实际作用和
  保留/剔除的具体数字，以及 canonical 目录文件的真实生成逻辑确认。
- `agent_tasks/event_selection_provenance_2026062515/logs/C_status.md`：简短状态日志。

## Phase 2：综合整理（1 个子代理，依赖 Phase 1 全部完成）

### 子代理 SYNTHESIS — 整合时间线，写最终给用户看的说明文档

**任务**：读取 A、B、C 三份输出文档（以及它们各自的状态日志），把整条筛选链路按时间顺序、
因果顺序整合成一份用户能看懂的叙事文档。结构建议：

1. **起点**：从 AI Timeline 抓取 235 条原始记录（2026-04-27 抓取），解析出 266 个模型候选。
2. **第一层人工筛选**：用户记得的"删掉产品只留模型"对应的具体步骤（引用子代理A的发现，
   如果A发现这一步有codebook规则就引用规则，如果只是纯人工判断没有留痕就明确说"未找到可追溯标准"）。
3. **脚本清洗阶段**：`clean_event_panel.py` 做了哪些自动化筛选（模态过滤？Tier过滤？日期精度过滤？
   公司可匹配性过滤？引用子代理B的漏斗表格）。
4. **AA匹配与公司映射阶段**：哪些候选因为匹配不到上市公司或匹配置信度太低被剔除
   （引用子代理C的发现和具体数字）。
5. **最终结果**：266个候选 → ... → 60个事件，每一步损失多少、损失的主要原因是什么。
6. **诚实的空白地带**：明确列出哪些环节没有找到可追溯的文档/代码依据，是纯人工判断、
   且当时没有留下标准说明的——告诉用户这些环节如果要在论文方法论部分写清楚，
   现在需要用户自己回忆补充，而不是研究团队能从痕迹里反推出来的。

**交付物**：
- `agent_tasks/event_selection_provenance_2026062515/outputs/event_selection_full_timeline.md`
  （这是最终给用户看的主文档，要写得清楚、按时间顺序、有具体数字支撑，不要写成日志体）
- `agent_tasks/event_selection_provenance_2026062515/logs/SYNTHESIS_status.md`

## Phase 3：审阅（1 个子代理，独立审计）

### 子代理 REVIEW — 核查溯源文档的真实性

**任务**：随机抽查 `event_selection_full_timeline.md` 里至少 6 个具体数字/事实陈述，回到原始文件
（脚本、报告、中间csv）独立核实是否真的有依据，而不是子代理凭推测写的。特别检查：
- 漏斗表格里每一步的数字是否真的能在某个文件里找到对应依据，而不是凑出来的。
- "未找到可追溯依据"的环节是否真的经过了认真搜索（检查A/B/C的状态日志和搜索过程），
  而不是偷懒没找就直接写"未知"。
- 文档语言是否诚实区分了"有文档依据的事实"和"基于间接证据的合理推测"——
  如果两者混在一起没有区分标注，这是需要打回去修订的问题。

**交付物**：
- `agent_tasks/event_selection_provenance_2026062515/review/review_findings.md`
- 给主agent的简短状态摘要（PASS / 需要修订的具体问题清单）

## Phase 4：主agent根据审阅结果决定是否需要修订，并写最终总结

主agent读审阅结果，如果有需要修订的具体问题，直接小修或派一个针对性的修订子代理；
最后写 `agent_tasks/event_selection_provenance_2026062515/final_summary.md`。

## 依赖关系图

```
Phase 1 (并行): 子代理A、子代理B、子代理C  ──┐
                                              ├──> Phase 2: SYNTHESIS ──> Phase 3: REVIEW ──> Phase 4: 主agent收尾
                                              ┘
```
