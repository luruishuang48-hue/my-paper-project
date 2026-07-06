#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(lmtest)
  library(sandwich)
})

args <- commandArgs(trailingOnly = FALSE)
script_arg <- args[grep("--file=", args)]
script_path <- if (length(script_arg)) sub("--file=", "", script_arg[1]) else
  "agent_tasks/relationship-specr_20260703-200524/run_time_heterogeneity_specr.R"
task_dir <- normalizePath(dirname(script_path))
root <- normalizePath(file.path(task_dir, "..", ".."))
panel_path <- file.path(root, "Analysis", "processed", "event_firm_panel.csv")

all_path <- file.path(task_dir, "time_heterogeneity_all_results.csv")
profile_path <- file.path(task_dir, "time_heterogeneity_cutoff_profile.csv")
summary_path <- file.path(task_dir, "time_heterogeneity_summary.csv")
validation_path <- file.path(task_dir, "time_heterogeneity_validation.csv")
notes_path <- file.path(task_dir, "time_heterogeneity_notes.md")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- unique(c(
  grep("^car_", names(df), value = TRUE),
  "size_log_assets", "bm_ratio", "volatility", "momentum", "aa_intelligence_index",
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner",
  "is_open_weight_or_open_source", "is_chinese_model", "is_reasoning_model",
  "is_media_generation_model", "is_multimodal", "is_model_family"
))
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$event_date <- as.Date(df$event_trading_date)
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

event_order <- unique(df[, c("event_id", "event_date")])
event_order <- event_order[order(event_order$event_date, event_order$event_id), ]
event_order$event_seq <- seq_len(nrow(event_order))
event_order$time_01 <- (event_order$event_seq - min(event_order$event_seq)) /
  (max(event_order$event_seq) - min(event_order$event_seq))
df <- merge(df, event_order[, c("event_id", "event_seq", "time_01")], by = "event_id", all.x = TRUE, sort = FALSE)
df$time_z <- as.numeric(scale(df$time_01))
df$phase <- ifelse(df$event_date < as.Date("2024-01-01"), "phase_2022_2023",
            ifelse(df$event_date < as.Date("2025-01-01"), "phase_2024",
            ifelse(df$event_date < as.Date("2026-01-01"), "phase_2025", "phase_2026")))
for (ph in c("phase_2022_2023", "phase_2024", "phase_2025", "phase_2026")) {
  df[[ph]] <- as.numeric(df$phase == ph)
}
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
  "rel_competitor", "platform_bigtech"
)
cutoff_dates <- as.Date(c(
  "2024-01-01", "2024-04-01", "2024-07-01", "2024-10-01",
  "2025-01-01", "2025-04-01", "2025-07-01", "2025-10-01", "2026-01-01"
))
phase_terms <- c("phase_2024", "phase_2025", "phase_2026")
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

support_for <- function(dat, treat) {
  list(
    n_treated = sum(treat, na.rm = TRUE),
    treated_events = length(unique(dat$event_id[treat])),
    treated_tickers = length(unique(dat$ticker[treat]))
  )
}

fit_term <- function(dat, y, rhs, term, family, sample_name, moderator, fe_type, treatment = NULL) {
  if (nrow(dat) < 400 || length(unique(dat$event_id)) < 8 || length(unique(dat$ticker)) < 12) return(NULL)
  fit <- tryCatch(suppressWarnings(lm(as.formula(paste(y, "~", rhs)), data = dat)), error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  vc <- tryCatch(suppressWarnings(vcovCL(fit, cluster = dat$event_id, type = "HC0")), error = function(e) NULL)
  if (is.null(vc)) return(NULL)
  ct <- tryCatch(suppressWarnings(coeftest(fit, vcov. = vc)), error = function(e) NULL)
  if (is.null(ct) || !(term %in% rownames(ct))) return(NULL)
  est <- ct[term, 1]
  se <- ct[term, 2]
  if (!is.finite(est) || !is.finite(se) || se <= 0) return(NULL)
  pval <- 2 * pt(abs(est / se), df = max(length(unique(dat$event_id)) - 1, 1), lower.tail = FALSE)
  if (is.null(treatment)) treatment <- rep(FALSE, nrow(dat))
  sup <- support_for(dat, treatment)
  data.frame(
    family = family,
    sample = sample_name,
    outcome = y,
    term = term,
    moderator = moderator,
    fe_type = fe_type,
    coef = est,
    se = se,
    p = pval,
    n = nobs(fit),
    n_events = length(unique(dat$event_id)),
    n_tickers = length(unique(dat$ticker)),
    n_treated = sup$n_treated,
    treated_events = sup$treated_events,
    treated_tickers = sup$treated_tickers,
    rhs = rhs,
    stringsAsFactors = FALSE
  )
}

rows <- list()
add <- function(x) {
  if (!is.null(x) && nrow(x) > 0) rows[[length(rows) + 1]] <<- x
}

cat("Running relation cutoff SPECR...\n")
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat0 <- prep_sample(sample_name, y)
    if (nrow(dat0) == 0) next
    for (cutoff in cutoff_dates) {
      dat <- dat0
      dat$post_cutoff <- as.numeric(dat$event_date >= cutoff)
      pre_events <- length(unique(dat$event_id[dat$post_cutoff == 0]))
      post_events <- length(unique(dat$event_id[dat$post_cutoff == 1]))
      if (pre_events < 8 || post_events < 8) next
      for (rel in time_rels) {
        if (!(rel %in% names(dat)) || sum(dat[[rel]] == 1, na.rm = TRUE) == 0) next
        term <- paste0(rel, ":post_cutoff")
        rhs <- paste(c(paste0(rel, "*post_cutoff"), setdiff(core_rels, rel),
                       controls, "factor(event_id)"), collapse = " + ")
        treat <- dat[[rel]] == 1 & dat$post_cutoff == 1
        add(fit_term(dat, y, rhs, term, "relation_cutoff", sample_name,
                     as.character(cutoff), "event", treat))
      }
    }
  }
}

