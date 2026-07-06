#!/usr/bin/env python3
"""Archive old-data workflow files into old/ while preserving paths."""

from __future__ import annotations

import csv
import shutil
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TASK_DIR = ROOT / "agent_tasks" / "archive-old-data_20260703-151110"
OLD = ROOT / "old"

ARCHIVE_ITEMS = [
    # Old root datasets and old-data papers.
    ("6.21事件集数据.csv", "old root event dataset"),
    ("6.21事件集数据(1).csv", "old root event dataset duplicate"),
    ("relationship_data_final.csv", "old relationship panel"),
    ("relationship_data_final 2.csv", "old relationship panel duplicate"),
    ("relationship_specr_newrel_report.md", "old relationship specification report"),
    ("6.21research proposal.docx", "old proposal document"),
    ("6.21research proposal(1).docx", "old proposal duplicate"),
    ("Long_prompt.md", "old-data draft revision notes"),
    ("可能需要修改的地方.docx", "old-data draft revision notes"),
    ("PAPER_B_WRITING_PLAN.md", "old-data paper plan"),
    ("paper_plan.md", "old-data paper plan"),
    ("paper_plan 2.md", "old-data paper plan duplicate"),
    ("prompt.md", "old prompt"),
    ("prompt 2.md", "old prompt duplicate"),
    ("proposal.md", "old proposal"),
    ("proposal 2.md", "old proposal duplicate"),
    ("research proposal.md", "old proposal"),
    ("research proposal 2.md", "old proposal duplicate"),
    ("research proposal.docx", "old proposal"),
    ("research proposal 2.docx", "old proposal duplicate"),
    ("result.md", "old results narrative"),
    ("result 2.md", "old results narrative duplicate"),
    ("long_tex_gap_analysis.md", "old draft gap analysis"),
    ("long_tex_gap_analysis 2.md", "old draft gap analysis duplicate"),
    ("to_do_align_proposal.md", "old proposal alignment checklist"),
    ("to_do_align_proposal 2.md", "old proposal alignment checklist duplicate"),
    # Old data, scripts, reports and outputs.
    ("data", "old canonical/intermediate/panel dataset tree"),
    ("scripts", "old preprocessing and regression scripts"),
    ("reports", "old generated reports"),
    ("task", "old merge and relationship task workspace"),
    ("output", "old generated tables and figures"),
    ("archive", "old pre-existing archive directory"),
    ("Tex", "old TeX drafts and compile artifacts based on old sample"),
    ("大语言模型发布行为对金融市场的影响 - 来自美股市场的证据", "nested old project copy"),
    ("new data set/scripts/compare_old60_new61.py", "old-vs-new comparison script dependent on old data"),
    ("new data set/reports/old60_new61_two_groups.md", "old-vs-new comparison report"),
    ("new data set/reports/old60_vs_ai_timeline61_comparison_report.md", "old-vs-new comparison report"),
    ("new data set/processed/ai_timeline_61_event_level.csv", "old-vs-new comparison intermediate"),
    ("new data set/processed/old60_vs_ai_timeline61_comparison.xlsx", "old-vs-new comparison workbook"),
    ("new data set/processed/old60_vs_ai_timeline61_new_view.csv", "old-vs-new comparison table"),
    ("new data set/processed/old60_vs_ai_timeline61_objective_pairs.csv", "old-vs-new comparison table"),
    ("new data set/processed/old60_vs_ai_timeline61_old_view.csv", "old-vs-new comparison table"),
    ("new data set/agent_tasks 2", "empty duplicate old folder"),
    ("new data set/processed 2", "empty duplicate old folder"),
    ("new data set/raw 2", "empty duplicate old folder"),
    ("new data set/reports 2", "empty duplicate old folder"),
    ("new data set/scripts 2", "empty duplicate old folder"),
    # Old agent task outputs. Keep current task and new-data collection tasks in place.
    ("agent_tasks/analysis_report_20260521-133006", "old analysis task"),
    ("agent_tasks/car_pre_control_20260627", "old CAR control task"),
    ("agent_tasks/coder_a_relationship_coding_2026062418", "old relationship coding task"),
    ("agent_tasks/coder_ab_discrepancy_audit_20260624-211116", "old relationship discrepancy task"),
    ("agent_tasks/data_consolidation_20260614-122508", "old data consolidation task"),
    ("agent_tasks/econometric_robustness_20260613-210000", "old econometric robustness task"),
    ("agent_tasks/event_data_cleaning_202606021351", "old event cleaning task"),
    ("agent_tasks/event_selection_provenance_2026062515", "old event provenance task"),
    ("agent_tasks/frl-draft_20260611-134549", "old FRL draft task"),
    ("agent_tasks/frl_project_review_20260613-204658", "old project review task"),
    ("agent_tasks/frl_project_review_20260613-204850", "old project review task"),
    ("agent_tasks/frl_submission_20260614-091455", "old submission package task"),
    ("agent_tasks/full_length_data_collection_todo_20260614.md", "old data collection task note"),
    ("agent_tasks/full_length_data_collection_todo_20260614 2.md", "old data collection task note duplicate"),
    ("agent_tasks/full_length_paper_gap_assessment_20260614.md", "old paper gap task note"),
    ("agent_tasks/latex_paper_2026061100", "old LaTeX paper task"),
    ("agent_tasks/lit_review_long_new_20260625-194602", "old literature task tied to old draft"),
    ("agent_tasks/paper_b_robustness_2026062514", "old paper robustness task"),
    ("agent_tasks/proposal_gap_analysis_20260619-092947", "old proposal gap task"),
    ("agent_tasks/proposal_gap_completion_20260619-104007", "old proposal completion task"),
    ("agent_tasks/publishable_results_inventory_20260613-233641.md", "old results inventory task note"),
    ("agent_tasks/publishable_results_inventory_20260613-233641 2.md", "old results inventory task note duplicate"),
    ("agent_tasks/ref_audit_20260625-233637", "old reference audit task"),
    ("agent_tasks/relationship_coding_20260624-184054", "old relationship coding task"),
    ("agent_tasks/relationship_coding_20260624-184413", "old relationship coding task"),
    ("agent_tasks/relationship_coding_20260624-205216", "old relationship coding task"),
    ("agent_tasks/relationship_merge_20260625-0005", "old relationship merge task"),
    ("agent_tasks/relationship_recode_switch_2026062500", "old relationship recode task"),
    ("agent_tasks/relationship_specr_newrel_20260625-005125", "old relationship specification task"),
    ("agent_tasks/specr_star_scan_20260627", "old specification scan task"),
]

