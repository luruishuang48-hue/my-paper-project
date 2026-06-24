from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "data/relationships/6.21事件集数据.csv"
OUT_DIR = ROOT / "data/relationships"
TASK_DIR = ROOT / "agent_tasks/relationship_coding_20260624-184413"

REL_COLS = [
    "upstream_hardware",
    "upstream_cloud",
    "downstream_integrator",
    "downstream_deployer",
    "downstream_enabler",
    "competitor",
    "is_investor",
    "is_owner",
]

CREATOR_OWNER = {
    "Alibaba": ("BABA", "F2:listed parent of Alibaba model releases", "H"),
    "Google": ("GOOGL", "F2:listed parent of Google model releases", "H"),
    "Meta": ("META", "F2:listed parent of Meta model releases", "H"),
    "Microsoft": ("MSFT", "F2:listed parent of Microsoft model releases", "H"),
}

INVESTORS = {
    ("MSFT", "OpenAI"): ("F1:Microsoft equity investment in OpenAI", "H"),
    ("AMZN", "Anthropic"): ("F1:Amazon equity investment in Anthropic", "H"),
    ("GOOGL", "Anthropic"): ("F1:Google equity investment in Anthropic", "H"),
    ("CRM", "Anthropic"): ("F1:Salesforce Ventures investment in Anthropic", "M"),
    ("MSFT", "Mistral AI"): ("F1:Microsoft minority investment in Mistral AI", "M"),
}

UPSTREAM_HARDWARE = {
    "NVDA": ("R1:GPU and AI accelerator supplier for LLM training and inference", "H"),
    "TSM": ("R1:advanced-node foundry for AI accelerators", "H"),
    "AMD": ("R1:MI accelerators and EPYC data-center CPUs", "H"),
    "AVGO": ("R1:custom AI accelerators and data-center networking", "H"),
    "000660 KS": ("R1:HBM supplier for AI accelerators", "H"),
    "MU": ("R1:HBM and DRAM supplier for AI data centers", "H"),
    "005930 KS": ("R1:HBM DRAM NAND and foundry services for AI hardware", "H"),
    "INTC": ("R1:data-center CPUs and Gaudi AI accelerators", "H"),
    "QCOM": ("R1:edge and on-device AI inference chips", "M"),
    "MRVL": ("R1:custom AI silicon and data-center networking", "H"),
    "NXPI": ("R1:edge AI processors for auto and IoT", "L"),
    "IFX GR": ("R1:power-management components for data centers", "M"),
    "SMCI": ("R1:AI-optimized GPU server systems", "H"),
    "AMBA": ("R1:edge AI vision processors", "L"),
    "STX": ("R1:data-center storage for AI data pipelines", "M"),
    "3443 TT": ("R1:memory modules with indirect AI exposure", "L"),
    "2395 TT": ("R1:industrial edge computing platforms", "L"),
    "2353 TT": ("R1:PC and hardware maker with limited AI infrastructure exposure", "L"),
    "HPE": ("R1:AI-optimized servers and HPC systems", "M"),
    "5803 JP": ("R1:power and industrial systems for data centers", "L"),
}

UPSTREAM_CLOUD = {
    "AMZN": ("R2:AWS cloud infrastructure and AI workloads", "H"),
    "GOOGL": ("R2:Google Cloud and Vertex AI infrastructure", "H"),
    "MSFT": ("R2:Azure cloud infrastructure for AI workloads", "H"),
    "ORCL": ("R2:OCI GPU cloud infrastructure for AI workloads", "H"),
    "BABA": ("R2:Alibaba Cloud infrastructure and AI services", "H"),
}

