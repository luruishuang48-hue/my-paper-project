# Finance Research Letters 投稿匹配度评估

访问日期 2026-06-13。

本报告只评估期刊要求和本项目匹配度，未修改项目主文。

## 一、FRL 当前官方投稿定位

Finance Research Letters 是 Elsevier 旗下金融学短文期刊。官方定位很宽，接受 broadly defined finance 领域投稿，并强调 rapid publication of important new results。期刊首页和作者指南均显示，市场效率、事件研究、金融市场和金融计量都在欢迎主题内。因此，本项目的事件研究设计、AI 技术冲击、异常收益率和市场定价问题，主题上属于 FRL 可接收范围。

FRL 的定位不是常规长篇实证论文，而是短、快、清楚的新结果。作者指南写明投稿论文应少于 2500 words，并且要清楚、流畅地传达 findings and novelty，还要包含对广泛金融学共同体有兴趣的 new, preliminary or experimental results。这个措辞对本项目很关键。FRL 可以接受较新的 AI 资本市场证据，但不会给作者太多空间解释复杂数据工程、多个机制和大量稳健性。

期刊也明确会先由主编做 desk review。2026 年 6 月 13 日访问 ScienceDirect 期刊页时，页面展示 submission to first decision 为 4 days。这意味着编辑很可能快速判断两个问题。一是这个结果是否属于金融学问题。二是贡献是否能在摘要、引言前两段和主表中立刻看清。

FRL 对单国重复检验较谨慎。作者指南特别提到，单一国家复制 well-established results 通常不在范围内。本项目不是既有结论的美国市场复制，而是新型 AI 模型发布事件的首次系统事件研究。这一点有利。但论文表述不能写成泛泛的“美国市场中 AI 发布影响股价”，否则容易显得只是一个新事件场景。更合适的定位是，LLM capability 是否被资本市场定价，以及这种定价是否取决于 appropriability。

## 二、官方格式和投稿约束

核心长度要求是少于 2500 words。当前 `Tex/frl_draft_main_text.tex` 经粗略去 LaTeX 后约 2430 词。这个估算包括部分表格文字和参考文献信息，实际投稿系统如何计数不完全确定，但可以判断当前草稿已经贴近上限。后续不应继续加长理论、文献和稳健性解释，必须通过删减来换取新增内容。

摘要要求 concise and factual，不超过 250 words，并需说明研究目的、主要结果和主要结论。当前摘要方向合适，主要数值清楚，长度看起来可控。

关键词要求 1 到 7 个英文关键词。当前已有 keywords，基本符合。

Highlights 必须单独作为可编辑文件提交，3 到 5 条，每条最多 85 characters including spaces。当前项目未见单独 highlights 文件。FRL 投稿前需要补。

文件格式方面，Elsevier 要求提供可编辑源文件。Word 使用单栏，LaTeX 可使用 Elsevier 模板。当前是普通 `article` 类，不一定会直接构成技术拒稿，但投稿前最好转为 Elsevier `elsarticle` 或至少确认 Editorial Manager 接受当前源文件。

表格和图片需可编辑，表格要有标题、说明和脚注。FRL 还建议 sparingly 使用表格，避免重复正文已说明的数据。当前 FRL 草稿有 3 张主表，方向合理，但表注较长，可能挤压 2500 词空间。

数据政策需要特别注意。FRL 作者指南当前对 research data 使用 Option C。作者需要将研究数据存入相关 repository 并在文中引用链接，若不能共享，则必须说明不能共享原因。项目使用 AA 指标、FinBERT 新闻情感、股价和人工关系编码。投稿前至少要准备 data availability statement，并明确哪些数据可共享，哪些受许可或版权约束。

其他投稿材料包括 CRediT author contribution statement、利益冲突声明、资助声明。若 manuscript preparation 使用了生成式 AI，还需要按 Elsevier 政策声明。当前草稿 title footnote 里有 `[ACKNOWLEDGMENTS]` 占位符，作者单位也有 `[Shandong University]` 占位符，这些都需要清理。

FRL 目前有 USD 200 submission fee。开放获取 APC 页面显示为 USD 3540 excluding taxes，但 subscription 路径不收出版费。是否 OA 不影响初稿适配度，但投稿预算要确认。

## 三、FRL 对贡献和结果清晰度的隐含要求

FRL 的显性规则是 2500 词以内，隐含规则是只有一个核心贡献。编辑不太可能在短文里接受“AI 发布事件、开源闭源、投资方、云厂商、owner、Tier、媒体情感、市场学习、行业异质性、Mag7 分化”同时作为主线。当前项目早期中文全文有八到十个发现，更像完整 working paper。当前英文 FRL 草稿已经收窄为 appropriability and capability pricing，这是正确方向。

