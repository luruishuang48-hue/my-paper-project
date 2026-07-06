# Full-length paper 数据收集 To-do

生成时间 2026-06-14。  
当前版本 2026-06-14。

这份文档只处理数据收集和数据整理，不写回归设计。当前目标是把已有材料转成论文级 canonical 数据表，并补齐 full-length paper 还缺的外部数据。

## 当前执行状态

已完成第一步数据归拢。统一数据目录为 `data/`。

已生成的关键文件如下。

| 文件 | 说明 |
|---|---|
| `data/README.md` | 统一数据目录说明 |
| `data/manifest.csv` | `data/` 下全部文件清单，含行数、列数、文件大小和短哈希 |
| `data/panel/clean_event_firm_panel.csv` | 当前主面板，5160 行、60 个事件、86 家公司 |
| `data/canonical/event_master_from_panel.csv` | 从主面板去重得到的 60 行事件级表 |
| `data/canonical/company_master_from_panel.csv` | 从主面板去重得到的 86 行公司级表 |
| `data/canonical/event_metric_snapshot_from_panel.csv` | 从主面板提取的事件级 AA 指标快照 |
| `data/canonical/event_firm_relationship_flags_from_panel.csv` | 从主面板提取的事件-公司关系 flags |
| `data/canonical/event_official_sources_from_report.csv` | 从官方发布日期抓取报告解析出的 47 条官方来源 |
| `data/raw_external_paths/missing_raw_files.csv` | 报告中提到但当前项目未找到的原始快照路径 |
| `data/quality_checks/consolidation_checks.csv` | 第一轮归拢校验 |

待恢复的原始快照记录在 `data/raw_external_paths/missing_raw_files.csv`。`data/raw/aitimeline/` 和 `data/raw/artificial_analysis/` 已经作为归档位置创建。

## 一、当前本地已有数据

| 内容 | 本地证据 | 现在状态 |
|---|---|---|
| AI Timeline 原始来源 | `reports/aitimeline_extraction_report.md` | 已抓取并解析。报告显示来源为 NHLOCAL/AiTimeline 的 raw markdown，抓取时间为 2026-04-27 |
| AI Timeline 模型候选事件 | `reports/aitimeline_model_events_enriched_report.md` | 已有 136 条 enriched review rows，其中 82 条有确认可用 AA 指标 |
| Artificial Analysis API 抓取 | `reports/aa_api_fetch_report.md` | 已有抓取报告，覆盖 LLM 和 media endpoints。原始文件路径在另一个 Matrix I 项目目录中 |
| AA 字段说明 | `reports/aa_master_database_codebook.md` 和 `reports/aa_trends_variable_plan.md` | 已有 codebook 和变量计划 |
| AI Timeline 到 AA 的匹配 | `reports/aa_match_report.csv` | 已有 79 条匹配诊断，包括 match status、match score、match method |
| 低置信度和未匹配清单 | `reports/low_confidence_matches.csv`、`reports/unmatched_models.csv`、`reports/manual_review_needed.csv` | 已有人工复核队列 |
| 官方发布日期抓取 | `reports/official_release_date_crawl_report.md` | 已处理 72 个事件，181 条 source candidate，47 个事件填入官方日期 |
| 最终 60 事件报告 | `reports/final_60_event_sample_report.md`、`data/canonical/event_master_from_panel.csv` | 已有最终样本摘要，并已从主面板导出 60 行事件级初表 |
| 计量输入面板 | `output/data/clean_event_firm_panel.csv` | 已有 60 事件 × 86 公司，5160 行 balanced panel |
| AA 指标进入面板 | `output/data/clean_event_firm_panel.csv`、`output/data/specr_input_clean.csv`、`output/data/specr_rel_clean.csv` | 已包含 AA Intelligence、Coding、Math、Media Elo 等指标 |
| 媒体情绪 | `output/data/clean_event_firm_panel.csv` | 已有多个窗口的 media sentiment mean 和 sd |
| 事件-公司关系 | `task/firm_model_relationships.csv`、`task/firm_model_relationship_evidence_business_real_split_narrow_downstream.csv`、`output/data/specr_rel_clean.csv` | 已有 owner、investor、cloud、business_upstream、real_upstream 等关系变量和证据表 |
| 公司业务位置分类 | `task/firm_business_position_classification_narrow_downstream.csv` | 已有 86 家公司的 upstream/downstream 分类 |
| CAR 和控制变量 | `output/data/clean_event_firm_panel.csv` | 已有 market model CAR、FF3 CAR、size、bm、volatility、momentum |
| 已跑结果 | `output/tables/`、`output/figures/` | 已有主回归、spec curve、heterogeneity、composition、quarter 等结果 |

