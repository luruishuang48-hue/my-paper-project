# 计量稳健性试跑结论

任务时间 20260613-210000，北京时间。

## 做了什么

本轮新增了一个独立脚本 `run_econometric_robustness.R`。脚本以 `output/data/clean_event_firm_panel.csv` 为底表，再从 `output/data/specr_rel_clean.csv` 并入关系变量。所有输出都写入 `agent_tasks/econometric_robustness_20260613-210000/`，没有覆盖原始数据和既有主结果。

本轮完成了以下检验。

- 加入 firm fixed effects。
- 报告 event cluster、firm cluster 和 event firm two-way cluster。
- 用 FF3 CAR[0,+20] 替代市场模型 CAR。
- 用 pre-event CAR 检查提前定价。
- 做事件层聚合回归。
- 做 leave-one-creator-out。
- 做美国交易标的粗口径检验。
- 做 20 个自然日窗口重叠诊断。

受现有数据限制，严格 placebo event date 没有做。当前面板只有既定事件窗口 CAR，没有非事件日的日收益序列。若要把事件日提前 30 个交易日或随机换成同季度非事件日，需要回到底层日收益、市场收益和因子数据重新算 CAR。

## 核心结果

### 1. 加 firm FE 后，主结论没有消失

全样本加入 firm FE 后，`intel_c` 系数为 0.001537，event-cluster p 值为 0.0258。two-way cluster 下 p 值为 0.0520，变成 10% 边际。

闭源样本加入 firm FE 后，`intel_c` 系数为 0.002260。event-cluster p 值为 0.0010，firm-cluster p 值为 0.0018，two-way cluster p 值为 0.0138。

这对论文是好消息。它说明闭源能力定价结果不是由公司间长期差异、公司规模层级或固定 AI 暴露差异机械带出来的。

### 2. 开源交互在 firm FE 下仍为负

加入 firm FE 后，闭源基准斜率为 0.002281，event-cluster p 值为 0.0005。`intel_c × is_open_weight` 的系数为 -0.003658，event-cluster p 值为 0.0031，two-way cluster p 值为 0.0067。

这个结果方向支持可占有性机制。不过主文仍应保守，因为此前 CR2 和 wild bootstrap 显示开源交互在小聚类修正下更脆弱。最稳的写法仍是 open-source releases attenuate the capability-pricing slope。

### 3. FF3 CAR 支持方向，但闭源量级变小

用 FF3 CAR[0,+20] 替代市场模型 CAR 后，全样本系数为 0.001018，event-cluster p 值为 0.0254。闭源样本系数为 0.001176，p 值为 0.0274。

这说明能力定价不是市场模型异常收益的产物。闭源结果仍成立，但量级比市场模型小。论文可把 FF3 放入附录稳健性表。

### 4. 发布前 CAR 没有显著预测

用 pre-event CAR 作为因变量时，全样本系数为 0.000155，p 值为 0.576。闭源样本系数为 0.000474，p 值为 0.119。

这对论文很重要。它缓解了提前定价或信息泄露的担忧。闭源样本的发布前系数为正但不显著，主文应写成 no strong evidence of pre-event run-up，不要说完全排除提前定价。

### 5. 事件层聚合给出混合结果

按事件聚合所有公司平均 CAR 后，全样本事件层系数为 0.000987，p 值为 0.120，不显著。闭源事件层系数为 0.001715，p 值为 0.0165，显著。

按有显性关系的公司聚合后，全样本和闭源样本都不显著。闭源相关公司均值的系数为 0.001420，p 值为 0.178。

这个结果很有信息量。它支持闭源机制，但也提示论文不要把结果写成仅由显性关系公司驱动。当前结果更像市场对广义 AI 暴露股票池的重估，而不是只对 owner、investor、cloud、upstream、downstream 或 competitor 等显性关系公司重估。

### 6. 剔除主要 creator 后，闭源结果总体稳

闭源样本逐一剔除主要发布者后，系数仍为正。剔除 Google 后系数为 0.002039，p 值为 0.0148。剔除 OpenAI 后系数为 0.004262，p 值小于 0.001。剔除 Anthropic 后系数为 0.001980，p 值为 0.0038。剔除 Alibaba 后系数为 0.002148，p 值为 0.0013。

这说明闭源主结果不是单个 creator 独自驱动。全样本 leave-one-creator-out 较弱一些，剔除 OpenAI、Anthropic、Microsoft 等以后有些规格只剩 10% 边际或不显著。这再次说明主文应以闭源样本为中心。

### 7. 美国交易标的粗口径下结果仍在

用无交易所后缀的 ticker 粗略识别美国交易标的后，全样本 firm FE 系数为 0.001932，p 值为 0.0195。闭源样本系数为 0.002709，p 值为 0.0006。

这个结果可以作为附录检验，但不能直接写成精确美国上市公司样本。因为当前没有正式 exchange country 字段，这只是规则近似。

### 8. 事件窗口重叠很严重

47 个 intelligence 事件中，只有 4 个事件在前后 20 个自然日内没有其他 intelligence 事件。中位数事件在前后 20 个自然日内有 3 个其他事件，最大值为 6 个。

这意味着不能简单剔除所有重叠事件，否则样本几乎没有了。主文应承认 AI 模型发布在 2025 年高度密集，CAR[0,+20] 捕捉的是市场对连续技术发布环境下能力信息的重估。若要严格处理重叠，需要回到底层日收益层面，构造 calendar-time 或多事件控制。

## 对论文的含义

本轮结果增强了闭源能力定价这条主线。加入 firm FE、two-way cluster、FF3 CAR、pre-event CAR 和 leave-one-creator-out 后，闭源结果总体仍然成立。最适合进主文的新增结果是 firm FE 和 pre-event CAR。事件层聚合也值得放，但应谨慎解释，因为只有闭源全体公司均值显著，显性关系公司均值不显著。

本轮结果也提醒不要写太强。全样本在 two-way cluster 下只是边际。事件层全样本不显著。显性关系公司聚合不显著。窗口重叠很严重。开源交互方向稳，但仍受 11 个开源事件的小样本限制。

## 建议进主文的内容

主文可加一句。

The closed-source capability slope remains positive after adding firm fixed effects and is not present in pre-event CARs.

主表可以新增一列 firm FE closed-source。附录放完整稳健性表，包含 market-model CAR、FF3 CAR、pre-event CAR、event-level aggregation 和 leave-one-creator-out。

## 建议不要进主文的内容

不要在主文强调 two-way cluster 的全样本结果。它只有边际意义，而且两维聚类在当前包实现中有少量非正定警告。

不要在主文强调有显性关系公司聚合结果。它不显著，容易引出新的解释负担。

不要声称已经做了严格 placebo event date。现有数据不支持这个检验。

不要声称已经解决窗口重叠。当前只是诊断出重叠严重。

## 下一步若继续推进

下一步最有价值的是回到底层日收益，补两个检验。

第一，构造 placebo event dates。把事件日前移 30 个交易日，或在同季度随机抽非事件日，重新估计 CAR。

第二，处理重叠事件。可按发布日期聚类、合并同日同 creator 事件，或用日度收益面板做 calendar-time regression。

这两步比继续加异质性更能提高 FRL 送审可信度。
