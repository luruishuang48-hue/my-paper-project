# 多代理执行计划：论文 B 写作计划落地 + 5 项稳健性回归

创建时间：2026-06-25 14:15 (Beijing)
工作目录：`agent_tasks/paper_b_robustness_2026062514/`

## 任务目标（用户原始请求）

1. 把论文 B（*Who Gains, Who Loses? Ecosystem Position Repricing from LLM Releases*）的完整写作计划总结为一份 md 文件
2. 跑 5 个新增稳健性回归：
   - R1：upstream_hardware vs upstream_cloud 系数差异的正式 Wald/lincom 检验
   - R2：downstream_deployer 作为唯一关系变量的专项稳健性回归（CAR[0,+1] 到 [0,+20] 全窗口 + CR2 + wild bootstrap）
   - R3：剔除 DeepSeek R1 事件后重估 + leave-one-event-out + leave-one-firm-out
   - R4：FF3 三因子模型替代 market model，重跑 Table 1/Table 2 核心行
   - R5：对 Table 1-4 核心系数补充 wild cluster bootstrap p 值（Rademacher, B=4999）

## 关键事实核查（已在规划阶段验证，子代理直接复用，不要重新验证）

- **数据源**：`data/panel/specr_rel_clean.csv`（5,160+ 行，新旧关系列共存——新 8 维列
  `upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer,
  downstream_enabler, competitor, is_investor, is_owner` 和旧列
  `owner, investor, cloud, real_upstream, business_upstream, real_downstream,
  business_downstream` 同时存在于该文件中。**所有新回归必须只使用新 8 维列**，
  不要误用旧列。
- **Table 1-5 的源脚本**：`scripts/analysis/paper_plan_core_outputs.R`
  （已读取并确认）。复刻其规格惯例：
  - 控制变量：`size_log_assets, bm_ratio, volatility, momentum` + `factor(release_year)`
  - 聚类：按 `final_event_id`，`se_type = "CR0"`（用 `estimatr::lm_robust`）
  - 结果变量：`car_10, car_15, car_20`（百分点 = estimate × 100）
  - position_vars（基准 6 个）：`upstream_hardware, upstream_cloud,
    downstream_integrator, downstream_deployer, downstream_enabler, competitor`
  - bundle 变量：`upstream_any (upstream_hardware|upstream_cloud)`,
    `strategic_any (+ is_investor|is_owner)`,
    `downstream_any (downstream_integrator|downstream_deployer|downstream_enabler)`,
    `downstream_deployer`
  - 开闭源交互：`x * is_open_weight`，用 linear_combo 算 closed/open/diff 三行
  - 样本量基准：全样本约 4,829 条非缺失观测，60 个事件；控制 AA Intelligence 后
    降至约 3,780 条、47 个事件
  - DeepSeek R1 事件：`final_event_id == "FMR-0021"`（已用 Python 核实，
    `release_date = 2025/1/22`）
- **Wild cluster bootstrap 复用代码**：`scripts/analysis/core_table.R` 第 69-111 行
  的 `wild_boot_p()` 函数已经实现 Rademacher (±1) wild cluster bootstrap，
  impose-null 方法，默认 `B=4999`，`seed=42`，对 cluster 数 < 5 的样本返回 NA。
  子代理应直接复制这个函数到新脚本里，不要重新发明。
- **CR2 复用代码**：同文件第 62-67 行的 `refit_cr2()` 函数。
- **现有 v2 回归与发现**（写文档时必须引用，不要重新调研）：
  - `agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md`
    — 6 个脚本迁移的综合审阅，downstream_deployer 三脚本收敛证据、
    upstream hardware vs cloud 异质性的具体数字都在这里
  - `data/relationships/RELATIONSHIP_CODING_WORKFLOW_REPORT.md`
    — 完整编码方法论记录（双盲编码、κ=0.986、仲裁流程）
  - `Tex/long.tex` — 论文 B 当前稿，Table 1-5 + 正文已成形（中文）
  - `Tex/frl_draft_main_text.tex` — 论文 A（FRL，与论文 B 范围不同，不要混淆/不要修改）

## 范围边界（重要：防止子代理任务蔓延）

- 不修改 `data/panel/specr_rel_clean.csv` 或任何现有产出文件
- 不修改 `Tex/long.tex` 本身——本次任务只产出新的回归结果和一份独立的写作计划 md，
  不在本轮重写论文正文（写作计划文件里可以给出"建议如何把新结果插入 long.tex"的说明，
  但不直接改 tex）
