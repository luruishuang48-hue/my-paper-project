#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(lmtest)
  library(sandwich)
})

args <- commandArgs(trailingOnly = FALSE)
script_arg <- args[grep("--file=", args)]
script_path <- if (length(script_arg)) sub("--file=", "", script_arg[1]) else
  "agent_tasks/relationship-specr_20260703-200524/run_relationship_specr_extended.R"
task_dir <- normalizePath(dirname(script_path))
root <- normalizePath(file.path(task_dir, "..", ".."))
panel_path <- file.path(root, "Analysis", "processed", "event_firm_panel.csv")

all_path <- file.path(task_dir, "specr_extended_all_results.csv")
summary_path <- file.path(task_dir, "specr_extended_candidate_summary.csv")
validation_path <- file.path(task_dir, "specr_extended_validation.csv")
rollup_path <- file.path(task_dir, "specr_extended_family_rollup.csv")
notes_path <- file.path(task_dir, "specr_extended_run_notes.md")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- unique(c(
  grep("^car_", names(df), value = TRUE),
  "size_log_assets", "bm_ratio", "volatility", "momentum", "aa_intelligence_index",
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner",
  "is_open_weight_or_open_source", "is_chinese_model", "is_reasoning_model",
  "is_media_generation_model", "is_multimodal", "is_model_family",
  "is_coding_model", "is_cross_modality_release"
))
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
df$post_2024 <- as.numeric(df$event_trading_date >= "2024-04-01")
df$post_2025 <- as.numeric(df$event_trading_date >= "2025-01-01")
df$upstream_any <- as.numeric(df$rel_upstream_hardware == 1 | df$rel_upstream_cloud == 1)
df$downstream_any <- as.numeric(
  df$rel_downstream_integrator == 1 |
    df$rel_downstream_deployer == 1 |
    df$rel_downstream_enabler == 1
)
df$capital_link <- as.numeric(df$rel_is_investor == 1 | df$rel_is_owner == 1)
df$related_any <- as.numeric(
  df$upstream_any == 1 | df$downstream_any == 1 | df$rel_competitor == 1 |
    df$capital_link == 1
)
df$platform_bigtech <- as.numeric(
  df$rel_upstream_cloud == 1 | df$rel_competitor == 1 |
    df$rel_is_investor == 1 | df$rel_is_owner == 1
)
df$strategic_any <- as.numeric(df$upstream_any == 1 | df$rel_competitor == 1 | df$capital_link == 1)
df$hardware_sox <- as.numeric(df$rel_upstream_hardware == 1 & df$index_tag %in% c("both", "sox_only"))
df$hardware_nonsox <- as.numeric(df$rel_upstream_hardware == 1 & !(df$index_tag %in% c("both", "sox_only")))
df$intel_high <- as.numeric(df$aa_intelligence_index >= median(df$aa_intelligence_index, na.rm = TRUE))

core_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
single_rels <- c(
  core_rels, "upstream_any", "downstream_any", "capital_link", "related_any",
  "platform_bigtech", "strategic_any", "hardware_sox", "hardware_nonsox"
)

outcomes <- c(
  "car_mm_spy_0_5", "car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
  "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_soxx_0_20"
)
outcomes <- intersect(outcomes, names(df))
placebo_outcomes <- intersect(
  c("car_mm_spy_pre_m10_m2", "car_ff3_pre_m10_m2", "car_mm_qqq_pre_m10_m2", "car_mm_soxx_pre_m10_m2"),
  names(df)
)

sample_defs <- list(
  main = rep(TRUE, nrow(df)),
  post_2024 = df$event_trading_date >= "2024-04-01",
  early_2022_2024 = df$event_trading_date < "2025-01-01",
  late_2025_2026 = df$event_trading_date >= "2025-01-01",
  high_date = df$date_confidence == "high",
  no_multi_component = df$multi_component_date_flag == "False",
  llm_events = df$aa_metric_type == "llm",
  media_events = df$aa_metric_type == "media",
  reasoning_events = df$is_reasoning_model == 1,
  open_events = df$is_open_weight_or_open_source == 1,
  closed_events = df$is_open_weight_or_open_source == 0,
  chinese_events = df$is_chinese_model == 1,
  non_chinese_events = df$is_chinese_model == 0
)

