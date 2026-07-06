# Relationship Coding Plan (Coder A)

## Task
Code 86 companies × 14 creators = 1,204 pairs with 8 binary relationship indicators following `gpt_coding_prompt.md` and `relationship_codebook.md`.

## Execution Plan

### Phase 1: Parallel Coding (4 subagents)
Split 86 companies into 4 batches (~22 companies each), each subagent codes all 14 creators for their batch.

- **Batch 1** (Semiconductors + Hardware): 000660 KS, 005930 KS, 2353 TT, 2395 TT, 3443 TT, AMBA, AMD, AVGO, HPE, IFX GR, INTC, MRVL, MU, NVDA, NXPI, QCOM, SMCI, STX, TSM, ZBRA, WRD (21 companies)
- **Batch 2** (Cloud/Internet/Media): 3690 HK, 4755 JP, 700 HK, AAPL, AMZN, BABA, BIDU, GOOGL, META, MSFT, NFLX, ORCL, SHOP, SNAP, STNE, TSLA, UBER, HUT, PONY, ERIC (20 companies)  
- **Batch 3** (Software AI-native): ADBE, AI, APP, CCC, CRM, CYBR, DDOG, FTNT, NICE, NOW, OKTA, PATH, PEGA, PLTR, QUBT, SNOW, SNPS, CDNS, SOUN, TDC, TEMN SW, TTD, TWLO, WDAY, WIX, ZS (26 companies)
- **Batch 4** (IT Services + Japanese + Other): 5803 JP, 6588 JP, 6701 JP, 6702 JP, 6758 JP, 6954 JP, ACN, AMP IM, CRWV, CSCO, DXC, EXPN LN, G, GEHC, IBM, SIE GR, TIETO FH, TRI, WKL NA (19 companies)

### Phase 2: Main Agent Integration
- Merge 4 CSV fragments into single 1,204-row output
- Validate completeness (all 86 × 14 present)
- Sort by company_id (alpha) then creator (alpha)

### Phase 3: Review
- Spot-check multi-role companies (MSFT, AMZN, GOOGL, META)
- Verify NVIDIA rule (always R1=1, R6=0)
- Verify is_owner mappings
- Verify is_investor known relationships

### Phase 4: Deliver
- Save final CSV to `data/relationships/coder_a_output.csv`

## Timeline
- Timestamp: 20260624-205216
- Working dir: agent_tasks/relationship_coding_20260624-205216/
