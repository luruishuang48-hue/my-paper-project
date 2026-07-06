#!/usr/bin/env Rscript
# =============================================================================
# core_table.R
# 1. Center aa_intelligence_index → intel_c
# 2. Re-run all interaction models with intel_c
# 3. CR0 / CR2 / Wild-bootstrap (Rademacher, B=4999) for all key terms
# 4. Output publishable core table (CSV + markdown + console)
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

# ─── Load data ─────────────────────────────────────────────────────────────────
df <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)
num_cols <- c(
  "car_20","car_1","car_15",
  "aa_intelligence_index","size_log_assets","bm_ratio","volatility","momentum",
  "release_year","is_open_weight","owner","investor","cloud",
  "business_upstream","real_upstream","business_downstream","real_downstream","competitor"
)
for (col in num_cols) if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])

df$tier1 <- ifelse(df$candidate_tier == "Tier 1", 1L,
              ifelse(df$candidate_tier == "Tier 2", 0L, NA_integer_))

df_base <- df[
  !is.na(df$aa_intelligence_index) &
  !is.na(df$size_log_assets) &
  !is.na(df$bm_ratio) &
  !is.na(df$volatility) &
  !is.na(df$momentum), ]

# ─── Center intelligence index ─────────────────────────────────────────────────
intel_mean <- mean(df_base$aa_intelligence_index, na.rm = TRUE)
cat(sprintf("aa_intelligence_index: mean = %.4f  SD = %.4f  (full base sample, n=%d)\n",
            intel_mean,
            sd(df_base$aa_intelligence_index, na.rm = TRUE),
            nrow(df_base)))
df_base$intel_c <- df_base$aa_intelligence_index - intel_mean

# Pass centering to subsamples
df_closed <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 0, ]
df_open   <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 1, ]
cat(sprintf("Closed: n=%d events=%d | Open: n=%d events=%d\n",
            nrow(df_closed), length(unique(df_closed$final_event_id)),
            nrow(df_open),   length(unique(df_open$final_event_id))))

ctrl <- c("size_log_assets","bm_ratio","volatility","momentum")

# ─── SE helpers ───────────────────────────────────────────────────────────────
get_p <- function(mod, var, se_type_label) {
  # Refit with different se_type if needed
  tryCatch({
    b  <- coef(mod)[[var]]
    se <- sqrt(diag(vcov(mod)))[[var]]
    as.numeric(summary(mod)$coefficients[var, "Pr(>|t|)"])
  }, error = function(e) NA_real_)
}

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

stars <- function(p) {
  if (is.na(p)) return("n/a")
  ifelse(p<0.01,"***", ifelse(p<0.05,"**", ifelse(p<0.10,"*","")))
}
fmt_p <- function(p) {
  if (is.na(p)) return("n/a")
  sprintf("%.3f%s", p, stars(p))
}

# =============================================================================
# MODEL DEFINITIONS
# =============================================================================
# All use intel_c (centered); full sample unless noted; CR0 cluster by event

# Base formula builder
make_fml <- function(y, xterms) {
  as.formula(paste(y, "~", paste(c(xterms, ctrl, "factor(release_year)"), collapse=" + ")))
}

# =============================================================================
# RUN MODELS & COLLECT RESULTS
# =============================================================================
cat("\n", strrep("=",80), "\n")
cat("RUNNING ALL MODELS (centered intel_c)\n")
cat(strrep("=",80), "\n\n")

rows <- list()

# ── Helper: run one model row ──────────────────────────────────────────────────
run_row <- function(label, data, fml_full, fml_restr, var, B = 4999) {
  d    <- data[!is.na(data[[all.vars(fml_full)[1]]]), ]
  n    <- nrow(d)
  nevt <- length(unique(d$final_event_id))

  # CR0
  m0   <- lm_robust(fml_full, data = d, clusters = d$final_event_id, se_type = "CR0")
  b    <- coef(m0)[[var]]
  se   <- sqrt(diag(vcov(m0)))[[var]]
  p0   <- as.numeric(summary(m0)$coefficients[var, "Pr(>|t|)"])

  cat(sprintf("[%s]  var=%s  n=%d  events=%d  beta=%.6f  SE=%.6f  CR0 p=%.4f\n",
              label, var, n, nevt, b, se, p0))

  # CR2
  p2 <- refit_cr2(d, fml_full, var)
  cat(sprintf("  CR2  p=%.4f\n", p2))

  # Wild bootstrap
  cat(sprintf("  Wild bootstrap... B=%d\n", B))
  pw <- wild_boot_p(d, fml_full, fml_restr, var, B = B)
  cat(sprintf("  Wild p=%.4f\n", pw))

  list(label=label, var=var, n=n, events=nevt,
       beta=b, se=se, p_cr0=p0, p_cr2=p2, p_wild=pw)
}

# ── (1) Baseline: full sample car_20 ──────────────────────────────────────────
r1 <- run_row(
  "(1) Full sample, car_20",
  df_base,
  make_fml("car_20", "intel_c"),
  make_fml("car_20", character(0)),
  "intel_c"
)
rows[[1]] <- r1

