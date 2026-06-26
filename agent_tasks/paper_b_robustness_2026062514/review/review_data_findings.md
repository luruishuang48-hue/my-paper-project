# REVIEW-DATA: Audit of R1-R5 Robustness Regression Scripts

Working directory: `agent_tasks/paper_b_robustness_2026062514/`
Reviewer: REVIEW-DATA (independent audit, did not write the scripts under review)

---

## 1. Old-schema leakage grep

Command run:

```
grep -nE "\b(owner|investor|cloud|real_upstream|business_upstream|real_downstream|business_downstream)\b" agent_tasks/paper_b_robustness_2026062514/scripts/*.R
```

Hits (all manually inspected):

| File | Line(s) | Context | Verdict |
|---|---|---|---|
| `r1_hardware_cloud_wald_test.R` | 11-12 | Header comment listing old-schema columns NOT used | OK (comment only) |
| `r1_hardware_cloud_wald_test.R` | 105, 154 | `cat(sprintf("diff (hardware - cloud)...`, and a long descriptive string about `relonly_regression` discussion | OK (string literal / prose, not a variable reference; `cloud` here is part of the word "hardware - cloud" diff label and `review_regressions_summary.md` filename text, not the old `cloud` column) |
| `r2_downstream_deployer_dedicated.R` | 19-20 | Header comment listing old-schema columns NOT used | OK (comment only) |
| `r4_ff3_robustness.R` | 10-12, 180-181 | Header comment + comparison-markdown string listing old-schema columns NOT used | OK (comment/string only) |

No hits in `r3_exclusion_sensitivity.R` or `r5_wild_bootstrap_core_tables.R`.

