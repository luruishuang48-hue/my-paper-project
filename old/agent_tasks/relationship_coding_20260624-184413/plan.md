# Multi-agent execution plan

任务：按照 data/relationships/gpt_coding_prompt.md 和 data/relationships/relationship_codebook.md，为事件与公司标注关系。

时间：20260624-184413，Asia/Shanghai。

阶段 1 信息收集与方案规划
- 读取提示词、关系 codebook 和待处理数据结构。
- 判断输入文件、输出字段和已有中间结果。

阶段 2 执行与整合
- 依据规则生成或更新关系标注结果。
- 如果任务可分片，使用子代理分片审阅或标注，并将结果写入本地文件。
- 主代理整合冲突，生成最终数据。

阶段 3 审阅与反馈
- 检查字段完整性、标签合法性、重复项和明显冲突。
- 抽样复核边界案例。

阶段 4 修订与交付
- 根据审阅结果修订最终文件。
- 汇总输出位置、处理规模和验证结果。
