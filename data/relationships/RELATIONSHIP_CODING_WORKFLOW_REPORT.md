# 公司-发布方关系编码：完整工作流与结果报告

**记录范围：** 2026-06-24 至 2026-06-25
**目的：** 把分散在 `data/relationships/`、`agent_tasks/relationship_coding_*`、`agent_tasks/coder_a_relationship_coding_*`、`agent_tasks/coder_ab_discrepancy_audit_*`、`agent_tasks/relationship_recode_switch_*` 等多个目录里的关系编码工作，整合成一条完整、可追溯的时间线，覆盖动机、设计、双盲编码、审计、仲裁、合并、正式切换。

---

## 0. 为什么要重新编码

主数据集 `data/relationships/6.21事件集数据.csv` 里原有一个 `与模型发布者的关系`（`relationship_old`）文本列，以及一套旧的 8 列二进制编码（`owner, investor, cloud, business_upstream, real_upstream, business_downstream, real_downstream, competitor`）。这套旧编码存在两个问题：

1. **粒度不够。** `business_upstream`/`real_upstream` 和 `business_downstream`/`real_downstream` 的区分轴是"证据强度"（business=推断、real=确证），不是"角色类型"。这导致无法区分"硬件供应商"和"云服务商"这两种完全不同的上游暴露，也无法区分"AI 是核心产品"和"AI 只是部署工具"这两种完全不同的下游暴露。
2. **缺失审计链。** 旧编码没有 confidence 分级，也没有 justification，审稿人无法追溯每一个 1 的判断依据。
3. **单一标注源。** 旧编码由人工或单一模型一次性产出，没有交叉验证。

为此设计了一套新的 8 维 codebook，并采用双盲编码 + Cohen's κ 检验 + 人工仲裁的流程重新编码，目标是产出一份可审计、可复现、粒度更细的关系数据集，最终替换旧编码作为正式分析口径。

---

## 1. Codebook 设计

**文件：** [`data/relationships/relationship_codebook.md`](relationship_codebook.md)（v1.0，2026-06-24）

**编码单位：** (company, event) 对，86 家公司 × 60 个事件 = 5,160 个观测；底层稳定单位是 (company, creator)，86 家公司 × 14 个发布方 = 1,204 对。

**8 个维度：**

| 代码 | 列名 | 定义 |
|---|---|---|
| R1 | `upstream_hardware` | 为 AI 训练/推理供应物理硬件或组件 |
| R2 | `upstream_cloud` | 运营被 AI workload 使用的云/数据中心基础设施 |
| R3 | `downstream_integrator` | AI 能力是核心产品输入；直接集成 LLM API 或基础模型 |
| R4 | `downstream_deployer` | 在传统（非 AI 原生）业务中把 AI 当工具部署 |
| R5 | `downstream_enabler` | 帮助客户采用 AI 的 IT 服务/咨询/外包公司 |
| R6 | `competitor` | 自研或发布与该事件模型竞争的 LLM/基础模型 |
| F1 | `is_investor` | 持有发布方的股权 |
| F2 | `is_owner` | 本身就是发布方或其上市母公司 |

**关键原则：** 多标签（可同时为多个维度=1）；保守默认（证据不充分则编 0）；证据导向（每个 1 需要可验证来源）；creator 锚定（同一发布方下角色应稳定，事件可标注例外）。R3/R4/R5 三类下游互斥。NVIDIA 特殊规则：全部 creator 下 `upstream_hardware=1`，不标 `competitor`。

---

## 2. 双盲编码

### 2.1 Coder B（GPT，独立编码）

**提示词：** [`data/relationships/gpt_coding_prompt.md`](gpt_coding_prompt.md)
**任务目录：** `agent_tasks/relationship_coding_20260624-184413/`

按 (company, creator) 矩阵编码 1,204 对，再展开到事件层 5,160 行。输出文件：

- `data/relationships/company_creator_relationships_coder_b.csv`（1,204 行）
- `data/relationships/event_company_relationships_coder_b.csv`（5,160 行）
- `data/relationships/6.21事件集数据_relationships_coder_b.csv`（追加 `rel_` 前缀字段的合并版）

