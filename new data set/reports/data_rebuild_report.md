# AI Timeline 与 Artificial Analysis 数据重建报告

生成时间 2026-06-25 19:15:50

## 文件清单

- 原始 AI Timeline 数据 `new data set/raw/ai_timeline_timeline.yml` 和 `new data set/raw/ai_timeline_timeline.json`
- 原始 AA API 数据 `new data set/raw/aa_api_v2/`
- 原始 AA 网页排行榜数据 `new data set/raw/aa_website_api/`
- 清洗后事件表 `new data set/processed/ai_timeline_events.csv`
- 清洗后实体表 `new data set/processed/ai_timeline_entities.csv`
- AA 合并模型表 `new data set/processed/aa_models.csv`
- 匹配结果 `new data set/processed/ai_timeline_aa_model_matches.csv`
- 需人工审核匹配 `new data set/processed/ai_timeline_aa_model_matches_review.csv`

## 数据来源

- AI Timeline 来自 `https://github.com/NHLOCAL/AiTimeline/blob/main/_data/timeline.yml`
- AA 正式 API 文档来自 `https://artificialanalysis.ai/data-api/docs`
- AA 免费 API 使用 `x-api-key` 请求，报告不保存也不展示密钥
- AA 官方文档说明 API 基址为 `https://artificialanalysis.ai/api/v2`，认证头为 `x-api-key`

## AI Timeline 概况

- 事件总数 235
- 年份分布 2022 年 11 条, 2023 年 18 条, 2024 年 94 条, 2025 年 95 条, 2026 年 17 条
- 事件类型 mixed 5, model 200, model_context_without_bold_entity 6, other 3, product 21
- 加粗实体总数 308
- 实体类型 model 266, other 16, product 26

## AA 数据概况

- 合并模型记录 1191 条
- 模态分布 image-editing 68, image-to-video 79, image-to-video-audio 28, language 542, music-instrumental 16, music-with-vocals 13, speech-to-speech 31, speech-to-text 66, text-to-image 148, text-to-speech 86, text-to-video 85, text-to-video-audio 29
- 旧版 LLM 端点 `/api/v2/data/llms/models` 返回 542 条，是本次语言模型匹配主表
- 新版 `/api/v2/language/models/free` 返回 200 条，Pro 端点在当前 key 下返回 403

### AA API 抓取状态

```text
200	148203	/api/v2/language/models/free	new data set/raw/aa_api_v2/language_models_free.json
403	60	/api/v2/language/models	new data set/raw/aa_api_v2/language_models.json
403	145	/api/v2/language/providers	new data set/raw/aa_api_v2/language_providers.json
200	29949	/api/v2/media/text-to-image/models/free	new data set/raw/aa_api_v2/media_text-to-image_models_free.json
403	65	/api/v2/media/text-to-image/models?include_categories=true	new data set/raw/aa_api_v2/media_text-to-image_models_include_categories_true.json
200	13928	/api/v2/media/image-editing/models/free	new data set/raw/aa_api_v2/media_image-editing_models_free.json
403	65	/api/v2/media/image-editing/models?include_categories=true	new data set/raw/aa_api_v2/media_image-editing_models_include_categories_true.json
200	16509	/api/v2/media/text-to-video/models/free	new data set/raw/aa_api_v2/media_text-to-video_models_free.json
403	65	/api/v2/media/text-to-video/models?include_categories=true	new data set/raw/aa_api_v2/media_text-to-video_models_include_categories_true.json
200	15491	/api/v2/media/image-to-video/models/free	new data set/raw/aa_api_v2/media_image-to-video_models_free.json
403	66	/api/v2/media/image-to-video/models?include_categories=true	new data set/raw/aa_api_v2/media_image-to-video_models_include_categories_true.json
200	5718	/api/v2/media/text-to-video-audio/models/free	new data set/raw/aa_api_v2/media_text-to-video-audio_models_free.json
403	76	/api/v2/media/text-to-video-audio/models?include_categories=true	new data set/raw/aa_api_v2/media_text-to-video-audio_models_include_categories_true.json
200	5550	/api/v2/media/image-to-video-audio/models/free	new data set/raw/aa_api_v2/media_image-to-video-audio_models_free.json
403	77	/api/v2/media/image-to-video-audio/models?include_categories=true	new data set/raw/aa_api_v2/media_image-to-video-audio_models_include_categories_true.json
200	16715	/api/v2/media/text-to-speech/models/free	new data set/raw/aa_api_v2/media_text-to-speech_models_free.json
403	66	/api/v2/media/text-to-speech/models	new data set/raw/aa_api_v2/media_text-to-speech_models.json
200	7815	/api/v2/media/speech-to-speech/models/free	new data set/raw/aa_api_v2/media_speech-to-speech_models_free.json
403	68	/api/v2/media/speech-to-speech/models	new data set/raw/aa_api_v2/media_speech-to-speech_models.json
200	11595	/api/v2/media/speech-to-text/models/free	new data set/raw/aa_api_v2/media_speech-to-text_models_free.json
403	66	/api/v2/media/speech-to-text/models	new data set/raw/aa_api_v2/media_speech-to-text_models.json
200	2709	/api/v2/media/music/instrumental/models/free	new data set/raw/aa_api_v2/media_music_instrumental_models_free.json
403	70	/api/v2/media/music/instrumental/models?include_genres=true	new data set/raw/aa_api_v2/media_music_instrumental_models_include_genres_true.json
200	2196	/api/v2/media/music/with-vocals/models/free	new data set/raw/aa_api_v2/media_music_with-vocals_models_free.json
403	69	/api/v2/media/music/with-vocals/models?include_genres=true	new data set/raw/aa_api_v2/media_music_with-vocals_models_include_genres_true.json
200	469424	/api/v2/data/llms/models	new data set/raw/aa_api_v2/data_llms_models.json
200	38644	/api/v2/data/media/text-to-image	new data set/raw/aa_api_v2/data_media_text-to-image.json
200	17872	/api/v2/data/media/image-editing	new data set/raw/aa_api_v2/data_media_image-editing.json
200	17993	/api/v2/data/media/text-to-speech	new data set/raw/aa_api_v2/data_media_text-to-speech.json
200	22833	/api/v2/data/media/text-to-video	new data set/raw/aa_api_v2/data_media_text-to-video.json
200	21405	/api/v2/data/media/image-to-video	new data set/raw/aa_api_v2/data_media_image-to-video.json
```

