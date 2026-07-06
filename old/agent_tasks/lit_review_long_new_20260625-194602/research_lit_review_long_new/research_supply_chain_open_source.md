# 任务 C 调研结果

调研对象为 `Tex/long_new.tex` 第二节中“产业链外溢效应”和“开源与技术扩散”两部分。本文的核心机制可以写成三条线索。第一，重大技术事件不是只影响发布者，也会通过客户、供应商、竞争者和互补方传导到其他上市公司。第二，同一技术信号可能同时包含互补品需求扩张和替代品利润挤压。第三，开源与闭源改变价值捕获方式，进而调节上游硬件、平台所有者和下游应用商之间的收益分配。

下表按文献用途整理。每条均给出作者年份、题名或主题、核心发现、与本文上游利好、下游替代、开源调节机制的连接，以及 DOI 或来源 URL。

## 一、供应链外溢、客户供应商关系与竞争性信息转移

| 文献 | 题名或主题 | 核心发现 | 与本文机制的连接 | 来源 |
|---|---|---|---|---|
| Foster 1981 | *Intra-Industry Information Transfers Associated with Earnings Releases* | 公司盈余公告会向同业公司传递共同需求、成本或竞争信息，市场反应不只局限于公告公司。 | 支持把 LLM 发布看作行业信息事件。若模型能力提升代表行业需求扩张，互补方可获得正向信息；若代表竞争压力，替代方会受损。 | https://doi.org/10.1016/0165-4101(81)90003-3 |
| Lang and Stulz 1992 | *Contagion and Competitive Intra-Industry Effects of Bankruptcy Announcements* | 破产公告会同时产生传染效应和竞争效应。同业公司可能随负面信号下跌，也可能因市场份额再分配上涨。 | 给本文“同一事件产生方向相反反应”提供金融学先例。模型发布可同时利好算力供应商、压低下游部署商。 | https://doi.org/10.1016/0304-405X(92)90024-R |
| Fee and Thomas 2004 | *Sources of Gains in Horizontal Mergers* | 横向并购的财富效应会扩散到客户、供应商和竞争者，市场可用上下游股价反应识别并购收益来源。 | 支持在事件研究中同时观察发布者之外的供应商、客户和竞争者。 | https://doi.org/10.1016/j.jfineco.2003.10.002 |
| Shahrur 2005 | *Industry Structure and Horizontal Takeovers* | 横向收购会影响竞争者、供应商和企业客户。财富效应取决于行业结构、买方力量和效率提升。 | 说明产业链外溢方向取决于结构关系，而非事件好坏本身。可用于解释 AI 发布对上游和下游方向不同。 | https://doi.org/10.1016/j.jfineco.2004.01.001 |
| Hertzel, Li, Officer, and Rodgers 2008 | *Inter-Firm Linkages and the Wealth Effects of Financial Distress Along the Supply Chain* | 企业财务困境和破产会沿供应链传导，重要客户或供应商也会出现财富损失。 | 证明客户供应商链接能产生可度量的股价外溢。本文可借此说明 AI 产业链位置具有资产定价含义。 | https://doi.org/10.1016/j.jfineco.2007.01.005 |
| Cohen and Frazzini 2008 | *Economic Links and Predictable Returns* | 投资者不能及时处理客户供应商关系中的信息，客户股票收益可预测供应商后续收益。 | 为“经济链接内的信息扩散存在滞后”提供证据。本文 20 日窗口中渐进学习的解释可引用这篇。 | https://doi.org/10.1111/j.1540-6261.2008.01379.x |
| Menzly and Ozbas 2010 | *Market Segmentation and Cross-Predictability of Returns* | 投资者专业化和市场分割导致相关资产之间存在交叉可预测性。 | 支持 AI 生态内不同位置企业被不同投资者分开定价，模型发布信息可能逐步扩散。 | https://doi.org/10.1111/j.1540-6261.2010.01578.x |
| Pandit, Wasley, and Zach 2011 | *Information Externalities Along the Supply Chain* | 客户盈余公告会影响供应商股价，供应链关系强度会放大这种信息外部性。 | 可直接支撑“客户或下游需求信号影响上游供应商估值”的逻辑。闭源模型发布向 GPU 供应商传递需求确认信号。 | https://doi.org/10.1111/j.1911-3846.2011.01092.x |
| Acemoglu, Carvalho, Ozdaglar, and Tahbaz-Salehi 2012 | *The Network Origins of Aggregate Fluctuations* | 投入产出网络可把微观冲击放大为宏观波动，网络结构决定传播强度。 | 将本文的 AI 生态位置编码放在生产网络文献中。模型发布是微观技术冲击，网络位置决定估值反应。 | https://doi.org/10.3982/ECTA9623 |
| Bloom, Schankerman, and Van Reenen 2013 | *Identifying Technology Spillovers and Product Market Rivalry* | 企业创新同时带来技术溢出和产品市场竞争。技术接近产生正向知识溢出，产品市场接近产生负向竞争效应。 | 非供应链但高度相关。可帮助本文区分“AI 技术进步总体利好”与“能力替代压低下游利润”。 | https://doi.org/10.3982/ECTA9466 |
| Barrot and Sauvagnat 2016 | *Input Specificity and the Propagation of Idiosyncratic Shocks in Production Networks* | 受灾供应商会给客户带来产出损失和市场价值损失，投入越专用，冲击传播越强。 | 支持“算力作为关键专用投入”的经济含义。高端 GPU 和云算力越难替代，上游需求信号越强。 | https://doi.org/10.1093/qje/qjw018 |
| Herskovic 2018 | *Networks in Production: Asset Pricing Implications* | 投入产出网络的集中度和稀疏度会成为系统性风险来源，并进入均衡资产价格。 | 说明生产网络位置不只是叙事变量，而是风险和收益的定价维度。 | https://doi.org/10.1111/jofi.12684 |
| Gofman, Segal, and Wu 2020 | *Production Networks and Stock Returns: The Role of Vertical Creative Destruction* | 上游生产率冲击会降低下游既有资产价值。越远离终端消费者，企业风险溢价和生产率暴露越高。 | 这是本文下游替代机制最贴近的金融学文献。更强模型可看作上游能力冲击，它提高模型层生产率，同时侵蚀下游部署商既有资产。 | https://doi.org/10.1093/rfs/hhaa034 |
| Carvalho, Nirei, Saito, and Tahbaz-Salehi 2021 | *Supply Chain Disruptions: Evidence from the Great East Japan Earthquake* | 2011 年日本地震冲击沿直接和间接供应链上下游传播，并放大宏观影响。 | 2020 年后的网络传播证据。可用于说明外溢并不止于一阶客户供应商，也会沿生态网络扩散。 | https://doi.org/10.1093/qje/qjaa044 |
| Ding, Levine, Lin, and Xie 2021 | *Corporate Immunity to the COVID-19 Pandemic* | 疫情期间，供应链暴露、财务状况和公司治理解释了公司股票收益差异。 | 2020 年后事件冲击和供应链暴露的资产价格证据。可作为 LLM 发布事件研究的近年参照。 | https://doi.org/10.1016/j.jfineco.2021.03.005 |

