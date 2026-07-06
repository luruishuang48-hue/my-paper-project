#!/usr/bin/env python3
"""Coder B event-label pass for the 2026-07-03 event sample."""

import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NDS = ROOT / "new data set" / "processed"

IDENTITY_MATCH_LEVELS = {"exact_or_near_exact", "high", "manual_redirect"}
MEDIA_MODALITIES = {
    "text-to-image",
    "text-to-video",
    "image-to-video",
    "image-editing",
    "text-to-speech",
    "speech-to-text",
    "speech-to-speech",
    "text-to-video-audio",
    "image-to-video-audio",
    "music-instrumental",
    "music-with-vocals",
}
CHINESE_CREATORS = {
    "Alibaba",
    "DeepSeek",
    "Kimi",
    "Z AI",
    "MiniMax",
    "ByteDance Seed",
    "KlingAI",
    "Vidu",
    "Kuaishou",
}

OPEN_WEIGHT = {
    "AIT-2022-10-001",
    "AIT-2022-12-001",
    "AIT-2023-07-001",
    "AIT-2023-07-003",
    "AIT-2024-04-003",
    "AIT-2024-04-004",
    "AIT-2024-04-005",
    "AIT-2024-06-001",
    "AIT-2024-06-003",
    "AIT-2024-07-002",
    "AIT-2024-07-007",
    "AIT-2024-08-001",
    "AIT-2024-09-003",
    "AIT-2024-09-006",
    "AIT-2024-09-008",
    "AIT-2024-10-010",
    "AIT-2024-11-001",
    "AIT-2024-11-002",
    "AIT-2024-11-005",
    "AIT-2024-12-008",
    "AIT-2024-12-009",
    "AIT-2024-12-013",
    "AIT-2025-01-003",
    "AIT-2025-01-005",
    "AIT-2025-02-006",
    "AIT-2025-03-005",
    "AIT-2025-03-007",
    "AIT-2025-04-001",
    "AIT-2025-04-008",
    "AIT-2025-05-009",
    "AIT-2025-05-012",
    "AIT-2025-07-005",
    "AIT-2025-07-006",
    "AIT-2025-07-007",
    "AIT-2025-08-004",
    "AIT-2025-08-006",
    "AIT-2025-09-009",
    "AIT-2025-11-001",
    "AIT-2025-11-008",
    "AIT-2025-12-001",
    "AIT-2025-12-007",
    "AIT-2025-12-009",
    "AIT-2026-02-005",
    "AIT-2026-03-003",
}

REASONING = {
    "AIT-2024-09-002",
    "AIT-2024-11-001",
    "AIT-2024-12-002",
    "AIT-2024-12-005",
    "AIT-2025-01-002",
    "AIT-2025-01-003",
    "AIT-2025-01-007",
    "AIT-2025-02-001",
    "AIT-2025-02-002",
    "AIT-2025-03-001",
    "AIT-2025-03-005",
    "AIT-2025-03-007",
    "AIT-2025-04-002",
    "AIT-2025-04-005",
    "AIT-2025-04-008",
    "AIT-2025-05-003",
    "AIT-2025-05-009",
    "AIT-2025-06-003",
    "AIT-2025-07-001",
    "AIT-2025-07-007",
    "AIT-2025-08-002",
    "AIT-2025-08-004",
    "AIT-2025-08-005",
    "AIT-2025-08-006",
    "AIT-2025-09-007",
    "AIT-2025-09-009",
    "AIT-2025-10-003",
    "AIT-2025-11-001",
    "AIT-2025-11-002",
    "AIT-2025-11-003",
    "AIT-2025-11-004",
    "AIT-2025-11-007",
    "AIT-2025-12-002",
    "AIT-2025-12-003",
    "AIT-2025-12-007",
    "AIT-2026-01-003",
    "AIT-2026-02-001",
    "AIT-2026-02-002",
    "AIT-2026-02-005",
    "AIT-2026-02-006",
    "AIT-2026-03-002",
    "AIT-2026-03-003",
}

CODING = {
    "AIT-2024-06-003",
    "AIT-2024-11-002",
    "AIT-2025-12-009",
    "AIT-2026-02-002",
}

