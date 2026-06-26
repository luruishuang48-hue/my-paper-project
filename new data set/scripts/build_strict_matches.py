#!/usr/bin/env python3
import csv
import re
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path


BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"
REPORTS = BASE / "reports"

ENTITIES_CSV = PROCESSED / "ai_timeline_model_entities.csv"
AA_MODELS_CSV = PROCESSED / "aa_models.csv"
STATUS_CSV = PROCESSED / "ai_timeline_aa_strict_match_status.csv"
STRICT_CSV = PROCESSED / "ai_timeline_aa_strict_matches.csv"
NAME_EXACT_CSV = PROCESSED / "ai_timeline_aa_name_exact_matches.csv"
REPORT_MD = REPORTS / "strict_match_report.md"

MONTHS = {
    "january": 1,
    "february": 2,
    "march": 3,
    "april": 4,
    "may": 5,
    "june": 6,
    "july": 7,
    "august": 8,
    "september": 9,
    "october": 10,
    "november": 11,
    "december": 12,
}


def read_csv(path):
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def write_csv(path, rows, fieldnames):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def strip_aa_date_parentheses(value):
    """Remove AA snapshot labels like GPT-4o (May '24), not model variant labels."""
    return re.sub(
        r"\s*\((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|"
        r"January|February|March|April|May|June|July|August|September|October|November|December)"
        r"\.?\s*'?\d{2,4}\)\s*",
        " ",
        value,
        flags=re.I,
    )


def canonical_model_name(value):
    text = unicodedata.normalize("NFKC", value or "")
    text = text.replace("‑", "-").replace("–", "-").replace("—", "-").replace("−", "-")
    text = text.replace("’", "'").replace("‘", "'")
    text = strip_aa_date_parentheses(text)
    text = re.sub(r"\bmodels?\b", " ", text, flags=re.I)
    text = text.lower()
    return re.sub(r"[^a-z0-9]+", "", text)


def ai_year_month(row):
    year = int(row["year"])
    if row.get("month_num"):
        return year, int(row["month_num"])
    month_name = (row.get("month") or "").split()[0].lower()
    return year, MONTHS.get(month_name, 0)


def release_year_month(value):
    match = re.match(r"^(\d{4})-(\d{1,2})", value or "")
    if not match:
        return None
    return int(match.group(1)), int(match.group(2))


def format_year_month(year_month):
    if not year_month:
        return ""
    return f"{year_month[0]:04d}-{year_month[1]:02d}"


def candidate_summary(rows):
    parts = []
    for row in rows:
        release = row.get("release_date") or "no_date"
        creator = row.get("aa_creator") or ""
        modality = row.get("aa_modality") or ""
        parts.append(f"{row.get('aa_name', '')} | {release} | {creator} | {modality}")
    return "; ".join(parts)


def choose_candidate(rows):
    return sorted(
        rows,
        key=lambda row: (
            row.get("release_date") or "",
            row.get("aa_modality") or "",
            row.get("aa_creator") or "",
            row.get("aa_name") or "",
        ),
    )[0]


