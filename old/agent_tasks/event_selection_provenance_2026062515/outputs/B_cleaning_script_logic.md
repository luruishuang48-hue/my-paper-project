# B. clean_event_panel.py 等清洗脚本的筛选逻辑溯源

## 核心结论（先说重点）

**`scripts/prep/clean_event_panel.py`（以及 `specr_prep.py`、`specr_rel_prep.py`、`specr_rel_prep_v2.py`）
都不包含把候选事件从266个/任何更大数字筛选到60个的逻辑。** 这4个脚本全部读取的输入文件
（`事件集数据.csv` / `事件集数据-new.csv` / `事件集数据-relationships.csv` / `事件集数据-relationships_v2.csv`）
在脚本运行**之前**就已经是 60个事件 × 86家公司 = 5,160行（或+1行表头/空行）的**事件-公司面板**结构，
而不是一份266个候选事件的列表。也就是说：

- 266 → 60 的筛选（事件层面的取舍）发生在这些脚本的输入文件生成之前，属于更上游的人工/半人工筛选阶段
  （任务A"抓取与人工审核阶段"和任务C"AA匹配与公司映射阶段"的范畴），**不在 `clean_event_panel.py` 的代码逻辑里**。
- `clean_event_panel.py` 拿到手的，已经是逐事件确定了"哪些上市公司受影响"之后展开的事件×公司面板
  （每个事件固定对应86家公司，结构完全平衡），它只做**列重命名、类型转换、缺失值统计、面板结构校验**，
  不做任何会改变事件数量或公司数量的 drop/filter 操作。

这是用代码逐行验证后的结论，证据见下文。

---

## 1. 直接证据：脚本自身生成的清洗报告

脚本运行后生成的 `cleaning_report.md`（仓库里有两份归档副本：`data/source_reports/cleaning_report.md`
和 `reports/cleaning_report.md`，内容一致）第1节明确写着：

```
- Path: .../事件集数据.csv
- Encoding: gb18030
- Raw rows: 5161
- Raw columns: 106
- Empty rows removed: 1
- Empty columns removed: 1 (indices: [13])
- Cleaned rows: 5160
- Cleaned columns: 107
```

第7节（Event-Firm Panel Check）：
```
- Events: 60
- Firms: 86
- Observations: 5160
- Balanced panel: True
- Firms per event: 86 – 86 (all events have exactly the same set of firms)
- Duplicate (event x firm) keys: N/A / 0
```

也就是说脚本输入的原始行数是5,161行数据，只移除了1行全空行，得到5,160行清洗后数据——
**事件数量从始至终都是60，脚本没有删除任何一个事件或任何一家公司**。

我用 pandas 独立重新读取了归档的输入文件副本（`archive/old_relationship_20260625/task/事件集数据.csv`，
与脚本读取的 `事件集数据.csv` 是同源文件的归档版本）做了交叉验证：

```
rows (skiprows=2): 5161
unique value count of 事件ID(final_event_id) 列: 61  (其中包含1个空字符串 ''，即对应被移除的那1行空行)
```

去掉空字符串后正好是 **60个唯一事件ID**，与脚本报告完全吻合。

---

## 2. 逐函数过一遍 clean_event_panel.py（共927行），确认没有遗漏的筛选逻辑

读取方式：用 Read 工具分3段（1-250、250-500、500-927行）通读了全文，逐段记录如下。

### 第48-74行：读取原始数据
`read_raw_data()` 只是按"两行表头+数据"的格式读 CSV，无筛选。

### 第89-120行：移除空行/空列（唯一会改变行数的逻辑）
```python
empty_row_mask = df.apply(lambda row: (row == "").all(), axis=1)
df = df[~empty_row_mask].copy()
```
规则：**只移除"所有列都是空字符串"的行**（彻底空行），不是"某个字段缺失"就删。
实测效果：移除了1行（见上面报告数据，`empty_rows_removed = 1`）。这不是事件筛选，是去掉一行
彻底空白的表格行（很可能是表格里残留的空白行）。

列方向同理：
```python
empty_col_mask = [data_empty and header_empty for ...]
```
规则是"数据全空 **并且** 中英文表头都为空"才删除，移除了1列（col index 13）。脚本注释里特别强调：
"Named columns like 'relationship' are kept even if all values are empty" ——
即使 `relationship` 列100%缺失（后面第10节有专门校验，确认该列在这份输入里全空），
脚本**仍然保留**该列，没有因为它全空而删事件或删列。这与最终面板里看到 `relationship` 长期空白、
后续靠 `specr_rel_prep.py`/`specr_rel_prep_v2.py` 重新合并关系变量的事实吻合。

