# Multi-Agent Execution Plan

任务时间 20260613-210000，北京时间。

任务目标

对当前项目的核心计量设计做一轮可执行改进，重点检验闭源 AI 模型能力定价结果是否经得起更严格的计量设定。

执行原则

- 不覆盖原始数据和既有主脚本。
- 新增脚本和输出集中保存在 `agent_tasks/econometric_robustness_20260613-210000/`。
- 主代理负责关键脚本、运行和最终判断。
- 子代理只做边界清楚的并行复核。
- 中文输出遵守项目要求，减少冒号。

阶段一 规划阶段

- 读取清洗后的回归数据字段，确认变量名称、样本口径和可用 CAR 窗口。
- 设计最小但高价值的稳健性检验。
- 并行分派复核任务。
  - 子代理 A 复核数据结构和变量口径，输出到 `data_structure_review.md`。
  - 子代理 B 复核 R 代码和统计推断实现，输出到 `code_review.md`。

阶段二 实施阶段

- 新建 `run_econometric_robustness.R`。
- 跑以下检验。
  - firm fixed effects。
  - event-level aggregated CAR 回归。
  - pre-event CAR 检验。
  - leave-one-creator-out。
  - placebo event date，如果数据中有可用 pre CAR 或足够字段。
  - firm cluster 和 two-way cluster，如果依赖包可用。
  - 窗口重叠诊断。
  - 美国交易标的或 ADR 口径检验，如果 ticker 规则可稳定识别。

阶段三 审阅阶段

- 读取输出表，检查核心结果是否改变。
- 比对子代理复核意见。
- 标记哪些检验可以进主文，哪些只能进附录。

阶段四 修订阶段

- 形成 `econometric_robustness_report.md`。
- 输出最终中文总结。
- 明确哪些结果增强论文，哪些结果带来新风险。
