# OpenAI date evidence

Input file: `OpenAI_events.csv`

Output rows: 21

Rule used: official OpenAI technical blog, product/research announcement, developer announcement, or first-party release notes. If no dated first-party announcement was found, `official_date` is left blank and the reason is recorded.

## Summary

Three rows are unresolved because no dated first-party announcement page was identified in this pass: DALL-E 2, DALL-E 3, and GPT-4o 0806.

Four rows are multi-model events with multiple dates in `official_date`: AIT-2024-12-002, AIT-2025-12-002, AIT-2026-03-002, and the o1/Sora row uses both product-page and release-note evidence.

Two rows have dates that differ from the AA label or AA date in the input: Sora 2 is dated 2025-09-30 on the OpenAI page, and GPT-5.1 is dated 2025-11-12 on the OpenAI page.

## Evidence table

| event_id | model_names | official_date | confidence | source |
|---|---|---:|---|---|
| AIT-2022-04-002 | DALL-E 2 |  | low | https://openai.com/index/dall-e-2/ |
| AIT-2023-03-002 | GPT-4 | 2023-03-14 | high | https://openai.com/index/gpt-4-research/ |
| AIT-2023-10-001 | DALL-E 3 |  | low | https://openai.com/index/dall-e-3/ |
| AIT-2024-05-001 | GPT-4o model | 2024-05-13 | high | https://openai.com/index/hello-gpt-4o/ |
| AIT-2024-07-001 | GPT-4o mini | 2024-07-18 | high | https://openai.com/index/gpt-4o-mini-advancing-cost-efficient-intelligence/ |
| AIT-2024-08-002 | GPT-4o 0806 |  | low |  |
| AIT-2024-09-002 | o1 preview; o1 mini | 2024-09-12 | high | https://openai.com/index/introducing-openai-o1-preview/ |
| AIT-2024-12-002 | SORA; o1; o1 Pro | 2024-12-09; 2024-12-05; 2024-12-05 | medium | https://openai.com/index/sora-is-here/; https://help.openai.com/en/articles/6825453-chatgpt-release-notes |
| AIT-2025-01-007 | o3 mini | 2025-01-31 | high | https://openai.com/index/openai-o3-mini/ |
| AIT-2025-02-007 | GPT-4.5 | 2025-02-27 | high | https://openai.com/index/introducing-gpt-4-5/ |
| AIT-2025-03-003 | GPT-4o Image Generation | 2025-03-25 | high | https://openai.com/index/introducing-4o-image-generation/ |
| AIT-2025-04-004 | GPT-4.1 | 2025-04-14 | high | https://openai.com/index/gpt-4-1/ |
| AIT-2025-04-005 | o3 full; o4 mini | 2025-04-16 | high | https://openai.com/index/introducing-o3-and-o4-mini/ |
| AIT-2025-06-003 | o3 pro | 2025-06-10 | medium | https://help.openai.com/en/articles/6825453-chatgpt-release-notes |
| AIT-2025-08-004 | gpt-oss-120b; gpt-oss-20b | 2025-08-05 | high | https://openai.com/index/introducing-gpt-oss/ |
| AIT-2025-08-005 | GPT-5 | 2025-08-07 | high | https://openai.com/index/introducing-gpt-5/ |
| AIT-2025-09-008 | Sora 2 | 2025-09-30 | high | https://openai.com/index/sora-2/ |
| AIT-2025-11-002 | GPT 5.1 | 2025-11-12 | high | https://openai.com/index/gpt-5-1/ |
| AIT-2025-12-002 | GPT-5.2; GPT-Image 1.5 | 2025-12-11; 2025-12-16 | medium | https://openai.com/index/introducing-gpt-5-2/; https://help.openai.com/en/articles/6825453-chatgpt-release-notes |
| AIT-2026-02-002 | GPT-5.3-Codex | 2026-02-05 | high | https://openai.com/index/introducing-gpt-5-3-codex/ |
| AIT-2026-03-002 | GPT-5.4; GPT-5.4 mini; GPT-5.4 nano | 2026-03-05; 2026-03-17; 2026-03-17 | medium | https://help.openai.com/en/articles/6825453-chatgpt-release-notes; https://openai.com/index/introducing-gpt-5-4-mini-and-nano/ |

## Unresolved rows

AIT-2022-04-002: DALL-E 2 has an official OpenAI page, but the fetched page did not expose the original dated announcement. I did not fill 2022-04 from the input month.

AIT-2023-10-001: DALL-E 3 has an official OpenAI page, but the fetched page did not expose the original dated announcement. I did not fill a September or October date without a dated first-party source.

AIT-2024-08-002: GPT-4o 0806 appears to be a model snapshot. I did not identify a first-party technical blog or dated announcement page for that snapshot, so the official date is blank.