### 第123-282行：处理重复列名/无名列
纯粹是列重命名逻辑（CAR列拆成market model版本/FF3版本，windows-*列拆成mean/sd），
**不涉及任何行的增减**。

### 第289-422行：日期解析（release_date / release_month）
`parse_date_mixed()` / `parse_month_to_ym()` 尝试多种格式（Excel序列号、YYYY/M/D、YY-Mon等），
解析失败时返回 `pd.NaT` 并记录到 `date_failures` / `month_failures` 列表，**但不会删除该行**——
失败的值仅以 NaT/NA 形式保留在原行里，行数不变。报告里第4节会列出失败样例，
实际报告显示 release_date/release_month 解析失败数为0（脚本注释提到"Excel serial 46098 → 2026-03-17
(FMR-0060 GPT-5.4 family, 82 rows)"已被正确解析，没有出现因为日期模糊/只有年月而被剔除的情况）。

**结论：没有"日期精度不够就剔除事件"的逻辑**。即使某条目只有年-月没有日，也只是在
`release_date` 字段留下 NaT，不影响事件是否进入最终面板（因为决定进入面板的判断早已在更上游完成）。

### 第425-479行：数值类型转换
`numeric_candidates` 列表收录 CAR列、媒体情绪列、财务控制变量、AA能力指标、价格/速度指标等，
统一做 `pd.to_numeric(errors="coerce")`，转换失败变成 NaN，**同样不删行**。
脚本只在某列缺失率超过50%时打印 WARNING（例如 `aa_math_index` 61.7%缺失、`aa_media_*` 78.3%缺失），
报告里也写明"Do NOT blindly delete these columns; they are structurally missing based on model type"——
明确告诉使用者这是结构性缺失（比如媒体生成模型没有数学指标），**不要因此删除事件或列**。

### 第482-554行：面板结构校验
计算 `n_events = df['final_event_id'].nunique()`、`n_firms = df['company_id'].nunique()`，
检查 `df.duplicated(subset=[eid_col, cid_col], keep=False)` 找重复的(事件,公司)键对——
**这是检测逻辑，不是过滤逻辑**：如果发现重复键，脚本只是把重复行另存为
`duplicate_event_firm_rows.csv` 供人工核查，**没有 `df = df[~dup_mask]` 这种自动删除重复行的代码**。
实际报告显示 `n_duplicate_keys = 0`，也就是这份输入数据本身没有重复键，这一步未产生任何实际删除。

### 第556-578行：检查 search_code_2 列
纯诊断，发现该列99%以上的值是固定的财务报告季度"2024Q2"（59/60个事件用带横线格式，
仅FMR-0001用不带横线格式），结论是"建议保留但不作为时变回归变量"，**不涉及行筛选**。

### 第580-636行：关键变量缺失统计
对 `key_vars`（包括 final_event_id, release_date, company_id, relationship, mkt_car_*, ff3_car_* 等）
逐列统计缺失数/缺失率，**仅统计，不删除**。报告里特别记录 `relationship` 列100%缺失
（5160/5160行全空），并加了一条 "CRITICAL" 提示——但这条提示是给后续人工/脚本补充关系变量用的，
不是反过来去筛选事件。

### 第638-926行：保存输出 + 生成报告 + 终端汇总
全部是落盘/打印逻辑，没有进一步的数据筛选代码。

### 全文检索结果
对全文搜索 `drop(`、`.loc[`、布尔索引赋值等模式，**唯一出现"行筛选"语义的代码就是第93-95行的空行移除**
（`df = df[~empty_row_mask].copy()`），以及第106行的空列移除（按列筛选，不影响行数/事件数）。
没有发现任何 `if modality == ...: continue`、`if tier == ...: skip`、按 Tier/模态/匹配状态做
`drop_duplicates` 或条件剔除的代码。

---

## 3. 模态（modality）假设验证：结论是"没有模态筛选"，证据如下

任务背景猜测"最终面板可能只保留了文本/推理类LLM"——**用真实数据验证后，这个猜测不成立**。

