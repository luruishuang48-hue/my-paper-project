# Archive Review

时间：20260703-151110，北京时间。

## 执行结果

- 实际移动 77 项，清单见 `archive_manifest.csv`。
- 旧内容统一归档到根目录 `old/`，并保留原相对路径。
- 已归档范围包括旧根目录数据、旧脚本、旧报告、旧输出、旧 `Tex/` 稿件、嵌套旧项目、旧 agent task、旧稿修改意见，以及 `new data set/` 中依赖旧 `data/panel/clean_event_firm_panel.csv` 的 old60 对照产物。

## 保留的新数据链路

- `new data set/processed/final_event_sample_main.csv`
- `new data set/decisions/event_label_decisions.csv`
- `new data set/decisions/relationship_decisions.csv`
- `Analysis/processed/event_firm_panel.csv`
- `CAR/processed/returns_daily_long.csv`
- `Fundamentals/processed/fundamentals_quarterly_wide.csv`
- `事件标签/coder_AB_discrepancies_20260703.csv`
- `关系标签/coder_AB_discrepancies_20260703.csv`

## 抽查结论

- 根目录的 `data`、`scripts`、`reports`、`task`、`output`、`archive`、`Tex` 和嵌套同名项目均已移动到 `old/`。
- 根目录旧文件 `relationship_data_final.csv`、`6.21事件集数据.csv`、`Long_prompt.md`、`可能需要修改的地方.docx` 已移动到 `old/`。
- 当前 `new data set/` 下已无 `old60` 对照文件、`compare_old60_new61.py` 或空的 `* 2` 重复目录。

## 有意保留

- `事件标签/aitimeline_model_events_enriched_codebook.md` 和 `关系标签/relationship_codebook.md` 保留在原位。它们包含旧路径或旧样本数量，但当前 README 明确把它们作为本轮标签规则来源，移动会降低新标签流程的可追溯性。
- `关系标签/gpt_coding_prompt.md` 保留在原位。当前 README 明确说明它是沿用旧版提示词的规则参考，不作为旧结果使用。
