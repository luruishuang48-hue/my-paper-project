#!/usr/bin/env Rscript
# Diagnostic inference for the FRL event-firm regressions.
#
# Outputs
#   1. Comparison of event, event-date, firm, and two-way clustered inference.
#   2. Within-firm residual dependence by event-window distance.
#   3. Event-by-event cross-sectional coefficients with calendar-time HAC.
#
# This script does not edit manuscript files.

suppressPackageStartupMessages({
  library(estimatr)
  library(sandwich)
})

args <- commandArgs(trailingOnly = FALSE)
script_dir <- dirname(sub("--file=", "", args[grep("--file=", args)]))
root_env <- Sys.getenv("FRL_PROJECT_ROOT")
root <- if (nzchar(root_env)) {
  normalizePath(root_env)
} else {
  normalizePath(file.path(script_dir, "..", ".."))
}
report_dir <- Sys.getenv(
  "FRL_REPORT_DIR",
  unset = file.path(root, "Analysis", "reports")
)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

panel_path <- Sys.getenv(
  "FRL_PANEL_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_panel.csv")
)
market_path <- file.path(root, "CAR", "processed", "market_benchmarks_daily.csv")

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)
market <- read.csv(market_path, stringsAsFactors = FALSE)

num_cols <- c(
  "car_mm_spy_0_20", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
for (col in num_cols) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
base <- df[
  df$is_main_ndxt == "True" &
    df$event_excluded_identity == "False" &
    !is.na(df$car_mm_spy_0_20) &
    !is.na(df$size_log_assets) &
    !is.na(df$volatility) &
    !is.na(df$momentum),
]
base$bm_missing <- as.numeric(is.na(base$bm_ratio))
base$bm_ratio[is.na(base$bm_ratio)] <- 0

spy_dates <- sort(unique(as.Date(market$date[market$symbol == "SPY"])))
base$trading_day_index <- match(as.Date(base$event_trading_date), spy_dates)
if (anyNA(base$trading_day_index)) {
  stop("Some event trading dates are missing from the SPY trading calendar.")
}

position_terms <- c(
  "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
controls <- c(
  "size_log_assets", "bm_ratio", "bm_missing", "volatility", "momentum"
)
position_rhs <- paste(c(position_terms, controls), collapse = " + ")
pooled_formula <- as.formula(
  paste(
    "car_mm_spy_0_20 ~", position_rhs, "+ factor(release_year)"
  )
)

star <- function(p) {
  ifelse(
    is.na(p), "",
    ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
  )
}

extract_cr2 <- function(fit, method) {
  tab <- summary(fit)$coefficients
  keep <- intersect(position_terms, rownames(tab))
  data.frame(
    method = method,
    term = keep,
    coef = tab[keep, "Estimate"],
    se = tab[keep, "Std. Error"],
    p = tab[keep, "Pr(>|t|)"],
    df = tab[keep, "DF"],
    stars = star(tab[keep, "Pr(>|t|)"]),
    observations = nobs(fit),
    cluster_1 = NA_real_,
    cluster_2 = NA_real_,
    vcov_min_eigenvalue_before_fix = NA_real_,
    vcov_eigenvalue_fix_applied = NA,
    stringsAsFactors = FALSE
  )
}

extract_multiway <- function(fit, cluster_data, method) {
  vcov_raw <- vcovCL(
    fit,
    cluster = cluster_data,
    type = "HC1",
    cadjust = TRUE,
    multi0 = TRUE,
    fix = FALSE
  )
  min_eigen <- min(eigen(
    vcov_raw,
    symmetric = TRUE,
    only.values = TRUE
  )$values)
  fix_applied <- min_eigen < -1e-10
  vcov_use <- vcovCL(
    fit,
    cluster = cluster_data,
    type = "HC1",
    cadjust = TRUE,
    multi0 = TRUE,
    fix = fix_applied
  )
  se <- sqrt(diag(vcov_use))
  coef_value <- coef(fit)
  cluster_counts <- vapply(
    cluster_data,
    function(x) length(unique(x)),
    numeric(1)
  )
  df_t <- min(cluster_counts) - 1
  p <- 2 * pt(abs(coef_value / se), df = df_t, lower.tail = FALSE)
  keep <- intersect(position_terms, names(coef_value))
  data.frame(
    method = method,
    term = keep,
    coef = coef_value[keep],
    se = se[keep],
    p = p[keep],
    df = df_t,
    stars = star(p[keep]),
    observations = nobs(fit),
    cluster_1 = cluster_counts[1],
    cluster_2 = cluster_counts[2],
    vcov_min_eigenvalue_before_fix = min_eigen,
    vcov_eigenvalue_fix_applied = fix_applied,
    stringsAsFactors = FALSE
  )
}

# -------------------------------------------------------------------------
# 1. Cluster-method comparison
# -------------------------------------------------------------------------

fit_event <- lm_robust(
  pooled_formula,
  data = base,
  clusters = base$event_id,
  se_type = "CR2"
)
fit_event_date <- lm_robust(
  pooled_formula,
  data = base,
  clusters = base$event_trading_date,
  se_type = "CR2"
)
fit_firm <- lm_robust(
  pooled_formula,
  data = base,
  clusters = base$ticker,
  se_type = "CR2"
)
fit_ols <- lm(pooled_formula, data = base)

cluster_results <- rbind(
  extract_cr2(fit_event, "event_id_CR2"),
  extract_cr2(fit_event_date, "event_date_CR2"),
  extract_cr2(fit_firm, "firm_CR2"),
  extract_multiway(
    fit_ols,
    data.frame(event_id = base$event_id, ticker = base$ticker),
    "event_id_x_firm_HC1"
  ),
  extract_multiway(
    fit_ols,
    data.frame(
      event_trading_date = base$event_trading_date,
      ticker = base$ticker
    ),
    "event_date_x_firm_HC1"
  )
)

cluster_path <- file.path(
  report_dir, "frl_cluster_method_diagnostics.csv"
)
write.csv(cluster_results, cluster_path, row.names = FALSE)

# -------------------------------------------------------------------------
# 2. Within-firm residual dependence
# -------------------------------------------------------------------------

gap_levels <- c(
  "same_day", "1_5_days", "6_10_days", "11_20_days",
  "21_40_days", "over_40_days"
)
gap_breaks <- c(-0.5, 0.5, 5.5, 10.5, 20.5, 40.5, Inf)

residual_dependence <- function(dat, residual_value, model_name) {
  dat$residual_firm_demeaned <- ave(
    residual_value,
    dat$ticker,
    FUN = function(x) x - mean(x)
  )
  agg <- data.frame(
    gap_bin = gap_levels,
    pair_count = 0,
    sum_xy = 0,
    sum_x2 = 0,
    sum_y2 = 0,
    stringsAsFactors = FALSE
  )
  adjacent_x <- numeric()
  adjacent_y <- numeric()
  adjacent_gap <- numeric()

  for (ticker_value in unique(dat$ticker)) {
    d <- dat[dat$ticker == ticker_value, ]
    d <- d[order(d$trading_day_index, d$event_id), ]
    n <- nrow(d)
    if (n < 2) {
      next
    }

    pairs <- combn(seq_len(n), 2)
    gap <- abs(
      d$trading_day_index[pairs[2, ]] -
        d$trading_day_index[pairs[1, ]]
    )
    bins <- cut(
      gap,
      breaks = gap_breaks,
      labels = gap_levels,
      right = TRUE
    )
    x <- d$residual_firm_demeaned[pairs[1, ]]
    y <- d$residual_firm_demeaned[pairs[2, ]]

    for (bin_value in gap_levels) {
      use <- bins == bin_value
      use[is.na(use)] <- FALSE
      if (!any(use)) {
        next
      }
      row <- match(bin_value, agg$gap_bin)
      agg$pair_count[row] <- agg$pair_count[row] + sum(use)
      agg$sum_xy[row] <- agg$sum_xy[row] + sum(x[use] * y[use])
      agg$sum_x2[row] <- agg$sum_x2[row] + sum(x[use]^2)
      agg$sum_y2[row] <- agg$sum_y2[row] + sum(y[use]^2)
    }

    adjacent_x <- c(adjacent_x, d$residual_firm_demeaned[-n])
    adjacent_y <- c(adjacent_y, d$residual_firm_demeaned[-1])
    adjacent_gap <- c(adjacent_gap, diff(d$trading_day_index))
  }

  agg$pooled_pair_correlation <- agg$sum_xy /
    sqrt(agg$sum_x2 * agg$sum_y2)
  agg$share_of_all_pairs <- agg$pair_count / sum(agg$pair_count)
  agg$overlapping_car_window <- agg$gap_bin %in% c(
    "same_day", "1_5_days", "6_10_days", "11_20_days"
  )

  adjacent_all <- data.frame(
    gap_bin = "adjacent_events_all_gaps",
    pair_count = length(adjacent_x),
    sum_xy = sum(adjacent_x * adjacent_y),
    sum_x2 = sum(adjacent_x^2),
    sum_y2 = sum(adjacent_y^2),
    pooled_pair_correlation = sum(adjacent_x * adjacent_y) /
      sqrt(sum(adjacent_x^2) * sum(adjacent_y^2)),
    share_of_all_pairs = NA_real_,
    overlapping_car_window = NA,
    stringsAsFactors = FALSE
  )
  adjacent_overlap_use <- adjacent_gap <= 20
  adjacent_overlap <- data.frame(
    gap_bin = "adjacent_events_gap_le_20",
    pair_count = sum(adjacent_overlap_use),
    sum_xy = sum(
      adjacent_x[adjacent_overlap_use] *
        adjacent_y[adjacent_overlap_use]
    ),
    sum_x2 = sum(adjacent_x[adjacent_overlap_use]^2),
    sum_y2 = sum(adjacent_y[adjacent_overlap_use]^2),
    pooled_pair_correlation = sum(
      adjacent_x[adjacent_overlap_use] *
        adjacent_y[adjacent_overlap_use]
    ) / sqrt(
      sum(adjacent_x[adjacent_overlap_use]^2) *
        sum(adjacent_y[adjacent_overlap_use]^2)
    ),
    share_of_all_pairs = NA_real_,
    overlapping_car_window = TRUE,
    stringsAsFactors = FALSE
  )

  result <- rbind(
    agg,
    adjacent_all[names(agg)],
    adjacent_overlap[names(agg)]
  )
  result$model <- model_name
  result
}

event_fe_formula <- as.formula(
  paste(
    "car_mm_spy_0_20 ~", position_rhs, "+ factor(event_id)"
  )
)
fit_event_fe_ols <- lm(event_fe_formula, data = base)
residual_results <- rbind(
  residual_dependence(
    base,
    residuals(fit_ols),
    "year_fixed_effects"
  ),
  residual_dependence(
    base,
    residuals(fit_event_fe_ols),
    "event_fixed_effects"
  )
)
residual_path <- file.path(
  report_dir, "frl_within_firm_residual_dependence.csv"
)
write.csv(residual_results, residual_path, row.names = FALSE)

# -------------------------------------------------------------------------
# 3. Event-by-event cross-sectional estimates and calendar-time HAC
# -------------------------------------------------------------------------

event_formula <- as.formula(
  paste("car_mm_spy_0_20 ~", position_rhs)
)
event_ids <- unique(base$event_id)
event_rows <- list()
event_i <- 0

for (event_value in event_ids) {
  d <- base[base$event_id == event_value, ]
  fit <- lm(event_formula, data = d)
  fit_coef <- coef(fit)
  for (term in position_terms) {
    if (!(term %in% names(fit_coef)) || is.na(fit_coef[term])) {
      next
    }
    event_i <- event_i + 1
    event_rows[[event_i]] <- data.frame(
      event_id = event_value,
      event_trading_date = d$event_trading_date[1],
      trading_day_index = d$trading_day_index[1],
      term = term,
      coefficient = unname(fit_coef[term]),
      observations = nobs(fit),
      stringsAsFactors = FALSE
    )
  }
}

event_coefficients <- do.call(rbind, event_rows)
event_coef_path <- file.path(
  report_dir, "frl_event_level_position_coefficients.csv"
)
write.csv(event_coefficients, event_coef_path, row.names = FALSE)

calendar_hac <- function(coef_data, bandwidth) {
  x <- coef_data$coefficient
  day <- coef_data$trading_day_index
  n <- length(x)
  estimate <- mean(x)
  u <- x - estimate
  meat <- sum(u^2)

  if (bandwidth > 0 && n > 1) {
    pairs <- combn(seq_len(n), 2)
    distance <- abs(day[pairs[2, ]] - day[pairs[1, ]])
    use <- distance <= bandwidth
    if (any(use)) {
      weight <- 1 - distance[use] / (bandwidth + 1)
      meat <- meat + 2 * sum(
        weight *
          u[pairs[1, use]] *
          u[pairs[2, use]]
      )
    }
  }

  variance <- (n / (n - 1)) * meat / n^2
  variance <- max(variance, 0)
  se <- sqrt(variance)
  n_dates <- length(unique(coef_data$event_trading_date))
  df_t <- n_dates - 1
  t_value <- estimate / se
  p_value <- 2 * pt(abs(t_value), df = df_t, lower.tail = FALSE)
  q95 <- qt(0.975, df = df_t)

  data.frame(
    estimate = estimate,
    se = se,
    t = t_value,
    p = p_value,
    ci95_low = estimate - q95 * se,
    ci95_high = estimate + q95 * se,
    events = n,
    unique_event_dates = n_dates,
    bandwidth_trading_days = bandwidth,
    stringsAsFactors = FALSE
  )
}

hac_rows <- list()
hac_i <- 0
for (term in position_terms) {
  term_data <- event_coefficients[event_coefficients$term == term, ]
  for (bandwidth in c(0, 5, 10, 20, 40)) {
    hac_i <- hac_i + 1
    row <- calendar_hac(term_data, bandwidth)
    row$term <- term
    hac_rows[[hac_i]] <- row
  }
}
hac_results <- do.call(rbind, hac_rows)
hac_results$stars <- star(hac_results$p)
hac_results <- hac_results[
  ,
  c(
    "term", "bandwidth_trading_days", "estimate", "se", "t", "p",
    "stars", "ci95_low", "ci95_high", "events", "unique_event_dates"
  )
]
hac_path <- file.path(
  report_dir, "frl_event_level_calendar_hac_results.csv"
)
write.csv(hac_results, hac_path, row.names = FALSE)

# Calendar-HAC deployer equivalence test using the manuscript's margin
pooled_hardware <- coef(fit_ols)["rel_upstream_hardware"]
equivalence_margin <- abs(pooled_hardware) / 3
deployer_hac <- hac_results[
  hac_results$term == "rel_downstream_deployer" &
    hac_results$bandwidth_trading_days == 20,
]
deployer_df <- deployer_hac$unique_event_dates - 1
t_lower <- (
  deployer_hac$estimate + equivalence_margin
) / deployer_hac$se
t_upper <- (
  deployer_hac$estimate - equivalence_margin
) / deployer_hac$se
p_lower <- pt(t_lower, df = deployer_df, lower.tail = FALSE)
p_upper <- pt(t_upper, df = deployer_df, lower.tail = TRUE)
p_tost <- max(p_lower, p_upper)
q90 <- qt(0.95, df = deployer_df)
equivalence_result <- data.frame(
  method = "event_level_calendar_HAC_20_trading_days",
  deployer_estimate = deployer_hac$estimate,
  deployer_se = deployer_hac$se,
  equivalence_margin = equivalence_margin,
  ci90_low = deployer_hac$estimate - q90 * deployer_hac$se,
  ci90_high = deployer_hac$estimate + q90 * deployer_hac$se,
  p_lower_bound = p_lower,
  p_upper_bound = p_upper,
  p_tost = p_tost,
  equivalent_at_5pct = p_tost < 0.05,
  events = deployer_hac$events,
  unique_event_dates = deployer_hac$unique_event_dates,
  stringsAsFactors = FALSE
)
equivalence_path <- file.path(
  report_dir, "frl_deployer_calendar_hac_equivalence.csv"
)
write.csv(equivalence_result, equivalence_path, row.names = FALSE)

cat("Cluster diagnostics:", cluster_path, "\n")
cat("Residual dependence:", residual_path, "\n")
cat("Event-level coefficients:", event_coef_path, "\n")
cat("Calendar-time HAC:", hac_path, "\n")
cat("Calendar-time equivalence:", equivalence_path, "\n\n")

cat("Cluster comparison for headline terms\n")
print(
  cluster_results[
    cluster_results$term %in% c(
      "rel_upstream_hardware",
      "rel_downstream_deployer",
      "rel_competitor"
    ),
    c("method", "term", "coef", "se", "p")
  ],
  row.names = FALSE
)

cat("\nWithin-firm residual dependence\n")
print(
  residual_results[
    ,
    c("model", "gap_bin", "pair_count", "pooled_pair_correlation")
  ],
  row.names = FALSE
)

cat("\nCalendar-time HAC at 20 trading days\n")
print(
  hac_results[
    hac_results$bandwidth_trading_days == 20 &
      hac_results$term %in% c(
        "rel_upstream_hardware",
        "rel_downstream_deployer",
        "rel_competitor"
      ),
    c("term", "estimate", "se", "p", "events", "unique_event_dates")
  ],
  row.names = FALSE
)

cat("\nCalendar-time deployer equivalence\n")
print(equivalence_result, row.names = FALSE)
