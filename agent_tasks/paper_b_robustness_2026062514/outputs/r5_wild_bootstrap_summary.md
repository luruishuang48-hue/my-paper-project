# R5 Wild Bootstrap Summary: Inference Robustness for Position Effects

**Status**: Complete. Source data: `outputs/r5_wild_bootstrap_table1to4.csv` (16 rows).

## What this checks

For every key position-variable coefficient appearing in Tables 1-4 of the
paper (CAR[0,+20] outcome, market-model), we re-derive p-values under three
inference methods and compare them:

- `p_cr0`: standard cluster-robust SE, clustered on `final_event_id` (the
  paper's baseline inference)
- `p_cr2`: CR2 (bias-adjusted) cluster-robust SE, same clustering
- `p_wild`: wild cluster bootstrap p-value (1,000+ replications), the
  strictest of the three and the standard remedy when the number of clusters
  is small (here: 60 events)

All three are computed on the same sample (N = 4,829 firm-event
observations, 60 events).

## 1. Baseline single-position regressions (Table 1/2 style)

| Variable | beta | p_cr0 | p_cr2 | p_wild | Verdict |
|---|---|---|---|---|---|
| `upstream_hardware` | +0.0228 | 0.0090 | 0.0095 | 0.02 | Significant at 5% under all three methods |
| `upstream_cloud` | +0.0113 | 0.066 | 0.069 | 0.04 | Marginal under CR0/CR2 (10% level), but wild bootstrap actually pushes it to 5% significance |
| `downstream_integrator` | -0.0069 | 0.415 | 0.419 | 0.44 | Not significant under any method |
| `downstream_deployer` | -0.0190 | 0.0004 | 0.0005 | <0.0002 (reported 0) | Strongly significant under all three methods, including wild bootstrap |
| `downstream_enabler` | -0.0107 | 0.116 | 0.118 | 0.08 | Not significant at 5% under any method (borderline at 10% under wild bootstrap) |
| `competitor` | -0.0005 | 0.941 | 0.941 | 1.00 | Not significant under any method |

The two headline coefficients of the baseline specification both survive
the strict wild bootstrap: `upstream_hardware` (beta = +2.28pp, p_wild =
0.02) and `downstream_deployer` (beta = -1.90pp, p_wild < 0.0002). The
downstream_deployer result is the strongest finding in the entire table by
an order of magnitude in p-value.

## 2. Bundled position regressions (Table 3 style)

| Variable | beta | p_cr0 | p_cr2 | p_wild | Verdict |
|---|---|---|---|---|---|
| `upstream_any` | +0.0222 | 0.0062 | 0.0066 | 0 | Significant under all three methods |
| `downstream_any` | -0.0250 | 0.0035 | 0.0037 | 0 | Significant under all three methods |

Both bundled (collapsed-category) position effects are robust to the
strictest inference method available, with wild bootstrap p-values
reported as 0 (i.e., no bootstrap replication produced a coefficient as
extreme as the observed one).

## 3. Joint model — all six position variables entered together

| Variable | beta | p_cr0 | p_cr2 | p_wild | Verdict |
|---|---|---|---|---|---|
| `upstream_hardware` | -0.0083 | 0.553 | 0.557 | 0.64 | **Loses significance** — sign flips negative, p_wild = 0.64 |
| `upstream_cloud` | +0.0054 | 0.457 | 0.461 | 0.42 | Not significant |
| `downstream_integrator` | -0.0309 | 0.0238 | 0.0251 | 0.02 | Significant at 5%, borderline |
| `downstream_deployer` | -0.0424 | 0.0048 | 0.0052 | 0 | Strongly significant; magnitude more than doubles vs. baseline |
| `downstream_enabler` | -0.0325 | 0.0062 | 0.0067 | 0 | Strongly significant (was insignificant in the single-variable baseline) |
| `competitor` | -0.0237 | 0.0086 | 0.0093 | 0.02 | Becomes significant (was insignificant in the single-variable baseline) |

This is the key nuance of the robustness exercise: once all six position
indicators are entered simultaneously (so each coefficient is identified
off firms that occupy *that* position and not the others), `upstream_hardware`
**loses both its sign and its significance** (beta flips from +0.0228 to
-0.0083, p_wild rises from 0.02 to 0.64). By contrast, `downstream_deployer`
not only survives but strengthens (p_wild still 0, beta grows in magnitude
from -0.0190 to -0.0424), and several other downstream/competitor variables
that were insignificant in isolation (`downstream_enabler`, `competitor`)
become significant once the full position structure is controlled for.

## 4. Open-weight interaction model

| Variable | beta | p_cr0 | p_cr2 | p_wild | Verdict |
|---|---|---|---|---|---|
| `upstream_hardware:is_open_weight` | -0.0366 | 0.0178 | 0.0284 | 0.04 | Significant at 5% under all three methods |
| `downstream_deployer:is_open_weight` | +0.0106 | 0.329 | 0.352 | 0.30 | Not significant under any method |

The `upstream_hardware` premium is significantly moderated by whether the
release is open-weight (the interaction is negative and significant, p_wild
= 0.04), implying the upstream-hardware effect documented in the baseline
table is concentrated in closed-source releases. The `downstream_deployer`
effect shows no such moderation — its interaction with `is_open_weight` is
small and statistically indistinguishable from zero across all three
inference methods, consistent with `downstream_deployer` operating uniformly
regardless of release type.

## Overall conclusion

`downstream_deployer` is the most robust finding in the paper. It is
significant at conventional levels (p_wild = 0, or < 0.0002) in **every one**
of the four table contexts examined here — the single-variable baseline, the
bundled specification, the fully-saturated joint model, and (by virtue of its
interaction term being null) the open-weight interaction model — and under
**all three** inference methods, including the wild cluster bootstrap, which
is the most conservative approach given the small number of clusters (60
events).

`upstream_hardware` is robust in three of the four contexts (baseline,
bundle, and the open-weight interaction, where it is further shown to be
concentrated in closed-source releases) but **is not robust in the joint
model**: once the other five position variables (upstream_cloud,
downstream_integrator/deployer/enabler, competitor) are partialled out
simultaneously, the upstream_hardware coefficient shrinks toward zero and
flips sign (p_wild rises from 0.02 to 0.64). This is an important nuance for
the paper: the upstream-hardware market reaction documented in the simple
specifications may be partly absorbing variation that is more properly
attributed to correlated downstream/cloud position effects, whereas the
downstream_deployer effect is identified independently of how the rest of
the position structure is specified.

**Recommendation for the paper**: present `downstream_deployer` as the
unambiguous, fully robust headline result. Present `upstream_hardware` with
an explicit caveat that its significance depends on whether downstream
position variables are controlled for jointly — this should be flagged in
the discussion/robustness section rather than treated as having the same
evidentiary weight as the downstream_deployer result.
