#!/usr/bin/env Rscript
# =============================================================================
# heterogeneity_analysis.R
#
# Part A: Industry-group subsamples (intel_c → car_20)
# Part B: Mag7 vs non-Mag7 interaction model
# Part C: FinBERT media sentiment — mediation & moderation
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

# ─── Load & prepare data ──────────────────────────────────────────────────────
df <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c(
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "ff3_car_1","ff3_car_5","ff3_car_10","ff3_car_15","ff3_car_20",
  "aa_intelligence_index","size_log_assets","bm_ratio","volatility","momentum",
  "release_year","is_open_weight","owner","investor","cloud",
  "business_upstream","real_upstream","business_downstream","real_downstream","competitor"
)
for (col in num_cols) if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])

# Rename sentiment columns to short names
df$sent_w2  <- as.numeric(df[["媒体态度均值(2,2)"]])
df$sent_w5  <- as.numeric(df[["媒体态度均值(5,5)"]])
df$sent_w10 <- as.numeric(df[["媒体态度均值(10,10)"]])
df$sent_w20 <- as.numeric(df[["媒体态度均值(20,20)"]])

# Base filter: complete controls + intelligence
ctrl <- c("size_log_assets","bm_ratio","volatility","momentum")
df_base <- df[
  !is.na(df$aa_intelligence_index) &
  !is.na(df$size_log_assets) &
  !is.na(df$bm_ratio) &
  !is.na(df$volatility) &
  !is.na(df$momentum), ]

# Center intelligence
intel_mean <- mean(df_base$aa_intelligence_index, na.rm = TRUE)
df_base$intel_c <- df_base$aa_intelligence_index - intel_mean
cat(sprintf("Base sample: n=%d, events=%d, intel_mean=%.3f\n",
            nrow(df_base), length(unique(df_base$final_event_id)), intel_mean))

# Mag7 indicator
mag7_names <- c("苹果","微软","英伟达","Alphabet（谷歌）","亚马逊","Meta（Facebook）","特斯拉")
df_base$mag7 <- as.integer(df_base$company %in% mag7_names)
cat(sprintf("Mag7: %d obs, %d events  |  non-Mag7: %d obs, %d events\n",
            sum(df_base$mag7==1, na.rm=TRUE), length(unique(df_base$final_event_id[df_base$mag7==1])),
            sum(df_base$mag7==0, na.rm=TRUE), length(unique(df_base$final_event_id[df_base$mag7==0]))))

# Formula helpers
make_fml <- function(y, xterms) {
  as.formula(paste(y, "~", paste(c(xterms, ctrl, "factor(release_year)"), collapse = " + ")))
}

stars <- function(p) {
  if (is.na(p)) return("")
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
}
fmt <- function(b, p) sprintf("%.5f%s", b, stars(p))
fmt_p <- function(p) if (is.na(p)) "n/a" else sprintf("%.3f%s", p, stars(p))

# Quick OLS (CR0 + CR2)
run_both <- function(data, fml, var) {
  d <- data[!is.na(data[[all.vars(fml)[1]]]), ]
  m0 <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0")
  m2 <- lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR2")
  b  <- coef(m0)[[var]]
  se <- sqrt(diag(vcov(m0)))[[var]]
  p0 <- as.numeric(summary(m0)$coefficients[var, "Pr(>|t|)"])
  p2 <- tryCatch(as.numeric(summary(m2)$coefficients[var, "Pr(>|t|)"]), error = function(e) NA_real_)
  list(n = nrow(d), events = length(unique(d$final_event_id)), b = b, se = se, p0 = p0, p2 = p2)
}


# =============================================================================
# PART A: INDUSTRY GROUP HETEROGENEITY
# =============================================================================
cat("\n", strrep("=", 80), "\n")
cat("PART A: INDUSTRY GROUP SUBSAMPLES (intel_c → car_20)\n")
cat(strrep("=", 80), "\n\n")

