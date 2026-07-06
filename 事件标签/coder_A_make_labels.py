#!/usr/bin/env python3
"""Coder A（Claude，2026-07-03）事件标签编码。

规则见 labeling_rules.md。机械字段（modalities / cross_modality /
media_generation / chinese）由数据直接派生；判断字段（reasoning / coding /
multimodal / family / open_weight）逐事件人工判定，判定集合与备注写死在本脚本，
保证可审计、可复跑。Coder B 不得参考本文件。
"""
import csv
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NDS = ROOT / "new data set" / "processed"

IDENTITY = {"exact_or_near_exact", "high", "manual_redirect"}
CHINESE_CREATORS = {"Alibaba", "DeepSeek", "Kimi", "Z AI", "MiniMax",
                    "ByteDance Seed", "KlingAI", "Vidu", "Kuaishou"}

# ---------- 人工判定集合（coder A） ----------

OPEN_WEIGHT = {
    "AIT-2022-10-001", "AIT-2022-12-001", "AIT-2023-07-001", "AIT-2023-07-003",
    "AIT-2024-02-001", "AIT-2024-04-003", "AIT-2024-04-004", "AIT-2024-04-005",
    "AIT-2024-06-001", "AIT-2024-06-003", "AIT-2024-07-002", "AIT-2024-07-007",
    "AIT-2024-08-001", "AIT-2024-09-003", "AIT-2024-09-006", "AIT-2024-09-008",
    "AIT-2024-09-010", "AIT-2024-10-010", "AIT-2024-11-001", "AIT-2024-11-002",
    "AIT-2024-11-005", "AIT-2024-12-008", "AIT-2024-12-009", "AIT-2024-12-013",
    "AIT-2025-01-003", "AIT-2025-01-005", "AIT-2025-02-006", "AIT-2025-03-005",
    "AIT-2025-03-007", "AIT-2025-04-001", "AIT-2025-04-008", "AIT-2025-05-009",
    "AIT-2025-05-012", "AIT-2025-07-005", "AIT-2025-07-006", "AIT-2025-07-007",
    "AIT-2025-08-004", "AIT-2025-08-006", "AIT-2025-09-009", "AIT-2025-11-001",
    "AIT-2025-11-008", "AIT-2025-12-001", "AIT-2025-12-007", "AIT-2025-12-009",
    "AIT-2026-01-003", "AIT-2026-02-005", "AIT-2026-03-003",
}

REASONING = {
    "AIT-2024-09-002", "AIT-2024-11-001", "AIT-2024-12-002", "AIT-2024-12-005",
    "AIT-2025-01-002", "AIT-2025-01-003", "AIT-2025-01-007", "AIT-2025-02-001",
    "AIT-2025-02-002", "AIT-2025-03-001", "AIT-2025-03-005", "AIT-2025-04-002",
    "AIT-2025-04-005", "AIT-2025-04-008", "AIT-2025-05-003", "AIT-2025-05-009",
    "AIT-2025-06-003", "AIT-2025-07-001", "AIT-2025-07-007", "AIT-2025-08-002",
    "AIT-2025-08-004", "AIT-2025-08-005", "AIT-2025-08-006", "AIT-2025-09-007",
    "AIT-2025-09-009", "AIT-2025-10-003", "AIT-2025-11-001", "AIT-2025-11-002",
    "AIT-2025-11-003", "AIT-2025-11-004", "AIT-2025-11-007", "AIT-2025-12-002",
    "AIT-2025-12-003", "AIT-2025-12-004", "AIT-2025-12-007", "AIT-2026-01-003",
    "AIT-2026-02-001", "AIT-2026-02-002", "AIT-2026-02-005", "AIT-2026-02-006",
    "AIT-2026-03-002", "AIT-2026-03-003",
}

CODING = {"AIT-2024-06-003", "AIT-2024-11-002", "AIT-2025-12-009", "AIT-2026-02-002"}

