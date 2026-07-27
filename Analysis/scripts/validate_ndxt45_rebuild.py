#!/usr/bin/env python3
"""Validate the public NDXT45 data and analysis workflow."""

from __future__ import annotations

import json
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]
RUN_DIR = ROOT / "Analysis" / "reproduction"
OFFICIAL = (
    "ADBE AMD GOOGL GOOG ADI AAPL AMAT APP ARM ASML ADSK AVGO CDNS CTSH "
    "CRWD DDOG DASH FTNT INTC INTU KLAC LRCX MRVL META MCHP MU MSFT MPWR "
    "NVDA NXPI PLTR PANW PDD QCOM ROP SNDK STX SHOP MSTR SNPS TXN TRI WDC "
    "WDAY ZS"
).split()
OFFICIAL_SET = set(OFFICIAL)
BENCHMARKS = {"SPY", "QQQ", "SOXX", "^NDX", "^IXIC", "^GSPC", "^SOX"}
CANONICAL_CSV_DIRS = (
    "CAR/metadata",
    "CAR/processed",
    "CAR/reports",
    "Fundamentals/metadata",
    "Fundamentals/processed",
    "Fundamentals/reports",
    "Analysis/processed",
    "Analysis/reports",
)


def read(path: str) -> pd.DataFrame:
    return pd.read_csv(ROOT / path, low_memory=False)


def log_errors(folder: Path) -> dict[str, list[str]]:
    markers = ("Execution halted", "Error in ", "Traceback", "cannot open file")
    errors: dict[str, list[str]] = {}
    for path in sorted(folder.glob("*.log")):
        content = path.read_text(encoding="utf-8", errors="replace")
        hits = [marker for marker in markers if marker in content]
        if hits:
            errors[path.name] = hits
    return errors


