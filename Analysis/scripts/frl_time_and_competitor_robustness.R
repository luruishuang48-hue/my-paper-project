#!/usr/bin/env Rscript

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
panel_path <- Sys.getenv(
  "FRL_PANEL_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_panel.csv")
)
report_dir <- Sys.getenv(
  "FRL_REPORT_DIR",
  unset = file.path(root, "Analysis", "reports")
)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)

position_terms <- c(
  "rel_upstream_hardware",
  "rel_upstream_cloud",
  "rel_downstream_integrator",
  "rel_downstream_deployer",
  "rel_downstream_enabler",
  "rel_competitor",
  "rel_is_investor",
  "rel_is_owner"
)
control_terms <- c(
  "size_log_assets", "bm_ratio", "bm_missing", "volatility", "momentum"
)
outcomes <- c(
  market_model = "car_mm_spy_0_20",
  fama_french_3factor = "car_ff3_0_20"
)
numeric_cols <- c(
  unname(outcomes), "car_mm_qqq_0_20", "car_mm_soxx_0_20",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  position_terms
)
for (column in numeric_cols) {
  df[[column]] <- suppressWarnings(as.numeric(df[[column]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
df$post_2025 <- as.numeric(df$event_trading_date >= "2025-01-01")
df$issuer_id <- ifelse(df$ticker %in% c("GOOG", "GOOGL"), "ALPHABET", df$ticker)

base <- df[
  df$is_main_ndxt == "True" &
    df$event_excluded_identity == "False" &
    !is.na(df$size_log_assets) &
    !is.na(df$volatility) &
    !is.na(df$momentum),
]
base$bm_missing <- as.numeric(is.na(base$bm_ratio))
base$bm_ratio[is.na(base$bm_ratio)] <- 0

star <- function(p) {
  ifelse(
    is.na(p), "",
    ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
  )
}

complete_model_data <- function(dat, formula) {
  model_data <- model.frame(formula, data = dat, na.action = na.pass)
  dat[complete.cases(model_data), , drop = FALSE]
}

make_psd <- function(covariance) {
  original_dimnames <- dimnames(covariance)
  covariance <- (covariance + t(covariance)) / 2
  decomposition <- eigen(covariance, symmetric = TRUE)
  minimum <- min(decomposition$values)
  fixed <- minimum < 0
  if (fixed) {
    decomposition$values[decomposition$values < 0] <- 0
    covariance <- decomposition$vectors %*%
      diag(decomposition$values, nrow = length(decomposition$values)) %*%
      t(decomposition$vectors)
    dimnames(covariance) <- original_dimnames
  }
  list(vcov = covariance, minimum = minimum, fixed = fixed)
}

multiway_vcov <- function(fit, dat, second_cluster = "ticker") {
  clusters <- data.frame(
    event_id = dat$event_id,
    cluster_2 = dat[[second_cluster]]
  )
  raw <- vcovCL(
    fit,
    cluster = clusters,
    type = "HC1",
    cadjust = TRUE,
    multi0 = TRUE
  )
  fixed <- make_psd(raw)
  fixed$df <- min(
    length(unique(dat$event_id)),
    length(unique(dat[[second_cluster]]))
  ) - 1
  fixed$cluster_1 <- length(unique(dat$event_id))
  fixed$cluster_2 <- length(unique(dat[[second_cluster]]))
  fixed
}

linear_stat <- function(beta, covariance, contrast, df) {
  estimable <- intersect(names(beta), rownames(covariance))
  beta <- beta[estimable]
  beta <- beta[!is.na(beta)]
  covariance <- covariance[
    names(beta), names(beta), drop = FALSE
  ]
  common <- intersect(names(contrast), names(beta))
  vector <- setNames(rep(0, length(beta)), names(beta))
  vector[common] <- contrast[common]
  estimate <- unname(sum(vector * beta))
  variance <- unname(t(vector) %*% covariance %*% vector)
  se <- if (is.finite(variance) && variance >= 0) sqrt(variance) else NA_real_
  t_value <- estimate / se
  p <- 2 * pt(abs(t_value), df = df, lower.tail = FALSE)
  critical <- qt(0.975, df = df)
  list(
    estimate = estimate,
    se = se,
    t = t_value,
    p = p,
    df = df,
    ci_low = estimate - critical * se,
    ci_high = estimate + critical * se
  )
}

fit_time_model <- function(dat, outcome, benchmark) {
  interaction_terms <- paste0(position_terms, ":post_2025")
  formula <- as.formula(
    paste(
      outcome, "~",
      paste(
        c(
          position_terms, interaction_terms, control_terms,
          "factor(release_year)"
        ),
        collapse = " + "
      )
    )
  )
  d <- complete_model_data(dat, formula)
  event_fit <- lm_robust(
    formula,
    data = d,
    clusters = d$event_id,
    se_type = "CR2"
  )
  event_beta <- coef(event_fit)
  event_vcov <- vcov(event_fit)
  event_table <- summary(event_fit)$coefficients

  ols_fit <- lm(formula, data = d)
  two <- multiway_vcov(ols_fit, d, "ticker")
  two_beta <- coef(ols_fit)

  rows <- list()
  index <- 0
  for (term in position_terms) {
    interaction <- paste0(term, ":post_2025")
    event_df <- min(event_table[c(term, interaction), "DF"], na.rm = TRUE)
    estimands <- list(
      early_2022_2024 = setNames(1, term),
      change_after_2025 = setNames(1, interaction),
      late_2025_2026 = setNames(c(1, 1), c(term, interaction))
    )
    for (estimand in names(estimands)) {
      event_result <- linear_stat(
        event_beta, event_vcov, estimands[[estimand]], event_df
      )
      index <- index + 1
      rows[[index]] <- data.frame(
        benchmark = benchmark,
        outcome = outcome,
        term = term,
        estimand = estimand,
        method = "event_CR2",
        estimate = event_result$estimate,
        estimate_pp = 100 * event_result$estimate,
        se = event_result$se,
        p = event_result$p,
        stars = star(event_result$p),
        ci95_low = event_result$ci_low,
        ci95_high = event_result$ci_high,
        observations = nrow(d),
        events = length(unique(d$event_id)),
        firms = length(unique(d$ticker)),
        df = event_result$df,
        stringsAsFactors = FALSE
      )

      two_result <- linear_stat(
        two_beta, two$vcov, estimands[[estimand]], two$df
      )
      index <- index + 1
      rows[[index]] <- data.frame(
        benchmark = benchmark,
        outcome = outcome,
        term = term,
        estimand = estimand,
        method = "event_x_firm_HC1",
        estimate = two_result$estimate,
        estimate_pp = 100 * two_result$estimate,
        se = two_result$se,
        p = two_result$p,
        stars = star(two_result$p),
        ci95_low = two_result$ci_low,
        ci95_high = two_result$ci_high,
        observations = nrow(d),
        events = length(unique(d$event_id)),
        firms = length(unique(d$ticker)),
        df = two_result$df,
        stringsAsFactors = FALSE
      )
    }
  }

  interaction_names <- paste0(position_terms, ":post_2025")
  joint_test <- function(beta, covariance, denominator_df, method) {
    values <- beta[interaction_names]
    sub_vcov <- covariance[interaction_names, interaction_names, drop = FALSE]
    decomposition <- eigen(
      (sub_vcov + t(sub_vcov)) / 2,
      symmetric = TRUE
    )
    tolerance <- max(decomposition$values) * 1e-10
    keep <- decomposition$values > tolerance
    rank <- sum(keep)
    projected <- as.numeric(
      t(decomposition$vectors[, keep, drop = FALSE]) %*% values
    )
    statistic <- sum(
      projected^2 / decomposition$values[keep]
    ) / rank
    data.frame(
      benchmark = benchmark,
      outcome = outcome,
      test = "all_position_changes_after_2025_equal_zero",
      method = method,
      numerator_df = rank,
      denominator_df = denominator_df,
      f = statistic,
      p = pf(
        statistic,
        df1 = rank,
        df2 = denominator_df,
        lower.tail = FALSE
      ),
      observations = nrow(d),
      events = length(unique(d$event_id)),
      firms = length(unique(d$ticker)),
      stringsAsFactors = FALSE
    )
  }
  event_denominator_df <- min(event_table[interaction_names, "DF"], na.rm = TRUE)
  joint <- rbind(
    joint_test(
      event_beta, event_vcov, event_denominator_df, "event_CR2"
    ),
    joint_test(
      two_beta, two$vcov, two$df, "event_x_firm_HC1"
    )
  )

  hardware_change <- "rel_upstream_hardware:post_2025"
  competitor_change <- "rel_competitor:post_2025"
  change_difference <- setNames(
    c(1, -1),
    c(hardware_change, competitor_change)
  )
  contrast_df <- min(
    event_table[c(hardware_change, competitor_change), "DF"],
    na.rm = TRUE
  )
  event_contrast <- linear_stat(
    event_beta, event_vcov, change_difference, contrast_df
  )
  two_contrast <- linear_stat(
    two_beta, two$vcov, change_difference, two$df
  )
  contrasts <- rbind(
    data.frame(
      benchmark = benchmark,
      outcome = outcome,
      contrast = "hardware_change_minus_competitor_change_after_2025",
      method = "event_CR2",
      estimate = event_contrast$estimate,
      estimate_pp = 100 * event_contrast$estimate,
      se = event_contrast$se,
      p = event_contrast$p,
      stars = star(event_contrast$p),
      ci95_low = event_contrast$ci_low,
      ci95_high = event_contrast$ci_high,
      ci95_low_pp = 100 * event_contrast$ci_low,
      ci95_high_pp = 100 * event_contrast$ci_high,
      observations = nrow(d),
      events = length(unique(d$event_id)),
      firms = length(unique(d$ticker)),
      df = event_contrast$df,
      stringsAsFactors = FALSE
    ),
    data.frame(
      benchmark = benchmark,
      outcome = outcome,
      contrast = "hardware_change_minus_competitor_change_after_2025",
      method = "event_x_firm_HC1",
      estimate = two_contrast$estimate,
      estimate_pp = 100 * two_contrast$estimate,
      se = two_contrast$se,
      p = two_contrast$p,
      stars = star(two_contrast$p),
      ci95_low = two_contrast$ci_low,
      ci95_high = two_contrast$ci_high,
      ci95_low_pp = 100 * two_contrast$ci_low,
      ci95_high_pp = 100 * two_contrast$ci_high,
      observations = nrow(d),
      events = length(unique(d$event_id)),
      firms = length(unique(d$ticker)),
      df = two_contrast$df,
      stringsAsFactors = FALSE
    )
  )
  list(
    results = do.call(rbind, rows),
    joint = joint,
    contrasts = contrasts
  )
}

time_results <- list()
time_joint <- list()
time_contrasts <- list()
for (benchmark in names(outcomes)) {
  result <- fit_time_model(base, outcomes[[benchmark]], benchmark)
  time_results[[benchmark]] <- result$results
  time_joint[[benchmark]] <- result$joint
  time_contrasts[[benchmark]] <- result$contrasts
}
time_results <- do.call(rbind, time_results)
time_joint <- do.call(rbind, time_joint)
time_contrasts <- do.call(rbind, time_contrasts)
write.csv(
  time_results,
  file.path(report_dir, "frl_time_heterogeneity_results.csv"),
  row.names = FALSE
)
write.csv(
  time_joint,
  file.path(report_dir, "frl_time_heterogeneity_joint_tests.csv"),
  row.names = FALSE
)
write.csv(
  time_contrasts,
  file.path(report_dir, "frl_time_heterogeneity_contrasts.csv"),
  row.names = FALSE
)

fit_competitor <- function(
    dat,
    outcome,
    spec,
    fixed_effects = "factor(release_year)",
    second_cluster = "ticker",
    detail = "") {
  formula <- as.formula(
    paste(
      outcome, "~",
      paste(
        c(position_terms, control_terms, fixed_effects),
        collapse = " + "
      )
    )
  )
  d <- complete_model_data(dat, formula)
  event_fit <- tryCatch(
    lm_robust(
      formula,
      data = d,
      clusters = d$event_id,
      se_type = "CR2"
    ),
    error = function(error) NULL
  )
  ols_fit <- tryCatch(lm(formula, data = d), error = function(error) NULL)
  if (is.null(event_fit) || is.null(ols_fit) ||
      !("rel_competitor" %in% names(coef(ols_fit)))) {
    return(data.frame())
  }

  event_table <- summary(event_fit)$coefficients
  if (!("rel_competitor" %in% rownames(event_table))) {
    return(data.frame())
  }
  event_row <- event_table["rel_competitor", ]
  two <- multiway_vcov(ols_fit, d, second_cluster)
  two_beta <- coef(ols_fit)
  two_contrast <- setNames(1, "rel_competitor")
  two_row <- linear_stat(two_beta, two$vcov, two_contrast, two$df)

  competitor_rows <- d[d$rel_competitor == 1, , drop = FALSE]
  rbind(
    data.frame(
      spec = spec,
      detail = detail,
      outcome = outcome,
      method = "event_CR2",
      coef = unname(event_row["Estimate"]),
      coef_pp = 100 * unname(event_row["Estimate"]),
      se = unname(event_row["Std. Error"]),
      p = unname(event_row["Pr(>|t|)"]),
      stars = star(unname(event_row["Pr(>|t|)"])),
      observations = nrow(d),
      events = length(unique(d$event_id)),
      firms = length(unique(d$ticker)),
      competitor_rows = nrow(competitor_rows),
      competitor_events = length(unique(competitor_rows$event_id)),
      competitor_firms = length(unique(competitor_rows$ticker)),
      cluster_2 = NA_integer_,
      stringsAsFactors = FALSE
    ),
    data.frame(
      spec = spec,
      detail = detail,
      outcome = outcome,
      method = paste0("event_x_", second_cluster, "_HC1"),
      coef = two_row$estimate,
      coef_pp = 100 * two_row$estimate,
      se = two_row$se,
      p = two_row$p,
      stars = star(two_row$p),
      observations = nrow(d),
      events = length(unique(d$event_id)),
      firms = length(unique(d$ticker)),
      competitor_rows = nrow(competitor_rows),
      competitor_events = length(unique(competitor_rows$event_id)),
      competitor_firms = length(unique(competitor_rows$ticker)),
      cluster_2 = two$cluster_2,
      stringsAsFactors = FALSE
    )
  )
}

robustness <- list()
robustness_index <- 0
add_robustness <- function(result) {
  if (nrow(result)) {
    robustness_index <<- robustness_index + 1
    robustness[[robustness_index]] <<- result
  }
}

add_robustness(
  fit_competitor(
    base, "car_mm_spy_0_20", "baseline_spy"
  )
)
add_robustness(
  fit_competitor(
    base, "car_ff3_0_20", "baseline_ff3"
  )
)
add_robustness(
  fit_competitor(
    base, "car_mm_qqq_0_20", "baseline_qqq"
  )
)
add_robustness(
  fit_competitor(
    base, "car_mm_soxx_0_20", "baseline_soxx"
  )
)
add_robustness(
  fit_competitor(
    base,
    "car_mm_spy_0_20",
    "event_and_firm_fixed_effects",
    fixed_effects = "factor(event_id) + factor(ticker)"
  )
)
add_robustness(
  fit_competitor(
    base,
    "car_mm_spy_0_20",
    "issuer_cluster_alphabet_combined",
    second_cluster = "issuer_id"
  )
)

for (ticker in c("GOOG", "GOOGL")) {
  add_robustness(
    fit_competitor(
      base[base$ticker != ticker, ],
      "car_mm_spy_0_20",
      "alphabet_share_class",
      detail = paste0("drop_", ticker)
    )
  )
}

overlap_terms <- c(
  "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_is_investor", "rel_is_owner"
)
for (overlap in c(
  "rel_upstream_cloud",
  "rel_downstream_integrator",
  "rel_downstream_deployer"
)) {
  keep <- !(base$rel_competitor == 1 & base[[overlap]] == 1)
  add_robustness(
    fit_competitor(
      base[keep, ],
      "car_mm_spy_0_20",
      "exclude_competitor_overlap",
      detail = overlap
    )
  )
}
other_position_count <- rowSums(base[, overlap_terms, drop = FALSE] == 1)
pure_keep <- !(base$rel_competitor == 1 & other_position_count > 0)
add_robustness(
  fit_competitor(
    base[pure_keep, ],
    "car_mm_spy_0_20",
    "pure_competitor_pressure_test",
    detail = "drop_competitor_rows_with_any_other_position"
  )
)

competitor_tickers <- sort(unique(base$ticker[base$rel_competitor == 1]))
for (ticker in competitor_tickers) {
  add_robustness(
    fit_competitor(
      base[base$ticker != ticker, ],
      "car_mm_spy_0_20",
      "leave_one_competitor_ticker_out",
      detail = ticker
    )
  )
}

competitor_issuers <- sort(unique(base$issuer_id[base$rel_competitor == 1]))
for (issuer in competitor_issuers) {
  add_robustness(
    fit_competitor(
      base[base$issuer_id != issuer, ],
      "car_mm_spy_0_20",
      "leave_one_competitor_issuer_out",
      detail = issuer
    )
  )
}

event_creators <- unique(base[, c("event_id", "aa_creators")])
all_creators <- trimws(
  unlist(strsplit(event_creators$aa_creators, ";", fixed = TRUE))
)
all_creators <- sort(unique(all_creators[nzchar(all_creators)]))
for (creator in all_creators) {
  contains_creator <- vapply(
    strsplit(event_creators$aa_creators, ";", fixed = TRUE),
    function(values) creator %in% trimws(values),
    logical(1)
  )
  removed_events <- event_creators$event_id[contains_creator]
  removed_competitor_rows <- sum(
    base$event_id %in% removed_events & base$rel_competitor == 1
  )
  if (removed_competitor_rows > 0) {
    add_robustness(
      fit_competitor(
        base[!(base$event_id %in% removed_events), ],
        "car_mm_spy_0_20",
        "leave_one_creator_out",
        detail = creator
      )
    )
  }
}

robustness <- do.call(rbind, robustness)
write.csv(
  robustness,
  file.path(report_dir, "frl_competitor_robustness_results.csv"),
  row.names = FALSE
)

main_event_fit <- lm_robust(
  as.formula(
    paste(
      "car_mm_spy_0_20 ~",
      paste(
        c(position_terms, control_terms, "factor(release_year)"),
        collapse = " + "
      )
    )
  ),
  data = complete_model_data(
    base,
    as.formula(
      paste(
        "car_mm_spy_0_20 ~",
        paste(
          c(position_terms, control_terms, "factor(release_year)"),
          collapse = " + "
        )
      )
    )
  ),
  clusters = complete_model_data(
    base,
    as.formula(
      paste(
        "car_mm_spy_0_20 ~",
        paste(
          c(position_terms, control_terms, "factor(release_year)"),
          collapse = " + "
        )
      )
    )
  )$event_id,
  se_type = "CR2"
)
position_table <- summary(main_event_fit)$coefficients[position_terms, , drop = FALSE]
adjusted <- data.frame(
  term = position_terms,
  raw_p = position_table[, "Pr(>|t|)"],
  holm_p = p.adjust(position_table[, "Pr(>|t|)"], method = "holm"),
  bonferroni_p = p.adjust(
    position_table[, "Pr(>|t|)"], method = "bonferroni"
  ),
  stringsAsFactors = FALSE
)
write.csv(
  adjusted,
  file.path(report_dir, "frl_position_multiple_testing_adjustment.csv"),
  row.names = FALSE
)

cat(
  "time_rows=", nrow(time_results),
  " joint_rows=", nrow(time_joint),
  " contrast_rows=", nrow(time_contrasts),
  " competitor_rows=", nrow(robustness),
  "\n",
  sep = ""
)
