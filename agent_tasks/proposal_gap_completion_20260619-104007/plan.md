# Multi-agent execution plan

任务：通读项目，根据 `proposal.md` 找出尚未完成的分析，并在现有数据与代码条件下补做可执行分析。

时间：20260619-104007，Asia/Shanghai。

## 目标

1. 梳理 `proposal.md` 的研究问题、假设、变量、识别设计和预期分析。
2. 盘点项目中已完成的数据处理、回归、稳健性检验、异质性分析、图表和论文草稿。
3. 找出 proposal 承诺但尚未完成，且现有数据可以支持的分析。
4. 补做缺口分析，输出可复现脚本、结果表、图和中文总结。
5. 审阅新结果，修正统计口径和文字解释。

## 阶段一 规划与信息收集

主代理负责读取 `proposal.md`、数据字典、主结果表和现有任务报告，建立缺口清单。  
子代理 A 负责盘点现有结果文件，输出 `existing_results_inventory.md`。  
子代理 B 负责逐项提取 proposal 中的分析承诺，输出 `proposal_analysis_requirements.md`。  
子代理 C 负责核查数据字段与可用样本，输出 `data_feasibility_audit.md`。

## 阶段二 执行与整合

主代理根据缺口清单选择可执行分析，优先做不需要外部新数据的项目。  
新分析脚本保存为 `run_missing_analyses.R` 或 `run_missing_analyses.py`。  
结果保存为 CSV、PNG 和一份 `missing_analysis_report.md`。

## 阶段三 审阅

审阅统计口径、样本定义、回归设定、输出表头、中文解释和与 proposal 的一致性。  
审阅意见保存为 `review.md`。

## 阶段四 修订与交付

根据审阅意见修订脚本和报告。  
最终输出 `final_report.md`，说明补做了什么、主要发现是什么、哪些分析仍需新增数据后才能完成。

## 约束

不覆盖用户已有文件。  
不撤销既有更改。  
减少中文写作中冒号的使用。  
所有子代理只写入本任务目录下的指定文件。
