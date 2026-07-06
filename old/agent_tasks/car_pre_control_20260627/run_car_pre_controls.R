#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(broom)
  library(estimatr)
})

input_file <- "data/panel/specr_rel_clean.csv"
out_dir <- "agent_tasks/car_pre_control_20260627/outputs"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(input_file, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

names(df)[names(df) == "FF3异常收益[-10,-2]"] <- "ff3_car_pre"
names(df)[names(df) == "是否包含推理模型"] <- "is_reasoning_model"
names(df)[names(df) == "是否包含代码模型"] <- "is_code_model"
names(df)[names(df) == "媒体态度均值(20,20)"] <- "media_sentiment_20"

num_cols <- c(
  "release_year", "car_pre", "car_1", "car_2", "car_3", "car_5",
  "car_10", "car_15", "car_20", "ff3_car_pre", "ff3_car_1",
  "ff3_car_2", "ff3_car_3", "ff3_car_5", "ff3_car_10",
  "ff3_car_15", "ff3_car_20", "aa_intelligence_index",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "is_open_weight", "is_chinese_model", "is_reasoning_model",
  "is_code_model", "media_sentiment_20", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  if (!col %in% names(df)) stop(paste("Missing relationship variable:", col))
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

df$is_reasoning_model[is.na(df$is_reasoning_model)] <- 0
df$is_code_model[is.na(df$is_code_model)] <- 0

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
    is_listed = as.integer(creator_type %in% c(
      "listed_us_company", "public_non_us", "public_non_us_company",
      "listed_non_us_company"
    ))
  )

media_mu <- mean(df$media_sentiment_20, na.rm = TRUE)
media_sd <- sd(df$media_sentiment_20, na.rm = TRUE)
df$media_sentiment_z <- (df$media_sentiment_20 - media_mu) / media_sd

position_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor"
)

bundle_vars <- c(
  "upstream_any", "strategic_any", "downstream_any", "downstream_deployer"
)

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "car_pre", "factor(release_year)")
aa_controls <- c(firm_controls, "car_pre", "factor(release_year)", "aa_intelligence_index")

label_map <- c(
  upstream_hardware = "Upstream hardware",
  upstream_cloud = "Upstream cloud",
  downstream_integrator = "Downstream integrator",
  downstream_deployer = "Downstream deployer",
  downstream_enabler = "Downstream enabler",
  competitor = "Direct competitor",
  upstream_any = "Any upstream",
  strategic_any = "Strategic/upstream",
  downstream_any = "Any downstream"
)

outcome_map <- c(
  car_10 = "CAR[0,+10]",
  car_15 = "CAR[0,+15]",
  car_20 = "CAR[0,+20]"
)

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

run_lm <- function(data, y, rhs, terms) {
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
    filter(term %in% terms) %>%
    mutate(
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      r_squared = summary(mod)$r.squared,
      estimate_pp = 100 * estimate,
      se_pp = 100 * std.error,
      conf.low_pp = 100 * conf.low,
      conf.high_pp = 100 * conf.high
    )
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
  tibble(
    term = terms,
    estimate = est,
    std.error = se,
    p.value = p,
    conf.low = est - 1.96 * se,
    conf.high = est + 1.96 * se,
    estimate_pp = 100 * est,
    se_pp = 100 * se,
    conf.low_pp = 100 * (est - 1.96 * se),
    conf.high_pp = 100 * (est + 1.96 * se)
  )
}

run_single_position <- function(x, y) {
  run_lm(df, y, c(x, base_controls), x) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      outcome_label = unname(outcome_map[y]),
      table_family = "single_position_car_pre"
    )
}

table_baseline <- crossing(variable = position_vars, y_var = names(outcome_map)) %>%
  mutate(res = map2(variable, y_var, run_single_position)) %>%
  select(res) %>%
  unnest(res)

run_bundle <- function(x, y) {
  run_lm(df, y, c(x, base_controls), x) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      outcome_label = unname(outcome_map[y]),
      table_family = "bundle_position_car_pre"
    )
}

table_bundle <- crossing(variable = bundle_vars, y_var = names(outcome_map)) %>%
  mutate(res = map2(variable, y_var, run_bundle)) %>%
  select(res) %>%
  unnest(res)

run_joint_positions <- function(y) {
  run_lm(df, y, c(position_vars, base_controls), position_vars) %>%
    mutate(
      variable = term,
      variable_label = unname(label_map[term]),
      outcome_label = unname(outcome_map[y]),
      table_family = "joint_positions_car_pre"
    )
}

table_joint <- map_dfr(names(outcome_map), run_joint_positions)

