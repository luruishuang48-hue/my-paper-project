# Analysis 母表说明

本文件夹保存事件-公司层面的可回归母表。当前版本先解决合并问题，每行是一条 `event_id × ticker`。

## 主输出

- `processed/event_firm_panel.csv`
  全样本母表，125 个事件 × 108 家公司，共 13500 行。
- `processed/event_firm_panel_main_nasdaq100.csv`
  Nasdaq-100 主样本，共 12625 行。
- `processed/event_firm_panel_sox_robustness.csv`
  SOX/SOXX 稳健性样本，共 3125 行。

## 已接入内容

- 事件信息来自 `CAR/metadata/event_dates_with_trading_day.csv`。
- 公司池和样本标签来自 `CAR/metadata/firm_universe_for_car.csv`。
- CAR 从 `CAR/processed/returns_daily_long.csv` 重新计算。
- FF3 CAR 使用 `CAR/processed/ff3_daily.csv`。
- 财务变量来自 `Fundamentals/processed/fundamentals_quarterly_wide.csv`。

## CAR 口径

- 收益率使用 adjusted close 简单收益。
- 市场模型估计窗为 `[-200,-10]`。
- 最少估计窗观测数为 120。
- 主基准为 `QQQ`。
- 稳健性基准包括 `SPY` 和 `SOXX`。
- FF3 口径也已生成。
- 事件窗口包括 `pre_m10_m2`、`m1_p1`、`m3_p3`、`m5_p5`、`0_0`、`0_1`、`0_2`、`0_3`、`0_5`、`0_10`、`0_15`、`0_20`。

核心因变量建议先用 `car_mm_qqq_0_20`。若需要更严格的价格覆盖规则，可筛选 `car_ready_max_window == True`。

## 财务变量口径

本版按事件交易日所在日历季度合并财务变量，暂时不处理财报披露滞后。这是按照当前任务要求先解决母表合并，下一步再替换成事件日前可得财报。

主要控制变量包括：

- `size_log_assets`
- `bm_ratio`
- `leverage`
- `total_assets_usd`
- `stockholders_equity_usd`
- `quarter_end_market_cap_usd`

## 当前覆盖

- 全样本行数为 13500。
- `car_mm_qqq_0_20` 非缺失 13173 行。
- `car_ff3_0_20` 非缺失 13173 行。
- `total_assets_usd` 非缺失 13348 行。
- `bm_ratio` 非缺失 13189 行。
- 公司-事件无重复行。

更细覆盖率见 `reports/event_firm_panel_coverage.csv`、`reports/event_firm_panel_ticker_coverage.csv` 和 `reports/event_firm_panel_event_coverage.csv`。

## 复现

运行 `scripts/build_event_firm_panel.py` 可重新生成全部母表和覆盖率报告。
