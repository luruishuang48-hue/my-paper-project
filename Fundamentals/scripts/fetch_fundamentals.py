#!/usr/bin/env python3
from __future__ import annotations

import json
import math
import re
import ssl
import time
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

import certifi
import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
CAR = ROOT / "CAR"
FUND = ROOT / "Fundamentals"
RAW_STOCKANALYSIS = FUND / "raw" / "stockanalysis_html"
RAW_FX = FUND / "raw" / "yahoo_fx_json"
RAW_SEC = FUND / "raw" / "sec"
PROCESSED = FUND / "processed"
METADATA = FUND / "metadata"
REPORTS = FUND / "reports"

UNIVERSE_FILE = CAR / "metadata" / "firm_universe_for_car.csv"
PRICE_FILE = CAR / "processed" / "prices_daily_long.csv"

START_QUARTER = "2022Q1"
END_QUARTER = "2026Q1"

USER_AGENT = "Mozilla/5.0 academic research financial data script"
SEC_USER_AGENT = "academic research chen@example.com"

FX_SYMBOLS = {
    "EUR": "EURUSD=X",
    "CNY": "CNYUSD=X",
    "TWD": "TWDUSD=X",
}


@dataclass
class FetchStatus:
    ticker: str
    ok_balance_sheet: bool
    ok_income_statement: bool
    rows_quarterly: int
    first_quarter: str
    last_quarter: str
    message: str


def ensure_dirs() -> None:
    for path in [RAW_STOCKANALYSIS, RAW_FX, RAW_SEC, PROCESSED, METADATA, REPORTS]:
        path.mkdir(parents=True, exist_ok=True)


def http_get(url: str, user_agent: str = USER_AGENT, timeout: int = 35) -> bytes:
    context = ssl.create_default_context(cafile=certifi.where())
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": user_agent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        },
    )
    last_error: Exception | None = None
    for attempt in range(1, 4):
        try:
            with urllib.request.urlopen(req, context=context, timeout=timeout) as response:
                return response.read()
        except Exception as exc:
            last_error = exc
            time.sleep(0.75 * attempt)
    raise last_error if last_error else RuntimeError("http_get_failed")


def load_universe() -> pd.DataFrame:
    universe = pd.read_csv(UNIVERSE_FILE)
    universe["ticker"] = universe["ticker"].astype(str).str.strip()
    return universe


def sec_ticker_map() -> pd.DataFrame:
    url = "https://www.sec.gov/files/company_tickers.json"
    target = RAW_SEC / "company_tickers.json"
    if target.exists():
        payload = target.read_bytes()
    else:
        payload = http_get(url, user_agent=SEC_USER_AGENT)
        target.write_bytes(payload)
    data = json.loads(payload.decode("utf-8"))
    rows = []
    for item in data.values():
        rows.append(
            {
                "ticker": str(item["ticker"]).upper(),
                "sec_cik": f"{int(item['cik_str']):010d}",
                "sec_title": item["title"],
            }
        )
    return pd.DataFrame(rows)


def stockanalysis_url(ticker: str, statement: str) -> str:
    symbol = urllib.parse.quote(ticker.lower(), safe="")
    if statement == "balance_sheet":
        return f"https://stockanalysis.com/stocks/{symbol}/financials/balance-sheet/?p=quarterly"
    if statement == "income_statement":
        return f"https://stockanalysis.com/stocks/{symbol}/financials/?p=quarterly"
    raise ValueError(statement)


def yahoo_chart_url(symbol: str) -> str:
    params = urllib.parse.urlencode(
        {
            "period1": "1640995200",
            "period2": "1770000000",
            "interval": "1d",
            "events": "history",
        }
    )
    return "https://query2.finance.yahoo.com/v8/finance/chart/" + urllib.parse.quote(symbol, safe="") + "?" + params


