#!/usr/bin/env python3
"""
Merge Engine: Event Data + Relationship Coding → Regression-Ready Dataset
Merges 事件集数据-new 2.csv with firm_model_relationships.csv
Key requirement: event data columns MUST NOT be altered.
"""
import csv, os, re
from collections import defaultdict
from datetime import datetime, timedelta

TASK_DIR = '/Users/chenzhuo/Library/Mobile Documents/com~apple~CloudDocs/Documents/Manuscript/在研项目/大语言模型发布行为对金融市场的影响 - 来自美股市场的证据/task'

def excel_serial_to_date(serial):
    """Convert Excel date serial number to YYYY-MM-DD string."""
    try:
        serial = int(serial)
        # Excel date epoch: 1899-12-30 (accounting for the 1900 leap year bug)
        base = datetime(1899, 12, 30)
        return (base + timedelta(days=serial)).strftime('%Y-%m-%d')
    except (ValueError, TypeError):
        return None

def normalize_date(d):
    """Normalize date from various formats to YYYY-MM-DD."""
    d = d.strip()
    # Try YYYY/M/D or YYYY-M-D
    for sep in ['/', '-']:
        parts = d.split(sep)
        if len(parts) == 3:
            try:
                return f'{int(parts[0]):04d}-{int(parts[1]):02d}-{int(parts[2]):02d}'
            except ValueError:
                pass
    # Try Excel serial number
    result = excel_serial_to_date(d)
    if result:
        return result
    # Already YYYY-MM-DD?
    if re.match(r'^\d{4}-\d{2}-\d{2}$', d):
        return d
    return d

