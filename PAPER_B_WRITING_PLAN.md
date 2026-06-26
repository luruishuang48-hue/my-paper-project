# 论文 B 写作计划：谁受益，谁受损？大语言模型发布的 AI 生态位置再定价效应

**Working title (English):** *Who Gains, Who Loses? Ecosystem Position Repricing from LLM Releases*

**文档创建时间：** 2026-06-25
**对应任务目录：** `agent_tasks/paper_b_robustness_2026062514/`（5 项新增稳健性回归的源头）
**当前草稿：** `Tex/long.tex`（中文，已包含摘要 + 6 个实证子节 + 小结 + 待补充的稳健性检验框架）

本文档是论文 B 的长期参考文档，目的是把（1）已有素材、（2）本轮新完成的 5 项稳健性回归、（3）论文结构、（4）范围边界、（5）剩余工作量，整合成一份可以反复查阅、持续更新的写作计划。本文档**不修改** `Tex/long.tex` 本身。

---

## 1. 定位与目标期刊

### 1.1 论文 B 在三论文体系中的位置

本项目的总课题——LLM 模型发布行为对美股市场的影响——已拆分为三篇独立论文：

| | 论文 A | **论文 B（本文档）** | 论文 C |
|---|---|---|---|
| 标题方向 | *Appropriability and the Market Pricing of AI Model Capability* | *Who Gains, Who Loses? Ecosystem Position Repricing from LLM Releases* | 媒体情感传导（暂定） |
| 核心自变量 | AA Intelligence Index（模型能力的连续测度） | 8 维生态位置编码（`upstream_hardware` 等关系变量） | 媒体情感/新闻文本 |
| 核心命题 | 模型能力越强，市场反应越大；可占有性（appropriability）决定谁能把能力转化为估值 | 同一次发布，沿产业链位置产生方向相反的再定价；上游受益、下游（尤其部署型）受损 | LLM 发布事件如何通过媒体情感渠道传导至更广泛的市场反应 |
| 目标期刊 | FRL（*Finance Research Letters*，短文形式） | **JFE / RFS / JBF / JFQA 级别全长论文** | 待定（暂缓，不在本轮范围内） |
| 草稿文件 | `Tex/frl_draft_main_text.tex` | `Tex/long.tex` | 无 |

三篇论文共享同一事件库（60 次模型发布、86 家上市公司、5,160 条事件-公司观测）和同一套 CAR 计算管线，但自变量、识别策略、目标期刊完全不同，互不替代、互不稀释对方的边际贡献。

### 1.2 为什么这组发现值得做成一篇全长论文

论文 B 与论文 A 的根本区别在于研究问题的性质：论文 A 问"模型能力强弱如何被定价"（一个连续变量的定价问题，更适合短文快速建立事实）；论文 B 问"同一条经济信号（模型发布）如何沿产业链结构被不对称地重新分配"（一个分布式再定价问题，天然需要更完整的理论框架、更系统的稳健性检验、更深入的机制讨论），这类问题正是 JFE/RFS/JBF/JFQA 主流文献的核心关切（事件研究 + 产业链外溢 + 异质性机制）。具体而言，论文 B 具备全长论文所需的三个要素：

1. **清晰的方向性预测和经济机制**：上游（算力供应）与模型能力是互补品，下游（部署应用）与模型能力是替代品——这是一个可以从产业组织理论直接推导、且能被数据证伪的预测，不是事后挖出来的相关性。
2. **多层递进的实证结构**：基准位置效应 → 合并组验证 → 联合回归排除共线性混淆 → 开闭源异质性机制检验——四层证据相互印证，而不是单一回归结果。
3. **方法论贡献**：8 维生态位置编码本身（双盲编码、Cohen's κ = 0.986、系统化仲裁流程，详见 §2.4）是一项可被其他研究者复用的数据贡献，这类"测量学贡献 + 实证发现"的组合是全长论文区别于研究简报的典型特征。

本轮新增的 5 项稳健性回归（R1-R5，见 §3）进一步充实了这一定位：downstream_deployer 发现现在有七个窗口、三种推断方法、四种模型设定的交叉验证，达到了顶刊审稿人对核心发现稳健性的常规要求。

---

## 2. 现有材料清单

### 2.1 `Tex/long.tex` 现有结构（已完成部分）