**Coder B 编码计数（公司-发布方层，1204 对）：**

| 维度 | 计数 |
|---|---:|
| upstream_hardware | 280 |
| upstream_cloud | 70 |
| downstream_integrator | 433 |
| downstream_deployer | 280 |
| downstream_enabler | 112 |
| competitor | 122 |
| is_investor | 5 |
| is_owner | 4 |

**关键口径决定：**
- 云服务采用宽口径：AMZN、GOOGL、MSFT、ORCL、BABA 对所有发布方事件标 `upstream_cloud=1`。
- `is_owner` 只映射 BABA-Alibaba、GOOGL-Google、META-Meta、MSFT-Microsoft。
- `is_investor` 只映射 5 组已知投资关系（MSFT-OpenAI、AMZN-Anthropic、GOOGL-Anthropic、CRM-Anthropic、MSFT-Mistral AI）。
- 专业信息服务公司（EXPN LN、TRI、WKL NA）按边界规则归入 R3 而非 R5。

同任务目录下还有一份独立的**子代理规则审阅**（[`subagent_rule_review.md`](../../agent_tasks/relationship_coding_20260624-184413/subagent_rule_review.md)），在编码执行前核对了数据结构（GB18030 编码、双层表头）、creator 名称规范化要求、owner/investor 映射规则、NVIDIA 规则等，作为执行前的风险检查。

### 2.2 Coder A（Claude，独立编码）

**任务目录：** `agent_tasks/coder_a_relationship_coding_2026062418/`

采用多代理分批架构：7 个子代理并行编码（按公司分组：半导体、云与大科技、AI 原生软件、企业软件、IT 服务、硬件与基础设施、部署方，覆盖全部 86 家公司 × 14 个发布方），再合并、扩展到事件层、复核、修订，产出 `data/relationships/coder_a_output.csv`（1,204 行）。

（注：`agent_tasks/relationship_coding_20260624-205216/` 是 Coder A 编码流程的一次重新规划尝试，最终执行仍以 `coder_a_relationship_coding_2026062418/` 的 7-agent 分批方案为准；`agent_tasks/relationship_coding_20260624-184054/` 为更早的空白尝试，未产出有效结果。）

---

## 3. 一致性检验（Cohen's κ）

**报告：** [`data/relationships/kappa_report.md`](kappa_report.md)
**独立复核审计：** `agent_tasks/coder_ab_discrepancy_audit_20260624-211116/coder_ab_discrepancy_report.md`（用独立脚本重新计算，数字与下表完全一致，互相验证）

对比对象：`coder_a_output.csv` vs `company_creator_relationships_coder_b.csv`，1,204 对 × 8 维 = 9,632 个可比单元格。

| 维度 | κ | 一致率 | A=1 | B=1 | 分歧数 |
|---|---|---|---|---|---:|
| upstream_hardware | **1.000** | 100.0% | 280 | 280 | 0 |
| upstream_cloud | **0.985** | 99.8% | 68 | 70 | 2 |
| downstream_integrator | **0.973** | 98.8% | 418 | 433 | 15 |
| downstream_deployer | **0.967** | 98.8% | 266 | 280 | 14 |
| downstream_enabler | **1.000** | 100.0% | 112 | 112 | 0 |
| competitor | **1.000** | 100.0% | 122 | 122 | 0 |
| is_investor | **1.000** | 100.0% | 5 | 5 | 0 |
| is_owner | **1.000** | 100.0% | 4 | 4 | 0 |
| **Pooled** | **0.986** | **99.7%** | — | — | **31** |

8 个维度全部达到 Landis & Koch "几乎完全一致"标准（κ > 0.96）。31 个分歧全部是单向的：Coder B（GPT）标 1，Coder A（Opus）标 0——Coder A 在所有分歧上都更保守，零例反向分歧。

