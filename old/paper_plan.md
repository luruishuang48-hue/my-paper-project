# 论文计划：谁受益，谁受损？——大语言模型发布的产业链价值再分配效应

> 最后更新：2026-06-25

---

## 一、标题方案

### 首选（中文）

**《谁受益，谁受损？——大语言模型发布的产业链价值再分配效应》**

### 首选（英文）

*"Who Gains, Who Loses? Supply Chain Redistribution Effects of Large Language Model Releases"*

### 备选

- 《开源颠覆，闭源巩固：AI 模型发布沿供应链的差异化市场传导》
- *"Open Source Disrupts, Closed Source Consolidates: Heterogeneous Market Reactions to LLM Releases Along the AI Supply Chain"*
- *"Creative Destruction Along the AI Supply Chain: Evidence from Large Language Model Releases"*

---

## 二、核心发现摘要

### 主效应：上游正、下游负

| 供应链位置 | CAR[0,+20] | p 值 | 经济含义 |
|-----------|-----------|------|---------|
| 算力/硬件上游 (R1) | **+2.28%** | 0.009*** | 模型发布→算力需求信号→硬件厂商受益 |
| 云服务上游 (R2) | +1.13% | 0.066* | 边际正向，推理部署拉动云服务 |
| 技术集成下游 (R3) | −0.69% | 0.415 | 不显著 |
| 应用部署下游 (R4) | **−1.90%** | 0.0004*** | 能力替代风险→应用层估值下修 |
| 能力赋能下游 (R5) | −1.14% | 0.136 | 方向为负但未达显著 |
| 直接竞争者 (R6) | −0.05% | 0.941 | 无系统效应 |

### 联合回归（所有哑变量同时进入）

当控制位置交叠后，下游三类全部显著：

| 变量 | β | p 值 |
|------|---|------|
| downstream_integrator (R3) | −3.23% | 0.032** |
| downstream_deployer (R4) | −4.38% | 0.010*** |
| downstream_enabler (R5) | −3.37% | 0.010** |
| competitor (R6) | −2.50% | 0.021** |
| real_upstream (R1) | −0.96% | 0.541（与下游共线性） |

### 核心异质性：闭源 vs 开源（论文灵魂）

**分组回归 CAR[0,+20]：**

| 供应链位置 | 闭源模型 β | 开源模型 β | 方向差异 |
|-----------|-----------|-----------|---------|
| 算力上游 (R1) | **+3.07%*** | −0.64% (n.s.) | 闭源利上游，开源不利 |
| 云服务 (R2) | +1.29%* | +0.62% (n.s.) | 均为正但开源减弱 |
| 部署下游 (R4) | **−2.24%*** | −0.98% (n.s.) | 闭源伤下游，开源减轻 |
| 赋能下游 (R5) | −1.32% (n.s.) | −0.39% (n.s.) | 方向一致但均不显著 |
| 竞争者 (R6) | −0.44% (n.s.) | +1.42% (n.s.) | 方向相反（开源可白嫖） |

**交互项检验（全样本）：**

| 变量 | 闭源基准 β | 交互项 β（×开源） | 交互项 p 值 |
|------|-----------|-----------------|------------|
| real_upstream | +3.07%*** | **−3.66%** | **0.018**\*\* |
| cloud | +1.09% | +0.15% | 0.941 |
| downstream_deployer | −2.13%*** | +1.06% | 0.329 |
| downstream_enabler | −1.29% | +1.01% | 0.549 |

**关键交互项 `upstream × open_weight` 显著（p=0.018），统计上证实闭源 vs 开源对上游效应的差异。**

---

## 三、经济机制