# ── (2) Closed source car_20 ──────────────────────────────────────────────────
r2 <- run_row(
  "(2) Closed source, car_20",
  df_closed,
  make_fml("car_20", "intel_c"),
  make_fml("car_20", character(0)),
  "intel_c"
)
rows[[2]] <- r2

# ── (3) intelligence × open_weight: interaction term (car_20) ─────────────────
fml3_full  <- make_fml("car_20", c("intel_c", "is_open_weight", "intel_c:is_open_weight"))
fml3_restr <- make_fml("car_20", c("intel_c", "is_open_weight"))   # impose null on interaction
d3 <- df_base[!is.na(df_base$is_open_weight), ]

r3a <- run_row("(3a) intel_c × open_weight — main intel_c (closed-src slope)", d3,
               fml3_full, make_fml("car_20", c("is_open_weight")), "intel_c")
rows[[3]] <- r3a

r3b <- run_row("(3b) intel_c × open_weight — INTERACTION TERM", d3,
               fml3_full, fml3_restr, "intel_c:is_open_weight")
rows[[4]] <- r3b

# ── (3c) open_weight main effect (interpretable with centering) ────────────────
{
  d  <- d3[!is.na(d3$car_20), ]
  m  <- lm_robust(fml3_full, data=d, clusters=d$final_event_id, se_type="CR0")
  b  <- coef(m)[["is_open_weight"]]
  se <- sqrt(diag(vcov(m)))[["is_open_weight"]]
  p  <- as.numeric(summary(m)$coefficients["is_open_weight","Pr(>|t|)"])
  cat(sprintf("[open_weight main effect at mean intel]  beta=%.4f  SE=%.4f  p=%.4f %s\n",
              b, se, p, stars(p)))
}

# ── (4) intelligence × investor: interaction term (car_20) ────────────────────
fml4_full  <- make_fml("car_20", c("intel_c","investor","intel_c:investor"))
fml4_restr <- make_fml("car_20", c("intel_c","investor"))
d4 <- df_base[!is.na(df_base$investor), ]

r4a <- run_row("(4a) intel_c × investor — main intel_c (non-investor slope)", d4,
               fml4_full, make_fml("car_20","investor"), "intel_c")
rows[[5]] <- r4a

r4b <- run_row("(4b) intel_c × investor — INTERACTION TERM", d4,
               fml4_full, fml4_restr, "intel_c:investor")
rows[[6]] <- r4b

# ── (4c) investor main effect (interpretable at mean intel) ────────────────────
{
  d  <- d4[!is.na(d4$car_20), ]
  m  <- lm_robust(fml4_full, data=d, clusters=d$final_event_id, se_type="CR0")
  b  <- coef(m)[["investor"]]
  se <- sqrt(diag(vcov(m)))[["investor"]]
  p  <- as.numeric(summary(m)$coefficients["investor","Pr(>|t|)"])
  cat(sprintf("[investor main effect at mean intel]  beta=%.4f  SE=%.4f  p=%.4f %s\n",
              b, se, p, stars(p)))
}

# ── (5) intelligence × cloud: interaction term (car_20) ───────────────────────
fml5_full  <- make_fml("car_20", c("intel_c","cloud","intel_c:cloud"))
fml5_restr <- make_fml("car_20", c("intel_c","cloud"))
d5 <- df_base[!is.na(df_base$cloud), ]

r5a <- run_row("(5a) intel_c × cloud — main intel_c (non-cloud slope)", d5,
               fml5_full, make_fml("car_20","cloud"), "intel_c")
rows[[7]] <- r5a

r5b <- run_row("(5b) intel_c × cloud — INTERACTION TERM", d5,
               fml5_full, fml5_restr, "intel_c:cloud")
rows[[8]] <- r5b

# ── (5c) cloud main effect ──────────────────────────────────────────────────────
{
  d  <- d5[!is.na(d5$car_20), ]
  m  <- lm_robust(fml5_full, data=d, clusters=d$final_event_id, se_type="CR0")
  b  <- coef(m)[["cloud"]]
  se <- sqrt(diag(vcov(m)))[["cloud"]]
  p  <- as.numeric(summary(m)$coefficients["cloud","Pr(>|t|)"])
  cat(sprintf("[cloud main effect at mean intel]  beta=%.4f  SE=%.4f  p=%.4f %s\n",
              b, se, p, stars(p)))
}

# ── (6) intelligence × owner: car_1 and car_2 (Owner reversal test) ────────────
fml6a_full  <- make_fml("car_1",  c("intel_c","owner","intel_c:owner"))
fml6a_restr <- make_fml("car_1",  c("intel_c","owner"))
fml6b_full  <- make_fml("car_2",  c("intel_c","owner","intel_c:owner"))
fml6b_restr <- make_fml("car_2",  c("intel_c","owner"))
d6 <- df_base[!is.na(df_base$owner), ]

