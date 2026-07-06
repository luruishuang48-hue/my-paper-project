#!/usr/bin/env python3
"""Coder A（Claude，2026-07-03）关系编码：108 公司 × 25 发布方 = 2,700 对。

规则见 relationship_codebook.md（v1.0，8 维：R1-R6 + F1/F2）。
结构性维度（R1-R5）按公司档案编，跨发布方不变；R6 按模态匹配规则逐对生成；
F1/F2 按已知股权/母公司关系逐对指定。全部判断固化于本脚本，可审计可复跑。
Coder B 不得参考本文件。

codebook 未覆盖的扩展判定（见 README 第 3 节，待仲裁）：
半导体设备/材料商按 R1 扩展编 M；电力公司编 0 留 note；Cisco 按 R1(a) 编；
NVIDIA 时变投资 F1=L。
"""
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UNIVERSE = ROOT / "new data set" / "decisions" / "firm_universe_decisions.csv"
OUT = ROOT / "关系标签" / "coder_A_company_creator_20260703.csv"

# ---------- 发布方档案：竞争模态 ----------
CREATORS = {
    "OpenAI":            {"llm", "image", "video", "speech"},
    "Google":            {"llm", "image", "video", "speech", "music"},
    "Anthropic":         {"llm"},
    "DeepSeek":          {"llm", "image"},
    "Alibaba":           {"llm", "image", "video"},
    "xAI":               {"llm", "video", "speech"},
    "Meta":              {"llm"},
    "Mistral":           {"llm"},
    "Microsoft":         {"llm"},
    "Kimi":              {"llm"},
    "Z AI":              {"llm"},
    "Amazon":            {"llm", "image", "video", "speech"},
    "MiniMax":           {"llm"},
    "Stability.ai":      {"image", "music"},
    "Midjourney":        {"image"},
    "Runway":            {"video"},
    "Black Forest Labs": {"image"},
    "Suno":              {"music"},
    "Udio":              {"music"},
    "Kyutai":            {"speech"},
    "Recraft":           {"image"},
    "KlingAI":           {"video"},
    "Vidu":              {"video"},
    "ElevenLabs":        {"speech"},
    "ByteDance Seed":    {"image", "video"},
}
CHINESE_CREATORS = {"DeepSeek", "Alibaba", "Kimi", "Z AI", "MiniMax", "KlingAI", "Vidu", "ByteDance Seed"}

# F2 owner：发布方 → 上市主体 ticker
OWNERS = {"Google": {"GOOGL", "GOOG"}, "Meta": {"META"}, "Microsoft": {"MSFT"}, "Amazon": {"AMZN"}}
# F1 investor：(ticker, creator) → (conf, note)
INVESTORS = {
    ("MSFT", "OpenAI"):    ("H", "微软累计投资 OpenAI 约 130 亿美元，2025 重组后持股约 27%"),
    ("MSFT", "Mistral"):   ("M", "微软 2024 年对 Mistral 1500 万欧元小额投资"),
    ("AMZN", "Anthropic"): ("H", "亚马逊对 Anthropic 累计投资约 80 亿美元"),
    ("GOOGL", "Anthropic"): ("H", "Alphabet 对 Anthropic 投资约 20-30 亿美元"),
    ("GOOG", "Anthropic"): ("H", "同 GOOGL（共享类股）"),
    ("NVDA", "OpenAI"):    ("L", "2025-09 宣布最高 1000 亿美元投资意向，时变：仅适用其后事件，待仲裁"),
    ("NVDA", "xAI"):       ("L", "2025-12 参与 xAI 融资轮，时变：仅适用其后事件，待仲裁"),
}

# ---------- 公司档案 ----------
# 每家：R1-R5 = (0/1, conf, 理由)（最多一个 downstream 维度为 1，按 codebook 决策流程），
# competes = {模态: conf}（用于 R6），notes = 全局备注。
P = {}
def firm(t, r1=None, r2=None, r3=None, r4=None, r5=None, competes=None, note=""):
    P[t] = dict(r1=r1, r2=r2, r3=r3, r4=r4, r5=r5, competes=competes or {}, note=note)

# --- 上游硬件 ---
firm("NVDA", r1=("H", "全球 AI 训练/推理 GPU 主导供应商"),
     note="codebook 明确：不编 competitor，市场对其定价通过硬件需求渠道")
