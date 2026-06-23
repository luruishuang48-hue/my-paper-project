# 稳健性检验数据结构复核

复核时间 2026-06-13 21:01，北京时间。

复核范围包括 `output/data/specr_rel_clean.csv`、`output/data/specr_input_clean.csv`、`output/data/clean_event_firm_panel.csv`、`output/tables/data_dictionary.csv`、`reports/cleaning_report.md` 和 `task/agent_tasks/merge_regression_202606110558/merge_summary.md`。本次只读文件，没有修改项目主文件和原始数据。

## 核心结论

核心回归和新增稳健性检验，建议以 `output/data/clean_event_firm_panel.csv` 作为底表。这个文件已经去掉空行，日期统一为 ISO 格式，市场模型 CAR 和 FF3 CAR 字段也已改成清晰变量名。若检验需要关系变量，应从 `output/data/specr_rel_clean.csv` 按 `final_event_id` 和 `company_id` 并入 8 个关系哑变量。

不建议直接把 `specr_input_clean.csv` 作为新稳健性底表。它保留了重复 CAR 字段的旧命名，`relationship` 为空，也有一条空行。不建议直接把 `specr_rel_clean.csv` 作为唯一底表。它有关系变量，但多一条空键行，日期仍有 Excel serial 值，字段命名不如清洗面板稳定。

实测显示，`clean_event_firm_panel.csv` 与 `specr_rel_clean.csv` 非空键行可以无损合并。5160 行全部匹配，市场模型 `mkt_car_20` 与关系版 `car_20` 完全一致，`mkt_car_pre` 与 `car_pre` 完全一致，`ff3_car_20` 和 FF3 pre 窗口也完全一致。

## 三个数据文件口径

| 文件 | 行列 | 事件数 | 公司数 | 主要用途 | 主要问题 |
|---|---:|---:|---:|---|---|
| `clean_event_firm_panel.csv` | 5160 × 107 | 60 | 86 | 新稳健性检验底表 | 缺少 owner、investor、cloud 等关系哑变量 |
| `specr_rel_clean.csv` | 5161 × 84 | 60 | 86 | 现有主回归和异质性脚本使用 | 多一条空键行，日期未完全规范，字段名有旧口径 |
| `specr_input_clean.csv` | 5161 × 106 | 60 | 86 | 现有规格曲线脚本使用 | 多一条空键行，`relationship` 为空，重复 CAR 字段命名不清 |

`reports/cleaning_report.md` 说明 `clean_event_firm_panel.csv` 是清洗后的平衡事件 公司面板。它覆盖 60 个事件和 86 家公司，没有重复的事件 公司键。`task/agent_tasks/merge_regression_202606110558/merge_summary.md` 说明关系编码已 100% 匹配到事件 公司面板，并新增了 8 个关系变量。

## 关键字段可用性

| 口径 | 推荐字段 | 可用性 | 说明 |
|---|---|---|---|
| event id | `final_event_id` | 可用 | 三个文件都有。清洗面板无缺失。 |
| firm id | `company_id` | 可用 | 三个文件都有。它是最稳的公司键，也承担 ticker 功能。 |
| 公司名称 | `company` | 可用 | 三个文件都有，可用于展示和 Mag7 等手工分组。 |
| creator | `true_model_creator` | 可用 | 三个文件都有。清洗面板有 14 个 creator。 |
| creator 类型 | `creator_type` | 可用 | 可做 listed US creator 等子样本。 |
| open-weight | `is_open_weight_or_open_source` 或 `is_open_weight` | 可用 | 清洗面板和规格曲线文件用前者，关系版用后者。建议统一为 `is_open_weight_or_open_source`。 |
| AA Intelligence | `aa_intelligence_index` | 可用 | 4042 行，47 个事件。闭源样本 3096 行，36 个事件。开放权重样本 946 行，11 个事件。 |
| CAR[0,+20] | `mkt_car_20` | 可用 | 清洗面板推荐用这个字段。关系版和规格曲线文件中对应 `car_20`。 |
| pre-event CAR | `mkt_car_pre` | 可用 | 对应市场模型 CAR[-10,-2]。关系版和规格曲线文件中对应 `car_pre`。 |
| FF3 CAR | `ff3_car_1` 至 `ff3_car_20`，`ff3_car_pre` | 可用 | 清洗面板字段最清楚。关系版的 FF3 pre 字段名是中文 `FF3异常收益[-10,-2]`。 |
| 关系变量 | `owner`、`investor`、`cloud`、`business_upstream`、`real_upstream`、`business_downstream`、`real_downstream`、`competitor` | 可用但需合并 | 只在 `specr_rel_clean.csv` 中可直接使用。可无损合并到清洗面板。 |
| ticker | `company_id` | 基本可用 | 含 AAPL、MSFT 等美股 ticker，也含 `005930 KS`、`700 HK` 等带交易所后缀代码。 |
| 潜在美股暴露 ticker | `possible_us_exposed_tickers` | 可用但不是 firm ticker | 这是事件层潜在暴露字段，不是公司层标识，不能替代 `company_id`。 |
| 搜索代码 | `search_code_1` 或 `搜索代码1` | 可用但不建议建模 | 它是检索拼接字段，不适合作为 firm id 或 ticker。 |

## 关系变量现状

`specr_rel_clean.csv` 中 8 个关系哑变量都有 0/1 取值。去掉空键行后可以直接并入清洗面板。当前 60 个事件内的取值数量如下。

