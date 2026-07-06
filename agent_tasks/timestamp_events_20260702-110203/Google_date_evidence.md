# Google date evidence

Input file: `Google_events.csv`

Output scope: Google events only. Dates use first-party Google sources when a dated official blog or technical announcement was found. If no dated first-party source was found, `official_date` is left blank.

| event_id | model_names | official_date | source_type | confidence | source |
|---|---|---:|---|---|---|
| AIT-2023-05-002 | PaLM 2 | 2023-05-10 | Google Blog | high | [Introducing PaLM 2](https://blog.google/innovation-and-ai/products/google-palm-2-ai-large-language-model/) |
| AIT-2023-12-002 | Gemini Pro | 2023-12-06 | Google Blog | high | [Bard gets its biggest upgrade yet with Gemini](https://blog.google/products-and-platforms/products/gemini/google-bard-try-gemini-ai/) |
| AIT-2024-02-003 | Gemini Pro 1.5 | 2024-02-15 | Google Blog | high | [Our next-generation model: Gemini 1.5](https://blog.google/innovation-and-ai/products/google-gemini-next-generation-model-february-2024/) |
| AIT-2024-05-002 | Gemini Flash 1.5 model | 2024-05-14 | Google Blog | high | [Gemini breaks new ground with a faster model, longer context, AI agents and more](https://blog.google/innovation-and-ai/products/google-gemini-update-flash-ai-assistant-io-2024/) |
| AIT-2024-08-003 | Imagen 3 | 2024-12-16 | Google Blog | medium | [Whisk: Visualize and remix ideas using images and AI](https://blog.google/innovation-and-ai/models-and-research/google-labs/whisk/) |
| AIT-2024-08-006 | Gemini 1.5 Flash8B | 2024-10-03 | Google AI for Developers release notes | medium | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2024-09-007 | Gemini Pro 1.5 002; Gemini Flash 1.5 002 | 2024-09-24 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2024-12-004 | Gemini 2.0 Flash | 2024-12-11 | Google Blog | high | [Introducing Gemini 2.0: our new AI model for the agentic era](https://blog.google/innovation-and-ai/models-and-research/google-deepmind/google-gemini-ai-update-december-2024/) |
| AIT-2024-12-005 | Gemini-2.0-Flash-Thinking | 2024-12-19 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2024-12-006 | Veo 2 |  | Google DeepMind model page | low | [Veo](https://deepmind.google/models/veo/) |
| AIT-2025-01-002 | Gemini Flash Thinking 0121 | 2025-01-21 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2025-02-004 | Gemini 2.0 Flash; Gemini 2.0 Flash-Lite Preview; Gemini 2.0 Pro Experimental | 2025-02-05 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2025-03-001 | Gemini 2.5 Pro | 2025-03-25 | Google Blog | high | [Gemini 2.5: Our most intelligent AI model](https://blog.google/innovation-and-ai/models-and-research/google-deepmind/gemini-model-thinking-updates-march-2025/) |
| AIT-2025-04-002 | Gemini 2.5 Flash | 2025-04-17 | Google Developers Blog | high | [Start building with Gemini 2.5 Flash](https://developers.googleblog.com/en/start-building-with-gemini-25-flash/) |
| AIT-2025-05-004 | Veo 3; Imagen 4 | 2025-05-20 | Google Blog | high | [Fuel your creativity with new generative media models and tools](https://blog.google/innovation-and-ai/products/generative-media-models-io-2025/) |
| AIT-2025-05-012 | Gemma 3n | 2025-05-20 | Google Developers Blog | high | [Announcing Gemma 3n preview: powerful, efficient, mobile-first AI](https://developers.googleblog.com/en/introducing-gemma-3n/) |
| AIT-2025-08-007 | Gemini 2.5 Flash Image | 2025-08-26 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2025-11-004 | Gemini 3.0 | 2025-11-18 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2025-11-006 | Nano Banana Pro | 2025-11-20 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2025-12-003 | Gemini 3.0 Flash; Gemini 2.5 Flash Audio | 2025-12-17 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |
| AIT-2026-02-003 | Gemini 3 Deep Think |  | Google DeepMind model page | low | [Gemini 3.1 Deep Think](https://deepmind.google/models/gemini/deep-think/) |
| AIT-2026-02-008 | Nano Banana 2 | 2026-02-26 | Google AI for Developers release notes | high | [Release notes](https://ai.google.dev/gemini-api/docs/changelog) |

Notes:

- `AIT-2024-08-003` uses a dated Google Labs post that names Imagen 3 as the latest image model behind Whisk. I did not find a dated first-party August 2024 release page.
- `AIT-2024-08-006` dates the stable AA record for Gemini 1.5 Flash-8B. I did not find a dated first-party page for the August experimental announcement.
- `AIT-2024-12-006` and `AIT-2026-02-003` are left without `official_date` because I found official model pages but no dated first-party blog or technical announcement during this pass.
- `AIT-2025-12-003` uses 2025-12-17 for Gemini 3 Flash Preview. The same official release notes list Gemini 2.5 Flash Native Audio Preview on 2025-12-12.
