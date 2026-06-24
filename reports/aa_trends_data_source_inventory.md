# Artificial Analysis Trends Data Source Inventory

Generated: 2026-04-26

## Scope And Guardrails

- Target page: `https://artificialanalysis.ai/trends`
- Method: minimal public-page reconnaissance using `curl`/requests-style checks; no API key was sent to undocumented endpoints.
- Browser CDP was not used because Chrome remote debugging was unavailable in this environment.
- No login, paid access, anti-bot bypass, or large-scale crawling was attempted.

## Summary Finding

`https://artificialanalysis.ai/trends` is a public, statically prerendered Next.js page. The initial HTML response contains React Server Components flight payload and chart configuration/data references. The page also loads static `_next/static` JavaScript/CSS/font assets and analytics scripts.

I did not find a public, stable, documented trends JSON/API endpoint for the chart datasets. The trends page HTML contains no `/api/v2` or `/api/` URL strings, and the public trends page JavaScript chunk contains no `fetch(`, `axios`, `/api`, or `api/v2` strings. Therefore, the exact trends chart datasets should be treated as `not_available_via_public_api`.

The official API documentation at `https://artificialanalysis.ai/documentation` documents the free Artificial Analysis Data API endpoints already used in this project, including `/api/v2/data/llms/models` and the media endpoints. These documented endpoints require `x-api-key`; a no-key request to `/api/v2/data/llms/models` returned `401 {"error":"API key is required"}`. The documentation did not list a trends endpoint.

## Checked URLs

| URL | Result | Notes |
|---|---:|---|
| `https://artificialanalysis.ai/trends` | 200 | Public HTML, `x-nextjs-prerender: 1`, about 6.4 MB. |
| `https://artificialanalysis.ai/_next/static/chunks/app/(pages)/trends/page-2e2a37cd0bb9edf9.js` | 200 | Public static JS chunk, about 31 KB; no front-end API fetch calls found. |
| `https://artificialanalysis.ai/documentation` | 200 | Official API documentation. Documents model/media benchmark endpoints, not trends endpoints. |
| `https://artificialanalysis.ai/api/v2/data/llms/models` without API key | 401 | Documented API requires `x-api-key`; no key was sent. |

## Official API Documentation Status

Documented free API endpoints observed in the official documentation:

| Endpoint | Documented | Requires Authentication | Relevance To Trends |
|---|---:|---:|---|
| `/api/v2/data/llms/models` | Yes | Yes, `x-api-key` | Can support partial reconstruction of model-level trends such as intelligence, price, speed, release date. |
| `/api/v2/data/media/text-to-image` | Yes | Yes, `x-api-key` | Media leaderboard only, not trends page chart source. |
| `/api/v2/data/media/image-editing` | Yes | Yes, `x-api-key` | Media leaderboard only, not trends page chart source. |
| `/api/v2/data/media/text-to-speech` | Yes | Yes, `x-api-key` | Media leaderboard only, not trends page chart source. |
| `/api/v2/data/media/text-to-video` | Yes | Yes, `x-api-key` | Media leaderboard only, not trends page chart source. |
| `/api/v2/data/media/image-to-video` | Yes | Yes, `x-api-key` | Media leaderboard only, not trends page chart source. |
| trends-specific API | No | Unknown | No public documented endpoint found. |

## Chart Inventory

For all rows below:

- Page URL: `https://artificialanalysis.ai/trends`
- Public JSON/API request found on page load: No
- Authentication for page request: No
- Authentication for documented API alternatives: Yes, `x-api-key`
- In official API docs: No for the exact chart dataset; partial underlying fields are documented only for some model/media benchmark data.