cat("Running relation continuous trend SPECR...\n")
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (rel in time_rels) {
      if (!(rel %in% names(dat)) || sum(dat[[rel]] == 1, na.rm = TRUE) == 0) next
      term <- paste0(rel, ":time_z")
      rhs <- paste(c(paste0(rel, "*time_z"), setdiff(core_rels, rel),
                     controls, "factor(event_id)"), collapse = " + ")
      treat <- dat[[rel]] == 1
      add(fit_term(dat, y, rhs, term, "relation_trend", sample_name,
                   "time_z", "event", treat))
    }
  }
}

cat("Running relation phase SPECR...\n")
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (rel in time_rels) {
      if (!(rel %in% names(dat)) || sum(dat[[rel]] == 1, na.rm = TRUE) == 0) next
      rhs <- paste(c(paste0(rel, "*(", paste(phase_terms, collapse = " + "), ")"),
                     setdiff(core_rels, rel), controls, "factor(event_id)"), collapse = " + ")
      for (ph in phase_terms) {
        term <- paste0(rel, ":", ph)
        treat <- dat[[rel]] == 1 & dat[[ph]] == 1
        add(fit_term(dat, y, rhs, term, "relation_phase", sample_name,
                     ph, "event", treat))
      }
    }
  }
}

cat("Running AA cutoff and trend SPECR...\n")
aa_vars <- c("intel_c", "intel_high")
aa_fe <- list(
  year = "factor(release_year)",
  year_sector = "factor(release_year) + factor(gics_sector)",
  year_creator_sector = "factor(release_year) + factor(aa_creators) + factor(gics_sector)"
)
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat0 <- prep_sample(sample_name, y, need_intel = TRUE)
    if (nrow(dat0) == 0 || length(unique(dat0$event_id)) < 8) next
    for (cutoff in cutoff_dates) {
      dat <- dat0
      dat$post_cutoff <- as.numeric(dat$event_date >= cutoff)
      pre_events <- length(unique(dat$event_id[dat$post_cutoff == 0]))
      post_events <- length(unique(dat$event_id[dat$post_cutoff == 1]))
      if (pre_events < 8 || post_events < 8) next
      for (aa in aa_vars) {
        if (length(unique(na.omit(dat[[aa]]))) < 2) next
        for (fe_name in names(aa_fe)) {
          term <- paste0(aa, ":post_cutoff")
          rhs <- paste(c(paste0(aa, "*post_cutoff"), core_rels, controls, aa_fe[[fe_name]]), collapse = " + ")
          treat <- dat$post_cutoff == 1 & !is.na(dat[[aa]])
          add(fit_term(dat, y, rhs, term, "aa_cutoff", sample_name,
                       as.character(cutoff), fe_name, treat))
        }
      }
    }
    for (aa in aa_vars) {
      if (length(unique(na.omit(dat0[[aa]]))) < 2) next
      for (fe_name in names(aa_fe)) {
        term <- paste0(aa, ":time_z")
        rhs <- paste(c(paste0(aa, "*time_z"), core_rels, controls, aa_fe[[fe_name]]), collapse = " + ")
        add(fit_term(dat0, y, rhs, term, "aa_trend", sample_name,
                     "time_z", fe_name, !is.na(dat0[[aa]])))
      }
      rhs_phase <- paste(c(paste0(aa, "*(", paste(phase_terms, collapse = " + "), ")"),
                           core_rels, controls, "factor(gics_sector)"), collapse = " + ")
      for (ph in phase_terms) {
        term <- paste0(aa, ":", ph)
        treat <- dat0[[ph]] == 1 & !is.na(dat0[[aa]])
        add(fit_term(dat0, y, rhs_phase, term, "aa_phase", sample_name,
                     ph, "sector", treat))
      }
    }
  }
}