## 二、互补品、替代品、平台生态与平台所有者进入

| 文献 | 题名或主题 | 核心发现 | 与本文机制的连接 | 来源 |
|---|---|---|---|---|
| Katz and Shapiro 1985 | *Network Externalities, Competition, and Compatibility* | 采用者数量和兼容性会改变产品价值，网络效应可使平台和互补品相互强化。 | 为“模型能力提升带动算力、工具链和生态互补品”提供经典理论基础。 | https://www.jstor.org/stable/1814809 |
| Bresnahan and Trajtenberg 1995 | *General Purpose Technologies* | 通用目的技术通过普遍适用、持续改进和创新互补性推动增长。 | LLM 可被写成新一代通用目的技术。其发布同时改变上游投入需求和下游应用边界。 | https://doi.org/10.1016/0304-4076(94)01598-T |
| Rochet and Tirole 2003 | *Platform Competition in Two-Sided Markets* | 平台价值来自多边用户之间的相互依赖，平台定价和治理要同时考虑各边参与。 | 模型发布方可被理解为 AI 平台。闭源 API 平台一边连接开发者和企业用户，另一边连接算力供应商。 | https://doi.org/10.1162/154247603322493212 |
| Parker and Van Alstyne 2005 | *Two-Sided Network Effects* | 信息产品可通过补贴一边、扩大另一边参与来创造跨边网络效应。 | 帮助解释 API、开源权重和低价模型的策略。免费或低价访问可扩大开发者边，但也可能改变价值捕获方向。 | https://doi.org/10.1287/mnsc.1050.0400 |
| Armstrong 2006 | *Competition in Two-Sided Markets* | 多边平台竞争下，价格结构和接入规则决定各边福利和竞争均衡。 | 可支撑“开源与闭源不是单纯技术差异，而是平台治理和接入规则差异”。 | https://doi.org/10.1111/j.1756-2171.2006.tb00037.x |
| Gawer and Cusumano 2002 | *Platform Leadership* | 平台领导者通过架构控制、接口开放、互补品激励和内部组织设计来驱动生态创新。 | 候选文献版本核实为 2002 年 Harvard Business School Press 图书。可用于写平台领导者如何扶持或压制互补方。 | https://dl.acm.org/doi/10.5555/560754 |
| Gawer and Henderson 2007 | *Platform Owner Entry and Innovation in Complementary Markets* | Intel 会进入部分互补市场并补贴其他互补市场，同时用组织承诺缓解互补者担忧。 | 对应本文“下游部署商被基础模型厂商替代”。平台所有者进入互补品空间会压缩下游利润，但并非所有互补市场都会被进入。 | https://doi.org/10.1111/j.1530-9134.2007.00130.x |
| Adner and Kapoor 2010 | *Value Creation in Innovation Ecosystems* | 焦点企业表现取决于上游组件和下游互补方的创新瓶颈，生态结构决定价值创造速度。 | 适合解释上游硬件、云服务和下游应用为何对同一模型发布有不同反应。 | https://doi.org/10.1002/smj.821 |
| Boudreau 2010 | *Open Platform Strategies and Innovation* | 开放平台可分为开放互补品市场和放弃平台控制，两种开放方式对创新有不同影响。 | 可用于区分“开放权重”与“完全开源”。开源模型降低接入门槛，但不一定放弃平台和商业控制。 | https://doi.org/10.1287/mnsc.1100.1215 |
| Eisenmann, Parker, and Van Alstyne 2011 | *Platform Envelopment* | 平台可通过捆绑进入相邻平台市场，利用共同用户关系吞并其他功能。 | 对本文下游部署商受损很关键。更强基础模型可能把文档生成、客服、数据分析等应用功能包进模型层。 | https://doi.org/10.1002/smj.935 |
| Boudreau 2012 | *Let a Thousand Flowers Bloom?* | 大量应用开发者进入平台会增加软件种类，创新模式取决于开发者多样性和专门化。 | 支持开源模型可能促进下游应用创新，但其收益可能分散在大量开发者之间，不一定利好已有上市部署商。 | https://doi.org/10.1287/orsc.1110.0678 |
| Gawer 2014 | *Bridging Differing Perspectives on Technological Platforms* | 整合经济学、工程设计和组织视角，把平台视为可治理的产业架构。 | 可作为平台生态概念的综述性文献，帮助定义 AI 模型层、算力层和应用层之间的架构关系。 | https://doi.org/10.1016/j.respol.2014.03.006 |
| Zhu and Liu 2018 | *Competing with Complementors* | Amazon 更可能进入成功的第三方卖家产品空间，并考虑卖家平台专用投资。 | 直接支持“基础模型厂商可能进入下游成功应用空间”。下游部署商面临来自平台所有者的替代威胁。 | https://doi.org/10.1002/smj.2932 |
| Jacobides, Cennamo, and Gawer 2018 | *Towards a Theory of Ecosystems* | 生态系统由互补性、非完全层级治理和成员间相互依赖构成。 | 可给本文“AI 生态位置”提供概念基础，避免只用传统行业分类。 | https://doi.org/10.1002/smj.2904 |
| Wen and Zhu 2019 | *Threat of Platform-Owner Entry and Complementor Responses* | Google 进入威胁会使 Android 应用开发者降低受威胁方向的创新并提高价格。 | 说明平台所有者进入不必真实发生，威胁本身就能改变互补方行为和估值。LLM 发布提高了市场对下游被进入的预期。 | https://doi.org/10.1002/smj.3031 |
| Rietveld, Ploog, and Nieborg 2020 | *Coevolution of Platform Dominance and Governance Strategies* | 平台越占优势，治理越从普遍支持互补者转向选择性扶持和终端用户导向，个体互补者需求更集中。 | 2020 年后的平台生态证据。可解释领先模型发布方扩张后，价值可能从众多下游互补者转向少数平台核心企业。 | https://doi.org/10.5465/amd.2019.0064 |
| Gawer 2020/2021 | *Digital Platforms’ Boundaries* | 数字平台边界由企业范围、平台边、数字接口共同决定。 | 可支撑“闭源 API 与开放权重的边界选择不同”。边界变化决定谁能获得模型能力和算力租金。 | https://doi.org/10.1016/j.lrp.2020.102045 |
| Cennamo 2021 | *Competing in Digital Markets* | 数字市场竞争不只是价格竞争，还包括平台市场类型、跨边网络效应、数据和生态治理。 | 适合写 2020 年后数字平台竞争的新文献。本文可把模型发布解释为平台竞争和生态治理事件。 | https://doi.org/10.5465/amp.2016.0048 |
| Rietveld and Schilling 2021 | *Platform Competition: A Systematic and Interdisciplinary Review* | 系统梳理 1985 至 2019 年平台竞争文献，归纳平台进入、治理、互补者策略和多边网络效应。 | 可作为平台文献综述的总括引用。 | https://doi.org/10.1177/0149206320969791 |
| Kang and Suarez 2022 | *Platform Owner Entry Into Complementor Spaces Under Different Governance Modes* | 平台所有者进入互补者空间的竞争压力取决于治理模式和进入方式。 | 2020 年后的平台进入研究。适合支撑“下游受损程度取决于闭源、开源和治理边界”。 | https://doi.org/10.1177/01492063221094759 |
| Shi, Aaltonen, Henfridsson, and Gopal 2023 | *Comparing Platform Owners’ Early and Late Entry into Complementary Markets* | Amazon Alexa 的早期进入更像促进互补市场价值创造，晚期进入更像捕获已被互补者创造的价值。 | 可细化本文下游替代机制。基础模型早期发布可能扩张市场，成熟模型发布更可能挤压已有应用商。 | https://doi.org/10.25300/MISQ/2023/17413 |