### AA 网页排行榜补充数据

| 文件 | 状态 | 记录数 | 字节数 |
|---|---:|---:|---:|
| host_models_performance_100k_p1.json | 200 | 870 | 22550263 |
| host_models_performance_100k_p10.json | 200 | 0 | 94 |
| host_models_performance_long_p1.json | 200 | 923 | 23550119 |
| host_models_performance_long_p10.json | 200 | 0 | 93 |
| host_models_performance_medium_coding_p1.json | 200 | 942 | 23959548 |
| host_models_performance_medium_coding_p10.json | 200 | 0 | 92 |
| host_models_performance_medium_p1.json | 200 | 942 | 23948690 |
| host_models_performance_medium_p10.json | 200 | 927 | 22354496 |
| host_models_performance_vision_single_image_p1.json | 200 | 457 | 11115851 |
| host_models_performance_vision_single_image_p10.json | 200 | 0 | 92 |

## 分类规则

- 先读取事件中的 `<b>...</b>` 加粗实体
- 公司名被标为 `other`，例如 OpenAI、Google、Meta
- ChatGPT、Bard、Copilot+、AI Overviews、Operator 等被标为 `product`
- 出现 GPT、Claude、Gemini、Llama、Mistral、Qwen、DeepSeek、Grok、Phi、Gemma、Stable Diffusion、DALL-E、Midjourney、Imagen、Veo、Sora、Flux 等模型族，或上下文明确写有 model、language model、open-source、parameters、video generation、music creation 等词时，标为 `model`
- 同一事件同时包含模型和产品实体时，事件类型标为 `mixed`

## 匹配规则

- 对实体名和 AA 模型名做规范化，统一大小写、连字符、括号和 `model/models` 等泛词
- 短名称会结合事件上下文推断创建方，例如 DeepSeek 的 R1、Suno 的 v4
- 匹配分数综合字符相似度、词集合相似度、包含关系、创建方一致和模态一致
- `exact_or_near_exact` 和 `high` 通常可直接使用，`medium`、`low`、`unmatched` 已标记为需审核

## 匹配结果概况

- 待匹配 AI Timeline 模型实体 266 个
- 匹配等级 exact_or_near_exact 207, high 21, low 16, medium 19, unmatched 3
- 非 unmatched 记录 263 个
- 需人工审核记录 38 个

## 需优先审核样本

