# Task: Independent Relationship Coding for LLM Event Study

You are acting as **Coder B** in a dual-coder inter-rater reliability protocol for an academic finance paper. Another LLM (Coder A) will independently code the same data. Your outputs will be compared using Cohen's κ. The research team will adjudicate any disagreements.

**Your goal:** For each (company, model_creator) pair listed below, classify the structural economic relationship between the company and the model creator, following the codebook provided. Your coding must be evidence-based, conservative, and reproducible.

---

## Codebook (complete — this is your sole reference)

### Coding Unit

You will code at the **(company, creator)** level. There are 86 companies and 14 model creators = 1,204 unique pairs. Each pair receives:

- **Six binary (0/1) relationship indicators** — a single pair may have multiple indicators = 1
- **Two binary (0/1) flags**
- **A confidence rating** (H/M/L) — lowest confidence among all 1-indicators
- **A brief justification** — semicolon-separated reasons for each indicator = 1

### Relationship Dimensions

| Code | Column Name | Definition |
|------|-------------|------------|
| R1 | `upstream_hardware` | Company supplies physical hardware or components for AI training/inference (GPUs, AI accelerators, memory/HBM, storage, networking, AI servers, chip fabrication/packaging) |
| R2 | `upstream_cloud` | Company operates large-scale cloud computing / data-center-as-a-service platforms used for AI workloads (IaaS/PaaS with documented AI/ML support) |
| R3 | `downstream_integrator` | AI capability is a **core input** to the company's primary product. Company directly integrates LLM APIs or foundation-model features into revenue-generating products. If frontier LLM capability doubled, this company's core product would directly improve. |
| R4 | `downstream_deployer` | Company deploys AI as a **tool or enabler** within a non-AI-native business. Core business exists independently of AI. AI improves efficiency or features but is not the primary value proposition. |
| R5 | `downstream_enabler` | IT services / consulting / systems integration firm that helps enterprise clients adopt and deploy AI solutions. Does not build frontier AI models itself. |
| R6 | `competitor` | Company develops, trains, or releases its own LLMs or foundation models competing with the creator's models. Must train foundation models from scratch or near-foundation scale — fine-tuning third-party models does not qualify. |
| F1 | `is_investor` | Company holds a documented equity stake in the model creator |
| F2 | `is_owner` | Company IS the model creator (or its listed parent) |

### Key Rules

1. **Multi-label.** One pair can have multiple 1s. Microsoft for OpenAI events can be upstream_cloud=1, downstream_integrator=1, competitor=1, is_investor=1 simultaneously.

2. **Conservative default.** If evidence is ambiguous, code 0. False positives are worse than false negatives for this study.

3. **Downstream categories (R3, R4, R5) are mutually exclusive** for most companies. Assign the primary role. If genuinely borderline, code the stronger one = 1 and note the secondary in justification.

4. **R3 vs R4 test:** "Would this company's core business survive and remain identifiable without AI?" Yes → R4. No → R3.

5. **R3 vs R5 test:** "Does this company help *others* use AI, or embed AI in *its own* product?" Helps others → R5. Own product → R3.

6. **Competitor modality:** Major AI labs (Google, OpenAI, Meta, Anthropic, Alibaba, Baidu, Tencent) should be coded as competitors for ALL creators they don't own, because model releases signal broad competitive positioning. Smaller/niche companies → only code competitor if they compete in the same modality space.

7. **NVIDIA rule:** NVIDIA is primarily an AI infrastructure hardware supplier. Code NVIDIA as `upstream_hardware` = 1 for ALL creators. Do NOT code NVIDIA as `competitor` = 1 — its primary market impact from LLM releases is through hardware demand, not model competition. If you disagree, code competitor = 1 with confidence L and flag in justification.

8. **is_owner mapping:**
   - Google events → GOOGL is_owner=1
   - Meta events → META is_owner=1
   - Microsoft events → MSFT is_owner=1
   - Alibaba events → BABA is_owner=1
   - OpenAI events → no listed owner (MSFT is investor, not owner)
   - Anthropic, xAI, DeepSeek, Mistral, Stability AI, Runway, Kuaishou, ShengShu, Zhipu → no listed owner in sample

