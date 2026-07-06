# 子代理 C 数据可行性核查

本文件核查现有数据能支持哪些 proposal 中尚未充分完成的分析。核查依据为 `proposal.md`、`data/README.md`、`data/manifest.csv`、`data/canonical/event_firm_panel_manifest.csv`、`data/results_tables/data_dictionary.csv`，以及三个面板文件。

## 一、结论

现有数据足以继续补做三类分析。第一类是价格、速度和成本效率机制。第二类是媒体情感及媒体分歧的放大机制。第三类是时间演变机制的交互检验。它也能支持更系统的窗口稳健性、FF3 稳健性、关系哑变量异质性和 media 模型能力补充分析。

现有数据不能直接完成 ASVI、媒体覆盖数量、混淆事件剔除、能力跃迁、事件日前可得 benchmark、exposure_strength、manual_exposure_confidence、替代事件日和 Fama-French 五因子检验。这些分析需要新增原始数据或重新整理关系证据。

推荐主代理优先补做以下内容。

| 优先级 | 分析 | 当前数据是否支持 | 可用样本 |
|---|---|---|---|
| 1 | 价格、速度、成本效率机制 | 支持 | 47 个 LLM 事件，约 3,762 个事件-公司观测 |
| 2 | 媒体情感均值和分歧机制 | 支持，但样本少一些 | w5 口径约 37 个事件，2,966 个观测 |
| 3 | 时间演变交互 | 支持 | 47 个 LLM 事件，3,762 个观测 |
| 4 | 不同 CAR 窗口和 FF3 稳健性 | 支持 | 47 个 LLM 事件，约 3,762 至 3,782 个观测 |
| 5 | 关系暴露异质性 | 支持，但字段在 rel 表，不在 clean 表 | 47 个 LLM 事件，基准 3,762 个观测 |
| 6 | media 模型能力样本 | 只能作为补充 | 13 个事件，1,043 个观测 |
| 暂缓 | ASVI、混淆事件、能力跃迁、精细关系强度 | 不支持 | 需要新增数据 |

## 二、样本规模

### 主清洗面板

`data/panel/clean_event_firm_panel.csv` 是最适合作为主面板的文件。

| 项目 | 数值 |
|---|---:|
| 行数 | 5,160 |
| 列数 | 107 |
| 事件数 | 60 |
| 公司数 | 86 |
| 唯一键 | `final_event_id + company_id` |
| 重复键 | 0 |
| 日期范围 | 2024-04-18 至 2026-03-17 |

事件季度分布如下。

| 季度 | 事件数 |
|---|---:|
| 2024Q2 | 4 |
| 2024Q3 | 6 |
| 2024Q4 | 10 |
| 2025Q1 | 10 |
| 2025Q2 | 12 |
| 2025Q3 | 7 |
| 2025Q4 | 6 |
| 2026Q1 | 5 |

发布者分布较集中。Google 有 19 个事件，OpenAI 有 13 个事件，Anthropic 有 8 个事件，Alibaba 有 7 个事件。美国发布者事件 46 个，中国发布者事件 11 个，法国 2 个，英国 1 个。

模态分布如下。

| 模态 | 事件数 |
|---|---:|
| text_llm | 21 |
| reasoning_llm | 17 |
| image_generation | 6 |
| video_generation | 6 |
| multimodal_llm | 5 |
| coding_llm | 4 |
| image_editing | 1 |

### specr 输入表

`data/panel/specr_input_clean.csv` 有 5,161 行和 106 列。最后一行是空行，`final_event_id` 和 `company_id` 都缺失。这个文件保留了原始命名，例如 `car_20` 和 `windows-5`，适合复用旧 specr 脚本，但不如清洗面板稳定。

`data/panel/specr_rel_clean.csv` 有 5,161 行和 84 列。它也有一条空行。剔除空行后，它是关系异质性分析的关键文件，因为它包含 `owner`、`investor`、`cloud`、`business_upstream`、`real_upstream`、`business_downstream`、`real_downstream` 和 `competitor`。

## 三、关键字段

### clean 面板中可直接使用的字段

