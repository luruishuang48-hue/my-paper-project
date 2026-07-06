# 事件集匹配流程审计报告（2026-07-02）

对 `build_dataset.py → resolve_manual_review.py → resolve_version_mismatches.py → build_final_sample.py`
流水线及其产出（266 个模型实体、190 条 match、76 条 unmatch、144 个事件）做的全面复审。
审计方法：(1) 对全部 unmatched 实体在 AA 全库（1191 条）做独立复搜（词集合+版本号相等，处理
创建方前缀/推理后缀/词序）；(2) 对全部 matched 实体检查变体词不对称、快照日期偏差、
同事件/跨事件重复映射；(3) 对无版本号实体逐条人工核对。

## 一、假 unmatch：正确的 AA 记录其实存在，却被终审排除（13 条）

上一轮终审只看了 top-1 候选，而算法的字符串包含逻辑无法区分版本边界（"claude 3" 是
"claude 3.5" 的前缀，两者都能拿满分），同分并列时按 AA 列表顺序随机取胜，正确记录被
压到 top-1 之下。终审工作流只提供"接受 top-1 / unmatch"两个选项，没有"改指向正确记录"。

| # | 实体（事件月） | 被错排到 top-1 的 | AA 里实际存在的正确记录 | AA release_date |
|---|---|---|---|---|
| 1 | Claude 3 (2024-03) | Claude 3.5 Sonnet | Claude 3 Opus / Sonnet / Haiku | 2024-03-04 同月 |
| 2 | LLaMA 3 (2024-04) | Llama 3.3 70B | Llama 3 Instruct 70B / 8B | 2024-04-18 同月 |
| 3 | Stable Diffusion 3 (2024-02 宣布) | SD 3.5 Large | Stable Diffusion 3 Large | 2024-02 同月 |
| 4 | Stable Diffusion 3 (2024-06 发布) | SD 3.5 Large | Stable Diffusion 3 Medium（事件文本明说 medium 2B） | 2024-06 同月 |
| 5 | Stable Diffusion 3.5 (2024-10) | SD 1.5 | SD 3.5 Large / Large Turbo / Medium | 2024-10 同月 |
| 6 | Midjourney v6.1 (2024-07) | Midjourney v6 | Midjourney v6.1 | 2024-07 同月 |
| 7 | GPT-4.5 (2025-02) | GPT-5.4 | GPT-4.5 (Preview) | 2025-02-27 同月 |
| 8 | GPT-5 (2025-08) | GPT-5.5 | GPT-5 (high/medium/low) | 2025-08-07 同月 |
| 9 | Claude Sonnet 4.5 (2025-09) | Claude Sonnet 4.6 | Claude 4.5 Sonnet (Reasoning/Non-r) | 2025-09-29 同月 |
| 10 | Suno v5 (2025-09) | Suno V5.5 | Suno V5 | — |
| 11 | Qwen 3 (2025-04) | Qwen3.5 Omni | Qwen3 235B A22B (Reasoning) 等全家族 | 2025-04-28 同月 |
| 12 | Gemini 3.0 Flash (2025-12) | Gemini 3.5 Flash | Gemini 3 Flash Preview（3.0≡3，同 Claude 2≡2.0 规则） | 2025-12-17 同月 |
| 13 | Nova 2 (2025-12)〔决策项〕 | Nova 2.0 Lite | Nova 2.0 Omni / Pro Preview（家族） | 2025-11-26/27 |

其中 GPT-5、Claude Sonnet 4.5、Claude 3、LLaMA 3、Qwen 3 都是市场影响极大的头部事件，
漏掉它们对事件研究是重大样本缺陷。

注意：Midjourney v1 的复搜命中"Midjourney V1 (image-to-video, rel 2025-06)"是假线索——
那是 Midjourney 2025 年 6 月的**视频**模型 V1，不是 2022 年的图像模型 v1，维持 unmatch 正确。

## 二、假 match：仍留在样本里的错配（约 25 条）

根因：版本号终审只覆盖了"两边都提取得到数字"的配对，**没有版本号的实体全部漏检**。

### 2a. 明确错配，应改 unmatch（AA 无对应记录）