def fetch_fx_rates() -> pd.DataFrame:
    rows = []
    for currency, symbol in FX_SYMBOLS.items():
        target = RAW_FX / f"{symbol.replace('=', '_').replace('/', '_')}.json"
        if target.exists():
            payload = target.read_bytes()
        else:
            payload = http_get(yahoo_chart_url(symbol))
            target.write_bytes(payload)
            time.sleep(0.25)
        data = json.loads(payload.decode("utf-8"))
        result = (data.get("chart", {}).get("result") or [{}])[0]
        timestamps = result.get("timestamp") or []
        quote = (result.get("indicators", {}).get("quote") or [{}])[0]
        close = quote.get("close") or []
        for ts, value in zip(timestamps, close):
            rows.append(
                {
                    "date": datetime.utcfromtimestamp(ts).date().isoformat(),
                    "financial_currency": currency,
                    "fx_symbol": symbol,
                    "fx_to_usd": value,
                }
            )
    frame = pd.DataFrame(rows)
    frame.to_csv(PROCESSED / "fx_rates_to_usd.csv", index=False)
    return frame


def parse_js_array(html: str, key: str) -> list:
    pattern = r"(?<![A-Za-z0-9_])" + re.escape(key) + r":\[([^\]]*)\]"
    match = re.search(pattern, html)
    if not match:
        return []
    raw = match.group(1).strip()
    if not raw:
        return []
    raw = raw.replace("void 0", "null")
    raw = re.sub(r"(^|,)\s*-\.(\d+)", r"\1-0.\2", raw)
    raw = re.sub(r"(^|,)\s*\.(\d+)", r"\g<1>0.\2", raw)
    raw = re.sub(r"(^|,)\s*(NaN|Infinity|-Infinity)(?=,|$)", r"\1null", raw)
    return json.loads("[" + raw + "]")


def parse_currency(html: str) -> dict[str, str | None]:
    match = re.search(r"curr:\{([^}]+)\}", html)
    if not match:
        return {"main_currency": None, "price_currency": None, "financial_currency": None}
    text = match.group(1)

    def find(name: str) -> str | None:
        m = re.search(re.escape(name) + r':"([^"]+)"', text)
        return m.group(1) if m else None

    return {
        "main_currency": find("main"),
        "price_currency": find("price"),
        "financial_currency": find("financial"),
    }


def parse_stockanalysis_statement(html: str, keys: list[str]) -> pd.DataFrame:
    datekey = parse_js_array(html, "datekey")
    fiscal_year = parse_js_array(html, "fiscalYear")
    fiscal_quarter = parse_js_array(html, "fiscalQuarter")
    if not datekey:
        return pd.DataFrame()
    frame = pd.DataFrame(
        {
            "period_end_date": datekey,
            "fiscal_year": fiscal_year[: len(datekey)] if fiscal_year else [None] * len(datekey),
            "fiscal_quarter": fiscal_quarter[: len(datekey)] if fiscal_quarter else [None] * len(datekey),
        }
    )
    for key in keys:
        values = parse_js_array(html, key)
        if values:
            frame[key] = values[: len(datekey)]
        else:
            frame[key] = [None] * len(datekey)
    return frame


