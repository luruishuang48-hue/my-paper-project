# 子题 A 调研 科技产品发布与技术创新公告的事件研究

本文件只服务于 `Tex/long_new.tex` 第二节文献综述的后续整合，不修改主文稿。调研重点放在三类文献上。一是事件研究方法的经典来源，二是科技产品发布、IT 投资、技术联盟、创新和专利公告的市场反应，三是 2020 年以后向数字化、平台、区块链和 AI 公告扩展的近期研究。整体写作目标是为本文提供一个清晰定位，即现有文献已经证明技术类公告会被资本市场定价，但多数研究仍以公告发起企业、直接竞争者或单一行业为分析对象，较少同时刻画 AI 生态上游和下游在同一模型发布冲击下的方向相反反应。

## 一、建议写入综述的主线

第一，事件研究法是测度技术信息进入股价的标准工具。Fama et al. (1969) 用股票分割事件展示价格会围绕新信息快速调整，Brown and Warner (1980, 1985)、MacKinlay (1997)、Kothari and Warner (2007)、Corrado (1989, 2011) 系统讨论了异常收益、市场模型、短窗口可靠性和非参数检验。本文以 LLM 发布作为公开且可精确定位的技术冲击，采用短窗口 CAR 与稳健推断，方法上可以直接承接这一传统。

第二，技术产品发布和 IT 投资公告通常被视为关于未来现金流、增长机会和战略能力的信号。新产品公告文献发现，产品发布总体可能带来正向估值效应，但反应高度依赖行业、产品创新程度、企业规模、既有预期和产品组合重要性。IT 投资文献的结论更有条件性，早期研究对一般 IT 投资公告未发现显著平均效应，后来研究表明只有战略性、转型性、组织整合程度高的 IT 投资更容易创造市场价值。这一脉络可以帮助本文强调，市场不会机械地把任何技术发布都当作均匀利好，而是会根据技术路径、商业互补性和组织位置重新定价。

第三，技术联盟、R&D 增加、专利和创新公告文献进一步说明，技术信息也会通过竞争、互补、知识资本和期权价值影响企业估值。技术联盟往往产生正向异常收益，专利价值可以用授权或公告日附近的股价反应衡量。本文可以借此说明，LLM 发布不只是发布方自身的创新事件，它同时向算力供应商、云平台、模型应用企业和潜在替代者释放不同信号。

第四，2020 年以后的研究逐渐从传统产品发布转向数字平台、区块链、AI 投资、ChatGPT 和生成式 AI 公告。区块链研究显示，市场会区分实质性项目、投机性披露、联盟或后续公告。AI 投资研究发现，AI 公告并不必然带来正向反应，企业能力、行业属性和投资类型会改变结果。生成式 AI 研究开始关注 ChatGPT 发布和企业 GenAI 公告的市场效应，也出现了对供应商外溢的分析。不过，这些研究多使用 AI 暴露度、企业自我公告或单一市场概念股分类，尚未系统区分 LLM 产业链生态位置和开源闭源属性。

## 二、经典事件研究方法文献

