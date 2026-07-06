# OLD vs NEW relationship coding: comparison of key coefficients

Script: `run_proposal_gap_supplement.R` (OLD, reads `output/data/specr_rel_clean.csv`,
old 8-column schema) vs `run_proposal_gap_supplement_v2.R` (NEW, reads
`data/panel/specr_rel_clean.csv`, new 8-dimension schema). Outcome throughout: `mkt_car_20`
(20-day market-adjusted CAR), firm-clustered SE, year FE + standard controls.

## 1. Relationship x capability interaction terms (`proposal_relationship_interactions.csv` vs `_v2.csv`)

| Metric x Relation (old -> new label) | OLD coef (p) | NEW coef (p) | Sign change? | Sig. threshold crossed (p<0.10/0.05)? |
|---|---|---|---|---|
| AA intelligence x owner -> is_owner | 0.0425 (0.257) | 0.0425 (0.257) | no | no (identical — owner/is_owner near 1:1, unchanged) |
| Lower price x owner -> is_owner | -0.1241 (0.022)* | -0.1241 (0.022)* | no | no |
| AA intelligence x investor -> is_investor | -0.0359 (0.008)** | -0.0346 (0.005)** | no | no (stays significant, slightly stronger) |
| AA coding x investor -> is_investor | -0.0303 (0.033)* | -0.0294 (0.028)* | no | no |
| AA math x investor -> is_investor | 0.0943 (0.065) | 0.0484 (0.165) | no | **lost** marginal significance (p crosses 0.10) |
| AA intelligence x cloud -> upstream_cloud | -0.0281 (0.046)* | -0.0098 (0.147) | no | **lost** significance at 0.05/0.10 |
| AA coding x cloud -> upstream_cloud | -0.0265 (0.064) | -0.0168 (0.018)* | no | gained significance (became *more* significant) |
| AA intelligence x real_upstream -> upstream_hardware | -0.0031 (0.819) | 0.0024 (0.802) | **yes** (flips sign) | no (both insignificant) |
| AA math x real_downstream -> broad_downstream | 0.1114 (0.013)* | 0.0116 (0.359) | no | **lost** significance |
| Lower price x real_downstream -> broad_downstream | 0.0253 (0.028)* | 0.0137 (0.076) | no | weakened to marginal (0.05 -> 0.10 tier) |
| AA coding x competitor | -0.0185 (0.078) | -0.0191 (0.051) | no | borderline, essentially unchanged |
| Lower price x pos_exposure | 0.0070 (0.359) | 0.0194 (0.264) | no | no (both insignificant) |
| AA coding x pos_exposure | -0.0041 (0.639) | 0.0160 (0.320) | **yes** (flips sign) | no (both insignificant) |

\* p<0.05, ** p<0.01

## 2. "Relationship bundle" joint model (`proposal_joint_models.csv` vs `_v2.csv`, outcome = mkt_car_20)

| Term (old -> new) | OLD coef (p) | NEW coef (p) | Notable change |
|---|---|---|---|
| z_intelligence | 0.0203 (0.026)* | 0.0204 (0.026)* | unchanged (capability term, not relationship-coded) |
| owner -> is_owner | 0.0377 (0.151) | 0.0023 (0.943) | coefficient collapses toward zero, loses what little signal it had |
| investor -> is_investor | -0.0231 (0.619) | -0.0029 (0.907) | shrinks toward zero |
| cloud -> upstream_cloud | 0.0261 (0.503) | -0.0014 (0.870) | **sign flip**, shrinks toward zero |
| real_upstream -> upstream_hardware | **0.0473 (0.0025)**\*\* | -0.0069 (0.694) | **most notable change: significant positive effect disappears entirely** |
| real_downstream -> broad_downstream | -0.0129 (0.526) | **-0.0425 (0.0051)**\*\* | **becomes significant and negative** (was insignificant before) |
| competitor | 0.0028 (0.748) | -0.0227 (0.064) | gains marginal significance, flips sign |

## Key bullet points

- **Most notable finding:** in the OLD coding, the tangible upstream-supply-chain channel (`real_upstream`, narrow: 126 positive obs in the old data) showed a significant *positive* CAR(20) effect (coef 0.047, p=0.0025) in the joint relationship-bundle model. Under the NEW, much broader `upstream_hardware`/`upstream_cloud` split, this effect vanishes (coef -0.007, p=0.69 for upstream_hardware; coef -0.001, p=0.87 for upstream_cloud). The broadening of the upstream category (1,200+300 new positives vs ~280 old) appears to dilute what was previously a concentrated, significant signal — consistent with the broader new coding picking up many marginal/incidental hardware-supplier relationships that don't carry the same market-reaction signal as the narrowly-coded "real" suppliers (e.g., NVIDIA, TSMC) did.
- **Downstream effect flips on:** the broad downstream exposure variable (old `real_downstream`, then `broad_downstream` in both versions) goes from insignificant (p=0.53) under the old narrow `real_downstream` definition to significantly *negative* (coef -0.0425, p=0.0051) once it captures the full union of `downstream_integrator` + `downstream_deployer` + `downstream_enabler`. This is a sign flip with a significance threshold crossing, and is the single largest substantive change in the relationship-bundle model.
- **Investor and owner channels are stable but weaker:** `is_investor` interactions with capability metrics retain the same signs and similar (slightly improved) significance as the old `investor` column, consistent with the codebook describing `is_investor` as "near 1:1" with the old `investor` coding. In the joint model, however, both `is_owner` and `is_investor` main effects shrink toward zero and lose what marginal significance they had — likely because the joint model's other terms (especially the now-significant `broad_downstream` and `upstream_hardware` shifts) absorb explanatory power previously attributed to owner/investor.
- **Cloud exposure interactions are mixed:** `upstream_cloud` (new, broader) loses the significant negative interaction with AA intelligence that `cloud` (old, narrow) had (p: 0.046 -> 0.147), but gains significance on the AA-coding interaction (p: 0.064 -> 0.018). This is consistent with `upstream_cloud` now including a much larger and more heterogeneous set of companies (300 positives vs 29 old), washing out some signals while picking up others.
- **Capability-only results are exactly unchanged**, as expected: `proposal_topline_capability_car20.csv` and its `_v2` counterpart are byte-identical, since the capability-metric regressions never include relationship terms — confirming the v2 script only altered relationship-variable construction, not the rest of the pipeline.
