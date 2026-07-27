# Market-return inputs

This directory contains the daily data used to construct abnormal returns.
The sample contains 45 securities from the May 1, 2026 NDXT snapshot and
seven benchmark series.

## Source snapshots

- `raw/yahoo_chart_json/` contains 45 stock files and 7 benchmark files.
- `raw/factors/` contains the Fama-French daily three-factor data.

The builder reads local snapshots first. It downloads a source only when the
corresponding cache is missing.

## Reproduction

```sh
python3 CAR/scripts/fetch_car_inputs.py
python3 CAR/scripts/validate_car_inputs.py
```

The scripts create standardized prices, returns, event trading-day mappings,
factor data, and coverage diagnostics. The market-model estimation window is
`[-200,-11]`, and the longest event window is `[0,+20]`.
