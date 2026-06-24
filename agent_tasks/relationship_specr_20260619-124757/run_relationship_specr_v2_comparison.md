# run_relationship_specr v1 vs v2 comparison

**v1** uses `data/panel/specr_rel_clean_OLD_BACKUP.csv` (old 8-column relationship coding), outputs in `outputs/`.
**v2** uses `data/panel/specr_rel_clean.csv` (new 8-dimension relationship coding), outputs in `outputs_v2/`.

## Genuineness check

Confirmed genuine: the script uses the relationship flags in two ways — (1) as **subsample
filters** (`subsample_defs`, with `x_var = aa_intelligence_index`), and (2) as the **main
explanatory variable `x_var`** itself (`relationship_x_results`, looping over all 8 flags one
at a time). It also builds four derived composite indicators (`broad_upstream`,
`broad_downstream`, `positive_rel`, `downstream_comp`) from the raw flags. This is exactly the
specification-curve pattern the task description anticipated.

## Column mapping used in v2

| Old column | New column(s) | Notes |
|---|---|---|
| `owner` | `is_owner` | near 1:1 per codebook |
| `investor` | `is_investor` | near 1:1, new version slightly broader |
| `cloud` | `upstream_cloud` | new version much broader (covers all major cloud providers, not just direct cloud partners) |
| `business_upstream`, `real_upstream` | `upstream_hardware`, `upstream_cloud` | old 2-way split regrouped into new 2-way split along hardware vs. cloud lines (not a literal rename — semantics shifted) |
| `business_downstream`, `real_downstream` | `downstream_integrator`, `downstream_deployer`, `downstream_enabler` | old 2-way split expanded into a new 3-way split |
| `competitor` | `competitor` | same name, slightly broader, all old 1s preserved as new 1s |

Derived composites recomputed with semantically matched new flags:

- `broad_upstream` = max(`upstream_hardware`, `upstream_cloud`) — was max(`business_upstream`, `real_upstream`)
- `broad_downstream` = max(`downstream_integrator`, `downstream_deployer`, `downstream_enabler`) — was max(`business_downstream`, `real_downstream`); now unions 3 dimensions instead of 2
- `positive_rel` = max(`is_owner`, `is_investor`, `upstream_cloud`, `upstream_hardware`) — was max(`owner`, `investor`, `cloud`, `business_upstream`, `real_upstream`); `cloud` term dropped because it is now absorbed into the broader `upstream_cloud`
- `downstream_comp` = max(`downstream_integrator`, `downstream_deployer`, `downstream_enabler`, `competitor`) — was max(`business_downstream`, `real_downstream`, `competitor`)

`rel_flags` (the 8-element vector used both for subsample definitions and as the `x_vars` loop
in the relationship-as-X grid) was changed from
`c("owner","investor","cloud","business_upstream","real_upstream","business_downstream","real_downstream","competitor")`
to
`c("upstream_hardware","upstream_cloud","downstream_integrator","downstream_deployer","downstream_enabler","competitor","is_investor","is_owner")`.
Output paths were redirected to `outputs_v2/` and the Chinese auto-report header/labels were
updated; no other logic (regression model, clustering, control sets, year-FE toggle, min
obs/clusters thresholds) was changed.

## Run status

v2 ran cleanly on the first attempt (`Rscript run_relationship_specr_v2.R`), no errors. Produced
756 subsample-grid specs and 2,310 relationship-as-X specs (vs. 756 and 2,226 in v1 — the new
schema's 8 flags have somewhat different valid-observation counts than the old 8, mainly because
`downstream_integrator` and `competitor` have many more 1s than the old `real_downstream`/old
`competitor` did, generating slightly more non-degenerate specs).

## Headline numbers: full specification-curve grid

| Grid | n specs | % p<0.05 | % p<0.10 | % positive estimate |
|---|---:|---:|---:|---:|
| Subsample × aa_intelligence_index — v1 (OLD) | 756 | 15.7% | 23.9% | 60.8% |
| Subsample × aa_intelligence_index — v2 (NEW) | 756 | 12.7% | 24.5% | 62.6% |
| Relationship-flag-as-X — v1 (OLD) | 2,226 | 17.9% | 24.7% | 48.5% |
| Relationship-flag-as-X — v2 (NEW) | 2,310 | 11.4% | 18.2% | 50.7% |

**Overall shift:** moving to the new 8-dimension coding *reduces* the share of statistically
significant (p<0.05) specifications in both grids — most sharply in the relationship-as-X grid
(17.9% → 11.4%, roughly a one-third drop). The share of positive-sign estimates is essentially
unchanged (~49-51% in the X grid, ~61-63% in the subsample grid). This is consistent with the new
schema spreading what used to be concentrated, noisy old categories (e.g. old `real_downstream`,
n=81, drove a lot of the old significance) across larger, better-powered but more diluted new
categories.

