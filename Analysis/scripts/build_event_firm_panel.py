#!/usr/bin/env python3
from __future__ import annotations

import math
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
CAR = ROOT / "CAR"
FUND = ROOT / "Fundamentals"
ANALYSIS = ROOT / "Analysis"
PROCESSED = ANALYSIS / "processed"
REPORTS = ANALYSIS / "reports"

EVENTS_FILE = CAR / "metadata" / "event_dates_with_trading_day.csv"
FIRMS_FILE = CAR / "metadata" / "firm_universe_for_car.csv"
RETURNS_FILE = CAR / "processed" / "returns_daily_long.csv"
FF3_FILE = CAR / "processed" / "ff3_daily.csv"
FUNDAMENTALS_FILE = FUND / "processed" / "fundamentals_quarterly_wide.csv"
READINESS_FILE = CAR / "reports" / "event_ticker_car_readiness.csv"
AA_METRICS_FILE = ROOT / "new data set" / "processed" / "event_aa_metrics.csv"
LABELS_FILE = ROOT / "new data set" / "decisions" / "event_label_decisions.csv"
RELATIONSHIP_FILE = ROOT / "new data set" / "decisions" / "relationship_decisions.csv"

REL_DIMS = [
    ("r1_upstream_hardware", "rel_upstream_hardware"),
    ("r2_upstream_cloud", "rel_upstream_cloud"),
    ("r3_downstream_integrator", "rel_downstream_integrator"),
    ("r4_downstream_deployer", "rel_downstream_deployer"),
    ("r5_downstream_enabler", "rel_downstream_enabler"),
    ("r6_competitor", "rel_competitor"),
    ("f1_is_investor", "rel_is_investor"),
    ("f2_is_owner", "rel_is_owner"),
]

# D1（decisions/analysis_design_decisions.md）：事件身份三方矛盾，主样本剔除
IDENTITY_EXCLUDED_EVENTS = {"AIT-2026-02-006"}

BENCHMARKS = ["QQQ", "SPY", "SOXX"]
MIN_ESTIMATION_OBS = 120
ESTIMATION_WINDOW = (-200, -11)
# 动量与波动率控制变量（沿用旧面板定义：事件前12个月动量、事件前波动率）
MOMENTUM_WINDOW = (-252, -21)
MIN_MOMENTUM_OBS = 120
# 财务合并：只允许使用事件日之前已公开的报表。
# 可用日 = 财政期末 + FILING_LAG（10-Q 法定披露期约 40-45 天）；
# 过旧报表截断于 MAX_STALENESS（400 天，容纳 CCEP/FER 半年报公司）。
FUND_FILING_LAG_DAYS = 45
FUND_MAX_STALENESS_DAYS = 400
WINDOWS = {
    "pre_m10_m2": (-10, -2),
    "m1_p1": (-1, 1),
    "m3_p3": (-3, 3),
    "m5_p5": (-5, 5),
    "0_0": (0, 0),
    "0_1": (0, 1),
    "0_2": (0, 2),
    "0_3": (0, 3),
    "0_5": (0, 5),
    "0_10": (0, 10),
    "0_15": (0, 15),
    "0_20": (0, 20),
}


def ensure_dirs() -> None:
    PROCESSED.mkdir(parents=True, exist_ok=True)
    REPORTS.mkdir(parents=True, exist_ok=True)


def qstr(series: pd.Series) -> pd.Series:
    return pd.to_datetime(series).dt.to_period("Q").astype(str)


def safe_symbol(symbol: str) -> str:
    return symbol.lower().replace("^", "").replace("-", "_")


def fit_market_model(frame: pd.DataFrame, bench_col: str) -> dict[str, float | bool | int]:
    start, end = ESTIMATION_WINDOW
    est = frame.loc[(frame["rel_day"] >= start) & (frame["rel_day"] <= end), ["stock_ret", bench_col]].dropna()
    out: dict[str, float | bool | int] = {
        "alpha": math.nan,
        "beta": math.nan,
        "estimation_obs": int(len(est)),
        "model_ready": False,
    }
    if len(est) < MIN_ESTIMATION_OBS:
        return out
    x = est[bench_col].to_numpy(dtype=float)
    y = est["stock_ret"].to_numpy(dtype=float)
    var_x = float(np.var(x, ddof=1))
    if not np.isfinite(var_x) or var_x <= 0:
        return out
    beta = float(np.cov(x, y, ddof=1)[0, 1] / var_x)
    alpha = float(np.mean(y) - beta * np.mean(x))
    out.update({"alpha": alpha, "beta": beta, "model_ready": True})
    return out