DOWNSTREAM_INTEGRATOR = {
    "PLTR": ("R3:AIP embeds LLMs in flagship analytics platform", "H"),
    "AI": ("R3:enterprise AI platform is the core product", "H"),
    "SOUN": ("R3:voice AI platform powered by foundation-model capability", "H"),
    "SNOW": ("R3:Cortex AI embeds LLMs in data cloud products", "H"),
    "DDOG": ("R3:AI observability assistant and LLM monitoring features", "M"),
    "NOW": ("R3:Now Assist embeds GenAI across the platform", "H"),
    "ADBE": ("R3:Firefly generative AI integrated into Creative Cloud", "H"),
    "CRM": ("R3:Einstein GPT and Agentforce integrated into CRM platform", "H"),
    "PATH": ("R3:AI-powered automation is central to RPA products", "H"),
    "WDAY": ("R3:AI embedded in HCM and finance platform", "M"),
    "OKTA": ("R3:AI-powered identity security features", "M"),
    "PEGA": ("R3:GenAI Blueprint and process automation features", "M"),
    "CCC": ("R3:AI-powered insurance claims software", "H"),
    "NICE": ("R3:CXone AI for contact-center software", "M"),
    "WIX": ("R3:AI website builder and content generation features", "M"),
    "FTNT": ("R3:FortiAI and AI security features", "M"),
    "ZS": ("R3:AI-powered zero-trust security features", "M"),
    "CYBR": ("R3:AI-based identity security and threat detection", "M"),
    "APP": ("R3:AXON AI ad optimization is core to product", "H"),
    "TTD": ("R3:AI-powered programmatic ad bidding platform", "M"),
    "TDC": ("R3:AI and ML analytics platform features", "M"),
    "TWLO": ("R3:CustomerAI and LLM-powered communication APIs", "M"),
    "TEMN SW": ("R3:GenAI banking software features", "M"),
    "SHOP": ("R3:Shopify Magic and AI commerce features", "M"),
    "SNPS": ("R3:AI-powered EDA tools", "H"),
    "CDNS": ("R3:AI-powered EDA automation tools", "H"),
    "QUBT": ("R3:quantum-AI optimization with marginal LLM relevance", "L"),
    "EXPN LN": ("R3:AI-enhanced data and credit analytics products", "M"),
    "TRI": ("R3:AI-powered professional information products", "M"),
    "WKL NA": ("R3:AI-powered professional workflow products", "M"),
}

DOWNSTREAM_DEPLOYER = {
    "TSLA": ("R4:AI deployed in autonomous driving within automotive business", "H"),
    "UBER": ("R4:AI for routing pricing and platform operations", "H"),
    "NFLX": ("R4:AI recommendation and content operations in streaming", "H"),
    "SNAP": ("R4:AI features in social media and AR products", "H"),
    "GEHC": ("R4:AI diagnostics in medical imaging equipment", "H"),
    "PONY": ("R4:autonomous driving AI within mobility business", "M"),
    "SIE GR": ("R4:industrial AI and digital-twin deployment", "H"),
    "6758 JP": ("R4:AI deployed in gaming imaging and entertainment", "M"),
    "6954 JP": ("R4:AI deployed in electronics and industrial solutions", "M"),
    "6588 JP": ("R4:AI deployed in infrastructure and electronics", "L"),
    "3690 HK": ("R4:AI for delivery optimization and recommendations", "M"),
    "4755 JP": ("R4:AI deployed in e-commerce fintech and internet services", "M"),
    "CSCO": ("R4:AI assistants and optimization in networking products", "M"),
    "ERIC": ("R4:AI-powered telecom network optimization", "M"),
    "STNE": ("R4:AI deployed in payments and financial services", "L"),
    "CRWV": ("R4:AI deployed in healthcare IT workflows", "L"),
    "AMP IM": ("R4:AI deployed in hearing solutions and fitting", "L"),
    "ZBRA": ("R4:AI deployed in warehouse and supply-chain automation", "M"),
    "WRD": ("R4:rugged computing with limited AI deployment relevance", "L"),
    "HUT": ("R4:crypto mining business transitioning toward AI and HPC hosting", "M"),
}

DOWNSTREAM_ENABLER = {
    "ACN": ("R5:IT consulting firm helping enterprises deploy GenAI", "H"),
    "IBM": ("R5:IBM Consulting helps enterprises adopt AI", "H"),
    "6702 JP": ("R5:IT services and AI consulting for enterprise clients", "H"),
    "6701 JP": ("R5:IT services and AI solutions for enterprise clients", "H"),
    "DXC": ("R5:IT outsourcing and managed AI services", "H"),
    "G": ("R5:BPO and process services with AI automation", "H"),
    "TIETO FH": ("R5:IT services and consulting with AI practice", "H"),
    "HPE": ("R5:enterprise AI infrastructure and implementation services", "M"),
}