base_filter <- df$is_main_nasdaq100 == "True" &
  df$event_excluded_identity == "False" &
  !is.na(df$size_log_assets) &
  !is.na(df$volatility) &
  !is.na(df$momentum)

prep_sample <- function(sample_name, y, need_intel = FALSE) {
  dat <- df[base_filter & sample_defs[[sample_name]], ]
  dat <- dat[!is.na(dat[[y]]), ]
  dat$bm_missing <- as.numeric(is.na(dat$bm_ratio))
  dat$bm_ratio[is.na(dat$bm_ratio)] <- 0
  if (need_intel) dat <- dat[!is.na(dat$aa_intelligence_index), ]
  dat$intel_c <- dat$aa_intelligence_index - mean(dat$aa_intelligence_index, na.rm = TRUE)
  dat
}

term_support <- function(dat, term) {
  parts <- strsplit(term, ":", fixed = TRUE)[[1]]
  if (length(parts) == 1 && parts[1] %in% names(dat)) {
    treat <- dat[[parts[1]]] == 1
  } else if (length(parts) == 2 && all(parts %in% names(dat))) {
    left <- dat[[parts[1]]] == 1
    right_values <- sort(unique(na.omit(dat[[parts[2]]])))
    if (length(right_values) <= 2 && all(right_values %in% c(0, 1))) {
      treat <- left & dat[[parts[2]]] == 1
    } else {
      treat <- left & !is.na(dat[[parts[2]]])
    }
  } else {
    treat <- rep(FALSE, nrow(dat))
  }
  list(
    n_treated = sum(treat, na.rm = TRUE),
    treated_events = length(unique(dat$event_id[treat])),
    treated_tickers = length(unique(dat$ticker[treat])),
    top_tickers = names(sort(table(dat$ticker[treat]), decreasing = TRUE)),
    top_creators = names(sort(table(dat$aa_creators[treat]), decreasing = TRUE))
  )
}

parse_outcome <- function(y) {
  benchmark <- sub("^(car_[^_]+_[^_]+).*", "\\1", y)
  window <- sub("^car_[^_]+_[^_]+_", "", y)
  if (grepl("^car_ff3_", y)) {
    benchmark <- "car_ff3"
    window <- sub("^car_ff3_", "", y)
  }
  if (grepl("pre_m10_m2", y)) window <- "pre_m10_m2"
  c(benchmark = benchmark, window = window)
}

