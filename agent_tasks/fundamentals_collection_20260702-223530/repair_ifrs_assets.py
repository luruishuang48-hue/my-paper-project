#!/usr/bin/env python3
import csv
from pathlib import Path

import sec_companyfacts_recon as recon


TASK_DIR = Path(__file__).resolve().parent
STATUS_CSV = TASK_DIR / "sec_companyfacts_status.csv"
FIELD_CSV = TASK_DIR / "sec_companyfacts_field_coverage.csv"

ASSET_TAGS = [
    ("ifrs-full", "Assets"),
    ("ifrs-full", "CurrentAssets"),
    ("ifrs-full", "NoncurrentAssets"),
]


with STATUS_CSV.open(newline="", encoding="utf-8") as f:
    status_rows = list(csv.DictReader(f))

with FIELD_CSV.open(newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    field_rows = list(reader)
    fieldnames = reader.fieldnames

existing = {
    (r["ticker"], r["taxonomy"], r["tag"], r["group"])
    for r in field_rows
}

for row in status_rows:
    if "ifrs-full" not in row["taxonomy_namespaces"]:
        continue
    data, status, err = recon.fetch_json(recon.SEC_COMPANYFACTS_URL.format(cik10=row["cik"]))
    if err or status != 200:
        continue
    facts = data.get("facts", {})
    found_assets = False
    for taxonomy, tag in ASSET_TAGS:
        concept = recon.get_concept(facts, taxonomy, tag)
        summary = recon.summarize_concept(concept)
        if not summary["present"]:
            continue
        found_assets = True
        key = (row["ticker"], taxonomy, tag, "assets")
        if key not in existing:
            field_rows.append({
                "ticker": row["ticker"],
                "company": row["company"],
                "cik": row["cik"],
                "taxonomy": taxonomy,
                "tag": tag,
                "group": "assets",
                "present": summary["present"],
                "units": summary["units"],
                "fact_count": summary["fact_count"],
                "quarterly_2022_2026_count": summary["quarterly_2022_2026_count"],
                "forms": summary["forms"],
                "has_frame": summary["has_frame"],
                "recent_fact": summary["recent_fact"],
            })
            existing.add(key)
    if found_assets:
        row["assets_any"] = "True"
        row["assets_primary"] = "ifrs-full:Assets"

with STATUS_CSV.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=status_rows[0].keys())
    writer.writeheader()
    writer.writerows(status_rows)

with FIELD_CSV.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(field_rows)

print("updated IFRS assets")