| 变量 | 取值为 1 的观测数 | 判断 |
|---|---:|---|
| `owner` | 29 | 可做交互，但小样本风险高 |
| `investor` | 37 | 可做交互，但小样本风险高 |
| `cloud` | 29 | 可做交互，但小样本风险高 |
| `business_upstream` | 156 | 可做异质性检验 |
| `real_upstream` | 126 | 可做异质性检验 |
| `business_downstream` | 1440 | 可做异质性检验 |
| `real_downstream` | 81 | 可做异质性检验，但样本较小 |
| `competitor` | 462 | 可做异质性检验 |

`relationship` 这个旧字段在 `clean_event_firm_panel.csv` 和 `specr_input_clean.csv` 中为空，不应继续使用。关系分析应使用 8 个明确哑变量。

## 可以直接做的检验

1. firm fixed effects。

   数据具备 `company_id`、`final_event_id`、AA Intelligence、CAR 和控制变量。不能加 event fixed effects，因为 AA Intelligence 是事件层变量，会被事件固定效应吸收。可以加 firm fixed effects 和 year fixed effects。

2. event-level aggregated CAR 回归。

   可以直接按 `final_event_id` 聚合 `mkt_car_20`、`ff3_car_20`、`mkt_car_pre`。聚合方式可做 equal-weighted，也可用关系变量筛选或加权。事件层解释变量包括 `aa_intelligence_index`、`is_open_weight_or_open_source`、`true_model_creator`、`creator_type`。

3. pre-event CAR 检验。

   可用 `mkt_car_pre` 和 `ff3_car_pre`。这可以检验发布前是否已经存在和能力指标相关的收益变化。

4. FF3 CAR 稳健性。

   可用 `ff3_car_1`、`ff3_car_2`、`ff3_car_3`、`ff3_car_5`、`ff3_car_10`、`ff3_car_15`、`ff3_car_20`。建议优先复刻主结果的 `ff3_car_20`。

5. leave-one-creator-out。

   可用 `true_model_creator` 逐一剔除 creator。AA Intelligence 样本覆盖 14 个 creator，其中 47 个事件可进入 LLM 能力样本。

6. open-weight 与 closed-source 子样本。

   可用 `is_open_weight_or_open_source`。AA Intelligence 样本中闭源 36 个事件，开放权重 11 个事件。开放权重样本事件数少，推断需保守。

7. 关系变量异质性。

   可从 `specr_rel_clean.csv` 并入关系变量后做。建议对 `owner`、`investor`、`cloud` 这类稀疏变量使用交互项而不是单独子样本。`business_downstream` 和 `competitor` 更适合单独子样本或交互检验。

8. cluster 口径稳健性。

   数据支持 event cluster、firm cluster 和 event firm two-way cluster。实现取决于 R 包或 Python 包，但数据结构本身没有障碍。

9. 事件窗口重叠诊断。

   `release_date` 已可用，可按事件日期计算相邻事件间距。可以标记前后 20 个交易日或自然日附近是否有其他模型发布。不过若要严格按交易日判断，需要交易日历。

## 不能直接做或需要补充的检验

1. placebo event date。

   不能仅凭这三个面板文件直接做。当前文件只有既定事件窗口 CAR，没有非事件日的日收益或可重新计算 CAR 的原始收益序列。若要把事件日前移 30 个交易日或随机抽同季度非事件日，需要原始日收益、市场收益和因子数据。

2. 严格的窗口重叠剔除。

   可以做自然日近似版，但严格交易日版需要交易日历。若还要重新剔除重叠窗口内的收益污染，最好回到日收益层面。

3. 美国交易标的精确子样本。

   `company_id` 可以粗略识别。无空格的代码多为美股或 ADR，带 `KS`、`HK`、`JP`、`TT`、`LN` 等后缀多为海外交易标的。但当前没有单独的 `is_us_listed_firm` 或 `exchange_country` 字段。若要严谨做美国交易标的样本，需要补一个交易所或上市地字段。

4. 事件级别能力变化或 surprise 检验。

   `aa_intelligence_index` 是代表模型能力水平，不是相对前代的能力增量，也不是市场预期外 surprise。若要做 surprise，需要为每个 creator 或模型家族构造前代能力基准，或加入发布前市场预期代理。

5. 关系编码证据审计。

   当前面板有关系变量和 notes，但如果审稿人要求逐条证据，需要进一步整理 `task/firm_model_relationships.csv` 或相关 evidence 文件。仅靠这三个回归数据文件不足以形成可审计 appendix。

## 建议的稳健性底表构造

建议新增一个临时分析数据，不覆盖原文件。

1. 读取 `clean_event_firm_panel.csv`。
2. 从 `specr_rel_clean.csv` 删除 `final_event_id` 或 `company_id` 为空的行。
3. 按 `final_event_id` 和 `company_id` 合并 8 个关系变量及 `relationship_notes`。
4. 统一保留清洗面板字段名。市场模型 CAR 使用 `mkt_car_*`，FF3 CAR 使用 `ff3_car_*`，开放权重使用 `is_open_weight_or_open_source`。
5. 新增一个清楚的 firm ticker 字段，例如从 `company_id` 复制为 `firm_ticker_raw`，不要用 `possible_us_exposed_tickers` 替代。

## 最优先的可执行检验

最建议先做四个检验。第一，基准式加入 firm fixed effects。第二，把 CAR 聚合到事件层后重跑核心回归。第三，用 `mkt_car_pre` 和 `ff3_car_pre` 做发布前 CAR 检验。第四，逐一剔除主要 creator 做 leave-one-creator-out。

这四个检验都能直接用现有数据完成，且正好回应有效样本量、公司异质性、提前定价和 creator 集中度这几个核心审稿风险。
