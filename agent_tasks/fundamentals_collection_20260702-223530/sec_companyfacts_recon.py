#!/usr/bin/env python3
import csv
import gzip
import json
import ssl
import time
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[2]
TASK_DIR = ROOT / "agent_tasks" / "fundamentals_collection_20260702-223530"
INPUT_UNIVERSE = ROOT / "CAR" / "metadata" / "firm_universe_for_car.csv"
REPORT = TASK_DIR / "sec_recon.md"
STATUS_CSV = TASK_DIR / "sec_companyfacts_status.csv"
FIELD_CSV = TASK_DIR / "sec_companyfacts_field_coverage.csv"
TICKER_MAP_JSON = TASK_DIR / "sec_company_tickers.json"
RAW_DIR = TASK_DIR / "sec_companyfacts_samples"

UA = "Codex academic research contact chen@example.com"
SEC_TICKERS_URL = "https://www.sec.gov/files/company_tickers.json"
SEC_DOCS_URL = "https://www.sec.gov/search-filings/edgar-application-programming-interfaces"
SEC_COMPANYFACTS_URL = "https://data.sec.gov/api/xbrl/companyfacts/CIK{cik10}.json"

try:
    import certifi

    SSL_CONTEXT = ssl.create_default_context(cafile=certifi.where())
except Exception:
    SSL_CONTEXT = ssl._create_unverified_context()

FIELD_GROUPS = {
    "assets": [
        ("us-gaap", "Assets"),
        ("us-gaap", "AssetsCurrent"),
        ("ifrs-full", "Assets"),
        ("ifrs-full", "CurrentAssets"),
        ("ifrs-full", "NoncurrentAssets"),
    ],
    "equity": [
        ("us-gaap", "StockholdersEquity"),
        ("us-gaap", "StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest"),
        ("us-gaap", "StockholdersEquityAttributableToParent"),
        ("ifrs-full", "Equity"),
        ("ifrs-full", "EquityAttributableToOwnersOfParent"),
        ("ifrs-full", "EquityAndLiabilities"),
    ],
    "shares": [
        ("dei", "EntityCommonStockSharesOutstanding"),
        ("us-gaap", "CommonStocksOutstanding"),
        ("us-gaap", "CommonStockSharesOutstanding"),
        ("us-gaap", "WeightedAverageNumberOfSharesOutstandingBasic"),
        ("us-gaap", "WeightedAverageNumberOfDilutedSharesOutstanding"),
        ("ifrs-full", "NumberOfSharesOutstanding"),
    ],
    "document_focus": [
        ("dei", "DocumentFiscalYearFocus"),
        ("dei", "DocumentFiscalPeriodFocus"),
    ],
}

REQUIRED_EXACT = [
    ("us-gaap", "Assets"),
    ("us-gaap", "StockholdersEquity"),
    ("dei", "EntityCommonStockSharesOutstanding"),
    ("dei", "DocumentFiscalYearFocus"),
    ("dei", "DocumentFiscalPeriodFocus"),
]


def fetch_json(url, sleep_after=0.12):
    req = Request(url, headers={"User-Agent": UA, "Accept-Encoding": "gzip"})
    try:
        with urlopen(req, timeout=45, context=SSL_CONTEXT) as resp:
            data = resp.read()
            status = resp.status
            if resp.headers.get("Content-Encoding") == "gzip":
                data = gzip.decompress(data)
    except HTTPError as exc:
        return None, exc.code, str(exc)
    except URLError as exc:
        return None, None, str(exc)
    finally:
        time.sleep(sleep_after)
    return json.loads(data.decode("utf-8")), status, None


def load_universe():
    with INPUT_UNIVERSE.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    for row in rows:
        row["ticker_norm"] = row["ticker"].replace(".", "-").upper()
    return rows


def load_sec_ticker_map():
    data, status, err = fetch_json(SEC_TICKERS_URL)
    if err:
        raise RuntimeError(f"Could not fetch SEC ticker map: {status} {err}")
    TICKER_MAP_JSON.write_text(json.dumps(data, indent=2), encoding="utf-8")
    mapping = {}
    for item in data.values():
        ticker = item["ticker"].upper()
        mapping[ticker] = {
            "cik": int(item["cik_str"]),
            "cik10": str(item["cik_str"]).zfill(10),
            "sec_title": item["title"],
        }
    return mapping


