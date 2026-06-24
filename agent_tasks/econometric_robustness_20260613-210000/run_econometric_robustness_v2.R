#!/usr/bin/env Rscript
#
# v2 of run_econometric_robustness.R, migrated to the NEW 8-dimension
# relationship coding schema (data/panel/specr_rel_clean.csv).
#
# Schema migration notes (see data/relationships/relationship_codebook.md):
#   OLD: owner, investor, cloud, business_upstream, real_upstream,
#        business_downstream, real_downstream, competitor
#   NEW: upstream_hardware, upstream_cloud, downstream_integrator,
#        downstream_deployer, downstream_enabler, competitor,
#        is_investor, is_owner
#
# The only use of relationship variables in this script is a coarse
# "does this firm have ANY structural relationship to the event" filter
# (rel_vars -> rowSums(...) > 0) used to build the "related firms"
# event-level subsample (df_rel / ed_rel). It does not use any single
# old dimension as a standalone regressor, interaction term, or FE -
# only the union of all relationship dimensions matters here. The
# semantically correct migration is therefore to replace the old
# 8-column union with the new 8-column union (all NEW dimensions),
# which still answers "does this firm have any coded structural tie to
# this model release" under the new, more granular schema.
#
# No other part of the script (core_results spec set, event window
# overlap diagnostics, leave-one-creator-out) touches relationship
# columns at all, so those sections are unchanged except for output
# paths/labels.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(estimatr)
  library(sandwich)
  library(lmtest)
})

out_dir <- "agent_tasks/econometric_robustness_20260613-210000"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

df_clean <- read.csv("output/data/clean_event_firm_panel.csv", stringsAsFactors = FALSE, check.names = FALSE)
# NEW relationship schema lives in data/panel/specr_rel_clean.csv (the old
# output/data/specr_rel_clean.csv copy still has the OLD 8-column schema).
df_rel <- read.csv("data/panel/specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)
df_rel <- df_rel[!is.na(df_rel$final_event_id) & df_rel$final_event_id != "" &
                   !is.na(df_rel$company_id) & df_rel$company_id != "", ]
rel_vars <- c("upstream_hardware", "upstream_cloud", "downstream_integrator",
              "downstream_deployer", "downstream_enabler", "competitor",
              "is_investor", "is_owner", "relationship_notes")
df <- df_clean %>%
  left_join(df_rel[, c("final_event_id", "company_id", rel_vars)], by = c("final_event_id", "company_id"))

df$car_pre <- df$mkt_car_pre
df$car_1 <- df$mkt_car_1
df$car_2 <- df$mkt_car_2
df$car_3 <- df$mkt_car_3
df$car_5 <- df$mkt_car_5
df$car_10 <- df$mkt_car_10
df$car_15 <- df$mkt_car_15
df$car_20 <- df$mkt_car_20
df$is_open_weight <- df$is_open_weight_or_open_source
df$trend_month <- df$trend_month_since_2022_11
df <- df[!is.na(df$final_event_id) & df$final_event_id != "", ]

num_cols <- c(
  "release_year", "trend_month", "car_pre", "car_1", "car_2", "car_3", "car_5",
  "car_10", "car_15", "car_20", "ff3_car_1", "ff3_car_2", "ff3_car_3",
  "ff3_car_5", "ff3_car_10", "ff3_car_15", "ff3_car_20",
  "aa_intelligence_index", "size_log_assets", "bm_ratio", "volatility", "momentum",
  "is_open_weight", "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor", "is_investor", "is_owner"
)
for (v in intersect(num_cols, names(df))) df[[v]] <- suppressWarnings(as.numeric(df[[v]]))
df$release_date <- as.Date(df$release_date, tryFormats = c("%Y-%m-%d", "%Y/%m/%d", "%m/%d/%Y"))

ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
rel_vars <- c("upstream_hardware", "upstream_cloud", "downstream_integrator",
              "downstream_deployer", "downstream_enabler", "competitor",
              "is_investor", "is_owner")

base_filter <- function(data, y = "car_20") {
  keep <- !is.na(data[[y]]) &
    !is.na(data$aa_intelligence_index) &
    !is.na(data$release_year) &
    !is.na(data$final_event_id) &
    !is.na(data$company_id)
  for (v in ctrl) keep <- keep & !is.na(data[[v]])
  data[keep, ]
}

df_base <- base_filter(df, "car_20")
intel_mean <- mean(df_base$aa_intelligence_index, na.rm = TRUE)
df$intel_c <- df$aa_intelligence_index - intel_mean
df_base <- base_filter(df, "car_20")
df_closed <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 0, ]

