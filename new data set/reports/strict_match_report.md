# AI Timeline-AA 名字严格匹配报告

当前主样本规则。

- 只要求 AI Timeline 模型名和 AA 模型名规范化后完全相同。
- 发布时间不再决定删留，只作为参考列保留。
- 规范化只忽略大小写、空格、标点、连字符、撇号、通用词 model/models，以及 AA 快照日期标签，例如 `(May '24)`。
- 不允许同系列、相邻版本、同公司或模糊替代。

## 数量

- 检查 AI Timeline 模型实体 266 条
- 名字严格对上 76 条
- 其中时间同月 49 条
- 其中时间不同月或 AA 缺少时间 27 条
- AA 没有严格同名模型 190 条

## 名字严格对上的年份分布

- 2022 年 4 条
- 2023 年 5 条
- 2024 年 34 条
- 2025 年 31 条
- 2026 年 2 条

## 旧口径参考

- 名字和月份都对上 49 条
- 名字对上但月份不对或缺少时间 27 条

## 输出文件

- 名字严格对上的主表 `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/ai_timeline_aa_name_exact_matches.csv`
- 全部状态表 `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/ai_timeline_aa_strict_match_status.csv`
- 名字和月份都对上的旧口径表 `/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/new data set/processed/ai_timeline_aa_strict_matches.csv`
