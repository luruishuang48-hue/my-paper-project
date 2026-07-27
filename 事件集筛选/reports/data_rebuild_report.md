# AI Timeline 与 Artificial Analysis 数据重建报告

生成时间 2026-07-27 17:06:48

## 文件清单

- 原始 AI Timeline 数据 `事件集筛选/raw/ai_timeline_timeline.json`
- 原始 AA API 数据 `事件集筛选/raw/aa_api_v2/`
- 清洗后事件表 `事件集筛选/processed/ai_timeline_events.csv`
- 清洗后实体表 `事件集筛选/processed/ai_timeline_entities.csv`
- AA 合并模型表 `事件集筛选/processed/aa_models.csv`
- 匹配结果 `事件集筛选/processed/ai_timeline_aa_model_matches.csv`
- 需人工审核匹配 `事件集筛选/processed/ai_timeline_aa_model_matches_review.csv`

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
- 语言模型记录来自 `/api/v2/data/llms/models` 快照
- 媒体模型记录来自各任务的 `/api/v2/data/media/` 快照

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
- `exact_or_near_exact` 和 `high` 直接采用；`medium`、`low` 中若最高分候选与实体名无共享有效词根（去除 model/version 等停用词后）且分数低于 0.75，自动改判为 `unmatched` 并记录 `auto_unmatch_reason`，不再进入人工审核队列
- 该自动判定规则已在全量样本上验证：不会把任何 `exact_or_near_exact` 或 `high` 记录降级
- 未被自动改判的 `medium`、`low` 记录（通常是同族但版本粒度不一致，如尺寸变体或实验快照），以及原生 `unmatched`，仍需人工审核

## 匹配结果概况

- 待匹配 AI Timeline 模型实体 266 个
- 匹配等级 exact_or_near_exact 207, high 21, low 7, medium 19, unmatched 12
- 非 unmatched 记录 254 个
- 其中自动改判为 unmatched 的记录 9 个（见 `ai_timeline_aa_model_matches_auto_unmatched.csv`）
- 仍需人工审核记录 26 个

## 需优先审核样本

