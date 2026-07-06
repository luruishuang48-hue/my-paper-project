# Relationship Classification Codebook

**Project:** Impact of LLM Release Behavior on Financial Markets — Evidence from the U.S. Stock Market

**Version:** 1.0 | **Date:** 2026-06-24

**Purpose:** This codebook is the sole authoritative reference for classifying the relationship between each sample company and each LLM release event. All coders must follow this document exactly. No relationship label may be assigned without satisfying the criteria specified here.

---

## 1. Overview

### 1.1 Coding Unit

Each observation is a **(company, event)** pair. There are 86 companies and 60 events, yielding up to 5,160 observations. Each observation receives:

- **Six binary (0/1) relationship indicators** — a single observation may have multiple indicators equal to 1
- **Two binary (0/1) flags** — layered on top of the six indicators
- **A confidence rating** — H (high), M (medium), or L (low) for each indicator marked 1
- **A brief justification** — for each indicator marked 1

### 1.2 Relationship Dimensions

| Code | Label | Short Definition |
|------|-------|-----------------|
| R1 | `upstream_hardware` | Supplies physical hardware or components for AI training/inference |
| R2 | `upstream_cloud` | Operates cloud/data-center infrastructure used for AI workloads |
| R3 | `downstream_integrator` | AI capability is a core product input; directly integrates LLM APIs or foundation models |
| R4 | `downstream_deployer` | Deploys AI as a tool within a traditional (non-AI-native) business |
| R5 | `downstream_enabler` | IT services / consulting / outsourcing firm that helps clients adopt AI |
| R6 | `competitor` | Develops or releases its own LLMs or foundation models competing with the event's model |
| F1 | `is_investor` | Holds an equity stake in the model's releasing entity (flag) |
| F2 | `is_owner` | Is the releasing entity itself or its listed parent (flag) |

### 1.3 Key Principles

1. **Multi-label by design.** A company may hold multiple roles simultaneously (e.g., Microsoft may be `upstream_cloud` + `competitor` + `is_investor` for an OpenAI event). Code each dimension independently.

2. **Conservative default.** If evidence is ambiguous, code 0. It is better to undercount than to overcount — false positives introduce noise into heterogeneity tests.

3. **Evidence-based.** Each indicator = 1 must be supported by at least one verifiable public source (10-K filing, annual report, press release, supply-chain database, or established industry knowledge). "Common knowledge" is acceptable for well-known relationships (e.g., TSMC fabricates chips for NVIDIA) but must be noted.

4. **Event-aware but creator-anchored.** The primary coding unit is effectively **(company, creator)** — a company's structural relationship to a given model creator should be stable across that creator's events. However, coders should flag and document exceptions where the specific event changes the relationship (e.g., a media-generation model release may not implicate a text-only downstream integrator).

---

## 2. Detailed Category Definitions

### R1: `upstream_hardware`

**Definition:** The company designs, manufactures, or supplies physical hardware components that are directly used in the training, inference, or deployment of large AI models. This includes semiconductor chips (GPUs, TPUs, AI accelerators, CPUs for data centers), memory (HBM, DRAM), storage, networking equipment for data centers, and AI-optimized server systems.

**Inclusion criteria (satisfy at least one):**

- (a) The company's products are used in AI training clusters or inference infrastructure (GPUs, AI accelerators, HBM, data-center switches, AI servers).
- (b) The company fabricates or packages chips used in AI hardware (foundry services, advanced packaging).
- (c) The company supplies storage, memory, or networking components specifically marketed for or predominantly consumed by AI/data-center workloads.

**Exclusion criteria:**

- General-purpose consumer electronics manufacturers whose AI exposure is incidental (e.g., a TV maker that includes a minor AI chip).
- Software-only companies, even if they optimize for specific hardware.

**Typical companies and reasoning:**

| Company | Ticker | Reasoning | Confidence |
|---------|--------|-----------|------------|
| NVIDIA | NVDA | Dominant GPU/AI accelerator supplier for all major LLM training | H |
| TSMC | TSM | Sole advanced-node foundry for NVIDIA, AMD, Apple AI chips | H |
| AMD | AMD | Produces MI-series AI accelerators and EPYC data-center CPUs | H |
| Broadcom | AVGO | Custom AI accelerators (Google TPU), data-center networking (Memory fabric, NICs) | H |
| SK Hynix | 000660 KS | Leading HBM supplier (HBM3E) for NVIDIA and AMD AI GPUs | H |
| Micron | MU | HBM and DRAM for AI data centers | H |
| Samsung | 005930 KS | HBM, DRAM, NAND for AI; also foundry services | H |
| Intel | INTC | Data-center CPUs (Xeon), Gaudi AI accelerators, foundry ambitions | H |
| Qualcomm | QCOM | AI inference chips for edge/on-device AI | M |
| Marvell | MRVL | Custom AI accelerators, data-center networking, storage controllers | H |
| NXP | NXPI | Edge AI processors for automotive and IoT — weaker link to LLM training | L |
| Infineon | IFX GR | Power management ICs for data centers — indirect but real | M |
| Super Micro | SMCI | AI-optimized server systems (GPU servers, liquid cooling) | H |
| Ambarella | AMBA | Edge AI vision processors — limited LLM relevance | L |
| Seagate | STX | Data-center storage (HDDs, SSDs) for AI data pipelines | M |
| Transcend | 3443 TT | Memory modules — very indirect AI exposure | L |
| Advantech | 2395 TT | Industrial computing platforms with AI edge capability | L |
| Acer | 2353 TT | PC/hardware maker — minimal direct AI infrastructure role | L |
| HPE | HPE | AI-optimized servers and HPC systems for enterprise AI | M |
| Mitsubishi Electric | 5803 JP | Power systems and industrial equipment for data centers — indirect | L |

