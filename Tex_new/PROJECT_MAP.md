# Current manuscript and data map

The only active manuscript is `frl_three_results.tex`. Its online appendix is
`frl_three_results_online_appendix.tex`.

## Dependency chain

1. `事件集筛选/` builds 125 day-verified release events and event capability
   metrics.
2. `企业列表/` builds the official 45-security NDXT universe.
3. `事件标签/` and `关系标签/` validate the two independent coding exercises
   and their adjudicated tables.
4. `CAR/` and `Fundamentals/` rebuild daily returns, factors, benchmarks, and
   accounting controls from local source snapshots.
5. `Analysis/scripts/build_event_firm_panel.py` creates the 5,625-row balanced
   event-firm panel.
6. `Analysis/scripts/run_ndxt45_full_workflow.sh` reproduces all reported
   regressions, checks, and the figure.
7. `run_reproduction.sh` executes the full chain, validates it, and compiles
   both PDFs.

## Canonical decision tables

All hand-verified inputs are in `事件集筛选/decisions/`.

- `entity_decisions.csv`
- `date_decisions.csv`
- `firm_universe_decisions.csv`
- `relationship_decisions.csv`
- `event_label_decisions.csv`
- `analysis_design_decisions.md`

Older manuscripts, alternative samples, exploratory analyses, and internal
reviews are stored locally in `history/` and are excluded from the public
repository.