def build():
    entities = read_csv(ENTITIES_CSV)
    aa_rows = read_csv(AA_MODELS_CSV)

    aa_by_canonical = defaultdict(list)
    for row in aa_rows:
        key = canonical_model_name(row.get("aa_name"))
        if key:
            aa_by_canonical[key].append(row)

    status_rows = []
    strict_rows = []
    name_exact_rows = []

    for entity in entities:
        canonical = canonical_model_name(entity.get("entity_name"))
        exact_name_candidates = aa_by_canonical.get(canonical, [])
        ai_ym = ai_year_month(entity)
        same_month = [
            row for row in exact_name_candidates
            if release_year_month(row.get("release_date")) == ai_ym
        ]

        if exact_name_candidates:
            name_exact_status = "name_exact_keep"
            if same_month:
                time_match_status = "same_month"
            else:
                time_match_status = "time_mismatch_or_missing"
        else:
            name_exact_status = "drop_no_exact_name"
            time_match_status = "no_exact_name"

        if same_month:
            chosen = choose_candidate(same_month)
            status = "strict_keep"
            reason = "normalized_name_exact_and_same_calendar_month"
        elif exact_name_candidates:
            chosen = choose_candidate(exact_name_candidates)
            status = "drop_name_exact_time_mismatch"
            reason = "normalized_name_exact_but_release_month_not_same_or_missing"
        else:
            chosen = {}
            status = "drop_no_exact_name"
            reason = "no_aa_model_with_exact_normalized_name"

        out = {
            "name_exact_status": name_exact_status,
            "time_match_status": time_match_status,
            "strict_status": status,
            "strict_reason": reason,
            "entity_id": entity.get("entity_id", ""),
            "event_id": entity.get("event_id", ""),
            "ai_model_name": entity.get("entity_name", ""),
            "ai_year_month": format_year_month(ai_ym),
            "ai_year": entity.get("year", ""),
            "ai_month": entity.get("month", ""),
            "event_text": entity.get("event_text", ""),
            "canonical_name": canonical,
            "aa_name": chosen.get("aa_name", ""),
            "aa_creator": chosen.get("aa_creator", ""),
            "aa_modality": chosen.get("aa_modality", ""),
            "aa_release_date": chosen.get("release_date", ""),
            "aa_url": chosen.get("aa_url", ""),
            "exact_name_candidate_count": len(exact_name_candidates),
            "same_month_candidate_count": len(same_month),
            "same_month_candidates": candidate_summary(same_month),
            "all_exact_name_candidates": candidate_summary(exact_name_candidates),
        }
        status_rows.append(out)
        if status == "strict_keep":
            strict_rows.append(out)
        if name_exact_status == "name_exact_keep":
            name_exact_rows.append(out)

    fields = [
        "name_exact_status",
        "time_match_status",
        "strict_status",
        "strict_reason",
        "entity_id",
        "event_id",
        "ai_model_name",
        "ai_year_month",
        "ai_year",
        "ai_month",
        "aa_name",
        "aa_creator",
        "aa_modality",
        "aa_release_date",
        "aa_url",
        "canonical_name",
        "exact_name_candidate_count",
        "same_month_candidate_count",
        "same_month_candidates",
        "all_exact_name_candidates",
        "event_text",
    ]
    write_csv(STATUS_CSV, status_rows, fields)
    write_csv(STRICT_CSV, strict_rows, fields)
    write_csv(NAME_EXACT_CSV, name_exact_rows, fields)

    counts = Counter(row["strict_status"] for row in status_rows)
    name_counts = Counter(row["name_exact_status"] for row in status_rows)
    time_counts = Counter(row["time_match_status"] for row in status_rows)
    year_counts = Counter(row["ai_year"] for row in strict_rows)
    name_year_counts = Counter(row["ai_year"] for row in name_exact_rows)
    lines = [
        "# AI Timeline-AA 名字严格匹配报告",
        "",
        "当前主样本规则。",
        "",
        "- 只要求 AI Timeline 模型名和 AA 模型名规范化后完全相同。",
        "- 发布时间不再决定删留，只作为参考列保留。",
        "- 规范化只忽略大小写、空格、标点、连字符、撇号、通用词 model/models，以及 AA 快照日期标签，例如 `(May '24)`。",
        "- 不允许同系列、相邻版本、同公司或模糊替代。",
        "",
        "## 数量",
        "",
        f"- 检查 AI Timeline 模型实体 {len(status_rows)} 条",
        f"- 名字严格对上 {name_counts['name_exact_keep']} 条",
        f"- 其中时间同月 {time_counts['same_month']} 条",
        f"- 其中时间不同月或 AA 缺少时间 {time_counts['time_mismatch_or_missing']} 条",
        f"- AA 没有严格同名模型 {name_counts['drop_no_exact_name']} 条",
        "",
        "## 名字严格对上的年份分布",
        "",
    ]
    for year in sorted(name_year_counts):
        lines.append(f"- {year} 年 {name_year_counts[year]} 条")
    lines.extend(
        [
            "",
            "## 旧口径参考",
            "",
            f"- 名字和月份都对上 {counts['strict_keep']} 条",
            f"- 名字对上但月份不对或缺少时间 {counts['drop_name_exact_time_mismatch']} 条",
            "",
            "## 输出文件",
            "",
            f"- 名字严格对上的主表 `{NAME_EXACT_CSV}`",
            f"- 全部状态表 `{STATUS_CSV}`",
            f"- 名字和月份都对上的旧口径表 `{STRICT_CSV}`",
        ]
    )
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"checked={len(status_rows)}")
    print(f"name_exact_keep={name_counts['name_exact_keep']}")
    print(f"strict_keep={counts['strict_keep']}")
    print(f"name_exact_time_mismatch={counts['drop_name_exact_time_mismatch']}")
    print(f"no_exact_name={counts['drop_no_exact_name']}")
    print(STATUS_CSV)
    print(NAME_EXACT_CSV)
    print(STRICT_CSV)
    print(REPORT_MD)


if __name__ == "__main__":
    build()
