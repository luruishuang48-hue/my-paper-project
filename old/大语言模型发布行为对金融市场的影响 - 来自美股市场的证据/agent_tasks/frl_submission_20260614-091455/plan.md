# Multi-Agent Execution Plan

任务时间 20260614-091455，北京时间。

任务目标

把现有结果整理成一份可投 Finance Research Letters 的英文稿件。正文保留最精华结果，长附录承接全部可用稳健性和扩展分析。

执行原则

- 不覆盖 `Tex/` 中已有稿件。
- 新投稿稿件和辅助材料写入 `agent_tasks/frl_submission_20260614-091455/`。
- 正文按 FRL short letter 标准写作，结果具体，主线单一。
- 附录可以很长，但要有结构，方便之后删减或拆成 online appendix。
- 清除所有占位引用和旧稿中的 `[CITATION]` 类占位符。
- 遵守项目写作要求，中文沟通减少冒号。

阶段一 规划阶段

- 读取当前 FRL 草稿、结果库存、稳健性结果和核心表格。
- 确定正文结果组合和附录结构。
- 并行分派两个子任务。
  - 子代理 A 准备长附录材料清单和表格安排，输出 `appendix_architecture.md`。
  - 子代理 B 从审稿人视角检查主文应避免的过强表述，输出 `submission_risk_review.md`。

阶段二 实施阶段

- 主代理撰写 `frl_submission_main.tex`，包括标题页、摘要、正文、三张主表、参考文献和在线附录引用。
- 撰写 `frl_online_appendix.tex`，包含样本、变量、稳健性、规格曲线、异质性、关系编码和补充发现。
- 撰写 `highlights.txt`、`data_availability_statement.md` 和 `cover_letter_draft.md`。

阶段三 审阅阶段

- 对主文进行经济学写作检查。
- 检查数字、表格和文字是否一致。
- 检查是否仍有占位符、冒号过多、过强因果表述或没有来源的结果。

阶段四 修订阶段

- 根据审阅结果修订主文和附录。
- 尝试编译 LaTeX。若不能编译，记录原因。
- 最终交付文件路径和主要修改说明。
