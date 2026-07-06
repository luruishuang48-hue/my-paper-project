#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(lmtest)
  library(sandwich)
})

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("--file=", "", args[grep("--file=", args)])
if (length(script_path) == 0) {
  script_path <- "agent_tasks/relationship-specr_20260703-200524/run_relationship_specr_tight.R"
}
task_dir <- normalizePath(dirname(script_path))
root <- normalizePath(file.path(task_dir, "..", ".."))
panel_path <- file.path(root, "Analysis", "processed", "event_firm_panel.csv")

all_path <- file.path(task_dir, "specr_tight_all_results.csv")
summary_path <- file.path(task_dir, "specr_tight_candidate_summary.csv")
validation_path <- file.path(task_dir, "specr_tight_validation.csv")
notes_path <- file.path(task_dir, "specr_tight_run_notes.md")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c(
  "size_log_assets", "bm_ratio", "volatility", "momentum", "aa_intelligence_index",
  "car_mm_spy_0_1", "car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
  "car_mm_qqq_0_20", "car_mm_soxx_0_20", "car_ff3_0_20",
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner",
  "is_open_weight_or_open_source", "is_chinese_model", "is_reasoning_model",
  "is_media_generation_model"
)
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
df$post_2025 <- as.numeric(df$event_trading_date >= "2025-01-01")
df$upstream_any <- as.numeric(df$rel_upstream_hardware == 1 | df$rel_upstream_cloud == 1)
df$downstream_any <- as.numeric(
  df$rel_downstream_integrator == 1 |
    df$rel_downstream_deployer == 1 |
    df$rel_downstream_enabler == 1
)
df$related_any <- as.numeric(
  df$upstream_any == 1 | df$downstream_any == 1 | df$rel_competitor == 1 |
    df$rel_is_investor == 1 | df$rel_is_owner == 1
)
df$platform_bigtech <- as.numeric(df$rel_upstream_cloud == 1 | df$rel_competitor == 1 | df$rel_is_owner == 1)

core_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
single_rels <- c(core_rels, "upstream_any", "downstream_any", "related_any", "platform_bigtech")

outcomes <- c(
  "car_mm_spy_0_20", "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_soxx_0_20",
  "car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_1"
)

sample_defs <- list(
  main = rep(TRUE, nrow(df)),
  high_date = df$date_confidence == "high",
  no_multi_component = df$multi_component_date_flag == "False",
  llm_events = df$aa_metric_type == "llm",
  media_events = df$aa_metric_type == "media",
  early_2022_2024 = df$event_trading_date < "2025-01-01",
  late_2025_2026 = df$event_trading_date >= "2025-01-01",
  reasoning_events = df$is_reasoning_model == 1,
  nonreasoning_events = df$is_reasoning_model == 0,
  post_2024 = df$event_trading_date >= "2024-04-01"
)

base_filter <- df$is_main_nasdaq100 == "True" &
  df$event_excluded_identity == "False" &
  !is.na(df$size_log_assets) &
  !is.na(df$volatility) &
  !is.na(df$momentum)

prep_sample <- function(sample_name, y, need_intel = FALSE) {
  dat <- df[base_filter & sample_defs[[sample_name]], ]
  if (need_intel) dat <- dat[!is.na(dat$aa_intelligence_index), ]
  dat <- dat[!is.na(dat[[y]]), ]
  dat$bm_missing <- as.numeric(is.na(dat$bm_ratio))
  dat$bm_ratio[is.na(dat$bm_ratio)] <- 0
  dat$intel_c <- dat$aa_intelligence_index - mean(dat$aa_intelligence_index, na.rm = TRUE)
  dat
}