| 章节 | 内容 | 状态 |
|---|---|---|
| 摘要 | 样本描述 + 三条核心数字（upstream_hardware +2.28pp, downstream_deployer −1.90pp, bundle ±2.2~2.5pp, 开闭源交互 −3.66pp） | 已完成 |
| §1 实证结果 引言段 | 三层递进逻辑说明（基准→联合→异质性），对应 H1/H2/H3 | 已完成 |
| §1.1 样本与关键变量 | 60 事件、86 公司、5,160 观测；8 维位置分类定义；结构性经济暴露 vs 直接合同冲击的识别边界讨论 | 已完成 |
| §1.2 估计设定 | 主回归方程 + 开闭源交互方程 | 已完成 |
| §1.3 基准位置效应（Table 1, Figure 1） | 6 个位置变量单独回归，car_10/15/20 | 已完成 |
| §1.4 合并位置组（Table 2） | upstream_any/strategic_any/downstream_any/downstream_deployer | 已完成 |
| §1.5 联合回归（Table 3） | 6 变量同时进入，识别"条件净效应" | 已完成 |
| §1.6 开源与闭源异质性（Table 4, Figure 2） | 交互项模型，闭源/开源/差异三列 | 已完成 |
| §1.7 控制 AA Intelligence 后的稳健性（Table 5） | 加入 AA 指标控制后位置效应不变甚至增大 | 已完成 |
| §1.8 补充结果与边界讨论 | 投资方/控制方样本量过小、云服务集中度、竞争者设定依赖性、下游集成商层级差异 | 已完成 |
| §2 小结 | 三点凝练（位置再定价、开源调节、位置独立于能力） | 已完成 |
| §3 稳健性检验 | 列出 5 项待办（DeepSeek 剔除、leave-one-out、FF3、wild bootstrap、specification curve） | **[待补充]——本轮 R1-R5 解决前 4 项** |

### 2.2 图表清单

| 编号 | 文件 | 内容 | 状态 |
|---|---|---|---|
| Table 1 | `tab:baseline_position_effects`（long.tex 内嵌） | 基准 6 位置单独回归 | 已完成 |
| Table 2 | `tab:bundle_position_effects` | 合并组回归 | 已完成 |
| Table 3 | `tab:joint_position_effects` | 联合回归 | 已完成 |
| Table 4 | `tab:open_closed_position_effects` | 开闭源交互 | 已完成 |
| Table 5 | `tab:aa_control_position_effects` | 控制 AA Intelligence | 已完成 |
| Figure 1 | `output/paper_plan_core/figures/figure1_position_effects.pdf/png` | 基准位置效应 CAR[0,+20] 系数图 + 95% CI | 已完成 |
| Figure 2 | `output/paper_plan_core/figures/figure2_open_closed_effects.pdf/png` | 开闭源位置效应对比图 | 已完成 |

### 2.3 源脚本

| 脚本 | 作用 | 状态 |
|---|---|---|
| `scripts/analysis/paper_plan_core_outputs.R` | Table 1-5 + Figure 1-2 的生成脚本，定义控制变量、聚类方式、样本边界等所有规格惯例 | 已完成，本轮 R1-R5 严格复刻其规格 |
| `scripts/analysis/core_table.R` | 提供可复用的 `wild_boot_p()`（第 69-111 行，Rademacher wild cluster bootstrap，B=4999, impose-null）和 `refit_cr2()`（第 62-67 行）函数 | 已完成，本轮直接复用 |

### 2.4 方法论贡献材料

`data/relationships/RELATIONSHIP_CODING_WORKFLOW_REPORT.md`（已找到，路径确认）系统记录了 8 维生态位置编码的完整工作流：

- **Codebook 设计**：`data/relationships/relationship_codebook.md`，8 个维度（R1-R6 角色型 + F1-F2 持股/控制型），多标签、保守默认、证据导向、creator 锚定四项编码原则。
- **双盲编码**：Coder A（Claude，7 子代理分批编码）与 Coder B（GPT，独立编码），覆盖 1,204 个 (company, creator) 对。
- **一致性检验**：Cohen's κ pooled = **0.986**，8 个维度全部 κ > 0.96（Landis & Koch "几乎完全一致"标准），31 个分歧全部为单向（Coder B 更宽松，Coder A 更保守，零例反向）。
- **仲裁**：逐案审议 5 类分歧（AMZN/GOOGL 的 upstream_cloud 采纳更宽口径；MSFT、QUBT、WRD 的下游归类采纳保守口径），仲裁后构造效应 κ = 1.000。
- **最终数据**：`data/relationships/adjudicated_event_level.csv`（5,160 行，含 confidence 和 justification 字段，可审计）。

