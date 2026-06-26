#!/usr/bin/env Rscript
# =============================================================================
# interaction_se_analysis.R
# Part 1: Interaction mechanism regressions
#   1A. intelligence × is_open_weight  (open vs closed moderator)
#   1B. intelligence × tier1           (Tier 1 moderation)
#   1C. intelligence × relationship    (owner / investor / real_downstream / competitor)
# Part 2: Small-cluster robust SE comparison (CR0 / CR2 / CR3)
# Part 3: Wild cluster bootstrap for clusters < 30
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

# ─── Load data ────────────────────────────────────────────────────────────────
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

# Tier dummies — only label rows that are explicitly Tier 1 or Tier 2
df$tier1 <- ifelse(df$candidate_tier == "Tier 1", 1L,
              ifelse(df$candidate_tier == "Tier 2", 0L, NA_integer_))
cat("candidate_tier dist: "); print(sort(table(df$candidate_tier, useNA="ifany")))

# Base working dataset (non-missing on key vars)
df_base <- df[
  !is.na(df$aa_intelligence_index) &
  !is.na(df$size_log_assets) &
  !is.na(df$bm_ratio) &
  !is.na(df$volatility) &
  !is.na(df$momentum),
]
cat(sprintf("Base dataset: n = %d | events = %d\n",
            nrow(df_base), length(unique(df_base$final_event_id))))

# ─── Helper: extract one variable from a fitted model ─────────────────────────
extr <- function(mod, var) {
  b  <- coef(mod)[[var]]
  se <- sqrt(diag(vcov(mod)))[[var]]
  p  <- as.numeric(summary(mod)$coefficients[var, "Pr(>|t|)"])
  s  <- ifelse(p<0.01,"***", ifelse(p<0.05,"**", ifelse(p<0.10,"*","")))
  sprintf("%.6f (SE %.6f)  p = %.4f %s", b, se, p, s)
}

ctrl <- c("size_log_assets","bm_ratio","volatility","momentum")

# =============================================================================
# PART 1 — INTERACTION MECHANISM REGRESSIONS
# =============================================================================
cat("\n")
cat(strrep("=",80), "\n")
cat("PART 1: INTERACTION MECHANISM REGRESSIONS\n")
cat(strrep("=",80), "\n")

# ─── 1A. intelligence × open_weight ──────────────────────────────────────────
cat("\n--- 1A: intelligence × is_open_weight ---\n")
df_ow <- df_base[!is.na(df_base$is_open_weight), ]

for (y in c("car_1","car_20")) {
  d <- df_ow[!is.na(df_ow[[y]]), ]
  fml <- as.formula(paste(y,
    "~ aa_intelligence_index * is_open_weight +",
    paste(ctrl, collapse=" + "), "+ factor(release_year)"))
  mod <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0")

  b0   <- coef(mod)[["aa_intelligence_index"]]
  b_int <- coef(mod)[["aa_intelligence_index:is_open_weight"]]
  cat(sprintf("\n  [%s] n=%d  events=%d\n", toupper(y), nobs(mod), mod$nclusters))
  cat("  intelligence (closed-src slope): ", extr(mod, "aa_intelligence_index"), "\n")
  cat("  is_open_weight (main):           ", extr(mod, "is_open_weight"), "\n")
  cat("  intelligence × open_weight:      ", extr(mod, "aa_intelligence_index:is_open_weight"), "\n")
  cat(sprintf("  Implied slope CLOSED (open=0):   %.6f\n", b0))
  cat(sprintf("  Implied slope OPEN   (open=1):   %.6f\n", b0 + b_int))
}

# ─── 1B. intelligence × tier1 ────────────────────────────────────────────────
cat("\n--- 1B: intelligence × tier1 ---\n")
for (y in c("car_1","car_20")) {
  d <- df_base[!is.na(df_base[[y]]) & !is.na(df_base$tier1), ]
  fml <- as.formula(paste(y,
    "~ aa_intelligence_index * tier1 +",
    paste(ctrl, collapse=" + "), "+ factor(release_year)"))
  mod <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0")

  b0   <- coef(mod)[["aa_intelligence_index"]]
  b_int <- coef(mod)[["aa_intelligence_index:tier1"]]
  cat(sprintf("\n  [%s] n=%d  events=%d\n", toupper(y), nobs(mod), mod$nclusters))
  cat("  intelligence (Tier-2 baseline):  ", extr(mod, "aa_intelligence_index"), "\n")
  cat("  tier1 (main):                    ", extr(mod, "tier1"), "\n")
  cat("  intelligence × tier1:            ", extr(mod, "aa_intelligence_index:tier1"), "\n")
  cat(sprintf("  Implied slope Tier 2 (tier1=0): %.6f\n", b0))
  cat(sprintf("  Implied slope Tier 1 (tier1=1): %.6f\n", b0 + b_int))
}

