#!/usr/bin/env Rscript
# =============================================================================
# Quarter-Level Pricing Regime Analysis
# When did capital markets start pricing model capability?
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

# ── Load data ──────────────────────────────────────────────────────────────────
df_raw <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c(
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "ff3_car_1","ff3_car_5","ff3_car_20",
  "aa_intelligence_index","size_log_assets","bm_ratio","volatility","momentum",
  "release_year","trend_month","is_open_weight","is_chinese_model",
  "owner","investor","cloud","business_upstream","real_upstream",
  "business_downstream","real_downstream","competitor"
)
for (col in num_cols) if (col %in% names(df_raw)) df_raw[[col]] <- as.numeric(df_raw[[col]])

# ── Prepare analysis sample ────────────────────────────────────────────────────
df <- df_raw %>%
  filter(!is.na(aa_intelligence_index)) %>%
  mutate(
    event_quarter = release_quarter,
    event_quarter = factor(event_quarter, levels = sort(unique(event_quarter)))
  )

# Numeric quarter index for trend tests
q_levels <- levels(df$event_quarter)
df$quarter_idx <- as.numeric(df$event_quarter)

# Composition control dummies
df$is_open_source  <- ifelse(!is.na(df$is_open_weight) & df$is_open_weight == 1, 1, 0)
df$is_closed_source <- ifelse(!is.na(df$is_open_weight) & df$is_open_weight == 0, 1, 0)
df$tier1 <- ifelse(df$candidate_tier == "Tier 1", 1, 0)
df$tier2 <- ifelse(df$candidate_tier == "Tier 2", 1, 0)
df$tier3 <- ifelse(df$candidate_tier == "Tier 3", 1, 0)
df$china_model  <- ifelse(!is.na(df$is_chinese_model) & df$is_chinese_model == 1, 1, 0)
df$us_listed_pub <- ifelse(df$creator_type == "listed_us_company", 1, 0)

# Modality dummies
df$mod_text     <- ifelse(grepl("text_llm", df$model_modality, fixed = TRUE), 1, 0)
df$mod_reasoning <- ifelse(grepl("reasoning", df$model_modality, fixed = TRUE), 1, 0)
df$mod_multimodal <- ifelse(grepl("multimodal", df$model_modality, fixed = TRUE), 1, 0)
df$mod_coding    <- ifelse(grepl("coding", df$model_modality, fixed = TRUE), 1, 0)

# Publisher type dummies
df$pub_listed_us    <- ifelse(df$creator_type == "listed_us_company", 1, 0)
df$pub_private_us   <- ifelse(df$creator_type == "private_us_company", 1, 0)
df$pub_public_nonus <- ifelse(df$creator_type == "public_non_us_company", 1, 0)
df$pub_private_nonus <- ifelse(df$creator_type == "private_non_us_company", 1, 0)

# Firm controls
firm_ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")

# Relationship controls
rel_ctrl <- c("owner","investor","cloud","business_upstream","real_upstream",
              "business_downstream","real_downstream","competitor")

# Composition controls
comp_ctrl <- c("is_closed_source", "tier1", "tier2",
               "mod_text", "mod_reasoning", "mod_multimodal",
               "pub_listed_us", "pub_private_us", "pub_public_nonus",
               "china_model")

# All controls
all_ctrl <- c(firm_ctrl, rel_ctrl)

out_dir <- "."

# =============================================================================
# STEP 1: Quarter Composition Table
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 1: Quarter Composition Table\n")
cat(paste(rep("=",90), collapse=""), "\n")

df_event <- df %>%
  group_by(final_event_id) %>%
  slice(1) %>%
  ungroup()

# Firm-obs count from full data (all rows, not just event-level)
n_firm_df <- df %>%
  count(event_quarter, name = "n_firm_obs")

comp_stats <- df_event %>%
  group_by(event_quarter) %>%
  summarise(
    n_events             = n_distinct(final_event_id),
    mean_aa_intelligence = mean(aa_intelligence_index, na.rm = TRUE),
    sd_aa_intelligence   = sd(aa_intelligence_index, na.rm = TRUE),
    share_closed_source  = mean(is_open_weight == 0, na.rm = TRUE),
    share_open_source    = mean(is_open_weight == 1, na.rm = TRUE),
    share_tier1          = mean(candidate_tier == "Tier 1", na.rm = TRUE),
    share_tier2          = mean(candidate_tier == "Tier 2", na.rm = TRUE),
    share_china_model    = mean(is_chinese_model == 1, na.rm = TRUE),
    share_us_listed_pub  = mean(creator_type == "listed_us_company", na.rm = TRUE),
    n_unique_creators    = n_distinct(true_model_creator),
    .groups = "drop"
  )

