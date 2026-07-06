#!/usr/bin/env Rscript
# =============================================================================
# Specification Curve Analysis — Relationship Data
# X: aa_intelligence_index
# Y: car_1 … car_20
# Subsamples: relationship types + modality + open/closed + creator type
# SE: CR0 clustered by final_event_id
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
  library(broom)
  library(patchwork)
})

# ─── 1. Load data ─────────────────────────────────────────────────────────────

df <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)
cat("Loaded:", nrow(df), "rows x", ncol(df), "cols\n")

num_cols <- c(
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "aa_intelligence_index",
  "size_log_assets","bm_ratio","volatility","momentum",
  "release_year","is_open_weight",
  "owner","investor","cloud",
  "business_upstream","real_upstream",
  "business_downstream","real_downstream","competitor"
)
for (col in num_cols) if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])

cat("Events:", length(unique(df$final_event_id)), "\n")
cat("aa_intelligence_index non-NA:", sum(!is.na(df$aa_intelligence_index)), "\n\n")

# ─── 2. Specification dimensions ─────────────────────────────────────────────

X_VAR    <- "aa_intelligence_index"
Y_VARS   <- c("car_1","car_2","car_3","car_5","car_10","car_15","car_20")

CONTROL_SETS <- list(
  none = character(0),
  size = "size_log_assets",
  full = c("size_log_assets","bm_ratio","volatility","momentum")
)

# Subsamples: relationship types + existing subsamples
SUBSAMPLES <- list(
  # ── 全样本
  all                = function(d) rep(TRUE, nrow(d)),
  # ── 关系类型（各类型内部，=1 的行）
  owner              = function(d) !is.na(d$owner)              & d$owner              == 1,
  investor           = function(d) !is.na(d$investor)           & d$investor           == 1,
  cloud              = function(d) !is.na(d$cloud)              & d$cloud              == 1,
  business_upstream  = function(d) !is.na(d$business_upstream)  & d$business_upstream  == 1,
  real_upstream      = function(d) !is.na(d$real_upstream)      & d$real_upstream      == 1,
  business_downstream= function(d) !is.na(d$business_downstream)& d$business_downstream== 1,
  real_downstream    = function(d) !is.na(d$real_downstream)    & d$real_downstream    == 1,
  competitor         = function(d) !is.na(d$competitor)         & d$competitor         == 1,
  # ── 任意正向关系（owner/investor/cloud/upstream）
  positive_rel       = function(d) {
    pos <- d$owner + d$investor + d$cloud + d$business_upstream + d$real_upstream
    !is.na(pos) & pos >= 1
  },
  # ── 下游 + 竞争（规模较大）
  downstream_comp    = function(d) {
    dc <- d$business_downstream + d$real_downstream + d$competitor
    !is.na(dc) & dc >= 1
  },
  # ── 开源 / 闭源
  open_source        = function(d) !is.na(d$is_open_weight) & d$is_open_weight == 1,
  closed_source      = function(d) !is.na(d$is_open_weight) & d$is_open_weight == 0,
  # ── 创始者类型
  us_creator         = function(d) d$creator_type == "listed_us_company",
  non_us_creator     = function(d) d$creator_type != "listed_us_company",
  # ── 模型模态
  text_or_reason     = function(d) d$model_modality %in% c("text_llm","reasoning_llm","coding_llm","multimodal_llm"),
  media_gen          = function(d) d$model_modality %in% c("image_generation","video_generation","image_editing")
)

YEAR_FE_OPTS <- c(FALSE, TRUE)
MIN_OBS      <- 20
MIN_CLUSTERS <- 5

# ─── 3. Run all specifications ────────────────────────────────────────────────

run_one <- function(formula_obj, df_sub) {
  n_cl <- length(unique(df_sub$final_event_id))
  if (n_cl >= MIN_CLUSTERS) {
    mod <- lm_robust(formula_obj, data = df_sub,
                     clusters = df_sub$final_event_id, se_type = "CR0")
  } else {
    mod <- lm(formula_obj, data = df_sub)
  }
  tidy(mod, conf.int = TRUE)
}

records <- vector("list", 3000)
idx <- 0L