def fetch_stockanalysis_ticker(ticker: str, pause: float = 0.4) -> tuple[pd.DataFrame, FetchStatus]:
    safe_ticker = ticker.replace("/", "_")
    balance_path = RAW_STOCKANALYSIS / f"{safe_ticker}_balance_sheet_quarterly.html"
    income_path = RAW_STOCKANALYSIS / f"{safe_ticker}_income_statement_quarterly.html"
    messages = []
    ok_bs = False
    ok_is = False
    balance = pd.DataFrame()
    income = pd.DataFrame()
    currencies = {"main_currency": None, "price_currency": None, "financial_currency": None}

    try:
        if balance_path.exists():
            balance_html = balance_path.read_text(encoding="utf-8", errors="replace")
        else:
            balance_html = http_get(stockanalysis_url(ticker, "balance_sheet")).decode("utf-8", errors="replace")
            balance_path.write_text(balance_html, encoding="utf-8")
        currencies = parse_currency(balance_html)
        balance = parse_stockanalysis_statement(
            balance_html,
            ["assets", "equity", "bookValue", "bookValuePerShare"],
        )
        ok_bs = not balance.empty
        if not ok_bs:
            messages.append("balance_sheet_empty")
    except Exception as exc:
        messages.append(f"balance_sheet_error={type(exc).__name__}: {exc}")
    if not balance_path.exists():
        time.sleep(pause)

    try:
        if income_path.exists():
            income_html = income_path.read_text(encoding="utf-8", errors="replace")
        else:
            income_html = http_get(stockanalysis_url(ticker, "income_statement")).decode("utf-8", errors="replace")
            income_path.write_text(income_html, encoding="utf-8")
        income = parse_stockanalysis_statement(income_html, ["sharesBasic", "sharesDiluted"])
        ok_is = not income.empty
        if not ok_is:
            messages.append("income_statement_empty")
    except Exception as exc:
        messages.append(f"income_statement_error={type(exc).__name__}: {exc}")
    if not income_path.exists():
        time.sleep(pause)

    if balance.empty:
        status = FetchStatus(ticker, ok_bs, ok_is, 0, "", "", "; ".join(messages) or "empty")
        return pd.DataFrame(), status

    merged = balance.merge(
        income[["period_end_date", "sharesBasic", "sharesDiluted"]] if not income.empty else pd.DataFrame(columns=["period_end_date", "sharesBasic", "sharesDiluted"]),
        on="period_end_date",
        how="left",
    )
    merged.insert(0, "ticker", ticker)
    for key, value in currencies.items():
        merged[key] = value
    merged["source"] = "stockanalysis_fiscal_ai"
    merged["period_end_date"] = pd.to_datetime(merged["period_end_date"], errors="coerce")
    merged["quarter_anchor_date"] = merged["period_end_date"] - pd.Timedelta(days=15)
    quarter_period = merged["quarter_anchor_date"].dt.to_period("Q")
    merged["calendar_quarter"] = quarter_period.astype(str)
    quarter_end = quarter_period.dt.to_timestamp(how="end").dt.normalize()
    merged["calendar_quarter_end_date"] = quarter_end.dt.date.astype(str)
    merged["days_from_calendar_quarter_end"] = (merged["period_end_date"] - quarter_end).dt.days.abs()
    merged["period_end_date"] = merged["period_end_date"].dt.date.astype(str)
    merged["quarter_anchor_date"] = merged["quarter_anchor_date"].dt.date.astype(str)
    merged = merged[(merged["calendar_quarter"] >= START_QUARTER) & (merged["calendar_quarter"] <= END_QUARTER)]
    merged = (
        merged.sort_values(["calendar_quarter", "days_from_calendar_quarter_end", "period_end_date"])
        .drop_duplicates(["ticker", "calendar_quarter"], keep="first")
        .sort_values("period_end_date")
    )
    status = FetchStatus(
        ticker=ticker,
        ok_balance_sheet=ok_bs,
        ok_income_statement=ok_is,
        rows_quarterly=len(merged),
        first_quarter=str(merged["calendar_quarter"].min()) if not merged.empty else "",
        last_quarter=str(merged["calendar_quarter"].max()) if not merged.empty else "",
        message="; ".join(messages) or "ok",
    )
    return merged, status


def price_on_or_before(prices: pd.DataFrame, ticker: str, date_string: str) -> tuple[str | None, float | None]:
    sub = prices[prices["symbol"] == ticker].copy()
    if sub.empty:
        return None, None
    target = pd.to_datetime(date_string)
    sub = sub[sub["date"] <= target]
    if sub.empty:
        return None, None
    row = sub.sort_values("date").iloc[-1]
    return row["date"].date().isoformat(), float(row["close"]) if pd.notna(row["close"]) else None


