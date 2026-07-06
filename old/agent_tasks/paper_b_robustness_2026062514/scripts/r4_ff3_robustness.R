#!/usr/bin/env Rscript
#
# Agent R4: FF3 three-factor model robustness check
#
# Replaces market-model car_10/15/20 with FF3-model ff3_car_10/15/20 and
# re-runs the Table 2 (single-position) and Table 3 (bundle-position) core
# rows from scripts/analysis/paper_plan_core_outputs.R, using ONLY the new
# 8-dim relationship columns (upstream_hardware, upstream_cloud,
# downstream_integrator, downstream_deployer, downstream_enabler,
# competitor, is_investor, is_owner). Old-schema columns (owner, investor,
# cloud, real_upstream, business_upstream, real_downstream,
# business_downstream) are NOT used anywhere in this script.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(broom)
  library(estimatr)
})

input_file <- "data/panel/specr_rel_clean.csv"
out_dir <- "agent_tasks/paper_b_robustness_2026062514/outputs"
log_dir <- "agent_tasks/paper_b_robustness_2026062514/logs"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)

df <- read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE)

cat("Rows read:", nrow(df), "\n")

# New-schema relationship variables ONLY
rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year",
  "car_10", "car_15", "car_20",
  "ff3_car_10", "ff3_car_15", "ff3_car_20",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "is_open_weight", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  if (!col %in% names(df)) stop(paste("Missing relationship variable:", col))
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

# Bundle variables, copied exactly from paper_plan_core_outputs.R logic
df <- df %>%
  mutate(
    upstream_any = as.integer(upstream_hardware == 1 | upstream_cloud == 1),
    downstream_any = as.integer(
      downstream_integrator == 1 |
        downstream_deployer == 1 |
        downstream_enabler == 1
    )
  )

position_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor"
)

bundle_vars <- c("upstream_any", "downstream_any", "downstream_deployer")

ff3_outcomes <- c("ff3_car_10", "ff3_car_15", "ff3_car_20")
mm_outcome_map <- c(
  ff3_car_10 = "car_10",
  ff3_car_15 = "car_15",
  ff3_car_20 = "car_20"
)

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "factor(release_year)")

safe_formula <- function(y, rhs) {
  as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
}

model_data <- function(data, y, rhs_vars) {
  needed <- unique(c(y, "final_event_id", rhs_vars))
  needed <- needed[!grepl("^factor\\(", needed)]
  needed <- needed[needed %in% names(data)]

  out <- data %>%
    filter(!is.na(.data[[y]]), !is.na(final_event_id))

  for (v in setdiff(needed, c(y, "final_event_id"))) {
    out <- out %>% filter(!is.na(.data[[v]]))
  }

  out
}

run_lm <- function(data, y, rhs, term) {
  rhs_plain <- rhs[!grepl("^factor\\(", rhs)]
  d <- model_data(data, y, rhs_plain)

  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) {
    return(tibble())
  }

  mod <- lm_robust(
    safe_formula(y, rhs),
    data = d,
    clusters = d$final_event_id,
    se_type = "CR0"
  )

  tidy(mod, conf.int = TRUE) %>%
    filter(term == !!term) %>%
    transmute(
      variable = term,
      outcome = y,
      beta = estimate,
      se = std.error,
      p = p.value,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id)
    )
}

# ---- Step 1: Table 2 core rows (single-position regressions), FF3 outcomes ----
table2_ff3 <- crossing(variable = position_vars, outcome = ff3_outcomes) %>%
  mutate(res = map2(variable, outcome, function(x, y) {
    run_lm(df, y, c(x, base_controls), x)
  })) %>%
  select(res) %>%
  unnest(res)

cat("\n=== Table 2 (FF3) single-position regressions ===\n")
print(table2_ff3)

write.csv(table2_ff3, file.path(out_dir, "r4_ff3_table2_position.csv"), row.names = FALSE)

# ---- Step 2: Table 3 bundle core rows, FF3 outcomes ----
table3_ff3 <- crossing(variable = bundle_vars, outcome = ff3_outcomes) %>%
  mutate(res = map2(variable, outcome, function(x, y) {
    run_lm(df, y, c(x, base_controls), x)
  })) %>%
  select(res) %>%
  unnest(res)

cat("\n=== Table 3 (FF3) bundle-position regressions ===\n")
print(table3_ff3)

write.csv(table3_ff3, file.path(out_dir, "r4_ff3_table3_bundle.csv"), row.names = FALSE)

# ---- Step 3: Comparison with market-model results, if available ----
mm_table2_path <- "output/paper_plan_core/data/table2_baseline_position.csv"
mm_table3_path <- "output/paper_plan_core/data/table3_bundle_positions.csv"