隐含要求之一是主结果必须一眼能懂。当前最强结果是闭源模型中 AA Intelligence Index 对 CAR[0,+20] 的正向系数，CR2 p 为 0.007，wild bootstrap p 为 0.008。这个结果可以作为 FRL 主表的核心。

隐含要求之二是机制不能靠边缘证据支撑过强结论。当前 open-source interaction 的方向很漂亮，系数为 -0.003734，CR2 p 为 0.048，但 wild bootstrap p 为 0.086。由于只有 11 个 open-source events，若标题和摘要写成“markets price capability only when appropriable”，审稿人可能认为机制证据过度解读。更稳妥的写法是闭源 capability pricing 是 robust fact，open-source attenuation 是 suggestive mechanism。

隐含要求之三是实证设计要足够透明。FRL 可以接受 preliminary or experimental results，但事件筛选、事件日期、AA 指标匹配、公司暴露关系编码必须可审计。否则编辑会把文章看成“新颖但不可复核的数据拼接”。

隐含要求之四是金融学受众要看到本项目不是 AI 技术榜单论文。文章需要持续强调资产定价含义。即市场何时把技术能力转化为预期现金流、竞争优势或租金捕获，而不是讨论模型性能本身。

## 四、本项目适配点

第一，选题契合 FRL 的短 empirical letter。LLM 模型发布是高频、新近、金融市场关注度高的信息事件。FRL 欢迎金融市场、事件研究、市场效率和新结果，本项目的主题天然可放入这些栏目。

第二，项目已有一个可压缩成短文的强结果。闭源样本中 capability pricing 的 CR2 和 wild bootstrap 都支持，事件数为 36，样本量为 2899。这个结果足以支撑一篇短 empirical letter 的主发现。

第三，项目的贡献具有新数据优势。60 个重大模型发布事件、86 家 AI 相关上市公司、5161 个事件公司观测，加上 AA Intelligence Index 和关系编码，比单一事件案例或少数公司分析更有信息量。

第四，当前英文草稿已经比早期中文全文更适合 FRL。`Tex/frl_draft_main_text.tex` 的标题、摘要、引言和结果结构都围绕 appropriability，已经抛弃了过宽的市场学习和产业链全景叙事。

第五，文章可用三张表完成主要证明。Table 1 放 baseline closed-source capability pricing。Table 2 放 open-source interaction，但保守解释。Table 3 放 media sentiment，说明 hype alternative 不能解释 capability effect。这个结构符合短文体裁。

第六，FRL 对新、初步、实验性结果的容忍度比顶级综合金融期刊更高。项目目前的 AI 场景、人工事件集和模型能力指标都更适合先投 short letter，而不是先扩成过长的机制论文。

## 五、本项目不适配点和投稿前风险

最大风险是贡献叙事仍然偏强。当前标题为 `Appropriability and the Market Pricing of AI Model Capability`，摘要结尾写 markets appear to price AI capability primarily when it can be appropriated。这个结论依赖 open-source attenuation，但 open-source 只有 11 个事件，wild bootstrap 未到 5%。建议把主张降一档。稳健事实是 closed-source releases show capability pricing。机制解释是 appropriability-consistent。

第二个风险是 20 日窗口的可识别性。CAR[0,+20] 有利于捕捉慢速信息扩散，但也更容易受到财报、宏观、行业新闻和其他 AI 事件污染。FRL 编辑会接受 20 日窗口，但前提是文章能说明为什么短窗口弱、长窗口强不是数据挖掘。当前草稿已有 alternative windows，但应更明确地把 pre-event CAR、confounding event screen 和 FF3 robustness 放入附录或补充材料。

第三个风险是事件公司面板的独立性。当前主要按 event 聚类，处理了事件层变量的共同冲击，但同一公司在多个事件中重复出现，可能存在公司层相关性。FRL 短文未必要求完整两维聚类，但投稿前应至少补一个 firm-cluster 或 two-way cluster 的稳健性，或者解释为何事件层聚类是主推断口径。

第四个风险是样本构造解释不足。主文写 60 events，但回归主样本为 47 event clusters。原因是 Intelligence Index 和 controls 非缺失筛选。这个差异必须在 Data 段落里清楚说明，否则读者会怀疑样本选择。

第五个风险是 relationship coding 的可复核性。86 家 AI 相关公司如何进入样本、关系编码如何避免事后选择、OpenAI/Microsoft、Anthropic/Amazon/Google、xAI/Tesla 等关系如何处理，都会被问到。FRL 主文不需要长篇展开，但至少要有一个在线 appendix 或 data codebook。

第六个风险是文献仍不完整。当前草稿仍有 `[CITATION]` 和三条 citation placeholder。FRL desk review 前不能出现这种占位符。需要补上 AI/LLM finance、technology announcements、innovation appropriability、media sentiment 和 event study 的最小文献组。