def fit_ff3_model(frame: pd.DataFrame) -> dict[str, float | bool | int]:
    cols = ["stock_ret", "Mkt_RF_decimal", "SMB_decimal", "HML_decimal", "RF_decimal"]
    start, end = ESTIMATION_WINDOW
    est = frame.loc[(frame["rel_day"] >= start) & (frame["rel_day"] <= end), cols].dropna()
    out: dict[str, float | bool | int] = {
        "alpha": math.nan,
        "beta_mkt": math.nan,
        "beta_smb": math.nan,
        "beta_hml": math.nan,
        "estimation_obs": int(len(est)),
        "model_ready": False,
    }
    if len(est) < MIN_ESTIMATION_OBS:
        return out
    y = (est["stock_ret"] - est["RF_decimal"]).to_numpy(dtype=float)
    x = est[["Mkt_RF_decimal", "SMB_decimal", "HML_decimal"]].to_numpy(dtype=float)
    x = np.column_stack([np.ones(len(x)), x])
    try:
        coef, _, rank, _ = np.linalg.lstsq(x, y, rcond=None)
    except np.linalg.LinAlgError:
        return out
    if rank < x.shape[1]:
        return out
    out.update(
        {
            "alpha": float(coef[0]),
            "beta_mkt": float(coef[1]),
            "beta_smb": float(coef[2]),
            "beta_hml": float(coef[3]),
            "model_ready": True,
        }
    )
    return out


def window_car_market_model(
    frame: pd.DataFrame,
    bench_col: str,
    alpha: float,
    beta: float,
    start: int,
    end: int,
) -> tuple[float, int, bool]:
    cols = ["stock_ret", bench_col]
    sub = frame.loc[(frame["rel_day"] >= start) & (frame["rel_day"] <= end), cols].dropna()
    expected_obs = end - start + 1
    complete = len(sub) == expected_obs
    if not complete or not np.isfinite(alpha) or not np.isfinite(beta):
        return math.nan, int(len(sub)), bool(complete)
    abnormal = sub["stock_ret"] - (alpha + beta * sub[bench_col])
    return float(abnormal.sum()), int(len(sub)), bool(complete)


def window_car_ff3(
    frame: pd.DataFrame,
    alpha: float,
    beta_mkt: float,
    beta_smb: float,
    beta_hml: float,
    start: int,
    end: int,
) -> tuple[float, int, bool]:
    cols = ["stock_ret", "Mkt_RF_decimal", "SMB_decimal", "HML_decimal", "RF_decimal"]
    sub = frame.loc[(frame["rel_day"] >= start) & (frame["rel_day"] <= end), cols].dropna()
    expected_obs = end - start + 1
    complete = len(sub) == expected_obs
    params = [alpha, beta_mkt, beta_smb, beta_hml]
    if not complete or not all(np.isfinite(v) for v in params):
        return math.nan, int(len(sub)), bool(complete)
    expected = (
        sub["RF_decimal"]
        + alpha
        + beta_mkt * sub["Mkt_RF_decimal"]
        + beta_smb * sub["SMB_decimal"]
        + beta_hml * sub["HML_decimal"]
    )
    abnormal = sub["stock_ret"] - expected
    return float(abnormal.sum()), int(len(sub)), bool(complete)


