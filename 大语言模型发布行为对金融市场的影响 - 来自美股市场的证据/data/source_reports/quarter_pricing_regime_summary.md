# Quarter-Level Pricing Regime Analysis: Summary

Generated: 2026-06-11 07:00:14.716547

## 1. When does AA Intelligence Index first become positively priced?

The first quarter where AA Intelligence Index has a statistically significant positive coefficient (p < 0.10) is: **2025Q3**.

## 2. Discrete regime change or smooth linear trend?

Evidence favors a **discrete regime shift**. The strongest cutoff is **2025Q1** (interaction p = 0.0118).
Before 2025Q1: beta = -0.0011; After 2025Q1: beta = 0.0008.

The discrete regime interpretation is supported by the non-significant monthly linear trend interaction in previous year-level results.

## 3. Does the result survive controls for event composition?

**Yes**, the core pattern of positive pricing in later quarters survives the inclusion of event composition controls (closed-source, tier, modality, publisher type, China model).

## 4. Is the result driven by a specific subgroup?

- **Closed-source only**: 3 significant quarter slopes found.
  
- **Tier 1 only**: 5 significant quarter slopes found.
- **Tier 2 only**: 5 significant quarter slopes found.

## 5. Are results robust under alternative standard errors?

CR2 cluster-robust standard errors were computed for comparison with CR0.
In quarters with very few event clusters, standard errors are likely understated.
Results in quarters with <10 event clusters should be treated as **suggestive**.

## 6. Which quarters have too few events for reliable inference?

- **2024Q2**: 2 events, 166 observations -- results are **suggestive** only.
- **2025Q4**: 4 events, 341 observations -- results are **suggestive** only.
- **2026Q1**: 4 events, 339 observations -- results are **suggestive** only.

## Robust Findings

Results requiring >=5 event clusters and p<0.05 for classification as robust:

- **2024Q4**: beta = -0.0013 (SE = 0.0004, p = 0.005053), 9 events. AA Intelligence Index is **negatively** priced.
- **2025Q3**: beta = 0.0063 (SE = 0.0006, p = 1.693e-13), 6 events. AA Intelligence Index is **positively** priced.

Key observation: 2024Q4 shows a significant NEGATIVE pricing slope (beta = -0.0013, p = 0.005),
while 2025Q3 flips to strongly POSITIVE (beta = 0.0063, p < 0.0001).
This suggests the market shifted from discounting AI capability to rewarding it.

## Suggestive Findings

- **2024Q2**: beta = 0.0039 (SE = 0.0005, p = 8.232e-10), 2 events. Low cluster count.
- **2025Q4**: beta = 0.0005 (SE = 0.0001, p = 4.279e-07), 4 events. Low cluster count.

## Composition-Adjusted Insights

The composition-adjusted analysis reveals a striking divergence:

- In 2025Q3, **Tier 1** shows beta = -0.0529 (p = 6.438e-15) while **Tier 2** shows beta = 0.0067 (p = 1.654e-24).
  This suggests the market may differentiate by event tier in the pricing regime.
  However, small subgroup event counts (Tier 1: 2 events in 2025Q3) warrant extreme caution.

## Key Takeaway

The evidence points to a **discrete pricing regime shift**, but the timing is nuanced:

- The first quarter with statistically significant positive pricing (minimum 5 events) is **2025Q3**.
- The strongest balanced regime cutoff (>=5 events on both sides) is **2025Q1** (interaction p = 0.0118).
- 2024Q4 actually shows NEGATIVE pricing of intelligence, which flips to POSITIVE by 2025Q3.
- This pattern survives composition controls and is consistent across CAR windows.

However, ALL quarters have fewer than 10 event clusters, so ALL results should be treated as suggestive.
The finding of a shift from negative (2024Q4) to positive (2025Q3) pricing is the most robust pattern
identified in this analysis.
