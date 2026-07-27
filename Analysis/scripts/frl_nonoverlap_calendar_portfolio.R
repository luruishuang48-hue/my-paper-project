#!/usr/bin/env Rscript
# FRL overlap-robust analyses.
#
# 1. Estimate the position regression on maximum-cardinality event sets whose
#    [0,+20] windows do not overlap. Event selection uses dates only.
# 2. Build daily event-driven long-short portfolios, collapse overlapping
#    event positions into one daily return, and use Newey-West inference.
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

panel <- read.csv(
  Sys.getenv(
    "FRL_PANEL_PATH",
    unset = file.path(root, "Analysis", "processed", "event_firm_panel.csv")
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
returns <- read.csv(
  file.path(root, "CAR", "processed", "returns_daily_long.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
ff3 <- read.csv(
  file.path(root, "CAR", "processed", "ff3_daily.csv"),
  stringsAsFactors = FALSE
)

num_cols <- c(
  "car_mm_spy_0_20", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner",
  "ret_adj_close"
)
for (col in intersect(num_cols, names(panel))) {
  panel[[col]] <- suppressWarnings(as.numeric(panel[[col]]))
}
returns$ret_adj_close <- suppressWarnings(as.numeric(returns$ret_adj_close))

panel$release_year <- substr(panel$event_trading_date, 1, 4)
base <- panel[
  panel$is_main_ndxt == "True" &
    panel$event_excluded_identity == "False" &
    !is.na(panel$car_mm_spy_0_20) &
    !is.na(panel$size_log_assets) &
    !is.na(panel$volatility) &
    !is.na(panel$momentum),
]
base$bm_missing <- as.numeric(is.na(base$bm_ratio))
base$bm_ratio[is.na(base$bm_ratio)] <- 0
base$unrelated <- as.numeric(rowSums(
  base[
    ,
    c(
      "rel_upstream_hardware", "rel_upstream_cloud",
      "rel_downstream_integrator", "rel_downstream_deployer",
      "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner"
    )
  ],
  na.rm = TRUE
) == 0)

returns$date <- as.Date(returns$date)
ff3$date <- as.Date(ff3$date)
trading_dates <- sort(unique(returns$date))
base$trading_day_index <- match(
  as.Date(base$event_trading_date),
  trading_dates
)
if (anyNA(base$trading_day_index)) {
  stop("Some event dates are absent from the return trading calendar.")
}

position_terms <- c(
  "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
controls <- c(
  "size_log_assets", "bm_ratio", "bm_missing", "volatility", "momentum"
)
position_formula <- as.formula(
  paste(
    "car_mm_spy_0_20 ~",
    paste(c(position_terms, controls, "factor(release_year)"), collapse = " + ")
  )
)
headline_terms <- c(
  "rel_upstream_hardware",
  "rel_downstream_deployer",
  "rel_competitor"
)

star <- function(p) {
  ifelse(
    is.na(p), "",
    ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
  )
}

# -------------------------------------------------------------------------
# 1. Maximum-cardinality non-overlapping event sets
# -------------------------------------------------------------------------

events <- unique(
  base[
    ,
    c(
      "event_id", "event_trading_date", "trading_day_index",
      "date_confidence"
    )
  ]
)
events <- events[
  order(events$trading_day_index, events$event_id),
]
rownames(events) <- NULL

greedy_select <- function(event_data, direction = c("earliest", "latest")) {
  direction <- match.arg(direction)
  if (direction == "earliest") {
    order_index <- order(
      event_data$trading_day_index,
      event_data$event_id
    )
  } else {
    order_index <- order(
      -event_data$trading_day_index,
      event_data$event_id
    )
  }
  selected <- integer()
  for (i in order_index) {
    if (
      !length(selected) ||
        all(abs(
          event_data$trading_day_index[i] -
            event_data$trading_day_index[selected]
        ) > 20)
    ) {
      selected <- c(selected, i)
    }
  }
  sort(selected)
}

optimal_dp <- numeric(nrow(events) + 1)
previous_compatible <- integer(nrow(events))
for (i in seq_len(nrow(events))) {
  compatible <- which(
    events$trading_day_index[seq_len(i - 1)] <
      events$trading_day_index[i] - 20
  )
  previous_compatible[i] <- if (length(compatible)) max(compatible) else 0
  optimal_dp[i + 1] <- max(
    optimal_dp[i],
    1 + optimal_dp[previous_compatible[i] + 1]
  )
}

sample_optimal_set <- function() {
  selected <- integer()
  i <- nrow(events)
  while (i > 0) {
    include_value <- 1 + optimal_dp[previous_compatible[i] + 1]
    exclude_value <- optimal_dp[i]
    if (include_value > exclude_value) {
      choose_include <- TRUE
    } else if (include_value < exclude_value) {
      choose_include <- FALSE
    } else {
      choose_include <- sample(c(FALSE, TRUE), 1)
    }
    if (choose_include) {
      selected <- c(i, selected)
      i <- previous_compatible[i]
    } else {
      i <- i - 1
    }
  }
  selected
}

fit_nonoverlap <- function(selected_indices, selection, draw = NA_integer_) {
  selected_events <- events$event_id[selected_indices]
  dat <- base[base$event_id %in% selected_events, ]

  event_fit <- lm_robust(
    position_formula,
    data = dat,
    clusters = dat$event_id,
    se_type = "CR2"
  )
  firm_fit <- lm_robust(
    position_formula,
    data = dat,
    clusters = dat$ticker,
    se_type = "CR2"
  )
  ols_fit <- lm(position_formula, data = dat)
  two_way_clusters <- data.frame(
    event_id = dat$event_id,
    ticker = dat$ticker
  )
  two_way_vcov_raw <- vcovCL(
    ols_fit,
    cluster = two_way_clusters,
    type = "HC1",
    cadjust = TRUE,
    multi0 = TRUE,
    fix = FALSE
  )
  two_way_min_eigen <- min(eigen(
    two_way_vcov_raw,
    symmetric = TRUE,
    only.values = TRUE
  )$values)
  two_way_vcov <- vcovCL(
    ols_fit,
    cluster = two_way_clusters,
    type = "HC1",
    cadjust = TRUE,
    multi0 = TRUE,
    fix = two_way_min_eigen < -1e-10
  )
  two_way_se <- sqrt(diag(two_way_vcov))
  two_way_coef <- coef(ols_fit)
  two_way_df <- min(
    length(unique(dat$event_id)),
    length(unique(dat$ticker))
  ) - 1
  two_way_p <- 2 * pt(
    abs(two_way_coef / two_way_se),
    df = two_way_df,
    lower.tail = FALSE
  )
  event_table <- summary(event_fit)$coefficients
  firm_table <- summary(firm_fit)$coefficients

  rows <- list()
  row_i <- 0
  for (term in headline_terms) {
    for (method in c("event_CR2", "firm_CR2", "event_x_firm_HC1")) {
      if (method == "event_x_firm_HC1") {
        if (!(term %in% names(two_way_coef))) {
          next
        }
        estimate <- two_way_coef[term]
        standard_error <- two_way_se[term]
        p_value <- two_way_p[term]
      } else {
        tab <- if (method == "event_CR2") event_table else firm_table
        if (!(term %in% rownames(tab))) {
          next
        }
        estimate <- tab[term, "Estimate"]
        standard_error <- tab[term, "Std. Error"]
        p_value <- tab[term, "Pr(>|t|)"]
      }
      row_i <- row_i + 1
      rows[[row_i]] <- data.frame(
        selection = selection,
        draw = draw,
        method = method,
        term = term,
        coef = estimate,
        se = standard_error,
        p = p_value,
        stars = star(p_value),
        observations = nobs(event_fit),
        events = length(unique(dat$event_id)),
        unique_event_dates = length(unique(dat$event_trading_date)),
        first_event_date = min(dat$event_trading_date),
        last_event_date = max(dat$event_trading_date),
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

earliest_indices <- greedy_select(events, "earliest")
latest_indices <- greedy_select(events, "latest")
deterministic_results <- rbind(
  fit_nonoverlap(earliest_indices, "earliest_first"),
  fit_nonoverlap(latest_indices, "latest_first")
)

selected_events_output <- rbind(
  transform(
    events[earliest_indices, ],
    selection = "earliest_first"
  ),
  transform(
    events[latest_indices, ],
    selection = "latest_first"
  )
)
selected_events_path <- file.path(
  report_dir, "frl_nonoverlap_selected_events.csv"
)
write.csv(selected_events_output, selected_events_path, row.names = FALSE)

deterministic_path <- file.path(
  report_dir, "frl_nonoverlap_deterministic_results.csv"
)
write.csv(deterministic_results, deterministic_path, row.names = FALSE)

set.seed(20260727)
n_draws <- 250
random_rows <- vector("list", n_draws)
for (draw in seq_len(n_draws)) {
  selected <- sample_optimal_set()
  random_rows[[draw]] <- fit_nonoverlap(
    selected,
    "random_maximum_set",
    draw
  )
}
random_results <- do.call(rbind, random_rows)
random_path <- file.path(
  report_dir, "frl_nonoverlap_random_maximum_results.csv"
)
write.csv(random_results, random_path, row.names = FALSE)

random_summary_rows <- list()
summary_i <- 0
for (method in unique(random_results$method)) {
  for (term in unique(random_results$term)) {
    x <- random_results[
      random_results$method == method &
        random_results$term == term,
    ]
    summary_i <- summary_i + 1
    random_summary_rows[[summary_i]] <- data.frame(
      method = method,
      term = term,
      draws = nrow(x),
      events_min = min(x$events),
      events_max = max(x$events),
      coef_mean = mean(x$coef),
      coef_median = median(x$coef),
      coef_p05 = quantile(x$coef, 0.05),
      coef_p95 = quantile(x$coef, 0.95),
      p_median = median(x$p),
      share_p_lt_005 = mean(x$p < 0.05),
      share_p_lt_010 = mean(x$p < 0.10),
      stringsAsFactors = FALSE
    )
  }
}
random_summary <- do.call(rbind, random_summary_rows)
random_summary_path <- file.path(
  report_dir, "frl_nonoverlap_random_maximum_summary.csv"
)
write.csv(random_summary, random_summary_path, row.names = FALSE)

# -------------------------------------------------------------------------
# 2. Calendar-time portfolios
# -------------------------------------------------------------------------

nw_result <- function(
  data,
  outcome,
  portfolio,
  window,
  lag,
  active_exposure = FALSE
) {
  if (active_exposure) {
    data$active_indicator <- as.numeric(data$active_events > 0)
    data$active_mkt <- data$active_indicator * data$Mkt_RF_decimal
    data$active_smb <- data$active_indicator * data$SMB_decimal
    data$active_hml <- data$active_indicator * data$HML_decimal
    formula <- as.formula(
      paste(
        outcome,
        "~ 0 + active_indicator + active_mkt + active_smb + active_hml"
      )
    )
    alpha_term <- "active_indicator"
  } else {
    formula <- as.formula(
      paste(
        outcome,
        "~ Mkt_RF_decimal + SMB_decimal + HML_decimal"
      )
    )
    alpha_term <- "(Intercept)"
  }
  fit <- lm(formula, data = data)
  vcov_nw <- NeweyWest(
    fit,
    lag = lag,
    prewhite = FALSE,
    adjust = TRUE
  )
  alpha <- coef(fit)[alpha_term]
  se <- sqrt(diag(vcov_nw))[alpha_term]
  df_t <- df.residual(fit)
  p <- 2 * pt(abs(alpha / se), df = df_t, lower.tail = FALSE)
  q95 <- qt(0.975, df = df_t)
  data.frame(
    portfolio = portfolio,
    event_window = window,
    nw_lag = lag,
    daily_alpha = alpha,
    daily_se = se,
    p = p,
    stars = star(p),
    ci95_low = alpha - q95 * se,
    ci95_high = alpha + q95 * se,
    annualized_alpha_arithmetic = if (active_exposure) {
      alpha * mean(data$active_events > 0) * 252
    } else {
      alpha * 252
    },
    active_day_alpha = if (active_exposure) alpha else NA_real_,
    daily_mean_return = mean(data[[outcome]], na.rm = TRUE),
    annualized_mean_return_arithmetic =
      mean(data[[outcome]], na.rm = TRUE) * 252,
    observations = nobs(fit),
    active_days = if ("active_events" %in% names(data)) {
      sum(data$active_events > 0)
    } else {
      nrow(data)
    },
    share_active_days = if ("active_events" %in% names(data)) {
      mean(data$active_events > 0)
    } else {
      1
    },
    stringsAsFactors = FALSE
  )
}

# Full-period static portfolio, reproduced from the earlier analysis.
all_relationships <- panel[panel$event_excluded_identity == "False", ]
hardware_tickers <- sort(unique(
  all_relationships$ticker[
    all_relationships$rel_upstream_hardware == 1
  ]
))
downstream_tickers <- sort(unique(
  all_relationships$ticker[
    all_relationships$rel_downstream_integrator == 1 |
      all_relationships$rel_downstream_deployer == 1
  ]
))

portfolio_returns <- returns[
  returns$date >= as.Date("2022-04-01") &
    returns$date <= as.Date("2026-04-30") &
    returns$symbol %in% c(hardware_tickers, downstream_tickers),
  c("date", "symbol", "ret_adj_close")
]
portfolio_returns$leg <- ifelse(
  portfolio_returns$symbol %in% hardware_tickers,
  "hardware",
  "downstream"
)
static_daily <- aggregate(
  ret_adj_close ~ date + leg,
  data = portfolio_returns,
  FUN = function(x) mean(x, na.rm = TRUE)
)
static_wide <- reshape(
  static_daily,
  idvar = "date",
  timevar = "leg",
  direction = "wide"
)
names(static_wide) <- sub("ret_adj_close\\.", "", names(static_wide))
static_wide$static_hardware_minus_downstream <-
  static_wide$hardware - static_wide$downstream
static_wide <- merge(static_wide, ff3, by = "date")

portfolio_results <- list()
portfolio_i <- 0
for (lag in c(5, 10, 20, 40)) {
  portfolio_i <- portfolio_i + 1
  portfolio_results[[portfolio_i]] <- nw_result(
    static_wide,
    "static_hardware_minus_downstream",
    "static_hardware_minus_downstream",
    "full_period",
    lag
  )
}

# Event-driven position portfolios.
portfolio_terms <- c(
  hardware = "rel_upstream_hardware",
  competitor = "rel_competitor",
  deployer = "rel_downstream_deployer"
)
main_tickers <- sort(unique(base$ticker))
daily_main_returns <- returns[
  returns$symbol %in% main_tickers,
  c("date", "symbol", "ret_adj_close")
]
return_key <- split(
  daily_main_returns$ret_adj_close,
  paste(daily_main_returns$date, daily_main_returns$symbol)
)
lookup_returns <- function(date_value, tickers) {
  keys <- paste(date_value, tickers)
  values <- unlist(return_key[keys], use.names = FALSE)
  values[is.finite(values)]
}

event_portfolio_rows <- list()
event_portfolio_i <- 0
window_specs <- list(
  pre_21_1 = seq.int(-21, -1),
  pre_11_1 = seq.int(-11, -1),
  `0_10` = seq.int(0, 10),
  `0_20` = seq.int(0, 20)
)
for (window_name in names(window_specs)) {
  offsets <- window_specs[[window_name]]
  for (event_value in unique(base$event_id)) {
    event_data <- base[base$event_id == event_value, ]
    event_index <- event_data$trading_day_index[1]
    active_indices <- event_index + offsets
    active_indices <- active_indices[
      active_indices >= 1 &
        active_indices <= length(trading_dates)
    ]
    unrelated_tickers <- event_data$ticker[event_data$unrelated == 1]

    for (portfolio_name in names(portfolio_terms)) {
      term <- portfolio_terms[[portfolio_name]]
      long_tickers <- event_data$ticker[event_data[[term]] == 1]
      if (!length(long_tickers) || !length(unrelated_tickers)) {
        next
      }
      for (day_index in active_indices) {
        date_value <- trading_dates[day_index]
        long_returns <- lookup_returns(date_value, long_tickers)
        short_returns <- lookup_returns(date_value, unrelated_tickers)
        if (!length(long_returns) || !length(short_returns)) {
          next
        }
        event_portfolio_i <- event_portfolio_i + 1
        event_portfolio_rows[[event_portfolio_i]] <- data.frame(
          date = date_value,
          event_id = event_value,
          portfolio = paste0(portfolio_name, "_minus_unrelated"),
          event_window = window_name,
          event_portfolio_return =
            mean(long_returns) - mean(short_returns),
          stringsAsFactors = FALSE
        )
      }
    }
  }
}
event_portfolio_long <- do.call(rbind, event_portfolio_rows)
event_portfolio_long$date <- as.Date(
  event_portfolio_long$date,
  origin = "1970-01-01"
)

event_daily <- aggregate(
  event_portfolio_return ~ date + portfolio + event_window,
  data = event_portfolio_long,
  FUN = mean
)
active_counts <- aggregate(
  event_id ~ date + portfolio + event_window,
  data = event_portfolio_long,
  FUN = function(x) length(unique(x))
)
names(active_counts)[names(active_counts) == "event_id"] <- "active_events"
event_daily <- merge(
  event_daily,
  active_counts,
  by = c("date", "portfolio", "event_window")
)

event_daily_complete_rows <- list()
complete_i <- 0
for (portfolio_name in unique(event_daily$portfolio)) {
  for (window_name in unique(event_daily$event_window)) {
    observed <- event_daily[
      event_daily$portfolio == portfolio_name &
        event_daily$event_window == window_name,
    ]
    if (!nrow(observed)) {
      next
    }
    full_dates <- data.frame(
      date = trading_dates[
        trading_dates >= min(observed$date) &
          trading_dates <= max(observed$date)
      ]
    )
    complete <- merge(full_dates, observed, by = "date", all.x = TRUE)
    complete$portfolio <- portfolio_name
    complete$event_window <- window_name
    complete$event_portfolio_return[
      is.na(complete$event_portfolio_return)
    ] <- 0
    complete$active_events[is.na(complete$active_events)] <- 0
    complete_i <- complete_i + 1
    event_daily_complete_rows[[complete_i]] <- complete
  }
}
event_daily_complete <- do.call(rbind, event_daily_complete_rows)
event_daily_complete <- merge(
  event_daily_complete,
  ff3,
  by = "date"
)

post_pre_contrast_rows <- list()
contrast_i <- 0
window_pairs <- list(
  `0_10_minus_pre_11_1` = c("0_10", "pre_11_1"),
  `0_20_minus_pre_21_1` = c("0_20", "pre_21_1")
)

for (portfolio_name in unique(event_daily_complete$portfolio)) {
  for (window_name in unique(event_daily_complete$event_window)) {
    dat <- event_daily_complete[
      event_daily_complete$portfolio == portfolio_name &
        event_daily_complete$event_window == window_name,
    ]
    for (lag in c(5, 10, 20, 40)) {
      portfolio_i <- portfolio_i + 1
      portfolio_results[[portfolio_i]] <- nw_result(
        dat,
        "event_portfolio_return",
      portfolio_name,
      window_name,
      lag,
      active_exposure = TRUE
      )
    }
  }

  for (pair_name in names(window_pairs)) {
    post_window <- window_pairs[[pair_name]][1]
    pre_window <- window_pairs[[pair_name]][2]
    post <- event_daily_complete[
      event_daily_complete$portfolio == portfolio_name &
        event_daily_complete$event_window == post_window,
      c("date", "event_portfolio_return", "active_events")
    ]
    pre <- event_daily_complete[
      event_daily_complete$portfolio == portfolio_name &
        event_daily_complete$event_window == pre_window,
      c("date", "event_portfolio_return", "active_events")
    ]
    names(post)[2:3] <- c("post_return", "post_active_events")
    names(pre)[2:3] <- c("pre_return", "pre_active_events")
    contrast_data <- merge(post, pre, by = "date", all = TRUE)
    contrast_data$post_return[is.na(contrast_data$post_return)] <- 0
    contrast_data$pre_return[is.na(contrast_data$pre_return)] <- 0
    contrast_data$post_active_events[
      is.na(contrast_data$post_active_events)
    ] <- 0
    contrast_data$pre_active_events[
      is.na(contrast_data$pre_active_events)
    ] <- 0
    contrast_data <- merge(
      contrast_data,
      ff3[
        ,
        c(
          "date", "Mkt_RF_decimal", "SMB_decimal", "HML_decimal"
        )
      ],
      by = "date"
    )
    contrast_data$post_active <- as.numeric(
      contrast_data$post_active_events > 0
    )
    contrast_data$pre_active <- as.numeric(
      contrast_data$pre_active_events > 0
    )
    contrast_data$post_mkt <-
      contrast_data$post_active * contrast_data$Mkt_RF_decimal
    contrast_data$post_smb <-
      contrast_data$post_active * contrast_data$SMB_decimal
    contrast_data$post_hml <-
      contrast_data$post_active * contrast_data$HML_decimal
    contrast_data$pre_mkt <-
      contrast_data$pre_active * contrast_data$Mkt_RF_decimal
    contrast_data$pre_smb <-
      contrast_data$pre_active * contrast_data$SMB_decimal
    contrast_data$pre_hml <-
      contrast_data$pre_active * contrast_data$HML_decimal
    contrast_data$return_difference <-
      contrast_data$post_return - contrast_data$pre_return

    contrast_formula <- return_difference ~ 0 +
      post_active + pre_active +
      post_mkt + post_smb + post_hml +
      pre_mkt + pre_smb + pre_hml
    contrast_fit <- lm(contrast_formula, data = contrast_data)
    contrast_vector <- rep(0, length(coef(contrast_fit)))
    names(contrast_vector) <- names(coef(contrast_fit))
    contrast_vector["post_active"] <- 1
    contrast_vector["pre_active"] <- 1

    for (lag in c(5, 10, 20, 40)) {
      contrast_vcov <- NeweyWest(
        contrast_fit,
        lag = lag,
        prewhite = FALSE,
        adjust = TRUE
      )
      estimate <- sum(contrast_vector * coef(contrast_fit))
      se <- sqrt(
        as.numeric(
          t(contrast_vector) %*%
            contrast_vcov %*%
            contrast_vector
        )
      )
      df_t <- df.residual(contrast_fit)
      p <- 2 * pt(abs(estimate / se), df = df_t, lower.tail = FALSE)
      contrast_i <- contrast_i + 1
      post_pre_contrast_rows[[contrast_i]] <- data.frame(
        portfolio = portfolio_name,
        contrast = pair_name,
        nw_lag = lag,
        post_alpha = coef(contrast_fit)["post_active"],
        pre_alpha = -coef(contrast_fit)["pre_active"],
        post_minus_pre_alpha = estimate,
        se = se,
        p = p,
        stars = star(p),
        observations = nobs(contrast_fit),
        stringsAsFactors = FALSE
      )
    }
  }
}

portfolio_results <- do.call(rbind, portfolio_results)
portfolio_results_path <- file.path(
  report_dir, "frl_calendar_time_portfolio_results.csv"
)
write.csv(
  portfolio_results,
  portfolio_results_path,
  row.names = FALSE
)

event_daily_path <- file.path(
  report_dir, "frl_event_driven_portfolio_daily.csv"
)
write.csv(
  event_daily_complete[
    ,
    c(
      "date", "portfolio", "event_window",
      "event_portfolio_return", "active_events"
    )
  ],
  event_daily_path,
  row.names = FALSE
)

post_pre_contrasts <- do.call(rbind, post_pre_contrast_rows)
post_pre_contrast_path <- file.path(
  report_dir, "frl_calendar_time_post_pre_contrasts.csv"
)
write.csv(
  post_pre_contrasts,
  post_pre_contrast_path,
  row.names = FALSE
)

cat("Non-overlap selected events:", selected_events_path, "\n")
cat("Non-overlap deterministic results:", deterministic_path, "\n")
cat("Non-overlap random results:", random_path, "\n")
cat("Non-overlap random summary:", random_summary_path, "\n")
cat("Calendar-time portfolio results:", portfolio_results_path, "\n")
cat("Event-driven daily portfolio:", event_daily_path, "\n\n")
cat("Calendar-time post-pre contrasts:", post_pre_contrast_path, "\n\n")

cat("Maximum non-overlap event count:", optimal_dp[nrow(events) + 1], "\n\n")
cat("Deterministic non-overlap results\n")
print(
  deterministic_results[
    deterministic_results$term %in% headline_terms,
    c("selection", "method", "term", "coef", "se", "p", "events")
  ],
  row.names = FALSE
)

cat("\nRandom maximum-set summary\n")
print(random_summary, row.names = FALSE)

cat("\nCalendar-time portfolio results at NW lag 20\n")
print(
  portfolio_results[
    portfolio_results$nw_lag == 20,
    c(
      "portfolio", "event_window", "daily_alpha", "daily_se", "p",
      "annualized_alpha_arithmetic", "observations", "share_active_days"
    )
  ],
  row.names = FALSE
)

cat("\nCalendar-time post-minus-pre contrasts at NW lag 20\n")
print(
  post_pre_contrasts[
    post_pre_contrasts$nw_lag == 20,
    c(
      "portfolio", "contrast", "post_alpha", "pre_alpha",
      "post_minus_pre_alpha", "se", "p"
    )
  ],
  row.names = FALSE
)
