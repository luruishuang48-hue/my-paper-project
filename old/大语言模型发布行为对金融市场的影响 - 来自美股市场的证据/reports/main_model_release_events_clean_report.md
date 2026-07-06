# Clean Main Model Release Event Table Report

This table is event-level and keeps only research-useful fields from the enriched AI Timeline + AA dataset.

## Counts

- Enriched input rows: 136
- Confirmed AA, non-excluded candidate rows: 82
- Clean deduplicated event rows: 72
- Deduplication groups with more than one source row: 10

## Source Table Counts

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

## Tier Counts

- Tier 1: 34
- Tier 2: 35
- Tier 3: 3

## Year Counts

- 2022: 1
- 2024: 23
- 2025: 41
- 2026: 7

## Next Step

- Fill `release_date`, `release_date_source_url`, `release_date_source_title`, `release_date_source_type`, and `release_date_confidence` from official technical blogs or announcements.
- Do not use `event_month` as the event-study date unless no exact date can be verified; event study requires a trading-day event date.
