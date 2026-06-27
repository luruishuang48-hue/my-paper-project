#!/usr/bin/env Rscript

# R8: Code-model interaction, listed-vs-unlisted creator interaction, and a
# joint open-weight x Chinese-origin model. Replicates the exact spec of
# scripts/analysis/paper_plan_core_outputs.R (lm_robust, CR0, clustered by
# final_event_id, base_controls). Also regenerates figure3/figure4 in the
# ggplot style of figure1/figure2.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(broom)
  library(estimatr)
  library(ggplot2)
})

input_file <- "data/panel/specr_rel_clean.csv"
out_dir <- "agent_tasks/paper_b_robustness_2026062514/outputs"
figure_dir <- "output/paper_plan_core/figures"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

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

names(df)[names(df) == "是否包含代码模型"] <- "is_code_model"
df$is_code_model <- suppressWarnings(as.numeric(df$is_code_model))
df$is_code_model[is.na(df$is_code_model)] <- 0

df$is_listed <- as.integer(df$creator_type %in% c("listed_us_company", "public_non_us_company"))

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

vars_to_run <- c("upstream_hardware", "upstream_any", "downstream_deployer")
vars_to_run_origin <- c("upstream_hardware", "upstream_any", "downstream_any")

## (a) Code model interaction
table_code <- map_dfr(vars_to_run, ~run_interaction(.x, "is_code_model"))
write_csv(table_code, file.path(out_dir, "r8a_code_model_interaction.csv"))

## (b) Listed-creator interaction
table_listed <- map_dfr(vars_to_run_origin, ~run_interaction(.x, "is_listed"))
write_csv(table_listed, file.path(out_dir, "r8b_creator_type_interaction.csv"))

## (c) Joint open-weight x Chinese-origin model
run_joint_open_origin <- function(x, y = "car_20") {
  rhs <- c(
    paste0(x, " * is_open_weight"),
    paste0(x, " * is_chinese_model"),
    base_controls
  )
  rhs_plain <- c(x, "is_open_weight", "is_chinese_model", firm_controls)
  d <- model_data(df, y, rhs_plain)
  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) return(tibble())

  mod <- lm_robust(safe_formula(y, rhs), data = d, clusters = d$final_event_id, se_type = "CR0")

  open_term <- paste0(x, ":is_open_weight")
  if (!open_term %in% names(coef(mod))) open_term <- paste0("is_open_weight:", x)
  china_term <- paste0(x, ":is_chinese_model")
  if (!china_term %in% names(coef(mod))) china_term <- paste0("is_chinese_model:", x)

  terms_keep <- c(x, "is_open_weight", "is_chinese_model", open_term, china_term)
  tidy(mod, conf.int = TRUE) %>%
    filter(term %in% terms_keep) %>%
    mutate(variable = x, variable_label = unname(label_map[x]), y_var = y,
           n = nobs(mod), n_events = n_distinct(d$final_event_id))
}

table_joint <- map_dfr(c("upstream_hardware", "upstream_any"), run_joint_open_origin)
write_csv(table_joint, file.path(out_dir, "r8c_joint_open_origin_model.csv"))

cat("=== Code model interaction (car_20) ===\n")
print(table_code %>% select(variable, term, estimate, std.error, p.value, n, n_events))
cat("\n=== Listed-creator interaction (car_20) ===\n")
print(table_listed %>% select(variable, term, estimate, std.error, p.value, n, n_events))
cat("\n=== Joint open x origin model (car_20) ===\n")
print(table_joint %>% select(variable, term, estimate, std.error, p.value, n, n_events))

## ---- Figures ----

reasoning_csv <- file.path(out_dir, "r7a_reasoning_model_interaction.csv")
origin_csv <- file.path(out_dir, "r7c_chinese_model_interaction.csv")

table_reasoning <- read_csv(reasoning_csv, show_col_types = FALSE)
table_origin <- read_csv(origin_csv, show_col_types = FALSE)

pos_levels <- c("Downstream deployer", "Any upstream", "Upstream hardware")

prep_facet <- function(data, level0_label, level1_label, facet_label, keep_vars) {
  data %>%
    filter(term %in% c("Baseline (mod=0)", "Mod=1"), variable_label %in% keep_vars) %>%
    mutate(
      group = ifelse(term == "Baseline (mod=0)", level0_label, level1_label),
      group_role = ifelse(term == "Baseline (mod=0)", "level0", "level1"),
      facet = facet_label,
      variable_label = factor(variable_label, levels = pos_levels),
      estimate_pp = 100 * estimate,
      conf.low_pp = 100 * conf.low,
      conf.high_pp = 100 * conf.high
    )
}

