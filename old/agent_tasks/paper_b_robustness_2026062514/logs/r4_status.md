# R4 Status: FF3 three-factor robustness check

**Status**: Complete.

## What was done

- Script: `agent_tasks/paper_b_robustness_2026062514/scripts/r4_ff3_robustness.R`
- Replaced market-model `car_10/15/20` with FF3-model `ff3_car_10/15/20` in the
  Table 2 (6 single-position regressions) and Table 3 (3 bundle-position
  regressions: `upstream_any`, `downstream_any`, `downstream_deployer`) core
  specs from `scripts/analysis/paper_plan_core_outputs.R`. Same controls
  (`size_log_assets, bm_ratio, volatility, momentum, factor(release_year)`),
  same CR0 clustering by `final_event_id`. Used only new-schema relationship
  columns; verified no old-schema columns (`owner, investor, cloud,
  real_upstream, business_upstream, real_downstream, business_downstream`)
  appear anywhere in the script.
- Market-model baseline files (`output/paper_plan_core/data/table2_baseline_position.csv`,
  `table3_bundle_positions.csv`) were found, so a full row-by-row comparison
  (27 matched variable x window rows) was produced.
- Sample: N = 4,831 obs / 60 events for all FF3 rows (matches the market-model N).

## Key finding

Both headline coefficients **keep their sign** under FF3 risk adjustment but
**lose statistical significance** at the CAR[0,+20] / FF3_CAR[0,+20] window:

- `upstream_hardware`: market-model +2.276pp (p=0.0090, **) -> FF3 +0.145pp (p=0.8794, n.s.)
- `downstream_deployer`: market-model -1.902pp (p=0.0004, ***) -> FF3 -0.763pp (p=0.1334, n.s.)

Across all 27 matched rows, 6 show an outright sign flip (mostly at the
car_10 window where market-model effects were already weak/insignificant);
none of the sign flips involve the two headline variables. The general
pattern: FF3 coefficients are systematically smaller in magnitude (roughly
1/3 to 1/2 of market-model size) and noisier (wider relative SEs), so several
previously-significant rows (e.g. `downstream_enabler`, `downstream_any`)
also become insignificant under FF3, even though signs are preserved.

## Outputs

- `outputs/r4_ff3_table2_position.csv`
- `outputs/r4_ff3_table3_bundle.csv`
- `outputs/r4_ff3_vs_marketmodel_comparison.csv` (full 27-row comparison)
- `outputs/r4_ff3_comparison.md` (human-readable, includes focused headline section)
- `logs/r4_run_log.txt` (console log)
