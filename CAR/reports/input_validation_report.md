# CAR 输入校验报告

## 样本规模

- 公司数：45
- 事件数：125
- event × ticker 组合数：5625
- 最大窗口可计算组合数：5493
- 最大窗口不可计算组合数：132

## 不可计算组合的主要来源

以下公司上市或可用价格起点较晚，无法覆盖早期事件的 `[-200,-11]` 估计窗。

| ticker   | company      | price_first_date   | price_last_date   |   events_total |   events_car_ready |   events_missing | first_unready_event   |
|:---------|:-------------|:-------------------|:------------------|---------------:|-------------------:|-----------------:|:----------------------|
| ARM      | Arm Holdings | 2023-09-14         | 2026-04-30        |            125 |                101 |               24 | AIT-2022-04-002       |
| SNDK     | Sandisk      | 2025-02-13         | 2026-04-30        |            125 |                 17 |              108 | AIT-2022-04-002       |

## 基准和 FF3 对齐

- SPY 交易日缺少 FF3 因子日期数：0
- FF3 因子日期不在 SPY 交易日数：0

## 生成文件

- `CAR/reports/event_ticker_car_readiness.csv`
- `CAR/reports/car_readiness_by_ticker.csv`
- `CAR/reports/benchmark_coverage.csv`
- `CAR/reports/factor_market_date_alignment.csv`