firm("AMD",  r1=("H", "MI 系列 AI 加速器与 EPYC 数据中心 CPU"))
firm("TSM",  r1=("H", "NVIDIA/AMD/Apple AI 芯片先进制程独家代工"))
firm("AVGO", r1=("H", "定制 AI 加速器（谷歌 TPU）与数据中心网络芯片"))
firm("MU",   r1=("H", "HBM/DRAM，AI 数据中心内存"))
firm("INTC", r1=("H", "Xeon 数据中心 CPU、Gaudi 加速器与代工"))
firm("MRVL", r1=("H", "定制 AI 加速器与数据中心互连"))
firm("ARM",  r1=("H", "数据中心 CPU 架构 IP（Grace/Graviton 基于 Arm）"))
firm("ALAB", r1=("H", "AI 服务器 PCIe/CXL/以太网互连芯片，直接绑定 GPU 集群"))
firm("CRDO", r1=("H", "AI 数据中心高速连接（AEC/SerDes）"))
firm("MPWR", r1=("H", "GPU/AI 服务器供电模块（NVIDIA 平台电源方案）"))
firm("QCOM", r1=("M", "端侧/边缘 AI 推理芯片"))
firm("LITE", r1=("M", "数据中心光模块/光器件，AI 网络用"))
firm("MTSI", r1=("M", "数据中心光电与高速模拟器件"))
firm("SNDK", r1=("M", "NAND 闪存，AI 数据管线存储"))
firm("WDC",  r1=("M", "数据中心存储"))
firm("STX",  r1=("M", "数据中心 HDD（codebook 原表）"))
firm("ASX",  r1=("M", "封测 OSAT，先进封装参与 AI 芯片供应链"))
firm("ASML", r1=("M", "EUV 光刻设备，AI 芯片制造必经；设备商 R1 扩展判定，待仲裁"))
firm("AMAT", r1=("M", "沉积/刻蚀等制造设备；设备商 R1 扩展判定，待仲裁"))
firm("LRCX", r1=("M", "刻蚀设备；设备商 R1 扩展判定，待仲裁"))
firm("KLAC", r1=("M", "检测/量测设备；设备商 R1 扩展判定，待仲裁"))
firm("TER",  r1=("M", "半导体测试设备（含 AI 加速器测试）；扩展判定，待仲裁"))
firm("ENTG", r1=("M", "半导体材料与污染控制；扩展判定，待仲裁"))
firm("CSCO", r1=("M", "数据中心交换机/AI 集群以太网符合 R1(a)；旧 codebook 归 R4，待仲裁"))
firm("NXPI", r1=("L", "边缘 AI 车规处理器，与 LLM 训练关联弱（codebook 原表）"))
firm("ADI",  r1=("L", "模拟/电源芯片，数据中心间接暴露"))
firm("TXN",  r1=("L", "模拟/嵌入式芯片，间接暴露"))
firm("MCHP", r1=("L", "MCU/模拟，间接暴露"))
firm("ON",   r1=("L", "功率/图像传感，汽车为主"))
firm("UMC",  r1=("L", "成熟制程代工，AI 暴露低"))

# --- 上游云 ---
firm("MSFT", r2=("H", "Azure 主要云平台，独家托管 OpenAI 工作负载"),
     competes={"llm": "H", "speech": "M"},
     note="Phi/MAI 自研模型构成 LLM 竞争；语音 M")
firm("GOOGL", r2=("H", "GCP 主要云平台，TPU 与 Vertex AI"),
     competes={"llm": "H", "image": "H", "video": "H", "speech": "M", "music": "M"})
firm("GOOG", r2=("H", "同 GOOGL（共享类股）"),
     competes={"llm": "H", "image": "H", "video": "H", "speech": "M", "music": "M"})
firm("AMZN", r2=("H", "AWS 最大云平台，Bedrock 托管 LLM"),
     competes={"llm": "M", "image": "M", "video": "M", "speech": "M"},
     note="Nova 系列构成多模态竞争（M）")
firm("CRWV", r2=("H", "GPU 专业云，AI 训练/推理算力供应商"))
firm("NBIS", r2=("H", "GPU 云（Nebius），AI 算力供应商"))

# --- 下游集成 R3 ---
firm("PLTR", r3=("H", "AIP 平台直接集成 LLM（codebook 原表）"))
firm("ADBE", r3=("H", "Firefly 生成式 AI 是 Creative Cloud 核心差异化（codebook 原表）"),
     competes={"image": "H", "video": "M"},
     note="Firefly 自研图像/视频基础模型，对媒体发布方构成竞争")