# Consolidate industry groups for analysis
# Keep the 6 largest; collapse others into "其他"
top_industries <- c(
  "软件",
  "半导体和半导体设备",
  "技术硬件、存储和外围设备",
  "IT服务",
  "互联网服务和基础设施",
  "互联网零售"
)
df_base$ind_group <- ifelse(df_base$industry_2 %in% top_industries,
                             df_base$industry_2, "其他/非IT")

cat("Industry group sizes:\n")
print(table(df_base$ind_group))

# Subsample regressions
ind_results <- list()
for (g in c(top_industries, "其他/非IT")) {
  sub <- df_base[df_base$ind_group == g, ]
  n_sub   <- sum(!is.na(sub$car_20))
  n_ev    <- length(unique(sub$final_event_id))
  if (n_sub < 20 || n_ev < 3) {
    cat(sprintf("  [SKIP] %s: n=%d events=%d (too small)\n", g, n_sub, n_ev))
    next
  }
  r <- tryCatch(run_both(sub, make_fml("car_20", "intel_c"), "intel_c"), error = function(e) NULL)
  if (!is.null(r)) {
    ind_results[[g]] <- r
    cat(sprintf("  %-30s n=%4d ev=%2d  beta=%+.5f  CR0=%s  CR2=%s\n",
                g, r$n, r$events,
                r$b, fmt_p(r$p0), fmt_p(r$p2)))
  }
}

# Interaction: full model with industry × intel_c dummies
# (Using top 4 + "其他" — need at least 5 obs in each cell)
cat("\n--- Full interaction model: intel_c × industry_group ---\n")
df_ind <- df_base[!is.na(df_base$car_20), ]
df_ind$ind_f <- factor(df_ind$ind_group,
                       levels = c("软件", "半导体和半导体设备",
                                  "技术硬件、存储和外围设备", "IT服务",
                                  "互联网服务和基础设施", "互联网零售", "其他/非IT"))
fml_ind <- as.formula(paste(
  "car_20 ~ intel_c * ind_f +",
  paste(ctrl, collapse = "+"), "+ factor(release_year)"
))
m_ind <- tryCatch(
  lm_robust(fml_ind, data = df_ind, clusters = df_ind$final_event_id, se_type = "CR0"),
  error = function(e) { cat("Interaction model failed:", e$message, "\n"); NULL }
)
if (!is.null(m_ind)) {
  sm <- summary(m_ind)$coefficients
  int_rows <- grepl("intel_c:ind_f", rownames(sm))
  cat("\nInteraction terms (baseline = 软件):\n")
  for (rn in rownames(sm)[int_rows]) {
    b  <- sm[rn, "Estimate"]
    p  <- sm[rn, "Pr(>|t|)"]
    cat(sprintf("  %-45s  beta=%+.5f  p=%s\n", rn, b, fmt_p(p)))
  }
  # Main intel_c at baseline (software)
  b0 <- sm["intel_c", "Estimate"]
  p0 <- sm["intel_c", "Pr(>|t|)"]
  cat(sprintf("\n  intel_c (baseline=软件):  beta=%+.5f  p=%s\n", b0, fmt_p(p0)))
}

# Also: sector-level CAR means (no intelligence control) for descriptive table
cat("\n--- Descriptive: mean CAR[0,+20] by industry group ---\n")
desc_ind <- df_base %>%
  filter(!is.na(car_20)) %>%
  group_by(ind_group) %>%
  summarise(
    n         = n(),
    events    = n_distinct(final_event_id),
    mean_car20 = mean(car_20, na.rm = TRUE),
    sd_car20   = sd(car_20, na.rm = TRUE),
    .groups = "drop"
  ) %>% arrange(desc(n))
print(as.data.frame(desc_ind))
write.csv(desc_ind, "industry_car_summary.csv", row.names = FALSE)


# =============================================================================
# PART B: MAG7 vs NON-MAG7
# =============================================================================
cat("\n", strrep("=", 80), "\n")
cat("PART B: MAG7 vs NON-MAG7\n")
cat(strrep("=", 80), "\n\n")

df_m7    <- df_base[df_base$mag7 == 1, ]
df_nonm7 <- df_base[df_base$mag7 == 0, ]