# ─── 1C. intelligence × relationship type ─────────────────────────────────────
cat("\n--- 1C: intelligence × relationship type (car_20) ---\n")
rel_vars <- c("owner","investor","real_downstream","competitor","real_upstream","cloud")

results_1c <- lapply(rel_vars, function(rv) {
  d <- df_base[!is.na(df_base[[rv]]) & !is.na(df_base$car_20), ]
  n_rel <- sum(d[[rv]] == 1, na.rm=TRUE)
  tryCatch({
    fml <- as.formula(paste("car_20 ~ aa_intelligence_index *", rv, "+",
                             paste(ctrl, collapse=" + "), "+ factor(release_year)"))
    mod <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0")
    b0    <- coef(mod)[["aa_intelligence_index"]]
    b_rel <- coef(mod)[[rv]]
    b_int <- coef(mod)[[paste0("aa_intelligence_index:", rv)]]
    p_int <- as.numeric(summary(mod)$coefficients[paste0("aa_intelligence_index:", rv), "Pr(>|t|)"])
    p_rel <- as.numeric(summary(mod)$coefficients[rv, "Pr(>|t|)"])
    s_int <- ifelse(p_int<0.01,"***", ifelse(p_int<0.05,"**", ifelse(p_int<0.10,"*","")))
    s_rel <- ifelse(p_rel<0.01,"***", ifelse(p_rel<0.05,"**", ifelse(p_rel<0.10,"*","")))

    cat(sprintf("\n  [%s]  N_rel=%d  N_total=%d  events=%d\n", rv, n_rel, nobs(mod), mod$nclusters))
    cat(sprintf("    intelligence (baseline):    %.6f\n", b0))
    cat(sprintf("    %s (main):                  %.6f  p=%.4f %s\n", rv, b_rel, p_rel, s_rel))
    cat(sprintf("    intelligence × %s:           %.6f  p=%.4f %s\n", rv, b_int, p_int, s_int))
    cat(sprintf("    Implied slope (%s=0, other): %.6f\n", rv, b0))
    cat(sprintf("    Implied slope (%s=1):        %.6f\n", rv, b0 + b_int))
    list(rv=rv, b0=b0, b_rel=b_rel, b_int=b_int, p_int=p_int, p_rel=p_rel,
         n_rel=n_rel, n=nobs(mod), events=mod$nclusters)
  }, error = function(e) {
    cat(sprintf("\n  [%s] ERROR: %s\n", rv, conditionMessage(e)))
    NULL
  })
})

# ─── 1D. Three-way: intelligence × tier1 × open_weight ──────────────────────
cat("\n--- 1D: Three-way intelligence × tier1 × open_weight (car_20) ---\n")
d3 <- df_base[!is.na(df_base$is_open_weight) & !is.na(df_base$tier1) & !is.na(df_base$car_20), ]
fml3 <- as.formula(paste(
  "car_20 ~ aa_intelligence_index * tier1 * is_open_weight +",
  paste(ctrl, collapse=" + "), "+ factor(release_year)"))
mod3 <- lm_robust(fml3, data = d3, clusters = d3$final_event_id, se_type = "CR0")
cat(sprintf("  n=%d  events=%d\n", nobs(mod3), mod3$nclusters))

key3 <- c("aa_intelligence_index", "tier1", "is_open_weight",
           "aa_intelligence_index:tier1", "aa_intelligence_index:is_open_weight",
           "tier1:is_open_weight", "aa_intelligence_index:tier1:is_open_weight")