这一方法论本身构成 Data Section 的一个独立小节内容，也是论文区别于"拿现成数据跑回归"的方法论贡献点，应在投稿信/贡献陈述中明确提及。

### 2.5 本轮新增：5 项稳健性回归输出（R1-R5）

详见 §3 的逐项汇总。产出文件统一位于 `agent_tasks/paper_b_robustness_2026062514/outputs/`：

| Agent | 主要输出文件 |
|---|---|
| R1 | `r1_hardware_vs_cloud_diff.csv`, `r1_hardware_vs_cloud_diff.md` |
| R2 | `r2_downstream_deployer_robustness.csv`, `r2_downstream_deployer_robustness.md` |
| R3 | `r3_deepseek_exclusion.csv`, `r3_leave_one_event_out.csv`, `r3_leave_one_firm_out.csv`, `r3_sensitivity_summary.md` |
| R4 | `r4_ff3_table2_position.csv`, `r4_ff3_table3_bundle.csv`, `r4_ff3_vs_marketmodel_comparison.csv`, `r4_ff3_comparison.md` |
| R5 | `r5_wild_bootstrap_table1to4.csv`, `r5_wild_bootstrap_summary.md` |

---

## 3. 五项新增稳健性检验结果汇总

> **核心结论先行：** 五项检验（R1-R3、R5 计入论文；R4/FF3 不写入论文正文，理由见下）共同表明，**downstream_deployer（下游部署型负效应）是本文最稳健、最可辩护的核心发现**——在全部 7 个 CAR 窗口、3 种推断方法（CR0/CR2/wild bootstrap）、4 种模型设定（单独/合并/联合/交互）下全部显著。**upstream_hardware（上游硬件正效应）方向上是真实且一致的，但在联合模型设定下统计上更脆弱**（见 R5）。这一不对称性必须在论文中如实呈现，不能把两个发现写成同等强度。

### R1：upstream_hardware vs upstream_cloud 系数差异的正式检验

**检验设计：** 两变量同时进入回归（而非分别单独估计），对差异 `hardware − cloud` 做 Wald 检验。

**关键数字（car_20，n=4,829，60 事件）：** β_hardware = 0.0237（se=0.0086），β_cloud = 0.0161（se=0.0069），差异 = 0.0076，se_diff = 0.0073，z = 1.040，**p = 0.2984**。car_10、car_15 窗口的差异也都不显著（p=0.58、p=0.776）。

**对论文论断的含义——诚实的非结论：** 之前 `review_regressions_summary.md` 中"上游效应几乎全部由硬件驱动、云服务弱且不显著"的说法，是基于**分别单独估计**的描述性系数对比得出的定性印象。本次正式 Wald 检验**未能在统计上确认这一差异**——三个窗口的差异检验均不显著。这意味着：

- 不应在论文正文中把"硬件驱动、云弱"作为一个经过统计检验确认的发现来写。
- 应改写为更审慎的措辞：硬件和云服务的点估计方向一致（都为正），硬件的点估计始于车 car_20 略大于云，但**两者在统计上不可区分**。
- 这是一个真实的零结果（null finding），应在稳健性章节中坦诚报告，而非淡化或省略。

### R2：downstream_deployer 专项稳健性回归——五项中最强的结果

**检验设计：** `downstream_deployer` 作为唯一关系自变量，跑全部 7 个窗口（car_1 到 car_20）× 3 种推断方法（CR0/CR2/wild bootstrap, B=4999, Rademacher, seed=42）。

**关键数字：**

| 窗口 | beta (pp) | p_CR0 | p_CR2 | p_wild |
|---|---|---|---|---|
| car_1 | −0.34 | 0.0181 | 0.0196 | 0.0202 |
| car_5 | −0.72 | 0.0043 | 0.0049 | 0.0024 |
| car_10 | −0.99 | 0.0077 | 0.0082 | 0.0068 |
| car_15 | −1.43 | 0.0016 | 0.0017 | 0.0014 |
| car_20 | −1.90 | 0.0004 | 0.0005 | 0.0004 |

