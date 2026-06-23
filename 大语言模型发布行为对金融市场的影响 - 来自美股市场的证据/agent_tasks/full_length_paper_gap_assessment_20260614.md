# 全场版论文还差什么

生成时间 2026-06-14。

本文档只回答一个问题。以现在的结果为基础，如果不只是投 *Finance Research Letters*，而是写一篇完整长度的金融或创新经济学论文，还缺什么。重点区分需要补的数据和需要跑的回归。

## 一、总判断

现在的结果足够支撑一篇短文。核心发现清楚，AA Intelligence 在 CAR[0,+20] 上相对其他能力指标更稳定，闭源发布中的能力定价斜率显著，open-weight 发布削弱该斜率。

但现在还不够支撑一篇 full-length paper。

主要原因不是结果太少，而是识别和机制还不够硬。现在的证据仍主要是事件层能力指标与公司事件 CAR 的相关性。已有 firm FE、FF3、pre-event CAR、event-level aggregation、leave-one-creator-out、CR2 和 wild bootstrap，这些足以让短文站住。但长文会被审稿人追问更多问题。

- 高能力发布是否同时也是媒体关注更强、预期更充分、公司更大、新闻更多的发布。
- 20 日窗口高度重叠时，CAR 是否混入其他 AI 事件和行业共振。
- 闭源机制是否真的来自 rent capture，而不只是 closed-source 发布者和事件类型不同。
- 哪些公司被定价，是 owner、cloud、investor、downstream、competitor，还是整个 AI 股票篮子。
- AA Intelligence 是事后能力 proxy，投资者在发布日能否观察或推断这个能力。

全场版论文需要把这些问题系统补上。

## 二、需要的数据

### 1. 更严格的事件库

这是硬门槛。

现在 60 个事件可以写短文，但全场版需要更可复核的事件定义。

需要补充的数据包括：

- 每个事件的官方发布时间，最好到小时级或至少确认交易日前后。
- 事件是否是正式发布、预告、API 开放、模型卡发布、benchmark 披露、开源权重发布。
- 事件进入样本的规则和排除规则。
- 同一模型家族多次发布时，哪些合并为一个事件，哪些保留为独立事件。
- 事件 tier 的判定依据。
- 发布日前是否已有 preview、leak、benchmark rumor、developer conference announcement。

为什么重要。

全场版审稿人会担心 event selection。若事件库看起来是事后挑的，主回归再显著也会被削弱。

最低可接受做法。

建立一个 `event_master` 表，每个事件至少有 release_date、release_time、event_type、official_source_url、sample_inclusion_reason、prior_preview_indicator、model_family_id、creator、open_weight_status。

### 2. 发布时可观察的信息

这是硬门槛。

AA Intelligence 是好 proxy，但它可能是发布后更新的综合分数。全场版必须处理信息可得性。

需要补充的数据包括：

- AA benchmark 记录的抓取日期或发布时间。
- 发布日前后公开 benchmark 是否已经可得。
- 官方发布文档中的 benchmark 分数。
- 第三方 benchmark、leaderboard、媒体报道中的能力描述。
- 是否能构建一个 release-day observable capability proxy。

为什么重要。

如果 AA Intelligence 是事后测得，论文不能强写“市场在发布日看到这个分数”。更稳的说法是，AA Intelligence 衡量发布披露的真实能力，而市场可能通过官方 benchmark、媒体测评、产品演示和开发者反馈学习能力。

最低可接受做法。

给每个事件加一个 `capability_observable_by_day_0` 或 `benchmark_available_by_day_0` 指标。再做一个子样本检验，只保留发布日或发布后一两天有公开 benchmark 的事件。

### 3. 媒体关注和叙事强度

这是硬门槛。

现有 FinBERT sentiment 有用，但全场版还需要 attention，而不只是 sentiment。

需要补充的数据包括：

- 发布日前后新闻数量。
- 主流财经媒体覆盖数量。
- 技术媒体覆盖数量。
- Google Trends 或 Wikipedia pageviews，若可得。
- 社交媒体或开发者社区热度，若可得。
- 新闻标题中是否出现 frontier、breakthrough、open-source、cheap、reasoning、multimodal 等词。

为什么重要。

审稿人会问，AA Intelligence 是不是只是 attention 的 proxy。情绪变量不能完全回答这个问题，因为强能力发布可能带来更多报道，而不是更正面的报道。

最低可接受做法。

构造 event-level media volume，至少包括窗口 [-5,+5] 和 [0,+2] 的新闻数量。主回归加入 media volume 和 sentiment，并报告 AA Intelligence 系数是否保留。

### 4. 公司 AI 暴露和关系强度

这是硬门槛。

现在关系变量有 owner、investor、cloud、upstream、downstream、competitor，但很多是 0/1 且稀疏。全场版需要更连续的 exposure。

需要补充的数据包括：

