# 新关系口径下的关系导向 Specr 结果

本轮只使用 `data/panel/specr_rel_clean.csv`。没有读取旧 `output/data`，也没有使用历史结果表。

## 运行概况

脚本为 `run_relationship_specr_newrel.R`。共估计 2448 条规格，覆盖关系主效应、关系与 AA Intelligence 交互、关系子样本能力斜率，以及几个关系对比模型。标准误按事件聚类，使用 `estimatr::lm_robust` 的 CR0。

主要关系变量为 `upstream_hardware`、`upstream_cloud`、`downstream_integrator`、`downstream_deployer`、`downstream_enabler`、`competitor`、`is_investor` 和 `is_owner`。扩展 bundle 包括 `upstream_any`、`downstream_any`、`strategic_any`、`appropriable_any` 和 `any_relationship`。

一个重要解释边界是，除 `is_investor` 和 `is_owner` 外，大部分关系变量在 60 个事件中都有覆盖，更接近公司在 AI 生态中的位置，而不是某一事件独有的双边关系。因此，下述结果应表述为“不同生态位置公司的市场反应不同”，不宜表述为严格的事件特定关系因果效应。

## 样本结构

| 变量 | 取 1 行数 | 覆盖事件 | 覆盖公司 | CAR20 非缺失 | AA 非缺失 |
| --- | ---: | ---: | ---: | ---: | ---: |
| upstream_hardware | 1200 | 60 | 20 | 1200 | 940 |
| upstream_cloud | 274 | 60 | 5 | 274 | 217 |
| downstream_integrator | 1797 | 60 | 30 | 1760 | 1407 |
| downstream_deployer | 1140 | 60 | 19 | 1090 | 893 |
| downstream_enabler | 480 | 60 | 8 | 480 | 376 |
| competitor | 511 | 60 | 9 | 511 | 402 |
| is_investor | 39 | 23 | 4 | 39 | 38 |
| is_owner | 29 | 29 | 4 | 29 | 21 |

`any_relationship` 覆盖 5040 行，占样本 97.7%。这个变量过宽，不适合做核心回归解释变量。

## 最适合写进主文的结果

### 1. 下游部署型公司有稳定负向反应

`downstream_deployer` 是本轮最干净的关系结果。它覆盖 1140 行、60 个事件和 19 家公司。单变量关系规格中，长窗口全部为负，控制公司特征、年份固定效应和 AA Intelligence 后仍显著。

| 因变量 | 控制 | 系数 | 标准误 | p 值 | N |
| --- | --- | ---: | ---: | ---: | ---: |
| CAR[0,+10] | firm + year + intelligence | -0.0100 | 0.0042 | 0.0218 | 3780 |
| CAR[0,+15] | firm + year + intelligence | -0.0158 | 0.0050 | 0.0029 | 3780 |
| CAR[0,+20] | firm + year + intelligence | -0.0202 | 0.0054 | 0.0005 | 3780 |

不加 AA Intelligence 的 firm-year 规格也几乎相同。CAR[0,+20] 系数为 -0.0190，p = 0.0004，N = 4829。

可以写成论文主结论。模型发布并不普遍利好应用层。对于把 AI 当作业务工具部署、但不直接拥有模型能力或基础设施的公司，市场反应在 10 到 20 天窗口持续为负。这一结果支持“AI 能力扩散可能压缩非 AI 原生企业的差异化租金或提高竞争压力”的解释。

### 2. 上游硬件和战略位置呈稳定正向反应

`upstream_hardware`、`upstream_any` 和 `strategic_any` 在长窗口中持续为正。单变量关系规格中，CAR[0,+20] 结果最强。

| 变量 | 因变量 | 控制 | 系数 | 标准误 | p 值 | N |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| upstream_hardware | CAR[0,+20] | firm + year + intelligence | 0.0305 | 0.0097 | 0.0028 | 3780 |
| upstream_any | CAR[0,+20] | firm + year + intelligence | 0.0287 | 0.0090 | 0.0026 | 3780 |
| strategic_any | CAR[0,+20] | firm + year + intelligence | 0.0280 | 0.0088 | 0.0025 | 3780 |

`upstream_hardware` 在 CAR[0,+15] 也显著为正，系数 0.0226，p = 0.0114。CAR[0,+10] 为正但只有 10% 水平，系数 0.0115，p = 0.0936。

这组结果可以作为上游机制。市场更愿意把模型发布解释为算力和基础设施需求信号，而不是单纯的模型发布方利好。

### 3. 下游整体负向和上游整体正向形成清晰对照

Bundle 结果给出一个可以做图或表的关系分化。

