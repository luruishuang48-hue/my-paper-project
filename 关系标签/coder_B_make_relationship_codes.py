#!/usr/bin/env python3
"""Coder B company-creator relationship coding for the 2026-07-03 sample."""

import csv
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
DECISIONS = ROOT / "new data set" / "decisions"
PROCESSED = ROOT / "new data set" / "processed"
OUT = ROOT / "关系标签" / "coder_B_company_creator_20260703.csv"

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
FIELDNAMES = ["company_id", "creator", *REL_COLS, "confidence", "justification"]
CONF_RANK = {"H": 3, "M": 2, "L": 1}

HARDWARE = {
    "ADI": ("M", "R1:analog and power semiconductors used in AI data-center hardware"),
    "ALAB": ("H", "R1:high-speed connectivity chips for AI servers and cloud infrastructure"),
    "AMAT": ("M", "R1:semiconductor equipment enabling AI chip fabrication"),
    "AMD": ("H", "R1:GPU accelerators and data-center CPUs for AI workloads"),
    "ARM": ("M", "R1:CPU and accelerator IP used across data-center and edge AI chips"),
    "ASML": ("M", "R1:lithography equipment enabling advanced AI chip production"),
    "ASX": ("M", "R1:semiconductor assembly and packaging for advanced chips"),
    "AVGO": ("H", "R1:custom AI accelerators and data-center networking chips"),
    "CRDO": ("H", "R1:high-speed connectivity products for AI data centers"),
    "CSCO": ("M", "R1:data-center switches and networking equipment for AI clusters"),
    "ENTG": ("M", "R1:materials and process products for semiconductor fabrication"),
    "INTC": ("H", "R1:data-center CPUs and AI accelerators"),
    "KLAC": ("M", "R1:process-control equipment enabling advanced chip manufacturing"),
    "LITE": ("M", "R1:optical components used in data-center networking"),
    "LRCX": ("M", "R1:semiconductor equipment enabling AI chip production"),
    "MCHP": ("M", "R1:embedded and data-center semiconductor components"),
    "MPWR": ("M", "R1:power-management chips for AI servers and accelerators"),
    "MRVL": ("H", "R1:custom AI silicon, interconnect, storage and networking chips"),
    "MTSI": ("M", "R1:high-speed analog and optical semiconductors for data centers"),
    "MU": ("H", "R1:HBM and DRAM used in AI accelerators and servers"),
    "NVDA": ("H", "R1:dominant GPU and AI accelerator supplier"),
    "NXPI": ("L", "R1:edge AI processors with weaker LLM infrastructure exposure"),
    "ON": ("M", "R1:power and sensing semiconductors used in AI hardware supply chains"),
    "QCOM": ("M", "R1:on-device AI inference chips and edge AI processors"),
    "SNDK": ("M", "R1:data-center flash storage for AI data pipelines"),
    "STX": ("M", "R1:data-center storage for AI data pipelines"),
    "TER": ("M", "R1:semiconductor test equipment for AI chip production"),
    "TSM": ("H", "R1:advanced-node foundry for AI chips"),
    "TXN": ("M", "R1:analog and power chips used across data-center hardware"),
    "UMC": ("M", "R1:semiconductor foundry services for chip supply chains"),
    "WDC": ("M", "R1:data-center storage for AI data pipelines"),
}

CLOUD = {
    "AMZN": ("H", "R2:AWS provides cloud and AI infrastructure"),
    "CRWV": ("H", "R2:CoreWeave provides GPU cloud infrastructure for AI workloads"),
    "GOOG": ("H", "R2:Google Cloud provides AI infrastructure"),
    "GOOGL": ("H", "R2:Google Cloud provides AI infrastructure"),
    "MSFT": ("H", "R2:Azure provides cloud and AI infrastructure"),
    "NBIS": ("M", "R2:Nebius provides GPU cloud infrastructure for AI workloads"),
}