## 三、开源经济学、开源平台与开放模型

| 文献 | 题名或主题 | 核心发现 | 与本文机制的连接 | 来源 |
|---|---|---|---|---|
| Johnson 2002 | *Open Source Software: Private Provision of a Public Good* | 用户开发者在私人收益足够时会自愿生产公共品性质的软件；开发者基础规模影响开源项目能否形成。 | 为“开源降低获取门槛、扩大开发者基础”提供理论基础。开源模型可扩大下游创新人数，但收益分散。 | https://doi.org/10.1111/j.1430-9134.2002.00637.x |
| Lerner and Tirole 2002 | *Some Simple Economics of Open Source* | 开源参与者的动机可由声誉、职业关切和互补商业模式解释。 | 经典开源经济学引用。可说明企业参与开源不是放弃利润，而是通过互补品、服务和声誉获益。 | https://doi.org/10.1111/1467-6451.00174 |
| Lakhani and von Hippel 2003 | *How Open Source Software Works* | Apache 用户社区可通过用户对用户支持来提供服务，贡献动机包括自身需求、乐趣和声誉。 | 支持开源 AI 的社区维护和生态扩散逻辑。开源模型改写价值创造边界，但未必提高上市部署商利润。 | https://doi.org/10.1016/S0048-7333(02)00095-1 |
| von Hippel and von Krogh 2003 | *Open Source Software and the Private-Collective Innovation Model* | 开源结合私人投资和集体行动，两者并非互斥。 | 可用于解释开源模型兼具公共知识和私人商业策略。 | https://doi.org/10.1287/orsc.14.2.209.14992 |
| Lerner and Tirole 2005 | *The Economics of Technology Sharing: Open Source and Beyond* | 综述开源运动的经济学解释，并讨论技术共享超出软件领域的适用性。 | 候选文献版本核实为 JEP 2005 年第 19 卷第 2 期，DOI 为 10.1257/0895330054048678。可作为开源技术共享综述引用。 | https://doi.org/10.1257/0895330054048678 |
| Bessen 2006 或 working version | *Open Source Software: Free Provision of Complex Public Goods* | 复杂软件中的合同不完备和所有权问题使开源可能成为有效的公共品供给方式，并可与商业软件互补。 | 用户候选中的 Bessen 需要谨慎标注版本。检索到的稳定来源为 SSRN/BU 记录，常被引用为 working paper。本文可用其支持“开源与专有供给是互补而非简单替代”。 | https://doi.org/10.2139/ssrn.588763 |
| Casadesus-Masanell and Ghemawat 2006 | *Dynamic Mixed Duopoly: A Model Motivated by Linux vs. Windows* | 零价格或低边际成本的开源竞争者会通过动态学习和网络效应改变专有软件定价和投资。 | 可解释开源模型对闭源 API 的价格和算力租金压力。开源不一定直接替代闭源，但会约束闭源价值捕获。 | https://doi.org/10.1287/mnsc.1060.0548 |
| Economides and Katsamakas 2006 | *Two-Sided Competition of Proprietary vs. Open Source Technology Platforms* | 专有平台和开源平台在价格、应用数量、利润和社会福利上存在不同均衡；开源平台可能提高福利但降低行业利润。 | 与本文假设 3 高度契合。开源模型可提高下游可得性和总福利，同时削弱上游硬件或平台所有者的独占租金。 | https://doi.org/10.1287/mnsc.1060.0549 |
| West 2003 | *How Open Is Open Enough?* | 企业可在专有与开放平台策略之间混合选择，开放程度取决于互补品创新和控制权取舍。 | 对开放权重模型特别有用。许多“开源 AI”并非完全开放，而是保留许可证、数据和算力控制。 | https://doi.org/10.1016/S0048-7333(03)00052-0 |
| Henkel 2006 | *Selective Revealing in Open Innovation Processes* | 企业会选择性公开部分知识，以获得外部创新和标准扩散，同时保留关键专有资产。 | 可解释开源模型发布中的“开放权重但保留训练数据、训练代码或商用限制”。 | https://doi.org/10.1016/j.respol.2005.09.010 |
| Solaiman 2023 | *The Gradient of Generative AI Release* | 生成式 AI 的发布方式可落在从完全闭源到完全开放的连续谱上。发布策略在集中权力和风险控制之间取舍。 | 这是开闭源变量的现代 AI 版本。本文可借此把 `Open_i` 写成发布治理差异，而非二元技术标签。 | https://doi.org/10.1145/3593013.3593981 |
| Widder, West, and Whittaker 2023 | *Open (For Business)* | “开放”和“开源”在 AI 中常被混用，开放叙事也可能服务于大型科技公司的市场权力。 | 可帮助论文避免把开源简单写成民主化。开源模型可能扩散能力，同时继续巩固数据、算力和平台控制。 | https://doi.org/10.2139/ssrn.4543807 |
| Kapoor et al. 2024 | *On the Societal Impact of Open Foundation Models* | 开放权重基础模型带来定制化、竞争、透明度和权力分散等收益，也带来监测困难和不可撤回风险。 | 2020 年后开放模型核心文献。可用于解释开源模型为何改变价值分配，同时不必假设下游替代威胁消失。 | https://arxiv.org/abs/2403.07918 |
| Nagle and Yue 2025 | *The Latent Role of Open Models in the AI Economy* | 基于模型使用、价格和性能数据，开放模型在部分场景中以较低价格提供接近闭源模型的性能，但采用率仍低。 | 最新开源 AI 经济证据。可补充说明开源模型通过价格和性能压低闭源模型租金，也可能降低高端推理算力边际价值。 | https://doi.org/10.2139/ssrn.5767103 |