## 二、真正的问题

当前剩下两类问题。

第一类是 canonical 化。已有数据需要合并成稳定主表，统一主键、字段名、来源、过滤路径、匹配规则和质检口径。重点是 `event_master.csv`、`event_filter_flow.csv`、`event_sources.csv`、`event_aa_match.csv` 和 `event_firm_relationships_v2.csv`。

第二类是补外部数据。full-length paper 仍缺 news volume、正式证券标识、额外市场和行业因子、release-day observability、公司 AI 暴露和混杂公司新闻。

## 三、建议的数据包结构

统一数据目录为 `data/`。后续 canonical 表优先放在 `data/canonical/`。

| 表名 | 当前状态 | 优先级 |
|---|---|---|
| `source_inventory.md` | 部分已由 `data/README.md` 和 `data/manifest.csv` 承接，仍需补正式版 | P0 |
| `event_universe_aitimeline.csv` | 已有解析结果，但需导出为 canonical 表 | P0 |
| `event_master.csv` | 已有 `event_master_from_panel.csv` 初版，仍需合并 AI Timeline raw ID、官方来源和过滤路径 | P0 |
| `event_filter_flow.csv` | 需从 AI Timeline universe 到 final sample 重建流失路径 | P0 |
| `event_sources.csv` | 已有 `event_official_sources_from_report.csv` 初版，仍需补 manual override 和非官方来源 | P0 |
| `event_aa_match.csv` | 已有匹配报告，需合并进最终事件 ID 和代表模型规则 | P0 |
| `event_metric_snapshot.csv` | 已有 `event_metric_snapshot_from_panel.csv` 初版 | P0 |
| `event_firm_panel_manifest.csv` | 已有 `event_firm_panel_manifest.csv` 初版 | P0 |
| `event_firm_relationships_v2.csv` | 已有关系和证据，需升级成强度版 | P1 |
| `security_master.csv` | 只有公司和 ticker/code，正式证券 ID 仍缺 | P1 |
| `event_news_volume.csv` | 只有 sentiment，新闻数量缺 | P1 |
| `market_factor_daily.csv` | 已有 FF3 CAR，额外因子缺 | P1 |
| `event_capability_observability.csv` | 可由现有来源构造初版，但目前没有独立表 | P1 |
| `firm_ai_exposure.csv` | 只有业务分类雏形，时间变化 AI 暴露缺 | P2 |
| `confounding_news.csv` | 当前未见系统表 | P2 |

## 四、P0 任务，先把已有东西整理成论文级数据

### 1. 来源清单 `source_inventory.md`

目标是告诉读者每个关键数据源从哪里来、什么时候抓、是否能复现。

已有材料。

- `reports/aitimeline_extraction_report.md`
- `reports/aa_api_fetch_report.md`
- `reports/aa_trends_data_source_inventory.md`
- `reports/official_release_date_crawl_report.md`

agent 能做。

- 把 AI Timeline、Artificial Analysis、官方发布日期、公司关系证据、收益数据全部列成 inventory。
- 写明每个来源的 URL、抓取时间、本地文件、字段用途。
- 标出哪些原始文件在当前项目里，哪些只在另一个 Matrix I 项目路径里。

你需要做。

