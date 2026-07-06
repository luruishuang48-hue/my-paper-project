# Relationship Recode Switch — Synthesis of v2 Regression Comparisons

Synthesizes all six `*_v2_comparison.md` files documenting the migration of relationship
regressors from the OLD 8-column schema (`owner, investor, cloud, business_upstream,
real_upstream, business_downstream, real_downstream, competitor`) to the NEW 8-dimension
schema (`upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer,
downstream_enabler, competitor, is_investor, is_owner`).

Source files reviewed (6 of 6 found and read):

1. `agent_tasks/relation_subsample_regressions_20260619-110835/run_relation_subsample_regressions_v2_comparison.md`
2. `agent_tasks/econometric_robustness_20260613-210000/run_econometric_robustness_v2_comparison.md`
3. `agent_tasks/proposal_gap_completion_20260619-104007/run_missing_analyses_v2_comparison.md`
4. `agent_tasks/proposal_gap_analysis_20260619-092947/run_proposal_gap_supplement_v2_comparison.md`
5. `agent_tasks/vix_news_regression_20260624-150843/relonly_regression_v2_comparison.md`
6. `agent_tasks/relationship_specr_20260619-124757/run_relationship_specr_v2_comparison.md`

---

## 1. One-line verdict per script

| # | Script | Verdict |
|---|---|---|
| 1 | `run_relation_subsample_regressions` | **Stable.** No sign reversals of substantive magnitude. `broad_upstream` and `positive_exposure` newly cross into significance — attributed to a power gain (larger subsamples), not a substantive change. Headline aggregates (`any_relation`, `broad_downstream`) and `owner`/`is_owner` essentially unchanged. |
| 2 | `run_econometric_robustness` | **Mostly stable, with a serious methodological caveat.** No sign flips; one spec (`event_level_related_firms_closed`) crosses from insignificant (p=0.178) to significant (p=0.040). But the underlying "related firms" filter goes from 40.2% to 97.7% of firm-event pairs flagged "related," gutting the filter's discriminating power as a sample restriction. |
| 3 | `run_missing_analyses` | **Mixed — one major new significant finding, one significance loss.** `positive_exposure` on CAR[0,+1] flips from clearly insignificant (p=0.978) to highly significant (p=0.0031), driven by a ~13x larger exposure pool. `z_intelligence:broad_downstream` interaction on CAR[0,+20] loses significance (p=0.012 → 0.151). No sign reversals on headline terms. |
| 4 | `run_proposal_gap_supplement` | **Meaningfully changed — flagged for attention.** In the relationship-bundle joint model, the old `real_upstream` significant positive effect (coef 0.047, p=0.0025) vanishes under new `upstream_hardware`/`upstream_cloud`. Simultaneously, `real_downstream → broad_downstream` flips from insignificant (p=0.53) to significantly **negative** (coef −0.0425, p=0.0051) — a genuine sign-flip-plus-significance-crossing. |
| 5 | `relonly_regression` | **Stable headline, but reveals new heterogeneity.** Main regression (PART R1) untouched. Splitting old `upstream` into `upstream_hardware`/`upstream_cloud` shows the effect is driven almost entirely by hardware (cloud weak/n.s.). `downstream_deployer` shows a sign-flipped (negative) CAR[0,+20] coefficient vs. positive coefficients for `downstream_integrator`/`downstream_enabler` — newly visible heterogeneity, not previously detectable under the old business/real split. |
| 6 | `run_relationship_specr` | **Headline significance rate drops, but a strong new single-flag finding emerges.** Share of p<0.05 specs in the relationship-as-X grid falls from 17.9% to 11.4%. But `downstream_deployer` emerges as the single strongest, most significant individual relationship flag in the full-sample main spec (coef −0.019, p=0.0004) — a pattern invisible under the old coarse business/real downstream split. |

---

## 2. Notable cross-cutting findings (with numbers)

### 2.1 "Related firms" subsample filter loses discriminating power (run_econometric_robustness) — METHODOLOGICAL CAVEAT, FLAGGED PROMINENTLY

The event-level robustness script restricts a subsample to firms with *any* coded
relationship to the event's model creator (`related_any <- rowSums(d[, rel_vars]) > 0`).

- **OLD schema:** 2,073 / 5,161 firm-event pairs (**40.2%**) flagged "related."
- **NEW schema:** 5,040 / 5,160 firm-event pairs (**97.7%**) flagged "related."

