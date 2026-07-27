# 事件标签编码

本目录保存 125 个日度可识别模型发布事件的双编码证据。

## 文件

- `aitimeline_model_events_enriched_codebook.md` 定义事件标签字段。
- `labeling_rules.md` 给出边界情形和执行规则。
- `coder_A_event_labels.csv` 与 `coder_B_event_labels.csv` 是两套独立编码。
- `coder_AB_discrepancies.csv` 记录 10 处分歧及仲裁结果。
- `事件集筛选/decisions/event_label_decisions.csv` 是分析使用的定稿表。

校验脚本检查 125 个事件、8 个二元维度、1,000 个二元单元以及全部分歧记录。

```sh
python3 事件标签/validate_event_labels.py
```