def load_market_arrays() -> tuple[dict[str, object], dict[pd.Timestamp, int]]:
    returns = pd.read_csv(RETURNS_FILE, parse_dates=["date"], low_memory=False)
    ff3 = pd.read_csv(FF3_FILE, parse_dates=["date"], low_memory=False)

    stock_returns = returns.loc[returns["is_benchmark"] == False, ["date", "symbol", "ret_adj_close"]].copy()
    stock_returns = stock_returns.rename(columns={"symbol": "ticker", "ret_adj_close": "stock_ret"})

    benchmark_returns = returns.loc[
        returns["symbol"].isin(BENCHMARKS),
        ["date", "symbol", "ret_adj_close"],
    ].copy()
    bench_wide = benchmark_returns.pivot(index="date", columns="symbol", values="ret_adj_close").reset_index()
    bench_wide = bench_wide.rename(columns={symbol: f"bench_ret_{safe_symbol(symbol)}" for symbol in BENCHMARKS})

    calendar = bench_wide[["date"]].drop_duplicates().sort_values("date").reset_index(drop=True)
    calendar["trading_index"] = np.arange(len(calendar))
    market_frame = calendar.merge(bench_wide, on="date", how="left").merge(ff3, on="date", how="left")
    date_to_pos = dict(zip(market_frame["date"], market_frame["trading_index"]))

    stock_wide = stock_returns.pivot(index="date", columns="ticker", values="stock_ret").reindex(market_frame["date"])
    arrays: dict[str, object] = {
        "dates": market_frame["date"].to_numpy(),
        "bench": {
            safe_symbol(symbol): market_frame[f"bench_ret_{safe_symbol(symbol)}"].to_numpy(dtype=float)
            for symbol in BENCHMARKS
        },
        "ff3": {
            "Mkt_RF_decimal": market_frame["Mkt_RF_decimal"].to_numpy(dtype=float),
            "SMB_decimal": market_frame["SMB_decimal"].to_numpy(dtype=float),
            "HML_decimal": market_frame["HML_decimal"].to_numpy(dtype=float),
            "RF_decimal": market_frame["RF_decimal"].to_numpy(dtype=float),
        },
        "stocks": {ticker: stock_wide[ticker].to_numpy(dtype=float) for ticker in stock_wide.columns},
    }
    return arrays, date_to_pos


def bounded_slice(pos: int, start: int, end: int, nobs: int) -> tuple[int, int, bool]:
    left = pos + start
    right = pos + end
    in_bounds = left >= 0 and right < nobs
    left = max(left, 0)
    right = min(right, nobs - 1)
    return left, right, in_bounds and left <= right


def fit_market_model_arrays(stock_ret: np.ndarray, bench_ret: np.ndarray, pos: int) -> dict[str, float | bool | int]:
    out: dict[str, float | bool | int] = {
        "alpha": math.nan,
        "beta": math.nan,
        "estimation_obs": 0,
        "model_ready": False,
    }
    left, right, in_bounds = bounded_slice(pos, ESTIMATION_WINDOW[0], ESTIMATION_WINDOW[1], len(stock_ret))
    if not in_bounds:
        return out
    y = stock_ret[left : right + 1]
    x = bench_ret[left : right + 1]
    valid = np.isfinite(y) & np.isfinite(x)
    out["estimation_obs"] = int(valid.sum())
    if int(valid.sum()) < MIN_ESTIMATION_OBS:
        return out
    x = x[valid]
    y = y[valid]
    var_x = float(np.var(x, ddof=1))
    if not np.isfinite(var_x) or var_x <= 0:
        return out
    beta = float(np.cov(x, y, ddof=1)[0, 1] / var_x)
    alpha = float(np.mean(y) - beta * np.mean(x))
    out.update({"alpha": alpha, "beta": beta, "model_ready": True})
    return out


def fit_ff3_model_arrays(stock_ret: np.ndarray, ff3: dict[str, np.ndarray], pos: int) -> dict[str, float | bool | int]:
    out: dict[str, float | bool | int] = {
        "alpha": math.nan,
        "beta_mkt": math.nan,
        "beta_smb": math.nan,
        "beta_hml": math.nan,
        "estimation_obs": 0,
        "model_ready": False,
    }
    left, right, in_bounds = bounded_slice(pos, ESTIMATION_WINDOW[0], ESTIMATION_WINDOW[1], len(stock_ret))
    if not in_bounds:
        return out
    y = stock_ret[left : right + 1]
    mkt = ff3["Mkt_RF_decimal"][left : right + 1]
    smb = ff3["SMB_decimal"][left : right + 1]
    hml = ff3["HML_decimal"][left : right + 1]
    rf = ff3["RF_decimal"][left : right + 1]
    valid = np.isfinite(y) & np.isfinite(mkt) & np.isfinite(smb) & np.isfinite(hml) & np.isfinite(rf)
    out["estimation_obs"] = int(valid.sum())
    if int(valid.sum()) < MIN_ESTIMATION_OBS:
        return out
    target = y[valid] - rf[valid]
    x = np.column_stack([np.ones(int(valid.sum())), mkt[valid], smb[valid], hml[valid]])
    try:
        coef, _, rank, _ = np.linalg.lstsq(x, target, rcond=None)
    except np.linalg.LinAlgError:
        return out
    if rank < x.shape[1]:
        return out
    out.update(
        {
            "alpha": float(coef[0]),
            "beta_mkt": float(coef[1]),
            "beta_smb": float(coef[2]),
            "beta_hml": float(coef[3]),
            "model_ready": True,
        }
    )
    return out