def main() -> None:
    checks: dict[str, object] = {}

    firms = read("事件集筛选/decisions/firm_universe_decisions.csv")
    checks["firm_universe_rows"] = len(firms)
    checks["firm_universe_order_exact"] = firms["ticker"].tolist() == OFFICIAL
    checks["firm_universe_unique"] = firms["ticker"].nunique() == 45

    relationships = read("事件集筛选/decisions/relationship_decisions.csv")
    relationship_counts = relationships.groupby("ticker")["creator"].nunique()
    checks["relationship_rows"] = len(relationships)
    checks["relationship_tickers_exact"] = set(relationship_counts.index) == OFFICIAL_SET
    checks["relationship_creators_each"] = sorted(relationship_counts.unique().tolist())
    checks["relationship_key_unique"] = not relationships.duplicated(
        ["ticker", "creator"]
    ).any()

    labels = read("事件集筛选/decisions/event_label_decisions.csv")
    checks["event_label_rows"] = len(labels)
    checks["event_label_unique"] = labels["event_id"].nunique() == 125

    car_firms = read("CAR/metadata/firm_universe_for_car.csv")
    checks["car_firms_exact"] = set(car_firms["ticker"]) == OFFICIAL_SET
    checks["car_ndxt_flag_all_true"] = bool(car_firms["is_main_ndxt"].all())

    prices = read("CAR/processed/prices_daily_long.csv")
    price_stocks = prices.loc[
        prices["is_benchmark"].astype(str).str.lower() != "true", "symbol"
    ]
    checks["price_stock_tickers_exact"] = set(price_stocks) == OFFICIAL_SET
    checks["ctsh_price_rows"] = int((prices["symbol"] == "CTSH").sum())
    checks["zs_price_rows"] = int((prices["symbol"] == "ZS").sum())

    fundamentals = read("Fundamentals/processed/fundamentals_quarterly_wide.csv")
    checks["fundamental_tickers_exact"] = set(fundamentals["ticker"]) == OFFICIAL_SET
    checks["ctsh_fundamental_rows"] = int((fundamentals["ticker"] == "CTSH").sum())
    checks["zs_fundamental_rows"] = int((fundamentals["ticker"] == "ZS").sum())

    panel = read("Analysis/processed/event_firm_panel.csv")
    checks["panel_rows"] = len(panel)
    checks["panel_events"] = panel["event_id"].nunique()
    checks["panel_tickers"] = panel["ticker"].nunique()
    checks["panel_tickers_exact"] = set(panel["ticker"]) == OFFICIAL_SET
    checks["panel_balanced"] = len(panel) == 125 * 45
    checks["panel_key_unique"] = not panel[["event_id", "ticker"]].duplicated().any()
    checks["panel_ndxt_flag_all_true"] = bool(panel["is_main_ndxt"].all())
    checks["r5_only_ctsh"] = set(
        panel.loc[panel["rel_downstream_enabler"] == 1, "ticker"]
    ) == {"CTSH"}
    checks["ctsh_r5_all_events"] = bool(
        (panel.loc[panel["ticker"] == "CTSH", "rel_downstream_enabler"] == 1).all()
    )
    checks["zs_r3_all_events"] = bool(
        (panel.loc[panel["ticker"] == "ZS", "rel_downstream_integrator"] == 1).all()
    )

    for name in (
        "event_firm_abnormal_volume.csv",
        "event_firm_car_shifted.csv",
        "event_firm_car_sym14.csv",
    ):
        frame = read(f"Analysis/processed/{name}")
        checks[f"{name}_tickers_exact"] = set(frame["ticker"]) == OFFICIAL_SET
        checks[f"{name}_outside_ndxt"] = sorted(set(frame["ticker"]) - OFFICIAL_SET)

    two_way = read("Analysis/reports/frl_event_firm_two_way_cluster_results.csv")
    position = two_way.loc[two_way["spec"].str.startswith("position_")]
    checks["position_report_firm_counts"] = sorted(
        position["firms"].dropna().astype(int).unique().tolist()
    )
    checks["position_report_includes_r5"] = (
        position.groupby("spec")["term"]
        .apply(lambda values: "rel_downstream_enabler" in set(values))
        .all()
    )

    pairwise = read("Analysis/reports/frl_position_pairwise_contrasts.csv")
    checks["pairwise_firm_counts"] = sorted(
        pairwise["firms"].dropna().astype(int).unique().tolist()
    )
    checks["pairwise_includes_hardware_enabler"] = (
        "hardware_minus_enabler" in set(pairwise["contrast"])
    )

    time_results = read("Analysis/reports/frl_time_heterogeneity_results.csv")
    time_joint = read("Analysis/reports/frl_time_heterogeneity_joint_tests.csv")
    time_contrasts = read("Analysis/reports/frl_time_heterogeneity_contrasts.csv")
    checks["time_heterogeneity_rows"] = len(time_results)
    checks["time_heterogeneity_firm_counts"] = sorted(
        time_results["firms"].dropna().astype(int).unique().tolist()
    )
    checks["time_heterogeneity_methods"] = sorted(
        time_results["method"].dropna().unique().tolist()
    )
    checks["time_heterogeneity_has_competitor_change"] = bool(
        (
            (time_results["term"] == "rel_competitor")
            & (time_results["estimand"] == "change_after_2025")
        ).any()
    )
    checks["time_joint_rows"] = len(time_joint)
    checks["time_joint_methods"] = sorted(
        time_joint["method"].dropna().unique().tolist()
    )
    checks["time_contrast_rows"] = len(time_contrasts)
    checks["time_contrast_methods"] = sorted(
        time_contrasts["method"].dropna().unique().tolist()
    )
    checks["time_contrast_test_exact"] = set(
        time_contrasts["contrast"].dropna().unique().tolist()
    ) == {"hardware_change_minus_competitor_change_after_2025"}
    checks["time_contrast_firm_counts"] = sorted(
        time_contrasts["firms"].dropna().astype(int).unique().tolist()
    )

    competitor = read("Analysis/reports/frl_competitor_robustness_results.csv")
    required_competitor_specs = {
        "baseline_spy",
        "event_and_firm_fixed_effects",
        "issuer_cluster_alphabet_combined",
        "alphabet_share_class",
        "exclude_competitor_overlap",
        "pure_competitor_pressure_test",
        "leave_one_competitor_ticker_out",
        "leave_one_competitor_issuer_out",
        "leave_one_creator_out",
    }
    checks["competitor_robustness_specs_complete"] = (
        required_competitor_specs <= set(competitor["spec"])
    )
    checks["competitor_robustness_baseline_firms"] = sorted(
        competitor.loc[
            competitor["spec"] == "baseline_spy", "firms"
        ].dropna().astype(int).unique().tolist()
    )
    checks["competitor_leave_one_ticker_count"] = competitor.loc[
        competitor["spec"] == "leave_one_competitor_ticker_out", "detail"
    ].nunique()
    checks["competitor_leave_one_creator_count"] = competitor.loc[
        competitor["spec"] == "leave_one_creator_out", "detail"
    ].nunique()
    checks["competitor_leave_one_creator_rows"] = len(
        competitor.loc[competitor["spec"] == "leave_one_creator_out"]
    )

    multiple_testing = read(
        "Analysis/reports/frl_position_multiple_testing_adjustment.csv"
    )
    competitor_multiple = multiple_testing.loc[
        multiple_testing["term"] == "rel_competitor"
    ]
    checks["competitor_multiple_testing_row"] = len(competitor_multiple) == 1
    checks["competitor_holm_p_below_01"] = bool(
        competitor_multiple["holm_p"].iloc[0] < 0.01
    )

    out_of_scope_by_file: dict[str, dict[str, list[str]]] = {}
    security_columns = {"ticker", "symbol", "dropped_ticker", "download_symbol"}
    for folder in CANONICAL_CSV_DIRS:
        for path in sorted((ROOT / folder).glob("*.csv")):
            try:
                frame = pd.read_csv(path, low_memory=False)
            except Exception:
                continue
            for column in security_columns.intersection(frame.columns):
                values = set(frame[column].dropna().astype(str))
                outside = sorted(values - (OFFICIAL_SET | BENCHMARKS))
                if outside:
                    relative = str(path.relative_to(ROOT))
                    out_of_scope_by_file.setdefault(relative, {})[column] = outside
    checks["canonical_csv_out_of_scope_values"] = out_of_scope_by_file
    checks["analysis_log_errors"] = log_errors(RUN_DIR / "logs")

    required_truths = [
        checks["firm_universe_rows"] == 45,
        checks["firm_universe_order_exact"],
        checks["firm_universe_unique"],
        checks["relationship_rows"] == 1125,
        checks["relationship_tickers_exact"],
        checks["relationship_creators_each"] == [25],
        checks["relationship_key_unique"],
        checks["event_label_rows"] == 125,
        checks["event_label_unique"],
        checks["car_firms_exact"],
        checks["car_ndxt_flag_all_true"],
        checks["price_stock_tickers_exact"],
        checks["ctsh_price_rows"] == 1337,
        checks["zs_price_rows"] == 1337,
        checks["fundamental_tickers_exact"],
        checks["ctsh_fundamental_rows"] == 17,
        checks["zs_fundamental_rows"] == 17,
        checks["panel_rows"] == 5625,
        checks["panel_events"] == 125,
        checks["panel_tickers"] == 45,
        checks["panel_tickers_exact"],
        checks["panel_balanced"],
        checks["panel_key_unique"],
        checks["panel_ndxt_flag_all_true"],
        checks["r5_only_ctsh"],
        checks["ctsh_r5_all_events"],
        checks["zs_r3_all_events"],
        checks["position_report_firm_counts"] == [45],
        checks["position_report_includes_r5"],
        checks["pairwise_firm_counts"] == [45],
        checks["pairwise_includes_hardware_enabler"],
        checks["time_heterogeneity_rows"] == 96,
        checks["time_heterogeneity_firm_counts"] == [45],
        checks["time_heterogeneity_methods"] == ["event_CR2", "event_x_firm_HC1"],
        checks["time_heterogeneity_has_competitor_change"],
        checks["time_joint_rows"] == 4,
        checks["time_joint_methods"] == ["event_CR2", "event_x_firm_HC1"],
        checks["time_contrast_rows"] == 4,
        checks["time_contrast_methods"] == ["event_CR2", "event_x_firm_HC1"],
        checks["time_contrast_test_exact"],
        checks["time_contrast_firm_counts"] == [45],
        checks["competitor_robustness_specs_complete"],
        checks["competitor_robustness_baseline_firms"] == [45],
        checks["competitor_leave_one_ticker_count"] == 6,
        checks["competitor_leave_one_creator_count"] == 25,
        checks["competitor_leave_one_creator_rows"] == 50,
        checks["competitor_multiple_testing_row"],
        checks["competitor_holm_p_below_01"],
        not checks["canonical_csv_out_of_scope_values"],
        not checks["analysis_log_errors"],
    ]
    required_truths.extend(
        value for key, value in checks.items() if key.endswith("_tickers_exact")
    )
    required_truths.extend(
        not value for key, value in checks.items() if key.endswith("_outside_ndxt")
    )
    checks["passed"] = bool(all(required_truths))

    RUN_DIR.mkdir(parents=True, exist_ok=True)
    (RUN_DIR / "validation.json").write_text(
        json.dumps(checks, ensure_ascii=False, indent=2, default=bool) + "\n",
        encoding="utf-8",
    )
    lines = [
        "# NDXT45 workflow validation",
        "",
        f"- Passed: {checks['passed']}",
        f"- Firm universe: {checks['firm_universe_rows']} securities",
        f"- Event labels: {checks['event_label_rows']} events",
        f"- Relationship matrix: {checks['relationship_rows']} rows",
        f"- Event-firm panel: {checks['panel_rows']} rows",
        f"- Main regression firm counts: {checks['position_report_firm_counts']}",
        f"- Analysis log errors: {checks['analysis_log_errors']}",
        "",
    ]
    (RUN_DIR / "validation.md").write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps(checks, ensure_ascii=False, indent=2, default=bool))
    if not checks["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
