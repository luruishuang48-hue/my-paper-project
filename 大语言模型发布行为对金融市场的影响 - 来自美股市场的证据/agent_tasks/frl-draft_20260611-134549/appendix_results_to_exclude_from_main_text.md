# Results to Exclude from Main Text (Appendix Only)

These results are available in the exploratory analysis but should NOT appear in the main text of the FRL submission. They may be referenced briefly (one sentence) or placed in the appendix.

---

## 1. Specification Curve Analysis (966 specifications)

**Why excluded**: Reporting SCA in a paper where the main design was already chosen based on prior exploration creates a circularity. SCA is most credible as a sensitivity analysis for a pre-specified design.

**Appendix treatment**: Table A4 may show median coefficient, interquartile range, and share positive-and-significant, with a note that the main specification falls in the upper portion of the distribution.

**One sentence allowed in main text**: "Results are broadly consistent across 966 alternative specifications varying control sets and factor models (Appendix Table A4)."

---

## 2. Tier 1 vs. Tier 2 Subsamples

**Why excluded**: The formal interaction term is not significant (p = 0.888). The apparent difference across tiers is driven by subsample estimation variability, not an identifiable moderating mechanism. Reporting it risks a false-precision narrative.

**Appendix treatment**: Appendix Table A2 may include a brief note.

**Do NOT include in main text.**

---

## 3. Investor and Cloud Interactions (intel_c × investor; intel_c × cloud)

**Why excluded**:
- investor: CR2 p = 0.050 (borderline), wild p = 0.126 (not robust)
- cloud: CR2 p = 0.100, wild p = 0.137 (both not robust)

**Appendix treatment**: Table A3 shows all relationship-type interactions for completeness.

**One sentence allowed in main text** (in Section 5): "Interactions between capability and investor/cloud status produce negative point estimates consistent with the appropriability narrative but do not survive conservative inference (Appendix Table A3)."

---

## 4. Owner Short-Window Negative Effect

**Why semi-included**: The intel_c × owner interaction is significant under wild bootstrap for car_1 (p = 0.034) and car_2 (p = 0.046). This is the *most robust* interaction result aside from the open-source channel.

**Main text treatment**: One paragraph in Section 5 (Robustness) noting the pattern and its potential interpretation.

**Full details**: Appendix Table A3.

---

## 5. Quarterly Regime / Year-by-Year Evolution

**Why excluded**: Year-level interaction with only a handful of events per year (5 in 2026, 20 in 2024) produces extremely noisy estimates. The apparent 2024→2025 shift is suggestive but not robust.

**Do NOT claim a structural break in the main text.**

**One sentence allowed**: "Year fixed effects capture aggregate trends; the positive capability effect appears concentrated in 2025 events, though this pattern should be interpreted cautiously given the event count per year."

---

## 6. Mag7 Analysis

**Why excluded**: The interaction is not significant (p = 0.633). The individual company decomposition (NVIDIA vs. Tesla) is descriptive and not identified.

**One sentence allowed in Section 5**: "Results are not driven by the Magnificent Seven — the intelligence slope is nearly identical for Mag7 and non-Mag7 firms, and a Mag7 interaction is not significant."

---

## 7. FinBERT Sentiment Quartile Subsamples

**Why excluded**: Subsample-by-sentiment-quartile has only ~10–11 event clusters per quartile; CR2 destroys significance completely.

**Do NOT include. The joint model in Table 3 captures the sentiment story cleanly.**

---

## 8. Chinese Model Subsample

**Why excluded**: Only 7 independent events; results not identifiable.

**Mention only in data section limitations if needed.**

---

## Summary

| Result | Main text | Section | Appendix |
|---|---|---|---|
| Closed-source effect | ✓ MAIN | §4.1 | Table A1 (windows) |
| Full-sample effect | ✓ MAIN | §4.1 | — |
| Open-source interaction | ✓ secondary (caution) | §4.2 | — |
| Sentiment negative | ✓ MAIN | §4.3 | — |
| Owner short-window | ✓ brief | §5 | Table A3 |
| Industry heterogeneity | ✓ brief | §5 | Table A2 |
| Mag7 check | ✓ one sentence | §5 | Table A2 |
| SCA / 966 specs | one sentence | §5 | Table A4 |
| Tier 1 vs Tier 2 | ✗ exclude | — | Table A2 note |
| Investor/cloud interactions | one sentence | §5 | Table A3 |
| Quarterly/year evolution | one sentence | §5 | — |
| Sentiment quartile subsample | ✗ exclude | — | — |
| Chinese model subsample | ✗ exclude | — | data note |
