# AI Timeline 235条原始记录 vs AA官方数据库（2026-06-25重新拉取）逐条匹配结果

用你提供的key重新拉取了AA官方API：542个LLM模型 + 466个media模型（text-to-image/image-editing/text-to-speech/text-to-video/image-to-video 五个端点），
跟重建出的235条AI Timeline原始记录逐条做模糊名称匹配（去除大小写、空格、括号后比对，支持子串和高相似度匹配）。

- 总条目: 235
- 能在AA数据库中找到名称匹配: 168
- 找不到匹配: 67

**注意**：这是用AA**现在（2026-06-25）**的数据库去匹配，不是当年4月抓取时刻的AA数据库状态，两者覆盖范围可能不同。
模糊匹配也可能有漏判（比如版本号、括号写法不一致导致匹配失败，但模型其实在AA库里），下面列表只能作为参考，不是100%精确的真值。

---

## 一、找不到AA匹配的条目（67条）

2. [2022-March] OpenAI releases **text-davinci-002** and **code-davinci-002** with an API approach.
8. [2022-November] **ChatGPT**, a chatbot by OpenAI using GPT-3.5, is released to the public and quickly becomes a viral sensation. (*special*)
13. [2023-February] Microsoft gradually releases **Bing AI**, an AI chat based on an upgraded GPT model integrating internet search.
16. [2023-March] Google releases the AI chat **Bard** in a limited capacity, based on the LaMDA language model.
25. [2023-October] Adobe releases **Firefly 2**.
36. [2024-March] Suno AI, which develops a model for creating music, releases **Suno v3** to the general public.
37. [2024-April] Stability AI releases a new update to the music creation model - **Stable Audio 2.0**.
43. [2024-April] The startup **Reka AI** presents a series of multimodal language models in 3 sizes. The models are capable of processing video, audio and images. The large model featured similar capabilities to GPT-4.
44. [2024-April] Apple releases as full open source a series of small language models under the name **OpenELM**. The models are available in four weights between 270 million and 3 billion parameters.
47. [2024-May] Microsoft announces **Copilot+** for dedicated computers, which will allow a full search of the user's history through screenshots of the user's activity. The company also released as open source the SLMs that display impressive capabilities in a minimal size: **Phi-3 Small**, **Phi-3 Medium**, and **Phi-3 Vision** which includes image recognition capability.
48. [2024-May] Meta introduces **Chameleon**, a new multimodal model that seamlessly renders text and images.
50. [2024-May] Google announces **AI Overviews** intended to give a summary of the relevant information in Google search. (*special*)
51. [2024-May] Suno AI releases an updated music creation model **Suno v3.5**.
54. [2024-June] Apple announces **Apple Intelligence**, an AI system that will be integrated into the company's devices and will combine AI models of different sizes for different tasks.
58. [2024-June] Microsoft releases in open source a series of image recognition models called **Florence 2**.
61. [2024-July] Meta releases as open source the **llama 3.1 model** in sizes 8B, 70B and 405B. The large model features the same capabilities as the best closed source models (*special*)
62. [2024-July] mistral ai releases three new models: **Codestral Mamba**, **Mistral NeMo** and **Mathstral** designed for mathematics
63. [2024-July] Google DeepMind has unveiled two new AI systems that won silver medals at this year's International Mathematical Olympiad (IMO),  **AlphaProof** and **AlphaGeometry 2**. (*special*)
64. [2024-July] OpenAI launched **SearchGPT**, an integrated web search
65. [2024-July] Startup Udio has released **Udio v1.5**, an updated version of its music creation model
73. [2024-August] Microsoft has introduced its small language models, **Phi 3.5**, in three versions, each showcasing impressive performance relative to their size.
76. [2024-August] Luma has unveiled the **Dream Machine 1.5** model for video creation.
77. [2024-September] The French AI company Mistral has introduced **Pixtral12B**, its first multimodal model capable of processing both images and text.
81. [2024-September] **OpenAI** launches the **advanced voice mode** of GPT 4o for all subscribers.
85. [2024-September] Google releases an update to its AI tool **NotebookLM** that enables users to create podcasts based on their own content.
88. [2024-October] Meta unveils **Movie Gen**, a new AI model that generates videos, images, and audio from text input.
89. [2024-October] Pika introduces **Video Model 1.5** along with "Pika Effects."
91. [2024-October] Startup Rhymes AI releases **Aria**, an opensource, multimodal model exhibiting capabilities similar to comparably sized proprietary models.
92. [2024-October] Meta releases an opensource speechtospeech language model named **Meta Spirit LM**.
94. [2024-October] **Janus AI**, a multimodal language model capable of recognizing and generating both text and images, is released as open source by DeepSeekAI.
95. [2024-October] Google DeepMind and MIT unveil **Fluid**, a texttoimage generation model with industryleading performance at a scale of 10.5B parameters.
98. [2024-October] Anthropic announces an experimental feature for computer use with a public beta API.
100. [2024-October] OpenAI has launched **Search GPT**, allowing users to perform web searches directly within the platform.
106. [2024-November] Google introduced two experimental models, **gemini-exp-1114** and **gemini-exp-1121**, currently leading the arena chatbot with enhanced performance.
110. [2024-December] Google unveiled the experimental model **Gemini-Exp-1206**, which ranked first in the chatbot leaderboard.
114. [2024-December] xAI integrated **Aurora**, a new model for generating high-quality and realistic images.
119. [2024-December] Meta introduced **Apollo**, a video generation model available in three different sizes.
124. [2025-January] OpenAI released **Operator** for Pro subscribers – an experimental AI agent capable of browsing websites and performing actions. (*special*)
125. [2025-January] Google introduced **Gemini Flash Thinking 0121**, an enhanced reasoning model that secured the top spot in the Arena Chatbots rankings.
127. [2025-January] Google published a research paper on a new language model architecture called **Titans**, designed to enable models to retain both short- and long-term memory. This architecture significantly improves processing for extended context windows. (*special*)
133. [2025-February] OpenAI unveils **Deep Research**, a tool for autonomous research, enabling real-time web searches and comprehensive report generation. (*special*)
135. [2025-February] Alibaba launches **QwQ-Max** – a reasoning model based on Qwen2.5-Max, offering improved analytical and logical capabilities.
139. [2025-March] Google launched the Gemma 3 series, featuring open-source multimodal models in various parameter sizes, a 128K context window, multi-language support, and integrated image and video understanding capabilities.
145. [2025-March] Sesame AI unveiled its **Conversational Speech Model (CSM)**, enabling remarkably human-like, real-time voice interaction, incorporating emotional nuances, natural pauses, laughter, and contextual memory. (*special*)
148. [2025-April] Amazon introduces **Nova Act**, a new framework for building multi-step autonomous agents.
155. [2025-May] Suno releases **Suno 4.5**, fixing shimmer noise and improving audio decay stability in long tracks.
159. [2025-May] Google releases **Jules**, an asynchronous autonomous coding agent on Gemini 2.5 Pro, analyzing repositories and creating GitHub Pull Requests.
163. [2025-May] Google DeepMind launches **AlphaEvolve**, an autonomous code-optimizer using evolutionary strategies with LLMs, achieving SOTA on 75% of math problems and discovering enhanced algorithms 20% of the time. (*special*)
164. [2025-May] Google releases **Gemini Diffusion**, an experimental text diffusion model achieving high-speed text generation with enhanced control and creativity via noise refinement. (*special*)
170. [2025-July] OpenAI unveils the **ChatGPT Agent**, embedding autonomous coding, web research and tool use directly within the chat interface. (*special*)
171. [2025-July] An experimental OpenAI model secures a **gold medal** at IMO 2025 without any external tools. (*special*)
178. [2025-August] Google DeepMind announced **Genie 3.0**, a "world model" for creating interactive 3D environments from text, maintaining consistency for several minutes. (*special*)
185. [2025-September] OpenAI reported a reasoning and code model achieved a perfect score (12/12) in ICPC testing. (*special*)
186. [2025-September] Suno released **Suno v5**, an upgrade in music generation with studio-grade fidelity and more natural-sounding vocals.
192. [2025-September] OpenAI and NVIDIA announced a strategic partnership for NVIDIA to supply at least **10 gigawatts** of AI systems for OpenAI's infrastructure. (*special*)
193. [2025-October] Figure unveiled **Figure 03**, a humanoid robot designed for domestic and general-purpose tasks.
194. [2025-October] Google released a **Gemini model for computer control**, achieving state-of-the-art (SOTA) performance in GUI automation.
196. [2025-October] OpenAI announced **ChatGPT Atlas**, an AI-native web browser with a built-in "Agent Mode" for task automation.
197. [2025-October] 1X announced **Neo**, a humanoid robot marketed as the first consumer-ready model for home use. (*special*)
207. [2025-November] Microsoft open-sourced **Fara-7B**, a small model optimized for browser agents and computer control.
208. [2025-November] **Poetiq** shatters the **ARC-AGI-2** benchmark with a score of over 60%, surpassing the human average.
214. [2025-December] xAI launches the **Grok Voice Agent API**, enabling native, real-time bidirectional audio streaming for developers.
218. [2025-December] A specialized system by **Poetiq**, powered by GPT-5.2, reportedly solves the **ARC-2** benchmark, marking a major breakthrough in abstract reasoning. (*special*)
219. [2026-January] **AxiomProver** solves all 12 problems from the 2025 Putnam exam using formal Lean proofs. (*special*)
220. [2026-January] Anthropic launches **Claude Cowork**, a research preview for delegating knowledge-work tasks across documents, spreadsheets, and presentations. (*special*)
223. [2026-January] **Moltbook**, a social platform where AI agents post and reply to each other, becomes a viral online phenomenon.
235. [2026-March] Suno launches **Suno v5.5**, adding Voices, Custom Models, and My Taste for more personalized music creation.

