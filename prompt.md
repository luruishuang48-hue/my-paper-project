# Task: Write a Finance Research Letters Draft from an Exploratory AI Event Study

## Objective

Write a concise English manuscript suitable for submission to *Finance Research Letters*.

The current full draft is an exploratory screening report. It contains many results, including specification curve analysis, multiple windows, multiple ability measures, relationship heterogeneity, quarterly regime tests, industry groups, Mag7, and media sentiment.

For the FRL draft, do NOT write a broad working paper. Write a short, focused finance letter around one core question:

**Do financial markets price AI model capability, and does this pricing depend on whether the capability is proprietary and appropriable?**

The paper’s central thesis should be:

**Markets do not simply reward AI model releases or AI hype. They price model capability primarily when the capability is closed-source and commercially appropriable. Open-source releases weaken or reverse this capability-pricing channel.**

## Very Important: Remove P-Hacking Risk

Do NOT include specification curve analysis.

Do NOT mention that the current results came from a broad screening exercise.

Do NOT write “we examine many windows/specifications/subsamples and find…”.

Do NOT present a long list of eight or ten findings.

Do NOT use CAR[0,+5] or other windows as if selected after looking at results.

Do NOT emphasize Tier 2 > Tier 1, quarterly breakpoints, Mag7 heterogeneity, investor/cloud heterogeneity, or owner effects as main findings.

The FRL version must look like a hypothesis-driven paper with a small number of pre-specified tests.

Lock the main design as follows:

* Main dependent variable: CAR[0,+20].
* Main independent variable: AA Intelligence Index.
* Main mechanism: closed-source versus open-source appropriability.
* Main inference: CR2 and wild cluster bootstrap, with CR0 reported only for comparison.
* Main robustness: media sentiment and media attention / macro controls if available.
* Secondary windows: CAR[0,+1] and CAR[0,+15] only in robustness or appendix, not as core evidence.

## Required Story

The manuscript should develop the following logic:

1. LLM releases are observable technology shocks.
2. Model capability should matter for firm valuation only if it can be appropriated and monetized.
3. Closed-source models create proprietary rents, API revenue potential, ecosystem lock-in, and commercial barriers.
4. Open-source models diffuse capability more broadly and may commoditize model services.
5. Therefore, the market should price model capability positively for closed-source releases, but the slope should be weaker or negative for open-source releases.
6. Media sentiment captures narrative heat, not technological capability. If the intelligence result survives sentiment and attention controls, the effect is not merely AI hype.

## Main Empirical Results to Use

Use the following results as the core results.

### Main result 1: Closed-source capability pricing

Closed-source CAR[0,+20]:

* coefficient approximately +0.00232
* CR0 p = 0.001
* CR2 p = 0.007
* wild cluster bootstrap p = 0.008
* 36 event clusters

Interpretation:

Closed-source model capability is robustly positively priced by the market.

This is the strongest and most reliable result in the paper.

### Main result 2: Full-sample effect is positive but weaker

Full-sample CAR[0,+20]:

* coefficient approximately +0.00152
* CR0 p = 0.027
* CR2 p = 0.054
* wild cluster bootstrap p = 0.053
* 47 event clusters

Interpretation:

The full-sample effect is positive but only marginally robust under small-cluster corrections. Therefore, the paper should not oversell the unconditional full-sample result. It should use the full-sample result as motivation and then emphasize that the robust effect is concentrated in closed-source releases.

### Main result 3: Open-source weakens capability pricing

Interaction model:

* baseline closed-source slope: approximately +0.00226
* intelligence × open_weight coefficient: approximately −0.00373
* CR0 p = 0.003
* CR2 p = 0.048
* wild cluster bootstrap p = 0.086
* implied open-source slope: approximately −0.00148

Interpretation:

Open-source status significantly weakens the pricing slope of model capability. In point estimates, it reverses the slope from positive to negative.

Use conservative wording:

“The evidence supports a significant attenuation of the capability-pricing slope for open-source releases. The negative open-source slope should be interpreted cautiously because inference is weaker under wild bootstrap.”

