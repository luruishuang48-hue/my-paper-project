# Event_2.xlsx Data Quality Report

## Scope
- Source file: `Event_2.xlsx`
- Cleaned output: `data/events_clean.csv`
- Date conflict report: `date_conflict_report.csv`
- Manual review queue: `reports/manual_review_needed.csv`
- Total input rows: 94
- Rows retained: 94
- Rows deleted: 0

## Cleaning Rules
- `Date` was standardized to `release_date` in `YYYY-MM-DD` format.
- The original `Month` field was preserved as `release_month_original` for audit purposes.
- The canonical `release_month` column was re-derived from `release_date` in `YYYY-MM` format.
- Derived time fields: `release_year`, `release_quarter`, `trend_month_since_2022_11`.
- `creator` labels were normalized using deterministic string rules only, with no external validation.

## Creator Normalization
- `Openai -> OpenAI`: 3 rows
- `XAI -> xAI`: 8 rows
- `XAi -> xAI`: 1 rows

## Quality Checks
| Check | Count |
|---|---:|
| Date parse failures | 0 |
| Original month parse failures | 0 |
| Date vs Month conflicts | 1 |
| Duplicate event rows | 0 |
| Duplicate event groups | 0 |
| Missing `manual_sota` | 17 |
| Missing `manual_reason` | 20 |
| Rows queued for manual review | 21 |

## Notes
- No events were deleted.
- Duplicate detection rule: same normalized `creator`, same `event_name`, same standardized `release_date`.
- Manual review rows aggregate all flagged issues into `manual_review_issues`.
- Requirement collision was resolved by preserving the original month in `release_month_original` and using `release_month` for the canonical date-derived month.
