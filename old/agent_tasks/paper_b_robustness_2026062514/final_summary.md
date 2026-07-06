# Final Summary: Paper B Robustness Round (5 Regressions + Writing Plan)

**Task**: 把论文B的完整写作计划总结为md文件，并跑5项新增稳健性回归（R1-R5）。
**Workspace**: `agent_tasks/paper_b_robustness_2026062514/`
**Status**: Complete. All deliverables produced, reviewed, and one bug fixed.

## What was delivered

1. **`PAPER_B_WRITING_PLAN.md`** (project root) — full writing plan for Paper B
   ("Who Gains, Who Loses? Ecosystem Position Repricing from LLM Releases"):
   positioning vs. Paper A/C, materials inventory, R1-R5 results summary,
   8-section paper structure outline, out-of-scope list, updated effort
   estimate (~5-6.5 days remaining).

2. **Five new robustness regressions**, each with script + CSV + markdown
   write-up under `scripts/`, `outputs/`, `logs/`:

   | # | Test | Headline result |
   |---|------|------------------|
   | R1 | upstream_hardware vs upstream_cloud formal Wald diff test | **Not significant** (p=0.298 at car_20) — the qualitative "hardware drives it" claim is NOT formally confirmed; flag as an honest null result |
   | R2 | downstream_deployer alone, all CAR windows (1-20d), CR0+CR2+wild boot | **Most robust finding** — significant at every window, all 3 inference methods agree |
   | R3 | DeepSeek R1 exclusion + leave-one-event-out (60) + leave-one-firm-out (86) | Both headline findings unaffected by any single event/firm, including DeepSeek R1 |
   | R4 | FF3 three-factor model replacing market-model CAR | **Important caveat**: both headline findings keep sign but lose significance at car_20/ff3_car_20 (upstream_hardware p=0.879; downstream_deployer p=0.133) — directionally robust, statistically fragile under FF3 |
   | R5 | Wild bootstrap (B=4999) added to Table 1-4 core coefficients | downstream_deployer robust in all 4 table contexts; **upstream_hardware loses significance and flips sign in the joint 6-variable model** (p_wild=0.64) |

## Key finding of the round

The two headline results are **not equally strong**: `downstream_deployer`
(negative effect for firms that deploy AI as a tool) is robust across every
window, every inference method, and every model specification tested.
`upstream_hardware` (positive effect for hardware suppliers) is real and
directionally consistent but more fragile — it doesn't survive FF3 risk
adjustment or the fully-saturated joint model. `PAPER_B_WRITING_PLAN.md`
reflects this asymmetry explicitly in its Robustness and Main Results
sections rather than presenting both as equally strong.

## Review and fixes

- **REVIEW-DATA** (independent audit, re-ran R2 and R5 from scratch):
  PASS with one bug found — R5's `n_events` column computed an invalid
  positional index (`as.integer(rownames(mf))`) into already-NA-filtered
  data, inflating the reported cluster count from 60 to 61 in all 16 rows.
  No beta/SE/p-value was affected (cosmetic metadata only). Confirmed no
  old-schema relationship columns were used in any of the 5 scripts; the
  `wild_boot_p()`/`refit_cr2()` functions were verbatim, correct copies of
  `scripts/analysis/core_table.R`; the joint-model sign flip for
  upstream_hardware is genuine, not a formula bug.
- **REVIEW-CONTENT** (independent audit of `PAPER_B_WRITING_PLAN.md`):
  PASS, no FAILs — 14 spot-checked numbers all matched source files; all
  three critical nuances (R1 null, R4 dual fragility, R5 asymmetry)
  preserved and foregrounded, not buried; no Paper A/C scope bleed.
- **Fix applied**: corrected the indexing bug in
  `scripts/r5_wild_bootstrap_core_tables.R` (line 125-127, now uses
  `d[rownames(mf), "final_event_id"]` instead of integer-position lookup),
  re-ran the script (deterministic, seed=42 — all betas/SEs/p-values
  identical to before), and propagated the corrected n_events=60 into
  `outputs/r5_wild_bootstrap_table1to4.csv`, `outputs/r5_wild_bootstrap_summary.md`,
  and `logs/r5_status.md`.

## Scope discipline maintained

- No existing data files (`data/panel/specr_rel_clean.csv`) were modified.
- `Tex/long.tex` and `Tex/frl_draft_main_text.tex` were read-only references,
  not edited this round (per plan.md's explicit scope boundary — actually
  drafting the new Robustness section text into long.tex is future work,
  itemized in `PAPER_B_WRITING_PLAN.md`'s effort estimate).
- Paper A and Paper C were untouched.

## Next step (not part of this round)

Use `PAPER_B_WRITING_PLAN.md` to actually draft the new §3 稳健性检验 section
of `Tex/long.tex` using the R1-R5 outputs, and hedge the Main Results
language around `upstream_hardware` per the plan's instructions.