for (v in key3) {
  if (v %in% names(coef(mod3))) {
    b  <- coef(mod3)[[v]]
    se <- sqrt(diag(vcov(mod3)))[[v]]
    p  <- as.numeric(summary(mod3)$coefficients[v, "Pr(>|t|)"])
    s  <- ifelse(p<0.01,"***", ifelse(p<0.05,"**", ifelse(p<0.10,"*","")))
    cat(sprintf("  %-50s %.6f (%.6f)  p=%.4f %s\n", v, b, se, p, s))
  }
}

# Implied slopes for the 4 cells: tier × open
b <- coef(mod3)
cat("\n  Implied slopes (intelligence effect) by cell:\n")
cells <- list(c(0,0,"Tier2_Closed"), c(0,1,"Tier2_Open"), c(1,0,"Tier1_Closed"), c(1,1,"Tier1_Open"))
for (cell in cells) {
  t1 <- as.integer(cell[1]); ow <- as.integer(cell[2]); lab <- cell[3]
  slope <- b["aa_intelligence_index"] +
           t1 * ifelse("aa_intelligence_index:tier1" %in% names(b), b["aa_intelligence_index:tier1"], 0) +
           ow * ifelse("aa_intelligence_index:is_open_weight" %in% names(b), b["aa_intelligence_index:is_open_weight"], 0) +
           t1 * ow * ifelse("aa_intelligence_index:tier1:is_open_weight" %in% names(b), b["aa_intelligence_index:tier1:is_open_weight"], 0)
  cat(sprintf("    %s: %.6f\n", lab, slope))
}

# =============================================================================
# PART 2 — SMALL-CLUSTER ROBUST SE: CR0 vs CR2 vs CR3
# =============================================================================
cat("\n")
cat(strrep("=",80), "\n")
cat("PART 2: SMALL-CLUSTER ROBUST SE COMPARISON  (CR0 / CR2 / CR3)\n")
cat(strrep("=",80), "\n")

compare_se <- function(data, y, label, var = "aa_intelligence_index") {
  d   <- data[!is.na(data[[y]]), ]
  n_e <- length(unique(d$final_event_id))
  fml <- as.formula(paste(y, "~", var, "+",
                           paste(ctrl, collapse=" + "), "+ factor(release_year)"))
  cat(sprintf("\n[%s]  y=%s  n=%d  events=%d\n", label, y, nrow(d), n_e))
  for (se_type in c("CR0","CR1S","CR2","CR3")) {
    tryCatch({
      mod <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = se_type)
      b   <- coef(mod)[[var]]
      se  <- sqrt(diag(vcov(mod)))[[var]]
      p   <- as.numeric(summary(mod)$coefficients[var, "Pr(>|t|)"])
      s   <- ifelse(p<0.01,"***", ifelse(p<0.05,"**", ifelse(p<0.10,"*","")))
      cat(sprintf("  %-5s  coef=%+.6f  SE=%.6f  p=%.4f %s\n", se_type, b, se, p, s))
    }, error = function(e) cat(sprintf("  %-5s  ERROR: %s\n", se_type, conditionMessage(e))))
  }
}

# Full sample
compare_se(df_base,   "car_1",  "Full sample")
compare_se(df_base,   "car_20", "Full sample")

# Closed source (36 events)
df_closed <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 0, ]
compare_se(df_closed, "car_20", "Closed source")

# Open source (11 events) — most critical
df_open <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 1, ]
compare_se(df_open,   "car_15", "Open source")
compare_se(df_open,   "car_20", "Open source")

# Owner (21 events)
df_owner <- df_base[!is.na(df_base$owner) & df_base$owner == 1, ]
compare_se(df_owner,  "car_1",  "Owner")
compare_se(df_owner,  "car_20", "Owner")

# Investor (20 events)
df_investor <- df_base[!is.na(df_base$investor) & df_base$investor == 1, ]
compare_se(df_investor, "car_20", "Investor")

# Real downstream (~20 events)
df_rdm <- df_base[!is.na(df_base$real_downstream) & df_base$real_downstream == 1, ]
compare_se(df_rdm,    "car_20", "Real downstream")

# Tier 1 (18 events)
df_t1 <- df_base[!is.na(df_base$tier1) & df_base$tier1 == 1, ]
compare_se(df_t1,     "car_20", "Tier 1")