| 模块 | 字段 |
|---|---|
| 键 | `final_event_id`、`company_id` |
| 事件时间 | `release_date`、`release_year`、`release_month`、`release_quarter`、`trend_month_since_2022_11` |
| 发布者 | `true_model_creator`、`creator_country`、`creator_type` |
| 公司 | `company`、`industry`、`industry_2` |
| 控制变量 | `size_log_assets`、`bm_ratio`、`volatility`、`momentum` |
| 市场模型 CAR | `mkt_car_pre`、`mkt_car_1`、`mkt_car_2`、`mkt_car_3`、`mkt_car_5`、`mkt_car_10`、`mkt_car_15`、`mkt_car_20` |
| FF3 CAR | `ff3_car_pre`、`ff3_car_1`、`ff3_car_2`、`ff3_car_3`、`ff3_car_5`、`ff3_car_10`、`ff3_car_15`、`ff3_car_20` |
| 媒体情感 | `media_sent_mean_w2` 至 `media_sent_mean_w20`，`media_sent_sd_w2` 至 `media_sent_sd_w20` |
| LLM 能力 | `aa_intelligence_index`、`aa_coding_index`、`aa_math_index`、`mmlu_pro`、`gpqa`、`hle`、`livecodebench`、`scicode`、`math_500`、`aime` |
| 价格和速度 | `price_1m_input_tokens`、`price_1m_output_tokens`、`price_1m_blended_3_to_1`、`median_output_tokens_per_second`、`median_time_to_first_token_seconds`、`median_time_to_first_answer_token` |
| media 模型能力 | `aa_media_task`、`aa_media_elo`、`aa_media_rank`、`aa_media_ci95`、`aa_media_appearances`、`aa_media_category_rows` |
| 事件类型 | `model_modality`、`is_model_family`、`is_multimodal`、`is_reasoning_model`、`is_coding_model`、`is_media_generation_model`、`is_open_weight_or_open_source`、`is_chinese_model` |
| 来源 | `release_date_confidence`、`release_source_urls`、`release_source_titles` |

### 关系字段的注意点

`clean_event_firm_panel.csv` 里的 `relationship` 全部缺失，不能用于关系异质性。

关系分析需要使用 `specr_rel_clean.csv`。可用关系哑变量如下。

| 关系变量 | 行数 | 事件数 | 公司数 |
|---|---:|---:|---:|
| owner | 29 | 29 | 4 |
| investor | 37 | 21 | 4 |
| cloud | 29 | 21 | 3 |
| business_upstream | 156 | 60 | 5 |
| real_upstream | 126 | 49 | 5 |
| business_downstream | 1,440 | 60 | 24 |
| real_downstream | 81 | 21 | 5 |
| competitor | 462 | 60 | 9 |

在加入 `aa_intelligence_index`、CAR 和常规控制变量后，LLM 关系分析的可用基准样本为 3,762 行、47 个事件、84 家公司。各关系子样本会明显缩小。owner 只有 21 行，investor 36 行，cloud 28 行，real_downstream 56 行。关系异质性可以做，但对小样本关系不要给强结论。

## 四、缺失情况

### 核心变量缺失

| 字段 | 非缺失行 | 缺失率 | 非缺失事件数 |
|---|---:|---:|---:|
| release_date | 5,160 | 0.0% | 60 |
| true_model_creator | 5,160 | 0.0% | 60 |
| company_id | 5,160 | 0.0% | 60 |
| industry | 5,160 | 0.0% | 60 |
| size_log_assets | 5,075 | 1.6% | 60 |
| bm_ratio | 5,030 | 2.5% | 60 |
| volatility | 4,933 | 4.4% | 60 |
| momentum | 4,892 | 5.2% | 60 |
| mkt_car_20 | 5,053 | 2.1% | 60 |
| ff3_car_20 | 5,078 | 1.6% | 60 |
| media_sent_mean_w5 | 3,956 | 23.3% | 47 |
| media_sent_sd_w5 | 3,869 | 25.0% | 45 |
| aa_intelligence_index | 4,042 | 21.7% | 47 |
| aa_coding_index | 3,010 | 41.7% | 35 |
| aa_math_index | 1,978 | 61.7% | 23 |
| price_1m_blended_3_to_1 | 4,042 | 21.7% | 47 |
| median_output_tokens_per_second | 4,042 | 21.7% | 47 |
| aa_media_elo | 1,118 | 78.3% | 13 |
| release_source_urls | 4,902 | 5.0% | 57 |