INTEGRATOR = {
    "ADBE": ("H", "R3:Firefly and generative AI are embedded in creative software products"),
    "ADSK": ("M", "R3:AI design features are embedded in Autodesk software"),
    "APP": ("H", "R3:AI ad optimization is central to the platform"),
    "AXON": ("M", "R3:AI drafting and evidence-analysis tools are core public-safety software features"),
    "CDNS": ("H", "R3:AI-powered EDA tools are core design software inputs"),
    "CRWD": ("M", "R3:AI security assistants and detection features are embedded in the platform"),
    "DDOG": ("M", "R3:AI observability and LLM-monitoring features are embedded in the platform"),
    "FTNT": ("M", "R3:AI security features are embedded in cybersecurity products"),
    "INTU": ("M", "R3:AI assistants are embedded in tax and small-business software"),
    "PANW": ("M", "R3:AI security operations are embedded in the platform"),
    "PLTR": ("H", "R3:AIP directly integrates foundation models into Palantir products"),
    "SHOP": ("M", "R3:AI commerce tools are embedded in Shopify products"),
    "SNPS": ("H", "R3:AI-powered EDA tools are core design software inputs"),
    "TRI": ("M", "R3:AI is embedded in legal, tax and professional information products"),
    "WDAY": ("M", "R3:AI is embedded in HCM and finance software"),
}

DEPLOYER = {
    "AAPL": ("M", "R4:Apple Intelligence and on-device AI augment a hardware and services business"),
    "ABNB": ("M", "R4:AI improves travel search, matching and customer operations"),
    "ADP": ("M", "R4:AI augments payroll and HCM operations"),
    "BKNG": ("M", "R4:AI improves travel search, recommendation and customer service"),
    "CMCSA": ("M", "R4:AI augments media, broadband and customer-service operations"),
    "CSCO": ("M", "R4:AI assistants augment networking and security products"),
    "DASH": ("M", "R4:AI improves delivery logistics and marketplace operations"),
    "DXCM": ("M", "R4:AI augments medical-device analytics"),
    "EA": ("M", "R4:AI augments game development and live-service operations"),
    "GEHC": ("H", "R4:AI augments medical imaging and diagnostics"),
    "HON": ("M", "R4:AI augments industrial automation and building systems"),
    "IDXX": ("M", "R4:AI augments veterinary diagnostics"),
    "ISRG": ("M", "R4:AI augments robotic surgery workflows"),
    "MELI": ("M", "R4:AI improves commerce, payments and logistics operations"),
    "NFLX": ("H", "R4:AI recommendation and production tools augment streaming operations"),
    "PAYX": ("M", "R4:AI augments payroll and HR services"),
    "PDD": ("M", "R4:AI improves e-commerce recommendation and operations"),
    "PYPL": ("M", "R4:AI augments payments, risk and fraud operations"),
    "TMUS": ("M", "R4:AI augments telecom network and customer operations"),
    "TSLA": ("H", "R4:AI is used in autonomy while the core business remains autos and energy"),
    "TTWO": ("M", "R4:AI augments game development and live operations"),
    "WBD": ("M", "R4:AI augments media production and streaming operations"),
    "WMT": ("M", "R4:AI improves retail logistics, search and customer operations"),
}

BROAD_COMPETITORS = {
    "AAPL": ("M", "R6:Apple Intelligence and Apple foundation models compete in consumer AI"),
    "AMZN": ("M", "R6:Titan and Nova models compete with foundation-model creators"),
    "GOOG": ("H", "R6:Gemini, Imagen and Veo compete across AI model markets"),
    "GOOGL": ("H", "R6:Gemini, Imagen and Veo compete across AI model markets"),
    "META": ("H", "R6:Llama and Meta foundation models compete across AI model markets"),
    "MSFT": ("H", "R6:Phi models and OpenAI partnership give Microsoft competing model exposure"),
}

MEDIA_CREATORS = {
    "Amazon",
    "Black Forest Labs",
    "ByteDance Seed",
    "Google",
    "KlingAI",
    "Midjourney",
    "OpenAI",
    "Recraft",
    "Runway",
    "Stability.ai",
    "Vidu",
}
MEDIA_COMPETITORS = {
    "ADBE": ("M", "R6:Firefly competes with image and video generation model creators"),
}