r6a <- run_row("(6a) intel_c × owner — INTERACTION car_1", d6,
               fml6a_full, fml6a_restr, "intel_c:owner")
rows[[9]] <- r6a

r6b <- run_row("(6b) intel_c × owner — INTERACTION car_2", d6,
               fml6b_full, fml6b_restr, "intel_c:owner")
rows[[10]] <- r6b

# =============================================================================
# BUILD PUBLISHABLE CORE TABLE
# =============================================================================
cat("\n", strrep("=",80), "\n")
cat("PUBLISHABLE CORE TABLE\n")
cat(strrep("=",80), "\n\n")

# Console table
hdr <- sprintf("%-46s %7s %8s %8s %8s %8s %7s %7s",
               "Spec / Coefficient", "N", "Events", "Beta", "SE",
               "CR0 p", "CR2 p", "Wild p")
cat(hdr, "\n")
cat(strrep("-", nchar(hdr)), "\n")

for (r in rows) {
  cat(sprintf("%-46s %7d %8d %8.5f %8.5f %8s %8s %8s\n",
              substr(r$label, 1, 46),
              r$n, r$events,
              r$beta, r$se,
              fmt_p(r$p_cr0), fmt_p(r$p_cr2), fmt_p(r$p_wild)))
}

# Markdown table
md <- c(
  "| Spec / Coefficient | N | Events | Beta | SE | CR0 p | CR2 p | Wild p |",
  "|---|---|---|---|---|---|---|---|"
)
for (r in rows) {
  md <- c(md, sprintf("| %s | %d | %d | %.5f | %.5f | %s | %s | %s |",
                      r$label, r$n, r$events,
                      r$beta, r$se,
                      fmt_p(r$p_cr0), fmt_p(r$p_cr2), fmt_p(r$p_wild)))
}
cat("\n\n--- MARKDOWN TABLE ---\n\n")
cat(paste(md, collapse="\n"), "\n")

# CSV output
results_df <- do.call(rbind, lapply(rows, function(r) {
  data.frame(
    spec    = r$label,
    var     = r$var,
    n       = r$n,
    events  = r$events,
    beta    = round(r$beta, 6),
    se      = round(r$se, 6),
    p_cr0   = round(r$p_cr0, 4),
    p_cr2   = round(r$p_cr2, 4),
    p_wild  = round(r$p_wild, 4),
    stringsAsFactors = FALSE
  )
}))
write.csv(results_df, "core_table_results.csv", row.names = FALSE)
cat("\nSaved: core_table_results.csv\n")

# =============================================================================
# CENTERED EFFECT INTERPRETATION SUMMARY
# =============================================================================
cat("\n", strrep("=",80), "\n")
cat("CENTERING INTERPRETATION SUMMARY\n")
cat(strrep("=",80), "\n")
cat(sprintf("  Centering point: intel_c = 0 ↔ aa_intelligence_index = %.4f\n", intel_mean))
cat("  Main effects of is_open_weight, investor, cloud are now interpreted\n")
cat("  at the AVERAGE intelligence level in the sample (not at index=0).\n\n")

# Implied slopes
cat("Implied intelligence slopes (centered):\n")

# open_weight model
{
  d <- d3[!is.na(d3$car_20), ]
  m <- lm_robust(fml3_full, data=d, clusters=d$final_event_id, se_type="CR0")
  b <- coef(m)
  cat(sprintf("  Open/Closed model:\n"))
  cat(sprintf("    Closed (open=0):  %.6f\n", b["intel_c"]))
  cat(sprintf("    Open   (open=1):  %.6f\n", b["intel_c"] + b["intel_c:is_open_weight"]))
}

# investor model
{
  d <- d4[!is.na(d4$car_20), ]
  m <- lm_robust(fml4_full, data=d, clusters=d$final_event_id, se_type="CR0")
  b <- coef(m)
  cat(sprintf("  Investor model:\n"))
  cat(sprintf("    Non-investor (investor=0):  %.6f\n", b["intel_c"]))
  cat(sprintf("    Investor     (investor=1):  %.6f\n", b["intel_c"] + b["intel_c:investor"]))
  cat(sprintf("    At mean intel, investor main effect: %.4f (i.e., avg CAR diff = %.2f%%)\n",
              b["investor"], b["investor"]*100))
}

# cloud model
{
  d <- d5[!is.na(d5$car_20), ]
  m <- lm_robust(fml5_full, data=d, clusters=d$final_event_id, se_type="CR0")
  b <- coef(m)
  cat(sprintf("  Cloud model:\n"))
  cat(sprintf("    Non-cloud (cloud=0):  %.6f\n", b["intel_c"]))
  cat(sprintf("    Cloud     (cloud=1):  %.6f\n", b["intel_c"] + b["intel_c:cloud"]))
  cat(sprintf("    At mean intel, cloud main effect: %.4f (i.e., avg CAR diff = %.2f%%)\n",
              b["cloud"], b["cloud"]*100))
}

cat("\nAll done.\n")