| 文献 | 题名或主题 | 核心发现 | 可用于本文的写作连接 | 来源 |
|---|---|---|---|---|
| Fama, Fisher, Jensen and Roll (1969) | The Adjustment of Stock Prices to New Information | 以股票分割为事件，展示股价围绕新信息迅速调整，是现代事件研究的奠基文献之一。 | 支撑本文将 LLM 发布视为市场可观察的信息冲击，并用事件窗口测度市场重新定价。 | DOI [10.2307/2525569](https://doi.org/10.2307/2525569) |
| Brown and Warner (1980) | Measuring Security Price Performance | 用模拟方法比较月度收益事件研究的多种异常收益模型，发现市场模型等简单方法在多数设定下表现良好。 | 为本文采用市场模型估计正常收益提供经典依据。 | DOI [10.1016/0304-405X(80)90002-1](https://doi.org/10.1016/0304-405X(80)90002-1) |
| Brown and Warner (1985) | Using Daily Stock Returns | 证明日度收益事件研究在常规设定下可行，标准方法通常具有良好规格，但需要注意事件诱发波动和相关性。 | 支撑本文使用日度股价和短期 CAR，同时提示需进行稳健推断。 | DOI [10.1016/0304-405X(85)90042-X](https://doi.org/10.1016/0304-405X(85)90042-X) |
| Corrado (1989) | A nonparametric test for abnormal security-price performance | 提出事件研究中的非参数秩检验，模拟显示在非正态收益分布下更稳健。 | 可作为本文补充非参数或 bootstrap 推断的依据。 | DOI [10.1016/0304-405X(89)90064-0](https://doi.org/10.1016/0304-405X(89)90064-0) |
| MacKinlay (1997) | Event Studies in Economics and Finance | 系统综述事件研究流程，强调在市场理性条件下，事件经济影响会迅速反映在证券价格中。 | 适合在方法论综述中说明事件研究为何能测度 LLM 发布的市场价值影响。 | URL [IDEAS/RePEc](https://ideas.repec.org/a/aea/jeclit/v35y1997i1p13-39.html) |
| McWilliams and Siegel (1997) | Event Studies in Management Research | 指出管理学事件研究常见问题包括事件窗口选择、混杂事件、样本选择和理论识别不足。 | 可用于说明本文需要严格筛选 LLM 发布日期，并控制混杂技术事件。 | DOI [10.5465/257056](https://doi.org/10.5465/257056) |
| Kothari and Warner (2007) | Econometrics of Event Studies | 综述事件研究计量问题，认为短窗口方法较可靠，而长窗口异常收益推断更困难。 | 支撑本文重点解释短中期事件窗口，谨慎对待较长窗口解释。 | SSRN [608601](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=608601) |
| Corrado (2011) | Event Studies A Methodology Review | 回顾短期事件研究中的关键方法问题，讨论异常收益度量、检验方法和事件诱发方差。 | 可用于说明本文采用多种标准误和稳健性检验的必要性。 | DOI [10.1111/j.1467-629X.2010.00375.x](https://doi.org/10.1111/j.1467-629X.2010.00375.x) |

## 三、科技产品发布、IT 投资与技术创新公告

| 文献 | 题名或主题 | 核心发现 | 可用于本文的写作连接 | 来源 |
|---|---|---|---|---|
| Chan, Martin and Kensinger (1990) | Corporate Research and Development Expenditures and Share Value | 研究 R&D 支出增加公告，发现平均异常收益显著为正，高科技企业反应更强，低科技企业可能为负。 | 说明技术投入公告的市场价值取决于行业技术属性。LLM 事件也可能对 AI 生态不同位置企业产生异质性效应。 | DOI [10.1016/0304-405X(90)90005-K](https://doi.org/10.1016/0304-405X(90)90005-K) |
| Chaney, Devinney and Winer (1991) | The Impact of New Product Introductions on the Market Value of Firms | 使用事件研究分析新产品引入对企业市值的影响，发现新产品公告包含可被资本市场定价的信息。 | 可作为科技产品发布事件研究的经典入口，但其重点是公告企业自身价值而非产业链外溢。 | DOI [10.1086/296552](https://doi.org/10.1086/296552) |
| Hendricks and Singhal (1997) | Delays in New Product Introductions and the Market Value of the Firm | 新产品推迟公告平均导致约 5.25% 的市值损失，显示产品发布时点具有重大价值含义。 | 支撑本文关注模型发布日期本身，因为技术产品能否如期发布会直接改变投资者预期。 | DOI [10.1287/mnsc.43.4.422](https://doi.org/10.1287/mnsc.43.4.422) |
| Dos Santos, Peffers and Mauer (1993) | The Impact of IT Investment Announcements on the Market Value of the Firm | 分析 1981 至 1988 年 97 个 IT 投资公告，整体和行业子样本均未发现显著超额收益。 | 可用于引出 IT 投资公告文献的早期混合证据，说明技术公告并非自动产生正向估值。 | DOI [10.1287/isre.4.1.1](https://doi.org/10.1287/isre.4.1.1) |
| Im, Dow and Grover (2001) | A Reexamination of IT Investment and the Market Value of the Firm | 重新检验 IT 投资公告与企业市场价值，强调样本时期、行业和投资特征会影响市场反应。 | 支撑本文在 LLM 发布研究中引入企业生态位置，而不是把所有 AI 企业视为同质。 | DOI [10.1287/isre.12.1.103.9718](https://doi.org/10.1287/isre.12.1.103.9718) |
| Dehning, Richardson and Zmud (2003) | The Value Relevance of Announcements of Transformational IT Investments | 发现转型性 IT 投资公告带来正向异常收益，IT 战略角色能解释市场反应差异。 | 可用于论证技术事件价值取决于其是否改变企业竞争位置和业务流程。 | DOI [10.2307/30036551](https://doi.org/10.2307/30036551) |
| Hayes, Hunton and Reck (2001) | Market Reaction to ERP Implementation Announcements | ERP 实施公告通常引发正向市场反应，反应大小与企业状况和供应商声誉相关。 | 说明企业采用基础性技术系统的公告会被定价，但仍需结合组织能力和实施风险解释。 | DOI [10.2308/jis.2001.15.1.3](https://doi.org/10.2308/jis.2001.15.1.3) |
| Ranganathan and Brown (2006) | ERP Investments and the Market Value of Firms | ERP 投资的市场价值取决于功能范围、物理范围和供应商等项目变量。 | 可类比 LLM 发布中模型能力、开闭源和生态位置都会调节市场反应。 | DOI [10.1287/isre.1060.0084](https://doi.org/10.1287/isre.1060.0084) |
| Bayus, Erickson and Jacobson (2003) | The Financial Rewards of New Product Introductions in the Personal Computer Industry | 在个人电脑行业中，新产品引入影响利润率和企业规模增长，但不一定提高利润率持续性。 | 这是科技硬件产品发布的代表性研究，可用于对比本文的 LLM 软件模型发布和硬件上游受益机制。 | DOI [10.1287/mnsc.49.2.197.12741](https://doi.org/10.1287/mnsc.49.2.197.12741) |
| Sorescu, Shankar and Kushwaha (2007) | New Product Preannouncements and Shareholder Value | 软件和硬件新产品预告在长期上有正向股东价值效应，但兑现承诺很重要。 | 可用于说明技术发布既是能力信号，也是承诺信号。LLM 发布与预告不同，通常更接近已实现能力披露。 | DOI [10.1509/jmkr.44.3.468](https://doi.org/10.1509/jmkr.44.3.468) |
| Sood and Tellis (2009) | Do Innovations Really Pay Off? Total Stock Market Returns to Innovation | 基于 5,481 个创新事件，发现完整创新项目的市场回报远高于单一事件，开发阶段活动回报高于商业化阶段。 | 说明单次发布只捕捉技术创新项目价值的一部分。本文用 60 次 LLM 发布构建重复冲击，可以缓解单事件局限。 | DOI [10.1287/mksc.1080.0407](https://doi.org/10.1287/mksc.1080.0407) |
| Srinivasan, Pauwels, Silva-Risso and Hanssens (2009) | Product Innovations, Advertising, and Stock Returns | 在汽车行业中，产品创新和配套营销投资通过改善未来现金流预期影响股票收益。 | 可用于说明产品发布效应不仅来自技术本身，也来自互补投入和商业化能力。 | DOI [10.1509/jmkg.73.1.024](https://doi.org/10.1509/jmkg.73.1.024) |
| Warren and Sorescu (2017) | Interpreting the Stock Returns to New Product Announcements | 用 4,865 个美国上市公司新产品公告证明，公告日反应会受公司过去创新历史、竞争者创新和媒体情绪影响。 | 对本文很重要。LLM 发布是重复发生的技术事件，公告日 CAR 既反映新信息，也反映发布前市场已形成的预期。 | DOI [10.1509/jmr.14.0119](https://doi.org/10.1509/jmr.14.0119) |
| Boyd, Kannan and Slotegraaf (2019) | Branded Apps and Their Impact on Firm Value | 移动 App 发布能够提高企业价值，且 App 设计特征会调节价值创造。 | 代表数字产品发布研究，可说明近年产品发布从实体硬件扩展到软件和平台入口。 | DOI [10.1177/0022243718820588](https://doi.org/10.1177/0022243718820588) |
| Niederreiter and Riccaboni (2022) | Product innovation announcements in biopharmaceuticals | 以生物医药产品为样本，发现市场反应受成功概率和产品在企业组合中的重要性共同驱动。 | 可用于说明创新公告的估值取决于产品相对重要性和不确定性。本文中的模型能力、开闭源和生态位置可被视为类似的条件变量。 | DOI [10.1080/13662716.2021.1967729](https://doi.org/10.1080/13662716.2021.1967729) |

## 四、技术联盟、专利和创新价值测度

| 文献 | 题名或主题 | 核心发现 | 可用于本文的写作连接 | 来源 |
|---|---|---|---|---|
| Koh and Venkatraman (1991) | Joint Venture Formations and Stock Market Reactions in IT | 考察信息技术行业合资形成公告，发现合资策略会影响母公司市场价值。 | 可用于说明技术生态中的合作和互补关系本身会产生资本市场价值。 | DOI [10.5465/256393](https://doi.org/10.5465/256393) |
| Chan, Kensinger, Keown and Martin (1997) | Do Strategic Alliances Create Value? | 战略联盟整体创造正向财富效应，且不存在简单财富转移。 | 可作为技术联盟市场反应的金融学经典文献，帮助本文引入生态合作和互补品视角。 | DOI [10.1016/S0304-405X(97)00029-9](https://doi.org/10.1016/S0304-405X(97)00029-9) |
| Park and Kim (1997) | Market valuation of joint ventures | 合资企业特征会影响财富增益，市场对合作项目的价值判断并不均一。 | 可用于论证 LLM 发布影响取决于企业与发布方的具体关系，而不是一般 AI 标签。 | DOI [10.1016/S0883-9026(96)00036-5](https://doi.org/10.1016/S0883-9026(96)00036-5) |
| Das, Sen and Sengupta (1998) | Impact of Strategic Alliances on Firm Valuation | 技术联盟公告的异常收益高于营销联盟，表明技术合作的知识资本价值更强。 | 可用于连接本文的上游硬件、云平台和模型发布方之间的互补关系。 | DOI [10.5465/256895](https://doi.org/10.5465/256895) |
| Griliches (1981) | Market Value, R&D, and Patents | 将企业市场价值与 R&D、专利联系起来，奠定知识资本价值测度的早期框架。 | 可用于说明技术创新既可以通过公告日反应度量，也可以通过知识资产存量反映。 | URL [EconPapers](https://econpapers.repec.org/RePEc%3Aeee%3Aecolet%3Av%3A7%3Ay%3A1981%3Ai%3A2%3Ap%3A183-187) |
| Austin (1993) | An Event-Study Approach to Measuring Innovative Output | 在生物技术行业中，用事件研究法度量创新产出，展示专利或研发里程碑具有市场价值。 | 可作为“用市场反应度量创新输出”的直接先例。 | URL [IDEAS/RePEc](https://ideas.repec.org/a/aea/aecrev/v83y1993i2p253-58.html) |
| Hall, Jaffe and Trajtenberg (2005) | Market Value and Patent Citations | 发现引用加权专利与 Tobin's Q 等市场价值指标相关，专利引用包含创新质量信息。 | 可用于说明资本市场会识别技术资产质量，而不只是技术资产数量。 | URL [IDEAS/RePEc](https://ideas.repec.org/a/rje/randje/v36y20051p16-38.html) |
| Kogan, Papanikolaou, Seru and Stoffman (2017) | Technological Innovation, Resource Allocation, and Growth | 将 1926 至 2010 年美国专利数据与专利新闻附近的股价反应结合，构造专利层面的私人经济价值。 | 与本文非常贴近。它用股价反应估计创新价值，本文则用 LLM 发布冲击估计 AI 生态位置的再定价。 | DOI [10.1093/qje/qjw040](https://doi.org/10.1093/qje/qjw040) |

## 五、2020 年以后数字化、平台和 AI 公告的延展

严格意义上的“科技产品发布”事件研究在 2020 年后并没有形成一个集中而成熟的独立文献群。更常见的做法是围绕数字化项目、区块链、AI 投资、ChatGPT 或生成式 AI 公告展开。这些研究对本文有两层价值。一是证明新兴技术公告仍然适合用事件研究估值。二是显示市场反应高度依赖项目真实性、企业能力、技术用途和供应链关系，这与本文的生态位置异质性高度契合。

| 文献 | 题名或主题 | 核心发现 | 可用于本文的写作连接 | 来源 |
|---|---|---|---|---|
| Cahill, Baur, Liu and Yang (2020) | I am a blockchain too | 基于 713 个全球区块链相关公告，公告日平均异常收益约 5%，美国企业、小企业和 2017 至 2018 年公告反应更强，且与 Bitcoin 表现相关。 | 可用于说明新兴技术公告中存在“技术叙事”和“投机热度”，市场反应可能混合真实价值与概念炒作。 | DOI [10.1016/j.jbankfin.2020.105740](https://doi.org/10.1016/j.jbankfin.2020.105740) |
| Klöckner, Schmidt and Wagner (2022) | When Blockchain Creates Shareholder Value | 基于 175 个国际企业区块链项目公告，公告日平均异常收益约 0.30%，用例、项目和企业特征会影响反应。 | 可用于说明数字技术公告的市场价值不均一，必须区分项目属性和企业条件。 | DOI [10.1111/poms.13609](https://doi.org/10.1111/poms.13609) |
| Lui, Lee and Ngai (2022) | Impact of Artificial Intelligence Investment on Firm Value | 基于 119 个 AI 投资公告，发现公告日股价平均下降 1.77%，非制造业、IT 能力弱和信用评级低的企业反应更负面。 | 可用于反驳“AI 公告必然利好”的朴素观点，支撑本文关于 AI 产业链内部方向相反反应的设定。 | DOI [10.1007/s10479-020-03862-8](https://doi.org/10.1007/s10479-020-03862-8) |
| Rogalski and Schiereck (2024) | When is Blockchain Worth It? | 发现区块链公告在联盟或合作、科技公司、后续公告等情形下更可能产生正向市场反应，且不显著改变系统性风险。 | 可用于说明技术公告的可置信度和生态合作关系影响市场定价。 | DOI [10.1007/s12525-024-00718-y](https://doi.org/10.1007/s12525-024-00718-y) |
| Babina, Fedyk, He and Hodson (2024) | Artificial Intelligence, Firm Growth, and Product Innovation | 用员工简历和职位信息测度企业 AI 投资，发现 AI 投资企业销售、就业和市场估值增长更快，增长主要来自产品创新。 | 可作为 AI 与企业价值的代表性金融文献，但它关注企业 AI 投资存量而非 LLM 发布事件。本文可强调二者的测量维度不同。 | DOI [10.1016/j.jfineco.2023.103745](https://doi.org/10.1016/j.jfineco.2023.103745) |
| Eisfeldt, Schubert and Zhang (2023, revised 2026) | Generative AI and Firm Values | 构造企业生成式 AI 劳动力暴露度，发现 ChatGPT 发布后高暴露企业相对低暴露企业获得显著超额收益。 | 是本文 AI 资本市场效应的重要近邻。本文可指出该文关注 AI 暴露度，而本文区分 AI 生态位置和开源闭源属性。 | URL [NBER Working Paper 31222](https://www.nber.org/papers/w31222) |
| Qian, Peng and Li (2025) | The Impact of Generative AI Announcements on Suppliers | 研究企业 GenAI 倡议对供应商股价的影响，发现公告日供应商平均获得约 0.27% 正向异常收益，产品创新类 GenAI 公告的外溢更强。 | 对本文的供应链外溢很有价值。它关注企业 GenAI 倡议对供应商的正向外溢，本文进一步区分模型发布对上游和下游的相反影响。 | DOI [10.1177/10591478251398333](https://doi.org/10.1177/10591478251398333) |
| Chou, Chen and He (2026) | OpenAI's Technological Announcements | 研究 OpenAI 技术公告对台湾 AI 概念股及匹配公司的反应，发现 AI 概念股持续跑赢匹配公司，产品原创性和市场认知度影响反应。 | 这是非常接近 LLM 公告的近期研究，但样本聚焦台湾 AI 概念股。本文可突出美股 AI 产业链和生态位置编码的差异。 | DOI [10.1016/j.ribaf.2025.103252](https://doi.org/10.1016/j.ribaf.2025.103252) |

## 六、可写入 `long_new.tex` 的文献综述连接

可在“技术冲击与资产定价”小节中写成如下逻辑。

一方面，事件研究法为识别技术冲击的资本市场影响提供了成熟工具。Fama et al. (1969) 以后，Brown and Warner (1980, 1985)、MacKinlay (1997)、Kothari and Warner (2007) 和 Corrado (2011) 形成了短窗口异常收益测度的标准框架。该框架适合用来研究日期明确、信息公开且预期会改变未来现金流的技术事件。大语言模型发布正具备这些特征，尤其是 frontier 模型发布往往在发布日集中释放能力、成本、开源许可和商业化路径信息。

另一方面，围绕新产品、IT 投资、R&D、ERP、技术联盟和专利的实证研究表明，技术公告的市场反应并不均匀。Chaney et al. (1991)、Bayus et al. (2003)、Sood and Tellis (2009) 和 Warren and Sorescu (2017) 显示，新产品公告具有估值含义，但市场反应受到行业、公司规模、预期和创新历史影响。Dos Santos et al. (1993)、Im et al. (2001)、Dehning et al. (2003) 和 Ranganathan and Brown (2006) 进一步表明，IT 投资公告只有在具有转型性、组织整合价值或战略属性时才更可能获得正向定价。技术联盟和专利文献也显示，技术信息会通过互补、竞争和知识资本渠道进入企业价值。由此可见，技术发布不是资本市场中的单一利好信号，而是一个需要结合企业位置、技术用途和商业关系解释的多维信息冲击。

本文可以在上述文献基础上突出三点边际贡献。第一，已有产品发布和 IT 投资公告研究多以公告企业本身为中心，较少在同一事件框架下同时考察上游、下游和竞争者。第二，2020 年以后的区块链和 AI 公告研究已经注意到新兴技术公告的异质性，但多依赖概念股、AI 暴露度或企业自我披露，尚未形成针对 LLM 生态位置的细分测度。第三，本文把 LLM 发布作为重复发生的技术冲击，并将企业按上游硬件、云服务、下游集成、下游部署、下游赋能和竞争者等生态位置编码，可以直接检验同一技术进步是否沿产业链产生价值再分配，而不是仅检验 AI 板块的平均重估。

## 七、建议写入 `long_new.tex` 的参考文献条目草稿

以下给出 `thebibliography` 形式草稿。若后续主文稿改用 BibTeX，可按这些信息转为 `.bib`。

```latex
\begin{thebibliography}{99}

\bibitem{Fama1969}
Fama, E. F., Fisher, L., Jensen, M. C., and Roll, R. (1969).
The adjustment of stock prices to new information.
\textit{International Economic Review}, 10(1), 1--21.
https://doi.org/10.2307/2525569

\bibitem{BrownWarner1985}
Brown, S. J., and Warner, J. B. (1985).
Using daily stock returns: The case of event studies.
\textit{Journal of Financial Economics}, 14(1), 3--31.
https://doi.org/10.1016/0304-405X(85)90042-X

\bibitem{MacKinlay1997}
MacKinlay, A. C. (1997).
Event studies in economics and finance.
\textit{Journal of Economic Literature}, 35(1), 13--39.

\bibitem{KothariWarner2007}
Kothari, S. P., and Warner, J. B. (2007).
Econometrics of event studies.
In \textit{Handbook of Corporate Finance: Empirical Corporate Finance}, Vol. 1, 3--36.
Elsevier.

\bibitem{Corrado2011}
Corrado, C. J. (2011).
Event studies: A methodology review.
\textit{Accounting \& Finance}, 51(1), 207--234.
https://doi.org/10.1111/j.1467-629X.2010.00375.x

\bibitem{DosSantos1993}
Dos Santos, B. L., Peffers, K., and Mauer, D. C. (1993).
The impact of information technology investment announcements on the market value of the firm.
\textit{Information Systems Research}, 4(1), 1--23.
https://doi.org/10.1287/isre.4.1.1

\bibitem{Chaney1991}
Chaney, P. K., Devinney, T. M., and Winer, R. S. (1991).
The impact of new product introductions on the market value of firms.
\textit{The Journal of Business}, 64(4), 573--610.
https://doi.org/10.1086/296552

\bibitem{SoodTellis2009}
Sood, A., and Tellis, G. J. (2009).
Do innovations really pay off? Total stock market returns to innovation.
\textit{Marketing Science}, 28(3), 442--456.
https://doi.org/10.1287/mksc.1080.0407

\bibitem{Kogan2017}
Kogan, L., Papanikolaou, D., Seru, A., and Stoffman, N. (2017).
Technological innovation, resource allocation, and growth.
\textit{The Quarterly Journal of Economics}, 132(2), 665--712.
https://doi.org/10.1093/qje/qjw040

\bibitem{Eisfeldt2023}
Eisfeldt, A. L., Schubert, G., and Zhang, M. B. (2023).
Generative AI and firm values.
NBER Working Paper No. 31222.
https://www.nber.org/papers/w31222

\end{thebibliography}
```

## 八、后续整合时的取舍建议

正文不宜堆叠过多单篇产品发布文献。建议正文保留方法经典 3 至 5 篇，技术产品和 IT 公告 4 至 6 篇，专利或创新价值 1 至 2 篇，2020 年后 AI 或数字技术公告 2 至 3 篇。较细的文献，如 ERP、App、区块链和生物医药产品，可以放入脚注或作为“相关研究显示”一句带过。

如果主文稿篇幅有限，最值得保留的引用组合为 MacKinlay (1997)、Brown and Warner (1985)、Corrado (2011)、Dos Santos et al. (1993)、Chaney et al. (1991)、Sood and Tellis (2009)、Kogan et al. (2017)、Lui et al. (2022)、Babina et al. (2024) 和 Eisfeldt et al. (2023)。这个组合能同时覆盖方法、产品发布、IT 投资、创新价值和 AI 金融市场。