MULTIMODAL = {
    "AIT-2023-03-002", "AIT-2023-12-002", "AIT-2024-02-003", "AIT-2024-03-002",
    "AIT-2024-05-001", "AIT-2024-05-002", "AIT-2024-06-005", "AIT-2024-07-001",
    "AIT-2024-08-002", "AIT-2024-08-004", "AIT-2024-08-006", "AIT-2024-09-006",
    "AIT-2024-09-007", "AIT-2024-10-011", "AIT-2024-11-005", "AIT-2024-12-001",
    "AIT-2024-12-002", "AIT-2024-12-004", "AIT-2024-12-005", "AIT-2025-01-002",
    "AIT-2025-01-005", "AIT-2025-02-001", "AIT-2025-02-002", "AIT-2025-02-004",
    "AIT-2025-02-006", "AIT-2025-02-007", "AIT-2025-03-001", "AIT-2025-04-001",
    "AIT-2025-04-002", "AIT-2025-04-004", "AIT-2025-04-005", "AIT-2025-05-003",
    "AIT-2025-05-012", "AIT-2025-06-003", "AIT-2025-07-001", "AIT-2025-08-005",
    "AIT-2025-09-007", "AIT-2025-10-003", "AIT-2025-11-002", "AIT-2025-11-003",
    "AIT-2025-11-004", "AIT-2025-11-007", "AIT-2025-12-001", "AIT-2025-12-002",
    "AIT-2025-12-003", "AIT-2025-12-004", "AIT-2026-01-003", "AIT-2026-02-001",
    "AIT-2026-02-006",
}

FAMILY = {
    "AIT-2023-07-003", "AIT-2024-02-001", "AIT-2024-03-002", "AIT-2024-04-004",
    "AIT-2024-07-002", "AIT-2024-08-001", "AIT-2024-08-004", "AIT-2024-08-006",
    "AIT-2024-09-002", "AIT-2024-09-003", "AIT-2024-09-006", "AIT-2024-09-007",
    "AIT-2024-10-010", "AIT-2024-12-001", "AIT-2024-12-002", "AIT-2025-02-001",
    "AIT-2025-02-004", "AIT-2025-02-006", "AIT-2025-04-001", "AIT-2025-04-004",
    "AIT-2025-04-008", "AIT-2025-05-003", "AIT-2025-07-005", "AIT-2025-08-004",
    "AIT-2025-11-008", "AIT-2025-12-001", "AIT-2025-12-004", "AIT-2026-02-001",
    "AIT-2026-03-002",
}

NOTES = {
    "AIT-2024-02-001": "SD3 为公告事件，权重后续放出；开源按 SD 家族惯例编 1，家族按 AA 两条记录编 1",
    "AIT-2024-07-007": "Mistral Large 2 权重公开但为非商用研究许可，仍编开源 1",
    "AIT-2024-08-001": "FLUX.1 事件实质为放权重（dev/schnell），旗舰 [pro] 为 API；按事件级规则编 1",
    "AIT-2024-08-006": "事件文本明说三个实验模型（1.5 家族），family=1",
    "AIT-2024-09-008": "Moshi 开源语音对话模型；音频进音频出按单媒体模态处理 multimodal=0",
    "AIT-2024-11-007": "Claude 3.5 Haiku 上线时纯文本，multimodal=0",
    "AIT-2024-12-002": "o1+o1 Pro 同系两档 family=1；含 Sora 跨模态；旗舰 o1 支持图像输入",
    "AIT-2025-01-005": "Janus Pro 统一理解+生成，文本明说 fully multimodal，编 1",
    "AIT-2025-02-001": "旗舰按 AA 指数为 Grok 3 mini Reasoning（AA 评分高于基础版），reasoning=1",
    "AIT-2025-03-003": "GPT-4o 图像生成能力发布，按媒体事件处理，multimodal 按媒体默认 0",
    "AIT-2025-04-005": "o3 与 o4 mini 系列号不同，不按同家族编，family=0",
    "AIT-2025-04-007": "跨厂商视频三连发（Kling/Runway/Vidu），旗舰 Kling 2.0 为中国模型，chinese=1；非同家族",
    "AIT-2025-05-004": "Veo 3 与 Imagen 4 为不同产品线，family=0",
    "AIT-2025-07-005": "旗舰为 2507 Instruct（非思考版）reasoning=0；含 Qwen3-Coder 组件但旗舰非编程模型 coding=0",
    "AIT-2025-11-008": "FLUX.2 旗舰 [pro] 为 API，dev 权重公开，事件级开源编 1",
    "AIT-2025-12-001": "旗舰 Mistral Large 3（多模态、开放权重）；含 Devstral 2 编程系但旗舰非编程 coding=0",
    "AIT-2025-12-003": "Gemini 3.0 Flash 与 2.5 Flash Audio 非同家族 family=0；含语音组件 cross/media=1",
    "AIT-2025-12-004": "Nova 2.0 Pro (medium) 为推理档位 reasoning=1（待 B 核对）；含 Sonic 语音组件",
    "AIT-2025-12-009": "MiniMax-M2.1 定位编程/agent 模型 coding=1；权重在官方 HF 仓库 open=1；无 (Reasoning) 后缀 reasoning=0（待 B 核对）",
    "AIT-2026-01-003": "Kimi K2.5 开源与视觉支持按公开报道编 1（发布时点较新，待 B 核对）",
    "AIT-2026-02-002": "GPT-5.3-Codex 编程旗舰 coding=1，(xhigh) 推理档 reasoning=1；图像输入不确定 multimodal=0",
    "AIT-2026-02-005": "GLM-5 按 Zhipu 开放权重惯例编 open=1（待 B 核对）",
    "AIT-2026-02-006": "该事件已被 D1 决策标记主样本剔除，标签仍照编",
}

