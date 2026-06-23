# Data folder README

Created: 2026-06-14.

This folder consolidates useful project data that was previously scattered across `reports/`, `task/`, `output/data/`, and `output/tables/`. The purpose is to create a stable working data layer for the full-length paper.

## Folder structure

| Folder | Contents |
|---|---|
| `canonical/` | Derived canonical tables extracted from the current clean panel |
| `panel/` | Clean regression input panels copied from `output/data/` |
| `relationships/` | Existing event-firm relationship files copied from `task/` |
| `source_reports/` | Existing data construction reports copied from `reports/` |
| `intermediate/` | Existing intermediate CSV reports copied from `reports/` |
| `results_tables/` | Existing regression and summary result CSV files copied from `output/tables/` |
| `raw/aitimeline/` | Placeholder for AI Timeline raw snapshots |
| `raw/artificial_analysis/` | Placeholder for Artificial Analysis raw API responses |
| `raw_external_paths/` | Records of raw files mentioned in reports but not found in the current project folder |
| `quality_checks/` | Light checks for the consolidated data |

## Key canonical tables

| File | Description |
|---|---|
| `canonical/event_master_from_panel.csv` | Event-level table deduplicated from the clean event-firm panel |
| `canonical/company_master_from_panel.csv` | Company-level table deduplicated from the clean event-firm panel |
| `canonical/event_firm_relationship_flags_from_panel.csv` | Event-firm relationship indicators and notes extracted from the current panel |
| `canonical/event_metric_snapshot_from_panel.csv` | Event-level AA and media metric snapshot extracted from the current panel |
| `canonical/event_official_sources_from_report.csv` | Official release-date sources parsed from the crawl report |
| `canonical/event_firm_panel_manifest.csv` | Short description of the current clean panel |
| `manifest.csv` | File-level inventory for all files under `data/` |

## Current counts

The current panel copied to `panel/clean_event_firm_panel.csv` has 5160 observations, 60 events, and 86 companies. The panel is the immediate source for the first canonical event and company tables.

The official release-date crawl report yields 47 structured official source rows in `canonical/event_official_sources_from_report.csv`.

## Important caveat

The project reports mention raw AI Timeline and Artificial Analysis files, but those raw files were not found in the current project folder during this consolidation pass.

Known missing raw files are listed in:

`raw_external_paths/missing_raw_files.csv`

This means the project has strong report-level evidence and processed data for AI Timeline and Artificial Analysis, but the raw snapshots still need to be recovered from the older path or regenerated before a replication package is complete.

## Next steps

1. Recover or regenerate raw AI Timeline and Artificial Analysis snapshots.
2. Build a stronger `event_master.csv` by merging `event_master_from_panel.csv`, AA match diagnostics, official release-date crawl results, and AI Timeline raw IDs.
3. Build `event_filter_flow.csv` to document the path from AI Timeline universe to the final 60 events.
4. Upgrade `event_official_sources_from_report.csv` into a full `event_sources.csv` by adding manual override reports and non-official sources where needed.
5. Build `event_aa_match.csv` from the AA match report and current panel AA variables.
