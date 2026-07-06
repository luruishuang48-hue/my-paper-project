# Event Date Reconciliation for CAR Data Collection

生成时间 2026-07-02 18:17 北京时间

## 结论

可以进入 CAR 原始数据收集阶段。`final_event_sample_main.csv` 中 125 条主样本事件全部有日度 `official_date`，没有缺失或非 `YYYY-MM-DD` 日期。CAR 计算不要直接使用 AI Timeline 的月份字段，应从 `official_date` 生成美股首个可反应交易日 `event_trading_date`。

若沿用项目旧口径中的估计窗 `[-200,-10]` 和最长事件窗 `[0,+20]`，日度收益和因子数据的严格覆盖范围应至少为 2021-06-21 到 2026-04-24。若从价格计算收益，还需要再向前多取一个交易日，建议实际拉取从 2021-06-01 到 2026-05-15，给交易日历、复权和数据源差异留缓冲。

`to_do_rebuild_regression_20260702.md` 中写的 2021-07 到 2026-04 是粗略范围。按 `[-200,-10]` 严格倒推，2021-07 起点不够覆盖最早事件的完整 200 个交易日估计窗。

## 读取文件

- `new data set/processed/final_event_sample_main.csv`
- `to_do_rebuild_regression_20260702.md`
- `new data set/reports/data_rebuild_report.md`
- `new data set/reports/date_coverage_report.md`
- `new data set/scripts/build_event_dates.py`
- `scripts/prep/specr_rel_prep.py`
- `scripts/prep/specr_rel_prep_v2.py`

未联网。

## 日期字段核对

主样本事件数为 125。关键日期字段如下。

| 字段 | 判断 |
|---|---|
| `official_date` | CAR 日期推导的唯一输入真值 |
| `official_date_all` | 多组件事件的全部日期，当前 `official_date` 取最早非空日度日期 |
| `official_date_month_candidates` | 月度候选，不进入主样本日期 |
| `date_status` | 125 条均为 `day_resolved` |
| `date_confidence` | high 104，medium 20，low 1 |
| `ai_year`、`ai_month` | 来源事件月份，不能作为事件研究日期 |

日期范围如下。

| 项 | 值 |
|---|---:|
| 事件数 | 125 |
| 唯一 `official_date` | 112 |
| 最早 `official_date` | 2022-04-06 |
| 最晚 `official_date` | 2026-03-26 |
| 年份分布 | 2022 年 3 条，2023 年 8 条，2024 年 45 条，2025 年 59 条，2026 年 10 条 |

`build_event_dates.py` 明确规定，`official_date` 记录厂商来源显示的日历日，不做时区换算。美东首个可反应交易日由下游 CAR 脚本处理。

## 需要关注的日期异常

### 非美股交易日

按 NYSE/Nasdaq 常规交易日历，以下 4 条需要从 `official_date` 顺延到下一个交易日。

| event_id | 模型 | official_date | 原日期性质 | event_trading_date |
|---|---|---:|---|---:|
| AIT-2024-11-001 | QwQ 32B Preview | 2024-11-28 | Thanksgiving | 2024-11-29 |
| AIT-2025-01-003 | R1 | 2025-01-20 | Martin Luther King Jr. Day | 2025-01-21 |
| AIT-2025-04-001 | Llama 4 | 2025-04-05 | Saturday | 2025-04-07 |
| AIT-2025-12-009 | MiniMax-M2.1 | 2025-12-20 | Saturday | 2025-12-22 |

### 多组件事件

6 条事件的 `official_date_all` 含多个日度日期。当前规则取最早组件日期作为事件日。

| event_id | 模型 | official_date | official_date_all |
|---|---|---:|---|
| AIT-2024-12-002 | SORA; o1; o1 Pro | 2024-12-05 | 2024-12-05; 2024-12-09 |
| AIT-2025-07-005 | Qwen3-235B-A22B-Instruct-2507; Qwen3-Coder | 2025-07-21 | 2025-07-21; 2025-07-22 |
| AIT-2025-12-001 | Mistral 3; Devstral 2 | 2025-12-02 | 2025-12-02; 2025-12-09 |
| AIT-2025-12-002 | GPT-5.2; GPT-Image 1.5 | 2025-12-11 | 2025-12-11; 2025-12-16 |
| AIT-2026-02-001 | Claude Opus 4.6; Claude Sonnet 4.6 | 2026-02-05 | 2026-02-05; 2026-02-17 |
| AIT-2026-03-002 | GPT-5.4; GPT-5.4 mini; GPT-5.4 nano | 2026-03-05 | 2026-03-05; 2026-03-17 |

这个规则可复现，但经济含义是“同一事件最早可反应日”。如果后续把不同组件拆成独立事件，需要重新生成事件集。