all <- if (length(rows)) do.call(rbind, rows) else data.frame()
if (nrow(all) == 0) stop("No valid specs.")
all$q_family <- ave(all$p, all$family, FUN = function(x) p.adjust(x, "BH"))
all$q_term <- ave(all$p, interaction(all$family, all$term, drop = TRUE), FUN = function(x) p.adjust(x, "BH"))
all$q_global <- p.adjust(all$p, "BH")
all$direction <- ifelse(all$coef > 0, "positive", "negative")
write.csv(all, all_path, row.names = FALSE)

aggregate_summary <- function(dat) {
  keys <- unique(dat[, c("family", "term")])
  out <- lapply(seq_len(nrow(keys)), function(i) {
    sub <- dat[dat$family == keys$family[i] & dat$term == keys$term[i], ]
    best <- sub[which.min(sub$p), ]
    data.frame(
      family = keys$family[i],
      term = keys$term[i],
      n_specs = nrow(sub),
      median_coef = median(sub$coef, na.rm = TRUE),
      positive_share = mean(sub$coef > 0, na.rm = TRUE),
      p05_share = mean(sub$p < 0.05, na.rm = TRUE),
      q10_family_share = mean(sub$q_family < 0.10, na.rm = TRUE),
      min_p = min(sub$p, na.rm = TRUE),
      min_q_family = min(sub$q_family, na.rm = TRUE),
      min_q_term = min(sub$q_term, na.rm = TRUE),
      min_q_global = min(sub$q_global, na.rm = TRUE),
      best_moderator = best$moderator,
      best_sample = best$sample,
      best_outcome = best$outcome,
      best_fe = best$fe_type,
      best_coef = best$coef,
      best_p = best$p,
      best_q_family = best$q_family,
      best_n = best$n,
      best_events = best$n_events,
      best_treated_events = best$treated_events,
      best_treated_tickers = best$treated_tickers,
      best_rhs = best$rhs,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

summary <- aggregate_summary(all)
summary$risk_flag <- ""
summary$risk_flag[grepl("^intel_", summary$term)] <- "aa_event_level"
summary$risk_flag[summary$best_treated_events < 20 | summary$best_treated_tickers < 6] <-
  paste(summary$risk_flag[summary$best_treated_events < 20 | summary$best_treated_tickers < 6],
        "low_support", sep = ";")
summary$risk_flag <- sub("^;+", "", summary$risk_flag)
summary <- summary[order(summary$min_q_family, summary$min_p, -summary$p05_share), ]
write.csv(summary, summary_path, row.names = FALSE)

cutoff <- all[all$family %in% c("relation_cutoff", "aa_cutoff"), ]
profile <- aggregate(
  cbind(median_coef = coef, p05_share = as.numeric(p < 0.05), positive_share = as.numeric(coef > 0)) ~
    family + term + moderator,
  data = cutoff,
  FUN = function(x) c(median = median(x, na.rm = TRUE), mean = mean(x, na.rm = TRUE))
)
write.csv(profile, profile_path, row.names = FALSE)

candidates <- summary[summary$min_q_family < 0.10 | summary$p05_share >= 0.30, ]
validation_rows <- list()
if (nrow(candidates) > 0) {
  for (i in seq_len(nrow(candidates))) {
    br <- candidates[i, ]
    sub <- all[all$family == br$family & all$term == br$term, ]
    val <- aggregate(cbind(coef = coef, p = p, q_family = q_family) ~ moderator, sub,
                     FUN = function(x) c(median = median(x, na.rm = TRUE), min = min(x, na.rm = TRUE)))
    val$family <- br$family
    val$term <- br$term
    validation_rows[[length(validation_rows) + 1]] <- val
  }
}
validation <- if (length(validation_rows)) do.call(rbind, validation_rows) else data.frame()
write.csv(validation, validation_path, row.names = FALSE)

notes <- c(
  "# Time Heterogeneity SPECR Notes",
  "",
  "本轮专门检验市场对模型发布的认知是否随时间变化。",
  "",
  sprintf("- Input panel: `%s`", panel_path),
  sprintf("- Successful specs: %d", nrow(all)),
  sprintf("- Full results: `%s`", all_path),
  sprintf("- Summary: `%s`", summary_path),
  sprintf("- Cutoff profile: `%s`", profile_path),
  sprintf("- Validation: `%s`", validation_path),
  "",
  "关系变量使用事件固定效应，AA 指标是事件层变量，因此 AA 规格使用年份、发布方和行业固定效应组合。"
)
writeLines(notes, notes_path)

cat("successful_specs=", nrow(all), "\n", sep = "")
cat("summary=", summary_path, "\n", sep = "")
cat("profile=", profile_path, "\n", sep = "")