def window_car_market_model_arrays(
    stock_ret: np.ndarray,
    bench_ret: np.ndarray,
    pos: int,
    alpha: float,
    beta: float,
    start: int,
    end: int,
) -> tuple[float, int, bool]:
    left, right, in_bounds = bounded_slice(pos, start, end, len(stock_ret))
    if left > right:
        return math.nan, 0, False
    y = stock_ret[left : right + 1]
    x = bench_ret[left : right + 1]
    valid = np.isfinite(y) & np.isfinite(x)
    obs = int(valid.sum())
    complete = bool(in_bounds and obs == (end - start + 1))
    if not complete or not np.isfinite(alpha) or not np.isfinite(beta):
        return math.nan, obs, complete
    abnormal = y[valid] - (alpha + beta * x[valid])
    return float(abnormal.sum()), obs, complete


def window_car_ff3_arrays(
    stock_ret: np.ndarray,
    ff3: dict[str, np.ndarray],
    pos: int,
    alpha: float,
    beta_mkt: float,
    beta_smb: float,
    beta_hml: float,
    start: int,
    end: int,
) -> tuple[float, int, bool]:
    left, right, in_bounds = bounded_slice(pos, start, end, len(stock_ret))
    if left > right:
        return math.nan, 0, False
    y = stock_ret[left : right + 1]
    mkt = ff3["Mkt_RF_decimal"][left : right + 1]
    smb = ff3["SMB_decimal"][left : right + 1]
    hml = ff3["HML_decimal"][left : right + 1]
    rf = ff3["RF_decimal"][left : right + 1]
    valid = np.isfinite(y) & np.isfinite(mkt) & np.isfinite(smb) & np.isfinite(hml) & np.isfinite(rf)
    obs = int(valid.sum())
    complete = bool(in_bounds and obs == (end - start + 1))
    params = [alpha, beta_mkt, beta_smb, beta_hml]
    if not complete or not all(np.isfinite(v) for v in params):
        return math.nan, obs, complete
    expected = rf[valid] + alpha + beta_mkt * mkt[valid] + beta_smb * smb[valid] + beta_hml * hml[valid]
    abnormal = y[valid] - expected
    return float(abnormal.sum()), obs, complete


def momentum_arrays(stock_ret: np.ndarray, pos: int) -> tuple[float, int]:
    left, right, in_bounds = bounded_slice(pos, MOMENTUM_WINDOW[0], MOMENTUM_WINDOW[1], len(stock_ret))
    if left > right:
        return math.nan, 0
    y = stock_ret[left : right + 1]
    y = y[np.isfinite(y)]
    if len(y) < MIN_MOMENTUM_OBS:
        return math.nan, int(len(y))
    return float(np.prod(1.0 + y) - 1.0), int(len(y))


def volatility_arrays(stock_ret: np.ndarray, pos: int) -> tuple[float, int]:
    left, right, _ = bounded_slice(pos, ESTIMATION_WINDOW[0], ESTIMATION_WINDOW[1], len(stock_ret))
    if left > right:
        return math.nan, 0
    y = stock_ret[left : right + 1]
    y = y[np.isfinite(y)]
    if len(y) < MIN_ESTIMATION_OBS:
        return math.nan, int(len(y))
    return float(np.std(y, ddof=1) * math.sqrt(252.0)), int(len(y))


