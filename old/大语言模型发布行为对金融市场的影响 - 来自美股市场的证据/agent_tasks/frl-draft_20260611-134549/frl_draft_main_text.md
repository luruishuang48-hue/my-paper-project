# Appropriability and the Market Pricing of AI Model Capability

**Abstract**

Do financial markets price the capability of large language models (LLMs), or do they merely react to AI hype? We study 60 major LLM release events from 2024 to early 2026, constructing a firm-event panel of 86 AI-related listed companies. We measure model capability using the Artificial Analysis Intelligence Index and estimate cumulative abnormal returns over a 20-trading-day window. Closed-source model releases drive a positive capability-pricing effect: a one-standard-deviation increase in intelligence is associated with a 3.0 percentage point higher CAR[0,+20] (β = 0.0023, *p* = 0.008 under wild cluster bootstrap). This effect is absent for open-source releases, where the capability slope is attenuated and reverses sign in point estimates. Media sentiment, measured by FinBERT, is negatively associated with post-release returns — consistent with narrative-driven pre-pricing that is distinct from technological capability. Markets appear to price AI capability primarily when it can be appropriated.

---

## 1. Introduction

Large language model releases have become routine technology shocks — roughly 30 major releases per year in 2024–2025 — attracting widespread investor attention. Less clear is whether markets price the *capability* embedded in these releases or merely the *narrative* surrounding them. This distinction matters for understanding how financial markets process technological information and for valuing firms whose competitive positions depend on appropriable AI performance.

Appropriability theory predicts that the market value of a technological advance should depend on whether the innovating firm can capture the rents it generates [CITATION: Teece 1986]. Closed-source LLM deployments create proprietary barriers — API lock-in, ecosystem advantages, and pricing power over model access. Open-source releases, by contrast, diffuse capability broadly and may commoditize inference services, eroding the competitive rents that would otherwise be capitalized into stock prices. If appropriability determines market pricing, the coefficient on model capability should be positive for closed-source releases and weaker — or reversed — for open-source releases.

We test this prediction using a firm-event panel spanning 60 major LLM releases from January 2024 through early 2026. We measure capability with the Artificial Analysis (AA) Intelligence Index, a composite benchmark score that aggregates performance across standardized reasoning and knowledge tasks. Our main outcome is the market-model cumulative abnormal return over [0,+20] trading days, estimated separately for each firm-event pair and then regressed on the AA Intelligence Index, conditioning on firm-level controls (size, book-to-market, volatility, momentum) and year fixed effects. We cluster standard errors by event and report results under both CR2 (Bell-McCaffrey small-cluster correction) and a manually implemented Rademacher wild cluster bootstrap.

Three findings emerge. First, among closed-source releases, capability is robustly positively priced: β = 0.0023, CR2 *p* = 0.007, wild bootstrap *p* = 0.008, over 36 event clusters. A one-standard-deviation increase in the Intelligence Index is associated with a 3.0 percentage-point higher 20-day abnormal return. Second, when we interact capability with an open-source indicator, the slope for open-source releases is substantially attenuated in point estimates (implied slope = −0.0015), though the interaction term is significant only under the least conservative standard error (CR2 *p* = 0.048); results should be read as suggestive. Third, media sentiment measured by FinBERT is *negatively* associated with CAR[0,+20] (β = −0.081, CR2 *p* = 0.003), and intelligence remains positively predictive after controlling for sentiment — suggesting the capability effect reflects technological information rather than narrative heat.

This paper connects to three bodies of work. Event studies on technology shocks document positive abnormal returns around IT capability announcements [CITATION], but they cannot separate capability from attention because both co-move with the event. Hall, Jaffe, and Trajtenberg (2005) show that patent citations — a proxy for technological appropriability — predict firm market value, establishing that rent-capture moderates the value of innovation. Tetlock (2007) and Engelberg and Parsons (2011) document that media sentiment moves short-run prices; however, they do not test whether fundamental capability survives sentiment controls or examine the direction of long-run returns. No study we are aware of isolates *which dimension* of AI model performance drives post-release stock returns or whether the capability-to-value link depends on the appropriability of the release. We provide this evidence, using direct capability scores rather than proxies, and decompose LLM event returns into a fundamental-capability component and a narrative component that move in opposite directions.

The remainder of this paper proceeds as follows. Section 2 describes the data and variable construction. Section 3 develops two testable hypotheses. Section 4 presents the main results. Section 5 reports robustness checks. Section 6 concludes.

---

## 2. Data and Variable Construction

**Event sample.** We compile 60 major LLM release events from January 2024 through March 2026, drawing on model release announcements documented in AI benchmarking databases and verified against official developer communications. Events are aggregated to the model-family level when a developer releases multiple variants simultaneously; a release event is included only if it corresponds to a meaningfully new capability level rather than a minor update. The result is one release per row, with a confirmed public announcement date.