fit_term <- function(dat, y, rhs, term, family, sample_name, fe_type, control_variant, note = "") {
  if (nrow(dat) < 400 || length(unique(dat$event_id)) < 8 || length(unique(dat$ticker)) < 12) return(NULL)
  fml <- as.formula(paste(y, "~", rhs))
  fit <- tryCatch(suppressWarnings(lm(fml, data = dat)), error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  vc <- tryCatch(suppressWarnings(vcovCL(fit, cluster = dat$event_id, type = "HC0")), error = function(e) NULL)
  if (is.null(vc)) return(NULL)
  ct <- tryCatch(suppressWarnings(coeftest(fit, vcov. = vc)), error = function(e) NULL)
  if (is.null(ct) || !(term %in% rownames(ct))) return(NULL)
  est <- ct[term, 1]
  se <- ct[term, 2]
  if (!is.finite(est) || !is.finite(se) || se <= 0) return(NULL)
  tval <- est / se
  df_c <- max(length(unique(dat$event_id)) - 1, 1)
  pval <- 2 * pt(abs(tval), df = df_c, lower.tail = FALSE)
  sup <- term_support(dat, term)
  yw <- parse_outcome(y)
  data.frame(
    family = family,
    sample = sample_name,
    outcome = y,
    benchmark = yw["benchmark"],
    window = yw["window"],
    fe = fe_type,
    control_variant = control_variant,
    term = term,
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
    note = note,
    stringsAsFactors = FALSE
  )
}

rows <- list()
add <- function(x) {
  if (!is.null(x) && nrow(x) > 0) rows[[length(rows) + 1]] <<- x
}

controls <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum"
fe_year <- "factor(release_year)"
fe_event <- "factor(event_id)"
fe_sector <- "factor(gics_sector)"
fe_creator <- "factor(aa_creators)"

single_variants <- list(
  year_core = list(fe = fe_year, fe_type = "year", extra = "", need_intel = FALSE),
  event_core = list(fe = fe_event, fe_type = "event", extra = "", need_intel = FALSE),
  year_sector = list(fe = paste(fe_year, fe_sector, sep = " + "), fe_type = "year_sector", extra = "", need_intel = FALSE),
  year_creator = list(fe = paste(fe_year, fe_creator, sep = " + "), fe_type = "year_creator", extra = "", need_intel = FALSE)
)

cat("Running extended single and bundle screens...\n")
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    for (variant_name in names(single_variants)) {
      variant <- single_variants[[variant_name]]
      dat <- prep_sample(sample_name, y, need_intel = variant$need_intel)
      if (nrow(dat) == 0) next
      for (term in single_rels) {
        if (!(term %in% names(dat)) || sum(dat[[term]] == 1, na.rm = TRUE) == 0 ||
            length(unique(na.omit(dat[[term]]))) < 2) next
        rhs <- paste(c(term, controls, variant$extra, variant$fe), collapse = " + ")
        add(fit_term(dat, y, rhs, term, "single_extended", sample_name,
                     variant$fe_type, variant_name))
      }
    }
  }
}

joint_variants <- list(
  year_core = list(fe = fe_year, fe_type = "year"),
  event_core = list(fe = fe_event, fe_type = "event"),
  year_sector = list(fe = paste(fe_year, fe_sector, sep = " + "), fe_type = "year_sector"),
  year_creator = list(fe = paste(fe_year, fe_creator, sep = " + "), fe_type = "year_creator")
)

cat("Running joint position screens...\n")
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    active_core <- core_rels[sapply(core_rels, function(z) {
      z %in% names(dat) && sum(dat[[z]] == 1, na.rm = TRUE) > 0 && length(unique(na.omit(dat[[z]]))) > 1
    })]
    if (length(active_core) == 0) next
    for (variant_name in names(joint_variants)) {
      variant <- joint_variants[[variant_name]]
      rhs <- paste(c(active_core, controls, variant$fe), collapse = " + ")
      for (term in active_core) {
        add(fit_term(dat, y, rhs, term, "joint_extended", sample_name,
                     variant$fe_type, variant_name))
      }
    }
  }
}

cat("Running placebo pre-window screens...\n")
for (sample_name in c("main", "post_2024", "late_2025_2026", "high_date")) {
  for (y in placebo_outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (term in single_rels) {
      if (!(term %in% names(dat)) || sum(dat[[term]] == 1, na.rm = TRUE) == 0 ||
          length(unique(na.omit(dat[[term]]))) < 2) next
      for (fe_pair in list(c("year", fe_year), c("event", fe_event))) {
        rhs <- paste(c(term, controls, fe_pair[2]), collapse = " + ")
        add(fit_term(dat, y, rhs, term, "pre_placebo", sample_name,
                     fe_pair[1], paste0("pre_", fe_pair[1])))
      }
    }
  }
}