第七个风险是表述和投稿材料尚未整理。当前草稿的 acknowledgments、affiliation、appendix references、highlights、data availability、CRediT、declaration of competing interests、AI use statement 还未准备。它们不是学术贡献问题，但足以拖慢投稿。

第八个风险是过多探索性结果容易削弱主线。Owner 短期负向、investor 交互、cloud 交互、Tier 2、市场学习、行业异质性、Mag7 分化都很有意思，但对 FRL 主文来说太多。它们应进入 appendix 或后续 full paper，不应争夺摘要和引言空间。

## 六、作为短 empirical letter 的建议定位

建议投稿定位为一篇关于 AI 技术能力如何被资本市场选择性定价的短实证信。最稳妥的一句话是：

Financial markets price LLM capability when the release is proprietary, while open-weight releases show only suggestive attenuation.

中文理解是，资本市场会为闭源 LLM 能力定价，开源削弱能力溢价的证据方向明确但统计上应保守。

建议主线只保留三层。

第一层是事实。闭源 LLM release 中，AA Intelligence Index 对 CAR[0,+20] 显著为正。

第二层是机制。open-weight interaction 为负，说明 appropriability 可能解释为什么同样的 capability 不是总能转化为股价收益。

第三层是排除替代解释。媒体情感为负且与 intelligence 正交，说明结果不是简单 AI hype。

不建议在 FRL 主文中主推市场学习、Tier 2、行业分组或 Mag7。这些结果适合附录，也适合将来扩展成长文。

## 七、下一步修改方向

一是把 claim 改得更稳。标题可从 `Appropriability and the Market Pricing of AI Model Capability` 改为 `The Market Pricing of Proprietary AI Model Capability`。摘要和结论中把 open-source 结果统一写成 suggestive attenuation，而不是 decisive reversal。

二是压缩引言。引言只做三件事。提出 capability versus hype 的金融学问题。解释 proprietary versus open-weight 的租金捕获逻辑。给出三条结果。不要展开过多 AI 产业组织背景。

三是重做主表叙事。Table 1 放 full sample 和 closed-source 的主结果。Table 2 放 interaction，并在表注写明 wild p 为 0.086。Table 3 放 sentiment joint model。其余表进入 appendix 或 online supplement。

四是补一页数据透明度。包括事件纳入标准、AA 匹配规则、86 家公司池、关系编码原则、缺失值导致 60 events 到 47 event clusters 的过程。主文可以很短，但 supplement 要完整。

五是补关键稳健性。至少包括 FF3 CAR、pre-event CAR placebo、不同窗口、two-way 或 firm-level clustering、剔除 DeepSeek R1 或其他极端事件、剔除 Mag7 或最大权重公司。若空间不足，主文只报告一句，细节放补充材料。

六是完成投稿格式。准备 highlights 文件、data availability statement、CRediT、conflict of interest、funding statement、AI use statement。检查 abstract 不超过 250 words，keywords 不超过 7 个。清除所有 `[CITATION]`、`[ACKNOWLEDGMENTS]` 和单位占位符。

七是处理数据共享。建议把可共享的事件列表、变量字典、回归用去标识面板、代码和结果表放入 OSF、Zenodo 或 GitHub release。若 AA 原始数据、新闻文本或股价数据受许可限制，则在 data statement 中说明，并共享派生变量和复现脚本。

八是为 cover letter 准备一句贡献。不要写“first paper”。写作重点应是 broad finance relevance，即本研究提供了直接证据，说明资本市场不是机械反应 AI 新闻，而是在技术能力、商业捕获和媒体叙事之间作区分。

## 八、总体判断

本项目适合投 Finance Research Letters，但需要按 FRL 的短文逻辑进一步收窄。当前最可发表的版本不是“LLM 发布行为对金融市场的全景影响”，而是“闭源 LLM 能力被资本市场定价，开源释放削弱这种能力溢价的方向性证据”。

若按当前英文草稿继续推进，匹配度中上。真正的投稿阻断点不是主题不合，而是三件事。结论表述略强，数据构造透明度还不够，投稿材料和文献占位尚未完成。解决这三点后，FRL 是一个合理目标。

## 参考来源

- Elsevier ScienceDirect。Finance Research Letters Guide for Authors。https://www.sciencedirect.com/journal/finance-research-letters/publish/guide-for-authors。访问日期 2026-06-13。
- Elsevier ScienceDirect。Finance Research Letters journal page。https://www.sciencedirect.com/journal/finance-research-letters。访问日期 2026-06-13。
- Elsevier ScienceDirect。Finance Research Letters aims and scope 相关内容见 Guide for Authors 中 Aims and scope。访问日期 2026-06-13。