用 pandas 读取 `data/panel/specr_rel_clean.csv`（5,160行，60个唯一 `final_event_id`），
按事件去重后统计 `model_modality`（事件层面字段，行内对同一事件恒定）：

| model_modality | 事件数 |
|---|---|
| text_llm | 21 |
| reasoning_llm | 17 |
| image_generation | 6 |
| video_generation | 6 |
| multimodal_llm | 5 |
| coding_llm | 4 |
| image_editing | 1 |
| **合计** | **60** |

可见最终60个事件覆盖了7种模态，文本/推理类LLM合计38个（21+17），但图像生成、视频生成、
多模态、代码、图像编辑合计22个事件**也都保留在最终样本里**。**脚本代码里也找不到任何按
`model_modality` 过滤的逻辑**——这与抓取阶段11种模态、266个候选模型的模态分布
（text_llm 121、image_generation 36、reasoning_llm 26、video_generation 23、multimodal_llm 21、
music_generation 11、coding_llm 11、vision_language_model 8、audio_speech 5、image_editing 3、
world_model 1）对比，可以看到 `music_generation`、`vision_language_model`、`audio_speech`、
`world_model` 这4种模态在最终60个事件里**完全消失**（0个事件），但这4种模态加起来在候选池里只有
11+8+5+1=25个候选，是否被剔除的判断逻辑发生在更上游（不在本次审计的4个脚本里）。

**诚实说明**：这4种模态为何消失、是因为"无法匹配上市公司"还是"人工认为不够重要"还是别的原因，
**本次审计的代码里没有找到依据**，需要任务A/C去追溯抓取后的人工筛选记录。

---

## 4. 是否存在"上市公司匹配"相关的筛选逻辑

**`clean_event_panel.py`、`specr_prep.py`、`specr_rel_prep.py`、`specr_rel_prep_v2.py`
这4个脚本的全文里，没有任何一处引用 `aa_match_report.csv` 或 `unmatched_models.csv`**
（用 `grep -n "aa_match_report\|unmatched_models\|intermediate"` 对4个脚本全文搜索，
唯一命中的是 `clean_event_panel.py` 里变量名包含"intermediate"这个英文单词本身的几行代码，
与 `data/intermediate/` 目录完全无关）。

进一步核查 `data/intermediate/aa_match_report.csv` 的内容后发现，这个文件记录的是
**候选事件 → Artificial Analysis (AA) 能力基准数据库模型ID 的匹配状态**（列名包括
`aa_match_status`（unmatched/matched_low_confidence/matched_confirmed）、`aa_model_id`、
`match_score` 等），**不是"候选事件 → 可交易上市公司"的匹配**。该文件共79行候选
（`aa_match_status`: unmatched 31、matched_low_confidence 27、matched_confirmed 21），
`needs_manual_review` 标记为1的有58行。这明显是**任务C"AA匹配与公司映射阶段"**的产物，
不属于本次审计范围内的清洗脚本逻辑。

因此：**"是否能匹配到上市公司"这一筛选维度，在 `clean_event_panel.py` 等4个脚本里找不到任何代码依据**。
最终面板里"公司"维度的体现，是脚本拿到手时事件×公司面板已经做好（每个事件固定映射到86家公司），
这86家公司的确定过程发生在更上游，不在这4个脚本里。

---

## 5. 是否存在"日期精度"相关的筛选逻辑

**没有找到依据**。如第2节分析，`parse_date_mixed()` / `parse_month_to_ym()` 对解析失败的日期值
只是赋值为 NaT/NA，不删除整行。脚本注释甚至特别处理了 Excexcel序列号格式
（"Excel serial 46098 → 2026-03-17 (FMR-0060 GPT-5.4 family, 82 rows)"），
说明开发者是希望尽量保留、解析所有日期格式，而不是把模糊日期的事件剔除。
报告第4节显示实际解析失败数为0，也就是这份已经筛好的60事件输入数据里，
所有事件的 release_date 都成功解析了——但这可能是因为"无法确定精确日期的候选"
**已经在更上游被排除**（在变成这60个事件之前），而不是这个脚本本身做了剔除。
这一点需要任务A去追溯。

---

## 6. 是否存在"Tier"相关的筛选逻辑

**脚本代码里没有找到任何按 `candidate_tier` 过滤的逻辑**（全文搜索未发现 `tier` 相关的
条件判断/drop操作；`candidate_tier` 只在 `event_summary_cols` 列表里作为"如果存在就纳入摘要"
的展示字段出现，第537行）。