| AI Timeline 实体 | 年月 | 匹配等级 | 分数 | AA 候选 | 事件文本 |
|---|---:|---:|---:|---|---|
| code-davinci-002 | 2022 March | low | 0.6225 | GPT-5.1 Codex mini (high) | OpenAI releases text-davinci-002 and code-davinci-002 with an API approach. |
| Firefly 2 | 2023 October | medium | 0.8778 | Firefly Image 4 | Adobe releases Firefly 2 . |
| Music AI | 2024 May | medium | 0.78 | Studio | Google announces a large number of AI features in its products. The main ones: increasing the token limit to 2 millio... |
| Astra model | 2024 May | medium | 0.8007 | Standard | Google announces a large number of AI features in its products. The main ones: increasing the token limit to 2 millio... |
| Phi-3 Small | 2024 May | low | 0.7267 | Phi-3 Mini Instruct 3.8B | Microsoft announces Copilot+ for dedicated computers, which will allow a full search of the user's history through sc... |
| Phi-3 Medium | 2024 May | medium | 0.7873 | Phi-3 Mini Instruct 3.8B | Microsoft announces Copilot+ for dedicated computers, which will allow a full search of the user's history through sc... |
| Phi-3 Vision | 2024 May | medium | 0.7873 | Phi-3 Mini Instruct 3.8B | Microsoft announces Copilot+ for dedicated computers, which will allow a full search of the user's history through sc... |
| Codestral Mamba | 2024 July | medium | 0.8507 | Mistral Saba | mistral ai releases three new models: Codestral Mamba , Mistral NeMo and Mathstral designed for mathematics |
| Mathstral | 2024 July | medium | 0.8168 | Mistral Saba | mistral ai releases three new models: Codestral Mamba , Mistral NeMo and Mathstral designed for mathematics |
| Phi 3.5 | 2024 August | medium | 0.7659 | Phi-3 Mini Instruct 3.8B | Microsoft has introduced its small language models, Phi 3.5 , in three versions, each showcasing impressive performan... |
| Dream Machine 1.5 | 2024 August | low | 0.7027 | HiDream-O1-Image-1.5 | Luma has unveiled the Dream Machine 1.5 model for video creation. |
| Pixtral12B | 2024 September | medium | 0.8292 | Pixtral Large | The French AI company Mistral has introduced Pixtral12B , its first multimodal model capable of processing both image... |
| Movie Gen | 2024 October | medium | 0.8007 | MusicGen | Meta unveils Movie Gen , a new AI model that generates videos, images, and audio from text input. |
| Aria | 2024 October | medium | 0.78 | Solaria-1, Gladia | Startup Rhymes AI releases Aria , an opensource, multimodal model exhibiting capabilities similar to comparably sized... |
| Fluid | 2024 October | medium | 0.78 | Studio | Google DeepMind and MIT unveil Fluid , a texttoimage generation model with industryleading performance at a scale of ... |
| gemini-exp-1114 | 2024 November | low | 0.6807 | Gemini 1.5 Pro (Sep '24) | Google introduced two experimental models, gemini-exp-1114 and gemini-exp-1121 , currently leading the arena chatbot ... |
| gemini-exp-1121 | 2024 November | low | 0.6807 | Gemini 2.5 Pro | Google introduced two experimental models, gemini-exp-1114 and gemini-exp-1121 , currently leading the arena chatbot ... |
| Gemini-Exp-1206 | 2024 December | low | 0.6807 | Gemini 2.5 Pro | Google unveiled the experimental model Gemini-Exp-1206 , which ranked first in the chatbot leaderboard. |
| Titans | 2025 January | medium | 0.7743 | Standard | Google published a research paper on a new language model architecture called Titans , designed to enable models to r... |
| Qwen2.5-1M | 2025 January | medium | 0.8571 | Qwen2.5 Max | Alibaba unveiled Qwen2.5-Max , a large language model that surpasses several leading models, including DeepSeek-V3 , ... |
| Qwen2.5-VL | 2025 January | medium | 0.7619 | Qwen2.5 Max | Alibaba unveiled Qwen2.5-Max , a large language model that surpasses several leading models, including DeepSeek-V3 , ... |
| Gemini Diffusion | 2025 May 2025 | medium | 0.7873 | Gemini 3 Flash (High), Google | Google releases Gemini Diffusion , an experimental text diffusion model achieving high-speed text generation with enh... |
| Gemini model for computer control | 2025 October 2025 | low | 0.6314 | Gemini 2.5 Lite, Google | Google released a Gemini model for computer control , achieving state-of-the-art (SOTA) performance in GUI automation. |
| Gemini 3.0 | 2025 November 2025 | medium | 0.8782 | Gemini 3 Pro Preview (high) | Google debuted Gemini 3.0 , a flagship "thinking" model that claimed the top spot on major benchmarks. |
| Mistral OCR 3 | 2025 December 2025 | medium | 0.8457 | Mistral Large 3 | Mistral AI launches the Mistral 3 family (Large & Ministral) alongside Mistral OCR 3 and the Devstral 2 coding series... |
| Claude Cowork | 2026 January 2026 | medium | 0.8507 | Claude 2.0 | Anthropic launches Claude Cowork , a research preview for delegating knowledge-work tasks across documents, spreadshe... |

## 使用建议

- 先审核 `ai_timeline_aa_model_matches_review.csv`，此时已排除自动判定的 unmatched 记录
- 对仍在 `medium`、`low` 的记录，优先看 `top_candidates_json` 中前 5 个候选
- `ai_timeline_aa_model_matches_auto_unmatched.csv` 中每条记录都附 `auto_unmatch_reason`，可直接核查判定依据
- 人工确认后，可增加别名表再重跑脚本
