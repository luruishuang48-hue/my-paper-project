#!/usr/bin/env python3
import gzip
import json
import ssl
import time
from urllib.request import Request, urlopen


CIKS = {
    "ASX": "0001122411",
    "CCEP": "0001650107",
    "FER": "0001468522",
    "TRI": "0001075124",
    "TSM": "0001046179",
    "UMC": "0001033767",
}

ctx = ssl._create_unverified_context()

for ticker, cik in CIKS.items():
    req = Request(
        f"https://data.sec.gov/api/xbrl/companyfacts/CIK{cik}.json",
        headers={
            "User-Agent": "Codex academic research contact chen@example.com",
            "Accept-Encoding": "gzip",
        },
    )
    with urlopen(req, timeout=45, context=ctx) as resp:
        data = resp.read()
        if resp.headers.get("Content-Encoding") == "gzip":
            data = gzip.decompress(data)
    facts = json.loads(data.decode("utf-8")).get("facts", {}).get("ifrs-full", {})
    hits = [
        tag for tag in facts
        if tag in {
            "Assets",
            "CurrentAssets",
            "NoncurrentAssets",
            "Equity",
            "EquityAttributableToOwnersOfParent",
            "NumberOfSharesOutstanding",
        }
        or "SharesOutstanding" in tag
        or ("Share" in tag and "Outstanding" in tag)
    ]
    print(ticker, hits[:40])
    time.sleep(0.2)
