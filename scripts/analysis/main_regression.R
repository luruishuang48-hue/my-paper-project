#!/usr/bin/env Rscript
# =============================================================================
# Main Regression Table: aa_intelligence_index → CAR
# Table structure:
#   (1) car_1,  all sample,    full controls, year FE
#   (2) car_20, all sample,    full controls, year FE
#   (3) car_1,  closed source, full controls, year FE
#   (4) car_20, closed source, full controls, year FE  ← three stars (p<0.001)
# SE: clustered by final_event_id (CR0)
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

df <- read.csv("specr_input_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

# Coerce numerics
num_cols <- c("car_1","car_20","aa_intelligence_index",
              "size_log_assets","bm_ratio","volatility","momentum",
              "release_year","is_open_weight_or_open_source")
for (col in num_cols) df[[col]] <- as.numeric(df[[col]])

# Subsamples
df_all    <- df[!is.na(df$aa_intelligence_index), ]
df_closed <- df[!is.na(df$aa_intelligence_index) &
                !is.na(df$is_open_weight_or_open_source) &
                df$is_open_weight_or_open_source == 0, ]

cat("Full sample n:", nrow(df_all), "| events:", length(unique(df_all$final_event_id)), "\n")
cat("Closed-source n:", nrow(df_closed), "| events:", length(unique(df_closed$final_event_id)), "\n")

# ─── Run four regressions ────────────────────────────────────────────────────

fml_1  <- car_1  ~ aa_intelligence_index + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)
fml_20 <- car_20 ~ aa_intelligence_index + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)

m1 <- lm_robust(fml_1,  data = df_all,    clusters = df_all$final_event_id,    se_type = "CR0")
m2 <- lm_robust(fml_20, data = df_all,    clusters = df_all$final_event_id,    se_type = "CR0")
m3 <- lm_robust(fml_1,  data = df_closed, clusters = df_closed$final_event_id, se_type = "CR0")
m4 <- lm_robust(fml_20, data = df_closed, clusters = df_closed$final_event_id, se_type = "CR0")

# ─── Extract results for key variable ────────────────────────────────────────

extract_row <- function(mod, var = "aa_intelligence_index") {
  b  <- coef(mod)[var]
  se <- sqrt(diag(vcov(mod)))[var]
  p  <- summary(mod)$coefficients[var, "Pr(>|t|)"]
  ci <- confint(mod)[var, ]
  stars <- ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ifelse(p < 0.10, "†", ""))))
  list(
    coef       = round(b, 6),
    se         = round(se, 6),
    p          = signif(p, 4),
    ci_lo      = round(ci[1], 6),
    ci_hi      = round(ci[2], 6),
    stars      = stars,
    n          = nobs(mod),
    n_clusters = mod$nclusters,
    r2         = round(summary(mod)$r.squared, 4)
  )
}

r1 <- extract_row(m1); r2 <- extract_row(m2)
r3 <- extract_row(m3); r4 <- extract_row(m4)

# ─── Print console table ─────────────────────────────────────────────────────

cat("\n")
cat("=================================================================\n")
cat("Main Regression: aa_intelligence_index → CAR\n")
cat("=================================================================\n")
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "", "(1) CAR[0,1]", "(2) CAR[0,20]", "(3) CAR[0,1]", "(4) CAR[0,20]"))
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "Sample", "All", "All", "Closed-src", "Closed-src"))
cat("-----------------------------------------------------------------\n")

fmt_coef <- function(r) sprintf("%s%s", formatC(r$coef, format="f", digits=5), r$stars)
fmt_se   <- function(r) sprintf("(%s)", formatC(r$se,   format="f", digits=5))

cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "aa_intelligence_index",
    fmt_coef(r1), fmt_coef(r2), fmt_coef(r3), fmt_coef(r4)))
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "",
    fmt_se(r1), fmt_se(r2), fmt_se(r3), fmt_se(r4)))
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "p-value",
    r1$p, r2$p, r3$p, r4$p))
cat("-----------------------------------------------------------------\n")
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "Controls", "Yes", "Yes", "Yes", "Yes"))
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "Year FE", "Yes", "Yes", "Yes", "Yes"))
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "Cluster (event)", "Yes", "Yes", "Yes", "Yes"))
cat(sprintf("%-22s %12d %12d %12d %12d\n",
    "N", r1$n, r2$n, r3$n, r4$n))
cat(sprintf("%-22s %12d %12d %12d %12d\n",
    "Events", r1$n_clusters, r2$n_clusters, r3$n_clusters, r4$n_clusters))
cat(sprintf("%-22s %12s %12s %12s %12s\n",
    "R²", r1$r2, r2$r2, r3$r2, r4$r2))
cat("=================================================================\n")
cat("† p<0.10  * p<0.05  ** p<0.01  *** p<0.001\n")
cat("Controls: size_log_assets, bm_ratio, volatility, momentum\n")
cat("SE clustered by final_event_id (CR0)\n")
cat("\n")

# ─── Save CSV ────────────────────────────────────────────────────────────────

tbl <- data.frame(
  column      = c("(1) CAR[0,1] All","(2) CAR[0,20] All","(3) CAR[0,1] Closed","(4) CAR[0,20] Closed"),
  coef        = c(r1$coef, r2$coef, r3$coef, r4$coef),
  se          = c(r1$se,   r2$se,   r3$se,   r4$se),
  p_value     = c(r1$p,    r2$p,    r3$p,    r4$p),
  stars       = c(r1$stars,r2$stars,r3$stars,r4$stars),
  ci_lo       = c(r1$ci_lo,r2$ci_lo,r3$ci_lo,r4$ci_lo),
  ci_hi       = c(r1$ci_hi,r2$ci_hi,r3$ci_hi,r4$ci_hi),
  n           = c(r1$n,    r2$n,    r3$n,    r4$n),
  n_events    = c(r1$n_clusters, r2$n_clusters, r3$n_clusters, r4$n_clusters),
  r_squared   = c(r1$r2,  r2$r2,  r3$r2,  r4$r2)
)
write.csv(tbl, "main_regression_results.csv", row.names = FALSE)
cat("Saved: main_regression_results.csv\n")