用真实数据验证最终面板的 Tier 分布（按事件去重后统计 `candidate_tier`）：

| candidate_tier | 事件数 |
|---|---|
| Tier 2 | 31 |
| Tier 1 | 27 |
| Tier 3 | 2 |
| **合计** | **60** |

对比抓取阶段的候选池 Tier 分布（Tier 1: 134、Tier 2: 125、Tier 3: 7），可以看到：
- Tier 1 候选134个 → 最终27个事件（约20%留存）
- Tier 2 候选125个 → 最终31个事件（约25%留存）
- Tier 3 候选7个 → 最终2个事件（约29%留存）

三个Tier都有相当比例的留存，且**留存比例彼此接近**（20%-29%），并不存在"只留Tier 1"或
"剔除Tier 3"这种简单的硬性Tier筛选规则的痕迹。**结论：没有发现按Tier做硬性筛选的代码依据**，
实际筛选标准（无论是什么）跨越了所有3个Tier，应该是基于其他维度（比如是否能精确定位发布日期、
是否有清晰的上市公司风险敞口等）做的判断，而不是简单按Tier分层去取舍。

---

## 7. specr_prep.py / specr_rel_prep.py / specr_rel_prep_v2.py 的角色确认

逐文件确认（非仅凭文件大小判断，已读取全文）：

- **`specr_prep.py`**（53行）：读取 `事件集数据-new.csv`（GB18030编码），转成UTF-8、重命名几个
  含空格/特殊字符的列名（如 `size (log_assets)` → `size_log_assets`），输出 `specr_input_clean.csv`。
  末尾打印诊断信息（事件数、非缺失计数、`relationship`/`creator_type`/`model_modality` 的值分布），
  **纯编码转换+诊断脚本，不含任何筛选逻辑**。

- **`specr_rel_prep.py`**（92行）：读取 `task/事件集数据-relationships.csv`（UTF-8），
  把中文列名（如"市场模型异常收益时间窗口1"）映射为英文（如 `car_1`），对数值列做
  `pd.to_numeric(errors='coerce')`，输出 `specr_rel_clean.csv`。**纯重命名+数值化脚本**。
  唯一与本任务相关的信息：列名映射表里包含 `'模型的模态': 'model_modality'` 和
  `'候选事件重要性分层，Tier 1 最高': 'candidate_tier'`，说明这两个字段是**贯穿保留**
  下来的元数据，而不是被这个脚本用来筛选的依据。

- **`specr_rel_prep_v2.py`**（101行）：与 `specr_rel_prep.py` 几乎是镜像（脚本注释自称
  "镜像 specr_rel_prep.py 的清洗逻辑，仅替换输入/输出路径并扩展数值化列表"），读取
  `task/事件集数据-relationships_v2.csv`，增加了仲裁后的新关系列
  （`upstream_hardware`, `upstream_cloud`, `downstream_integrator`, `downstream_deployer`,
  `downstream_enabler`, `competitor_new`, `is_investor`, `is_owner`）。**同样不含事件数量筛选逻辑**。

三个脚本的输出文件都报告 `df['final_event_id'].nunique()`，按脚本设计意图，这只是一个
"健全性检查打印"，用来确认转换过程没有意外增减事件数，**不是筛选机制本身**。

---

## 8. 漏斗表格：从候选池到最终60个事件

**重要说明**：本次审计只覆�盖了 `scripts/prep/` 目录下4个清洗脚本的代码逻辑。这4个脚本的输入文件
本身就已经是60个事件，所以下面漏斗表的"中间环节"主要基于已知的背景事实（抓取阶段数据）和
`data/intermediate/` 文件做交叉验证，**266→60之间具体在哪一步、按什么规则收窄，本次审计在这4个
清洗脚本里找不到代码依据**，需要任务A/C的溯源结果来补全。