Do NOT write that open-source releases are definitively value-destroying.

### Main result 4: Media sentiment is negatively associated with CAR

FinBERT sentiment predicting CAR[0,+20]:

* sentiment coefficient approximately −0.081
* CR2 p = 0.003 in the sentiment-only model
* in the joint model controlling for intelligence, sentiment remains negative and intelligence remains positive, though both become more marginal under conservative inference

Interpretation:

Positive media tone is associated with lower post-release CAR, consistent with a sell-the-news or pre-priced narrative mechanism. This helps distinguish technological capability from media hype.

Use careful causal language:

“consistent with,” not “proves.”

### Secondary or Appendix Results Only

The following results may be mentioned briefly in one paragraph or moved to appendix. Do not make them central.

1. Owner short-window negative reaction:

   * interesting, but short-window and small subsample.
   * may be mentioned as suggestive evidence that publishers themselves do not mechanically benefit.

2. Investor interaction:

   * negative point estimate, CR2 borderline, wild not robust.
   * mention only as exploratory.

3. Cloud interaction:

   * negative point estimate, weak inference.
   * appendix only.

4. Industry heterogeneity:

   * internet infrastructure, software, and semiconductors show stronger positive effects.
   * useful as supporting evidence but not a core result.

5. Quarterly regime shift:

   * may be mentioned very briefly as suggestive timing evidence.
   * do not claim a precise structural break.
   * do not make 2025Q3 a central result because quarter-level event clusters are small.

6. Tier 1 versus Tier 2:

   * do not use as a major claim.
   * formal interaction does not support a statistically distinguishable Tier difference.

7. Mag7:

   * not central.
   * use only to state the result is not simply a Mag7 effect if needed.

## Paper Structure

Write the manuscript in the following structure.

### Title

Use one of the following titles, or propose a sharper version:

1. Do Financial Markets Price AI Model Capability?
2. Appropriability and the Market Pricing of AI Model Capability
3. Proprietary AI Capability and Stock Market Reactions to LLM Releases

Preferred title:

**Appropriability and the Market Pricing of AI Model Capability**

### Abstract

Maximum 150–180 words.

The abstract should contain:

* research question
* sample: 60 LLM release events, 86 AI-related listed firms, 2024–2026
* method: event-study CARs and model capability measures
* main finding: closed-source capability is positively priced
* mechanism: open-source weakens/reverses capability pricing
* media sentiment: negative association with CAR, distinct from capability
* contribution: markets price appropriable AI capability rather than generic AI hype

Do not list many secondary results.

### 1. Introduction

Keep short.

Suggested structure:

Paragraph 1: LLM releases are frequent, economically important technology shocks, but it is unclear whether markets price raw model capability or broader AI hype.

Paragraph 2: Explain appropriability. Capability should create firm value only when it can be monetized through proprietary access, APIs, ecosystem lock-in, or commercial deployment. Open-source capability diffuses rents and may commoditize model services.

Paragraph 3: Describe data and empirical design.

Paragraph 4: Summarize three findings only:

* closed-source capability is robustly positively priced;
* open-source status weakens/reverses the capability-pricing slope;
* media sentiment is negatively associated with CAR and does not explain the capability result.

Paragraph 5: Contribution to finance literature: technology shocks, asset pricing of intangible technological capability, investor attention/media hype, and market valuation of AI.

### 2. Data and Variable Construction

Keep concise.

Describe:

* 60 major LLM release events from 2024–2026
* 86 AI-related listed firms
* firm-event panel
* CAR construction using event-study abnormal returns
* main window CAR[0,+20]
* AA Intelligence Index as model capability
* closed-source / open-source variables
* controls: firm size, book-to-market, volatility, momentum, relationship controls
* media sentiment from FinBERT
* standard errors clustered by event; CR2 and wild bootstrap for robustness

Do not describe the specification curve exercise.

Do not describe every relationship variable in excessive detail. One sentence is enough:

“We control for firm–model exposure using pre-event relationship indicators such as owner, investor, cloud, upstream, downstream, and competitor status.”

