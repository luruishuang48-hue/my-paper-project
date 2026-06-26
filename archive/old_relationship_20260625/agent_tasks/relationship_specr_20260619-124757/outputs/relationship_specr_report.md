# 关系变量 Specr 报告

生成时间 2026-06-19 12:47，任务目录 `agent_tasks/relationship_specr_20260619-124757`。

## 做了什么

本次跑两套规格曲线。第一套把关系变量作为子样本，用 `aa_intelligence_index` 解释不同 CAR 窗口。第二套把关系旗标逐个作为主解释变量，检验某类关系本身是否对应更强或更弱的异常收益。

两套分析都使用 `data/panel/specr_rel_clean.csv`。回归使用 `lm_robust`，标准误按 `final_event_id` 聚类。聚类数不足 5 时退回普通 OLS。控制变量组为无控制、仅规模、完整控制。完整控制包括规模、账面市值比、波动率和动量。年份固定效应按规格开关。

## 数据校验

- 输入维度  5161 行，84 列。
- 事件数  61。
- 关系旗标计数  owner 29，investor 37，cloud 29，business_upstream 156，real_upstream 126，business_downstream 1440，real_downstream 81，competitor 462。

## 关系作子样本

有效规格数为 756。显著率最高的子样本如下。

| 子样本 | 规格数 | p<0.05 比例 | 正向比例 | 中位系数 |
|---|---:|---:|---:|---:|
| us_creator | 42 | 47.6% | 100.0% | 0.001110 |
| open_source | 42 | 38.1% | 7.1% | -0.000599 |
| owner | 42 | 35.7% | 35.7% | -0.001469 |
| real_downstream | 42 | 33.3% | 73.8% | 0.000786 |
| closed_source | 42 | 26.2% | 88.1% | 0.000512 |
| investor | 42 | 21.4% | 45.2% | -0.000750 |

主读 `car_20 + 完整控制 + 年份固定效应` 时，关系组内的能力定价排序如下。

| 子样本 | N | 事件数 | 系数 | 标准误 | p 值 |
|---|---:|---:|---:|---:|---:|
| us_creator | 1304 | 16 | 0.00245+ | 0.00131 | 0.0813 |
| closed_source | 2899 | 36 | 0.00232*** | 0.00062 | 0.00064 |
| real_downstream | 62 | 20 | 0.00200 | 0.00164 | 0.235 |
| business_downstream | 1090 | 47 | 0.00184* | 0.00091 | 0.0496 |
| broad_downstream | 1090 | 47 | 0.00184* | 0.00091 | 0.0496 |
| business_upstream | 122 | 47 | 0.00166 | 0.00133 | 0.221 |
| broad_upstream | 122 | 47 | 0.00166 | 0.00133 | 0.221 |
| all | 3780 | 47 | 0.00152* | 0.00067 | 0.0271 |
| text_or_reason | 3780 | 47 | 0.00152* | 0.00067 | 0.0271 |
| real_upstream | 103 | 41 | 0.00150 | 0.00138 | 0.284 |

## 关系旗标作 X

有效规格数为 2226。各关系旗标逐个进入回归，避免多个重叠旗标同时进入导致解释不清。

| 关系旗标 | 规格数 | p<0.05 比例 | 正向比例 | 中位系数 |
|---|---:|---:|---:|---:|
| real_downstream | 252 | 40.5% | 8.7% | -0.010376 |
| cloud | 252 | 29.4% | 31.0% | -0.003638 |
| investor | 252 | 29.4% | 21.8% | -0.007873 |
| real_upstream | 294 | 28.9% | 77.6% | 0.006057 |
| business_upstream | 294 | 17.3% | 72.4% | 0.004099 |
| business_downstream | 294 | 3.4% | 41.8% | -0.001060 |
| competitor | 294 | 0.7% | 52.4% | 0.000492 |
| owner | 294 | 0.0% | 70.4% | 0.008598 |

全样本 `car_20 + 完整控制 + 年份固定效应` 下，关系旗标本身的估计如下。

| 关系旗标 | N | 事件数 | 系数 | 标准误 | p 值 |
|---|---:|---:|---:|---:|---:|
| real_upstream | 4829 | 60 | 0.04163** | 0.01274 | 0.00181 |
| business_upstream | 4829 | 60 | 0.03691** | 0.01139 | 0.00196 |
| owner | 4829 | 60 | 0.01905 | 0.02144 | 0.378 |
| cloud | 4829 | 60 | 0.00586 | 0.02054 | 0.777 |
| competitor | 4829 | 60 | -0.00269 | 0.00712 | 0.707 |
| investor | 4829 | 60 | -0.00291 | 0.02167 | 0.894 |
| business_downstream | 4829 | 60 | -0.00936 | 0.00653 | 0.157 |
| real_downstream | 4829 | 60 | -0.01316 | 0.01703 | 0.443 |

## 解读口径

- 关系作子样本回答的是，模型能力信号在哪些关系组内更容易被市场定价。
- 关系旗标作 X 回答的是，某种公司和模型发布者关系本身是否对应更高或更低 CAR。
- owner、investor 和 cloud 样本很小，只适合作为探索性证据。报告和正文不宜把这些组写成强结论。
- 关系旗标不是互斥分类。某家公司可以同时是投资者、云服务方或竞争者。关系旗标作 X 的结果应读成单旗标相关性，不应读成互斥身份差异。

## 输出文件

- `outputs/relationship_subsample_specr_results_all.csv`
- `outputs/relationship_subsample_specr_summary.csv`
- `outputs/relationship_x_specr_results_all.csv`
- `outputs/relationship_x_specr_summary.csv`
- `outputs/relationship_subsample_specr_curve_all.pdf`
- `outputs/relationship_x_specr_curve_by_x.pdf`
- `outputs/relationship_specr_validation.csv`
- `outputs/relationship_subsample_car20_full_yearfe.csv`
- `outputs/relationship_x_car20_full_yearfe.csv`
