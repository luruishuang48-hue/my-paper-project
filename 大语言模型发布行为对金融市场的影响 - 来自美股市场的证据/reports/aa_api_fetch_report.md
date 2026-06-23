# Artificial Analysis API Fetch Report

## Endpoint Status
| Endpoint | Success | Used cache | Status | Models | Request started | Request completed | Fetched at | Elapsed seconds | Raw file |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| llms_models | True | True | cache | 496 |  |  | 2026-04-26T12:30:01+00:00 |  | /Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/llms_models_2026-04-26.json |
| text_to_image | True | True | cache | 122 |  |  | 2026-04-26T12:30:07+00:00 |  | /Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/text_to_image_2026-04-26.json |
| image_editing | True | True | cache | 54 |  |  | 2026-04-26T12:30:10+00:00 |  | /Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/image_editing_2026-04-26.json |
| text_to_speech | True | True | cache | 71 |  |  | 2026-04-26T12:27:24+00:00 |  | /Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/text_to_speech_2026-04-26.json |
| text_to_video | True | True | cache | 80 |  |  | 2026-04-26T12:27:29+00:00 |  | /Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/text_to_video_2026-04-26.json |
| image_to_video | True | True | cache | 74 |  |  | 2026-04-26T12:27:34+00:00 |  | /Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/Matrix I - Bandit与研发竞赛/llms/data/raw/artificial_analysis/image_to_video_2026-04-26.json |

## Missing Field Statistics
| Table | Field | Missing rows |
| --- | --- | --- |
| aa_llm_models | aa_model_id | 0 |
| aa_llm_models | aa_model_name | 0 |
| aa_llm_models | aa_slug | 0 |
| aa_llm_models | aa_creator_id | 0 |
| aa_llm_models | aa_creator_name | 0 |
| aa_llm_models | aa_creator_slug | 0 |
| aa_llm_models | aa_intelligence_index | 7 |
| aa_llm_models | aa_coding_index | 97 |
| aa_llm_models | aa_math_index | 227 |
| aa_llm_models | mmlu_pro | 151 |
| aa_llm_models | gpqa | 29 |
| aa_llm_models | hle | 33 |
| aa_llm_models | livecodebench | 153 |
| aa_llm_models | scicode | 35 |
| aa_llm_models | math_500 | 295 |
| aa_llm_models | aime | 302 |
| aa_llm_models | price_1m_input_tokens | 0 |
| aa_llm_models | price_1m_output_tokens | 0 |
| aa_llm_models | price_1m_blended_3_to_1 | 0 |
| aa_llm_models | median_output_tokens_per_second | 0 |
| aa_llm_models | median_time_to_first_token_seconds | 0 |
| aa_llm_models | median_time_to_first_answer_token | 0 |
| aa_llm_models | source_endpoint | 0 |
| aa_llm_models | fetched_at | 0 |
| aa_media_models | aa_model_id | 0 |
| aa_media_models | aa_model_name | 0 |
| aa_media_models | aa_slug | 0 |
| aa_media_models | aa_creator_id | 0 |
| aa_media_models | aa_creator_name | 0 |
| aa_media_models | media_task | 0 |
| aa_media_models | elo | 0 |
| aa_media_models | rank | 0 |
| aa_media_models | ci95 | 0 |
| aa_media_models | appearances | 71 |
| aa_media_models | release_date_raw | 71 |
| aa_media_models | source_endpoint | 0 |
| aa_media_models | fetched_at | 0 |
| aa_media_categories | aa_model_id | 0 |
| aa_media_categories | aa_model_name | 0 |
| aa_media_categories | media_task | 0 |
| aa_media_categories | style_category | 4417 |
| aa_media_categories | subject_matter_category | 2094 |
| aa_media_categories | format_category | 5413 |
| aa_media_categories | category_elo | 0 |
| aa_media_categories | category_ci95 | 0 |
| aa_media_categories | category_appearances | 0 |

## Duplicate Checks
| Table | Duplicate key | Duplicate groups | Examples |
| --- | --- | --- | --- |
| aa_llm_models | aa_model_id | 0 |  |
| aa_media_models | aa_model_id | 92 | 9570e1d0-a390-48c1-a270-1317570fe3d5 (2); a1ee4d6f-d136-434b-bb1d-066fe5f9bf6f (2); 3180162e-693d-487d-adbb-721f859f768d (2); ae424391-721f-4df7-bf24-a8bef3c4c46c (2); 6a5056eb-6854-43c4-bf18-01d185ce9e2f (2); e9f5c7b0-bcb3-400b-81a1-0a1401323551 (2); 6a398b55-7f36-4039-bbbf-2045ef8ab525 (2); 18874791-11a3-4cb7-bc0e-6ca10138eec7 (2); bcc5b88d-1bb0-45e6-9940-2f8b99567b40 (2); e2201d15-3e29-48c6-89ba-e63ccf3dde15 (2) |
| aa_llm_models | aa_model_name + aa_creator_name | 0 |  |
| aa_media_models | aa_model_name + aa_creator_name | 92 | GPT Image 2 (high) | OpenAI (2); GPT Image 1.5 (high) | OpenAI (2); Nano Banana 2 (Gemini 3.1 Flash Image Preview) | Google (2); Riverflow 2.0 | Sourceful (2); Nano Banana Pro (Gemini 3 Pro Image) | Google (2); Seedream 4.0 | ByteDance Seed (2); FLUX.2 [max] | Black Forest Labs (2); FLUX.2 [pro] | Black Forest Labs (2); grok-imagine-image | xAI (2); FLUX.2 [flex] | Black Forest Labs (2) |

## Output Row Counts
- `data/processed/aa_llm_models.csv`: 496
- `data/processed/aa_media_models.csv`: 401
- `data/processed/aa_media_categories.csv`: 5962

## Endpoint Errors
No endpoint errors.

## Cache Policy
- Raw JSON cache directory: `data/raw/artificial_analysis/`
- Default behavior: use same-date raw JSON if present.
- Refresh behavior: pass `--refresh` to request all endpoints again and overwrite same-date raw JSON files.
- API key was read from `ARTIFICIAL_ANALYSIS_API_KEY`; it is not written to code or output files.