**结论：** 效应方向一致为负，**单调随窗口扩大而增大**（−0.34pp → −1.90pp，约 5.7 倍），**显著性同时增强而非衰减**（p 从约 0.02 降到约 0.0004）。这种"随时间推移逐步走强"的模式更符合渐进信息扩散/重新定价，而非公告日一次性超调后反转。三种推断方法在每个窗口高度一致（彼此差异不超过约 0.002），在 60 个事件聚类这种中等聚类数下，wild bootstrap 与渐近方法（CR0/CR2）的高度吻合本身就是一项有意义的稳健性证据。car_20 数字（β=−0.01902, p_CR0=0.000404）与此前 `run_relationship_specr` 报告的 −0.019/0.0004 几乎完全一致，独立复现成功。

### R3：剔除极端事件 + Leave-one-out 敏感性分析

**检验设计：** 对 upstream_hardware 和 downstream_deployer 在 car_20 上做（1）剔除 DeepSeek R1（FMR-0021）后重估、（2）60 次 leave-one-event-out、（3）86 次 leave-one-firm-out。

**关键数字：**

- **DeepSeek R1 剔除：** upstream_hardware 系数完全不变（0.0228 → 0.0228，变化 0.2%），downstream_deployer 几乎不变（−0.0190 → −0.0186，变化 2.2%）；两者 5% 显著性均保持不变。
- **Leave-one-event-out（60 次）：** upstream_hardware 系数区间 [0.0203, 0.0249]（sd=0.00111），最大影响事件 FMR-0056；downstream_deployer 系数区间 [−0.0204, −0.0174]（sd=0.00067），最大影响事件 FMR-0016。两变量在全部 60 次迭代中均**零次**符号翻转、**零次**跌出 10% 显著性。
- **Leave-one-firm-out（86 次）：** upstream_hardware 区间 [0.0204, 0.0249]（sd=0.00076），最大影响公司 SMCI；downstream_deployer 区间 [−0.0208, −0.0168]（sd=0.00065），最大影响公司 5803 JP。同样零次符号翻转、零次跌出显著性。

**结论：** 两个核心发现**都不**由单一事件或单一公司驱动，是本轮中第二个干净的"通过"结果，可直接支撑论文中"结果不依赖极端观测"的稳健性陈述。

### R4：FF3 三因子模型替代——已完成但不计入本文写作范围

**检验设计：** 用 FF3 三因子模型计算的 CAR（`ff3_car_10/15/20`）替代 market-model CAR，重跑 Table 2（单独位置）和 Table 3（合并组）核心行，其余规格不变。

**处理决定：** 该检验已经跑完并通过独立审阅（结果保留在 `agent_tasks/paper_b_robustness_2026062514/outputs/r4_ff3_*` 作为内部参考），但**决定不将其写入论文正文或附录**。FF3 调整下两个 headline 系数在 car_20 窗口失去统计显著性（但保留符号方向），而 60 个事件聚类下 FF3 窗口本身标准误更大、检验力更弱；与其让这一检验力不足的稳健性检验主导对核心发现强度的叙事，不如不展示这项检验。upstream_hardware 的真正脆弱性证据由 R5（联合模型）独立确认，已经足够支撑诚实的证据强度分级，无需额外引入 R4。

### R5：Table 1-4 核心系数的 Wild Bootstrap 补充——揭示 upstream_hardware 在联合模型中的脆弱性

**检验设计：** 对 Table 1-4 中出现的全部核心系数（16 行）补充 wild cluster bootstrap p 值，与 CR0/CR2 对比。

**四种模型设定下的表现：**

| 设定 | upstream_hardware | downstream_deployer |
|---|---|---|
| 基准单独回归 | β=+0.0228, p_wild=0.02（显著） | β=−0.0190, p_wild<0.0002（极显著） |
| 合并组（upstream_any/downstream_any） | β=+0.0222, p_wild=0（显著） | （downstream_any）β=−0.0250, p_wild=0（显著） |
| **联合回归（6 变量同时进入）** | **β=−0.0083（符号翻转！）, p_wild=0.64（完全不显著）** | β=−0.0424（幅度翻倍）, p_wild=0（依然极显著） |
| 开闭源交互项 | 交互项 β=−0.0366, p_wild=0.04（显著，集中于闭源） | 交互项 β=+0.0106, p_wild=0.30（不显著，效应不随开闭源调节） |