def get_concept(facts, taxonomy, tag):
    return facts.get(taxonomy, {}).get(tag)


def summarize_concept(concept):
    if not concept:
        return {
            "present": False,
            "label": "",
            "description": "",
            "units": "",
            "fact_count": 0,
            "quarterly_2022_2026_count": 0,
            "recent_fact": "",
            "forms": "",
            "has_frame": False,
        }
    units = concept.get("units", {})
    fact_count = sum(len(v) for v in units.values())
    forms = Counter()
    recent = None
    recent_key = None
    quarterly = 0
    has_frame = False
    for unit, facts in units.items():
        for fact in facts:
            forms[fact.get("form", "")] += 1
            has_frame = has_frame or bool(fact.get("frame"))
            fy = fact.get("fy")
            fp = fact.get("fp")
            if isinstance(fy, int) and 2022 <= fy <= 2026 and fp in {"Q1", "Q2", "Q3", "Q4", "FY"}:
                quarterly += 1
            if fact.get("end"):
                candidate_key = (fact.get("end", ""), fact.get("filed", ""), unit, len(str(fact.get("val", ""))))
                if recent_key is None or candidate_key > recent_key:
                    recent_key = candidate_key
                    recent = (unit, fact)
    recent_text = ""
    if recent:
        unit = recent[0]
        fact = recent[1]
        recent_text = (
            f"{fact.get('end','')} filed {fact.get('filed','')} "
            f"{fact.get('form','')} {fact.get('fy','')}{fact.get('fp','')} "
            f"{fact.get('val','')} {unit}"
        )
    return {
        "present": True,
        "label": concept.get("label", ""),
        "description": concept.get("description", ""),
        "units": ";".join(sorted(units.keys())),
        "fact_count": fact_count,
        "quarterly_2022_2026_count": quarterly,
        "recent_fact": recent_text,
        "forms": ";".join([k for k, _ in forms.most_common(5) if k]),
        "has_frame": has_frame,
    }


def pick_available(facts, options):
    found = []
    for taxonomy, tag in options:
        concept = get_concept(facts, taxonomy, tag)
        if concept:
            summary = summarize_concept(concept)
            found.append((taxonomy, tag, summary))
    return found


