#!/usr/bin/env python3
"""Validate the 125-event dual-coder label files and final decisions."""

from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LABEL_DIR = ROOT / "事件标签"
FINAL = ROOT / "事件集筛选" / "decisions" / "event_label_decisions.csv"
BINARY_FIELDS = [
    "is_cross_modality_release",
    "is_model_family",
    "is_multimodal",
    "is_reasoning_model",
    "is_coding_model",
    "is_media_generation_model",
    "is_open_weight_or_open_source",
    "is_chinese_model",
]


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def by_event(rows: list[dict[str, str]]) -> dict[str, dict[str, str]]:
    result = {row["event_id"]: row for row in rows}
    if len(result) != len(rows):
        raise RuntimeError("Duplicate event_id.")
    return result


def main() -> None:
    coder_a = by_event(read_rows(LABEL_DIR / "coder_A_event_labels.csv"))
    coder_b = by_event(read_rows(LABEL_DIR / "coder_B_event_labels.csv"))
    final = by_event(read_rows(FINAL))
    discrepancies = read_rows(
        LABEL_DIR / "coder_AB_discrepancies.csv"
    )
    if len(final) != 125 or set(coder_a) != set(final) or set(coder_b) != set(final):
        raise RuntimeError("Event-label files do not share the same 125 events.")
    for source_name, source in [
        ("coder A", coder_a),
        ("coder B", coder_b),
        ("final", final),
    ]:
        for event_id, row in source.items():
            for field in BINARY_FIELDS:
                if row[field] not in {"0", "1"}:
                    raise RuntimeError(
                        f"{source_name} has invalid {field} for {event_id}."
                    )
    observed = {
        (event_id, field)
        for event_id in final
        for field in BINARY_FIELDS
        if coder_a[event_id][field] != coder_b[event_id][field]
    }
    recorded = {(row["event_id"], row["field"]) for row in discrepancies}
    if observed != recorded or len(recorded) != 10:
        raise RuntimeError("Recorded event-label discrepancies are incomplete.")
    for row in discrepancies:
        if final[row["event_id"]][row["field"]] != row["user_final"]:
            raise RuntimeError(
                f"Final label does not match adjudication for {row['event_id']}."
            )
    print(
        "event_labels_pass "
        f"events={len(final)} binary_cells={len(final) * len(BINARY_FIELDS)} "
        f"disagreements={len(recorded)}"
    )


if __name__ == "__main__":
    main()
