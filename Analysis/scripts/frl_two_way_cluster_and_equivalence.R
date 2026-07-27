#!/usr/bin/env Rscript
# FRL inference robustness
# 1. Re-estimate the paper's main specifications with event x firm clustered SEs.
# 2. Test whether the deployer coefficient is equivalent to zero within a
#    margin equal to one third of the baseline hardware coefficient.
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

panel_path <- Sys.getenv(
  "FRL_PANEL_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_panel.csv")
)
volume_path <- Sys.getenv(
  "FRL_VOLUME_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_abnormal_volume.csv")
)
report_dir <- Sys.getenv(
  "FRL_REPORT_DIR",
  unset = file.path(root, "Analysis", "reports")
)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)
av <- read.csv(volume_path, stringsAsFactors = FALSE, check.names = FALSE)
df <- merge(df, av, by = c("event_id", "ticker"), all.x = TRUE)

num_cols <- c(
  grep(
    "^car_mm_spy|^car_mm_qqq_0_20|^car_mm_soxx_0_20|^car_ff3_0_20|^av_",
    names(df),
    value = TRUE
  ),
  "aa_intelligence_index", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner",
  "is_open_weight_or_open_source"
)
for (col in unique(num_cols)) {
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
base$related <- as.numeric(
  base$rel_upstream_hardware == 1 |
    base$rel_upstream_cloud == 1 |
    base$rel_downstream_integrator == 1 |
    base$rel_downstream_deployer == 1 |
    base$rel_downstream_enabler == 1 |
    base$rel_competitor == 1 |
    base$rel_is_investor == 1 |
    base$rel_is_owner == 1
)

position_terms <- c(
  "rel_upstream_hardware", "rel_upstream_cloud",
  "rel_downstream_integrator", "rel_downstream_deployer",
  "rel_downstream_enabler", "rel_competitor", "rel_is_investor", "rel_is_owner"
)
position_rhs <- paste(position_terms, collapse = " + ")
controls <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum"

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

fit_compare <- function(dat, outcome, rhs, fixed_effects, spec, terms) {
  formula <- as.formula(paste(outcome, "~", rhs, "+", fixed_effects))
  d <- complete_model_data(dat, formula)

  event_fit <- lm_robust(
    formula,
    data = d,
    clusters = d$event_id,
    se_type = "CR2"
  )
  event_table <- summary(event_fit)$coefficients

  ols_fit <- lm(formula, data = d)
  clusters <- data.frame(event_id = d$event_id, ticker = d$ticker)
  vcov_two <- vcovCL(
    ols_fit,
    cluster = clusters,
    type = "HC1",
    cadjust = TRUE,
    multi0 = FALSE,
    fix = FALSE
  )
  eigen_min <- min(eigen(vcov_two, symmetric = TRUE, only.values = TRUE)$values)
  vcov_fixed <- eigen_min < -1e-10
  if (vcov_fixed) {
    vcov_two <- vcovCL(
      ols_fit,
      cluster = clusters,
      type = "HC1",
      cadjust = TRUE,
      multi0 = FALSE,
      fix = TRUE
    )
  }

  coef_two <- coef(ols_fit)
  se_two <- sqrt(diag(vcov_two))
  n_events <- length(unique(d$event_id))
  n_firms <- length(unique(d$ticker))
  df_two <- min(n_events, n_firms) - 1
  p_two <- 2 * pt(abs(coef_two / se_two), df = df_two, lower.tail = FALSE)
  q_two <- qt(0.975, df = df_two)

  rows <- list()
  row_i <- 0
  for (term in terms) {
    if (!(term %in% names(coef_two)) || !(term %in% rownames(event_table))) {
      next
    }
    row_i <- row_i + 1
    rows[[row_i]] <- data.frame(
      spec = spec,
      outcome = outcome,
      term = term,
      coef = unname(coef_two[term]),
      se_event_cr2 = event_table[term, "Std. Error"],
      p_event_cr2 = event_table[term, "Pr(>|t|)"],
      stars_event_cr2 = star(event_table[term, "Pr(>|t|)"]),
      se_event_firm_hc1 = unname(se_two[term]),
      p_event_firm_hc1 = unname(p_two[term]),
      stars_event_firm_hc1 = star(unname(p_two[term])),
      ci95_low_event_firm = unname(coef_two[term] - q_two * se_two[term]),
      ci95_high_event_firm = unname(coef_two[term] + q_two * se_two[term]),
      observations = nobs(ols_fit),
      events = n_events,
      firms = n_firms,
      df_event_firm = df_two,
      vcov_min_eigenvalue_before_fix = eigen_min,
      vcov_eigenvalue_fix_applied = vcov_fixed,
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

results <- list()
result_i <- 0
add_result <- function(...) {
  result_i <<- result_i + 1
  results[[result_i]] <<- fit_compare(...)
}

# Ecosystem-position return regressions
position_full_rhs <- paste(position_rhs, controls, sep = " + ")
add_result(
  base, "car_mm_spy_0_20", position_full_rhs, "factor(release_year)",
  "position_mm_year_fe", position_terms
)
add_result(
  base, "car_ff3_0_20", position_full_rhs, "factor(release_year)",
  "position_ff3_year_fe", position_terms
)
add_result(
  base, "car_mm_qqq_0_20", position_full_rhs, "factor(release_year)",
  "position_qqq_year_fe", position_terms
)
add_result(
  base, "car_mm_soxx_0_20", position_full_rhs, "factor(release_year)",
  "position_soxx_year_fe", position_terms
)
add_result(
  base, "car_mm_spy_0_20", position_full_rhs, "factor(event_id)",
  "position_mm_event_fe", position_terms
)

# Capability regressions
capability <- base[!is.na(base$aa_intelligence_index), ]
capability$intel_c <- capability$aa_intelligence_index -
  mean(capability$aa_intelligence_index)
capability_fe <- paste(controls, "factor(release_year)", sep = " + ")
add_result(
  capability, "car_mm_spy_0_20", "aa_intelligence_index", capability_fe,
  "capability_all", "aa_intelligence_index"
)
add_result(
  capability[capability$is_open_weight_or_open_source == 0, ],
  "car_mm_spy_0_20", "aa_intelligence_index", capability_fe,
  "capability_closed", "aa_intelligence_index"
)
add_result(
  capability[capability$is_open_weight_or_open_source == 1, ],
  "car_mm_spy_0_20", "aa_intelligence_index", capability_fe,
  "capability_open", "aa_intelligence_index"
)
add_result(
  capability[capability$related == 0, ],
  "car_mm_spy_0_20", "aa_intelligence_index", capability_fe,
  "capability_placebo", "aa_intelligence_index"
)
add_result(
  capability, "car_mm_spy_0_20",
  "intel_c * rel_upstream_hardware", capability_fe,
  "capability_x_hardware",
  c("intel_c", "rel_upstream_hardware",
    "intel_c:rel_upstream_hardware")
)
add_result(
  capability, "car_ff3_0_20", "aa_intelligence_index", capability_fe,
  "capability_all_ff3", "aa_intelligence_index"
)
add_result(
  capability, "car_ff3_0_20",
  "intel_c * rel_upstream_hardware", capability_fe,
  "capability_x_hardware_ff3",
  c("intel_c", "rel_upstream_hardware",
    "intel_c:rel_upstream_hardware")
)

# Abnormal-volume regressions
late <- base[base$event_trading_date >= "2025-01-01", ]
volume_fe <- paste(position_full_rhs, "factor(event_id)", sep = " + ")
for (window in c("av_pre_m10_m2", "av_0_1")) {
  add_result(
    base, window, position_full_rhs, "factor(event_id)",
    paste0("volume_full_", window), position_terms
  )
  add_result(
    late, window, position_full_rhs, "factor(event_id)",
    paste0("volume_2025_2026_", window), position_terms
  )
}

cluster_results <- do.call(rbind, results)
cluster_path <- file.path(
  report_dir, "frl_event_firm_two_way_cluster_results.csv"
)
write.csv(cluster_results, cluster_path, row.names = FALSE)

# Deployer equivalence test in the baseline position regression
equiv_formula <- as.formula(
  paste(
    "car_mm_spy_0_20 ~", position_full_rhs, "+ factor(release_year)"
  )
)
equiv_data <- complete_model_data(base, equiv_formula)
equiv_event_fit <- lm_robust(
  equiv_formula,
  data = equiv_data,
  clusters = equiv_data$event_id,
  se_type = "CR2"
)
equiv_event_table <- summary(equiv_event_fit)$coefficients

equiv_ols_fit <- lm(equiv_formula, data = equiv_data)
equiv_clusters <- data.frame(
  event_id = equiv_data$event_id,
  ticker = equiv_data$ticker
)
equiv_vcov_two <- vcovCL(
  equiv_ols_fit,
  cluster = equiv_clusters,
  type = "HC1",
  cadjust = TRUE,
  multi0 = FALSE,
  fix = TRUE
)

deployer_term <- "rel_downstream_deployer"
hardware_term <- "rel_upstream_hardware"
beta_deployer <- unname(coef(equiv_ols_fit)[deployer_term])
beta_hardware <- unname(coef(equiv_ols_fit)[hardware_term])
equivalence_margin <- abs(beta_hardware) / 3

tost_row <- function(method, se, df) {
  t_lower <- (beta_deployer + equivalence_margin) / se
  t_upper <- (beta_deployer - equivalence_margin) / se
  p_lower <- pt(t_lower, df = df, lower.tail = FALSE)
  p_upper <- pt(t_upper, df = df, lower.tail = TRUE)
  p_tost <- max(p_lower, p_upper)
  q90 <- qt(0.95, df = df)
  data.frame(
    method = method,
    deployer_coef = beta_deployer,
    deployer_se = se,
    hardware_coef = beta_hardware,
    equivalence_margin = equivalence_margin,
    ci90_low = beta_deployer - q90 * se,
    ci90_high = beta_deployer + q90 * se,
    p_lower_bound = p_lower,
    p_upper_bound = p_upper,
    p_tost = p_tost,
    equivalent_at_5pct = p_tost < 0.05,
    df = df,
    observations = nobs(equiv_ols_fit),
    events = length(unique(equiv_data$event_id)),
    firms = length(unique(equiv_data$ticker)),
    stringsAsFactors = FALSE
  )
}

event_se <- equiv_event_table[deployer_term, "Std. Error"]
event_df <- equiv_event_table[deployer_term, "DF"]
two_way_se <- sqrt(diag(equiv_vcov_two))[deployer_term]
two_way_df <- min(
  length(unique(equiv_data$event_id)),
  length(unique(equiv_data$ticker))
) - 1

equivalence_results <- rbind(
  tost_row("event_CR2", event_se, event_df),
  tost_row("event_firm_HC1", two_way_se, two_way_df)
)
equivalence_path <- file.path(
  report_dir, "frl_deployer_equivalence_results.csv"
)
write.csv(equivalence_results, equivalence_path, row.names = FALSE)

cat("Two-way cluster results:", cluster_path, "\n")
cat("Equivalence results:", equivalence_path, "\n\n")
cat("Baseline position terms\n")
print(
  cluster_results[
    cluster_results$spec == "position_mm_year_fe" &
      cluster_results$term %in%
        c("rel_upstream_hardware", "rel_downstream_deployer",
          "rel_competitor"),
    c("term", "coef", "se_event_cr2", "p_event_cr2",
      "se_event_firm_hc1", "p_event_firm_hc1")
  ],
  row.names = FALSE
)
cat("\nCapability terms\n")
print(
  cluster_results[
    cluster_results$spec %in%
      c("capability_closed", "capability_x_hardware"),
    c("spec", "term", "coef", "se_event_cr2", "p_event_cr2",
      "se_event_firm_hc1", "p_event_firm_hc1")
  ],
  row.names = FALSE
)
cat("\nAnnouncement-volume terms\n")
print(
  cluster_results[
    cluster_results$spec == "volume_full_av_0_1" &
      cluster_results$term %in%
        c("rel_upstream_hardware", "rel_upstream_cloud",
          "rel_downstream_deployer"),
    c("term", "coef", "se_event_cr2", "p_event_cr2",
      "se_event_firm_hc1", "p_event_firm_hc1")
  ],
  row.names = FALSE
)
cat("\nDeployer equivalence\n")
print(equivalence_results, row.names = FALSE)