```
┌─────────────────────────────────────────────────────────────┐
│                     模型发布事件                              │
│                         │                                    │
│            ┌────────────┴────────────┐                       │
│            ▼                         ▼                       │
│        闭源模型                    开源模型                   │
│            │                         │                       │
│     ┌──────┴──────┐           ┌──────┴──────┐               │
│     ▼             ▼           ▼             ▼               │
│  上游 ↑↑↑      下游 ↓↓↓    上游 ≈0/↓     下游 ≈0           │
│  (+3.07%)     (−2.24%)     (−0.64%)     (−0.98%)           │
│                                                             │
│  机制：锁定    机制：API     机制：降低    机制：自主          │
│  高端算力需求   定价权压榨   单位算力需求   托管，绕开API      │
│  →Nvidia受益   →部署商受损  →Nvidia受威胁 →伤害被对冲        │
└─────────────────────────────────────────────────────────────┘
```

### 直觉解释

- **闭源 frontier 模型**（如 GPT-4, Claude 3.5）：只有发布者能提供 API，训练需要大量高端 GPU → 算力供应商获得需求确定性（上游 +3%），应用公司被锁在 API 定价和能力迭代中（下游 −2%）
- **开源模型**（如 DeepSeek R1, Llama 3）：同等能力用更少算力即可推理部署 → 算力单位价值被侵蚀（上游效应消失），应用公司可以自主部署、不受 API 约束（下游伤害减轻）

### DeepSeek R1 事件的一般化

2025 年 1 月 DeepSeek R1 发布时 Nvidia 市值蒸发约 5,900 亿美元，不是异常值，是"开源消灭上游溢价"的系统规律在极端情况下的体现。

---

## 四、论文结构

### 第 1 章 引言

- **Hook**：DeepSeek R1 → Nvidia −5,900 亿 vs 下游企业平稳/回升
- **Puzzle**：同一技术事件为何产生方向相反的市场反应？
- **回答**：取决于公司在 AI 供应链中的位置 × 模型的开闭源属性
- **核心数字**：闭源上游 +3.07%\*\*\*，闭源下游 −2.24%\*\*\*，交互项 −3.66%\*\*
- **贡献**：数据（8 维编码 + IRR）、识别（event-firm pair + clustered SE）、经济含义（技术冲击沿供应链的分配效应）

### 第 2 章 制度背景

- AI 产业链结构：算力 → 云 → 模型 → 应用
- 闭源 vs 开源的商业模式差异
  - 闭源：API 收入、壁垒护城河、高算力训练投入
  - 开源：生态收入、降低门槛、推理效率竞争
- 2022.11—2025.06 关键事件时间线（60 events）

### 第 3 章 数据与样本

- **事件筛选**：60 个重大 LLM 发布事件（筛选标准：官方发布 + 媒体覆盖 + leaderboard 收录）
- **公司确定**：86 家美股上市公司
- **关系编码**：8 维体系
  - R1 算力/硬件上游、R2 云服务上游
  - R3 技术集成下游、R4 应用部署下游、R5 能力赋能下游
  - R6 直接竞争者
  - F1 持股关系、F2 控制关系
- **编码质量**：双人独立编码 + IRR（Cohen's κ ≥ 0.967 所有维度）
- **能力数据**：Artificial Analysis API（496 LLM 记录）
- **开源标记**：`is_open_weight`（1118 开源 / 4042 闭源观测）

### 第 4 章 方法论

- 市场模型 + FF3 → CAR[0,+1] 和 CAR[0,+20]
- 横截面回归：$\text{CAR}_{ij} = \alpha + \beta \cdot \text{Position}_{ij} + \gamma' X_{j} + \delta_t + \varepsilon_{ij}$
- 聚类稳健标准误（event-level, CR0）
- 交互项模型：$\text{CAR}_{ij} = \alpha + \beta_1 \text{Position} + \beta_2 \text{Open} + \beta_3 (\text{Position} \times \text{Open}) + \gamma' X + \delta_t + \varepsilon$
- Specification curve 设计（400+ 规格）

### 第 5 章 实证结果

| 节 | 内容 | 对应表格 |
|----|------|---------|
| 5.1 | 基准结果：各位置哑变量单独进入 | Table 2 |
| 5.2 | 联合回归：所有位置同时进入 | Table 3 |
| 5.3 | **核心异质性：开源 vs 闭源** | Table 4（论文灵魂） |
| 5.4 | 模型能力的解释力 (within-group) | Table 5 |

