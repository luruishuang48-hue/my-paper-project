#!/usr/bin/env Rscript
# =============================================================================
# r1_hardware_cloud_wald_test.R
#
# Agent R1 task: Test whether upstream_hardware and upstream_cloud have
# statistically distinguishable effects on CAR, via a JOINT regression
# (both regressors simultaneously) + formal Wald-style difference test.
#
# IMPORTANT: Uses ONLY the new 8-dim relationship columns
# (upstream_hardware, upstream_cloud). Does NOT touch old-schema columns
# (owner, investor, cloud, real_upstream, business_upstream,
#  real_downstream, business_downstream).
#
# Spec (per plan.md / paper_b_robustness_2026062514):
#   car ~ upstream_hardware + upstream_cloud + size_log_assets + bm_ratio +
#         volatility + momentum + factor(release_year)
#   estimatr::lm_robust(..., clusters = data$final_event_id, se_type = "CR0")
#
# Difference test:
#   diff     = beta_hardware - beta_cloud
#   var_diff = Var(beta_hardware) + Var(beta_cloud) - 2*Cov(beta_hardware, beta_cloud)
#   se_diff  = sqrt(var_diff)
#   z        = diff / se_diff
#   p_value  = 2 * pnorm(abs(z), lower.tail = FALSE)
# =============================================================================

suppressPackageStartupMessages({
  library(estimatr)
})

# ─── Paths ───────────────────────────────────────────────────────────────────
data_path <- "data/panel/specr_rel_clean.csv"
out_csv   <- "agent_tasks/paper_b_robustness_2026062514/outputs/r1_hardware_vs_cloud_diff.csv"
out_md    <- "agent_tasks/paper_b_robustness_2026062514/outputs/r1_hardware_vs_cloud_diff.md"

# ─── Load data ───────────────────────────────────────────────────────────────
df <- read.csv(data_path, stringsAsFactors = FALSE, check.names = FALSE)

required_cols <- c(
  "upstream_hardware", "upstream_cloud",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "release_year", "final_event_id",
  "car_10", "car_15", "car_20"
)
stopifnot(all(required_cols %in% names(df)))

ctrl_vars <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
rhs_vars  <- c("upstream_hardware", "upstream_cloud", ctrl_vars)

# ─── Helper: build formula ───────────────────────────────────────────────────
make_fml <- function(y) {
  as.formula(paste(y, "~", paste(c(rhs_vars, "factor(release_year)"), collapse = " + ")))
}

# ─── Helper: filter to non-missing on outcome + all RHS vars (excl factor) ──
model_data <- function(data, y) {
  needed <- c(y, rhs_vars, "final_event_id")
  out <- data
  for (v in needed) {
    out <- out[!is.na(out[[v]]), ]
  }
  out
}

outcomes <- c("car_10", "car_15", "car_20")

results <- list()

for (y in outcomes) {
  cat("\n", strrep("=", 80), "\n", sep = "")
  cat(sprintf("OUTCOME: %s\n", y))
  cat(strrep("=", 80), "\n")

  d <- model_data(df, y)
  n <- nrow(d)
  n_events <- length(unique(d$final_event_id))

  mod <- lm_robust(
    make_fml(y),
    data = d,
    clusters = d$final_event_id,
    se_type = "CR0"
  )

  b  <- coef(mod)
  V  <- vcov(mod)
  se <- sqrt(diag(V))

  beta_hardware <- b[["upstream_hardware"]]
  se_hardware   <- se[["upstream_hardware"]]
  beta_cloud    <- b[["upstream_cloud"]]
  se_cloud      <- se[["upstream_cloud"]]

  diff     <- beta_hardware - beta_cloud
  var_diff <- V["upstream_hardware", "upstream_hardware"] +
              V["upstream_cloud", "upstream_cloud"] -
              2 * V["upstream_hardware", "upstream_cloud"]
  se_diff  <- sqrt(var_diff)
  z        <- diff / se_diff
  p_value  <- 2 * pnorm(abs(z), lower.tail = FALSE)

  cat(sprintf("n = %d, n_events (unique final_event_id) = %d\n", n, n_events))
  cat(sprintf("beta_hardware = %.6f  (SE = %.6f)\n", beta_hardware, se_hardware))
  cat(sprintf("beta_cloud    = %.6f  (SE = %.6f)\n", beta_cloud, se_cloud))
  cat(sprintf("diff (hardware - cloud) = %.6f\n", diff))
  cat(sprintf("se_diff = %.6f\n", se_diff))
  cat(sprintf("z = %.4f\n", z))
  cat(sprintf("p_value = %.4f\n", p_value))

  results[[y]] <- data.frame(
    outcome       = y,
    beta_hardware = beta_hardware,
    se_hardware   = se_hardware,
    beta_cloud    = beta_cloud,
    se_cloud      = se_cloud,
    diff          = diff,
    se_diff       = se_diff,
    z             = z,
    p_value       = p_value,
    n             = n,
    n_events      = n_events,
    stringsAsFactors = FALSE
  )
}

