#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(estimatr)
})

args <- commandArgs(trailingOnly = FALSE)
script_file <- sub("--file=", "", args[grep("--file=", args)])
script_dir <- if (length(script_file)) dirname(script_file) else getwd()
root_env <- Sys.getenv("FRL_PROJECT_ROOT")
root <- if (nzchar(root_env)) {
  normalizePath(root_env)
} else {
  normalizePath(file.path(script_dir, "..", ".."))
}

panel_path <- Sys.getenv(
  "FRL_PANEL_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_panel.csv")
)
volume_path <- Sys.getenv(
  "FRL_VOLUME_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_abnormal_volume.csv")
)
out_dir <- Sys.getenv("FRL_REPORT_DIR", unset = script_dir)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)
vol <- read.csv(volume_path, stringsAsFactors = FALSE, check.names = FALSE)
df <- merge(df, vol, by = c("event_id", "ticker"), all.x = TRUE)

num_cols <- c(
  "car_mm_spy_0_20", "car_mm_spy_0_15", "car_mm_spy_0_10",
  "car_mm_spy_0_5", "car_mm_spy_0_1", "car_mm_spy_0_0",
  "car_ff3_0_20", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "mm_spy_beta", "aa_intelligence_index", "elo",
  "price_1m_input_tokens", "price_1m_output_tokens",
  "price_1m_blended_3_to_1", "median_output_tokens_per_second",
  "median_time_to_first_token_seconds", "aa_coding_index", "aa_math_index",
  "mmlu_pro", "gpqa", "livecodebench", "aime", "av_pre_m10_m2", "av_0_1",
  "av_0_5", "av_0_10", "av_0_20", "rel_upstream_hardware",
  "rel_upstream_cloud", "rel_downstream_integrator",
  "rel_downstream_deployer", "rel_downstream_enabler", "rel_competitor",
  "rel_is_investor", "rel_is_owner", "is_open_weight_or_open_source",
  "is_reasoning_model", "is_coding_model", "is_media_generation_model",
  "is_multimodal", "is_model_family", "is_chinese_model",
  "is_cross_modality_release", "model_count"
)
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
df$event_date <- as.Date(df$event_trading_date)
df$bm_missing <- as.numeric(is.na(df$bm_ratio))
df$bm_ratio[is.na(df$bm_ratio)] <- 0
df$in_sox <- as.numeric(
  as.character(df$is_sox_robustness) %in% c("True", "TRUE", "true", "1") |
    df$index_tag %in% c("both", "sox_only") |
    grepl("SOX", df$source_index)
)
df$hardware_sox <- df$rel_upstream_hardware * df$in_sox
df$hardware_nonsox <- df$rel_upstream_hardware * (1 - df$in_sox)
df$post_2_20 <- df$car_mm_spy_0_20 - df$car_mm_spy_0_1