9. **Known investments (as of 2026):**
   - MSFT → OpenAI (~$13B, 49% profit interest)
   - AMZN → Anthropic (~$4B)
   - GOOGL → Anthropic (~$2B)
   - CRM → Anthropic (via Salesforce Ventures)
   - MSFT → Mistral AI (€15M)

10. **If no relationship applies** with confidence ≥ M, all indicators = 0. This is valid — it means the company has no classifiable structural link to this creator.

### Decision Procedure

For each (company, creator) pair, work through this sequence:

```
Step 1: Is the company the creator's listed parent? → is_owner
Step 2: Does the company have equity in the creator? → is_investor
Step 3: Does the company supply AI hardware/components? → upstream_hardware
Step 4: Does the company operate cloud infra for AI? → upstream_cloud
Step 5: Does the company develop competing foundation models? → competitor
Step 6: Is AI a core product input for this company? → downstream_integrator (STOP further downstream)
Step 7: Does the company help clients deploy AI? → downstream_enabler (STOP further downstream)
Step 8: Does the company deploy AI in a non-AI business? → downstream_deployer
Step 9: None apply → all 0
```

---

## Input Data

### 86 Companies

| ticker | company_name | industry |
|--------|-------------|----------|
| 000660 KS | SK Hynix | Semiconductors |
| 005930 KS | Samsung Electronics | Semiconductors |
| 2353 TT | Acer | Tech Hardware |
| 2395 TT | Advantech | Tech Hardware |
| 3443 TT | Transcend | Tech Hardware |
| 3690 HK | Meituan | Internet Retail |
| 4755 JP | Rakuten | Internet Retail |
| 5803 JP | Mitsubishi Electric | Electrical Equipment |
| 6588 JP | Toshiba | Industrial Conglomerate |
| 6701 JP | NEC | IT Services |
| 6702 JP | Fujitsu | IT Services |
| 6758 JP | Sony | Entertainment |
| 6954 JP | Panasonic | Consumer Electronics |
| 700 HK | Tencent | Internet Services |
| AAPL | Apple | Tech Hardware / Software |
| ACN | Accenture | IT Services |
| ADBE | Adobe | Software |
| AI | C3.ai | Software (AI-native) |
| AMBA | Ambarella | Semiconductors (Edge AI) |
| AMD | AMD | Semiconductors |
| AMP IM | Amplifon | Healthcare Equipment |
| AMZN | Amazon | Internet Retail / Cloud |
| APP | AppLovin | Software (Ad Tech) |
| AVGO | Broadcom | Semiconductors / Networking |
| BABA | Alibaba | Internet Retail / Cloud |
| BIDU | Baidu | Internet Services |
| CCC | CCC Intelligent Solutions | Software (Insurance AI) |
| CDNS | Cadence Design Systems | Software (EDA) |
| CRM | Salesforce | Software (CRM) |
| CRWV | CareCloud | Healthcare IT |
| CSCO | Cisco | Communications Equipment |
| CYBR | CyberArk | Software (Security) |
| DDOG | Datadog | Software (Observability) |
| DXC | DXC Technology | IT Services |
| ERIC | Ericsson | Communications Equipment |
| EXPN LN | Experian | Professional Services (Data) |
| FTNT | Fortinet | Software (Security) |
| G | Genpact | IT Services (BPO) |
| GEHC | GE HealthCare | Healthcare Equipment |
| GOOGL | Alphabet (Google) | Internet Services / Cloud |
| HPE | HPE | Tech Hardware / IT Solutions |
| HUT | Hut 8 Mining | Capital Markets / Crypto-to-AI |
| IBM | IBM | IT Services / Software |
| IFX GR | Infineon | Semiconductors |
| INTC | Intel | Semiconductors |
| META | Meta (Facebook) | Internet Services |
| MRVL | Marvell | Semiconductors |
| MSFT | Microsoft | Software / Cloud |
| MU | Micron | Semiconductors (Memory) |
| NICE | NICE Systems | Software (Contact Center AI) |
| NFLX | Netflix | Media / Streaming |
| NOW | ServiceNow | Software (Enterprise) |
| NVDA | NVIDIA | Semiconductors (GPU/AI) |
| NXPI | NXP | Semiconductors (Auto/IoT) |
| OKTA | Okta | Software (Security) |
| ORCL | Oracle | Software / Cloud |
| PATH | UiPath | Software (RPA/AI) |
| PEGA | Pegasystems | Software (Process AI) |
| PLTR | Palantir | Software (AI Platform) |
| PONY | Pony.ai | Automotive (Autonomous) |
| QCOM | Qualcomm | Semiconductors (Mobile/Edge) |
| QUBT | Quantum Computing | Software (Quantum) |
| SHOP | Shopify | Software (E-commerce) |
| SIE GR | Siemens | Industrial Conglomerate |
| SMCI | Super Micro Computer | Tech Hardware (AI Servers) |
| SNAP | Snap | Internet Services (Social) |
| SNOW | Snowflake | Software (Data Cloud) |
| SNPS | Synopsys | Software (EDA) |
| SOUN | SoundHound AI | Software (Voice AI) |
| STNE | StoneCo | Fintech |
| STX | Seagate | Tech Hardware (Storage) |
| TDC | Teradata | Software (Analytics) |
| TEMN SW | Temenos Group | Software (Banking) |
| TIETO FH | Tietoevry | IT Services |
| TRI | Thomson Reuters | Professional Services |
| TSLA | Tesla | Automotive |
| TSM | TSMC | Semiconductors (Foundry) |
| TTD | The Trade Desk | Software (Ad Tech) |
| TWLO | Twilio | Software (Communications) |
| UBER | Uber | Transportation |
| WDAY | Workday | Software (HCM/Finance) |
| WIX | Wix.com | Software (Web Builder) |
| WKL NA | Wolters Kluwer | Professional Services |
| WRD | WeRock | Machinery (Rugged Computing) |
| ZBRA | Zebra Technologies | Tech Hardware (Enterprise) |
| ZS | Zscaler | Software (Security) |