### 跨 AI Timeline 月份

2 条事件的 `official_date` 与 `ai_month` 不在同一月份。

| event_id | 模型 | ai_month | official_date | 置信度 | 说明 |
|---|---|---|---:|---|---|
| AIT-2025-04-007 | Runway Gen-4; Vidu Q1; Kling 2.0 | April 2025 | 2025-03-31 | medium | 多视频事件按最早组件日期处理 |
| AIT-2026-02-006 | Grok 4.20 | February 2026 | 2026-03-10 | low | 事件身份与日期来源不完全一致，建议 CAR 前单独复核或做剔除稳健性 |

### 同日多事件

共有 12 个 `official_date` 对应多条事件。它们不是数据错误，但会造成同一事件日上多个 AI 发布冲击重叠。回归阶段至少应保留 `event_id`，不要仅按日期合并事件。

## 交易日映射规则

建议在 CAR 脚本中生成以下字段。

| 字段 | 含义 |
|---|---|
| `official_date` | 事件样本原始官方日历日 |
| `event_trading_date` | 美股首个可反应交易日，CAR 的 t=0 |
| `official_date_is_trading_day` | `official_date` 是否为 NYSE/Nasdaq 交易日 |
| `date_roll_rule` | `same_day`、`next_trading_day_nonmarket`、`next_trading_day_after_close`、`manual_review` |
| `release_time_status` | `known_pre_open`、`known_intraday`、`known_after_close`、`unknown` |
| `date_review_flag` | 是否需要人工复核 |

推荐规则如下。

1. 交易日历使用 NYSE/Nasdaq 常规日历。周末和闭市假日顺延到下一交易日。至少覆盖 New Year、MLK Day、Presidents Day、Good Friday、Memorial Day、Juneteenth、Independence Day、Labor Day、Thanksgiving、Christmas，以及 2025-01-09 Carter mourning closure。
2. 有精确发布时间时，盘前和盘中发布取当日，盘后发布取下一交易日。盘后阈值建议用美东 16:00。
3. 无精确发布时间时，若 `official_date` 是交易日，默认 `event_trading_date = official_date`，并把 `release_time_status` 标为 `unknown`。不要在没有证据时主动后移。
4. 中国或亚洲厂商的北京时间日期不回推到前一美东日。`date_coverage_report.md` 已说明，北京白天发布通常对应美东前一日晚间，首个美股可反应交易日通常就是北京日期当天。除非有明确时间戳证明美股已经可在前一交易日反应，否则仍按 `official_date` 到交易日历映射。
5. `official_date_all` 含多个日期时，主口径继续用最早组件日期。可另设稳健性用主组件日期或最大日期，但这属于事件定义变化，不应混入主 CAR 脚本。

## CAR 数据覆盖范围

本轮 To Do 指定 CAR 窗口为 `pre/1/2/3/5/10/15/20`。旧预处理脚本显示，`car_pre` 对应市场模型异常收益 `[-10,-2]`，旧写作说明使用估计窗 `[-200,-10]`。据此推导如下。

| 项 | 日期 |
|---|---:|
| 最早 `event_trading_date` | 2022-04-06 |
| 最晚 `event_trading_date` | 2026-03-26 |
| 估计窗最早需要日，t-200 | 2021-06-21 |
| 最长事件窗最后需要日，t+20 | 2026-04-24 |
| 若从价格算收益，建议最早价格日 | 不晚于 2021-06-18 |
| 建议实际拉取范围 | 2021-06-01 到 2026-05-15 |

需要同一日期范围的数据。

- 股票日度复权价格或日收益。若只拿价格，必须能得到 adjusted close。
- 市场基准日收益。主口径建议固定一个，如 QQQ 或 SPY，并把另一个作为稳健性。
- Fama-French 3 因子日度数据。FF3 日期应与交易日窗口对齐。
- SOX/SOXX 稳健性样本若需要同日计算，也使用同一覆盖范围。

## 对 CAR 脚本的最低要求

1. 从 `official_date` 生成 `event_trading_date`，不要覆盖原字段。
2. 先对每个 ticker 生成完整交易日收益序列，再按 `event_trading_date` 切窗。
3. 每个事件和 ticker 都检查 t-200 到 t+20 是否可用。
4. 缺少估计窗、缺少事件窗或停牌缺口较大的组合应写入缺失报告，不应静默丢弃。
5. 对 AIT-2026-02-006 另加 `date_review_flag = true`。主样本可以先保留，但稳健性应测试剔除。

## 任务状态

事件日期字段已核对。生成 CAR 的日期范围和交易日映射规则已经明确。下一步可以据此生成 `event_trading_date` 表和 ticker × date 拉数清单。