- 不跑论文 A（FRL）相关的任何内容
- 不跑论文 C（媒体情感）相关的任何内容
- 5 个回归任务各自独立，互不依赖，可完全并行

---

## Phase 1：规划阶段（信息收集与方案规划）— 已完成

本阶段由主代理直接完成（探索关键文件、核实数据列、核实源脚本逻辑、核实
DeepSeek R1 事件 ID、定位可复用的 wild bootstrap 代码），不再派子代理重复探索。
以上"关键事实核查"章节即为本阶段产出，供 Phase 2 子代理直接使用。

---

## Phase 2：实施阶段（5 个回归子代理 + 1 个文档子代理，全部并行）

每个子代理必须：
- 读取本计划文件的"关键事实核查"和"范围边界"章节
- 将 R 脚本保存到 `agent_tasks/paper_b_robustness_2026062514/scripts/`
- 将运行日志保存到 `agent_tasks/paper_b_robustness_2026062514/logs/`
- 将结果 CSV/表格保存到 `agent_tasks/paper_b_robustness_2026062514/outputs/`
- 写一份 100-200 字的简短状态摘要到
  `agent_tasks/paper_b_robustness_2026062514/logs/{agent_name}_status.md`，
  只在状态摘要里汇报给主代理，**不要把完整回归输出粘贴回主对话**
- 文件命名加前缀区分：`r1_`, `r2_`, `r3_`, `r4_`, `r5_`

### Agent R1：upstream_hardware vs upstream_cloud 系数差异检验

**任务**：在同一回归中同时纳入 `upstream_hardware` 和 `upstream_cloud`
（而不是分别单独回归），对 `car_10, car_15, car_20` 三个窗口，用
`car ~ upstream_hardware + upstream_cloud + size_log_assets + bm_ratio +
volatility + momentum + factor(release_year)`，CR0 聚类标准误（cluster =
final_event_id）。然后对 `upstream_hardware - upstream_cloud = 0` 做正式检验
（线性组合检验，可用 `car_table.R` 里 `linear_combo` 风格的手算 Wald 检验：
`diff = b1 - b2`, `var(diff) = var(b1) + var(b2) - 2*cov(b1,b2)` 从 `vcov(mod)`
中取，`z = diff/se(diff)`，双侧 p 值）。

**输出**：
- `outputs/r1_hardware_vs_cloud_diff.csv`（每个窗口一行：beta_hardware, se_hardware,
  beta_cloud, se_cloud, diff, se_diff, z, p_value, n, n_events）
- `outputs/r1_hardware_vs_cloud_diff.md`（人类可读的结果说明，2-3 句话总结
  是否显著不同，对比之前 review_regressions_summary.md 里提到的描述性差异）
- `scripts/r1_hardware_cloud_wald_test.R`

### Agent R2：downstream_deployer 专项稳健性回归

**任务**：以 `downstream_deployer` 为唯一关系自变量（不与其他关系变量同时进入），
跑全部窗口 `car_1, car_2, car_3, car_5, car_10, car_15, car_20`（注意这些列在
`specr_rel_clean.csv` 中均存在）。每个窗口：
1. CR0（`lm_robust(..., se_type="CR0")`）
2. CR2（复用 `core_table.R` 的 `refit_cr2()`）
3. Wild cluster bootstrap（复用 `core_table.R` 的 `wild_boot_p()`，B=4999, seed=42；
   restricted model 是去掉 `downstream_deployer` 项的同一公式）

**输出**：
- `outputs/r2_downstream_deployer_robustness.csv`（每个窗口一行：beta, se, n, n_events,
  p_cr0, p_cr2, p_wild）
- `outputs/r2_downstream_deployer_robustness.md`（总结：效应在哪些窗口最强、
  三种推断方法是否一致，并与 `review_regressions_summary.md` 中提到的
  `run_relationship_specr`（coef -0.019, p=0.0004）和 `relonly_regression`
  的结果做对比验证是否量级吻合）
- `scripts/r2_downstream_deployer_dedicated.R`

### Agent R3：剔除极端事件 + leave-one-out 分析

**任务**：基准规格用 Table 2 的核心行设定（`car_20 ~ position_var + controls + year FE`，
CR0），对 `upstream_hardware`, `downstream_deployer`（最重要的两个发现）做三组检验：

1. **剔除 DeepSeek R1**：过滤 `final_event_id != "FMR-0021"` 后重估上述两个系数，
   对比剔除前后的 beta/se/p，确认结论是否仅靠这一个事件撑起来