results_df <- do.call(rbind, results)
rownames(results_df) <- NULL

cat("\n", strrep("=", 80), "\n", sep = "")
cat("FINAL RESULTS TABLE\n")
cat(strrep("=", 80), "\n")
print(results_df, digits = 6)

write.csv(results_df, out_csv, row.names = FALSE)
cat(sprintf("\nSaved CSV: %s\n", out_csv))

# ─── Markdown summary ────────────────────────────────────────────────────────
car20_row <- results_df[results_df$outcome == "car_20", ]
sig_car20 <- car20_row$p_value < 0.05

md_lines <- c(
  "# R1: upstream_hardware vs upstream_cloud — formal difference test",
  "",
  sprintf(
    "At the primary window **car_20**, the joint regression (both `upstream_hardware` and `upstream_cloud` entered simultaneously, controls + year FE, CR0 clustered by `final_event_id`) gives beta_hardware = %.4f (SE = %.4f) vs. beta_cloud = %.4f (SE = %.4f); the difference is %.4f with SE %.4f, z = %.3f, **p = %.4f** (n = %d, %d event clusters). %s",
    car20_row$beta_hardware, car20_row$se_hardware,
    car20_row$beta_cloud, car20_row$se_cloud,
    car20_row$diff, car20_row$se_diff, car20_row$z, car20_row$p_value,
    car20_row$n, car20_row$n_events,
    if (sig_car20) "This difference IS statistically significant at the 5% level." else "This difference is NOT statistically significant at the 5% level."
  ),
  "",
  sprintf(
    "%s `agent_tasks/relationship_recode_switch_2026062500/review_regressions_summary.md` (line 28, `relonly_regression` discussion), which claims the upstream effect is \"driven almost entirely by hardware (cloud weak/n.s.)\" based on eyeballing point estimates from separate single-variable regressions: the joint-model point estimates point the same direction at car_20 (hardware > cloud), but the formal difference test does not reach conventional significance, so the qualitative claim is %s by this stricter test.",
    if (sig_car20) "This formally confirms the claim in" else "This does NOT formally confirm the claim in",
    if (sig_car20) "confirmed" else "not confirmed (only descriptively, not statistically, supported)"
  ),
  "",
  "Full results across car_10 / car_15 / car_20:",
  "",
  "| outcome | beta_hardware | se_hardware | beta_cloud | se_cloud | diff | se_diff | z | p_value | n | n_events |",
  "|---|---|---|---|---|---|---|---|---|---|---|"
)
for (i in seq_len(nrow(results_df))) {
  r <- results_df[i, ]
  md_lines <- c(md_lines, sprintf(
    "| %s | %.4f | %.4f | %.4f | %.4f | %.4f | %.4f | %.3f | %.4f | %d | %d |",
    r$outcome, r$beta_hardware, r$se_hardware, r$beta_cloud, r$se_cloud,
    r$diff, r$se_diff, r$z, r$p_value, r$n, r$n_events
  ))
}

writeLines(md_lines, out_md)
cat(sprintf("Saved MD: %s\n", out_md))

cat("\nDone.\n")
