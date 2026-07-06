# AI Timeline Enriched Model Events Report

Generated locally from AI Timeline review files and local Artificial Analysis master tables. No API calls were made.

## Core Counts

- Total enriched review rows: 136
- Rows with confirmed usable AA metrics: 82
- Rows with possible but unconfirmed AA alias metrics: 1
- Rows excluded/deleted by manual decision: 10
- Rows marked as merged/duplicate variants: 16
- Media category long rows linked to enriched events: 442

## AA Score Group

- with_aa_candidate_score: 117
- without_aa_candidate_score: 19

## Final Sample Status

- excluded_or_deleted_candidate: 10
- kept_with_confirmed_aa_metrics: 77
- kept_without_confirmed_aa_metrics: 18
- merged_or_duplicate_without_direct_metrics: 8
- merged_variant_with_own_or_family_metrics: 8
- needs_manual_review_without_decision: 14
- no_aa_candidate_score: 1

## Final AA Source Table

- aa_llm_models: 68
- aa_media_models: 15
- no_aa_metrics: 53

## Modality Distribution

- ambiguous: 11
- audio_speech: 1
- coding_llm: 8
- image_editing: 2
- image_generation: 8
- multimodal_llm: 13
- music_generation: 2
- reasoning_llm: 15
- text_llm: 66
- video_generation: 7
- vision_language_model: 3

## Interpretation Notes

- LLM benchmark, price, speed, and latency fields are filled only for rows mapped to `aa_llm_models.csv`.
- Media Elo/rank/category fields are filled only for rows mapped to `aa_media_models.csv` and `aa_media_categories_long.csv`.
- Different modality metrics are kept in separate columns; the file intentionally does not create a single cross-modality capability score.
- Rows with `aa_metrics_usage_status = possible_alias_needs_confirmation` are included for auditability but should not be used as confirmed AA matches without final manual approval.
- Excluded and merged rows are retained because prior instructions required marking suspected errors rather than deleting events.