## 四、可写入 `long_new.tex` 的综述组织建议

第一段可从金融学事件研究和信息转移切入。Foster 1981 和 Lang and Stulz 1992 说明公告会影响同业企业，且方向取决于传染效应还是竞争效应。Fee and Thomas 2004、Shahrur 2005、Hertzel et al. 2008、Cohen and Frazzini 2008、Pandit et al. 2011 进一步把这种外溢扩展到客户供应商关系。本文的边际贡献可以写为，已有研究证明外溢存在，但多数研究围绕盈余、并购、破产和自然灾害等传统事件，较少考察 LLM 发布这类技术平台事件如何在 AI 生态中同时产生上游需求确认和下游替代威胁。

第二段可用生产网络和互补品、替代品解释方向。Acemoglu et al. 2012、Barrot and Sauvagnat 2016、Herskovic 2018、Gofman et al. 2020、Carvalho et al. 2021 说明网络位置影响冲击传播、产出损失和资产价格。尤其是 Gofman et al. 2020 的“vertical creative destruction”与本文下游部署商受损高度贴合。可以写成，更强的基础模型提高模型层生产率，对 GPU、云服务和工具链形成互补需求，但也会削弱依赖旧能力边界的应用层企业资产价值。

第三段可引入平台生态。Rochet and Tirole 2003、Parker and Van Alstyne 2005、Gawer and Cusumano 2002、Gawer and Henderson 2007、Adner and Kapoor 2010、Eisenmann et al. 2011 说明平台所有者既依赖互补者，又可能进入互补市场。Zhu and Liu 2018、Wen and Zhu 2019、Kang and Suarez 2022、Shi et al. 2023 提供平台进入压缩互补者空间的近年证据。本文可据此把下游部署商负向反应解释为市场预期基础模型厂商将功能上移或平台捆绑。