This is not a modest broadening — it is a collapse of the filter's purpose. With nearly
every sampled firm now "related" to nearly every event (driven by the breadth of
`downstream_deployer` and `downstream_enabler`), the "related firms" subsample is now
almost indistinguishable from the "all firms" sample. The one significance change this
produces — `event_level_related_firms_closed` crossing from p=0.178 (OLD) to p=0.040
(NEW), with R² improving from 0.44 to 0.51 — is most plausibly explained by the
"related" sample simply becoming a less noisy approximation of the *full* sample (tighter
SE: 0.00103 → 0.00048), not by a sharper test of "relatedness" per se.

**This is a methodological problem, not just a footnote.** As currently constructed, the
`event_level_related_firms_*` specs no longer test what they were designed to test
(sensitivity to *excluding* unrelated firms). The comparison file's own authors recommend
tightening the filter under the new schema — e.g., excluding `downstream_deployer`/
`downstream_enabler`-only firms, or requiring a minimum confidence/evidence tier — before
this robustness check can be trusted to do its job.

### 2.2 `positive_exposure` on CAR[0,+1]: insignificant → highly significant (run_missing_analyses) — power gain vs. population-change artifact

- OLD: mean 0.0001, n=238, **p=0.978**
- NEW: mean 0.0023, n=3,184, **p=0.0031**
- Sample size grew **~13.4x** (238 → 3,184).

**Assessment:** this looks more like a definition-changed-the-population effect than a
clean power gain. A pure power gain would show the *same* underlying effect estimated
more precisely as n grows — but here the point estimate itself moved by more than an
order of magnitude (0.0001 → 0.0023), not just its precision. The old `positive_exposure`
(238 obs) was a narrow set of owner/investor/cloud/downstream-business firms; the new
13x-larger pool is dominated by `downstream_integrator`-tagged firms, which is a
*different, much larger population* with a different average short-window reaction, not
a more precisely measured version of the old population. The comparison file itself
attributes the shift to "the new integrator-driven exposure pool... concentrates
short-window reaction in firms that are core AI-product integrators" — i.e., a
composition change, not pure power. **This finding should be treated as provisional**
until decomposed (e.g., does it survive if integrator-only or integrator-excluded subsets
are tested separately?).

### 2.3 Downstream exposure term flips from insignificant to significantly NEGATIVE (run_proposal_gap_supplement) — NEEDS RESEARCH-TEAM ATTENTION

In the relationship-bundle joint model (outcome `mkt_car_20`):

- OLD `real_downstream`: coef −0.0129, **p=0.526** (insignificant)
- NEW `broad_downstream` (= union of `downstream_integrator`, `downstream_deployer`,
  `downstream_enabler`): coef **−0.0425, p=0.0051** (significant, negative)

This is a genuine sign-flip-plus-significance-crossing — not a borderline shift in
magnitude or a p-value drifting across a single threshold, but a coefficient that was
statistically indistinguishable from zero becoming a meaningfully sized, highly
significant negative effect. Compounding this, in the *same* joint model the old
significant positive upstream effect (`real_upstream`: coef 0.047, p=0.0025) **disappears
entirely** under the new `upstream_hardware`/`upstream_cloud` split (coef −0.007, p=0.69;
coef −0.001, p=0.87). Two headline terms in the same specification moved in opposite,
non-trivial ways simultaneously. Given that both changes are driven by broadening
(downstream union now spans 3 categories instead of 2; upstream now categorized by
hardware/cloud rather than business/real confidence tiers), this combination is exactly
the kind of result that needs a second look before being cited as a finding — it could
be a real, sharper signal, or it could be sample composition swamping a previously
cleaner contrast.

### 2.4 Specification curve: overall significance rate drops, but `downstream_deployer` emerges as strongest single effect (run_relationship_specr)

- Relationship-as-X grid: share of p<0.05 specs falls from **17.9% (OLD) to 11.4% (NEW)**
  — roughly a one-third relative drop.
- Subsample grid: 15.7% → 12.7% (smaller drop).
- But in the **full-sample main specification** (car_20, full controls, year FE),
  `downstream_deployer` is the single strongest and most significant relationship flag in
  the entire table: **coef −0.019, p=0.0004**. No old downstream flag
  (`business_downstream`, `real_downstream`) was significant in this same spec.
- Across the full grid, `downstream_deployer` (25.9% of specs p<0.05) and
  `upstream_hardware` (25.2%) are far ahead of all other dimensions; `downstream_enabler`
  (6.8%), `competitor` (0.7%), `downstream_integrator` (0.7%), and `is_owner` (0%) are
  weakest.
- For comparison, the old schema's strongest dimensions were `real_downstream` (40.5%),
  `cloud` (29.4%), `investor` (29.4%) — **none of which map cleanly onto the new
  strongest dimensions.** The qualitative conclusion about *which relationship type
  matters most* has materially shifted, not just the magnitude of an existing result.

