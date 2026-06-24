# 关系变量 Specr 报告（v2，新 8 维关系编码）

生成时间 2026-06-25，任务目录 `agent_tasks/relationship_specr_20260619-124757`（v2 重跑，输出目录 `outputs_v2`）。

## 做了什么

本次跑两套规格曲线。第一套把关系变量作为子样本，用 `aa_intelligence_index` 解释不同 CAR 窗口。第二套把关系旗标逐个作为主解释变量，检验某类关系本身是否对应更强或更弱的异常收益。

两套分析都使用 `data/panel/specr_rel_clean.csv`（新 8 维关系编码：upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer, downstream_enabler, competitor, is_investor, is_owner）。回归使用 `lm_robust`，标准误按 `final_event_id` 聚类。聚类数不足 5 时退回普通 OLS。控制变量组为无控制、仅规模、完整控制。完整控制包括规模、账面市值比、波动率和动量。年份固定效应按规格开关。

## 数据校验

- 输入维度  5160 行，86 列。
- 事件数  60。
- 关系旗标计数（新 8 维编码）  upstream_hardware 1200，upstream_cloud 300，downstream_integrator 1797，downstream_deployer 1140，downstream_enabler 480，competitor 511，is_investor 39，is_owner 29。

## 关系作子样本

有效规格数为 756。显著率最高的子样本如下。

| 子样本 | 规格数 | p<0.05 比例 | 正向比例 | 中位系数 |
|---|---:|---:|---:|---:|
| us_creator | 42 | 47.6% | 100.0% | 0.001110 |
| open_source | 42 | 38.1% | 7.1% | -0.000599 |
| is_owner | 42 | 35.7% | 35.7% | -0.001469 |
| closed_source | 42 | 26.2% | 88.1% | 0.000512 |
| is_investor | 42 | 21.4% | 33.3% | -0.000674 |
| all | 42 | 11.9% | 83.3% | 0.000342 |

主读 `car_20 + 完整控制 + 年份固定效应` 时，关系组内的能力定价排序如下。

| 子样本 | N | 事件数 | 系数 | 标准误 | p 值 |
|---|---:|---:|---:|---:|---:|
| us_creator | 1304 | 16 | 0.00245+ | 0.00131 | 0.0813 |
| closed_source | 2899 | 36 | 0.00232*** | 0.00062 | 0.00064 |
| downstream_integrator | 1373 | 47 | 0.00184+ | 0.00098 | 0.0675 |
| all | 3780 | 47 | 0.00152* | 0.00067 | 0.0271 |
| text_or_reason | 3780 | 47 | 0.00152* | 0.00067 | 0.0271 |
| broad_downstream | 2490 | 47 | 0.00139+ | 0.00073 | 0.0635 |
| non_us_creator | 2476 | 31 | 0.00137+ | 0.00070 | 0.0596 |
| downstream_comp | 2801 | 47 | 0.00128* | 0.00062 | 0.0453 |
| is_investor | 38 | 22 | 0.00109 | 0.00136 | 0.43 |
| upstream_hardware | 907 | 47 | 0.00107 | 0.00076 | 0.165 |

## 关系旗标作 X

有效规格数为 2310。各关系旗标逐个进入回归，避免多个重叠旗标同时进入导致解释不清。

| 关系旗标 | 规格数 | p<0.05 比例 | 正向比例 | 中位系数 |
|---|---:|---:|---:|---:|
| downstream_deployer | 294 | 25.9% | 0.0% | -0.006757 |
| upstream_hardware | 294 | 25.2% | 76.2% | 0.002502 |
| is_investor | 252 | 18.3% | 23.8% | -0.007464 |
| upstream_cloud | 294 | 14.6% | 80.6% | 0.004951 |
| downstream_enabler | 294 | 6.8% | 38.4% | -0.001082 |
| competitor | 294 | 0.7% | 58.8% | 0.001076 |
| downstream_integrator | 294 | 0.7% | 53.4% | 0.000358 |
| is_owner | 294 | 0.0% | 70.4% | 0.008598 |

全样本 `car_20 + 完整控制 + 年份固定效应` 下，关系旗标本身的估计如下。

| 关系旗标 | N | 事件数 | 系数 | 标准误 | p 值 |
|---|---:|---:|---:|---:|---:|
| upstream_hardware | 4829 | 60 | 0.02276** | 0.00842 | 0.00897 |
| is_owner | 4829 | 60 | 0.01905 | 0.02144 | 0.378 |
| upstream_cloud | 4829 | 60 | 0.01096+ | 0.00557 | 0.054 |
| competitor | 4829 | 60 | -0.00050 | 0.00671 | 0.941 |
| is_investor | 4829 | 60 | -0.00238 | 0.02065 | 0.909 |
| downstream_integrator | 4829 | 60 | -0.00688 | 0.00838 | 0.415 |
| downstream_enabler | 4829 | 60 | -0.01065 | 0.00667 | 0.116 |
| downstream_deployer | 4829 | 60 | -0.01902*** | 0.00507 | 0.000404 |

## 解读口径

- 关系作子样本回答的是，模型能力信号在哪些关系组内更容易被市场定价。
- 关系旗标作 X 回答的是，某种公司和模型发布者关系本身是否对应更高或更低 CAR。
- is_owner、is_investor 和 upstream_cloud 样本仍然偏小（is_owner、is_investor 尤其小），只适合作为探索性证据。报告和正文不宜把这些组写成强结论。
- 关系旗标不是互斥分类。某家公司可以同时是投资者、云服务方或竞争者。关系旗标作 X 的结果应读成单旗标相关性，不应读成互斥身份差异。

## 输出文件

- `outputs_v2/relationship_subsample_specr_results_all.csv`
- `outputs_v2/relationship_subsample_specr_summary.csv`
- `outputs_v2/relationship_x_specr_results_all.csv`
- `outputs_v2/relationship_x_specr_summary.csv`
- `outputs_v2/relationship_subsample_specr_curve_all.pdf`
- `outputs_v2/relationship_x_specr_curve_by_x.pdf`
- `outputs_v2/relationship_specr_validation.csv`
- `outputs_v2/relationship_subsample_car20_full_yearfe.csv`
- `outputs_v2/relationship_x_car20_full_yearfe.csv`