**Note on NVIDIA's dual role:** NVIDIA increasingly develops its own AI software stack (NeMo, AI Enterprise, DGX Cloud) and has positioned itself as an AI platform company. However, its primary revenue exposure to LLM releases comes through hardware demand. Code NVIDIA as `upstream_hardware` = 1 for all events. Additionally code NVIDIA as `competitor` = 1 only for events where the releasing entity is a direct competitor in AI hardware/platform (see R6 rules).

---

### R2: `upstream_cloud`

**Definition:** The company operates large-scale cloud computing or data-center-as-a-service platforms that are used by AI developers to train, host, or serve LLMs. These companies provide the compute infrastructure layer (IaaS/PaaS) on which LLMs run.

**Inclusion criteria (satisfy at least one):**

- (a) The company operates a major public cloud platform (IaaS/PaaS) with documented AI/ML workload support.
- (b) The company provides GPU-as-a-service or specialized AI cloud infrastructure.

**Exclusion criteria:**

- SaaS companies that run *on* cloud but do not *provide* cloud infrastructure to others.
- Data-center REITs or colocation providers (they provide real estate, not compute services).

**Typical companies and reasoning:**

| Company | Ticker | Reasoning | Confidence |
|---------|--------|-----------|------------|
| Amazon | AMZN | AWS — largest cloud provider; hosts Bedrock (LLM serving), provides GPU instances | H |
| Alphabet | GOOGL | GCP — major cloud; provides TPU access, Vertex AI | H |
| Microsoft | MSFT | Azure — major cloud; exclusive OpenAI hosting, GPU instances | H |
| Oracle | ORCL | OCI — growing AI cloud with GPU clusters; OCI used by xAI, OpenAI | H |
| Alibaba | BABA | Alibaba Cloud — major cloud in Asia; serves Qwen models | H |

**Interaction with R6 (competitor):** All five companies listed above also develop their own LLMs (Gemini, GPT via partnership, Llama hosting, Qwen, etc.). When coding an event, if the releasing entity is a *different* company, the cloud provider should be coded as both `upstream_cloud` = 1 and `competitor` = 1 (assuming they meet R6 criteria). When the releasing entity is the cloud provider *itself*, code `is_owner` = 1 instead.

**Interaction with is_investor (F1):** Amazon and Google have invested in Anthropic; Microsoft has invested in OpenAI and Mistral. These should be independently flagged.

---

### R3: `downstream_integrator`

**Definition:** AI capability is a **core input** to the company's primary product or service offering. The company directly integrates LLM APIs, foundation-model outputs, or AI-native features into its revenue-generating products. A meaningful change in frontier AI capability would directly affect the company's product quality, competitive position, or addressable market.

**Inclusion criteria (satisfy at least one):**

- (a) The company's flagship products embed LLM or foundation-model capabilities as a core feature (e.g., AI copilots, AI-powered analytics, AI-native search).
- (b) The company's primary revenue model depends on access to frontier AI models (e.g., API reselling, AI-powered SaaS).
- (c) The company is widely recognized as an "AI-first" or "AI-native" company whose valuation is substantially tied to AI capability advances.

**Exclusion criteria:**

- Companies that use AI internally for operational efficiency but whose customer-facing product does not depend on AI (→ R4 instead).
- Companies that offer AI-related consulting or integration services to clients (→ R5 instead).

**Distinguishing R3 from R4:** Ask: "If frontier LLM capability doubled overnight, would this company's core product directly improve?" If yes → R3. If the benefit is indirect or operational → R4.

**Typical companies and reasoning:**

| Company | Ticker | Reasoning | Confidence |
|---------|--------|-----------|------------|
| Palantir | PLTR | AIP (AI Platform) is the flagship product; directly integrates LLMs | H |
| C3.ai | AI | Enterprise AI platform; entire business model is AI-native | H |
| SoundHound AI | SOUN | Voice AI platform powered by foundation models | H |
| Snowflake | SNOW | Cortex AI features integrate LLMs into data cloud; AI is central growth vector | H |
| Datadog | DDOG | AI-powered observability; Bits AI assistant; LLM monitoring tools | M |
| ServiceNow | NOW | Now Assist (GenAI copilot) embedded across all products | H |
| Adobe | ADBE | Firefly (generative AI) integrated into Creative Cloud, core product differentiator | H |
| Salesforce | CRM | Einstein GPT / Agentforce — AI is central to platform strategy | H |
| UiPath | PATH | AI-powered RPA; integrates LLMs for intelligent automation | H |
| Workday | WDAY | AI embedded in HCM/finance platform (Workday AI) | M |
| Okta | OKTA | AI-powered identity threat detection; AI integration in security | M |
| Pegasystems | PEGA | GenAI Blueprint, AI-powered process automation | M |
| CCC Intelligent Solutions | CCC | AI-powered claims processing for insurance; AI is core product | H |
| NICE Systems | NICE | CXone AI for contact centers; AI is primary differentiator | M |
| Wix.com | WIX | AI website builder, AI text/image generation in product | M |
| Fortinet | FTNT | FortiAI uses LLMs for threat detection; AI security features | M |
| Zscaler | ZS | AI-powered zero trust security; AI threat intelligence | M |
| CyberArk | CYBR | AI-based identity security, threat detection | M |
| AppLovin | APP | AI-powered ad optimization (AXON engine) — AI is the core product | H |
| The Trade Desk | TTD | AI-powered programmatic ad bidding (Kokai platform) | M |
| Teradata | TDC | AI/ML analytics platform; ClearScape Analytics | M |
| Twilio | TWLO | CustomerAI platform; LLM-powered communication APIs | M |
| Temenos | TEMN SW | GenAI banking platform features | M |
| Shopify | SHOP | Shopify Magic (AI product descriptions, AI assistant); AI commerce features | M |
| Synopsys | SNPS | AI-powered EDA (Synopsys.ai); AI chip design tools | H |
| Cadence | CDNS | AI-powered EDA (Cadence Cerebrus); AI chip design automation | H |
| Quantum Computing | QUBT | Quantum-AI optimization — marginal LLM relevance | L |