This is the clearest example in the whole set of a coarse old category averaging over
heterogeneous sub-populations: the old `business_downstream`/`real_downstream` columns
never isolated "AI deployed as a tool in a non-AI-native business" as a distinct group: that
category (`downstream_deployer`) did not exist before. Its emergence as the strongest
result, with a tight p-value (0.0004) and a sample size in the hundreds, looks like a
genuine new discovery rather than a sample-size artifact — but it is also the most novel
claim in the set and should be corroborated against `relonly_regression`'s independent
finding (2.5 below) before treating it as settled.

### 2.5 Upstream hardware-vs-cloud heterogeneity, and downstream sign-flip on deployer (relonly_regression)

- **Upstream:** OLD combined `upstream` (n=100, 47 events) shows car_5 coef 0.00138
  (p=0.021), car_20 coef 0.00224 (p=0.052, marginal). Splitting into NEW
  `upstream_hardware` (n=169) reproduces the car_5 result almost exactly (coef 0.00133,
  p=0.0085 — *more* significant, not less) while `upstream_cloud` (n=235) is small and
  insignificant throughout (car_5 coef 0.00040, p=0.232; car_20 coef 0.00036, p=0.439).
  **The entire old "upstream" effect is attributable to hardware; cloud carries
  essentially no signal.** This corroborates the independent finding in
  `run_relationship_specr` (2.4 above) that `upstream_hardware` is one of the two
  strongest dimensions in the new schema while `upstream_cloud` is comparatively weak —
  two independently migrated scripts converge on the same heterogeneity.
- **Downstream:** splitting into `downstream_integrator` (n=1356), `downstream_deployer`
  (n=184), `downstream_enabler` (n=372) at car_20 gives coefficients of +0.00162 (p=0.110),
  **−0.00059 (p=0.488)**, and +0.00065 (p=0.394) respectively. `downstream_deployer` is
  the only one with a *negative* sign — consistent in direction (though not magnitude or
  significance, given the small subsample here) with the much stronger, statistically
  significant negative `downstream_deployer` effect found independently in
  `run_relationship_specr` (2.4) and the negative `broad_downstream` effect in
  `run_proposal_gap_supplement` (2.3). **Three independent scripts now point the same
  direction on "deployer-type downstream exposure is negative."** This convergence across
  independently migrated scripts is the single strongest piece of evidence in this whole
  review that the deployer-negative pattern is a real, substantive discovery rather than
  an artifact of any one script's sample or specification choices.

### 2.6 `run_relation_subsample_regressions`: stable, with power-driven new significance

`broad_upstream` (n: 122 → 1,142) and `positive_exposure` (n: 196 → 2,665) both newly
cross into significance (10% and 5% thresholds respectively) while keeping the same
positive sign and similar point estimates (`broad_upstream`: 2.36% → 1.29%;
`positive_exposure`: 1.77% → 1.69%). Because point estimates stayed close while only
precision improved, this case is more consistent with a genuine power gain than the
population-change artifact flagged in 2.2 above — worth noting as a within-set contrast:
not every "old n.s. → new sig." crossing in this review has the same underlying
mechanism.

---

## 3. Overall editorial assessment

The user's working hypothesis is **largely confirmed, with one important refinement**:
the new schema is broader/more inclusive on several dimensions (`upstream_cloud`,
downstream categories generally, `is_investor`), and this broadening has three distinct,
separable consequences visible across the six scripts — not just one:

1. **Mechanical power gains in already-correctly-signed estimates.** Where the new,
   larger subsample produces a similar point estimate with a tighter SE (e.g.,
   `run_relation_subsample_regressions`'s `broad_upstream`/`positive_exposure`, §2.6;
   `relonly_regression`'s `upstream_hardware` reproducing the old `upstream` car_5 result
   at higher significance, §2.5), this is genuinely just added statistical power. **Safe
   to rely on.**

2. **Discriminating-power dilution in broad "any relationship" filters.** Where a filter's
   *entire function* is to separate "related" from "unrelated," broadening every component
   dimension simultaneously breaks the filter (run_econometric_robustness's 40%→98%
   "related firms" sample, §2.1). This is the most serious caveat in the set — it is not
   just a footnote, it invalidates the design intent of that specific robustness check as
   currently coded.