| 实体（事件月） | 当前错配到 | 依据 |
|---|---|---|
| LLaMA (2023-02, 初代) | Llama 3.3 Instruct 70B | AA 无 LLaMA 1 |
| Firefly (2023-04, 初代) | Firefly Image 5 Preview | AA 只有 Image 3/4/5 |
| Veo (2024-05, 初代) | Veo 3 Preview | AA 无 Veo 1 |
| Codestral (2024-05) | Devstral 2 | AA 无 Codestral |
| Mistral NeMo (2024-07) | Mistral Medium | AA 无 NeMo |
| Firefly Video (2024-10) | Firefly Image 4 | AA 无 Firefly 视频模型 |
| Ministral (2024-10, les Ministraux 3B/8B) | Ministral 3 3B (2025-12 家族) | AA 无 2024-10 的 Ministral |
| Janus AI (2024-10, 初代) | Janus Pro (2025-01) | AA 只有 Pro |
| PaliGemma 2 (2024-12) | PALM-2 | 完全不同的模型 |
| Gemma (2024-12, "integrated with existing Gemma models") | Gemma 4 26B | 是提及不是发布 |
| QVQ-72B-Preview (2024-12) | QwQ 32B-Preview | QVQ 视觉推理≠QwQ，AA 未收录 QVQ |
| Grok 2 mini (2024-08) | Grok 2 | 尺寸变体，AA 未单独收录（与 Phi-3 Small 判例一致） |
| QwQ-Max (2025-02) | Qwen3 Max (2025-09) | QwQ-Max 基于 Qwen2.5-Max，AA 未收录 |
| Gemini Deep Think (2025-07) | Gemini 3 Deep Think (2026-02) | 7 月事件是 2.5 Deep Think（与已 unmatch 的"Gemini 2.5 Deep Think"同判） |
| Phi-4 reasoning (2025-05) | Phi-4 (2024-12 基础版) | Phi-4-reasoning 是独立模型，AA 未收录 |
| GPT 5.1 Codex Max (2025-11) | GPT-5.1 Codex | Max 是独立模型，AA 未收录 |
| GPT-5.3-Codex-Spark (2026-02) | GPT-5.3 Codex | Spark 是独立变体，AA 未收录 |
| Runway (2024-06, 公司名) | Runway Gen-4.5 | 实体分类错误：公司名被当模型（该事件的 Gen3 Alpha 已单独正确匹配） |
| Mistral 3 (2025-12) | Ministral 3 3B | **上轮判定表里已写 unmatch，但漏写进脚本**（转录遗漏）；另 AA 有 Mistral Large 3，可作家族代表，见决策项 |

### 2b. 错记录，应改指向 AA 里的正确条目

