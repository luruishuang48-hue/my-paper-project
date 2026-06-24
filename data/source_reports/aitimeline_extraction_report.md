# AI Timeline 模型发布候选事件池抽取报告

## 抓取与解析

- 抓取时间：2026-04-27T01:36:32+08:00
- 数据源：`https://raw.githubusercontent.com/NHLOCAL/AiTimeline/main/_data/timeline.md`
- 本地缓存：`data/raw/aitimeline/timeline_2026-04-27.md`
- 是否使用缓存：是
- 抓取状态：used existing same-day cache
- 解析规则：仅解析 Markdown 中的 `# Year: YYYY`、`## Month` 和 `- event text`。未使用网页 HTML。

## 数量概览

- 原始条目数量：235
- 模型候选行数量：266
- 非模型条目数量：22
- ambiguous 条目数量：14
- 进入人工审核的候选行数量：136

## 原始条目按年份统计

- 2025: 95
- 2024: 94
- 2023: 18
- 2026: 17
- 2022: 11

## 候选模型按模态统计

- text_llm: 121
- image_generation: 36
- reasoning_llm: 26
- video_generation: 23
- multimodal_llm: 21
- music_generation: 11
- coding_llm: 11
- vision_language_model: 8
- audio_speech: 5
- image_editing: 3
- world_model: 1

## 候选模型按真实发布者统计

- Google: 61
- OpenAI: 41
- Anthropic: 20
- Alibaba: 17
- Mistral AI: 15
- xAI: 13
- Meta: 12
- DeepSeek: 12
- Microsoft: 11
- Midjourney: 10
- Stability AI: 10
- Suno: 6
- Adobe: 4
- Runway: 3
- Black Forest Labs: 3
- Kuaishou: 3
- Amazon: 3
- Moonshot AI: 3
- Zhipu AI: 3
- Pika Labs: 2
- Google DeepMind: 2
- ByteDance: 2
- Apple: 1
- Udio: 1
- Ideogram: 1
- Luma: 1
- Kyutai: 1
- unknown: 1
- Recraft: 1
- Sesame AI: 1

## 候选模型按 Tier 统计

- Tier 1: 134
- Tier 2: 125
- Tier 3: 7

## 高置信度 Tier 1 候选

