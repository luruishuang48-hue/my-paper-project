#!/usr/bin/env Rscript
# =============================================================================
# r5_wild_bootstrap_core_tables.R
# Agent R5: Wild cluster bootstrap (+ CR2) supplement for Table 1-4 core
# coefficients in Tex/long.tex, car_20 window only.
#
# Groups:
#   A - baseline single-position regressions (6 position vars, one at a time)
#   B - bundle regressions (upstream_any, downstream_any, sole regressor)
#   C - joint regression (all 6 position vars simultaneously)
#   D - open/closed interaction (upstream_hardware, downstream_deployer)
#
# CR2 and wild_boot_p() functions are copied verbatim from
# scripts/analysis/core_table.R (lines ~62-111), per task instructions.
# =============================================================================

suppressPackageStartupMessages({
  library(estimatr)
})

set.seed(42)

# ─── Load data ───────────────────────────────────────────────────────────────
input_file <- "data/panel/specr_rel_clean.csv"
df <- read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE)

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year", "car_20",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "is_open_weight", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

# NA -> 0 fill for relationship (new-schema) vars, matching
# paper_plan_core_outputs.R convention exactly.
for (col in rel_vars) {
  if (!col %in% names(df)) stop(paste("Missing relationship variable:", col))
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

df$upstream_any <- as.integer(df$upstream_hardware == 1 | df$upstream_cloud == 1)
df$downstream_any <- as.integer(
  df$downstream_integrator == 1 |
    df$downstream_deployer == 1 |
    df$downstream_enabler == 1
)

ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")

# ─── SE helpers: copied verbatim from scripts/analysis/core_table.R ─────────

refit_cr2 <- function(data, fml, var) {
  tryCatch({
    m <- lm_robust(fml, data = data, clusters = data$final_event_id, se_type = "CR2")
    as.numeric(summary(m)$coefficients[var, "Pr(>|t|)"])
  }, error = function(e) NA_real_)
}

# Wild cluster bootstrap: impose null on `var`
wild_boot_p <- function(data, fml_full, fml_restr, var, B = 4999, seed = 42) {
  d <- data
  # Drop rows missing outcome
  y_var <- all.vars(fml_full)[1]
  d <- d[!is.na(d[[y_var]]), ]

  n_cl <- length(unique(d$final_event_id))
  if (n_cl < 5) return(NA_real_)

  # Observed t-stat (CR0)
  tryCatch({
    mod_obs  <- lm_robust(fml_full, data = d, clusters = d$final_event_id, se_type = "CR0")
    b_obs    <- coef(mod_obs)[[var]]
    se_obs   <- sqrt(diag(vcov(mod_obs)))[[var]]
    t_obs    <- b_obs / se_obs

    # Restricted model (impose null): residuals
    mod_r  <- lm(fml_restr, data = d)
    e_hat  <- residuals(mod_r)
    y_hat  <- fitted(mod_r)

    cl_ids <- d$final_event_id
    ucl    <- unique(cl_ids)
    G      <- length(ucl)

    set.seed(seed)
    t_star <- numeric(B)
    for (b in seq_len(B)) {
      g <- sample(c(-1L, 1L), G, replace = TRUE)
      names(g) <- ucl
      e_b      <- e_hat * g[as.character(cl_ids)]
      d_b      <- d
      d_b[[y_var]] <- y_hat + e_b
      tryCatch({
        m_b       <- lm_robust(fml_full, data = d_b, clusters = d_b$final_event_id, se_type = "CR0")
        t_star[b] <- coef(m_b)[[var]] / sqrt(diag(vcov(m_b)))[[var]]
      }, error = function(e) { t_star[b] <<- NA_real_ })
    }
    t_star <- t_star[!is.na(t_star)]
    mean(abs(t_star) >= abs(t_obs))
  }, error = function(e) NA_real_)
}

# ─── Generic runner: fit CR0 model, then CR2 + wild boot for one var ────────

run_one_coef <- function(data, fml_full, fml_restr, var, table_source, outcome = "car_20") {
  y_var <- all.vars(fml_full)[1]
  d <- data[!is.na(data[[y_var]]), ]
  # restrict to complete cases on the full formula's RHS as well (lm_robust
  # will drop NAs internally, but we want consistent n/n_events reporting)
  mod <- lm_robust(fml_full, data = d, clusters = d$final_event_id, se_type = "CR0")
  used_n <- nobs(mod)
  # n_events: unique clusters actually used by the fitted model
  # lm_robust stores the used data row count but not directly the cluster ids
  # post-NA-drop on covariates; reconstruct via model.frame
  mf <- model.frame(fml_full, data = d, na.action = na.omit)
  n_events <- length(unique(d[rownames(mf), "final_event_id"]))

  beta <- coef(mod)[[var]]
  se   <- sqrt(diag(vcov(mod)))[[var]]
  p_cr0 <- as.numeric(summary(mod)$coefficients[var, "Pr(>|t|)"])
  p_cr2 <- refit_cr2(d, fml_full, var)
  p_wild <- wild_boot_p(d, fml_full, fml_restr, var, B = 4999, seed = 42)

  data.frame(
    table_source = table_source,
    variable = var,
    outcome = outcome,
    beta = beta,
    se = se,
    p_cr0 = p_cr0,
    p_cr2 = p_cr2,
    p_wild = p_wild,
    n = used_n,
    n_events = n_events,
    stringsAsFactors = FALSE
  )
}

results <- list()
idx <- 1

cat("=== Group A: baseline single-position regressions (car_20) ===\n")
position_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor"
)