def main():
    print("=" * 60)
    print("MERGE ENGINE: Event Data + Relationship Coding")
    print("=" * 60)

    # ============================================================
    # LOAD EVENT DATA (preserve every byte)
    # ============================================================
    with open(os.path.join(TASK_DIR, '事件集数据-new 2.csv'), 'r', encoding='gb18030') as f:
        ev_raw = list(csv.DictReader(f))

    # Store original headers (Chinese)
    ev_headers = ev_raw[0].keys() if ev_raw else []
    print(f"Event data: {len(ev_raw)} rows, {len(ev_headers)} columns")

    # Filter out description row (row with placeholder values like 'final_event_id')
    ev_data = [r for r in ev_raw if r.get('事件 ID', '') != 'final_event_id']
    desc_count = len(ev_raw) - len(ev_data)
    print(f"Filtered {desc_count} description row(s), {len(ev_data)} real data rows")

    # Deep copy event data to detect any alteration later
    ev_original = []
    for r in ev_data:
        ev_original.append(dict(r))

    # ============================================================
    # LOAD RELATIONSHIP DATA
    # ============================================================
    with open(os.path.join(TASK_DIR, 'firm_model_relationships.csv'), 'r', encoding='utf-8-sig') as f:
        rel_data = list(csv.DictReader(f))
    print(f"Relationship data: {len(rel_data)} rows")

    # Build relationship lookup
    rel_lookup = {}
    for r in rel_data:
        key = (
            r['firm_ticker'].strip(),
            r['model_company'].strip(),
            r['model'].strip(),
            r['event_date'].strip()
        )
        rel_lookup[key] = {
            'owner': r['owner'],
            'investor': r['investor'],
            'cloud': r['cloud'],
            'business_upstream': r['business_upstream'],
            'real_upstream': r['real_upstream'],
            'business_downstream': r['business_downstream'],
            'real_downstream': r['real_downstream'],
            'competitor': r['competitor'],
            'relationship_notes': r.get('notes', ''),
        }

    # ============================================================
    # MERGE
    # ============================================================
    print("\n--- Merging ---")

    merged = []
    matched = 0
    unmatched = 0
    unmatched_details = []

    REL_VARS = ['owner', 'investor', 'cloud', 'business_upstream', 'real_upstream',
                'business_downstream', 'real_downstream', 'competitor', 'relationship_notes']

    for i, r in enumerate(ev_data):
        ticker = r['公司编码'].strip()
        model_company = r['模型发布者'].strip()
        model = r['模型名称'].strip()
        raw_date = r['日级发布日期'].strip()
        date = normalize_date(raw_date)

        key = (ticker, model_company, model, date)

        # Build merged row: ALL original columns + relationship variables
        row = dict(r)  # Start with original data

        if key in rel_lookup:
            rel = rel_lookup[key]
            for var in REL_VARS:
                row[var] = rel[var]
            matched += 1
        else:
            # No match found - set to 0 with note
            for var in REL_VARS[:-1]:  # All except notes
                row[var] = '0'
            row['relationship_notes'] = f'UNMATCHED: no relationship coding found for ticker={ticker}, mc={model_company}, model={model}, date_raw={raw_date}, date_norm={date}'
            unmatched += 1
            if len(unmatched_details) < 20:
                # Find closest matches for diagnostics
                same_ticker = [k for k in rel_lookup if k[0] == ticker]
                same_ticker_date = [k for k in same_ticker if k[3] == date]
                unmatched_details.append(
                    f'{ticker} | {model_company} | {model} | raw={raw_date} norm={date} | '
                    f'same_ticker={len(same_ticker)} same_ticker+date={len(same_ticker_date)}'
                )

        merged.append(row)

    print(f"Matched: {matched}, Unmatched: {unmatched} ({100*matched/(matched+unmatched):.1f}% match rate)")
    if unmatched_details:
        print(f"Unmatched details:")
        for d in unmatched_details:
            print(f"  {d}")

    # ============================================================
    # VERIFY: Event data NOT altered
    # ============================================================
    print("\n" + "=" * 60)
    print("VERIFICATION: Event Data Integrity Check")
    print("=" * 60)

    alterations = 0
    alteration_samples = []

    for i, (orig, merged_row) in enumerate(zip(ev_original, merged)):
        for key in orig:
            if key not in merged_row:
                alterations += 1
                if len(alteration_samples) < 5:
                    alteration_samples.append(f'MISSING column: row {i}, key={key}')
            elif orig[key] != merged_row[key]:
                alterations += 1
                if len(alteration_samples) < 5:
                    alteration_samples.append(
                        f'ALTERED value: row {i}, key={key}, '
                        f'orig={orig[key][:50]}, new={merged_row[key][:50]}'
                    )

    if alterations == 0:
        print("VERIFIED: 0 alterations to original event data columns!")
    else:
        print(f"WARNING: {alterations} alterations found!")
        for s in alteration_samples:
            print(f"  {s}")

    # Check row count
    assert len(merged) == len(ev_data), f"Row count changed: {len(ev_data)} → {len(merged)}"

    # Check all new columns present
    for var in REL_VARS:
        assert var in merged[0], f"Missing column: {var}"

    # Check all original columns present
    for key in ev_headers:
        assert key in merged[0], f"Missing original column: {key}"

    # ============================================================
    # ADDITIONAL VERIFICATIONS
    # ============================================================
    print("\n--- Additional Verifications ---")

    # Count relationship variable distributions
    rel_counts = defaultdict(int)
    for r in merged:
        for var in REL_VARS[:-1]:  # Exclude notes
            if r[var] == '1':
                rel_counts[var] += 1
    print("Relationship value=1 counts:")
    for var in REL_VARS[:-1]:
        print(f"  {var}: {rel_counts[var]}")

    # Verify relationship counts match expected (from narrow downstream)
    expected = {
        'owner': 31, 'investor': 44, 'cloud': 34,
        'business_upstream': 172, 'real_upstream': 141,
        'business_downstream': 1584, 'real_downstream': 89,
        'competitor': 495
    }
    for var in REL_VARS[:-1]:
        exp = expected[var]
        actual = rel_counts[var]
        # Note: expected counts are from 5676 × 1. The merge may map to 5161 rows,
        # so counts should be ≤ expected. For unmatched rows, they're 0.
        if actual > exp:
            print(f"  WARNING: {var} count {actual} > expected {exp}")
        else:
            print(f"  {var}: {actual} (≤{exp} due to 5161-row event sample) ✓")

    # Check that non-matched rows have 0 in all relationship columns
    unmatched_zero = 0
    for r in merged:
        if 'UNMATCHED' in r.get('relationship_notes', ''):
            all_zero = all(r.get(var, '0') == '0' for var in REL_VARS[:-1])
            if not all_zero:
                unmatched_zero += 1
    print(f"Unmatched rows with non-zero relationship values: {unmatched_zero}")

    # ============================================================
    # WRITE OUTPUT
    # ============================================================
    print("\n--- Writing output ---")

    # Build output headers: all original columns + relationship variables
    out_headers = list(ev_headers) + REL_VARS
    print(f"Output columns: {len(out_headers)} ({len(ev_headers)} original + {len(REL_VARS)} relationship)")

    out_path = os.path.join(TASK_DIR, '事件集数据-relationships.csv')
    with open(out_path, 'w', newline='', encoding='utf-8-sig') as f:
        w = csv.DictWriter(f, fieldnames=out_headers, extrasaction='ignore')
        w.writeheader()
        w.writerows(merged)

    # Verify written file
    with open(out_path, 'r', encoding='utf-8-sig') as f:
        verify_rows = list(csv.DictReader(f))
    print(f"Written: {len(verify_rows)} rows, {len(verify_rows[0])} columns")
    assert len(verify_rows) == len(ev_data), f"Row count mismatch in output: {len(verify_rows)} != {len(ev_data)}"

    # Final integrity check: re-read and compare
    print("\n--- Final integrity check: re-read output and compare to original ---")
    with open(out_path, 'r', encoding='utf-8-sig') as f:
        final_rows = list(csv.DictReader(f))

    final_alterations = 0
    for i, (orig, final) in enumerate(zip(ev_original, final_rows)):
        for key in orig:
            if key not in final or orig[key] != final[key]:
                final_alterations += 1
                if final_alterations <= 3:
                    print(f"  ALTERATION row {i} col '{key}': orig='{orig[key][:60]}' != final='{final.get(key, 'MISSING')[:60]}'")

    if final_alterations == 0:
        print("FINAL VERIFICATION PASSED: 0 alterations in output file!")
    else:
        print(f"FINAL VERIFICATION FAILED: {final_alterations} alterations!")
        import sys; sys.exit(1)

    # Summary
    summary = f"""# Merge Summary: Event Data + Relationship Coding

## Input
- 事件集数据-new 2.csv: {len(ev_data)} event rows, {len(ev_headers)} columns
- firm_model_relationships.csv: {len(rel_data)} relationship rows, 14 columns

## Output
- 事件集数据-relationships.csv: {len(merged)} rows, {len(out_headers)} columns

## Merge Results
- Matched: {matched} ({100*matched/(matched+unmatched):.1f}%)
- Unmatched: {unmatched}

## Relationship Value=1 Counts (in merged dataset)
| Variable | Count |
|---|---|
| owner | {rel_counts['owner']} |
| investor | {rel_counts['investor']} |
| cloud | {rel_counts['cloud']} |
| business_upstream | {rel_counts['business_upstream']} |
| real_upstream | {rel_counts['real_upstream']} |
| business_downstream | {rel_counts['business_downstream']} |
| real_downstream | {rel_counts['real_downstream']} |
| competitor | {rel_counts['competitor']} |

## Integrity Verification
- Original event data columns: 0 alterations confirmed
- Row count preserved: {len(ev_data)} → {len(merged)}
- All original columns present: YES
- All 9 relationship columns added: YES
"""
    with open(os.path.join(TASK_DIR, 'agent_tasks/merge_regression_202606110558/merge_summary.md'), 'w', encoding='utf-8') as f:
        f.write(summary)

    print(f"\n{'='*60}")
    print("MERGE COMPLETE")
    print(f"{'='*60}")
    print(f"Output: 事件集数据-relationships.csv")
    print(f"Rows: {len(merged)}, Columns: {len(out_headers)}")
    print(f"Match rate: {100*matched/(matched+unmatched):.1f}%")
    print(f"Event data integrity: VERIFIED (0 alterations)")

if __name__ == '__main__':
    main()
