#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(lmtest)
  library(sandwich)
})

args <- commandArgs(trailingOnly = FALSE)
script_arg <- args[grep("--file=", args)]
script_path <- if (length(script_arg)) sub("--file=", "", script_arg[1]) else
  "agent_tasks/relationship-specr_20260703-200524/run_relationship_yearshape.R"
task_dir <- normalizePath(dirname(script_path))
root <- normalizePath(file.path(task_dir, "..", ".."))
panel_path <- file.path(root, "Analysis", "processed", "event_firm_panel.csv")
out_path <- file.path(task_dir, "specr_yearshape_results.csv")
summary_path <- file.path(task_dir, "specr_yearshape_summary.csv")
notes_path <- file.path(task_dir, "specr_yearshape_notes.md")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)
num_cols <- unique(c(
  grep("^car_", names(df), value = TRUE),
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner",
  "is_open_weight_or_open_source", "is_chinese_model", "is_reasoning_model"
))
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
df$upstream_any <- as.numeric(df$rel_upstream_hardware == 1 | df$rel_upstream_cloud == 1)
df$downstream_any <- as.numeric(
  df$rel_downstream_integrator == 1 |
    df$rel_downstream_deployer == 1 |
    df$rel_downstream_enabler == 1
)
df$strategic_any <- as.numeric(
  df$upstream_any == 1 | df$rel_competitor == 1 |
    df$rel_is_investor == 1 | df$rel_is_owner == 1
)
df$platform_bigtech <- as.numeric(
  df$rel_upstream_cloud == 1 | df$rel_competitor == 1 |
    df$rel_is_investor == 1 | df$rel_is_owner == 1
)

base_filter <- df$is_main_nasdaq100 == "True" &
  df$event_excluded_identity == "False" &
  !is.na(df$size_log_assets) &
  !is.na(df$volatility) &
  !is.na(df$momentum)

sample_defs <- list(
  main = rep(TRUE, nrow(df)),
  high_date = df$date_confidence == "high",
  no_multi_component = df$multi_component_date_flag == "False",
  llm_events = df$aa_metric_type == "llm"
)
rels <- c(
  "rel_upstream_hardware", "upstream_any", "strategic_any",
  "downstream_any", "rel_downstream_deployer", "rel_downstream_integrator",
  "rel_competitor", "platform_bigtech"
)
outcomes <- intersect(
  c("car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
    "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_soxx_0_20"),
  names(df)
)
years <- sort(unique(df$release_year))
controls <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum"

prep_sample <- function(sample_name, y) {
  dat <- df[base_filter & sample_defs[[sample_name]], ]
  dat <- dat[!is.na(dat[[y]]), ]
  dat$bm_missing <- as.numeric(is.na(dat$bm_ratio))
  dat$bm_ratio[is.na(dat$bm_ratio)] <- 0
  dat
}

fit_one <- function(dat, y, rel, sample_name) {
  if (nrow(dat) < 400 || length(unique(dat$event_id)) < 8) return(NULL)
  for (yr in years) {
    dat[[paste0(rel, "_y", yr)]] <- as.numeric(dat[[rel]] == 1 & dat$release_year == yr)
  }
  terms <- paste0(rel, "_y", years)
  active_terms <- terms[sapply(terms, function(z) sum(dat[[z]] == 1, na.rm = TRUE) > 0)]
  if (length(active_terms) == 0) return(NULL)
  rhs <- paste(c(active_terms, controls, "factor(event_id)"), collapse = " + ")
  fit <- tryCatch(suppressWarnings(lm(as.formula(paste(y, "~", rhs)), data = dat)), error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  vc <- tryCatch(suppressWarnings(vcovCL(fit, cluster = dat$event_id, type = "HC0")), error = function(e) NULL)
  if (is.null(vc)) return(NULL)
  ct <- tryCatch(suppressWarnings(coeftest(fit, vcov. = vc)), error = function(e) NULL)
  if (is.null(ct)) return(NULL)
  rows <- list()
  for (term in active_terms) {
    if (!(term %in% rownames(ct))) next
    est <- ct[term, 1]
    se <- ct[term, 2]
    if (!is.finite(est) || !is.finite(se) || se <= 0) next
    yr <- sub(paste0("^", rel, "_y"), "", term)
    tval <- est / se
    pval <- 2 * pt(abs(tval), df = max(length(unique(dat$event_id)) - 1, 1), lower.tail = FALSE)
    tr <- dat[[term]] == 1
    rows[[length(rows) + 1]] <- data.frame(
      relation = rel,
      year = yr,
      sample = sample_name,
      outcome = y,
      coef = est,
      se = se,
      p = pval,
      n = nobs(fit),
      n_events = length(unique(dat$event_id)),
      year_events = length(unique(dat$event_id[dat$release_year == yr])),
      treated = sum(tr, na.rm = TRUE),
      treated_tickers = length(unique(dat$ticker[tr])),
      stringsAsFactors = FALSE
    )
  }
  if (length(rows)) do.call(rbind, rows) else NULL
}

rows <- list()
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat <- prep_sample(sample_name, y)
    for (rel in rels) {
      if (!(rel %in% names(dat)) || sum(dat[[rel]] == 1, na.rm = TRUE) == 0) next
      rows[[length(rows) + 1]] <- fit_one(dat, y, rel, sample_name)
    }
  }
}

out <- do.call(rbind, rows)
out$q_relation <- ave(out$p, out$relation, FUN = function(x) p.adjust(x, "BH"))
write.csv(out, out_path, row.names = FALSE)

summary <- aggregate(
  cbind(median_coef = coef, p05_share = p < 0.05, positive_share = coef > 0) ~ relation + year,
  data = transform(out, p05_share = as.numeric(p < 0.05), positive_share = as.numeric(coef > 0)),
  FUN = function(x) c(median = median(x, na.rm = TRUE), mean = mean(x, na.rm = TRUE))
)
write.csv(summary, summary_path, row.names = FALSE)

notes <- c(
  "# Relationship Year-Shape Notes",
  "",
  "本补跑直接估计关系变量在每个年份内的事件固定效应系数，避免把 2024 与 2025-2026 混在 post 指标中。",
  sprintf("- Results: `%s`", out_path),
  sprintf("- Summary: `%s`", summary_path)
)
writeLines(notes, notes_path)

cat("yearshape_rows=", nrow(out), "\n", sep = "")
cat("results=", out_path, "\n", sep = "")
