# CAR 输入校验报告

## 样本规模

- 公司数：108
- 事件数：125
- event × ticker 组合数：13500
- 最大窗口可计算组合数：13094
- 最大窗口不可计算组合数：406

## 不可计算组合的主要来源

以下公司上市或可用价格起点较晚，无法覆盖早期事件的 `[-200,-10]` 估计窗。

| ticker   | company                            | price_first_date   | price_last_date   |   events_total |   events_car_ready |   events_missing | first_unready_event   |
|:---------|:-----------------------------------|:-------------------|:------------------|---------------:|-------------------:|-----------------:|:----------------------|
| ALAB     | Astera Labs                        | 2024-03-20         | 2026-04-30        |            125 |                 69 |               56 | AIT-2022-04-002       |
| ARM      | Arm Holdings                       | 2023-09-14         | 2026-04-30        |            125 |                101 |               24 | AIT-2022-04-002       |
| CEG      | Constellation Energy               | 2022-01-19         | 2026-04-30        |            125 |                123 |                2 | AIT-2022-04-002       |
| CRDO     | Credo Technology Group Holding Ltd | 2022-01-27         | 2026-04-30        |            125 |                123 |                2 | AIT-2022-04-002       |
| CRWV     | CoreWeave                          | 2025-03-28         | 2026-04-30        |            125 |                 10 |              115 | AIT-2022-04-002       |
| GEHC     | GE HealthCare                      | 2022-12-15         | 2026-04-30        |            125 |                117 |                8 | AIT-2022-04-002       |
| NBIS     | Nebius Group                       | 2024-10-21         | 2026-04-30        |            125 |                 34 |               91 | AIT-2022-04-002       |
| SNDK     | Sandisk                            | 2025-02-13         | 2026-04-30        |            125 |                 17 |              108 | AIT-2022-04-002       |

## 基准和 FF3 对齐

- SPY 交易日缺少 FF3 因子日期数：0
- FF3 因子日期不在 SPY 交易日数：0

## 生成文件

- `CAR/reports/event_ticker_car_readiness.csv`
- `CAR/reports/car_readiness_by_ticker.csv`
- `CAR/reports/benchmark_coverage.csv`
- `CAR/reports/factor_market_date_alignment.csv`