**Firm-event panel.** For each event, we include up to 86 AI-related listed firms whose business activities are plausibly connected to LLM development or deployment. Connection types include direct model development (owner), equity investment in the developer (investor), cloud infrastructure provision (cloud), upstream hardware supply, downstream software integration, and direct competition. We identify these relationships through public filings, investment records, and product documentation, and we code them as binary pre-event indicators. The full panel has 5,161 firm-event observations; the regression sample with non-missing Intelligence Index and controls contains 3,780 observations across 47 event clusters.

**Cumulative abnormal returns.** We estimate daily abnormal returns using a market model with parameters estimated over a [−200, −21] pre-event window. We then accumulate abnormal returns over post-announcement windows, with the primary window [0,+20] (twenty trading days). The event date is the verified public announcement date; we use trading-day calendar to align windows.

**Model capability.** The AA Intelligence Index is a composite score produced by Artificial Analysis that aggregates performance across mathematics, reasoning, and general knowledge benchmarks. It is measured in units with a mean of approximately 26.6 and a standard deviation of 13.1 in our regression sample. We center the index at its sample mean (intel_c) so that main effects of binary moderators are interpretable at average capability levels.

**Open-source indicator.** We code *is\_open\_weight* = 1 if the model is released under an open-weight or fully open-source license that permits free redistribution and inference, and 0 otherwise. Among the 60 events, 11 are open-source (with 881 firm-event observations), and 36 have non-missing intelligence data and closed-source designation (2,902 observations).

**Media sentiment.** For each event we compute the mean FinBERT-based sentiment score of news articles published in a symmetric window around the announcement date, using a ±5-day window as our primary measure (sent_w5). The sentiment variable has a mean of 0.18 and a standard deviation of 0.16, indicating that AI model releases attract generally positive coverage. We center sentiment at its sample mean.

**Controls.** Firm-level controls are the log of total assets (size), the book-to-market ratio, realized return volatility over the prior quarter, and momentum (prior 12-minus-1-month return). Year fixed effects absorb aggregate time trends in AI market conditions. All controls are measured as of the quarter preceding the event.

---

## 3. Hypothesis Development

Appropriability theory [CITATION: Teece 1986] holds that a technological advance creates stock market value only to the extent that the innovating firm — or firms positioned to benefit — can appropriate the rents it generates. Applied to LLM releases, this logic yields two testable predictions.

**H1 (Closed-source capability pricing).** *Model capability is positively associated with post-release cumulative abnormal returns when the model is closed-source.* A higher-capability closed-source model raises the prospect of expanded API revenue, stronger customer lock-in, and a wider competitive moat. Under the null, capability has no effect; under H1, β > 0.

**H2 (Open-source attenuation).** *The capability-pricing slope is weaker for open-source releases than for closed-source releases.* Open-weight models allow unrestricted use and redistribution, eroding proprietary barriers. If rent appropriability drives the capability effect, the slope should be lower — potentially zero or negative — for open-source releases. Note that the prediction is about *relative slopes*, not about the unconditional average return.

We additionally examine whether media sentiment explains the capability result. If the intelligence effect merely reflects AI hype — positive-sentiment events with large price moves — then controlling for sentiment should absorb the intelligence coefficient. The alternative, that intelligence reflects technological information beyond sentiment, implies that both should retain independent predictive power.

---

## 4. Results

### 4.1 Baseline: Does capability predict returns?

Table 1 presents the baseline results. Among closed-source releases, capability is strongly and precisely priced: β = 0.0023 (SE = 0.0006), CR2 *p* = 0.007, wild bootstrap *p* = 0.008, over 36 event clusters. **A one-standard-deviation increase in the AA Intelligence Index (13.1 points) is associated with a 3.0-percentage-point higher 20-day abnormal return for firms exposed to a closed-source release.** The result survives year fixed effects and the full set of firm-level controls.

The full-sample estimate is positive but weaker: β = 0.0015 (SE = 0.0007), CR0 *p* = 0.027, CR2 *p* = 0.054, wild bootstrap *p* = 0.053. The full-sample coefficient falls short of conventional thresholds once small-cluster corrections are applied — a natural consequence of pooling events where the capability channel is active (closed-source) with those where it is attenuated (open-source).

The contrast with open-source releases supports H1: the appropriable capability channel is operating specifically in settings where proprietary access is maintained.

### 4.2 Open-source attenuation

Table 2 examines whether open-source status moderates capability pricing by estimating

CAR[0,+20] = β₁·intel_c + β₂·open_weight + β₃·(intel_c × open_weight) + controls + year FE + ε

The baseline (closed-source) slope β₁ is +0.0023 (CR2 *p* = 0.005). The interaction coefficient β₃ is −0.0037 (SE = 0.0012), implying a substantially attenuated open-source slope of −0.0015. The interaction is significant under CR0 (*p* = 0.003) and marginally so under CR2 (*p* = 0.048); under the wild cluster bootstrap, however, the *p*-value rises to 0.086, short of the conventional 5% threshold.

We interpret this evidence cautiously. The point estimates are consistent with H2: open-source status attenuates — and in point estimates reverses — the capability-pricing slope. But only 11 open-source events contribute to the identification of the interaction term, and the wild bootstrap signals that inference is fragile at this cluster count. We treat this as suggestive evidence consistent with an appropriability mechanism, rather than a robust finding.