| Chart Name | Public JSON/API Data Request | Request Needs Auth | Appears In Official API Docs | Approximate Fields Visible From Page/Code | Recommendation |
|---|---|---:|---:|---|---|
| Frontier Language Model Intelligence, Over Time | None found; data/config embedded in prerendered page | N/A | No exact chart endpoint | `release_date`, `intelligence_index`, `short_name`, `model_url`, `reasoning_model`, creator color/name | Reconstruct partially from documented LLM API plus local event dates; do not scrape page as API. |
| Capital Expenditure by Major Tech Companies, Over Time | None found; quarterly capex array hardcoded in public JS chunk | N/A | No | `id`, `label`, `microsoft`, `google`, `meta`, `amazon`, `oracle`, `apple` | Do not ingest from JS chunk as stable source; use company filings or external financial datasets if needed. |
| Intelligence vs. Release Date | None found | N/A | No exact chart endpoint | `release_date`, `intelligence_index`, `short_name`, `model_creators.name/color` | Reconstruct from documented LLM API if release dates are retained in normalization. |
| Leading Models by AI Lab | None found | N/A | No exact chart endpoint | `model_creators.id/name/slug`, `intelligence_index`, `short_name`, `model_url` | Reconstruct from documented LLM API. |
| Artificial Analysis Intelligence Index by Model Type | None found | N/A | No exact chart endpoint | `intelligence_index`, `reasoning_model`, `short_name` | Reconstruct only if `reasoning_model` is available locally; otherwise not available via public API. |
| Language Model Inference Price | None found | N/A | No exact chart endpoint | `release_date`, `price_1m_blended_3_to_1`, `intelligence_index`, `short_name` | Reconstruct from documented LLM API using release date and pricing fields. |
| Language Model Output Speed | None found | N/A | No exact chart endpoint | `release_date`, `timescaleData.median_output_speed`, `intelligence_index`, `short_name` | Partially reconstruct from documented LLM API using `median_output_tokens_per_second`; exact `timescaleData` not public. |
| Frontier Language Model Intelligence By Country, Over Time | None found | N/A | No exact chart endpoint | `model_creators.country`, `release_date`, `intelligence_index`, `short_name` | Reconstruct only if creator country is available; not present in current normalized public API table. |
| Open Weights: Frontier Language Model Intelligence By Country, Over Time | None found | N/A | No exact chart endpoint | `model_creators.country`, `is_open_weights`, `release_date`, `intelligence_index` | Not fully available via documented public API unless license/country fields are present in page/internal data. |
| Leading Models by Country | None found | N/A | No exact chart endpoint | `model_creators.country`, `intelligence_index`, `short_name` | Not fully available from current project public API tables. |
| Progress in Open Weights vs. Proprietary Intelligence | None found | N/A | No exact chart endpoint | `open_source_categorization`, `release_date`, `intelligence_index` | Not fully available from current normalized public API tables unless license category is added from a verified source. |
| Artificial Analysis Intelligence Index by Open Weights / Proprietary | None found | N/A | No exact chart endpoint | `open_source_categorization`, `intelligence_index`, `short_name` | Not fully available via current public API output. |
| Intelligence Index vs. Release Date by Model Architecture | None found | N/A | No exact chart endpoint | `architecture`, `parameters`, `inference_parameters_active_billions`, `release_date`, `intelligence_index` | Not available via documented public API; avoid page scraping. |
| Model Size: Total and Active Parameters | None found | N/A | No exact chart endpoint | `parameters`, `activeParams` / `inference_parameters_active_billions`, `short_name` | Not available via documented public API; commercial API or manual sources needed. |
| Intelligence vs. Active Parameters | None found | N/A | No exact chart endpoint | `activeParams`, `intelligence_index`, `short_name` | Not available via documented public API. |
| Intelligence vs. Total Parameters | None found | N/A | No exact chart endpoint | `parameters`, `intelligence_index`, `short_name` | Not available via documented public API. |
| Training Tokens By Model | None found | N/A | No exact chart endpoint | `training_information.training_tokens_trillions`, `short_name`, `model_creators` | Not available via documented public API. |
| Intelligence vs. Training Tokens | None found | N/A | No exact chart endpoint | `training_information.training_tokens_trillions`, `intelligence_index`, `short_name` | Not available via documented public API. |
| Context Length (Tokens), Median By Quarter | None found | N/A | No exact chart endpoint | `release_date`, `context_window_tokens`, `open_source_categorization`, quarterly medians | Not available via documented public API; can only be reconstructed if context window and license data are independently sourced. |

## Request/Data Shape Observations

The trends page chart code references fields including:

- Model identity: `short_name`, `name`, `slug`, `model_url`
- Creator metadata: `model_creators.name`, `model_creators.slug`, `model_creators.color`, `model_creators.country`, `model_creators.logo_small_url`
- Benchmark variables: `intelligence_index`, `reasoning_model`
- Price/speed variables: `price_1m_blended_3_to_1`, `timescaleData.median_output_speed`
- Release and classification variables: `release_date`, `open_source_categorization`, `is_open_weights`
- Size/context/training variables: `parameters`, `activeParams`, `inference_parameters_active_billions`, `context_window_tokens`, `training_information.training_tokens_trillions`
- Capex variables: `microsoft`, `google`, `meta`, `amazon`, `oracle`, `apple` by quarter

These fields are not exposed as a stable trends API in the checked public documentation.

## Decision

`not_available_via_public_api`

Do not build a scraper against the trends page HTML/RSC payload or `_next/static` chunks. Those are public web assets but not a stable, documented data interface.

Recommended alternatives:

- contact Artificial Analysis for commercial API
- reconstruct trend variables from existing master database
- use quarterly State of AI reports as historical snapshots