fit_term <- function(dat, y, rhs, term, family, sample_name, fe_type, note = "") {
  if (nrow(dat) < 500 || length(unique(dat$event_id)) < 20 || length(unique(dat$ticker)) < 20) return(NULL)
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

  treatment <- rep(NA_real_, nrow(dat))
  parts <- strsplit(term, ":", fixed = TRUE)[[1]]
  if (length(parts) == 1 && parts[1] %in% names(dat)) {
    treatment <- dat[[parts[1]]]
  } else if (length(parts) == 2 && all(parts %in% names(dat))) {
    treatment <- dat[[parts[1]]] * dat[[parts[2]]]
  }
  n_treated <- if (all(is.na(treatment))) NA_integer_ else sum(treatment == 1, na.rm = TRUE)
  treated_events <- if (all(is.na(treatment))) NA_integer_ else length(unique(dat$event_id[treatment == 1]))
  treated_tickers <- if (all(is.na(treatment))) NA_integer_ else length(unique(dat$ticker[treatment == 1]))

  data.frame(
    family = family,
    sample = sample_name,
    outcome = y,
    fe = fe_type,
    term = term,
    coef = est,
    se = se,
    p = pval,
    n = nobs(fit),
    n_events = length(unique(dat$event_id)),
    n_tickers = length(unique(dat$ticker)),
    n_treated = n_treated,
    treated_events = treated_events,
    treated_tickers = treated_tickers,
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
fe_event <- "factor(event_id)"
fe_year <- "factor(release_year)"

# Main relation curves. Event FE is the preferred relationship design.
for (sample_name in names(sample_defs)) {
  for (y in outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (fe_type in c("event", "year")) {
      fe <- if (fe_type == "event") fe_event else fe_year
      rhs_joint <- paste(c(core_rels, controls, fe), collapse = " + ")
      for (term in core_rels) {
        if (sum(dat[[term]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat[[term]]))) < 2) next
        add(fit_term(dat, y, rhs_joint, term, "joint_core", sample_name, fe_type))
      }
      for (term in single_rels) {
        if (sum(dat[[term]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat[[term]]))) < 2) next
        rhs_single <- paste(c(term, controls, fe), collapse = " + ")
        add(fit_term(dat, y, rhs_single, term, "single_or_bundle", sample_name, fe_type))
      }
    }
  }
}

# Mechanism interactions. Small labels such as coding and cross-modality are deliberately excluded.
interaction_rels <- c("rel_upstream_hardware", "rel_competitor", "rel_downstream_deployer", "downstream_any", "rel_upstream_cloud")
moderators <- c("is_open_weight_or_open_source", "is_reasoning_model", "post_2025", "is_chinese_model", "is_media_generation_model")
interaction_samples <- c("main", "high_date", "no_multi_component", "llm_events", "late_2025_2026")
interaction_outcomes <- c("car_mm_spy_0_20", "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_spy_0_10", "car_mm_spy_0_15")

for (sample_name in interaction_samples) {
  for (y in interaction_outcomes) {
    dat <- prep_sample(sample_name, y)
    if (nrow(dat) == 0) next
    for (r in interaction_rels) {
      if (sum(dat[[r]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat[[r]]))) < 2) next
      for (m in moderators) {
        if (sum(dat[[m]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat[[m]]))) < 2) next
        term <- paste0(r, ":", m)
        rhs <- paste(c(paste0(r, "*", m), setdiff(core_rels, r), controls, fe_event), collapse = " + ")
        add(fit_term(dat, y, rhs, term, "rel_x_event", sample_name, "event"))
      }
    }
  }
}

# Capability interactions. These are only mechanism diagnostics, not broad ability-pricing claims.
ability_rels <- c("rel_upstream_hardware", "rel_competitor", "rel_downstream_deployer", "downstream_any", "rel_upstream_cloud")
ability_samples <- c("main", "llm_events", "closed_events", "late_2025_2026")
sample_defs$closed_events <- df$is_open_weight_or_open_source == 0
ability_outcomes <- c("car_mm_spy_0_20", "car_ff3_0_20", "car_mm_spy_0_10", "car_mm_spy_0_15")

for (sample_name in ability_samples) {
  for (y in ability_outcomes) {
    dat <- prep_sample(sample_name, y, need_intel = TRUE)
    if (nrow(dat) == 0) next
    for (r in ability_rels) {
      if (sum(dat[[r]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat[[r]]))) < 2) next
      term <- paste0(r, ":intel_c")
      rhs <- paste(c(paste0(r, "*intel_c"), setdiff(core_rels, r), controls, fe_event), collapse = " + ")
      add(fit_term(dat, y, rhs, term, "rel_x_intelligence", sample_name, "event"))
    }
  }
}

all <- do.call(rbind, rows)
all$q_global <- p.adjust(all$p, method = "BH")
all$q_family <- ave(all$p, all$family, FUN = function(x) p.adjust(x, method = "BH"))
all$sig_p05 <- all$p < 0.05
all$sig_q10_family <- all$q_family < 0.10
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
      min_q_global = min(sub$q_global, na.rm = TRUE),
      median_n = median(sub$n, na.rm = TRUE),
      median_events = median(sub$n_events, na.rm = TRUE),
      min_treated = min(sub$n_treated, na.rm = TRUE),
      min_treated_events = min(sub$treated_events, na.rm = TRUE),
      min_treated_tickers = min(sub$treated_tickers, na.rm = TRUE),
      best_sample = best$sample,
      best_outcome = best$outcome,
      best_fe = best$fe,
      best_coef = best$coef,
      best_se = best$se,
      best_p = best$p,
      best_q_family = best$q_family,
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
summary$risk_flag <- ""
summary$risk_flag[summary$min_treated_tickers < 6 | summary$min_treated_events < 20] <- "low_support"
summary$risk_flag[summary$term %in% c("rel_is_investor", "rel_is_owner")] <- "low_support_relation"
summary <- summary[order(summary$min_q_family, summary$min_p, -summary$p05_share), ]
write.csv(summary, summary_path, row.names = FALSE)

