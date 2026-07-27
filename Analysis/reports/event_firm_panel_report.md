# Event-firm panel report

Generated at 2026-07-27T17:06:59.

## Scope

- Rows: 5625
- Events: 125
- Tickers: 45
- NDXT45 rows: 5625
- SOX robustness rows: 2000

## Main outputs

- `Analysis/processed/event_firm_panel.csv`
- `Analysis/processed/event_firm_panel_ndxt45.csv`
- `Analysis/processed/event_firm_panel_sox_robustness.csv`

## CAR construction

- Return input uses adjusted-close simple returns from `CAR/processed/returns_daily_long.csv`.
- Market-model estimation window is [-200,-11].
- Minimum estimation observations are 120.
- Main benchmark is SPY. The firm sample is the official NDXT constituent basket; QQQ, SOXX and FF3 provide alternative benchmarks.
- Event AIT-2026-02-006 carries `event_excluded_identity=True` (decision D1); exclude it from the main regression sample.
- Event-level AA capability metrics are merged from `事件集筛选/processed/event_aa_metrics.csv` (flagship representative per event).
- FF3 CAR uses Mkt-RF, SMB, HML and RF from `CAR/processed/ff3_daily.csv`.
- CAR windows include pre [-10,-2], symmetric windows [-1,+1], [-3,+3], [-5,+5], and forward windows [0,+0], [0,+1], [0,+2], [0,+3], [0,+5], [0,+10], [0,+15], [0,+20].

## Financial merge

- Lagged as-of merge: only statements disclosed before the event date are used.
- Availability date = fiscal period end + 45 days (10-Q filing lag); the most recent available statement is matched.
- Statements older than 400 days (period end to event date) are treated as missing; the cap accommodates semiannual reporters (CCEP, FER).
- `fund_staleness_days` records the age of the matched statement.

## Control variables

- `momentum`: cumulative simple return over trading days [-252,-21] before the event (12-month momentum, min 120 obs).
- `volatility`: annualized std of daily returns over the estimation window [-200,-11].
- `negative_equity`: stockholders' equity < 0 (buyback-driven). For these rows `bm_ratio` is set to missing; the raw value is kept in `bm_ratio_raw`.

## Coverage

- `car_mm_qqq_0_20` nonmissing: 5519
- `car_ff3_0_20` nonmissing: 5519
- `total_assets_usd` nonmissing: 5592
- `bm_ratio` nonmissing: 5341
- `momentum` nonmissing: 5517
- `volatility` nonmissing: 5519

See `Analysis/reports/event_firm_panel_coverage.csv` for sample-level details.
