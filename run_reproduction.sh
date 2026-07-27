#!/bin/sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PIPELINE_LOGS="$PROJECT_ROOT/Analysis/reproduction/pipeline_logs"
mkdir -p "$PIPELINE_LOGS"

run_python() {
  stage="$1"
  script="$2"
  printf '%s\n' "Running $stage"
  python3 "$PROJECT_ROOT/$script" > "$PIPELINE_LOGS/$stage.log" 2>&1
  printf '%s\n' "Completed $stage"
}

run_python "01_firm_universe" "企业列表/build_firm_universe.py"
run_python "02_event_source_build" "事件集筛选/scripts/build_dataset.py"
run_python "03_event_entity_resolution" "事件集筛选/scripts/resolve_entities.py"
run_python "04_event_sample" "事件集筛选/scripts/build_final_sample.py"
run_python "05_event_dates" "事件集筛选/scripts/build_event_dates.py"
run_python "06_event_capability" "事件集筛选/scripts/build_event_aa_metrics.py"
run_python "07_event_label_validation" "事件标签/validate_event_labels.py"
run_python "08_relationship_validation" "关系标签/validate_relationship_coding.py"
run_python "09_car_inputs" "CAR/scripts/fetch_car_inputs.py"
run_python "10_car_validation" "CAR/scripts/validate_car_inputs.py"
run_python "11_fundamentals" "Fundamentals/scripts/fetch_fundamentals.py"
run_python "12_event_firm_panel" "Analysis/scripts/build_event_firm_panel.py"
run_python "13_abnormal_volume" "Analysis/scripts/build_abnormal_volume.py"

printf '%s\n' "Running 14_analysis"
sh "$PROJECT_ROOT/Analysis/scripts/run_ndxt45_full_workflow.sh"
printf '%s\n' "Completed 14_analysis"

printf '%s\n' "Running 15_manuscript"
(
  cd "$PROJECT_ROOT/Tex_new"
  latexmk -pdf -interaction=nonstopmode -halt-on-error frl_three_results.tex
) > "$PIPELINE_LOGS/15_manuscript.log" 2>&1
printf '%s\n' "Completed 15_manuscript"

printf '%s\n' "Running 16_online_appendix"
(
  cd "$PROJECT_ROOT/Tex_new"
  latexmk -pdf -interaction=nonstopmode -halt-on-error \
    frl_three_results_online_appendix.tex
) > "$PIPELINE_LOGS/16_online_appendix.log" 2>&1
printf '%s\n' "Completed 16_online_appendix"

printf '%s\n' "Reproduction completed successfully."
