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
out_dir <- "agent_tasks/specr_star_scan_20260627/outputs"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(input_file, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))

names(df)[names(df) == "FF3异常收益[-10,-2]"] <- "ff3_car_pre"
names(df)[names(df) == "是否包含推理模型"] <- "is_reasoning_model"
names(df)[names(df) == "是否包含代码模型"] <- "is_code_model"
names(df)[names(df) == "是否包含图像、视频等媒体生成模型"] <- "is_media_generation_model"
names(df)[names(df) == "媒体态度均值(20,20)"] <- "media_sentiment_20"

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year", "car_pre", "car_1", "car_2", "car_3", "car_5",
  "car_10", "car_15", "car_20", "ff3_car_pre", "ff3_car_1",
  "ff3_car_2", "ff3_car_3", "ff3_car_5", "ff3_car_10",
  "ff3_car_15", "ff3_car_20", "aa_intelligence_index",
  "aa_coding_index", "aa_math_index", "aa_media_elo",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "is_open_weight", "is_chinese_model", "is_reasoning_model",
  "is_code_model", "is_media_generation_model", "media_sentiment_20",
  rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in setdiff(c("aa_coding_index", "aa_math_index", "aa_media_elo"), names(df))) {
  df[[col]] <- NA_real_
}

for (col in rel_vars) {
  if (!col %in% names(df)) stop(paste("Missing relationship variable:", col))
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

for (col in c("is_reasoning_model", "is_code_model", "is_media_generation_model")) {
  df[[col]][is.na(df[[col]])] <- 0
}

zscore <- function(x) as.numeric(scale(x))

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
    )),
    text_or_reason = as.integer(
      model_modality %in% c("text_llm", "reasoning_llm", "multimodal_llm", "coding_llm") |
        is_reasoning_model == 1 | is_code_model == 1
    ),
    z_intelligence = zscore(aa_intelligence_index),
    z_coding = zscore(aa_coding_index),
    z_math = zscore(aa_math_index),
    z_media_elo = zscore(aa_media_elo),
    z_media_sentiment = zscore(media_sentiment_20)
  )

outcomes <- c("car_1", "car_2", "car_3", "car_5", "car_10", "car_15", "car_20")
ff3_outcomes <- c("ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_5", "ff3_car_10", "ff3_car_15", "ff3_car_20")

position_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "upstream_any", "downstream_any", "strategic_any"
)

capability_vars <- c("z_intelligence", "z_coding", "z_math", "z_media_elo")
capability_vars <- capability_vars[vapply(capability_vars, function(v) {
  v %in% names(df) && sum(!is.na(df[[v]])) >= 200
}, logical(1))]

label_map <- c(
  upstream_hardware = "Upstream hardware",
  upstream_cloud = "Upstream cloud",
  downstream_integrator = "Downstream integrator",
  downstream_deployer = "Downstream deployer",
  downstream_enabler = "Downstream enabler",
  competitor = "Direct competitor",
  upstream_any = "Any upstream",
  downstream_any = "Any downstream",
  strategic_any = "Strategic/upstream",
  z_intelligence = "AA Intelligence Index (z)",
  z_coding = "AA Coding Index (z)",
  z_math = "AA Math Index (z)",
  z_media_elo = "AA Media Elo (z)"
)

sample_defs <- list(
  all = quote(TRUE),
  closed = quote(is_open_weight == 0),
  open_weight = quote(is_open_weight == 1),
  reasoning = quote(is_reasoning_model == 1),
  non_reasoning = quote(is_reasoning_model == 0),
  code_model = quote(is_code_model == 1),
  chinese_origin = quote(is_chinese_model == 1),
  non_chinese_origin = quote(is_chinese_model == 0),
  listed_creator = quote(is_listed == 1),
  unlisted_creator = quote(is_listed == 0),
  text_or_reason = quote(text_or_reason == 1),
  media_generation = quote(is_media_generation_model == 1)
)

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")

controls_for <- function(control_set, outcome_family) {
  pre_var <- if (outcome_family == "ff3") "ff3_car_pre" else "car_pre"
  switch(
    control_set,
    none = character(),
    firm = firm_controls,
    firm_year = c(firm_controls, "factor(release_year)"),
    firm_year_pre = c(firm_controls, pre_var, "factor(release_year)")
  )
}

safe_formula <- function(y, rhs) {
  if (length(rhs) == 0) return(as.formula(paste(y, "~ 1")))
  as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
}

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

