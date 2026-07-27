#!/usr/bin/env python3
"""Build reproducible NDXT45 CAR sensitivity panels.

The shifted design keeps the original event-date market-model parameters and
moves only the return-accumulation window forward by one trading day. Thus its
reported [0,k] window is calculated over original relative days [1,k+1].
The symmetric design reports the SPY market-model CAR over [-14,+14].
"""

from __future__ import annotations

import importlib.util
from datetime import datetime
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
ANALYSIS = ROOT / "Analysis"
PANEL_SCRIPT = ANALYSIS / "scripts" / "build_event_firm_panel.py"
EVENTS_FILE = ROOT / "CAR" / "metadata" / "event_dates_with_trading_day.csv"
FIRMS_FILE = ROOT / "CAR" / "metadata" / "firm_universe_for_car.csv"
PROCESSED = ANALYSIS / "processed"
REPORTS = ANALYSIS / "reports"

SHIFTED_WINDOWS = {
    "s1_0_1": (1, 2),
    "s1_0_2": (1, 3),
    "s1_0_5": (1, 6),
    "s1_0_20": (1, 21),
}
SYMMETRIC_WINDOWS = {"sym14": (-14, 14)}


def load_panel_module():
    spec = importlib.util.spec_from_file_location(
        "event_firm_panel_builder", PANEL_SCRIPT
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load {PANEL_SCRIPT}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> None:
    module = load_panel_module()
    if tuple(module.ESTIMATION_WINDOW) != (-200, -11):
        raise RuntimeError(
            f"Unexpected estimation window {module.ESTIMATION_WINDOW}"
        )

    events = pd.read_csv(EVENTS_FILE, low_memory=False)[
        ["event_id", "event_trading_date"]
    ]
    firms = pd.read_csv(FIRMS_FILE, low_memory=False)
    if len(firms) != 45 or firms["ticker"].nunique() != 45:
        raise RuntimeError("Sensitivity panels require the 45-security NDXT basket.")

    module.WINDOWS = {**SHIFTED_WINDOWS, **SYMMETRIC_WINDOWS}
    computed = module.compute_car_panel(events, firms)

    shifted_map = {
        f"car_mm_spy_{key}": f"car_{key}"
        for key in SHIFTED_WINDOWS
    }
    shifted = computed[
        ["event_id", "ticker", *shifted_map]
    ].rename(columns=shifted_map)
    shifted_value_cols = list(shifted_map.values())
    shifted = shifted.loc[
        shifted[shifted_value_cols].notna().any(axis=1)
    ].reset_index(drop=True)
    shifted.to_csv(
        PROCESSED / "event_firm_car_shifted.csv",
        index=False,
        float_format="%.12g",
    )

    symmetric = computed[
        ["event_id", "ticker", "car_mm_spy_sym14"]
    ].rename(columns={"car_mm_spy_sym14": "car_sym14"})
    symmetric = symmetric.loc[symmetric["car_sym14"].notna()].reset_index(drop=True)
    symmetric.to_csv(
        PROCESSED / "event_firm_car_sym14.csv",
        index=False,
        float_format="%.12g",
    )

    report = f"""# NDXT45 CAR sensitivity panels

Generated at {datetime.now().isoformat(timespec="seconds")}.

- Firm securities: {firms["ticker"].nunique()}
- Events: {events["event_id"].nunique()}
- Estimation window: [{module.ESTIMATION_WINDOW[0]},{module.ESTIMATION_WINDOW[1]}]
- Shifted-panel rows: {len(shifted)}
- Symmetric [-14,+14] rows: {len(symmetric)}

The shifted design retains the market-model parameters estimated at the
original event date and moves each accumulation window forward by one trading
day. The symmetric design uses the same SPY market model and estimation window.
"""
    (REPORTS / "car_sensitivity_variants_report.md").write_text(
        report,
        encoding="utf-8",
    )
    print(
        f"shifted_rows={len(shifted)} symmetric_rows={len(symmetric)} "
        f"tickers={firms['ticker'].nunique()} events={events['event_id'].nunique()}"
    )


if __name__ == "__main__":
    main()
