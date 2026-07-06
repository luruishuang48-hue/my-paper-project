#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(estimatr)
})

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("--file=", "", args[grep("--file=", args)])
if (length(script_path) == 0) {
  script_path <- "agent_tasks/relationship-specr_20260703-200524/run_relationship_specr.R"
}
task_dir <- normalizePath(dirname(script_path))
root <- normalizePath(file.path(task_dir, "..", ".."))
panel_path <- file.path(root, "Analysis", "processed", "event_firm_panel.csv")

out_all <- file.path(task_dir, "specr_all_results.csv")
out_summary <- file.path(task_dir, "specr_candidate_summary.csv")
out_validation <- file.path(task_dir, "specr_candidate_validation.csv")
out_readme <- file.path(task_dir, "specr_run_notes.md")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c(
  "size_log_assets", "bm_ratio", "volatility", "momentum", "aa_intelligence_index",
  "car_mm_spy_0_1", "car_mm_spy_0_5", "car_mm_spy_0_10", "car_mm_spy_0_15", "car_mm_spy_0_20",
  "car_mm_qqq_0_20", "car_mm_soxx_0_20", "car_ff3_0_20", "car_mm_spy_pre_m10_m2",
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner",
  "is_open_weight_or_open_source", "is_chinese_model", "is_reasoning_model",
  "is_coding_model", "is_media_generation_model", "is_multimodal",
  "is_model_family", "is_cross_modality_release", "model_count"
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
df$platform_competitor <- as.numeric(df$rel_upstream_cloud == 1 & df$rel_competitor == 1)
df$ai_platform <- as.numeric(df$rel_upstream_cloud == 1 | df$rel_competitor == 1 | df$rel_is_owner == 1)

rel_vars <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner", "upstream_any", "downstream_any",
  "related_any", "platform_competitor", "ai_platform"
)
rel_vars <- rel_vars[rel_vars %in% names(df)]

event_vars <- c(
  "is_open_weight_or_open_source", "is_chinese_model", "is_reasoning_model",
  "is_coding_model", "is_media_generation_model", "is_multimodal",
  "is_model_family", "is_cross_modality_release", "post_2025"
)
event_vars <- event_vars[event_vars %in% names(df)]

core_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
core_rels <- core_rels[core_rels %in% names(df)]

outcomes <- c(
  "car_mm_spy_0_1", "car_mm_spy_0_5", "car_mm_spy_0_10", "car_mm_spy_0_15",
  "car_mm_spy_0_20", "car_ff3_0_20", "car_mm_qqq_0_20", "car_mm_soxx_0_20"
)
outcomes <- outcomes[outcomes %in% names(df)]

sample_defs <- list(
  main = rep(TRUE, nrow(df)),
  post_2024 = df$event_trading_date >= "2024-04-01",
  high_date = df$date_confidence == "high",
  no_multi_component = df$multi_component_date_flag == "False",
  llm_events = df$aa_metric_type == "llm",
  media_events = df$aa_metric_type == "media",
  reasoning_events = df$is_reasoning_model == 1,
  nonreasoning_events = df$is_reasoning_model == 0,
  closed_events = df$is_open_weight_or_open_source == 0,
  open_events = df$is_open_weight_or_open_source == 1,
  early_2022_2024 = df$event_trading_date < "2025-01-01",
  late_2025_2026 = df$event_trading_date >= "2025-01-01"
)

control_sets <- list(
  none = "",
  size_bm = "size_log_assets + bm_ratio + bm_missing",
  full = "size_log_assets + bm_ratio + bm_missing + volatility + momentum"
)

fe_sets <- list(
  none = "",
  year = "factor(release_year)",
  event = "factor(event_id)"
)

base_filter <- df$is_main_nasdaq100 == "True" &
  df$event_excluded_identity == "False" &
  !is.na(df$size_log_assets) &
  !is.na(df$volatility) &
  !is.na(df$momentum)

fit_one <- function(dat, y, rhs_terms, test_term, family, sample_name, controls_name, fe_name, note = "") {
  dat <- dat[!is.na(dat[[y]]), ]
  if (nrow(dat) < 500 || length(unique(dat$event_id)) < 20) return(NULL)
  rhs <- paste(rhs_terms[rhs_terms != ""], collapse = " + ")
  if (rhs == "") return(NULL)
  fml <- as.formula(paste(y, "~", rhs))
  fit <- tryCatch(
    lm_robust(fml, data = dat, clusters = dat$event_id, se_type = "CR0"),
    error = function(e) NULL
  )
  if (is.null(fit)) return(NULL)
  s <- summary(fit)$coefficients
  if (!(test_term %in% rownames(s))) return(NULL)
  data.frame(
    family = family,
    sample = sample_name,
    outcome = y,
    controls = controls_name,
    fe = fe_name,
    term = test_term,
    coef = s[test_term, "Estimate"],
    se = s[test_term, "Std. Error"],
    p = s[test_term, "Pr(>|t|)"],
    n = nobs(fit),
    n_events = length(unique(dat$event_id)),
    n_tickers = length(unique(dat$ticker)),
    note = note,
    stringsAsFactors = FALSE
  )
}