### 14 Model Creators

| creator | country | type | notable_models |
|---------|---------|------|---------------|
| Alibaba | China | listed (BABA) | Qwen family |
| Anthropic | USA | private | Claude family |
| DeepSeek | China | private | DeepSeek R1 |
| Google | USA | listed (GOOGL) | Gemini, Imagen, Veo |
| Kuaishou | China | listed (HK) but not in sample | Kling video |
| Meta | USA | listed (META) | Llama family |
| Microsoft | USA | listed (MSFT) | Phi family |
| Mistral AI | France | private | Mistral, Devstral |
| OpenAI | USA | private (MSFT investor) | GPT, o-series, SORA |
| Runway | USA | private | Gen-4 video |
| ShengShu Technology | China | private | Vidu video |
| Stability AI | UK | private | Stable Diffusion |
| Zhipu AI | China | private | GLM family |
| xAI | USA | private | Grok family |

---

## Output Format

Produce a CSV with exactly these columns, one row per (company, creator) pair:

```
company_id,creator,upstream_hardware,upstream_cloud,downstream_integrator,downstream_deployer,downstream_enabler,competitor,is_investor,is_owner,confidence,justification
```

- 1,204 rows total (86 companies × 14 creators)
- All relationship columns: 0 or 1
- `confidence`: H, M, or L (lowest confidence among all 1-indicators for that row; leave blank if all indicators are 0)
- `justification`: Semicolon-separated brief reasons for each indicator = 1 (e.g., "R1:GPU supplier for all LLM training; R6:Gemini competes with this creator's models"). Leave blank if all 0.

**Sort** by company_id (alphabetical), then by creator (alphabetical).

---

## Important Reminders

- You are Coder B. Another coder will independently produce the same output. Do NOT try to guess what the other coder will do. Code based solely on this codebook and your knowledge of these companies.
- Be **conservative**. When in doubt, code 0.
- Your knowledge of these companies' business models, products, partnerships, and competitive positioning is the evidence base. For well-known facts (TSMC fabricates for NVIDIA, Microsoft invested in OpenAI), you do not need external citations. For less certain claims, note confidence = L.
- Do NOT invent relationships. If you are unsure whether a company has a structural AI relationship, code 0.
- The downstream categories (R3/R4/R5) should be **mutually exclusive** per company in almost all cases.
- Output the complete 1,204-row CSV. Do not truncate or summarize.

Begin coding now. Output the full CSV.
