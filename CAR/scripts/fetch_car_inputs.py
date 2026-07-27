#!/usr/bin/env python3
from __future__ import annotations

import csv
import io
import json
import math
import ssl
import time
import urllib.parse
import urllib.request
import zipfile
from bisect import bisect_left
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

import pandas as pd

try:
    import certifi
except Exception:  # pragma: no cover
    certifi = None


ROOT = Path(__file__).resolve().parents[2]
CAR = ROOT / "CAR"
RAW_JSON = CAR / "raw" / "yahoo_chart_json"
RAW_FACTORS = CAR / "raw" / "factors"
PROCESSED = CAR / "processed"
REPORTS = CAR / "reports"
METADATA = CAR / "metadata"

EVENT_FILE = ROOT / "事件集筛选" / "processed" / "final_event_sample_main.csv"
FIRM_FILE = ROOT / "事件集筛选" / "decisions" / "firm_universe_decisions.csv"

START_DATE = date(2021, 1, 1)
END_DATE = date(2026, 4, 30)

FF3_URL = "https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily_CSV.zip"

BENCHMARKS = {
    "SPY": "SPDR S&P 500 ETF Trust",
    "QQQ": "Invesco QQQ Trust",
    "SOXX": "iShares Semiconductor ETF",
    "^NDX": "NASDAQ-100 Index",
    "^IXIC": "NASDAQ Composite Index",
    "^GSPC": "S&P 500 Index",
    "^SOX": "PHLX Semiconductor Index",
}


@dataclass
class DownloadStatus:
    symbol: str
    ok: bool
    rows: int
    first_date: str
    last_date: str
    source: str
    message: str


def ensure_dirs() -> None:
    for path in [RAW_JSON, RAW_FACTORS, PROCESSED, REPORTS, METADATA]:
        path.mkdir(parents=True, exist_ok=True)


def http_get(url: str, timeout: int = 40) -> bytes:
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 CAR data collection research script",
            "Accept": "*/*",
        },
    )
    context = ssl.create_default_context(cafile=certifi.where()) if certifi else None
    with urllib.request.urlopen(req, timeout=timeout, context=context) as resp:
        return resp.read()


def unix_seconds(d: date) -> int:
    return int(datetime(d.year, d.month, d.day, tzinfo=timezone.utc).timestamp())


def yahoo_url(symbol: str, start: date, end: date) -> str:
    # Yahoo period2 is exclusive, so request one day after the intended end.
    params = {
        "period1": str(unix_seconds(start)),
        "period2": str(unix_seconds(end + timedelta(days=1))),
        "interval": "1d",
        "events": "history",
        "includeAdjustedClose": "true",
    }
    return (
        "https://query2.finance.yahoo.com/v8/finance/chart/"
        + urllib.parse.quote(symbol, safe="")
        + "?"
        + urllib.parse.urlencode(params)
    )


def parse_yahoo_chart(symbol: str, payload: bytes) -> tuple[pd.DataFrame, str]:
    data = json.loads(payload.decode("utf-8"))
    chart = data.get("chart", {})
    error = chart.get("error")
    if error:
        return pd.DataFrame(), f"yahoo_error={error}"
    results = chart.get("result") or []
    if not results:
        return pd.DataFrame(), "empty_result"
    result = results[0]
    timestamps = result.get("timestamp") or []
    quote = (result.get("indicators", {}).get("quote") or [{}])[0]
    adj = (result.get("indicators", {}).get("adjclose") or [{}])[0].get("adjclose") or []
    if not timestamps:
        return pd.DataFrame(), "empty_timestamp"
    n = len(timestamps)

    def padded(values: list | None) -> list:
        values = values or []
        return list(values) + [None] * max(0, n - len(values))

    frame = pd.DataFrame(
        {
            "date": [datetime.utcfromtimestamp(ts).date().isoformat() for ts in timestamps],
            "symbol": symbol,
            "open": padded(quote.get("open"))[:n],
            "high": padded(quote.get("high"))[:n],
            "low": padded(quote.get("low"))[:n],
            "close": padded(quote.get("close"))[:n],
            "adj_close": padded(adj)[:n],
            "volume": padded(quote.get("volume"))[:n],
            "currency": result.get("meta", {}).get("currency"),
            "exchange": result.get("meta", {}).get("exchangeName"),
            "instrument_type": result.get("meta", {}).get("instrumentType"),
            "source": "yahoo_chart",
        }
    )
    frame = frame.dropna(subset=["date"]).drop_duplicates(["symbol", "date"])
    return frame, "ok"


