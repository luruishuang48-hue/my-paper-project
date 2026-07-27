# Analysis

`processed/event_firm_panel.csv` is the canonical balanced panel with 125
events and 45 NDXT securities. The regression sample excludes one
identity-contested event and uses 124 events.

The main outcome is the SPY market-model CAR over `[0,+20]`. The estimation
window is `[-200,-11]`, with at least 120 observations. QQQ, SOXX, and the
Fama-French three-factor model provide alternative benchmarks.

## Build the panel

```sh
python3 Analysis/scripts/build_event_firm_panel.py
python3 Analysis/scripts/build_abnormal_volume.py
```

The panel merges event dates, capability metrics, event labels, the complete
45×25 relationship table, daily returns, and lagged accounting controls.

## Reproduce the reported analysis

```sh
sh Analysis/scripts/run_ndxt45_full_workflow.sh
```

This entry point rebuilds sensitivity variants, position regressions,
pairwise contrasts, time interactions, capability estimates, competitor
checks, non-overlapping designs, calendar-time portfolios, the paper figure,
and the validation report.

Successful validation is recorded in
`Analysis/reproduction/validation.json`.