rows <- list()
idx <- 0
add <- function(x) {
  if (is.null(x) || nrow(x) == 0) return(invisible(NULL))
  idx <<- idx + 1
  rows[[idx]] <<- x
}

for (sample_name in names(sample_defs)) {
  sf <- base_filter & sample_defs[[sample_name]]
  dat0 <- df[sf, ]
  dat0$bm_missing <- as.numeric(is.na(dat0$bm_ratio))
  dat0$bm_ratio[is.na(dat0$bm_ratio)] <- 0

  for (y in outcomes) {
    for (controls_name in names(control_sets)) {
      for (fe_name in names(fe_sets)) {
        if (controls_name == "none" && fe_name == "event") next
        if (fe_name == "event" && sample_name %in% c("llm_events", "media_events", "reasoning_events", "nonreasoning_events", "closed_events", "open_events")) next
        controls <- control_sets[[controls_name]]
        fe <- fe_sets[[fe_name]]

        for (v in rel_vars) {
          if (sum(dat0[[v]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat0[[v]]))) < 2) next
          rhs <- c(v, controls, fe)
          add(fit_one(dat0, y, rhs, v, "rel_single", sample_name, controls_name, fe_name))
        }

        if (length(core_rels) > 1) {
          rhs_joint <- c(core_rels, controls, fe)
          for (v in core_rels) {
            if (sum(dat0[[v]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat0[[v]]))) < 2) next
            add(fit_one(dat0, y, rhs_joint, v, "rel_joint_core", sample_name, controls_name, fe_name))
          }
        }

        for (v in event_vars) {
          if (fe_name == "event") next
          if (sum(dat0[[v]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat0[[v]]))) < 2) next
          rhs <- c(v, core_rels, controls, fe)
          add(fit_one(dat0, y, rhs, v, "event_label_plus_rels", sample_name, controls_name, fe_name))
        }
      }
    }
  }
}

moderators <- c(
  "is_open_weight_or_open_source", "is_reasoning_model", "is_chinese_model",
  "is_media_generation_model", "is_coding_model", "post_2025"
)
moderators <- moderators[moderators %in% names(df)]
interaction_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "upstream_any", "downstream_any", "related_any"
)
interaction_rels <- interaction_rels[interaction_rels %in% names(df)]

for (sample_name in c("main", "post_2024", "high_date", "no_multi_component", "llm_events", "media_events")) {
  sf <- base_filter & sample_defs[[sample_name]]
  dat0 <- df[sf, ]
  dat0$bm_missing <- as.numeric(is.na(dat0$bm_ratio))
  dat0$bm_ratio[is.na(dat0$bm_ratio)] <- 0
  for (y in c("car_mm_spy_0_20", "car_ff3_0_20", "car_mm_spy_0_10", "car_mm_spy_0_15")) {
    if (!(y %in% names(dat0))) next
    for (controls_name in c("size_bm", "full")) {
      controls <- control_sets[[controls_name]]
      fe <- "factor(release_year)"
      for (r in interaction_rels) {
        if (sum(dat0[[r]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat0[[r]]))) < 2) next
        for (m in moderators) {
          if (sum(dat0[[m]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat0[[m]]))) < 2) next
          ix <- paste0(r, ":", m)
          rhs <- c(paste0(r, "*", m), setdiff(core_rels, r), controls, fe)
          add(fit_one(dat0, y, rhs, ix, "rel_x_event_label", sample_name, controls_name, "year"))
        }
      }
    }
  }
}

