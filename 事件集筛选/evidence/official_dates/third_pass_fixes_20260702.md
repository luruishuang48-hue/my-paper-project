# 三次补漏与错误改正证据（2026-07-02 下午）

本文件对应 `third_pass_fixes_20260702.csv`，是 2026-07-02 下午复核批次新增的证据行，覆盖两类修改：

## 一、改正的错误（4 条日期 + 1 条降级）

- **AIT-2024-06-005 Claude 3.5 Sonnet**：2024-06-21 → 2024-06-20。页面元数据 `publishedOn: 2024-06-21T03:28Z` 为 UTC，即美东 6/20 晚间，美国公告日为 6/20。（证据行在原 Anthropic 文件中就地更正，不在本 CSV。）
- **AIT-2024-08-003 Imagen 3**：弃用 12 月 Whisk 博客，改用一手技术报告 arXiv:2408.07009（v1 提交 2024-08-13）。
- **AIT-2024-08-006 Gemini 1.5 Flash-8B**：弃用 10 月 stable 日期，改用官方 changelog 2024-08-27 实验模型发布条目。
- **AIT-2024-11-007 Claude 3.5 Haiku**：弃用 10-22 预告日，改用 Vertex AI release notes 2024-11-04 GA 记录。
- **AIT-2026-02-006 Grok 4.20**：日期保留 2026-03-10，置信度 high → low（ATL 2 月 / 官方 3-10 / AA 4-07 三者不一致）。

## 二、三次补漏新解决（8 条）

日期核验方法有三类，均在 notes 里注明：

1. **官方页面自带日期**：Udio v1.5（datePublished）、Recraft V3（页面日期）、Nova 2（AWS "Posted on"）。
2. **Wayback Machine 首次快照定日**：DALL-E 2、Stable Diffusion 1.5、DALL-E 3（10 月可用博客）、GPT-4o 0806。快照日均与公开报道的发布日一致；此法给出的是"页面最晚于该日存在"，置信度标 medium（GPT-4o 0806 因模型版本号自带 0806 标 high）。
3. **官方 HuggingFace 仓库 createdAt**：MiniMax-M2.1（2025-12-20）。

Firefly 3 未能取得一方日度来源，升为 month_only（2024-04）。