is_us_like <- function(x) {
  grepl("^[A-Z.]{1,5}$", x) & !grepl(" ", x)
}
df_base$us_like_ticker <- is_us_like(df_base$company_id)
df_closed$us_like_ticker <- is_us_like(df_closed$company_id)

p_stars <- function(p) {
  ifelse(is.na(p), "",
    ifelse(p < 0.001, "***",
      ifelse(p < 0.01, "**",
        ifelse(p < 0.05, "*",
          ifelse(p < 0.10, "+", "")))))
}

term_stats <- function(model, term, vcov_mat, df_p) {
  b <- coef(model)[[term]]
  se <- sqrt(diag(vcov_mat))[[term]]
  tval <- b / se
  p <- 2 * pt(abs(tval), df = df_p, lower.tail = FALSE)
  tibble(term = term, beta = b, se = se, t = tval, p = p, stars = p_stars(p))
}

fit_lm_cluster <- function(label, data, formula, term = "intel_c", cluster = "event") {
  data <- as.data.frame(data)
  rownames(data) <- seq_len(nrow(data))
  d <- model.frame(formula, data = data, na.action = na.omit)
  if (nrow(d) == 0) {
    return(tibble(
      spec = label, cluster = cluster, term = term, beta = NA_real_, se = NA_real_,
      t = NA_real_, p = NA_real_, stars = "", n = 0L, events = 0L, firms = 0L,
      r2 = NA_real_, note = "Skipped because no non-missing observations"
    ))
  }
  row_ids <- as.integer(rownames(d))
  dd <- data[row_ids, ]
  if (length(unique(dd$final_event_id)) < 2 || length(unique(dd$company_id)) < 1) {
    return(tibble(
      spec = label, cluster = cluster, term = term, beta = NA_real_, se = NA_real_,
      t = NA_real_, p = NA_real_, stars = "", n = nrow(dd),
      events = length(unique(dd$final_event_id)), firms = length(unique(dd$company_id)),
      r2 = NA_real_, note = "Skipped because too few clusters"
    ))
  }
  m <- lm(formula, data = dd)
  if (cluster == "event") {
    vc <- vcovCL(m, cluster = dd$final_event_id, type = "HC1")
    df_p <- length(unique(dd$final_event_id)) - 1
  } else if (cluster == "firm") {
    vc <- vcovCL(m, cluster = dd$company_id, type = "HC1")
    df_p <- length(unique(dd$company_id)) - 1
  } else if (cluster == "two_way") {
    vc <- vcovCL(m, cluster = data.frame(event = dd$final_event_id, firm = dd$company_id), type = "HC1")
    df_p <- min(length(unique(dd$final_event_id)), length(unique(dd$company_id))) - 1
  } else {
    stop("Unknown cluster")
  }
  s <- term_stats(m, term, vc, df_p)
  s %>%
    mutate(
      spec = label,
      cluster = cluster,
      n = nobs(m),
      events = length(unique(dd$final_event_id)),
      firms = length(unique(dd$company_id)),
      r2 = summary(m)$r.squared,
      note = "",
      .before = term
    )
}

make_formula <- function(data, y, xterms, firm_fe = FALSE) {
  rhs <- c(xterms, ctrl)
  if (length(unique(data$release_year[!is.na(data$release_year)])) >= 2) {
    rhs <- c(rhs, "factor(release_year)")
  }
  if (firm_fe && length(unique(data$company_id[!is.na(data$company_id)])) >= 2) {
    rhs <- c(rhs, "factor(company_id)")
  }
  as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
}

