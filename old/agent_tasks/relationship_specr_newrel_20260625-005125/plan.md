# Multi-agent execution plan

Task timestamp: 20260625-005125 Beijing time

## Objective

Run a fresh relationship-focused specification curve using the new relationship coding in `data/panel/specr_rel_clean.csv`. The goal is to screen regression results that help the paper's relationship mechanism, not to re-estimate the old AA Intelligence headline.

## Data scope

Only use these current panel files as needed:

- `data/panel/specr_rel_clean.csv`
- `data/panel/specr_input_clean.csv`
- `data/panel/clean_event_firm_panel.csv`

Primary input for this task is `data/panel/specr_rel_clean.csv`.

Ignore old `output/data`, historical result tables, and archived relationship files except for context checks that do not enter estimation.

## Relationship variables

Main new relationship variables:

- `upstream_hardware`
- `upstream_cloud`
- `downstream_integrator`
- `downstream_deployer`
- `downstream_enabler`
- `competitor`
- `is_investor`
- `is_owner`

Derived bundles:

- `any_relationship`
- `upstream_any`
- `downstream_any`
- `strategic_any`
- `appropriable_any`
- `non_ai_deployer_only`

## Planned specification families

1. Relationship main effects

Estimate CAR on one relationship flag at a time, with and without controls, year fixed effects, and AA Intelligence controls.

2. Relationship plus capability interactions

Estimate whether the slope on AA Intelligence changes by relationship flag. These are useful for saying which relationships turn model capability into value.

3. Relationship subsample capability slopes

Estimate AA Intelligence slopes inside each relationship-defined subsample. These results are secondary because small subsamples can be unstable.

4. Bundle and contrast regressions

Estimate upstream vs downstream, deployer vs integrator, hardware vs cloud, and strategic vs broad relationship contrasts.

## Estimation choices

- Outcomes: `car_1`, `car_2`, `car_3`, `car_10`, `car_15`, `car_20`, plus matching FF3 outcomes when available.
- Primary window: `car_20`.
- Controls: none, firm controls, firm controls plus year fixed effects.
- Firm controls: `size_log_assets`, `bm_ratio`, `volatility`, `momentum`.
- Standard errors: event-clustered CR0 using `estimatr::lm_robust` when possible.
- Minimum sample threshold: 20 observations.
- Minimum treated count for relationship main effects and interactions: 20 treated observations.

## Subagents

Use bounded parallel agents only for sidecar checks.

- Agent A reviews the new relationship variables, sample counts, overlap patterns, and potential thin-cell risks.
- Agent B reviews the final output tables and flags fragile or misleading screened results.

The main agent keeps the critical path locally: write code, run the specification curve, integrate findings, revise after review.

## Outputs

All outputs go under this task directory.

- `run_relationship_specr_newrel.R`
- `relationship_specr_newrel_all.csv`
- `relationship_specr_newrel_summary.csv`
- `relationship_interaction_screen.csv`
- `relationship_main_effect_screen.csv`
- `relationship_subsample_screen.csv`
- `relationship_contrast_screen.csv`
- `sample_overlap_report.csv`
- `screened_results.md`
- `review.md`
- `final_report.md`

## Review and revision

After running the analysis, review the screened results for:

- enough treated observations and event clusters
- consistency across CAR windows
- whether the sign is economically interpretable
- whether significance depends only on one narrow specification
- whether results duplicate the old AA Intelligence headline rather than add relationship insight

Revise the screened result list before final delivery.