---

## 二、能找到AA匹配的条目（168条），附带匹配到的AA模型名/类型/相似度

1. [2022-February] **Midjourney v1**
   → 匹配到: Midjourney V1 (media_image-to-video, score=1.00)
3. [2022-April] **Midjourney v2**
   → 匹配到: Journey (media_text-to-speech, score=0.90)
4. [2022-April] **DALL-E 2** is announced for gradual release. (*special*)
   → 匹配到: DALLE 2 (media_text-to-image, score=1.00)
5. [2022-July] **Midjourney v3** is launched.
   → 匹配到: Journey (media_text-to-speech, score=0.90)
6. [2022-August] **Stable Diffusion 1.4** is released.
   → 匹配到: Stable Diffusion 2.1 (media_text-to-image, score=0.94)
7. [2022-October] **Stable Diffusion 1.5** becomes available. (*special*)
   → 匹配到: Stable Diffusion 1.5 (media_text-to-image, score=1.00)
9. [2022-November] **Midjourney v4** is released.
   → 匹配到: Journey (media_text-to-speech, score=0.90)
10. [2022-November] **Stable Diffusion 2.0** is launched.
   → 匹配到: Stable Diffusion 2.1 (media_text-to-image, score=0.94)
11. [2022-December] **Stable Diffusion 2.1** is released.
   → 匹配到: Stable Diffusion 2.1 (media_text-to-image, score=1.00)
12. [2023-February] Meta releases the **LLaMA** language model as open-source for research purposes. The model is later leaked. (*special*)
   → 匹配到: DeepHermes 3 - Llama-3.1 8B Preview (Non-reasoning) (llm, score=0.90)
14. [2023-March] **Midjourney v5** is launched.
   → 匹配到: Journey (media_text-to-speech, score=0.90)
15. [2023-March] OpenAI's **GPT-4** model is partially released, featuring multimodal image analysis and improved multi-language support. (*special*)
   → 匹配到: GPT-4 (llm, score=1.00)
17. [2023-April] Adobe releases the **Firefly** image creation model as a beta version to a waiting list. The model allowed a variety of capabilities including text formatting.
   → 匹配到: Firefly Image 5 Preview (media_text-to-image, score=0.90)
18. [2023-May] **Midjourney v5.1** is released.
   → 匹配到: Journey (media_text-to-speech, score=0.90)
19. [2023-May] Google announces an upgrade to Bard, moving it to the upgraded **PaLM 2** language model. It will support 180 countries and many languages.
   → 匹配到: PALM-2 (llm, score=1.00)
20. [2023-June] **Midjourney v5.2** is launched.
   → 匹配到: Journey (media_text-to-speech, score=0.90)
21. [2023-July] **Stable Diffusion XL 1.0** is released.
   → 匹配到: Stable Diffusion XL 1.0 (media_text-to-image, score=1.00)
22. [2023-July] Anthropic announces a new version of their large language model - **Claude 2**.
   → 匹配到: Claude 2.0 (llm, score=0.90)
23. [2023-July] Meta releases the **LLaMA 2** open source language model to the general public in a variety of sizes.
   → 匹配到: Llama 2 Chat 70B (llm, score=0.90)
