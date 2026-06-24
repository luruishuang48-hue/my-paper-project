# v2 Comparison: OLD vs NEW Relationship Schema

## Scope of impact

`run_econometric_robustness.R` uses relationship variables in exactly **one** place: the
event-level subsample filter `related_any <- rowSums(d[, rel_vars], na.rm = TRUE) > 0`,
which restricts `event_level_data(..., related_only = TRUE)` to firms with at least one
coded structural relationship to the event's model creator. This feeds only the
`event_level_related_firms_all` and `event_level_related_firms_closed` specs.

All other specs (`core_robustness_results`, `leave_one_creator_out_results`,
`no_overlap_results`, `event_level_all_firms_*`) do **not** use relationship columns and
are byte-identical between v1 and v2 (confirmed via `diff`).

**Migration applied:** `rel_vars` OLD (`owner, investor, cloud, business_upstream,
real_upstream, business_downstream, real_downstream, competitor`) → NEW
(`upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer,
downstream_enabler, competitor, is_investor, is_owner`). Since the script only ever
takes the row-wise union ("any relationship"), the correct migration is the full union
of all 8 new dimensions — no decomposition into separate regressors was needed.

## Key coefficient comparison (intel_c on car20_mean, event-level)

| Spec | Schema | beta | se | t | p | n (events) | R² |
|---|---|---|---|---|---|---|---|
| event_level_related_firms_all | OLD | 0.000610 | 0.000776 | 0.786 | 0.437 | 47 | 0.306 |
| event_level_related_firms_all | NEW | 0.000855 | 0.000543 | 1.574 | 0.124 | 47 | 0.360 |
| event_level_related_firms_closed | OLD | 0.001420 | 0.001028 | 1.380 | 0.178 | 36 | 0.440 |
| event_level_related_firms_closed | **NEW** | **0.001028** | **0.000476** | **2.157** | **0.0397\*** | 36 | 0.514 |
| event_level_all_firms_all (unaffected) | both | 0.000987 | 0.000620 | 1.590 | 0.120 | 47 | 0.453 |
| event_level_all_firms_closed (unaffected) | both | 0.001715 | 0.000672 | 2.551 | 0.0165\* | 36 | 0.455 |

## Sample composition shift

- Firm-(event) pairs flagged "any relationship": **OLD = 2,073 / 5,161 (40.2%)** vs.
  **NEW = 5,040 / 5,160 (97.7%)**. The new schema's broader `downstream_deployer` and
  `downstream_enabler` categories make almost every sampled firm "related" to almost
  every event, so the "related firms" subsample loses most of its discriminating power
  as a sample restriction (it now nearly equals the "all firms" sample).
- Despite this, the *number of events* retained is unchanged (47 / 36), because at
  least one related firm survives per event in both schemas — only the firm-level
  composition within each event-level mean shifts.

## Notable findings

- **No sign flips.** All four related-firms coefficients keep the same (positive) sign
  across OLD and NEW.
- **Significance threshold crossing:** `event_level_related_firms_closed` crosses from
  insignificant under OLD (p = 0.178) to significant at the 5% level under NEW
  (p = 0.040, t = 2.16). This is the single most notable change — driven by both a
  smaller, more precisely estimated coefficient (tighter SE: 0.00048 vs 0.00103) under
  the broader, less noisy "related" sample definition.
- **R² improves modestly** for both related-firms specs under NEW (0.31→0.36 all;
  0.44→0.51 closed), consistent with a less idiosyncratic/noisy subsample once the
  relationship filter captures nearly the full closed-model sample.
- **Practical caveat:** because NEW flags 97.7% of pairs as "related," the
  `event_level_related_firms_*` specs are now an almost redundant robustness check
  against `event_level_all_firms_*` — they no longer isolate a meaningfully different
  subsample. If the "related firms only" robustness check is meant to test sensitivity
  to *excluding* structurally unrelated firms, consider tightening the filter (e.g.,
  excluding `downstream_deployer`/`downstream_enabler`-only firms, or requiring
  confidence ≥ M) rather than using the full 8-dimension union under the new schema.
- All core specs, leave-one-creator-out results, and the calendar-overlap diagnostics
  are unaffected by the schema change (confirmed identical via diff), since they never
  reference relationship columns.