def compute_car_panel(events: pd.DataFrame, firms: pd.DataFrame) -> pd.DataFrame:
    market_arrays, date_to_pos = load_market_arrays()
    bench_arrays = market_arrays["bench"]
    ff3_arrays = market_arrays["ff3"]
    stock_arrays = market_arrays["stocks"]
    rows: list[dict[str, object]] = []

    event_positions = {}
    for event in events.to_dict("records"):
        event_date = pd.Timestamp(event["event_trading_date"])
        event_positions[event["event_id"]] = date_to_pos.get(event_date)

    for ticker in firms["ticker"].tolist():
        stock_ret = stock_arrays.get(ticker)
        if stock_ret is None:
            stock_ret = np.full(len(market_arrays["dates"]), math.nan)
        for event in events.to_dict("records"):
            event_id = event["event_id"]
            event_pos = event_positions[event_id]
            row: dict[str, object] = {"event_id": event_id, "ticker": ticker}
            if event_pos is None:
                row["car_event_date_in_market_calendar"] = False
                rows.append(row)
                continue
            row["car_event_date_in_market_calendar"] = True

            mom, mom_obs = momentum_arrays(stock_ret, int(event_pos))
            vol, vol_obs = volatility_arrays(stock_ret, int(event_pos))
            row["momentum"] = mom
            row["momentum_obs"] = mom_obs
            row["volatility"] = vol
            row["volatility_obs"] = vol_obs

            for symbol in BENCHMARKS:
                bench_name = safe_symbol(symbol)
                bench_ret = bench_arrays[bench_name]
                fit = fit_market_model_arrays(stock_ret, bench_ret, int(event_pos))
                row[f"mm_{bench_name}_alpha"] = fit["alpha"]
                row[f"mm_{bench_name}_beta"] = fit["beta"]
                row[f"mm_{bench_name}_estimation_obs"] = fit["estimation_obs"]
                row[f"mm_{bench_name}_model_ready"] = fit["model_ready"]
                for window_name, (start, end) in WINDOWS.items():
                    car, obs, complete = window_car_market_model_arrays(
                        stock_ret,
                        bench_ret,
                        int(event_pos),
                        float(fit["alpha"]),
                        float(fit["beta"]),
                        start,
                        end,
                    )
                    row[f"car_mm_{bench_name}_{window_name}"] = car
                    row[f"car_mm_{bench_name}_{window_name}_obs"] = obs
                    row[f"car_mm_{bench_name}_{window_name}_complete"] = complete

            ff3_fit = fit_ff3_model_arrays(stock_ret, ff3_arrays, int(event_pos))
            row["ff3_alpha"] = ff3_fit["alpha"]
            row["ff3_beta_mkt"] = ff3_fit["beta_mkt"]
            row["ff3_beta_smb"] = ff3_fit["beta_smb"]
            row["ff3_beta_hml"] = ff3_fit["beta_hml"]
            row["ff3_estimation_obs"] = ff3_fit["estimation_obs"]
            row["ff3_model_ready"] = ff3_fit["model_ready"]
            for window_name, (start, end) in WINDOWS.items():
                car, obs, complete = window_car_ff3_arrays(
                    stock_ret,
                    ff3_arrays,
                    int(event_pos),
                    float(ff3_fit["alpha"]),
                    float(ff3_fit["beta_mkt"]),
                    float(ff3_fit["beta_smb"]),
                    float(ff3_fit["beta_hml"]),
                    start,
                    end,
                )
                row[f"car_ff3_{window_name}"] = car
                row[f"car_ff3_{window_name}_obs"] = obs
                row[f"car_ff3_{window_name}_complete"] = complete
            rows.append(row)

    return pd.DataFrame(rows)