OWNER = {
    ("AMZN", "Amazon"): ("H", "F2:listed parent of Amazon Nova releases"),
    ("GOOG", "Google"): ("H", "F2:Alphabet share class is listed parent of Google releases"),
    ("GOOGL", "Google"): ("H", "F2:Alphabet share class is listed parent of Google releases"),
    ("META", "Meta"): ("H", "F2:listed parent of Meta model releases"),
    ("MSFT", "Microsoft"): ("H", "F2:listed parent of Microsoft model releases"),
}

INVESTOR = {
    ("AMZN", "Anthropic"): ("H", "F1:Amazon has a documented equity investment in Anthropic"),
    ("GOOG", "Anthropic"): ("H", "F1:Alphabet has a documented equity investment in Anthropic"),
    ("GOOGL", "Anthropic"): ("H", "F1:Alphabet has a documented equity investment in Anthropic"),
    ("MSFT", "Mistral"): ("H", "F1:Microsoft has a documented investment in Mistral AI"),
    ("MSFT", "OpenAI"): ("H", "F1:Microsoft has a documented investment and profit interest in OpenAI"),
    ("NVDA", "OpenAI"): ("L", "F1:NVIDIA investment is time-varying and applies only after the 2025-09 announcement"),
    ("NVDA", "xAI"): ("L", "F1:NVIDIA investment is time-varying and applies only after the 2025-12 announcement"),
}


def add_flag(row, col, conf, reason, reasons, confs):
    row[col] = 1
    reasons.append(reason)
    confs.append(conf)


def min_conf(confs):
    if not confs:
        return ""
    return min(confs, key=lambda c: CONF_RANK[c])


def main():
    firms = pd.read_csv(DECISIONS / "firm_universe_decisions.csv")
    firms = firms[firms["decision"].eq("include")].copy()
    creators = sorted({
        c.strip()
        for s in pd.read_csv(PROCESSED / "final_event_sample_main.csv")["aa_creators"].dropna()
        for c in str(s).split(";")
        if c.strip()
    })

    rows = []
    for _, firm in firms.sort_values("ticker").iterrows():
        ticker = firm["ticker"]
        for creator in creators:
            row = {k: 0 for k in REL_COLS}
            row["company_id"] = ticker
            row["creator"] = creator
            reasons = []
            confs = []

            if (ticker, creator) in OWNER:
                add_flag(row, "is_owner", *OWNER[(ticker, creator)], reasons, confs)

            if (ticker, creator) in INVESTOR:
                add_flag(row, "is_investor", *INVESTOR[(ticker, creator)], reasons, confs)

            if ticker in HARDWARE:
                add_flag(row, "upstream_hardware", *HARDWARE[ticker], reasons, confs)

            if ticker in CLOUD:
                add_flag(row, "upstream_cloud", *CLOUD[ticker], reasons, confs)

            if ticker in BROAD_COMPETITORS and row["is_owner"] == 0:
                add_flag(row, "competitor", *BROAD_COMPETITORS[ticker], reasons, confs)

            if ticker in MEDIA_COMPETITORS and creator in MEDIA_CREATORS and row["is_owner"] == 0:
                add_flag(row, "competitor", *MEDIA_COMPETITORS[ticker], reasons, confs)

            if ticker == "MSFT" and creator != "Microsoft":
                add_flag(
                    row,
                    "downstream_integrator",
                    "H",
                    "R3:Copilot and Microsoft software directly integrate foundation-model capabilities",
                    reasons,
                    confs,
                )
            elif ticker in INTEGRATOR:
                add_flag(row, "downstream_integrator", *INTEGRATOR[ticker], reasons, confs)
            elif ticker in DEPLOYER:
                add_flag(row, "downstream_deployer", *DEPLOYER[ticker], reasons, confs)

            row["confidence"] = min_conf(confs)
            row["justification"] = "; ".join(reasons)
            rows.append(row)

    with OUT.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(rows)

    print(f"firms={len(firms)} creators={len(creators)} rows={len(rows)} -> {OUT.name}")
    for col in REL_COLS:
        print(f"{col}: {sum(r[col] for r in rows)}")


if __name__ == "__main__":
    main()
