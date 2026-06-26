# Multi-agent execution plan

任务时间 20260625-234254，北京时间。

目标是基于已有 `new data set` 数据生成一个 PDF。PDF 表格包含 8 列，分别是 AI Timeline 事件、AI Timeline 时间、AA 最可能模型、该模型发布时间、可信度、AA 第二可能模型、发布时间和可信度。

## 成功标准

- 所有新增文件仍在 `new data set` 内。
- PDF 可打开，包含所有 AI Timeline 模型实体对应的候选匹配。
- 同步输出一份 CSV，便于后续继续编辑或核查。
- 可信度按 10 分制展示。
- 候选发布时间来自已抓取的 AA 模型表，若 AA 无日期则留空。

## 阶段一，规划和输入核查

- 检查已有匹配表 `new data set/processed/ai_timeline_aa_model_matches.csv`。
- 检查 AA 合并模型表 `new data set/processed/aa_models.csv`。
- 确认 `top_candidates_json` 足够生成候选 1 和候选 2。

## 阶段二，生成 PDF 和 CSV

- 生成审阅用 CSV `new data set/processed/ai_timeline_aa_top2_for_review.csv`。
- 生成 PDF `new data set/reports/ai_timeline_aa_top2_review.pdf`。
- PDF 使用横向大页面，长文本自动换行。

## 阶段三，审阅

- 检查行数、列数、分页和 PDF 可读取性。
- 抽查 high、medium、low 和 unmatched 记录。

## 阶段四，修订和交付

- 若发现字段缺失或排版问题，修订生成脚本后重跑。
- 最终交付 PDF、CSV 和生成脚本。

## 执行方式

本任务不需要并行子代理。输入已经在本地，关键路径是主代理生成和核查 PDF。

