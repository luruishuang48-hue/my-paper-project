#!/usr/bin/env python3
"""为 final_event_sample.csv 中每个事件附加官方日度日期。

AiTimeline 本身只精确到月（见 build_final_sample.py 说明），日级日期需要逐事件
检索厂商一方来源（官方博客/技术报告/release notes/模型卡）来确定。检索与判定过程
不可脚本化，因此固化在 decisions/date_decisions.csv 中，逐条附来源 URL 与理由
（与 decisions/entity_decisions.csv 同一约定：判定表是唯一真值，脚本只做合并）。

日期规则：
- 首选厂商官方技术博客或发布公告；没有日度日期时退而使用同厂商官方文档、模型页、
  release notes 或一手技术报告，来源类型记在 date_source_types。
- 同一事件多个组件有不同日期时，official_date 取最早的非空日度日期，
  official_date_all 保留全部。
- 只有月份精度的来源放 official_date_month_candidates，不写入 official_date。
- 找不到日度来源的事件保留 date_status = unresolved，不得用 AiTimeline 月份
  或 AA release_date 顶替（AA release_date 常是入库日而非发布日，见
  build_final_sample.py 说明）。

主样本规则（用户 2026-07-02 拍板）：没有日度官方日期的事件（unresolved 与
month_only）全部剔除，不进回归主样本。剔除名单单独落盘备查，
final_event_sample_main.csv 只含 day_resolved 事件。

已知时区坑：厂商官方页面元数据可能用 UTC，美国下午发布会在 UTC 记为次日
（例如 Anthropic 曾一度误标 Claude 3.5 Sonnet 为 06-21，实为美东 06-20）；
中国厂商官方页面用北京日期，通常等于美东首个可反应交易日，一般无需调整。
official_date 记录的是厂商来源显示的日历日本身，不做时区换算；
"美东首个可反应交易日"的推导是下游 CAR 脚本的职责，不在本文件处理。
"""
import csv
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"
DECISIONS = BASE / "decisions"


def main():
    with (PROCESSED / "final_event_sample.csv").open(newline="", encoding="utf-8") as f:
        events = list(csv.DictReader(f))

    with (DECISIONS / "date_decisions.csv").open(newline="", encoding="utf-8") as f:
        decisions = {r["event_id"]: r for r in csv.DictReader(f)}

    date_fields = [
        "official_date", "official_date_all", "official_date_month_candidates",
        "date_status", "date_confidence", "date_source_urls", "date_source_titles",
        "date_source_types", "date_notes",
    ]

    missing = []
    out_rows = []
    for ev in events:
        d = decisions.get(ev["event_id"])
        if d is None:
            missing.append(ev["event_id"])
            row = {**ev, **{k: "" for k in date_fields}}
            row["date_status"] = "undecided"
        else:
            row = {**ev, **{k: d.get(k, "") for k in date_fields}}
        out_rows.append(row)

    fieldnames = list(events[0].keys()) + date_fields
    out_path = PROCESSED / "final_event_sample_with_dates.csv"
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(out_rows)

    # 主样本：剔除无日度官方日期的事件（用户 2026-07-02 决定）
    main_rows = [r for r in out_rows if r["date_status"] == "day_resolved"]
    dropped = [r for r in out_rows if r["date_status"] != "day_resolved"]
    main_path = PROCESSED / "final_event_sample_main.csv"
    with main_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(main_rows)
    drop_path = PROCESSED / "final_sample_dropped_no_day_date.csv"
    with drop_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(dropped)

    from collections import Counter
    status_counts = Counter(r["date_status"] for r in out_rows)
    print(f"事件总数: {len(out_rows)}")
    print(f"日期状态分布: {dict(status_counts)}")
    if missing:
        print(f"警告：{len(missing)} 个事件在 date_decisions.csv 中无判定记录: {missing}")
    print(f"输出: {out_path.relative_to(BASE)}")
    print(f"主样本（day_resolved）: {len(main_rows)} 事件 -> {main_path.relative_to(BASE)}")
    print(f"剔除（无日度日期）: {len(dropped)} 事件 -> {drop_path.relative_to(BASE)}")


if __name__ == "__main__":
    main()
