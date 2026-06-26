# 关系分组回归报告

生成时间 20260619-110835，Asia/Shanghai。

## 一、做了什么

本次按关系分类重新估计事件-公司回归。关系变量来自 `data/panel/specr_rel_clean.csv`，不是 `clean_event_firm_panel.csv` 中的 `relationship` 列。后者全部为空。

输出两套关系口径。

第一套是非互斥旗标。一个事件-公司观测可以同时进入投资者、云服务方、竞争者等多个关系组。  
第二套是互斥主关系。脚本按 owner、investor、cloud、真实上游、商业上游、竞争者、真实下游、商业下游、其他或无关系旗标的顺序归类。

核心脚本为 `run_relation_subsample_regressions.R`。结果都在 `outputs/`。

## 二、主要输出

核心表和图如下。

- `outputs/relationship_sample_summary.csv`
- `outputs/relationship_sample_summary.md`
- `outputs/relationship_intelligence_car20_main_table.csv`
- `outputs/relationship_intelligence_car20_main_table.md`
- `outputs/relationship_closed_source_car20.csv`
- `outputs/relationship_mechanism_car20.csv`
- `outputs/relationship_subsample_regressions_all.csv`
- `outputs/relationship_overlap_matrix.csv`
- `outputs/figure_relation_intelligence_car20_flag.png`
- `outputs/figure_relation_intelligence_car20_exclusive.png`

辅助审阅文件如下。

- `relationship_data_audit.md`
- `relationship_regression_review.md`
- `review.md`

## 三、关系样本结构

主面板有 5,160 个事件-公司观测。至少一种关系旗标为 1 的观测有 2,073 个，占 40.17%。

关系变量不是互斥分类。投资者、云服务方、竞争者和真实下游之间重叠明显。投资者与云服务方重叠 29 个观测，云服务方与竞争者也重叠 29 个观测。商业上游和真实上游高度嵌套，商业下游和真实下游也高度嵌套。

样本规模差异很大。owner 只有 29 个观测，investor 37 个，cloud 29 个。business_downstream 有 1,440 个，competitor 有 462 个，business_upstream 有 156 个，real_upstream 有 126 个。

## 四、关系组内能力定价

主规格回归为 `CAR[0,+20]` 对标准化 AA Intelligence，控制 pre-CAR、规模、账面市值比、波动率、动量和年份固定效应，标准误按事件聚类。

非互斥旗标口径显示，下游合并样本的能力系数为 2.39 个百分点，p 值为 0.009。任一关系样本的系数为 1.90 个百分点，p 值为 0.005。真实下游样本的系数为 4.97 个百分点，p 值为 0.023，但只有 56 个观测和 20 个事件，应放附录。

上游合并样本的系数为 2.36 个百分点，p 值为 0.155。方向较强，但置信区间宽。竞争者样本的系数为 0.24 个百分点，p 值为 0.548。owner、investor 和 cloud 的系数均不显著，且样本很小。

互斥口径给出相近结论。互斥商业下游的系数为 2.32 个百分点，p 值为 0.013。互斥竞争者的系数为 0.25 个百分点，p 值为 0.544。互斥真实上游的系数为 2.13 个百分点，p 值为 0.199。

## 五、闭源样本

闭源样本中的关系组内能力定价更强。非互斥口径下，真实上游系数为 3.29 个百分点，p 值为 0.047。商业下游系数为 3.32 个百分点，p 值为 0.001。真实下游系数为 6.20 个百分点，p 值为 0.003。竞争者系数为 1.02 个百分点，p 值为 0.002。

这一组结果和项目已有主线一致。市场更容易定价闭源或专有模型的能力提升。关系分组说明这种定价在下游应用、真实上游和竞争者样本中都能观察到，但竞争者结果应谨慎解释。竞争者组由少数大型公司反复出现，且经济含义可能包括竞争压力和行业共同预期。

## 六、机制补充

开源交互在多个关系组中为负。下游合并样本中，AA Intelligence 的闭源斜率为 3.19 个百分点，能力 × 开放权重交互为 -5.05 个百分点，p 值为 0.013。上游合并样本中，该交互为 -6.45 个百分点，p 值为 0.044。竞争者样本中交互不显著。

成本速度机制方向不单一。低 TTFT 在下游合并样本中系数为 -3.52 个百分点，p 值小于 0.001。上游合并样本中，低价格系数为 -2.68 个百分点，p 值为 0.026。结果不支持“更便宜、更快一定利好所有关系组”的简单叙述。

媒体情感机制更适合放附录。下游合并样本中，能力系数保持正向。竞争者样本中，w5 情感系数为正且显著，说明媒体情感与竞争者 CAR 的关系不同于全样本，但这更像探索性结果。

## 七、正文建议

正文可保留三点。

第一，关系路径会改变模型发布冲击的资本市场映射。能力定价不是平均落在所有 AI 相关公司上。  
第二，商业下游和下游合并样本显示最清楚的能力定价。AA Intelligence 增加一个标准差，对应 `CAR[0,+20]` 增加约 2.3 到 2.4 个百分点。  
第三，竞争者样本在全样本中没有正向能力定价，说明模型能力提升并不自动利好同赛道公司。

上游结果建议这样写。上游样本的平均 CAR 较高，能力回归方向也为正，但公司数少、标准误宽。它支持算力链暴露的重要性，但不应写成精确估计。

## 八、附录建议

附录放完整关系旗标分组回归、互斥口径结果、闭源样本、开源交互、成本速度和媒体情感机制。owner、investor、cloud 单独回归也放附录，只作为方向性证据。

表注需要说明三点。关系旗标不是互斥分类。标准误按事件聚类。小样本组的事件数和公司数较少，不宜过度解释。