| 阶段 | 候选/事件数 | 数据来源 | 依据类型 |
|---|---|---|---|
| AI Timeline 抓取候选模型 | 266个模型候选 | 任务背景给出的已确认事实 | 已知背景事实 |
| ……（中间筛选步骤未知）…… | ? | 需要任务A/C溯源 | 待补全 |
| AA能力库匹配状态统计 | 79个候选条目（matched_confirmed 21 / matched_low_confidence 27 / unmatched 31） | `data/intermediate/aa_match_report.csv` | 真实数据，但**不属于本次审计的4个清洗脚本**，是任务C范畴 |
| `clean_event_panel.py` 等4个脚本的输入 | 60个事件（5,161行数据，含1行全空行） | `事件集数据.csv` 及其变体（`-new.csv`、`-relationships.csv`、`-relationships_v2.csv`），归档于 `archive/old_relationship_20260625/task/` | 直接读取归档文件验证 |
| `clean_event_panel.py` 清洗后 | 60个事件 / 86家公司 / 5,160行（移除1行全空行，无事件层面筛选） | `data/source_reports/cleaning_report.md`、`reports/cleaning_report.md`（脚本自动生成的报告） | 脚本输出报告 + 代码逐行核查 |
| `specr_rel_prep.py` / `_v2.py` 处理后 | 60个事件，列重命名+数值化，事件数不变 | `data/panel/specr_rel_clean.csv`（5,160行，60个唯一 `final_event_id`，已用pandas验证） | 真实数据交叉验证 |
| **最终面板** | **60个事件 / 86家公司 / 5,160行** | `data/panel/specr_rel_clean.csv` | 真实数据 |

---

## 9. 诚实的不确定性清单

**代码里有明确依据的结论：**
1. `clean_event_panel.py` 全程只移除了1行全空行，没有任何按模态/Tier/匹配状态/日期精度
   筛选事件的代码逻辑（已逐行通读全部927行验证）。
2. `specr_prep.py`、`specr_rel_prep.py`、`specr_rel_prep_v2.py` 三个脚本同样不含事件数量筛选逻辑，
   只做列重命名/编码转换/数值化（已逐行通读全文验证）。
3. 最终面板覆盖7种模态（text_llm 21、reasoning_llm 17、image_generation 6、video_generation 6、
   multimodal_llm 5、coding_llm 4、image_editing 1），证伪了"只保留文本/推理类LLM"的猜测
   （已用pandas读取 `data/panel/specr_rel_clean.csv` 验证）。
4. 最终面板覆盖全部3个Tier（Tier 1: 27、Tier 2: 31、Tier 3: 2），证伪"只保留某个Tier"的猜测
   （已用pandas验证）。
5. `data/intermediate/aa_match_report.csv` 和 `unmatched_models.csv` 未被这4个清洗脚本引用
   （已用grep对4个脚本全文搜索验证），它们属于AA能力库匹配阶段（任务C范畴），与本次审计的
   清洗脚本无关。

**基于代码行为的合理推断（非脚本直接证据）：**
1. 266个候选 → 60个事件的核心筛选，发生在这4个清洗脚本运行**之前**，即生成
   `事件集数据.csv`/`事件集数据-new.csv` 等文件本身的那个（人工或半人工）过程里，
   不在 `scripts/prep/` 目录的Python代码中体现。
2. `relationship` 列在 `clean_event_panel.py` 处理时100%缺失，说明那一批60个事件在被纳入
   `事件集数据.csv` 时，关系变量是后续单独用 `specr_rel_prep.py`/`merge_adjudicated_relationships.py`
   补充合并进来的，不是清洗脚本自己生成或筛选的。
3. 音乐生成(music_generation)、视觉语言模型(vision_language_model)、语音(audio_speech)、
   世界模型(world_model)这4种模态在最终60个事件里完全消失，但具体剔除原因/剔除环节
   不在本次审计范围的代码里。

**完全没有找到依据、需要其他任务补全的：**
1. 266→60具体的逐步筛选规则（比如是否有"无法精确到日"的剔除、是否有"无法匹配到可交易上市公司"
   的剔除、是否有人工主观判断的"事件重要性"剔除）——这些猜测在本次审计的4个清洗脚本代码里
   **都没有找到任何代码层面的实现**，需要任务A（抓取与人工审核阶段）和任务C（AA匹配与公司映射阶段）
   的溯源来还原。
2. `data/intermediate/` 下 `manual_match_review.csv`（58行需人工复核）、`manual_review_needed.csv`、
   `low_confidence_matches.csv`、`main_model_release_events_date_review.csv` 这几个文件具体如何
   影响了最终60个事件的取舍——本次审计只确认了它们不被这4个清洗脚本引用，但没有深入这些文件
   本身的内容溯源（按任务边界，这部分属于任务A/C）。
