# 事件样本

本目录从 AI Timeline 与 Artificial Analysis 的原始快照构造模型发布事件。

## 构造顺序

```sh
python3 事件集筛选/scripts/build_dataset.py
python3 事件集筛选/scripts/resolve_entities.py
python3 事件集筛选/scripts/build_final_sample.py
python3 事件集筛选/scripts/build_event_dates.py
python3 事件集筛选/scripts/build_event_aa_metrics.py
```

流程先生成 134 个身份匹配事件，再依据官方日期决策保留 125 个日度可识别事件。
回归阶段另排除身份存在冲突的 `AIT-2026-02-006`，因此论文估计使用 124 个事件。

`raw/` 保存复现所需的 AI Timeline 与 Artificial Analysis 快照。
`decisions/` 保存实体解析、日期、事件标签、企业样本和企业关系的人工终审表。
`processed/` 由脚本生成。事件能力指标采用每个事件的旗舰代表模型。