---

### R4: `downstream_deployer`

**Definition:** The company deploys AI as a **tool or enabler** within its primary business, but the primary business is *not* AI itself. AI improves the company's operational efficiency, customer experience, or product features, but the company's core value proposition and revenue model exist independently of AI.

**Inclusion criteria (satisfy at least one):**

- (a) The company has publicly announced or deployed AI/LLM features in its products or operations, but these are supplementary to its core non-AI business.
- (b) The company operates in a sector being transformed by AI (autonomous driving, content recommendation, logistics optimization) but is primarily identified by its non-AI industry.

**Exclusion criteria:**

- Companies whose core product *is* AI or AI-powered analytics (→ R3 instead).
- Companies with no meaningful public AI deployment or strategy.

**Distinguishing R4 from R3:** Ask: "Would this company's core business survive and remain identifiable without AI?" If yes → R4. If removing AI would fundamentally undermine the product → R3.

**Typical companies and reasoning:**

| Company | Ticker | Reasoning | Confidence |
|---------|--------|-----------|------------|
| Tesla | TSLA | Autonomous driving uses AI; but Tesla is fundamentally a car/energy company | H |
| Uber | UBER | AI for routing, pricing, autonomous ride-hailing; but core is transportation platform | H |
| Netflix | NFLX | AI recommendation engine; but core is content streaming/production | H |
| Snap | SNAP | AI-powered AR filters, My AI chatbot; but core is social media | H |
| GE HealthCare | GEHC | AI-powered medical imaging diagnostics; core is medical devices | H |
| Pony.ai | PONY | Autonomous driving — AI is closer to core here, but primarily a mobility company | M |
| Siemens | SIE GR | Industrial AI (digital twin, predictive maintenance); core is industrial conglomerate | H |
| Sony | 6758 JP | AI in gaming, imaging, entertainment; core is diversified electronics/entertainment | M |
| Panasonic | 6954 JP | AI in consumer electronics and industrial solutions; core is electronics | M |
| Toshiba | 6588 JP | AI in infrastructure and storage; core is diversified industrial/electronics | L |
| Meituan | 3690 HK | AI for delivery optimization, recommendation; core is local services platform | M |
| Rakuten | 4755 JP | AI in e-commerce, fintech; core is internet services ecosystem | M |
| Cisco | CSCO | AI-powered networking (Cisco AI Assistant for Security/Networking); core is networking equipment | M |
| Ericsson | ERIC | AI-powered network optimization; core is telecom infrastructure | M |
| StoneCo | STNE | AI in payment processing and financial services; core is fintech | L |
| CareCloud | CRWV | AI in healthcare IT; small-cap with limited AI deployment evidence | L |
| Amplifon | AMP IM | AI in hearing aid fitting; core is hearing solutions retail | L |
| Zebra Technologies | ZBRA | AI in supply chain/warehouse automation; core is enterprise tracking | M |
| WeRock | WRD | Rugged computing; very limited AI relevance | L |
| Hut 8 Mining | HUT | Bitcoin mining → pivoting to AI cloud/HPC hosting; transitional | M |

**Note on Hut 8:** Hut 8 is transitioning from crypto mining to AI/HPC hosting. If this transition is confirmed with revenue by the event date, it may qualify as `upstream_cloud` instead. Code based on the company's primary business at the event date.

---

### R5: `downstream_enabler`

**Definition:** The company is an IT services, consulting, or systems integration firm that helps enterprise clients adopt, deploy, and manage AI solutions. The company does not build frontier AI models itself, nor is AI the direct product it sells to end users. Instead, it enables AI adoption across the enterprise landscape.

**Inclusion criteria (satisfy at least one):**

- (a) The company's core business is IT consulting, outsourcing, or systems integration, and it has established AI/GenAI practice areas.
- (b) The company provides managed AI services, AI implementation services, or AI-augmented business process outsourcing.

**Exclusion criteria:**

- Companies that build their own AI products for end users (→ R3 instead).
- Companies that develop AI models (→ R6 instead).
- Pure data/analytics companies with proprietary AI products (→ evaluate R3 or R4).