def fetch_yahoo_symbol(symbol: str, start: date, end: date, pause: float = 0.25) -> tuple[pd.DataFrame, DownloadStatus]:
    url = yahoo_url(symbol, start, end)
    target = RAW_JSON / f"{symbol.replace('^', '_caret_').replace('/', '_')}.json"
    if target.exists():
        payload = target.read_bytes()
        frame, message = parse_yahoo_chart(symbol, payload)
        if not frame.empty:
            return (
                frame,
                DownloadStatus(
                    symbol=symbol,
                    ok=True,
                    rows=len(frame),
                    first_date=str(frame["date"].min()),
                    last_date=str(frame["date"].max()),
                    source="yahoo_chart_cache",
                    message=message,
                ),
            )
    last_message = ""
    for attempt in range(1, 4):
        try:
            payload = http_get(url)
            target.write_bytes(payload)
            frame, message = parse_yahoo_chart(symbol, payload)
            if not frame.empty:
                status = DownloadStatus(
                    symbol=symbol,
                    ok=True,
                    rows=len(frame),
                    first_date=str(frame["date"].min()),
                    last_date=str(frame["date"].max()),
                    source="yahoo_chart",
                    message=message,
                )
                time.sleep(pause)
                return frame, status
            last_message = message
        except Exception as exc:
            last_message = f"{type(exc).__name__}: {exc}"
        time.sleep(pause * attempt * 4)
    return (
        pd.DataFrame(),
        DownloadStatus(
            symbol=symbol,
            ok=False,
            rows=0,
            first_date="",
            last_date="",
            source="yahoo_chart",
            message=last_message,
        ),
    )


def load_universe() -> pd.DataFrame:
    firms = pd.read_csv(FIRM_FILE)
    firms["ticker"] = firms["ticker"].astype(str).str.strip()
    firms["is_main_ndxt"] = firms["source_index"].str.contains("NDXT", na=False)
    firms["is_sox_robustness"] = firms["source_index"].str.contains("SOX", na=False)
    firms["download_symbol"] = firms["ticker"]
    firms.to_csv(METADATA / "firm_universe_for_car.csv", index=False)
    firms[firms["is_main_ndxt"]].to_csv(METADATA / "ndxt45_tickers.csv", index=False)
    firms[firms["is_sox_robustness"]].to_csv(METADATA / "robustness_sox_tickers.csv", index=False)
    return firms


def load_events() -> pd.DataFrame:
    events = pd.read_csv(EVENT_FILE)
    events["official_date"] = pd.to_datetime(events["official_date"]).dt.date
    out = events[
        [
            "event_id",
            "ai_year",
            "ai_month",
            "official_date",
            "official_date_all",
            "model_names",
            "aa_creators",
            "model_count",
            "date_status",
            "date_confidence",
            "date_source_types",
        ]
    ].copy()
    out.to_csv(METADATA / "event_dates_for_car.csv", index=False)
    return out


def fetch_ff3_daily() -> pd.DataFrame:
    zip_path = RAW_FACTORS / "F-F_Research_Data_Factors_daily_CSV.zip"
    if zip_path.exists():
        payload = zip_path.read_bytes()
    else:
        payload = http_get(FF3_URL)
        zip_path.write_bytes(payload)
    with zipfile.ZipFile(io.BytesIO(payload)) as zf:
        names = zf.namelist()
        csv_name = [name for name in names if name.lower().endswith(".csv")][0]
        raw_text = zf.read(csv_name).decode("utf-8", errors="replace")
    (RAW_FACTORS / csv_name).write_text(raw_text, encoding="utf-8")

    rows: list[dict[str, float | str]] = []
    reader = csv.reader(io.StringIO(raw_text))
    header_seen = False
    headers: list[str] = []
    for row in reader:
        if not row:
            continue
        first = row[0].strip()
        if not header_seen:
            if first == "" and len(row) >= 5 and row[1].strip().lower() == "mkt-rf":
                headers = ["date"] + [c.strip().replace("-", "_") for c in row[1:]]
                header_seen = True
            continue
        if not first.isdigit() or len(first) != 8:
            break
        item = {"date": f"{first[:4]}-{first[4:6]}-{first[6:]}"}
        for key, value in zip(headers[1:], row[1:]):
            item[key] = float(value)
            item[f"{key}_decimal"] = float(value) / 100.0
        rows.append(item)

    factors = pd.DataFrame(rows)
    factors = factors[(factors["date"] >= START_DATE.isoformat()) & (factors["date"] <= END_DATE.isoformat())]
    factors.to_csv(PROCESSED / "ff3_daily.csv", index=False)
    return factors