# Subsample regressions for multiple windows
windows <- c("car_1","car_2","car_5","car_10","car_15","car_20")
cat(sprintf("%-12s  %s\n", "", "--- Mag7 ---          --- non-Mag7 ---"))
cat(sprintf("%-12s  %6s %6s %8s   %6s %6s %8s\n",
            "Window", "n", "ev", "CR0 p", "n", "ev", "CR0 p"))
cat(strrep("-", 65), "\n")
for (w in windows) {
  r7  <- tryCatch(run_both(df_m7,    make_fml(w, "intel_c"), "intel_c"), error = function(e) NULL)
  rn7 <- tryCatch(run_both(df_nonm7, make_fml(w, "intel_c"), "intel_c"), error = function(e) NULL)
  if (!is.null(r7) && !is.null(rn7)) {
    cat(sprintf("%-12s  %6d %6d %8s   %6d %6d %8s\n",
                w, r7$n, r7$events, fmt_p(r7$p0),
                rn7$n, rn7$events, fmt_p(rn7$p0)))
  }
}

# Interaction: intel_c × mag7 (full sample, car_20)
cat("\n--- Interaction: intel_c × mag7 (car_20) ---\n")
fml_m7 <- make_fml("car_20", c("intel_c","mag7","intel_c:mag7"))
dm7 <- df_base[!is.na(df_base$car_20) & !is.na(df_base$mag7), ]
m_m7 <- lm_robust(fml_m7, data = dm7, clusters = dm7$final_event_id, se_type = "CR0")
m_m7_cr2 <- lm_robust(fml_m7, data = dm7, clusters = dm7$final_event_id, se_type = "CR2")
sm_m7 <- summary(m_m7)$coefficients
sm_m7_cr2 <- summary(m_m7_cr2)$coefficients
for (v in c("intel_c","mag7","intel_c:mag7")) {
  b  <- sm_m7[v, "Estimate"]
  p0 <- sm_m7[v, "Pr(>|t|)"]
  p2 <- sm_m7_cr2[v, "Pr(>|t|)"]
  se <- sm_m7[v, "Std. Error"]
  cat(sprintf("  %-20s beta=%+.5f SE=%.5f CR0=%s CR2=%s\n",
              v, b, se, fmt_p(p0), fmt_p(p2)))
}
b_main <- coef(m_m7)[["intel_c"]]
b_int  <- coef(m_m7)[["intel_c:mag7"]]
cat(sprintf("\n  Implied slope (non-Mag7): %+.6f\n", b_main))
cat(sprintf("  Implied slope (Mag7):     %+.6f\n", b_main + b_int))

# Mag7 with CR0 & CR2 for car_20 detailed
cat("\n--- Detailed: Mag7 and non-Mag7 car_20 (CR0 + CR2) ---\n")
for (nm in c("Mag7","non-Mag7")) {
  sub <- if (nm == "Mag7") df_m7 else df_nonm7
  r0 <- run_both(sub, make_fml("car_20", "intel_c"), "intel_c")
  cat(sprintf("  %-10s n=%4d ev=%2d  beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
              nm, r0$n, r0$events, r0$b, r0$se, fmt_p(r0$p0), fmt_p(r0$p2)))
}

# Per-company descriptive: mean car_20 by Mag7 company
cat("\n--- Mag7 individual company: mean car_20 across events ---\n")
mag7_desc <- df_base %>%
  filter(company %in% mag7_names, !is.na(car_20)) %>%
  group_by(company) %>%
  summarise(
    n         = n(),
    events    = n_distinct(final_event_id),
    mean_car1  = mean(car_1, na.rm = TRUE),
    mean_car20 = mean(car_20, na.rm = TRUE),
    .groups = "drop"
  ) %>% arrange(desc(mean_car20))
print(as.data.frame(mag7_desc))
write.csv(mag7_desc, "mag7_company_car_summary.csv", row.names = FALSE)


# =============================================================================
# PART C: FINBERT MEDIA SENTIMENT
# =============================================================================
cat("\n", strrep("=", 80), "\n")
cat("PART C: FINBERT MEDIA SENTIMENT\n")
cat(strrep("=", 80), "\n\n")

