#!/usr/bin/env Rscript
# =============================================================================
# Specification Curve Analysis: AI Model Capability → Stock Returns (CAR)
# =============================================================================
# Input:   specr_input_clean.csv  (UTF-8, prepared by specr_prep.py)
# Output:  specr_results_all.csv, specr_summary.csv, specr_curve_*.pdf
#
# X vars:    aa_intelligence_index | aa_coding_index | aa_math_index | aa_media_elo
# Y vars:    car_1 | car_2 | car_3 | car_5 | car_10 | car_15 | car_20
# Controls:  none | size_log_assets | size + bm_ratio + volatility + momentum
# Subsets:   all | us_creator | non_us_creator | open_source | closed_source
#            | text_or_reason | media_gen
# Year FE:   none | factor(release_year)
# SE:        clustered by final_event_id (CR0), via estimatr::lm_robust
#            fallback to OLS when <5 clusters
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
  library(broom)
  if (!requireNamespace("patchwork", quietly = TRUE))
    install.packages("patchwork", repos = "https://cran.r-project.org")
  library(patchwork)
})

# ─── 1. Load & coerce data ────────────────────────────────────────────────────

df <- read.csv("specr_input_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)
cat("Loaded:", nrow(df), "rows x", ncol(df), "cols\n")

num_cols <- c(
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "aa_intelligence_index","aa_coding_index","aa_math_index","aa_media_elo",
  "size_log_assets","bm_ratio","volatility","momentum",
  "release_year","is_open_weight_or_open_source"
)
for (col in num_cols) {
  if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])
}

cat("release_year:", sort(unique(na.omit(df$release_year))), "\n")
cat("creator_type:\n");   print(table(df$creator_type,                   useNA = "ifany"))
cat("model_modality:\n"); print(table(df$model_modality,                useNA = "ifany"))
cat("is_open_weight:\n"); print(table(df$is_open_weight_or_open_source, useNA = "ifany"))

# ─── 2. Specification dimensions ─────────────────────────────────────────────

X_VARS <- c("aa_intelligence_index","aa_coding_index","aa_math_index","aa_media_elo")
Y_VARS <- c("car_1","car_2","car_3","car_5","car_10","car_15","car_20")

CONTROL_SETS <- list(
  none = character(0),
  size = "size_log_assets",
  full = c("size_log_assets","bm_ratio","volatility","momentum")
)

# Subsample filters applied AFTER dropping NA on x/y
SUBSAMPLES <- list(
  all            = function(d) rep(TRUE,  nrow(d)),
  us_creator     = function(d) d$creator_type == "listed_us_company",
  non_us_creator = function(d) d$creator_type != "listed_us_company",
  open_source    = function(d) !is.na(d$is_open_weight_or_open_source) & d$is_open_weight_or_open_source == 1,
  closed_source  = function(d) !is.na(d$is_open_weight_or_open_source) & d$is_open_weight_or_open_source == 0,
  text_or_reason = function(d) d$model_modality %in% c("text_llm","reasoning_llm","coding_llm","multimodal_llm"),
  media_gen      = function(d) d$model_modality %in% c("image_generation","video_generation","image_editing")
)

YEAR_FE_OPTS <- c(FALSE, TRUE)
MIN_OBS      <- 20   # minimum observations per spec
MIN_CLUSTERS <- 5    # minimum clusters for CR0 SE; else fall back to OLS

# ─── 3. Run all specifications ────────────────────────────────────────────────

run_one <- function(formula_obj, df_sub, x_var) {
  n_cl <- length(unique(df_sub$final_event_id))
  if (n_cl >= MIN_CLUSTERS) {
    mod <- lm_robust(formula_obj, data = df_sub,
                     clusters = df_sub$final_event_id, se_type = "CR0")
  } else {
    mod <- lm(formula_obj, data = df_sub)
  }
  tbl <- tidy(mod, conf.int = TRUE)
  tbl[tbl$term == x_var, ]
}

# Total specs (upper bound): 4 × 7 × 3 × 7 × 2 = 1176
records <- vector("list", 2000)
idx <- 0L