MEDIA_MODS = {"text-to-image", "text-to-video", "image-to-video", "image-editing",
              "text-to-speech", "speech-to-text", "speech-to-speech",
              "text-to-video-audio", "image-to-video-audio",
              "music-instrumental", "music-with-vocals"}


def main():
    aa = {r["aa_record_key"]: r for r in csv.DictReader(open(NDS / "aa_models.csv"))}
    matches = [r for r in csv.DictReader(open(NDS / "ai_timeline_aa_model_matches.csv"))
               if r["match_level"] in IDENTITY and r.get("is_comparison_reference") != "True"
               and r["aa_record_key"] in aa]
    mods_by_event = defaultdict(set)
    for r in matches:
        mods_by_event[r["event_id"]].add(aa[r["aa_record_key"]]["aa_modality"])
    rep = {r["event_id"]: r for r in csv.DictReader(open(NDS / "event_aa_metrics.csv"))}
    main_rows = list(csv.DictReader(open(NDS / "final_event_sample_main.csv")))

    out = []
    for ev in sorted(main_rows, key=lambda x: x["event_id"]):
        eid = ev["event_id"]
        mods = sorted(mods_by_event[eid])
        has_lang = "language" in mods
        has_media = any(m in MEDIA_MODS for m in mods)
        creators = {c.strip() for c in ev["aa_creators"].split(";")}
        chinese = bool(creators & CHINESE_CREATORS)
        out.append({
            "event_id": eid,
            "model_names": ev["model_names"],
            "representative_aa_name": rep[eid]["representative_aa_name"],
            "model_modalities": "; ".join(mods),
            "is_cross_modality_release": int(has_lang and has_media),
            "is_model_family": int(eid in FAMILY),
            "is_multimodal": int(eid in MULTIMODAL),
            "is_reasoning_model": int(eid in REASONING),
            "is_coding_model": int(eid in CODING),
            "is_media_generation_model": int(has_media),
            "is_open_weight_or_open_source": int(eid in OPEN_WEIGHT),
            "is_chinese_model": int(chinese),
            "notes": NOTES.get(eid, ""),
            "coder": "A",
            "coded_at": "2026-07-03",
        })

    path = ROOT / "标签" / "coder_A_event_labels_20260703.csv"
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(out[0].keys()), quoting=csv.QUOTE_ALL)
        w.writeheader()
        w.writerows(out)

    from collections import Counter
    for col in ["is_open_weight_or_open_source", "is_reasoning_model", "is_coding_model",
                "is_multimodal", "is_model_family", "is_media_generation_model",
                "is_cross_modality_release", "is_chinese_model"]:
        c = Counter(r[col] for r in out)
        print(f"{col}: 1={c.get(1,0)} 0={c.get(0,0)}")
    print(f"\n{len(out)} events -> {path.name}")


if __name__ == "__main__":
    main()