comparison_lines <- c(
  "# R4: FF3 three-factor model robustness check vs market-model baseline",
  "",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## Scope",
  "",
  "Replicates the Table 2 (single-position) and Table 3 (bundle-position) core",
  "rows from `scripts/analysis/paper_plan_core_outputs.R`, swapping the",
  "market-model CAR outcomes (`car_10/15/20`) for the Fama-French three-factor",
  "model CAR outcomes (`ff3_car_10/15/20`). Same controls",
  "(`size_log_assets, bm_ratio, volatility, momentum, factor(release_year)`),",
  "same clustering (`final_event_id`, CR0), same new-schema relationship",
  "columns. Only the new 8-dim relationship columns",
  "(`upstream_hardware, upstream_cloud, downstream_integrator,",
  "downstream_deployer, downstream_enabler, competitor`) and the bundle vars",
  "derived from them (`upstream_any`, `downstream_any`) plus",
  "`downstream_deployer` (bundle table) were used. Old-schema columns",
  "(`owner, investor, cloud, real_upstream, business_upstream,",
  "real_downstream, business_downstream`) were not referenced.",
  ""
)

mm_available <- file.exists(mm_table2_path) && file.exists(mm_table3_path)

if (mm_available) {
  mm_table2 <- read.csv(mm_table2_path, stringsAsFactors = FALSE, check.names = FALSE)
  mm_table3 <- read.csv(mm_table3_path, stringsAsFactors = FALSE, check.names = FALSE)

  comparison_lines <- c(
    comparison_lines,
    "## Comparison data availability",
    "",
    paste0("Market-model baseline files FOUND: `", mm_table2_path, "`, `", mm_table3_path, "`."),
    "Row-by-row comparison performed below (FF3 vs market-model, matched on",
    "variable + corresponding outcome window, e.g. `ff3_car_20` vs `car_20`).",
    ""
  )

  build_comparison <- function(ff3_tab, mm_tab, var_set, table_label) {
    rows <- list()
    for (v in var_set) {
      for (ff3_y in ff3_outcomes) {
        mm_y <- mm_outcome_map[[ff3_y]]
        ff3_row <- ff3_tab %>% filter(variable == v, outcome == ff3_y)
        mm_row <- mm_tab %>% filter(variable == v, y_var == mm_y)

        if (nrow(ff3_row) == 0 && nrow(mm_row) == 0) next

        rows[[length(rows) + 1]] <- tibble(
          table = table_label,
          variable = v,
          mm_outcome = mm_y,
          ff3_outcome = ff3_y,
          mm_beta_pp = if (nrow(mm_row) > 0) 100 * mm_row$estimate[1] else NA_real_,
          mm_p = if (nrow(mm_row) > 0) mm_row$p.value[1] else NA_real_,
          mm_n = if (nrow(mm_row) > 0) mm_row$n[1] else NA_integer_,
          ff3_beta_pp = if (nrow(ff3_row) > 0) 100 * ff3_row$beta[1] else NA_real_,
          ff3_p = if (nrow(ff3_row) > 0) ff3_row$p[1] else NA_real_,
          ff3_n = if (nrow(ff3_row) > 0) ff3_row$n[1] else NA_integer_,
          mm_sig = if (nrow(mm_row) > 0 && !is.na(mm_row$p.value[1])) mm_row$p.value[1] < 0.10 else NA,
          ff3_sig = if (nrow(ff3_row) > 0 && !is.na(ff3_row$p[1])) ff3_row$p[1] < 0.10 else NA,
          same_sign = if (nrow(mm_row) > 0 && nrow(ff3_row) > 0) {
            sign(mm_row$estimate[1]) == sign(ff3_row$beta[1])
          } else NA
        )
      }
    }
    bind_rows(rows)
  }

  comp_table2 <- build_comparison(table2_ff3, mm_table2, position_vars, "Table 2 (single-position)")
  comp_table3 <- build_comparison(table3_ff3, mm_table3, bundle_vars, "Table 3 (bundle-position)")

  comp_all <- bind_rows(comp_table2, comp_table3)
  write.csv(comp_all, file.path(out_dir, "r4_ff3_vs_marketmodel_comparison.csv"), row.names = FALSE)

  fmt <- function(x, d = 3) ifelse(is.na(x), "NA", formatC(x, format = "f", digits = d))

  comparison_lines <- c(
    comparison_lines,
    "## Row-by-row comparison (full table)",
    "",
    "| Table | Variable | Window | MM beta (pp) | MM p | FF3 beta (pp) | FF3 p | Same sign? | Both sig (p<.10)? |",
    "|---|---|---|---|---|---|---|---|---|"
  )

  for (i in seq_len(nrow(comp_all))) {
    r <- comp_all[i, ]
    both_sig <- if (isTRUE(r$mm_sig) && isTRUE(r$ff3_sig)) "both sig" else
      if (!isTRUE(r$mm_sig) && !isTRUE(r$ff3_sig)) "both n.s." else "DIVERGES"
    comparison_lines <- c(
      comparison_lines,
      paste0(
        "| ", r$table, " | ", r$variable, " | ", r$mm_outcome, " vs ", r$ff3_outcome,
        " | ", fmt(r$mm_beta_pp), " | ", fmt(r$mm_p, 4),
        " | ", fmt(r$ff3_beta_pp), " | ", fmt(r$ff3_p, 4),
        " | ", ifelse(isTRUE(r$same_sign), "yes", "NO"),
        " | ", both_sig, " |"
      )
    )
  }

  # Focused summary on the two headline findings at the 20-day window
  # (dedupe: downstream_deployer appears in both Table 2 and Table 3 bundle set)
  headline <- comp_all %>%
    filter(variable %in% c("upstream_hardware", "downstream_deployer"), ff3_outcome == "ff3_car_20") %>%
    distinct(variable, ff3_outcome, .keep_all = TRUE)

  comparison_lines <- c(
    comparison_lines,
    "",
    "## Focused check: headline findings at CAR[0,+20] / FF3_CAR[0,+20]",
    ""
  )

  for (i in seq_len(nrow(headline))) {
    r <- headline[i, ]
    comparison_lines <- c(
      comparison_lines,
      paste0(
        "- **", r$variable, "**: market-model beta = ", fmt(r$mm_beta_pp), " pp (p = ", fmt(r$mm_p, 4),
        "); FF3 beta = ", fmt(r$ff3_beta_pp), " pp (p = ", fmt(r$ff3_p, 4), "). ",
        "Sign ", ifelse(isTRUE(r$same_sign), "MATCHES", "DOES NOT MATCH"), " across the two risk models. ",
        ifelse(isTRUE(r$mm_sig) && isTRUE(r$ff3_sig), "Both significant at the 10% level.",
          ifelse(!isTRUE(r$mm_sig) && !isTRUE(r$ff3_sig), "Both insignificant at the 10% level.",
            "Significance status DIVERGES between the two models."))
      )
    )
  }

  n_diverge <- sum(!comp_all$same_sign, na.rm = TRUE)
  n_total <- sum(!is.na(comp_all$same_sign))

  comparison_lines <- c(
    comparison_lines,
    "",
    "## Overall summary",
    "",
    paste0(
      "Across all ", n_total, " matched variable x window rows (Table 2 + Table 3 combined), ",
      n_diverge, " row(s) show a sign flip between market-model and FF3 risk adjustment."
    )
  )

} else {
  comparison_lines <- c(
    comparison_lines,
    "## Comparison data availability",
    "",
    paste0(
      "Market-model baseline file(s) NOT FOUND at `", mm_table2_path, "` and/or `",
      mm_table3_path, "`. Per task scope, R4 does NOT re-run the market-model",
      " script itself. Reporting FF3 numbers standalone below."
    ),
    "",
    "## FF3 Table 2 (single-position) results",
    "",
    "| Variable | Outcome | Beta (pp) | SE (pp) | p | N | N events |",
    "|---|---|---|---|---|---|---|"
  )
  for (i in seq_len(nrow(table2_ff3))) {
    r <- table2_ff3[i, ]
    comparison_lines <- c(
      comparison_lines,
      paste0(
        "| ", r$variable, " | ", r$outcome, " | ", round(100 * r$beta, 3), " | ",
        round(100 * r$se, 3), " | ", round(r$p, 4), " | ", r$n, " | ", r$n_events, " |"
      )
    )
  }
  comparison_lines <- c(
    comparison_lines,
    "",
    "## FF3 Table 3 (bundle-position) results",
    "",
    "| Variable | Outcome | Beta (pp) | SE (pp) | p | N | N events |",
    "|---|---|---|---|---|---|---|"
  )
  for (i in seq_len(nrow(table3_ff3))) {
    r <- table3_ff3[i, ]
    comparison_lines <- c(
      comparison_lines,
      paste0(
        "| ", r$variable, " | ", r$outcome, " | ", round(100 * r$beta, 3), " | ",
        round(100 * r$se, 3), " | ", round(r$p, 4), " | ", r$n, " | ", r$n_events, " |"
      )
    )
  }
}

writeLines(comparison_lines, file.path(out_dir, "r4_ff3_comparison.md"), useBytes = TRUE)

cat("\nDone. Outputs written to:", out_dir, "\n")