run_open_interaction <- function(x, y = "car_20") {
  rhs <- c(paste0(x, " * is_open_weight"), base_controls)
  rhs_plain <- c(x, "is_open_weight", firm_controls, "car_pre")
  d <- model_data(df, y, rhs_plain)
  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) return(tibble())

  mod <- lm_robust(
    safe_formula(y, rhs),
    data = d,
    clusters = d$final_event_id,
    se_type = "CR0"
  )

  interaction_term <- paste0(x, ":is_open_weight")
  if (!interaction_term %in% names(coef(mod))) {
    interaction_term <- paste0("is_open_weight:", x)
  }

  closed <- linear_combo(mod, "Closed/proprietary", c(setNames(1, x)))
  open <- linear_combo(mod, "Open-weight", c(setNames(1, x), setNames(1, interaction_term)))
  diff <- linear_combo(mod, "Open minus closed", c(setNames(1, interaction_term)))

  bind_rows(closed, open, diff) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      y_var = y,
      outcome_label = unname(outcome_map[y]),
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      table_family = "open_interaction_car_pre"
    )
}

table_open <- map_dfr(
  c("upstream_hardware", "upstream_cloud", "downstream_deployer", "downstream_enabler", "competitor"),
  run_open_interaction
)

run_aa_control <- function(x, y) {
  run_lm(df, y, c(x, aa_controls), x) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      outcome_label = unname(outcome_map[y]),
      table_family = "aa_control_car_pre"
    )
}

aa_vars <- c("upstream_hardware", "upstream_any", "downstream_any", "downstream_deployer")
table_aa <- crossing(variable = aa_vars, y_var = names(outcome_map)) %>%
  mutate(res = map2(variable, y_var, run_aa_control)) %>%
  select(res) %>%
  unnest(res)

run_binary_interaction <- function(x, mod_var, y = "car_20") {
  rhs <- c(paste0(x, " * ", mod_var), base_controls)
  rhs_plain <- c(x, mod_var, firm_controls, "car_pre")
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
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      moderator = mod_var,
      table_family = paste0(mod_var, "_interaction_car_pre")
    )
}

vars_common <- c("upstream_hardware", "upstream_any", "downstream_any", "downstream_deployer")
vars_reason_code <- c("upstream_hardware", "upstream_any", "downstream_deployer")
vars_origin <- c("upstream_hardware", "upstream_any", "downstream_any")

table_reasoning <- map_dfr(vars_common, ~run_binary_interaction(.x, "is_reasoning_model"))
table_code <- map_dfr(vars_reason_code, ~run_binary_interaction(.x, "is_code_model"))
table_chinese <- map_dfr(vars_common, ~run_binary_interaction(.x, "is_chinese_model"))
table_listed <- map_dfr(vars_origin, ~run_binary_interaction(.x, "is_listed"))

run_joint_open_origin <- function(x, y = "car_20") {
  rhs <- c(
    paste0(x, " * is_open_weight"),
    paste0(x, " * is_chinese_model"),
    base_controls
  )
  rhs_plain <- c(x, "is_open_weight", "is_chinese_model", firm_controls, "car_pre")
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
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      estimate_pp = 100 * estimate,
      se_pp = 100 * std.error,
      conf.low_pp = 100 * conf.low,
      conf.high_pp = 100 * conf.high,
      table_family = "joint_open_origin_car_pre"
    )
}

table_joint_open_origin <- map_dfr(c("upstream_hardware", "upstream_any"), run_joint_open_origin)

run_media_interaction <- function(x, mod_var = "media_sentiment_z", y = "car_20") {
  rhs <- c(paste0(x, " * ", mod_var), base_controls)
  rhs_plain <- c(x, mod_var, firm_controls, "car_pre")
  d <- model_data(df, y, rhs_plain)
  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) return(tibble())

  mod <- lm_robust(safe_formula(y, rhs), data = d, clusters = d$final_event_id, se_type = "CR0")

  interaction_term <- paste0(x, ":", mod_var)
  if (!interaction_term %in% names(coef(mod))) {
    interaction_term <- paste0(mod_var, ":", x)
  }

  main_x <- linear_combo(mod, "Position main effect (at mean sentiment)", c(setNames(1, x)))
  main_mod <- linear_combo(mod, "Sentiment main effect", c(setNames(1, mod_var)))
  interaction <- linear_combo(mod, "Interaction (position x sentiment)", c(setNames(1, interaction_term)))
  low_sent <- linear_combo(mod, "Position effect at -1 SD sentiment", c(setNames(1, x), setNames(-1, interaction_term)))
  high_sent <- linear_combo(mod, "Position effect at +1 SD sentiment", c(setNames(1, x), setNames(1, interaction_term)))

  bind_rows(main_x, main_mod, interaction, low_sent, high_sent) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      moderator = mod_var,
      table_family = "media_sentiment_car_pre"
    )
}

table_media <- map_dfr(vars_common, run_media_interaction)

