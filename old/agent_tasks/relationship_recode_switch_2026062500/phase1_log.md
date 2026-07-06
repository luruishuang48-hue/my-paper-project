# Phase 1 执行日志

时间: 2026-06-25 00:12

## 操作
1. 读取 `data/panel/specr_rel_clean_v2.csv`（94 列）。
2. 删除旧 8 列：owner, investor, cloud, business_upstream, real_upstream, business_downstream, real_downstream, competitor（旧版）。
3. `competitor_new` 重命名为 `competitor`。
4. 保留 relationship_old（旧中文文本，历史参照）、relationship_confidence、relationship_justification。
5. 输出根目录 `relationship_data_final.csv`（86 列，5160 行）。
6. 备份 `data/panel/specr_rel_clean.csv` → `data/panel/specr_rel_clean_OLD_BACKUP.csv`（6,119,460 bytes，与原文件一致）。
7. 用新口径覆盖 `data/panel/specr_rel_clean.csv`。

## 完整性检查结果（全部通过）

| 维度 | 计数 | 预期 | 状态 |
|---|---|---|---|
| upstream_hardware | 1200 | 1200 | OK |
| upstream_cloud | 300 | 300 | OK |
| downstream_integrator | 1797 | 1797 | OK |
| downstream_deployer | 1140 | 1140 | OK |
| downstream_enabler | 480 | 480 | OK |
| competitor | 511 | 511 | OK |
| is_investor | 39 | 39 | OK |
| is_owner | 29 | 29 | OK |

- 行数: 5160（预期 5160）OK
- 事件数: 60（预期 60）OK
- 旧列（owner/investor/cloud/business_upstream/real_upstream/business_downstream/real_downstream）确认已全部删除
- competitor_new 确认已重命名为 competitor，无残留

## 最终列名（86 列）
final_event_id, release_date, release_year, release_month, release_quarter, trend_month, event_name,
Unnamed: 7, true_model_creator, creator_country, creator_type, model_names, company, 搜索代码1, 搜索代码2,
company_id, relationship_old, industry, industry_2, size_log_assets, bm_ratio, volatility, momentum,
car_pre, car_1-20, FF3异常收益[-10,-2], ff3_car_1-20, 媒体态度均值/标准差(多窗口), ...(原有 AA/模型元数据列)...,
aa_intelligence_index, relationship_notes,
**upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer, downstream_enabler,
competitor, is_investor, is_owner, relationship_confidence, relationship_justification**

## 输出文件
- `/relationship_data_final.csv`（仓库根目录，新创建）
- `data/panel/specr_rel_clean.csv`（覆盖，新口径，6,355,064 bytes）
- `data/panel/specr_rel_clean_OLD_BACKUP.csv`（旧口径备份，6,119,460 bytes，与覆盖前原文件完全一致）