| AI Timeline 实体 | 年月 | 匹配等级 | 分数 | AA 候选 | 事件文本 |
|---|---:|---:|---:|---|---|
| text-davinci-002 | 2022 March | unmatched | 0.5428 |  | OpenAI releases text-davinci-002 and code-davinci-002 with an API approach. |
| code-davinci-002 | 2022 March | low | 0.6225 | GPT-5.1 Codex mini (high) | OpenAI releases text-davinci-002 and code-davinci-002 with an API approach. |
| Firefly 2 | 2023 October | medium | 0.8778 | Firefly Image 4 | Adobe releases Firefly 2 . |
| OpenELM | 2024 April | unmatched | 0.5926 |  | Apple releases as full open source a series of small language models under the name OpenELM . The models are availabl... |
| Music AI | 2024 May | medium | 0.78 | Studio | Google announces a large number of AI features in its products. The main ones: increasing the token limit to 2 millio... |
| Astra model | 2024 May | medium | 0.8007 | Standard | Google announces a large number of AI features in its products. The main ones: increasing the token limit to 2 millio... |
| Phi-3 Small | 2024 May | low | 0.7267 | Phi-3 Mini Instruct 3.8B | Microsoft announces Copilot+ for dedicated computers, which will allow a full search of the user's history through sc... |
| Phi-3 Medium | 2024 May | medium | 0.7873 | Phi-3 Mini Instruct 3.8B | Microsoft announces Copilot+ for dedicated computers, which will allow a full search of the user's history through sc... |
| Phi-3 Vision | 2024 May | medium | 0.7873 | Phi-3 Mini Instruct 3.8B | Microsoft announces Copilot+ for dedicated computers, which will allow a full search of the user's history through sc... |
| Chameleon | 2024 May | low | 0.6526 | MusicGen | Meta introduces Chameleon , a new multimodal model that seamlessly renders text and images. |
| Florence 2 | 2024 June | low | 0.7429 | MAI-Voice-1 | Microsoft releases in open source a series of image recognition models called Florence 2 . |
| Codestral Mamba | 2024 July | medium | 0.8507 | Mistral Saba | mistral ai releases three new models: Codestral Mamba , Mistral NeMo and Mathstral designed for mathematics |
| Mathstral | 2024 July | medium | 0.8168 | Mistral Saba | mistral ai releases three new models: Codestral Mamba , Mistral NeMo and Mathstral designed for mathematics |
| AlphaProof | 2024 July | low | 0.6886 | Lyria 3 Pro | Google DeepMind has unveiled two new AI systems that won silver medals at this year's International Mathematical Olym... |
| AlphaGeometry 2 | 2024 July | low | 0.7457 | PALM-2 | Google DeepMind has unveiled two new AI systems that won silver medals at this year's International Mathematical Olym... |
| Phi 3.5 | 2024 August | medium | 0.7659 | Phi-3 Mini Instruct 3.8B | Microsoft has introduced its small language models, Phi 3.5 , in three versions, each showcasing impressive performan... |
| Dream Machine 1.5 | 2024 August | low | 0.7027 | HiDream-O1-Image-1.5 | Luma has unveiled the Dream Machine 1.5 model for video creation. |
| Pixtral12B | 2024 September | medium | 0.8292 | Pixtral Large | The French AI company Mistral has introduced Pixtral12B , its first multimodal model capable of processing both image... |
| Movie Gen | 2024 October | medium | 0.8007 | MusicGen | Meta unveils Movie Gen , a new AI model that generates videos, images, and audio from text input. |
| Aria | 2024 October | medium | 0.78 | Solaria-1, Gladia | Startup Rhymes AI releases Aria , an opensource, multimodal model exhibiting capabilities similar to comparably sized... |
| Meta Spirit LM | 2024 October | low | 0.685 | Llama 4 Scout | Meta releases an opensource speechtospeech language model named Meta Spirit LM . |
| Fluid | 2024 October | medium | 0.78 | Studio | Google DeepMind and MIT unveil Fluid , a texttoimage generation model with industryleading performance at a scale of ... |
| gemini-exp-1114 | 2024 November | low | 0.6807 | Gemini 1.5 Pro (Sep '24) | Google introduced two experimental models, gemini-exp-1114 and gemini-exp-1121 , currently leading the arena chatbot ... |
| gemini-exp-1121 | 2024 November | low | 0.6807 | Gemini 2.5 Pro | Google introduced two experimental models, gemini-exp-1114 and gemini-exp-1121 , currently leading the arena chatbot ... |
| Gemini-Exp-1206 | 2024 December | low | 0.6807 | Gemini 2.5 Pro | Google unveiled the experimental model Gemini-Exp-1206 , which ranked first in the chatbot leaderboard. |
| Aurora | 2024 December | low | 0.6687 | Grok Beta | xAI integrated Aurora , a new model for generating high-quality and realistic images. |
| Apollo | 2024 December | low | 0.62 | Llama 65B | Meta introduced Apollo , a video generation model available in three different sizes. |
| Titans | 2025 January | medium | 0.7743 | Standard | Google published a research paper on a new language model architecture called Titans , designed to enable models to r... |
| Qwen2.5-1M | 2025 January | medium | 0.8571 | Qwen2.5 Max | Alibaba unveiled Qwen2.5-Max , a large language model that surpasses several leading models, including DeepSeek-V3 , ... |
| Qwen2.5-VL | 2025 January | medium | 0.7619 | Qwen2.5 Max | Alibaba unveiled Qwen2.5-Max , a large language model that surpasses several leading models, including DeepSeek-V3 , ... |

## 使用建议

- 先审核 `ai_timeline_aa_model_matches_review.csv`
- 对 `medium` 和 `low` 记录，优先看 `top_candidates_json` 中前 5 个候选
- 对 `unmatched` 记录，判断是 AA 未覆盖、AI Timeline 实体不是模型，还是名称需要手工别名
- 人工确认后，可增加别名表再重跑脚本
