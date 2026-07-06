# 事件时间标记覆盖报告

生成时间 2026-07-02 11:02:03 Asia/Shanghai 批次；下午复核修订。

原始检索工作在临时文件夹 `事件时间标记_20260702-110203/` 完成，2026-07-02 已并入正式
流水线并删除该文件夹。判定结果固化为 `decisions/date_decisions.csv`（134 条，逐事件
official_date + 来源 + 理由，约定同 `decisions/entity_decisions.csv`），原始检索证据
移入 `evidence/official_dates/`，可重跑的合并脚本是 `scripts/build_event_dates.py`，
产物是 `processed/final_event_sample_with_dates.csv`。后续新增/修改日期判定，改
`date_decisions.csv` 后重跑该脚本即可，不需要再手工拼表。

## 输入

- 事件表 `final_event_sample.csv`，134 条事件。
- 证据表来自各厂牌分组检索和二次补漏，共 139 条证据行，覆盖 134 个唯一事件。
- 二次补漏证据 3 条，文件 `Manual_second_pass_date_evidence.csv`。

## 日期规则

- 首选厂牌官方技术博客或官方发布公告。
- 没有技术博客日度日期时，使用同一厂牌官方文档、模型页、发布日志或一手技术报告，并在 `date_source_types` 和 `date_notes` 中标明。
- 只有 `YYYY-MM-DD` 被写入事件级 `official_date`。
- 同一事件有多个组件日期时，`official_date` 取最早的非空日度日期，`official_date_all` 保留所有日度日期。
- 只有月份的来源保留在 `official_date_month_candidates`，不写入 `official_date`。
- 没找到日度官方日期的事件标为 `unresolved` 或 `month_only`。

## 覆盖

- day_resolved 125
- month_only 2
- unresolved 7

（初版为 117 / 2 / 15，2026-07-02 下午复核与三次补漏后更新，见文末修订记录。）

## 置信度

- high 104
- medium 22
- low 4
- unresolved 4

## 二次补漏

| event_id | date | source_title | source_url | notes |
|---|---|---|---|---|
| AIT-2022-12-001 | 2022-12-07 | Stable Diffusion v2.1 and DreamStudio Updates 7-Dec 22 | https://stability.ai/news-updates/stablediffusion2-1-release7-dec-2022 | Second-pass verification. Official Stability AI page title includes 7-Dec-22 and page source exposes datePublished 2022-12-07. |
| AIT-2023-07-001 | 2023-07-26 | Announcing SDXL 1.0 | https://stability.ai/news-updates/stable-diffusion-sdxl-1-announcement | Second-pass verification. Official Stability AI page source exposes datePublished 2023-07-26. |
| AIT-2024-12-006 | 2024-12-16 | State-of-the-art video and image generation with Veo 2 and Imagen 3 | https://blog.google/innovation-and-ai/models-and-research/google-labs/video-image-generation-update-december-2024/ | Second-pass verification. Official Google blog page is dated Dec 16, 2024 and announces Veo 2. |

## 未取得日度日期的事件（2026-07-02 三次补漏后）

| event_id | model_names | creators | status | month_candidates | notes |
|---|---|---|---|---|---|
| AIT-2024-04-006 | Firefly 3 | Adobe | month_only | 2024-04 | 二手来源一致为 2024-04-23（Adobe MAX London），但 Adobe 一方新闻稿无法访问或存档定位，按规则不写入日度日期。 |
| AIT-2024-09-004 | KLING 1.5 | KlingAI | unresolved |  | 快手 Kling 无带日期的一方公告页，发布走 App 内更新与社交渠道。 |
| AIT-2024-10-003 | Pika 1.5 | Pika Art | unresolved |  | Pika 无一方公告页，发布走 X 平台，二手指向 2024-10 上旬。 |
| AIT-2024-12-011 | Pika 2.0 | Pika Art | unresolved |  | 同上，无一方公告页。 |
| AIT-2024-12-016 | Kling 1.6 | KlingAI | unresolved |  | 同 Kling 1.5，无一方公告页。 |
| AIT-2025-09-006 | Wan 2.5 | Alibaba | unresolved |  | 二手来源一致指向 2025-09-24（云栖大会），未找到可访问一方公告页。 |
| AIT-2025-12-008 | Z-Image-Turbo; Qwen-Image-2512 | Alibaba | unresolved |  | Z-Image-Turbo 的官方 HF 仓库 createdAt 为 2025-11-25，早于 ATL 12 月，组件身份需复核；Qwen-Image-2512 未检索到。 |
| AIT-2026-02-003 | Gemini 3 Deep Think | Google | unresolved |  | 官方博客初版发布于 2025-12-04；ATL 2026-02 事件疑指后续更新，身份待复核，不能沿用 12-04。 |
| AIT-2026-02-004 | Seedance 2.0 | ByteDance Seed | month_only | 2026-02 | 一手技术报告称 2026 年 2 月上旬在国内正式发布，无具体日。 |