COMPETITORS = {
    "GOOGL": ("R6:Gemini Imagen and Veo compete across model modalities", "H"),
    "META": ("R6:Llama family competes in foundation models", "H"),
    "AMZN": ("R6:Titan and Nova models compete in foundation models", "M"),
    "MSFT": ("R6:Phi models and OpenAI partnership create model competition", "H"),
    "BABA": ("R6:Qwen family competes in foundation models", "H"),
    "BIDU": ("R6:ERNIE models compete in foundation models", "H"),
    "700 HK": ("R6:Hunyuan models compete in foundation models", "M"),
    "AAPL": ("R6:Apple Intelligence and on-device foundation models", "M"),
    "IBM": ("R6:Granite models compete in enterprise foundation models", "M"),
}

CONF_RANK = {"": 4, "H": 3, "M": 2, "L": 1}


def add(codes, col, reason, conf):
    codes[col] = 1
    return reason, conf


def classify(company_id, creator):
    codes = {col: 0 for col in REL_COLS}
    reasons = []
    confs = []

    owner = CREATOR_OWNER.get(creator)
    is_owner = owner and owner[0] == company_id

    if is_owner:
        reason, conf = add(codes, "is_owner", owner[1], owner[2])
        reasons.append(reason)
        confs.append(conf)

    inv = INVESTORS.get((company_id, creator))
    if inv:
        reason, conf = add(codes, "is_investor", inv[0], inv[1])
        reasons.append(reason)
        confs.append(conf)

    if company_id in UPSTREAM_HARDWARE:
        reason, conf = add(codes, "upstream_hardware", *UPSTREAM_HARDWARE[company_id])
        reasons.append(reason)
        confs.append(conf)

    if company_id in UPSTREAM_CLOUD:
        reason, conf = add(codes, "upstream_cloud", *UPSTREAM_CLOUD[company_id])
        reasons.append(reason)
        confs.append(conf)

    if company_id in COMPETITORS and not is_owner:
        reason, conf = add(codes, "competitor", *COMPETITORS[company_id])
        reasons.append(reason)
        confs.append(conf)

    if company_id == "MSFT" and creator != "Microsoft":
        reason, conf = add(
            codes,
            "downstream_integrator",
            "R3:Microsoft Copilot integrates frontier LLM capability",
            "H",
        )
        reasons.append(reason)
        confs.append(conf)
    elif company_id in DOWNSTREAM_INTEGRATOR:
        reason, conf = add(codes, "downstream_integrator", *DOWNSTREAM_INTEGRATOR[company_id])
        reasons.append(reason)
        confs.append(conf)
    elif company_id in DOWNSTREAM_ENABLER:
        reason, conf = add(codes, "downstream_enabler", *DOWNSTREAM_ENABLER[company_id])
        reasons.append(reason)
        confs.append(conf)
    elif company_id in DOWNSTREAM_DEPLOYER:
        reason, conf = add(codes, "downstream_deployer", *DOWNSTREAM_DEPLOYER[company_id])
        reasons.append(reason)
        confs.append(conf)

    confidence = min(confs, key=lambda c: CONF_RANK[c]) if confs else ""
    return codes, confidence, "; ".join(reasons)