KEEP_NOTES = [
    ("new data set", "new event rebuild, raw AA/AI Timeline files and final sample"),
    ("Analysis", "new event-firm panel and new regressions"),
    ("CAR", "new CAR input collection"),
    ("Fundamentals", "new fundamentals collection"),
    ("事件标签", "new event labels and A/B discrepancies"),
    ("关系标签", "new relationship labels and A/B discrepancies"),
    ("企业列表", "new firm universe work area"),
    ("agent_tasks/archive-old-data_20260703-151110", "current archive task workspace"),
    ("agent_tasks/car_data_collection_20260702-181321", "new CAR data task evidence"),
    ("agent_tasks/fundamentals_collection_20260702-223530", "new fundamentals task evidence"),
    ("agent_tasks/timestamp_events_20260702-110203", "new date evidence task"),
    ("to_do_rebuild_regression_20260702.md", "new-data rebuild checklist"),
    ("数据问题与欠缺清单_20260703.md", "new-data issue list"),
]


def unique_dest(rel: Path) -> Path:
    dest = OLD / rel
    if not dest.exists():
        return dest
    parent = dest.parent
    stem = dest.name
    for i in range(1, 1000):
        candidate = parent / f"{stem}.archived_{i}"
        if not candidate.exists():
            return candidate
    raise RuntimeError(f"too many destination conflicts for {rel}")


def build_rows():
    rows = []
    for rel_s, reason in ARCHIVE_ITEMS:
        rel = Path(rel_s)
        src = ROOT / rel
        status = "missing"
        dest_rel = ""
        if src.exists():
            dest = unique_dest(rel)
            dest_rel = str(dest.relative_to(ROOT))
            status = "ready"
        rows.append({
            "source": rel_s,
            "destination": dest_rel,
            "reason": reason,
            "status": status,
        })
    return rows


def write_manifest(rows, name):
    path = TASK_DIR / name
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["source", "destination", "reason", "status"])
        writer.writeheader()
        writer.writerows(rows)
    return path


def write_keep_notes():
    path = TASK_DIR / "kept_new_data_paths.md"
    with path.open("w", encoding="utf-8") as f:
        f.write("# Kept New-Data Paths\n\n")
        for rel, reason in KEEP_NOTES:
            f.write(f"- `{rel}` — {reason}\n")
    return path


def move(rows):
    OLD.mkdir(exist_ok=True)
    moved = []
    for row in rows:
        if row["status"] != "ready":
            moved.append(row)
            continue
        src = ROOT / row["source"]
        dest = ROOT / row["destination"]
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dest))
        row["status"] = "moved"
        moved.append(row)
    return moved


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--dry-run"
    if mode not in {"--dry-run", "--execute"}:
        raise SystemExit("usage: archive_old_files.py [--dry-run|--execute]")

    rows = build_rows()
    write_keep_notes()
    if mode == "--execute":
        rows = move(rows)
        manifest = write_manifest(rows, "archive_manifest.csv")
    else:
        manifest = write_manifest(rows, "archive_dry_run_manifest.csv")

    ready = sum(1 for r in rows if r["status"] in {"ready", "moved"})
    missing = sum(1 for r in rows if r["status"] == "missing")
    print(f"mode={mode} ready_or_moved={ready} missing={missing} manifest={manifest}")


if __name__ == "__main__":
    main()