**分歧分布：**
- 按公司：QUBT（14 个，遍及全部 14 个 creator）、WRD（14 个，遍及全部 14 个 creator）、AMZN（1）、GOOGL（1）、MSFT（1）。
- 按维度：`downstream_integrator`(15)、`downstream_deployer`(14)、`upstream_cloud`(2)，其余 5 维零分歧。

**保守 H/M 口径（把 confidence=L 的正关系重置为 0）：** 分歧从 31 降到 3，pooled 一致率从 99.68% 升到接近完全一致——说明几乎所有分歧都集中在低置信度边界判断上，不是规则理解的根本分歧。

---

## 4. 仲裁

**报告：** [`data/relationships/kappa_report.md`](kappa_report.md) 第 2-3 节

逐一审议 5 类分歧案例：

| 案例 | 公司 | 维度 | 分歧数 | 裁决 | 采纳 |
|---|---|---|---:|---|---|
| 1 | AMZN | upstream_cloud | 1 | → 1 | Coder B |
| 2 | GOOGL | upstream_cloud | 1 | → 1 | Coder B |
| 3 | MSFT | downstream_integrator | 1 | → 0 | Coder A |
| 4 | QUBT | downstream_integrator | 14 | → 0 | Coder A |
| 5 | WRD | downstream_deployer | 14 | → 0 | Coder A |

**裁决依据：**
- AMZN-Alibaba、GOOGL-Google 的 `upstream_cloud`：codebook 把 R2 定义为"运营 AI workload 用的云基础设施"这一结构性属性，不依赖于是否具体托管某个发布方的模型，也不因为公司本身是发布方（is_owner=1）就互斥——一家公司可以同时是 owner 和拥有云基础设施。两案均采纳更宽口径（Coder B）。
- MSFT-Mistral AI 的 `downstream_integrator`：Copilot 生态的集成主要绑定 OpenAI 模型，Mistral 关系更准确地描述为云托管+投资+竞争，不构成集成方，采纳保守口径（Coder A）。
- QUBT、WRD 在 `downstream_integrator`/`downstream_deployer` 上的全 14-creator 分歧：均为 confidence=L 的边界判断，按 codebook"证据不充分则编 0"的保守默认原则，采纳 Coder A。

**结果：** 2 个单元格改为 1（采纳 B），29 个单元格维持 0（采纳 A）。仲裁后构造效应κ = 1.000（按构造）。

---

## 5. 合并进事件层数据集

仲裁后的最终结果落地为两份权威文件：

- `data/relationships/adjudicated_company_creator.csv`（1,204 行，公司-发布方层）
- `data/relationships/adjudicated_event_level.csv`（5,160 行，事件-公司层，含 `confidence`、`justification`）

**事件层最终计数（5,160 行，60 事件 × 86 公司）：**

| 维度 | 计数 |
|---|---:|
| upstream_hardware | 1200 |
| upstream_cloud | 300 |
| downstream_integrator | 1797 |
| downstream_deployer | 1140 |
| downstream_enabler | 480 |
| competitor | 511 |
| is_investor | 39 |
| is_owner | 29 |

（注：Coder B 编码阶段的事件层初稿计数为 `downstream_integrator=1859`、`downstream_deployer=1200`——这是仲裁前的单一标注者数字。仲裁把 QUBT/WRD 的 14 个 creator × 多个事件的低置信度判断改回 0 后，两个数字分别降到 1797 和 1140，这是预期中的下修，不是数据错误。）

**合并流程**（2026-06-25，`scripts/prep/merge_adjudicated_relationships.py`）：以 `(final_event_id, company_id)` 为键，把 `adjudicated_event_level.csv` 合并进源头文件 `task/事件集数据-relationships.csv`，产出新旧并存版本 `task/事件集数据-relationships_v2.csv`，再镜像 `specr_rel_prep.py` 的清洗逻辑产出 `data/panel/specr_rel_clean_v2.csv`。合并后逐一核对 8 个维度计数与 `adjudicated_event_level.csv` 直接统计完全一致（全部 OK），行数、唯一键、缺失值检查全部通过。

---

## 6. 切换为正式分析口径