### 事件层能力覆盖

| 能力字段 | 覆盖事件数 |
|---|---:|
| aa_intelligence_index | 47 |
| aa_coding_index | 35 |
| aa_math_index | 23 |
| mmlu_pro | 39 |
| gpqa | 44 |
| hle | 44 |
| livecodebench | 40 |
| scicode | 44 |
| math_500 | 35 |
| aime | 33 |
| 价格变量 | 47 |
| 速度变量 | 47 |
| aa_media_elo | 13 |

LLM 能力样本较完整。数学、AIME 等细分能力样本偏小。media 模型只有 13 个事件，只适合作为补充或附录分析。

### 媒体情感覆盖

媒体情感不是全样本变量。w5 均值覆盖 47 个事件，但同时纳入 AA 能力、CAR 和控制变量后，可用样本为 37 个事件和 2,966 个观测。w10 覆盖稍多，但窗口更长，可能离短期事件研究的核心窗口更远。

## 五、可建变量

### 可直接构造的机制变量

1. 价格变量。可使用 `price_1m_input_tokens`、`price_1m_output_tokens`、`price_1m_blended_3_to_1`。建议使用 `log1p(price)`、高价 dummy、低价 dummy，避免免费或接近零价格导致比值爆炸。
2. 成本效率。可构造 `aa_intelligence_index / price_1m_blended_3_to_1`，但只有 32 个事件有有限值。更稳妥的是用 `aa_intelligence_index` 与 `log1p(price)` 共同进入回归，或构造免费模型 dummy。
3. 速度机制。可构造 `aa_intelligence_index × median_output_tokens_per_second`、`aa_intelligence_index / median_time_to_first_token_seconds`，也可直接放入速度和 TTFT。
4. 细分能力。可使用 coding、math、MMLU-Pro、GPQA、HLE、LiveCodeBench、SciCode、MATH-500 和 AIME。数学和 AIME 样本较小，适合规格曲线或附录。
5. 开源机制。可使用 `is_open_weight_or_open_source`，并与能力、价格、速度交互。
6. 发布者国家机制。可使用 `is_chinese_model`、`creator_country`、`creator_type`。
7. 时间演变。可使用 `trend_month_since_2022_11`、`release_quarter`，并与能力、价格、速度、媒体情感交互。由于样本从 2024Q2 开始，无法检验 2022 至 2023 的早期阶段。
8. 媒体情感机制。可使用 `media_sent_mean_w*` 和 `media_sent_sd_w*`，检验情感均值和媒体分歧是否放大模型能力的资本市场反应。
9. media 模型能力。可使用 `aa_media_elo`、`aa_media_rank`、`aa_media_ci95` 和 `aa_media_appearances`，单独估计 media 模型样本。
10. 窗口稳健性。市场模型和 FF3 都有多个窗口，可系统比较 1、2、3、5、10、15、20 天 CAR。
11. 关系异质性。可在 `specr_rel_clean.csv` 中使用八个关系哑变量，做能力 × 关系、价格 × 关系、速度 × 关系。小样本关系需要降级为探索性结果。

### 可近似构造但需谨慎的变量

1. within-modality rank percentile。可在 60 个事件内按 `model_modality` 对 AA 指标或 media Elo 排名，但这是样本内相对排名，不等于真实 leaderboard 前沿排名。
2. 高能力 dummy。可按样本分位数构造，不等于 proposal 中的 frontier rank。
3. 高媒体关注 proxy。现有数据没有报道数量，只能用情感变量是否非缺失、情感分歧或 `aa_media_appearances`。这不等同于媒体覆盖强度。
4. 关系强度 proxy。可用关系哑变量数量或 `relationship_notes` 文本粗略判断，但现有字段没有结构化来源和置信度，不建议作为主结果。

