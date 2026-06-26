#!/usr/bin/env Rscript
# =============================================================================
# r2_downstream_deployer_dedicated.R
#
# Agent R2 — downstream_deployer dedicated robustness regressions.
#
# downstream_deployer (NEW 8-dim relationship schema) as the SOLE relationship
# regressor, run separately for each CAR window: car_1, car_2, car_3, car_5,
# car_10, car_15, car_20.
#
# For each window:
#   1. CR0 cluster-robust SE (estimatr::lm_robust, clusters = final_event_id)
#   2. CR2 cluster-robust p-value (refit_cr2(), copied from core_table.R)
#   3. Wild cluster bootstrap p-value (wild_boot_p(), copied verbatim from
#      core_table.R lines ~69-111), restricted model = same formula without
#      downstream_deployer, B = 4999, seed = 42, Rademacher weights.
#
# Data: data/panel/specr_rel_clean.csv (new 8-dim columns only; old schema
# columns owner/investor/cloud/real_upstream/business_upstream/
# real_downstream/business_downstream are present in the file but NOT used
# here).
# =============================================================================

suppressPackageStartupMessages({
  library(estimatr)
})

# ─── Paths (robust to cwd) ──────────────────────────────────────────────────
find_repo_root <- function() {
  # Walk up from this script's directory until we find data/panel/specr_rel_clean.csv
  d <- normalizePath(getwd())
  for (i in 1:6) {
    cand <- file.path(d, "data/panel/specr_rel_clean.csv")
    if (file.exists(cand)) return(d)
    d <- dirname(d)
  }
  stop("Could not locate repo root containing data/panel/specr_rel_clean.csv")
}
repo_root <- find_repo_root()
data_path <- file.path(repo_root, "data/panel/specr_rel_clean.csv")
out_dir   <- file.path(repo_root, "agent_tasks/paper_b_robustness_2026062514/outputs")
log_dir   <- file.path(repo_root, "agent_tasks/paper_b_robustness_2026062514/logs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)

cat(sprintf("Repo root: %s\n", repo_root))
cat(sprintf("Data path: %s\n", data_path))

# ─── Load data ──────────────────────────────────────────────────────────────
df <- read.csv(data_path, stringsAsFactors = FALSE, check.names = FALSE)
cat(sprintf("Loaded data: %d rows, %d cols\n", nrow(df), ncol(df)))

windows <- c("car_1","car_2","car_3","car_5","car_10","car_15","car_20")
stopifnot(all(windows %in% names(df)))
stopifnot("downstream_deployer" %in% names(df))

num_cols <- c(windows, "downstream_deployer", "size_log_assets", "bm_ratio",
              "volatility", "momentum", "release_year")
for (col in num_cols) if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])

ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")

make_fml_full  <- function(y) {
  as.formula(paste(y, "~ downstream_deployer +", paste(ctrl, collapse = " + "),
                    "+ factor(release_year)"))
}
make_fml_restr <- function(y) {
  as.formula(paste(y, "~", paste(ctrl, collapse = " + "), "+ factor(release_year)"))
}

# ─── refit_cr2(): copied from scripts/analysis/core_table.R lines 62-67 ────
refit_cr2 <- function(data, fml, var) {
  tryCatch({
    m <- lm_robust(fml, data = data, clusters = data$final_event_id, se_type = "CR2")
    as.numeric(summary(m)$coefficients[var, "Pr(>|t|)"])
  }, error = function(e) NA_real_)
}

# ─── wild_boot_p(): copied verbatim from scripts/analysis/core_table.R
#     lines ~69-111 (Rademacher wild cluster bootstrap, impose-null) ───────
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

# ─── Run for all windows ────────────────────────────────────────────────────
results <- list()

for (y in windows) {
  cat(sprintf("\n%s\n", strrep("=", 70)))
  cat(sprintf("Window: %s\n", y))
  cat(strrep("=", 70), "\n")

  fml_full  <- make_fml_full(y)
  fml_restr <- make_fml_restr(y)

  needed <- c(y, "downstream_deployer", ctrl)
  keep <- complete.cases(df[, needed])
  d_sub <- df[keep, ]

  n_obs    <- nrow(d_sub)
  n_events <- length(unique(d_sub$final_event_id))

  cat(sprintf("n = %d, n_events = %d\n", n_obs, n_events))

  mod_cr0 <- tryCatch(
    lm_robust(fml_full, data = d_sub, clusters = d_sub$final_event_id, se_type = "CR0"),
    error = function(e) { cat("CR0 model failed:", conditionMessage(e), "\n"); NULL }
  )

  if (is.null(mod_cr0)) {
    beta <- NA_real_; se <- NA_real_; p_cr0 <- NA_real_
  } else {
    beta  <- coef(mod_cr0)[["downstream_deployer"]]
    se    <- sqrt(diag(vcov(mod_cr0)))[["downstream_deployer"]]
    p_cr0 <- as.numeric(summary(mod_cr0)$coefficients["downstream_deployer", "Pr(>|t|)"])
  }

  cat(sprintf("CR0:  beta = %.6f, se = %.6f, p = %.4f\n", beta, se, p_cr0))

  p_cr2 <- refit_cr2(d_sub, fml_full, "downstream_deployer")
  cat(sprintf("CR2:  p = %.4f\n", p_cr2))

  cat("Running wild cluster bootstrap (B=4999)...\n")
  t0 <- Sys.time()
  p_wild <- wild_boot_p(d_sub, fml_full, fml_restr, "downstream_deployer", B = 4999, seed = 42)
  t1 <- Sys.time()
  cat(sprintf("Wild bootstrap: p = %.4f  (elapsed %.1f sec)\n", p_wild, as.numeric(t1 - t0, units = "secs")))

  results[[y]] <- data.frame(
    outcome   = y,
    beta      = beta,
    se        = se,
    n         = n_obs,
    n_events  = n_events,
    p_cr0     = p_cr0,
    p_cr2     = p_cr2,
    p_wild    = p_wild,
    stringsAsFactors = FALSE
  )
}

res_df <- do.call(rbind, results)
rownames(res_df) <- NULL

cat("\n\n", strrep("=", 70), "\n")
cat("FINAL RESULTS TABLE\n")
cat(strrep("=", 70), "\n")
print(res_df, digits = 6)

out_csv <- file.path(out_dir, "r2_downstream_deployer_robustness.csv")
write.csv(res_df, out_csv, row.names = FALSE)
cat(sprintf("\nSaved: %s\n", out_csv))