## 修订记录（2026-07-02 下午复核 + 三次补漏）

### 改正的错误

| event_id | 模型 | 原值 | 新值 | 依据 |
|---|---|---|---|---|
| AIT-2024-06-005 | Claude 3.5 Sonnet | 2024-06-21 | 2024-06-20 | Anthropic 页面 publishedOn 为 2024-06-21T03:28Z（UTC），即美东 6/20 晚间；美国公告日为 6/20。原值系 UTC 时区伪影。 |
| AIT-2024-08-003 | Imagen 3 | 2024-12-16（Whisk 博客） | 2024-08-13 | 原证据是 12 月 Whisk 博客，与 8 月事件不符；改用一手技术报告 arXiv:2408.07009 v1（2024-08-13）。 |
| AIT-2024-08-006 | Gemini 1.5 Flash-8B | 2024-10-03（stable 版） | 2024-08-27 | 官方 changelog 记录 2024-08-27 发布三个实验模型（含 flash-8b-exp-0827），与事件文本（三个实验模型）完全对应。 |
| AIT-2024-11-007 | Claude 3.5 Haiku | 2024-10-22（预告） | 2024-11-04 | ATL 11 月事件对应可用而非预告；Vertex AI release notes 记录 2024-11-04 GA。 |
| AIT-2026-02-006 | Grok 4.20 | 置信度 high | 置信度 low | ATL 月份（2026-02）、官方 release notes（2026-03-10）、AA（2026-04-07）三者不一致，事件身份存疑，建议日度分析前复核或剔除。 |

### 三次补漏新解决（unresolved/month_only → day_resolved，8 条）

| event_id | 模型 | official_date | 依据 |
|---|---|---|---|
| AIT-2022-04-002 | DALL-E 2 | 2022-04-06 | 官方页 Wayback 首次快照 2022-04-06，与公开公告日一致。 |
| AIT-2022-10-001 | Stable Diffusion 1.5 | 2022-10-20 | runwayml HF 仓库页 Wayback 首次快照 2022-10-20。 |
| AIT-2023-10-001 | DALL-E 3 | 2023-10-19 | 官方博客（ChatGPT Plus/Enterprise 可用）Wayback 首次快照 2023-10-19，对应 ATL 10 月可用事件。 |
| AIT-2024-07-006 | Udio v1.5 | 2024-07-23 | Udio 官方博客 datePublished 2024-07-23。 |
| AIT-2024-08-002 | GPT-4o 0806 | 2024-08-06 | OpenAI structured outputs 官方博客（发布 gpt-4o-2024-08-06），Wayback 首次快照 2024-08-06。 |
| AIT-2024-10-013 | Recraft V3 | 2024-10-30 | Recraft 官方博客页面日期 October 30, 2024。 |
| AIT-2025-12-004 | Nova 2 系列 | 2025-12-02 | AWS What's New "Posted on: Dec 2, 2025"（re:Invent）。 |
| AIT-2025-12-009 | MiniMax-M2.1 | 2025-12-20 | MiniMax 官方 HF 仓库 createdAt 2025-12-20。 |

另：AIT-2024-04-006 Firefly 3 由 unresolved 升为 month_only（2024-04）。

### 时区规则（进回归前必须决定）

`official_date` 记录的是厂商官方来源显示的日历日，存在两类时区噪音：

1. **UTC 伪影**：Anthropic 等站点元数据用 UTC，美国下午发布会显示为次日（Claude 3.5 Sonnet 即此类，已改正）。
2. **北京时间**：中国厂商（Qwen、Kling、MiniMax、Z.ai 等）博客用北京日期。北京白天发布 = 美东前一日晚间（盘后），首个可反应交易日恰为北京日期当天，因此北京日历日通常无需调整。AA 快照日期比官方日期早一天的系统性差异（QwQ、Qwen 3、Qwen2.5-Coder 等）即源于此，AA 日期不可直接当真值。

建议：回归阶段由 `official_date` 另行生成“美东首个可反应交易日”（US 盘中/盘前发布取当日，盘后取次一交易日，周末顺延），而不是回头改 `official_date`。

### 仍跨月的两条（保留但需注意）

- AIT-2025-04-007（4 月合并视频事件）：按“取最早组件”规则得 Runway Gen-4 的 2025-03-31，落在事件月之外。
- AIT-2026-02-006（Grok 4.20）：official_date 2026-03-10 与 ATL 2 月不符，置信度已降为 low。

## 输出

- `final_event_sample_with_official_dates.csv` 是带官方日期的事件级交付表。
- `official_date_evidence_all.csv` 是完整证据表。
- `evidence/` 保存每个厂牌分组的证据 CSV 和说明。
