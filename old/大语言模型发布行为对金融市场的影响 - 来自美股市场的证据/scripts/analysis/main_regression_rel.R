#!/usr/bin/env Rscript
# =============================================================================
# Main Regression — Relationship Data
# (1) All     CAR[0,+1]    (2) All     CAR[0,+20]
# (3) Real-downstream      (4) Competitor
# (5) US-listed creator    (6) Closed-source
# Outcome: car_20 for cols (3)-(6) [highest specr signal]
# SE: CR0 clustered by final_event_id
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

df <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c("car_1","car_20","aa_intelligence_index",
              "size_log_assets","bm_ratio","volatility","momentum",
              "release_year","is_open_weight",
              "owner","investor","cloud",
              "business_upstream","real_upstream",
              "business_downstream","real_downstream","competitor")
for (col in num_cols) df[[col]] <- as.numeric(df[[col]])

# ─── Subsamples ───────────────────────────────────────────────────────────────

df_base   <- df[!is.na(df$aa_intelligence_index), ]
df_rdwn   <- df_base[!is.na(df_base$real_downstream)   & df_base$real_downstream   == 1, ]
df_comp   <- df_base[!is.na(df_base$competitor)         & df_base$competitor         == 1, ]
df_us     <- df_base[df_base$creator_type == "listed_us_company", ]
df_closed <- df_base[!is.na(df_base$is_open_weight)     & df_base$is_open_weight     == 0, ]
df_inv    <- df_base[!is.na(df_base$investor)            & df_base$investor            == 1, ]

for (nm in c("df_base","df_rdwn","df_comp","df_us","df_closed","df_inv")) {
  d <- get(nm)
  cat(sprintf("%-12s n=%5d  events=%d\n", nm, nrow(d), length(unique(d$final_event_id))))
}

# ─── Formula ──────────────────────────────────────────────────────────────────

fml <- function(y) as.formula(paste(
  y, "~ aa_intelligence_index + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)"
))

fit <- function(d, y) {
  lm_robust(fml(y), data = d, clusters = d$final_event_id, se_type = "CR0")
}

# ─── Six regressions ──────────────────────────────────────────────────────────

models <- list(
  m1 = fit(df_base,   "car_1"),
  m2 = fit(df_base,   "car_20"),
  m3 = fit(df_rdwn,   "car_20"),
  m4 = fit(df_comp,   "car_20"),
  m5 = fit(df_us,     "car_20"),
  m6 = fit(df_closed, "car_20")
)

# ─── Extract key row ──────────────────────────────────────────────────────────

extract <- function(mod) {
  b  <- coef(mod)["aa_intelligence_index"]
  se <- sqrt(diag(vcov(mod)))["aa_intelligence_index"]
  p  <- summary(mod)$coefficients["aa_intelligence_index", "Pr(>|t|)"]
  ci <- confint(mod)["aa_intelligence_index", ]
  s  <- ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ifelse(p < 0.10, "+", ""))))
  list(b=round(b,6), se=round(se,6), p=signif(p,3), ci_lo=round(ci[1],6), ci_hi=round(ci[2],6),
       stars=s, n=mod$nobs, ncl=mod$nclusters, r2=round(summary(mod)$r.squared,4))
}

r <- lapply(models, extract)

# ─── Print table ──────────────────────────────────────────────────────────────

hdr <- c("(1)All\nCAR[0,1]","(2)All\nCAR[0,20]","(3)Real-Down\nCAR[0,20]",
         "(4)Competitor\nCAR[0,20]","(5)US-Creator\nCAR[0,20]","(6)Closed-src\nCAR[0,20]")

cat("\n")
cat(paste(rep("=",90), collapse=""), "\n")
cat("Main Regression: aa_intelligence_index → CAR  |  Relationship Data\n")
cat(paste(rep("=",90), collapse=""), "\n")
cat(sprintf("%-24s", ""))
for (h in c("(1)","(2)","(3)","(4)","(5)","(6)")) cat(sprintf("%13s", h))
cat("\n")
cat(sprintf("%-24s", "Dep. var / Sample"))
for (h in c("CAR1/All","CAR20/All","CAR20/RDwn","CAR20/Comp","CAR20/US","CAR20/Closed")) cat(sprintf("%13s", h))
cat("\n")
cat(paste(rep("-",90), collapse=""), "\n")
cat(sprintf("%-24s", "aa_intelligence_index"))
for (i in 1:6) cat(sprintf("%13s", paste0(formatC(r[[i]]$b, format="f", digits=5), r[[i]]$stars)))
cat("\n")
cat(sprintf("%-24s", ""))
for (i in 1:6) cat(sprintf("%13s", paste0("(", formatC(r[[i]]$se, format="f", digits=5), ")")))
cat("\n")
cat(sprintf("%-24s", "p-value"))
for (i in 1:6) cat(sprintf("%13s", r[[i]]$p))
cat("\n")
cat(paste(rep("-",90), collapse=""), "\n")
cat(sprintf("%-24s%s\n", "Controls", paste(rep(sprintf("%13s","Yes"), 6), collapse="")))
cat(sprintf("%-24s%s\n", "Year FE",  paste(rep(sprintf("%13s","Yes"), 6), collapse="")))
cat(sprintf("%-24s%s\n", "Cluster",  paste(rep(sprintf("%13s","Event"), 6), collapse="")))
cat(sprintf("%-24s", "N"))
for (i in 1:6) cat(sprintf("%13d", r[[i]]$n)); cat("\n")
cat(sprintf("%-24s", "Events"))
for (i in 1:6) cat(sprintf("%13d", r[[i]]$ncl)); cat("\n")
cat(sprintf("%-24s", "R2"))
for (i in 1:6) cat(sprintf("%13s", r[[i]]$r2)); cat("\n")
cat(paste(rep("=",90), collapse=""), "\n")
cat("+ p<0.10  * p<0.05  ** p<0.01  *** p<0.001\n")
cat("Controls: size_log_assets, bm_ratio, volatility, momentum\n\n")

# ─── Save CSV ─────────────────────────────────────────────────────────────────

tbl <- data.frame(
  column   = c("(1)All CAR1","(2)All CAR20","(3)RealDwn CAR20",
               "(4)Competitor CAR20","(5)US-Creator CAR20","(6)Closed CAR20"),
  coef     = sapply(r, `[[`, "b"),
  se       = sapply(r, `[[`, "se"),
  p_value  = sapply(r, `[[`, "p"),
  stars    = sapply(r, `[[`, "stars"),
  ci_lo    = sapply(r, `[[`, "ci_lo"),
  ci_hi    = sapply(r, `[[`, "ci_hi"),
  n        = sapply(r, `[[`, "n"),
  n_events = sapply(r, `[[`, "ncl"),
  r2       = sapply(r, `[[`, "r2")
)
write.csv(tbl, "main_regression_rel_results.csv", row.names = FALSE)
cat("Saved: main_regression_rel_results.csv\n")
