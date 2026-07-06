# Coder A (Claude) Relationship Coding — Multi-Agent Execution Plan

**Created:** 2026-06-24 18:58 Beijing Time
**Task:** Code 1,204 (company × creator) relationship pairs per the codebook

## Architecture

### Phase 1: Parallel Coding (7 agents)
Each agent gets a batch of companies grouped by natural category, codes them against all 14 creators, and saves output CSV to the working directory.

| Agent | Batch | Companies | Pairs |
|-------|-------|-----------|-------|
| coding_1 | Semiconductors | 13 | 182 |
| coding_2 | Cloud & Big Tech | 7 | 98 |
| coding_3 | AI-Native Software | 13 | 182 |
| coding_4 | Enterprise Software | 14 | 196 |
| coding_5 | IT Services | 10 | 140 |
| coding_6 | Hardware & Infra | 11 | 154 |
| coding_7 | Deployers | 18 | 252 |

### Phase 2: Merge & Expand (1 agent)
- Merge 7 batch CSVs into one master file (1,204 rows at company×creator level)
- Expand to event level (5,160 rows) using event-creator mapping
- Run internal consistency checks

### Phase 3: Review (2 agents in parallel)
- Agent review_logic: Check coding logic against codebook rules
- Agent review_compare: Compare with GPT Coder B output, compute preliminary Cohen's κ per dimension

### Phase 4: Revision (1 agent)
- Apply review findings to produce final corrected output
- Generate final κ statistics and discrepancy report

## Output Files
- `batch_{1-7}_coded.csv` — Phase 1 outputs
- `coder_a_company_creator.csv` — Merged company×creator level (1,204 rows)
- `coder_a_event_level.csv` — Expanded event level (5,160 rows)
- `review_logic.md` — Logic review findings
- `review_comparison.md` — κ comparison with Coder B
- `coder_a_final.csv` — Final revised event-level output
- `kappa_report.md` — Final inter-coder reliability report
