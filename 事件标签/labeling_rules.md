# 事件标签编码细则（coder A/B 共同遵守）

依据 `aitimeline_model_events_enriched_codebook.md` 第 41-48 字段定义具体化。
编码单位是**事件**（event_id），不是单个模型。多模型事件先确定旗舰代表模型
（`new data set/processed/event_aa_metrics.csv` 的 representative_aa_name），
涉及"代表模型"的字段以旗舰为准，涉及"事件包含"的字段看全部组件。

## 可用证据

只允许使用：事件行的 model_names / aa_names / event_text / aa_creators、
AA 记录的 aa_modality、发布方与模型的公开常识（权重是否公开、是否推理模型）。
不确定时编 0（保守默认，同旧规则），并在 notes 里写"不确定"。

## 各字段判据

1. **model_modalities**：事件内全部身份匹配 AA 记录的 aa_modality 去重合集，
   分号分隔，按 AA 原始词汇（language, text-to-image, text-to-video, ...）。
2. **is_cross_modality_release** = 1 当且仅当 modalities 同时含 language 和
   至少一种媒体模态（image/video/speech/music 类）。
3. **is_model_family** = 1 当事件发布 ≥2 个同系列不同规格/档位变体
   （如 GPT-5.4 + mini + nano；Gemini 家族多档），或 event_text 明说 family/系列。
   同名单模型多快照（如仅一个模型）= 0。
4. **is_multimodal** = 1 当旗舰代表模型支持多模态输入或输出（GPT-4o、Gemini
   系列原生多模态 = 1；纯文本 LLM 如 DeepSeek R1 = 0；媒体生成模型本身
   不因"文生图"记 1，除非同时接受图文等多种输入——遵循旧口径：媒体模型默认 0，
   除非明确多模态输入）。
5. **is_reasoning_model** = 1 当旗舰是推理模型：名称含 o1/o3/R1/QwQ/Reasoning/
   Thinking/Deep Think，或 AA 名称带 (Reasoning)，或 event_text 主打 reasoning。
   注意混合档模型（GPT-5 系带 reasoning 档）按 AA 代表记录是否为 reasoning 档判断。
6. **is_coding_model** = 1 当旗舰主打编程：Codex/Coder/Devstral/Codestral/
   Claude Code 类。通用模型顺带 coding 强 = 0。
7. **is_media_generation_model** = 1 当事件包含任一图像/视频/语音/音乐生成组件
   （看全部组件，不只旗舰）。
8. **is_open_weight_or_open_source** = 1 当**事件发布的模型中含公开可下载权重的
   主要版本**（事件级判据，与旧 codebook 字段 42 口径一致；Llama、Qwen、DeepSeek、
   Mistral 开放系、Gemma、Phi、GPT-oss、Stable Diffusion、FLUX [dev/schnell]、
   GLM、Kimi K2、MiniMax M 系、QwQ 等）。全 API-only 事件（GPT-4/Claude/Gemini/
   Grok 3+/Veo/Sora/Kling/Midjourney）= 0。
   【修订记录】coder A 2026-07-03：原稿写"以旗舰为准"，但 FLUX 类事件旗舰是
   API 版而事件实质是放权重，旗舰判据会系统性误编；改为事件级判据。
   已在 coder B 编码前修订，A/B 用同一版规则。
9. **is_chinese_model** = 1 当发布方属中国生态：Alibaba/Qwen、DeepSeek、
   Moonshot/Kimi、Zhipu/Z.ai、MiniMax、ByteDance/Seed、Kuaishou/Kling、
   百度、腾讯、阶跃、01.AI、ShengShu/Vidu 等。注意 NVIDIA 发布的
   Llama-Nemotron = 0（美国），HK/新加坡壳但主体在中国的按中国编。

## 输出格式

每行一个事件：event_id、上述 9 个字段、notes（判断依据一句话）、coder、coded_at。