| 实体（事件月） | 当前错配到 | 应改为 | 正确记录 release_date |
|---|---|---|---|
| Gemini Pro (2023-12) | Gemini 3 Pro (High) | Gemini 1.0 Pro | 2023-12-06 同月 |
| Gemini Pro (2024-02) | Gemini 3 Pro (High) | Gemini 1.0 Pro | 2023-12-06 |
| Sora (2024-02 宣布) | Sora 2 Pro | Sora | 2024-12 |
| SORA (2024-12 发布) | Sora 2 Pro | Sora | 2024-12 同月 |
| Flux (2024-08) | FLUX.2 [max] (2025-11) | FLUX.1 [pro]（家族旗舰） | 2024-08 同月 |
| Qwen 2.5 (2024-09 开源家族) | Qwen2.5 Max (2025-01 闭源) | Qwen2.5 Instruct 72B（旗舰） | 2024-09-19 同月 |
| Mistral Small (2024-09) | Mistral Small 3 (2025-01) | Mistral Small (Sep '24) | 2024-09-17 同月 |
| Video Model 1.5 (Pika, 2024-10) | HunyuanVideo-1.5（腾讯！） | Pika 1.5 | 2024-10 同月 |
| Gemini 1.5 Flash8B (2024-08) | Gemini 1.5 Flash | Gemini 1.5 Flash-8B | 2024-10-03 |
| Gemini-2.0-Flash-Thinking (2024-12) | Gemini 2.0 Flash (experimental) | Gemini 2.0 Flash Thinking Experimental (Dec '24) | 2024-12-19 同月 |
| gpt-oss-20b (2025-08) | gpt-oss-120b | gpt-oss-20B (high/low) | 2025-08-05 同月 |
| Sora 2 (2025-09) | Sora 2 Pro | Sora 2 (October) | 2025-09 |
| Qwen3-Coder (2025-07) | Qwen3 Coder Next (2026-02) | Qwen3 Coder 480B A35B Instruct | 2025-07-22 同月 |
| Claude 3.7 (2025-02, 非思考版) | Claude 3.7 Sonnet (Reasoning) | Claude 3.7 Sonnet (Non-reasoning)（Thinking 实体已占 Reasoning） | 2025-02-24 |
| LLaMA 2 (2023-07) | Llama 2 Chat 7B | Llama 2 Chat 70B（旗舰，需家族规则） | 2023-07-18 |

### 2c. 边界情况，需要你拍板（决策项）

| 实体 | 现状 | 问题 |
|---|---|---|
| DeepSeek-R1-Lite-Preview (2024-11) | 配到 DeepSeek R1 (Jan '25) | 与严格变体规则矛盾（上轮我判"可接受"，但按 Phi-3 Small 判例应 unmatch）；且造成 R1 跨事件重复 |
| R1-Zero (2025-01) | 配到 DeepSeek R1 | R1-Zero 是独立模型，AA 未收录；但与 R1 同日同公告发布 |
| GPT-4o Image Generation (2025-03) | 配到 GPT-4o (Aug '24) | 可改 GPT Image 1 (rel 2025-04)，或视为功能发布剔除 |
| Gemini 2.5 Flash Audio (2025-12) | 配到 Gemini 2.5 Flash | AA 有 Gemini 2.5 Flash Native Audio Dialog（speech-to-speech），或视为功能部署剔除 |
| Grok 4.1 (2025-11) | 配到 Grok 4.1 Fast (Reasoning) | AA 只有 Fast 变体，无基础版 |
| KLING 1.5 (2024-09) | 配到 Kling 1.5 Pro | AA 只有 Pro 档（同版本同月，档位差异） |
| Qwen-Image-2512 (2025-12) | 配到 Qwen Image Max 2512 | AA 只有 Max 档（旧 60 样本也这么配的） |
| Imagen 4 / Udio v1.5 / Wan 2.5 等 | 配到 Ultra Preview / Allegro / Preview 变体 | 同版本同期、AA 仅收录该变体，目前按 match 保留 |

## 三、快照选择错误（同名多日期快照，未按事件月选取）

AA 对同一模型有多个日期快照（能力指标不同！），当前算法随机选中一个，直接影响主回归的
Intelligence Index 取值：

| 实体（事件月） | 当前快照 | 应选快照 |
|---|---|---|
| GPT-4o model (2024-05) | Aug '24 | May '24 |
| Gemini Flash 1.5 model (2024-05) | Sep '24 | May '24 |
| Gemini Pro 1.5 (2024-02) | Sep '24 | May '24（最早） |
| Claude Sonnet 3.5 (2024-06) | Oct '24 | June '24 |
| Mistral Large 2 (2024-07) | Nov '24 | Jul '24 |
| GPT 4o (2024-12) | Aug '24 | Nov '24 |

需要一条明文规则：多快照时选与事件月最近（或不晚于事件月的最近）快照。

## 四、跨事件重复（需要去重/事件定义政策）

同一 AA 模型出现在多个事件中——announce vs release vs 后续提及：

- Claude 3.5 Haiku：10 月宣布 + 11 月上线
- o3：12 月宣布 + 4 月发布 + 5 月"Operator 改用 o3"（第三处是产品更新提及，应剔除）
- o3-mini：12 月预告（"expected in January"）+ 1 月发布
- Gemini 2.5 Pro：3 月 experimental + 5 月提及 + 6 月 GA
- Sora：2 月宣布 + 12 月发布
- Gemini 2.0 Flash：AIT-2024-12-004（发布）与 AIT-2024-12-005（"based on Gemini 2.0 Flash"提及）重复

## 五、对比/提及排除规则的遗漏

`is_comparison_reference` 目前只覆盖 outperform/similar to/surpasses including 等模式，漏掉：

- "based on X"（AIT-2024-12-005 的 Gemini 2.0 Flash；QwQ-Max 事件的 Qwen2.5-Max）
- "updates Operator to use the X model"（产品更新提及，AIT-2025-05-008 的 o3）
- "integrated with existing X models"（AIT-2024-12-010 的 Gemma）
- "moving it to the upgraded X"（Bard 升级类事件——不过这类算真实部署，需定性）

## 六、流程与代码层面的问题

1. **终审字典以 entity_name 为 key**：同名实体跨事件被强制同判。Stable Diffusion 3 的两个
   事件（2 月宣布、6 月发布）本应分别对应 SD 3 Large 和 SD 3 Medium，却被一刀切 unmatch。
   应改为 entity_id 级别判定。
2. **终审判定硬编码在脚本字典里**：我自己就把聊天里判好的"Mistral 3 → unmatch"漏写进了
   脚本。判定应放在独立 CSV 决策表中由脚本读入，脚本校验覆盖完整性。
3. **终审缺"改指向"选项**：只有接受 top-1 / unmatch 两种，造成第一节 13 条假 unmatch。
   决策表应支持第三列"指定正确 aa_record_key"。
4. **版本号终审的覆盖盲区**：只检查了"两边都有数字"的配对，无版本号实体（LLaMA、Firefly、
   Gemini Pro、Sora、Veo、Flux、Codestral、NeMo、QVQ……）全部漏检，是第二节大部分假 match
   的直接原因。
5. **打分算法三个系统性缺陷**（一切的根源）：
   - 字符串包含逻辑无视版本边界："claude 3" ⊂ "claude 3 5" 也算 containment 高分；
   - 同分并列按 AA 行序取胜（stable sort），排序结果实质随机；
   - 同名多快照/多档位（date paren、Reasoning、high/low effort）之间无选择规则。
6. **entity_resolution_log.csv 用追加模式**：单独重跑 resolve_version_mismatches 会产生
   重复日志行（有 failsafe 报错兜底，但日志本身会脏）。
7. **needs_review 语义**：unmatch 之后不再进入复审队列，假 unmatch 因此不可见——本次
   13 条假 unmatch 全部是这样漏掉的。复审产物应包含"被改判 unmatch 的记录+其全部
   同分候选"，而不只是 top-1。

## 七、量化影响

- 假 unmatch：约 13 条实体（含 GPT-5、Claude Sonnet 4.5、Claude 3、LLaMA 3、Qwen 3 等
  头部事件）→ 当前 144 事件样本**漏掉了多个市场影响最大的发布**。
- 假 match / 错记录：约 25+ 条实体 → 样本中存在张冠李戴的能力指标（如 Pika 事件挂着
  腾讯混元的记录、PaliGemma 挂着 PaLM-2 的记录）。
- 快照错误：6+ 条 → Intelligence Index 取值系统性偏晚（偏高）。
- 结论：**当前 final_event_sample.csv 不能直接用于回归**，需按上述清单修正后重建。

---

# 处置结果（同日完成）

用户确认三条政策：(1) 家族发布全收、同公告合并为一个事件；(2) AA 仅收录某档位变体时算
match；(3) announce/preview 与 release 重复时保留 release。据此完成重构：

## 新流水线

`build_dataset.py → resolve_entities.py → build_final_sample.py`

- 全部人工判定迁入独立决策表 `decisions/entity_decisions.csv`（entity_id 级，136 条：
  87 unmatched + 38 redirect + 11 confirm），支持 redirect 多目标 = 家族全收；
  旧的 resolve_manual_review.py 与 resolve_version_mismatches.py 已删除。
- `resolve_entities.py` 内置两条确定性规则（只作用于算法匹配行）：
  快照就近（修正 6 条，如 GPT-4o 2024-05 事件改用 May '24 快照）、
  测量口径规范化 Reasoning > 最高 effort（修正 9 条，如 Claude 4 Sonnet 改用 Reasoning 档）。
- `build_dataset.py` 对比排除正则补充 `comparable to`（自动排除 Llama 3.3 事件中的
  Llama 3.1 405B 引用，对比引用实体共 8 条）。
- `build_final_sample.py` 事件内按 aa_record_key 去重（Claude 3.7/Thinking 等）。

## 修正核对

- 13 条假 unmatch 全部平反回样本（GPT-5、Claude Sonnet 4.5、Claude 3、LLaMA 3、
  Qwen 3、GPT-4.5、SD3×2、SD3.5、Midjourney v6.1、Suno v5、Gemini 3.0 Flash、Nova 2）；
- 全部假 match 清除（PaliGemma 2→PALM-2、Video Model 1.5→混元、Codestral→Devstral 2 等），
  复验时又捞出两条迁移遗漏（Qwen2.5-VL 32B、Mistral-7B-Instruct-v0.3）一并处理；
- 跨事件重复清零（announce/提及占位由决策表逐条排除，理由留痕于
  `processed/entity_resolution_log.csv`）。

## 最终样本

`processed/final_event_sample.csv`：**134 个事件、188 个模型实体**
（2022:3, 2023:8, 2024:50, 2025:61, 2026:12），AA 记录跨事件零重复。

已知遗留（不影响样本构成）：AA 对 Phi-4 Mini Instruct 的 release_date 标为 2024-02-26
（应为 2025-02-26），属上游数据错误，匹配本身正确；事件日期仍为 AiTimeline 月度粒度，
日级精度留待后续任务。
