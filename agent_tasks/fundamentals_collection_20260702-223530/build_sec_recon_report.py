#!/usr/bin/env python3
import csv
from collections import defaultdict
from datetime import datetime
from pathlib import Path


TASK_DIR = Path(__file__).resolve().parent
REPORT = TASK_DIR / "sec_recon.md"
STATUS_CSV = TASK_DIR / "sec_companyfacts_status.csv"
FIELD_CSV = TASK_DIR / "sec_companyfacts_field_coverage.csv"

SEC_TICKERS_URL = "https://www.sec.gov/files/company_tickers.json"
SEC_DOCS_URL = "https://www.sec.gov/search-filings/edgar-application-programming-interfaces"


def read_csv(path):
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def boolish(value):
    return str(value) in {"True", "true", "1", "yes"}


def bullet_list(items):
    return "无" if not items else "、".join(items)


status_rows = read_csv(STATUS_CSV)
field_rows = read_csv(FIELD_CSV)
unique_cik_count = len({r["cik"] for r in status_rows if r["cik"]})

exact_presence = defaultdict(set)
group_presence = defaultdict(set)
for row in field_rows:
    if row["present"] == "True":
        exact_presence[(row["taxonomy"], row["tag"])].add(row["ticker"])
        group_presence[row["group"]].add(row["ticker"])

missing_map = [r["ticker"] for r in status_rows if not r["cik"]]
unavailable = [r["ticker"] for r in status_rows if r["companyfacts_status"] != "200"]
no_assets = [r["ticker"] for r in status_rows if r["companyfacts_status"] == "200" and not boolish(r["assets_any"])]
no_equity = [r["ticker"] for r in status_rows if r["companyfacts_status"] == "200" and not boolish(r["equity_any"])]
no_shares = [r["ticker"] for r in status_rows if r["companyfacts_status"] == "200" and not boolish(r["shares_any"])]
no_focus = [r["ticker"] for r in status_rows if r["companyfacts_status"] == "200" and not boolish(r["document_focus_any"])]
foreign_ifrs = [r["ticker"] for r in status_rows if "ifrs-full" in r["taxonomy_namespaces"]]
no_us_gaap = [r["ticker"] for r in status_rows if r["companyfacts_status"] == "200" and "us-gaap" not in r["taxonomy_namespaces"]]

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

field_defs = [
    "- `us-gaap:Assets` 表示报告主体资产总额，是资产负债表瞬时项。样本中单位为 `USD`。",
    "- `ifrs-full:Assets` 是 IFRS 发行人的资产总额。ASX、CCEP、FER、TRI、TSM、UMC 使用该口径。",
    "- `us-gaap:StockholdersEquity` 表示股东权益。样本中 102 家 US-GAAP 公司可用。",
    "- `us-gaap:StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest` 可作为权益备选口径，但包含非控制性权益，不能与普通股东权益静默混用。",
    "- `ifrs-full:Equity` 和 `ifrs-full:EquityAttributableToOwnersOfParent` 是 IFRS 权益口径。后者更接近归属于母公司股东的权益。",
    "- `dei:EntityCommonStockSharesOutstanding` 是封面披露的普通股或相关权益单位数量，单位通常为 `shares`。它更适合估算季末市值。",
    "- `us-gaap:CommonStockSharesOutstanding` 是普通股股数备选项。本轮覆盖低于 `dei:EntityCommonStockSharesOutstanding`。",
    "- `us-gaap:WeightedAverageNumberOfSharesOutstandingBasic` 和 `us-gaap:WeightedAverageNumberOfDilutedSharesOutstanding` 是期间平均股数，适合 EPS 口径，不等同季末流通股数。",
    "- `dei:DocumentFiscalYearFocus` 和 `dei:DocumentFiscalPeriodFocus` 是报告封面的财年和期间焦点 concept。本轮 108 家的 companyfacts JSON 中未观察到这两个 concept；后续季度面板应使用每条 fact 自带的 `fy` 和 `fp`。",
    "- `fy`、`fp`、`end`、`filed`、`form`、`frame` 是 companyfacts fact 层字段。`fy/fp` 是申报财年和期间，`end` 是事实截止日，`filed` 是文件提交日，`form` 是申报类型，`frame` 是 SEC 对齐自然日历期后的框架标签。",
]

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

SEC 官方说明要点。`companyfacts` 端点按单个 CIK 返回该公司全部 XBRL concept 数据。每个 concept 按单位分组，事实项通常含 `end`、`val`、`accn`、`fy`、`fp`、`form`、`filed`、`frame`，部分期间型字段还含 `start`。SEC 文档还说明，`frames` 端点按日历期聚合；公司财年日期可能不完全等同自然季度，使用 `frame` 时要留意。

