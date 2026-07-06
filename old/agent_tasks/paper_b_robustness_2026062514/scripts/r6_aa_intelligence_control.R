#!/usr/bin/env Rscript

# R6: Position effects controlling for AA Intelligence Index.
# Replicates the exact spec of scripts/analysis/paper_plan_core_outputs.R
# (lm_robust, CR0, clustered by final_event_id, base_controls), adding
# aa_intelligence_index as an additional control. AA coverage is 47 events.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(broom)
  library(estimatr)
})

input_file <- "data/panel/specr_rel_clean.csv"
out_dir <- "agent_tasks/paper_b_robustness_2026062514/outputs"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(input_file, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year", "car_1", "car_10", "car_15", "car_20",
  "aa_intelligence_index", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "is_open_weight", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

df <- df %>%
  mutate(
    upstream_any = as.integer(upstream_hardware == 1 | upstream_cloud == 1),
    downstream_any = as.integer(
      downstream_integrator == 1 | downstream_deployer == 1 | downstream_enabler == 1
    )
  )

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "factor(release_year)", "aa_intelligence_index")

label_map <- c(
  upstream_hardware = "Upstream hardware",
  upstream_any = "Any upstream",
  downstream_any = "Any downstream",
  downstream_deployer = "Downstream deployer"
)

outcome_map <- c(car_10 = "CAR[0,+10]", car_15 = "CAR[0,+15]", car_20 = "CAR[0,+20]")

safe_formula <- function(y, rhs) as.formula(paste(y, "~", paste(rhs, collapse = " + ")))

model_data <- function(data, y, rhs_vars) {
  needed <- unique(c(y, "final_event_id", rhs_vars))
  needed <- needed[!grepl("^factor\\(", needed)]
  needed <- needed[needed %in% names(data)]

  out <- data %>% filter(!is.na(.data[[y]]), !is.na(final_event_id))
  for (v in setdiff(needed, c(y, "final_event_id"))) {
    out <- out %>% filter(!is.na(.data[[v]]))
  }
  out
}

run_lm <- function(data, y, rhs, terms) {
  rhs_plain <- rhs[!grepl("^factor\\(", rhs)]
  d <- model_data(data, y, rhs_plain)

  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) return(tibble())

  mod <- lm_robust(
    safe_formula(y, rhs),
    data = d,
    clusters = d$final_event_id,
    se_type = "CR0"
  )

  tidy(mod, conf.int = TRUE) %>%
    filter(term %in% terms) %>%
    mutate(
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id)
    )
}

run_position <- function(x, y) {
  run_lm(df, y, c(x, base_controls), x) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      outcome_label = unname(outcome_map[y])
    )
}

vars_to_run <- c("upstream_hardware", "upstream_any", "downstream_any", "downstream_deployer")

table5_aa_control <- crossing(variable = vars_to_run, y_var = names(outcome_map)) %>%
  mutate(res = map2(variable, y_var, run_position)) %>%
  select(res) %>%
  unnest(res)

write_csv(table5_aa_control, file.path(out_dir, "r6_aa_intelligence_control.csv"))

cat("Done. n events with AA coverage:\n")
cat(n_distinct(df$final_event_id[!is.na(df$aa_intelligence_index)]), "\n")
print(table5_aa_control %>% select(variable, y_var, estimate, std.error, p.value, n, n_events))
