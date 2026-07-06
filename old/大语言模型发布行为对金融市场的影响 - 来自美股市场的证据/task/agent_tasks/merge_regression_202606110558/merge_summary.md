# Merge Summary: Event Data + Relationship Coding

## Input
- 事件集数据-new 2.csv: 5161 event rows, 75 columns
- firm_model_relationships.csv: 5676 relationship rows, 14 columns

## Output
- 事件集数据-relationships.csv: 5161 rows, 84 columns

## Merge Results
- Matched: 5160 (100.0%)
- Unmatched: 1

## Relationship Value=1 Counts (in merged dataset)
| Variable | Count |
|---|---|
| owner | 29 |
| investor | 37 |
| cloud | 29 |
| business_upstream | 156 |
| real_upstream | 126 |
| business_downstream | 1440 |
| real_downstream | 81 |
| competitor | 462 |

## Integrity Verification
- Original event data columns: 0 alterations confirmed
- Row count preserved: 5161 → 5161
- All original columns present: YES
- All 9 relationship columns added: YES