| 变量 | CAR[0,+20] 系数 | 标准误 | p 值 | 方向 |
| --- | ---: | ---: | ---: | --- |
| upstream_any | 0.0287 | 0.0090 | 0.0026 | 正 |
| strategic_any | 0.0280 | 0.0088 | 0.0025 | 正 |
| downstream_any | -0.0330 | 0.0087 | 0.0004 | 负 |
| downstream_deployer | -0.0202 | 0.0054 | 0.0005 | 负 |

这个对照比单独强调 AA Intelligence 更贴近论文的关系主题。可以作为一张主文关系异质性表。

## 适合放机制或附录的结果

### 4. 投资方的能力斜率显著为负，但样本很小

`intel_c × is_investor` 在 10、15、20 天窗口均为负，且在 firm-year 规格下显著。

| 因变量 | 系数 | 标准误 | p 值 | treated N | treated 事件 |
| --- | ---: | ---: | ---: | ---: | ---: |
| CAR[0,+10] | -0.0025 | 0.0007 | 0.0006 | 38 | 22 |
| CAR[0,+15] | -0.0025 | 0.0005 | 0.0000 | 38 | 22 |
| CAR[0,+20] | -0.0026 | 0.0009 | 0.0052 | 38 | 22 |

这个结果和之前“投资方主效应可以为正，但对模型能力边际提升不敏感甚至反向”的故事一致。但 treated 行数只有 38，建议作为探索性机制，不宜作为主文核心表的强结论。

### 5. 竞争者的能力斜率偏负，但证据较弱

`intel_c × competitor` 在 CAR[0,+15] 和 CAR[0,+20] 的方向为负，p 值在 0.07 到 0.11 之间。样本量比 investor 好，treated 行数 402，覆盖 47 个有 AA 指数的事件，但统计强度不够。可作为“竞争者未系统受益，能力提升可能带来弱负向压力”的附录证据。

### 6. 下游 enabler 在联合下游模型中显著为负

在 `downstream_integrator`、`downstream_deployer` 和 `downstream_enabler` 同时进入的模型中，`downstream_enabler` 在 CAR[0,+10]、CAR[0,+15]、CAR[0,+20] 均为负且显著。CAR[0,+20] 系数为 -0.0315，p = 0.0017。

不过它只有 480 行和 8 家公司。单变量主效应在 CAR[0,+20] 只有弱显著或不显著。建议放在机制讨论或附录，不作为主文核心发现。

## 暂不建议作为核心结果

`any_relationship` 覆盖 97.7% 样本，几乎没有对照组。它不适合解释关系差异。

`is_owner` 只有 29 行，虽有若干短窗口正向系数，但统计不稳。它更像案例描述，不适合做 Specr 核心结果。

`upstream_cloud` 覆盖 274 行和 5 家公司。方向大多为正，但样本过窄，且与 competitor、investor 有明显重叠。可作为补充，不宜单独上主表。

`downstream_integrator` 单变量结果基本不显著。它在联合下游模型中变为负，说明它的解释依赖控制结构。主文中若使用，应和 `downstream_deployer`、`downstream_enabler` 一起作为下游结构对比，而不是单独强调。

## 建议写法

本轮最适合支撑的论文表述如下。

模型发布的资本市场反应沿 AI 生态位置分化。上游硬件和战略暴露公司获得正向 CAR，说明市场把模型发布理解为算力和基础设施需求信号。相反，下游部署型公司在 10 到 20 天窗口呈显著负向 CAR，表明模型能力扩散可能削弱非 AI 原生应用公司的差异化租金。投资方并不随模型能力提升获得更高边际定价，`intelligence × investor` 交互项显著为负，但该结果样本较小，应作为探索性机制。

## 修订后的使用口径

主文可以优先报告三项结果。第一，下游部署型公司的 CAR[0,+20] 显著为负。第二，上游硬件和战略位置公司的 CAR[0,+20] 显著为正。第三，上游和下游方向相反，说明模型发布不是对整条 AI 链条的同向利好，而是沿生态位置重新分配预期收益。

写作时应避免把这些 broad flags 说成严格的事件特定双边关系。更稳妥的说法是，这些变量刻画公司在 AI 生态中的经济位置。`is_investor` 和 `is_owner` 更接近事件特定关系，但样本很小，只适合机制或附录。

FMR-0060 存在日期混合编码，一部分行为 `2026/3/17`，一部分行为 Excel 序列号 `46098`。回归按 `final_event_id` 聚类，因此不改变事件数和本轮估计。若后续做事件明细表，应先统一日期。

## 输出文件

- `relationship_specr_newrel_all.csv`
- `relationship_specr_newrel_summary.csv`
- `relationship_main_effect_screen.csv`
- `relationship_interaction_screen.csv`
- `relationship_subsample_screen.csv`
- `relationship_contrast_screen.csv`
- `relationship_sample_audit.md`
- `relationship_overlap_matrix.csv`
- `screened_results.md`
- `review.md`