# Tier 2 (27 events — use explicit label, not tier1==0 which includes Tier 3)
df_t2 <- df_base[!is.na(df_base$candidate_tier) & df_base$candidate_tier == "Tier 2", ]
compare_se(df_t2,     "car_20", "Tier 2")

# =============================================================================
# PART 3 — WILD CLUSTER BOOTSTRAP  (manual implementation, Rademacher weights)
#   Uses "impose null" approach: residuals from restricted model
# =============================================================================
cat("\n")
cat(strrep("=",80), "\n")
cat("PART 3: WILD CLUSTER BOOTSTRAP  (manual, Rademacher; B=4999)\n")
cat(strrep("=",80), "\n")

wild_boot <- function(data, y, label, var = "aa_intelligence_index",
                      B = 4999, seed = 42) {
  d <- data[!is.na(data[[y]]) & !is.na(data[[var]]), ]
  for (cv in ctrl) d <- d[!is.na(d[[cv]]), ]
  d <- d[!is.na(d$final_event_id), ]

  n_cl <- length(unique(d$final_event_id))
  cat(sprintf("\n[%s]  y=%s  n=%d  events=%d\n", label, y, nrow(d), n_cl))

  fml_full  <- as.formula(paste(y, "~", var, "+",
                                paste(ctrl, collapse=" + "), "+ factor(release_year)"))
  fml_restr <- as.formula(paste(y, "~",
                                paste(ctrl, collapse=" + "), "+ factor(release_year)"))

  # Observed CR0 result
  mod_obs <- lm_robust(fml_full, data = d, clusters = d$final_event_id, se_type = "CR0")
  b_obs   <- coef(mod_obs)[[var]]
  se_obs  <- sqrt(diag(vcov(mod_obs)))[[var]]
  t_obs   <- b_obs / se_obs
  p_cr0   <- as.numeric(summary(mod_obs)$coefficients[var, "Pr(>|t|)"])

  # Restricted model residuals (impose null)
  mod_r   <- lm(fml_restr, data = d)
  e_hat   <- residuals(mod_r)
  y_hat   <- fitted(mod_r)

  cl_ids  <- d$final_event_id
  ucl     <- unique(cl_ids)
  G       <- length(ucl)

  set.seed(seed)
  t_star  <- numeric(B)
  for (b in seq_len(B)) {
    g <- sample(c(-1L, 1L), G, replace = TRUE)
    names(g) <- ucl
    e_b      <- e_hat * g[as.character(cl_ids)]
    d_b      <- d
    d_b[[y]] <- y_hat + e_b
    tryCatch({
      m_b      <- lm_robust(fml_full, data = d_b, clusters = d_b$final_event_id, se_type = "CR0")
      t_star[b] <- coef(m_b)[[var]] / sqrt(diag(vcov(m_b)))[[var]]
    }, error = function(e) { t_star[b] <<- NA_real_ })
  }
  t_star <- t_star[!is.na(t_star)]
  p_wild <- mean(abs(t_star) >= abs(t_obs))

  s_cr0  <- ifelse(p_cr0<0.01,"***", ifelse(p_cr0<0.05,"**", ifelse(p_cr0<0.10,"*","")))
  s_wild <- ifelse(p_wild<0.01,"***", ifelse(p_wild<0.05,"**", ifelse(p_wild<0.10,"*","")))
  cat(sprintf("  coef = %.6f   t = %.3f\n", b_obs, t_obs))
  cat(sprintf("  CR0  p = %.4f %s\n", p_cr0, s_cr0))
  cat(sprintf("  Wild p = %.4f %s  (B=%d, Rademacher)\n", p_wild, s_wild, length(t_star)))
}

# Key small-cluster cases
wild_boot(df_open,     "car_15", "Open source, car_15")
wild_boot(df_open,     "car_20", "Open source, car_20")
wild_boot(df_owner,    "car_1",  "Owner, car_1")
wild_boot(df_owner,    "car_2",  "Owner, car_2")

# Tier 1 (18 clusters)
df_t1_wb <- df_base[!is.na(df_base$tier1) & df_base$tier1 == 1, ]
wild_boot(df_t1_wb,    "car_20", "Tier 1, car_20")

# Full sample & closed source for reference
wild_boot(df_base,     "car_20", "Full sample, car_20")
wild_boot(df_closed,   "car_20", "Closed source, car_20")

cat("\n\nAll done.\n")
