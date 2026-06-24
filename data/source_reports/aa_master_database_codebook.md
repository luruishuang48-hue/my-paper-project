# Artificial Analysis Master Database Codebook

## Source
- Official Artificial Analysis API only.
- API key source: `ARTIFICIAL_ANALYSIS_API_KEY` environment variable.
- Request authentication header: `x-api-key`.
- Raw responses: `data/raw/artificial_analysis/`.

## `data/processed/aa_llm_models.csv`
| Column | Description |
|---|---|
| `aa_model_id` | Artificial Analysis model id from the LLM endpoint. |
| `aa_model_name` | Model display name. |
| `aa_slug` | Artificial Analysis model slug. |
| `aa_creator_id` | Creator id returned by Artificial Analysis. |
| `aa_creator_name` | Creator display name returned by Artificial Analysis. |
| `aa_creator_slug` | Creator slug returned by Artificial Analysis. |
| `aa_intelligence_index` | Artificial Analysis Intelligence Index, if returned. |
| `aa_coding_index` | Artificial Analysis Coding Index, if returned. |
| `aa_math_index` | Artificial Analysis Math Index, if returned. |
| `mmlu_pro` | MMLU-Pro benchmark score, if returned. |
| `gpqa` | GPQA benchmark score, if returned. |
| `hle` | Humanity's Last Exam benchmark score, if returned. |
| `livecodebench` | LiveCodeBench benchmark score, if returned. |
| `scicode` | SciCode benchmark score, if returned. |
| `math_500` | MATH-500 benchmark score, if returned. |
| `aime` | AIME benchmark score, if returned. |
| `price_1m_input_tokens` | Price per 1M input tokens, if returned. |
| `price_1m_output_tokens` | Price per 1M output tokens, if returned. |
| `price_1m_blended_3_to_1` | Blended 3:1 input/output price per 1M tokens, if returned. |
| `median_output_tokens_per_second` | Median output tokens per second, if returned. |
| `median_time_to_first_token_seconds` | Median time to first token in seconds, if returned. |
| `median_time_to_first_answer_token` | Median time to first answer token, if returned. |
| `source_endpoint` | Official API endpoint used for the row. |
| `fetched_at` | UTC time when the raw payload was fetched, or raw cache file modification time when cache was used. |

## `data/processed/aa_media_models.csv`
| Column | Description |
|---|---|
| `aa_model_id` | Artificial Analysis media model id. |
| `aa_model_name` | Media model display name. |
| `aa_slug` | Artificial Analysis media model slug. |
| `aa_creator_id` | Creator id returned by Artificial Analysis, if returned. |
| `aa_creator_name` | Creator display name returned by Artificial Analysis, if returned. |
| `media_task` | One of `text_to_image`, `image_editing`, `text_to_speech`, `text_to_video`, `image_to_video`. |
| `elo` | Overall media leaderboard Elo, if returned. |
| `rank` | Overall rank, if returned. |
| `ci95` | 95% confidence interval field, if returned. |
| `appearances` | Appearance/count field, if returned. |
| `release_date_raw` | Release date as returned by the API, if present. |
| `source_endpoint` | Official API endpoint used for the row. |
| `fetched_at` | UTC time when the raw payload was fetched, or raw cache file modification time when cache was used. |

## `data/processed/aa_media_categories.csv`
| Column | Description |
|---|---|
| `aa_model_id` | Artificial Analysis media model id. |
| `aa_model_name` | Media model display name. |
| `media_task` | Media endpoint task. |
| `style_category` | Style category name, if returned. |
| `subject_matter_category` | Subject matter category name, if returned. |
| `format_category` | Format category name, if returned. |
| `category_elo` | Category-level Elo or score, if returned. |
| `category_ci95` | Category-level 95% confidence interval, if returned. |
| `category_appearances` | Category-level appearances/count, if returned. |

## Missing Values
Fields not returned by the API are left blank. No values are inferred or fabricated.
