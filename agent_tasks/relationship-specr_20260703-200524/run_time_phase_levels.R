#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(lmtest)
  library(sandwich)
})

args <- commandArgs(trailingOnly = FALSE)
script_arg <- args[grep("--file=", args)]
script_path <- if (length(script_arg)) sub("--file=", "", script_arg[1]) else
  "agent_tasks/relationship-specr_20260703-200524/run_time_phase_levels.R"
task_dir <- normalizePath(dirname(script_path))
root <- normalizePath(file.path(task_dir, "..", ".."))
panel_path <- file.path(root, "Analysis", "processed", "event_firm_panel.csv")
out_path <- file.path(task_dir, "time_phase_level_results.csv")
summary_path <- file.path(task_dir, "time_phase_level_summary.csv")
notes_path <- file.path(task_dir, "time_phase_level_notes.md")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)
num_cols <- unique(c(
  grep("^car_", names(df), value = TRUE),
  "size_log_assets", "bm_ratio", "volatility", "momentum", "aa_intelligence_index",
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner"
))
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$event_date <- as.Date(df$event_trading_date)
df$release_year <- substr(df$event_trading_date, 1, 4)
df$phase <- ifelse(df$event_date < as.Date("2024-01-01"), "p2022_2023",
            ifelse(df$event_date < as.Date("2025-01-01"), "p2024",
            ifelse(df$event_date < as.Date("2026-01-01"), "p2025", "p2026")))
phases <- c("p2022_2023", "p2024", "p2025", "p2026")
for (ph in phases) df[[ph]] <- as.numeric(df$phase == ph)
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
df$intel_high <- as.numeric(df$aa_intelligence_index >= median(df$aa_intelligence_index, na.rm = TRUE))

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
outcomes <- intersect(
  c("car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
    "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_soxx_0_20"),
  names(df)
)
core_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
time_rels <- c(
  "rel_upstream_hardware", "upstream_any", "strategic_any",
  "downstream_any", "rel_downstream_deployer", "rel_downstream_integrator",
  "rel_competitor"
)
controls <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum"

prep_sample <- function(sample_name, y, need_intel = FALSE) {
  dat <- df[base_filter & sample_defs[[sample_name]], ]
  dat <- dat[!is.na(dat[[y]]), ]
  dat$bm_missing <- as.numeric(is.na(dat$bm_ratio))
  dat$bm_ratio[is.na(dat$bm_ratio)] <- 0
  if (need_intel) dat <- dat[!is.na(dat$aa_intelligence_index), ]
  dat$intel_c <- dat$aa_intelligence_index - mean(dat$aa_intelligence_index, na.rm = TRUE)
  dat
}

fit_terms <- function(dat, y, rhs, terms, family, sample_name, fe_type, treat_fun) {
  if (nrow(dat) < 400 || length(unique(dat$event_id)) < 8) return(NULL)
  fit <- tryCatch(suppressWarnings(lm(as.formula(paste(y, "~", rhs)), data = dat)), error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  vc <- tryCatch(suppressWarnings(vcovCL(fit, cluster = dat$event_id, type = "HC0")), error = function(e) NULL)
  if (is.null(vc)) return(NULL)
  ct <- tryCatch(suppressWarnings(coeftest(fit, vcov. = vc)), error = function(e) NULL)
  if (is.null(ct)) return(NULL)
  out <- list()
  for (term in terms) {
    if (!(term %in% rownames(ct))) next
    est <- ct[term, 1]
    se <- ct[term, 2]
    if (!is.finite(est) || !is.finite(se) || se <= 0) next
    pval <- 2 * pt(abs(est / se), df = max(length(unique(dat$event_id)) - 1, 1), lower.tail = FALSE)
    tr <- treat_fun(dat, term)
    ph <- sub("^.*__(p[0-9_]+)$", "\\1", term)
    out[[length(out) + 1]] <- data.frame(
      family = family,
      sample = sample_name,
      outcome = y,
      term = term,
      phase = ph,
      fe_type = fe_type,
      coef = est,
      se = se,
      p = pval,
      n = nobs(fit),
      n_events = length(unique(dat$event_id)),
      phase_events = length(unique(dat$event_id[dat[[ph]] == 1])),
      treated_events = length(unique(dat$event_id[tr])),
      treated_tickers = length(unique(dat$ticker[tr])),
      stringsAsFactors = FALSE
    )
  }
  if (length(out)) do.call(rbind, out) else NULL
}

rows <- list()
add <- function(x) if (!is.null(x) && nrow(x) > 0) rows[[length(rows) + 1]] <<- x

for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (rel in time_rels) {
      rel_terms <- c()
      for (ph in phases) {
        nm <- paste0(rel, "__", ph)
        dat[[nm]] <- as.numeric(dat[[rel]] == 1 & dat[[ph]] == 1)
        rel_terms <- c(rel_terms, nm)
      }
      active <- rel_terms[sapply(rel_terms, function(z) sum(dat[[z]] == 1, na.rm = TRUE) > 0)]
      if (length(active) == 0) next
      rhs <- paste(c(active, setdiff(core_rels, rel), controls, "factor(event_id)"), collapse = " + ")
      add(fit_terms(dat, y, rhs, active, "relation_phase_level", sample_name, "event",
                    function(d, term) d[[term]] == 1))
    }

    dat_i <- prep_sample(sample_name, y, need_intel = TRUE)
    if (nrow(dat_i) == 0) next
    for (aa in c("intel_c", "intel_high")) {
      aa_terms <- c()
      for (ph in phases) {
        nm <- paste0(aa, "__", ph)
        dat_i[[nm]] <- dat_i[[aa]] * dat_i[[ph]]
        aa_terms <- c(aa_terms, nm)
      }
      rhs <- paste(c(aa_terms, core_rels, controls,
                     "factor(release_year)", "factor(aa_creators)", "factor(gics_sector)"), collapse = " + ")
      add(fit_terms(dat_i, y, rhs, aa_terms, "aa_phase_level", sample_name, "year_creator_sector",
                    function(d, term) {
                      ph <- sub("^.*__(p[0-9_]+)$", "\\1", term)
                      d[[ph]] == 1 & !is.na(d[[sub("__.*$", "", term)]])
                    }))
    }
  }
}

out <- do.call(rbind, rows)
out$q_family <- ave(out$p, out$family, FUN = function(x) p.adjust(x, "BH"))
out$q_term <- ave(out$p, interaction(out$family, out$term, drop = TRUE), FUN = function(x) p.adjust(x, "BH"))
write.csv(out, out_path, row.names = FALSE)

summary <- aggregate(
  cbind(median_coef = coef, p05_share = as.numeric(p < 0.05), positive_share = as.numeric(coef > 0)) ~
    family + term + phase,
  data = out,
  FUN = function(x) c(median = median(x, na.rm = TRUE), mean = mean(x, na.rm = TRUE))
)
write.csv(summary, summary_path, row.names = FALSE)

notes <- c(
  "# Time Phase Level Notes",
  "",
  "本补跑估计每个阶段内的关系效应和 AA 斜率。不同于 `time_heterogeneity_all_results.csv` 中的 phase interaction，这里不是相对 2022-2023 的差值。",
  sprintf("- Results: `%s`", out_path),
  sprintf("- Summary: `%s`", summary_path)
)
writeLines(notes, notes_path)

cat("phase_level_rows=", nrow(out), "\n", sep = "")
cat("results=", out_path, "\n", sep = "")
