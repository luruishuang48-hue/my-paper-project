# Media Image Video Date Evidence

Input file: `Media_Image_Video_events.csv`

Output rule used here: first-party technical blog, first-party announcement, official documentation, official model page, or first-party technical report. When no accessible first-party dated source was found, `official_date` is left blank and the reason is recorded in `notes`.

One event, `AIT-2025-04-007`, contains three different model vendors. It is split into three evidence rows so the dates are not forced into one artificial event date.

## Summary

- Input events: 25
- Evidence rows: 27
- High confidence first-party dates: 10
- Medium confidence first-party or first-party-adjacent dates: 6
- Low confidence first-party pages without usable dates: 2
- Unresolved first-party dates: 9

## Evidence Table

| event_id | vendor | model_names | official_date | confidence | source_type | source |
|---|---|---|---|---|---|---|
| AIT-2022-10-001 | Stability AI / RunwayML | Stable Diffusion 1.5 |  | low | first-party model card mirror | [Stable Diffusion v1-5 Model Card](https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/raw/main/README.md) |
| AIT-2022-12-001 | Stability AI | Stable Diffusion 2.1 |  | unresolved | official blog not retrieved | Stable Diffusion v2.1 and DreamStudio Updates 7-Dec-22 |
| AIT-2023-07-001 | Stability AI | Stable Diffusion XL 1.0 |  | low | first-party model card | [SD-XL 1.0-base Model Card](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0) |
| AIT-2023-12-001 | Midjourney | Midjourney v6 | 2023-12-20 | high | official documentation | [Version](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version) |
| AIT-2024-02-001 | Stability AI | Stable Diffusion 3 | 2024-02-22 | high | official blog | [Stable Diffusion 3](https://stability.ai/news/stable-diffusion-3) |
| AIT-2024-04-001 | Stability AI | Stable Audio 2.0 | 2024-04-03 | high | official blog | [Introducing Stable Audio 2.0](https://stability.ai/news/stable-audio-2-0) |
| AIT-2024-04-006 | Adobe | Firefly 3 |  | unresolved | official source not found | Firefly Image 3 Foundation Model |
| AIT-2024-06-001 | Stability AI | Stable Diffusion 3 | 2024-06-12 | high | official blog | [Announcing the Open Release of Stable Diffusion 3 Medium](https://stability.ai/news/stable-diffusion-3-medium) |
| AIT-2024-06-004 | Runway | Gen3 Alpha | 2024-06-17 | high | official research blog | [Runway Gen-3 Alpha](https://runwayml.com/research/introducing-gen-3-alpha) |
| AIT-2024-07-006 | Udio | Udio v1.5 |  | unresolved | official source not found | Udio v1.5 |
| AIT-2024-07-008 | Midjourney | Midjourney v6.1 | 2024-07-30 | high | official documentation | [Version](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version) |
| AIT-2024-08-001 | Black Forest Labs | Flux | 2024-08-01 | high | official blog | [Announcing Black Forest Labs](https://bfl.ai/blog/24-08-01-bfl) |
| AIT-2024-09-004 | KlingAI / Kuaishou | KLING 1.5 |  | unresolved | official source not found | KLING 1.5 |
| AIT-2024-10-001 | Black Forest Labs | Flux 1.1 Pro | 2024-10-02 | high | official blog | [Announcing FLUX1.1 [pro] and the BFL API](https://bfl.ai/blog/24-10-02-flux) |
| AIT-2024-10-003 | Pika | Video Model 1.5 |  | unresolved | official source not found | Pika 1.5 |
| AIT-2024-10-010 | Stability AI | Stable Diffusion 3.5 | 2024-10-22 | high | official blog | [Introducing Stable Diffusion 3.5](https://stability.ai/news/introducing-stable-diffusion-3-5) |
| AIT-2024-10-013 | Recraft | Recraft v3 | 2024-10 | medium | official documentation | [Recraft V3](https://www.recraft.ai/docs/recraft-models/recraft-V3) |
| AIT-2024-12-011 | Pika | 2.0 |  | unresolved | official source not found | Pika 2.0 |
| AIT-2024-12-016 | KlingAI / Kuaishou | Kling 1.6 |  | unresolved | official source not found | Kling 1.6 |
| AIT-2025-04-006 | Midjourney | v7 | 2025-04-03 | high | official documentation | [Version](https://docs.midjourney.com/hc/en-us/articles/32199405667853-Version) |
| AIT-2025-04-007 | Runway | Runway Gen-4 | 2025-03-31 | medium | official research page | [Runway Gen-4](https://runwayml.com/research/introducing-runway-gen-4) |
| AIT-2025-04-007 | Vidu | Vidu Q1 |  | unresolved | official source not found | Vidu Q1 |
| AIT-2025-04-007 | KlingAI / Kuaishou | Kling 2.0 |  | unresolved | official source not found | Kling 2.0 |
| AIT-2025-09-001 | ByteDance Seed | Seedream 4.0 | 2025-09-24 | medium | first-party technical report | [Seedream 4.0](https://arxiv.org/abs/2509.20427) |
| AIT-2025-11-008 | Black Forest Labs | FLUX 2 | 2025-11-25 | medium | official model page | [FLUX.2](https://bfl.ai/models/flux-2) |
| AIT-2025-12-005 | Runway | Gen-4.5 | 2025-12-01 | medium | official research page not retrieved | [Introducing Runway Gen-4.5](https://runwayml.com/research/introducing-runway-gen-4-5) |
| AIT-2026-02-004 | ByteDance Seed | Seedance 2.0 | 2026-02 | medium | first-party technical report | [Seedance 2.0](https://arxiv.org/abs/2604.14148) |

## Unresolved First-Party Dates

The following rows should not be treated as dated by official evidence yet.

- Stable Diffusion 1.5. Accessible model card confirms the model, but no date was exposed.
- Stable Diffusion 2.1. Search indexes reference an official Stability AI page dated 7-Dec-22, but the page itself was not retrieved.
- Stable Diffusion XL 1.0. Official model card confirms the model, but no official release day was exposed.
- Adobe Firefly Image 3. Secondary coverage reports 2024-04-23, but no Adobe first-party page was retrieved.
- Udio v1.5. Secondary sources report 2024-07-23, but no Udio first-party page was retrieved.
- Kling 1.5, Kling 1.6, Kling 2.0. No accessible Kuaishou or Kling first-party announcement page was found.
- Pika 1.5 and Pika 2.0. No accessible Pika first-party announcement page was found.
- Vidu Q1. No accessible first-party announcement page was found.

## Notes

- Dates without a day, such as `2024-10` and `2026-02`, are intentionally month-level because the first-party source did not provide a daily date.
- Runway Gen-4 and Gen-4.5 are marked medium rather than high where the official page was found or referenced but the retrieved text did not expose the date directly.
- ByteDance Seed product pages were accessible but did not expose daily dates. For Seedream 4.0 and Seedance 2.0, first-party technical report dates or month statements are used instead.
