# 关系编码合并验证报告
生成时间: 2026-06-25
## 1. 行数与唯一键校验
- 合并输出行数: 5160（预期 5160，源头文件去除 1 行空 key 后对齐）
- 唯一事件数: 60（预期 60）
- (final_event_id, company_id) 重复键: 0（预期 0）

## 2. 新 8 维列计数 vs adjudicated_event_level.csv 直接统计
已在 merge_adjudicated_relationships.py 运行时验证，全部 8 个维度计数完全一致（OK）。详见该脚本的运行输出。

## 3. 旧编码 vs 新编码 — 各维度计数对比
| 旧列 | 旧计数(=1) | 新列 | 新计数(=1) |
|---|---|---|---|
| owner | 29 | is_owner | 29 |
| investor | 37 | is_investor | 39 |
| cloud | 29 | upstream_cloud | 300 |
| business_upstream | 156 | upstream_hardware | 1200 |
| real_upstream | 126 | (无直接对应，已拆分为 upstream_hardware/upstream_cloud) | — |
| business_downstream | 1440 | downstream_integrator | 1797 |
| real_downstream | 81 | downstream_deployer | 1140 |
| competitor | 462 | competitor_new | 511 |

## 4. competitor (旧) vs competitor_new (新) 混淆矩阵
```
新 competitor_new     0    1
旧 competitor               
0                 4649   49
1                    0  462
```

一致率: 99.1%

## 5. owner (旧) vs is_owner (新) 混淆矩阵
```
新 is_owner     0   1
旧 owner             
0           5131   0
1              0  29
```

## 6. investor (旧) vs is_investor (新) 混淆矩阵
```
新 is_investor     0   1
旧 investor             
0              5121   2
1                 0  37
```

## 7. 结论
- 新 8 维仲裁结果已成功合并进 `task/事件集数据-relationships_v2.csv`，并通过 `specr_rel_prep_v2.py` 生成 `data/panel/specr_rel_clean_v2.csv`。
- 旧列与新列并存，未删除旧列，可随时回退或对比。
- 新编码整体覆盖范围更广（如 downstream_integrator=1797 远高于旧 business_downstream=1440），符合新 codebook 对 R3/R4/R5 三分类更细粒度、更宽口径的设计意图（旧编码只有粗略的 business/real upstream/downstream 二分）。
- is_owner/is_investor 与旧 owner/investor 高度一致（核心持股关系编码稳定）。
- 建议下一步：若决定切换正式分析口径，需更新 R 回归脚本（如 `agent_tasks/relation_subsample_regressions_20260619-110835/run_relation_subsample_regressions.R`）改用新列名，并将 `data/panel/specr_rel_clean_v2.csv` 提升为正式 `specr_rel_clean.csv`。本次任务不做此切换。