ability_rels <- c(
  "rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_competitor", "upstream_any", "downstream_any", "related_any"
)
ability_rels <- ability_rels[ability_rels %in% names(df)]
for (sample_name in c("main", "post_2024", "llm_events", "closed_events", "late_2025_2026")) {
  sf <- base_filter & sample_defs[[sample_name]] & !is.na(df$aa_intelligence_index)
  dat0 <- df[sf, ]
  if (nrow(dat0) == 0) next
  dat0$bm_missing <- as.numeric(is.na(dat0$bm_ratio))
  dat0$bm_ratio[is.na(dat0$bm_ratio)] <- 0
  dat0$intel_c <- dat0$aa_intelligence_index - mean(dat0$aa_intelligence_index, na.rm = TRUE)
  for (y in c("car_mm_spy_0_20", "car_ff3_0_20", "car_mm_spy_0_10", "car_mm_spy_0_15")) {
    if (!(y %in% names(dat0))) next
    for (r in ability_rels) {
      if (sum(dat0[[r]] == 1, na.rm = TRUE) == 0 || length(unique(na.omit(dat0[[r]]))) < 2) next
      ix <- paste0(r, ":intel_c")
      rhs <- c(paste0(r, "*intel_c"), setdiff(core_rels, r), control_sets[["full"]], "factor(release_year)")
      add(fit_one(dat0, y, rhs, ix, "rel_x_intelligence", sample_name, "full", "year"))
    }
  }
}

all <- if (length(rows)) do.call(rbind, rows) else data.frame()
if (nrow(all) == 0) stop("no successful specifications")
all$q_bh <- p.adjust(all$p, method = "BH")
all$sig_p05 <- all$p < 0.05
all$sig_q10 <- all$q_bh < 0.10
all$direction <- ifelse(all$coef > 0, "positive", "negative")
write.csv(all, out_all, row.names = FALSE)

summ <- aggregate(
  cbind(coef, p, q_bh, n, n_events, sig_p05, sig_q10) ~ family + term,
  data = all,
  FUN = function(x) c(
    n_specs = length(x),
    median = median(x, na.rm = TRUE),
    min = min(x, na.rm = TRUE),
    max = max(x, na.rm = TRUE),
    mean = mean(x, na.rm = TRUE)
  )
)

flatten <- function(df) {
  out <- data.frame(df[, c("family", "term")], stringsAsFactors = FALSE)
  for (col in setdiff(names(df), c("family", "term"))) {
    mat <- do.call(rbind, df[[col]])
    for (nm in colnames(mat)) out[[paste(col, nm, sep = "_")]] <- mat[, nm]
  }
  out
}
summary_flat <- flatten(summ)

dir_share <- aggregate(coef ~ family + term, data = all, FUN = function(x) mean(x > 0, na.rm = TRUE))
names(dir_share)[3] <- "positive_share"
summary_flat <- merge(summary_flat, dir_share, by = c("family", "term"), all.x = TRUE)

best_idx <- tapply(seq_len(nrow(all)), paste(all$family, all$term, sep = "\r"), function(ii) ii[which.min(all$p[ii])])
best <- all[as.integer(best_idx), c("family", "term", "sample", "outcome", "controls", "fe", "coef", "se", "p", "q_bh", "n", "n_events", "n_tickers")]
names(best)[3:ncol(best)] <- paste0("best_", names(best)[3:ncol(best)])
summary_flat <- merge(summary_flat, best, by = c("family", "term"), all.x = TRUE)

summary_flat <- summary_flat[order(summary_flat$q_bh_min, summary_flat$p_min, -summary_flat$sig_p05_mean), ]
write.csv(summary_flat, out_summary, row.names = FALSE)

candidate_keys <- summary_flat[
  summary_flat$p_min < 0.01 |
    summary_flat$sig_p05_mean >= 0.30 |
    summary_flat$q_bh_min < 0.20,
  c("family", "term")
]
candidate_keys$key <- paste(candidate_keys$family, candidate_keys$term, sep = "\r")
all$key <- paste(all$family, all$term, sep = "\r")
cand_all <- all[all$key %in% candidate_keys$key, ]