drop_bad_rhs <- function(data, rhs) {
  rhs2 <- rhs
  if ("factor(release_year)" %in% rhs2 && n_distinct(data$release_year[!is.na(data$release_year)]) < 2) {
    rhs2 <- setdiff(rhs2, "factor(release_year)")
  }
  rhs2
}

fit_extract <- function(data, y, rhs, keep_terms, meta) {
  rhs_plain <- rhs[!grepl("^factor\\(", rhs)]
  d <- model_data(data, y, rhs_plain)
  rhs <- drop_bad_rhs(d, rhs)

  if (nrow(d) < 200 || n_distinct(d$final_event_id) < 8) return(tibble())

  # Skip if the focal terms or interaction ingredients have no usable variation.
  vars_to_check <- unique(gsub(":.*$|.*:", "", keep_terms))
  vars_to_check <- intersect(vars_to_check, names(d))
  for (v in vars_to_check) {
    if (n_distinct(d[[v]][!is.na(d[[v]])]) < 2) return(tibble())
  }

  mod <- tryCatch(
    lm_robust(safe_formula(y, rhs), data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
  if (is.null(mod)) return(tibble())

  tidy(mod, conf.int = TRUE) %>%
    filter(term %in% keep_terms) %>%
    mutate(
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      r_squared = summary(mod)$r.squared,
      estimate_pp = 100 * estimate,
      se_pp = 100 * std.error,
      conf.low_pp = 100 * conf.low,
      conf.high_pp = 100 * conf.high,
      !!!meta
    )
}

run_main_grid <- function(outcome_family, y, x, control_set, sample_name) {
  data <- df %>% filter(eval(sample_defs[[sample_name]]))
  rhs <- c(x, controls_for(control_set, outcome_family))
  fit_extract(
    data, y, rhs, x,
    list(
      spec_type = "main_effect",
      outcome_family = outcome_family,
      x = x,
      x_label = unname(label_map[x]),
      moderator = NA_character_,
      control_set = control_set,
      sample = sample_name
    )
  )
}

run_interaction_grid <- function(y, x, moderator, control_set, sample_name) {
  data <- df %>% filter(eval(sample_defs[[sample_name]]))
  rhs <- c(paste0(x, " * ", moderator), controls_for(control_set, "market"))
  term1 <- paste0(x, ":", moderator)
  term2 <- paste0(moderator, ":", x)
  fit_extract(
    data, y, rhs, c(term1, term2),
    list(
      spec_type = "interaction",
      outcome_family = "market",
      x = x,
      x_label = unname(label_map[x]),
      moderator = moderator,
      control_set = control_set,
      sample = sample_name
    )
  )
}

cat("Running main-effect SPECR scan...\n")

main_specs <- crossing(
  outcome_family = c("market", "ff3"),
  y = list(market = outcomes, ff3 = ff3_outcomes) %>% unlist(use.names = FALSE),
  x = c(position_vars, capability_vars),
  control_set = c("none", "firm", "firm_year", "firm_year_pre"),
  sample_name = names(sample_defs)
) %>%
  filter(
    (outcome_family == "market" & y %in% outcomes) |
      (outcome_family == "ff3" & y %in% ff3_outcomes)
  )

main_results <- pmap_dfr(main_specs, run_main_grid)

cat("Running interaction SPECR scan...\n")

interaction_specs <- crossing(
  y = c("car_3", "car_5", "car_10", "car_15", "car_20"),
  x = c("upstream_hardware", "upstream_cloud", "upstream_any", "downstream_any", "downstream_deployer"),
  moderator = c("is_open_weight", "is_reasoning_model", "is_code_model", "is_chinese_model", "is_listed", "z_media_sentiment"),
  control_set = c("firm_year", "firm_year_pre"),
  sample_name = c("all", "text_or_reason", "non_chinese_origin")
)

interaction_results <- pmap_dfr(interaction_specs, run_interaction_grid)

all_results <- bind_rows(main_results, interaction_results) %>%
  mutate(
    p_bh_all = p.adjust(p.value, method = "BH"),
    p_bonf_all = p.adjust(p.value, method = "bonferroni"),
    sign = case_when(
      estimate > 0 ~ "positive",
      estimate < 0 ~ "negative",
      TRUE ~ "zero"
    ),
    three_star = p.value < 0.01,
    bh_1pct = p_bh_all < 0.01,
    bh_5pct = p_bh_all < 0.05
  ) %>%
  arrange(p.value)

three_star_results <- all_results %>%
  filter(three_star) %>%
  arrange(p.value)

summary_by_pattern <- all_results %>%
  group_by(spec_type, x, x_label, moderator, outcome_family, sign) %>%
  summarise(
    n_specs = n(),
    n_three_star = sum(three_star, na.rm = TRUE),
    share_three_star = n_three_star / n_specs,
    n_bh_5pct = sum(bh_5pct, na.rm = TRUE),
    median_est_pp = median(estimate_pp, na.rm = TRUE),
    min_p = min(p.value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n_three_star > 0) %>%
  arrange(desc(n_three_star), min_p)

summary_by_x <- all_results %>%
  group_by(spec_type, x, x_label, moderator) %>%
  summarise(
    n_specs = n(),
    n_three_star = sum(three_star, na.rm = TRUE),
    share_three_star = n_three_star / n_specs,
    n_positive = sum(estimate > 0, na.rm = TRUE),
    n_negative = sum(estimate < 0, na.rm = TRUE),
    sign_stability = pmax(n_positive, n_negative) / n_specs,
    n_bh_5pct = sum(bh_5pct, na.rm = TRUE),
    median_est_pp = median(estimate_pp, na.rm = TRUE),
    min_p = min(p.value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n_three_star > 0) %>%
  arrange(desc(n_three_star), desc(sign_stability), min_p)

write_csv(all_results, file.path(out_dir, "all_specr_results.csv"))
write_csv(three_star_results, file.path(out_dir, "three_star_results_p001.csv"))
write_csv(summary_by_pattern, file.path(out_dir, "three_star_summary_by_pattern.csv"))
write_csv(summary_by_x, file.path(out_dir, "three_star_summary_by_x.csv"))

top_display <- summary_by_x %>%
  slice_head(n = 20) %>%
  mutate(
    median_est_pp = round(median_est_pp, 3),
    share_three_star = round(share_three_star, 3),
    sign_stability = round(sign_stability, 3),
    min_p = signif(min_p, 3)
  )

strong_display <- three_star_results %>%
  filter(bh_5pct) %>%
  select(
    spec_type, x_label, moderator, y_var, outcome_family, control_set, sample,
    term, estimate_pp, se_pp, p.value, p_bh_all, n, n_events
  ) %>%
  mutate(
    estimate_pp = round(estimate_pp, 3),
    se_pp = round(se_pp, 3),
    p.value = signif(p.value, 3),
    p_bh_all = signif(p_bh_all, 3)
  ) %>%
  slice_head(n = 30)

fmt_table <- function(data) {
  if (nrow(data) == 0) return("(none)")
  header <- paste(names(data), collapse = " | ")
  sep <- paste(rep("---", ncol(data)), collapse = " | ")
  rows <- apply(data, 1, function(r) paste(r, collapse = " | "))
  paste(c(header, sep, rows), collapse = "\n")
}

md <- c(
  "# SPECR three-star scan",
  "",
  "This is an exploratory specification scan. It is meant to find candidate patterns, not to replace the pre-specified main tables.",
  "",
  sprintf("- Total tested coefficients: %s", format(nrow(all_results), big.mark = ",")),
  sprintf("- Raw p < 0.01 coefficients: %s", format(nrow(three_star_results), big.mark = ",")),
  sprintf("- BH-adjusted p < 0.05 coefficients: %s", format(sum(all_results$bh_5pct, na.rm = TRUE), big.mark = ",")),
  sprintf("- BH-adjusted p < 0.01 coefficients: %s", format(sum(all_results$bh_1pct, na.rm = TRUE), big.mark = ",")),
  "",
  "## Most frequent three-star patterns",
  "",
  fmt_table(top_display),
  "",
  "## Strongest BH-adjusted candidates",
  "",
  fmt_table(strong_display),
  "",
  "## Files",
  "",
  "- `all_specr_results.csv`",
  "- `three_star_results_p001.csv`",
  "- `three_star_summary_by_pattern.csv`",
  "- `three_star_summary_by_x.csv`"
)

writeLines(md, file.path(out_dir, "specr_three_star_summary.md"))

cat("Done.\n")
cat("All coefficients:", nrow(all_results), "\n")
cat("Raw p<0.01:", nrow(three_star_results), "\n")
cat("BH p<0.05:", sum(all_results$bh_5pct, na.rm = TRUE), "\n")
cat("Outputs:", out_dir, "\n")