**Distinguishing R5 from R3:** R5 companies are *intermediaries* that connect AI capability to enterprise clients. R3 companies *embed* AI capability into their own products. Ask: "Does this company help *others* use AI, or does it use AI in *its own* product?" If the former → R5. If the latter → R3.

**Typical companies and reasoning:**

| Company | Ticker | Reasoning | Confidence |
|---------|--------|-----------|------------|
| Accenture | ACN | Global IT consulting; major GenAI practice; helps enterprises deploy AI | H |
| IBM | IBM | Hybrid: consulting (IBM Consulting AI services) + own AI (Granite models). Code BOTH R5 and R6 | H |
| Fujitsu | 6702 JP | IT services and consulting; AI solutions for enterprise clients | H |
| NEC | 6701 JP | IT services; AI and biometrics solutions | H |
| DXC Technology | DXC | IT outsourcing and managed services; AI-augmented offerings | H |
| Genpact | G | Business process outsourcing with AI automation | H |
| Tietoevry | TIETO FH | Nordic IT services and consulting with AI practice | H |
| HPE | HPE | Enterprise IT infrastructure + AI/ML solutions; hybrid hardware/enabler | M |
| Experian | EXPN LN | Data analytics and credit services with AI/ML models — borderline R3/R5 | M |
| Thomson Reuters | TRI | Information services with AI-powered legal/tax/news tools — borderline R3/R5 | M |
| Wolters Kluwer | WKL NA | Information services with AI features for legal/health/tax — borderline R3/R5 | M |

**Note on borderline R3/R5 cases (Experian, Thomson Reuters, Wolters Kluwer):** These information services companies have *proprietary data* as their core asset and increasingly embed AI into their products. They sit between R3 (AI is becoming core to their product) and R5 (they enable professional workflows). The coder should evaluate whether the company's primary value-add is *its data + AI-enhanced delivery* (lean R3) or *helping professionals use AI tools* (lean R5). If uncertain, code R3 = 1 (primary) and R5 = 0, because the information-services model is closer to "AI in own product" than "helping clients use AI."

---

### R6: `competitor`

**Definition:** The company develops, trains, or releases its own large language models or foundation models (including text, code, image, video, or multimodal models) that compete in the same capability space as the event's released model.

**Inclusion criteria (satisfy at least one):**

- (a) The company has publicly released or operates a competing LLM or foundation model (including via API) at the time of the event.
- (b) The company is the listed parent or majority owner of an entity that develops competing models (e.g., Alphabet/Google for Gemini, Meta for Llama).
- (c) The company has publicly announced significant investment in developing competing foundation models, with demonstrated outputs (research papers, model releases, API products).

**Exclusion criteria:**

- Companies that *use* LLMs but do not *develop* their own foundation models. Fine-tuning a third-party model does not qualify — the company must train foundation models from scratch or at near-foundation scale.
- Companies whose AI activities are limited to narrow, domain-specific models (e.g., a fraud detection model) that do not compete in the general-purpose AI model space.

**Critical rule — modality matching:** The `competitor` label should primarily apply when the company's model competes in the **same modality** as the event's model. For example:
- A text-LLM event → companies with competing text LLMs are competitors.
- An image-generation event → companies with competing image generators are competitors.
- However, major AI labs that compete across multiple modalities (Google, OpenAI, Meta, Anthropic, Alibaba) should be coded as competitors for **all** LLM events, because model releases signal broader competitive positioning.

**Typical companies and reasoning:**

| Company | Ticker | Reasoning | Confidence |
|---------|--------|-----------|------------|
| Alphabet (Google) | GOOGL | Gemini, Imagen, Veo — competes across all modalities | H |
| Meta | META | Llama family, FAIR research — major open-source LLM competitor | H |
| Amazon | AMZN | Develops Titan models, Nova models for Bedrock; invests in Anthropic | M |
| Microsoft | MSFT | Develops Phi models; strategic partnership with OpenAI gives competitive positioning | H |
| Alibaba | BABA | Qwen family — major LLM developer | H |
| Baidu | BIDU | ERNIE models — major Chinese LLM developer | H |
| Tencent | 700 HK | Hunyuan models — Chinese LLM developer | M |
| Apple | AAPL | Apple Intelligence, on-device AI models; emerging competitor | M |
| IBM | IBM | Granite models — enterprise-focused LLM family | M |

**Who is NOT a competitor:**

| Company | Ticker | Why not R6 |
|---------|--------|-----------|
| NVIDIA | NVDA | Despite AI software stack (NeMo), NVIDIA's primary market impact from LLM releases is through hardware demand, not model competition. Do NOT code as competitor for LLM release events. Code as `upstream_hardware` only. |
| Palantir | PLTR | Uses/integrates LLMs but does not develop foundation models | |
| Salesforce | CRM | Uses AI extensively but does not develop competing foundation models at scale | |
| Oracle | ORCL | Cloud hosting and enterprise software; no competing foundation models | |

**Note on NVIDIA:** This is the single most important judgment call in the codebook. NVIDIA is primarily valued by the market as an AI infrastructure supplier. When OpenAI releases GPT-5, the market's reaction for NVIDIA is driven by "this validates GPU demand" (upstream), not "NVIDIA's AI models are now less competitive" (competitor). Coding NVIDIA as `competitor` would contaminate the upstream channel identification. If a coder disagrees, code `competitor` = 1 with confidence L and flag for adjudication.

