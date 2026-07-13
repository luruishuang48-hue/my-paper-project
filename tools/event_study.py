#!/usr/bin/env python3
"""事件研究（市场模型 + FF3 三因子，一个脚本取代旧版两个）。

适配旧工作流的逐公司 Excel 数据（列：code, date, share_earn, market_earn,
Mkt-RF, smb, hml, rf），但修正旧版全部已诊断问题：

  1. 【窗口】旧版 'car20'=(-20,20) 是对称日历日窗（实际 ≈±14 交易日且逐事件
     长短不齐）。本版全部按 **交易日位置** 索引：事件后窗 [0,+w]，
     事件前窗 [-10,-2] 单独报告，不合并、不贴错标签。
  2. 【估计窗】旧版 [-130,-11] 日历日 ≈80 个交易日，且与 car15/car20 窗
     重叠 10 天。本版默认 [-200,-11] 交易日，与任何报告窗零重叠（启动时断言），
     最少 120 个有效观测（可调）。
  3. 【假日】旧版事件日落在休市日时 day 0 悄悄消失。本版顺延到下一交易日
     并在输出中记录 rolled=True。
  4. 【单位】旧版 FF3 把百分点的 rf/smb/hml 与小数收益混用
     （Ri−rf 每天多减约 2 个百分点）。本版按量级自动检测并统一为小数，
     检测结果打印留痕；无法判断时报错拒跑。
  5. 【流程】旧版每公司手工改代码、手工贴 60 个日期。本版批量扫描数据文件夹，
     事件日期默认读流水线核证表（也可 --events 提供自定义 CSV：
     列 event_id,date），重复日期去重并警告。

用法：
  python3 tools/event_study.py --data-dir /path/to/xlsx_folder
  python3 tools/event_study.py --data-file GOOGL.xlsx --events my_events.csv
  python3 tools/event_study.py --data-file GOOGL.xlsx --est-window -200 -11
输出：event_study_results.csv（长表：公司 × 事件 × 模型 × 窗口）
"""
import argparse
import sys
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_EVENTS = ROOT / "CAR/metadata/event_dates_with_trading_day.csv"

POST_WINDOWS = {"car_0_1": (0, 1), "car_0_5": (0, 5),
                "car_0_10": (0, 10), "car_0_20": (0, 20)}
PRE_WINDOW = ("car_pre_m10_m2", (-10, -2))
MIN_EST_OBS = 120

REQUIRED_COLS = {"date", "share_earn", "market_earn"}
FF3_COLS = {"smb", "hml", "rf"}


def load_company_file(path: Path) -> pd.DataFrame:
    df = pd.read_excel(path) if path.suffix.lower() in (".xlsx", ".xls") else pd.read_csv(path)
    df.columns = [str(c).strip() for c in df.columns]
    missing = REQUIRED_COLS - set(df.columns)
    if missing:
        raise SystemExit(f"{path.name}: 缺少必需列 {sorted(missing)}（现有列: {list(df.columns)}）")
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.dropna(subset=["date", "share_earn", "market_earn"])
    df = df.sort_values("date").drop_duplicates("date").reset_index(drop=True)
    if df["date"].dt.dayofweek.isin([5, 6]).any():
        print(f"  警告: {path.name} 含周末行（数据应为交易日序列），已保留但请核查", file=sys.stderr)
    return df


def harmonize_units(df: pd.DataFrame, fname: str) -> tuple[pd.DataFrame, bool]:
    """把 smb/hml/rf/Mkt-RF 统一成小数。判据：日频收益中位绝对值，
    小数口径 ~0.005-0.02，百分点口径 ~0.5-2。比值 >20 判为百分点。"""
    has_ff3 = FF3_COLS <= set(df.columns)
    if not has_ff3:
        return df, False
    base = df["share_earn"].abs().median()
    for col in ["smb", "hml", "Mkt-RF"]:
        if col not in df.columns:
            continue
        med = df[col].abs().replace(0, np.nan).median()
        if pd.isna(med) or med == 0:
            continue
        ratio = med / base if base > 0 else np.inf
        if ratio > 20:
            df[col] = df[col] / 100.0
            print(f"  [{fname}] 列 {col} 判为百分点口径（中位量级比 {ratio:.0f}x），已 ÷100")
        elif ratio > 5:
            raise SystemExit(
                f"{fname}: 列 {col} 量级可疑（比收益大 {ratio:.1f}x），无法自动判定单位，"
                "请人工确认并预先转换后再跑。")
    # rf 专门规则：日频无风险利率按小数口径不可能超过 0.0008（≈20%/年）。
    # 百分点口径的日 rf（如 0.02 = 2bp）恰与小数收益同量级，通用比值判据抓不住。
    med_rf = df["rf"].abs().replace(0, np.nan).median()
    if pd.notna(med_rf) and med_rf > 0.0008:
        df["rf"] = df["rf"] / 100.0
        print(f"  [{fname}] 列 rf 非零中位 {med_rf:.4f} 超出小数口径上限，判为百分点，已 ÷100")
    return df, has_ff3


def event_positions(dates: pd.Series, event_date: pd.Timestamp):
    """返回 (day0 位置, 是否顺延)。事件日非交易日 → 顺延到下一交易日。"""
    arr = dates.values
    idx = int(np.searchsorted(arr, np.datetime64(event_date)))
    if idx >= len(arr):
        return None, False
    rolled = arr[idx] != np.datetime64(event_date)
    return idx, rolled