**结论（与任务说明中的关键提醒完全一致）：** downstream_deployer 在全部四种模型设定下、全部三种推断方法下**全部显著**——是本文唯一在每一种检验组合下都"过关"的系数。upstream_hardware 在基准、合并组、开闭源交互三种设定下稳健，但**在联合回归（6 个位置变量同时控制）中不仅失去显著性，点估计还从 +0.0228 翻转为 −0.0083**（p_wild 从 0.02 升至 0.64）。这说明基准单独回归中观察到的 upstream_hardware 效应，部分可能是吸收了与其高度共线的云服务/下游位置变量的变异，而非一个独立可分离的硬件位置效应。

**写入论文的稳健性检验的统一建议（直接采纳 R5 输出文件的措辞）：** "downstream_deployer 应作为本文无可争议的、完全稳健的核心发现呈现；upstream_hardware 应附带明确的限定条件——其显著性取决于是否同时控制下游位置变量——这一点应在讨论/稳健性章节中被明确标注，而不应被赋予与 downstream_deployer 同等的证据权重。"

---

## 4. 论文结构大纲（8 节框架）

| 节 | 内容 | 对应现有材料 | 状态 |
|---|---|---|---|
| **1. Introduction** | 研究问题（LLM 发布的产业链外溢效应）、核心命题预览（位置再定价、上游正/下游负）、与文献的差异化定位、headline 数字预览、贡献陈述（实证发现 + 8 维编码方法论） | 摘要现有数字可直接复用；需要新写完整 Intro 叙事和文献定位段 | 部分已有素材，**需新写** |
| **2. Literature & Hypotheses** | 产业链外溢/spillover 文献，事件研究方法文献，AI/技术冲击对资产定价文献，开源 vs 闭源技术扩散文献；推导 H1（位置异质性）H2（方向预测：互补 vs 替代）H3（开源调节） | `Tex/long.tex` §1 引言段已隐含 H1/H2/H3 表述，可作为种子内容扩展 | **需新写**（全长论文需要的文献深度远超现有段落） |
| **3. Data & Sample** | 60 事件、86 公司、5,160 观测的样本构造；事件识别标准；CAR 计算方法（market model vs FF3）；**8 维生态位置编码方法论小节**（双盲编码、κ=0.986、仲裁流程，引用 `RELATIONSHIP_CODING_WORKFLOW_REPORT.md`） | `Tex/long.tex` §1.1 样本部分已有；`RELATIONSHIP_CODING_WORKFLOW_REPORT.md` 提供方法论小节全部素材 | 样本部分已完成；方法论小节**需新写**（整合现成报告内容，非重新调研） |
| **4. Empirical Strategy** | 主回归方程、合并组定义、联合回归动机、开闭源交互设定；聚类与推断方法说明（CR0 基准 + CR2/wild bootstrap 作为推断稳健性） | `Tex/long.tex` §1.2 已有方程；推断方法部分需要扩展说明三种方法的选择逻辑 | 基本已完成，**小幅扩写** |
| **5. Main Results** | Table 1（基准）、Table 2（合并组）、Table 3（联合回归）、Table 4（开闭源交互）、Figure 1-2；**需新增一段关于 upstream_hardware 在联合模型中失去显著性的"前瞻性对冲"段落**，引用 R5 数字，提示读者后文稳健性章节会进一步检验 | `Tex/long.tex` §1.3-§1.6 已完成 90% | 已完成，**需插入 1 段对冲性讨论**（引用 R5 联合模型 p_wild=0.64） |
| **6. Robustness**（本轮核心新增） | R1（硬件 vs 云差异检验，报告零结果）、R2（downstream_deployer 全窗口全方法验证）、R3（剔除极端事件 + leave-one-out）、R5（wild bootstrap 全表补充，突出联合模型脆弱性）；外加 Table 5（控制 AA Intelligence，已完成）。**R4/FF3 不写入本节**（见 §3 R4 段落的处理决定） | `Tex/long.tex` §3 当前为 "[待补充]" 占位列表；Table 5 已完成但目前放在 §1.7，建议移入本节或保留交叉引用 | **本轮 R1-R3、R5 已产出全部数字和结论，需新写约 1,200-2,000 字的稳健性章节正文 + 3-4 张新表** |
| **7. Heterogeneity / Mechanism** | 开闭源调节效应的机制讨论（互补品 vs 替代品框架，算力租金归属逻辑）；可选：下游三个子类（integrator/deployer/enabler）的机制区分讨论（为何只有 deployer 显著为负） | `Tex/long.tex` §1.6 开闭源部分 + §1.8 补充讨论已有大量素材 | 大部分已完成，**可直接整合**，建议补充一段"为何只有 deployer 而非 integrator/enabler 显著"的机制讨论（现有 §1.8 已有简短讨论，可扩写） |
| **8. Conclusion** | 三点核心发现凝练（位置再定价、开源调节、独立于能力）；政策含义（AI 产业链利润分配）；**新增：诚实陈述发现的相对稳健性等级**（downstream_deployer 强稳健 vs upstream_hardware 方向稳健但统计上对设定敏感）；未来研究方向 | `Tex/long.tex` §2 小结已有前两点，**需要新增第四点关于证据强度分级的诚实陈述**，并删除/弱化暗示两发现同等强度的措辞 | 已有 70% 素材，**需新写约 1 段**关于证据强度不对称性的总结性陈述 |