## Main specification: car_20, full controls, year FE

### Relationship as subsample (X = aa_intelligence_index)

Old top hits: `business_downstream`/`broad_downstream` (p=0.050, n=1090), `all` (p=0.027),
`downstream_comp` (p=0.029), `non_us_creator` (p=0.060, marginal).

New top hits: `downstream_integrator` (p=0.068, n=1373, marginal), `all` (p=0.027, unchanged —
doesn't depend on relationship coding), `broad_downstream` (p=0.063, marginal),
`non_us_creator` (p=0.060, unchanged), `downstream_comp` (p=0.045).

The strongest old downstream-subsample result (`business_downstream`/`broad_downstream` at
p=0.050) becomes marginal in the new coding (`downstream_integrator`/`broad_downstream` at
p=0.06-0.07) — same direction and similar magnitude, but no longer crosses the 5% line. None of
the genuinely new-only categories (`upstream_hardware`, `upstream_cloud`, `downstream_enabler`,
`downstream_deployer`) reach p<0.05 in this single main specification; `is_owner`/`is_investor`
(small-n, same as old `owner`/`investor`) remain insignificant as before.

### Relationship flag as X (full sample, n=4829)

| Old (v1) | estimate | p | | New (v2) | estimate | p |
|---|---:|---:|---|---|---:|---:|
| real_upstream | 0.0416 | 0.0018 | | upstream_hardware | 0.0228 | 0.0090 |
| business_upstream | 0.0369 | 0.0020 | | upstream_cloud | 0.0110 | 0.0540 (marginal) |
| owner | 0.0191 | 0.378 | | is_owner | 0.0191 | 0.378 |
| cloud | 0.0059 | 0.777 | | competitor | -0.0005 | 0.941 |
| competitor | -0.0027 | 0.707 | | is_investor | -0.0024 | 0.909 |
| investor | -0.0029 | 0.894 | | downstream_integrator | -0.0069 | 0.415 |
| business_downstream | -0.0094 | 0.157 | | downstream_enabler | -0.0107 | 0.116 |
| real_downstream | -0.0132 | 0.443 | | **downstream_deployer** | **-0.0190** | **0.0004*** |

**Most notable finding:** in v1, the old upstream flags (`real_upstream`, `business_upstream`)
were the only significant single-flag drivers, both positive and both p<0.01. In v2 the upstream
story survives but weakens (`upstream_hardware` p=0.009, `upstream_cloud` now only marginal at
p=0.054 — splitting the old upstream categories along hardware/cloud lines rather than
business/real lines dilutes the cloud side). The bigger change is on the downstream side: none of
the old downstream flags were significant in the full-sample main spec, but in the new schema
`downstream_deployer` (companies that deploy AI as a tool within a traditional, non-AI-native
business) emerges as the single strongest and most significant effect in the entire table —
estimate -0.019, p=0.0004 — a relationship dimension that did not exist as a separable category
in the old coding (it was previously merged into `business_downstream`/`real_downstream`, both
insignificant). This suggests the new finer-grained downstream split recovers a real,
economically large negative announcement effect for non-AI-native deployers that was masked by
aggregation in the old schema.

## Which new dimensions are strongest / weakest

Across the full relationship-as-X grid (`outputs_v2/relationship_x_specr_summary.csv`):

- **Strongest (most often significant):** `downstream_deployer` (25.9% of specs p<0.05) and
  `upstream_hardware` (25.2%) — both far ahead of the rest.
- **Moderate:** `is_investor` (18.3%), `upstream_cloud` (14.6%).
- **Weakest:** `downstream_enabler` (6.8%), `competitor` (0.7%), `downstream_integrator` (0.7%),
  `is_owner` (0%, small sample, n=29 events only).

For comparison, in the old schema the strongest dimensions were `real_downstream` (40.5%),
`cloud` (29.4%), and `investor` (29.4%) — none of which map cleanly onto the new strongest
dimensions, confirming the specification curve's qualitative conclusions about *which*
relationship type matters most have materially shifted, not just the magnitude of an existing
result.

## Caveats

- `is_owner`/`is_investor` samples remain small (n=29/39 events) in both schemas — treat as
  exploratory, consistent with the original script's own caveat.
- Relationship flags are not mutually exclusive in either schema; "relationship-as-X" results are
  single-flag correlations, not exclusive-category contrasts.
- Spec counts differ slightly (756 vs 756, 2226 vs 2310) because some new flags admit more
  non-degenerate subsample/control/FE combinations than the old flags they replace.
