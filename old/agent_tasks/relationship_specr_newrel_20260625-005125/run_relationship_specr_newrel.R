#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(stringr)
  library(broom)
  library(estimatr)
})

task_dir <- "agent_tasks/relationship_specr_newrel_20260625-005125"
input_file <- "data/panel/specr_rel_clean.csv"

df <- read_csv(input_file, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year", "trend_month",
  "car_1", "car_2", "car_3", "car_5", "car_10", "car_15", "car_20",
  "ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_5", "ff3_car_10",
  "ff3_car_15", "ff3_car_20",
  "aa_intelligence_index", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "is_open_weight", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  if (!col %in% names(df)) stop(paste("Missing relationship variable:", col))
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

df <- df %>%
  mutate(
    upstream_any = as.integer(upstream_hardware == 1 | upstream_cloud == 1),
    downstream_any = as.integer(
      downstream_integrator == 1 |
        downstream_deployer == 1 |
        downstream_enabler == 1
    ),
    strategic_any = as.integer(
      upstream_hardware == 1 |
        upstream_cloud == 1 |
        is_investor == 1 |
        is_owner == 1
    ),
    appropriable_any = as.integer(
      upstream_hardware == 1 |
        upstream_cloud == 1 |
        downstream_integrator == 1 |
        downstream_enabler == 1 |
        is_investor == 1 |
        is_owner == 1
    ),
    non_ai_deployer_only = as.integer(
      downstream_deployer == 1 &
        upstream_hardware == 0 &
        upstream_cloud == 0 &
        downstream_integrator == 0 &
        downstream_enabler == 0 &
        competitor == 0 &
        is_investor == 0 &
        is_owner == 0
    ),
    any_relationship = as.integer(
      upstream_hardware == 1 |
        upstream_cloud == 1 |
        downstream_integrator == 1 |
        downstream_deployer == 1 |
        downstream_enabler == 1 |
        competitor == 1 |
        is_investor == 1 |
        is_owner == 1
    ),
    intel_c = aa_intelligence_index - mean(aa_intelligence_index, na.rm = TRUE)
  )

bundle_vars <- c(
  "upstream_any", "downstream_any", "strategic_any",
  "appropriable_any", "non_ai_deployer_only", "any_relationship"
)

all_rel_vars <- c(rel_vars, bundle_vars)

outcomes_market <- c("car_1", "car_2", "car_3", "car_10", "car_15", "car_20")
outcomes_ff3 <- c("ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_10", "ff3_car_15", "ff3_car_20")
outcome_map <- bind_rows(
  tibble(outcome_model = "market", y_var = outcomes_market),
  tibble(outcome_model = "ff3", y_var = outcomes_ff3)
) %>%
  filter(y_var %in% names(df))

control_sets <- list(
  none = character(0),
  firm = c("size_log_assets", "bm_ratio", "volatility", "momentum"),
  firm_year = c("size_log_assets", "bm_ratio", "volatility", "momentum", "factor(release_year)"),
  firm_year_intel = c(
    "size_log_assets", "bm_ratio", "volatility", "momentum",
    "aa_intelligence_index", "factor(release_year)"
  )
)

interaction_control_sets <- list(
  none = character(0),
  firm_year = c("size_log_assets", "bm_ratio", "volatility", "momentum", "factor(release_year)")
)

MIN_OBS <- 20
MIN_EVENTS <- 5
MIN_TREATED <- 20

stars <- function(p) {
  ifelse(is.na(p), "",
    ifelse(p < 0.01, "***",
      ifelse(p < 0.05, "**",
        ifelse(p < 0.10, "*", "")
      )
    )
  )
}

safe_formula <- function(y, rhs_parts) {
  as.formula(paste(y, "~", paste(rhs_parts, collapse = " + ")))
}

fit_extract <- function(data, formula_obj, terms, family, spec_label, x_var, y_var,
                        outcome_model, controls, extra = list()) {
  data <- data %>%
    filter(!is.na(.data[[y_var]]), !is.na(final_event_id))
  if (nrow(data) < MIN_OBS) return(NULL)
  n_events <- n_distinct(data$final_event_id)
  if (n_events < MIN_EVENTS) return(NULL)

  mod <- tryCatch(
    lm_robust(formula_obj, data = data, clusters = data$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
  if (is.null(mod)) return(NULL)

  td <- tryCatch(tidy(mod, conf.int = TRUE), error = function(e) NULL)
  if (is.null(td)) return(NULL)

  keep <- td %>% filter(term %in% terms)
  if (nrow(keep) == 0) return(NULL)

  treated_n <- if (!is.null(x_var) && x_var %in% names(data)) sum(data[[x_var]] == 1, na.rm = TRUE) else NA_integer_
  untreated_n <- if (!is.null(x_var) && x_var %in% names(data)) sum(data[[x_var]] == 0, na.rm = TRUE) else NA_integer_
  treated_events <- if (!is.null(x_var) && x_var %in% names(data)) n_distinct(data$final_event_id[data[[x_var]] == 1]) else NA_integer_
  untreated_events <- if (!is.null(x_var) && x_var %in% names(data)) n_distinct(data$final_event_id[data[[x_var]] == 0]) else NA_integer_
  mean_y_treated <- if (!is.null(x_var) && x_var %in% names(data) && treated_n > 0) mean(data[[y_var]][data[[x_var]] == 1], na.rm = TRUE) else NA_real_
  mean_y_untreated <- if (!is.null(x_var) && x_var %in% names(data) && untreated_n > 0) mean(data[[y_var]][data[[x_var]] == 0], na.rm = TRUE) else NA_real_

  out <- keep %>%
    mutate(
      family = family,
      spec_label = spec_label,
      x_var = ifelse(is.null(x_var), NA_character_, x_var),
      y_var = y_var,
      outcome_model = outcome_model,
      controls = controls,
      n = nobs(mod),
      n_events = n_events,
      treated_n = treated_n,
      untreated_n = untreated_n,
      treated_events = treated_events,
      untreated_events = untreated_events,
      mean_y_treated = mean_y_treated,
      mean_y_untreated = mean_y_untreated,
      r_squared = summary(mod)$r.squared
    )

  if (length(extra) > 0) {
    out <- out %>% bind_cols(as_tibble(extra))
  }

  out
}

records <- list()
idx <- 0L

add_record <- function(res) {
  if (!is.null(res) && nrow(res) > 0) {
    idx <<- idx + 1L
    records[[idx]] <<- res
  }
}

for (x in all_rel_vars) {
  treated_total <- sum(df[[x]] == 1, na.rm = TRUE)
  if (treated_total < MIN_TREATED) next

  for (row_i in seq_len(nrow(outcome_map))) {
    y <- outcome_map$y_var[row_i]
    om <- outcome_map$outcome_model[row_i]

    for (ctrl_name in names(control_sets)) {
      ctrl <- control_sets[[ctrl_name]]
      rhs <- c(x, ctrl)
      fml <- safe_formula(y, rhs)
      d <- df %>% filter(!is.na(.data[[y]]))
      res <- fit_extract(
        d, fml, x, "main_effect_single", "single_flag", x, y, om, ctrl_name
      )
      add_record(res)
    }
  }
}

for (x in all_rel_vars) {
  treated_total <- sum(df[[x]] == 1, na.rm = TRUE)
  if (treated_total < MIN_TREATED) next

  for (row_i in seq_len(nrow(outcome_map))) {
    y <- outcome_map$y_var[row_i]
    om <- outcome_map$outcome_model[row_i]

    for (ctrl_name in names(interaction_control_sets)) {
      ctrl <- interaction_control_sets[[ctrl_name]]
      rhs <- c(paste0("intel_c * ", x), ctrl)
      fml <- safe_formula(y, rhs)
      d <- df %>%
        filter(!is.na(.data[[y]]), !is.na(intel_c), !is.na(.data[[x]]))
      term <- paste0("intel_c:", x)
      res <- fit_extract(
        d, fml, c("intel_c", x, term), "interaction_intel_by_relation",
        "intel_x_relation", x, y, om, ctrl_name
      )
      add_record(res)
    }
  }
}

for (x in all_rel_vars) {
  treated_total <- sum(df[[x]] == 1, na.rm = TRUE)
  if (treated_total < MIN_TREATED) next

  for (row_i in seq_len(nrow(outcome_map))) {
    y <- outcome_map$y_var[row_i]
    om <- outcome_map$outcome_model[row_i]

    for (ctrl_name in c("none", "firm_year")) {
      ctrl <- if (ctrl_name == "none") character(0) else c(
        "size_log_assets", "bm_ratio", "volatility", "momentum",
        "factor(release_year)"
      )
      rhs <- c("aa_intelligence_index", ctrl)
      fml <- safe_formula(y, rhs)
      d <- df %>%
        filter(.data[[x]] == 1, !is.na(aa_intelligence_index), !is.na(.data[[y]]))
      res <- fit_extract(
        d, fml, "aa_intelligence_index", "capability_slope_in_relation_subsample",
        "subsample_flag_eq_1", x, y, om, ctrl_name,
        extra = list(subsample_flag = x)
      )
      add_record(res)
    }
  }
}

joint_specs <- list(
  joint_all_eight = list(
    vars = rel_vars,
    terms = rel_vars
  ),
  joint_bundles = list(
    vars = c("upstream_any", "downstream_any", "competitor", "is_investor", "is_owner"),
    terms = c("upstream_any", "downstream_any", "competitor", "is_investor", "is_owner")
  ),
  upstream_hardware_vs_cloud = list(
    vars = c("upstream_hardware", "upstream_cloud"),
    terms = c("upstream_hardware", "upstream_cloud")
  ),
  downstream_three_way = list(
    vars = c("downstream_integrator", "downstream_deployer", "downstream_enabler"),
    terms = c("downstream_integrator", "downstream_deployer", "downstream_enabler")
  )
)

for (spec_name in names(joint_specs)) {
  vars <- joint_specs[[spec_name]]$vars
  terms <- joint_specs[[spec_name]]$terms

  for (row_i in seq_len(nrow(outcome_map))) {
    y <- outcome_map$y_var[row_i]
    om <- outcome_map$outcome_model[row_i]

    for (ctrl_name in c("none", "firm_year_intel")) {
      ctrl <- control_sets[[ctrl_name]]
      rhs <- c(vars, ctrl)
      fml <- safe_formula(y, rhs)
      d <- df %>% filter(!is.na(.data[[y]]))
      res <- fit_extract(
        d, fml, terms, "joint_relationship_model", spec_name,
        NA_character_, y, om, ctrl_name
      )
      add_record(res)
    }
  }
}

results <- bind_rows(records) %>%
  mutate(
    p.value = as.numeric(p.value),
    estimate = as.numeric(estimate),
    std.error = as.numeric(std.error),
    conf.low = as.numeric(conf.low),
    conf.high = as.numeric(conf.high),
    stars = stars(p.value),
    significant_05 = p.value < 0.05,
    significant_10 = p.value < 0.10,
    sign = case_when(
      estimate > 0 ~ "positive",
      estimate < 0 ~ "negative",
      TRUE ~ "zero"
    ),
    is_long_window = y_var %in% c("car_10", "car_15", "car_20", "ff3_car_10", "ff3_car_15", "ff3_car_20"),
    is_primary_window = y_var %in% c("car_20", "ff3_car_20")
  ) %>%
  select(
    family, spec_label, term, x_var, y_var, outcome_model, controls,
    estimate, std.error, statistic, p.value, conf.low, conf.high, stars,
    significant_05, significant_10, sign, n, n_events, treated_n,
    untreated_n, treated_events, untreated_events, mean_y_treated,
    mean_y_untreated, r_squared, everything()
  )

write_csv(results, file.path(task_dir, "relationship_specr_newrel_all.csv"))

summary_tbl <- results %>%
  group_by(family, spec_label, term, x_var, outcome_model) %>%
  summarise(
    n_specs = n(),
    n_sig_05 = sum(significant_05, na.rm = TRUE),
    pct_sig_05 = round(100 * mean(significant_05, na.rm = TRUE), 1),
    n_sig_10 = sum(significant_10, na.rm = TRUE),
    pct_sig_10 = round(100 * mean(significant_10, na.rm = TRUE), 1),
    pct_positive = round(100 * mean(estimate > 0, na.rm = TRUE), 1),
    median_est = median(estimate, na.rm = TRUE),
    mean_est = mean(estimate, na.rm = TRUE),
    min_p = min(p.value, na.rm = TRUE),
    primary_car20_est = estimate[
      match(TRUE, y_var == "car_20" & controls %in% c("firm_year_intel", "firm_year"))
    ],
    .groups = "drop"
  ) %>%
  arrange(family, min_p)

write_csv(summary_tbl, file.path(task_dir, "relationship_specr_newrel_summary.csv"))

screen_base <- results %>%
  filter(
    p.value < 0.10,
    n_events >= 8,
    is_long_window,
    outcome_model == "market"
  ) %>%
  arrange(p.value, desc(abs(estimate)))

main_screen <- screen_base %>%
  filter(family %in% c("main_effect_single", "joint_relationship_model")) %>%
  select(family, spec_label, term, x_var, y_var, controls, estimate, std.error,
         p.value, stars, n, n_events, treated_n, treated_events,
         mean_y_treated, mean_y_untreated) %>%
  arrange(p.value)

interaction_screen <- screen_base %>%
  filter(family == "interaction_intel_by_relation", str_detect(term, "intel_c:")) %>%
  select(family, term, x_var, y_var, controls, estimate, std.error, p.value,
         stars, n, n_events, treated_n, treated_events) %>%
  arrange(p.value)

subsample_screen <- screen_base %>%
  filter(family == "capability_slope_in_relation_subsample") %>%
  select(family, term, x_var, y_var, controls, estimate, std.error, p.value,
         stars, n, n_events, treated_n, treated_events) %>%
  arrange(p.value)

contrast_screen <- screen_base %>%
  filter(family == "joint_relationship_model") %>%
  select(family, spec_label, term, y_var, controls, estimate, std.error, p.value,
         stars, n, n_events) %>%
  arrange(p.value)

write_csv(main_screen, file.path(task_dir, "relationship_main_effect_screen.csv"))
write_csv(interaction_screen, file.path(task_dir, "relationship_interaction_screen.csv"))
write_csv(subsample_screen, file.path(task_dir, "relationship_subsample_screen.csv"))
write_csv(contrast_screen, file.path(task_dir, "relationship_contrast_screen.csv"))

sample_counts <- map_dfr(all_rel_vars, function(x) {
  tibble(
    variable = x,
    n_1 = sum(df[[x]] == 1, na.rm = TRUE),
    n_0 = sum(df[[x]] == 0, na.rm = TRUE),
    events_1 = n_distinct(df$final_event_id[df[[x]] == 1]),
    events_0 = n_distinct(df$final_event_id[df[[x]] == 0]),
    car20_nonmissing_1 = sum(df[[x]] == 1 & !is.na(df$car_20), na.rm = TRUE),
    intel_nonmissing_1 = sum(df[[x]] == 1 & !is.na(df$aa_intelligence_index), na.rm = TRUE),
    mean_car20_1 = mean(df$car_20[df[[x]] == 1], na.rm = TRUE),
    mean_car20_0 = mean(df$car_20[df[[x]] == 0], na.rm = TRUE)
  )
}) %>%
  arrange(desc(n_1))

write_csv(sample_counts, file.path(task_dir, "sample_overlap_report.csv"))

fmt_num <- function(x, digits = 4) {
  ifelse(is.na(x), "", formatC(x, format = "f", digits = digits))
}

top_md_table <- function(tbl, n = 12) {
  if (nrow(tbl) == 0) return("_No screened rows._\n")
  out <- tbl %>% head(n)
  if ("estimate" %in% names(out)) out <- out %>% mutate(estimate = fmt_num(estimate, 5))
  if ("std.error" %in% names(out)) out <- out %>% mutate(std.error = fmt_num(std.error, 5))
  if ("p.value" %in% names(out)) out <- out %>% mutate(p.value = signif(p.value, 3))
  out %>% knitr::kable(format = "pipe")
}

md <- c(
  "# Relationship-focused Specr screened results",
  "",
  "Input file: `data/panel/specr_rel_clean.csv`.",
  "",
  "This run screens relationship mechanisms under the new 8-dimension coding. It does not use old `output/data` files or historical result tables.",
  "",
  "## Sample coverage",
  "",
  top_md_table(sample_counts %>% select(variable, n_1, events_1, car20_nonmissing_1, intel_nonmissing_1, mean_car20_1, mean_car20_0), 20),
  "",
  "## Main and joint relationship effects",
  "",
  top_md_table(main_screen, 20),
  "",
  "## Intelligence by relationship interactions",
  "",
  top_md_table(interaction_screen, 20),
  "",
  "## Capability slopes within relationship subsamples",
  "",
  top_md_table(subsample_screen, 20),
  "",
  "## Relationship contrast models",
  "",
  top_md_table(contrast_screen, 20),
  "",
  "## Files",
  "",
  "- `relationship_specr_newrel_all.csv`",
  "- `relationship_specr_newrel_summary.csv`",
  "- `relationship_main_effect_screen.csv`",
  "- `relationship_interaction_screen.csv`",
  "- `relationship_subsample_screen.csv`",
  "- `relationship_contrast_screen.csv`",
  "- `sample_overlap_report.csv`"
)

writeLines(md, file.path(task_dir, "screened_results.md"))

cat("Input:", input_file, "\n")
cat("Rows:", nrow(df), "Cols:", ncol(df), "\n")
cat("All specs:", nrow(results), "\n")
cat("Screened main rows:", nrow(main_screen), "\n")
cat("Screened interaction rows:", nrow(interaction_screen), "\n")
cat("Screened subsample rows:", nrow(subsample_screen), "\n")
cat("Done. Outputs written to", task_dir, "\n")