2. **Leave-one-event-out**：对每个唯一 `final_event_id`，剔除该事件后重估
   `upstream_hardware` 和 `downstream_deployer` 在 car_20 上的系数，存成
   一个长表（每行 = 剔除的 event_id + 该次估计的 beta/se/p），并报告 beta 的
   最小值/最大值/标准差，判断结果对单个事件的敏感度
3. **Leave-one-firm-out**：同理，对每个唯一 `company`（或 `company_id`），
   剔除该公司后重估两个系数，存成长表并报告敏感度统计

**输出**：
- `outputs/r3_deepseek_exclusion.csv`
- `outputs/r3_leave_one_event_out.csv`
- `outputs/r3_leave_one_firm_out.csv`
- `outputs/r3_sensitivity_summary.md`（总结哪个事件/公司对结果影响最大，
  是否存在单一观测主导结论的情况）
- `scripts/r3_exclusion_sensitivity.R`

### Agent R4：FF3 三因子模型替代

**任务**：用 `ff3_car_10, ff3_car_15, ff3_car_20`（已存在于
`specr_rel_clean.csv` 中，FF3 三因子模型计算的 CAR）替代 market model 的
`car_10, car_15, car_20`，重跑：
1. Table 2 核心行（6 个 position_vars 的单独回归）
2. Table 3 bundle 核心行（`upstream_any`, `downstream_any`,
   `downstream_deployer`）

控制变量和聚类方式不变（CR0, cluster=final_event_id, controls + year FE）。

**输出**：
- `outputs/r4_ff3_table2_position.csv`
- `outputs/r4_ff3_table3_bundle.csv`
- `outputs/r4_ff3_comparison.md`（逐行对比 market-model 版本（来自
  `output/paper_plan_core/data/table2_baseline_position.csv` 和
  `table3_bundle_positions.csv`，如果这两个文件不存在就重新跑一遍 market-model
  基准作对比）与 FF3 版本的系数/显著性是否一致，特别关注 upstream_hardware 和
  downstream_deployer 是否在两种风险调整方式下都稳健）
- `scripts/r4_ff3_robustness.R`

### Agent R5：Table 1-4 核心系数的 Wild Cluster Bootstrap 补充

**任务**：对以下"核心系数"补充 wild cluster bootstrap p 值（B=4999, Rademacher,
impose-null，复用 `core_table.R` 的 `wild_boot_p()`）：
- Table 1/2（baseline position，car_20 窗口）：`upstream_hardware`,
  `upstream_cloud`, `downstream_deployer`, `downstream_enabler`,
  `downstream_integrator`, `competitor`（6 个系数）
- Table 2/3（bundle，car_20 窗口）：`upstream_any`, `downstream_any`（2 个系数）
- Table 3（joint regression，car_20 窗口，6 个变量同时进入一个模型）：
  同 6 个 position_vars 的联合回归系数（注意这是单个回归里的 6 个系数，
  不是 6 个独立回归）
- Table 4（开闭源交互，car_20）：`upstream_hardware`, `downstream_deployer`
  的交互项（open minus closed 那一行对应的交互系数本身）

每个系数都要同时报告 CR0 p、CR2 p、wild bootstrap p 三者对比。

**输出**：
- `outputs/r5_wild_bootstrap_table1to4.csv`（列：table_source, variable,
  outcome, beta, se, p_cr0, p_cr2, p_wild, n, n_events）
- `outputs/r5_wild_bootstrap_summary.md`（总结：哪些系数在 wild bootstrap 下
  跌出显著性边界，哪些保持稳健——重点关注 downstream_deployer 和
  upstream_hardware 这两个核心发现是否在最严格推断下依然显著）
- `scripts/r5_wild_bootstrap_core_tables.R`

### Agent DOC：写作计划文档

**任务**：基于以下内容（不要重新调研，直接整合），把论文 B 的完整写作计划
总结为一份独立的 md 文件：

输入材料（直接读取并整合，不要重新做分析）：
- 本对话中已经讨论并确认的论文 B 定位：标题方向
  *Who Gains, Who Loses? Ecosystem Position Repricing from LLM Releases*，
  核心命题（位置再定价、上游硬件正效应、下游部署型负效应、闭源中更突出）
- `Tex/long.tex` 的现有结构（8 节框架、Table 1-5、Figure 1-2、稳健性待办清单
  第 291-301 行）
- `agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md`
  的关键发现（downstream_deployer 三脚本收敛、upstream hardware vs cloud 异质性）
- `data/relationships/RELATIONSHIP_CODING_WORKFLOW_REPORT.md` 的方法论摘要
  （双盲编码 + κ=0.986 + 仲裁，将作为 Data Section 的方法论小节）