---

### F1: `is_investor` (Flag)

**Definition:** The company holds a documented equity investment in the entity that released the model in this event.

**Inclusion criteria:**

- The company (or its subsidiary) has made a publicly documented equity investment (direct or convertible) in the model's releasing entity.
- The investment must be documented before the event date.

**Known relationships (as of 2026):**

| Investor | Investee | Investment | Events affected |
|----------|----------|------------|-----------------|
| Microsoft (MSFT) | OpenAI | ~$13B cumulative; 49% profit interest | All OpenAI events |
| Amazon (AMZN) | Anthropic | ~$4B | All Anthropic events |
| Alphabet (GOOGL) | Anthropic | ~$2B | All Anthropic events |
| Salesforce (CRM) | Anthropic | Undisclosed (via Salesforce Ventures) | All Anthropic events |
| Microsoft (MSFT) | Mistral AI | €15M (minor) | All Mistral events |

**Note:** Code `is_investor` = 1 only for the specific releasing entity. Microsoft investing in OpenAI does not make Microsoft an investor in Google's Gemini events.

---

### F2: `is_owner` (Flag)

**Definition:** The company *is* the releasing entity or its listed parent company. This flag identifies the "publisher" of the model.

**Inclusion criteria:**

- The company is the listed entity that directly developed and released the model, OR
- The company is the listed parent/controlling shareholder of the releasing entity.

**Mapping:**

| Creator | Listed Entity | Ticker | Confidence |
|---------|--------------|--------|------------|
| Google | Alphabet | GOOGL | H |
| OpenAI | — (not listed; Microsoft is investor, not owner) | — | — |
| Meta | Meta Platforms | META | H |
| Microsoft | Microsoft | MSFT | H (for Phi events only) |
| Alibaba | Alibaba Group | BABA | H |
| Baidu | Baidu | BIDU | H (if Baidu events exist) |
| Anthropic | — (not listed) | — | — |
| xAI | — (not listed) | — | — |
| DeepSeek | — (not listed) | — | — |

**Critical rule:** Microsoft is NOT the owner of OpenAI. Code `is_investor` = 1 for Microsoft on OpenAI events, but `is_owner` = 0. Microsoft is `is_owner` = 1 only for Microsoft's own model releases (Phi family).

---

## 3. Decision Procedure

For each (company, event) pair, follow these steps in order:

```
Step 1: Is the company the releasing entity's listed parent?
        → If yes: is_owner = 1. Continue to check other dimensions.

Step 2: Does the company have an equity stake in the releasing entity?
        → If yes: is_investor = 1. Continue.

Step 3: Does the company supply hardware/components for AI infrastructure?
        → Apply R1 criteria. Assess: does this company's hardware
          plausibly support the releasing entity's AI workloads?
        → If yes: upstream_hardware = 1.

Step 4: Does the company operate cloud infrastructure used for AI?
        → Apply R2 criteria.
        → If yes: upstream_cloud = 1.

Step 5: Does the company develop competing foundation models?
        → Apply R6 criteria. Check modality match.
        → If yes: competitor = 1.

Step 6: Does the company integrate AI as a core product feature?
        → Apply R3 criteria. Ask: "Does frontier LLM improvement
          directly improve this company's core product?"
        → If yes: downstream_integrator = 1. STOP downstream check.

Step 7: Does the company help clients deploy AI solutions?
        → Apply R5 criteria. Ask: "Is this an IT services/consulting
          firm with AI practice areas?"
        → If yes: downstream_enabler = 1. STOP downstream check.

Step 8: Does the company deploy AI in a non-AI-native business?
        → Apply R4 criteria.
        → If yes: downstream_deployer = 1.

Step 9: If none of the above apply with confidence ≥ M,
        all indicators = 0. The company has no classifiable
        structural relationship to this event.
```

**Note on Steps 6–8:** The three downstream categories (R3, R4, R5) are intended to be **mutually exclusive** for most companies. A company should typically receive exactly one downstream label. If a borderline case genuinely straddles two categories, code the *primary* role = 1 and note the secondary role in the justification field.

---

## 4. Multi-Role Examples

These examples illustrate how multi-label coding works for complex cases.

### Microsoft (MSFT)

| Dimension | For OpenAI events | For Google events | For Microsoft events (Phi) |
|-----------|-------------------|-------------------|--------------------------|
| upstream_hardware | 0 | 0 | 0 |
| upstream_cloud | 1 (Azure hosts OpenAI) | 0 | 1 |
| downstream_integrator | 1 (Copilot integrates GPT) | 1 (Copilot uses AI) | 0 |
| downstream_deployer | 0 | 0 | 0 |
| downstream_enabler | 0 | 0 | 0 |
| competitor | 1 (Phi models) | 1 (Phi models) | 0 |
| is_investor | 1 | 0 | 0 |
| is_owner | 0 | 0 | 1 |

### Amazon (AMZN)

| Dimension | For Anthropic events | For OpenAI events | For Google events |
|-----------|---------------------|-------------------|-------------------|
| upstream_cloud | 1 (AWS Bedrock hosts Claude) | 1 (AWS offers GPT access) | 1 |
| competitor | 1 (Titan/Nova models) | 1 | 1 |
| is_investor | 1 ($4B in Anthropic) | 0 | 0 |

### Alphabet/Google (GOOGL)

