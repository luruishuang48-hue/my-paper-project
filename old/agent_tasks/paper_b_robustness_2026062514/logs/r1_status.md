# R1 status log: upstream_hardware vs upstream_cloud Wald test

**Task**: Formal difference test (joint regression + Wald-style z-test) for
whether `upstream_hardware` and `upstream_cloud` have distinguishable effects
on CAR, replacing the previous eyeballed comparison from separate
single-variable regressions.

## What was run

- Environment check: `Rscript -e 'library(estimatr); library(tidyverse)'` —
  OK, both packages available, no environment issues.
- Data: `data/panel/specr_rel_clean.csv` (5,160 rows), used ONLY new 8-dim
  columns `upstream_hardware`, `upstream_cloud` (+ controls + `final_event_id`
  + `release_year`). Did not touch old-schema columns (owner, investor,
  cloud, real_upstream, business_upstream, real_downstream,
  business_downstream).
- For each of `car_10`, `car_15`, `car_20`: filtered to non-missing rows on
  outcome + all RHS vars, fit
  `car ~ upstream_hardware + upstream_cloud + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)`
  via `estimatr::lm_robust(..., clusters = final_event_id, se_type = "CR0")`.
  Computed `diff = beta_hardware - beta_cloud`,
  `var_diff = Var(b_hw) + Var(b_cloud) - 2*Cov(b_hw,b_cloud)` from `vcov(mod)`,
  `se_diff = sqrt(var_diff)`, `z = diff/se_diff`, two-sided
  `p = 2*pnorm(abs(z), lower.tail=FALSE)`.
- Sample is stable across all three windows: n = 4,829, 60 unique
  `final_event_id` clusters (matches the plan's documented baseline sample
  size).

## Issues encountered

None. Script ran cleanly on first execution after a minor wording fix to the
markdown summary prose (no numerical changes).

## Final results (car_20, the primary window)

- beta_hardware = 0.0237 (SE 0.0086), beta_cloud = 0.0161 (SE 0.0069)
- diff = 0.0076, se_diff = 0.0073, z = 1.040
- **p_value = 0.2984** — NOT statistically significant at 5% (or even 10%)

Full table (car_10 / car_15 / car_20): p = 0.580 / 0.776 / 0.298 respectively.
Sign of the hardware-cloud gap is not even stable across windows (negative at
car_10/car_15, positive at car_20), and none of the three differences are
significant.

## Conclusion vs. prior qualitative claim

`review_regressions_summary.md` (the `relonly_regression` discussion) claimed
the upstream effect is "driven almost entirely by hardware (cloud weak/n.s.)"
based on separate single-variable regressions. The formal joint-model test
**does not confirm this as statistically distinguishable** — the point
estimates differ descriptively (and point the claimed direction at car_20),
but the hardware-cloud gap is statistically indistinguishable from zero at
all three windows. This should be flagged as a downgrade from "robust
heterogeneity" to "suggestive but not formally significant" in any writeup
that cites this comparison.

## Outputs produced

- `agent_tasks/paper_b_robustness_2026062514/scripts/r1_hardware_cloud_wald_test.R`
- `agent_tasks/paper_b_robustness_2026062514/outputs/r1_hardware_vs_cloud_diff.csv`
- `agent_tasks/paper_b_robustness_2026062514/outputs/r1_hardware_vs_cloud_diff.md`
- `agent_tasks/paper_b_robustness_2026062514/logs/r1_status_run.log` (raw console capture)
