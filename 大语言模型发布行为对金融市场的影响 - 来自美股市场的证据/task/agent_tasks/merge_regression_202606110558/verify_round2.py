#!/usr/bin/env python3
"""
Verification Round 2: Completely independent checking logic.
Uses different approach: column-wise comparison, statistical profiling, random spot checks.
"""
import csv, os, random
from collections import defaultdict

TASK_DIR = '/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/task'

def main():
    print("=" * 60)
    print("COMPREHENSIVE VERIFICATION — ROUND 2")
    print("=" * 60)

    # Load all data fresh
    with open(os.path.join(TASK_DIR, '事件集数据-new 2.csv'), 'r', encoding='gb18030') as f:
        ev_raw = list(csv.DictReader(f))
    ev_data = [r for r in ev_raw if r.get('事件 ID', '') != 'final_event_id']

    with open(os.path.join(TASK_DIR, '事件集数据-relationships.csv'), 'r', encoding='utf-8-sig') as f:
        merged = list(csv.DictReader(f))

    ev_headers = sorted([k for k in ev_data[0].keys()])
    all_passed = True

    # === R2-C1: Column-wise value comparison (different from row-wise) ===
    print("R2-C1: Column-wise comparison...", end=' ', flush=True)
    col_diffs = 0
    for col in ev_headers:
        orig_vals = [r[col] for r in ev_data]
        merged_vals = [r[col] for r in merged]
        if orig_vals != merged_vals:
            col_diffs += 1
            print(f"\n  Column '{col}' differs!")
    c1 = col_diffs == 0
    print(f"{'PASS' if c1 else 'FAIL'}")
    all_passed &= c1

    # === R2-C2: Random spot check of 200 rows ===
    print("R2-C2: Random spot check (200 rows)...", end=' ', flush=True)
    random.seed(42)
    indices = random.sample(range(len(ev_data)), min(200, len(ev_data)))
    spot_diffs = 0
    for i in indices:
        orig = ev_data[i]
        m = merged[i]
        for k in ev_headers:
            if orig.get(k, '') != m.get(k, ''):
                spot_diffs += 1
    c2 = spot_diffs == 0
    print(f"{'PASS' if c2 else 'FAIL'} ({spot_diffs} differences in {len(indices)} spot checks)")
    all_passed &= c2

    # === R2-C3: First/Last row boundary check ===
    print("R2-C3: First and last row boundary check...", end=' ', flush=True)
    boundary_ok = True
    for i in [0, 1, 2, -1, -2, -3]:
        orig = ev_data[i]
        m = merged[i]
        for k in ev_headers:
            if orig.get(k, '') != m.get(k, ''):
                boundary_ok = False
                break
    c3 = boundary_ok
    print(f"{'PASS' if c3 else 'FAIL'}")
    all_passed &= c3

    # === R2-C4: Statistical profile of financial variables ===
    print("R2-C4: Financial variable statistical profile...", end=' ')
    fin_cols = ['市场模型异常收益[-10,-2]', 'FF3异常收益时间窗口1', '市场模型异常收益5', 'FF3异常收益5',
                '市场模型异常收益20', 'FF3异常收益20', '规模（亿美元）（ln）', '账面市值比',
                '前期波动率', '累计涨幅']
    profile_ok = True
    for col in fin_cols:
        if col in ev_headers:
            orig_sum = sum(float(r[col]) for r in ev_data if r[col].strip() and r[col].replace('.','').replace('-','').replace('e','').replace('E','').isdigit())
            merged_sum = sum(float(r[col]) for r in merged if r[col].strip() and r[col].replace('.','').replace('-','').replace('e','').replace('E','').isdigit())
            if abs(orig_sum - merged_sum) > 0.01:
                profile_ok = False
                print(f"\n  {col}: orig_sum={orig_sum:.4f} merged_sum={merged_sum:.4f}")
    c4 = profile_ok
    print(f"{'PASS' if c4 else 'FAIL'}")
    all_passed &= c4

    # === R2-C5: Chinese text columns preserved ===
    print("R2-C5: Chinese text columns preserved...", end=' ', flush=True)
    cn_cols = ['公司', '行业板块', '行业分组', '模型发布者', '事件名称']
    cn_ok = True
    for col in cn_cols:
        if col in ev_headers:
            for i in range(min(100, len(ev_data))):
                if ev_data[i].get(col, '') != merged[i].get(col, ''):
                    cn_ok = False
                    break
    c5 = cn_ok
    print(f"{'PASS' if c5 else 'FAIL'}")
    all_passed &= c5

    # === R2-C6: Relationship variables are separable (can remove to get original) ===
    print("R2-C6: Can reconstruct original by removing new columns...", end=' ', flush=True)
    rel_vars = ['owner','investor','cloud','business_upstream','real_upstream',
                'business_downstream','real_downstream','competitor','relationship_notes']
    reconstructed = []
    for m in merged:
        r = {k: v for k, v in m.items() if k not in rel_vars}
        reconstructed.append(r)
    recon_ok = True
    for i, (orig, recon) in enumerate(zip(ev_data, reconstructed)):
        for k in ev_headers:
            if orig.get(k, '') != recon.get(k, ''):
                recon_ok = False
                break
        if not recon_ok:
            break
    c6 = recon_ok
    print(f"{'PASS' if c6 else 'FAIL'}")
    all_passed &= c6

    # === R2-C7: Market model CAR columns not corrupted ===
    print("R2-C7: CAR values within reasonable range...", end=' ', flush=True)
    car_cols = [c for c in ev_headers if '异常收益' in c or 'car' in c.lower()]
    car_ok = True
    for col in car_cols:
        for r in merged[:500]:
            val = r.get(col, '')
            if val and val.strip():
                try:
                    fv = float(val)
                    if abs(fv) > 2.0:
                        car_ok = False
                        break
                except ValueError:
                    pass
    c7 = car_ok
    print(f"{'PASS' if c7 else 'FAIL'}")
    all_passed &= c7

    # === R2-C8: No unintended encoding issues ===
    print("R2-C8: No mojibake or encoding corruption...", end=' ', flush=True)
    encoding_ok = True
    for r in merged[:100]:
        for k, v in r.items():
            if '�' in v:  # Unicode replacement character
                encoding_ok = False
                break
    c8 = encoding_ok
    print(f"{'PASS' if c8 else 'FAIL'}")
    all_passed &= c8

    # === R2-C9: Panel structure intact (each event has same firms) ===
    print("R2-C9: Panel structure verification...", end=' ', flush=True)
    from collections import defaultdict
    event_firms = defaultdict(set)
    for r in merged:
        eid = r['事件 ID'].strip()
        fid = r['公司编码'].strip()
        if eid and fid:
            event_firms[eid].add(fid)
    # Count firms per event
    firm_counts = [len(fs) for fs in event_firms.values()]
    # Most events should have 86 firms
    c9 = all(c <= 86 for c in firm_counts) and any(c >= 80 for c in firm_counts)
    print(f"{'PASS' if c9 else 'FAIL'} (events: {len(event_firms)}, firms/event: min={min(firm_counts)}, max={max(firm_counts)}, median={sorted(firm_counts)[len(firm_counts)//2]})")
    all_passed &= c9

    # === R2-C10: Relationship variable cross-tabulations make sense ===
    print("R2-C10: Relationship cross-tab sanity...", end=' ', flush=True)
    # owner=1 should not have competitor=1 (self-competition rule)
    self_comp = sum(1 for r in merged if r.get('owner') == '1' and r.get('competitor') == '1')
    # TSMC should have business_upstream=1 for all
    tsmc_bu = sum(1 for r in merged if r.get('公司') == '台积电' and r.get('business_upstream') != '1')
    c10 = self_comp == 0 and tsmc_bu == 0
    print(f"{'PASS' if c10 else 'FAIL'} (self_comp={self_comp}, tsmc_bu_mismatches={tsmc_bu})")
    all_passed &= c10

    print(f"\n{'='*60}")
    print(f"ROUND 2: {'ALL PASSED' if all_passed else 'SOME FAILED'}")
    print(f"{'='*60}")

    if not all_passed:
        import sys; sys.exit(1)

if __name__ == '__main__':
    main()
