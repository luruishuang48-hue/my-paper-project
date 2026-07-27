#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
RUN_DIR="$PROJECT_ROOT/Analysis/reproduction"
LOG_DIR="$RUN_DIR/logs"

mkdir -p "$LOG_DIR"

export FRL_PROJECT_ROOT="$PROJECT_ROOT"
export FRL_PANEL_PATH="$PROJECT_ROOT/Analysis/processed/event_firm_panel.csv"
export FRL_VOLUME_PATH="$PROJECT_ROOT/Analysis/processed/event_firm_abnormal_volume.csv"
export FRL_REPORT_DIR="$PROJECT_ROOT/Analysis/reports"
export FRL_FIGURE_DIR="$PROJECT_ROOT/Tex_new/figures"

printf '%s\n' "Running 00_car_sensitivity_variants"
python3 "$SCRIPT_DIR/build_car_sensitivity_variants.py" \
  > "$LOG_DIR/00_car_sensitivity_variants.log" 2>&1
printf '%s\n' "Completed 00_car_sensitivity_variants"

run_stage() {
  stage="$1"
  script="$2"
  printf '%s\n' "Running $stage"
  Rscript "$script" > "$LOG_DIR/$stage.log" 2>&1
  printf '%s\n' "Completed $stage"
}

run_stage "01_t9_main_regressions" \
  "$SCRIPT_DIR/t9_main_regressions.R"
run_stage "02_t9_robustness_matrix" \
  "$SCRIPT_DIR/t9_robustness_matrix.R"
run_stage "03_paper_numbers" \
  "$SCRIPT_DIR/paper_numbers.R"
run_stage "04_capability_pricing" \
  "$SCRIPT_DIR/frl_capability_pricing.R"
run_stage "05_position_contrasts" \
  "$SCRIPT_DIR/frl_position_contrasts.R"
run_stage "06_two_way_cluster_equivalence" \
  "$SCRIPT_DIR/frl_two_way_cluster_and_equivalence.R"
run_stage "07_inference_diagnostics" \
  "$SCRIPT_DIR/frl_inference_diagnostics.R"
run_stage "08_nonoverlap_calendar_portfolio" \
  "$SCRIPT_DIR/frl_nonoverlap_calendar_portfolio.R"
run_stage "09_more_findings" \
  "$SCRIPT_DIR/more_findings.R"
run_stage "10_time_competitor_robustness" \
  "$SCRIPT_DIR/frl_time_and_competitor_robustness.R"
run_stage "11_figure" \
  "$SCRIPT_DIR/fig1_car_profile.R"

printf '%s\n' "Running 12_validation"
python3 "$SCRIPT_DIR/validate_ndxt45_rebuild.py" \
  > "$LOG_DIR/12_validation.log" 2>&1
printf '%s\n' "Completed 12_validation"

printf '%s\n' "NDXT45 analysis workflow completed."