for (v in position_vars) {
  cat(sprintf("  [A] %s ...\n", v))
  fml_full  <- as.formula(paste("car_20 ~", v, "+", paste(ctrl, collapse = " + "), "+ factor(release_year)"))
  fml_restr <- as.formula(paste("car_20 ~", paste(ctrl, collapse = " + "), "+ factor(release_year)"))
  res <- run_one_coef(df, fml_full, fml_restr, v, table_source = "baseline_single")
  print(res)
  results[[idx]] <- res
  idx <- idx + 1
}

cat("=== Group B: bundle regressions (car_20) ===\n")
bundle_vars <- c("upstream_any", "downstream_any")
for (v in bundle_vars) {
  cat(sprintf("  [B] %s ...\n", v))
  fml_full  <- as.formula(paste("car_20 ~", v, "+", paste(ctrl, collapse = " + "), "+ factor(release_year)"))
  fml_restr <- as.formula(paste("car_20 ~", paste(ctrl, collapse = " + "), "+ factor(release_year)"))
  res <- run_one_coef(df, fml_full, fml_restr, v, table_source = "bundle")
  print(res)
  results[[idx]] <- res
  idx <- idx + 1
}

cat("=== Group C: joint regression, all 6 position vars (car_20) ===\n")
fml_joint_full <- as.formula(paste(
  "car_20 ~", paste(position_vars, collapse = " + "), "+",
  paste(ctrl, collapse = " + "), "+ factor(release_year)"
))
for (v in position_vars) {
  cat(sprintf("  [C] joint, var = %s ...\n", v))
  other_vars <- setdiff(position_vars, v)
  fml_restr <- as.formula(paste(
    "car_20 ~", paste(other_vars, collapse = " + "), "+",
    paste(ctrl, collapse = " + "), "+ factor(release_year)"
  ))
  res <- run_one_coef(df, fml_joint_full, fml_restr, v, table_source = "joint")
  print(res)
  results[[idx]] <- res
  idx <- idx + 1
}

cat("=== Group D: open/closed interaction (car_20) ===\n")
interaction_vars <- c("upstream_hardware", "downstream_deployer")
for (v in interaction_vars) {
  cat(sprintf("  [D] %s x is_open_weight ...\n", v))
  inter_term <- paste0(v, ":is_open_weight")
  fml_full <- as.formula(paste(
    "car_20 ~", v, "* is_open_weight +",
    paste(ctrl, collapse = " + "), "+ factor(release_year)"
  ))
  # Restricted model: drop interaction term, keep main effects of v and is_open_weight
  fml_restr <- as.formula(paste(
    "car_20 ~", v, "+ is_open_weight +",
    paste(ctrl, collapse = " + "), "+ factor(release_year)"
  ))
  res <- run_one_coef(df, fml_full, fml_restr, inter_term, table_source = "open_interaction")
  print(res)
  results[[idx]] <- res
  idx <- idx + 1
}

final_df <- do.call(rbind, results)
print(final_df)

out_csv <- "agent_tasks/paper_b_robustness_2026062514/outputs/r5_wild_bootstrap_table1to4.csv"
write.csv(final_df, out_csv, row.names = FALSE)
cat(sprintf("\nSaved: %s\n", out_csv))
