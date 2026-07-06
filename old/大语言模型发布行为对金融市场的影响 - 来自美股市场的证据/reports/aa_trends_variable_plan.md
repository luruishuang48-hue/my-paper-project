# Artificial Analysis Trends Variable Plan

Generated: 2026-04-26

## Bottom Line

The exact `https://artificialanalysis.ai/trends` chart datasets are not available through a public, documented trends API. The project should not scrape the trends page as a data source. Instead, build reproducible trend variables from documented Artificial Analysis API outputs already cached locally, plus clearly marked external/manual sources where the public API does not expose required fields.

No `scripts/fetch_aa_trends_public.py` was created because the condition was not met: the trends page does not load a public documented trends API.

## Recommended Strategy

1. Use the existing Artificial Analysis master database pipeline for officially documented benchmark endpoints.
2. Extend the LLM normalized table to retain any documented fields already present in raw API responses but omitted from normalization, especially `release_date`.
3. Reconstruct only variables that can be derived reproducibly from documented API data.
4. Mark variables requiring internal page data, commercial API access, or non-AA sources as unavailable until a legitimate source is obtained.

## Variables We Can Reconstruct From Current Or Cached Public API Data

| Variable Family | Candidate Variables | Required Source | Current Status | Plan |
|---|---|---|---|---|
| Intelligence over time | max/frontier `aa_intelligence_index` by release date, creator, quarter | `data/raw/artificial_analysis/llms_models_*.json` or documented `/api/v2/data/llms/models` | Raw API includes `release_date`; current `aa_llm_models.csv` omits it | Add `release_date_raw` / `release_date` to normalized LLM table in a future master-db revision. |
| Price over time | `price_1m_input_tokens`, `price_1m_output_tokens`, `price_1m_blended_3_to_1` by release date/quarter | documented LLM API | Available in normalized table; release date omitted | Add release date, then aggregate by quarter/month. |
| Speed over time | `median_output_tokens_per_second`, `median_time_to_first_token_seconds`, `median_time_to_first_answer_token` | documented LLM API | Available in normalized table; release date omitted | Add release date, then compute frontier/median trend series. |
| Benchmark composition | `mmlu_pro`, `gpqa`, `hle`, `livecodebench`, `scicode`, `math_500`, `aime` | documented LLM API | Mostly available in normalized table | Use directly; keep missing values blank. |
| Media model trend snapshots | media `elo`, `rank`, `ci95`, `appearances`, `release_date_raw` by media task | documented media APIs | Available in `aa_media_models.csv` | Aggregate by `media_task` and release month/quarter. |
| Media category trends | category ELO and appearances by task/dimension/category | documented media APIs with `include_categories=true` | Available in `aa_media_categories_long.csv` | Aggregate category performance cautiously; category data are leaderboard snapshots, not full historical time series. |

## Variables Not Available Via Current Public API

| Trends Chart Variable | Reason Not Publicly Reproducible | Suggested Treatment |
|---|---|---|
| Exact trends page chart series | No documented trends endpoint; no public JSON/API request found on page load | `not_available_via_public_api` |
| `timescaleData.median_output_speed` | Trends page field differs from public LLM API output; exact historical timescale series not documented | Use current `median_output_tokens_per_second` snapshot only. |
| Model creator country | Referenced by trends page, not present in current normalized public API table | Build manual creator-country mapping with source notes, or request commercial API. |
| Open weights/proprietary category | Referenced by trends page as `open_source_categorization`; not present in current normalized public API table | Use manual license classification with citations, or request commercial API. |
| Total/active parameters | Referenced by trends page as `parameters` and `activeParams`; not present in documented LLM API output used here | Use commercial API or manual model-card extraction; do not infer. |
| Context window | Referenced by trends page as `context_window_tokens`; not present in documented LLM API output used here | Use vendor model cards/manual sources or commercial API. |
| Training tokens | Referenced by trends page as `training_information.training_tokens_trillions`; not present in documented LLM API output used here | Use commercial API, papers/model cards, or leave missing. |
| Capex by company/quarter | Hardcoded in public JS chunk, not a documented AA API | Rebuild from company filings or financial statement datasets, not AA page JS. |

## Proposed Project Tables

| Output Table | Grain | Inputs | Notes |
|---|---|---|---|
| `data/processed/aa_llm_models.csv` revision | one row per AA LLM model | documented LLM API raw cache | Add `release_date_raw` and any new documented eval fields already present in raw JSON, such as `ifbench`, `lcr`, `tau2`, `terminalbench_hard`, `aime_25`. |
| `data/processed/aa_llm_trends_reconstructed.csv` | model-month or model-release event | revised LLM table | Derived table; no new AA endpoint required. |
| `data/processed/aa_media_trends_reconstructed.csv` | media model release/task | existing media tables | Use `release_date_raw`; keep as snapshot-based, not true historical leaderboard. |
| `data/processed/creator_country_manual.csv` | creator | manual/source-backed | Only if country-level trends are needed. |
| `data/processed/model_license_manual.csv` | model or model family | manual/source-backed | Only if open/proprietary trends are needed. |

## Recommended Trend Variables For Event Study

| Variable | Definition | Feasible Now | Source |
|---|---|---:|---|
| `aa_frontier_intelligence_at_release_month` | max AA intelligence index among models released on/before event month | Partial | Needs LLM `release_date` retained from raw public API. |
| `aa_creator_best_intelligence_to_date` | creator-level max AA intelligence index up to event date | Partial | Needs LLM `release_date` and creator IDs. |
| `aa_price_frontier_by_month` | lowest blended price among models above chosen intelligence threshold by month | Partial | Needs release date plus current pricing. |
| `aa_speed_frontier_by_month` | highest output speed among models above chosen intelligence threshold by month | Partial | Needs release date plus current speed. |
| `aa_media_elo_by_task_at_release` | media model ELO/rank by task for matched media models | Yes | Existing `aa_media_models.csv`. |
| `aa_context_window_trend` | median context window by quarter | No | Not public in documented API; request commercial API or manual source. |
| `aa_training_tokens_trend` | model training tokens by release date | No | Not public in documented API; request commercial API or manual source. |
| `aa_capex_trend` | major tech company capex by quarter | No from AA public API | Reconstruct from SEC/company filings or financial data provider. |

## Recommended External Path For Missing Variables

- contact Artificial Analysis for commercial API
- reconstruct trend variables from existing master database
- use quarterly State of AI reports as historical snapshots

## Implementation Notes For Future Work

- Do not parse `self.__next_f` from the trends HTML as a production data source.
- Do not parse hardcoded `_next/static` JavaScript arrays as a production data source.
- If a future official trends API is published, add `scripts/fetch_aa_trends_public.py` only after confirming it appears in the official documentation and its authentication/terms are compatible with project use.
- Preserve raw API responses and add fetch dates, as already done for the master database pipeline.

