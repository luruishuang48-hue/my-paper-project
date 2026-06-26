# Multi-agent execution plan

任务时间 20260625-185057，北京时间。

目标是在 `new data set` 内重建一套可审计数据。数据来自 AI Timeline 和 Artificial Analysis。最后输出原始数据、清洗后的事件表、模型与产品区分结果、AA 模型能力表、匹配结果，以及一份 Markdown 报告。

## 成功标准

- 所有新增文件都在 `new data set` 目录内。
- AI Timeline 事件数据尽量完整保存，保留来源字段和抓取时间。
- 事件被区分为模型、产品和其他，分类规则写入报告。
- AA 能力数据尽量多地获取，保留 API 来源和字段说明。
- AI Timeline 中的模型事件与 AA 模型数据完成可复核匹配。
- 输出可供人工审核的匹配表，包含匹配等级、理由和待审标记。

## 阶段一，规划和取数探查

- 主代理确认目录约束、数据源入口、可用接口和页面结构。
- 子代理 A 负责 AI Timeline 站点结构探查，结果写入 `new data set/agent_tasks/llm-release-data_20260625-185057/ai_timeline_probe.md`。
- 子代理 B 负责 Artificial Analysis API 探查，结果写入 `new data set/agent_tasks/llm-release-data_20260625-185057/aa_probe.md`。
- 主代理同步准备目录结构、记录计划，并保留关键命令和抓取方式。

## 阶段二，执行和整合

- 下载 AI Timeline 可获得的全部事件数据到 `new data set/raw`。
- 下载 AA 可获得的模型能力数据到 `new data set/raw`。
- 清洗 AI Timeline 事件，输出 `new data set/processed/ai_timeline_events.csv`。
- 生成事件类型表，输出 `new data set/processed/ai_timeline_events_classified.csv`。
- 清洗 AA 模型能力数据，输出 `new data set/processed/aa_models.csv`。
- 进行名称规范化和模糊匹配，输出 `new data set/processed/ai_timeline_aa_model_matches.csv`。

## 阶段三，审阅和反馈

- 检查记录数、重复项、缺失字段和明显误分类。
- 抽查高置信、低置信和未匹配样本。
- 识别名称别名、供应商归属和版本号造成的匹配风险。

## 阶段四，修订和交付

- 根据审阅结果修订分类与匹配规则。
- 输出最终报告 `new data set/reports/data_rebuild_report.md`。
- 报告包含数据来源、处理步骤、字段说明、匹配统计和需用户审核的样本。

## 角色分工

- 主代理负责关键路径、最终取数脚本、整合、审阅和交付。
- AI Timeline 子代理只做站点结构和数据位置探查。
- AA 子代理只做 API 端点和字段可得性探查，不在最终报告中暴露 API key。