MULTIMODAL = {
    "AIT-2023-03-002",
    "AIT-2023-12-002",
    "AIT-2024-02-003",
    "AIT-2024-03-002",
    "AIT-2024-05-001",
    "AIT-2024-05-002",
    "AIT-2024-06-005",
    "AIT-2024-07-001",
    "AIT-2024-08-002",
    "AIT-2024-08-004",
    "AIT-2024-08-006",
    "AIT-2024-09-006",
    "AIT-2024-09-007",
    "AIT-2024-10-011",
    "AIT-2024-11-005",
    "AIT-2024-11-007",
    "AIT-2024-12-001",
    "AIT-2024-12-002",
    "AIT-2024-12-004",
    "AIT-2024-12-005",
    "AIT-2025-01-002",
    "AIT-2025-01-005",
    "AIT-2025-02-001",
    "AIT-2025-02-002",
    "AIT-2025-02-004",
    "AIT-2025-02-006",
    "AIT-2025-02-007",
    "AIT-2025-03-001",
    "AIT-2025-04-001",
    "AIT-2025-04-002",
    "AIT-2025-04-004",
    "AIT-2025-04-005",
    "AIT-2025-05-003",
    "AIT-2025-05-012",
    "AIT-2025-06-003",
    "AIT-2025-07-001",
    "AIT-2025-08-002",
    "AIT-2025-08-005",
    "AIT-2025-09-007",
    "AIT-2025-10-003",
    "AIT-2025-11-002",
    "AIT-2025-11-003",
    "AIT-2025-11-004",
    "AIT-2025-11-007",
    "AIT-2025-12-001",
    "AIT-2025-12-002",
    "AIT-2025-12-003",
    "AIT-2025-12-004",
    "AIT-2026-02-001",
    "AIT-2026-02-006",
    "AIT-2026-03-002",
    "AIT-2026-03-003",
}

FAMILY = {
    "AIT-2023-07-003",
    "AIT-2024-02-001",
    "AIT-2024-03-002",
    "AIT-2024-04-004",
    "AIT-2024-07-002",
    "AIT-2024-08-001",
    "AIT-2024-08-004",
    "AIT-2024-08-006",
    "AIT-2024-09-002",
    "AIT-2024-09-003",
    "AIT-2024-09-006",
    "AIT-2024-09-007",
    "AIT-2024-10-010",
    "AIT-2024-12-001",
    "AIT-2024-12-002",
    "AIT-2025-02-001",
    "AIT-2025-02-004",
    "AIT-2025-02-006",
    "AIT-2025-04-001",
    "AIT-2025-04-004",
    "AIT-2025-04-008",
    "AIT-2025-05-003",
    "AIT-2025-07-005",
    "AIT-2025-08-004",
    "AIT-2025-11-008",
    "AIT-2025-12-001",
    "AIT-2025-12-004",
    "AIT-2026-02-001",
    "AIT-2026-03-002",
}

EDGE_NOTES = {
    "AIT-2024-02-001": "SD3 在该事件中是公告和等待名单，未见当日开放权重证据，开放权重按 0。",
    "AIT-2024-09-010": "Mistral Small 事件文本未说明开放权重，按不确定从 0。",
    "AIT-2024-12-002": "同一事件含 Sora 和 o1，两者跨语言与视频模态；o1/o1 Pro 按同系列两档处理。",
    "AIT-2025-03-003": "GPT-4o 图像生成作为媒体事件处理，多模态字段不因文生图自动记 1。",
    "AIT-2025-04-005": "o3 与 o4 mini 都是推理模型，但不是同一模型家族的多档发布。",
    "AIT-2025-04-007": "多厂商视频模型同发，含中国厂商 Kling 和 Vidu，但不是同系列家族发布。",
    "AIT-2025-12-003": "Gemini 3 Flash 和 Gemini 2.5 Flash Audio 属不同版本与模态，家族字段保守记 0。",
    "AIT-2025-12-004": "Nova 2 系列含语言和语音组件，按跨模态、家族和多模态事件处理；未把 medium 档自动视为推理档。",
    "AIT-2026-01-003": "Kimi K2.5 名称和代表记录显示推理属性，事件文本未说明开放权重，开放权重按 0。",
}