def build_panel() -> pd.DataFrame:
    events = pd.read_csv(EVENTS_FILE, parse_dates=["official_date", "event_trading_date"], low_memory=False)
    firms = pd.read_csv(FIRMS_FILE, low_memory=False)
    fundamentals = pd.read_csv(FUNDAMENTALS_FILE, low_memory=False)
    readiness = pd.read_csv(READINESS_FILE, low_memory=False)

    events["event_calendar_quarter"] = qstr(events["event_trading_date"])
    events["official_calendar_quarter"] = qstr(events["official_date"])

    skeleton = events.assign(_key=1).merge(firms.assign(_key=1), on="_key", how="outer").drop(columns="_key")
    car_panel = compute_car_panel(events, firms)

    readiness_cols = [
        "event_id",
        "ticker",
        "has_required_boundary_dates",
        "missing_required_boundary_dates",
        "can_estimate_full_200_day_window",
        "can_compute_event_window_20",
        "car_ready_max_window",
    ]
    skeleton = skeleton.merge(readiness[readiness_cols], on=["event_id", "ticker"], how="left")
    panel = skeleton.merge(car_panel, on=["event_id", "ticker"], how="left")

    fund_cols = [
        "ticker",
        "calendar_quarter",
        "period_end_date",
        "fiscal_year",
        "fiscal_quarter",
        "financial_currency",
        "price_currency",
        "total_assets",
        "stockholders_equity",
        "book_value",
        "book_value_per_share",
        "shares_basic",
        "shares_diluted",
        "shares_for_market_cap",
        "shares_for_market_cap_source",
        "quarter_price_date",
        "quarter_end_close_usd",
        "quarter_end_market_cap_usd",
        "financial_fx_date",
        "financial_fx_to_usd",
        "financial_fx_symbol",
        "total_assets_usd",
        "stockholders_equity_usd",
        "book_value_usd",
        "size_log_assets",
        "bm_ratio",
        "source",
    ]
    fund = fundamentals[fund_cols].rename(
        columns={
            "calendar_quarter": "fund_calendar_quarter",
            "period_end_date": "fund_period_end_date",
            "fiscal_year": "fund_fiscal_year",
            "fiscal_quarter": "fund_fiscal_quarter",
            "source": "fund_source",
        }
    )
    # 滞后 as-of 合并：只用事件日之前已披露的报表，杜绝前视。
    # 可用日 = period_end + FUND_FILING_LAG_DAYS；取事件日前最近一期；
    # 报表过旧（期末距事件日超过 FUND_MAX_STALENESS_DAYS）置缺失。
    fund = fund.dropna(subset=["fund_period_end_date"]).copy()
    fund["fund_period_end_date"] = pd.to_datetime(fund["fund_period_end_date"])
    fund["fund_available_date"] = fund["fund_period_end_date"] + pd.Timedelta(days=FUND_FILING_LAG_DAYS)
    fund = fund.sort_values("fund_available_date")

    panel = panel.sort_values("event_trading_date").reset_index(drop=True)
    panel = pd.merge_asof(
        panel,
        fund,
        left_on="event_trading_date",
        right_on="fund_available_date",
        by="ticker",
        direction="backward",
        tolerance=pd.Timedelta(days=FUND_MAX_STALENESS_DAYS - FUND_FILING_LAG_DAYS),
    )
    panel["fund_staleness_days"] = (panel["event_trading_date"] - panel["fund_period_end_date"]).dt.days

    panel["leverage"] = 1 - panel["stockholders_equity_usd"] / panel["total_assets_usd"]

    # 负权益处理：bm_ratio 为负没有经济意义（回购型负权益公司），
    # 置缺失并保留 dummy；原值留在 bm_ratio_raw 供稳健性使用。
    panel["negative_equity"] = panel["stockholders_equity_usd"] < 0
    panel["bm_ratio_raw"] = panel["bm_ratio"]
    panel.loc[panel["negative_equity"] == True, "bm_ratio"] = np.nan

    # 事件级 AA 能力指标（旗舰代表模型，见 new data set/scripts/build_event_aa_metrics.py）
    aa_metrics = pd.read_csv(AA_METRICS_FILE, low_memory=False)
    panel = panel.merge(aa_metrics, on="event_id", how="left")

    # 事件标签（双盲编码 A/B + 仲裁定稿，见 decisions/event_label_decisions.csv）
    labels = pd.read_csv(LABELS_FILE, low_memory=False)
    label_cols = ["event_id", "model_modalities", "is_cross_modality_release", "is_model_family",
                  "is_multimodal", "is_reasoning_model", "is_coding_model",
                  "is_media_generation_model", "is_open_weight_or_open_source", "is_chinese_model"]
    panel = panel.merge(labels[label_cols], on="event_id", how="left")

    # D1：事件身份存疑剔除标记（主回归样本应排除 event_excluded_identity == True）
    panel["event_excluded_identity"] = panel["event_id"].isin(IDENTITY_EXCLUDED_EVENTS)

    # 关系编码（双盲 A/B + 仲裁定稿，decisions/relationship_decisions.csv）。
    # 编码单位是（公司×发布方）；事件级取该事件全部发布方的并集（多发布方事件如
    # Kling/Runway/Vidu 三连发，任一发布方命中即记 1）。
    rel = pd.read_csv(RELATIONSHIP_FILE, low_memory=False)
    rel_map = {(r["ticker"], r["creator"]): r for r in rel.to_dict("records")}
    ev_creators = {
        e["event_id"]: [c.strip() for c in str(e["aa_creators"]).split(";") if c.strip()]
        for e in events.to_dict("records")
    }
    for src, dst in REL_DIMS:
        panel[dst] = [
            int(any(rel_map.get((t, c), {}).get(src, 0) == 1 for c in ev_creators.get(eid, [])))
            for eid, t in zip(panel["event_id"], panel["ticker"])
        ]

    first_cols = [
        "event_id",
        "ticker",
        "company",
        "gics_sector",
        "index_tag",
        "is_main_nasdaq100",
        "is_sox_robustness",
        "official_date",
        "event_trading_date",
        "event_calendar_quarter",
        "model_names",
        "aa_creators",
        "model_count",
        "date_status",
        "date_confidence",
        "release_time_status",
        "date_review_flag",
        "fund_calendar_quarter",
        "fund_period_end_date",
        "fund_staleness_days",
        "total_assets_usd",
        "stockholders_equity_usd",
        "quarter_end_market_cap_usd",
        "size_log_assets",
        "bm_ratio",
        "bm_ratio_raw",
        "negative_equity",
        "leverage",
        "momentum",
        "volatility",
        "aa_metric_type",
        "representative_aa_name",
        "aa_intelligence_index",
        "elo",
        "event_excluded_identity",
        "car_mm_spy_0_20",
        "car_mm_qqq_0_20",
        "car_mm_soxx_0_20",
        "car_ff3_0_20",
    ]
    ordered = [c for c in first_cols if c in panel.columns] + [c for c in panel.columns if c not in first_cols]
    return panel[ordered].sort_values(["event_trading_date", "event_id", "ticker"]).reset_index(drop=True)