第四段可讨论开源调节。Lerner and Tirole 2002、Lerner and Tirole 2005、Johnson 2002、von Hippel and von Krogh 2003、Boudreau 2010、Economides and Katsamakas 2006 说明开源降低接入门槛，扩大互补创新，但也改变租金归属。Solaiman 2023、Widder et al. 2023、Kapoor et al. 2024 和 Nagle and Yue 2025 把这一逻辑延伸到开放基础模型。本文可以写成，闭源模型通过 API 和集中推理巩固算力需求，开源模型则把模型能力扩散到更多开发者和本地部署场景，削弱独占式高端算力租金。因此，开源属性应调节上游硬件效应，而不必显著消除下游替代压力。

## 五、建议写入 `long_new.tex` 的参考文献条目草稿

以下 12 条优先覆盖经典金融外溢、供应链资产价格、平台生态和开源 AI。若正文篇幅有限，可先保留前 10 条，把 Widder et al. 2023 或 Kapoor et al. 2024 放入脚注或补充引用。

1. Foster, G. 1981. Intra-industry information transfers associated with earnings releases. *Journal of Accounting and Economics* 3(3), 201--232. https://doi.org/10.1016/0165-4101(81)90003-3

2. Lang, L. H. P., and R. M. Stulz. 1992. Contagion and competitive intra-industry effects of bankruptcy announcements. *Journal of Financial Economics* 32(1), 45--60. https://doi.org/10.1016/0304-405X(92)90024-R

