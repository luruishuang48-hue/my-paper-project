# Review

This review checks the relationship-focused Specr outputs in `agent_tasks/relationship_specr_newrel_20260625-005125/`.

## Main-paper candidates

The strongest main-paper result is the negative `downstream_deployer` effect. It is large, stable across CAR[0,+10], CAR[0,+15], and CAR[0,+20], and survives firm controls, year fixed effects, and AA Intelligence controls. The treated sample is not thin, with 1090 CAR20-valid rows across all 60 events.

The second main-paper result is the positive upstream or strategic position effect. `upstream_hardware`, `upstream_any`, and `strategic_any` are all positive in long windows. The CAR[0,+20] estimates with firm controls, year fixed effects, and AA Intelligence controls are statistically strong.

The best framing is a contrast. Upstream and strategic positions earn positive post-release CAR, while downstream deployment positions earn negative post-release CAR.

## Exploratory results

The `intel_c × is_investor` interaction is statistically strong, but treated N is only 38 across 22 AA-covered events. It should be described as exploratory.

The `competitor` interaction is weakly negative, but p values are mostly around 0.07 to 0.11. It is useful as suggestive evidence only.

`downstream_enabler` is negative in joint downstream models, but it has only 480 rows and 8 companies. It is better placed in the appendix unless the paper has space for a downstream decomposition table.

`upstream_cloud` is positive in several specifications, but it has only 274 rows and 5 companies and overlaps heavily with `competitor` and `is_investor`.

## Risks

Most new relationship variables cover all 60 events and appear close to company ecosystem-position categories. They should not be described as event-specific bilateral relationships unless the text explains the coding logic carefully.

`any_relationship` is too broad. It covers 97.7% of the sample and does not provide useful contrast.

`is_owner` and `is_investor` are too small for standalone main effects.

FMR-0060 has mixed date coding, with one group using an ISO-like date and another using Excel serial `46098`. The regressions cluster on `final_event_id`, so the issue does not change the event count, but event-level descriptive tables should clean it before use.

The joint all-eight model can be hard to interpret because some relationship variables overlap. Prefer cleaner contrast models and single-flag screens for the main text.

## Revision recommendation

Keep the final report's main claims, but soften causal language. Use “AI ecosystem position” and “relationship coding” rather than “event-specific relation” when describing the broad relationship flags. Put investor and owner results in exploratory mechanisms.