3. **Genuine heterogeneity revealed by finer new categories that didn't exist before.**
   The new schema's role-based split (hardware vs. cloud upstream; integrator vs. deployer
   vs. enabler downstream) is a different *axis* of classification than the old
   business/real evidence-confidence split, not a relabeling. This is where the most
   interesting substantive findings live: hardware-driven upstream effects (§2.5),
   and especially the convergent deployer-negative finding appearing independently in
   `run_relationship_specr` (§2.4) and `relonly_regression` (§2.5), and consistent in sign
   with `run_proposal_gap_supplement`'s `broad_downstream` sign flip (§2.3).

**Genuine new substantive discoveries (worth highlighting in the paper, pending the action
items below):**
- Upstream effect is a hardware story, not a cloud story (§2.5; corroborated by §2.4).
- `downstream_deployer` (AI used as a tool in non-AI-native businesses) carries a
  negative, often significant announcement effect, distinct from and opposite to
  `downstream_integrator`/`downstream_enabler` — corroborated across three independently
  migrated scripts (§2.3, §2.4, §2.5). This is the single most interesting new pattern in
  the whole review.

**Findings that look like statistical artifacts of changed sample composition (need
caveats or robustness checks before relying on them):**
- `run_econometric_robustness`'s "related firms closed" significance crossing (§2.1) —
  filter no longer discriminates; treat the p=0.040 result with caution until the filter
  is tightened.
- `run_missing_analyses`'s `positive_exposure` CAR[0,+1] crossing (§2.2) — point estimate
  moved by 23x, not just precision; likely a population change, not a power gain.
- `run_proposal_gap_supplement`'s simultaneous upstream-effect-vanishing /
  downstream-effect-flipping-negative in the joint model (§2.3) — directionally
  consistent with the deployer-negative discovery above, but in this specific script the
  *joint model*'s absorption of variance across multiple shifted terms at once makes it
  hard to isolate cause; should be checked against a model that doesn't bundle upstream
  and downstream terms together.

---

## 4. Action items for the research team

1. **Fix or caveat the `event_level_related_firms_*` robustness check in
   `run_econometric_robustness` before citing it.** The "related" filter now captures
   97.7% of firm-event pairs (vs. 40.2% under the old schema) and is no longer a
   meaningful sample restriction. Either (a) tighten the filter — e.g., require
   `upstream_hardware`, `is_owner`, `is_investor`, or `downstream_integrator` only,
   excluding `downstream_deployer`/`downstream_enabler`-only matches — and re-run, or
   (b) drop this specific robustness check from the paper and replace it with a
   confidence-tier-based restriction if one exists in the new schema.

2. **Decompose `run_missing_analyses`'s `positive_exposure` CAR[0,+1] result (p=0.0031)
   before using it as evidence.** Re-run with the exposure pool split by which component
   dimension is driving membership (e.g., integrator-only vs. integrator-excluded) to
   determine whether the significant result holds within sub-populations or is an
   artifact of pooling a 13x larger, compositionally different group.

3. **Re-examine `run_proposal_gap_supplement`'s joint relationship-bundle model.** The
   simultaneous disappearance of the upstream effect (p: 0.0025 → 0.69) and emergence of
   a significant negative downstream effect (p: 0.53 → 0.0051) in the same model warrants
   a check with upstream and downstream terms estimated in separate models (not jointly)
   to rule out one term's coefficient shift being a mechanical consequence of the other's
   change in the bundled specification.

4. **Treat the convergent `downstream_deployer`-negative finding as a priority for a
   dedicated robustness section**, given it appears independently and directionally
   consistently in three scripts (`run_relationship_specr` §2.4, `relonly_regression`
   §2.5, and consistent with `run_proposal_gap_supplement`'s broad_downstream flip §2.3).
   Recommend: (a) verify the `downstream_deployer` company list against the codebook to
   confirm coding accuracy for this category specifically (it is the newest, least
   precedented category), and (b) run a dedicated specification with `downstream_deployer`
   as the sole downstream regressor (not bundled into `broad_downstream`) across all
   relevant scripts to confirm consistency of magnitude, not just sign.

5. **Corroborate the upstream hardware-vs-cloud heterogeneity** (§2.5, §2.4) with a
   direct test of whether `upstream_hardware` and `upstream_cloud` coefficients are
   statistically distinguishable from each other (e.g., an interaction or seemingly
   unrelated regression test), rather than relying on separately-estimated subsample
   coefficients that happen to look different.

6. **Do not use the old-schema versions of any of the six scripts' outputs going
   forward** for any spec involving relationship variables — but keep the OLD output
   files (`outputs/*.csv` without `_v2`) archived as-is for traceability, since several
   comparisons above (especially items 2–4) require being able to re-derive the OLD
   numbers if reviewers ask.
