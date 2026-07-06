# 子题 B 调研结果

调研对象是 `Tex/long_new.tex` 文献综述中与 AI、ChatGPT、生成式 AI 和金融市场有关的部分。本文最适合把既有文献组织成三条线索。第一条线是 AI 或生成式 AI 暴露度如何被测量，并如何进入公司价值和股票回报。第二条线是 AI 投资、AI 专利和机器人自动化如何影响企业成长、创新、劳动力和市场估值。第三条线是大语言模型如何改变资本市场的信息处理和资产价格形成。

核心判断如下。

1. 现有最接近本文的研究是 Eisfeldt、Schubert 和 Zhang 的 `Generative AI and Firm Values`，以及 Blomkvist、Qiu 和 Zhao 的 `Automation and Stock Prices: The Case of ChatGPT`。前者发现 ChatGPT 发布后，劳动力更暴露于生成式 AI 的公司获得正向异常收益；后者发现 AI 可替代性更强行业中的公司出现负向反应。两者共同说明，ChatGPT 不是一个均匀利好，而会在横截面上产生再定价。
2. 多数 AI 暴露度研究把公司看成“任务或劳动力是否受 AI 影响”的容器，常用职业、任务、招聘、简历、专利或文本来聚合暴露度。本文的生态位置变量不同。它不是衡量公司“被 AI 改造多少”，而是衡量公司相对于模型发布方处在上游、下游、竞争者、投资者或控制方的哪一类经济关系。
3. 已有研究通常只利用 ChatGPT 这一单一冲击，或研究 AI 投资的长期平均回报。本文的优势在于把 2022 到 2025 年多次重大模型发布作为事件序列，并区分开源与闭源，能直接回答 AI 模型发布如何沿产业链重分配价值。
4. 生成式 AI 与金融市场的新文献已从“企业是否受益”扩展到“市场如何处理信息”。Italy ChatGPT ban、LLM 新闻情绪、分析师信息处理等研究说明，生成式 AI 同时是生产技术和信息处理技术。本文可借此解释为什么模型发布会在事件窗口中快速被定价。

## 一、逐篇文献要点