position_terms <- c(
  "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
controls <- c("size_log_assets", "bm_ratio", "bm_missing", "volatility", "momentum")

base <- df[
  df$is_main_ndxt == "True" &
    df$event_excluded_identity == "False" &
    !is.na(df$car_mm_spy_0_20) &
    !is.na(df$size_log_assets) &
    !is.na(df$volatility) &
    !is.na(df$momentum),
]

fmt <- function(x, digits = 4) {
  ifelse(is.na(x), "", formatC(x, format = "f", digits = digits))
}

safe_lm <- function(formula, data) {
  tryCatch(
    lm_robust(as.formula(formula), data = data, clusters = data$event_id, se_type = "CR2"),
    error = function(e) NULL
  )
}

extract_terms <- function(model, spec, terms, data) {
  if (is.null(model)) {
    return(data.frame())
  }
  s <- summary(model)$coefficients
  rows <- intersect(terms, rownames(s))
  if (!length(rows)) {
    return(data.frame())
  }
  data.frame(
    spec = spec,
    term = rows,
    coef = s[rows, "Estimate"],
    se = s[rows, "Std. Error"],
    p = s[rows, "Pr(>|t|)"],
    n = nobs(model),
    events = length(unique(data$event_id)),
    stringsAsFactors = FALSE
  )
}

bind_frames <- function(xs) {
  xs <- xs[vapply(xs, nrow, integer(1)) > 0]
  if (!length(xs)) {
    return(data.frame())
  }
  cols <- unique(unlist(lapply(xs, names)))
  filled <- lapply(xs, function(x) {
    missing <- setdiff(cols, names(x))
    for (m in missing) x[[m]] <- NA
    x[, cols]
  })
  do.call(rbind, filled)
}

run_terms <- function(y, rhs_terms, spec, keep_terms, data = base, fe = c("year", "event")) {
  fe <- match.arg(fe)
  fe_term <- if (fe == "year") "factor(release_year)" else "factor(event_id)"
  needed <- unique(c(y, rhs_terms, controls, "event_id", "release_year"))
  dat <- data[complete.cases(data[, intersect(needed, names(data))]), ]
  rhs <- paste(c(rhs_terms, controls, fe_term), collapse = " + ")
  model <- safe_lm(paste(y, "~", rhs), dat)
  extract_terms(model, spec, keep_terms, dat)
}

all_results <- list()

# 1. Timing of price formation and attention.
rhs_pos <- position_terms
all_results[["timing_0_1"]] <- run_terms(
  "car_mm_spy_0_1", rhs_pos, "price_car_0_1", position_terms, fe = "year"
)
all_results[["timing_2_20"]] <- run_terms(
  "post_2_20", rhs_pos, "price_increment_2_20", position_terms, fe = "year"
)
all_results[["volume_0_1"]] <- run_terms(
  "av_0_1", rhs_pos, "volume_0_1", position_terms, fe = "event"
)
all_results[["volume_pre"]] <- run_terms(
  "av_pre_m10_m2", rhs_pos, "volume_pre_m10_m2", position_terms, fe = "event"
)
cloud_tickers <- sort(unique(base$ticker[base$rel_upstream_cloud == 1]))
cloud_pre_loo <- data.frame()
for (tk in cloud_tickers) {
  dat <- base[base$ticker != tk, ]
  res <- run_terms(
    "av_pre_m10_m2", rhs_pos, paste0("drop_", tk),
    "rel_upstream_cloud", data = dat, fe = "event"
  )
  if (nrow(res)) {
    res$dropped_ticker <- tk
    cloud_pre_loo <- rbind(cloud_pre_loo, res)
  }
}
write.csv(cloud_pre_loo, file.path(out_dir, "leave_one_cloud_ticker_pre_volume.csv"),
          row.names = FALSE)

# 2. Is hardware driven by SOX membership or single firms?
rhs_hwsplit <- c(
  "hardware_sox", "hardware_nonsox", setdiff(position_terms, "rel_upstream_hardware")
)
all_results[["hardware_sox_split"]] <- run_terms(
  "car_mm_spy_0_20", rhs_hwsplit, "hardware_sox_vs_nonsox",
  c("hardware_sox", "hardware_nonsox"), fe = "event"
)
split_needed <- unique(c("car_mm_spy_0_20", rhs_hwsplit, controls, "event_id"))
split_dat <- base[complete.cases(base[, intersect(split_needed, names(base))]), ]
split_model <- safe_lm(
  paste("car_mm_spy_0_20 ~",
        paste(c(rhs_hwsplit, controls, "factor(event_id)"), collapse = " + ")),
  split_dat
)
split_contrast <- data.frame()
if (!is.null(split_model) &&
    all(c("hardware_sox", "hardware_nonsox") %in% names(coef(split_model)))) {
  split_vcov <- vcov(split_model)
  split_diff <- coef(split_model)[["hardware_nonsox"]] - coef(split_model)[["hardware_sox"]]
  split_se <- sqrt(
    split_vcov["hardware_nonsox", "hardware_nonsox"] +
      split_vcov["hardware_sox", "hardware_sox"] -
      2 * split_vcov["hardware_nonsox", "hardware_sox"]
  )
  split_t <- split_diff / split_se
  split_p <- 2 * pt(abs(split_t), df = split_model$df.residual, lower.tail = FALSE)
  split_contrast <- data.frame(
    contrast = "hardware_nonsox_minus_sox",
    coef = split_diff,
    se = split_se,
    p = split_p,
    n = nobs(split_model),
    events = length(unique(split_dat$event_id))
  )
}
write.csv(split_contrast, file.path(out_dir, "hardware_sox_contrast.csv"), row.names = FALSE)

base_event_fe <- run_terms(
  "car_mm_spy_0_20", rhs_pos, "baseline_event_fe", "rel_upstream_hardware", fe = "event"
)
hardware_tickers <- sort(unique(base$ticker[base$rel_upstream_hardware == 1]))
loo <- data.frame()
for (tk in hardware_tickers) {
  dat <- base[base$ticker != tk, ]
  res <- run_terms(
    "car_mm_spy_0_20", rhs_pos, paste0("drop_", tk),
    "rel_upstream_hardware", data = dat, fe = "event"
  )
  if (nrow(res)) {
    res$dropped_ticker <- tk
    loo <- rbind(loo, res)
  }
}
write.csv(loo, file.path(out_dir, "leave_one_hardware_ticker_out.csv"), row.names = FALSE)

# 3. Event attribute moderators. Event fixed effects absorb event-level levels.
moderators <- c(
  "is_open_weight_or_open_source", "is_reasoning_model", "is_coding_model",
  "is_media_generation_model", "is_multimodal", "is_model_family",
  "is_chinese_model", "is_cross_modality_release"
)
moderator_rows <- data.frame()
for (m in moderators) {
  h_term <- paste0("rel_upstream_hardware:", m)
  c_term <- paste0("rel_competitor:", m)
  d_term <- paste0("rel_downstream_deployer:", m)
  rhs <- c(position_terms, h_term, c_term, d_term)
  res <- run_terms(
    "car_mm_spy_0_20", rhs, paste0("moderator_", m),
    c(h_term, c_term, d_term), fe = "event"
  )
  moderator_rows <- rbind(moderator_rows, res)
}
if (nrow(moderator_rows)) {
  moderator_rows$q_bh <- p.adjust(moderator_rows$p, method = "BH")
}
all_results[["moderators"]] <- moderator_rows

# 4. Cost, speed, and task-performance metrics. Standardized by unique event.
event_vars <- c(
  "aa_intelligence_index", "price_1m_blended_3_to_1",
  "price_1m_output_tokens", "median_output_tokens_per_second",
  "median_time_to_first_token_seconds", "aa_coding_index", "aa_math_index",
  "mmlu_pro", "gpqa", "livecodebench", "aime"
)
metric_rows <- data.frame()
for (v in event_vars) {
  zname <- paste0("z_", v)
  ok <- !is.na(base[[v]])
  if (sum(ok) == 0) next
  ev <- unique(base[ok, c("event_id", v)])
  if (nrow(ev) < 10 || sd(ev[[v]], na.rm = TRUE) == 0) next
  ev[[zname]] <- as.numeric(scale(ev[[v]]))
  dat <- merge(base, ev[, c("event_id", zname)], by = "event_id", all.x = TRUE)
  h_term <- paste0("rel_upstream_hardware:", zname)
  dep_term <- paste0("rel_downstream_deployer:", zname)
  comp_term <- paste0("rel_competitor:", zname)
  rhs <- c(position_terms, h_term, dep_term, comp_term)
  res <- run_terms(
    "car_mm_spy_0_20", rhs, paste0("metric_", v),
    c(h_term, dep_term, comp_term), data = dat, fe = "event"
  )
  res$metric <- v
  metric_rows <- rbind(metric_rows, res)
}
if (nrow(metric_rows)) {
  metric_rows$q_bh <- p.adjust(metric_rows$p, method = "BH")
}
all_results[["metrics"]] <- metric_rows

# 5. Crowding of release calendars.
events <- unique(base[, c("event_id", "event_date")])
events <- events[!is.na(events$event_date), ]
events$density_pm10 <- vapply(events$event_date, function(d) {
  sum(abs(as.numeric(events$event_date - d)) <= 10) - 1
}, numeric(1))
events$density_pm20 <- vapply(events$event_date, function(d) {
  sum(abs(as.numeric(events$event_date - d)) <= 20) - 1
}, numeric(1))
events$isolated_pm10 <- as.numeric(events$density_pm10 == 0)
events$z_density_pm10 <- as.numeric(scale(events$density_pm10))
crowd <- merge(base, events[, c("event_id", "isolated_pm10", "z_density_pm10")],
               by = "event_id", all.x = TRUE)
all_results[["crowding_isolated"]] <- run_terms(
  "car_mm_spy_0_20",
  c(position_terms, "rel_upstream_hardware:isolated_pm10",
    "rel_competitor:isolated_pm10", "rel_downstream_deployer:isolated_pm10"),
  "calendar_isolated_pm10",
  c("rel_upstream_hardware:isolated_pm10",
    "rel_competitor:isolated_pm10", "rel_downstream_deployer:isolated_pm10"),
  data = crowd, fe = "event"
)
all_results[["crowding_density"]] <- run_terms(
  "car_mm_spy_0_20",
  c(position_terms, "rel_upstream_hardware:z_density_pm10",
    "rel_competitor:z_density_pm10", "rel_downstream_deployer:z_density_pm10"),
  "calendar_density_pm10",
  c("rel_upstream_hardware:z_density_pm10",
    "rel_competitor:z_density_pm10", "rel_downstream_deployer:z_density_pm10"),
  data = crowd, fe = "event"
)

results <- bind_frames(all_results)
if (nrow(results)) {
  results$q_by_family <- ave(results$p, results$spec, FUN = function(x) p.adjust(x, method = "BH"))
}
write.csv(results, file.path(out_dir, "more_findings_results.csv"), row.names = FALSE)

sink(file.path(out_dir, "more_findings_summary.md"))
cat("# Additional findings scan\n\n")
cat("Sample: ", nrow(base), " firm-event observations, ",
    length(unique(base$event_id)), " events, ", length(unique(base$ticker)), " firms.\n\n", sep = "")

cat("## Timing and attention\n\n")
timing <- results[results$spec %in% c("price_car_0_1", "price_increment_2_20", "volume_0_1", "volume_pre_m10_m2") &
                    results$term %in% c("rel_upstream_hardware", "rel_upstream_cloud", "rel_downstream_deployer", "rel_competitor"), ]
if (nrow(timing)) {
  print(timing[, c("spec", "term", "coef", "se", "p", "n", "events")], row.names = FALSE)
}

cat("\n## Hardware concentration\n\n")
cat("Baseline event-FE hardware coefficient: ")
if (nrow(base_event_fe)) {
  cat(fmt(base_event_fe$coef), " (se ", fmt(base_event_fe$se), ", p ", fmt(base_event_fe$p), ").\n", sep = "")
}
split_res <- results[results$spec == "hardware_sox_vs_nonsox", ]
if (nrow(split_res)) {
  print(split_res[, c("term", "coef", "se", "p", "n", "events")], row.names = FALSE)
}
if (nrow(split_contrast)) {
  cat("\nContrast:\n")
  print(split_contrast, row.names = FALSE)
}
if (nrow(loo)) {
  cat("\nLeave-one-hardware-ticker-out range: ")
  cat(fmt(min(loo$coef, na.rm = TRUE)), " to ", fmt(max(loo$coef, na.rm = TRUE)),
      "; significant at 5% in ", sum(loo$p < .05, na.rm = TRUE), " of ",
      nrow(loo), " exclusions.\n", sep = "")
  ord <- loo[order(loo$coef), c("dropped_ticker", "coef", "se", "p")]
  cat("\nLowest five after exclusions:\n")
  print(head(ord, 5), row.names = FALSE)
  cat("\nHighest five after exclusions:\n")
  print(tail(ord, 5), row.names = FALSE)
}

cat("\n## Cloud pre-event volume leave-one-out\n\n")
if (nrow(cloud_pre_loo)) {
  cat("Leave-one-cloud-ticker-out range: ")
  cat(fmt(min(cloud_pre_loo$coef, na.rm = TRUE)), " to ",
      fmt(max(cloud_pre_loo$coef, na.rm = TRUE)),
      "; significant at 1% in ", sum(cloud_pre_loo$p < .01, na.rm = TRUE),
      " of ", nrow(cloud_pre_loo), " exclusions.\n", sep = "")
  print(cloud_pre_loo[, c("dropped_ticker", "coef", "se", "p")], row.names = FALSE)
}

cat("\n## Event attribute moderators\n\n")
mods <- results[grepl("^moderator_", results$spec), ]
if (nrow(mods)) {
  print(mods[order(mods$p), c("spec", "term", "coef", "se", "p", "q_bh", "n", "events")],
        row.names = FALSE)
}

cat("\n## Cost, speed, and benchmark metrics\n\n")
metrics <- results[grepl("^metric_", results$spec), ]
if (nrow(metrics)) {
  print(metrics[order(metrics$p), c("metric", "term", "coef", "se", "p", "q_bh", "n", "events")],
        row.names = FALSE)
}

cat("\n## Release-calendar crowding\n\n")
crowd_res <- results[grepl("^calendar_", results$spec), ]
if (nrow(crowd_res)) {
  print(crowd_res[, c("spec", "term", "coef", "se", "p", "n", "events")], row.names = FALSE)
}
cat("\nEvent density within +/-10 calendar days:\n")
print(summary(events$density_pm10))
cat("Isolated events (+/-10 days): ", sum(events$isolated_pm10 == 1), " of ", nrow(events), ".\n", sep = "")

sink()

cat("Wrote:\n")
cat(file.path(out_dir, "more_findings_results.csv"), "\n")
cat(file.path(out_dir, "leave_one_hardware_ticker_out.csv"), "\n")
cat(file.path(out_dir, "more_findings_summary.md"), "\n")
