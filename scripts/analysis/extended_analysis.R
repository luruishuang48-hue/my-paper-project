#!/usr/bin/env Rscript
# =============================================================================
# Extended Analysis: Three additional angles
# A. Owner short/long reversal
# B. Time trend: intelligence × trend_month interaction
# C. Chinese vs non-Chinese model events
# D. Tier 1 only
# E. FF3 vs market model robustness
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

df <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c(
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "ff3_car_1","ff3_car_5","ff3_car_20",
  "aa_intelligence_index","size_log_assets","bm_ratio","volatility","momentum",
  "release_year","trend_month","is_open_weight","is_chinese_model",
  "owner","investor","cloud","business_upstream","real_upstream",
  "business_downstream","real_downstream","competitor"
)
for (col in num_cols) if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])

base_ctrl <- c("size_log_assets","bm_ratio","volatility","momentum")
fml <- function(y, extra = character(0), data = df) {
  rhs <- c("aa_intelligence_index", base_ctrl, extra, "factor(release_year)")
  as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
}
fit <- function(d, formula) {
  lm_robust(formula, data = d, clusters = d$final_event_id, se_type = "CR0")
}
extr <- function(mod, var = "aa_intelligence_index") {
  b  <- coef(mod)[[var]]
  se <- sqrt(diag(vcov(mod)))[[var]]
  p  <- as.numeric(summary(mod)$coefficients[var, "Pr(>|t|)"])
  ci <- confint(mod)[var, ]
  s  <- ifelse(p<0.001,"***",ifelse(p<0.01,"**",ifelse(p<0.05,"*",ifelse(p<0.10,"+",""))))
  list(coef=round(b,6), se=round(se,6), p=signif(p,3),
       ci_lo=round(ci[[1]],6), ci_hi=round(ci[[2]],6),
       stars=s, n=mod$nobs, ncl=mod$nclusters, r2=round(summary(mod)$r.squared,4))
}

df_base <- df[!is.na(df$aa_intelligence_index), ]

# =============================================================================
# A. Owner: Short vs long window (all 7 windows)
# =============================================================================
cat("\n")
cat(paste(rep("=",80),collapse=""),"\n")
cat("PANEL A: Owner firms — across all CAR windows\n")
cat(paste(rep("=",80),collapse=""),"\n")

df_owner <- df_base[!is.na(df_base$owner) & df_base$owner == 1, ]
cat("Owner obs:", nrow(df_owner), "| events:", length(unique(df_owner$final_event_id)), "\n\n")

windows_A <- c("car_1","car_2","car_3","car_5","car_10","car_15","car_20")
res_A <- lapply(windows_A, function(y) {
  d <- df_owner[!is.na(df_owner[[y]]), ]
  tryCatch(extr(fit(d, fml(y, data=d))), error=function(e) NULL)
})
names(res_A) <- windows_A

cat(sprintf("%-12s %10s %10s %8s %6s\n", "Window", "Coef", "SE", "p", "Sig"))
for (w in windows_A) {
  r <- res_A[[w]]
  if (!is.null(r))
    cat(sprintf("%-12s %10s %10s %8s %6s\n", w,
      formatC(r$coef, format="f", digits=5),
      paste0("(",formatC(r$se, format="f", digits=5),")"),
      r$p, r$stars))
}

# =============================================================================
# B. Time trend: Does the intelligence-CAR relationship change over time?
#    Regression: CAR20 ~ intelligence × trend_month + controls + year FE
#    Also: split by year
# =============================================================================
cat("\n")
cat(paste(rep("=",80),collapse=""),"\n")
cat("PANEL B: Time trend — split by release year\n")
cat(paste(rep("=",80),collapse=""),"\n")

df_B <- df_base[!is.na(df_base$car_20), ]

# Interaction model
fml_int <- car_20 ~ aa_intelligence_index + trend_month +
           aa_intelligence_index:trend_month +
           size_log_assets + bm_ratio + volatility + momentum
m_int <- tryCatch(
  lm_robust(fml_int, data=df_B, clusters=df_B$final_event_id, se_type="CR0"),
  error=function(e) NULL
)
if (!is.null(m_int)) {
  cat("\nInteraction model: intelligence × trend_month → CAR20\n")
  vars_show <- c("aa_intelligence_index","trend_month","aa_intelligence_index:trend_month")
  for (v in vars_show) {
    b  <- coef(m_int)[v]
    se <- sqrt(diag(vcov(m_int)))[v]
    p  <- summary(m_int)$coefficients[v,"Pr(>|t|)"]
    s  <- ifelse(p<0.001,"***",ifelse(p<0.01,"**",ifelse(p<0.05,"*",ifelse(p<0.10,"+",""))))
    cat(sprintf("  %-45s %10s %10s  p=%s %s\n", v,
      formatC(b, format="f", digits=6),
      paste0("(",formatC(se,format="f",digits=6),")"),
      signif(p,3), s))
  }
  cat(sprintf("  N=%d  R2=%.4f\n", m_int$nobs, summary(m_int)$r.squared))
}