for (y_var in Y_VARS) {
  df_xy <- df[!is.na(df[[X_VAR]]) & !is.na(df[[y_var]]), ]

  for (ctrl_name in names(CONTROL_SETS)) {
    for (ss_name in names(SUBSAMPLES)) {
      for (use_fe in YEAR_FE_OPTS) {

        df_sub <- df_xy[SUBSAMPLES[[ss_name]](df_xy), ]
        if (nrow(df_sub) < MIN_OBS) next

        rhs <- X_VAR
        ctrlv <- CONTROL_SETS[[ctrl_name]]
        if (length(ctrlv) > 0) rhs <- c(rhs, ctrlv)
        if (use_fe)            rhs <- c(rhs, "factor(release_year)")

        formula_obj <- as.formula(paste(y_var, "~", paste(rhs, collapse = " + ")))

        row <- tryCatch(run_one(formula_obj, df_sub), error = function(e) NULL)
        if (is.null(row)) next
        row <- row[row$term == X_VAR, ]
        if (nrow(row) == 0) next

        idx <- idx + 1L
        records[[idx]] <- data.frame(
          x_var     = X_VAR,
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

df_res <- do.call(rbind, records[seq_len(idx)])
cat("Total specifications:", nrow(df_res), "\n")
write.csv(df_res, "specr_rel_results_all.csv", row.names = FALSE)
cat("Saved: specr_rel_results_all.csv\n\n")

# ─── 4. Summary by subsample ──────────────────────────────────────────────────

summ_sub <- df_res %>%
  group_by(subsample) %>%
  summarise(
    n_specs      = n(),
    n_sig_05     = sum(sig_05),
    pct_sig_05   = round(100 * mean(sig_05), 1),
    pct_positive = round(100 * mean(estimate > 0), 1),
    median_est   = round(median(estimate), 6),
    mean_est     = round(mean(estimate), 6),
    sd_est       = round(sd(estimate), 6),
    .groups = "drop"
  ) %>%
  arrange(desc(pct_sig_05))

write.csv(summ_sub, "specr_rel_summary.csv", row.names = FALSE)
cat("=== SUMMARY BY SUBSAMPLE ===\n")
print(as.data.frame(summ_sub), row.names = FALSE)

# ─── 5. Spec curve plot ───────────────────────────────────────────────────────

plot_curve <- function(df_res, title_suffix = "") {
  d <- df_res %>%
    arrange(estimate) %>%
    mutate(
      rank      = row_number(),
      sig_label = ifelse(sig_05, "p<0.05", "p>=0.05")
    )

  n_sig <- sum(d$sig_05)
  pct   <- round(100 * n_sig / nrow(d))

  p_top <- ggplot(d, aes(x = rank, y = estimate)) +
    geom_hline(yintercept = 0, color = "#e74c3c", linewidth = 0.6, linetype = "dashed") +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = sig_label), alpha = 0.22) +
    geom_point(aes(color = sig_label), size = 0.7, shape = 16) +
    scale_color_manual(values = c("p<0.05" = "#2980b9", "p>=0.05" = "#95a5a6"), name = NULL) +
    scale_fill_manual( values = c("p<0.05" = "#2980b9", "p>=0.05" = "#bdc3c7"), name = NULL) +
    labs(
      title    = paste0("Specification Curve -- X = aa_intelligence_index", title_suffix),
      subtitle = paste0(nrow(d), " specifications | ", n_sig, " sig. at p<0.05 (", pct, "%)"),
      y = "Coefficient estimate", x = NULL
    ) +
    theme_bw(base_size = 10) +
    theme(legend.position = c(0.02, 0.98), legend.justification = c(0,1),
          legend.background = element_rect(fill = alpha("white", 0.8)),
          axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          panel.grid.minor = element_blank())

  d_long <- d %>%
    select(rank, y_var, controls, subsample, year_fe) %>%
    mutate(year_fe = ifelse(year_fe, "Year FE", "No FE")) %>%
    pivot_longer(-rank, names_to = "dim", values_to = "val") %>%
    mutate(dim = factor(dim,
      levels = c("year_fe","subsample","controls","y_var"),
      labels = c("Year FE","Subsample","Controls","Outcome")))

  p_bot <- ggplot(d_long, aes(x = rank, y = val)) +
    geom_point(shape = "|", size = 1.8, color = "#2c3e50") +
    facet_grid(dim ~ ., scales = "free_y", space = "free_y") +
    labs(x = "Specifications (ranked by estimate)", y = NULL) +
    theme_bw(base_size = 9) +
    theme(strip.text.y = element_text(angle = 0, hjust = 0, size = 8),
          panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
          axis.text.x = element_blank(), axis.ticks.x = element_blank())

  p_top / p_bot + plot_layout(heights = c(2.5, 2.2))
}

# Full spec curve
p_all <- plot_curve(df_res, " (relationship data)")
ggsave("specr_rel_curve_all.pdf", p_all, width = 14, height = 10)
cat("Saved: specr_rel_curve_all.pdf\n")

# Relationship-type subsamples only
rel_ss <- c("owner","investor","cloud","business_upstream","real_upstream",
            "business_downstream","real_downstream","competitor","positive_rel","downstream_comp")
df_rel_only <- df_res %>% filter(subsample %in% rel_ss)
if (nrow(df_rel_only) > 10) {
  p_rel <- plot_curve(df_rel_only, " (relationship subsamples only)")
  ggsave("specr_rel_curve_relonly.pdf", p_rel, width = 14, height = 10)
  cat("Saved: specr_rel_curve_relonly.pdf\n")
}

cat("\nDone.\n")