plot_reasoning <- prep_facet(table_reasoning, "Non-reasoning", "Reasoning", "Reasoning model", pos_levels)
plot_code <- prep_facet(table_code, "Non-code", "Code model", "Code model", pos_levels)
plot_data_3 <- bind_rows(plot_reasoning, plot_code) %>%
  mutate(
    facet = factor(facet, levels = c("Reasoning model", "Code model")),
    group_role = factor(group_role, levels = c("level0", "level1"),
                         labels = c("Baseline (mod = 0)", "Treated (mod = 1)"))
  )

p3 <- ggplot(plot_data_3, aes(x = estimate_pp, y = variable_label, color = group_role)) +
  geom_vline(xintercept = 0, linewidth = 0.4, linetype = "dashed", color = "gray45") +
  geom_errorbar(
    aes(xmin = conf.low_pp, xmax = conf.high_pp),
    orientation = "y", width = 0, linewidth = 0.65,
    position = position_dodge(width = 0.55)
  ) +
  geom_point(size = 2.4, position = position_dodge(width = 0.55)) +
  scale_color_manual(values = c(
    "Baseline (mod = 0)" = "#1f5a85", "Treated (mod = 1)" = "#8b2f2f"
  )) +
  facet_wrap(~facet) +
  labs(x = "CAR[0,+20] effect, percentage points", y = NULL, color = NULL,
       title = "Reasoning- and code-model releases") +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave(file.path(figure_dir, "figure3_reasoning_code_effects.pdf"), p3, width = 9, height = 4.5)
ggsave(file.path(figure_dir, "figure3_reasoning_code_effects.png"), p3, width = 9, height = 4.5, dpi = 300)

pos_levels_origin <- c("Any downstream", "Any upstream", "Upstream hardware")

prep_facet_origin <- function(data, level0_label, level1_label, facet_label, keep_vars) {
  data %>%
    filter(term %in% c("Baseline (mod=0)", "Mod=1"), variable_label %in% keep_vars) %>%
    mutate(
      group_role = ifelse(term == "Baseline (mod=0)", "level0", "level1"),
      facet = facet_label,
      variable_label = factor(variable_label, levels = pos_levels_origin),
      estimate_pp = 100 * estimate,
      conf.low_pp = 100 * conf.low,
      conf.high_pp = 100 * conf.high
    )
}

plot_origin <- prep_facet_origin(table_origin, "Non-Chinese", "Chinese", "Model origin: China", pos_levels_origin)
plot_listed <- prep_facet_origin(table_listed, "Unlisted creator", "Listed creator", "Creator listing status", pos_levels_origin)
plot_data_4 <- bind_rows(plot_origin, plot_listed) %>%
  mutate(
    facet = factor(facet, levels = c("Model origin: China", "Creator listing status")),
    group_role = factor(group_role, levels = c("level0", "level1"),
                         labels = c("Baseline (mod = 0)", "Treated (mod = 1)"))
  )

p4 <- ggplot(plot_data_4, aes(x = estimate_pp, y = variable_label, color = group_role)) +
  geom_vline(xintercept = 0, linewidth = 0.4, linetype = "dashed", color = "gray45") +
  geom_errorbar(
    aes(xmin = conf.low_pp, xmax = conf.high_pp),
    orientation = "y", width = 0, linewidth = 0.65,
    position = position_dodge(width = 0.55)
  ) +
  geom_point(size = 2.4, position = position_dodge(width = 0.55)) +
  scale_color_manual(values = c(
    "Baseline (mod = 0)" = "#1f5a85", "Treated (mod = 1)" = "#8b2f2f"
  )) +
  facet_wrap(~facet) +
  labs(x = "CAR[0,+20] effect, percentage points", y = NULL, color = NULL,
       title = "Releases by model origin and creator listing status") +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave(file.path(figure_dir, "figure4_origin_effects.pdf"), p4, width = 9, height = 4.5)
ggsave(file.path(figure_dir, "figure4_origin_effects.png"), p4, width = 9, height = 4.5, dpi = 300)

cat("\nFigures written to", figure_dir, "\n")