def is_false(value):
    return str(value).strip().lower() in {"", "0", "false", "nan", "none"}


def read_csv(path):
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def build_notes(eid, rep_name, modalities, has_media, is_open, is_reasoning,
                is_coding, is_multimodal, is_family, is_chinese):
    if eid in EDGE_NOTES:
        return EDGE_NOTES[eid]

    pieces = []
    if is_family:
        pieces.append("同事件含同系列多规格或多档变体")
    if is_multimodal:
        pieces.append("代表模型支持多模态输入或输出")
    if is_reasoning:
        pieces.append("名称或事件文本指向推理模型")
    if is_coding:
        pieces.append("代表模型主打代码或软件工程任务")
    if has_media:
        pieces.append("事件包含媒体生成模态")
    if is_open:
        pieces.append("事件含开放权重或开源主要模型")
    if is_chinese:
        pieces.append("发布方属于中国模型生态")
    if not pieces:
        pieces.append("未触发家族、多模态、推理、代码、媒体、开放权重或中国生态标签")

    mod_text = "; ".join(modalities) if modalities else "none"
    return f"代表模型为 {rep_name}，AA 模态为 {mod_text}；" + "；".join(pieces) + "。"


def main():
    main_rows = read_csv(NDS / "final_event_sample_main.csv")
    metrics = {r["event_id"]: r for r in read_csv(NDS / "event_aa_metrics.csv")}
    matches = read_csv(NDS / "ai_timeline_aa_model_matches.csv")

    modalities_by_event = defaultdict(set)
    for row in matches:
        if row["match_level"] not in IDENTITY_MATCH_LEVELS:
            continue
        if not is_false(row.get("is_comparison_reference", "")):
            continue
        event_id = row["event_id"]
        if row.get("aa_modality"):
            modalities_by_event[event_id].add(row["aa_modality"])

    out = []
    for event in sorted(main_rows, key=lambda r: r["event_id"]):
        eid = event["event_id"]
        modalities = sorted(modalities_by_event[eid])
        has_language = "language" in modalities
        has_media = any(m in MEDIA_MODALITIES for m in modalities)
        creators = {c.strip() for c in event["aa_creators"].split(";") if c.strip()}
        chinese = bool(creators & CHINESE_CREATORS)
        rep_name = metrics[eid]["representative_aa_name"]

        row = {
            "event_id": eid,
            "model_names": event["model_names"],
            "representative_aa_name": rep_name,
            "model_modalities": "; ".join(modalities),
            "is_cross_modality_release": int(has_language and has_media),
            "is_model_family": int(eid in FAMILY),
            "is_multimodal": int(eid in MULTIMODAL),
            "is_reasoning_model": int(eid in REASONING),
            "is_coding_model": int(eid in CODING),
            "is_media_generation_model": int(has_media),
            "is_open_weight_or_open_source": int(eid in OPEN_WEIGHT),
            "is_chinese_model": int(chinese),
            "notes": build_notes(
                eid,
                rep_name,
                modalities,
                has_media,
                eid in OPEN_WEIGHT,
                eid in REASONING,
                eid in CODING,
                eid in MULTIMODAL,
                eid in FAMILY,
                chinese,
            ),
            "coder": "B",
            "coded_at": "2026-07-03",
        }
        out.append(row)

    path = ROOT / "标签" / "coder_B_event_labels_20260703.csv"
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(out[0].keys()), quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(out)

    for col in [
        "is_cross_modality_release",
        "is_model_family",
        "is_multimodal",
        "is_reasoning_model",
        "is_coding_model",
        "is_media_generation_model",
        "is_open_weight_or_open_source",
        "is_chinese_model",
    ]:
        positives = sum(int(r[col]) for r in out)
        print(f"{col}: 1={positives} 0={len(out) - positives}")
    print(f"{len(out)} events -> {path.name}")


if __name__ == "__main__":
    main()