write_csv(table_baseline, file.path(out_dir, "table_baseline_position_with_car_pre.csv"))
write_csv(table_bundle, file.path(out_dir, "table_bundle_positions_with_car_pre.csv"))
write_csv(table_joint, file.path(out_dir, "table_joint_positions_with_car_pre.csv"))
write_csv(table_open, file.path(out_dir, "table_open_closed_with_car_pre.csv"))
write_csv(table_aa, file.path(out_dir, "table_aa_control_with_car_pre.csv"))
write_csv(table_reasoning, file.path(out_dir, "table_reasoning_interaction_with_car_pre.csv"))
write_csv(table_code, file.path(out_dir, "table_code_interaction_with_car_pre.csv"))
write_csv(table_chinese, file.path(out_dir, "table_chinese_origin_with_car_pre.csv"))
write_csv(table_listed, file.path(out_dir, "table_creator_listing_with_car_pre.csv"))
write_csv(table_joint_open_origin, file.path(out_dir, "table_joint_open_origin_with_car_pre.csv"))
write_csv(table_media, file.path(out_dir, "table_media_sentiment_with_car_pre.csv"))

summary_rows <- bind_rows(
  table_baseline %>% filter(y_var == "car_20", variable %in% c("upstream_hardware", "downstream_deployer")) %>%
    mutate(section = "baseline"),
  table_bundle %>% filter(y_var == "car_20", variable %in% c("upstream_any", "downstream_any")) %>%
    mutate(section = "bundle"),
  table_open %>% filter(variable %in% c("upstream_hardware", "downstream_deployer")) %>%
    mutate(section = "open_closed"),
  table_aa %>% filter(y_var == "car_20", variable %in% c("upstream_hardware", "downstream_deployer")) %>%
    mutate(section = "aa_control"),
  table_reasoning %>% filter(variable %in% c("upstream_hardware", "downstream_deployer")) %>%
    mutate(section = "reasoning"),
  table_code %>% filter(variable %in% c("upstream_hardware", "downstream_deployer")) %>%
    mutate(section = "code"),
  table_chinese %>% filter(variable %in% c("upstream_hardware", "upstream_any")) %>%
    mutate(section = "chinese_origin"),
  table_media %>% filter(variable %in% c("upstream_hardware", "downstream_deployer")) %>%
    mutate(section = "media")
) %>%
  select(section, variable, variable_label, term, y_var, estimate_pp, se_pp, p.value, n, n_events)

write_csv(summary_rows, file.path(out_dir, "headline_results_with_car_pre.csv"))

fmt_p <- function(p) {
  p <- suppressWarnings(as.numeric(p))
  ifelse(is.na(p), "",
    ifelse(p < 0.001, "<0.001", sprintf("%.3f", p))
  )
}

fmt_row <- function(x) {
  estimate_pp <- suppressWarnings(as.numeric(x$estimate_pp))
  se_pp <- suppressWarnings(as.numeric(x$se_pp))
  n <- suppressWarnings(as.numeric(x$n))
  sprintf(
    "| %s | %s | %s | %.2f | %.2f | %s | %s |",
    x$section, x$variable_label, x$term, estimate_pp,
    se_pp, fmt_p(x$p.value), format(n, big.mark = ",", scientific = FALSE)
  )
}

md <- c(
  "# CAR_pre control rerun",
  "",
  "All regressions keep the current manuscript outcome construction and add market-model `car_pre` as an extra control.",
  "Controls are `size_log_assets`, `bm_ratio`, `volatility`, `momentum`, `car_pre`, and release-year fixed effects unless otherwise stated.",
  "Standard errors are CR0 clustered by `final_event_id`, matching the existing table scripts.",
  "",
  sprintf("- Input rows: %s", format(nrow(df), big.mark = ",")),
  sprintf("- Nonmissing `car_pre`: %s", format(sum(!is.na(df$car_pre)), big.mark = ",")),
  sprintf("- Nonmissing `car_20` with all baseline controls plus `car_pre`: %s",
          format(nrow(model_data(df, "car_20", c(firm_controls, "car_pre", "release_year"))), big.mark = ",")),
  sprintf("- Media sentiment coverage: %s events", n_distinct(df$final_event_id[!is.na(df$media_sentiment_20)])),
  "",
  "## Headline Results",
  "",
  "| Section | Variable | Term | Estimate pp | SE pp | p | n |",
  "|---|---|---:|---:|---:|---:|---:|",
  apply(summary_rows, 1, function(row) fmt_row(as.list(row))),
  "",
  "## Output Files",
  "",
  "- `table_baseline_position_with_car_pre.csv`",
  "- `table_bundle_positions_with_car_pre.csv`",
  "- `table_joint_positions_with_car_pre.csv`",
  "- `table_open_closed_with_car_pre.csv`",
  "- `table_aa_control_with_car_pre.csv`",
  "- `table_reasoning_interaction_with_car_pre.csv`",
  "- `table_code_interaction_with_car_pre.csv`",
  "- `table_chinese_origin_with_car_pre.csv`",
  "- `table_creator_listing_with_car_pre.csv`",
  "- `table_joint_open_origin_with_car_pre.csv`",
  "- `table_media_sentiment_with_car_pre.csv`"
)

writeLines(md, file.path(out_dir, "summary_with_car_pre.md"))

cat("Done. Outputs written to ", out_dir, "\n", sep = "")
print(summary_rows)
