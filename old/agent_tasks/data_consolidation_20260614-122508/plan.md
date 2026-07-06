# Data consolidation execution plan

Created: 2026-06-14 12:25:08 Asia/Shanghai

## Objective

把当前项目中可能有用的数据统一整理到项目根目录的 `data/` 文件夹，减少后续面对 `reports/`、`task/`、`output/`、历史路径混杂的问题。此次只做归拢、导出、登记和轻量校验，不改变原始数据含义。

## Phase 1. Planning and inventory

- 扫描 `reports/`、`task/`、`output/data/`、`output/tables/` 中已有数据。
- 识别可以直接复制的 CSV、可以从面板去重导出的 canonical 表、以及只有报告没有原始文件的项目。
- 形成目录结构和 manifest 字段。

## Phase 2. Implementation

- 创建 `data/` 目录结构。
- 复制已有原始和中间数据到 `data/source_reports/`、`data/intermediate/`、`data/panel/`、`data/results_tables/`。
- 从现有面板导出 `data/canonical/event_master_from_panel.csv`。
- 从现有面板导出 `data/canonical/company_master_from_panel.csv`。
- 从现有关系表和 evidence 表复制到 `data/relationships/`。
- 生成 `data/manifest.csv` 和 `data/README.md`。

## Phase 3. Review

- 检查关键文件是否存在。
- 检查 event master、company master、panel 的行数和主键数量。
- 标记当前项目缺失但报告中提到的 raw files。

## Phase 4. Revision

- 根据审查结果补充 README 和 manifest。
- 更新 `agent_tasks/full_length_data_collection_todo_20260614.md`，把第一步改成“已完成数据归拢，下一步做 canonical 表完善”。

## Outputs

- `data/README.md`
- `data/manifest.csv`
- `data/canonical/event_master_from_panel.csv`
- `data/canonical/company_master_from_panel.csv`
- `data/panel/clean_event_firm_panel.csv`
- `data/relationships/`
- `data/source_reports/`
- 更新后的 `agent_tasks/full_length_data_collection_todo_20260614.md`