def add_market_cap(fundamentals: pd.DataFrame) -> pd.DataFrame:
    prices = pd.read_csv(PRICE_FILE, parse_dates=["date"], low_memory=False)
    rows = []
    for row in fundamentals.to_dict("records"):
        ticker = row["ticker"]
        price_date, price = price_on_or_before(prices, ticker, row["period_end_date"])
        book_value = row.get("bookValue")
        bvps = row.get("bookValuePerShare")
        implied_shares = None
        if pd.notna(book_value) and pd.notna(bvps) and bvps not in (0, "0"):
            try:
                implied_shares = float(book_value) / float(bvps)
            except Exception:
                implied_shares = None
        shares_for_market_cap = row.get("sharesDiluted")
        shares_source = "shares_diluted"
        if pd.isna(shares_for_market_cap):
            shares_for_market_cap = row.get("sharesBasic")
            shares_source = "shares_basic"
        if pd.isna(shares_for_market_cap):
            shares_for_market_cap = implied_shares
            shares_source = "book_value_divided_by_book_value_per_share"
        market_cap = None
        if price is not None and pd.notna(shares_for_market_cap):
            market_cap = price * float(shares_for_market_cap)
        row["quarter_price_date"] = price_date
        row["quarter_end_close_usd"] = price
        row["implied_shares_from_book_value"] = implied_shares
        row["shares_for_market_cap"] = shares_for_market_cap
        row["shares_for_market_cap_source"] = shares_source if pd.notna(shares_for_market_cap) else ""
        row["quarter_end_market_cap_usd"] = market_cap
        rows.append(row)
    return pd.DataFrame(rows)


def fx_on_or_before(fx_rates: pd.DataFrame, currency: str | None, date_string: str) -> tuple[str | None, float | None, str | None]:
    if not currency or currency == "USD":
        return date_string, 1.0, "USD"
    sub = fx_rates[fx_rates["financial_currency"] == currency].copy()
    if sub.empty:
        return None, None, None
    target = pd.to_datetime(date_string)
    sub["date"] = pd.to_datetime(sub["date"])
    sub = sub[sub["date"] <= target]
    if sub.empty:
        return None, None, None
    row = sub.sort_values("date").iloc[-1]
    return row["date"].date().isoformat(), float(row["fx_to_usd"]) if pd.notna(row["fx_to_usd"]) else None, row["fx_symbol"]


