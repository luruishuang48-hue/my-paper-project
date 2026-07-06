# ATL-AA 134 事件交付包

本文件夹用于交付 AiTimeline 与 Artificial Analysis 交集筛选后的 134 个事件。

最终事件表是 `processed/final_event_sample.csv`。当前表内共有 134 个事件，`model_count` 加总为 187。

主要材料如下。

- `processed/final_event_sample.csv` 最终 134 个事件列表
- `processed/ai_timeline_aa_model_matches.csv` 终审后的实体级匹配表
- `processed/entity_resolution_log.csv` 人工决策和自动规则的处理日志
- `decisions/entity_decisions.csv` 人工筛选和重定向决策表
- `scripts/build_dataset.py` 初始事件和模型匹配脚本
- `scripts/resolve_entities.py` 应用人工决策和确定性规则
- `scripts/build_final_sample.py` 生成最终事件级样本
- `reports/audit_findings_20260702.md` 筛选审计记录
- `raw/` 脚本复跑所需原始抓取数据
- `inputs/` 传递文件夹中原始输入文件的副本
- `diagnostics/` 严格匹配、top-2 review 和历史诊断材料

复跑顺序如下。

```bash
python3 scripts/build_dataset.py
python3 scripts/resolve_entities.py
python3 scripts/build_final_sample.py
```

审计报告里有一处旧表述写为 188 个模型实体。以当前最终表为准，当前 `model_count` 加总为 187。