- 确认 AA 原始抓取文件能否复制到当前项目或 replication package。
- 确认哪些第三方数据不能公开，只能在论文中说明来源。

### 2. AI Timeline universe `event_universe_aitimeline.csv`

目标是把外部开源事件库转成论文可引用的原始 universe。

已有材料。

- AI Timeline 抓取报告显示 raw entries 为 235。
- 模型候选行数为 266。
- manual review candidates 为 136。

需要生成的字段。

| 字段 | 说明 |
|---|---|
| `raw_event_id` | 原始事件 ID，若源文件没有则生成 |
| `aitimeline_year` | AI Timeline 年份 |
| `aitimeline_month` | AI Timeline 月份 |
| `raw_event_text` | 原始 bullet text |
| `parsed_creator` | 解析出的发布者 |
| `parsed_model_name` | 解析出的模型名 |
| `candidate_type` | model、non_model、ambiguous |
| `parse_confidence` | high、medium、low |
| `snapshot_date` | 2026-04-27 或实际抓取时间 |
| `raw_source_path` | 本地 raw markdown 或快照路径 |

agent 能做。

- 从已有报告和可定位的 raw markdown 生成表。
- 如果当前项目缺少 `data/raw/aitimeline/`，先查另一个 Matrix I 路径，再复制或记录外部路径。
- 保留原始文本，不覆盖成清洗字段。

你需要做。

- 确认 AI Timeline 是否作为唯一事件 universe。
- 裁决 ambiguous 事件是否可以进入候选集。

### 3. 事件主表 `event_master.csv`

目标是把最终论文事件样本、排除路径、合并规则放在一张事件级表里。

已有材料。

- `reports/final_60_event_sample_report.md`
- `output/data/clean_event_firm_panel.csv`
- `task/事件集数据-new.csv`
- `task/事件集数据-new 2.csv`
- `reports/main_model_release_events_clean_report.md`

当前判断。

60 个最终事件已经嵌入回归面板。缺的是一张独立、干净、事件级的 canonical table。报告里提到的 `data/final_60_event_sample/main_ai_model_release_events_60.csv` 在当前项目根目录没有找到，所以不能假定它已经可用。

需要生成的字段。

| 字段 | 说明 |
|---|---|
| `event_id` | FMR 或 MMR 稳定 ID |
| `raw_event_id` | AI Timeline 原始事件 ID |
| `event_name` | 标准事件名 |
| `creator` | 发布者 |
| `creator_country` | 发布者国家 |
| `creator_type` | listed_us、private_us、listed_non_us 等 |
| `release_date` | 日级发布日期 |
| `release_month` | 发布月份 |
| `release_quarter` | 发布季度 |
| `event_type` | model release、API release、weights release 等 |
| `model_family` | 模型家族 |
| `model_variants` | 变体 |
| `model_modality` | text、reasoning、coding、image、video 等 |
| `merged_model_count` | 合并的原始模型行数 |
| `merge_rule` | 合并规则 |
| `is_open_weight_or_open_source` | 开放权重或开源 |
| `candidate_tier` | 事件重要性分层 |
| `included_in_final_60` | 是否进入最终 60 事件 |
| `included_in_aa_intelligence_sample` | 是否有 AA Intelligence |
| `included_in_closed_source_sample` | 是否闭源主样本 |
| `date_confidence` | 日期置信度 |
| `source_coverage_flag` | 是否有官方来源 |

agent 能做。

- 从 `output/data/clean_event_firm_panel.csv` 去重得到初版 60 事件表。
- 合并官方日期抓取、AA 匹配和 AI Timeline 原始 ID。
- 输出排除和合并路径。

你需要做。

- 最终确认 preview、API availability、weights release、model card 的事件边界。
- 最终确认同一天多型号发布的合并规则。

### 4. 过滤路径 `event_filter_flow.csv`

目标是把 “AI Timeline universe → 候选模型事件 → AA matched → final 60 → regression sample” 说清楚。

已有材料。

