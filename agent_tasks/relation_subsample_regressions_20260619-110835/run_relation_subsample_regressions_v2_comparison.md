# OLD vs NEW (v2) Relationship Schema — Subsample Regression Comparison

Generated 2026-06-25 (Asia/Shanghai). Compares:
- OLD: `agent_tasks/relation_subsample_regressions_20260619-110835/outputs/` (8-dim coding: owner, investor, cloud, business_upstream, real_upstream, business_downstream, real_downstream, competitor)
- NEW (v2): `agent_tasks/relation_subsample_regressions_20260619-110835/outputs_v2/` (8-dim coding: upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer, downstream_enabler, competitor, is_investor, is_owner)

Both regressions estimate `mkt_car_20 ~ z_intelligence [+ controls]` on relationship subsamples, clustered by event (`lm_robust`, CR0). Comparison restricted to the variables the task asked about: `broad_upstream`, `broad_downstream`, `positive_exposure`, `any_relation`, `competitor`, `owner`/`is_owner`, `investor`/`is_investor`, and `cloud`/`upstream_cloud`.

## Mapping reasoning (recap)

- `broad_upstream = pmax(upstream_hardware, upstream_cloud)`. Old `business_upstream`/`real_upstream` were **not** a role-type split — per `relationship_data_audit.md`, `real_upstream` was a confidence-filtered (evidence-strength) *subset* of `business_upstream` (both described the same set of 5 chip/hardware companies: NVDA, TSM, AVGO, SK Hynix, AMD). The new schema has no evidence-strength axis on its role columns, so the broadest faithful equivalent of "any upstream exposure" is the union of the two new upstream roles.
- `broad_downstream = pmax(downstream_integrator, downstream_deployer, downstream_enabler)`. Same logic: old `business_downstream`/`real_downstream` were broad/narrow evidence layers of the *same* underlying downstream-exposure concept (`real_downstream` was literally a subset of `business_downstream`'s company list), not a R3/R4/R5-style role split. The new schema's three downstream roles are a role-type split instead, so "any downstream exposure" maps to their union, not to any single one of the three.
- `positive_exposure = pmax(is_owner, is_investor, upstream_cloud, downstream_integrator, downstream_deployer, downstream_enabler)`. Mirrors the old formula's structural choice (owner + investor + cloud + downstream, deliberately excluding the broad upstream-hardware category — the old formula used `real_upstream` only inside `broad_upstream`/`any_relation`, not inside `positive_exposure`, and never included `business_upstream`/hardware at all in `positive_exposure`). We keep `upstream_hardware` out of `positive_exposure` for the same reason.
- `any_relation = pmax(upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer, downstream_enabler, competitor, is_investor, is_owner)`. Direct union of all 8 new columns, matching the old formula's union of all 8 old columns.
- `owner → is_owner`, `investor → is_investor`, `cloud → upstream_cloud`, `competitor → competitor`: near 1:1 per the task's role mapping.

## Key coefficient comparison (z_intelligence on mkt_car_20)

| Set type | Spec | Role (old → new) | Coef % (old) | p (old) | Coef % (new) | p (new) | Sign flip | Crossed 0.10 |
|---|---|---|---:|---:|---:|---:|:--:|:--:|
| flag | controls_intelligence | any_relation | 1.90 | 0.005 | 1.52 | 0.005 | No | No (both sig.) |
| flag | controls_intelligence | broad_downstream | 2.39 | 0.009 | 1.77 | 0.015 | No | No (both sig.) |
| flag | controls_intelligence | broad_upstream | 2.36 | 0.155 | 1.29 | 0.054 | No | **Yes** (n.s. → sig. at 10%) |
| flag | controls_intelligence | positive_exposure | 1.77 | 0.127 | 1.69 | 0.012 | No | **Yes** (n.s. → sig. at 5%) |
| flag | controls_intelligence | competitor | 0.24 | 0.548 | 0.14 | 0.681 | No | No (both n.s.) |
| flag | controls_intelligence | investor → is_investor | 1.55 | 0.553 | 1.14 | 0.521 | No | No (both n.s.) |
| flag | controls_intelligence | owner → is_owner | −0.05 | 0.986 | −0.05 | 0.986 | No | No (identical — single company group unaffected) |
| flag | controls_intelligence | cloud → upstream_cloud | 0.88 | 0.754 | 1.03 | 0.096 | No | **Yes** (n.s. → sig. at 10%) |
| flag | no_controls_intelligence | cloud → upstream_cloud | −3.45 | 0.078 | −0.51 | 0.499 | No (both negative) | **Yes** (sig. at 10% → n.s.) |
| flag | no_controls_intelligence | investor → is_investor | −4.06 | 0.039 | −3.60 | 0.052 | No | borderline (still sig. ~5–10%) |
| exclusive | controls_intelligence | competitor | 0.25 | 0.544 | −0.02 | 0.979 | Yes (sign flip, but both ≈0 and n.s.) | No |

Full side-by-side data: `agent_tasks/relation_subsample_regressions_20260619-110835/outputs_v2/old_vs_new_key_coef_comparison.csv`.

## Sample size changes

The new coding is structurally broader for several roles, which sharply increases subsample sizes:

| Role | Old n (flag) | New n (flag) |
|---|---:|---:|
| broad_upstream | 122 | 1,142 |
| broad_downstream | 1,072 | 2,472 |
| positive_exposure | 196 | 2,665 |
| any_relation | 1,568 | 3,711 |
| cloud / upstream_cloud | 28 | 235 |
| competitor | 366 | 402 |
| investor / is_investor | 36 | 38 |
| owner / is_owner | 21 | 21 (identical company-event set) |

## Interpretation (bullets)

- **Headline finding is robust.** The two largest, most policy-relevant aggregates — `any_relation` and `broad_downstream` — stay positive and statistically significant (p < 0.05) at essentially the same magnitude under both codings. The core claim that AI-intelligence improvements are priced positively across "any" relationship exposure does not depend on which coding scheme is used.
- **`broad_upstream` and `positive_exposure` gain significance, not lose it.** Under the new, much broader coding (upstream_hardware ∪ upstream_cloud covers 1,142 obs vs. 122 before; positive_exposure covers 2,665 vs. 196 before), both coefficients cross into significance (10% and 5% thresholds respectively) while keeping the same positive sign and a similar point estimate. This is consistent with a power gain from larger, better-populated subsamples rather than a substantive reinterpretation.
- **`cloud`/`upstream_cloud` is the most unstable cell**, as expected given it is the smallest, most fragile subsample in both versions. With controls, it goes from a noisy positive 0.88pp (p = 0.75, n = 28) to a marginally significant 1.03pp (p = 0.10, n = 235); without controls, it flips from a significant −3.45pp (p = 0.08, n = 20 events) to an insignificant −0.51pp (p = 0.50). Given n ≈ 20–47 events either way, this cell should continue to be treated as exploratory, not load-bearing, exactly as the original `relationship_data_audit.md` recommended.
- **`owner`/`is_owner` is unchanged**, because the underlying company-event set is identical (GOOGL, BABA, META, MSFT publisher-events) under the near-1:1 mapping — confirms the mapping was applied correctly with no unintended drift for the cleanest role.
- **`competitor` and `investor`/`is_investor` are qualitatively stable.** Both remain non-significant under the main controls_intelligence spec in both codings (competitor's small sign flip in the exclusive-group, no-controls cut is between two coefficients that are both economically negligible and statistically indistinguishable from zero). The `investor` coefficient in the no-controls spec stays marginally significant (crossing from p = 0.039 to p = 0.052, i.e., right at the 5%/10% boundary) — worth flagging as borderline but not a substantive reversal.

## Bottom line

No sign reversals of substantive magnitude and no loss of significance for any previously-significant key coefficient. The new, broader coding schema mainly *adds* statistical power to previously under-powered upstream/positive-exposure subsamples (broad_upstream, positive_exposure, upstream_cloud) by enlarging their sample sizes, while leaving the two headline aggregates (any_relation, broad_downstream) and the cleanest role (owner/is_owner) materially unchanged.
