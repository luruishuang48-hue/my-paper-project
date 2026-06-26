# R5 Status: Wild Cluster Bootstrap Inference Check

**Status**: Complete. Script ran to completion with no errors (only routine
R warnings from the bootstrap/regression calls, visible in the console log).

## What was run

Re-estimated the key position-variable coefficients from Tables 1-4
(CAR[0,+20], market-model) under three inference methods side by side:
CR0 cluster-robust SE, CR2 (bias-adjusted) cluster-robust SE, and a wild
cluster bootstrap (clustered on `final_event_id`, 60 clusters), to check
whether significance survives the strictest small-cluster-robust method.
Covered four table contexts:

- `baseline_single`: the 6 single-position regressions (upstream_hardware,
  upstream_cloud, downstream_integrator, downstream_deployer,
  downstream_enabler, competitor)
- `bundle`: the 2 collapsed-category regressions (upstream_any,
  downstream_any)
- `joint`: all 6 position variables entered simultaneously in one
  regression
- `open_interaction`: the 2 open-weight interaction terms
  (upstream_hardware:is_open_weight, downstream_deployer:is_open_weight)

Sample: N = 4,829 firm-event observations, 60 events, consistent across all
16 rows.

**Correction (post-review)**: the original run computed `n_events` via a
buggy positional index into row names (`as.integer(rownames(mf))`), which
mis-clustered to 61 instead of the correct 60. Fixed in
`scripts/r5_wild_bootstrap_core_tables.R` and the script was re-run; all
beta/SE/p-values are unchanged (deterministic, same seed=42), only the
`n_events` column was corrected from 61 to 60 in the CSV.

## Outputs

- `outputs/r5_wild_bootstrap_table1to4.csv` — full 16-row results table
  (beta, se, p_cr0, p_cr2, p_wild, n, n_events for every variable/context)
- `outputs/r5_wild_bootstrap_summary.md` — plain-language write-up of the
  results, with per-context tables and an overall conclusion
- `logs/r5_run_console.log` — full R console log from the run (confirms
  no errors; standard R warnings only)

## Key conclusion

`downstream_deployer` is significant (p_wild = 0 or < 0.0002) in all four
table contexts and under all three inference methods — the most robust
result in the set. `upstream_hardware` is robust in the baseline, bundle,
and open-weight interaction contexts, but loses significance in the joint
model (p_cr0 = 0.55, p_wild = 0.64, sign flips negative) once the other
five position variables are controlled for simultaneously. Full detail in
`outputs/r5_wild_bootstrap_summary.md`.
