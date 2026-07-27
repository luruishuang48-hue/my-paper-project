#!/usr/bin/env python3
"""读取 decisions/entity_decisions.csv 并完成模型实体终审。

1. 判定放在独立决策表 CSV 中（entity_id 级），不再硬编码在脚本字典里；
2. 决策支持三种类型：
   - unmatched：从样本排除（附理由）
   - redirect：改指向审计核实过的正确 AA 记录，分号分隔多目标 = 家族全收，
     每个目标展开为一行（entity_id 加 -R1/-R2 后缀），match_level = manual_redirect
   - confirm：确认保留当前算法匹配（AA 仅收录某档位变体等边界判定，留痕）
3. 对未被决策表覆盖的算法匹配（exact/high）应用两条确定性规则：
   - 快照就近：同创建方、同基名（剥离日期括号与测量口径括号）的多条 AA 记录中，
     选 release_date 与事件月最近的快照；仅当当前记录与最近候选都有可解析日期
     且候选严格更近时才切换（避免误动无日期的 experimental 类记录）；
   - 测量口径规范化：同基名同日期的变体中，优先 Reasoning，其次按
     xhigh/max > high > medium > low > minimal 的 effort 排序取最高档。
4. 校验：所有 needs_review 记录必须被决策表覆盖，否则报错列出；决策表中的
   entity_id 必须存在于匹配结果中。

运行顺序：build_dataset.py → 本脚本 → build_final_sample.py
"""
import csv
import re
import unicodedata
from collections import defaultdict
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
PROCESSED = BASE / "processed"
DECISIONS_CSV = BASE / "decisions" / "entity_decisions.csv"

MONTHS = {"january": 1, "february": 2, "march": 3, "april": 4, "may": 5, "june": 6,
          "july": 7, "august": 8, "september": 9, "october": 10, "november": 11, "december": 12}

DATE_PAREN = re.compile(
    r"\((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s*'?\s*(\d{2,4})\)", re.I)
VARIANT_PAREN = re.compile(
    r"\((?:Adaptive Reasoning[^)]*|Non-reasoning[^)]*|Reasoning[^)]*|xhigh|high|medium|low|minimal|"
    r"max effort|experimental|Preview|v\d+)\)", re.I)


def norm_key(name):
    return " ".join((name or "").split()).lower()


def base_name(aa_name):
    s = unicodedata.normalize("NFKC", aa_name or "")
    s = DATE_PAREN.sub(" ", s)
    s = VARIANT_PAREN.sub(" ", s)
    return norm_key(s)


def canon_rank(aa_name):
    parens = " ".join(re.findall(r"\(([^)]*)\)", aa_name or "")).lower()
    score = 0
    if "reasoning" in parens and "non-reasoning" not in parens:
        score += 10
    effort = 0
    for word, pts in (("xhigh", 5), ("max effort", 5), ("high", 4), ("medium", 3), ("low", 2), ("minimal", 1)):
        if word in parens:
            effort = max(effort, pts)
    return score + effort


def eff_ym(record):
    text = (record.get("release_date") or "").strip()
    m = re.match(r"^(\d{4})-(\d{1,2})", text)
    if m:
        return int(m.group(1)), int(m.group(2))
    m = DATE_PAREN.search(record.get("aa_name") or "")
    if m:
        mon = MONTHS.get(next((k for k in MONTHS if k.startswith(m.group(1).lower())), ""), None)
        yr = int(m.group(2))
        if yr < 100:
            yr += 2000
        if mon:
            return yr, mon
    return None


def event_ym(row):
    year = int(row["year"])
    if row.get("month_num"):
        return year, int(row["month_num"])
    mn = (row.get("month") or "").split()[0].lower()
    return year, MONTHS.get(mn, 0)


def ym_dist(a, b):
    return abs((a[0] - b[0]) * 12 + (a[1] - b[1]))


def aa_fields_from(record):
    return {
        "aa_record_key": record["aa_record_key"],
        "aa_name": record["aa_name"],
        "aa_slug": record["aa_slug"],
        "aa_creator": record["aa_creator"],
        "aa_modality": record["aa_modality"],
        "aa_release_date": record["release_date"],
        "aa_url": record["aa_url"],
    }


