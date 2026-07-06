# Multi-agent execution plan

## 任务

阅读项目主文与相关材料，诊断稿件作为 Finance Research Letters 投稿稿件的主要问题，并给出下一步前进方向。完整诊断写入 `agent_tasks/frl_project_review_20260613-204658/main_text_review.md`，不修改项目主文。

## 执行约束

- 使用北京时间 `20260613-204850` 建立临时工作目录
- 运行环境没有可调用的 `spawn_agent` 或 `wait_agent`，因此本次由主代理完成多阶段流程
- 写作使用中文，并尽量减少冒号
- 输出重点覆盖研究问题、贡献聚焦、摘要和引言、理论机制和文献定位、短文结构、最需要修改的段落或章节

## 阶段一 规划与信息收集

读取以下材料，先建立论文的现有叙事、实证结果和目标期刊口径。

- `Tex/frl_draft_main_text.tex`
- `Tex/llm_pricing_regime_full.tex`
- `proposal.md`
- `result.md`
- `agent_tasks/frl-draft_20260611-134549/frl_draft_main_text.md`

## 阶段二 执行与整合

提取主文的摘要、引言、理论与假说、数据和方法、结果、机制、稳健性和结论，判断稿件是否符合 FRL 短文特征。

## 阶段三 审阅与反馈

从编辑和审稿人角度列出当前最大风险，并区分必须立即修的问题与可后置的问题。

## 阶段四 修订输出

形成中文诊断报告，包含总体判断、核心问题、下一步方向和优先修改清单。写入指定输出文件。
