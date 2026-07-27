#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
CAR = ROOT / "CAR"
PROCESSED = CAR / "processed"
METADATA = CAR / "metadata"
REPORTS = CAR / "reports"


def main() -> None:
    prices = pd.read_csv(PROCESSED / "prices_daily_long.csv", parse_dates=["date"], low_memory=False)
    windows = pd.read_csv(METADATA / "event_window_requirements.csv")
    firms = pd.read_csv(METADATA / "firm_universe_for_car.csv")
    factors = pd.read_csv(PROCESSED / "ff3_daily.csv", parse_dates=["date"])
    benchmarks = pd.read_csv(PROCESSED / "market_benchmarks_daily.csv", parse_dates=["date"])

    stock_symbols = firms["ticker"].astype(str).tolist()
    price_stock = prices[prices["symbol"].isin(stock_symbols)].copy()

    date_sets = price_stock.groupby("symbol")["date"].apply(lambda s: set(s.dt.date)).to_dict()
    available_dates = price_stock.groupby("symbol").agg(first_date=("date", "min"), last_date=("date", "max"))
    available_dates["first_date"] = available_dates["first_date"].dt.date.astype(str)
    available_dates["last_date"] = available_dates["last_date"].dt.date.astype(str)

    rows: list[dict[str, object]] = []
    needed_cols = [
        "price_start_for_return_at_t_minus_200",
        "estimation_start_t_minus_200",
        "estimation_end_t_minus_10",
        "pre_window_start_t_minus_10",
        "pre_window_end_t_minus_2",
        "event_trading_date",
        "event_window_end_t_plus_20",
    ]
    for event in windows.to_dict("records"):
        required_dates = [pd.to_datetime(event[col]).date() for col in needed_cols if pd.notna(event[col]) and event[col]]
        for _, firm in firms.iterrows():
            symbol = str(firm["ticker"])
            dates = date_sets.get(symbol, set())
            missing_required = [d.isoformat() for d in required_dates if d not in dates]
            row = {
                "event_id": event["event_id"],
                "official_date": event["official_date"],
                "event_trading_date": event["event_trading_date"],
                "ticker": symbol,
                "company": firm["company"],
                "is_main_ndxt": bool(firm["is_main_ndxt"]),
                "is_sox_robustness": bool(firm["is_sox_robustness"]),
                "price_first_date": available_dates.loc[symbol, "first_date"] if symbol in available_dates.index else "",
                "price_last_date": available_dates.loc[symbol, "last_date"] if symbol in available_dates.index else "",
                "has_required_boundary_dates": len(missing_required) == 0,
                "missing_required_boundary_dates": ";".join(missing_required),
                "can_estimate_full_200_day_window": (
                    pd.notna(event["price_start_for_return_at_t_minus_200"])
                    and bool(event["price_start_for_return_at_t_minus_200"])
                    and symbol in available_dates.index
                    and available_dates.loc[symbol, "first_date"] <= str(event["price_start_for_return_at_t_minus_200"])
                    and available_dates.loc[symbol, "last_date"] >= str(event["estimation_end_t_minus_10"])
                ),
                "can_compute_event_window_20": (
                    symbol in available_dates.index
                    and available_dates.loc[symbol, "first_date"] <= str(event["event_trading_date"])
                    and available_dates.loc[symbol, "last_date"] >= str(event["event_window_end_t_plus_20"])
                ),
            }
            row["car_ready_max_window"] = row["can_estimate_full_200_day_window"] and row["can_compute_event_window_20"]
            rows.append(row)

    audit = pd.DataFrame(rows)
    audit.to_csv(REPORTS / "event_ticker_car_readiness.csv", index=False)

    by_ticker = (
        audit.groupby(["ticker", "company", "is_main_ndxt", "is_sox_robustness", "price_first_date", "price_last_date"])
        .agg(
            events_total=("event_id", "size"),
            events_car_ready=("car_ready_max_window", "sum"),
            events_missing=("car_ready_max_window", lambda s: int((~s).sum())),
            first_unready_event=("event_id", lambda s: audit.loc[s.index[~audit.loc[s.index, "car_ready_max_window"]], "event_id"].iloc[0] if (~audit.loc[s.index, "car_ready_max_window"]).any() else ""),
        )
        .reset_index()
    )
    by_ticker.to_csv(REPORTS / "car_readiness_by_ticker.csv", index=False)

    factor_dates = set(factors["date"].dt.date)
    spy_dates = set(benchmarks[benchmarks["symbol"] == "SPY"]["date"].dt.date)
    benchmark_summary = benchmarks.groupby("symbol").agg(first_date=("date", "min"), last_date=("date", "max"), rows=("date", "size")).reset_index()
    benchmark_summary["first_date"] = benchmark_summary["first_date"].dt.date.astype(str)
    benchmark_summary["last_date"] = benchmark_summary["last_date"].dt.date.astype(str)
    benchmark_summary.to_csv(REPORTS / "benchmark_coverage.csv", index=False)

    missing_factor_vs_spy = sorted(d.isoformat() for d in spy_dates - factor_dates)
    extra_factor_vs_spy = sorted(d.isoformat() for d in factor_dates - spy_dates)
    pd.DataFrame(
        {
            "check": ["spy_dates_missing_from_ff3", "ff3_dates_not_in_spy"],
            "count": [len(missing_factor_vs_spy), len(extra_factor_vs_spy)],
            "dates": [";".join(missing_factor_vs_spy), ";".join(extra_factor_vs_spy)],
        }
    ).to_csv(REPORTS / "factor_market_date_alignment.csv", index=False)

    summary = f"""# CAR 输入校验报告

## 样本规模

- 公司数：{len(firms)}
- 事件数：{windows['event_id'].nunique()}
- event × ticker 组合数：{len(audit)}
- 最大窗口可计算组合数：{int(audit['car_ready_max_window'].sum())}
- 最大窗口不可计算组合数：{int((~audit['car_ready_max_window']).sum())}

## 不可计算组合的主要来源

以下公司上市或可用价格起点较晚，无法覆盖早期事件的 `[-200,-11]` 估计窗。

{by_ticker[by_ticker['events_missing'] > 0][['ticker','company','price_first_date','price_last_date','events_total','events_car_ready','events_missing','first_unready_event']].to_markdown(index=False)}

## 基准和 FF3 对齐

- SPY 交易日缺少 FF3 因子日期数：{len(missing_factor_vs_spy)}
- FF3 因子日期不在 SPY 交易日数：{len(extra_factor_vs_spy)}

## 生成文件

- `CAR/reports/event_ticker_car_readiness.csv`
- `CAR/reports/car_readiness_by_ticker.csv`
- `CAR/reports/benchmark_coverage.csv`
- `CAR/reports/factor_market_date_alignment.csv`
"""
    (REPORTS / "input_validation_report.md").write_text(summary, encoding="utf-8")


if __name__ == "__main__":
    main()