## 总体结论

- 公司池共 {len(status_rows)} 家。
- SEC ticker-CIK 映射命中 {sum(1 for r in status_rows if r["cik"])} 个股票代码，对应 {unique_cik_count} 个唯一 CIK。GOOG 和 GOOGL 共用 Alphabet 的 CIK。
- companyfacts 端点 HTTP 200 返回 {sum(1 for r in status_rows if r["companyfacts_status"] == "200")} 家。
- 资产类字段可用 {sum(1 for r in status_rows if boolish(r["assets_any"]))} 家。
- 权益类字段可用 {sum(1 for r in status_rows if boolish(r["equity_any"]))} 家。
- 股数字段可用 {sum(1 for r in status_rows if boolish(r["shares_any"]))} 家。
- `DocumentFiscalYearFocus` 或 `DocumentFiscalPeriodFocus` 可用 {sum(1 for r in status_rows if boolish(r["document_focus_any"]))} 家。

结论是，SEC companyfacts 可以作为本项目季度财务数据的主来源。美国公司基本可直接用 `us-gaap` 字段。外资发行人和 ADR 也能通过 SEC 获取数据，但 ASX、CCEP、FER、TRI、TSM、UMC 使用 `ifrs-full` taxonomy，不能只写死 `us-gaap`。

## 字段口径

{chr(10).join(field_defs)}

推荐后续取数顺序：

1. 总资产优先用 `us-gaap:Assets`。若公司只含 IFRS taxonomy，则用 `ifrs-full:Assets`，并标记 `taxonomy=ifrs-full`。
2. 股东权益优先用 `us-gaap:StockholdersEquity`。若缺失，再用 `us-gaap:StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest` 或 `us-gaap:StockholdersEquityAttributableToParent`。IFRS 发行人优先用 `ifrs-full:EquityAttributableToOwnersOfParent`，再用 `ifrs-full:Equity`。
3. 季末股数优先用 `dei:EntityCommonStockSharesOutstanding`。若缺失，可考虑 `us-gaap:CommonStockSharesOutstanding` 或公司披露的 IFRS 股数字段。加权平均股数只能作为补充。
4. 不建议依赖 `DocumentFiscalYearFocus` 和 `DocumentFiscalPeriodFocus`。本轮 companyfacts 未观察到这两个字段。季度面板主键应使用 fact 层 `fy`、`fp`、`end`、`filed`、`form`、`frame`。

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
| `us-gaap:Assets` | {len(exact_presence[("us-gaap", "Assets")])} |
| `ifrs-full:Assets` | {len(exact_presence[("ifrs-full", "Assets")])} |
| `us-gaap:StockholdersEquity` | {len(exact_presence[("us-gaap", "StockholdersEquity")])} |
| `ifrs-full:Equity` | {len(exact_presence[("ifrs-full", "Equity")])} |
| `ifrs-full:EquityAttributableToOwnersOfParent` | {len(exact_presence[("ifrs-full", "EquityAttributableToOwnersOfParent")])} |
| `dei:EntityCommonStockSharesOutstanding` | {len(exact_presence[("dei", "EntityCommonStockSharesOutstanding")])} |
| `us-gaap:CommonStockSharesOutstanding` | {len(exact_presence[("us-gaap", "CommonStockSharesOutstanding")])} |
| `us-gaap:WeightedAverageNumberOfSharesOutstandingBasic` | {len(exact_presence[("us-gaap", "WeightedAverageNumberOfSharesOutstandingBasic")])} |
| `us-gaap:WeightedAverageNumberOfDilutedSharesOutstanding` | {len(exact_presence[("us-gaap", "WeightedAverageNumberOfDilutedSharesOutstanding")])} |
| `dei:DocumentFiscalYearFocus` | {len(exact_presence[("dei", "DocumentFiscalYearFocus")])} |
| `dei:DocumentFiscalPeriodFocus` | {len(exact_presence[("dei", "DocumentFiscalPeriodFocus")])} |

## 对后续季度面板的建议

后续可以直接写下载脚本，按 CIK 保存完整 companyfacts JSON。标准化时保留原始事实层字段，至少包括 `taxonomy`、`tag`、`unit`、`val`、`start`、`end`、`accn`、`fy`、`fp`、`form`、`filed`、`frame`。不要只保留一个宽表数值，否则后面很难复核 fiscal quarter 与 calendar quarter 的差异。

季度数据筛选建议：

- 资产和权益用瞬时项，优先选择 `form` 为 `10-Q`、`10-K`、`20-F`、`40-F`、`6-K` 的事实。
- 同一 ticker、字段、`end`、`fy`、`fp` 有多条事实时，优先保留较晚 `filed`，但保留原始 `accn` 供审计。
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
print(REPORT)