run_core_specs <- function() {
  rows <- list()
  f_base <- make_formula(df_base, "car_20", "intel_c", firm_fe = FALSE)
  f_firm_fe <- make_formula(df_base, "car_20", "intel_c", firm_fe = TRUE)
  f_firm_fe_closed <- make_formula(df_closed, "car_20", "intel_c", firm_fe = TRUE)
  f_interact_fe <- make_formula(df_base, "car_20", c("intel_c", "is_open_weight", "intel_c:is_open_weight"), firm_fe = TRUE)

  rows[[length(rows) + 1]] <- fit_lm_cluster("baseline_no_firm_fe_all", df_base, f_base, "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_all", df_base, f_firm_fe, "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_all", df_base, f_firm_fe, "intel_c", "firm")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_all", df_base, f_firm_fe, "intel_c", "two_way")

  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_closed", df_closed, f_firm_fe_closed, "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_closed", df_closed, f_firm_fe_closed, "intel_c", "firm")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_closed", df_closed, f_firm_fe_closed, "intel_c", "two_way")

  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_interaction_closed_slope", df_base, f_interact_fe, "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_interaction_open_interaction", df_base, f_interact_fe, "intel_c:is_open_weight", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("firm_fe_interaction_open_interaction", df_base, f_interact_fe, "intel_c:is_open_weight", "two_way")

  df_ff3 <- base_filter(df, "ff3_car_20")
  df_ff3_closed <- df_ff3[df_ff3$is_open_weight == 0, ]
  rows[[length(rows) + 1]] <- fit_lm_cluster("ff3_firm_fe_all", df_ff3, make_formula(df_ff3, "ff3_car_20", "intel_c", TRUE), "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("ff3_firm_fe_closed", df_ff3_closed, make_formula(df_ff3_closed, "ff3_car_20", "intel_c", TRUE), "intel_c", "event")

  df_pre <- base_filter(df, "car_pre")
  df_pre_closed <- df_pre[df_pre$is_open_weight == 0, ]
  rows[[length(rows) + 1]] <- fit_lm_cluster("pre_event_car_firm_fe_all", df_pre, make_formula(df_pre, "car_pre", "intel_c", TRUE), "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("pre_event_car_firm_fe_closed", df_pre_closed, make_formula(df_pre_closed, "car_pre", "intel_c", TRUE), "intel_c", "event")

  df_us <- df_base[df_base$us_like_ticker, ]
  df_us_closed <- df_closed[df_closed$us_like_ticker, ]
  rows[[length(rows) + 1]] <- fit_lm_cluster("us_like_tickers_firm_fe_all", df_us, make_formula(df_us, "car_20", "intel_c", TRUE), "intel_c", "event")
  rows[[length(rows) + 1]] <- fit_lm_cluster("us_like_tickers_firm_fe_closed", df_us_closed, make_formula(df_us_closed, "car_20", "intel_c", TRUE), "intel_c", "event")

  bind_rows(rows)
}

core_results <- run_core_specs()
write_csv(core_results, file.path(out_dir, "core_robustness_results_v2.csv"))

event_level_data <- function(data, related_only = FALSE) {
  d <- data
  if (related_only) {
    d$related_any <- rowSums(d[, rel_vars], na.rm = TRUE) > 0
    d <- d[d$related_any, ]
  }
  d %>%
    group_by(final_event_id) %>%
    summarise(
      car20_mean = mean(car_20, na.rm = TRUE),
      carpre_mean = mean(car_pre, na.rm = TRUE),
      ff3_car20_mean = mean(ff3_car_20, na.rm = TRUE),
      intel_c = first(intel_c),
      aa_intelligence_index = first(aa_intelligence_index),
      is_open_weight = first(is_open_weight),
      release_year = first(release_year),
      true_model_creator = first(true_model_creator),
      release_date = first(release_date),
      mean_size = mean(size_log_assets, na.rm = TRUE),
      mean_bm = mean(bm_ratio, na.rm = TRUE),
      mean_volatility = mean(volatility, na.rm = TRUE),
      mean_momentum = mean(momentum, na.rm = TRUE),
      n_firms = n(),
      .groups = "drop"
    ) %>%
    filter(
      !is.na(car20_mean), !is.na(intel_c), !is.na(release_year),
      !is.na(mean_size), !is.na(mean_bm), !is.na(mean_volatility), !is.na(mean_momentum)
    )
}

fit_event_level <- function(label, ed, y = "car20_mean", term = "intel_c") {
  ed <- as.data.frame(ed)
  rownames(ed) <- seq_len(nrow(ed))
  if (nrow(ed) < 5) {
    return(tibble(
      spec = label, cluster = "event_level_hc1", term = term, beta = NA_real_,
      se = NA_real_, t = NA_real_, p = NA_real_, stars = "", n = nrow(ed),
      events = nrow(ed), firms = NA_integer_, r2 = NA_real_,
      note = "Skipped because too few event-level observations"
    ))
  }
  rhs <- c("intel_c", "mean_size", "mean_bm", "mean_volatility", "mean_momentum")
  if (length(unique(ed$release_year[!is.na(ed$release_year)])) >= 2) {
    rhs <- c(rhs, "factor(release_year)")
  }
  f <- as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
  m <- lm(f, data = ed)
  vc <- vcovHC(m, type = "HC1")
  s <- term_stats(m, term, vc, max(nobs(m) - length(coef(m)), 1))
  s %>%
    mutate(
      spec = label,
      cluster = "event_level_hc1",
      n = nobs(m),
      events = nrow(ed),
      firms = NA_integer_,
      r2 = summary(m)$r.squared,
      note = "",
      .before = term
    )
}

ed_all <- event_level_data(df_base, related_only = FALSE)
ed_closed <- ed_all[ed_all$is_open_weight == 0, ]
ed_rel <- event_level_data(df_base, related_only = TRUE)
ed_rel_closed <- ed_rel[ed_rel$is_open_weight == 0, ]

event_results <- bind_rows(
  fit_event_level("event_level_all_firms_all", ed_all),
  fit_event_level("event_level_all_firms_closed", ed_closed),
  fit_event_level("event_level_related_firms_all", ed_rel),
  fit_event_level("event_level_related_firms_closed", ed_rel_closed)
)
write_csv(event_results, file.path(out_dir, "event_level_results_v2.csv"))
write_csv(ed_all, file.path(out_dir, "event_level_dataset_all_firms_v2.csv"))
write_csv(ed_rel, file.path(out_dir, "event_level_dataset_related_firms_v2.csv"))

loo_rows <- list()
top_creators <- names(sort(table(df_base$true_model_creator), decreasing = TRUE))
top_creators <- top_creators[top_creators != ""]
for (creator in top_creators) {
  d_all <- df_base[df_base$true_model_creator != creator, ]
  d_closed <- df_closed[df_closed$true_model_creator != creator, ]
  if (length(unique(d_closed$final_event_id)) >= 10) {
    loo_rows[[length(loo_rows) + 1]] <- fit_lm_cluster(
      paste0("closed_leave_out_", gsub("[^A-Za-z0-9]+", "_", creator)),
      d_closed,
      make_formula(d_closed, "car_20", "intel_c", TRUE),
      "intel_c",
      "event"
    ) %>% mutate(left_out_creator = creator)
  }
  if (length(unique(d_all$final_event_id)) >= 10) {
    loo_rows[[length(loo_rows) + 1]] <- fit_lm_cluster(
      paste0("all_leave_out_", gsub("[^A-Za-z0-9]+", "_", creator)),
      d_all,
      make_formula(d_all, "car_20", "intel_c", TRUE),
      "intel_c",
      "event"
    ) %>% mutate(left_out_creator = creator)
  }
}
loo_results <- bind_rows(loo_rows)
write_csv(loo_results, file.path(out_dir, "leave_one_creator_out_results_v2.csv"))

event_dates <- df_base %>%
  distinct(final_event_id, release_date, event_name, true_model_creator) %>%
  filter(!is.na(release_date)) %>%
  arrange(release_date)

overlap <- event_dates %>%
  rowwise() %>%
  mutate(
    events_within_20_calendar_days = sum(abs(as.numeric(release_date - event_dates$release_date)) <= 20, na.rm = TRUE) - 1,
    prior_events_within_20_calendar_days = sum(as.numeric(release_date - event_dates$release_date) > 0 &
                                                as.numeric(release_date - event_dates$release_date) <= 20, na.rm = TRUE),
    next_events_within_20_calendar_days = sum(as.numeric(event_dates$release_date - release_date) > 0 &
                                               as.numeric(event_dates$release_date - release_date) <= 20, na.rm = TRUE)
  ) %>%
  ungroup()
write_csv(overlap, file.path(out_dir, "event_window_overlap_diagnostic_v2.csv"))

non_overlap_events <- overlap$final_event_id[overlap$events_within_20_calendar_days == 0]
if (length(non_overlap_events) >= 10) {
  d_no_overlap <- df_base[df_base$final_event_id %in% non_overlap_events, ]
  d_no_overlap_closed <- df_closed[df_closed$final_event_id %in% non_overlap_events, ]
  no_overlap_results <- bind_rows(
    fit_lm_cluster("no_calendar_overlap_all", d_no_overlap,
                   make_formula(d_no_overlap, "car_20", "intel_c", TRUE),
                   "intel_c", "event"),
    fit_lm_cluster("no_calendar_overlap_closed", d_no_overlap_closed,
                   make_formula(d_no_overlap_closed, "car_20", "intel_c", TRUE),
                   "intel_c", "event")
  )
} else {
  no_overlap_results <- tibble(
    spec = "no_calendar_overlap",
    note = "Fewer than 10 non-overlapping intelligence events under +/-20 calendar-day rule"
  )
}
write_csv(no_overlap_results, file.path(out_dir, "no_overlap_results_v2.csv"))

sample_summary <- tibble(
  metric = c(
    "raw_rows_specr_rel",
    "rows_after_blank_filter",
    "events_after_blank_filter",
    "firms_after_blank_filter",
    "main_regression_rows",
    "main_regression_events",
    "closed_rows",
    "closed_events",
    "open_rows",
    "open_events",
    "us_like_main_rows",
    "us_like_main_firms",
    "intel_mean_for_centering"
  ),
  value = c(
    nrow(df_clean),
    nrow(df),
    length(unique(df$final_event_id)),
    length(unique(df$company_id)),
    nrow(df_base),
    length(unique(df_base$final_event_id)),
    nrow(df_closed),
    length(unique(df_closed$final_event_id)),
    nrow(df_base[df_base$is_open_weight == 1, ]),
    length(unique(df_base$final_event_id[df_base$is_open_weight == 1])),
    nrow(df_base[df_base$us_like_ticker, ]),
    length(unique(df_base$company_id[df_base$us_like_ticker])),
    intel_mean
  )
)
write_csv(sample_summary, file.path(out_dir, "sample_summary_v2.csv"))

fmt <- function(x, digits = 4) ifelse(is.na(x), "NA", formatC(x, format = "f", digits = digits))
summarise_results <- function(tbl) {
  tbl %>%
    transmute(
      spec,
      cluster,
      term,
      beta = fmt(beta, 6),
      se = fmt(se, 6),
      p = paste0(fmt(p, 4), stars),
      n,
      events,
      firms,
      r2 = fmt(r2, 3)
    )
}

report <- c(
  "# Econometric Robustness Report (v2 — NEW relationship schema)",
  "",
  "本报告由 `run_econometric_robustness_v2.R` 自动生成，使用新版8维度关系编码 (data/panel/specr_rel_clean.csv)。",
  "",
  "## 样本摘要",
  "",
  paste(capture.output(print(sample_summary, n = Inf)), collapse = "\n"),
  "",
  "## 核心稳健性结果",
  "",
  paste(capture.output(print(summarise_results(core_results), n = Inf)), collapse = "\n"),
  "",
  "## 事件层聚合结果",
  "",
  paste(capture.output(print(summarise_results(event_results), n = Inf)), collapse = "\n"),
  "",
  "## Leave-one-creator-out 结果",
  "",
  paste(capture.output(print(summarise_results(loo_results), n = Inf)), collapse = "\n"),
  "",
  "## 窗口重叠诊断",
  "",
  paste(capture.output(print(summary(overlap$events_within_20_calendar_days))), collapse = "\n"),
  "",
  "输出 CSV 已写入当前任务目录（均带 _v2 后缀）。"
)
writeLines(report, file.path(out_dir, "econometric_robustness_report_v2.md"))

cat("Saved robustness outputs to", out_dir, "\n")