## 六、不可建变量

下面这些 proposal 承诺需要新增数据，不能从现有面板可靠构造。

| 变量或分析 | 当前状态 | 原因 |
|---|---|---|
| firm-level ASVI | 不能构造 | 没有 Google Trends、搜索量、ASVI 或关键词时间序列字段 |
| model-level search intensity | 不能构造 | 没有模型名搜索数据 |
| creator-level search intensity | 不能构造 | 没有发布者搜索数据 |
| event-level attention index | 不能构造 | 没有搜索或报道数量基础数据 |
| 媒体报道数量 | 不能构造 | 面板只有情感均值和标准差，没有 article count 或 coverage count |
| 混淆事件剔除 | 不能构造 | 没有 earnings、M&A、诉讼、监管、管理层变动等事件-公司标记 |
| 替代事件日稳健性 | 不能构造 | 有 release_source_urls，但没有官方日、首次公开日、媒体首次报道日的多日期字段 |
| capability leap | 不能可靠构造 | 没有前代模型 ID、前代能力、family sequence 或 previous model 字段 |
| frontier rank | 不能可靠构造 | 没有事件时点 leaderboard 全体排名，只能做样本内排名 |
| exposure_strength | 不能构造 | 没有强度分数或 high、medium、low 字段 |
| exposure_source | 不能系统构造 | `relationship_notes` 有说明，但不是结构化证据来源表 |
| manual_exposure_confidence | 不能构造 | 没有置信度字段 |
| match_score 和 match_method | 不能构造 | 面板保留代表模型和选择规则，但没有匹配分数 |
| Fama-French 五因子 | 不能构造 | 面板只有市场模型和 FF3 CAR |
| 长期基本面结果 | 不能构造 | 没有事件后收入、利润、研发、市场份额等面板 |

## 七、推荐补做分析

### 1. 价格和速度机制

这是最值得先补做的分析。proposal 明确提出成本效率和速度是市场学习后期的核心机制，现有结果表主要围绕 `aa_intelligence_index`、`aa_coding_index`、`aa_math_index` 和 `aa_media_elo`，价格与速度还没有同等完整的表。

建议估计以下回归。被解释变量用 `mkt_car_20` 为主，并对 `mkt_car_1`、`mkt_car_5` 和 `ff3_car_20` 做稳健性。

- `CAR = intelligence + log1p(price_blended) + controls + industry FE + quarter FE`
- `CAR = intelligence + output_speed + TTFT + controls + FE`
- `CAR = intelligence × open_weight + price + speed + controls + FE`
- `CAR = intelligence × low_price_dummy + controls + FE`
- `CAR = intelligence × high_speed_dummy + controls + FE`

样本可用 47 个 LLM 事件和约 3,762 个观测。成本效率比值要谨慎，因为 `aa_intelligence_index / blended price` 只有 32 个事件有有限值。

### 2. 媒体情感和媒体分歧机制

proposal 中 H4 同时包含 ASVI 和媒体情感。ASVI 不能做，但媒体情感能做。建议把这一块作为 H4 的可执行部分。

建议估计以下回归。

- `CAR = media_sent_mean_w5 + media_sent_sd_w5 + controls + FE`
- `CAR = intelligence + media_sent_mean_w5 + intelligence × media_sent_mean_w5 + controls + FE`
- `CAR = intelligence + media_sent_sd_w5 + intelligence × media_sent_sd_w5 + controls + FE`
- 对 w2、w3、w5、w10 口径做规格曲线

w5 口径在加入控制变量后约有 37 个事件和 2,966 个观测。媒体情感缺失不是随机小问题，报告中应同时列出保留样本和被排除事件。

### 3. 时间演变交互

现有结果表已经有季度斜率和 regime cutoff，但 proposal 还承诺检验市场从 attention-driven 转向 capability-driven、cost-efficiency-driven 和 commercialization-driven。现有数据可以补做更贴近 proposal 的交互项。