firm("APP",  r3=("H", "AXON AI 广告引擎是核心产品（codebook 原表）"))
firm("SNPS", r3=("H", "Synopsys.ai AI EDA（codebook 原表）"))
firm("CDNS", r3=("H", "Cerebrus AI EDA（codebook 原表）"))
firm("TRI",  r3=("H", "CoCounsel 法律 AI 旗舰产品（codebook 边界案例按 R3）"))
firm("DDOG", r3=("M", "Bits AI 与 LLM 可观测性（codebook 原表）"))
firm("WDAY", r3=("M", "Workday AI 嵌入 HCM 平台（codebook 原表）"))
firm("FTNT", r3=("M", "FortiAI 威胁检测（codebook 原表）"))
firm("SHOP", r3=("M", "Shopify Magic AI 商务功能（codebook 原表）"))
firm("INTU", r3=("M", "Intuit Assist 嵌入 TurboTax/QuickBooks 全线"))
firm("ADSK", r3=("M", "Autodesk AI 嵌入设计软件"))
firm("CRWD", r3=("M", "Charlotte AI 安全助手嵌入平台"))
firm("PANW", r3=("M", "Precision AI 安全平台"))
firm("AXON", r3=("M", "Draft One 等 GenAI 产品成为新核心产品线"))

# --- 下游部署 R4 ---
firm("TSLA", r4=("H", "自动驾驶 AI，核心是汽车/能源（codebook 原表）"))
firm("NFLX", r4=("H", "推荐引擎/内容生产 AI，核心是流媒体（codebook 原表）"))
firm("GEHC", r4=("H", "AI 医学影像诊断，核心是医疗设备（codebook 原表）"))
firm("META", r4=("M", "广告/推荐系统大规模使用自研 AI，核心是社交平台"),
     competes={"llm": "H"},
     note="Llama 家族主要开源 LLM 竞争者（codebook 原表）")
firm("AAPL", r4=("M", "Apple Intelligence 嵌入设备生态，核心是消费硬件"),
     competes={"llm": "M"},
     note="端侧自研模型，新兴竞争者（codebook 原表 M）")
firm("ABNB", r4=("M", "AI 搜索/客服，核心是住宿平台"))
firm("BKNG", r4=("M", "AI 行程规划/客服，核心是旅行平台"))
firm("DASH", r4=("M", "AI 物流调度/推荐，核心是配送平台"))
firm("MELI", r4=("M", "电商推荐/金融风控 AI，核心是电商平台"))
firm("PDD",  r4=("M", "电商推荐/广告 AI，核心是电商平台"))
firm("WMT",  r4=("M", "供应链 AI 与 GenAI 购物助手，核心是零售"))
firm("SBUX", r4=("M", "Deep Brew AI 运营优化，核心是餐饮零售"))
firm("EA",   r4=("M", "游戏开发/内容生成 AI，核心是游戏"))
firm("ISRG", r4=("M", "手术机器人 AI 辅助，核心是医疗设备"))
firm("ADP",  r4=("M", "ADP Assist GenAI 嵌入 HCM/薪酬服务"))
firm("CMCSA", r4=("L", "宽带/媒体运营 AI 辅助"))
firm("TMUS", r4=("L", "网络运维/客服 AI"))
firm("WBD",  r4=("L", "流媒体推荐 AI"))
firm("TTWO", r4=("L", "游戏 AI 应用"))
firm("MAR",  r4=("L", "AI 客服/定价，核心是酒店"))
firm("PYPL", r4=("L", "支付风控 AI 与 agentic commerce 试点"))
firm("PAYX", r4=("L", "薪酬服务 AI 助手"))
firm("PCAR", r4=("L", "自动驾驶卡车合作（Aurora）"))
firm("HON",  r4=("L", "工业软件（Forge）AI 功能，核心是工业集团"))
firm("DXCM", r4=("L", "CGM 算法含 AI，核心是医疗器械"))

# --- 全零（无可归类结构关系；对照组） ---
POWER_NOTE = "电力公司：AI 数据中心电力需求受益方，codebook 无对应维度，编 0 待仲裁"
for t, n in [
    ("AEP", POWER_NOTE), ("EXC", POWER_NOTE), ("XEL", POWER_NOTE),
    ("CEG", POWER_NOTE + "；与微软签核电 PPA 供 AI 数据中心，暴露最直接"),
    ("ALNY", "AI 药物发现合作存在，与 LLM 事件结构关系弱"), ("AMGN", "同 ALNY"),
    ("GILD", "同 ALNY"), ("REGN", "同 ALNY"), ("VRTX", "同 ALNY"),
    ("MSTR", "比特币储备公司，BI 遗留业务 AI 暴露弱"),
    ("BKR", ""), ("CCEP", ""), ("COST", ""), ("CPRT", ""), ("CSX", ""),
    ("CTAS", ""), ("FANG", ""), ("FAST", ""), ("FER", ""), ("IDXX", ""),
    ("KDP", ""), ("KHC", ""), ("LIN", ""), ("MDLZ", ""), ("MNST", ""),
    ("ODFL", ""), ("ORLY", ""), ("PEP", ""), ("RKLB", ""), ("ROP", "垂直软件组合，公开 AI 部署证据不足"),
    ("ROST", ""),
]:
    firm(t, note=n)