def add_usd_conversions(wide: pd.DataFrame, fx_rates: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for row in wide.to_dict("records"):
        fx_date, fx_to_usd, fx_symbol = fx_on_or_before(fx_rates, row.get("financial_currency"), row["period_end_date"])
        row["financial_fx_date"] = fx_date
        row["financial_fx_to_usd"] = fx_to_usd
        row["financial_fx_symbol"] = fx_symbol
        for source, target in [
            ("total_assets", "total_assets_usd"),
            ("stockholders_equity", "stockholders_equity_usd"),
            ("book_value", "book_value_usd"),
        ]:
            value = row.get(source)
            row[target] = float(value) * fx_to_usd if pd.notna(value) and fx_to_usd is not None else None
        assets_usd = row.get("total_assets_usd")
        equity_usd = row.get("stockholders_equity_usd")
        market_cap = row.get("quarter_end_market_cap_usd")
        row["size_log_assets"] = math.log(float(assets_usd)) if assets_usd is not None and pd.notna(assets_usd) and assets_usd > 0 else None
        row["bm_ratio"] = float(equity_usd) / float(market_cap) if equity_usd is not None and pd.notna(equity_usd) and pd.notna(market_cap) and market_cap not in (0, None) else None
        rows.append(row)
    return pd.DataFrame(rows)


def standardize(fundamentals: pd.DataFrame, universe: pd.DataFrame) -> pd.DataFrame:
    out = fundamentals.rename(
        columns={
            "assets": "total_assets",
            "equity": "stockholders_equity",
            "bookValue": "book_value",
            "bookValuePerShare": "book_value_per_share",
            "sharesBasic": "shares_basic",
            "sharesDiluted": "shares_diluted",
        }
    )
    cols = [
        "ticker",
        "company",
        "gics_sector",
        "index_tag",
        "is_main_ndxt",
        "is_sox_robustness",
        "sec_cik",
        "sec_title",
    ]
    out = out.merge(universe[cols], on="ticker", how="left")
    ordered = [
        "ticker",
        "company",
        "sec_cik",
        "sec_title",
        "gics_sector",
        "index_tag",
        "is_main_ndxt",
        "is_sox_robustness",
        "calendar_quarter",
        "period_end_date",
        "quarter_anchor_date",
        "calendar_quarter_end_date",
        "days_from_calendar_quarter_end",
        "fiscal_year",
        "fiscal_quarter",
        "financial_currency",
        "price_currency",
        "total_assets",
        "total_assets_usd",
        "size_log_assets",
        "stockholders_equity",
        "stockholders_equity_usd",
        "book_value",
        "book_value_usd",
        "book_value_per_share",
        "shares_basic",
        "shares_diluted",
        "implied_shares_from_book_value",
        "shares_for_market_cap",
        "shares_for_market_cap_source",
        "quarter_price_date",
        "quarter_end_close_usd",
        "quarter_end_market_cap_usd",
        "bm_ratio",
        "financial_fx_date",
        "financial_fx_to_usd",
        "financial_fx_symbol",
        "source",
    ]
    return out[[c for c in ordered if c in out.columns]]


def make_long(wide: pd.DataFrame) -> pd.DataFrame:
    id_cols = [
        "ticker",
        "company",
        "calendar_quarter",
        "period_end_date",
        "financial_currency",
        "price_currency",
        "source",
    ]
    value_cols = [
        "total_assets",
        "stockholders_equity",
        "book_value",
        "book_value_per_share",
        "shares_basic",
        "shares_diluted",
        "shares_for_market_cap",
        "quarter_end_close_usd",
        "quarter_end_market_cap_usd",
        "total_assets_usd",
        "stockholders_equity_usd",
        "bm_ratio",
        "size_log_assets",
    ]
    return wide.melt(id_vars=id_cols, value_vars=[c for c in value_cols if c in wide.columns], var_name="variable", value_name="value")


def write_reports(wide: pd.DataFrame, statuses: pd.DataFrame, universe: pd.DataFrame) -> None:
    quarters = [str(q) for q in pd.period_range(START_QUARTER, END_QUARTER, freq="Q")]
    expected = len(universe) * len(quarters)
    coverage = (
        wide.groupby("ticker")
        .agg(
            company=("company", "first"),
            rows=("calendar_quarter", "size"),
            first_quarter=("calendar_quarter", "min"),
            last_quarter=("calendar_quarter", "max"),
            total_assets_nonmissing=("total_assets", lambda s: int(s.notna().sum())),
            equity_nonmissing=("stockholders_equity", lambda s: int(s.notna().sum())),
            shares_nonmissing=("shares_for_market_cap", lambda s: int(s.notna().sum())),
            market_cap_nonmissing=("quarter_end_market_cap_usd", lambda s: int(s.notna().sum())),
            total_assets_usd_nonmissing=("total_assets_usd", lambda s: int(s.notna().sum())),
            equity_usd_nonmissing=("stockholders_equity_usd", lambda s: int(s.notna().sum())),
            bm_ratio_nonmissing=("bm_ratio", lambda s: int(s.notna().sum())),
            financial_currency=("financial_currency", "first"),
        )
        .reset_index()
    )
    coverage["expected_quarters"] = len(quarters)
    coverage["missing_quarters"] = coverage["expected_quarters"] - coverage["rows"]
    coverage.to_csv(REPORTS / "fundamentals_coverage_report.csv", index=False)
    statuses.to_csv(REPORTS / "fundamentals_download_status.csv", index=False)

    currency_summary = wide.groupby("financial_currency").agg(tickers=("ticker", "nunique"), rows=("ticker", "size")).reset_index()
    currency_summary.to_csv(REPORTS / "financial_currency_summary.csv", index=False)

    missing = coverage[(coverage["rows"] < len(quarters)) | (coverage["total_assets_nonmissing"] < coverage["rows"]) | (coverage["equity_nonmissing"] < coverage["rows"])]
    report = f"""# 财务数据收集报告

生成时间：{datetime.now().isoformat(timespec='seconds')}

## 范围

- 公司数：{len(universe)}
- 目标季度：{START_QUARTER} 至 {END_QUARTER}，共 {len(quarters)} 个季度
- 理论 ticker × quarter 行数：{expected}
- 实际标准化行数：{len(wide)}

## 主要来源

- 主财务数据来自 StockAnalysis 页面嵌入的 Fiscal.ai 季度资产负债表和损益表数据。
- SEC `company_tickers.json` 用于 CIK 映射。
- 市值由 `CAR/processed/prices_daily_long.csv` 中的季末或季末前最近交易日收盘价乘以股数估算。

## 覆盖率

- `total_assets` 非缺失数：{int(wide['total_assets'].notna().sum())}
- `stockholders_equity` 非缺失数：{int(wide['stockholders_equity'].notna().sum())}
- `shares_for_market_cap` 非缺失数：{int(wide['shares_for_market_cap'].notna().sum())}
- `quarter_end_market_cap_usd` 非缺失数：{int(wide['quarter_end_market_cap_usd'].notna().sum())}
- `total_assets_usd` 非缺失数：{int(wide['total_assets_usd'].notna().sum())}
- `stockholders_equity_usd` 非缺失数：{int(wide['stockholders_equity_usd'].notna().sum())}
- `bm_ratio` 非缺失数：{int(wide['bm_ratio'].notna().sum())}

## 重要口径

- `financial_currency` 是财务报表币种。非 USD 公司已用 Yahoo FX 日线换算为 USD，汇率字段为 `financial_fx_to_usd`。
- `quarter_end_market_cap_usd` 是估算值，优先使用 diluted shares，其次 basic shares，最后用 book value / book value per share 反推股数。
- 晚上市公司天然缺少早期季度，不做外推。

## 覆盖不足或字段缺失公司

{missing.to_markdown(index=False) if not missing.empty else '无。'}
"""
    (REPORTS / "fundamentals_collection_report.md").write_text(report, encoding="utf-8")


def main() -> None:
    ensure_dirs()
    universe = load_universe()
    sec_map = sec_ticker_map()
    fx_rates = fetch_fx_rates()
    universe = universe.merge(sec_map, on="ticker", how="left")
    universe.to_csv(METADATA / "fundamentals_universe.csv", index=False)

    frames: list[pd.DataFrame] = []
    statuses: list[FetchStatus] = []
    for idx, ticker in enumerate(universe["ticker"], start=1):
        frame, status = fetch_stockanalysis_ticker(ticker)
        frames.append(frame)
        statuses.append(status)
        print(
            f"[{idx:03d}/{len(universe):03d}] {ticker} rows={status.rows_quarterly} "
            f"bs={status.ok_balance_sheet} is={status.ok_income_statement} {status.message}",
            flush=True,
        )

    raw_quarterly = pd.concat([f for f in frames if not f.empty], ignore_index=True) if frames else pd.DataFrame()
    raw_quarterly.to_csv(PROCESSED / "fundamentals_stockanalysis_raw_quarterly.csv", index=False)

    with_market_cap = add_market_cap(raw_quarterly)
    wide = standardize(with_market_cap, universe)
    wide = add_usd_conversions(wide, fx_rates)
    wide = wide.sort_values(["ticker", "calendar_quarter"])
    wide.to_csv(PROCESSED / "fundamentals_quarterly_wide.csv", index=False)
    make_long(wide).to_csv(PROCESSED / "fundamentals_quarterly_long.csv", index=False)

    status_df = pd.DataFrame([s.__dict__ for s in statuses])
    write_reports(wide, status_df, universe)


if __name__ == "__main__":
    main()
