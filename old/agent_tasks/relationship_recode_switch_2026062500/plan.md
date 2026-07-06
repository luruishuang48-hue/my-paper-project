# 关系编码切换为正式口径 — 多代理执行计划

创建时间: 2026-06-25 00:10 北京时间
工作目录: `agent_tasks/relationship_recode_switch_2026062500/`

## 背景

新 8 维仲裁后关系编码（`data/relationships/adjudicated_event_level.csv`，pooled κ=0.986）已验证合并进
`task/事件集数据-relationships_v2.csv` 和 `data/panel/specr_rel_clean_v2.csv`（新旧并存）。
本轮任务：删除旧 8 列编码，新 8 维成为唯一正式口径，产出根目录文件，重跑所有关系相关回归。

旧→新角色映射（非一一对应，回归脚本迁移时必须重新设计组合变量）：
- `owner` → `is_owner`（基本一一对应，29=29）
- `investor` → `is_investor`（几乎一一对应，37→39，新增 2 行是 MSFT-Mistral AI 投资，新规则补上的）
- `cloud` → `upstream_cloud`（旧 29 → 新 300，新口径明显更宽）
- `business_upstream`/`real_upstream` → 拆分重组进 `upstream_hardware`/`upstream_cloud`
- `business_downstream`/`real_downstream` → 拆分重组进 `downstream_integrator`/`downstream_deployer`/`downstream_enabler`（三分类）
- `competitor` → `competitor`（同名，511 vs 旧 462，旧 1 全部保留，新增 49）

## 阶段

### Phase 1（主控直接执行，非agent）
产出 `relationship_data_final.csv`（根目录）+ 覆盖 `data/panel/specr_rel_clean.csv`（备份旧版本）。

### Phase 2（7 个 agent 并行）
逐脚本判断是否为真正的关系回归，若是则建 `_v2` 副本迁移列名/组合变量逻辑，跑通，产出对比说明。
脚本清单见 TaskList #15-21。

### Phase 3（2 个 agent 并行）
- review_data：核对 Phase 1 产出
- review_regressions：汇总 Phase 2 所有对比说明

### Phase 4（主控或 1 个 agent）
根据审阅修正问题，产出最终摘要。

## 输出文件登记
- `relationship_data_final.csv`（根目录）
- `data/panel/specr_rel_clean.csv`（覆盖，新口径）
- `data/panel/specr_rel_clean_OLD_BACKUP.csv`（旧口径备份）
- 各 agent_tasks 子目录下的 `*_v2.R` / `*_v2_comparison.md` / outputs 下的 `*_v2.csv`
- `agent_tasks/relationship_recode_switch_2026062500/phase1_log.md`
- `agent_tasks/relationship_recode_switch_2026062500/review_data.md`
- `agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md`
- `agent_tasks/relationship_recode_switch_2026062500/final_summary.md`