- `reports/aitimeline_extraction_report.md`
- `reports/aitimeline_model_events_enriched_report.md`
- `reports/main_model_release_events_clean_report.md`
- `reports/final_60_event_sample_report.md`

需要生成的字段。

| 字段 | 说明 |
|---|---|
| `raw_event_id` | 原始事件 |
| `filter_stage` | universe、model_candidate、manual_review、aa_confirmed、clean_deduplicated、final_60 |
| `kept` | 是否保留 |
| `drop_or_merge_reason` | 排除或合并原因 |
| `linked_event_id` | 若进入样本，对应 event_id |
| `review_required` | 是否需要人工复核 |

agent 能做。

- 从现有报告重建样本流失路径。
- 标记每一步数量，形成论文里的 sample construction flow。

你需要做。

- 裁决无法从报告恢复的排除理由。

### 5. 事件来源表 `event_sources.csv`

目标是每个事件都有来源证据。

已有材料。

- `reports/official_release_date_crawl_report.md`
- `reports/manual_release_date_override_report.md`
- `reports/manual_event_metadata_override_report.md`

当前判断。

官方日期和来源候选已经抓过。缺的是一张事件-来源级别表，而不是重新找 60 个事件的来源。

需要生成的字段。

| 字段 | 说明 |
|---|---|
| `event_id` | 事件 ID |
| `source_type` | official、model_card、technical_report、docs、repo、news、benchmark |
| `source_title` | 来源标题 |
| `source_url` | URL |
| `source_date` | 来源发布日期 |
| `access_date` | 访问日期 |
| `supports_release_date` | 是否支持发布日期 |
| `supports_capability` | 是否支持能力信息 |
| `supports_open_status` | 是否支持开放权重分类 |
| `reliability` | high、medium、low |
| `conflict_flag` | 是否与 AI Timeline 月份冲突 |

agent 能做。

- 从官方日期抓取报告抽出事件-来源表。
- 对没有官方来源的事件补公开来源。
- 标记日期冲突和低置信度来源。

你需要做。

- 决定是否接受非官方来源补日期。
- 裁决官方日期与 AI Timeline 月份冲突的事件。

### 6. AA 匹配表 `event_aa_match.csv`

目标是证明 AA Intelligence 和其他 AA 指标不是作者主观挑出来的，而是事件与第三方 benchmark 数据匹配后的结果。

已有材料。

- `reports/aa_match_report.csv`
- `reports/aa_api_fetch_report.md`
- `output/data/clean_event_firm_panel.csv`
- `output/data/specr_input_clean.csv`

需要生成的字段。

| 字段 | 说明 |
|---|---|
| `event_id` | 事件 ID |
| `raw_event_id` | AI Timeline 原始事件 ID |
| `aa_model_id` | AA 模型 ID |
| `aa_model_name` | AA 模型名 |
| `aa_creator` | AA 发布者 |
| `aa_source_table` | LLM 或 media |
| `aa_intelligence_index` | Intelligence |
| `aa_coding_index` | Coding |
| `aa_math_index` | Math |
| `aa_media_elo` | Media Elo |
| `match_method` | exact、fuzzy、manual、family、no_match |
| `match_score` | 匹配分数 |
| `match_confidence` | high、medium、low |
| `representative_model_rule` | 多模型事件代表模型规则 |
| `alternative_aa_model_ids` | 备选模型 |
| `aa_snapshot_date` | AA 抓取日期 |

agent 能做。

- 把 `aa_match_report.csv` 与 final 60 event ID 对齐。
- 把 AA 指标和代表模型规则整理成事件级表。
- 列出 Intelligence 显著而 Coding、Math、Media 不显著的完整指标可得性。

你需要做。

- 最终确认多模型发布采用哪个 representative model rule。
- 裁决 medium 和 low confidence 匹配。
- 确认 AA 数据授权和可公开程度。

## 五、P1 任务，补足 full-length paper 的关键缺口

### 7. 新闻数量和关注度 `event_news_volume.csv`

当前状态。