validate_one <- function(row) {
  fam <- row$family
  term <- row$term
  subset <- cand_all[cand_all$family == fam & cand_all$term == term, ]
  if (nrow(subset) == 0) return(NULL)
  best_row <- subset[which.min(subset$p), ]
  dat <- df[base_filter & sample_defs[[best_row$sample]], ]
  dat$bm_missing <- as.numeric(is.na(dat$bm_ratio))
  dat$bm_ratio[is.na(dat$bm_ratio)] <- 0
  if (grepl("intel_c", term)) dat$intel_c <- dat$aa_intelligence_index - mean(dat$aa_intelligence_index, na.rm = TRUE)
  y <- best_row$outcome
  dat <- dat[!is.na(dat[[y]]), ]
  if (nrow(dat) < 500 || length(unique(dat$event_id)) < 20) return(NULL)

  if (fam == "rel_single" || fam == "event_label_plus_rels") {
    rhs <- c(term, core_rels[core_rels != term], control_sets[[best_row$controls]], if (best_row$fe == "year") "factor(release_year)" else "")
  } else if (fam == "rel_joint_core") {
    rhs <- c(core_rels, control_sets[[best_row$controls]], if (best_row$fe == "event") "factor(event_id)" else if (best_row$fe == "year") "factor(release_year)" else "")
  } else if (fam == "rel_x_event_label") {
    parts <- strsplit(term, ":", fixed = TRUE)[[1]]
    rhs <- c(paste0(parts[1], "*", parts[2]), setdiff(core_rels, parts[1]), control_sets[[best_row$controls]], "factor(release_year)")
  } else if (fam == "rel_x_intelligence") {
    r <- sub(":intel_c$", "", term)
    rhs <- c(paste0(r, "*intel_c"), setdiff(core_rels, r), control_sets[[best_row$controls]], "factor(release_year)")
  } else {
    return(NULL)
  }
  rhs <- paste(rhs[rhs != ""], collapse = " + ")
  fml <- as.formula(paste(y, "~", rhs))

  fit_extract <- function(d, label) {
    if (nrow(d) < 300 || length(unique(d$event_id)) < 10) {
      return(data.frame(validation = label, coef = NA, p = NA, n = nrow(d), n_events = length(unique(d$event_id))))
    }
    m <- tryCatch(lm_robust(fml, data = d, clusters = d$event_id, se_type = "CR0"), error = function(e) NULL)
    if (is.null(m)) return(data.frame(validation = label, coef = NA, p = NA, n = nrow(d), n_events = length(unique(d$event_id))))
    s <- summary(m)$coefficients
    if (!(term %in% rownames(s))) return(data.frame(validation = label, coef = NA, p = NA, n = nobs(m), n_events = length(unique(d$event_id))))
    data.frame(validation = label, coef = s[term, "Estimate"], p = s[term, "Pr(>|t|)"], n = nobs(m), n_events = length(unique(d$event_id)))
  }

  vals <- list(fit_extract(dat, "best_spec"))
  for (yr in sort(unique(dat$release_year))) {
    vals[[length(vals) + 1]] <- fit_extract(dat[dat$release_year != yr, ], paste0("drop_year_", yr))
  }
  ev_means <- aggregate(abs(dat[[y]]) ~ event_id, data = dat, FUN = mean, na.rm = TRUE)
  names(ev_means)[2] <- "abs_y"
  top_events <- head(ev_means[order(-ev_means$abs_y), "event_id"], 3)
  for (eid in top_events) {
    vals[[length(vals) + 1]] <- fit_extract(dat[dat$event_id != eid, ], paste0("drop_event_", eid))
  }
  val <- do.call(rbind, vals)
  val$family <- fam
  val$term <- term
  val$best_sample <- best_row$sample
  val$best_outcome <- best_row$outcome
  val$best_controls <- best_row$controls
  val$best_fe <- best_row$fe
  val
}

validation <- if (nrow(candidate_keys)) {
  do.call(rbind, lapply(seq_len(nrow(candidate_keys)), function(i) validate_one(candidate_keys[i, ])))
} else {
  data.frame()
}
if (!is.null(validation) && nrow(validation) > 0) {
  write.csv(validation, out_validation, row.names = FALSE)
}

notes <- c(
  "# Relationship Specr Run Notes",
  "",
  "本次运行是探索性筛查，不用于直接声称因果关系。",
  "",
  sprintf("- Input panel: `%s`", panel_path),
  sprintf("- Successful specs: %d", nrow(all)),
  sprintf("- Families: %s", paste(sort(unique(all$family)), collapse = ", ")),
  sprintf("- Outcomes: %s", paste(sort(unique(all$outcome)), collapse = ", ")),
  sprintf("- Samples: %s", paste(sort(unique(all$sample)), collapse = ", ")),
  sprintf("- Full results: `%s`", out_all),
  sprintf("- Candidate summary: `%s`", out_summary),
  sprintf("- Candidate validation: `%s`", out_validation),
  "",
  "筛选规则：优先看 BH q 值、跨规格显著比例、方向一致率和留一年/留事件核验。R5 下游赋能为空，自动跳过。"
)
writeLines(notes, out_readme)

cat("successful_specs=", nrow(all), "\n", sep = "")
cat("candidate_terms=", nrow(candidate_keys), "\n", sep = "")
cat("all_results=", out_all, "\n", sep = "")
cat("summary=", out_summary, "\n", sep = "")
cat("validation=", out_validation, "\n", sep = "")
