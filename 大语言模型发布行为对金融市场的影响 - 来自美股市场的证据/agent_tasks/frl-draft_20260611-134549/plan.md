# FRL Draft Execution Plan
**Task**: Write Finance Research Letters submission draft  
**Timestamp**: 2026-06-11 13:45:49  
**Working dir**: agent_tasks/frl-draft_20260611-134549/

---

## Deviation from GPT's prompt.md

GPT's instructions are followed **except** for the following changes (per user's instruction "其他听你的"):

1. **P-hacking transparency**: Add one honest sentence in Section 4 noting that the main window and stratification were motivated by prior exploratory analysis. Do NOT present the paper as if hypotheses were pre-registered.

2. **Open-source interaction downgraded**: GPT listed this as "Main Result 3". Evidence: CR2 p=0.048*, Wild p=0.086+. This does NOT clear the wild bootstrap threshold at 5%. It should be reported in Section 4 with heavy qualification ("the evidence is consistent with attenuation... caution warranted because...") but not advertised as a robust finding.

3. **Sentiment interpretation**: Neutral causal language throughout. "Consistent with sell-the-news" is one interpretation; we note endogeneity concern (high-sentiment = high attention = pre-priced).

4. **Sample period**: 2024–2026 (20+35+5 events across years). Not "2024–2026" in a misleading way — the 2026 slice has only 5 events from Q1.

---

## Key Numbers

| Result | β | SE | CR0 p | CR2 p | Wild p | n | events |
|---|---|---|---|---|---|---|---|
| Full sample, car_20 | +0.00152 | 0.00067 | 0.027* | 0.054+ | 0.053+ | 3,780 | 47 |
| Closed-source, car_20 | +0.00232 | 0.00062 | 0.001*** | 0.007** | 0.008** | 2,899 | 36 |
| Open×intel interaction | −0.00373 | 0.00120 | 0.003** | 0.048* | 0.086+ | 3,780 | 47 |
| Sentiment alone (w5) | −0.081 | 0.020 | <0.001*** | 0.003** | — | ~3,068 | 47 |
| Joint: intel_c | +0.00158 | 0.00072 | 0.035* | 0.087+ | — | ~3,068 | 47 |
| Joint: sentiment | −0.061 | 0.026 | 0.024* | 0.057+ | — | ~3,068 | 47 |

**Economic magnitude**: 1 SD of intelligence (≈13.1 points) × β_closed (+0.00232) = +3.0 pp CAR over 20 trading days.

---

## Output Files

- [ ] `frl_draft_main_text.md` — complete paper ~2,500–3,000 words
- [ ] `frl_tables_plan.md` — 3-table structure with column specs
- [ ] `appendix_results_to_exclude_from_main_text.md` — list of appendix items

---

## Phases

**Phase 1 (DONE)**: Data confirmation (sample period, n, events)  
**Phase 2 (IN PROGRESS)**: Write main paper  
**Phase 3**: Write tables plan + appendix list  
**Phase 4**: Review against econ-write checklist  
**Phase 5**: Revise and finalize  
