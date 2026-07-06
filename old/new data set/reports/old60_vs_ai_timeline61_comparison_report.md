# Old 60 与 AI Timeline 61 逐条对照

规则。

- 新表是 76 条名字严格匹配行按 AI Timeline `event_id` 合并后的 61 条。
- 旧表来自 `data/panel/clean_event_firm_panel.csv` 中 60 个唯一 `final_event_id`。
- 只要旧表和新表有任一模型名或 AA 模型名的规范化签名完全一致，就记为一组客观对应。
- 规范化只处理大小写、标点、连字符、月份括号和 `model/family/new/full` 等通用词。

## 数量

- new_61_events 61
- old_60_events 60
- objective_name_pairs 46
- new_events_with_any_old_match 26
- old_events_with_any_new_match 30
- new61_only_events 35
- old60_only_events 30
- same_month_pairs 25
- adjacent_month_pairs 10
- time_far_pairs 11

## 结论

这两张表不是逐条一一对应。它们有一个明显重叠的核心，但也各自有大量独有条目。

## 输出

- `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/old60_vs_ai_timeline61_comparison.xlsx`
- `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/old60_vs_ai_timeline61_objective_pairs.csv`
- `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/old60_vs_ai_timeline61_old_view.csv`
- `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/old60_vs_ai_timeline61_new_view.csv`
- `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/ai_timeline_61_event_level.csv`
