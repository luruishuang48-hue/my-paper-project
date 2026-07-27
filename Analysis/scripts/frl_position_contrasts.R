#!/usr/bin/env Rscript
# Direct ecosystem-position contrasts.
#
# Outputs
#   Analysis/reports/frl_position_pairwise_contrasts.csv
#   Analysis/reports/frl_position_joint_tests.csv
# The specifications match the manuscript's position regressions:
# firm controls, year fixed effects, event-level CR2 inference, and
# event-by-firm two-way HC1 inference.

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
  unname(outcomes), "size_log_assets", "bm_ratio", "volatility", "momentum",
  position_terms
)
for (col in numeric_cols) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

df$release_year <- substr(df$event_trading_date, 1, 4)
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
  mf <- model.frame(formula, data = dat, na.action = na.pass)
  dat[complete.cases(mf), , drop = FALSE]
}

two_way_vcov <- function(fit, dat) {
  clusters <- data.frame(event_id = dat$event_id, ticker = dat$ticker)
  vcov_raw <- vcovCL(
    fit,
    cluster = clusters,
    type = "HC1",
    cadjust = TRUE,
    multi0 = FALSE,
    fix = FALSE
  )
  min_eigen <- min(eigen(
    vcov_raw,
    symmetric = TRUE,
    only.values = TRUE
  )$values)
  fixed <- min_eigen < -1e-10
  vcov_use <- if (fixed) {
    vcovCL(
      fit,
      cluster = clusters,
      type = "HC1",
      cadjust = TRUE,
      multi0 = FALSE,
      fix = TRUE
    )
  } else {
    vcov_raw
  }
  list(vcov = vcov_use, min_eigen = min_eigen, fixed = fixed)
}

# Reparameterize the position block so the first transformed coefficient is
# exactly c'beta. This lets lm_robust compute the CR2 Satterthwaite degrees of
# freedom for each single linear contrast.
event_cr2_contrast <- function(dat, outcome, cvec) {
  stopifnot(length(cvec) == length(position_terms), sum(cvec^2) > 0)
  q_complete <- qr.Q(qr(matrix(cvec, ncol = 1)), complete = TRUE)
  transform <- cbind(cvec / sum(cvec^2), q_complete[, -1, drop = FALSE])
  stopifnot(
    max(abs(drop(cvec %*% transform) - c(1, rep(0, ncol(transform) - 1)))) <
      1e-10
  )

  transformed <- as.matrix(dat[, position_terms, drop = FALSE]) %*% transform
  transformed_names <- c(
    "target_contrast",
    paste0("position_nuisance_", seq_len(ncol(transformed) - 1))
  )
  colnames(transformed) <- transformed_names
  d <- cbind(dat, as.data.frame(transformed))
  rhs <- paste(
    c(transformed_names, control_terms, "factor(release_year)"),
    collapse = " + "
  )
  formula <- as.formula(paste(outcome, "~", rhs))
  fit <- lm_robust(
    formula,
    data = d,
    clusters = d$event_id,
    se_type = "CR2"
  )
  tab <- summary(fit)$coefficients["target_contrast", ]
  list(
    estimate = unname(tab["Estimate"]),
    se = unname(tab["Std. Error"]),
    df = unname(tab["DF"]),
    p = unname(tab["Pr(>|t|)"])
  )
}

contrast_vector <- function(...) {
  values <- c(...)
  out <- setNames(rep(0, length(position_terms)), position_terms)
  out[names(values)] <- values
  out
}

contrasts <- list(
  hardware_minus_cloud = contrast_vector(
    rel_upstream_hardware = 1,
    rel_upstream_cloud = -1
  ),
  hardware_minus_integrator = contrast_vector(
    rel_upstream_hardware = 1,
    rel_downstream_integrator = -1
  ),
  hardware_minus_deployer = contrast_vector(
    rel_upstream_hardware = 1,
    rel_downstream_deployer = -1
  ),
  hardware_minus_enabler = contrast_vector(
    rel_upstream_hardware = 1,
    rel_downstream_enabler = -1
  ),
  hardware_minus_competitor = contrast_vector(
    rel_upstream_hardware = 1,
    rel_competitor = -1
  ),
  hardware_minus_downstream_average = contrast_vector(
    rel_upstream_hardware = 1,
    rel_downstream_integrator = -1 / 3,
    rel_downstream_deployer = -1 / 3,
    rel_downstream_enabler = -1 / 3
  ),
  hardware_minus_nonhardware_average = contrast_vector(
    rel_upstream_hardware = 1,
    rel_upstream_cloud = -0.2,
    rel_downstream_integrator = -0.2,
    rel_downstream_deployer = -0.2,
    rel_downstream_enabler = -0.2,
    rel_competitor = -0.2
  )
)

joint_tests <- list(
  core_positions_equal = rbind(
    contrasts$hardware_minus_cloud,
    contrasts$hardware_minus_integrator,
    contrasts$hardware_minus_deployer,
    contrasts$hardware_minus_enabler,
    contrasts$hardware_minus_competitor
  ),
  hardware_equals_cloud_integrator_deployer = rbind(
    contrasts$hardware_minus_cloud,
    contrasts$hardware_minus_integrator,
    contrasts$hardware_minus_deployer
  )
)

pairwise_rows <- list()
joint_rows <- list()
pair_i <- 0
joint_i <- 0