def write_reports(panel: pd.DataFrame) -> None:
    panel.to_csv(PROCESSED / "event_firm_panel.csv", index=False)
    panel.loc[panel["is_main_nasdaq100"] == True].to_csv(PROCESSED / "event_firm_panel_main_nasdaq100.csv", index=False)
    panel.loc[panel["is_sox_robustness"] == True].to_csv(PROCESSED / "event_firm_panel_sox_robustness.csv", index=False)

    coverage_rows = []
    key_cols = [
        "car_mm_qqq_0_20",
        "car_mm_qqq_0_15",
        "car_mm_qqq_0_1",
        "car_mm_spy_0_20",
        "car_mm_soxx_0_20",
        "car_ff3_0_20",
        "total_assets_usd",
        "stockholders_equity_usd",
        "size_log_assets",
        "bm_ratio",
        "leverage",
        "momentum",
        "volatility",
    ]
    for sample_name, sample in [
        ("all", panel),
        ("main_nasdaq100", panel.loc[panel["is_main_nasdaq100"] == True]),
        ("sox_robustness", panel.loc[panel["is_sox_robustness"] == True]),
    ]:
        row = {
            "sample": sample_name,
            "rows": len(sample),
            "events": sample["event_id"].nunique(),
            "tickers": sample["ticker"].nunique(),
        }
        for col in key_cols:
            row[f"{col}_nonmissing"] = int(sample[col].notna().sum()) if col in sample.columns else 0
        coverage_rows.append(row)
    coverage = pd.DataFrame(coverage_rows)
    coverage.to_csv(REPORTS / "event_firm_panel_coverage.csv", index=False)

    ticker_coverage = (
        panel.groupby(["ticker", "company", "is_main_nasdaq100", "is_sox_robustness"], dropna=False)
        .agg(
            rows=("event_id", "size"),
            car_mm_qqq_0_20_nonmissing=("car_mm_qqq_0_20", lambda s: int(s.notna().sum())),
            car_ff3_0_20_nonmissing=("car_ff3_0_20", lambda s: int(s.notna().sum())),
            fundamentals_nonmissing=("total_assets_usd", lambda s: int(s.notna().sum())),
            bm_ratio_nonmissing=("bm_ratio", lambda s: int(s.notna().sum())),
        )
        .reset_index()
    )
    ticker_coverage.to_csv(REPORTS / "event_firm_panel_ticker_coverage.csv", index=False)

    event_coverage = (
        panel.groupby(["event_id", "official_date", "event_trading_date", "model_names"], dropna=False)
        .agg(
            rows=("ticker", "size"),
            car_mm_qqq_0_20_nonmissing=("car_mm_qqq_0_20", lambda s: int(s.notna().sum())),
            car_ff3_0_20_nonmissing=("car_ff3_0_20", lambda s: int(s.notna().sum())),
            fundamentals_nonmissing=("total_assets_usd", lambda s: int(s.notna().sum())),
        )
        .reset_index()
    )
    event_coverage.to_csv(REPORTS / "event_firm_panel_event_coverage.csv", index=False)

    main = coverage.loc[coverage["sample"] == "all"].iloc[0].to_dict()
    report = f"""# Event-firm panel report

Generated at {datetime.now().isoformat(timespec="seconds")}.

## Scope

- Rows: {int(main["rows"])}
- Events: {int(main["events"])}
- Tickers: {int(main["tickers"])}
- Main Nasdaq-100 rows: {int(coverage.loc[coverage["sample"] == "main_nasdaq100", "rows"].iloc[0])}
- SOX robustness rows: {int(coverage.loc[coverage["sample"] == "sox_robustness", "rows"].iloc[0])}

## Main outputs

- `Analysis/processed/event_firm_panel.csv`
- `Analysis/processed/event_firm_panel_main_nasdaq100.csv`
- `Analysis/processed/event_firm_panel_sox_robustness.csv`

## CAR construction

- Return input uses adjusted-close simple returns from `CAR/processed/returns_daily_long.csv`.
- Market-model estimation window is [-200,-10].
- Minimum estimation observations are {MIN_ESTIMATION_OBS}.
- Main benchmark is SPY (decision P4, 2026-07-03: the sample is Nasdaq-100 constituents, so QQQ self-benchmarks). QQQ, SOXX and FF3 are robustness.
- Event AIT-2026-02-006 carries `event_excluded_identity=True` (decision D1); exclude it from the main regression sample.
- Event-level AA capability metrics are merged from `new data set/processed/event_aa_metrics.csv` (flagship representative per event).
- FF3 CAR uses Mkt-RF, SMB, HML and RF from `CAR/processed/ff3_daily.csv`.
- CAR windows include pre [-10,-2], symmetric windows [-1,+1], [-3,+3], [-5,+5], and forward windows [0,+0], [0,+1], [0,+2], [0,+3], [0,+5], [0,+10], [0,+15], [0,+20].

## Financial merge

- Lagged as-of merge: only statements disclosed before the event date are used.
- Availability date = fiscal period end + {FUND_FILING_LAG_DAYS} days (10-Q filing lag); the most recent available statement is matched.
- Statements older than {FUND_MAX_STALENESS_DAYS} days (period end to event date) are treated as missing; the cap accommodates semiannual reporters (CCEP, FER).
- `fund_staleness_days` records the age of the matched statement.

## Control variables

- `momentum`: cumulative simple return over trading days [{MOMENTUM_WINDOW[0]},{MOMENTUM_WINDOW[1]}] before the event (12-month momentum, min {MIN_MOMENTUM_OBS} obs).
- `volatility`: annualized std of daily returns over the estimation window [{ESTIMATION_WINDOW[0]},{ESTIMATION_WINDOW[1]}].
- `negative_equity`: stockholders' equity < 0 (buyback-driven). For these rows `bm_ratio` is set to missing; the raw value is kept in `bm_ratio_raw`.

## Coverage

- `car_mm_qqq_0_20` nonmissing: {int(main["car_mm_qqq_0_20_nonmissing"])}
- `car_ff3_0_20` nonmissing: {int(main["car_ff3_0_20_nonmissing"])}
- `total_assets_usd` nonmissing: {int(main["total_assets_usd_nonmissing"])}
- `bm_ratio` nonmissing: {int(main["bm_ratio_nonmissing"])}
- `momentum` nonmissing: {int(main["momentum_nonmissing"])}
- `volatility` nonmissing: {int(main["volatility_nonmissing"])}

See `Analysis/reports/event_firm_panel_coverage.csv` for sample-level details.
"""
    (REPORTS / "event_firm_panel_report.md").write_text(report, encoding="utf-8")


def main() -> None:
    ensure_dirs()
    panel = build_panel()
    write_reports(panel)
    print(f"event_firm_panel rows={len(panel)}")
    print(f"events={panel['event_id'].nunique()} tickers={panel['ticker'].nunique()}")
    print(f"car_mm_qqq_0_20_nonmissing={panel['car_mm_qqq_0_20'].notna().sum()}")
    print(f"car_ff3_0_20_nonmissing={panel['car_ff3_0_20'].notna().sum()}")
    print(f"total_assets_usd_nonmissing={panel['total_assets_usd'].notna().sum()}")
    print(f"bm_ratio_nonmissing={panel['bm_ratio'].notna().sum()}")


if __name__ == "__main__":
    main()