def main():
    with (PROCESSED / "ai_timeline_aa_model_matches.csv").open() as f:
        reader = csv.DictReader(f)
        fieldnames = list(reader.fieldnames)
        rows = list(reader)
    with (PROCESSED / "aa_models.csv").open() as f:
        aa_rows = list(csv.DictReader(f))
    with DECISIONS_CSV.open() as f:
        decisions = list(csv.DictReader(f))

    aa_by_name = defaultdict(list)
    aa_by_base = defaultdict(list)
    for a in aa_rows:
        aa_by_name[norm_key(a["aa_name"])].append(a)
        aa_by_base[(norm_key(a["aa_creator"]), base_name(a["aa_name"]))].append(a)

    def resolve_target(name):
        cands = aa_by_name.get(norm_key(name), [])
        if not cands:
            raise SystemExit(f"redirect 目标不存在于 AA: {name!r}")
        cands = sorted(cands, key=lambda a: (not a["release_date"], a["aa_modality"] != "language", a["aa_record_key"]))
        return cands[0]

    dec_by_entity = {}
    for d in decisions:
        if d["entity_id"] in dec_by_entity:
            raise SystemExit(f"决策表中 entity_id 重复: {d['entity_id']}")
        dec_by_entity[d["entity_id"]] = d

    missing = [d["entity_id"] for d in decisions if d["entity_id"] not in {r["entity_id"] for r in rows}]
    if missing:
        raise SystemExit(f"决策表中的 entity_id 在匹配结果中不存在: {missing}")

    out_rows = []
    log = []
    for r in rows:
        d = dec_by_entity.get(r["entity_id"])
        if d is None:
            out_rows.append(r)
            continue
        old_level, old_aa = r["match_level"], r["aa_name"]
        if d["decision"] == "unmatched":
            r["match_level"] = "unmatched"
            for k in ("aa_record_key", "aa_name", "aa_slug", "aa_creator", "aa_modality", "aa_release_date", "aa_url"):
                r[k] = ""
            r["needs_review"] = "False"
            out_rows.append(r)
            log.append((r["entity_id"], r["entity_name"], r["event_id"], old_level, old_aa, "unmatched", "", d["reason"]))
        elif d["decision"] == "confirm":
            r["needs_review"] = "False"
            out_rows.append(r)
            log.append((r["entity_id"], r["entity_name"], r["event_id"], old_level, old_aa, "confirm", r["aa_name"], d["reason"]))
        elif d["decision"] == "redirect":
            targets = [resolve_target(t.strip()) for t in d["target_aa_names"].split(";")]
            for i, rec in enumerate(targets, start=1):
                nr = dict(r)
                if len(targets) > 1:
                    nr["entity_id"] = f"{r['entity_id']}-R{i}"
                nr["match_level"] = "manual_redirect"
                nr["needs_review"] = "False"
                nr.update(aa_fields_from(rec))
                out_rows.append(nr)
                log.append((nr["entity_id"], r["entity_name"], r["event_id"], old_level, old_aa, "redirect", rec["aa_name"], d["reason"]))
        else:
            raise SystemExit(f"未知决策类型: {d['decision']}")

    # 校验：needs_review 必须全部被决策覆盖
    leftover = [r for r in out_rows if r.get("needs_review") == "True"]
    if leftover:
        for r in leftover:
            print(f"  未决策: {r['entity_id']} {r['entity_name']} ({r['match_level']})")
        raise SystemExit(f"仍有 {len(leftover)} 条 needs_review 记录未被决策表覆盖")

    # 算法规则：快照就近 + 测量口径规范化（只作用于算法匹配，不动决策行与对比引用）
    decided_ids = set(dec_by_entity)
    rule_count = 0
    for r in out_rows:
        if r["match_level"] not in ("exact_or_near_exact", "high"):
            continue
        if r["entity_id"] in decided_ids or r.get("is_comparison_reference") == "True":
            continue
        current = {"aa_name": r["aa_name"], "release_date": r["aa_release_date"]}
        key = (norm_key(r["aa_creator"]), base_name(r["aa_name"]))
        siblings = aa_by_base.get(key, [])
        if len(siblings) <= 1:
            continue
        ev = event_ym(r)
        cur_ym = eff_ym(current)
        chosen = None
        if cur_ym is not None:
            dated = [(ym_dist(eff_ym(a), ev), -canon_rank(a["aa_name"]), a["aa_name"], a) for a in siblings if eff_ym(a) is not None]
            if dated:
                dated.sort(key=lambda x: x[:3])
                best = dated[0]
                if best[0] < ym_dist(cur_ym, ev) or (best[0] == ym_dist(cur_ym, ev) and -best[1] > canon_rank(r["aa_name"])):
                    chosen = best[3]
        else:
            same_date = [a for a in siblings if eff_ym(a) is None]
            same_date.sort(key=lambda a: (-canon_rank(a["aa_name"]), a["aa_name"]))
            if same_date and canon_rank(same_date[0]["aa_name"]) > canon_rank(r["aa_name"]):
                chosen = same_date[0]
        if chosen is not None and chosen["aa_name"] != r["aa_name"]:
            old = r["aa_name"]
            r.update(aa_fields_from(chosen))
            rule_count += 1
            log.append((r["entity_id"], r["entity_name"], r["event_id"], r["match_level"], old,
                        "rule:snapshot_or_canonical", chosen["aa_name"],
                        "同基名多记录，按事件月就近快照与 Reasoning/最高 effort 口径规则自动选择"))

    with (PROCESSED / "ai_timeline_aa_model_matches.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        w.writeheader()
        w.writerows(out_rows)

    with (PROCESSED / "entity_resolution_log.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["entity_id", "entity_name", "event_id", "algorithmic_level", "algorithmic_aa_name",
                    "action", "final_aa_name", "reason"])
        w.writerows(log)

    from collections import Counter
    print(f"决策应用 {len(dec_by_entity)} 条; 规则修正 {rule_count} 条; 输出 {len(out_rows)} 行")
    print(Counter(r["match_level"] for r in out_rows))


if __name__ == "__main__":
    main()