# Year-by-year split
cat("\nYear-by-year: intelligence → CAR20\n")
cat(sprintf("%-8s %8s %10s %10s %8s %6s\n","Year","N","Coef","SE","p","Sig"))
for (yr in c(2024, 2025, 2026)) {
  d_yr <- df_B[!is.na(df_B$release_year) & df_B$release_year == yr, ]
  if (nrow(d_yr) < 20) next
  r <- tryCatch({
    m <- lm_robust(car_20 ~ aa_intelligence_index + size_log_assets + bm_ratio + volatility + momentum,
                   data=d_yr, clusters=d_yr$final_event_id, se_type="CR0")
    extr(m)
  }, error=function(e) NULL)
  if (!is.null(r))
    cat(sprintf("%-8s %8d %10s %10s %8s %6s\n", yr, r$n,
      formatC(r$coef,format="f",digits=5),
      paste0("(",formatC(r$se,format="f",digits=5),")"),
      r$p, r$stars))
}

# =============================================================================
# C. Chinese vs Non-Chinese model events
# =============================================================================
cat("\n")
cat(paste(rep("=",80),collapse=""),"\n")
cat("PANEL C: Chinese vs Non-Chinese model events\n")
cat(paste(rep("=",80),collapse=""),"\n")

for (flag in c(0, 1)) {
  label <- ifelse(flag==1,"Chinese models","Non-Chinese models")
  d_c <- df_base[!is.na(df_base$is_chinese_model) & df_base$is_chinese_model==flag &
                 !is.na(df_base$car_20), ]
  cat(sprintf("\n%s: n=%d, events=%d\n", label, nrow(d_c), length(unique(d_c$final_event_id))))
  for (w in c("car_1","car_20")) {
    d_w <- d_c[!is.na(d_c[[w]]), ]
    if (nrow(d_w) < 20) next
    r <- tryCatch(extr(fit(d_w, fml(w, data=d_w))), error=function(e) NULL)
    if (!is.null(r))
      cat(sprintf("  %-8s %10s %10s  p=%-8s %s\n", w,
        formatC(r$coef,format="f",digits=5),
        paste0("(",formatC(r$se,format="f",digits=5),")"),
        r$p, r$stars))
  }
}

# =============================================================================
# D. Tier 1 only
# =============================================================================
cat("\n")
cat(paste(rep("=",80),collapse=""),"\n")
cat("PANEL D: Tier 1 events only\n")
cat(paste(rep("=",80),collapse=""),"\n")

df_t1 <- df_base[df_base$candidate_tier == "Tier 1" & !is.na(df_base$candidate_tier), ]
cat(sprintf("Tier 1 obs: %d | events: %d\n\n", nrow(df_t1), length(unique(df_t1$final_event_id))))

for (w in c("car_1","car_5","car_20")) {
  d_w <- df_t1[!is.na(df_t1[[w]]), ]
  if (nrow(d_w) < 20) next
  r <- tryCatch(extr(fit(d_w, fml(w, data=d_w))), error=function(e) NULL)
  if (!is.null(r))
    cat(sprintf("  %-8s %10s %10s  p=%-8s %s  (n=%d)\n", w,
      formatC(r$coef,format="f",digits=5),
      paste0("(",formatC(r$se,format="f",digits=5),")"),
      r$p, r$stars, r$n))
}

# =============================================================================
# E. FF3 vs Market Model robustness
# =============================================================================
cat("\n")
cat(paste(rep("=",80),collapse=""),"\n")
cat("PANEL E: FF3 vs Market model CAR — robustness\n")
cat(paste(rep("=",80),collapse=""),"\n")

pairs <- list(c("car_1","ff3_car_1"), c("car_5","ff3_car_5"), c("car_20","ff3_car_20"))
for (p in pairs) {
  mkt <- p[1]; ff3 <- p[2]
  cat(sprintf("\n  Window: %s\n", gsub("car_","[0,+",mkt) |> paste0("]")))
  for (y in c(mkt, ff3)) {
    d_w <- df_base[!is.na(df_base[[y]]) & !is.na(df_base$aa_intelligence_index), ]
    if (nrow(d_w) < 20) next
    r <- tryCatch(extr(fit(d_w, fml(y, data=d_w))), error=function(e) NULL)
    label <- ifelse(grepl("ff3",y), "FF3 ", "Mkt ")
    if (!is.null(r))
      cat(sprintf("    %-5s %10s %10s  p=%-8s %s\n", label,
        formatC(r$coef,format="f",digits=5),
        paste0("(",formatC(r$se,format="f",digits=5),")"),
        r$p, r$stars))
  }
}

cat("\n", paste(rep("=",80),collapse=""), "\n")
cat("Done.\n")