Separately confirmed that `upstream_cloud` (legitimate new-schema column) is used as an actual regressor in R1, R4, and R5 — this is correct and is not conflated with the banned old `cloud` column in the grep results (the regex's `\b` word boundaries correctly excluded `upstream_cloud`, `upstream_hardware`, etc., since `cloud`/`hardware` only match as whole words and `upstream_cloud` is one token without a boundary before "cloud").

I additionally read every line of all 5 scripts in full (not just grep hits) and confirmed the only relationship variables ever used as regressors, filters, or `group_by`/`mutate` inputs are: `upstream_hardware`, `upstream_cloud`, `downstream_integrator`, `downstream_deployer`, `downstream_enabler`, `competitor`, `is_investor`, `is_owner` (R4 only references `is_investor`/`is_owner` in its `rel_vars` list/NA-fill loop, not in any actual regression formula — they are coerced to 0/1 but never appear on an RHS). No script reads `owner`, `investor`, `cloud`, `real_upstream`, `business_upstream`, `real_downstream`, or `business_downstream` from the dataframe.

**Verdict: PASS.** No old-schema leakage in any of the 5 scripts.

---

## 2. Independent spot-check re-run (R2 and R5)

### R2 (`r2_downstream_deployer_dedicated.R`)

Re-ran via `Rscript agent_tasks/paper_b_robustness_2026062514/scripts/r2_downstream_deployer_dedicated.R` from repo root after backing up the original `outputs/r2_downstream_deployer_robustness.csv`. The script auto-locates the repo root and writes to the same output path.

Result: **byte-for-byte identical** to the original CSV (`diff` returned no output) across all 7 windows (car_1...car_20), all columns (beta, se, n, n_events, p_cr0, p_cr2, p_wild). Confirms full determinism (seed=42 fixed) and that the original output was not hand-edited or stale.

### R5 (`r5_wild_bootstrap_core_tables.R`)

Re-ran via `Rscript agent_tasks/paper_b_robustness_2026062514/scripts/r5_wild_bootstrap_core_tables.R` from repo root after backing up the original `outputs/r5_wild_bootstrap_table1to4.csv` (16 rows, ~6 min runtime due to 16 x B=4999 wild bootstrap replications).

Spot-checked against the live run log as it progressed (full run confirmed complete and CSV re-saved): every beta/se/p_cr0/p_cr2/p_wild value reproduced to the same precision as the original CSV for Groups A (baseline_single), B (bundle), and C (joint) rows inspected line-by-line during the run, including the headline joint-model `upstream_hardware` row (beta = -0.008255324..., p_wild = 0.6133227...) which matches the original exactly.

**Verdict: PASS.** Both R2 and R5 are fully reproducible from their saved scripts; no evidence of result tampering or non-determinism.

---

## 3. DeepSeek event ID verification

Independently queried the data (not trusting R3's `stopifnot`):

```r
df <- read.csv("data/panel/specr_rel_clean.csv", ...)
unique(df$event_name[df$final_event_id == "FMR-0021"])   # -> "DeepSeek R1"
unique(df$final_event_id[grepl("DeepSeek", df$event_name, ignore.case=TRUE)])  # -> "FMR-0021"
```

Confirmed: `final_event_id == "FMR-0021"` maps uniquely and exclusively to `event_name == "DeepSeek R1"` — no other event_id shares this name, and FMR-0021 has no other event_name value.

**Verdict: PASS.**

---

## 4. Wild bootstrap implementation check

Compared `wild_boot_p()` and `refit_cr2()` as defined in the canonical `scripts/analysis/core_table.R` (lines ~62-111) against the copies in `r2_downstream_deployer_dedicated.R` (lines 72-122) and `r5_wild_bootstrap_core_tables.R` (lines 62-111).

Diffed manually line-by-line: **the function bodies are verbatim-identical** across all three files. Specifically confirmed:
- `refit_cr2`: identical try/catch structure, `se_type = "CR2"`, same coefficient/p-value extraction.
- `wild_boot_p`: identical signature `(data, fml_full, fml_restr, var, B = 4999, seed = 42)`; identical guard `if (n_cl < 5) return(NA_real_)`; identical observed-t-stat computation via CR0; identical restricted-model residual/fitted-value extraction (`lm(fml_restr, ...)`, impose-null via `y_hat + e_b`); identical Rademacher weight draw `sample(c(-1L, 1L), G, replace = TRUE)`; identical `set.seed(seed)` placement (set once, before the bootstrap loop, matching the canonical code so that B draws are reproducible and consistent with the canonical script's RNG stream); identical two-sided p-value formula `mean(abs(t_star) >= abs(t_obs))`.

No subtle alterations (e.g., no swapped `>=`/`>`, no off-by-one in `B`, no different weight distribution, no different seed value) were found in either copy.

**Verdict: PASS.** Both R2 and R5 copied the canonical wild bootstrap and CR2 implementation verbatim, with B=4999 and seed=42 as specified in plan.md.

---

## 5. Sanity check on R5 joint-model sign flip (upstream_hardware: +0.0228 -> -0.0083)

Read R5's Group C construction (lines 181-197):

```r
fml_joint_full <- as.formula(paste(
  "car_20 ~", paste(position_vars, collapse = " + "), "+",
  paste(ctrl, collapse = " + "), "+ factor(release_year)"
))
```

with `position_vars <- c("upstream_hardware", "upstream_cloud", "downstream_integrator", "downstream_deployer", "downstream_enabler", "competitor")` and `ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")`.

Independently reconstructed this formula in a fresh R session:

```
car_20 ~ upstream_hardware + upstream_cloud + downstream_integrator +
    downstream_deployer + downstream_enabler + competitor + size_log_assets +
    bm_ratio + volatility + momentum + factor(release_year)
```

Verified: all 6 position variables appear exactly once each (`duplicated()` check returns `FALSE`), none omitted, and the control set (`size_log_assets, bm_ratio, volatility, momentum, factor(release_year)`) is identical to the baseline single-variable spec used in Group A and in R1/R2/R3/R4. Re-fit this joint model independently outside any of the 5 scripts and obtained `upstream_hardware` coefficient = -0.008255324, matching R5's CSV value (-0.00825532427949658) to full precision. Re-running R5's own script end-to-end (Check 2 above) reproduced the same value and the same p_wild = 0.6133.

**Verdict: PASS.** The sign flip is a genuine feature of the joint specification (multicollinearity/composition effect among the 6 position dummies), not a coding error. No variable duplication, omission, or control-set mismatch.

---

## 6. Cross-script consistency (baseline downstream_deployer and upstream_hardware car_20 coefficients)

| Script | downstream_deployer car_20 beta | upstream_hardware car_20 beta | Spec |
|---|---|---|---|
| R1 (`r1_hardware_vs_cloud_diff.csv`) | n/a (not estimated) | 0.0237 (SE 0.0086) | joint model with ONLY hardware+cloud (not single-variable, not full 6-var joint) |
| R2 (`r2_downstream_deployer_robustness.csv`) | -0.0190156167630144 | n/a (not estimated) | single-variable baseline |
| R3 (`r3_sensitivity_summary.md` / `r3_deepseek_exclusion.csv`) | -0.0190156167630144 (-0.0190, "-1.90 pp") | 0.0227637564746788 (0.0228, "2.28 pp") | single-variable baseline |
| R4 (`r4_ff3_comparison.md`, "MM beta" column, market-model reference) | -1.902 pp = -0.01902 | 2.276 pp = 0.02276 | single-variable baseline (re-derived from `output/paper_plan_core/data/table2_baseline_position.csv`, not re-estimated by R4 itself) |
| R5 (`r5_wild_bootstrap_table1to4.csv`, `baseline_single`) | -0.0190156167630144 | 0.0227637564746788 | single-variable baseline |

R2, R3, R5 (the three that actually estimate the single-variable baseline spec themselves) agree to full floating-point precision on both coefficients: `downstream_deployer` = -0.0190156167630144 and `upstream_hardware` = 0.0227637564746788. R4's market-model comparison numbers (read from the pre-existing `paper_plan_core_outputs.R` table, not re-estimated) round-trip to the same value at 4-decimal/pp precision (-1.902 pp, 2.276 pp). R1's hardware coefficient (0.0237) is from a *different* specification (hardware+cloud jointly, not the 6-var or single-var baseline) and is correctly documented as such in its own header/comments — this is not an inconsistency, it is intentionally a different model.

**Verdict: PASS.** All scripts that estimate the same baseline spec on the same data produce identical coefficients to floating-point precision. No silent data or spec divergence.

---

## Additional finding (not in the original 6-point checklist, found during Check 2/5 verification): R5 `n_events` bug

While re-running R5 and cross-checking against R2/R3, I found that **R5 systematically reports `n_events = 61` for the `car_20` baseline sample, while R1, R2, R3, and R4 all correctly report `n_events = 60`** for the identical sample (n=4829 observations, same filters). This is a real, reproducible discrepancy, not a transcription error — confirmed identically in both the original CSV and my independent rerun.

Root cause, located in `r5_wild_bootstrap_core_tables.R`, function `run_one_coef` (lines 115-128):

```r
mf <- model.frame(fml_full, data = d, na.action = na.omit)
used_idx <- as.integer(rownames(mf))
n_events <- length(unique(d$final_event_id[used_idx]))
```

`rownames(mf)` returns the **original row names inherited from `d`** (a string vector, e.g. `"5", "12", "13", ...`, not necessarily `1:nrow(d)` since `d` itself may have non-sequential row names from upstream filtering elsewhere in the pipeline — confirmed via `identical(rownames(d), as.character(1:nrow(d)))` returning `FALSE` in my test). Coercing these row-name strings to integers and using them as **positional indices** into `d$final_event_id` is incorrect — it looks up the wrong rows whenever `rownames(d)` is not the identity sequence. The correct fix is to index by row name (`d[rownames(mf), "final_event_id"]`) rather than by `as.integer(rownames(mf))` used positionally.

Independently confirmed via direct R session:
- "R5 method" (positional, buggy): `n_events = 61`
- "Correct method" (row-name indexed): `n_events = 60`, matching R1-R4.

Impact assessment: **this bug affects only the reported `n_events` column metadata in R5's outputs (CSV + `r5_wild_bootstrap_summary.md` + `logs/r5_status.md`, all of which say "61 events" / "61 clusters")**. It does NOT affect beta, se, p_cr0, p_cr2, or p_wild — those are all computed correctly from `lm_robust`/the bootstrap loop using the correctly-clustered `final_event_id` column directly (not via the buggy `used_idx` reconstruction), and I independently re-verified those values match across scripts (see Check 6). So the substantive findings (significance levels, sign flip, magnitudes) are unaffected — only the cosmetic cluster-count label is wrong, but it appears in the agent's own narrative ("61 events", "61 clusters") in two output documents and is inconsistent with the 60 reported everywhere else.

---

## Overall verdict: PASS WITH MINOR NOTE

All 6 checklist items pass. No old-schema leakage, full reproducibility on independent re-run, DeepSeek event ID correctly verified, wild bootstrap implementation verbatim and unaltered, joint-model sign flip is genuine (not a coding artifact), and the headline coefficients are numerically consistent across all scripts that estimate the same spec.

One minor, low-impact bug was found that was not in the original checklist:

### Fix needed
- **File**: `agent_tasks/paper_b_robustness_2026062514/scripts/r5_wild_bootstrap_core_tables.R`, function `run_one_coef`, lines 125-127.
- **Bug**: `n_events` is computed by coercing `rownames(model.frame(...))` to integers and using them as positional indices into `d$final_event_id`, which is incorrect when `d`'s row names are not `1:nrow(d)`. This inflates the reported cluster count from 60 (correct, matching R1/R2/R3/R4) to 61 for every row in `r5_wild_bootstrap_table1to4.csv`.
- **Downstream propagation**: the wrong "61 events"/"61 clusters" figure also appears in `outputs/r5_wild_bootstrap_summary.md` (e.g. "consistent across all 16 rows... 61 events" and the per-section narrative) and in `logs/r5_status.md`.
- **Suggested fix**: replace `d$final_event_id[used_idx]` with `d[rownames(mf), "final_event_id"]` (row-name-based indexing) or, more simply, just recompute `n_events` the same way R1-R4 do (count unique `final_event_id` in the filtered, complete-cases data frame before fitting, rather than reverse-engineering it from `model.frame` row names).
- **Severity**: low — does not affect any beta, SE, or p-value reported by R5; purely a metadata/cluster-count display bug, but should be corrected before the "61 events" language is carried into the paper draft, since the correct, paper-consistent figure is 60 events.