for (benchmark in names(outcomes)) {
  outcome <- outcomes[[benchmark]]
  full_rhs <- paste(
    c(position_terms, control_terms, "factor(release_year)"),
    collapse = " + "
  )
  full_formula <- as.formula(paste(outcome, "~", full_rhs))
  d <- complete_model_data(base, full_formula)

  event_fit <- lm_robust(
    full_formula,
    data = d,
    clusters = d$event_id,
    se_type = "CR2"
  )
  event_vcov <- vcov(event_fit)
  ols_fit <- lm(full_formula, data = d)
  two <- two_way_vcov(ols_fit, d)
  beta <- coef(ols_fit)
  df_two <- min(length(unique(d$event_id)), length(unique(d$ticker))) - 1

  contrast_event_results <- list()
  for (contrast_name in names(contrasts)) {
    c_position <- contrasts[[contrast_name]]
    event_result <- event_cr2_contrast(d, outcome, c_position)
    contrast_event_results[[contrast_name]] <- event_result

    c_full <- setNames(rep(0, length(beta)), names(beta))
    c_full[names(c_position)] <- c_position
    estimate <- unname(sum(c_full * beta))
    if (abs(estimate - event_result$estimate) > 1e-9) {
      stop("CR2 reparameterization changed the contrast estimate.")
    }

    se_two <- sqrt(drop(t(c_full) %*% two$vcov %*% c_full))
    p_two <- 2 * pt(abs(estimate / se_two), df = df_two, lower.tail = FALSE)

    for (method in c("event_CR2", "event_x_firm_HC1")) {
      if (method == "event_CR2") {
        se <- event_result$se
        df_method <- event_result$df
        p <- event_result$p
      } else {
        se <- se_two
        df_method <- df_two
        p <- p_two
      }
      q <- qt(0.975, df = df_method)
      pair_i <- pair_i + 1
      pairwise_rows[[pair_i]] <- data.frame(
        benchmark = benchmark,
        outcome = outcome,
        contrast = contrast_name,
        method = method,
        estimate = estimate,
        estimate_pp = 100 * estimate,
        se = se,
        se_pp = 100 * se,
        df = df_method,
        t = estimate / se,
        p = p,
        stars = star(p),
        ci95_low = estimate - q * se,
        ci95_high = estimate + q * se,
        ci95_low_pp = 100 * (estimate - q * se),
        ci95_high_pp = 100 * (estimate + q * se),
        observations = nobs(ols_fit),
        events = length(unique(d$event_id)),
        firms = length(unique(d$ticker)),
        two_way_vcov_min_eigenvalue = ifelse(
          method == "event_x_firm_HC1", two$min_eigen, NA_real_
        ),
        two_way_vcov_fix_applied = ifelse(
          method == "event_x_firm_HC1", two$fixed, NA
        ),
        stringsAsFactors = FALSE
      )
    }
  }

  for (test_name in names(joint_tests)) {
    r_position <- joint_tests[[test_name]]
    r_full <- matrix(
      0,
      nrow = nrow(r_position),
      ncol = length(beta),
      dimnames = list(NULL, names(beta))
    )
    r_full[, colnames(r_position)] <- r_position
    restriction_estimate <- drop(r_full %*% beta)
    q_restrictions <- nrow(r_full)

    event_single_dfs <- vapply(
      seq_len(nrow(r_position)),
      function(j) {
        event_cr2_contrast(d, outcome, r_position[j, ])$df
      },
      numeric(1)
    )
    df_event_joint <- min(event_single_dfs)

    for (method in c("event_CR2", "event_x_firm_HC1")) {
      vcov_use <- if (method == "event_CR2") event_vcov else two$vcov
      df_den <- if (method == "event_CR2") df_event_joint else df_two
      restriction_vcov <- r_full %*% vcov_use %*% t(r_full)
      wald_chisq <- drop(
        t(restriction_estimate) %*%
          qr.solve(restriction_vcov, restriction_estimate)
      )
      f_stat <- wald_chisq / q_restrictions
      p <- pf(
        f_stat,
        df1 = q_restrictions,
        df2 = df_den,
        lower.tail = FALSE
      )
      joint_i <- joint_i + 1
      joint_rows[[joint_i]] <- data.frame(
        benchmark = benchmark,
        outcome = outcome,
        test = test_name,
        method = method,
        restrictions = q_restrictions,
        wald_chisq = wald_chisq,
        f_stat = f_stat,
        df_num = q_restrictions,
        df_den = df_den,
        p = p,
        stars = star(p),
        df_rule = ifelse(
          method == "event_CR2",
          "minimum Satterthwaite df across component CR2 contrasts",
          "minimum cluster count minus one"
        ),
        observations = nobs(ols_fit),
        events = length(unique(d$event_id)),
        firms = length(unique(d$ticker)),
        stringsAsFactors = FALSE
      )
    }
  }
}

pairwise_results <- do.call(rbind, pairwise_rows)
joint_results <- do.call(rbind, joint_rows)

pairwise_path <- file.path(
  report_dir, "frl_position_pairwise_contrasts.csv"
)
joint_path <- file.path(
  report_dir, "frl_position_joint_tests.csv"
)
write.csv(pairwise_results, pairwise_path, row.names = FALSE)
write.csv(joint_results, joint_path, row.names = FALSE)

cat("Pairwise contrasts:", pairwise_path, "\n")
cat("Joint tests:", joint_path, "\n\n")

cat("Market-model pairwise contrasts in percentage points\n")
print(
  pairwise_results[
    pairwise_results$benchmark == "market_model",
    c("contrast", "method", "estimate_pp", "se_pp", "p", "stars")
  ],
  row.names = FALSE
)

cat("\nJoint equality tests\n")
print(
  joint_results[
    ,
    c("benchmark", "test", "method", "f_stat", "df_num", "df_den", "p", "stars")
  ],
  row.names = FALSE
)