# Center sentiment as well (for interaction interpretation)
df_base$sent_c5  <- df_base$sent_w5  - mean(df_base$sent_w5,  na.rm = TRUE)
df_base$sent_c10 <- df_base$sent_w10 - mean(df_base$sent_w10, na.rm = TRUE)
df_base$sent_c20 <- df_base$sent_w20 - mean(df_base$sent_w20, na.rm = TRUE)
sent_mean5 <- mean(df_base$sent_w5, na.rm = TRUE)
cat(sprintf("Sentiment w5: mean=%.4f, SD=%.4f, n=%d\n",
            sent_mean5,
            sd(df_base$sent_w5, na.rm = TRUE),
            sum(!is.na(df_base$sent_w5))))
cat(sprintf("Sentiment w20: mean=%.4f, SD=%.4f, n=%d\n",
            mean(df_base$sent_w20, na.rm=TRUE),
            sd(df_base$sent_w20, na.rm=TRUE),
            sum(!is.na(df_base$sent_w20))))

# C1: Sentiment alone (does media sentiment predict CAR?)
cat("\n--- C1: Sentiment alone (car_20 ~ sent_c5 + controls) ---\n")
r_s <- run_both(df_base, make_fml("car_20", "sent_c5"), "sent_c5")
cat(sprintf("  sent_c5  n=%d ev=%d  beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
            r_s$n, r_s$events, r_s$b, r_s$se, fmt_p(r_s$p0), fmt_p(r_s$p2)))
r_s20 <- run_both(df_base, make_fml("car_20", "sent_c20"), "sent_c20")
cat(sprintf("  sent_c20 n=%d ev=%d  beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
            r_s20$n, r_s20$events, r_s20$b, r_s20$se, fmt_p(r_s20$p0), fmt_p(r_s20$p2)))

# C2: Intelligence + Sentiment jointly (mutual control)
cat("\n--- C2: Joint model (car_20 ~ intel_c + sent_c5 + controls) ---\n")
r_joint <- run_both(df_base, make_fml("car_20", c("intel_c","sent_c5")), "intel_c")
r_sent_in_joint <- run_both(df_base, make_fml("car_20", c("intel_c","sent_c5")), "sent_c5")
cat(sprintf("  intel_c in joint:  beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
            r_joint$b, r_joint$se, fmt_p(r_joint$p0), fmt_p(r_joint$p2)))
cat(sprintf("  sent_c5 in joint:  beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
            r_sent_in_joint$b, r_sent_in_joint$se,
            fmt_p(r_sent_in_joint$p0), fmt_p(r_sent_in_joint$p2)))

# C3: Multiple windows — does sentiment window match CAR window?
cat("\n--- C3: Matched-window joint models ---\n")
sent_win_pairs <- list(
  list(car = "car_1",  sent = "sent_w2"),
  list(car = "car_5",  sent = "sent_w5"),
  list(car = "car_10", sent = "sent_w10"),
  list(car = "car_20", sent = "sent_w20")
)
cat(sprintf("%-10s  %-12s  %8s  %8s  %8s\n", "CAR", "Sent", "Beta_intel", "CR0", "CR2"))
for (pair in sent_win_pairs) {
  d <- df_base
  d$sc <- d[[pair$sent]] - mean(d[[pair$sent]], na.rm = TRUE)
  fml <- make_fml(pair$car, c("intel_c","sc"))
  r_i  <- tryCatch(run_both(d, fml, "intel_c"), error = function(e) NULL)
  r_s_ <- tryCatch(run_both(d, fml, "sc"), error = function(e) NULL)
  if (!is.null(r_i) && !is.null(r_s_)) {
    cat(sprintf("  %-10s  %-12s  %+.5f   %8s  %8s  |  sent: %+.5f CR0=%s\n",
                pair$car, pair$sent,
                r_i$b, fmt_p(r_i$p0), fmt_p(r_i$p2),
                r_s_$b, fmt_p(r_s_$p0)))
  }
}