建议估计以下回归。

- `CAR = intelligence × trend_month + controls + FE`
- `CAR = price × trend_month + controls + FE`
- `CAR = output_speed × trend_month + controls + FE`
- `CAR = media_sent_mean × trend_month + controls + FE`
- 早晚期分组。建议按 2025Q2 或 2025Q3 切分，因为实际样本从 2024Q2 开始，不存在 2022 至 2023 事件。

这个分析能解释 proposal 的 H5，但文字必须说明样本起点限制。

### 4. 关系暴露交互

关系机制需要使用 `specr_rel_clean.csv`。建议以 `business_downstream`、`competitor`、`business_upstream` 和 `real_upstream` 为主，其余小样本关系放附录。

可估计以下模型。

- `CAR = intelligence × relationship_flag + controls + FE`
- `CAR = price × relationship_flag + controls + FE`
- `CAR = speed × relationship_flag + controls + FE`

小样本关系的结果要写成探索性证据。owner、investor 和 cloud 的公司数只有 3 至 4 家，标准误和外推性都弱。

### 5. media 模型能力补充分析

media 能力样本有 13 个事件和约 1,043 个可用观测。这个样本适合回答 proposal 中不同模态不能混合的问题。

建议单独估计。

- `CAR = aa_media_elo + controls + FE`
- `CAR = aa_media_rank + controls + FE`
- `CAR = aa_media_elo × media_sent_mean_w5 + controls + FE`

结果应放在附录或补充报告。不要把 media Elo 与 LLM Intelligence Index 直接合并。

### 6. 系统稳健性表

现有面板已经有多个 CAR 窗口和 FF3 窗口。建议把同一核心机制在不同窗口下系统输出成一张表或系数图。

建议覆盖。

- 市场模型 CAR 1、2、3、5、10、15、20
- FF3 CAR 1、2、3、5、10、15、20
- 控制变量版本和无控制变量版本
- 行业固定效应、季度固定效应、两者同时加入

这项分析不需要新数据，能显著提高论文的可复现性和说服力。

## 八、建议主代理暂缓的分析

1. ASVI 机制。当前面板只有 `search_code_1` 和 `search_code_2`，它们是代码或检索辅助字段，不是搜索量。不能冒充 ASVI。
2. 混淆事件剔除。没有事件-公司层面的财报、并购、诉讼、监管等标记。除非新增数据，否则不能声称做了 clean-event 剔除。
3. 能力跃迁。没有上一代模型能力，不能构造相对前代提升。样本内分位数只能作为替代描述变量。
4. 精细关系类型。proposal 中的 publisher、parent_company、strategic_partner、major_investor、cloud_provider、distribution_partner、compute_supplier 等没有完整结构化字段。当前八个哑变量能支持较粗的关系机制，但不能完全替代 proposal 的理想关系表。
5. 高媒体覆盖事件筛选。没有报道数量字段，不能做高覆盖样本。
6. 替代事件日。release source 可以证明日期来源，但不能提供多个可替换事件日。

## 九、对后续执行的具体建议

主代理可以直接从 `clean_event_firm_panel.csv` 做价格、速度、媒体情感、时间演变和窗口稳健性。关系机制需要切换到 `specr_rel_clean.csv`，并先剔除最后一条空行。

推荐输出文件。

| 文件 | 内容 |
|---|---|
| `missing_analysis_price_speed.csv` | 价格、速度、成本效率回归 |
| `missing_analysis_media_sentiment.csv` | 媒体情感和媒体分歧回归 |
| `missing_analysis_time_evolution.csv` | 趋势交互和早晚期分组 |
| `missing_analysis_relationship_interactions.csv` | 关系交互结果 |
| `missing_analysis_window_robustness.csv` | 多窗口和 FF3 稳健性 |
| `missing_analysis_report.md` | 中文结果解释和不可做分析说明 |

建议在报告里明确一句。现有数据支持“模型能力、价格、速度、媒体情感和关系暴露如何解释短期 CAR”的补充分析，但还不支持完整的“ASVI 与混淆事件清洗”版本。
