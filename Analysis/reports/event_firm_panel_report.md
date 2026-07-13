# Event-firm panel report

Generated at 2026-07-13T16:02:57.

## Scope

- Rows: 13500
- Events: 125
- Tickers: 108
- Main Nasdaq-100 rows: 12625
- SOX robustness rows: 3125

## Main outputs

- `Analysis/processed/event_firm_panel.csv`
- `Analysis/processed/event_firm_panel_main_nasdaq100.csv`
- `Analysis/processed/event_firm_panel_sox_robustness.csv`

## CAR construction

- Return input uses adjusted-close simple returns from `CAR/processed/returns_daily_long.csv`.
- Market-model estimation window is [-200,-10].
- Minimum estimation observations are 120.
- Main benchmark is SPY (decision P4, 2026-07-03: the sample is Nasdaq-100 constituents, so QQQ self-benchmarks). QQQ, SOXX and FF3 are robustness.
- Event AIT-2026-02-006 carries `event_excluded_identity=True` (decision D1); exclude it from the main regression sample.
- Event-level AA capability metrics are merged from `new data set/processed/event_aa_metrics.csv` (flagship representative per event).
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

- `car_mm_qqq_0_20` nonmissing: 13171
- `car_ff3_0_20` nonmissing: 13171
- `total_assets_usd` nonmissing: 13399
- `bm_ratio` nonmissing: 12473
- `momentum` nonmissing: 13165
- `volatility` nonmissing: 13171

See `Analysis/reports/event_firm_panel_coverage.csv` for sample-level details.
