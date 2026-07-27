# Meta, Mistral, and Microsoft date evidence

Input file:

`Meta_Mistral_Microsoft_events.csv`

Output CSV:

`Meta_Mistral_Microsoft_date_evidence.csv`

Scope:

First-party technical blogs, official news posts, or first-party model cards were used. For Meta, priority was `ai.meta.com/blog`. For Mistral, priority was `mistral.ai/news` and official Mistral Docs model cards. For Microsoft, priority was Microsoft Azure Blog, Microsoft Research, or official Microsoft model cards.

## Evidence table

| event_id | vendor | model_names | official_date | source_type | source |
|---|---|---|---|---|---|
| AIT-2023-07-003 | Meta | LLaMA 2 | 2023-07-18 | official_blog | [Meta and Microsoft Introduce the Next Generation of Llama](https://ai.meta.com/blog/llama-2/) |
| AIT-2024-04-003 | Mistral | Mixtral 8x22B | 2024-04-17 | official_blog | [Cheaper, Better, Faster, Stronger](https://mistral.ai/news/mixtral-8x22b/) |
| AIT-2024-04-004 | Meta | LLaMA 3 | 2024-04-18 | official_blog | [Introducing Meta Llama 3](https://ai.meta.com/blog/meta-llama-3/) |
| AIT-2024-04-005 | Microsoft | Phi-3-mini | 2024-04-23 | official_blog | [Introducing Phi-3](https://azure.microsoft.com/en-us/blog/introducing-phi-3-redefining-whats-possible-with-slms/) |
| AIT-2024-07-002 | Meta | llama 3.1 model | 2024-07-23 | official_blog | [Introducing Llama 3.1](https://ai.meta.com/blog/meta-llama-3-1/) |
| AIT-2024-07-007 | Mistral | Mistral Large 2 | 2024-07-24 | official_blog | [Large Enough](https://mistral.ai/news/mistral-large-2407/) |
| AIT-2024-09-006 | Meta | Llama 3.2 | 2024-09-25 | official_blog | [Llama 3.2](https://ai.meta.com/blog/llama-3-2-connect-2024-vision-edge-mobile-devices/) |
| AIT-2024-09-010 | Mistral | Mistral Small | 2024-09-17 | official_model_card | [Mistral Small 2.0](https://docs.mistral.ai/models/model-cards/mistral-small-2-0-24-09) |
| AIT-2024-11-005 | Mistral | Pixtral Large | 2024-11-18 | official_blog | [Pixtral Large](https://mistral.ai/news/pixtral-large/) |
| AIT-2024-12-008 | Microsoft | Phi4 | 2024-12-12 | official_model_card | [microsoft/phi-4](https://huggingface.co/microsoft/phi-4) |
| AIT-2024-12-009 | Meta | Llama 3.3 70B | 2024-12-06 | official_model_card | [meta-llama/Llama-3.3-70B-Instruct](https://huggingface.co/meta-llama/Llama-3.3-70B-Instruct) |
| AIT-2025-02-006 | Microsoft | Phi4-mini; Phi4 Multimodal | 2025-02-26 | official_blog | [Empowering innovation: The next generation of the Phi family](https://azure.microsoft.com/en-us/blog/empowering-innovation-the-next-generation-of-the-phi-family/) |
| AIT-2025-04-001 | Meta | Llama 4 | 2025-04-05 | official_blog | [The Llama 4 herd](https://ai.meta.com/blog/llama-4-multimodal-intelligence/) |
| AIT-2025-12-001 | Mistral | Mistral 3; Devstral 2 | 2025-12-02; 2025-12-09 | official_blog | [Introducing Mistral 3](https://mistral.ai/news/mistral-3/) and [Devstral 2 and Mistral Vibe CLI](https://mistral.ai/news/devstral-2-vibe-cli/) |
| AIT-2026-03-003 | Mistral | Mistral Small 4 | 2026-03-16 | official_model_card | [Mistral Small 4](https://docs.mistral.ai/models/model-cards/mistral-small-4-0-26-03) |

## Notes

- Llama 3.3 and Phi-4 use official Hugging Face model cards because I did not find stable first-party blog pages for those rows in this pass.
- Mistral Small 2.0 and Mistral Small 4 use official Mistral Docs model cards because I did not find separate `mistral.ai/news` posts in this pass.
- AIT-2025-12-001 combines two official Mistral announcements. The Mistral 3 family date is 2025-12-02. The Devstral 2 date is 2025-12-09.
- AIT-2025-02-006 confirms that Phi-4-mini and Phi-4-multimodal were announced on 2025-02-26. This conflicts with the input AA date `2024-02-26` for Phi-4 Mini, which appears to be a typo.
