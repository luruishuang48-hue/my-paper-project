#!/usr/bin/env python3
"""Build the canonical firm universe from the archived official NDXT snapshot."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "事件集筛选" / "decisions" / "firm_universe_decisions.csv"
CONSTITUENTS = ROOT / "企业列表" / "ndxt45_constituents_20260501.csv"
MANIFEST = ROOT / "企业列表" / "firm_universe_manifest.json"

OFFICIAL_AS_OF = "2026-05-01"
OFFICIAL_SOURCE = "https://www.nasdaq.com/docs/index/ndxt"
NDXT_TICKERS = (
    "ADBE AMD GOOGL GOOG ADI AAPL AMAT APP ARM ASML ADSK AVGO CDNS CTSH "
    "CRWD DDOG DASH FTNT INTC INTU KLAC LRCX MRVL META MCHP MU MSFT MPWR "
    "NVDA NXPI PLTR PANW PDD QCOM ROP SNDK STX SHOP MSTR SNPS TXN TRI WDC "
    "WDAY ZS"
).split()

def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    if len(NDXT_TICKERS) != 45 or len(set(NDXT_TICKERS)) != 45:
        raise RuntimeError("The official NDXT basket must contain 45 unique securities.")

    source = pd.read_csv(CONSTITUENTS, dtype={"official_order": int})
    required = {
        "official_order",
        "ticker",
        "company",
        "official_as_of",
        "official_source",
        "is_sox_robustness",
    }
    if not required.issubset(source.columns):
        raise RuntimeError(f"Missing source columns: {sorted(required - set(source.columns))}")
    source = source.sort_values("official_order").reset_index(drop=True)
    if source["ticker"].tolist() != NDXT_TICKERS:
        raise RuntimeError("The source snapshot does not match the official 45-security order.")
    if source["ticker"].duplicated().any():
        raise RuntimeError("Duplicate ticker in the source snapshot.")
    if set(source["official_as_of"].astype(str)) != {OFFICIAL_AS_OF}:
        raise RuntimeError("Unexpected NDXT snapshot date.")
    if set(source["official_source"].astype(str)) != {OFFICIAL_SOURCE}:
        raise RuntimeError("Unexpected NDXT source URL.")
    source["is_sox_robustness"] = (
        source["is_sox_robustness"].astype(str).str.lower().eq("true")
    )

    rows = []
    for record in source.to_dict("records"):
        ticker = record["ticker"]
        in_sox = bool(record["is_sox_robustness"])
        source_index = "NASDAQ-100 Technology Sector Index (NDXT)"
        index_tag = "ndxt_only"
        reason = f"NDXT constituent as of {OFFICIAL_AS_OF}"
        if in_sox:
            source_index += " + SOX (via SOXX ETF holdings)"
            index_tag = "ndxt_sox"
            reason += "; also included in the SOX/SOXX robustness sample"

        rows.append(
            {
                "ticker": ticker,
                "company": record["company"],
                "gics_sector": "Technology",
                "source_index": source_index,
                "index_tag": index_tag,
                "decision": "include",
                "reason": reason,
            }
        )

    rebuilt = pd.DataFrame(rows)
    if rebuilt["ticker"].tolist() != NDXT_TICKERS:
        raise RuntimeError("NDXT order changed during firm-universe construction.")
    if rebuilt.duplicated("ticker").any():
        raise RuntimeError("Duplicate ticker in rebuilt firm universe.")
    if set(rebuilt["decision"]) != {"include"}:
        raise RuntimeError("All NDXT securities must be included.")

    TARGET.parent.mkdir(parents=True, exist_ok=True)
    rebuilt.to_csv(TARGET, index=False)

    manifest = {
        "official_index": "Nasdaq-100 Technology Sector Index",
        "official_ticker": "NDXT",
        "official_as_of": OFFICIAL_AS_OF,
        "official_source": OFFICIAL_SOURCE,
        "securities": len(rebuilt),
        "issuers": int(
            rebuilt.assign(
                issuer=rebuilt["ticker"].replace({"GOOG": "GOOGL"})
            )["issuer"].nunique()
        ),
        "sox_robustness_securities": int(
            rebuilt["source_index"].str.contains("SOX").sum()
        ),
        "source": str(CONSTITUENTS.relative_to(ROOT)),
        "source_sha256": file_sha256(CONSTITUENTS),
        "target": str(TARGET.relative_to(ROOT)),
        "target_sha256": file_sha256(TARGET),
    }
    MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