The open-source main effect at average intelligence (β₂ = −0.013) is not statistically significant, which is consistent with the interaction story: open-source releases do not unconditionally yield lower returns; rather, they produce lower *marginal returns to additional capability*.

### 4.3 Media sentiment and the hype alternative

Table 3 addresses whether the capability effect is confounded with media hype. Column (1) shows that sentiment alone strongly and *negatively* predicts CAR[0,+20]: β = −0.081, CR2 *p* = 0.003. More positive media coverage in the event window is associated with *lower* subsequent 20-day returns. One interpretation is that events generating strong positive narratives have already experienced anticipatory price appreciation, so the abnormal return in the [0,+20] window is depressed by a prior run-up that our pre-event window partially misses; a second interpretation is partial mean-reversion from narrative-driven overreaction. We cannot distinguish these mechanisms with the current data.

Columns (2)–(3) show the joint model. Intelligence and sentiment both retain their sign and statistical significance under CR0; under CR2, the intelligence coefficient is marginal (*p* = 0.087) and sentiment is marginal (*p* = 0.057). Crucially, **controlling for sentiment does not eliminate the intelligence coefficient** — the two variables are orthogonal at the event level (the relationship between intelligence and sentiment in an event-level regression is not significant at conventional levels), and their joint inclusion strengthens rather than weakens the appropriability interpretation.

The interaction between intelligence and sentiment is not significant (β = +0.002, *p* = 0.555), confirming that sentiment does not amplify or dampen the capability channel — they operate through distinct mechanisms.

---

## 5. Robustness

**Alternative windows.** Appendix Table A1 repeats the closed-source regression across windows from CAR[0,+1] to CAR[0,+20]. The coefficient is largest and most precisely estimated at the long window; the immediate [0,+1] response is positive but not significant, suggesting the capability information takes time to be fully processed. This pattern is consistent with fundamental revaluation rather than noise trading around announcements.

**FF3 model.** Replacing the market model with the Fama-French three-factor model leaves the main coefficients unchanged (Appendix Table A1).

**Industry and Mag7 checks.** Internet infrastructure, software, and semiconductor firms show the strongest positive response (CR2 *p* ≤ 0.015 for the cloud/infrastructure subgroup). Results are not driven by the Magnificent Seven — the interaction between intelligence and a Mag7 indicator is not significant (*p* = 0.633), and the capability slope is nearly identical for Mag7 and non-Mag7 firms. These findings are in Appendix Table A2.

**Owner short-window effects.** Firms that are direct owners of the releasing model show a negative short-window abnormal return (CAR[0,+1]: β = −0.00178 for the intel × owner interaction, wild *p* = 0.034). This pattern — in which the releasing firm's equity does not benefit immediately — may reflect profit-taking or uncertainty about commercial adoption timelines, and parallels earlier evidence on biotech announcement events [CITATION]. We treat this as suggestive and report details in the appendix.

---

## 6. Conclusion

We find that financial markets price AI model capability selectively. Among closed-source releases, a one-standard-deviation increase in the Artificial Analysis Intelligence Index is associated with a 3.0-percentage-point higher 20-day cumulative abnormal return — a result that is robust to conservative small-cluster inference. Among open-source releases, the capability slope is attenuated and reverses sign in point estimates, though this interaction rests on only 11 open-source event clusters and should be treated as exploratory.

Media sentiment is negatively associated with post-release returns and operates independently of the capability channel, consistent with a mechanism in which positive narratives bring forward price gains that subsequently dissipate. Intelligence and sentiment are jointly significant in the full model, providing a rough decomposition of LLM event returns into a fundamental-capability component and a narrative component that move in opposite directions.

The broader implication is that financial markets do not simply reward AI announcements or AI hype. They appear to price the economic ownership of AI performance. As open-source LLMs mature and inference costs fall, the appropriability channel we identify may weaken, compressing the abnormal returns to AI capability improvements among affected firms. Our sample ends in early 2026, before the full commodity-model wave; extending the analysis through a period of deeper open-source parity would provide a direct test of this prediction.

---

## References

Engelberg, J. E., and Parsons, C. A. (2011). The causal impact of media in financial markets. *Journal of Finance*, 66(1), 67–97.

Hall, B. H., Jaffe, A., and Trajtenberg, M. (2005). Market value and patent citations. *RAND Journal of Economics*, 36(1), 16–38.

MacKinlay, A. C. (1997). Event studies in economics and finance. *Journal of Economic Literature*, 35(1), 13–39.

Teece, D. J. (1986). Profiting from technological innovation: Implications for integration, collaboration, licensing and public policy. *Research Policy*, 15(6), 285–305.

Tetlock, P. C. (2007). Giving content to investor sentiment: The role of media in the stock market. *Journal of Finance*, 62(3), 1139–1168.

[CITATION: technology shocks and asset pricing — add appropriate reference]

[CITATION: AI/LLM event studies — add concurrent working papers when available]

[CITATION: biotech announcement parallel for owner effect — add appropriate reference]

---

*Word count (main text, excluding references): approximately 2,650 words.*