for (x_var in X_VARS) {
  cat("\n── X:", x_var, "──\n")

  for (y_var in Y_VARS) {
    # Drop NA on x and y first, then apply subsets
    df_xy <- df[!is.na(df[[x_var]]) & !is.na(df[[y_var]]), ]

    for (ctrl_name in names(CONTROL_SETS)) {
      for (ss_name in names(SUBSAMPLES)) {
        for (use_fe in YEAR_FE_OPTS) {

          df_sub <- df_xy[SUBSAMPLES[[ss_name]](df_xy), ]
          if (nrow(df_sub) < MIN_OBS) next

          # Build formula RHS
          rhs_parts <- x_var
          ctrlv <- CONTROL_SETS[[ctrl_name]]
          if (length(ctrlv) > 0)  rhs_parts <- c(rhs_parts, ctrlv)
          if (use_fe)              rhs_parts <- c(rhs_parts, "factor(release_year)")
          formula_obj <- as.formula(paste(y_var, "~", paste(rhs_parts, collapse = " + ")))

          row <- tryCatch(run_one(formula_obj, df_sub, x_var), error = function(e) NULL)
          if (is.null(row) || nrow(row) == 0) next

          idx <- idx + 1L
          records[[idx]] <- data.frame(
            x_var     = x_var,
            y_var     = y_var,
            controls  = ctrl_name,
            subsample = ss_name,
            year_fe   = use_fe,
            n         = nrow(df_sub),
            n_events  = length(unique(df_sub$final_event_id)),
            estimate  = row$estimate,
            std.error = row$std.error,
            p.value   = row$p.value,
            conf.low  = row$conf.low,
            conf.high = row$conf.high,
            sig_05    = row$p.value < 0.05,
            sig_10    = row$p.value < 0.10,
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }
}

df_res <- do.call(rbind, records[seq_len(idx)])
cat("\nTotal specifications run:", nrow(df_res), "\n")

# ─── 4. Save raw results ──────────────────────────────────────────────────────

write.csv(df_res, "specr_results_all.csv", row.names = FALSE)
cat("Saved: specr_results_all.csv\n")

# ─── 5. Summary table ─────────────────────────────────────────────────────────

summary_tbl <- df_res %>%
  group_by(x_var) %>%
  summarise(
    n_specs      = n(),
    n_sig_05     = sum(sig_05),
    pct_sig_05   = round(100 * mean(sig_05), 1),
    n_sig_10     = sum(sig_10),
    pct_sig_10   = round(100 * mean(sig_10), 1),
    pct_positive = round(100 * mean(estimate > 0), 1),
    median_est   = round(median(estimate), 5),
    mean_est     = round(mean(estimate), 5),
    sd_est       = round(sd(estimate), 5),
    min_est      = round(min(estimate), 5),
    max_est      = round(max(estimate), 5),
    .groups = "drop"
  )

write.csv(summary_tbl, "specr_summary.csv", row.names = FALSE)
cat("\n=== SUMMARY ===\n")
print(as.data.frame(summary_tbl), digits = 4, row.names = FALSE)

# ─── 6. Specification curve plots ─────────────────────────────────────────────

plot_spec_curve <- function(df_res, xv) {
  d <- df_res %>%
    filter(x_var == xv) %>%
    arrange(estimate) %>%
    mutate(
      rank      = row_number(),
      sig_label = ifelse(sig_05, "p<0.05", "p\u22650.05"),
      year_fe   = ifelse(year_fe, "Year FE", "No FE")
    )

  n_tot <- nrow(d)
  n_sig <- sum(d$sig_05)
  pct   <- round(100 * n_sig / n_tot)

  # ── top: coefficient estimates ────
  p_top <- ggplot(d, aes(x = rank, y = estimate)) +
    geom_hline(yintercept = 0, color = "#e74c3c", linewidth = 0.6, linetype = "dashed") +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = sig_label), alpha = 0.22) +
    geom_point(aes(color = sig_label), size = 0.7, shape = 16) +
    scale_color_manual(values = c("p<0.05" = "#2980b9", "p\u22650.05" = "#95a5a6"), name = NULL) +
    scale_fill_manual( values = c("p<0.05" = "#2980b9", "p\u22650.05" = "#bdc3c7"), name = NULL) +
    labs(
      title    = paste0("Specification Curve  \u2014  X = ", xv),
      subtitle = paste0(n_tot, " specifications  |  ", n_sig, " significant at p<0.05 (", pct, "%)"),
      y = "Coefficient estimate", x = NULL
    ) +
    theme_bw(base_size = 10) +
    theme(
      legend.position        = c(0.02, 0.98),
      legend.justification   = c(0, 1),
      legend.background      = element_rect(fill = alpha("white", 0.8)),
      axis.text.x            = element_blank(),
      axis.ticks.x           = element_blank(),
      panel.grid.minor       = element_blank()
    )

  # ── bottom: specification indicators ────
  d_long <- d %>%
    select(rank, y_var, controls, subsample, year_fe) %>%
    pivot_longer(-rank, names_to = "dim", values_to = "val") %>%
    mutate(dim = factor(dim,
      levels = c("year_fe","subsample","controls","y_var"),
      labels = c("Year FE","Subsample","Controls","Outcome (Y)")
    ))

  p_bot <- ggplot(d_long, aes(x = rank, y = val)) +
    geom_point(shape = "|", size = 1.8, color = "#2c3e50") +
    facet_grid(dim ~ ., scales = "free_y", space = "free_y") +
    labs(x = "Specifications (ranked by estimate)", y = NULL) +
    theme_bw(base_size = 9) +
    theme(
      strip.text.y         = element_text(angle = 0, hjust = 0, size = 8),
      panel.grid.major.x   = element_blank(),
      panel.grid.minor     = element_blank(),
      axis.text.x          = element_blank(),
      axis.ticks.x         = element_blank()
    )

  p_top / p_bot + plot_layout(heights = c(2.5, 1.8))
}

for (xv in unique(df_res$x_var)) {
  p     <- plot_spec_curve(df_res, xv)
  fname <- paste0("specr_curve_", xv, ".pdf")
  ggsave(fname, p, width = 12, height = 8)
  cat("Saved:", fname, "\n")
}

cat("\nDone.\n")