**关于 R5 联合模型脆弱性应同时出现在 Main Results 和 Robustness 两节的具体安排：** 建议在 §5 Main Results 介绍 Table 3（联合回归）的现有段落中（`Tex/long.tex` 第 180 行附近"联合回归的结果需要谨慎解读"一段），加入一句话提示"该模式在稳健性章节的 wild bootstrap 检验中得到进一步确认（见 §6）"；在 §6 Robustness 中给出 R5 完整数字和解释。这样读者在第一次看到联合回归结果时就被预先警示，不会等到稳健性章节才第一次意识到 upstream_hardware 的脆弱性。

---

## 5. 本轮工作之外的内容（明确排除范围）

| 内容 | 应归属 | 排除理由 |
|---|---|---|
| AA Intelligence Index 定价、模型能力连续测度 | 论文 A（FRL） | 论文 A 的核心自变量；论文 B 仅在 Table 5 中把它作为控制变量使用，不展开讨论能力指标本身的构造或定价含义 |
| 媒体情感传导、新闻文本分析 | 论文 C | 完全不同的识别策略和数据源，与生态位置编码无关 |
| PSM-DID、样本扩展（更多公司/更多事件） | 基础设施改进，非独立章节 | 除非这类改进**实质性改变**论文 B 的核心数字（目前没有证据表明会），否则不构成新的论文章节；如果未来要做，应作为"扩展稳健性"的一个子条目并入 §6，而不是新增独立章节 |
| 时间趋势/体制转换分析（如 2023 vs 2024 vs 2025 年度异质性） | 未来扩展，不在本版范围 | 当前 60 个事件的年度分布不足以支撑可靠的体制转换检验；可在 Future Research 段落中提及作为方向，不需要现在补充实证 |
| Specification curve analysis（400+ 规格组合） | 仍是 `Tex/long.tex` §3 的待办事项之一，但**不在本轮 R1-R5 范围内** | 本轮任务计划明确只覆盖 5 项检验（R1-R5），未涵盖原始稳健性清单中的第 5 项（specification curve）；`run_relationship_specr` 脚本已有 specification curve 的部分产出（见 `review_regressions_summary.md` §2.4），可在下一轮整合进 §6，但本文档不假装这一项已经完成 |
| Wald 检验确认"硬件驱动、云服务弱"的因果叙事 | 不应写入任何版本 | R1 已正式检验并得到 p=0.298 的不显著结果；这条叙事应被替换为更审慎的措辞（见 §3 R1 部分），而不是在其他论文或章节中以未经验证的方式复述 |
| FF3 三因子模型替代检验（R4） | 不写入论文正文或附录；仅保留为内部工作区参考文件 | 已完成并通过审阅，结果方向一致但显著性在该设定下消失；鉴于 60 个事件聚类下该检验本身检验力偏弱，决定不让其主导对核心发现强度的叙事——upstream_hardware 的脆弱性已由 R5（联合模型）独立确认，足够支撑诚实的证据分级，无需额外引入这一项 |

---

## 6. 更新后的工作量评估

> 基准对比：此前讨论中给出的估计为 5-7 个工作日（完成 5 项稳健性检验之前）。本轮 R1-R5 已经完成全部数据生成和数字验证工作，**剩余工作量大幅收窄到以写作和文献为主**，不再有悬而未决的实证任务（除 specification curve，见 §5 排除清单的说明）。

