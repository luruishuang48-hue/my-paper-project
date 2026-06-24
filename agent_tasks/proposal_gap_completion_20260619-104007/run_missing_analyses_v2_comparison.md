# OLD vs NEW relationship schema — comparison of key coefficients

Source scripts: `run_missing_analyses.R` (OLD 8-col schema: `owner, investor, cloud,
business_upstream, real_upstream, business_downstream, real_downstream, competitor`)
vs. `run_missing_analyses_v2.R` (NEW 8-dim schema: `upstream_hardware, upstream_cloud,
downstream_integrator, downstream_deployer, downstream_enabler, competitor, is_investor,
is_owner`). Remapping used: `owner→is_owner`, `investor→is_investor`,
`cloud→upstream_cloud`, `broad_upstream = pmax(upstream_hardware, upstream_cloud)`,
`broad_downstream = pmax(downstream_integrator, downstream_deployer, downstream_enabler)`,
`positive_exposure = pmax(is_owner, is_investor, upstream_cloud, upstream_hardware,
downstream_integrator)`, `competitor→competitor`.

## Role mean-CAR tests (`role_car_mean_tests*.csv`)

| Role | Outcome | OLD mean (n) | OLD p | NEW mean (n) | NEW p | Change |
|---|---|---|---|---|---|---|
| owner/is_owner | CAR[0,1] | 0.0008 (29) | 0.902 | 0.0008 (29) | 0.902 | unchanged (near 1:1 mapping) |
| owner/is_owner | CAR[0,20] | 0.0128 (29) | 0.568 | 0.0128 (29) | 0.568 | unchanged |
| investor/is_investor | CAR[0,1] | -0.0082 (37) | 0.141 | -0.0086 (39) | 0.105 | stable, slightly larger n |
| cloud/upstream_cloud | CAR[0,1] | -0.0060 (29) | 0.383 | -0.0005 (300) | 0.746 | sample 10x larger, effect shrinks toward 0, stays insignificant |
| upstream (broad) | CAR[0,1] | 0.0011 (156) | 0.696 | 0.0018 (1487) | 0.102 | sample ~10x larger; still insignificant but p drops |
| upstream (broad) | CAR[0,20] | 0.0228 (156) | **0.0036** | 0.0146 (1500) | **<0.0001** | **significance strengthens**, coefficient shrinks (diluted by broader hardware/cloud union) |
| downstream (broad) | CAR[0,1] | 0.0015 (1395) | 0.189 | 0.0015 (3321) | 0.070 | sample more than doubles; approaches but does not cross 0.05 |
| downstream (broad) | CAR[0,20] | -0.0007 (1403) | 0.881 | -0.0049 (3330) | 0.160 | sign flips negative, still insignificant |
| competitor | CAR[0,1] / CAR[0,20] | ~0 / -0.0019 | 0.458 / 0.684 | ~0 / -0.0002 | 0.424 / 0.956 | stable null result, sample modestly larger (461→511) |
| positive_exposure | CAR[0,1] | 0.0001 (238) | 0.978 | 0.0023 (3184) | **0.0031** | **crosses significance threshold** (insignificant → highly significant), sample 13x larger because integrator-driven exposure now dominates |
| positive_exposure | CAR[0,20] | 0.0154 (238) | **0.0241** | 0.0065 (3205) | **0.0192** | stays significant, coefficient roughly halves |

## Triple-interaction mechanism specs (`cost_efficiency_capability_results*.csv`, outcome = mkt_car_20)

| Spec / term | OLD coef | OLD p | NEW coef | NEW p | Change |
|---|---|---|---|---|---|
| Intelligence × upstream × open-weight: `broad_upstream` (main) | 0.0405 | **0.0059** | 0.0262 | **0.0050** | sign and significance stable, magnitude shrinks ~35% |
| Intelligence × upstream × open-weight: `z_intelligence:broad_upstream` | -0.0056 | 0.690 | -0.0080 | 0.293 | stays insignificant |
| Intelligence × upstream × open-weight: triple interaction | -0.0148 | 0.663 | -0.0004 | 0.981 | stays insignificant, moves toward 0 |
| Intelligence × downstream × open-weight: `broad_downstream` (main) | -0.0120 | 0.052 (marginal) | -0.0250 | **0.0083** | **crosses into significance**, same sign, larger magnitude |
| Intelligence × downstream × open-weight: `z_intelligence:broad_downstream` | 0.0174 | **0.0119** | 0.0111 | 0.151 | **loses significance** (significant → insignificant), same sign |
| Intelligence × downstream × open-weight: triple interaction | -0.0199 | 0.159 | -0.0192 | 0.320 | stays insignificant |

## Key bullet points

- **No sign reversals on any headline relationship coefficient.** Every role/mechanism term that was positive (or negative) under the OLD schema keeps the same sign under NEW; the broader NEW classification mainly dilutes or sharpens magnitude/precision, not direction.
- **Sample sizes inflate sharply for cloud, upstream, and especially downstream/positive_exposure** (e.g., downstream observations roughly 1,400 → 3,300+; positive_exposure 238 → ~3,200), reflecting that `upstream_cloud`, `downstream_integrator/deployer/enabler`, and the broader role definitions capture far more firm-event pairs than the old `cloud`/`business_*`/`real_*` columns.
- **Most notable threshold crossing:** `positive_exposure` on CAR[0,+1] flips from clearly insignificant (OLD p = 0.978) to highly significant (NEW p = 0.0031), because the new `downstream_integrator`-driven exposure pool is an order of magnitude larger and concentrates short-window reaction in firms that are core AI-product integrators.
- **One significance loss:** the `z_intelligence:broad_downstream` interaction on CAR[0,+20], significant under OLD (p = 0.012), becomes insignificant under NEW (p = 0.151) — consistent with the three-way downstream split (integrator/deployer/enabler) mixing together firms with heterogeneous sensitivity to capability surprises, attenuating the interaction.
- **Upstream remains the most robust channel:** `broad_upstream` (hardware + cloud) is significant at CAR[0,+20] in both versions (OLD p = 0.0036, NEW p < 0.0001), and the upstream×open-weight main effect stays significant in both (p ≈ 0.005–0.006), suggesting the upstream hardware/cloud exposure result is not an artifact of the old "real vs. business" upstream split.
- **Owner, investor, and competitor results are essentially invariant** across schemas (near-identical means, p-values, and similar/slightly larger samples), as expected given these map almost 1:1 between OLD and NEW.

All NEW-schema outputs are in `outputs/*_v2.csv` / `outputs/*_v2.png`; OLD-schema outputs (generated 2026-06-19, before the schema swap) remain untouched in `outputs/*.csv` (no `_v2` suffix).