candidates <- summary[
  summary$min_q_family < 0.10 |
    summary$p05_share >= 0.30 |
    (summary$min_p < 0.01 & summary$positive_share %in% c(0, 1)),
]

validate_fit <- function(best_row, dat, label) {
  if (nrow(dat) < 500 || length(unique(dat$event_id)) < 20) {
    return(data.frame(validation = label, coef = NA, p = NA, n = nrow(dat), events = length(unique(dat$event_id))))
  }
  res <- fit_term(dat, best_row$best_outcome, best_row$best_rhs, best_row$term, best_row$family, best_row$best_sample, best_row$best_fe)
  if (is.null(res)) {
    return(data.frame(validation = label, coef = NA, p = NA, n = nrow(dat), events = length(unique(dat$event_id))))
  }
  data.frame(validation = label, coef = res$coef, p = res$p, n = res$n, events = res$n_events)
}

make_treatment <- function(dat, term) {
  parts <- strsplit(term, ":", fixed = TRUE)[[1]]
  if (length(parts) == 1 && parts[1] %in% names(dat)) return(dat[[parts[1]]])
  if (length(parts) == 2 && all(parts %in% names(dat))) return(dat[[parts[1]]] * dat[[parts[2]]])
  rep(0, nrow(dat))
}

validation_rows <- list()
if (nrow(candidates) > 0) {
  for (i in seq_len(nrow(candidates))) {
    br <- candidates[i, ]
    dat <- prep_sample(br$best_sample, br$best_outcome, need_intel = grepl("intel_c", br$term, fixed = TRUE))
    base_val <- validate_fit(br, dat, "best_spec")
    vals <- list(base_val)
    for (yr in sort(unique(dat$release_year))) {
      vals[[length(vals) + 1]] <- validate_fit(br, dat[dat$release_year != yr, ], paste0("drop_year_", yr))
    }
    tr <- make_treatment(dat, br$term)
    top_tickers <- names(sort(table(dat$ticker[tr == 1]), decreasing = TRUE))[1:min(5, length(table(dat$ticker[tr == 1])))]
    for (tk in top_tickers) {
      vals[[length(vals) + 1]] <- validate_fit(br, dat[dat$ticker != tk, ], paste0("drop_ticker_", tk))
    }
    val <- do.call(rbind, vals)
    val$family <- br$family
    val$term <- br$term
    val$best_sample <- br$best_sample
    val$best_outcome <- br$best_outcome
    val$best_fe <- br$best_fe
    validation_rows[[length(validation_rows) + 1]] <- val
  }
}
validation <- if (length(validation_rows)) do.call(rbind, validation_rows) else data.frame()
write.csv(validation, validation_path, row.names = FALSE)

notes <- c(
  "# Tight Relationship SPECR Run Notes",
  "",
  "本次是按子代理审阅意见收紧后的探索性 SPECR。宽网格版本因事件固定效应和大量共线组合过慢而中止，没有用于结论。",
  "",
  sprintf("- Input panel: `%s`", panel_path),
  sprintf("- Successful specs: %d", nrow(all)),
  sprintf("- Candidate groups: %d", nrow(candidates)),
  sprintf("- Full results: `%s`", all_path),
  sprintf("- Candidate summary: `%s`", summary_path),
  sprintf("- Validation: `%s`", validation_path),
  "",
  "设计边界：主关系采用事件固定效应和完整控制组；R5 下游赋能全零，未纳入；owner/investor 低支持度，自动标风险；coding 和 cross-modality 事件数过少，未进入交互搜索。",
  "",
  "判读规则：优先看同族 BH q 值、方向一致率、处理组公司数/事件数和 leave-one-year / leave-one-ticker 核验。"
)
writeLines(notes, notes_path)

cat("successful_specs=", nrow(all), "\n", sep = "")
cat("candidate_groups=", nrow(candidates), "\n", sep = "")
cat("all_results=", all_path, "\n", sep = "")
cat("summary=", summary_path, "\n", sep = "")
cat("validation=", validation_path, "\n", sep = "")
