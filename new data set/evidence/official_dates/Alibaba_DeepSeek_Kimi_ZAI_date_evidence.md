# Alibaba, DeepSeek, Kimi, Z AI date evidence

Input file
`Alibaba_DeepSeek_Kimi_ZAI_events.csv`

Output criterion
Dates use official technical blogs, official API news pages, official research pages, official model cards, official GitHub repositories, or first-party technical reports. Rows with no official first-party source found are left blank in the CSV.

## Summary

Total rows checked: 24

Rows with high confidence dates: 16

Rows with medium confidence dates: 6

Rows left blank: 2

Blank rows:

- `AIT-2025-09-006` Wan 2.5
- `AIT-2025-12-008` Z-Image-Turbo; Qwen-Image-2512

## Evidence table

| event_id | vendor | model_names | official_date | confidence | primary source |
|---|---|---|---|---|---|
| AIT-2024-06-003 | DeepSeek | DeepSeekCoderV2 | 2024-06-17 | high | DeepSeek-authored arXiv technical report |
| AIT-2024-09-003 | Alibaba | Qwen 2.5 | 2024-09-19 | high | Qwen official blog |
| AIT-2024-11-001 | Alibaba | QwQ 32B Preview | 2024-11-28 | high | Qwen official blog |
| AIT-2024-11-002 | Alibaba | Qwen2.5 Coder 32B | 2024-11-12 | high | Qwen official blog |
| AIT-2024-12-013 | DeepSeek | Deepseek V3 | 2024-12-26 | high | DeepSeek API Docs |
| AIT-2025-01-003 | DeepSeek | R1 | 2025-01-20 | high | DeepSeek API Docs |
| AIT-2025-01-005 | DeepSeek | Janus Pro 7B | 2025-01-27 | high | DeepSeek GitHub repository news |
| AIT-2025-01-006 | Alibaba | Qwen2.5-Max | 2025-01-28 | high | Qwen official blog |
| AIT-2025-03-005 | Alibaba | QwQ-32B | 2025-03-06 | high | Qwen official blog |
| AIT-2025-03-007 | DeepSeek | DeepSeek-V3-0324 | 2025-03-25 | high | DeepSeek API Docs |
| AIT-2025-04-008 | Alibaba | Qwen 3 | 2025-04-29 | high | Qwen official blog |
| AIT-2025-05-009 | DeepSeek | R1-0528 | 2025-05-28 | high | DeepSeek API Docs |
| AIT-2025-07-005 | Alibaba | Qwen3-235B-A22B-Instruct-2507; Qwen3-Coder | 2025-07-21; 2025-07-22 | medium | Qwen Hugging Face model card and Qwen blog |
| AIT-2025-07-006 | Kimi | Kimi K2 | 2025-07-11 | high | Kimi official research page |
| AIT-2025-07-007 | Z AI | GLM-4.5 | 2025-07-28 | medium | Z.ai official blog URL |
| AIT-2025-08-006 | DeepSeek | DeepSeek V3.1 | 2025-08-21 | high | DeepSeek API Docs |
| AIT-2025-09-005 | Alibaba | Qwen-3-Max | 2025-09-24 | medium | Qwen official blog URL |
| AIT-2025-09-006 | Alibaba | Wan 2.5 |  | low | No official source found |
| AIT-2025-09-009 | DeepSeek | DeepSeek-V3.2-Exp | 2025-09-29 | high | DeepSeek API Docs |
| AIT-2025-11-001 | Kimi | Kimi K2 Thinking | 2025-11-06 | high | Kimi official research page |
| AIT-2025-12-007 | Z AI | GLM-4.7 | 2025-12-22 | medium | Z.ai official blog URL |
| AIT-2025-12-008 | Alibaba | Z-Image-Turbo; Qwen-Image-2512 |  | low | No official source found |
| AIT-2026-01-003 | Kimi | Kimi K2.5 | 2026-01-27 | high | Kimi official research page |
| AIT-2026-02-005 | Z AI | GLM-5 | 2026-02-11 | medium | Z.ai official blog URL |

## Notes

For Qwen, several official blog dates differ from AA dates by one day. I kept the technical blog date because the task specifies vendor blog time.

For Z.ai, official blog URLs exist but render through JavaScript and did not expose dates through static reading. The CSV keeps these rows at medium confidence.

For Wan 2.5 and Z-Image-Turbo / Qwen-Image-2512, I did not find official first-party evidence for the exact names. These are blank rather than inferred.
