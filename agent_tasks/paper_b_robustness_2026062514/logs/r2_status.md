# Agent R2 — Status Log

**Task**: `downstream_deployer` as sole relationship regressor, all CAR windows
(car_1...car_20), CR0 + CR2 + wild cluster bootstrap (B=4999, seed=42).

**Status**: COMPLETE. Script ran successfully end-to-end via
`Rscript agent_tasks/paper_b_robustness_2026062514/scripts/r2_downstream_deployer_dedicated.R`.
Total runtime ~3.5 minutes (7 windows x ~28-32 sec wild bootstrap each).

## Files produced

- `scripts/r2_downstream_deployer_dedicated.R` — full script, includes
  `refit_cr2()` and `wild_boot_p()` copied from `scripts/analysis/core_table.R`
  (lines 62-67 and ~69-111 respectively, unmodified)
- `outputs/r2_downstream_deployer_robustness.csv` — 7 rows (one per window):
  outcome, beta, se, n, n_events, p_cr0, p_cr2, p_wild
- `outputs/r2_downstream_deployer_robustness.md` — full write-up with
  comparison to `review_regressions_summary.md` citations
- `logs/r2_run_console.log` — full console output of the run

## Key result (car_20, headline window)

beta = -0.01902, se = 0.00507, n = 4829, n_events = 60
p_CR0 = 0.000404, p_CR2 = 0.000455, p_wild = 0.000400

Matches `run_relationship_specr`'s cited number (coef -0.019, p=0.0004) almost
exactly.

## Pattern across all 7 windows

Effect is negative and significant at EVERY window (car_1 through car_20), and
strengthens monotonically in both magnitude and significance as the window
widens — from beta=-0.0034 (p~0.018-0.020) at car_1 to beta=-0.0190
(p~0.0004-0.0005) at car_20. CR0, CR2, and wild bootstrap p-values agree
closely at every window (never differ by more than ~0.002, never disagree on
significance threshold crossed). No issues encountered; no old-schema columns
used.

## Data/method notes

- Used only `downstream_deployer` (new 8-dim schema); did not touch
  `business_downstream`/`real_downstream` or other old columns.
- Sample: full data, complete cases on {y, downstream_deployer, controls},
  60 events throughout, n ranges 4809 (car_1) to 4829 (car_10/15/20).
- No deviations from the plan's specified method.
