#!/usr/bin/env python3
"""为主样本每个事件对接 AA 能力指标，多模型合并事件取旗舰代表。

代表模型规则见 decisions/analysis_design_decisions.md T8。
- 事件内所有身份匹配（exact_or_near_exact / high / manual_redirect、非对比基准）
  的 AA 记录中：
  - 只要有记录带 aa_intelligence_index，取指数最高者为代表（LLM 旗舰），
    aa_metric_type = "llm"；
  - 否则取 media Elo 最高者（媒体旗舰），aa_metric_type = "media"；
  - 两者皆无（目前仅 2 个 speech-to-speech 事件：Moshi、Grok Voice Agent）
    取第一条记录留名字，指标缺失，aa_metric_type = "none"。
- LLM 优先于媒体：混合事件（如同日发 LLM + 图像模型）以 LLM 旗舰为代表，
  与"上游算力需求"假说的信息含量对应。

AA 指标是抓取快照时点的值。输出保留 AA 记录名和发布日期，便于核对。
"""
import csv
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"

IDENTITY_LEVELS = {"exact_or_near_exact", "high", "manual_redirect"}

METRIC_COLS = [
    "aa_intelligence_index", "aa_coding_index", "aa_math_index",
    "mmlu_pro", "gpqa", "livecodebench", "aime",
    "elo", "rank", "ci95", "appearances",
    "price_1m_input_tokens", "price_1m_output_tokens", "price_1m_blended_3_to_1",
    "median_output_tokens_per_second", "median_time_to_first_token_seconds",
    "median_time_to_first_answer_token",
]


def fnum(s: str):
    s = (s or "").strip()
    if not s:
        return None
    try:
        return float(s)
    except ValueError:
        return None


def main():
    with (PROCESSED / "final_event_sample_main.csv").open(newline="", encoding="utf-8") as f:
        events = list(csv.DictReader(f))
    with (PROCESSED / "aa_models.csv").open(newline="", encoding="utf-8") as f:
        aa = {r["aa_record_key"]: r for r in csv.DictReader(f)}
    with (PROCESSED / "ai_timeline_aa_model_matches.csv").open(newline="", encoding="utf-8") as f:
        matches = [
            r for r in csv.DictReader(f)
            if r["match_level"] in IDENTITY_LEVELS
            and r.get("is_comparison_reference") != "True"
            and r["aa_record_key"] in aa
        ]

    by_event = {}
    for r in matches:
        by_event.setdefault(r["event_id"], []).append(aa[r["aa_record_key"]])

    out = []
    for ev in events:
        eid = ev["event_id"]
        records = by_event.get(eid, [])
        # 事件内去重（多个实体写法映射同一 AA 记录）
        records = list({r["aa_record_key"]: r for r in records}.values())

        llm = [(fnum(r["aa_intelligence_index"]), r) for r in records]
        llm = [(v, r) for v, r in llm if v is not None]
        media = [(fnum(r["elo"]), r) for r in records]
        media = [(v, r) for v, r in media if v is not None]

        if llm:
            _, rep = max(llm, key=lambda x: x[0])
            mtype = "llm"
        elif media:
            _, rep = max(media, key=lambda x: x[0])
            mtype = "media"
        elif records:
            rep = records[0]
            mtype = "none"
        else:
            rep, mtype = None, "unmatched"

        row = {
            "event_id": eid,
            "aa_metric_type": mtype,
            "aa_matched_record_count": len(records),
            "aa_matched_names": "; ".join(r["aa_name"] for r in records),
            "representative_aa_record_key": rep["aa_record_key"] if rep else "",
            "representative_aa_name": rep["aa_name"] if rep else "",
            "representative_aa_creator": rep["aa_creator"] if rep else "",
            "representative_aa_modality": rep["aa_modality"] if rep else "",
            "representative_aa_release_date": rep["release_date"] if rep else "",
            "representative_selection_rule": (
                "max aa_intelligence_index (llm flagship)" if mtype == "llm"
                else "max media elo (media flagship)" if mtype == "media"
                else "first matched record, no comparable metric"
            ),
        }
        for c in METRIC_COLS:
            row[c] = rep[c] if rep else ""
        out.append(row)

    fieldnames = list(out[0].keys())
    out_path = PROCESSED / "event_aa_metrics.csv"
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(out)

    from collections import Counter
    types = Counter(r["aa_metric_type"] for r in out)
    n_int = sum(1 for r in out if r["aa_intelligence_index"])
    print(f"事件数: {len(out)}")
    print(f"代表模型类型: {dict(types)}")
    print(f"aa_intelligence_index 非缺失: {n_int}")
    print(f"输出: {out_path.relative_to(BASE)}")


if __name__ == "__main__":
    main()