已有媒体情绪变量，但没有发现系统的新闻数量表。`output/data/clean_event_firm_panel.csv` 包含 `media_sent_mean_w*` 和 `media_sent_sd_w*`，不等同于 news volume。

为什么还需要。

AA Intelligence 显著可能被质疑为新闻热度 proxy。新闻数量和独立媒体数量可以直接回应这个问题。

建议字段。

| 字段 | 说明 |
|---|---|
| `event_id` | 事件 ID |
| `window` | `[-20,-2]`、`[-5,-1]`、`[0,+1]`、`[0,+2]`、`[0,+5]`、`[0,+20]` |
| `total_news_count` | 总新闻数 |
| `finance_news_count` | 财经媒体新闻数 |
| `tech_news_count` | 技术媒体新闻数 |
| `unique_outlet_count` | 独立媒体数 |
| `headline_creator_count` | 标题含发布者名称数量 |
| `headline_model_count` | 标题含模型名数量 |
| `headline_benchmark_count` | 标题含 benchmark 或 leaderboard 数量 |
| `mean_sentiment` | 可复用现有 sentiment |
| `news_query` | 查询式 |
| `data_source` | GDELT、NewsAPI、Factiva、RavenPack 等 |

agent 能做。

- 用 GDELT 或可访问 API 做初版新闻量。
- 复用现有 sentiment，整理成 event-window 表。
- 输出 query log 和去重规则。

你需要做。

- 若用 Factiva、RavenPack、Refinitiv、Bloomberg，需要你导出。
- 确认最终新闻源和查询式。

### 8. 正式证券主表 `security_master.csv`

当前状态。

面板里已经有 86 家公司、ticker/code、行业、size、bm、volatility、momentum。但还没有正式证券 ID 和样本边界说明。

为什么还需要。

full-length paper 需要清楚说明“美股市场”到底是 US-listed common stocks、US-traded ADR，还是全球 AI 相关公司用美元/本地市场回报。

建议字段。

| 字段 | 说明 |
|---|---|
| `company_id` | 当前公司 ID |
| `company_name` | 公司名 |
| `ticker` | ticker 或本地代码 |
| `exchange` | 交易所 |
| `exchange_country` | 交易所国家 |
| `security_type` | common stock、ADR、ETF 等 |
| `is_us_listed_common_stock` | 是否美国上市普通股 |
| `is_adr` | 是否 ADR |
| `primary_listing_country` | 主上市地 |
| `permno` | 若有 CRSP |
| `gvkey` | 若有 Compustat |
| `isin` | 若可得 |
| `return_data_source` | 收益来源 |

agent 能做。

- 用公开来源初筛 exchange、ADR、security type。
- 从现有 86 家公司生成 draft security master。
- 标出非美国交易标的和疑似 ADR。

你需要做。

- 若目标是更高期刊，最好提供 CRSP、Compustat、Refinitiv 或 Bloomberg 导出。
- 决定主样本口径。

### 9. 市场和行业因子 `market_factor_daily.csv`

当前状态。

已有 FF3 CAR 和 market model CAR。未见 FF5、momentum、QQQ、SOXX、IGV、SKYY、BOTZ、AI basket 等日频因子表。

为什么还需要。

full-length paper 需要把模型发布效应与科技股、半导体、云计算、AI 主题行情区分开。

建议字段。

| 字段 | 说明 |
|---|---|
| `date` | 交易日 |
| `mkt_rf`、`smb`、`hml`、`rmw`、`cma`、`mom`、`rf` | Fama-French 和 momentum |
| `qqq_return` | Nasdaq proxy |
| `soxx_return` | 半导体 proxy |
| `igv_return` | software proxy |
| `skyy_return` | cloud proxy |
| `botz_return` | AI/robotics proxy |
| `mag7_return` | Mag7 return |
| `ai_basket_return` | 自建 AI basket |

agent 能做。

- 下载公开 FF5 和 momentum。
- 下载公开 ETF 日收益。
- 构造初版 Mag7 和 AI basket。

你需要做。

