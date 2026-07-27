# Accounting inputs

This directory builds quarterly accounting controls for the 45 NDXT
securities from 2022Q1 through 2026Q1.

Cached StockAnalysis pages provide quarterly statements. The SEC ticker file
provides CIK mappings, Yahoo exchange-rate snapshots convert non-USD
statements, and daily prices from `CAR/` provide quarter-end market values.

Run:

```sh
python3 Fundamentals/scripts/fetch_fundamentals.py
```

The main output is `processed/fundamentals_quarterly_wide.csv`. It includes
total assets, stockholders' equity, size, book-to-market, share-count fields,
currency conversion, and source dates. Event-panel construction applies a
45-day availability rule and matches only information available before each
release.