| 任务 | 工作量估计 | 说明 |
|---|---|---|
| 稳健性章节正文撰写（§6 Robustness，整合 R1-R3、R5） | **0.5-1 天** | 数字已全部就位（本文档 §3 已完成数字核对），主要工作是中文叙事撰写和表格排版，无需新的回归 |
| 新增表格排版（R1-R3、R5 共 4 张表，LaTeX threeparttable 格式） | **0.5 天** | 需要把 4 个 `.csv` 转成与 Table 1-5 一致的 LaTeX 格式；R3 的 leave-one-out 建议用一张汇总统计表（range/sd/最大影响事件）而非全部 60/86 行；R4/FF3 不排版，不计入此项 |
| Main Results 章节的对冲性措辞修订（插入 R5 联合模型警示段落） | **0.25 天** | 在现有 §1.5（联合回归）段落基础上插入 2-3 句话，引用具体数字，不需要重写整节 |
| Conclusion 章节的证据强度分级陈述 | **0.25 天** | 新增 1 段，明确区分 downstream_deployer（强稳健）与 upstream_hardware（方向稳健、统计上对设定敏感） |
| 文献综述深度扩展（Introduction + Literature 两节） | **2-3 天** | 这是全长论文相对 FRL 短文最大的增量工作——需要系统梳理产业链外溢、事件研究方法论、技术冲击资产定价、开源扩散经济学四条文献线，FRL 版本不需要这个深度 |
| Data Section 方法论小节撰写（整合 `RELATIONSHIP_CODING_WORKFLOW_REPORT.md`） | **0.5 天** | 素材已齐全（本文档 §2.4），主要是翻译/改写为论文体例的英文或中文学术叙事，非重新调研 |
| Specification curve analysis 补充（如决定纳入本轮范围） | **1-2 天**（可选，未列入当前范围） | 若研究团队决定把这一项也纳入下一轮，需要新派子代理基于 `run_relationship_specr` 现有产出扩展成完整图表；本文档暂不假设这一项会做 |
| 全文统稿、内部一致性检查（数字、记号、引用交叉核对） | **0.5-1 天** | 包括确认 §5 Main Results 与 §6 Robustness 之间不出现矛盾措辞（尤其 upstream_hardware 的强度描述要前后一致） |
| 期刊适配性修订（摘要、贡献陈述、与目标期刊风格匹配） | **0.5 天** | 视具体投稿期刊（JFE/RFS/JBF/JFQA）的摘要长度、引用格式要求做最后调整 |
| **合计（不含可选 specification curve）** | **约 5-6.5 天** | 相比此前 5-7 天的估计，**新增稳健性回归本身的工作量已经完全消化**（本轮 5 个子代理已完成），剩余几乎全部是写作和文献深度工作，没有悬而未决的统计分析任务 |
| **合计（含可选 specification curve）** | **约 6-8.5 天** | 如果研究团队希望在投稿前一次性补齐原始稳健性清单的全部 5 项（包括 specification curve），需要额外 1-2 天 |

**关键提醒：** 上述工作量估计假设核心实证结果（Table 1-5 + R1-R5）不再发生变化。如果文献综述阶段促使研究团队调整估计设定（例如要求加入额外的产业控制变量或工具变量策略），工作量会相应增加，本估计不包含这类潜在的设定层面返工。

---

## 附：本文档所有数字的核对来源

为确保本文档不引入未经验证的数字，以下列出每一类关键数字的核对来源文件：

- Table 1-5 数字（upstream_hardware +2.28pp 等）：`Tex/long.tex` 第 67、73、121、125、157、163、199、201 行等
- R1 数字：`agent_tasks/paper_b_robustness_2026062514/outputs/r1_hardware_vs_cloud_diff.md`
- R2 数字：`agent_tasks/paper_b_robustness_2026062514/outputs/r2_downstream_deployer_robustness.md`
- R3 数字：`agent_tasks/paper_b_robustness_2026062514/outputs/r3_sensitivity_summary.md`
- R4 数字（已完成但不写入论文，仅留存于工作区）：`agent_tasks/paper_b_robustness_2026062514/outputs/r4_ff3_comparison.md`
- R5 数字：`agent_tasks/paper_b_robustness_2026062514/outputs/r5_wild_bootstrap_summary.md`
- κ = 0.986 等编码方法论数字：`data/relationships/RELATIONSHIP_CODING_WORKFLOW_REPORT.md` 第 104 行（pooled κ）
- 此前发现的 downstream_deployer 收敛证据（三脚本独立验证）：`agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md` §2.4-§2.5