cat("Running wider interaction screens...\n")
interaction_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "upstream_any", "downstream_any",
  "platform_bigtech", "strategic_any"
)
moderators <- c(
  "post_2024", "post_2025", "is_open_weight_or_open_source", "is_reasoning_model",
  "is_chinese_model", "is_media_generation_model", "is_multimodal", "is_model_family",
  "intel_high"
)
interaction_samples <- c("main", "high_date", "no_multi_component", "post_2024", "llm_events")
interaction_outcomes <- intersect(
  c("car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
    "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_soxx_0_20"),
  names(df)
)
for (sample_name in interaction_samples) {
  for (y in interaction_outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (r in interaction_rels) {
      if (!(r %in% names(dat)) || sum(dat[[r]] == 1, na.rm = TRUE) == 0 ||
          length(unique(na.omit(dat[[r]]))) < 2) next
      for (m in moderators) {
        if (!(m %in% names(dat)) || sum(dat[[m]] == 1, na.rm = TRUE) == 0 ||
            length(unique(na.omit(dat[[m]]))) < 2) next
        term <- paste0(r, ":", m)
        controls_rels <- setdiff(core_rels, r)
        rhs <- paste(c(paste0(r, "*", m), controls_rels, controls, fe_event), collapse = " + ")
        add(fit_term(dat, y, rhs, term, "interaction_wide", sample_name,
                     "event", "event_core"))
      }
    }
  }
}

cat("Running continuous ability interaction screens...\n")
ability_rels <- interaction_rels
ability_samples <- c("main", "llm_events", "late_2025_2026", "open_events", "closed_events")
ability_outcomes <- intersect(
  c("car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
    "car_ff3_0_20", "car_mm_qqq_0_20"),
  names(df)
)
for (sample_name in ability_samples) {
  for (y in ability_outcomes) {
    dat <- prep_sample(sample_name, y, need_intel = TRUE)
    if (nrow(dat) == 0) next
    for (r in ability_rels) {
      if (!(r %in% names(dat)) || sum(dat[[r]] == 1, na.rm = TRUE) == 0 ||
          length(unique(na.omit(dat[[r]]))) < 2) next
      term <- paste0(r, ":intel_c")
      controls_rels <- setdiff(core_rels, r)
      rhs <- paste(c(paste0(r, "*intel_c"), controls_rels, controls, fe_event), collapse = " + ")
      add(fit_term(dat, y, rhs, term, "ability_interaction", sample_name,
                   "event", "event_core_intel"))
    }
  }
}

all <- if (length(rows)) do.call(rbind, rows) else data.frame()
if (nrow(all) == 0) stop("No valid specifications completed.")
all$q_global <- p.adjust(all$p, method = "BH")
all$q_family <- ave(all$p, all$family, FUN = function(x) p.adjust(x, method = "BH"))
all$q_family_term <- ave(all$p, interaction(all$family, all$term, drop = TRUE),
                         FUN = function(x) p.adjust(x, method = "BH"))
all$sig_p05 <- all$p < 0.05
all$sig_q10_family <- all$q_family < 0.10
all$direction <- ifelse(all$coef > 0, "positive", "negative")
write.csv(all, all_path, row.names = FALSE)