def fit_and_car(y, x_list, est_slice, win_slice):
    """在估计窗拟合 y = a + b·X，返回窗口 AR 之和；观测不足返回 None。"""
    Xe = np.column_stack([np.ones(est_slice.stop - est_slice.start)] +
                         [x[est_slice] for x in x_list])
    ye = y[est_slice]
    ok = np.isfinite(ye) & np.all(np.isfinite(Xe), axis=1)
    if ok.sum() < MIN_EST_OBS:
        return None, int(ok.sum()), None
    coef, *_ = np.linalg.lstsq(Xe[ok], ye[ok], rcond=None)
    Xw = np.column_stack([np.ones(win_slice.stop - win_slice.start)] +
                         [x[win_slice] for x in x_list])
    yw = y[win_slice]
    okw = np.isfinite(yw) & np.all(np.isfinite(Xw), axis=1)
    if okw.sum() < (win_slice.stop - win_slice.start):    # 窗口必须完整
        return None, int(ok.sum()), coef
    return float((yw[okw] - Xw[okw] @ coef).sum()), int(ok.sum()), coef


def load_events(path: Path):
    ev = pd.read_csv(path)
    if "event_trading_date" in ev.columns:         # 流水线核证表
        ev = ev.rename(columns={"event_trading_date": "date"})
    if not {"event_id", "date"} <= set(ev.columns):
        raise SystemExit(f"事件表需含 event_id,date 两列（现有: {list(ev.columns)}）")
    ev["date"] = pd.to_datetime(ev["date"].astype(str).str[:10], errors="coerce")
    ev = ev.dropna(subset=["date"])
    dup = ev["date"].duplicated(keep=False)
    if dup.any():
        print(f"  提示: 事件表存在 {ev.loc[dup, 'date'].nunique()} 个共享日期"
              "（同日多事件，正常保留）")
    return ev[["event_id", "date"]].drop_duplicates()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data-dir", help="逐公司 xlsx/csv 文件夹")
    ap.add_argument("--data-file", help="单个公司文件")
    ap.add_argument("--events", default=str(DEFAULT_EVENTS))
    ap.add_argument("--est-window", nargs=2, type=int, default=[-200, -11],
                    metavar=("START", "END"))
    ap.add_argument("--out", default="event_study_results.csv")
    args = ap.parse_args()

    est_s, est_e = args.est_window
    all_wins = list(POST_WINDOWS.values()) + [PRE_WINDOW[1]]
    earliest_win = min(w[0] for w in all_wins)
    assert est_e < earliest_win, \
        f"估计窗右端 ({est_e}) 必须早于最早报告窗左端 ({earliest_win})——不允许重叠"

    files = ([Path(args.data_file)] if args.data_file
             else sorted(Path(args.data_dir).glob("*.xls*")) + sorted(Path(args.data_dir).glob("*.csv")))
    if not files:
        raise SystemExit("未找到数据文件")
    events = load_events(Path(args.events))
    print(f"公司文件 {len(files)} 个 × 事件 {len(events)} 个 | 估计窗 [{est_s},{est_e}] 交易日")

    rows = []
    for fp in files:
        comp = fp.stem
        try:
            df = load_company_file(fp)
        except SystemExit as e:
            print(f"  跳过 {fp.name}: {e}", file=sys.stderr)
            continue
        df, has_ff3 = harmonize_units(df, fp.name)
        r = df["share_earn"].to_numpy(float)
        mkt = df["market_earn"].to_numpy(float)
        if has_ff3:
            rf = df["rf"].to_numpy(float)
            ex_r, ex_m = r - rf, mkt - rf
            smb, hml = df["smb"].to_numpy(float), df["hml"].to_numpy(float)
        n = len(df)

        for ev in events.itertuples():
            pos, rolled = event_positions(df["date"], ev.date)
            base = {"company": comp, "event_id": ev.event_id,
                    "event_date": ev.date.date().isoformat(), "day0_rolled": rolled}
            if pos is None or pos + est_s < 0 or pos + 20 >= n:
                rows.append({**base, "status": "insufficient_data"})
                continue
            est = slice(pos + est_s, pos + est_e + 1)
            rec = {**base, "status": "ok"}
            for name, (a, b) in list(POST_WINDOWS.items()) + [PRE_WINDOW]:
                win = slice(pos + a, pos + b + 1)
                car_mm, obs, coef = fit_and_car(r, [mkt], est, win)
                rec[f"mm_{name}"] = car_mm
                if has_ff3:
                    car_f3, _, _ = fit_and_car(ex_r, [ex_m, smb, hml], est, win)
                    rec[f"ff3_{name}"] = car_f3
            rec["est_obs"] = obs
            rec["mm_beta"] = round(float(coef[1]), 4) if coef is not None else None
            rows.append(rec)

    out = pd.DataFrame(rows)
    out.to_csv(args.out, index=False)
    n_ok = (out["status"] == "ok").sum()
    print(f"\n完成: {len(out)} 行（可用 {n_ok}）→ {args.out}")
    if n_ok:
        print("mm_car_0_20 概览:", out.loc[out.status == 'ok', 'mm_car_0_20']
              .describe().round(4).to_dict())


if __name__ == "__main__":
    main()