# C4: Interaction intelligence × sentiment (does high sentiment amplify intel effect?)
cat("\n--- C4: Interaction intel_c × sent_c5 (car_20) ---\n")
df_sent <- df_base[!is.na(df_base$sent_c5) & !is.na(df_base$car_20), ]
fml_int_s <- make_fml("car_20", c("intel_c","sent_c5","intel_c:sent_c5"))
m_is <- lm_robust(fml_int_s, data = df_sent, clusters = df_sent$final_event_id, se_type = "CR0")
m_is2 <- lm_robust(fml_int_s, data = df_sent, clusters = df_sent$final_event_id, se_type = "CR2")
for (v in c("intel_c","sent_c5","intel_c:sent_c5")) {
  b  <- coef(m_is)[[v]]
  se <- sqrt(diag(vcov(m_is)))[[v]]
  p0 <- as.numeric(summary(m_is)$coefficients[v, "Pr(>|t|)"])
  p2 <- tryCatch(as.numeric(summary(m_is2)$coefficients[v, "Pr(>|t|)"]), error = function(e) NA_real_)
  cat(sprintf("  %-22s beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
              v, b, se, fmt_p(p0), fmt_p(p2)))
}

# C5: Intelligence predicts sentiment? (First stage / mediation check)
cat("\n--- C5: Does intel_c predict media sentiment? (Event-level check) ---\n")
# Aggregate to event level for mediation check
df_ev <- df_base %>%
  group_by(final_event_id, release_year) %>%
  summarise(
    intel_c  = first(intel_c),
    sent_w5  = first(sent_w5),
    sent_w20 = first(sent_w20),
    .groups  = "drop"
  ) %>% filter(!is.na(intel_c))
cat(sprintf("Event-level obs: %d\n", nrow(df_ev)))
for (sv in c("sent_w5","sent_w20")) {
  sub <- df_ev[!is.na(df_ev[[sv]]), ]
  m <- lm(as.formula(sprintf("%s ~ intel_c + factor(release_year)", sv)), data = sub)
  b <- coef(m)[["intel_c"]]
  se <- sqrt(diag(vcov(m)))[["intel_c"]]
  t  <- b / se
  p  <- 2 * pt(abs(t), df = nrow(sub) - length(coef(m)), lower.tail = FALSE)
  cat(sprintf("  intel_c → %-12s  n_ev=%d  beta=%+.5f SE=%.5f t=%.2f  p=%s\n",
              sv, nrow(sub), b, se, t, fmt_p(p)))
}

# C6: Subsample by high/low sentiment quartile (does effect concentrate in high-sentiment events?)
cat("\n--- C6: Subsample by sentiment quartile (Q4 vs Q1) ---\n")
df_base$sent_q <- ntile(df_base$sent_w5, 4)
for (q in c(4, 1)) {
  sub <- df_base[!is.na(df_base$sent_q) & df_base$sent_q == q, ]
  r <- tryCatch(run_both(sub, make_fml("car_20", "intel_c"), "intel_c"), error = function(e) NULL)
  if (!is.null(r)) {
    cat(sprintf("  Sentiment Q%d  n=%4d ev=%2d  beta=%+.5f SE=%.5f  CR0=%s  CR2=%s\n",
                q, r$n, r$events, r$b, r$se, fmt_p(r$p0), fmt_p(r$p2)))
  }
}

# =============================================================================
# SUMMARY TABLE (for result.md)
# =============================================================================
cat("\n", strrep("=", 80), "\n")
cat("SUMMARY TABLES\n")
cat(strrep("=", 80), "\n\n")

# Industry table
cat("--- Panel A: Industry group car_20 ~ intel_c ---\n")
cat(sprintf("%-34s  %5s %5s  %9s  %7s  %7s\n",
            "Group", "N", "Ev", "Beta", "CR0 p", "CR2 p"))
cat(strrep("-", 70), "\n")
for (g in names(ind_results)) {
  r <- ind_results[[g]]
  cat(sprintf("%-34s  %5d %5d  %+9.5f  %7s  %7s\n",
              g, r$n, r$events, r$b, fmt_p(r$p0), fmt_p(r$p2)))
}