| Dimension | For Anthropic events | For OpenAI events | For Google events |
|-----------|---------------------|-------------------|-------------------|
| upstream_cloud | 1 (GCP) | 1 | 0 |
| competitor | 1 (Gemini) | 1 | 0 |
| is_investor | 1 ($2B in Anthropic) | 0 | 0 |
| is_owner | 0 | 0 | 1 |

### NVIDIA (NVDA)

| Dimension | For ANY event |
|-----------|---------------|
| upstream_hardware | 1 (always — GPU supplier for all LLM training) |
| upstream_cloud | 0 |
| downstream_* | 0 |
| competitor | 0 (see codebook note on NVIDIA under R6) |
| is_investor | 0 |
| is_owner | 0 |

### IBM (IBM)

| Dimension | For ANY non-IBM event |
|-----------|----------------------|
| upstream_hardware | 0 |
| upstream_cloud | 0 (IBM Cloud is minor in AI workloads) |
| downstream_integrator | 0 |
| downstream_deployer | 0 |
| downstream_enabler | 1 (IBM Consulting AI services) |
| competitor | 1 (Granite models) |

---

## 5. Output Format

Each coder produces a CSV with the following columns:

```
final_event_id, company_id, upstream_hardware, upstream_cloud,
downstream_integrator, downstream_deployer, downstream_enabler,
competitor, is_investor, is_owner,
confidence, justification
```

- `confidence`: Lowest confidence among all indicators marked 1 for this observation. H/M/L.
- `justification`: Semicolon-separated brief reasons for each indicator = 1. Format: `"R1:GPU supplier; R6:Gemini models"`.

---

## 6. Handling Edge Cases

### 6.1 Company with no AI relevance

If a company has no identifiable structural relationship to LLM development, deployment, or competition, all indicators = 0. This is a valid coding outcome — it means the company is in the sample but has no directional exposure through supply-chain or competitive channels. Document: `"No identifiable AI supply chain or competitive relationship"`.

### 6.2 Event-specific modality mismatch

If a downstream_integrator only uses text LLMs but the event is a pure image-generation model release (e.g., Runway Gen-4), the coder should still code `downstream_integrator` = 1 if the company's AI integration strategy *plausibly* extends to the released modality or if the event signals broader AI capability. However, if there is clearly no pathway (e.g., a text-only chatbot company for a video model release), code 0 for that observation and note the modality mismatch.

### 6.3 Chinese companies and non-US events

For Chinese model releases (DeepSeek, Alibaba/Qwen, Zhipu AI), U.S.-listed companies' relationships follow the same rules. Chinese models released as open-source can be deployed on any cloud, potentially making all cloud providers partial beneficiaries. The coder should not adjust relationship coding based on geopolitics — code based on structural economic relationships only.

### 6.4 Confidence thresholds for sensitivity analysis

After coding is complete, the research team will construct two versions of the relationship matrix:

- **Conservative:** Only indicators with confidence H or M are coded 1; confidence L → recoded to 0.
- **Inclusive:** All indicators as coded (H, M, and L all coded 1).

Regressions will be run on both versions to verify that results are robust to classification uncertainty.

---

## 7. Inter-Coder Reliability Protocol

1. Two coders (GPT-4o and Claude Opus) independently code all 5,160 observations using this codebook.
2. For each of the six relationship dimensions and two flags, compute Cohen's κ.
3. Target: κ ≥ 0.80 per dimension.
4. If κ < 0.80 for any dimension:
   - Review all discordant cases for that dimension.
   - Identify whether discrepancies stem from codebook ambiguity or factual disagreement.
   - If codebook ambiguity: revise the relevant section and re-code.
   - If factual disagreement: research team adjudicates based on documented evidence.
5. After adjudication, compute final κ and report in the paper.
6. The research team additionally performs a 20% random-sample manual verification against public filings and press releases.

---

## Appendix A: Complete Company List with Industry Classification

