# AI Timeline 模型事件整合数据集字段说明

本文档说明 `scripts/build_aitimeline_enriched_dataset.py` 生成的整合数据集。主表把 AI Timeline 候选事件、人工审核结果和本地 Artificial Analysis（AA）master database 指标合在一起。

## 文件

- `data/processed/aitimeline_model_events_enriched.csv`：主表，一行对应一个 AI Timeline 模型候选或一个需要审核的原始 ambiguous 词条。
- `data/processed/aitimeline_model_events_enriched_media_categories_long.csv`：media 模型的分类长表，只包含已匹配到 AA media 模型的行。

## 先看哪几列

- 判断这行能不能用 AA 指标：看 `aa_metrics_usage_status` 和 `has_confirmed_aa_metrics`。
- 找最终模型名：优先看 `review_final_model_event_name`；如果为空，再看 `model_name`。
- 找最终 AA 模型：看 `final_aa_model_id`、`final_aa_model_name` 和 `final_aa_source_table`。
- 判断这行是不是被排除或合并：看 `final_sample_status`、`is_excluded_or_deleted_candidate`、`is_merged_or_duplicate_candidate`。
- 遇到争议：看 `raw_entry_text` 和 `review_decision_notes`。

## 主表字段逐列说明

| 序号 | 字段名 | 分组 | 说明 |
|---:|---|---|---|
| 1 | `dataset_row_id` | 行标识与事件对象 | 本整合表里的行 ID。优先使用 `candidate_event_id`；如果这一行没有候选事件 ID，就用 `raw_entry_id`。做合并、回溯、去重时先看这一列。 |
| 2 | `candidate_event_id` | 行标识与事件对象 | AI Timeline 抽取脚本给模型候选事件生成的 ID。一个原始词条如果拆出多个模型，会有多个 `candidate_event_id`。 |
| 3 | `raw_entry_id` | 行标识与事件对象 | AI Timeline 原始词条 ID。多个拆分出来的模型候选可能共享同一个 `raw_entry_id`。 |
| 4 | `event_month` | 行标识与事件对象 | AI Timeline 能确认的事件月份，格式通常是 `YYYY-MM`。多数 AI Timeline 词条只有年月，没有具体日期，所以不要把它当成精确发布日期。 |
| 5 | `true_model_creator` | 行标识与事件对象 | 自动识别的真实模型发布者，例如 OpenAI、Google、Anthropic、Alibaba。它不是美股受影响公司，也不能把 OpenAI 直接等同于 Microsoft。 |
| 6 | `model_name` | 行标识与事件对象 | 自动抽取出的模型名。人工审核后，最终研究使用的名称优先看 `review_final_model_event_name`。 |
| 7 | `model_family` | 行标识与事件对象 | 自动识别的模型家族，例如 GPT、Claude、Gemini、Llama、Qwen。用于家族级合并和去重。 |
| 8 | `model_variant` | 行标识与事件对象 | 模型版本或变体，例如 `4o`、`3.5 Sonnet`、`70B`、`Flash`。如果原文没有清楚变体，这列可能为空。 |
| 9 | `model_modality` | 行标识与事件对象 | 自动分类的模型类型，例如 `text_llm`、`reasoning_llm`、`image_generation`、`video_generation`。不同模态不能直接共用同一个能力分数。 |
| 10 | `candidate_tier` | 行标识与事件对象 | 候选事件重要性分层。`Tier 1` 通常是重大模型事件；`Tier 2` 是中等重要事件；`Tier 3` 是弱模型或边缘事件。 |
| 11 | `aa_score_group` | 人工审核与最终样本状态 | 这行来自哪一组人工审核清单。`with_aa_candidate_score` 表示初步 fuzzy matching 找到 AA 候选分数；`without_aa_candidate_score` 表示初步没有 AA 候选分数。 |
| 12 | `review_decision_status` | 人工审核与最终样本状态 | 这行是否已经有人工审核决策。`decided` 表示已经处理；`not_decided` 表示还需要人工复核。 |
| 13 | `review_decision` | 人工审核与最终样本状态 | 人工审核时记录的决策类型，例如确认 AA 匹配、人工改匹配、拒绝匹配、合并到其他事件、删除候选等。 |
| 14 | `review_main_sample_action` | 人工审核与最终样本状态 | 人工审核后对主样本的处理动作。它比 `review_decision` 更接近最终样本构造规则。 |
| 15 | `review_final_model_event_name` | 人工审核与最终样本状态 | 人工审核确认后的最终模型事件名。下游研究应优先使用这列，而不是未经审核的 `model_name`。 |
| 16 | `review_final_creator` | 人工审核与最终样本状态 | 人工审核确认后的模型发布者。如果自动识别错误，以下游使用这列为准。 |
| 17 | `review_final_modality` | 人工审核与最终样本状态 | 人工审核确认后的模型模态。如果自动模态分类错误，以下游使用这列为准。 |
| 18 | `final_sample_status` | 人工审核与最终样本状态 | 本整合表给每行归一化后的最终状态。它告诉你这行是保留、排除、合并、无 AA 指标，还是仍需人工复核。 |
| 19 | `has_confirmed_aa_metrics` | 人工审核与最终样本状态 | `1` 表示这行已经有人工确认可用的 AA 指标；`0` 表示没有。回归时如果要使用 AA 能力变量，应优先筛选这一列等于 `1`。 |
| 20 | `has_possible_unconfirmed_aa_metrics` | 人工审核与最终样本状态 | `1` 表示找到可能的 AA 别名，但还没有最终确认。当前主要是 Gemini Pro -> Gemini 1.0 Pro 这类情况。不要把它当作确认匹配。 |
| 21 | `aa_metrics_usage_status` | 人工审核与最终样本状态 | AA 指标可用状态。`confirmed_usable` 可用于机制检验；`possible_alias_needs_confirmation` 只能人工复核；`not_available_or_not_safe` 不应回填指标。 |
| 22 | `final_aa_model_id` | 最终 AA 匹配 | 最终用于连接 AA master database 的模型 ID。为空表示没有安全可用的 AA 模型匹配。 |
| 23 | `final_aa_model_name` | 最终 AA 匹配 | 最终匹配到的 AA 模型名称。它来自 AA master 表，不是自动抽取名称。 |
| 24 | `final_aa_creator_name` | 最终 AA 匹配 | 最终匹配到的 AA 模型创建者名称，来自 AA master 表。 |
| 25 | `final_aa_source_table` | 最终 AA 匹配 | 最终 AA 指标来自哪张本地 master 表。`aa_llm_models` 是 LLM 指标表；`aa_media_models` 是图像、视频、语音等 media 模型表。 |
| 26 | `final_aa_match_basis` | 最终 AA 匹配 | 最终 AA 匹配依据。常见值包括人工决策备注中的 AA ID、确认的候选 1、或无分数组里的可能别名。 |
| 27 | `source` | AI Timeline 原始来源与抽取字段 | 候选事件来源。当前为 `AI Timeline`。 |
| 28 | `source_url` | AI Timeline 原始来源与抽取字段 | AI Timeline 页面 URL，用于回溯来源。 |
| 29 | `year` | AI Timeline 原始来源与抽取字段 | AI Timeline 原始 Markdown 所在年份。 |
| 30 | `month` | AI Timeline 原始来源与抽取字段 | AI Timeline 原始 Markdown 所在月份名称，例如 `August`。 |
| 31 | `event_date_precision` | AI Timeline 原始来源与抽取字段 | 日期精度。`month_only` 表示只有年月；`date_from_text` 表示文本里能抽出具体日期；`unknown` 表示无法判断。 |
| 32 | `raw_entry_text` | AI Timeline 原始来源与抽取字段 | AI Timeline 原始词条全文。遇到争议时，先看这一列判断原文到底说的是模型、产品、系统还是 benchmark。 |
| 33 | `raw_entry_order` | AI Timeline 原始来源与抽取字段 | 原始词条在 AI Timeline 中的顺序编号。用于回到原始列表定位。 |
| 34 | `raw_section` | AI Timeline 原始来源与抽取字段 | 原始词条所在章节，例如 `Year: 2024 / Month: August`。 |
| 35 | `is_special` | AI Timeline 原始来源与抽取字段 | `1` 表示原词条带有 `(*special*)` 标记；`0` 表示没有。 |
| 36 | `extraction_timestamp` | AI Timeline 原始来源与抽取字段 | 本地脚本抽取 AI Timeline 数据的时间戳。 |
| 37 | `split_from_multi_event` | AI Timeline 原始来源与抽取字段 | `1` 表示这行是从一个包含多个模型的原始词条拆出来的；`0` 表示原词条只对应一个候选。 |
| 38 | `split_entry_text` | AI Timeline 原始来源与抽取字段 | 拆分后的候选文本。多模型词条会在这里标出当前行对应哪个模型。 |
| 39 | `creator_country_guess` | AI Timeline 原始来源与抽取字段 | 根据发布者自动猜测的国家或地区。只是辅助字段，不是严格人工核验结果。 |
| 40 | `release_action` | AI Timeline 原始来源与抽取字段 | 原文中的发布动作类型，例如 released、launched、introduced、announced、open_sourced。 |
| 41 | `availability_status` | AI Timeline 原始来源与抽取字段 | 模型可获得状态的粗略判断，例如 public、api、open_weight、preview、announced_only、unknown。 |
| 42 | `is_open_weight_or_open_source` | AI Timeline 原始来源与抽取字段 | `1` 表示候选可能是开源或开放权重模型；`0` 表示不是或无法判断。 |
| 43 | `is_model_family` | AI Timeline 原始来源与抽取字段 | `1` 表示事件更像模型家族发布，而不是单一模型。 |
| 44 | `is_multimodal` | AI Timeline 原始来源与抽取字段 | `1` 表示模型可能支持多模态输入或输出。 |
| 45 | `is_reasoning_model` | AI Timeline 原始来源与抽取字段 | `1` 表示模型被识别为推理模型或强调 reasoning 能力。 |
| 46 | `is_coding_model` | AI Timeline 原始来源与抽取字段 | `1` 表示模型主要面向编程、代码生成或软件工程任务。 |
| 47 | `is_media_generation_model` | AI Timeline 原始来源与抽取字段 | `1` 表示模型属于图像、视频、语音、音乐等生成模型。 |
| 48 | `is_chinese_model` | AI Timeline 原始来源与抽取字段 | `1` 表示发布者或模型主要来自中国生态，例如 Qwen、DeepSeek、Kling、Wan 等。 |
| 49 | `is_us_public_company_creator` | AI Timeline 原始来源与抽取字段 | `1` 表示模型发布者本身是美国上市公司；`0` 表示不是或无法确认。注意：OpenAI、Anthropic、xAI 不是美国上市公司。 |
| 50 | `likely_us_market_relevance` | AI Timeline 原始来源与抽取字段 | 对美股市场相关性的粗略判断：high、medium、low 或 unclear。它只是筛选提示，不是回归变量的最终定义。 |
| 51 | `include_model_candidate` | AI Timeline 原始来源与抽取字段 | `1` 表示自动规则认为它可以进入模型候选池；`0` 表示不应作为模型候选。 |
| 52 | `manual_review_required` | AI Timeline 原始来源与抽取字段 | `1` 表示需要人工审核；`0` 表示自动分类相对明确。 |
| 53 | `exclusion_reason` | AI Timeline 原始来源与抽取字段 | 自动或人工记录的排除原因，例如产品事件、研究系统、低置信度、不是直接模型发布等。 |
| 54 | `classification_confidence` | AI Timeline 原始来源与抽取字段 | 自动分类置信度，范围大致为 0 到 1。越高表示脚本越有把握。 |
| 55 | `notes` | AI Timeline 原始来源与抽取字段 | 自动抽取阶段留下的备注，例如多模型词条、可能重复、产品混杂等。 |
| 56 | `creator_type` | AI Timeline 原始来源与抽取字段 | 发布者类型，例如美国上市公司、美国私营公司、非美国公司、研究机构等。 |
| 57 | `potential_us_exposure_type` | AI Timeline 原始来源与抽取字段 | 可能影响美股公司的经济暴露类型，例如 publisher、strategic_partner、compute_supplier_demand、direct_competitor 等。 |
| 58 | `possible_us_exposed_tickers` | AI Timeline 原始来源与抽取字段 | 可能受事件影响的美股 ticker，多个 ticker 用分号分隔。这里只填明显关系，不能当作最终暴露关系表。 |
| 59 | `needs_relationship_mapping` | AI Timeline 原始来源与抽取字段 | `1` 表示后续还需要人工构造公司层面的关系暴露；`0` 表示暂不需要。 |
| 60 | `possible_duplicate` | AI Timeline 原始来源与抽取字段 | `1` 表示这行可能和另一候选重复；`0` 表示未标记重复。 |
| 61 | `duplicate_of_candidate_event_id` | AI Timeline 原始来源与抽取字段 | 如果 `possible_duplicate=1`，这里给出它可能重复的候选事件 ID。 |
| 62 | `aa_candidate_1` | AA 初步候选匹配 | 初步 fuzzy matching 找到的第 1 个 AA 候选模型名称。它只是候选，不等于最终确认。 |
| 63 | `aa_candidate_1_id` | AA 初步候选匹配 | 第 1 个 AA 候选模型的 AA ID。 |
| 64 | `aa_candidate_1_source_table` | AA 初步候选匹配 | 第 1 个 AA 候选来自哪张表：`aa_llm_models` 或 `aa_media_models`。 |
| 65 | `aa_candidate_1_score` | AA 初步候选匹配 | 第 1 个 AA 候选的 fuzzy matching 分数。分数高不代表一定正确，仍需看人工决策。 |
| 66 | `aa_candidate_2` | AA 初步候选匹配 | 初步 fuzzy matching 找到的第 2 个 AA 候选模型名称。 |
| 67 | `aa_candidate_2_id` | AA 初步候选匹配 | 第 2 个 AA 候选模型的 AA ID。 |
| 68 | `aa_candidate_2_source_table` | AA 初步候选匹配 | 第 2 个 AA 候选来自哪张 AA 表。 |
| 69 | `aa_candidate_2_score` | AA 初步候选匹配 | 第 2 个 AA 候选的 fuzzy matching 分数。 |
| 70 | `aa_candidate_3` | AA 初步候选匹配 | 初步 fuzzy matching 找到的第 3 个 AA 候选模型名称。 |
| 71 | `aa_candidate_3_id` | AA 初步候选匹配 | 第 3 个 AA 候选模型的 AA ID。 |
| 72 | `aa_candidate_3_source_table` | AA 初步候选匹配 | 第 3 个 AA 候选来自哪张 AA 表。 |
| 73 | `aa_candidate_3_score` | AA 初步候选匹配 | 第 3 个 AA 候选的 fuzzy matching 分数。 |
| 74 | `aa_match_status` | AA 初步候选匹配 | 自动 AA 匹配状态，例如 candidate_found、no_candidate、not_applicable。 |
| 75 | `aa_manual_confirmation_required` | AA 初步候选匹配 | `1` 表示 AA 匹配必须人工确认；本项目原则上不自动确认低置信或跨模态匹配。 |
| 76 | `manual_review_source` | AA 初步候选匹配 | 人工审核队列来源。用于区分是自动分类触发、低置信匹配触发，还是其他规则触发。 |
| 77 | `review_batch` | 人工审核与最终样本状态 | 人工审核时所在批次，例如 batch_008。便于回看交互审核过程。 |
| 78 | `review_decision_notes` | 人工审核与最终样本状态 | 人工审核的完整备注。这里记录了为什么确认、为什么拒绝、使用哪个 AA ID、哪些不能回填。 |
| 79 | `is_excluded_or_deleted_candidate` | 人工审核与最终样本状态 | `1` 表示人工确认应排除或删除这个候选；`0` 表示没有这样标记。 |
| 80 | `is_merged_or_duplicate_candidate` | 人工审核与最终样本状态 | `1` 表示这行不是独立事件，而是合并到同一原始词条、同一模型家族或更强代表模型。 |
| 81 | `without_aa_recheck_status` | 无 AA 分数二次复核 | 对无 AA 分数组二次复核后的状态，例如 no_direct_aa_score 或 likely_direct_alias_needs_manual_confirmation。 |
| 82 | `without_aa_recheck_category` | 无 AA 分数二次复核 | 无 AA 分数组二次复核的原因类别，例如 alias_match、family_only_not_exact、product_event_not_model_release。 |
| 83 | `without_aa_recheck_candidate_name` | 无 AA 分数二次复核 | 无 AA 分数组二次复核时发现的可能 AA 候选名称。注意：出现名称不代表可直接使用指标。 |
| 84 | `without_aa_recheck_reason` | 无 AA 分数二次复核 | 无 AA 分数组二次复核的文字解释，说明为什么能或不能使用该候选。 |
| 85 | `aa_master_slug` | 最终 AA 匹配 | AA master 表中的模型 slug，通常是 URL 或数据库内部使用的短名称。 |
| 86 | `aa_master_creator_id` | 最终 AA 匹配 | AA master 表中的创建者 ID。 |
| 87 | `aa_master_creator_slug` | 最终 AA 匹配 | AA master 表中的创建者 slug。 |
| 88 | `aa_master_source_endpoint` | 最终 AA 匹配 | 该 AA 指标来自的官方 API endpoint。用于区分 LLM、text-to-image、text-to-video 等来源。 |
| 89 | `aa_master_fetched_at` | 最终 AA 匹配 | AA master 数据抓取时间。用于判断指标的时间口径。 |
| 90 | `aa_intelligence_index` | AA LLM 指标 | AA LLM Intelligence Index，只对 LLM 匹配行填值。media 模型为空。 |
| 91 | `aa_coding_index` | AA LLM 指标 | AA LLM Coding Index，只对 LLM 匹配行填值。 |
| 92 | `aa_math_index` | AA LLM 指标 | AA LLM Math Index，只对 LLM 匹配行填值。 |
| 93 | `mmlu_pro` | AA LLM 指标 | AA LLM 表里的 MMLU-Pro 分数。为空表示 AA 没返回或该行不是 LLM 匹配。 |
| 94 | `gpqa` | AA LLM 指标 | AA LLM 表里的 GPQA 分数。 |
| 95 | `hle` | AA LLM 指标 | AA LLM 表里的 HLE 分数。 |
| 96 | `livecodebench` | AA LLM 指标 | AA LLM 表里的 LiveCodeBench 分数。 |
| 97 | `scicode` | AA LLM 指标 | AA LLM 表里的 SciCode 分数。 |
| 98 | `math_500` | AA LLM 指标 | AA LLM 表里的 MATH-500 分数。 |
| 99 | `aime` | AA LLM 指标 | AA LLM 表里的 AIME 分数。 |
| 100 | `price_1m_input_tokens` | AA LLM 指标 | AA LLM 表里的每 100 万 input tokens 价格。 |
| 101 | `price_1m_output_tokens` | AA LLM 指标 | AA LLM 表里的每 100 万 output tokens 价格。 |
| 102 | `price_1m_blended_3_to_1` | AA LLM 指标 | AA LLM 表里的 3:1 混合 token 价格。 |
| 103 | `median_output_tokens_per_second` | AA LLM 指标 | AA LLM 表里的中位输出速度，单位是 tokens/second。 |
| 104 | `median_time_to_first_token_seconds` | AA LLM 指标 | AA LLM 表里的中位首 token 延迟，单位是秒。 |
| 105 | `median_time_to_first_answer_token` | AA LLM 指标 | AA LLM 表里的中位首个答案 token 时间。部分模型可能为空或为 0。 |
| 106 | `aa_media_task` | AA Media 指标与分类 | AA media 模型所属任务，例如 text_to_image、image_editing、text_to_video、image_to_video、text_to_speech。 |
| 107 | `aa_media_elo` | AA Media 指标与分类 | AA media leaderboard 的 Elo 分数。只对 media 模型填值。 |
| 108 | `aa_media_rank` | AA Media 指标与分类 | AA media leaderboard 排名。数值越小排名越靠前。 |
| 109 | `aa_media_ci95` | AA Media 指标与分类 | AA media Elo 的 95% 置信区间，通常是类似 `-10/10` 的字符串。 |
| 110 | `aa_media_appearances` | AA Media 指标与分类 | AA media 模型参与比较或出现的次数。可粗略理解为评分样本量。 |
| 111 | `aa_media_release_date_raw` | AA Media 指标与分类 | AA media 表里的原始发布日期字段。格式不一定统一，所以保留 raw 值。 |
| 112 | `aa_media_category_rows` | AA Media 指标与分类 | 这个 media 模型在 category 长表中对应多少行分类评分。 |
| 113 | `aa_media_style_category_count` | AA Media 指标与分类 | 这个 media 模型覆盖多少个 style 类别。 |
| 114 | `aa_media_subject_matter_category_count` | AA Media 指标与分类 | 这个 media 模型覆盖多少个 subject matter 类别。 |
| 115 | `aa_media_format_category_count` | AA Media 指标与分类 | 这个 media 模型覆盖多少个 format 类别。 |
| 116 | `aa_media_style_categories` | AA Media 指标与分类 | 这个 media 模型涉及的 style 类别名称，多个值用分号连接。 |
| 117 | `aa_media_subject_matter_categories` | AA Media 指标与分类 | 这个 media 模型涉及的 subject matter 类别名称，多个值用分号连接。 |
| 118 | `aa_media_format_categories` | AA Media 指标与分类 | 这个 media 模型涉及的 format 类别名称，多个值用分号连接。 |