24. [2023-October] **DALL-E 3** is released.
   → 匹配到: DALLE 3 (media_text-to-image, score=1.00)
26. [2023-November] **Stable Diffusion XL Turbo** is released - A fast model that allows the creation of an image in one step in real-time.
   → 匹配到: Stable Diffusion 3 Large Turbo (media_text-to-image, score=0.88)
27. [2023-December] **Midjourney v6** is launched.
   → 匹配到: Midjourney v6 (media_text-to-image, score=1.00)
28. [2023-December] Google upgrades Bard in limited areas, moving it to be based on the upgraded **Gemini Pro** language model.
   → 匹配到: Gemini 2.5 Pro (llm, score=0.90)
29. [2023-December] X Corporation launches **Grok AI** chatbot for paid subscribers in English language.
   → 匹配到: Grok 4 (llm, score=0.73)
30. [2024-February] Stability AI announces **Stable Diffusion 3** (gradually released to waiting list).
   → 匹配到: Stable Diffusion 3.5 Large Turbo (media_text-to-image, score=0.90)
31. [2024-February] Google upgrades the artificial intelligence chat in Bard, basing it on the new **Gemini Pro** model, in all available languages. Google replaces "Bard" with "Gemini".
   → 匹配到: Gemini 2.5 Pro (llm, score=0.90)
32. [2024-February] Google announces the **Gemini Pro 1.5** multimodal language model capable of parsing up to a million tokens, as well as parsing video and images. The model is gradually released to developers on a waiting list. (*special*)
   → 匹配到: o1 (llm, score=0.90)
33. [2024-February] OpenAI announces the **Sora** model that produces videos up to a minute long. The model is not released to the public at this time. (*special*)
   → 匹配到: Sora (media_text-to-video, score=1.00)
34. [2024-March] X Corporation announces the upcoming release of the **Grok 1.5** open source model.
   → 匹配到: Grok-1 (llm, score=0.90)