| # | Ticker | Company | GICS Industry Group |
|---|--------|---------|-------------------|
| 1 | 000660 KS | SK Hynix | Semiconductors |
| 2 | 005930 KS | Samsung Electronics | Semiconductors |
| 3 | 2353 TT | Acer | Tech Hardware |
| 4 | 2395 TT | Advantech | Tech Hardware |
| 5 | 3443 TT | Transcend | Tech Hardware |
| 6 | 3690 HK | Meituan | Internet Retail |
| 7 | 4755 JP | Rakuten | Internet Retail |
| 8 | 5803 JP | Mitsubishi Electric | Electrical Equipment |
| 9 | 6588 JP | Toshiba | Industrial Conglomerate |
| 10 | 6701 JP | NEC | IT Services |
| 11 | 6702 JP | Fujitsu | IT Services |
| 12 | 6758 JP | Sony | Entertainment |
| 13 | 6954 JP | Panasonic | Consumer Electronics |
| 14 | 700 HK | Tencent | Internet Services |
| 15 | AAPL | Apple | Tech Hardware / Software |
| 16 | ACN | Accenture | IT Services |
| 17 | ADBE | Adobe | Software |
| 18 | AI | C3.ai | Software |
| 19 | AMBA | Ambarella | Semiconductors |
| 20 | AMD | AMD | Semiconductors |
| 21 | AMP IM | Amplifon | Healthcare Equipment |
| 22 | AMZN | Amazon | Internet Retail / Cloud |
| 23 | APP | AppLovin | Software |
| 24 | AVGO | Broadcom | Semiconductors |
| 25 | BABA | Alibaba | Internet Retail / Cloud |
| 26 | BIDU | Baidu | Internet Services |
| 27 | CCC | CCC Intelligent Solutions | Software |
| 28 | CDNS | Cadence Design Systems | Software (EDA) |
| 29 | CRM | Salesforce | Software |
| 30 | CRWV | CareCloud | Healthcare IT |
| 31 | CSCO | Cisco | Communications Equipment |
| 32 | CYBR | CyberArk | Software (Security) |
| 33 | DDOG | Datadog | Software |
| 34 | DXC | DXC Technology | IT Services |
| 35 | ERIC | Ericsson | Communications Equipment |
| 36 | EXPN LN | Experian | Professional Services |
| 37 | FTNT | Fortinet | Software (Security) |
| 38 | G | Genpact | IT Services |
| 39 | GEHC | GE HealthCare | Healthcare Equipment |
| 40 | GOOGL | Alphabet (Google) | Internet Services / Cloud |
| 41 | HPE | HPE | Tech Hardware |
| 42 | HUT | Hut 8 Mining | Capital Markets |
| 43 | IBM | IBM | IT Services |
| 44 | IFX GR | Infineon | Semiconductors |
| 45 | INTC | Intel | Semiconductors |
| 46 | META | Meta | Internet Services |
| 47 | MRVL | Marvell | Semiconductors |
| 48 | MSFT | Microsoft | Software / Cloud |
| 49 | MU | Micron | Semiconductors |
| 50 | NICE | NICE Systems | Software |
| 51 | NFLX | Netflix | Media |
| 52 | NOW | ServiceNow | Software |
| 53 | NVDA | NVIDIA | Semiconductors |
| 54 | NXPI | NXP | Semiconductors |
| 55 | OKTA | Okta | Software (Security) |
| 56 | ORCL | Oracle | Software / Cloud |
| 57 | PATH | UiPath | Software |
| 58 | PEGA | Pegasystems | Software |
| 59 | PLTR | Palantir | Software |
| 60 | PONY | Pony.ai | Automotive |
| 61 | QCOM | Qualcomm | Semiconductors |
| 62 | QUBT | Quantum Computing | Software |
| 63 | SHOP | Shopify | Software |
| 64 | SIE GR | Siemens | Industrial Conglomerate |
| 65 | SMCI | Super Micro Computer | Tech Hardware |
| 66 | SNAP | Snap | Internet Services |
| 67 | SNOW | Snowflake | Software |
| 68 | SNPS | Synopsys | Software (EDA) |
| 69 | SOUN | SoundHound AI | Software |
| 70 | STNE | StoneCo | Fintech |
| 71 | STX | Seagate | Tech Hardware |
| 72 | TDC | Teradata | Software |
| 73 | TEMN SW | Temenos Group | Software |
| 74 | TIETO FH | Tietoevry | IT Services |
| 75 | TRI | Thomson Reuters | Professional Services |
| 76 | TSLA | Tesla | Automotive |
| 77 | TSM | TSMC | Semiconductors |
| 78 | TTD | The Trade Desk | Software |
| 79 | TWLO | Twilio | Software |
| 80 | UBER | Uber | Transportation |
| 81 | WDAY | Workday | Software |
| 82 | WIX | Wix.com | Software |
| 83 | WKL NA | Wolters Kluwer | Professional Services |
| 84 | WRD | WeRock | Machinery |
| 85 | ZBRA | Zebra Technologies | Tech Hardware |
| 86 | ZS | Zscaler | Software (Security) |

## Appendix B: Complete Event List

