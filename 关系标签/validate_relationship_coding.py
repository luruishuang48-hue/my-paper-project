#!/usr/bin/env python3
"""Validate the NDXT45 relationship grid and reproduce coder agreement."""

from __future__ import annotations

import csv
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "关系标签" / "coding_evidence"
FINAL = ROOT / "事件集筛选" / "decisions" / "relationship_decisions.csv"
OUTPUT = EVIDENCE / "agreement_by_dimension.csv"

DIMENSIONS = [
    ("Hardware supplier", "r1_upstream_hardware"),
    ("Cloud platform", "r2_upstream_cloud"),
    ("Downstream integrator", "r3_downstream_integrator"),
    ("Downstream deployer", "r4_downstream_deployer"),
    ("Downstream enabler", "r5_downstream_enabler"),
    ("Competitor", "r6_competitor"),
    ("Investor", "f1_is_investor"),
    ("Listed owner", "f2_is_owner"),
]


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def keyed(rows: list[dict[str, str]]) -> dict[tuple[str, str], dict[str, str]]:
    result = {(row["ticker"], row["creator"]): row for row in rows}
    if len(result) != len(rows):
        raise RuntimeError("Duplicate ticker-creator keys.")
    return result


def kappa(pairs: list[tuple[int, int]]) -> float:
    n = len(pairs)
    observed = sum(a == b for a, b in pairs) / n
    share_a = sum(a for a, _ in pairs) / n
    share_b = sum(b for _, b in pairs) / n
    expected = share_a * share_b + (1 - share_a) * (1 - share_b)
    return 1.0 if expected == 1.0 else (observed - expected) / (1 - expected)


def main() -> None:
    coder_a = keyed(read_rows(EVIDENCE / "coder_A_ndxt45.csv"))
    coder_b = keyed(read_rows(EVIDENCE / "coder_B_ndxt45.csv"))
    final = keyed(read_rows(FINAL))
    if set(coder_a) != set(coder_b) or set(coder_a) != set(final):
        raise RuntimeError("Coder and final-decision grids do not match.")
    if len(final) != 1125:
        raise RuntimeError(f"Expected 1,125 decisions, found {len(final)}.")
    ticker_counts = Counter(ticker for ticker, _ in final)
    creator_counts = Counter(creator for _, creator in final)
    if set(ticker_counts.values()) != {25} or set(creator_counts.values()) != {45}:
        raise RuntimeError("Relationship grid is not 45 securities by 25 creators.")

    rows = []
    total_disagreements = 0
    total_cells = 0
    for label, field in DIMENSIONS:
        pairs = [
            (int(coder_a[key][field]), int(coder_b[key][field]))
            for key in sorted(final)
        ]
        disagreements = sum(a != b for a, b in pairs)
        total_disagreements += disagreements
        total_cells += len(pairs)
        rows.append(
            {
                "position": label,
                "agreement_percent": f"{100 * (1 - disagreements / len(pairs)):.1f}",
                "cohen_kappa": f"{kappa(pairs):.3f}",
                "disagreements": disagreements,
                "cells": len(pairs),
            }
        )
    rows.append(
        {
            "position": "All binary cells",
            "agreement_percent": f"{100 * (1 - total_disagreements / total_cells):.1f}",
            "cohen_kappa": "",
            "disagreements": total_disagreements,
            "cells": total_cells,
        }
    )
    with OUTPUT.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)

    expected_disagreements = {
        "Hardware supplier": 0,
        "Cloud platform": 0,
        "Downstream integrator": 49,
        "Downstream deployer": 27,
        "Downstream enabler": 20,
        "Competitor": 37,
        "Investor": 0,
        "Listed owner": 0,
        "All binary cells": 133,
    }
    observed = {row["position"]: int(row["disagreements"]) for row in rows}
    if observed != expected_disagreements:
        raise RuntimeError(
            f"Agreement results differ from the appendix: {observed}"
        )
    print(
        "relationship_coding_pass "
        f"pairs={len(final)} cells={total_cells} disagreements={total_disagreements}"
    )


if __name__ == "__main__":
    main()