CONF_ORDER = {"H": 3, "M": 2, "L": 1}


def main():
    with UNIVERSE.open(newline="", encoding="utf-8") as f:
        firms = list(csv.DictReader(f))
    tickers = [r["ticker"] for r in firms]
    missing = [t for t in tickers if t not in P]
    extra = [t for t in P if t not in tickers]
    assert not missing, f"缺公司档案: {missing}"
    assert not extra, f"多余档案: {extra}"

    rows = []
    for fr in firms:
        t = fr["ticker"]
        prof = P[t]
        for creator, cmods in CREATORS.items():
            just = []
            row = {"ticker": t, "company": fr["company"], "creator": creator}
            # R1-R5 结构维度
            for dim, col in [("r1", "r1_upstream_hardware"), ("r2", "r2_upstream_cloud"),
                             ("r3", "r3_downstream_integrator"), ("r4", "r4_downstream_deployer"),
                             ("r5", "r5_downstream_enabler")]:
                v = prof[dim]
                if v:
                    conf, reason = v
                    # 对中国发布方，美系硬件供应受出口管制，R1 置信度降一档
                    if dim == "r1" and creator in CHINESE_CREATORS and conf == "H":
                        conf = "M"
                        reason += "（对中国发布方受出口管制，置信度降档）"
                    row[col], row[col + "_conf"] = 1, conf
                    just.append(f"{col}: {reason}")
                else:
                    row[col], row[col + "_conf"] = 0, ""
            # R6 竞争者：模态匹配（owner 对不编 competitor，codebook R2 交互规则）
            is_owner_pair = t in OWNERS.get(creator, set())
            overlap = {m: c for m, c in prof["competes"].items() if m in cmods}
            if overlap and not is_owner_pair:
                conf = max(overlap.values(), key=lambda c: CONF_ORDER[c])
                row["r6_competitor"], row["r6_competitor_conf"] = 1, conf
                just.append(f"r6: 竞争模态 {sorted(overlap)} 与发布方 {creator} 重叠")
            else:
                row["r6_competitor"], row["r6_competitor_conf"] = 0, ""
                if overlap and is_owner_pair:
                    just.append("r6: 为发布方上市主体，按 codebook 不编自竞争")
            # F2 owner 优先；owner 时 F1 不再编（自己不算投资自己）
            if t in OWNERS.get(creator, set()):
                row["f2_is_owner"], row["f2_is_owner_conf"] = 1, "H"
                row["f1_is_investor"], row["f1_is_investor_conf"] = 0, ""
                just.append(f"f2: {creator} 的上市主体")
            else:
                row["f2_is_owner"], row["f2_is_owner_conf"] = 0, ""
                inv = INVESTORS.get((t, creator))
                if inv:
                    row["f1_is_investor"], row["f1_is_investor_conf"] = 1, inv[0]
                    just.append(f"f1: {inv[1]}")
                else:
                    row["f1_is_investor"], row["f1_is_investor_conf"] = 0, ""
            note = prof["note"]
            row["justification"] = "; ".join(just) if just else (note or "无可归类结构关系")
            if note and just:
                row["justification"] += f"; 备注: {note}"
            row["coder"] = "A"
            row["coded_at"] = "2026-07-03"
            rows.append(row)

    cols = list(rows[0].keys())
    with OUT.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols, quoting=csv.QUOTE_ALL)
        w.writeheader()
        w.writerows(rows)

    from collections import Counter
    print(f"{len(rows)} 对（{len(tickers)} 公司 × {len(CREATORS)} 发布方）")
    for col in ["r1_upstream_hardware", "r2_upstream_cloud", "r3_downstream_integrator",
                "r4_downstream_deployer", "r5_downstream_enabler", "r6_competitor",
                "f1_is_investor", "f2_is_owner"]:
        c = Counter(r[col] for r in rows)
        print(f"  {col}: 1={c.get(1, 0)}")
    zero = sum(1 for r in rows if all(r[c] == 0 for c in
               ["r1_upstream_hardware", "r2_upstream_cloud", "r3_downstream_integrator",
                "r4_downstream_deployer", "r5_downstream_enabler", "r6_competitor",
                "f1_is_investor", "f2_is_owner"]))
    print(f"  全零对: {zero}")


if __name__ == "__main__":
    main()