3. Cohen, L., and A. Frazzini. 2008. Economic links and predictable returns. *Journal of Finance* 63(4), 1977--2011. https://doi.org/10.1111/j.1540-6261.2008.01379.x

4. Barrot, J.-N., and J. Sauvagnat. 2016. Input specificity and the propagation of idiosyncratic shocks in production networks. *Quarterly Journal of Economics* 131(3), 1543--1592. https://doi.org/10.1093/qje/qjw018

5. Gofman, M., G. Segal, and Y. Wu. 2020. Production networks and stock returns: The role of vertical creative destruction. *Review of Financial Studies* 33(12), 5856--5905. https://doi.org/10.1093/rfs/hhaa034

6. Rochet, J.-C., and J. Tirole. 2003. Platform competition in two-sided markets. *Journal of the European Economic Association* 1(4), 990--1029. https://doi.org/10.1162/154247603322493212

7. Parker, G. G., and M. W. Van Alstyne. 2005. Two-sided network effects: A theory of information product design. *Management Science* 51(10), 1494--1504. https://doi.org/10.1287/mnsc.1050.0400

8. Gawer, A., and R. Henderson. 2007. Platform owner entry and innovation in complementary markets: Evidence from Intel. *Journal of Economics & Management Strategy* 16(1), 1--34. https://doi.org/10.1111/j.1530-9134.2007.00130.x

9. Eisenmann, T., G. Parker, and M. W. Van Alstyne. 2011. Platform envelopment. *Strategic Management Journal* 32(12), 1270--1285. https://doi.org/10.1002/smj.935

10. Lerner, J., and J. Tirole. 2002. Some simple economics of open source. *Journal of Industrial Economics* 50(2), 197--234. https://doi.org/10.1111/1467-6451.00174

11. Lerner, J., and J. Tirole. 2005. The economics of technology sharing: Open source and beyond. *Journal of Economic Perspectives* 19(2), 99--120. https://doi.org/10.1257/0895330054048678

12. Solaiman, I. 2023. The gradient of generative AI release: Methods and considerations. *Proceedings of the 2023 ACM Conference on Fairness, Accountability, and Transparency*, 111--122. https://doi.org/10.1145/3593013.3593981

## 六、可选补充引用

如需强化开源 AI 的近年部分，可补充 Kapoor et al. 2024 和 Nagle and Yue 2025。前者适合解释开放权重模型的社会影响和风险收益权衡，后者适合说明开放模型的价格、性能和采用行为。若需要更强的平台进入证据，可补充 Zhu and Liu 2018、Wen and Zhu 2019、Kang and Suarez 2022、Shi et al. 2023。若需要更强生产网络外溢，可补充 Acemoglu et al. 2012、Herskovic 2018、Carvalho et al. 2021。
