#!/usr/bin/env python3
"""标准化异常对数成交量（事件 × 公司）。

估计窗 [-200,-11]（交易日，与 CAR 估计窗一致，右端点避开前窗 [-10,-2]，
2026-07-06 由 -10 修正为 -11）。异常量 = (lnV - 估计窗均值)/估计窗标准差，
窗口内取平均。输出 Analysis/processed/event_firm_abnormal_volume.csv。
"""
import csv, math
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EST = (-200, -11)
MIN_OBS = 120
WINS = {'av_pre_m10_m2': (-10, -2), 'av_0_1': (0, 1), 'av_0_5': (0, 5),
        'av_0_10': (0, 10), 'av_0_20': (0, 20)}

vol = defaultdict(dict)
for r in csv.DictReader(open(ROOT / 'CAR/processed/prices_daily_long.csv')):
    if r['is_benchmark'] == 'True':
        continue
    try:
        v = float(r['volume'])
        if v > 0:
            vol[r['symbol']][r['date']] = math.log(v)
    except (ValueError, TypeError):
        pass

cal = sorted({r['date'] for r in csv.DictReader(open(ROOT / 'CAR/processed/prices_daily_long.csv'))
              if r['symbol'] == 'SPY'})
didx = {d: i for i, d in enumerate(cal)}
arr = {s: [dd.get(d) for d in cal] for s, dd in vol.items()}

events = list(csv.DictReader(open(ROOT / 'CAR/metadata/event_dates_with_trading_day.csv')))
firms = [r['ticker'] for r in csv.DictReader(open(ROOT / '事件集筛选/decisions/firm_universe_decisions.csv'))]

out = []
for ev in events:
    ed = ev['event_trading_date'][:10]
    if ed not in didx:
        continue
    pos = didx[ed]
    for t in firms:
        a = arr.get(t)
        if a is None:
            continue
        lo, hi = pos + EST[0], pos + EST[1]
        if lo < 0:
            continue
        est = [x for x in a[lo:hi + 1] if x is not None]
        if len(est) < MIN_OBS:
            continue
        mu = sum(est) / len(est)
        sd = math.sqrt(sum((x - mu) ** 2 for x in est) / (len(est) - 1))
        if sd <= 0:
            continue
        row = {'event_id': ev['event_id'], 'ticker': t}
        ok = False
        for name, (s, e) in WINS.items():
            seg = [x for x in a[pos + s:pos + e + 1] if x is not None]
            if len(seg) == e - s + 1:
                row[name] = sum((x - mu) / sd for x in seg) / len(seg)
                ok = True
            else:
                row[name] = ''
        if ok:
            out.append(row)

with open(ROOT / 'Analysis/processed/event_firm_abnormal_volume.csv', 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=['event_id', 'ticker'] + list(WINS))
    w.writeheader()
    w.writerows(out)
print(f"abnormal volume rows: {len(out)}")