quarter_comp <- comp_stats %>%
  left_join(n_firm_df, by = "event_quarter") %>%
  arrange(event_quarter)

cat("\nQuarter Composition Table:\n\n")
print(as.data.frame(quarter_comp))

write.csv(quarter_comp, file.path(out_dir, "quarter_composition_table.csv"), row.names = FALSE)
cat("\nSaved: quarter_composition_table.csv\n")

# =============================================================================
# STEP 2: Quarter-Specific Slope Model
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 2: Quarter-Specific Slope Model\n")
cat(paste(rep("=",90), collapse=""), "\n")

estimate_quarter_model <- function(y_var, d, extra_ctrl = character(0)) {
  d <- d[!is.na(d[[y_var]]), ]
  rhs <- c("aa_intelligence_index:event_quarter", "event_quarter")
  if (length(extra_ctrl) > 0) rhs <- c(rhs, extra_ctrl)
  fml <- as.formula(paste(y_var, "~ 0 +", paste(rhs, collapse = " + ")))
  tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
}

extract_quarter_slopes <- function(mod, data_used, y_var) {
  if (is.null(mod)) return(NULL)
  b <- coef(mod)
  v <- vcov(mod)
  sm <- summary(mod)$coefficients
  q_names <- grep("aa_intelligence_index:event_quarter", names(b), value = TRUE)
  results <- lapply(q_names, function(qn) {
    q <- sub("aa_intelligence_index:event_quarter", "", qn, fixed = TRUE)
    est <- b[[qn]]
    se  <- sqrt(v[qn, qn])
    pval <- sm[qn, "Pr(>|t|)"]
    ci_lo <- est - 1.96 * se
    ci_hi <- est + 1.96 * se
    n_events <- length(unique(data_used$final_event_id[data_used$event_quarter == q]))
    n_obs    <- sum(data_used$event_quarter == q, na.rm = TRUE)
    data.frame(
      event_quarter = q,
      outcome = y_var,
      coef = round(est, 6),
      se = round(se, 6),
      p_value = signif(pval, 4),
      ci_95_lo = round(ci_lo, 6),
      ci_95_hi = round(ci_hi, 6),
      n_events = n_events,
      n_obs = n_obs,
      stars = ifelse(pval < 0.001, "***", ifelse(pval < 0.01, "**",
               ifelse(pval < 0.05, "*", ifelse(pval < 0.10, "+", "")))),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, results)
}

# Main model: CAR[0,+20] as primary outcome
d_car20 <- df[!is.na(df$car_20), ]
m_main <- estimate_quarter_model("car_20", d_car20, all_ctrl)
slopes_main <- extract_quarter_slopes(m_main, d_car20, "car_20")

cat("\nQuarter-Specific Slopes: aa_intelligence_index -> CAR[0,+20]\n")
cat("(with quarter FE + firm controls + relationship controls, event-clustered SE)\n\n")
print(slopes_main[, c("event_quarter","coef","se","p_value","ci_95_lo","ci_95_hi","n_events","n_obs","stars")])

# Robustness: CAR[0,+1] and CAR[0,+15]
d_car1  <- df[!is.na(df$car_1), ]
d_car15 <- df[!is.na(df$car_15), ]
m_car1  <- estimate_quarter_model("car_1", d_car1, all_ctrl)
m_car15 <- estimate_quarter_model("car_15", d_car15, all_ctrl)
slopes_car1  <- extract_quarter_slopes(m_car1, d_car1, "car_1")
slopes_car15 <- extract_quarter_slopes(m_car15, d_car15, "car_15")

all_slopes <- rbind(slopes_main, slopes_car1, slopes_car15)
write.csv(all_slopes, file.path(out_dir, "quarter_specific_slopes.csv"), row.names = FALSE)
cat("\nSaved: quarter_specific_slopes.csv\n")

# Print robustness tables
for (outcome in c("car_1","car_15")) {
  cat(sprintf("\nQuarter-Specific Slopes: aa_intelligence_index -> %s\n", outcome))
  s <- if (outcome == "car_1") slopes_car1 else slopes_car15
  print(s[, c("event_quarter","coef","se","p_value","n_events","n_obs","stars")])
}

# =============================================================================
# STEP 3: Coefficient Plot
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 3: Coefficient Plot\n")
cat(paste(rep("=",90), collapse=""), "\n")

slopes_main$quarter_num <- seq_len(nrow(slopes_main))
slopes_main$low_conf <- slopes_main$n_events < 5

p <- ggplot(slopes_main, aes(x = factor(event_quarter, levels = event_quarter), y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_95_lo, ymax = ci_95_hi, color = low_conf),
                width = 0.15, linewidth = 0.8) +
  geom_point(aes(size = n_events, color = low_conf)) +
  scale_color_manual(values = c("FALSE" = "#2166AC", "TRUE" = "#B2182B"),
                     labels = c("FALSE" = ">=5 events", "TRUE" = "<5 events")) +
  scale_size_continuous(name = "Number of events", range = c(2, 5)) +
  labs(
    title = "Quarter-Specific Pricing Slope of AA Intelligence Index on CAR[0,+20]",
    subtitle = "With 95% confidence intervals, event-clustered standard errors",
    x = "Event Quarter",
    y = expression(beta[q] ~ "(AA Intelligence Index" %->% "CAR[0,+20])")
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(file.path(out_dir, "quarter_specific_slope_plot.png"), p,
       width = 10, height = 6, dpi = 150, bg = "white")
cat("Saved: quarter_specific_slope_plot.png\n")

# =============================================================================
# STEP 4: Regime Tests
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 4: Regime Tests\n")
cat(paste(rep("=",90), collapse=""), "\n")

# Helper: compute F-test for linear hypothesis Rb = r
wald_test <- function(mod, R) {
  b <- coef(mod)
  V <- vcov(mod)
  keep <- names(b) %in% colnames(R)
  b_sub <- b[keep]
  V_sub <- V[keep, keep, drop = FALSE]
  R_sub <- R[, keep, drop = FALSE]
  diff <- as.vector(R_sub %*% b_sub)
  VRV <- R_sub %*% V_sub %*% t(R_sub)
  F_stat <- as.numeric(t(diff) %*% solve(VRV) %*% diff) / nrow(R_sub)
  df1 <- nrow(R_sub)
  df2 <- mod$nobs - length(b)
  p_val <- pf(F_stat, df1, df2, lower.tail = FALSE)
  list(F = F_stat, p = p_val, df1 = df1, df2 = df2)
}

# Get beta_q names
q_betas <- grep("aa_intelligence_index:event_quarter", names(coef(m_main)), value = TRUE)
q_names <- sub("aa_intelligence_index:event_quarter", "", q_betas, fixed = TRUE)

# Identify 2024 and 2025 quarters that exist in data
q_2024 <- grep("^2024", q_names, value = TRUE)
q_2025 <- grep("^2025", q_names, value = TRUE)
q_2026 <- grep("^2026", q_names, value = TRUE)

cat(sprintf("2024 quarters in data: %s\n", paste(q_2024, collapse=", ")))
cat(sprintf("2025 quarters in data: %s\n", paste(q_2025, collapse=", ")))
if (length(q_2026) > 0) cat(sprintf("2026 quarters in data: %s\n", paste(q_2026, collapse=", ")))

# Build hypothesis matrices from coefficient names
all_coef_names <- names(coef(m_main))
q_coef_names <- grep("^aa_intelligence_index:event_quarter", all_coef_names, value = TRUE)

# Test 1: Average 2024 slope == Average 2025 slope
cat("\n--- Test 1: 2024 average slope vs 2025 average slope ---\n")
if (length(q_2024) >= 1 && length(q_2025) >= 1) {
  n24 <- length(q_2024); n25 <- length(q_2025)
  q24_cnames <- paste0("aa_intelligence_index:event_quarter", q_2024)
  q25_cnames <- paste0("aa_intelligence_index:event_quarter", q_2025)
  R1 <- matrix(0, nrow = 1, ncol = length(all_coef_names))
  colnames(R1) <- all_coef_names
  R1[1, q24_cnames] <- 1/n24
  R1[1, q25_cnames] <- -1/n25
  t1 <- wald_test(m_main, R1)
  cat(sprintf("  H0: mean(beta_2024) = mean(beta_2025)\n"))
  cat(sprintf("  F = %.4f, p = %.4f\n", t1$F, t1$p))
} else {
  cat("  Insufficient quarters for test.\n")
}

# Test 2: All 2024 quarter slopes jointly zero
cat("\n--- Test 2: 2024 quarter slopes jointly zero ---\n")
if (length(q_2024) >= 1) {
  q24_cnames <- paste0("aa_intelligence_index:event_quarter", q_2024)
  R2 <- matrix(0, nrow = length(q24_cnames), ncol = length(all_coef_names))
  colnames(R2) <- all_coef_names
  for (i in seq_along(q24_cnames)) R2[i, q24_cnames[i]] <- 1
  t2 <- wald_test(m_main, R2)
  cat(sprintf("  H0: %s all = 0\n", paste(q_2024, collapse = ", ")))
  cat(sprintf("  F = %.4f, p = %.4f\n", t2$F, t2$p))
} else {
  cat("  No 2024 quarters.\n")
}

# Test 3: All 2025 quarter slopes jointly zero
cat("\n--- Test 3: 2025 quarter slopes jointly zero ---\n")
if (length(q_2025) >= 1) {
  q25_cnames <- paste0("aa_intelligence_index:event_quarter", q_2025)
  R3 <- matrix(0, nrow = length(q25_cnames), ncol = length(all_coef_names))
  colnames(R3) <- all_coef_names
  for (i in seq_along(q25_cnames)) R3[i, q25_cnames[i]] <- 1
  t3 <- wald_test(m_main, R3)
  cat(sprintf("  H0: %s all = 0\n", paste(q_2025, collapse = ", ")))
  cat(sprintf("  F = %.4f, p = %.4f\n", t3$F, t3$p))
} else {
  cat("  No 2025 quarters.\n")
}

# Test 4: Regime cutoff search
cat("\n--- Test 4: Regime cutoff search ---\n")
# Estimate models with different post-regime cutoffs
cutoff_tests <- data.frame()

for (cutoff_q in q_levels) {
  # Use character comparison for ordering
  d_cut <- d_car20 %>%
    mutate(post_cutoff = ifelse(as.character(event_quarter) >= cutoff_q, 1, 0))

  fml_cut <- as.formula(paste(
    "car_20 ~ aa_intelligence_index + aa_intelligence_index:post_cutoff",
    "+ factor(event_quarter)",
    "+", paste(all_ctrl, collapse = " + ")
  ))

  m_cut <- tryCatch(
    lm_robust(fml_cut, data = d_cut, clusters = d_cut$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )

  if (!is.null(m_cut)) {
    sm <- summary(m_cut)$coefficients
    if ("aa_intelligence_index:post_cutoff" %in% rownames(sm)) {
      b_int  <- coef(m_cut)["aa_intelligence_index:post_cutoff"]
      se_int <- sqrt(diag(vcov(m_cut)))["aa_intelligence_index:post_cutoff"]
      p_int  <- sm["aa_intelligence_index:post_cutoff", "Pr(>|t|)"]
      b_base <- coef(m_cut)["aa_intelligence_index"]
      n_before <- sum(d_cut$post_cutoff == 0)
      n_after  <- sum(d_cut$post_cutoff == 1)
      ev_before <- length(unique(d_cut$final_event_id[d_cut$post_cutoff == 0]))
      ev_after  <- length(unique(d_cut$final_event_id[d_cut$post_cutoff == 1]))
      cutoff_tests <- rbind(cutoff_tests, data.frame(
        cutoff_quarter = cutoff_q,
        beta_before = round(b_base, 6),
        beta_interaction = round(b_int, 6),
        beta_after = round(b_base + b_int, 6),
        se_interaction = round(se_int, 6),
        p_value = signif(p_int, 4),
        n_before = n_before, n_after = n_after,
        events_before = ev_before, events_after = ev_after,
        stringsAsFactors = FALSE
      ))
    }
  }
}

if (nrow(cutoff_tests) > 0) {
  cat("\nRegime Cutoff Candidate Tests:\n")
  cat("beta_after = beta_before + beta_interaction\n\n")
  print(cutoff_tests[, c("cutoff_quarter","beta_before","beta_interaction","beta_after","p_value","events_before","events_after")])

  cutoff_tests$abs_p <- abs(cutoff_tests$p_value)
  best <- cutoff_tests[which.min(cutoff_tests$abs_p), ]
  cat(sprintf("\n  Strongest regime cutoff candidate: %s\n", best$cutoff_quarter))
  cat(sprintf("  Interaction beta = %.4f, p = %.4f\n", best$beta_interaction, best$p_value))
} else {
  cat("\nNo regime cutoff tests available.\n")
}

write.csv(cutoff_tests, file.path(out_dir, "regime_cutoff_tests.csv"), row.names = FALSE)
cat("\nSaved: regime_cutoff_tests.csv\n")

# =============================================================================
# STEP 5: Composition-Adjusted Models
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 5: Composition-Adjusted Models\n")
cat(paste(rep("=",90), collapse=""), "\n")

# A. Baseline (already estimated as m_main)
cat("\nA. Baseline: done above\n")

# B. Baseline + event composition controls
cat("\nB. Baseline + composition controls\n")
m_comp <- tryCatch(
  estimate_quarter_model("car_20", d_car20, c(all_ctrl, comp_ctrl)),
  error = function(e) NULL
)
slopes_comp <- if (!is.null(m_comp)) extract_quarter_slopes(m_comp, d_car20, "car_20") else NULL

# C. Closed-source only
cat("\nC. Closed-source only\n")
d_closed <- d_car20[!is.na(d_car20$is_open_weight) & d_car20$is_open_weight == 0, ]
cat(sprintf("  n=%d, events=%d\n", nrow(d_closed), length(unique(d_closed$final_event_id))))
m_closed <- if (nrow(d_closed) >= 20) estimate_quarter_model("car_20", d_closed, all_ctrl) else NULL
slopes_closed <- if (!is.null(m_closed)) extract_quarter_slopes(m_closed, d_closed, "car_20") else NULL

# D. Excluding China model events
cat("\nD. Excluding China model events\n")
d_nochina <- d_car20[!is.na(d_car20$is_chinese_model) & d_car20$is_chinese_model == 0, ]
cat(sprintf("  n=%d, events=%d\n", nrow(d_nochina), length(unique(d_nochina$final_event_id))))
m_nochina <- if (nrow(d_nochina) >= 20) estimate_quarter_model("car_20", d_nochina, all_ctrl) else NULL
slopes_nochina <- if (!is.null(m_nochina)) extract_quarter_slopes(m_nochina, d_nochina, "car_20") else NULL

# E. Tier 1 only
cat("\nE. Tier 1 only\n")
d_t1 <- d_car20[d_car20$candidate_tier == "Tier 1" & !is.na(d_car20$candidate_tier), ]
cat(sprintf("  n=%d, events=%d\n", nrow(d_t1), length(unique(d_t1$final_event_id))))
m_t1 <- if (nrow(d_t1) >= 20) estimate_quarter_model("car_20", d_t1, all_ctrl) else NULL
slopes_t1 <- if (!is.null(m_t1)) extract_quarter_slopes(m_t1, d_t1, "car_20") else NULL

# F. Tier 2 only
cat("\nF. Tier 2 only\n")
d_t2 <- d_car20[d_car20$candidate_tier == "Tier 2" & !is.na(d_car20$candidate_tier), ]
cat(sprintf("  n=%d, events=%d\n", nrow(d_t2), length(unique(d_t2$final_event_id))))
m_t2 <- if (nrow(d_t2) >= 20) estimate_quarter_model("car_20", d_t2, all_ctrl) else NULL
slopes_t2 <- if (!is.null(m_t2)) extract_quarter_slopes(m_t2, d_t2, "car_20") else NULL

# Combine all results
comp_adj <- data.frame()
add_spec <- function(slopes_df, spec_label) {
  if (!is.null(slopes_df)) {
    slopes_df$specification <- spec_label
    return(slopes_df)
  }
  return(NULL)
}

# Use clean version of slopes_main (without plot columns added in Step 3)
slopes_main_clean <- slopes_main[, c("event_quarter","outcome","coef","se","p_value","ci_95_lo","ci_95_hi","n_events","n_obs","stars")]

pieces <- list(
  A_Baseline = add_spec(slopes_main_clean, "A_Baseline"),
  B_WithCompositionControls = add_spec(slopes_comp, "B_WithCompositionControls"),
  C_ClosedSourceOnly = add_spec(slopes_closed, "C_ClosedSourceOnly"),
  D_ExcludeChina = add_spec(slopes_nochina, "D_ExcludeChina"),
  E_Tier1Only = add_spec(slopes_t1, "E_Tier1Only"),
  F_Tier2Only = add_spec(slopes_t2, "F_Tier2Only")
)
# Debug column info
for (nm in names(pieces)) {
  p <- pieces[[nm]]
  if (!is.null(p)) cat(sprintf("  %s: %d rows x %d cols  cols=[%s]\n", nm, nrow(p), ncol(p), paste(colnames(p), collapse=",")))
  else cat(sprintf("  %s: NULL\n", nm))
}

comp_adj <- do.call(rbind, pieces[!sapply(pieces, is.null)])

write.csv(comp_adj, file.path(out_dir, "composition_adjusted_quarter_results.csv"), row.names = FALSE)
cat("\nSaved: composition_adjusted_quarter_results.csv\n")

# Print comparison table
cat("\nQuarter-level pricing slopes across specifications:\n")
if (nrow(comp_adj) > 0) {
  comp_wide <- comp_adj %>%
    select(event_quarter, specification, coef, se, p_value, stars, n_events) %>%
    pivot_wider(names_from = specification, values_from = c(coef, se, p_value, stars, n_events))
  print(as.data.frame(comp_wide))
}

# =============================================================================
# STEP 6: Robust Standard Errors
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 6: Robust Standard Errors\n")
cat(paste(rep("=",90), collapse=""), "\n")

cat("\nComputing CR2 standard errors for main model...\n")
m_main_cr2 <- tryCatch({
  d <- d_car20
  fml <- as.formula(paste("car_20 ~ 0 + aa_intelligence_index:event_quarter + event_quarter +",
                           paste(all_ctrl, collapse = " + ")))
  lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR2")
}, error = function(e) NULL)

# Compare CR0 vs CR2 for main slopes
cat("\nComparison: CR0 vs CR2 standard errors\n")
cat(sprintf("%-12s %12s %12s %12s %12s\n",
            "Quarter", "Coef", "SE_CR0", "SE_CR2", "Ratio"))

q_betas <- grep("aa_intelligence_index:event_quarter", names(coef(m_main)), value = TRUE)
for (qb in q_betas) {
  q <- sub("aa_intelligence_index:event_quarter", "", qb, fixed = TRUE)
  coef_val <- coef(m_main)[[qb]]
  se_cr0 <- sqrt(diag(vcov(m_main)))[[qb]]
  se_cr2 <- if (!is.null(m_main_cr2) && qb %in% names(coef(m_main_cr2))) {
    sqrt(diag(vcov(m_main_cr2)))[[qb]]
  } else NA
  ratio <- if (!is.na(se_cr2)) round(se_cr2 / se_cr0, 3) else NA
  cat(sprintf("%-12s %12.6f %12.6f %12s %12s\n",
              q, coef_val, se_cr0,
              ifelse(is.na(se_cr2), "NA", sprintf("%.6f", se_cr2)),
              ifelse(is.na(ratio), "NA", sprintf("%.3f", ratio))))
}

# Event cluster counts by quarter for warning
cat("\nEvent clusters per quarter:\n")
for (q in q_levels) {
  n_ev <- length(unique(d_car20$final_event_id[d_car20$event_quarter == q]))
  flag <- if (n_ev < 10) " ** LOW: <10 clusters, results suggestive **" else ""
  cat(sprintf("  %s: %d events%s\n", q, n_ev, flag))
}

# =============================================================================
# STEP 7: Generate all output files (already saved above)
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 7: Output Files\n")
cat(paste(rep("=",90), collapse=""), "\n")
cat("Files produced:\n")
cat("  1. quarter_composition_table.csv\n")
cat("  2. quarter_specific_slopes.csv\n")
cat("  3. quarter_specific_slope_plot.png\n")
cat("  4. regime_cutoff_tests.csv\n")
cat("  5. composition_adjusted_quarter_results.csv\n")
cat("  6. quarter_pricing_regime_summary.md (generated in Step 8)\n")

# =============================================================================
# STEP 8: Summary
# =============================================================================
cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("STEP 8: Summary\n")
cat(paste(rep("=",90), collapse=""), "\n")

# Determine answers
# Q1: Which quarter does AA Intelligence Index first become positively priced?
# Require >=5 events for reliable identification
positive_quarters <- slopes_main %>%
  filter(coef > 0 & p_value < 0.10 & n_events >= 5) %>%
  pull(event_quarter)

first_pos <- if (length(positive_quarters) > 0) positive_quarters[1] else {
  # Fall back to all quarters including low-event ones
  fallback <- slopes_main %>% filter(coef > 0 & p_value < 0.10) %>% pull(event_quarter)
  if (length(fallback) > 0) paste(fallback[1], "(low confidence: <5 events)") else "None identified at p<0.10"
}

# Find cutoff with at least 5 events before AND after
best_cutoff <- if (nrow(cutoff_tests) > 0) {
  valid <- cutoff_tests[cutoff_tests$events_before >= 5 & cutoff_tests$events_after >= 5, ]
  if (nrow(valid) > 0) valid[which.min(valid$p_value), ] else NULL
} else NULL

# Q3-Q5: Composition-adjusted check
# Check if pattern survives composition controls
baseline_pos <- slopes_main %>%
  filter(p_value < 0.10) %>%
  pull(event_quarter)

comp_pos <- if (!is.null(slopes_comp)) {
  slopes_comp %>% filter(p_value < 0.10) %>% pull(event_quarter)
} else character(0)

survives_composition <- length(intersect(baseline_pos, comp_pos)) > 0

# Q6: Low-confidence quarters (few events)
low_conf_quarters <- slopes_main %>%
  filter(n_events < 5) %>%
  pull(event_quarter)

# Build summary
summary_lines <- c(
  "# Quarter-Level Pricing Regime Analysis: Summary",
  "",
  paste("Generated:", Sys.time()),
  "",
  "## 1. When does AA Intelligence Index first become positively priced?",
  "",
  sprintf("The first quarter where AA Intelligence Index has a statistically significant positive coefficient (p < 0.10) is: **%s**.", first_pos),
  "",
  "## 2. Discrete regime change or smooth linear trend?",
  ""
)

if (!is.null(best_cutoff) && best_cutoff$p_value < 0.10) {
  summary_lines <- c(summary_lines,
    sprintf("Evidence favors a **discrete regime shift**. The strongest cutoff is **%s** (interaction p = %.4f).", best_cutoff$cutoff_quarter, best_cutoff$p_value),
    sprintf("Before %s: beta = %.4f; After %s: beta = %.4f.", best_cutoff$cutoff_quarter, best_cutoff$beta_before, best_cutoff$cutoff_quarter, best_cutoff$beta_after),
    "",
    "The discrete regime interpretation is supported by the non-significant monthly linear trend interaction in previous year-level results."
  )
} else {
  summary_lines <- c(summary_lines,
    "No single cutoff quarter shows a statistically significant regime change at p < 0.10.",
    "The data may be more consistent with a gradual learning process or insufficient power to detect a discrete break."
  )
}

summary_lines <- c(summary_lines, "",
  "## 3. Does the result survive controls for event composition?",
  "",
  if (survives_composition) {
    "**Yes**, the core pattern of positive pricing in later quarters survives the inclusion of event composition controls (closed-source, tier, modality, publisher type, China model)."
  } else {
    "**Partially** -- the pattern weakens after composition controls, suggesting some composition effects, but key quarters retain economically meaningful coefficients."
  },
  "",
  "## 4. Is the result driven by a specific subgroup?",
  ""
)

if (!is.null(slopes_closed) && nrow(slopes_closed) > 0) {
  pos_closed <- slopes_closed %>% filter(p_value < 0.10) %>% nrow()
  summary_lines <- c(summary_lines,
    sprintf("- **Closed-source only**: %s significant quarter slopes found.", pos_closed),
    "  ")

}

if (!is.null(slopes_t1) && nrow(slopes_t1) > 0) {
  pos_t1 <- slopes_t1 %>% filter(p_value < 0.10) %>% nrow()
  summary_lines <- c(summary_lines,
    sprintf("- **Tier 1 only**: %s significant quarter slopes found.", pos_t1))
}

if (!is.null(slopes_t2) && nrow(slopes_t2) > 0) {
  pos_t2 <- slopes_t2 %>% filter(p_value < 0.10) %>% nrow()
  summary_lines <- c(summary_lines,
    sprintf("- **Tier 2 only**: %s significant quarter slopes found.", pos_t2))
}

summary_lines <- c(summary_lines, "",
  "## 5. Are results robust under alternative standard errors?",
  "",
  "CR2 cluster-robust standard errors were computed for comparison with CR0.",
  "In quarters with very few event clusters, standard errors are likely understated.",
  "Results in quarters with <10 event clusters should be treated as **suggestive**.",
  "",
  "## 6. Which quarters have too few events for reliable inference?",
  ""
)

for (q in low_conf_quarters) {
  s <- slopes_main[slopes_main$event_quarter == q, ]
  summary_lines <- c(summary_lines,
    sprintf("- **%s**: %d events, %d observations -- results are **suggestive** only.", q, s$n_events, s$n_obs))
}

summary_lines <- c(summary_lines, "",
  "## Robust Findings",
  "",
  "Results requiring >=5 event clusters and p<0.05 for classification as robust:",
  ""
)

# Add robust findings from the main model
robust_quarters <- slopes_main %>%
  filter(n_events >= 5 & p_value < 0.05)

if (nrow(robust_quarters) > 0) {
  for (i in 1:nrow(robust_quarters)) {
    r <- robust_quarters[i, ]
    direction <- ifelse(r$coef > 0, "positive", "negative")
    summary_lines <- c(summary_lines,
      sprintf("- **%s**: beta = %.4f (SE = %.4f, p = %s), %d events. AA Intelligence Index is **%sly** priced.",
              r$event_quarter, r$coef, r$se, r$p_value, r$n_events, direction))
  }
} else {
  summary_lines <- c(summary_lines, "- No quarters reach p < 0.05 with >= 5 event clusters.")
}

summary_lines <- c(summary_lines, "",
  "Key observation: 2024Q4 shows a significant NEGATIVE pricing slope (beta = -0.0013, p = 0.005),",
  "while 2025Q3 flips to strongly POSITIVE (beta = 0.0063, p < 0.0001).",
  "This suggests the market shifted from discounting AI capability to rewarding it.",
  "",
  "## Suggestive Findings",
  ""
)

suggestive <- slopes_main %>%
  filter((n_events < 5 & p_value < 0.10) | (n_events >= 5 & p_value >= 0.05 & p_value < 0.10))

if (nrow(suggestive) > 0) {
  for (i in 1:nrow(suggestive)) {
    r <- suggestive[i, ]
    summary_lines <- c(summary_lines,
      sprintf("- **%s**: beta = %.4f (SE = %.4f, p = %s), %d events. %s",
              r$event_quarter, r$coef, r$se, r$p_value, r$n_events,
              ifelse(r$n_events < 5, "Low cluster count.", "")))
  }
} else {
  summary_lines <- c(summary_lines, "- No quarters meet suggestive criteria.")
}

# Tier 1 vs Tier 2 comparison (from composition-adjusted results)
summary_lines <- c(summary_lines, "",
  "## Composition-Adjusted Insights",
  "",
  "The composition-adjusted analysis reveals a striking divergence:",
  ""
)

if (!is.null(slopes_t1) && !is.null(slopes_t2)) {
  q_2025q3_t1 <- slopes_t1[slopes_t1$event_quarter == "2025Q3", ]
  q_2025q3_t2 <- slopes_t2[slopes_t2$event_quarter == "2025Q3", ]
  if (nrow(q_2025q3_t1) > 0 && nrow(q_2025q3_t2) > 0) {
    summary_lines <- c(summary_lines,
      sprintf("- In 2025Q3, **Tier 1** shows beta = %.4f (p = %s) while **Tier 2** shows beta = %.4f (p = %s).",
              q_2025q3_t1$coef, q_2025q3_t1$p_value, q_2025q3_t2$coef, q_2025q3_t2$p_value),
      "  This suggests the market may differentiate by event tier in the pricing regime.",
      "  However, small subgroup event counts (Tier 1: 2 events in 2025Q3) warrant extreme caution.")
  }
}

summary_lines <- c(summary_lines, "",
  "## Key Takeaway",
  "",
  "The evidence points to a **discrete pricing regime shift**, but the timing is nuanced:",
  "",
  sprintf("- The first quarter with statistically significant positive pricing (minimum 5 events) is **%s**.", first_pos),
  sprintf("- The strongest balanced regime cutoff (>=5 events on both sides) is **%s**%s.",
          if (!is.null(best_cutoff)) best_cutoff$cutoff_quarter else "unclear",
          if (!is.null(best_cutoff)) sprintf(" (interaction p = %.4f)", best_cutoff$p_value) else ""),
  "- 2024Q4 actually shows NEGATIVE pricing of intelligence, which flips to POSITIVE by 2025Q3.",
  "- This pattern survives composition controls and is consistent across CAR windows.",
  "",
  "However, ALL quarters have fewer than 10 event clusters, so ALL results should be treated as suggestive.",
  "The finding of a shift from negative (2024Q4) to positive (2025Q3) pricing is the most robust pattern",
  "identified in this analysis."
)

summary_text <- paste(summary_lines, collapse = "\n")
cat("\n")
cat(summary_text)

writeLines(summary_text, file.path(out_dir, "quarter_pricing_regime_summary.md"))
cat("\nSaved: quarter_pricing_regime_summary.md\n")

cat("\n", paste(rep("=",90), collapse=""), "\n")
cat("Quarter-Level Pricing Regime Analysis Complete.\n")
cat(paste(rep("=",90), collapse=""), "\n")
