# Tables and Figures Plan — FRL Draft

## Table 1. Sample and Baseline Capability Pricing

**Title**: Baseline Effect of AI Model Capability on Cumulative Abnormal Returns

**Columns**:
1. Full sample, CAR[0,+20], market model — CR0
2. Closed-source only, CAR[0,+20], market model — CR0
3. Full sample, CAR[0,+20] — adding CR2 p and Wild p as extra rows below coefficients
4. Closed-source only, CAR[0,+20] — adding CR2 p and Wild p as extra rows below coefficients

**Rows (key variables)**:
- AA Intelligence Index (intel_c) — coefficient + SE
- Year FE: Yes
- Firm controls: Yes (size_log_assets, bm_ratio, volatility, momentum)
- N (observations)
- N (event clusters)
- R²

**Below the main coefficients, add three-row block for main variable**:
- CR0 p: [value]
- CR2 p: [value]
- Wild bootstrap p: [value]

**Notes**:
"Dependent variable is the market-model cumulative abnormal return over [0,+20] trading days. intel_c is the AA Intelligence Index centered at its sample mean (26.6). Firm controls are log total assets, book-to-market ratio, prior-quarter volatility, and prior 12-minus-1-month momentum. Standard errors are clustered by event (final_event_id). CR2 uses the Bell-McCaffrey small-cluster bias correction. Wild bootstrap p-values use B = 4,999 Rademacher draws with the impose-null approach. + p<0.10, * p<0.05, ** p<0.01, *** p<0.001."

---

## Table 2. Open-Source Appropriability Interaction

**Title**: The Role of Appropriability: Closed-Source vs. Open-Source Capability Pricing

**Estimation equation**:
CAR[0,+20] = β₁·intel_c + β₂·open_weight + β₃·(intel_c × open_weight) + controls + year FE + ε

**Columns**:
1. Interaction model — CR0 standard errors
2. Interaction model — CR2 standard errors
3. [Optional] Implied slopes panel: coefficient and 95% CI for closed-source slope (β₁) and open-source slope (β₁ + β₃)

**Rows (key variables)**:
- intel_c (closed-source baseline slope) — coefficient + SE
- is_open_weight (main effect at mean intelligence) — coefficient + SE
- intel_c × is_open_weight (interaction) — coefficient + SE
- [Implied] Open-source slope (β₁ + β₃) — compute as linear combination, show SE and p
- Year FE: Yes
- Firm controls: Yes
- N, event clusters, R²

**Three-row block for interaction term**:
- CR0 p: 0.003**
- CR2 p: 0.048*
- Wild bootstrap p: 0.086+

**Notes**:
"This table estimates the interaction between model capability and open-source status. is_open_weight = 1 if the model is released under an open-weight or open-source license. The implied open-source slope is computed as the sum of the intel_c and intel_c×open_weight coefficients. The interaction term is significant under CR0 and marginally significant under CR2; the wild bootstrap p-value exceeds 0.05, so this result should be interpreted with caution. All other notes as in Table 1."

---

## Table 3. Media Sentiment and Robustness

**Title**: Media Sentiment, Model Capability, and CAR[0,+20]

**Estimation**: CAR[0,+20] regressed on various combinations of intel_c and sent_c5 (centered FinBERT sentiment)

**Columns**:
1. Sentiment only: CAR ~ sent_c5 + controls + year FE
2. Intelligence only: CAR ~ intel_c + controls + year FE (full sample, for comparison)
3. Joint: CAR ~ intel_c + sent_c5 + controls + year FE
4. Joint + CR2 SE (same as col 3 but reporting CR2 p-values)

**Rows (key variables)**:
- sent_c5 — coefficient + SE (rows 1, 3, 4)
- intel_c — coefficient + SE (rows 2, 3, 4)
- Year FE: Yes
- Firm controls: Yes
- N, event clusters, R²

**Key numbers to display**:
| | Col 1 | Col 2 | Col 3 | Col 4 (CR2) |
|---|---|---|---|---|
| sent_c5 | −0.081*** | — | −0.061* | −0.061+ |
| intel_c | — | +0.00152* | +0.00158* | +0.00158+ |

**Notes**:
"sent_c5 is the FinBERT mean sentiment score over a ±5-day event window, centered at its sample mean (0.18). Sentiment is available for approximately 3,068 observations. Columns 3–4 present the joint model; note that the sample size falls relative to Column 2 due to missing sentiment. CR2 p-values are shown in Column 4. The correlation between intel_c and sent_c5 at the event level is not statistically significant (p = 0.317), confirming that the two predictors are orthogonal. All other notes as in Table 1."

---

## Figure 1. Estimated Capability-Pricing Slopes

**Title**: Model Capability and CAR[0,+20]: Closed-Source vs. Open-Source

**Type**: Coefficient plot (dot + 95% CI)

**Rows**:
- Closed-source slope: +0.00226 (95% CI from CR2)
- Open-source slope: −0.00148 (95% CI from CR2 linear combination)
- Full sample slope: +0.00152 (95% CI from CR2)

**Axis labels**: x-axis = "Intelligence slope on CAR[0,+20] (percentage points per index point)"; vertical dashed line at zero

**Caption**: "Figure 1 displays point estimates and 95% confidence intervals for the marginal effect of a one-unit increase in the AA Intelligence Index on 20-day cumulative abnormal returns, estimated separately for closed-source releases (left panel) and implied from the interaction model for open-source releases (right panel). Confidence intervals use CR2 standard errors. The closed-source estimate is robust to wild cluster bootstrap (p = 0.008); the open-source attenuation is only marginally significant under CR2 (p = 0.048) and not under wild bootstrap (p = 0.086)."

---

## Appendix Tables

**Table A1**: Closed-source regression across windows (car_1 through car_20) and FF3 model
**Table A2**: Industry subgroup results and Mag7 check
**Table A3**: Full interaction model with all relationship types (owner, investor, cloud)
**Table A4**: Full specification curve summary statistics (966 specifications; median coefficient, share significant by sign)