- 2022-02 | Midjourney | Midjourney v1 | image_generation | confidence=0.75
- 2022-04 | Midjourney | Midjourney v2 | image_generation | confidence=0.75
- 2022-04 | OpenAI | DALL-E 2 | image_generation | confidence=1.0
- 2022-07 | Midjourney | Midjourney v3 | image_generation | confidence=1.0
- 2022-08 | Stability AI | Stable Diffusion 1.4 | image_generation | confidence=1.0
- 2022-10 | Stability AI | Stable Diffusion 1.5 | image_generation | confidence=1.0
- 2022-11 | Midjourney | Midjourney v4 | image_generation | confidence=1.0
- 2022-11 | Stability AI | Stable Diffusion 2.0 | image_generation | confidence=1.0
- 2022-12 | Stability AI | Stable Diffusion 2.1 | image_generation | confidence=1.0
- 2023-03 | Midjourney | Midjourney v5 | image_generation | confidence=1.0
- 2023-03 | OpenAI | GPT-4 | text_llm | confidence=1.0
- 2023-04 | Adobe | Firefly | image_generation | confidence=1.0
- 2023-05 | Midjourney | Midjourney v5.1 | image_generation | confidence=1.0
- 2023-06 | Midjourney | Midjourney v5.2 | image_generation | confidence=1.0
- 2023-07 | Stability AI | Stable Diffusion XL 1.0 | image_generation | confidence=1.0
- 2023-07 | Meta | LLaMA 2 | text_llm | confidence=1.0
- 2023-10 | OpenAI | DALL-E 3 | image_generation | confidence=1.0
- 2023-10 | Adobe | Firefly 2 | image_generation | confidence=1.0
- 2023-11 | Stability AI | Stable Diffusion XL Turbo | image_generation | confidence=1.0
- 2023-12 | Midjourney | Midjourney v6 | image_generation | confidence=1.0
- 2024-02 | Stability AI | Stable Diffusion 3 | image_generation | confidence=1.0
- 2024-02 | OpenAI | Sora | video_generation | confidence=1.0
- 2024-03 | Anthropic | Claude 3 | text_llm | confidence=1.0
- 2024-03 | Suno | Suno v3 | music_generation | confidence=1.0
- 2024-04 | Adobe | Firefly 3 | image_generation | confidence=1.0
- 2024-05 | OpenAI | GPT-4o | multimodal_llm | confidence=1.0
- 2024-05 | Suno | Suno v3.5 | music_generation | confidence=1.0
- 2024-06 | Stability AI | Stable Diffusion 3 | image_generation | confidence=1.0
- 2024-06 | DeepSeek | DeepSeekCoderV2 | coding_llm | confidence=1.0
- 2024-06 | Runway | Runway Gen3 Alpha | video_generation | confidence=1.0
- 2024-07 | Meta | llama 3.1 | text_llm | confidence=1.0
- 2024-07 | Mistral AI | Mistral Large 2 | text_llm | confidence=1.0
- 2024-07 | Midjourney | Midjourney v6.1 | image_generation | confidence=1.0
- 2024-08 | Black Forest Labs | FLUX | image_generation | confidence=1.0
- 2024-08 | OpenAI | GPT-4o 0806 | multimodal_llm | confidence=1.0
- 2024-08 | Google | Imagen 3 | image_generation | confidence=1.0
- 2024-08 | xAI | Grok 2 | text_llm | confidence=1.0
- 2024-08 | xAI | Grok 2 mini | text_llm | confidence=1.0
- 2024-09 | Alibaba | Qwen 2.5 | text_llm | confidence=1.0
- 2024-09 | Kuaishou | KLING 1.5 | video_generation | confidence=1.0
- 2024-09 | Meta | Llama 3.2 | text_llm | confidence=1.0
- 2024-10 | Black Forest Labs | Flux 1.1 Pro | image_generation | confidence=1.0
- 2024-10 | Adobe | Firefly Video | video_generation | confidence=1.0
- 2024-10 | Stability AI | Stable Diffusion 3.5 | image_generation | confidence=1.0
- 2024-11 | Suno | Suno v4 | music_generation | confidence=0.85
- 2024-11 | Mistral AI | Pixtral Large | vision_language_model | confidence=1.0
- 2024-12 | Amazon | Nova | text_llm | confidence=1.0
- 2024-12 | OpenAI | SORA | video_generation | confidence=1.0
- 2024-12 | OpenAI | o1 | reasoning_llm | confidence=1.0
- 2024-12 | OpenAI | o1 Pro | reasoning_llm | confidence=1.0
- 2024-12 | Google | Gemini-Exp-1206 | text_llm | confidence=0.85
- 2024-12 | Google | Gemini 2.0 Flash | multimodal_llm | confidence=1.0
- 2024-12 | Google | Gemini-2.0-Flash-Thinking | reasoning_llm | confidence=0.85
- 2024-12 | Google | Veo 2 | video_generation | confidence=1.0
- 2024-12 | Meta | Llama 3.3 70B | text_llm | confidence=1.0
- 2024-12 | Meta | Llama 3.1 405B | text_llm | confidence=1.0
- 2024-12 | DeepSeek | Deepseek V3 | text_llm | confidence=1.0
- 2024-12 | Alibaba | QVQ-72B-Preview | reasoning_llm | confidence=1.0
- 2024-12 | Kuaishou | Kling 1.6 | video_generation | confidence=1.0
- 2025-01 | Google | Gemini Flash Thinking 0121 | reasoning_llm | confidence=1.0

## 需要人工审核的主要原因

- multiple_models_in_raw_entry: 108
- possible_duplicate: 19
- mixed_product_or_agent_context: 18
- low_classification_confidence: 7
- research_system_or_benchmark_without_clear_model_release: 7
- release_action_unclear: 4
- research_system_or_benchmark_context: 4
- model_mentioned_without_extractable_model_name: 4
- business_or_hardware_context: 3
- not_direct_model_release_for_main_sample: 3

## 与 AA master database 的初步匹配

- 可匹配候选数量：263
- 找到 AA 候选的数量：239
- 初步候选发现率：90.9%
- 说明：这里只做 fuzzy matching 候选提示，不确认匹配，不回填任何 AA 指标。

## 数据局限

- AI Timeline 多数条目只有年月，没有具体日期；本次统一标记为 `month_only`，不编造日。
- AI Timeline 只作为候选事件发现来源，不是最终样本纳入标准。
- 自动分类可能把产品、agent、研究系统或模型更新误判为模型发布，因此低置信度和混合语境条目进入人工审核。
- 同一条原始记录可能包含多个模型；脚本会拆分候选行，并保留同一个 `raw_entry_id`。
- OpenAI、Anthropic、xAI 等非上市发布者没有被等同为 Microsoft、Amazon、Google 或 Tesla 的发布事件；相关股票只作为潜在暴露关系待后续映射。
- 不同模态模型只做同模态 AA 候选匹配，不合并不同模态的原始能力指标。