aggregate_summary <- function(dat) {
  keys <- unique(dat[, c("family", "term")])
  out <- lapply(seq_len(nrow(keys)), function(i) {
    sub <- dat[dat$family == keys$family[i] & dat$term == keys$term[i], ]
    best <- sub[which.min(sub$p), ]
    event_sub <- sub[sub$fe == "event", ]
    year_sub <- sub[sub$fe == "year", ]
    sector_sub <- sub[sub$fe == "year_sector", ]
    creator_sub <- sub[sub$fe == "year_creator", ]
    data.frame(
      family = keys$family[i],
      term = keys$term[i],
      n_specs = nrow(sub),
      median_coef = median(sub$coef, na.rm = TRUE),
      positive_share = mean(sub$coef > 0, na.rm = TRUE),
      p05_share = mean(sub$p < 0.05, na.rm = TRUE),
      q10_family_share = mean(sub$q_family < 0.10, na.rm = TRUE),
      event_p05_share = if (nrow(event_sub)) mean(event_sub$p < 0.05, na.rm = TRUE) else NA_real_,
      year_p05_share = if (nrow(year_sub)) mean(year_sub$p < 0.05, na.rm = TRUE) else NA_real_,
      sector_p05_share = if (nrow(sector_sub)) mean(sector_sub$p < 0.05, na.rm = TRUE) else NA_real_,
      creator_p05_share = if (nrow(creator_sub)) mean(creator_sub$p < 0.05, na.rm = TRUE) else NA_real_,
      min_p = min(sub$p, na.rm = TRUE),
      min_q_family = min(sub$q_family, na.rm = TRUE),
      min_q_family_term = min(sub$q_family_term, na.rm = TRUE),
      min_q_global = min(sub$q_global, na.rm = TRUE),
      median_n = median(sub$n, na.rm = TRUE),
      median_events = median(sub$n_events, na.rm = TRUE),
      min_treated = min(sub$n_treated, na.rm = TRUE),
      min_treated_events = min(sub$treated_events, na.rm = TRUE),
      min_treated_tickers = min(sub$treated_tickers, na.rm = TRUE),
      best_sample = best$sample,
      best_outcome = best$outcome,
      best_benchmark = best$benchmark,
      best_window = best$window,
      best_fe = best$fe,
      best_control_variant = best$control_variant,
      best_coef = best$coef,
      best_se = best$se,
      best_p = best$p,
      best_q_family = best$q_family,
      best_q_family_term = best$q_family_term,
      best_n = best$n,
      best_events = best$n_events,
      best_treated = best$n_treated,
      best_treated_events = best$treated_events,
      best_treated_tickers = best$treated_tickers,
      best_rhs = best$rhs,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

summary <- aggregate_summary(all)
placebo <- summary[summary$family == "pre_placebo", c("term", "min_p", "p05_share")]
names(placebo) <- c("term", "placebo_min_p", "placebo_p05_share")
summary <- merge(summary, placebo, by = "term", all.x = TRUE, sort = FALSE)
summary$risk_flag <- ""
summary$risk_flag[summary$min_treated_tickers < 6 | summary$min_treated_events < 20] <-
  paste(summary$risk_flag[summary$min_treated_tickers < 6 | summary$min_treated_events < 20],
        "low_support", sep = ";")
summary$risk_flag[summary$term %in% c("rel_is_investor", "rel_is_owner", "capital_link")] <-
  paste(summary$risk_flag[summary$term %in% c("rel_is_investor", "rel_is_owner", "capital_link")],
        "low_support_relation", sep = ";")
summary$risk_flag[summary$best_sample %in% c("media_events", "chinese_events", "reasoning_events")] <-
  paste(summary$risk_flag[summary$best_sample %in% c("media_events", "chinese_events", "reasoning_events")],
        "narrow_event_slice", sep = ";")
summary$risk_flag[grepl("intel_c", summary$term, fixed = TRUE)] <-
  paste(summary$risk_flag[grepl("intel_c", summary$term, fixed = TRUE)], "ability_level_not_news", sep = ";")
summary$risk_flag[!is.na(summary$placebo_min_p) & summary$placebo_min_p < 0.05] <-
  paste(summary$risk_flag[!is.na(summary$placebo_min_p) & summary$placebo_min_p < 0.05],
        "pre_window_signal", sep = ";")
summary$risk_flag <- sub("^;+", "", summary$risk_flag)
summary <- summary[order(summary$min_q_family, summary$min_p, -summary$p05_share), ]
write.csv(summary, summary_path, row.names = FALSE)

rollup <- aggregate(
  cbind(n_specs = p, p05 = sig_p05, q10 = sig_q10_family, positive = coef > 0) ~ family,
  data = transform(all, p05 = as.numeric(sig_p05), q10 = as.numeric(sig_q10_family), positive = as.numeric(coef > 0)),
  FUN = function(x) c(count = length(x), mean = mean(x, na.rm = TRUE))
)
write.csv(rollup, rollup_path, row.names = FALSE)

candidates <- summary[
  summary$family != "pre_placebo" &
    (summary$min_q_family < 0.10 |
       summary$min_q_family_term < 0.10 |
       summary$p05_share >= 0.25 |
       (summary$min_p < 0.001 & (summary$positive_share <= 0.10 | summary$positive_share >= 0.90))),
]

validate_fit <- function(best_row, dat, label) {
  if (nrow(dat) < 400 || length(unique(dat$event_id)) < 8) {
    return(data.frame(validation = label, coef = NA, p = NA, n = nrow(dat), events = length(unique(dat$event_id))))
  }
  res <- fit_term(dat, best_row$best_outcome, best_row$best_rhs, best_row$term,
                  best_row$family, best_row$best_sample, best_row$best_fe,
                  best_row$best_control_variant)
  if (is.null(res)) {
    return(data.frame(validation = label, coef = NA, p = NA, n = nrow(dat), events = length(unique(dat$event_id))))
  }
  data.frame(validation = label, coef = res$coef, p = res$p, n = res$n, events = res$n_events)
}

validation_rows <- list()
if (nrow(candidates) > 0) {
  for (i in seq_len(nrow(candidates))) {
    br <- candidates[i, ]
    dat <- prep_sample(br$best_sample, br$best_outcome,
                       need_intel = grepl("intel_c", br$best_rhs, fixed = TRUE))
    vals <- list(validate_fit(br, dat, "best_spec"))
    for (yr in sort(unique(dat$release_year))) {
      vals[[length(vals) + 1]] <- validate_fit(br, dat[dat$release_year != yr, ], paste0("drop_year_", yr))
    }
    sup <- term_support(dat, br$term)
    for (tk in head(sup$top_tickers, 5)) {
      vals[[length(vals) + 1]] <- validate_fit(br, dat[dat$ticker != tk, ], paste0("drop_ticker_", tk))
    }
    for (cr in head(sup$top_creators, 5)) {
      vals[[length(vals) + 1]] <- validate_fit(br, dat[dat$aa_creators != cr, ], paste0("drop_creator_", make.names(cr)))
    }
    val <- do.call(rbind, vals)
    val$family <- br$family
    val$term <- br$term
    val$best_sample <- br$best_sample
    val$best_outcome <- br$best_outcome
    val$best_fe <- br$best_fe
    val$best_control_variant <- br$best_control_variant
    validation_rows[[length(validation_rows) + 1]] <- val
  }
}
validation <- if (length(validation_rows)) do.call(rbind, validation_rows) else data.frame()
write.csv(validation, validation_path, row.names = FALSE)

notes <- c(
  "# Extended Relationship SPECR Run Notes",
  "",
  "第二轮扩展用于回应“是否还有别的显著关系”。它有意比 tight 版本更宽，纳入旧稿式单项关系、bundle、更多窗口、行业固定效应、发布方固定效应、事件固定效应、pre-window placebo 和更宽的事件属性交互。",
  "",
  sprintf("- Input panel: `%s`", panel_path),
  sprintf("- Successful specs: %d", nrow(all)),
  sprintf("- Candidate groups: %d", nrow(candidates)),
  sprintf("- Full results: `%s`", all_path),
  sprintf("- Candidate summary: `%s`", summary_path),
  sprintf("- Validation: `%s`", validation_path),
  sprintf("- Family rollup: `%s`", rollup_path),
  "",
  "判读边界：本轮用于找线索，不直接决定正文结论。优先看事件固定效应、行业/发布方固定效应、同族 q 值、pre-window 信号和 leave-one-year / leave-one-ticker / leave-one-creator 核验。"
)
writeLines(notes, notes_path)

cat("successful_specs=", nrow(all), "\n", sep = "")
cat("candidate_groups=", nrow(candidates), "\n", sep = "")
cat("all_results=", all_path, "\n", sep = "")
cat("summary=", summary_path, "\n", sep = "")
cat("validation=", validation_path, "\n", sep = "")