**任务目录：** `agent_tasks/relationship_recode_switch_2026062500/`（含 `plan.md`、`final_summary.md`、`review_data.md`、`review_regressions_summary.md`）

2026-06-25，决定不再新旧并存，正式删除旧 8 列编码，新 8 维成为唯一口径：

- 产出根目录 `relationship_data_final.csv`（5,160 行，86 列）。
- 覆盖 `data/panel/specr_rel_clean.csv`，旧版本备份为 `data/panel/specr_rel_clean_OLD_BACKUP.csv`。
- 独立审阅 agent 跑了 7 项完整性检查（行数、唯一键、旧列确认删除、新列计数与源头核对、零缺失值、零重复键、抽样行级核对），全部通过。

**6 个关系相关回归脚本**（`run_relation_subsample_regressions`、`run_econometric_robustness`、`run_proposal_gap_supplement`、`run_missing_analyses`、`relonly_regression`、`run_relationship_specr`）逐一迁移到新列名（语义重新映射，非字符串替换），建 `_v2` 版本跑通，原文件原结果保留不覆盖。`vix_news_regression.R` 因走独立管线（直接解析原始中文文本列）被判定不适用，另开 follow-up 任务（`task_d625672e`）处理。

**回归结果变化的关键发现：**
- `downstream_deployer`（AI 作为工具被非 AI 原生企业部署）呈现负向公告效应，在 3 个独立迁移的脚本中方向一致地浮现——旧编码的粗粒度分类完全掩盖不了这个模式，是这次重新编码最有价值的产出。
- upstream 效应几乎全部由 `upstream_hardware` 驱动，`upstream_cloud` 弱且不显著——旧版合并的 "upstream" 指标掩盖了这个异质性。
- 3 处需要谨慎对待、建议先做稳健性检查的结果：(1) "相关公司"子样本过滤器在新口径下覆盖率从 40.2% 飙升到 97.7%，已经失去区分能力；(2) 某 `positive_exposure` 显著性提升伴随样本量扩大 13 倍，更像样本构成变化而非纯统计功效提升；(3) 某联合模型中两个核心系数同时大幅变动，需要拆开独立估计排除互相干扰。

详见 [`review_regressions_summary.md`](../../agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md) 的完整数字和 6 条行动建议。

---

## 7. 文件索引

| 阶段 | 文件 |
|---|---|
| Codebook | `data/relationships/relationship_codebook.md` |
| Coder B 提示词 | `data/relationships/gpt_coding_prompt.md` |
| Coder B 输出 | `data/relationships/company_creator_relationships_coder_b.csv`, `event_company_relationships_coder_b.csv` |
| Coder B 执行报告 | `agent_tasks/relationship_coding_20260624-184413/final_report.md`, `plan.md`, `subagent_rule_review.md` |
| Coder A 执行计划 | `agent_tasks/coder_a_relationship_coding_2026062418/plan.md` |
| Coder A 输出 | `data/relationships/coder_a_output.csv` |
| κ 检验报告（含仲裁） | `data/relationships/kappa_report.md` |
| 独立复核审计 | `agent_tasks/coder_ab_discrepancy_audit_20260624-211116/coder_ab_discrepancy_report.md` |
| 仲裁后最终数据 | `data/relationships/adjudicated_company_creator.csv`, `adjudicated_event_level.csv` |
| 合并进管线 | `scripts/prep/merge_adjudicated_relationships.py`, `task/事件集数据-relationships_v2.csv`, `data/panel/specr_rel_clean_v2.csv` |
| 切换正式口径 | `relationship_data_final.csv`（根目录）, `data/panel/specr_rel_clean.csv`, `data/panel/specr_rel_clean_OLD_BACKUP.csv` |
| 切换执行与审阅 | `agent_tasks/relationship_recode_switch_2026062500/plan.md`, `final_summary.md`, `review_data.md`, `review_regressions_summary.md` |
| 待办 follow-up | `task_d625672e`（`vix_news_regression.R` 迁移，尚未执行） |
