#!/usr/bin/env python3
"""从终审后的 ai_timeline_aa_model_matches.csv 构建最终事件级研究样本。

替代旧的 build_strict_matches.py 独立字符串匹配链路：那条链路的 canonical_model_name
不处理创建方前缀（"R1" vs "DeepSeek R1"）和 AA 的 Reasoning/Non-reasoning 后缀，
系统性误杀了 DeepSeek R1、Claude 4 系列等重要事件。

身份匹配规则：只采用 build_dataset.py 打分匹配 + resolve_entities.py
（读取 decisions/entity_decisions.csv 决策表）终审后，match_level 为
exact_or_near_exact / high / manual_redirect 的记录——这一步已经用字符相似度、
词集合、创建方、模态、版本号、快照日期、测量口径等信号验证过。

事件内去重：同一事件中多个实体映射到同一 AA 记录时（如 R1 与 R1-Zero、
Claude 3.7 与 Claude 3.7 Thinking 规范化后同记录），只保留一条，
避免事件级指标重复计数。

对比基准实体排除：AiTimeline 的加粗规则不区分"本次发布的模型"和"文本中作为能力
对比基准提及的其他公司模型"（例如 "Alibaba unveiled Qwen2.5-Max...surpasses...
GPT-4o, Claude 3.5"）。is_comparison_reference=True 的实体一律不进最终样本，
避免把无关公司错误地归入某次发布事件。

事件日期：直接采用 AiTimeline 的年月（该数据源本身只精确到月），不使用 AA 的
release_date 做过滤或替换——AA 日期核实后发现大量早期/非语言模态模型是批量补录的
入库日期而非真实发布日（例如 Midjourney 各版本全标 2023-12），拿它做质量门槛会
系统性剔除早期样本、引入新的选择性偏差。日级精度问题留给后续任务单独处理。

事件级聚合：同一 event_id 下所有身份匹配通过、且非对比基准的模型实体合并为一行。
"""
import csv
from collections import defaultdict
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"

IDENTITY_LEVELS = {"exact_or_near_exact", "high", "manual_redirect"}


def main():
    with (PROCESSED / "ai_timeline_aa_model_matches.csv").open() as f:
        rows = list(csv.DictReader(f))

    identity_matched = [
        r for r in rows
        if r["match_level"] in IDENTITY_LEVELS and r.get("is_comparison_reference") != "True"
    ]
    comparison_excluded = [
        r for r in rows
        if r["match_level"] in IDENTITY_LEVELS and r.get("is_comparison_reference") == "True"
    ]

    by_event = defaultdict(list)
    for r in identity_matched:
        by_event[r["event_id"]].append(r)

    event_rows = []
    for event_id, raw_members in sorted(by_event.items()):
        # 事件内按 AA 记录去重（同一模型的多个实体写法只算一条）
        seen_records = set()
        members = []
        for m in raw_members:
            if m["aa_record_key"] in seen_records:
                continue
            seen_records.add(m["aa_record_key"])
            members.append(m)
        first = members[0]
        event_rows.append(
            {
                "event_id": event_id,
                "ai_year": first["year"],
                "ai_month": first["month"],
                "model_names": "; ".join(dict.fromkeys(m["entity_name"] for m in members)),
                "aa_names": "; ".join(m["aa_name"] for m in members),
                "aa_release_dates": "; ".join(m["aa_release_date"] for m in members),
                "aa_creators": "; ".join(sorted(set(m["aa_creator"] for m in members if m["aa_creator"]))),
                "model_count": len(members),
                "event_text": first["event_text"],
            }
        )

    fieldnames = [
        "event_id", "ai_year", "ai_month", "model_names", "aa_names",
        "aa_release_dates", "aa_creators", "model_count", "event_text",
    ]
    with (PROCESSED / "final_event_sample.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(event_rows)

    diag_fields = [
        "entity_id", "entity_name", "event_id", "year", "month",
        "match_level", "aa_name", "event_text",
    ]
    with (PROCESSED / "final_sample_excluded_comparison_refs.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=diag_fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(comparison_excluded)

    print(f"身份匹配（exact/high/manual）实体数（含对比基准）: {len(identity_matched) + len(comparison_excluded)}")
    print(f"  排除的对比基准实体: {len(comparison_excluded)}")
    print(f"  进入样本的实体: {len(identity_matched)}")
    print(f"最终事件级样本数: {len(event_rows)}")


if __name__ == "__main__":
    main()