def add_sample_flags(prices: pd.DataFrame, firms: pd.DataFrame) -> pd.DataFrame:
    flags = firms[
        [
            "ticker",
            "company",
            "index_tag",
            "is_main_ndxt",
            "is_sox_robustness",
        ]
    ].rename(columns={"ticker": "symbol"})
    out = prices.merge(flags, on="symbol", how="left")
    out["is_benchmark"] = out["symbol"].isin(BENCHMARKS)
    out["benchmark_name"] = out["symbol"].map(BENCHMARKS)
    return out


def compute_returns(prices: pd.DataFrame) -> pd.DataFrame:
    out = prices.copy()
    out["date"] = pd.to_datetime(out["date"])
    out = out.sort_values(["symbol", "date"])
    for col in ["close", "adj_close"]:
        out[f"ret_{col}"] = out.groupby("symbol")[col].pct_change()
        out[f"logret_{col}"] = out.groupby("symbol")[col].transform(
            lambda s: s.astype(float).apply(lambda x: math.log(x) if pd.notna(x) and x > 0 else math.nan).diff()
        )
    out["date"] = out["date"].dt.date.astype(str)
    return out


def ai_month_to_number(value: object) -> int | None:
    if pd.isna(value):
        return None
    text = str(value).strip()
    month_token = text.split()[0] if text else ""
    lookup = {
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
    if text.isdigit():
        return int(text)
    return lookup.get(month_token.lower())


def event_window_requirements(events: pd.DataFrame, benchmark_prices: pd.DataFrame) -> pd.DataFrame:
    trading_days = sorted(pd.to_datetime(benchmark_prices[benchmark_prices["symbol"] == "SPY"]["date"]).dt.date.unique())
    if not trading_days:
        return events
    result = events.copy()
    trading_set = set(trading_days)
    rows: list[dict[str, object]] = []
    for d in result["official_date"]:
        pos = bisect_left(trading_days, d)
        if pos >= len(trading_days):
            rows.append(
                {
                    "event_trading_date": "",
                    "first_us_trading_date_on_or_after_official_date": "",
                    "official_date_is_trading_day": False,
                    "date_roll_rule": "missing_future_trading_day",
                    "price_start_for_return_at_t_minus_200": "",
                    "estimation_start_t_minus_200": "",
                    "estimation_end_t_minus_10": "",
                    "pre_window_start_t_minus_10": "",
                    "pre_window_end_t_minus_2": "",
                    "event_window_end_t_plus_20": "",
                }
            )
            continue
        event_day = trading_days[pos]
        official_is_trading = d in trading_set
        idx = pos
        rows.append(
            {
                "event_trading_date": event_day.isoformat(),
                "first_us_trading_date_on_or_after_official_date": event_day.isoformat(),
                "official_date_is_trading_day": official_is_trading,
                "date_roll_rule": "same_day" if official_is_trading else "next_trading_day_nonmarket",
                "price_start_for_return_at_t_minus_200": trading_days[idx - 201].isoformat() if idx >= 201 else "",
                "estimation_start_t_minus_200": trading_days[idx - 200].isoformat() if idx >= 200 else "",
                "estimation_end_t_minus_10": trading_days[idx - 10].isoformat() if idx >= 10 else "",
                "pre_window_start_t_minus_10": trading_days[idx - 10].isoformat() if idx >= 10 else "",
                "pre_window_end_t_minus_2": trading_days[idx - 2].isoformat() if idx >= 2 else "",
                "event_window_end_t_plus_20": trading_days[idx + 20].isoformat() if idx + 20 < len(trading_days) else "",
            }
        )
    result = pd.concat([result.reset_index(drop=True), pd.DataFrame(rows)], axis=1)
    ai_month_num = result["ai_month"].map(ai_month_to_number)
    result["official_date_month_matches_ai_month"] = [
        bool(m == d.month) if m is not None else False for m, d in zip(ai_month_num, result["official_date"])
    ]
    result["multi_component_date_flag"] = result["official_date_all"].fillna("").astype(str).str.contains(";")
    result["release_time_status"] = "unknown"
    result["date_review_flag"] = (
        result["date_confidence"].astype(str).str.lower().eq("low")
        | result["multi_component_date_flag"]
        | ~result["official_date_month_matches_ai_month"]
    )
    result.to_csv(METADATA / "event_dates_with_trading_day.csv", index=False)
    result.to_csv(METADATA / "event_window_requirements.csv", index=False)
    return result


def coverage_report(prices: pd.DataFrame, events: pd.DataFrame, windows: pd.DataFrame) -> pd.DataFrame:
    min_event = min(events["official_date"])
    required_start = windows["price_start_for_return_at_t_minus_200"].replace("", pd.NA).dropna().min()
    required_end = windows["event_window_end_t_plus_20"].replace("", pd.NA).dropna().max()
    report = (
        prices.groupby("symbol")
        .agg(
            rows=("date", "size"),
            first_date=("date", "min"),
            last_date=("date", "max"),
            nonmissing_adj_close=("adj_close", lambda s: int(s.notna().sum())),
        )
        .reset_index()
    )
    report["required_start"] = required_start
    report["required_end_for_event_windows"] = required_end
    report["covers_required_start"] = report["first_date"] <= required_start
    report["covers_required_end"] = report["last_date"] >= required_end
    report["starts_after_first_event"] = report["first_date"] > min_event.isoformat()
    report["last_before_last_event_window"] = report["last_date"] < required_end
    report["starts_after_required_price_start"] = report["first_date"] > required_start
    report.to_csv(REPORTS / "coverage_report.csv", index=False)
    return report


def write_report(
    firms: pd.DataFrame,
    events: pd.DataFrame,
    prices: pd.DataFrame,
    factors: pd.DataFrame,
    statuses: list[DownloadStatus],
    coverage: pd.DataFrame,
    windows: pd.DataFrame,
) -> None:
    status_df = pd.DataFrame([s.__dict__ for s in statuses])
    status_df.to_csv(REPORTS / "yahoo_download_status.csv", index=False)
    failed = status_df[~status_df["ok"]]
    late = coverage[coverage["starts_after_required_price_start"] & ~coverage["symbol"].isin(BENCHMARKS)]
    gaps = coverage[coverage["last_before_last_event_window"]]
    rolled = windows[windows["date_roll_rule"] != "same_day"]
    review_flags = windows[windows["date_review_flag"]]
    required_start = coverage["required_start"].dropna().iloc[0] if not coverage.empty else ""
    required_end = coverage["required_end_for_event_windows"].dropna().iloc[0] if not coverage.empty else ""

    report = f"""# CAR 数据收集报告

生成时间：{datetime.now().isoformat(timespec='seconds')}

## 输入范围

- 事件数：{len(events)}
- 事件日期范围：{min(events['official_date'])} 至 {max(events['official_date'])}
- 公司池总数：{len(firms)}
- NDXT 主样本证券数：{int(firms['is_main_ndxt'].sum())}
- SOX/SOXX 稳健性样本：{int(firms['is_sox_robustness'].sum())}
- 合并去重下载股票数：{firms['ticker'].nunique()}
- 市场基准：{', '.join(BENCHMARKS)}
- 下载日期范围：{START_DATE} 至 {END_DATE}
- CAR 最低价格覆盖起点：{required_start}
- CAR 最长事件窗终点：{required_end}

## 已生成数据

- `CAR/metadata/firm_universe_for_car.csv`
- `CAR/metadata/event_dates_for_car.csv`
- `CAR/metadata/event_dates_with_trading_day.csv`
- `CAR/metadata/event_window_requirements.csv`
- `CAR/metadata/ndxt45_tickers.csv`
- `CAR/metadata/robustness_sox_tickers.csv`
- `CAR/processed/prices_daily_long.csv`
- `CAR/processed/returns_daily_long.csv`
- `CAR/processed/market_benchmarks_daily.csv`
- `CAR/processed/ff3_daily.csv`
- `CAR/reports/yahoo_download_status.csv`
- `CAR/reports/coverage_report.csv`

## 来源

- 股票、ETF 和指数日度价格来自 Yahoo Finance Chart API `query2`，原始 JSON 保存在 `CAR/raw/yahoo_chart_json/`。
- Fama-French 3 因子日度数据来自 Kenneth French Data Library，原始 zip 和解压 CSV 保存在 `CAR/raw/factors/`。

## 下载结果

- 成功下载 symbol 数：{int(status_df['ok'].sum())}
- 下载失败 symbol 数：{len(failed)}
- FF3 日度记录数：{len(factors)}
- 价格长表记录数：{len(prices)}
- 非交易日顺延事件数：{len(rolled)}
- 日期复核标记事件数：{len(review_flags)}

## 需要注意

- 部分 2024 或 2025 年后上市公司没有覆盖早期事件的估计窗。报告中 `starts_after_first_event=true` 的股票需要在面板构造时按上市日期处理。
- `event_trading_date` 目前只按日期顺延到最近美股交易日，没有使用盘前、盘中、盘后发布时间。
- 当前股票池仍是当前成分股快照，不是历史基准日成分股。

## 非交易日顺延事件

{rolled[['event_id','official_date','event_trading_date','date_roll_rule','model_names']].to_markdown(index=False) if not rolled.empty else '无。'}

## 日期复核标记

{review_flags[['event_id','official_date','event_trading_date','date_confidence','multi_component_date_flag','official_date_month_matches_ai_month','model_names']].to_markdown(index=False) if not review_flags.empty else '无。'}

## 下载失败

{failed.to_markdown(index=False) if not failed.empty else '无。'}

## 上市较晚或早期覆盖不足

{late[['symbol','first_date','last_date','rows']].to_markdown(index=False) if not late.empty else '无。'}

## 末端覆盖不足

{gaps[['symbol','first_date','last_date','rows']].to_markdown(index=False) if not gaps.empty else '无。'}
"""
    (REPORTS / "data_collection_report.md").write_text(report, encoding="utf-8")


def main() -> None:
    ensure_dirs()
    firms = load_universe()
    events = load_events()

    symbols = sorted(firms["download_symbol"].dropna().unique().tolist())
    all_symbols = symbols + list(BENCHMARKS.keys())
    pd.DataFrame(
        {
            "symbol": all_symbols,
            "is_stock_universe": [s in symbols for s in all_symbols],
            "is_benchmark": [s in BENCHMARKS for s in all_symbols],
            "benchmark_name": [BENCHMARKS.get(s, "") for s in all_symbols],
        }
    ).to_csv(METADATA / "download_universe_tickers.csv", index=False)

    factors = fetch_ff3_daily()

    frames: list[pd.DataFrame] = []
    statuses: list[DownloadStatus] = []
    for idx, symbol in enumerate(all_symbols, start=1):
        frame, status = fetch_yahoo_symbol(symbol, START_DATE, END_DATE)
        frames.append(frame)
        statuses.append(status)
        print(f"[{idx:03d}/{len(all_symbols):03d}] {symbol} ok={status.ok} rows={status.rows} {status.message}", flush=True)

    prices = pd.concat([f for f in frames if not f.empty], ignore_index=True) if frames else pd.DataFrame()
    prices = add_sample_flags(prices, firms)
    prices.to_csv(PROCESSED / "prices_daily_long.csv", index=False)

    benchmarks = prices[prices["symbol"].isin(BENCHMARKS)].copy()
    benchmarks.to_csv(PROCESSED / "market_benchmarks_daily.csv", index=False)
    windows = event_window_requirements(events, benchmarks)

    returns = compute_returns(prices)
    returns.to_csv(PROCESSED / "returns_daily_long.csv", index=False)

    coverage = coverage_report(prices, events, windows)
    write_report(firms, events, prices, factors, statuses, coverage, windows)


if __name__ == "__main__":
    main()