| 文献 | 状态与来源 | 测量方式 | 核心发现 | 与本文的写作连接 | 与生态位置测量的区别 |
| --- | --- | --- | --- | --- | --- |
| Eisfeldt, Schubert and Zhang, 2023，`Generative AI and Firm Values` | NBER Working Paper No. 31222，issue date May 2023，revision date January 2026。作者个人主页和 SSRN 显示 Journal of Finance forthcoming 版本加入 Bledi Taska。来源 [NBER](https://www.nber.org/papers/w31222)，DOI [10.3386/w31222](https://doi.org/10.3386/w31222)，另见 [Miao Ben Zhang 主页](https://www.miaobenzhang.com/research.html) | 用职业任务构造公司层面的生成式 AI 劳动力暴露度。核心是把 O*NET 任务映射到生成式 AI 能否替代或补充的任务，再用公司劳动力结构加权。还构造 Artificial-Minus-Human 组合，并用 ChatGPT 于 2022 年 11 月 30 日发布作为事件 | 高生成式 AI 暴露公司的股票在 ChatGPT 发布后显著跑赢低暴露公司。NBER 摘要报告 AMH 组合在发布后两周获得约 5% 收益，效果与 AI 产品暴露不同，并与数据资产、任务可替代性和后续盈利变化相关 | 可作为本文最直接的金融市场基准。本文可写成“已有研究证明 ChatGPT 作为技术冲击会被资本市场定价，但主要依赖劳动力暴露度，尚未刻画模型发布沿 AI 生态链的位置效应” | 该文衡量“公司劳动力任务受生成式 AI 影响的程度”。本文衡量“公司与发布方的生态关系”。例如 NVIDIA 的劳动力暴露未必最高，但在本文中是上游算力互补方；Chegg 是下游被替代方，而不是简单的高 AI 暴露公司 |
| Blomkvist, Qiu and Zhao, 2023，`Automation and Stock Prices: The Case of ChatGPT` | SSRN working paper，posted March 31, 2023。来源 [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4395339)，DOI [10.2139/ssrn.4395339](https://doi.org/10.2139/ssrn.4395339) | 把 ChatGPT 引入视为事件，用行业劳动力对 AI 技术的可替代性来衡量自动化威胁，再考察公司股票反应 | 劳动力更容易被 AI 替代的行业在 ChatGPT 引入后出现显著负向股票收益。作者把这种反应解释为新技术带来的竞争压力，而不是生产率提升占主导 | 可用于支撑本文下游部署型企业受损的机制。ChatGPT 的能力提升会压缩依赖旧有技术或人力服务的企业利润空间 | 该文以行业劳动力可替代性衡量风险。本文进一步把替代压力放到模型发布方与上市公司的经济关系中，区分下游集成、下游部署、下游赋能和直接竞争者 |
| Bertomeu, Lin, Liu and Ni, 2023/2025，`The Economic Consequences of Disrupted Generative AI Adoption` | SSRN working paper，posted May 31, 2023，last revised November 21, 2025。来源 [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4452670)，DOI [10.2139/ssrn.4452670](https://doi.org/10.2139/ssrn.4452670) | 利用 Italy 在 2023 年临时禁用 ChatGPT 的自然实验，结合企业生成式 AI 暴露度，考察禁用期间的市场价值、媒体和分析师情绪、招聘与专利变化 | 高生成式 AI 暴露企业在禁用期相对低暴露企业市场价值下降约 6%，小企业和年轻企业受影响更大。禁用还伴随更负面的媒体和分析师情绪、全职招聘下降和专利放缓 | 可说明资本市场把生成式 AI 视为具有真实生产价值的通用技术。ChatGPT 不可用会降低高暴露企业估值，这与 ChatGPT 发布带来正向价值重估形成互补证据 | 该文衡量企业对生成式 AI 应用的依赖。本文衡量企业在模型发布生态中的受益或受损方向。一个高暴露企业既可能因采用成本下降而受益，也可能因模型能力替代其产品而受损 |
| Bertomeu, Lin, Liu and Ni, 2025，`The Impact of Generative AI on Information Processing: Evidence from the Ban of ChatGPT in Italy` | Journal of Accounting and Economics, 80(1), Article 101782。来源 [WashU Research Profiles](https://profiles.wustl.edu/en/publications/the-impact-of-generative-ai-on-information-processing-evidence-fr/)，DOI [10.1016/j.jacceco.2025.101782](https://doi.org/10.1016/j.jacceco.2025.101782) | 利用 Italy ChatGPT ban，识别金融分析师是否使用生成式 AI，并比较国内分析师与外国分析师对同一公司的预测行为、预测准确性、市场反应和买卖价差 | 禁用降低国内分析师的 AI 使用和预测发布数量，降低预测准确性，削弱信息效率，导致盈余公告反应更强、买卖价差扩大 | 可用于说明生成式 AI 同时影响企业生产和市场信息处理。模型发布不只是实体经济事件，也改变投资者与中介处理信息的能力 | 该文关注资本市场中介如何使用 AI。本文关注模型发布事件如何改变不同生态位置企业的预期现金流和竞争格局 |
| Pietrzak, 2025，`A Trillion Dollars Race: How ChatGPT Affects Stock Prices` | Future Business Journal, 11, Article 50，published March 26, 2025。来源 [Springer Nature](https://link.springer.com/article/10.1186/s43093-025-00470-5)，DOI [10.1186/s43093-025-00470-5](https://doi.org/10.1186/s43093-025-00470-5) | 用 2023 年 1 到 5 月 SEC 6-K 与 8-K 中提及 ChatGPT 的公司公告作为事件，采用市场模型和 CAR，考察公告公司和 Russell 3000 行业组合反应 | 只有部分 ChatGPT 相关公告产生显著异常收益，信息技术板块持续受益，金融和能源板块在一些公告中更脆弱。公司规模、beta、年龄和员工数会解释反应差异 | 可作为事件研究方法和行业异质性证据。它说明市场不会机械地奖励所有提到 ChatGPT 的公司，而会按行业和公司特征区分机会与威胁 | 该文研究公司自我披露的 ChatGPT 事件。本文研究模型发布方的外部技术事件，并按生态位置编码非发布公司对同一事件的外溢反应 |
| Zhao, 2025/2026，`Open-source Generative AI and Firm Value: Evidence from the Release of DeepSeek` | 2025 job market paper，2026 Singapore Management University PhD dissertation 条目。来源 [SMU repository](https://ink.library.smu.edu.sg/etd_coll/839/) 和 [AFA 2026 program](https://www.aeaweb.org/conference/2026/program/2007) | 以 DeepSeek 2025 年 1 月发布作为开源生成式 AI 可得性冲击，用 2023 到 2024 年财报电话会中的 GenAI 关键词构造企业预事件暴露度，再做事件研究 | 高 GenAI 暴露的美国企业相对低暴露企业在事件窗口获得约 1.2% CAR，财务约束更强、专有信息顾虑更大的企业效应更强。论文也报告 GenAI providers 和硬件供应商负向反应 | 与本文的开源调节机制高度相关。它支持开源模型会降低采用成本并提升下游采用者价值，但也提示硬件供应商和模型提供商可能受损 | 该文的高暴露企业是潜在 GenAI 采用者，并排除 providers 和硬件供应商做主样本。本文把上游硬件、云服务、下游和竞争者放在同一框架内，因此能同时估计价值再分配 |
| Babina, Fedyk, He and Hodson, 2024，`Artificial Intelligence, Firm Growth, and Product Innovation` | Journal of Financial Economics, 151, Article 103745。来源 [Mendeley replication dataset](https://data.mendeley.com/datasets/s26kxvspn7/2) 和 [Columbia Business School](https://business.columbia.edu/faculty/research/artificial-intelligence-firm-growth-and-product-innovation)，DOI [10.1016/j.jfineco.2023.103745](https://doi.org/10.1016/j.jfineco.2023.103745) | 用员工简历和招聘信息识别公司层面的 AI 投资。核心变量是企业雇佣或拥有 AI 技能员工的程度，并用大学 AI 人才供给暴露作为工具变量 | AI 投资公司随后销售、就业和市场估值增长更快，增长主要通过产品创新实现。AI 增长集中于大型公司，并与行业集中度上升相关 | 可为本文提供长期基本面支撑。资本市场对模型发布的反应不只是叙事，因为 AI 投资确实与企业成长、产品创新和估值变化相关 | 该文衡量公司是否已经投入 AI 人才和能力。本文衡量公司在特定发布方事件中的位置，能解释为什么同样 AI 相关的公司会一涨一跌 |
| Chen, Shi, Srinivasan and Zakerinia, 2025，`The Value of AI Innovations in Non-IT Firms` | ABFER working paper，February 2025。来源 [ABFER](https://www.abfer.org/component/edocman/main-annual-conference/the-value-of-ai-innovations-in-non-it-firms?Itemid=) | 用 USPTO 标记的 AI 专利识别非 IT 企业的 AI 创新，并沿用专利市场价值方法，把专利公告附近股票反应转化为专利价值。另用 AlexNet 作为核心 AI 能力突破事件 | 非 IT 企业的 AI 专利相对其他专利有约 6% 价值溢价。AI 专利组合有正 alpha，AI 专利还伴随更多前向引用、更高利润率、毛利率和市场份额 | 可说明 AI 价值已从 IT 部门扩散到应用部门。本文可用它承接“AI 是通用目的技术”这一背景，但进一步指出应用部门并不总是受益，模型能力可能同时替代部分下游企业 | 该文衡量企业自己产生的 AI 创新。本文衡量外部模型发布对不同生态角色的再定价，不要求公司本身有 AI 专利 |
| Acemoglu, Autor, Hazell and Restrepo, 2022，`Artificial Intelligence and Jobs: Evidence from Online Vacancies` | Journal of Labor Economics, 40(S1)，DOI [10.1086/718327](https://doi.org/10.1086/718327)。来源 [Journal of Labor Economics](https://www.journals.uchicago.edu/doi/abs/10.1086/718327) 和 [IDEAS](https://ideas.repec.org/a/ucp/jlabec/doi10.1086-718327.html) | 用近乎全量美国在线招聘数据识别 AI 相关职位，并结合 Felten-Raj-Seamans、Brynjolfsson-Mitchell-Rock、Webb 等 AI 暴露度指标，衡量哪些企业和岗位更可能采用 AI | 2010 到 2018 年 AI 岗位快速增长。AI 暴露更高的企业采用 AI 后，非 AI 职位招聘减少，剩余职位技能要求改变 | 可为本文解释“下游部署企业面临组织重组和人力替代压力”。模型发布提高 AI 能力后，市场可能预期部分人力密集业务利润被压缩 | 该文测的是企业劳动力需求和岗位调整。本文测的是资本市场如何按产业链角色把同一模型发布解读成需求利好、替代威胁或竞争压力 |
| Acemoglu and Restrepo, 2020，`Robots and Jobs: Evidence from US Labor Markets` | Journal of Political Economy, 128(6), 2188-2244。来源 [JPE](https://www.journals.uchicago.edu/doi/abs/10.1086/705716)，DOI [10.1086/705716](https://doi.org/10.1086/705716) | 用工业机器人渗透率与地区初始产业结构构造 commuting zone 层面的机器人暴露，估计机器人对就业和工资的影响 | 机器人暴露显著降低当地就业和工资，说明自动化技术可以替代劳动并产生分配效应 | 这是自动化冲击的经典基准。本文可借用其“技术冲击有赢家和输家”的基本逻辑，但研究对象从机器人扩展到 LLM 模型发布和股票市场 | 机器人暴露按地区产业结构衡量。本文按公司与模型发布方的生态位置衡量，且结果变量是短期资本市场反应 |
| Webb, 2019/2020，`The Impact of Artificial Intelligence on the Labor Market` | SSRN working paper。来源 [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3482150) 和作者 PDF [Michael Webb](https://www.michaelwebb.co/webb_ai.pdf)，DOI [10.2139/ssrn.3482150](https://doi.org/10.2139/ssrn.3482150) | 用 AI 专利文本和 O*NET 任务描述的文本重合度构造职业层面的 AI 暴露度，并与软件、机器人等早期自动化技术对比 | AI 更集中影响判断、模式识别和优化任务，暴露职业不完全等同于传统常规任务或机器人暴露职业 | 可为本文提供“AI 暴露度不是简单行业标签”的方法论背景。生态位置编码也需要超越粗行业分类 | Webb 的指标基于技术能力与任务文本相似度。本文的指标基于公司在 AI 生态中的经济关系，不直接判断公司任务是否能被 AI 做掉 |
| Brynjolfsson, Mitchell and Rock, 2018，`What Can Machines Learn, and What Does It Mean for Occupations and the Economy?` | AEA Papers and Proceedings, 108, 43-47。来源 [AEA](https://www.aeaweb.org/articles?id=10.1257/pandp.20181019)，DOI [10.1257/pandp.20181019](https://doi.org/10.1257/pandp.20181019) | 建立 Suitability for Machine Learning rubric，对 O*NET 18,156 个任务评分，再聚合到职业，衡量机器学习适用性 | 机器学习影响的职业与早期自动化不同，多数职业包含部分适合机器学习的任务，但很少有职业可被整体替代 | 可用于文献综述中说明“任务暴露”测量的源头。本文可顺势强调，任务适用性不能直接推出产业链价值分配方向 | SML 是任务技术适用性。本文的生态位置是事件发布方关系。上游硬件不是因为任务适合机器学习而受益，而是因为模型发布提升算力需求预期 |
| Felten, Raj and Seamans, 2021，`Occupational, Industry, and Geographic Exposure to Artificial Intelligence` | Strategic Management Journal, 42(12), 2195-2217。来源 [Wiley](https://sms.onlinelibrary.wiley.com/doi/full/10.1002/smj.3286)，DOI [10.1002/smj.3286](https://doi.org/10.1002/smj.3286) | 构造 AI Occupational Exposure, AIOE，把 AI 应用进展映射到职业所需能力，并进一步聚合到行业和地区暴露度。作者也说明可进一步形成公司层面暴露度 | 提供一套可复用的 AI 暴露度数据，能够比较职业、行业和地理区域受 AI 影响程度 | 可用作本文测量体系的对照。该文解决“哪些职业、行业和地区更受 AI 影响”，本文解决“同一模型发布冲击沿 AI 生态链如何分配” | AIOE 是通用 AI 能力对职业能力的暴露。本文是特定发布方事件下的公司位置关系，具有方向性和事件特异性 |
| Felten, Raj and Seamans, 2023，`How will Language Modelers like ChatGPT Affect Occupations and Industries?` | arXiv working paper，March 2023。来源 [arXiv](https://arxiv.org/abs/2303.01157)，另见 [NYU Stern](https://www.stern.nyu.edu/experience-stern/faculty-research/how-will-language-modelers-chatgpt-affect-occupations-and-industries) | 把 AIOE 框架扩展到语言模型能力，衡量职业、行业和地区对 ChatGPT 类语言模型的暴露 | 法律服务、证券和投资等行业高度暴露，工资与语言模型暴露度正相关 | 可说明金融服务本身是语言模型暴露度很高的行业，也解释为什么资本市场和金融中介会快速关注 LLM | 该文是行业和职业暴露。本文不是判断金融行业是否暴露，而是判断 AI 生态中哪类公司在模型发布时获得或损失价值 |
| Eloundou, Manning, Mishkin and Rock, 2024，`GPTs are GPTs: Labor Market Impact Potential of LLMs` | Science, 384(6702), 1306-1308。来源 [Science](https://www.science.org/doi/10.1126/science.adj0998)，DOI [10.1126/science.adj0998](https://doi.org/10.1126/science.adj0998) | 用人工评估和 GPT-4 分类构造 LLM 任务暴露 rubric，衡量美国职业任务是否可由 LLM 或 LLM-powered software 加速 | 论文估计美国劳动力中相当比例的任务可能受 LLM 影响。早期 arXiv 版本报告约 80% 劳动力至少 10% 任务受影响，约 19% 劳动力至少 50% 任务受影响；Science 版本更保守地强调研究仍需估计实际就业后果 | 可为本文说明 LLM 是通用目的技术，影响范围远超 AI 产业内部。主文可用它承接“模型发布为何会被广泛定价” | 该文衡量任务可被 LLM 加速的潜在范围。本文衡量上市公司在 AI 模型发布生态中的收益和风险方向 |
| Brynjolfsson, Li and Raymond, 2025，`Generative AI at Work` | Quarterly Journal of Economics, 140(2), 889-942。来源 [QJE](https://academic.oup.com/qje/article/140/2/889/7990658)，DOI [10.1093/qje/qjae044](https://doi.org/10.1093/qje/qjae044) | 利用一家企业客服人员分阶段接入生成式 AI 助手的真实部署，比较员工生产率、客户情绪、留存和学习效应 | 接入工具使每小时解决问题数平均提高约 14%，新手和低技能员工收益最大，资深员工提升较小。结果支持生成式 AI 能扩散优秀员工实践 | 可作为生成式 AI 生产率效应的高质量微观证据。本文可借此说明投资者有理由把模型能力提升解读为企业生产率冲击 | 该文研究企业内部采用 AI 的生产率。本文研究模型发布这一外部技术事件如何沿公司与发布方的生态关系影响估值 |
| Lopez-Lira and Tang, 2023/2025，`Can ChatGPT Forecast Stock Price Movements? Return Predictability and Large Language Models` | arXiv and SSRN working paper，first version April 2023，arXiv 显示 2025 年 10 月版本。来源 [arXiv](https://arxiv.org/abs/2304.07619) 和 [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4412788) | 用 ChatGPT 或 GPT-4 对公司新闻标题分类为利好、利空或无关，构造 LLM sentiment score，并检验对后续股票收益的预测力 | LLM 情绪分数能够预测短期股票回报，特别是在小股票和负面新闻后。结果说明 LLM 能改变新闻处理和市场效率 | 可放在 AI 与金融市场的扩展段落。它说明生成式 AI 不只改变实体企业，也可能改变投资者处理信息的边际成本 | 该文研究 AI 作为投资者工具的预测能力。本文研究 AI 模型发布本身作为被市场定价的事件 |
| Eisfeldt and Schubert, 2025，`Generative AI and Finance` | Annual Review of Financial Economics, 17, 363-393。来源 [Annual Reviews](https://www.annualreviews.org/content/journals/10.1146/annurev-financial-112923-020503)，DOI [10.1146/annurev-financial-112923-020503](https://doi.org/10.1146/annurev-financial-112923-020503)。早期版本为 NBER Working Paper No. 33076，来源 [NBER](https://www.nber.org/papers/w33076)，DOI [10.3386/w33076](https://doi.org/10.3386/w33076) | 综述生成式 AI 对金融职业、公司价值和金融研究方法的影响，涵盖暴露度测量、ChatGPT 价值冲击和 AI 工具在金融研究中的应用 | 金融职业高度暴露于生成式 AI。论文系统梳理 ChatGPT 对公司价值和金融研究方法的影响，并指出未来研究需要更好识别 AI 技术冲击 | 可作为文献综述的总括性引用，帮助主文把本文放进“AI and finance”的快速成长领域 | 综述覆盖面广，但不提供 AI 生态位置的事件研究。本文可定位为把综述中提出的“重大技术冲击”落到模型发布和产业链外溢 |

## 二、可写入文献综述的叙事逻辑

### 1. 从 AI 暴露度到公司价值

已有研究首先回答了“哪些企业更受 AI 影响”。Felten、Raj 和 Seamans 用 AI 能力与职业能力的对应关系构造 AIOE，Brynjolfsson、Mitchell 和 Rock 从任务是否适合机器学习出发构造 SML，Webb 用 AI 专利文本和工作任务文本的重合度衡量职业暴露。Eloundou、Manning、Mishkin 和 Rock 则把暴露度框架推进到 LLM，直接评估 GPT 类模型能否加速职业任务。此类研究的共同特点是从任务、职业和行业出发，把公司价值变化理解为劳动力或业务流程被 AI 改造的结果。

金融市场研究沿用这一思路。Eisfeldt、Schubert 和 Zhang 用公司劳动力暴露度解释 ChatGPT 发布后的横截面收益，发现高暴露公司获得显著正向重估。Blomkvist、Qiu 和 Zhao 则强调可替代性带来的负向竞争压力，发现更易被 AI 自动化的行业出现负向股价反应。两篇文献给本文提供了直接出发点。它们显示生成式 AI 冲击不是均匀作用于所有公司，而是在横截面上带来赢家和输家。

本文可在这一段之后转入自己的贡献。现有研究的“暴露度”通常回答公司是否受 AI 影响，却不回答公司在 AI 模型发布生态中的利润来源是什么。本文的生态位置编码把公司放到模型发布方周围，区分算力供应商、云服务商、下游集成商、下游部署企业、赋能服务商和直接竞争者。因此，同样是 AI 暴露企业，既可能因模型能力提升而降低生产成本，也可能因能力替代而失去差异化价值。

### 2. 从 AI 投资到长期基本面

Babina、Fedyk、He 和 Hodson 表明，AI 投资不只是短期市场叙事。用简历和招聘数据衡量的公司 AI 投资与销售、就业、市场估值和产品创新增长相关。Chen、Shi、Srinivasan 和 Zakerinia 进一步从 AI 专利出发，发现非 IT 企业 AI 创新有价值溢价，并能预测未来收益。Brynjolfsson、Li 和 Raymond 的 QJE 实验则提供了生成式 AI 提高劳动生产率的微观证据。

这些文献可用于说明投资者有理由在模型发布时调整预期现金流。但它们也提醒，AI 价值的实现依赖互补资产和具体应用场景。本文在这里的边际贡献是把“AI 价值”拆分为上游需求确认和下游替代威胁。闭源 frontier 模型发布可能提高训练和推理算力需求，利好硬件和云服务；开源模型降低采用成本，可能利好部分应用企业，却削弱硬件稀缺性和闭源模型租金。

### 3. 从生成式 AI 到资本市场信息处理

生成式 AI 也改变资本市场的信息处理方式。Bertomeu、Lin、Liu 和 Ni 在 Italy ChatGPT ban 中发现，禁用 ChatGPT 会降低分析师预测数量和准确性，扩大买卖价差并降低市场效率。Lopez-Lira 和 Tang 发现 LLM 可从新闻标题中提取能预测短期股票收益的信息。Eisfeldt 和 Schubert 的 `Generative AI and Finance` 综述也把金融职业和金融研究方法的 AI 暴露度作为新议题。

这些研究可用于解释本文的事件窗口设计。模型发布事件之所以会被迅速定价，不只是因为技术本身重要，也因为投资者、分析师和财经媒体已把生成式 AI 当成解释公司价值变化的重要信息集。本文可以强调，资本市场对 LLM 发布的反应反映了两个层面的共同变化。一个层面是预期现金流变化，另一个层面是投资者处理和传播 AI 叙事的速度提高。

### 4. 开源与闭源的特殊位置

目前直接研究开源生成式 AI 与公司价值的文献仍少。Zhao 关于 DeepSeek 发布的工作表明，开源模型可能提升高 GenAI 暴露企业价值，原因是降低采用成本和缓解专有信息顾虑；同时，GenAI providers 和硬件供应商可能出现负向反应。这个发现与本文的开源调节假设高度贴近，但它以 DeepSeek 单一事件为主。本文可以把这一证据扩展为跨 60 次模型发布的系统检验，尤其是比较开源与闭源模型对上游硬件和下游部署企业的方向性影响。

## 三、建议写入 `long_new.tex` 的参考文献条目草稿

以下 12 条适合优先进入主文参考文献。若主文使用 BibTeX，可据此再转为标准 `.bib` 条目。

1. Acemoglu, D., Autor, D., Hazell, J., and Restrepo, P. 2022. Artificial intelligence and jobs: Evidence from online vacancies. `Journal of Labor Economics`, 40(S1). DOI 10.1086/718327.

2. Acemoglu, D., and Restrepo, P. 2020. Robots and jobs: Evidence from US labor markets. `Journal of Political Economy`, 128(6), 2188-2244. DOI 10.1086/705716.

3. Babina, T., Fedyk, A., He, A., and Hodson, J. 2024. Artificial intelligence, firm growth, and product innovation. `Journal of Financial Economics`, 151, 103745. DOI 10.1016/j.jfineco.2023.103745.

4. Bertomeu, J., Lin, Y., Liu, Y., and Ni, Z. 2025. The impact of generative AI on information processing: Evidence from the ban of ChatGPT in Italy. `Journal of Accounting and Economics`, 80(1), 101782. DOI 10.1016/j.jacceco.2025.101782.

5. Blomkvist, M., Qiu, Y., and Zhao, Y. 2023. Automation and stock prices: The case of ChatGPT. SSRN working paper. DOI 10.2139/ssrn.4395339.

6. Brynjolfsson, E., Li, D., and Raymond, L. 2025. Generative AI at work. `Quarterly Journal of Economics`, 140(2), 889-942. DOI 10.1093/qje/qjae044.

7. Eisfeldt, A. L., Schubert, G., and Zhang, M. B. 2023. Generative AI and firm values. NBER Working Paper No. 31222. DOI 10.3386/w31222. 注，作者主页与 SSRN 显示当前 Journal of Finance forthcoming 版本可能加入 Bledi Taska，正式引用前应按投稿时最新版核对作者列表。

8. Eisfeldt, A. L., and Schubert, G. 2025. Generative AI and finance. `Annual Review of Financial Economics`, 17, 363-393. DOI 10.1146/annurev-financial-112923-020503.

9. Eloundou, T., Manning, S., Mishkin, P., and Rock, D. 2024. GPTs are GPTs: Labor market impact potential of LLMs. `Science`, 384(6702), 1306-1308. DOI 10.1126/science.adj0998.

10. Felten, E. W., Raj, M., and Seamans, R. 2021. Occupational, industry, and geographic exposure to artificial intelligence: A novel dataset and its potential uses. `Strategic Management Journal`, 42(12), 2195-2217. DOI 10.1002/smj.3286.

11. Kogan, L., Papanikolaou, D., Seru, A., and Stoffman, N. 2017. Technological innovation, resource allocation, and growth. `Quarterly Journal of Economics`, 132(2), 665-712. DOI 10.1093/qje/qjw040.

12. Lopez-Lira, A., and Tang, Y. 2023. Can ChatGPT forecast stock price movements? Return predictability and large language models. arXiv working paper. URL https://arxiv.org/abs/2304.07619.

可作为补充或脚注的文献包括 Brynjolfsson、Mitchell 和 Rock 2018 关于 SML 的任务暴露度，Webb 2019/2020 关于 AI 专利和职业任务文本重合度，Felten、Raj 和 Seamans 2023 关于语言模型行业暴露度，Pietrzak 2025 关于 ChatGPT 相关 SEC current reports 的事件研究，Zhao 2025/2026 关于 DeepSeek 开源模型发布和企业价值。

## 四、建议主文可采用的中文表述

以下文字可供主代理改写进第二节，不建议原样粘贴。

现有研究已经证明，生成式 AI 冲击会被资本市场迅速定价。Eisfeldt、Schubert 和 Zhang 以 ChatGPT 发布为事件，发现劳动力更暴露于生成式 AI 的公司获得显著正向异常收益；Blomkvist、Qiu 和 Zhao 则发现，劳动力更容易被 AI 替代的行业在 ChatGPT 引入后出现负向反应。两类证据共同说明，生成式 AI 并非所有企业的均匀利好，而会在横截面上引发价值重分配。

但这一文献仍主要依赖任务或劳动力暴露度。无论是 Felten、Raj 和 Seamans 的 AIOE，Brynjolfsson、Mitchell 和 Rock 的 SML，Webb 的专利文本暴露，还是 Eloundou、Manning、Mishkin 和 Rock 的 LLM 任务暴露，核心问题都是“哪些职业或企业更容易被 AI 影响”。这类指标难以区分 AI 生态中的互补方与替代方。本文的生态位置编码转而从公司与模型发布方的经济关系出发，区分上游硬件、云基础设施、下游集成、下游部署、下游赋能和直接竞争者，从而识别同一模型发布如何同时利好一部分企业并损害另一部分企业。

AI 投资和创新文献为这种再定价提供了基本面基础。Babina、Fedyk、He 和 Hodson 发现，基于简历和招聘数据衡量的 AI 投资与企业销售、就业、市场估值和产品创新增长相关；Chen、Shi、Srinivasan 和 Zakerinia 发现，非 IT 企业 AI 专利相对其他专利具有价值溢价；Brynjolfsson、Li 和 Raymond 也在真实企业部署中发现生成式 AI 能提升员工生产率。这些证据说明，模型能力提升可能改变企业现金流预期。但本文进一步强调，现金流冲击的方向取决于生态位置。闭源 frontier 模型发布可能确认上游算力需求；开源模型发布则可能降低下游采用成本，同时压缩硬件稀缺性和闭源模型租金。

生成式 AI 还改变金融市场自身的信息处理过程。Italy ChatGPT ban 的证据显示，ChatGPT 被禁用会降低分析师预测数量和准确性，并扩大买卖价差。Lopez-Lira 和 Tang 则发现 LLM 可从公司新闻中提取具有短期收益预测力的信息。这说明 LLM 发布事件之所以能在短窗口内引发明显市场反应，不只因为技术本身重要，也因为投资者和信息中介已经把生成式 AI 纳入价格发现过程。

## 五、写作中应避免的表述风险

1. 不宜把“AI 暴露度高”直接等同于“股价一定上涨”。Blomkvist、Qiu 和 Zhao 以及 DeepSeek 开源事件相关证据都表明，暴露度可能代表机会，也可能代表替代风险。
2. 不宜把 ChatGPT 单一事件的发现直接推广到所有模型发布。本文的优势正是多事件、多发布方、开源与闭源区分。
3. 不宜把开源模型简单写成“利好下游、利空上游”的确定事实。更稳妥的表述是，开源降低采用成本并削弱闭源租金，但对硬件需求的净效应取决于效率提升和使用扩张之间的相对大小。
4. Eisfeldt、Schubert 和 Zhang 的作者列表需要在正式引用前再次核对。NBER 页面仍列 3 位作者，作者主页和 SSRN 的当前版本显示 Journal of Finance forthcoming 版本加入 Bledi Taska。