- 公司 AI 业务收入占比或文本披露中的 AI 暴露。
- 10-K、earnings call、press release 中 AI 关键词和 LLM 关键词强度。
- 公司与发布者的商业关系强度，最好区分投资、云合作、API 使用、芯片供应、模型集成。
- 客户、供应商、战略伙伴关系的来源链接。
- 关系发生时间，不能只用事后关系。

为什么重要。

现在的结果更像 AI 股票篮子整体重估。若要写完整论文，必须说明哪些公司应该反应更强，为什么。

最低可接受做法。

构造 firm-level AI exposure score 和 event-firm relationship intensity。然后跑 capability × exposure 和 capability × relationship 的交互。

### 5. 更干净的证券样本

这是硬门槛。

现在有一个 US-traded ticker 粗筛，但全场版需要正式的证券识别。

需要补充的数据包括：

- ticker、PERMNO 或其他稳定证券 ID。
- 交易所、国家、ADR 标识。
- 普通股、ADR、双重上市、退市样本处理。
- 每个公司在每个事件日是否正常交易。
- 汇率和本地市场指数，若保留非美国股票。

为什么重要。

论文标题如果说来自美股市场，样本就必须真的是 US-listed 或 US-traded，而不是靠 ticker 后缀推断。

最低可接受做法。

用 CRSP 或 Refinitiv、Compustat、Yahoo Finance 元数据整理出 exchange country 和 security type。主样本限定 US-listed common stocks，ADR 和海外股票放附录。

### 6. 更完整的市场因子和行业因子

这是增强项，但很重要。

需要补充的数据包括：

- Fama-French 5 因子和 momentum。
- Nasdaq、SOX、cloud/software ETF、AI thematic ETF。
- 行业日收益。
- Mag7 或 big tech basket return。
- AI sector calendar-time factor，最好由未受事件直接影响的 AI 股票篮子构造。

为什么重要。

AI 发布事件高度密集，单个事件窗口内可能混有整个科技板块的行情。仅 FF3 可能不够。

最低可接受做法。

至少补 FF5 + momentum、Nasdaq、SOX 或 software/cloud 行业因子。再看闭源 AA Intelligence 系数是否保留。

### 7. 事件窗口重叠和其他新闻

这是硬门槛。

现有 overlap diagnostic 已经说明 47 个 intelligence 事件里只有 4 个在 20 日内无其他 intelligence 事件。全场版不能只把它当 limitation。

需要补充的数据包括：

- 每个交易日是否处在其他 AI 发布事件窗口内。
- 同一发布者、同一模型家族、同一周内多个事件的标识。
- 公司层面的 earnings announcement、guidance、M&A、product event。
- 大盘和行业重大事件日期。

为什么重要。

CAR[0,+20] 不是纯净单事件反应。短文可以承认，长文需要处理。

最低可接受做法。

建立日度 firm-day panel，标记所有 AI release exposure，再做 calendar-time 事件回归或多事件控制。

## 三、需要跑的回归

### 1. 指标 horse race 回归

这是硬门槛。

当前已经有规格曲线比较，但全场版需要更正式。

需要跑：

- 单指标回归，分别放 AA Intelligence、Coding、Math、Media Elo。
- 多指标联合回归，在可比样本中同时放多个能力指标。
- 标准化指标回归，把不同指标转成 z-score 或 percentile。
- 同一样本 horse race，避免因为样本覆盖不同导致比较不公平。
- 多重检验调整，例如 Romano-Wolf、Benjamini-Hochberg 或至少报告 family-wise 解释。

核心目标。

证明不是事后挑 AA Intelligence，而是广义能力指标在同一比较框架中最有解释力。

### 2. 可观察能力子样本回归

这是硬门槛。

需要跑：

- 只保留发布日可观察 benchmark 的事件。
- 只保留发布后 1 至 2 日内有公开 benchmark 或第三方测评的事件。
- 用 official benchmark 或 release-day capability proxy 替代 AA Intelligence。
- AA Intelligence 与 release-day proxy 同时进入回归。

核心目标。

回答 AA Intelligence 是否只是事后测量的问题。

### 3. 媒体关注控制回归

这是硬门槛。

需要跑：

- CAR[0,+20] 对 AA Intelligence、media volume、sentiment 的联合回归。
- 加入 release-day news count 和 pre-release news count。
- 加入 media volume × closed-source。
- 分高 attention 和低 attention 子样本。
- 用 media volume 预测 AA Intelligence，说明两者相关程度。

核心目标。

区分 capability pricing 和 attention pricing。

### 4. 日度事件时间回归

这是硬门槛。

需要跑：

- firm-day 面板，因变量为日异常收益。
- 事件日前后动态系数，至少 [-10,+20]。
- capability × event-time dummies。
- closed-source × capability × event-time dummies。
- open-weight × capability × event-time dummies。

核心目标。

展示反应发生在发布后，而不是发布前，也不是只在某个任意窗口出现。

### 5. 多事件重叠控制

这是硬门槛。

需要跑：

- 在 firm-day 面板中同时控制其他 AI 发布事件窗口。
- 对每个 firm-day 加入当日所有活跃事件的 capability exposure。
- 排除同一周多事件密集期。
- 缩短窗口为 [0,+1]、[0,+2]、[0,+5] 再比较。
- 使用 calendar-time portfolio regression，看高能力闭源事件后的 AI basket 是否有异常收益。