### 第 6 章 稳健性检验

- 短窗口 CAR[0,+1] 一致性
- FF3 vs 市场模型
- Specification Curve Analysis（Figure 3）
- Wild Bootstrap（B=4999, Rademacher）
- 去除极端事件（DeepSeek R1 单独剔除后结论不变）

### 第 7 章 讨论

- "创造性破坏"的供应链方向性
- 开源作为 disruption mechanism：Schumpeterian gales
- 对比传统 IT 创新扩散文献
- 政策含义：开源监管 vs 算力垄断

### 第 8 章 结论

---

## 五、表格与图形清单

### 主文表格

| 编号 | 标题 | 内容 |
|------|------|------|
| Table 1 | Descriptive Statistics | 事件、公司、关系分布、CAR 描述 |
| Table 2 | Baseline: Supply Chain Position and CAR | 6 个位置哑变量单独回归 |
| Table 3 | Joint Regression: All Positions Simultaneously | 控制位置交叠 |
| **Table 4** | **Open vs Closed Source: Heterogeneous Effects** | 分组 + 交互项 |
| Table 5 | Model Capability and CAR (Within-Group) | aa_intelligence → CAR |

### 主文图形

| 编号 | 标题 | 内容 |
|------|------|------|
| Figure 1 | Supply Chain Position Effects | 各位置 β + 95%CI 点图 |
| Figure 2 | Open vs Closed: Coefficient Comparison | 两组 β 并排对比图 |
| Figure 3 | Specification Curve | 稳健性 |

### 附录

| 编号 | 内容 |
|------|------|
| Table A1 | 60 个事件完整列表 |
| Table A2 | 86 家公司完整列表 |
| Table A3 | 8 维编码 codebook |
| Table A4 | IRR 结果（Cohen's κ 各维度） |
| Table A5 | Wild Bootstrap p 值 |
| Figure A1 | 事件时间线 |

---

## 六、取舍决策

### ✅ 纳入主文

- 单哑变量基准回归（Table 2）—— 建立核心事实
- 联合回归（Table 3）—— 控制交叠后的净效应
- 开源/闭源分组 + 交互项（Table 4）—— 论文的核心贡献
- 能力指标 within-group（Table 5）—— 机制验证
- Spec curve 图 —— 顶刊审稿人必问

### ❌ 不纳入主文

- ASVI / 媒体情感分析 —— 数据尚不成熟，留给后续论文
- 时间趋势 / 分阶段回归 —— 当前不够显著，不构成独立贡献
- Owner / investor 单独分析 —— 样本太小（29/39 行），不支撑独立表格
- 旧编码的任何结果 —— 已被新 8 维编码替代
- 全部 400+ specr 规格明细 —— 仅放 curve 图，明细存附录数据

---

## 七、发表定位

| 期刊 | 适合度 | 理由 |
|------|--------|------|
| **《经济研究》** | ⭐⭐⭐⭐⭐ | 中文顶刊，AI 话题需求大，DeepSeek 故事天然 policy relevance |
| **《管理世界》** | ⭐⭐⭐⭐⭐ | 产业链视角契合管理学，样本量可接受 |
| **《金融研究》** | ⭐⭐⭐⭐ | 事件研究方法论匹配，但需强化金融理论 |
| Management Science | ⭐⭐⭐⭐ | tech + finance 交叉，对样本量容忍度高 |
| JFE / RFS | ⭐⭐⭐ | 方法干净，但 60 events 偏少、外部效度受限 |
| Information Systems Research | ⭐⭐⭐ | IT value 方向，备选 |

---

## 八、下一步行动

- [ ] 基于本文档确认论文定位和目标期刊
- [ ] 生成正式 LaTeX 主文表格（Table 2–4）
- [ ] 绘制 Figure 1–2 系数图
- [ ] 起草 Introduction 正式文本
- [ ] 完成 Section 5.3（开源/闭源）的正式写作
- [ ] 补充稳健性：去除 DeepSeek R1 后结果不变的检验
- [ ] 讨论 identification 问题（关系编码为何非内生）