def main():
    df = pd.read_csv(BASE, encoding="gb18030", skiprows=1, dtype=str)
    df = df[df["final_event_id"].astype(str).str.match(r"^FMR-\d{4}$", na=False)].copy()

    creators = sorted(df["true_model_creator"].dropna().unique())
    companies = sorted(df["company_id"].dropna().unique())

    cc_rows = []
    for company_id in companies:
        for creator in creators:
            codes, confidence, justification = classify(company_id, creator)
            row = {"company_id": company_id, "creator": creator}
            row.update(codes)
            row["confidence"] = confidence
            row["justification"] = justification
            cc_rows.append(row)

    cc_cols = ["company_id", "creator"] + REL_COLS + ["confidence", "justification"]
    cc = pd.DataFrame(cc_rows, columns=cc_cols).sort_values(["company_id", "creator"])

    event_rows = []
    cc_lookup = cc.set_index(["company_id", "creator"])
    for _, r in df.iterrows():
        key = (r["company_id"], r["true_model_creator"])
        rel = cc_lookup.loc[key].to_dict()
        row = {"final_event_id": r["final_event_id"], "company_id": r["company_id"]}
        row.update({col: rel[col] for col in REL_COLS})
        row["confidence"] = rel["confidence"]
        row["justification"] = rel["justification"]
        event_rows.append(row)

    event_cols = ["final_event_id", "company_id"] + REL_COLS + ["confidence", "justification"]
    ev = pd.DataFrame(event_rows, columns=event_cols).sort_values(["final_event_id", "company_id"])

    rel_renames = {col: f"rel_{col}" for col in REL_COLS + ["confidence", "justification"]}
    full_rel = ev.rename(columns=rel_renames)
    full = df.merge(full_rel, on=["final_event_id", "company_id"], how="left", validate="one_to_one")

    cc_path = OUT_DIR / "company_creator_relationships_coder_b.csv"
    ev_path = OUT_DIR / "event_company_relationships_coder_b.csv"
    full_path = OUT_DIR / "6.21事件集数据_relationships_coder_b.csv"
    task_cc_path = TASK_DIR / "company_creator_relationships_coder_b.csv"
    task_ev_path = TASK_DIR / "event_company_relationships_coder_b.csv"

    cc.to_csv(cc_path, index=False, encoding="utf-8-sig")
    ev.to_csv(ev_path, index=False, encoding="utf-8-sig")
    full.to_csv(full_path, index=False, encoding="utf-8-sig")
    cc.to_csv(task_cc_path, index=False, encoding="utf-8-sig")
    ev.to_csv(task_ev_path, index=False, encoding="utf-8-sig")

    audit_keys = [
        ("MSFT", "OpenAI", "Microsoft is investor not owner"),
        ("MSFT", "Microsoft", "own Phi events should not be competitor"),
        ("MSFT", "Mistral AI", "minor investment must still be captured"),
        ("GOOGL", "Google", "own Google events should not be competitor"),
        ("GOOGL", "Anthropic", "investor plus cloud plus competitor"),
        ("AMZN", "Anthropic", "investor plus cloud plus competitor"),
        ("CRM", "Anthropic", "Salesforce Ventures investment plus R3"),
        ("BABA", "Alibaba", "own Alibaba events should not be competitor"),
        ("META", "Meta", "own Meta events should not be competitor"),
        ("NVDA", "OpenAI", "NVIDIA upstream hardware not competitor"),
        ("ORCL", "xAI", "Oracle is cloud not model competitor"),
        ("IBM", "OpenAI", "IBM can be R5 and R6"),
        ("HPE", "OpenAI", "HPE can be R1 and R5 with medium confidence"),
        ("HUT", "OpenAI", "Hut 8 R2 versus R4 boundary"),
        ("EXPN LN", "OpenAI", "professional information service coded R3"),
        ("TRI", "OpenAI", "professional information service coded R3"),
        ("WKL NA", "OpenAI", "professional information service coded R3"),
        ("ACN", "OpenAI", "consulting firm coded R5 not R3"),
        ("AAPL", "Google", "Apple competitor with medium confidence"),
        ("700 HK", "Kuaishou", "Tencent is not Kuaishou owner"),
    ]
    audit_rows = []
    for company_id, creator, risk_note in audit_keys:
        rel = cc_lookup.loc[(company_id, creator)].to_dict()
        dims = [col for col in REL_COLS if int(rel[col]) == 1]
        audit_rows.append(
            {
                "scope_key": "company_creator",
                "company_id": company_id,
                "creator": creator,
                "final_event_id": "",
                "relationship_dimension": "|".join(dims),
                "provisional_value": "1" if dims else "0",
                "confidence": rel["confidence"],
                "rule_basis": rel["justification"],
                "risk_note": risk_note,
                "recommended_check": "manual review if changing cloud width or modality-specific coding",
            }
        )
    pd.DataFrame(audit_rows).to_csv(
        TASK_DIR / "relationship_audit_cases.csv", index=False, encoding="utf-8-sig"
    )

    summary = {
        "company_creator_rows": len(cc),
        "event_company_rows": len(ev),
        "full_rows": len(full),
        "companies": len(companies),
        "creators": len(creators),
        "events": df["final_event_id"].nunique(),
    }
    pd.Series(summary).to_csv(TASK_DIR / "build_summary.csv", header=False, encoding="utf-8-sig")


if __name__ == "__main__":
    main()
