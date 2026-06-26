# A子代理 状态日志

## 完整读取的文件
- data/source_reports/aitimeline_extraction_report.md（172行，全文）
- data/source_reports/aitimeline_model_events_enriched_report.md（55行，全文）
- data/source_reports/aitimeline_model_events_enriched_codebook.md（166行，全文）

## 执行的diff对比
- diff reports/aitimeline_extraction_report.md data/source_reports/aitimeline_extraction_report.md → 无差异
- diff reports/aitimeline_model_events_enriched_report.md data/source_reports/aitimeline_model_events_enriched_report.md → 无差异
- diff reports/aitimeline_model_events_enriched_codebook.md data/source_reports/aitimeline_model_events_enriched_codebook.md → 无差异
- ls -la 确认 reports/ 下三文件 mtime=Apr 27（生成当天），data/source_reports/ 下同名文件 mtime=Jun 14（项目整理时复制产生），内容完全相同，无版本分歧。

## 执行的搜索（全部记录，包括无结果的）
1. `grep -rliE "产品.*模型|模型.*产品|product.*model.*distinct" --include="*.md" .`
   - 命中9个文件，逐一核查后确认无一专门讲"产品vs模型"判定标准（命中均为字面共现，语境不同，如relationship coding相关文档）。
2. `find agent_tasks -maxdepth 1 -iname "*aitimeline*" -o -iname "*timeline*"` → 无结果。
3. `find archive -iname "*aitimeline*" -o -iname "*timeline*"` → 无结果。
4. `find . -iname "*aitimeline*"`（全项目）→ 仅命中 reports/、data/source_reports/ 下三份md，及 data/raw/aitimeline/（空目录）。
5. `ls -la data/raw/aitimeline/` → 确认目录为空，原始缓存文件timeline_2026-04-27.md不存在。
6. `ls data/` → 确认 data/processed/ 目录不存在（codebook中提到的主表 aitimeline_model_events_enriched.csv 所在目录）。
7. `find . -iname "build_aitimeline*"` 和 `grep -rl "build_aitimeline_enriched_dataset" scripts/` → 均无结果，确认生成脚本已不存在。
8. `git log --all --oneline -- "*aitimeline*"` 和 `git log --all --oneline -- "scripts/build_aitimeline_enriched_dataset.py"` → 该脚本从未被git追踪，无历史版本可恢复。
9. 检查了 agent_tasks/event_data_cleaning_202606021351/ 全部文件名是否提及aitimeline或产品/模型关键词 → 无关，该工作区处理面板结构/日期/数值审计，与AI Timeline抓取筛选无关。

## 结论性发现
- 抓取报告(extraction_report)和审核结果报告(enriched_report)+字段说明(codebook)三份文档内容可信、无版本歧义，是A段唯一可用的一手证据。
- 136条人工审核的逐条具体决策内容已永久丢失（底层csv文件和生成脚本均已物理删除，且从未进入git版本控制，无法恢复）。
- "产品vs模型"判定没有找到任何文档化规则，只能确认统计层面的痕迹数字（22条非模型条目、18条mixed_product_or_agent_context送审、10条最终排除），逐条标准已不可考。
- 已将上述发现及具体数字写入 outputs/A_extraction_and_review_timeline.md，并明确标注哪些是文档实证、哪些是推算、哪些完全找不到依据。