- 确认哪些因子作为主口径。
- 如果使用 CRSP 或 Bloomberg，提供导出。

### 10. Release-day capability observability `event_capability_observability.csv`

当前状态。

官方来源和 AA 指标都有，但没有单独表说明市场在发布当日是否能观察到能力信息。

为什么还需要。

AA Intelligence 是当前第三方 benchmark 指标。审稿人会问，市场在事件日是否已经知道这个能力水平。如果不知道，AA 指标更像事后质量 proxy，而不是当日信息。

建议字段。

| 字段 | 说明 |
|---|---|
| `event_id` | 事件 ID |
| `official_benchmark_available_day0` | 发布日是否有官方 benchmark |
| `model_card_available_day0` | 发布日是否有 model card |
| `technical_report_available_day0` | 发布日是否有 technical report |
| `third_party_benchmark_available_day0` | 发布日是否有第三方 benchmark |
| `aa_score_observed_date` | AA 分数首次可见日期，若可得 |
| `release_day_capability_proxy` | 发布日可见能力 proxy |
| `observability_score` | 0 到 4 |
| `observability_notes` | 说明 |

agent 能做。

- 从 `event_sources.csv` 和官方页面判断初版 observability。
- 查公开 leaderboard 和 model card 时间。
- 构造 0 到 4 初评分。

你需要做。

- 决定 observability score 的规则。
- 裁决模糊事件。
- 如果 AA 历史快照需要账号或商业权限，需要你提供导出。

## 六、P2 任务，增强机制但不是马上必须

### 11. 公司 AI 暴露 `firm_ai_exposure.csv`

当前状态。

已有公司业务位置分类和事件-公司关系变量，但没有公司-时间层面的 AI exposure。

建议字段。

| 字段 | 说明 |
|---|---|
| `company_id` | 公司 ID |
| `fiscal_period` | 财务期 |
| `ai_keyword_count` | 年报或 10-K AI 关键词 |
| `llm_keyword_count` | LLM 关键词 |
| `ai_keyword_share` | AI 关键词占比 |
| `ai_product_indicator` | 是否有明确 AI 产品 |
| `ai_business_indicator` | 是否有明确 AI 业务 |
| `ai_exposure_score` | 综合暴露评分 |
| `source_url` | 来源 |

agent 能做。

- 抓 SEC filings 和公司公开材料。
- 构造关键词暴露和初版评分。

你需要做。

- 若用 earnings call transcript，需要你提供数据库导出。
- 确认 AI exposure score 权重。

### 12. 事件-公司关系强度 `event_firm_relationships_v2.csv`

当前状态。

这部分不是空白。已有 `task/firm_model_relationships.csv` 和 45408 行 evidence 表，也已经合并到 `output/data/specr_rel_clean.csv`。需要升级的是论文级强度和时点。

建议字段。

| 字段 | 说明 |
|---|---|
| `event_id` | 事件 ID |
| `company_id` | 公司 ID |
| `relationship_type` | owner、investor、cloud、business_upstream、real_upstream、competitor 等 |
| `relationship_indicator` | 0 或 1 |
| `relationship_strength` | 0 到 3 |
| `known_before_event` | 事件日前是否已知 |
| `source_url` | 证据来源 |
| `source_date` | 来源日期 |
| `confidence` | high、medium、low |
| `notes` | 说明 |

agent 能做。

- 从已有关系表和 evidence 表生成 v2。
- 标记事件日前是否已知。
- 给出强度评分草案。

你需要做。

- 决定强度评分规则。
- 裁决 ambiguous relationship。

### 13. 混杂公司新闻 `confounding_news.csv`

当前状态。

未见系统的公司层面混杂新闻表。

建议字段。

| 字段 | 说明 |
|---|---|
| `company_id` | 公司 ID |
| `event_id` | 事件 ID |
| `window` | 事件窗口 |
| `earnings_announcement` | 是否财报日 |
| `guidance_news` | 是否业绩指引 |
| `mna_news` | 是否并购 |
| `major_product_news` | 是否重大产品新闻 |
| `confounding_news_count` | 混杂新闻数量 |

