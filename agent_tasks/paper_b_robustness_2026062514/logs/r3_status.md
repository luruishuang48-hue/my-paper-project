# R3 Status Log — Exclusion Sensitivity (DeepSeek R1, leave-one-event-out, leave-one-firm-out)

Completed: 2026-06-25 14:21 (Beijing)

## Setup
- Data: `data/panel/specr_rel_clean.csv` (5,160 rows, used only new-schema columns
  `upstream_hardware`, `downstream_deployer`).
- Verified `final_event_id == "FMR-0021"` -> `event_name == "DeepSeek R1"` (confirmed in script).
- Used `company_id` (ticker, 86 unique, no NAs) rather than `company` (Chinese names) for
  leave-one-firm-out — cleaner unique identifiers.
- Baseline spec: `car_20 ~ position_var + size_log_assets + bm_ratio + volatility + momentum +
  factor(release_year)`, `lm_robust(..., clusters = final_event_id, se_type = "CR0")`.
- Full-sample baseline: upstream_hardware beta = 0.0228 (p=0.0090, n=4829, 60 events);
  downstream_deployer beta = -0.0190 (p=0.0004, n=4829, 60 events).

## Runtime
- Leave-one-event-out loop (60 events x 2 vars = 120 regressions): ~2 sec.
- Leave-one-firm-out loop (86 firms x 2 vars = 172 regressions): ~2.8 sec.
- Total script runtime: well under a minute.

## Results summary
1. **DeepSeek R1 exclusion**: beta essentially unchanged for both variables
   (upstream_hardware 0.0228 -> 0.0228; downstream_deployer -0.0190 -> -0.0186, a 2.2% shift).
   Significance unchanged (both remain significant at 1%/5%).
2. **Leave-one-event-out**: beta ranges [0.0203, 0.0249] for upstream_hardware (sd=0.0011) and
   [-0.0204, -0.0174] for downstream_deployer (sd=0.0007) across all 60 iterations. Zero sign
   flips, zero iterations losing significance (p < 0.10 throughout). Most influential single
   event: FMR-0056 for upstream_hardware, FMR-0016 for downstream_deployer — neither is DeepSeek
   R1 (FMR-0021).
3. **Leave-one-firm-out**: beta ranges [0.0204, 0.0249] (upstream_hardware, sd=0.0008) and
   [-0.0208, -0.0168] (downstream_deployer, sd=0.0007) across all 86 firms. Zero sign flips,
   zero significance losses. Most influential firm: SMCI for upstream_hardware, "5803 JP"
   (ticker) for downstream_deployer.

## Outputs written
- `scripts/r3_exclusion_sensitivity.R`
- `outputs/r3_deepseek_exclusion.csv` (4 rows)
- `outputs/r3_leave_one_event_out.csv` (120 rows)
- `outputs/r3_leave_one_firm_out.csv` (172 rows)
- `outputs/r3_sensitivity_summary.md`
- `logs/r3_run_log.txt` (full console capture)

## Conclusion
Both headline findings are robust to exclusion of the DeepSeek R1 event and to leave-one-out
perturbation at both the event and firm level. No single observation drives either result.
