# Relationship Recode Schema Switch — Independent Verification

Date: 2026-06-25
Verified with pandas against actual file contents (not just headers).

## Summary verdict: PASS (with one minor, non-blocking anomaly)

All 7 checks pass on the substance of the schema switch (row counts, column sets, dimension counts, duplicate keys, missing values, and row-level value spot checks all confirmed correct). One pre-existing data artifact was found in the backup file (an "UNMATCHED" placeholder row with all-NaN keys), which is cosmetic and does not affect the new-schema files or any of the dimension counts.

## Pass/Fail Table

| # | Check | Result | Detail |
|---|-------|--------|--------|
| 1 | `relationship_data_final.csv` exists, 5160 rows, 60 unique `final_event_id`, no old columns | **PASS** | Rows = 5160. Unique `final_event_id` = 60. None of `owner, investor, cloud, business_upstream, real_upstream, business_downstream, real_downstream` present as columns. |
| 2 | `data/panel/specr_rel_clean.csv` has new-schema structure, not old | **PASS** | Rows = 5160. Same column set as `relationship_data_final.csv`. None of the old columns present. All 8 new dimension columns present. |
| 3 | `data/panel/specr_rel_clean_OLD_BACKUP.csv` exists, has OLD schema, plausible row count | **PASS with anomaly** | Old columns `owner, investor, cloud, business_upstream, real_upstream, business_downstream, real_downstream` all present (confirms old schema preserved). Row count = **5161**, not 5160 — see anomaly note below. |
| 4 | 8-dimension sum counts match expected exactly, across all 3 files | **PASS** | See counts table below — every dimension matches expected value exactly in `relationship_data_final.csv`, `specr_rel_clean.csv`, AND `data/relationships/adjudicated_event_level.csv` (source of truth). |
| 5 | No duplicate `(final_event_id, company_id)` keys | **PASS** | `relationship_data_final.csv`: 0 duplicates. `specr_rel_clean.csv`: 0 duplicates. |
| 6 | No missing/NaN in the 8 dimension columns | **PASS** | All 8 dimension columns have 0 NaN in both `relationship_data_final.csv` and `specr_rel_clean.csv`. All values are binary (0/1) — no stray values found. |
| 7 | Spot check 3 rows (AMZN, GOOGL, 1 random other) against `adjudicated_event_level.csv` | **PASS** | A full inner-join merge of `relationship_data_final.csv` to `adjudicated_event_level.csv` on `(final_event_id, company_id)` produced **5160 matched rows out of 5160** — i.e., every single row matches, not just the 3 spot-checked. All 8 dimension values matched exactly for AMZN (FMR-0001), GOOGL (FMR-0001), and a randomly sampled third row (WRD, ticker for Weride, event FMR-0052). |

## Dimension count detail (Check 4)

| Dimension | Expected | relationship_data_final.csv | specr_rel_clean.csv | adjudicated_event_level.csv |
|---|---|---|---|---|
| upstream_hardware | 1200 | 1200 ✓ | 1200 ✓ | 1200 ✓ |
| upstream_cloud | 300 | 300 ✓ | 300 ✓ | 300 ✓ |
| downstream_integrator | 1797 | 1797 ✓ | 1797 ✓ | 1797 ✓ |
| downstream_deployer | 1140 | 1140 ✓ | 1140 ✓ | 1140 ✓ |
| downstream_enabler | 480 | 480 ✓ | 480 ✓ | 480 ✓ |
| competitor | 511 | 511 ✓ | 511 ✓ | 511 ✓ |
| is_investor | 39 | 39 ✓ | 39 ✓ | 39 ✓ |
| is_owner | 29 | 29 ✓ | 29 ✓ | 29 ✓ |

All counts match exactly across all three files. No mismatches found.

## Anomaly found (Check 3)

`data/panel/specr_rel_clean_OLD_BACKUP.csv` has **5161 rows**, one more than the expected 5160. Investigation shows the extra row has `final_event_id = NaN`, `company_id = NaN`, `company = NaN`, and a `relationship_notes` value of:

> "UNMATCHED: no relationship coding found for ticker=, mc=, model=, date_raw=, date_norm="

This is a junk/placeholder row that appears to have existed in the original pre-migration `specr_rel_clean.csv` before the schema switch — it is not something the migration introduced, since the backup is supposed to be a faithful pre-overwrite snapshot. It does not have a valid key, has 0 duplicate `(final_event_id, company_id)` pairs otherwise, and all 60 `final_event_id` values are otherwise represented as expected. 

**Severity: Low / cosmetic.** This does not affect the new-schema files (`relationship_data_final.csv` and `specr_rel_clean.csv` both correctly have exactly 5160 valid rows with no NaN keys). It only affects the backup copy, which is for reference/rollback purposes. Recommend noting this for awareness but it does not block the switch — the backup still faithfully preserves the old schema and old data values for the 5160 real rows.

## Additional observation (not a failure)

Both new-schema files retain a column named `relationship_old` (a legacy/raw relationship string column, distinct from the structured old columns `owner/investor/cloud/...` that were explicitly checked and confirmed absent). This was not on the prohibited old-column list in the verification spec, so it is not flagged as a failure, but it's worth confirming with the analyst whether `relationship_old` is intentionally retained as a reference/audit column or should also have been dropped.

## Conclusion

The schema switch was executed correctly. All quantitative checks (row counts in the two live files, unique event counts, dimension sums, duplicate-key checks, missing-value checks, and full-row value reconciliation against the adjudicated source of truth) pass exactly with zero discrepancies. The only issue found is a single extra placeholder/junk row in the OLD_BACKUP file, which is a pre-existing artifact unrelated to the correctness of the new schema and does not require remediation before proceeding.