agent 能做。

- 用公开 earnings calendar 补主要公司财报日。
- 用新闻源初筛公司重大新闻。

你需要做。

- 如果要系统处理，需要提供 Factiva、RavenPack、Refinitiv 或 Bloomberg 导出。
- 决定剔除还是控制。

## 七、agent 和你各自负责什么

agent 可以完成。

- 从现有报告和面板重建 canonical event tables。
- 查找当前项目缺失但报告中提到的 raw files。
- 把另一个 Matrix I 路径中的 AA raw files 复制或登记到 source inventory。
- 生成 `event_universe_aitimeline.csv`、`event_master.csv`、`event_filter_flow.csv`、`event_sources.csv`、`event_aa_match.csv`。
- 从现有 relationship evidence 生成 `event_firm_relationships_v2.csv`。
- 下载公开市场因子和 ETF 收益。
- 用公开来源做初版 news volume。
- 构造 draft security master。
- 写数据字典和质检报告。

必须你完成或授权。

- 确认 AI Timeline 是否作为唯一事件 universe。
- 确认最终事件边界和合并规则。
- 确认多模型发布的 representative model rule。
- 裁决低置信度 AA 匹配。
- 确认 AA 原始数据是否能放进项目或 replication package。
- 提供需要权限的数据导出，包括 CRSP、Compustat、Refinitiv、Bloomberg、Factiva、RavenPack、LexisNexis、WRDS。
- 决定主样本到底是 US-listed common stocks，US-traded including ADR，还是 global AI-related equities。
- 确认 news source 作为主口径。
- 确认 relationship strength 和 AI exposure score 的规则。

## 八、推荐执行顺序

第一批只做整理，不新增外部数据。第一轮归拢已经完成，下一步是在 `data/canonical/` 里把初版表升级成正式 canonical 表。

1. 补正式 `source_inventory.md`。
2. 恢复或重抓 AI Timeline raw markdown 和 AA raw JSON。
3. 从现有材料导出 `event_universe_aitimeline.csv`。
4. 将 `event_master_from_panel.csv` 升级为正式 `event_master.csv`。
5. 建 `event_filter_flow.csv`。
6. 将 `event_official_sources_from_report.csv` 升级为正式 `event_sources.csv`。
7. 建 `event_aa_match.csv`。
8. 复核 `event_metric_snapshot_from_panel.csv` 并确定指标缺失口径。

这批完成后，就可以比较稳地写数据来源和样本构造。

第二批补 full-length paper 最容易被问到的数据。

1. 建 `event_news_volume.csv`。
2. 建 `security_master.csv`。
3. 建 `market_factor_daily.csv`。
4. 建 `event_capability_observability.csv`。

这批完成后，才适合认真扩展成全场版主文。

第三批补机制。

1. 升级 `event_firm_relationships_v2.csv`。
2. 建 `firm_ai_exposure.csv`。
3. 建 `confounding_news.csv`。

## 九、最低可用版本

如果只想把 full-length paper 的数据底座先补到能写的程度，最低可用版本不是十几张全新表，而是以下八件事。

1. 把 AI Timeline 和 AA 的原始快照或原始路径登记清楚。
2. 生成事件级 `event_master.csv`。
3. 生成从 AI Timeline universe 到 final 60 的 `event_filter_flow.csv`。
4. 生成事件-来源表 `event_sources.csv`。
5. 生成事件-AA 匹配表 `event_aa_match.csv`。
6. 补一个 news volume 表，至少包含 `[-5,-1]`、`[0,+2]`、`[0,+20]`。
7. 补一个正式证券主表，至少区分 US-listed、ADR、non-US listing。
8. 补一个市场因子表，至少包含 FF5、momentum、QQQ、SOXX、IGV 或相近行业因子。

在这个口径下，当前最应该做的是整理已有数据，而不是重新收集事件库或 AA 指标。