### 3. Hypothesis Development

This can be short, but it must make the paper hypothesis-driven.

Develop two hypotheses:

H1. Model capability is positively associated with stock market reactions when the model is closed-source and commercially appropriable.

H2. Open-source releases weaken the market pricing of model capability because open access diffuses rents and commoditizes model services.

Optional H3:

Media sentiment captures narrative attention and may differ from technological capability; therefore, the capability effect should survive sentiment controls if it reflects technological information rather than hype.

### 4. Empirical Results

Organize this section around three tables.

#### Table 1. Baseline capability pricing

Columns:

1. Full sample, CAR[0,+20]
2. Closed-source sample, CAR[0,+20]
3. Full sample with CR2 / wild p-values
4. Closed-source with CR2 / wild p-values

Main point:

The full-sample effect is positive but marginal under conservative inference. The closed-source effect is robust.

#### Table 2. Open-source interaction

Estimate:

CAR = beta_1 * intel_c + beta_2 * open_weight + beta_3 * intel_c × open_weight + controls + year or quarter FE + error

Report:

* closed-source baseline slope
* interaction coefficient
* implied open-source slope
* CR0, CR2, and wild p-values

Main point:

Open-source releases significantly attenuate the pricing of capability.

#### Table 3. Media sentiment and hype alternative

Estimate models with:

* sentiment only
* intelligence only
* intelligence + sentiment
* intelligence + sentiment + media attention / macro controls if available

Main point:

Sentiment is negatively associated with CAR, while intelligence remains positive. This supports the claim that the result is not merely media hype.

### 5. Robustness and Additional Evidence

Keep this section short.

Include only:

1. Alternative CAR windows: CAR[0,+1] and CAR[0,+15].
2. Macro controls if available:

   * VIX level or change
   * 10-year Treasury yield change
   * QQQ or Nasdaq pre-event return
3. Media attention:

   * log(1 + number of news articles) in the pre-event or event window
4. Industry and Mag7 checks:

   * state briefly that the result is not solely driven by Mag7 and is stronger in internet infrastructure, software, and semiconductors.
5. Optional: quarterly evidence as suggestive only.

   * Do not claim precise structural break.

Do not include specification curve analysis.

Do not include a long list of subsample regressions.

### 6. Conclusion

Keep it short.

Restate:

* Markets price AI model capability when the capability is appropriable.
* Closed-source model capability is robustly rewarded.
* Open-source releases weaken this pricing channel.
* Media sentiment moves in the opposite direction, suggesting a distinction between technological capability and narrative hype.

End with one implication:

Financial markets appear to distinguish between technological performance and the economic ownership of that performance.

## Tables and Figures

For an FRL draft, use no more than 3 main tables and 1 figure.

Recommended:

Table 1. Sample and baseline results
Table 2. Open-source appropriability interaction
Table 3. Sentiment and robustness
Figure 1. Estimated capability-pricing slopes for closed-source versus open-source releases

Move everything else to online appendix.

## Tone and Style

Write in clean academic English.

Do not oversell.

Use “consistent with” rather than “proves.”

Use “appropriability” as the central theoretical word.

Avoid phrases like:

* “we comprehensively examine”
* “we find eight results”
* “specification curve”
* “many robustness checks reveal”
* “we searched across windows”

Preferred language:

* “We focus on a pre-specified long-window response, CAR[0,+20].”
* “Our main test compares the pricing slope of model capability across closed-source and open-source releases.”
* “The evidence is consistent with markets pricing appropriable AI capability rather than generic AI attention.”
* “Results based on smaller subsamples are treated as suggestive and reported only in the appendix.”

## Required Output

Produce:

1. `frl_draft_main_text.tex`
2. `frl_draft_main_text.md`
3. `frl_tables_plan.md`
4. `appendix_results_to_exclude_from_main_text.md`

The main text should be around 2,500–3,000 words before references, unless the target journal requires a stricter limit.

Do not invent new results.

Do not invent references.

Use placeholders like “[citation needed]” where references must be added.

Before writing, first produce a one-page outline. Then write the draft.
