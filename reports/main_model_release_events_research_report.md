# Research-Ready Main Model Release Event Table Report

This table removes audit-only columns from the AI Timeline / AA matching workflow and keeps model-event fields needed for event-study construction.

## Counts

- Event rows: 72
- Event-study ready rows: 71
- Rows needing date manual review: 1
- Columns in research table: 62

## Official Date Confidence

- manual_confirmed_company_press_release: 1
- manual_confirmed_media_source: 4
- manual_confirmed_model_card: 3
- manual_confirmed_month_only: 1
- manual_confirmed_official_docs: 1
- manual_confirmed_official_source: 18
- manual_confirmed_secondary_source: 5
- manual_confirmed_user_source: 4
- official_date_matches_event_month: 35

## AA Source Table Counts

- aa_llm_models: 57
- aa_media_models: 15

## Modality Counts

- coding_llm: 4
- image_editing: 1
- image_generation: 8
- multimodal_llm: 5
- reasoning_llm: 22
- text_llm: 26
- video_generation: 6

## Date Policy

- `official_release_date` records the best official-source date if one was found by the crawler.
- `event_study_release_date` is filled when the crawler finds a high-confidence official date or when a manual override confirms a usable daily event date.
- If the official date conflicts with the AI Timeline month, the date is retained but flagged for manual review until a manual override resolves it.
- Month-only decisions, such as Midjourney V1, are retained in the main model-event table but not treated as daily event-study-ready observations.
- Audit-only fields removed include raw timeline text, split IDs, dedup rule, candidate source rows, and fuzzy-review metadata.