- 本任务 Phase 2 中 R1-R5 五个子代理产出的回归结果摘要（写文档前需要先等
  R1-R5 完成，读取它们的 `*.md` 摘要文件并把关键数字嵌入写作计划中的
  Robustness 章节，标注"已完成"）

**输出文件**：项目根目录 `PAPER_B_WRITING_PLAN.md`（不是临时目录，因为这是
长期参考文档，用户需要在根目录方便找到）

文档结构要求（沿用本对话中已经确认的 8 节框架，需包含）：
1. 定位（标题、目标期刊、核心命题）
2. 现有素材盘点表（每项标注"已完成"/"需新写"，引用具体文件路径）
3. 5 项稳健性回归结果汇总（嵌入 R1-R5 的关键数字和结论，每项注明产出文件路径）
4. 论文结构 8 节表（节名、内容、对应表图、状态）
5. 不在本论文范围内的内容清单（媒体情感深挖、PSM-DID、样本扩展、时间趋势/
   体制转换分析——并注明各自应去哪篇论文）
6. 工作量估计表（沿用之前讨论的 5-7 天估计，更新已完成的稳健性回归后的
   剩余工作量）

**重要**：DOC agent 必须在 R1-R5 全部完成后才能启动（依赖关系），因此实际
派发时机是 Phase 2 的"第二批"，不与 R1-R5 同批并行。

---

## Phase 3：审阅阶段（独立审阅，2 个子代理并行）

### Agent REVIEW-DATA：回归正确性审阅

独立重新抽查 R1-R5 的关键数字：
- 随机选 2 个回归（例如 R2 的 car_20 行和 R5 的 joint regression 行），
  自己重新跑一遍核对数字是否一致
- 检查所有脚本是否真的只用了新 8 维列，没有混用旧列
  （`grep -n "owner\|investor\|cloud\|real_upstream\|business_upstream\|real_downstream\|business_downstream"`
  在 5 个脚本里搜索，确认这些字符串只在变量名如 `is_owner`/`is_investor`/
  `upstream_cloud`/`downstream_integrator` 等新列名的子串中出现，不是独立引用旧列）
- 检查 DeepSeek R1 排除是否用了正确的 `final_event_id == "FMR-0021"`
- 检查 wild bootstrap 是否真的用了 B=4999、Rademacher、impose-null 方法
  （读脚本代码确认，不是道听途说）
- 输出：`review/review_data_correctness.md`（检查项列表 + 结论，发现的任何
  问题需要明确标注严重程度）

### Agent REVIEW-CONTENT：写作计划文档质量审阅

独立审阅 `PAPER_B_WRITING_PLAN.md`：
- 是否准确反映了本对话中讨论的论文 B 定位（与本计划文件开头的"任务目标"
  对照检查，不要凭空判断）
- 是否准确引用了 R1-R5 的真实数字（抽查 3 处引用，回到对应的 outputs/*.csv
  核对数字一致）
- 工作量估计是否合理更新（已完成 5 项稳健性回归后，剩余工作量应该减少）
- 是否有遗漏的重要素材（比如检查是否提到了 `RELATIONSHIP_CODING_WORKFLOW_REPORT.md`
  的方法论贡献）
- 输出：`review/review_content_quality.md`

---

## Phase 4：修订阶段

根据 Phase 3 两份审阅报告，主代理直接判断是否需要派修订子代理：
- 如果 REVIEW-DATA 发现严重问题（如混用旧列、wild bootstrap 实现错误），
  派 1 个修订子代理针对性修复对应的 R 脚本并重新运行
- 如果 REVIEW-CONTENT 发现写作计划文档有数字引用错误或结构缺陷，
  派 1 个修订子代理直接修改 `PAPER_B_WRITING_PLAN.md`
- 如果两份审阅都显示"无重大问题，仅有改进建议"，主代理可以直接采纳建议
  小幅修订，不必再派子代理

修订完成后，主代理整合所有产出，写最终总结报告：
`agent_tasks/paper_b_robustness_2026062514/final_summary.md`

---

## 任务依赖图

```
Phase 1 (主代理已完成)
   |
Phase 2a: R1, R2, R3, R4, R5  (5 个子代理完全并行)
   |
Phase 2b: DOC  (依赖 R1-R5 全部完成，读取其 .md 摘要)
   |
Phase 3: REVIEW-DATA, REVIEW-CONTENT  (2 个子代理并行，依赖 Phase 2 全部完成)
   |
Phase 4: 主代理判断 + 必要时派修订子代理 + 最终总结
```