## Media 分类长表字段

| 字段名 | 说明 |
|---|---|
| `dataset_row_id` | 回连主表的行 ID。 |
| `candidate_event_id` | 回连主表的候选事件 ID。 |
| `raw_entry_id` | 回连主表的 AI Timeline 原始词条 ID。 |
| `event_month` | 事件月份。 |
| `model_name` | 主表中的最终模型事件名或原始模型名。 |
| `true_model_creator` | 模型发布者。 |
| `final_aa_model_id` | AA media 模型 ID。 |
| `final_aa_model_name` | AA media 模型名称。 |
| `media_task` | AA media 任务类型。 |
| `category_dimension` | 分类维度：style、subject_matter 或 format。 |
| `category_name` | 具体类别名称。 |
| `category_elo` | 该模型在这个类别上的 Elo 分数。 |
| `category_ci95` | 该类别 Elo 的 95% 置信区间。 |
| `category_appearances` | 该类别下参与比较或出现的次数。 |

## 使用提醒

- 不要把 LLM 指标和 media 指标直接合成一个原始 `Capability` 分数。LLM 指标和 media Elo/rank 是不同体系。
- 做能力机制检验时，建议先筛选 `has_confirmed_aa_metrics = 1`。
- `possible_alias_needs_confirmation` 只表示可能匹配，不能当作已确认匹配。
- `aa_candidate_*` 是 fuzzy matching 候选，不是最终匹配。最终匹配只看 `final_aa_*` 和人工审核字段。
- 原始 AI Timeline 多数只有年月，所以 `event_month` 不能替代精确发布日期。精确发布日期需要后续官方公告核验。