| Event ID | Date | Creator | Model | Open/Closed | Tier |
|----------|------|---------|-------|-------------|------|
| FMR-0001 | 2024-04-18 | Meta | LLaMA 3 | Open | Tier 2 |
| FMR-0002 | 2024-05-14 | Google | Imagen 3 | Closed | Tier 2 |
| FMR-0003 | 2024-05-30 | Google | Gemini Flash 1.5 | Closed | Tier 2 |
| FMR-0004 | 2024-06-12 | Stability AI | Stable Diffusion 3 | Closed | Tier 1 |
| FMR-0005 | 2024-08-08 | Google | Gemini 1.5 Flash | Closed | Tier 2 |
| FMR-0006 | 2024-08-13 | xAI | Grok 2 | Closed | Tier 1 |
| FMR-0007 | 2024-08-28 | Google | Imagen 3 | Closed | Tier 1 |
| FMR-0008 | 2024-09-12 | OpenAI | o1 preview | Closed | Tier 2 |
| FMR-0009 | 2024-09-12 | OpenAI | o1 mini | Closed | Tier 2 |
| FMR-0010 | 2024-09-24 | Google | Gemini 1.5 002 family | Closed | Tier 2 |
| FMR-0011 | 2024-10-03 | Google | Gemini 1.5 Pro | Closed | Tier 2 |
| FMR-0012 | 2024-10-03 | Google | Gemini 1.5 Flash8B | Closed | Tier 2 |
| FMR-0013 | 2024-10-22 | Anthropic | Claude 3.5 Sonnet New / Haiku | Closed | Tier 2 |
| FMR-0014 | 2024-11-12 | Alibaba | Qwen2.5 Coder 32B | Open | Tier 2 |
| FMR-0015 | 2024-12-06 | Meta | Llama 3.3 70B | Closed | Tier 1 |
| FMR-0016 | 2024-12-09 | OpenAI | SORA | Closed | Tier 1 |
| FMR-0017 | 2024-12-11 | Google | Gemini-2.0-Flash-Thinking | Closed | Tier 1 |
| FMR-0018 | 2024-12-17 | OpenAI | o1 | Closed | Tier 1 |
| FMR-0019 | 2024-12-17 | OpenAI | o1 Pro | Closed | Tier 1 |
| FMR-0020 | 2024-12-20 | OpenAI | o3 family announcement | Closed | Tier 3 |
| FMR-0021 | 2025-01-22 | DeepSeek | DeepSeek R1 | Open | Tier 1 |
| FMR-0022 | 2025-01-28 | Alibaba | Qwen2.5-Max | Open | Tier 1 |
| FMR-0023 | 2025-01-31 | OpenAI | o3 mini | Closed | Tier 2 |
| FMR-0024 | 2025-02-05 | Google | Gemini 2.0 family | Closed | Tier 2 |
| FMR-0025 | 2025-02-17 | xAI | Grok 3 family | Closed | Tier 1 |
| FMR-0026 | 2025-02-18 | Anthropic | Claude 3.7 | Closed | Tier 1 |
| FMR-0027 | 2025-02-25 | Google | Gemini 2.0 Flash-Lite Preview | Closed | Tier 2 |
| FMR-0028 | 2025-02-26 | Microsoft | Phi-4 mini / multimodal | Closed | Tier 2 |
| FMR-0029 | 2025-03-12 | Google | Gemini 2.0 Flash Experimental | Closed | Tier 1 |
| FMR-0030 | 2025-03-31 | Runway | Runway Gen-4 | Closed | Tier 1 |
| FMR-0031 | 2025-04-15 | Google | Veo 2.0 | Closed | Tier 1 |
| FMR-0032 | 2025-04-15 | Kuaishou | Kling 2.0 | Closed | Tier 1 |
| FMR-0033 | 2025-04-16 | OpenAI | o3 full | Closed | Tier 2 |
| FMR-0034 | 2025-04-16 | OpenAI | o4 mini | Closed | Tier 2 |
| FMR-0035 | 2025-04-21 | ShengShu Technology | Vidu Q1 | Closed | Tier 1 |
| FMR-0036 | 2025-05-06 | Google | Gemini 2.5 Pro | Closed | Tier 2 |
| FMR-0037 | 2025-05-20 | Google | Gemma 3n | Open | Tier 3 |
| FMR-0038 | 2025-05-21 | Anthropic | Claude Sonnet 4 | Closed | Tier 1 |
| FMR-0039 | 2025-05-21 | Google | Google I/O media model family | Closed | Tier 1 |
| FMR-0040 | 2025-05-22 | Anthropic | Claude 4 Opus | Closed | Tier 1 |
| FMR-0041 | 2025-06-17 | Google | Gemini 2.5 Flash | Closed | Tier 2 |
| FMR-0042 | 2025-06-17 | Google | Gemini 2.5 Pro | Closed | Tier 1 |
| FMR-0043 | 2025-07-21 | Alibaba | Qwen3-235B | Open | Tier 2 |
| FMR-0044 | 2025-07-22 | Alibaba | Qwen3-Coder | Open | Tier 2 |
| FMR-0045 | 2025-07-28 | Zhipu AI | GLM-4.5 | Open | Tier 2 |
| FMR-0046 | 2025-08-05 | OpenAI | gpt-oss family | Open | Tier 1 |
| FMR-0047 | 2025-08-26 | Google | Gemini 2.5 Flash Image | Closed | Tier 1 |
| FMR-0048 | 2025-09-05 | Alibaba | Qwen-3-Max | Closed | Tier 1 |
| FMR-0049 | 2025-09-25 | Anthropic | Claude Sonnet 4.5 | Closed | Tier 2 |
| FMR-0050 | 2025-10-14 | Anthropic | Claude 4.5 Haiku | Closed | Tier 2 |
| FMR-0051 | 2025-12-02 | Mistral AI | Mistral 3 | Open | Tier 2 |
| FMR-0052 | 2025-12-09 | Mistral AI | Devstral 2 | Open | Tier 2 |
| FMR-0053 | 2025-12-18 | Alibaba | Z-Image-Turbo | Open | Tier 2 |
| FMR-0054 | 2025-12-18 | OpenAI | GPT-5.2 | Closed | Tier 1 |
| FMR-0055 | 2025-12-31 | Alibaba | Qwen-Image-2512 | Open | Tier 2 |
| FMR-0056 | 2026-02-05 | Anthropic | Claude Opus 4.6 | Closed | Tier 2 |
| FMR-0057 | 2026-02-12 | OpenAI | GPT-5.3-Codex | Closed | Tier 1 |
| FMR-0058 | 2026-02-16 | Anthropic | Claude Sonnet 4.6 | Closed | Tier 2 |
| FMR-0059 | 2026-02-26 | Google | Nano Banana 2 | Closed | Tier 2 |
| FMR-0060 | 2026-03-17 | OpenAI | GPT-5.4 family | Closed | Tier 1 |

---

*End of codebook. This document is the sole reference for all relationship coding in this study.*
