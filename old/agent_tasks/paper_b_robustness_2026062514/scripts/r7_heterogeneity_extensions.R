#!/usr/bin/env Rscript

# R7: Three new heterogeneity cuts, replicating the exact spec of
# scripts/analysis/paper_plan_core_outputs.R (lm_robust, CR0, clustered by
# final_event_id, base_controls):
#   (a) reasoning-model interaction (是否包含推理模型)
#   (b) pre- vs post-DeepSeek R1 regime split (release_date < 2025-01-22)
#   (c) Chinese-model-origin interaction (is_chinese_model)

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
  "size_log_assets", "bm_ratio", "volatility",
  "momentum", "is_open_weight", "is_chinese_model", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

names(df)[names(df) == "是否包含推理模型"] <- "is_reasoning_model"
df$is_reasoning_model <- suppressWarnings(as.numeric(df$is_reasoning_model))
df$is_reasoning_model[is.na(df$is_reasoning_model)] <- 0

df$release_date <- as.Date(df$release_date, format = "%Y/%m/%d")
df$post_deepseek <- as.integer(df$release_date >= as.Date("2025-01-22"))

df <- df %>%
  mutate(
    upstream_any = as.integer(upstream_hardware == 1 | upstream_cloud == 1),
    downstream_any = as.integer(
      downstream_integrator == 1 | downstream_deployer == 1 | downstream_enabler == 1
    )
  )

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "factor(release_year)")

label_map <- c(
  upstream_hardware = "Upstream hardware",
  upstream_any = "Any upstream",
  downstream_any = "Any downstream",
  downstream_deployer = "Downstream deployer"
)

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

  mod <- lm_robust(safe_formula(y, rhs), data = d, clusters = d$final_event_id, se_type = "CR0")

  tidy(mod, conf.int = TRUE) %>%
    filter(term %in% terms) %>%
    mutate(y_var = y, n = nobs(mod), n_events = n_distinct(d$final_event_id))
}

linear_combo <- function(mod, terms, weights) {
  b <- coef(mod)
  v <- vcov(mod)
  common <- intersect(names(weights), names(b))
  w <- weights[common]
  est <- sum(w * b[common])
  vv <- v[common, common, drop = FALSE]
  se <- sqrt(as.numeric(t(w) %*% vv %*% w))
  p <- 2 * pnorm(abs(est / se), lower.tail = FALSE)
  tibble(term = terms, estimate = est, std.error = se, p.value = p,
         conf.low = est - 1.96 * se, conf.high = est + 1.96 * se)
}

run_interaction <- function(x, mod_var, y = "car_20") {
  rhs <- c(paste0(x, " * ", mod_var), base_controls)
  rhs_plain <- c(x, mod_var, firm_controls)
  d <- model_data(df, y, rhs_plain)
  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) return(tibble())

  mod <- lm_robust(safe_formula(y, rhs), data = d, clusters = d$final_event_id, se_type = "CR0")

  interaction_term <- paste0(x, ":", mod_var)
  if (!interaction_term %in% names(coef(mod))) {
    interaction_term <- paste0(mod_var, ":", x)
  }

  level0 <- linear_combo(mod, "Baseline (mod=0)", c(setNames(1, x)))
  level1 <- linear_combo(mod, "Mod=1", c(setNames(1, x), setNames(1, interaction_term)))
  diff <- linear_combo(mod, "Interaction (mod=1 minus mod=0)", c(setNames(1, interaction_term)))

  bind_rows(level0, level1, diff) %>%
    mutate(variable = x, variable_label = unname(label_map[x]), y_var = y,
           n = nobs(mod), n_events = n_distinct(d$final_event_id), moderator = mod_var)
}

vars_to_run <- c("upstream_hardware", "upstream_any", "downstream_any", "downstream_deployer")

## (a) Reasoning-model interaction
table_reasoning <- map_dfr(vars_to_run, ~run_interaction(.x, "is_reasoning_model"))
write_csv(table_reasoning, file.path(out_dir, "r7a_reasoning_model_interaction.csv"))

## (b) Pre/post-DeepSeek regime split
run_subsample <- function(x, y, sub_filter_val) {
  d_sub <- df %>% filter(post_deepseek == sub_filter_val)
  rhs <- if (n_distinct(d_sub$release_year) > 1) c(x, base_controls) else c(x, firm_controls)
  run_lm(d_sub, y, rhs, x) %>%
    mutate(variable = x, variable_label = unname(label_map[x]), regime = ifelse(sub_filter_val == 1, "post_deepseek", "pre_deepseek"))
}

table_regime <- map_dfr(vars_to_run, function(x) {
  bind_rows(run_subsample(x, "car_20", 0), run_subsample(x, "car_20", 1))
})
write_csv(table_regime, file.path(out_dir, "r7b_pre_post_deepseek_regime.csv"))

## (c) Chinese-model-origin interaction
table_chinese <- map_dfr(vars_to_run, ~run_interaction(.x, "is_chinese_model"))
write_csv(table_chinese, file.path(out_dir, "r7c_chinese_model_interaction.csv"))

cat("=== Reasoning model interaction (car_20) ===\n")
print(table_reasoning %>% select(variable, term, estimate, std.error, p.value, n, n_events))
cat("\n=== Pre/Post DeepSeek regime split (car_20) ===\n")
print(table_regime %>% select(variable, regime, estimate, std.error, p.value, n, n_events))
cat("\n=== Chinese-model interaction (car_20) ===\n")
print(table_chinese %>% select(variable, term, estimate, std.error, p.value, n, n_events))
