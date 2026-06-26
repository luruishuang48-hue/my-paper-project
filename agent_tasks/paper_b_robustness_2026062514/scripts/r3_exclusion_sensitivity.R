# R3: Exclusion sensitivity for the two headline ecosystem-position findings
#   (1) upstream_hardware  -> positive CAR[0,+20]
#   (2) downstream_deployer -> negative CAR[0,+20]
#
# Checks:
#   1. Exclude DeepSeek R1 (final_event_id == "FMR-0021") and re-estimate
#   2. Leave-one-event-out across all final_event_id values
#   3. Leave-one-firm-out across all company_id values (clean ticker identifiers)
#
# Baseline spec: car_20 ~ position_var + size_log_assets + bm_ratio + volatility +
#                momentum + factor(release_year), clusters = final_event_id, CR0

suppressMessages({
  library(estimatr)
  library(dplyr)
  library(broom)
})

set.seed(42)

base_dir <- "agent_tasks/paper_b_robustness_2026062514"
out_dir  <- file.path(base_dir, "outputs")
log_dir  <- file.path(base_dir, "logs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)

cat("=== R3: Exclusion sensitivity ===\n")
cat("Start time:", format(Sys.time()), "\n\n")

df <- read.csv("data/panel/specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)
cat("Raw data dims:", nrow(df), "x", ncol(df), "\n")

# --- Verify DeepSeek R1 event id -------------------------------------------
deepseek_names <- unique(df$event_name[df$final_event_id == "FMR-0021"])
cat("Event name(s) for final_event_id == 'FMR-0021':", paste(deepseek_names, collapse = "; "), "\n")
stopifnot("DeepSeek R1" %in% deepseek_names)

target_vars  <- c("upstream_hardware", "downstream_deployer")
firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "factor(release_year)")
y_var <- "car_20"

safe_formula <- function(y, rhs) as.formula(paste(y, "~", paste(rhs, collapse = " + ")))

# model_data: drop rows missing any needed plain (non-factor) variable, plus the
# outcome and the cluster id, matching paper_plan_core_outputs.R conventions.
model_data <- function(data, y, rhs_vars, cluster_var = "final_event_id") {
  needed <- unique(c(y, cluster_var, rhs_vars))
  needed <- needed[!grepl("^factor\\(", needed)]
  needed <- needed[needed %in% names(data)]

  out <- data %>% filter(!is.na(.data[[y]]), !is.na(.data[[cluster_var]]))
  for (v in setdiff(needed, c(y, cluster_var))) {
    out <- out %>% filter(!is.na(.data[[v]]))
  }
  out
}

# Fit baseline spec for one position variable on one (possibly filtered) data set.
# Returns a one-row tibble with beta/se/p/n/n_events, or an empty tibble if the
# sample is too small / degenerate (e.g. variable has no variation left).
fit_one <- function(data, x, y = y_var, cluster_var = "final_event_id") {
  rhs <- c(x, base_controls)
  rhs_plain <- c(x, firm_controls)
  d <- model_data(data, y, rhs_plain, cluster_var)

  # Guardrails: need enough observations/clusters and variation in x
  if (nrow(d) < 30) return(tibble())
  if (n_distinct(d[[cluster_var]]) < 5) return(tibble())
  if (length(unique(d[[x]])) < 2) return(tibble())

  mod <- tryCatch(
    lm_robust(
      safe_formula(y, rhs),
      data = d,
      clusters = d[[cluster_var]],
      se_type = "CR0"
    ),
    error = function(e) NULL
  )
  if (is.null(mod)) return(tibble())

  tt <- tidy(mod, conf.int = FALSE) %>% filter(term == x)
  if (nrow(tt) == 0) return(tibble())

  tibble(
    variable = x,
    beta = tt$estimate[1],
    se = tt$std.error[1],
    p = tt$p.value[1],
    n = nobs(mod),
    n_events = n_distinct(d$final_event_id)
  )
}

# =============================================================================
# Check 1: DeepSeek R1 exclusion
# =============================================================================
cat("\n--- Check 1: DeepSeek R1 (FMR-0021) exclusion ---\n")

df_excl_deepseek <- df %>% filter(final_event_id != "FMR-0021")
cat("Rows full sample:", nrow(df), " | rows excl. DeepSeek:", nrow(df_excl_deepseek), "\n")

deepseek_results <- list()
for (v in target_vars) {
  full_res  <- fit_one(df, v) %>% mutate(spec = "full_sample")
  excl_res  <- fit_one(df_excl_deepseek, v) %>% mutate(spec = "excl_deepseek")
  deepseek_results[[length(deepseek_results) + 1]] <- bind_rows(full_res, excl_res)
}
deepseek_tbl <- bind_rows(deepseek_results) %>%
  select(variable, spec, beta, se, p, n, n_events)

print(deepseek_tbl)
write.csv(deepseek_tbl, file.path(out_dir, "r3_deepseek_exclusion.csv"), row.names = FALSE)
cat("Saved r3_deepseek_exclusion.csv\n")

# =============================================================================
# Check 2: Leave-one-event-out
# =============================================================================
cat("\n--- Check 2: Leave-one-event-out ---\n")

event_ids <- sort(unique(df$final_event_id))
cat("Number of unique final_event_id:", length(event_ids), "\n")

t0 <- Sys.time()
loo_event_list <- vector("list", length(event_ids) * length(target_vars))
idx <- 1
for (eid in event_ids) {
  d_drop <- df %>% filter(final_event_id != eid)
  for (v in target_vars) {
    res <- fit_one(d_drop, v)
    if (nrow(res) == 0) {
      res <- tibble(variable = v, beta = NA_real_, se = NA_real_, p = NA_real_, n = NA_integer_, n_events = NA_integer_)
    }
    res$dropped_event_id <- eid
    loo_event_list[[idx]] <- res
    idx <- idx + 1
  }
}
loo_event_tbl <- bind_rows(loo_event_list) %>%
  select(dropped_event_id, variable, beta, se, p, n)

cat("Leave-one-event-out loop time:", round(as.numeric(Sys.time() - t0, units = "secs"), 1), "sec\n")
write.csv(loo_event_tbl, file.path(out_dir, "r3_leave_one_event_out.csv"), row.names = FALSE)
cat("Saved r3_leave_one_event_out.csv (", nrow(loo_event_tbl), "rows )\n")

# =============================================================================
# Check 3: Leave-one-firm-out (using company_id -- clean ticker identifiers)
# =============================================================================
cat("\n--- Check 3: Leave-one-firm-out (company_id) ---\n")

firm_ids <- sort(unique(df$company_id))
cat("Number of unique company_id:", length(firm_ids), "\n")

t0 <- Sys.time()
loo_firm_list <- vector("list", length(firm_ids) * length(target_vars))
idx <- 1
for (fid in firm_ids) {
  d_drop <- df %>% filter(company_id != fid)
  for (v in target_vars) {
    res <- fit_one(d_drop, v)
    if (nrow(res) == 0) {
      res <- tibble(variable = v, beta = NA_real_, se = NA_real_, p = NA_real_, n = NA_integer_, n_events = NA_integer_)
    }
    res$dropped_firm <- fid
    loo_firm_list[[idx]] <- res
    idx <- idx + 1
  }
}
loo_firm_tbl <- bind_rows(loo_firm_list) %>%
  select(dropped_firm, variable, beta, se, p, n)

cat("Leave-one-firm-out loop time:", round(as.numeric(Sys.time() - t0, units = "secs"), 1), "sec\n")
write.csv(loo_firm_tbl, file.path(out_dir, "r3_leave_one_firm_out.csv"), row.names = FALSE)
cat("Saved r3_leave_one_firm_out.csv (", nrow(loo_firm_tbl), "rows )\n")

# =============================================================================
# Full-sample baseline (reference point for "most influential" comparisons)
# =============================================================================
full_baseline <- bind_rows(lapply(target_vars, function(v) fit_one(df, v)))
cat("\n--- Full-sample baseline (for reference) ---\n")
print(full_baseline)

# =============================================================================
# Summary statistics
# =============================================================================
cat("\n--- Summary stats: leave-one-event-out ---\n")
loo_event_summary <- loo_event_tbl %>%
  filter(!is.na(beta)) %>%
  group_by(variable) %>%
  summarise(
    beta_min = min(beta), beta_max = max(beta), beta_sd = sd(beta),
    n_iter = n(), .groups = "drop"
  )
print(loo_event_summary)

most_influential_event <- lapply(target_vars, function(v) {
  full_b <- full_baseline$beta[full_baseline$variable == v]
  sub <- loo_event_tbl %>% filter(variable == v, !is.na(beta)) %>%
    mutate(abs_diff = abs(beta - full_b))
  sub[which.max(sub$abs_diff), ]
})
names(most_influential_event) <- target_vars
cat("\nMost influential event per variable:\n")
print(most_influential_event)

cat("\n--- Summary stats: leave-one-firm-out ---\n")
loo_firm_summary <- loo_firm_tbl %>%
  filter(!is.na(beta)) %>%
  group_by(variable) %>%
  summarise(
    beta_min = min(beta), beta_max = max(beta), beta_sd = sd(beta),
    n_iter = n(), .groups = "drop"
  )
print(loo_firm_summary)

most_influential_firm <- lapply(target_vars, function(v) {
  full_b <- full_baseline$beta[full_baseline$variable == v]
  sub <- loo_firm_tbl %>% filter(variable == v, !is.na(beta)) %>%
    mutate(abs_diff = abs(beta - full_b))
  sub[which.max(sub$abs_diff), ]
})
names(most_influential_firm) <- target_vars
cat("\nMost influential firm per variable:\n")
print(most_influential_firm)

# Check whether any LOO iteration flips sign or kills significance (p>=0.10) relative
# to the full-sample baseline, for each variable
sign_flip_check <- function(loo_tbl, id_col) {
  lapply(target_vars, function(v) {
    full_b <- full_baseline$beta[full_baseline$variable == v]
    full_sign <- sign(full_b)
    sub <- loo_tbl %>% filter(variable == v, !is.na(beta))
    flips <- sub %>% filter(sign(beta) != full_sign)
    lost_sig <- sub %>% filter(p >= 0.10)
    list(
      variable = v,
      n_sign_flips = nrow(flips),
      flip_ids = if (nrow(flips) > 0) flips[[id_col]] else character(0),
      n_lost_significance = nrow(lost_sig),
      lost_sig_ids = if (nrow(lost_sig) > 0) lost_sig[[id_col]] else character(0)
    )
  })
}

event_flip_info <- sign_flip_check(loo_event_tbl, "dropped_event_id")
firm_flip_info <- sign_flip_check(loo_firm_tbl, "dropped_firm")

cat("\n--- Sign-flip / significance-loss check (event) ---\n")
print(event_flip_info)
cat("\n--- Sign-flip / significance-loss check (firm) ---\n")
print(firm_flip_info)

# =============================================================================
# Write markdown summary
# =============================================================================
fmt <- function(x, d = 4) ifelse(is.na(x), "NA", formatC(x, format = "f", digits = d))

md_lines <- c(
  "# R3: Exclusion Sensitivity Summary — upstream_hardware & downstream_deployer (CAR[0,+20])",
  "",
  paste0("Generated: ", format(Sys.time())),
  "",
  "## Baseline spec",
  "",
  "`car_20 ~ position_var + size_log_assets + bm_ratio + volatility + momentum + factor(release_year)`, ",
  "clustered SE by `final_event_id` (CR0, via `estimatr::lm_robust`).",
  "",
  "## Full-sample baseline (reference)",
  ""
)

for (i in seq_len(nrow(full_baseline))) {
  r <- full_baseline[i, ]
  md_lines <- c(md_lines, paste0(
    "- **", r$variable, "**: beta = ", fmt(r$beta), " (", fmt(r$beta * 100, 2), " pp), se = ", fmt(r$se),
    ", p = ", fmt(r$p, 4), ", n = ", r$n, ", n_events = ", r$n_events
  ))
}

md_lines <- c(md_lines, "", "## Check 1: DeepSeek R1 (FMR-0021) exclusion", "")

for (v in target_vars) {
  full_row <- deepseek_tbl %>% filter(variable == v, spec == "full_sample")
  excl_row <- deepseek_tbl %>% filter(variable == v, spec == "excl_deepseek")
  if (nrow(full_row) == 1 && nrow(excl_row) == 1) {
    delta <- excl_row$beta - full_row$beta
    pct_change <- if (full_row$beta != 0) 100 * delta / abs(full_row$beta) else NA
    sig_change <- (full_row$p < 0.05) != (excl_row$p < 0.05)
    md_lines <- c(md_lines,
      paste0("### ", v),
      "",
      paste0("- Full sample: beta = ", fmt(full_row$beta), " (", fmt(full_row$beta*100,2), " pp), se = ", fmt(full_row$se),
             ", p = ", fmt(full_row$p, 4), ", n = ", full_row$n, ", n_events = ", full_row$n_events),
      paste0("- Excl. DeepSeek R1: beta = ", fmt(excl_row$beta), " (", fmt(excl_row$beta*100,2), " pp), se = ", fmt(excl_row$se),
             ", p = ", fmt(excl_row$p, 4), ", n = ", excl_row$n, ", n_events = ", excl_row$n_events),
      paste0("- Change in beta: ", fmt(delta), " (", fmt(pct_change, 1), "% of full-sample beta); ",
             "significance at 5% ", ifelse(sig_change, "**changes**", "unchanged"), "."),
      ""
    )
  }
}

md_lines <- c(md_lines, paste0("## Check 2: Leave-one-event-out (n = ", length(event_ids), " events)"), "")
for (i in seq_len(nrow(loo_event_summary))) {
  r <- loo_event_summary[i, ]
  full_b <- full_baseline$beta[full_baseline$variable == r$variable]
  mi <- most_influential_event[[r$variable]]
  md_lines <- c(md_lines, paste0(
    "- **", r$variable, "**: beta range across ", r$n_iter, " leave-one-event-out iterations = [",
    fmt(r$beta_min), ", ", fmt(r$beta_max), "], sd = ", fmt(r$beta_sd, 5),
    "; full-sample beta = ", fmt(full_b), ".",
    " Most influential event when dropped: **", mi$dropped_event_id, "** (beta becomes ", fmt(mi$beta),
    ", |delta| = ", fmt(mi$abs_diff), ")."
  ))
}
flip_summary_event <- sapply(event_flip_info, function(x) x$n_sign_flips)
lost_sig_event <- sapply(event_flip_info, function(x) x$n_lost_significance)
md_lines <- c(md_lines, "", paste0(
  "Sign flips across leave-one-event-out: upstream_hardware = ", flip_summary_event[1],
  ", downstream_deployer = ", flip_summary_event[2], " (out of ", length(event_ids), " iterations each)."
), paste0(
  "Iterations where p >= 0.10 (lost 5%/10% significance): upstream_hardware = ", lost_sig_event[1],
  ", downstream_deployer = ", lost_sig_event[2], "."
), "")

md_lines <- c(md_lines, paste0("## Check 3: Leave-one-firm-out (n = ", length(firm_ids), " firms, by company_id)"), "")
for (i in seq_len(nrow(loo_firm_summary))) {
  r <- loo_firm_summary[i, ]
  full_b <- full_baseline$beta[full_baseline$variable == r$variable]
  mi <- most_influential_firm[[r$variable]]
  md_lines <- c(md_lines, paste0(
    "- **", r$variable, "**: beta range across ", r$n_iter, " leave-one-firm-out iterations = [",
    fmt(r$beta_min), ", ", fmt(r$beta_max), "], sd = ", fmt(r$beta_sd, 5),
    "; full-sample beta = ", fmt(full_b), ".",
    " Most influential firm when dropped: **", mi$dropped_firm, "** (beta becomes ", fmt(mi$beta),
    ", |delta| = ", fmt(mi$abs_diff), ")."
  ))
}
flip_summary_firm <- sapply(firm_flip_info, function(x) x$n_sign_flips)
lost_sig_firm <- sapply(firm_flip_info, function(x) x$n_lost_significance)
md_lines <- c(md_lines, "", paste0(
  "Sign flips across leave-one-firm-out: upstream_hardware = ", flip_summary_firm[1],
  ", downstream_deployer = ", flip_summary_firm[2], " (out of ", length(firm_ids), " iterations each)."
), paste0(
  "Iterations where p >= 0.10 (lost 5%/10% significance): upstream_hardware = ", lost_sig_firm[1],
  ", downstream_deployer = ", lost_sig_firm[2], "."
), "")

md_lines <- c(md_lines, "## Overall conclusion", "",
  "See bullet points above for quantitative detail. In plain terms: if dropping DeepSeek R1, or any single",
  "event, or any single firm flips the sign of beta or pushes p above conventional thresholds, the headline",
  "result for that variable should be flagged as fragile rather than robust. Otherwise, both headline findings",
  "(upstream_hardware positive, downstream_deployer negative on CAR[0,+20]) hold up under these sensitivity checks.",
  ""
)

writeLines(md_lines, file.path(out_dir, "r3_sensitivity_summary.md"))
cat("\nSaved r3_sensitivity_summary.md\n")

cat("\n=== R3 complete ===\n")
cat("End time:", format(Sys.time()), "\n")