35. [2024-March] Anthropic announces **Claude 3**, a new version of their large language model. The version is deployed in 3 different sizes, with the largest model performing better than GPT-4.
   → 匹配到: Claude 3.5 Sonnet (Oct '24) (llm, score=0.90)
38. [2024-April] X Corporation releases an upgrade to its language model, **Grok-1.5V**, which integrates high-level image recognition. In the test presented by the company, the model is the best in identifying and analyzing images compared to other models.
   → 匹配到: Grok-1 (llm, score=0.90)
39. [2024-April] The Mistral company releases its new model **Mixtral 8x22B** as open source. This is the most powerful model among the open source models and it contains 141 billion parameters but uses a method that allows more economical use.
   → 匹配到: Mixtral 8x22B Instruct (llm, score=0.90)
40. [2024-April] Meta releases the **LLaMA 3** model as open source in sizes 8B and 70B parameters. The large model shows better performance than Claude 3 Sonnet and Gemini Pro 1.5 in several measures. Meta is expected to later release larger models with 400 billion parameters and more.
   → 匹配到: DeepHermes 3 - Llama-3.1 8B Preview (Non-reasoning) (llm, score=0.90)
41. [2024-April] Microsoft releases the **Phi-3-mini** model in open source. The model comes in a reduced version of 3.8B parameters, which allows it to run on mobile devices as well, and it presents capabilities similar to GPT-3.5. (*special*)
   → 匹配到: Phi-3 Mini Instruct 3.8B (llm, score=0.90)
42. [2024-April] Adobe announces its new image creation model **Firefly 3**.
   → 匹配到: Firefly Image 3 (media_text-to-image, score=0.76)
45. [2024-May] OpenAI announces the **GPT-4o model** that presents full multimodal capabilities, including receiving and creating text, images, and audio. The model presents an impressive ability to speak with a high response speed and in natural language. The model is 2 times more efficient than the GPT-4 Turbo model, and has better capabilities for languages other than English. (*special*)
   → 匹配到: GPT-4o (Aug '24) (llm, score=0.90)
46. [2024-May] Google announces a large number of AI features in its products. The main ones: increasing the token limit to 2 million for Gemini 1.5 to waiting list, releasing a smaller and faster **Gemini Flash 1.5 model**. Revealing the latest image creation model **Imagen 3**, music creation model **Music AI** and video creation model **Veo**. And the announcement of the **Astra model** with multimodal capabilities for realtime audio and video reception.
   → 匹配到: Imagen 3 (v002) (media_text-to-image, score=1.00); Veo 3.1 Fast Preview (media_text-to-video, score=0.90)
49. [2024-May] Mistral AI releases a new open source version of its language model **Mistral-7B-Instruct-v0.3**.
   → 匹配到: Mistral 7B Instruct (llm, score=0.90)
52. [2024-May] Mistral AI releases a new language model designed for coding **Codestral** in size 22B.
   → 匹配到: Devstral 2 (llm, score=0.78)
53. [2024-June] Stability AI releases its updated image creation model **Stable Diffusion 3** in a medium version in size 2B parameters.
   → 匹配到: Stable Diffusion 3.5 Large Turbo (media_text-to-image, score=0.90)
55. [2024-June] DeepSeekAI publishes the **DeepSeekCoderV2** open source language model which presents similar coding capabilities to models such as GPT-4, Claude 3 Opus and more.
   → 匹配到: DeepSeek-Coder-V2 (llm, score=1.00)
56. [2024-June] **Runway** introduces **Gen3 Alpha**, a new AI model for video generation.
   → 匹配到: Runway Gen 3 Alpha Turbo (media_image-to-video, score=0.90); Runway Gen 3 Alpha Turbo (media_image-to-video, score=0.90)
57. [2024-June] Anthropic releases the **Claude Sonnet 3.5** model, which presents better capabilities than other models with low resource usage. (*special*)
   → 匹配到: Claude 4 Sonnet (Non-reasoning) (llm, score=0.89)
59. [2024-June] Google announces **Gemma 2** open source language models with 9B and 27B parameter sizes. Also, the company opens the context window capabilities to developers for up to 2 million tokens.
   → 匹配到: Gemma 4 E2B (Reasoning) (llm, score=0.80)
60. [2024-July] OpenAI has released a miniaturized model called **GPT-4o mini** that presents high capabilities at a low cost
   → 匹配到: GPT-4o mini (llm, score=1.00)
66. [2024-July] Mistral AI has released a large language model **Mistral Large 2** in size 123B, which presents capabilities close to the closed SOTA models. (*special*)
   → 匹配到: Mistral Large 2 (Nov '24) (llm, score=1.00)
67. [2024-July] **Midjourney v6.1** is released
   → 匹配到: Midjourney v6.1 (media_text-to-image, score=1.00)
68. [2024-July] Google releases the **Gemma 2 2B** model as open source. The model demonstrates better capabilities than much larger models.
   → 匹配到: Gemma 4 E2B (Reasoning) (llm, score=0.82)
69. [2024-August] "Black Forest Labs" releases weights for an image creation model named **Flux**, which shows better performance than similar closedsource models.
   → 匹配到: FLUX.2 [klein] Base 9B (media_text-to-image, score=0.90)
70. [2024-August] OpenAI released a new version of its model, **GPT-4o 0806**, achieving 100% success in generating valid JSON output.
   → 匹配到: GPT-4o (Aug '24) (llm, score=0.90)
71. [2024-August] Google's image generation model, **Imagen 3**, has been released.
   → 匹配到: Imagen 3 (v002) (media_text-to-image, score=1.00)
72. [2024-August] xAI Corporation has launched the models **Grok 2** and **Grok 2 mini**, which demonstrate performance on par with leading SOTA models in the market.
   → 匹配到: Grok 2 (Dec '24) (llm, score=1.00); Grok 2 (Dec '24) (llm, score=0.90)
74. [2024-August] Google has introduced three new experimental AI models: **Gemini 1.5 Flash8B**, **Gemini 1.5 Pro** Enhanced, and **Gemini 1.5 Flash** Updated.
   → 匹配到: Gemini 1.5 Flash-8B (llm, score=1.00); Gemini 1.5 Pro (Sep '24) (llm, score=1.00); Gemini 1.5 Flash (Sep '24) (llm, score=1.00)
75. [2024-August] **Ideogram 2.0** has been released, offering image generation capabilities that surpass those of other leading models.
   → 匹配到: Ideogram v2 (media_text-to-image, score=0.90)
78. [2024-September] OPENAI has released two nextgeneration AI models to its subscribers: **o1 preview** and **o1 mini**. These models show a significant improvement in performance, particularly in tasks requiring reasoning, including coding, mathematics, GPQA, and more. (*special*)
   → 匹配到: o1-preview (llm, score=1.00); o1-mini (llm, score=1.00)
79. [2024-September] Chinese company Alibaba releases the **Qwen 2.5** model in various sizes, ranging from 0.5B to 72B. The models demonstrate capabilities comparable to much larger models.
   → 匹配到: Qwen2.5 Coder Instruct 32B (llm, score=0.90)
80. [2024-September] The video generation model **KLING 1.5** has been released.
   → 匹配到: Kling 1.5 Pro (media_text-to-video, score=0.90)
82. [2024-September] **Meta** releases **Llama 3.2** in sizes 1B, 3B, 11B and 90B, featuring image recognition capabilities for the first time.
   → 匹配到: MetaVoice v1 (media_text-to-speech, score=0.90); Llama 3.2 Instruct 90B (Vision) (llm, score=0.90)
83. [2024-September] **Google** has rolled out new model updates ready for deployment, **Gemini Pro 1.5 002** and **Gemini Flash 1.5 002**, showcasing significantly improved longcontext processing.
   → 匹配到: o1 (llm, score=0.90); Gemini 3.5 Flash (minimal) (llm, score=0.76)
84. [2024-September] **Kyutai** releases two opensource versions of its voicetovoice model, **Moshi**.
   → 匹配到: Mochi 1 (media_text-to-video, score=0.73)
86. [2024-September] Mistral AI launches a 22B model named **Mistral Small**.
   → 匹配到: Mistral Small (Sep '24) (llm, score=1.00)
87. [2024-October] **Flux 1.1 Pro** is released, showcasing advanced capabilities for image creation.
   → 匹配到: FLUX1.1 [pro] (media_text-to-image, score=1.00)
90. [2024-October] Adobe announces its video creation model, **Firefly Video**.
   → 匹配到: Firefly Image 4 (media_text-to-image, score=0.72)
93. [2024-October] Mistral AI introduces **Ministral**, a new model available in 3B and 8B parameter sizes.
   → 匹配到: Ministral 3 14B (llm, score=0.90)
96. [2024-October] **Stable Diffusion 3.5** is released in three sizes as open source.
   → 匹配到: Stable Diffusion 3.5 Large Turbo (media_text-to-image, score=0.90)
97. [2024-October] Anthropic launches **Claude 3.5 Sonnet New**, demonstrating significant advancements in specific areas over its previous version, and announces **Claude 3.5 Haiku**.
   → 匹配到: Claude 3.5 Sonnet (Oct '24) (llm, score=0.90); Claude 3.5 Haiku (llm, score=1.00)
99. [2024-October] The texttoimage model **Recraft v3** has been released to the public, ranking first in benchmarks compared to similar models.
   → 匹配到: Recraft V3 (media_text-to-image, score=1.00)
101. [2024-November] Alibaba released its new model, **QwQ 32B Preview**, which integrates reasoning capabilities before responding. The model competes with, and sometimes surpasses, OpenAI's o1-preview model.
   → 匹配到: QwQ 32B-Preview (llm, score=1.00)
102. [2024-November] Alibaba opensourced the model **Qwen2.5 Coder 32B**, which offers comparable capabilities to leading proprietary language models in the coding domain.
   → 匹配到: Qwen2.5 Coder Instruct 32B (llm, score=0.78)
103. [2024-November] DeepSeek unveiled its new AI model, **DeepSeek-R1-Lite-Preview**, which incorporates reasoning capabilities and delivers impressive performance on the AIME and MATH benchmarks, matching the level of OpenAI's o1-preview.
   → 匹配到: DeepSeek R1 (Jan '25) (llm, score=0.90)
104. [2024-November] **Suno** upgraded its AIpowered music generator to **v4**, introducing new features and performance improvements.
   → 匹配到: Recraft V4.1 Utility Pro (media_text-to-image, score=0.90)
105. [2024-November] Mistral AI launched the **Pixtral Large** model, a multimodal language model excelling in image recognition and advanced performance metrics, and an update to Mistral Large, 2411.
   → 匹配到: Pixtral Large (llm, score=1.00)
107. [2024-November] Anthropic launches **Claude 3.5 Haiku** and Visual PDF Analysis in Claude.
   → 匹配到: Claude 3.5 Haiku (llm, score=1.00)
108. [2024-December] Amazon introduced a new series of models called **NOVA**, designed for text, image, and video processing.
   → 匹配到: Nova 2.0 Pro Preview (Non-reasoning) (llm, score=0.90)
109. [2024-December] OpenAI released **SORA**, a video generation model, along with the full version of **o1** and **o1 Pro** for advanced subscribers. Additionally, the company launched a live video mode for **GPT 4o**. (*special*)
   → 匹配到: Sora (media_text-to-video, score=1.00); o1 (llm, score=1.00); o1-pro (llm, score=1.00); GPT-4o (Aug '24) (llm, score=1.00)
111. [2024-December] Google launched **Gemini 2.0 Flash** in beta. This model leads benchmarks and outperforms the previous version, **Gemini Pro 1.5**. Additionally, Google introduced live speech and video mode and announced built-in image generation capabilities within the model. (*special*)
   → 匹配到: Gemini 2.0 Flash (experimental) (llm, score=1.00); o1 (llm, score=0.90)
112. [2024-December] Google revealed **Gemini-2.0-Flash-Thinking**, a thinking model based on **Gemini 2.0 Flash**, which secured second place in the chatbot leaderboard. (*special*)
   → 匹配到: Gemini 2.0 Flash Thinking Experimental (Jan '25) (llm, score=0.90); Gemini 2.0 Flash (experimental) (llm, score=1.00)
113. [2024-December] Google introduced **Veo 2**, a beta version video generation model capable of producing 4K videos up to two minutes long. The model outperformed **SORA** in human evaluations. Additionally, Google updated **Imagen 3**, offering enhanced image quality and realism. (*special*)
   → 匹配到: Veo 2 (media_text-to-video, score=1.00); Sora (media_text-to-video, score=1.00); Imagen 3 (v002) (media_text-to-image, score=1.00)
115. [2024-December] Microsoft open-sourced the **Phi4** model, sized at 14B, showcasing impressive capabilities for its size.
   → 匹配到: Phi-4 (llm, score=1.00)
116. [2024-December] Meta released **Llama 3.3 70B**, a model offering performance comparable to **Llama 3.1 405B**.
   → 匹配到: Hermes 4 - Llama-3.1 405B (Non-reasoning) (llm, score=0.90)
117. [2024-December] Google launched a multi-modal open-source model called **PaliGemma 2**, integrated with existing **Gemma** models.
   → 匹配到: Gemma 3n E4B Instruct Preview (May '25) (llm, score=0.90)
118. [2024-December] Pika Labs released **2.0**, the latest version of its AI-powered video generator.
   → 匹配到: Gemini 2.0 Flash Thinking Experimental (Jan '25) (llm, score=0.90)
120. [2024-December] Deepseek open-sourced **Deepseek V3**, a model with 671B parameters that surpasses closed-source SOTA models across several benchmarks. (*special*)
   → 匹配到: DeepSeek V3 (Dec '24) (llm, score=1.00)
121. [2024-December] Alibaba unveiled **QVQ-72B-Preview**, a cutting-edge thinking model capable of analyzing images, featuring SOTA-level performance. (*special*)
   → 匹配到: QwQ 32B-Preview (llm, score=0.85)
122. [2024-December] OpenAI announced **o3**, a groundbreaking AI model achieving 87.5% in the **ARC-AGI** benchmark, 25.2% in the **Frontier Math Benchmark** (compared to under 2% in previous models), and 87.7% in Ph.D.-level science questions. A cost-effective version, **o3 Mini**, is expected in January 2025, with performance similar to **o1**, alongside improved speed and efficiency. (*special*)
   → 匹配到: o3 (llm, score=1.00); o3-mini (high) (llm, score=1.00); o1 (llm, score=1.00)
123. [2024-December] The video generation model **Kling 1.6** was released, offering significant performance enhancements.
   → 匹配到: Kling 1.6 Standard (media_text-to-video, score=0.90)
126. [2025-January] DeepSeek open-sourced the reasoning models **R1** and **R1-Zero**, which demonstrated capabilities similar to **o1** across various domains at a fraction of the cost. Additionally, smaller distilled models were released, achieving high performance relative to their size. (*special*)
   → 匹配到: NVIDIA Nemotron 3 Super 120B A12B (Reasoning) (llm, score=0.90); o1 (llm, score=1.00)
128. [2025-January] DeepSeek open-sourced a fully multimodal model, **Janus Pro 7B**, which supports both text and image generation.
   → 匹配到: Janus Pro (media_text-to-image, score=0.90)
129. [2025-January] Alibaba unveiled **Qwen2.5-Max**, a large language model that surpasses several leading models, including **DeepSeek-V3**, **GPT-4o**, and **Claude 3.5**. Additionally, the **Qwen2.5-1M** series was open-sourced, capable of processing up to one million tokens, along with the **Qwen2.5-VL** vision model series in three different sizes.
   → 匹配到: Qwen2.5 Max (llm, score=1.00); DeepSeek V3 (Dec '24) (llm, score=1.00); GPT-4o (Aug '24) (llm, score=1.00); Claude 3.5 Sonnet (Oct '24) (llm, score=0.90); Qwen2.5 Max (llm, score=0.82)
130. [2025-January] OpenAI made the **o3 mini** reasoning model available to all users, including the free tier, featuring three reasoning levels. The model matches or comes close to o1 in several benchmarks, significantly surpasses it in coding, and remains significantly faster and more cost-efficient. (*special*)
   → 匹配到: o3-mini (high) (llm, score=1.00)
131. [2025-February] xAI launches **Grok 3**, **Grok 3 Reasoning** and **Grok 3 mini**, next-generation AI models trained with 10 times the computing power of Grok 2, significantly improving SOTA performance. They include "Think" and "Big Brain" modes for advanced reasoning, as well as **DeepSearch** for autonomous web searches. (*special*)
   → 匹配到: Grok 3 (llm, score=1.00); Grok 3 Reasoning Beta (llm, score=0.90); Grok 3 mini Reasoning (high) (llm, score=0.90)
132. [2025-February] Anthropic introduces **Claude 3.7** and **Claude 3.7 Thinking**, a new model with enhanced coding performance, support for "Extended Thinking" mode, and the ability to analyze reasoning processes. (*special*)
   → 匹配到: Claude 3.7 Sonnet (Reasoning) (llm, score=0.90)
134. [2025-February] Google releases **Gemini 2.0 Flash**, **Gemini 2.0 Flash-Lite Preview**, and **Gemini 2.0 Pro Experimental**.
   → 匹配到: Gemini 2.0 Flash (experimental) (llm, score=1.00); Gemini 2.0 Flash-Lite (Preview) (llm, score=0.90); Gemini 2.0 Pro Experimental (Feb '25) (llm, score=1.00)
136. [2025-February] Microsoft presents **Phi4-mini** and **Phi4 Multimodal**, lightweight models (3.8B and 5.6B) with enhanced performance, including support for multimodal inputs.
   → 匹配到: Phi-4 Mini Instruct (llm, score=0.90); Phi-4 Multimodal Instruct (llm, score=0.90)
137. [2025-February] OpenAI releases **GPT-4.5**, featuring advanced pattern recognition and significantly reduced hallucinations, improving accuracy and reliability. (*special*)
   → 匹配到: GPT-4.5 (Preview) (llm, score=1.00)
138. [2025-March] Google introduced **Gemini 2.5 Pro**, an experimental "Thinking model" with advanced reasoning and planning capabilities, a 1 million token context window, achieving top rankings across several key benchmarks. (*special*)
   → 匹配到: Gemini 2.5 Pro (llm, score=1.00)
140. [2025-March] OpenAI integrated **GPT-4o Image Generation**, enabling high-fidelity text-to-image creation, text rendering within images, and more. (*special*)
   → 匹配到: GPT-4o (Aug '24) (llm, score=0.90)
141. [2025-March] Google expanded experimental image generation and editing within **Gemini 2.0 Flash Experimental**, enabling image generation and editing, including enhanced text creation capabilities. (*special*)
   → 匹配到: Gemini 2.0 Flash Experimental (media_text-to-image, score=1.00)
142. [2025-March] Alibaba released **QwQ-32B**, an open-source 32B parameter reasoning model with exceptional math and coding performance, rivaling much larger models.
   → 匹配到: QwQ 32B (llm, score=1.00)
143. [2025-March] Alibaba released the **Qwen2.5-VL 32B**, open-source vision-language model with robust capabilities in visual analysis, text-in-image understanding, and visual agent tasks.
   → 匹配到: Qwen3 VL 32B (Reasoning) (llm, score=0.86)
144. [2025-March] DeepSeek updated its open-source MoE model with **DeepSeek-V3-0324**, featuring enhanced reasoning, coding, and math capabilities, positioning it as a top-tier base model.
   → 匹配到: DeepSeek V3 0324 (llm, score=1.00)
146. [2025-April] Meta releases **Llama 4** in three sizes with a context window of 10 million tokens and medium performance.
   → 匹配到: Llama 4 Maverick (llm, score=0.90)
147. [2025-April] Google launches **Gemini 2.5 Flash**, with a dynamic reasoning mode that allows tuning the reasoning level or disabling it as needed.
   → 匹配到: Gemini 2.5 Flash (Non-reasoning) (llm, score=1.00)
149. [2025-April] OpenAI releases **GPT-4.1** in three sizes, with a context window of 1 million tokens.
   → 匹配到: GPT-4.1 (llm, score=1.00)
150. [2025-April] OpenAI introduces **o3 full** and **o4 mini**, highly advanced models for reasoning, math, and coding.
   → 匹配到: o3 (llm, score=0.90); o4-mini (high) (llm, score=1.00)
151. [2025-April] Midjourney launches **v7**, with higher image quality and more precise control over style.
   → 匹配到: Midjourney v7 Alpha (media_text-to-image, score=0.90)
152. [2025-April] A series of video model updates - **Veo 2.0** (Google), **Runway Gen-4**, **Vidu Q1**, and **Kling 2.0** – a leap forward in high-quality video generation, with improvements in response times, realism, and style.
   → 匹配到: Veo 2 (media_text-to-video, score=0.90); Runway Gen 4 (media_image-to-video, score=1.00); Vidu Q1 (media_text-to-video, score=1.00); Kling 2.0 (media_text-to-video, score=1.00)
153. [2025-April] Alibaba releases **Qwen 3** as open source, in various sizes, with very impressive capabilities for their size. (*special*)
   → 匹配到: Qwen3 Coder 480B A35B Instruct (llm, score=0.90)
154. [2025-May] Microsoft launches the **Phi-4 reasoning** series as open source, small yet high-quality models that incorporate reasoning.
   → 匹配到: Phi-4 (llm, score=0.90)
156. [2025-May] Anthropic releases **Claude 4 Opus** and **Claude Sonnet 4**: Opus 4 offers a Hybrid "Deep Thought" mode with enhanced long-term context and 7-hour autonomous operation; Sonnet 4 focuses on improved math and coding performance. (*special*)
   → 匹配到: Claude 4 Opus (Reasoning) (llm, score=1.00); Claude Sonnet 4.6 (Adaptive Reasoning, Max Effort) (llm, score=0.90)
157. [2025-May] Google releases **Veo 3**, a video generation model for synchronized 4K video with natural audio integration, and **Imagen 4**, an advanced image model with deeper contextual understanding and artistic style support. (*special*)
   → 匹配到: Veo 3 (media_text-to-video, score=1.00); Imagen 4 Ultra Preview 0606 (media_text-to-image, score=0.90)
158. [2025-May] OpenAI releases **Codex**, an autonomous code agent in ChatGPT, powered by the o3 model, for writing code, debugging, testing, and creating GitHub Pull Requests.
   → 匹配到: GPT-5.1 Codex mini (high) (llm, score=0.90)
160. [2025-May] Google releases **Gemini 2.5 Pro** (Deep Think Mode) and **Gemini 2.5 Flash**, featuring improved reasoning, native audio support, extended context, and high-frequency task handling.
   → 匹配到: Gemini 2.5 Pro (llm, score=1.00); Gemini 2.5 Flash (Non-reasoning) (llm, score=1.00)
161. [2025-May] OpenAI updates **Operator** to use the **o3** model, achieving SOTA on OSWorld benchmarks and enhancing autonomous browser capabilities.
   → 匹配到: o3 (llm, score=1.00)
162. [2025-May] DeepSeek open-sources **R1-0528**, a code-and-inference model with near–o4-mini performance and moderate computational needs.
   → 匹配到: DeepSeek R1 0528 Qwen3 8B (llm, score=0.90)
165. [2025-May] Google introduces **Gemma 3n**, an open-source generative AI model for on-device use, with an efficient architecture and multi-modal (audio, text, visual) capabilities.
   → 匹配到: Gemma 3n E4B Instruct Preview (May '25) (llm, score=0.90)
166. [2025-June] Google releases **Gemini 2.5 Pro** (final production-ready version), which leads benchmarks across the board.
   → 匹配到: Gemini 2.5 Pro (llm, score=1.00)
167. [2025-June] ElevenLabs rolls out **Eleven v3 (alpha)** TTS with fine grained emotion control and support for 70+ languages.
   → 匹配到: Eleven v3 (media_text-to-speech, score=1.00)
168. [2025-June] OpenAI debuts **o3 pro**, an enhanced reasoning model offering extended context and real-time tool integrations.
   → 匹配到: o3-pro (llm, score=1.00)
169. [2025-July] xAI releases **Grok 4**, achieving a new SOTA of 15.9% on ARC-AGI v2 and 25.4% on Humanity’s Last Exam. (*special*)
   → 匹配到: Grok 4 (llm, score=1.00)
172. [2025-July] Google introduces **Gemini Deep Think**, which also earns an IMO 2025 gold by solving five of six problems with parallel reasoning. (*special*)
   → 匹配到: Gemini 3 Deep Think (llm, score=0.97)
173. [2025-July] Alibaba open-sources two variants, **Qwen3-235B-A22B-Instruct-2507** (instruction-tuned) and **Qwen3-Coder**, for general LLM use and automated code generation.
   → 匹配到: Qwen3 235B A22B (Non-reasoning) (llm, score=0.90); Qwen3 Coder 480B A35B Instruct (llm, score=0.90)
174. [2025-July] Moonshot AI debuts **Kimi K2**, a Chinese LLM praised for its open-research focus and robust performance.
   → 匹配到: Kimi K2 (llm, score=1.00)
175. [2025-July] Chinese startup Zhipu open-sources **GLM-4.5**, a 130 B-parameter model tailored for intelligent-agent applications.
   → 匹配到: GLM-4.5 (Reasoning) (llm, score=1.00)
176. [2025-August] Google introduced **Gemini 2.5 Deep Think**, a special "extended thinking" mode for solving complex problems and exploring alternatives. (*special*)
   → 匹配到: Gemini 3 Deep Think (llm, score=0.91)
177. [2025-August] Anthropic released **Claude Opus 4.1**, an upgrade focused on improving agentic capabilities and real-world coding.
   → 匹配到: Claude Opus 4.8 (Adaptive Reasoning, Max Effort) (llm, score=0.92)
179. [2025-August] OpenAI released **gpt-oss-120b** and **gpt-oss-20b**, a family of open-source models with high reasoning capabilities, optimized to run on accessible hardware.
   → 匹配到: gpt-oss-120b (high) (llm, score=1.00); gpt-oss-20B (high) (llm, score=1.00)
180. [2025-August] OpenAI launched **GPT-5**, the company's next-generation model, with significant improvements in coding and a dynamic "thinking" mode to reduce hallucinations.
   → 匹配到: GPT-5 (high) (llm, score=1.00)
181. [2025-August] DeepSeek released **DeepSeek V3.1**, a hybrid model combining fast and slow "thinking" modes to improve performance in agentic tasks and tool use.
   → 匹配到: DeepSeek V3.1 (Non-reasoning) (llm, score=1.00)
182. [2025-August] Google launched a preview of **Gemini 2.5 Flash Image** (showcased as *nano-banana*), an advanced model for precise image editing, merging, and maintaining character consistency. (*special*)
   → 匹配到: Gemini 2.5 Flash (Non-reasoning) (llm, score=0.90)
183. [2025-September] ByteDance released **Seedream 4.0**, a next-generation image model unifying high-quality text-to-image generation and natural-language image editing.
   → 匹配到: Seedream 4.0 (media_text-to-image, score=1.00)
184. [2025-September] An advanced Gemini variant, reported as **Gemini 2.5 - Deep Think**, achieved gold-medal-level performance at the ICPC World Finals programming contest. (*special*)
   → 匹配到: Gemini 3 Deep Think (llm, score=0.91)
187. [2025-September] Alibaba unveiled **Qwen-3-Max**, its flagship model with over a trillion parameters, focusing on long context and agent capabilities.
   → 匹配到: Qwen3 Max (llm, score=1.00)
188. [2025-September] **Wan 2.5** was released, a generative video model focused on multi-shot consistency and character animation.
   → 匹配到: Wan 2.5 Preview (media_text-to-image, score=0.90)
189. [2025-September] Anthropic announced **Claude Sonnet 4.5**, a model optimized for coding, agent construction, and improved reasoning.
   → 匹配到: Claude Sonnet 4.6 (Adaptive Reasoning, Max Effort) (llm, score=0.93)
190. [2025-September] OpenAI released **Sora 2**, a flagship video and audio generation model with improved physical modeling and synchronized sound.
   → 匹配到: Sora 2 (December) (media_text-to-video, score=1.00)
191. [2025-September] DeepSeek released **DeepSeek-V3.2-Exp**
   → 匹配到: DeepSeek V3.2 Exp (Non-reasoning) (llm, score=1.00)
195. [2025-October] Anthropic released **Claude 4.5 Haiku**, a fast, cost-effective model for high-volume, low-latency applications.
   → 匹配到: Claude 4.5 Haiku (Non-reasoning) (llm, score=1.00)
198. [2025-November] Moonshot AI released **Kimi K2 Thinking**, an open model setting new records in reasoning benchmarks.
   → 匹配到: Kimi K2 Thinking (llm, score=1.00)
199. [2025-November] OpenAI launched **GPT 5.1**, featuring specialized "Thinking" and "Instant" modes with expanded context.
   → 匹配到: GPT-5.1 (high) (llm, score=1.00)
200. [2025-November] xAI released **Grok 4.1**, combining high EQ with strong logic to top the LM Arena leaderboard.
   → 匹配到: Grok 4.1 Fast (Reasoning) (llm, score=0.90)
201. [2025-November] Google debuted **Gemini 3.0**, a flagship "thinking" model that claimed the top spot on major benchmarks.
   → 匹配到: Gemini 1.0 Pro (llm, score=0.74)
202. [2025-November] OpenAI introduced **GPT 5.1 Codex Max**, an agentic model built specifically for long-term coding tasks.
   → 匹配到: GPT-5.1 Codex (high) (llm, score=0.90)
203. [2025-November] Google released **Nano Banana Pro**, a superior image generation and editing model based on Gemini 3. (*special*)
   → 匹配到: Nano Banana Pro (Gemini 3 Pro Image) (media_text-to-image, score=1.00)
204. [2025-November] Anthropic announced **Claude Opus 4.5**, delivering elite coding and agentic performance at a significantly reduced price. (*special*)
   → 匹配到: Claude Opus 4.5 (Non-reasoning) (llm, score=1.00)
205. [2025-November] Black Forest Labs launched **FLUX 2**, a high-performance open-weight image generation model.
   → 匹配到: FLUX.2 [klein] Base 9B (media_text-to-image, score=0.90)
206. [2025-November] DeepSeek released **DeepSeekMath-V2** as open source, achieving gold-medal performance in math olympiads. (*special*)
   → 匹配到: DeepSeek V3.2 (Non-reasoning) (llm, score=0.80)
209. [2025-December] Mistral AI launches the **Mistral 3** family (Large & Ministral) alongside **Mistral OCR 3** and the **Devstral 2** coding series, reinforcing its open-weight leadership with advanced agentic workflows and Vibe CLI integration.
   → 匹配到: Ministral 3 8B (llm, score=0.80); Mistral Large 3 (llm, score=0.75); Devstral 2 (llm, score=1.00)
210. [2025-December] OpenAI releases **GPT-5.2**, featuring the autonomous **Codex** agent for complex engineering tasks, and **GPT-Image 1.5**, which claims the #1 spot on vision benchmarks, outperforming Nano Banana Pro.
   → 匹配到: GPT-5.2 (xhigh) (llm, score=1.00); GPT-5.1 Codex mini (high) (llm, score=0.90); GPT Image 1.5 (high) (media_text-to-image, score=1.00)
211. [2025-December] Google introduces **Gemini 3.0 Flash**, setting a new standard for price-performance, and deploys **Deep Research**, an autonomous agent capable of multi-step synthesis, alongside **Gemini 2.5 Flash Audio**. (*special*)
   → 匹配到: Gemini 3.5 Flash (minimal) (llm, score=0.92); Gemini 2.5 Flash (Non-reasoning) (llm, score=0.90)
212. [2025-December] Amazon unveils the **Nova 2** series, highlighted by **Nova 2 Sonic**, a native speech-to-speech model delivering ultra-low latency and natural conversation flow.
   → 匹配到: Nova 2.0 Pro Preview (Non-reasoning) (llm, score=0.90); Nova 2.0 Omni (medium) (llm, score=0.80)
213. [2025-December] Runway releases **Gen-4.5**, a video generation model that rises to the top of industry leaderboards for motion consistency and prompt adherence.
   → 匹配到: Runway Gen-4.5 (media_text-to-video, score=0.90)
215. [2025-December] Zhipu AI releases **GLM-4.7**, an open-weights model that reaches the top of global coding and reasoning leaderboards.
   → 匹配到: GLM-4.7 (Reasoning) (llm, score=1.00)
216. [2025-December] Alibaba open-sources **Z-Image-Turbo**, a highly efficient 6B model, and releases **Qwen-Image-2512**, which specializes in high-fidelity typography and complex visual compositions.
   → 匹配到: Z-Image Turbo (media_text-to-image, score=1.00); Qwen Image (media_text-to-image, score=0.90)
217. [2025-December] MiniMax releases **MiniMax-M2.1**, a 200k-context MoE model that rises to the top of web development and coding leaderboards, establishing itself as a leading open model for developers.
   → 匹配到: MiniMax-M2.1 (llm, score=1.00)
221. [2026-January] Moonshot AI releases **Kimi K2.5**, an upgraded model focused on stronger reasoning, coding, and agentic workflows.
   → 匹配到: Kimi K2.5 (Reasoning) (llm, score=1.00)
222. [2026-January] xAI launches **Imagine Video**, a video generation model in Grok that quickly rises to the top of public leaderboards.
   → 匹配到: grok-imagine-video-1.5-preview (media_image-to-video, score=0.90)
224. [2026-February] Anthropic releases **Claude Opus 4.6** and **Claude Sonnet 4.6**, adding a 1M-token context window in beta and making the updated Sonnet model the default across Claude and Cowork. (*special*)
   → 匹配到: Claude Opus 4.6 (Adaptive Reasoning, Max Effort) (llm, score=1.00); Claude Sonnet 4.6 (Adaptive Reasoning, Max Effort) (llm, score=1.00)
225. [2026-February] OpenAI introduces **GPT-5.3-Codex** and **GPT-5.3-Codex-Spark**, upgraded coding models for long-running and real-time development work.
   → 匹配到: GPT-5.3 Codex (xhigh) (llm, score=1.00); GPT-5.3 Codex (xhigh) (llm, score=0.90)
226. [2026-February] Google launches **Gemini 3 Deep Think**, a specialized reasoning mode that reaches 84.6% on **ARC-AGI-2**. (*special*)
   → 匹配到: Gemini 3 Deep Think (llm, score=1.00)
227. [2026-February] ByteDance releases **Seedance 2.0**, an upgraded video generation model with stronger motion quality and multimodal control.
   → 匹配到: Dreamina Seedance 2.0 720p (media_text-to-video, score=0.90)
228. [2026-February] Zhipu AI launches **GLM-5**, a new flagship model built for stronger reasoning, tool use, and agentic tasks.
   → 匹配到: GLM-5 (Reasoning) (llm, score=1.00)
229. [2026-February] xAI releases **Grok 4.20**, an updated flagship model with improved reasoning and chat performance.
   → 匹配到: Grok 4.20 0309 v2 (Reasoning) (llm, score=0.90)
230. [2026-February] OpenAI adds **gpt-audio-1.5**, an upgraded speech model for audio input and spoken responses.
   → 匹配到: o1 (llm, score=0.90)
231. [2026-February] Google launches **Nano Banana 2**, a Gemini 3.1 Flash-based image model that matches Nano Banana Pro quality at lower latency.
   → 匹配到: Nano Banana 2 (Gemini 3.1 Flash Image Preview) (media_text-to-image, score=1.00)
232. [2026-March] OpenAI releases **GPT-5.3 Instant**, a faster general-purpose GPT-5.3 variant for latency-sensitive tasks.
   → 匹配到: GPT-5 (high) (llm, score=0.90)
233. [2026-March] OpenAI launches **GPT-5.4** alongside **GPT-5.4 mini** and **GPT-5.4 nano**, expanding the GPT-5.4 family across flagship and lightweight tiers.
   → 匹配到: GPT-5.4 (Non-reasoning) (llm, score=1.00); GPT-5.4 mini (medium) (llm, score=1.00); GPT-5.4 nano (xhigh) (llm, score=1.00)
234. [2026-March] Mistral AI releases **Mistral Small 4**, a multimodal open model that unifies reasoning, coding, and vision capabilities.
   → 匹配到: Mistral Small 4 (Reasoning) (llm, score=1.00)