核心目标。

处理 20 日窗口重叠问题。

### 6. 公司 AI 暴露机制回归

这是硬门槛。

需要跑：

- AA Intelligence × firm AI exposure。
- AA Intelligence × relationship intensity。
- AA Intelligence × owner、cloud、investor、downstream、competitor。
- closed-source × AA Intelligence × firm AI exposure。
- open-weight × AA Intelligence × firm AI exposure。

核心目标。

证明市场不是无差别买入 AI 股票，而是对更相关或更可获利公司反应更强。

### 7. 事件层回归的强化版

这是硬门槛。

现在已有 event-level mean CAR，但还可以加强。

需要跑：

- 固定公司集合下的 event-level mean CAR。
- value-weighted event-level CAR。
- median event-level CAR。
- AI-exposure-weighted event-level CAR。
- event-level 关系公司均值和非关系公司均值的差异。
- event-level regression 加 media volume、event tier、creator fixed effects 或 creator group controls。

核心目标。

避免 firm-event panel 堆观测数的质疑。

### 8. 预期和提前定价检验

这是硬门槛。

已有 pre-event CAR，但全场版需要更细。

需要跑：

- CAR[-20,-2]、CAR[-10,-2]、CAR[-5,-1]。
- release-day observable news volume 对 pre-event CAR 的解释。
- 高能力事件和低能力事件的 pre-trend 图。
- 对有 preview 或 leak 的事件单独估计。
- 排除有明确预告的事件。

核心目标。

说明结果不是预期逐步累积或发布前泄露导致的。

### 9. 因子模型和行业调整

这是增强项，但建议做。

需要跑：

- FF5 + momentum CAR。
- Nasdaq-adjusted CAR。
- industry-adjusted CAR。
- SOX 或 software/cloud factor-adjusted CAR。
- Mag7 factor-adjusted CAR。
- AI basket factor-adjusted CAR。

核心目标。

回应结果是否只是科技股或 AI 板块共振。

### 10. 安慰剂和置换检验

这是增强项，但对全场版很有帮助。

需要跑：

- 随机打乱 event-date。
- 随机打乱 AA Intelligence across events。
- 使用非 AI 科技产品发布作为 placebo events。
- 使用不相关行业公司作为 placebo firms。
- 用未来 capability 预测过去 returns。

核心目标。

增强识别可信度，降低 data mining 质疑。

### 11. Creator 和事件类型控制

这是增强项。

需要跑：

- creator fixed effects，若可识别变异足够。
- creator group fixed effects，例如 OpenAI、Google、Meta、Anthropic、Alibaba、Other。
- model family fixed effects，若同一家族多次发布。
- event type controls，包括 API release、open weights、benchmark update、model card、product launch。
- leave-one-creator-out 的 CR2 或 wild 版本。

核心目标。

确认结果不是 OpenAI、Google 或某一类事件驱动。

### 12. 非线性和门槛效应

这是增强项。

需要跑：

- AA Intelligence 分位数组。
- top-quartile capability indicator。
- frontier release indicator。
- spline 或 threshold regression。
- high capability × closed-source。

核心目标。

判断市场定价是否只发生在 frontier capability，而不是线性地定价每一点 benchmark。

## 四、优先级排序

### 必须先做

1. 整理事件库和 release-day observability。
2. 补媒体关注变量，尤其是 news volume。
3. 建 firm-day panel，处理事件窗口重叠。
4. 建正式 US-listed security sample。
5. 跑同一样本的 capability metric horse race。
6. 跑 capability × firm AI exposure 或 relationship intensity。

### 第二批做

1. FF5、momentum、Nasdaq、SOX、AI basket 因子调整。
2. 固定公司集合的 event-level aggregation。
3. 更细 pre-trend 和 preview/leak 子样本。
4. creator 和 event type controls。
5. placebo 和 permutation tests。

### 可以放附录或暂缓

1. 季度异质性。
2. Mag7 vs non-Mag7。
3. owner 短窗口负反应。
4. 行业细分。
5. sentiment quantile。

这些结果有信息量，但现在还不是全场版论文的主骨架。

## 五、全场版论文的最低可发表门槛

如果只补一轮，最低需要达到以下状态。

第一，样本可复核。事件进入规则、发布时间、benchmark 可见性和证券样本定义都能被审稿人检查。

第二，AA Intelligence 不是事后挑选。至少有同一样本 horse race 和 release-day observable proxy 检验。

第三，20 日窗口不是主要漏洞。至少有日度事件时间回归和多事件重叠控制。

第四，机制不只靠 open-weight。至少要有 firm AI exposure 或 relationship intensity 的交互结果。

第五，结果不只是 AI 板块行情。至少要有更强因子或行业调整。

达到这些之后，才适合把论文从 FRL 短文扩成 full-length paper。否则扩写只会把短文的优点稀释掉。