# Mag7 table
cat("\n--- Panel B: Mag7 vs non-Mag7 ---\n")
cat(sprintf("%-12s  %5s %5s  %9s  %7s  %7s\n",
            "Group", "N", "Ev", "Beta", "CR0 p", "CR2 p"))
for (nm in c("Mag7","non-Mag7")) {
  sub <- if (nm == "Mag7") df_m7 else df_nonm7
  r <- run_both(sub, make_fml("car_20", "intel_c"), "intel_c")
  cat(sprintf("%-12s  %5d %5d  %+9.5f  %7s  %7s\n",
              nm, r$n, r$events, r$b, fmt_p(r$p0), fmt_p(r$p2)))
}

# Sentiment summary table
cat("\n--- Panel C: Sentiment models summary ---\n")
rows_c <- list(
  list(label = "Sentiment alone (w5)",          var = "sent_c5",     b = r_s$b,   p0 = r_s$p0,   p2 = r_s$p2),
  list(label = "Sentiment alone (w20)",          var = "sent_c20",    b = r_s20$b, p0 = r_s20$p0, p2 = r_s20$p2),
  list(label = "Joint: intel_c (+ sent_c5)",     var = "intel_c",     b = r_joint$b, p0 = r_joint$p0, p2 = r_joint$p2),
  list(label = "Joint: sent_c5 (+ intel_c)",     var = "sent_c5",     b = r_sent_in_joint$b, p0 = r_sent_in_joint$p0, p2 = r_sent_in_joint$p2)
)
for (r in rows_c) {
  cat(sprintf("  %-38s beta=%+.5f  CR0=%s  CR2=%s\n",
              r$label, r$b, fmt_p(r$p0), fmt_p(r$p2)))
}

# Save a CSV with all key results
all_rows <- data.frame(
  section = c(
    rep("A_industry", length(ind_results)),
    "B_mag7", "B_nonmag7",
    "C_sent_w5_alone", "C_sent_w20_alone",
    "C_intel_joint", "C_sent_in_joint"
  ),
  label = c(
    names(ind_results),
    "Mag7","non-Mag7",
    "sent_w5 alone","sent_w20 alone",
    "intel_c (joint w sent_c5)","sent_c5 (joint w intel_c)"
  ),
  n = c(
    sapply(ind_results, `[[`, "n"),
    run_both(df_m7, make_fml("car_20","intel_c"), "intel_c")$n,
    run_both(df_nonm7, make_fml("car_20","intel_c"), "intel_c")$n,
    r_s$n, r_s20$n, r_joint$n, r_sent_in_joint$n
  ),
  events = c(
    sapply(ind_results, `[[`, "events"),
    run_both(df_m7, make_fml("car_20","intel_c"), "intel_c")$events,
    run_both(df_nonm7, make_fml("car_20","intel_c"), "intel_c")$events,
    r_s$events, r_s20$events, r_joint$events, r_sent_in_joint$events
  ),
  beta = c(
    sapply(ind_results, `[[`, "b"),
    run_both(df_m7, make_fml("car_20","intel_c"), "intel_c")$b,
    run_both(df_nonm7, make_fml("car_20","intel_c"), "intel_c")$b,
    r_s$b, r_s20$b, r_joint$b, r_sent_in_joint$b
  ),
  p_cr0 = c(
    sapply(ind_results, `[[`, "p0"),
    run_both(df_m7, make_fml("car_20","intel_c"), "intel_c")$p0,
    run_both(df_nonm7, make_fml("car_20","intel_c"), "intel_c")$p0,
    r_s$p0, r_s20$p0, r_joint$p0, r_sent_in_joint$p0
  ),
  p_cr2 = c(
    sapply(ind_results, `[[`, "p2"),
    run_both(df_m7, make_fml("car_20","intel_c"), "intel_c")$p2,
    run_both(df_nonm7, make_fml("car_20","intel_c"), "intel_c")$p2,
    r_s$p2, r_s20$p2, r_joint$p2, r_sent_in_joint$p2
  ),
  stringsAsFactors = FALSE
)
write.csv(all_rows, "heterogeneity_results.csv", row.names = FALSE)
cat("\nSaved: heterogeneity_results.csv\n")
cat("\nAll done.\n")
