# R4: FF3 three-factor model robustness check vs market-model baseline

Generated: 2026-06-25 14:20:27 CST

## Scope

Replicates the Table 2 (single-position) and Table 3 (bundle-position) core
rows from `scripts/analysis/paper_plan_core_outputs.R`, swapping the
market-model CAR outcomes (`car_10/15/20`) for the Fama-French three-factor
model CAR outcomes (`ff3_car_10/15/20`). Same controls
(`size_log_assets, bm_ratio, volatility, momentum, factor(release_year)`),
same clustering (`final_event_id`, CR0), same new-schema relationship
columns. Only the new 8-dim relationship columns
(`upstream_hardware, upstream_cloud, downstream_integrator,
downstream_deployer, downstream_enabler, competitor`) and the bundle vars
derived from them (`upstream_any`, `downstream_any`) plus
`downstream_deployer` (bundle table) were used. Old-schema columns
(`owner, investor, cloud, real_upstream, business_upstream,
real_downstream, business_downstream`) were not referenced.

## Comparison data availability

Market-model baseline files FOUND: `output/paper_plan_core/data/table2_baseline_position.csv`, `output/paper_plan_core/data/table3_bundle_positions.csv`.
Row-by-row comparison performed below (FF3 vs market-model, matched on
variable + corresponding outcome window, e.g. `ff3_car_20` vs `car_20`).

## Row-by-row comparison (full table)

| Table | Variable | Window | MM beta (pp) | MM p | FF3 beta (pp) | FF3 p | Same sign? | Both sig (p<.10)? |
|---|---|---|---|---|---|---|---|---|
| Table 2 (single-position) | upstream_hardware | car_10 vs ff3_car_10 | 0.686 | 0.2494 | -0.668 | 0.2572 | NO | both n.s. |
| Table 2 (single-position) | upstream_hardware | car_15 vs ff3_car_15 | 1.654 | 0.0282 | -0.179 | 0.8216 | NO | DIVERGES |
| Table 2 (single-position) | upstream_hardware | car_20 vs ff3_car_20 | 2.276 | 0.0090 | 0.145 | 0.8794 | yes | DIVERGES |
| Table 2 (single-position) | upstream_cloud | car_10 vs ff3_car_10 | 0.969 | 0.0708 | 0.729 | 0.1651 | yes | DIVERGES |
| Table 2 (single-position) | upstream_cloud | car_15 vs ff3_car_15 | 1.611 | 0.0041 | 1.264 | 0.0215 | yes | both sig |
| Table 2 (single-position) | upstream_cloud | car_20 vs ff3_car_20 | 1.132 | 0.0663 | 0.770 | 0.1832 | yes | DIVERGES |
| Table 2 (single-position) | downstream_integrator | car_10 vs ff3_car_10 | -0.067 | 0.9101 | 0.471 | 0.4547 | NO | both n.s. |
| Table 2 (single-position) | downstream_integrator | car_15 vs ff3_car_15 | -0.417 | 0.5457 | 0.199 | 0.7981 | NO | both n.s. |
| Table 2 (single-position) | downstream_integrator | car_20 vs ff3_car_20 | -0.688 | 0.4151 | 0.137 | 0.8870 | NO | both n.s. |
| Table 2 (single-position) | downstream_deployer | car_10 vs ff3_car_10 | -0.985 | 0.0077 | -0.320 | 0.4141 | yes | DIVERGES |
| Table 2 (single-position) | downstream_deployer | car_15 vs ff3_car_15 | -1.429 | 0.0016 | -0.531 | 0.2395 | yes | DIVERGES |
| Table 2 (single-position) | downstream_deployer | car_20 vs ff3_car_20 | -1.902 | 0.0004 | -0.763 | 0.1334 | yes | DIVERGES |
| Table 2 (single-position) | downstream_enabler | car_10 vs ff3_car_10 | -1.091 | 0.0440 | -0.718 | 0.2135 | yes | DIVERGES |
| Table 2 (single-position) | downstream_enabler | car_15 vs ff3_car_15 | -1.726 | 0.0051 | -1.063 | 0.1147 | yes | DIVERGES |
| Table 2 (single-position) | downstream_enabler | car_20 vs ff3_car_20 | -1.065 | 0.1158 | -0.681 | 0.3678 | yes | both n.s. |
| Table 2 (single-position) | competitor | car_10 vs ff3_car_10 | 0.386 | 0.4396 | 0.148 | 0.7548 | yes | both n.s. |
| Table 2 (single-position) | competitor | car_15 vs ff3_car_15 | 0.495 | 0.3757 | 0.380 | 0.4619 | yes | both n.s. |
| Table 2 (single-position) | competitor | car_20 vs ff3_car_20 | -0.050 | 0.9406 | -0.183 | 0.7617 | yes | both n.s. |
| Table 3 (bundle-position) | upstream_any | car_10 vs ff3_car_10 | 0.820 | 0.1258 | -0.398 | 0.4556 | NO | both n.s. |
| Table 3 (bundle-position) | upstream_any | car_15 vs ff3_car_15 | 1.803 | 0.0088 | 0.150 | 0.8349 | yes | DIVERGES |
| Table 3 (bundle-position) | upstream_any | car_20 vs ff3_car_20 | 2.222 | 0.0062 | 0.309 | 0.7238 | yes | DIVERGES |
| Table 3 (bundle-position) | downstream_any | car_10 vs ff3_car_10 | -1.222 | 0.0270 | -0.051 | 0.9288 | yes | DIVERGES |
| Table 3 (bundle-position) | downstream_any | car_15 vs ff3_car_15 | -2.146 | 0.0021 | -0.613 | 0.4202 | yes | DIVERGES |
| Table 3 (bundle-position) | downstream_any | car_20 vs ff3_car_20 | -2.499 | 0.0035 | -0.693 | 0.4586 | yes | DIVERGES |
| Table 3 (bundle-position) | downstream_deployer | car_10 vs ff3_car_10 | -0.985 | 0.0077 | -0.320 | 0.4141 | yes | DIVERGES |
| Table 3 (bundle-position) | downstream_deployer | car_15 vs ff3_car_15 | -1.429 | 0.0016 | -0.531 | 0.2395 | yes | DIVERGES |
| Table 3 (bundle-position) | downstream_deployer | car_20 vs ff3_car_20 | -1.902 | 0.0004 | -0.763 | 0.1334 | yes | DIVERGES |

## Focused check: headline findings at CAR[0,+20] / FF3_CAR[0,+20]

- **upstream_hardware**: market-model beta = 2.276 pp (p = 0.0090); FF3 beta = 0.145 pp (p = 0.8794). Sign MATCHES across the two risk models. Significance status DIVERGES between the two models.
- **downstream_deployer**: market-model beta = -1.902 pp (p = 0.0004); FF3 beta = -0.763 pp (p = 0.1334). Sign MATCHES across the two risk models. Significance status DIVERGES between the two models.

## Overall summary

Across all 27 matched variable x window rows (Table 2 + Table 3 combined), 6 row(s) show a sign flip between market-model and FF3 risk adjustment.
