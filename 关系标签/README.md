# 关系编码（125 事件主样本 × 108 公司池）

对应 to_do T6：为新公司池重编 8 维生态位置关系，编码单位为（公司 × 发布方）对，
108 公司 × 25 发布方 = 2,700 对（旧版 86 × 14 = 1,204 对）。

## 规则来源（只放规则，不放旧结果）

- `relationship_codebook.md`：8 维定义（R1-R6 + F1/F2）、判据、决策流程、
  典型公司表——唯一权威参考，沿用旧版 v1.0 不改动。
- `gpt_coding_prompt.md`：旧版 coder 提示词，coder B 沿用。

## 编码协议（同事件标签流程）

1. **Coder A**：Claude（2026-07-03），产出 `coder_A_company_creator_20260703.csv`，
   判断集合与理由全部固化在 `coder_A_make_relationship_codes.py`。
2. **Coder B**：另开会话或用户，不得参考 coder A 结果，只读本文件夹规则文档
   与公司/发布方清单。
3. **仲裁**：分歧表 → 用户定稿 → κ → `decisions/relationship_decisions.csv`
   → 面板合并。

## 新公司池带来的、codebook 未覆盖的判定（coder A 的扩展，待仲裁确认）

1. **半导体设备/材料商**（ASML、AMAT、LRCX、KLAC、TER、ENTG）：不直接"供应 AI
   硬件"但是 AI 芯片产能的结构性上游。coder A 按 R1 判据扩展编 R1=1（conf M）。
2. **电力公司**（CEG、AEP、EXC、XEL）：AI 数据中心电力需求的直接受益方（CEG 与
   微软核电 PPA），但 codebook 无电力维度。coder A 全编 0 并留 note，仲裁时决定
   是否扩展 R1 或单列维度。
3. **Cisco**：旧 codebook 归 R4，但其数据中心交换机符合 R1(a)"data-center
   switches"字面判据。coder A 按 R1=1（M）编，留 note 待仲裁。
4. **NVIDIA 的时变投资**（OpenAI 2025-09、xAI 2025-12）：F1 编 1 但 conf L，
   note 标注仅适用于投资公告后的事件，回归阶段可能需要事件级开关。
5. **Alibaba 无上市主体在池内**（BABA 不在纳指100/SOX）：阿里系 8 个事件在新公司
   池中没有 F2=1 的"publisher"行——与旧样本结构不同，写论文时需说明。
