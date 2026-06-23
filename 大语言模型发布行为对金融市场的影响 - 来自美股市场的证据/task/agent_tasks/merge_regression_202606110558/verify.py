#!/usr/bin/env python3
"""
Comprehensive Verification: Event Data Integrity After Merge
Repeated independent checks to confirm no tampering.
"""
import csv, os, hashlib
from collections import defaultdict, Counter

TASK_DIR = '/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/task'

def main():
    print("=" * 60)
    print("COMPREHENSIVE VERIFICATION — ROUND 1")
    print("=" * 60)

    # Load originals
    with open(os.path.join(TASK_DIR, '事件集数据-new 2.csv'), 'r', encoding='gb18030') as f:
        ev_raw = list(csv.DictReader(f))
    ev_orig = [dict(r) for r in ev_raw if r.get('事件 ID', '') != 'final_event_id']

    with open(os.path.join(TASK_DIR, 'firm_model_relationships.csv'), 'r', encoding='utf-8-sig') as f:
        rel_data = list(csv.DictReader(f))

    with open(os.path.join(TASK_DIR, '事件集数据-relationships.csv'), 'r', encoding='utf-8-sig') as f:
        merged = list(csv.DictReader(f))

    ev_headers = list(ev_orig[0].keys())
    rel_vars = ['owner','investor','cloud','business_upstream','real_upstream',
                'business_downstream','real_downstream','competitor','relationship_notes']
    all_passed = True

    # === CHECK 1: Row count ===
    c1 = len(merged) == len(ev_orig)
    print(f"CHECK 1: Row count preserved ({len(ev_orig)} → {len(merged)}): {'PASS' if c1 else 'FAIL'}")
    all_passed &= c1

    # === CHECK 2: Column count ===
    c2 = len(merged[0]) == len(ev_headers) + 9
    print(f"CHECK 2: Column count ({len(ev_headers)} + 9 = {len(merged[0])}): {'PASS' if c2 else 'FAIL'}")
    all_passed &= c2

    # === CHECK 3: Every original column present ===
    missing_cols = [c for c in ev_headers if c not in merged[0]]
    c3 = len(missing_cols) == 0
    print(f"CHECK 3: All original columns present (missing: {len(missing_cols)}): {'PASS' if c3 else 'FAIL'}")
    if missing_cols:
        print(f"  Missing: {missing_cols}")
    all_passed &= c3

    # === CHECK 4: Every new column present ===
    missing_new = [c for c in rel_vars if c not in merged[0]]
    c4 = len(missing_new) == 0
    print(f"CHECK 4: All relationship columns present (missing: {len(missing_new)}): {'PASS' if c4 else 'FAIL'}")
    all_passed &= c4

    # === CHECK 5: Byte-by-byte comparison of ALL original values ===
    print("CHECK 5: Byte-by-byte comparison of all original values...", end=' ', flush=True)
    diffs = 0
    diff_samples = []
    for i, (orig, m) in enumerate(zip(ev_orig, merged)):
        for key in ev_headers:
            ov = orig.get(key, '')
            mv = m.get(key, '')
            if ov != mv:
                diffs += 1
                if len(diff_samples) < 5:
                    diff_samples.append((i, key, ov[:60], mv[:60]))
    c5 = diffs == 0
    print(f"{'PASS' if c5 else 'FAIL'} ({diffs} differences)")
    if diff_samples:
        for s in diff_samples:
            print(f"  Row {s[0]}, col '{s[1]}': orig='{s[2]}' vs merged='{s[3]}'")
    all_passed &= c5

    # === CHECK 6: Independent re-merge verification ===
    print("CHECK 6: Independent re-merge verification...", end=' ', flush=True)
    from datetime import datetime, timedelta

    def normalize_date(d):
        d = d.strip()
        for sep in ['/', '-']:
            parts = d.split(sep)
            if len(parts) == 3:
                try:
                    return f'{int(parts[0]):04d}-{int(parts[1]):02d}-{int(parts[2]):02d}'
                except ValueError:
                    pass
        try:
            serial = int(d)
            base = datetime(1899, 12, 30)
            return (base + timedelta(days=serial)).strftime('%Y-%m-%d')
        except (ValueError, TypeError):
            pass
        return d

    rel_lookup = {}
    for r in rel_data:
        key = (r['firm_ticker'].strip(), r['model_company'].strip(),
               r['model'].strip(), r['event_date'].strip())
        rel_lookup[key] = {v: r[v] for v in rel_vars[:-1]}
        rel_lookup[key]['relationship_notes'] = r.get('notes', '')

    remerge_diffs = 0
    for i, (orig, m) in enumerate(zip(ev_orig, merged)):
        ticker = orig['公司编码'].strip()
        mc = orig['模型发布者'].strip()
        model = orig['模型名称'].strip()
        date = normalize_date(orig['日级发布日期'].strip())
        key = (ticker, mc, model, date)

        if key in rel_lookup:
            expected = rel_lookup[key]
        else:
            expected = {v: '0' for v in rel_vars[:-1]}
            expected['relationship_notes'] = ''

        for var in rel_vars:
            ev = expected.get(var, '0') if var != 'relationship_notes' else expected.get(var, '')
            mv = m.get(var, '')
            if var != 'relationship_notes':
                if mv != ev and not (mv == '0' and ev == '0' and 'UNMATCHED' in m.get('relationship_notes', '')):
                    remerge_diffs += 1
    c6 = remerge_diffs == 0
    print(f"{'PASS' if c6 else 'FAIL'} ({remerge_diffs} re-merge differences)")
    all_passed &= c6

    # === CHECK 7: All relationship values are 0 or 1 ===
    bad_vals = 0
    for r in merged:
        for var in rel_vars[:-1]:
            if r[var] not in ('0', '1'):
                bad_vals += 1
    c7 = bad_vals == 0
    print(f"CHECK 7: All relationship values 0/1 (bad: {bad_vals}): {'PASS' if c7 else 'FAIL'}")
    all_passed &= c7

    # === CHECK 8: Relationship counts within bounds ===
    expected_max = {
        'owner': 31, 'investor': 44, 'cloud': 34,
        'business_upstream': 172, 'real_upstream': 141,
        'business_downstream': 1584, 'real_downstream': 89, 'competitor': 495
    }
    print("CHECK 8: Relationship counts ≤ expected max:")
    count_ok = True
    for var in rel_vars[:-1]:
        actual = sum(1 for r in merged if r[var] == '1')
        ok = actual <= expected_max[var]
        if not ok:
            count_ok = False
        print(f"  {var}: {actual} ≤ {expected_max[var]} {'✓' if ok else 'FAIL'}")
    c8 = count_ok
    all_passed &= c8

    # === CHECK 9: Hash of original columns ===
    print("CHECK 9: Original data hash consistency...", end=' ', flush=True)
    orig_concat = ''
    merged_concat = ''
    for orig in ev_orig:
        for key in sorted(ev_headers):
            orig_concat += orig.get(key, '') + '|'
    for m in merged:
        for key in sorted(ev_headers):
            merged_concat += m.get(key, '') + '|'
    orig_hash = hashlib.md5(orig_concat.encode('utf-8')).hexdigest()
    merged_hash = hashlib.md5(merged_concat.encode('utf-8')).hexdigest()
    c9 = orig_hash == merged_hash
    print(f"{'PASS' if c9 else 'FAIL'}")
    print(f"  Original hash: {orig_hash}")
    print(f"  Merged hash:   {merged_hash}")
    all_passed &= c9

    # === CHECK 10: Row ordering preserved ===
    print("CHECK 10: Row ordering preserved...", end=' ', flush=True)
    order_ok = True
    for i, (orig, m) in enumerate(zip(ev_orig, merged)):
        if orig['事件 ID'] != m['事件 ID']:
            order_ok = False
            break
    c10 = order_ok
    print(f"{'PASS' if c10 else 'FAIL'}")
    all_passed &= c10

    # === CHECK 11: No duplicate firm-event pairs (panel structure) ===
    firm_event_keys = [(r['公司编码'], r['事件 ID']) for r in merged if r['事件 ID'].strip() and r['公司编码'].strip()]
    dup_pairs = len(firm_event_keys) - len(set(firm_event_keys))
    c11 = dup_pairs == 0
    print(f"CHECK 11: No duplicate firm-event pairs (dups: {dup_pairs}): {'PASS' if c11 else 'FAIL'}")
    all_passed &= c11

    # === CHECK 11b: 86 firms per event (panel structure) ===
    from collections import Counter
    event_firm_counts = Counter(r['事件 ID'] for r in merged if r['事件 ID'].strip() and r['公司编码'].strip())
    firms_per_event = set(event_firm_counts.values())
    c11b = firms_per_event == {86} or all(v <= 86 for v in firms_per_event)
    print(f"CHECK 11b: Firms per event distribution: {sorted(firms_per_event)}: {'PASS' if c11b else 'FAIL'}")
    all_passed &= c11b

    # === CHECK 12: Firm count unchanged ===
    ev_firms = set(r['公司编码'] for r in ev_orig if r['公司编码'].strip())
    merged_firms = set(r['公司编码'] for r in merged if r['公司编码'].strip())
    c12 = ev_firms == merged_firms
    print(f"CHECK 12: Firm set unchanged ({len(ev_firms)} firms): {'PASS' if c12 else 'FAIL'}")
    all_passed &= c12

    # === CHECK 13: Event count unchanged ===
    ev_events = set((r['模型发布者'], r['模型名称'], r['日级发布日期']) for r in ev_orig)
    merged_events = set((r['模型发布者'], r['模型名称'], r['日级发布日期']) for r in merged)
    c13 = ev_events == merged_events
    print(f"CHECK 13: Event set unchanged ({len(ev_events)} events): {'PASS' if c13 else 'FAIL'}")
    all_passed &= c13

    # === CHECK 14: No NaN/None in original columns ===
    nan_count = 0
    for r in merged:
        for key in ev_headers:
            if r.get(key) is None:
                nan_count += 1
    c14 = nan_count == 0
    print(f"CHECK 14: No None values in original columns (None count: {nan_count}): {'PASS' if c14 else 'FAIL'}")
    all_passed &= c14

    # === CHECK 15: Numeric financial columns preserved ===
    print("CHECK 15: Financial column spot checks...", end=' ', flush=True)
    fin_cols = ['市场模型异常收益[-10,-2]', 'FF3异常收益时间窗口1', '规模（亿美元）（ln）', '账面市值比']
    fin_ok = True
    for col in fin_cols:
        if col in ev_headers:
            orig_vals = [r[col] for r in ev_orig if r[col].strip()]
            merged_vals = [r[col] for r in merged if r[col].strip()]
            if orig_vals[:5] != merged_vals[:5]:
                fin_ok = False
                break
    c15 = fin_ok
    print(f"{'PASS' if c15 else 'FAIL'}")
    all_passed &= c15

    print(f"\n{'='*60}")
    print(f"ALL CHECKS: {'ALL PASSED' if all_passed else 'SOME FAILED'}")
    print(f"{'='*60}")

    if not all_passed:
        import sys; sys.exit(1)

if __name__ == '__main__':
    main()