def main():
    TASK_DIR.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    universe = load_universe()
    ticker_map = load_sec_ticker_map()

    status_rows = []
    field_rows = []
    concept_defs = {}
    missing_map = []
    unavailable = []

    for index, row in enumerate(universe, start=1):
        ticker = row["ticker_norm"]
        print(f"[{index:03d}/{len(universe):03d}] {row['ticker']}", flush=True)
        mapping = ticker_map.get(ticker)
        base = {
            "ticker": row["ticker"],
            "company": row["company"],
            "source_index": row["source_index"],
            "index_tag": row["index_tag"],
            "is_main_nasdaq100": row["is_main_nasdaq100"],
            "is_sox_robustness": row["is_sox_robustness"],
            "cik": "",
            "sec_title": "",
            "companyfacts_status": "",
            "companyfacts_error": "",
            "entity_name": "",
            "taxonomy_namespaces": "",
            "assets_any": False,
            "equity_any": False,
            "shares_any": False,
            "document_focus_any": False,
            "assets_primary": "",
            "equity_primary": "",
            "shares_primary": "",
            "document_focus_tags": "",
        }

        if not mapping:
            base["companyfacts_status"] = "no_sec_ticker_map"
            status_rows.append(base)
            missing_map.append(row["ticker"])
            continue

        base["cik"] = mapping["cik10"]
        base["sec_title"] = mapping["sec_title"]
        data, http_status, err = fetch_json(SEC_COMPANYFACTS_URL.format(cik10=mapping["cik10"]))
        base["companyfacts_status"] = str(http_status) if http_status else "network_error"
        base["companyfacts_error"] = err or ""

        if err or not data:
            status_rows.append(base)
            unavailable.append(row["ticker"])
            continue

        if index <= 3 or row["ticker"] in {"ASML", "TSM", "ARM", "CRWV", "PDD", "MELI", "ASX"}:
            (RAW_DIR / f"{ticker}_{mapping['cik10']}.json").write_text(
                json.dumps(data, ensure_ascii=False)[:250000],
                encoding="utf-8",
            )

        facts = data.get("facts", {})
        base["entity_name"] = data.get("entityName", "")
        base["taxonomy_namespaces"] = ";".join(sorted(facts.keys()))

        for group_name, options in FIELD_GROUPS.items():
            found = pick_available(facts, options)
            base[f"{group_name}_any"] = bool(found)
            if group_name == "document_focus":
                base["document_focus_tags"] = ";".join([f"{tax}:{tag}" for tax, tag, _ in found])
            elif found:
                base[f"{group_name}_primary"] = f"{found[0][0]}:{found[0][1]}"

            for taxonomy, tag, summary in found:
                key = (taxonomy, tag)
                if key not in concept_defs:
                    concept_defs[key] = {
                        "taxonomy": taxonomy,
                        "tag": tag,
                        "label": summary["label"],
                        "description": summary["description"],
                        "units_seen": set(),
                    }
                if summary["units"]:
                    concept_defs[key]["units_seen"].update(summary["units"].split(";"))
                field_rows.append({
                    "ticker": row["ticker"],
                    "company": row["company"],
                    "cik": mapping["cik10"],
                    "taxonomy": taxonomy,
                    "tag": tag,
                    "group": group_name,
                    "present": summary["present"],
                    "units": summary["units"],
                    "fact_count": summary["fact_count"],
                    "quarterly_2022_2026_count": summary["quarterly_2022_2026_count"],
                    "forms": summary["forms"],
                    "has_frame": summary["has_frame"],
                    "recent_fact": summary["recent_fact"],
                })

        for taxonomy, tag in REQUIRED_EXACT:
            concept = get_concept(facts, taxonomy, tag)
            summary = summarize_concept(concept)
            field_rows.append({
                "ticker": row["ticker"],
                "company": row["company"],
                "cik": mapping["cik10"],
                "taxonomy": taxonomy,
                "tag": tag,
                "group": "required_exact",
                "present": summary["present"],
                "units": summary["units"],
                "fact_count": summary["fact_count"],
                "quarterly_2022_2026_count": summary["quarterly_2022_2026_count"],
                "forms": summary["forms"],
                "has_frame": summary["has_frame"],
                "recent_fact": summary["recent_fact"],
            })

        status_rows.append(base)

    with STATUS_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(status_rows[0].keys()))
        writer.writeheader()
        writer.writerows(status_rows)

    with FIELD_CSV.open("w", newline="", encoding="utf-8") as f:
        fieldnames = [
            "ticker", "company", "cik", "taxonomy", "tag", "group", "present",
            "units", "fact_count", "quarterly_2022_2026_count", "forms",
            "has_frame", "recent_fact",
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(field_rows)

    counters = {
        "universe_count": len(universe),
        "mapped_count": sum(1 for r in status_rows if r["cik"]),
        "companyfacts_200_count": sum(1 for r in status_rows if r["companyfacts_status"] == "200"),
        "assets_any_count": sum(1 for r in status_rows if r["assets_any"] == True),
        "equity_any_count": sum(1 for r in status_rows if r["equity_any"] == True),
        "shares_any_count": sum(1 for r in status_rows if r["shares_any"] == True),
        "document_focus_any_count": sum(1 for r in status_rows if r["document_focus_any"] == True),
    }

    def list_by_condition(condition):
        return [r["ticker"] for r in status_rows if condition(r)]

    exact_presence = defaultdict(list)
    for fr in field_rows:
        if fr["group"] == "required_exact" and str(fr["present"]) == "True":
            exact_presence[(fr["taxonomy"], fr["tag"])].append(fr["ticker"])

    no_assets = list_by_condition(lambda r: r["companyfacts_status"] == "200" and not r["assets_any"])
    no_equity = list_by_condition(lambda r: r["companyfacts_status"] == "200" and not r["equity_any"])
    no_shares = list_by_condition(lambda r: r["companyfacts_status"] == "200" and not r["shares_any"])
    no_focus = list_by_condition(lambda r: r["companyfacts_status"] == "200" and not r["document_focus_any"])
    foreign_ifrs = list_by_condition(lambda r: "ifrs-full" in r["taxonomy_namespaces"])
    no_us_gaap = list_by_condition(lambda r: r["companyfacts_status"] == "200" and "us-gaap" not in r["taxonomy_namespaces"])

    field_def_lines = []
    for taxonomy, tag in REQUIRED_EXACT + [
        ("us-gaap", "StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest"),
        ("us-gaap", "CommonStockSharesOutstanding"),
        ("us-gaap", "WeightedAverageNumberOfSharesOutstandingBasic"),
        ("ifrs-full", "Equity"),
    ]:
        info = concept_defs.get((taxonomy, tag))
        if info:
            desc = info["description"].replace("\n", " ").strip()
            if len(desc) > 360:
                desc = desc[:357].rstrip() + "..."
            units = ", ".join(sorted(info["units_seen"]))
            field_def_lines.append(
                f"- `{taxonomy}:{tag}`：{info['label']}。单位：{units or '未在样本中观察到'}。SEC 描述：{desc}"
            )
        else:
            field_def_lines.append(
                f"- `{taxonomy}:{tag}`：本轮 108 家 companyfacts 中未观察到该 concept。"
            )

    def bullet_list(items, empty="无"):
        return empty if not items else "、".join(items)

    status_table_lines = []
    for r in status_rows:
        status_table_lines.append(
            "| {ticker} | {cik} | {sec_title} | {status} | {assets} | {equity} | {shares} | {focus} | {tax} |".format(
                ticker=r["ticker"],
                cik=r["cik"] or "-",
                sec_title=(r["sec_title"] or "-").replace("|", "/"),
                status=r["companyfacts_status"],
                assets=r["assets_primary"] or "-",
                equity=r["equity_primary"] or "-",
                shares=r["shares_primary"] or "-",
                focus=r["document_focus_tags"] or "-",
                tax=r["taxonomy_namespaces"] or "-",
            )
        )

    report = f"""# SEC companyfacts 可用性与字段口径核对

生成时间：{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}，北京时间。

## 任务边界

本报告只核对 SEC companyfacts API 对 `CAR/metadata/firm_universe_for_car.csv` 中 108 家股票的可用性和字段定义。不修改 `Fundamentals/` 下任何文件。

输入文件：

- `CAR/metadata/firm_universe_for_car.csv`
- `CAR/README.md`

官方来源：

- SEC ticker-CIK 映射：{SEC_TICKERS_URL}
- SEC EDGAR API 说明：{SEC_DOCS_URL}
- SEC companyfacts 模板：`https://data.sec.gov/api/xbrl/companyfacts/CIK##########.json`

SEC 官方说明要点。`companyfacts` 端点按单个 CIK 返回该公司全部 XBRL concept 数据。每个 concept 按单位分组，事实项通常含 `end`、`val`、`accn`、`fy`、`fp`、`form`、`filed`、`frame`，部分期间型字段还含 `start`。SEC 文档还说明，`frames` 端点按日历期聚合；公司财年日期可能不完全等同自然季度，使用 `frame` 时要注意这一点。

## 总体结论

- 公司池共 {counters['universe_count']} 家。
- SEC ticker-CIK 映射命中 {counters['mapped_count']} 家。
- companyfacts 端点 HTTP 200 返回 {counters['companyfacts_200_count']} 家。
- 资产类字段可用 {counters['assets_any_count']} 家。
- 权益类字段可用 {counters['equity_any_count']} 家。
- 股数字段可用 {counters['shares_any_count']} 家。
- `DocumentFiscalYearFocus` 或 `DocumentFiscalPeriodFocus` 可用 {counters['document_focus_any_count']} 家。

结论是，SEC companyfacts 可以作为本项目季度财务数据的主来源。美国公司基本可直接用 `us-gaap` 字段。外资发行人和 ADR 也常能通过 SEC 获得数据，但部分使用 `ifrs-full` taxonomy，不能只写死 `us-gaap`。

## 字段口径

{chr(10).join(field_def_lines)}

推荐后续取数顺序：

1. 总资产优先用 `us-gaap:Assets`。这是资产负债表瞬时项，单位通常为 `USD`。
2. 股东权益优先用 `us-gaap:StockholdersEquity`。如果缺失，再用 `us-gaap:StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest` 或 `us-gaap:StockholdersEquityAttributableToParent`。IFRS 发行人可用 `ifrs-full:Equity` 或 `ifrs-full:EquityAttributableToOwnersOfParent`，但要单独标记口径差异。
3. 季末股数优先用 `dei:EntityCommonStockSharesOutstanding`。这是封面披露口径，通常有 `shares` 单位。若缺失，可考虑 `us-gaap:CommonStockSharesOutstanding`。加权平均股数只能作为收益率或 EPS 口径的补充，不等同季末流通股数。
4. `DocumentFiscalYearFocus` 与 `DocumentFiscalPeriodFocus` 是报告封面焦点年份和期间。companyfacts 里并非每家公司都稳定披露；季度面板主键仍应以每条 fact 自带的 `fy`、`fp`、`end`、`filed`、`form`、`frame` 为准。

## 关键缺口

- 未命中 SEC ticker-CIK 映射：{bullet_list(missing_map)}。
- companyfacts 未返回 HTTP 200：{bullet_list(unavailable)}。
- 有 companyfacts 但未观察到资产类字段：{bullet_list(no_assets)}。
- 有 companyfacts 但未观察到权益类字段：{bullet_list(no_equity)}。
- 有 companyfacts 但未观察到股数字段：{bullet_list(no_shares)}。
- 有 companyfacts 但未观察到 `DocumentFiscalYearFocus` 或 `DocumentFiscalPeriodFocus`：{bullet_list(no_focus)}。
- 含 `ifrs-full` taxonomy 的公司：{bullet_list(foreign_ifrs)}。
- 有 companyfacts 但不含 `us-gaap` namespace 的公司：{bullet_list(no_us_gaap)}。

## 精确字段覆盖

| 字段 | 覆盖家数 |
|---|---:|
| `us-gaap:Assets` | {len(exact_presence[('us-gaap', 'Assets')])} |
| `us-gaap:StockholdersEquity` | {len(exact_presence[('us-gaap', 'StockholdersEquity')])} |
| `dei:EntityCommonStockSharesOutstanding` | {len(exact_presence[('dei', 'EntityCommonStockSharesOutstanding')])} |
| `dei:DocumentFiscalYearFocus` | {len(exact_presence[('dei', 'DocumentFiscalYearFocus')])} |
| `dei:DocumentFiscalPeriodFocus` | {len(exact_presence[('dei', 'DocumentFiscalPeriodFocus')])} |

## 对后续季度面板的建议

后续可以直接写下载脚本，按 CIK 保存完整 companyfacts JSON。标准化时保留原始事实层字段，至少包括 `taxonomy`、`tag`、`unit`、`val`、`start`、`end`、`accn`、`fy`、`fp`、`form`、`filed`、`frame`。不要只保留一个宽表数值，否则后面很难复核 fiscal quarter 与 calendar quarter 的差异。

季度数据筛选建议：

- 资产和权益用瞬时项，优先选择 `form` 为 `10-Q`、`10-K`、`20-F`、`40-F`、`6-K` 的事实。
- 同一 ticker、字段、`end`、`fy`、`fp` 有多条事实时，优先保留较晚 `filed`，但要保留原始 `accn` 供审计。
- `frame` 可用于对齐自然季度，但不能替代 `fy/fp/end`。主面板建议用公司财年季度，回归时再按事件日向前匹配最近一期已披露财务。
- 外资发行人保留 taxonomy 标记。IFRS 权益字段与 US-GAAP 股东权益不是完全同名口径，不能静默混为一个变量。

## 公司级可用性表

| ticker | CIK | SEC title | HTTP | assets | equity | shares | document focus | taxonomies |
|---|---:|---|---:|---|---|---|---|---|
{chr(10).join(status_table_lines)}

## 附属输出

- `agent_tasks/fundamentals_collection_20260702-223530/sec_companyfacts_status.csv`
- `agent_tasks/fundamentals_collection_20260702-223530/sec_companyfacts_field_coverage.csv`
- `agent_tasks/fundamentals_collection_20260702-223530/sec_company_tickers.json`
- `agent_tasks/fundamentals_collection_20260702-223530/sec_companyfacts_samples/`
"""

    REPORT.write_text(report, encoding="utf-8")

    print(json.dumps(counters, ensure_ascii=False, indent=2))
    print(f"report={REPORT}")
    print(f"status_csv={STATUS_CSV}")
    print(f"field_csv={FIELD_CSV}")


if __name__ == "__main__":
    main()
