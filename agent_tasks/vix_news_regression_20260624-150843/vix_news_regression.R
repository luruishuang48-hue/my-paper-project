#!/usr/bin/env Rscript
# =============================================================================
# vix_news_regression.R
# 使用6.21更新数据集（含VIX和新闻数量）重跑全套回归
# 数据: outputs/specr_621_clean.csv
# 输出: outputs/各类结果CSV
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

# ─── 工具函数 ──────────────────────────────────────────────────────────────────
stars <- function(p) {
  if (is.na(p)) return("")
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
}
extr <- function(mod, var) {
  tryCatch({
    b  <- coef(mod)[[var]]
    se <- sqrt(diag(vcov(mod)))[[var]]
    p  <- as.numeric(summary(mod)$coefficients[var, "Pr(>|t|)"])
    ci <- confint(mod)[var, ]
    s  <- stars(p)
    list(coef=round(b,6), se=round(se,6), p=signif(p,4),
         ci_lo=round(ci[[1]],6), ci_hi=round(ci[[2]],6),
         stars=s, n=mod$nobs, ncl=mod$nclusters, r2=round(summary(mod)$r.squared,4))
  }, error = function(e) NULL)
}
fmt <- function(r) if (is.null(r)) "N/A" else sprintf("%.5f%s", r$coef, r$stars)
fmt_se <- function(r) if (is.null(r)) "" else sprintf("(%.5f)", r$se)
fmt_p  <- function(r) if (is.null(r)) "n/a" else sprintf("%.4f%s", r$p, r$stars)

run_cr0 <- function(data, fml) {
  d <- data[complete.cases(data[, all.vars(fml)]), ]
  if (nrow(d) < 20 || length(unique(d$final_event_id)) < 3) return(NULL)
  tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
}
run_cr2 <- function(data, fml) {
  d <- data[complete.cases(data[, all.vars(fml)]), ]
  if (nrow(d) < 20 || length(unique(d$final_event_id)) < 3) return(NULL)
  tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR2"),
    error = function(e) NULL
  )
}

# ─── 加载数据 ─────────────────────────────────────────────────────────────────
df <- read.csv("outputs/specr_621_clean.csv", stringsAsFactors = FALSE,
               check.names = FALSE)

num_cols <- c(
  "release_year", "trend_month", "VIX",
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "ff3_car_1","ff3_car_5","ff3_car_10","ff3_car_20",
  "size_log_assets","bm_ratio","volatility","momentum",
  "aa_intelligence_index","aa_coding_index","aa_math_index","aa_media_elo",
  "is_open_weight","is_chinese_model","is_reasoning_model","is_coding_model",
  "is_multimodal","is_media_generation_model",
  "owner","investor","competitor","upstream","downstream",
  "business_upstream","real_upstream","business_downstream","real_downstream",
  "sent_mean_w1","sent_mean_w2","sent_mean_w5","sent_mean_w10","sent_mean_w20",
  "news_count_w1","news_count_w2","news_count_w5","news_count_w10","news_count_w20",
  "log_news_w1","log_news_w2","log_news_w5","log_news_w10","log_news_w20"
)
for (col in num_cols) {
  if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])
}

# 中心化 aa_intelligence_index
intel_mean <- mean(df$aa_intelligence_index, na.rm = TRUE)
df$intel_c <- df$aa_intelligence_index - intel_mean

cat(sprintf("Loaded: %d rows, %d events\n", nrow(df), length(unique(df$final_event_id))))
cat(sprintf("aa_intelligence non-null: %d\n", sum(!is.na(df$aa_intelligence_index))))
cat(sprintf("VIX non-null: %d | mean=%.2f sd=%.2f\n",
            sum(!is.na(df$VIX)), mean(df$VIX, na.rm=T), sd(df$VIX, na.rm=T)))
cat(sprintf("news_count_w1 non-null: %d\n", sum(!is.na(df$news_count_w1))))

# 所有结果收集
all_results <- list()

# ─────────────────────────────────────────────────────────────────────────────
# PART 1: 主回归 — aa_intelligence_index → CAR
# 三种控制组合: (A)原始控制, (B)+VIX, (C)+VIX+log_news
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 1: MAIN REGRESSION — aa_intelligence_index → CAR\n")
cat(strrep("=", 80), "\n")

base_ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
make_fml <- function(y, extra = character(0)) {
  rhs <- paste(c("aa_intelligence_index", base_ctrl, extra, "factor(release_year)"),
               collapse = " + ")
  as.formula(paste(y, "~", rhs))
}

windows_main <- c("car_1", "car_5", "car_20")
ctrl_specs <- list(
  "base"         = character(0),
  "base+VIX"     = "VIX",
  "base+VIX+news"= c("VIX", "log_news_w1")
)

rows_main <- list()
for (y in windows_main) {
  df_y <- df[!is.na(df$aa_intelligence_index), ]
  for (spec_name in names(ctrl_specs)) {
    extra <- ctrl_specs[[spec_name]]
    m <- run_cr0(df_y, make_fml(y, extra))
    r <- extr(m, "aa_intelligence_index")
    row <- data.frame(
      outcome   = y,
      spec      = spec_name,
      sample    = "all",
      coef      = if (is.null(r)) NA else r$coef,
      se        = if (is.null(r)) NA else r$se,
      p_value   = if (is.null(r)) NA else r$p,
      stars     = if (is.null(r)) "" else r$stars,
      ci_lo     = if (is.null(r)) NA else r$ci_lo,
      ci_hi     = if (is.null(r)) NA else r$ci_hi,
      n         = if (is.null(r)) NA else r$n,
      n_events  = if (is.null(r)) NA else r$ncl,
      r2        = if (is.null(r)) NA else r$r2
    )
    rows_main <- c(rows_main, list(row))
    cat(sprintf("  %-12s %-20s: coef=%s  p=%s  n=%s\n",
                y, spec_name, fmt(r), fmt_p(r),
                if (is.null(r)) "n/a" else as.character(r$n)))
  }
  # Closed source subsample
  df_closed <- df[!is.na(df$aa_intelligence_index) &
                  !is.na(df$is_open_weight) &
                  df$is_open_weight == 0, ]
  m_cl <- run_cr0(df_closed, make_fml(y, c("VIX", "log_news_w1")))
  r_cl <- extr(m_cl, "aa_intelligence_index")
  row_cl <- data.frame(
    outcome   = y, spec = "base+VIX+news", sample = "closed_source",
    coef = if (is.null(r_cl)) NA else r_cl$coef,
    se   = if (is.null(r_cl)) NA else r_cl$se,
    p_value = if (is.null(r_cl)) NA else r_cl$p,
    stars   = if (is.null(r_cl)) "" else r_cl$stars,
    ci_lo = if (is.null(r_cl)) NA else r_cl$ci_lo,
    ci_hi = if (is.null(r_cl)) NA else r_cl$ci_hi,
    n     = if (is.null(r_cl)) NA else r_cl$n,
    n_events = if (is.null(r_cl)) NA else r_cl$ncl,
    r2    = if (is.null(r_cl)) NA else r_cl$r2
  )
  rows_main <- c(rows_main, list(row_cl))
  cat(sprintf("  %-12s %-20s: coef=%s  p=%s  n=%s [closed]\n",
              y, "base+VIX+news", fmt(r_cl), fmt_p(r_cl),
              if (is.null(r_cl)) "n/a" else as.character(r_cl$n)))
}
tbl_main <- do.call(rbind, rows_main)
write.csv(tbl_main, "outputs/01_main_regression.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/01_main_regression.csv\n")
all_results[["main"]] <- tbl_main

# ─────────────────────────────────────────────────────────────────────────────
# PART 2: 关系子样本回归
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 2: RELATIONSHIP SUBSAMPLES\n")
cat(strrep("=", 80), "\n")

df_base <- df[!is.na(df$aa_intelligence_index), ]

rel_subsamples <- list(
  "competitor"    = df_base[!is.na(df_base$competitor)    & df_base$competitor    == 1, ],
  "downstream"    = df_base[!is.na(df_base$downstream)    & df_base$downstream    == 1, ],
  "biz_down"      = df_base[!is.na(df_base$business_downstream) & df_base$business_downstream == 1, ],
  "real_down"     = df_base[!is.na(df_base$real_downstream)     & df_base$real_downstream == 1, ],
  "upstream"      = df_base[!is.na(df_base$upstream)      & df_base$upstream      == 1, ],
  "owner_invest"  = df_base[(!is.na(df_base$owner)        & df_base$owner == 1) |
                             (!is.na(df_base$investor)     & df_base$investor == 1), ]
)

rows_rel <- list()
windows_rel <- c("car_1", "car_5", "car_20")
fml_ctrl <- c("VIX", "log_news_w1")

for (rel_name in names(rel_subsamples)) {
  sub <- rel_subsamples[[rel_name]]
  cat(sprintf("\n  [%s] n=%d, events=%d\n", rel_name, nrow(sub), length(unique(sub$final_event_id))))
  for (y in windows_rel) {
    # Base controls only
    m_b  <- run_cr0(sub, make_fml(y))
    r_b  <- extr(m_b, "aa_intelligence_index")
    # With VIX + news
    m_vn <- run_cr0(sub, make_fml(y, fml_ctrl))
    r_vn <- extr(m_vn, "aa_intelligence_index")
    cat(sprintf("    %s | base: %s (%s) | +VIX+news: %s (%s)\n",
                y, fmt(r_b), fmt_p(r_b), fmt(r_vn), fmt_p(r_vn)))
    for (spec in list(list("base", r_b), list("base+VIX+news", r_vn))) {
      r <- spec[[2]]
      rows_rel <- c(rows_rel, list(data.frame(
        relationship = rel_name, outcome = y, spec = spec[[1]],
        coef     = if(is.null(r)) NA else r$coef,
        se       = if(is.null(r)) NA else r$se,
        p_value  = if(is.null(r)) NA else r$p,
        stars    = if(is.null(r)) "" else r$stars,
        ci_lo    = if(is.null(r)) NA else r$ci_lo,
        ci_hi    = if(is.null(r)) NA else r$ci_hi,
        n        = if(is.null(r)) NA else r$n,
        n_events = if(is.null(r)) NA else r$ncl,
        r2       = if(is.null(r)) NA else r$r2
      )))
    }
  }
}
tbl_rel <- do.call(rbind, rows_rel)
write.csv(tbl_rel, "outputs/02_relationship_subsamples.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/02_relationship_subsamples.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 3: 行业异质性
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 3: INDUSTRY HETEROGENEITY\n")
cat(strrep("=", 80), "\n")

top_industries <- c("软件","半导体和半导体设备","技术硬件、存储和外围设备",
                    "IT服务","互联网服务和基础设施","互联网零售")
df_base$ind_group <- ifelse(df_base$industry_2 %in% top_industries,
                             df_base$industry_2, "其他/非IT")

rows_ind <- list()
for (g in c(top_industries, "其他/非IT")) {
  sub <- df_base[df_base$ind_group == g & !is.na(df_base$car_20), ]
  if (nrow(sub) < 20) next
  m  <- run_cr0(sub, make_fml("car_20", fml_ctrl))
  r  <- extr(m, "aa_intelligence_index")
  cat(sprintf("  %-35s n=%4d ev=%2d  coef=%s  p=%s\n",
              g, if(is.null(r)) nrow(sub) else r$n,
                 if(is.null(r)) length(unique(sub$final_event_id)) else r$ncl,
                 fmt(r), fmt_p(r)))
  rows_ind <- c(rows_ind, list(data.frame(
    industry = g,
    n = if(is.null(r)) nrow(sub) else r$n,
    n_events = if(is.null(r)) length(unique(sub$final_event_id)) else r$ncl,
    coef = if(is.null(r)) NA else r$coef, se = if(is.null(r)) NA else r$se,
    p_value = if(is.null(r)) NA else r$p, stars = if(is.null(r)) "" else r$stars,
    r2 = if(is.null(r)) NA else r$r2
  )))
}
if (length(rows_ind) > 0) {
  tbl_ind <- do.call(rbind, rows_ind)
  write.csv(tbl_ind, "outputs/03_industry_heterogeneity.csv", row.names = FALSE)
  cat("\n  -> Saved: outputs/03_industry_heterogeneity.csv\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# PART 4: Mag7 vs non-Mag7
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 4: MAG7 vs NON-MAG7\n")
cat(strrep("=", 80), "\n")

mag7_names <- c("苹果","微软","英伟达","Alphabet（谷歌）","亚马逊","Meta（Facebook）","特斯拉")
df_base$mag7 <- as.integer(df_base$company %in% mag7_names)
df_m7    <- df_base[df_base$mag7 == 1, ]
df_nonm7 <- df_base[df_base$mag7 == 0, ]

cat(sprintf("Mag7: n=%d ev=%d | non-Mag7: n=%d ev=%d\n",
            nrow(df_m7), length(unique(df_m7$final_event_id)),
            nrow(df_nonm7), length(unique(df_nonm7$final_event_id))))

rows_mag7 <- list()
for (y in c("car_1", "car_5", "car_20")) {
  for (spec in list(list("base", character(0)), list("base+VIX+news", fml_ctrl))) {
    spec_name <- spec[[1]]; extra <- spec[[2]]
    r7  <- extr(run_cr0(df_m7,    make_fml(y, extra)), "aa_intelligence_index")
    rn7 <- extr(run_cr0(df_nonm7, make_fml(y, extra)), "aa_intelligence_index")
    cat(sprintf("  %-12s %-20s | Mag7: %s (%s) | nonMag7: %s (%s)\n",
                y, spec_name, fmt(r7), fmt_p(r7), fmt(rn7), fmt_p(rn7)))
    for (gr in list(list("mag7",r7), list("non_mag7",rn7))) {
      rows_mag7 <- c(rows_mag7, list(data.frame(
        group = gr[[1]], outcome = y, spec = spec_name,
        coef = if(is.null(gr[[2]])) NA else gr[[2]]$coef,
        se   = if(is.null(gr[[2]])) NA else gr[[2]]$se,
        p_value = if(is.null(gr[[2]])) NA else gr[[2]]$p,
        stars   = if(is.null(gr[[2]])) "" else gr[[2]]$stars,
        n = if(is.null(gr[[2]])) NA else gr[[2]]$n,
        n_events = if(is.null(gr[[2]])) NA else gr[[2]]$ncl,
        r2 = if(is.null(gr[[2]])) NA else gr[[2]]$r2
      )))
    }
  }
}
tbl_mag7 <- do.call(rbind, rows_mag7)
write.csv(tbl_mag7, "outputs/04_mag7_vs_nonmag7.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/04_mag7_vs_nonmag7.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 5: 时间趋势 (intelligence × trend_month)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 5: TIME TREND (intelligence × trend_month)\n")
cat(strrep("=", 80), "\n")

df_B <- df_base[!is.na(df_base$car_20) & !is.na(df_base$trend_month), ]

fml_trend_base <- car_20 ~ aa_intelligence_index + trend_month +
                  aa_intelligence_index:trend_month +
                  size_log_assets + bm_ratio + volatility + momentum
fml_trend_vix  <- car_20 ~ aa_intelligence_index + trend_month +
                  aa_intelligence_index:trend_month +
                  size_log_assets + bm_ratio + volatility + momentum + VIX + log_news_w1

for (spec in list(list("base", fml_trend_base), list("base+VIX+news", fml_trend_vix))) {
  m <- run_cr0(df_B, spec[[2]])
  if (!is.null(m)) {
    sm <- summary(m)$coefficients
    cat(sprintf("\n  Spec: %s\n", spec[[1]]))
    for (v in c("aa_intelligence_index", "trend_month", "aa_intelligence_index:trend_month")) {
      if (v %in% rownames(sm)) {
        b <- sm[v, "Estimate"]; p <- sm[v, "Pr(>|t|)"]
        cat(sprintf("    %-40s  b=%+.5f  p=%.4f%s\n", v, b, p, stars(p)))
      }
    }
    cat(sprintf("    n=%d, events=%d, R2=%.4f\n", m$nobs, m$nclusters, summary(m)$r.squared))
  }
}

# 按年分解
cat("\n--- By Year ---\n")
rows_yr <- list()
for (yr in sort(unique(df_B$release_year[!is.na(df_B$release_year)]))) {
  sub_yr <- df_B[df_B$release_year == yr, ]
  m_yr <- tryCatch({
    fml_yr <- car_20 ~ aa_intelligence_index + size_log_assets + bm_ratio + volatility + momentum + VIX + log_news_w1
    run_cr0(sub_yr, fml_yr)
  }, error = function(e) NULL)
  r_yr <- extr(m_yr, "aa_intelligence_index")
  cat(sprintf("  Year %s: coef=%s  p=%s  n=%s\n",
              yr, fmt(r_yr), fmt_p(r_yr),
              if(is.null(r_yr)) "n/a" else as.character(r_yr$n)))
  if (!is.null(r_yr)) {
    rows_yr <- c(rows_yr, list(data.frame(
      year=yr, coef=r_yr$coef, se=r_yr$se, p_value=r_yr$p, stars=r_yr$stars,
      n=r_yr$n, n_events=r_yr$ncl, r2=r_yr$r2
    )))
  }
}
if (length(rows_yr) > 0) {
  tbl_yr <- do.call(rbind, rows_yr)
  write.csv(tbl_yr, "outputs/05_by_year.csv", row.names = FALSE)
  cat("\n  -> Saved: outputs/05_by_year.csv\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# PART 6: FF3 稳健性
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 6: FF3 ROBUSTNESS\n")
cat(strrep("=", 80), "\n")

rows_ff3 <- list()
for (y in c("ff3_car_1", "ff3_car_20")) {
  for (spec in list(list("base", character(0)), list("base+VIX+news", fml_ctrl))) {
    m <- run_cr0(df_base, make_fml(y, spec[[2]]))
    r <- extr(m, "aa_intelligence_index")
    cat(sprintf("  %-15s %-20s: coef=%s  p=%s  n=%s\n",
                y, spec[[1]], fmt(r), fmt_p(r),
                if(is.null(r)) "n/a" else as.character(r$n)))
    rows_ff3 <- c(rows_ff3, list(data.frame(
      outcome=y, spec=spec[[1]],
      coef = if(is.null(r)) NA else r$coef, se = if(is.null(r)) NA else r$se,
      p_value = if(is.null(r)) NA else r$p, stars = if(is.null(r)) "" else r$stars,
      n = if(is.null(r)) NA else r$n, n_events = if(is.null(r)) NA else r$ncl,
      r2 = if(is.null(r)) NA else r$r2
    )))
  }
}
tbl_ff3 <- do.call(rbind, rows_ff3)
write.csv(tbl_ff3, "outputs/06_ff3_robustness.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/06_ff3_robustness.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 7: VIX 作为调节变量 (高 vs 低 VIX)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 7: VIX AS MODERATOR (high vs low)\n")
cat(strrep("=", 80), "\n")

vix_median <- median(df_base$VIX, na.rm = TRUE)
cat(sprintf("VIX median split: %.2f\n", vix_median))
df_hi_vix <- df_base[!is.na(df_base$VIX) & df_base$VIX > vix_median, ]
df_lo_vix <- df_base[!is.na(df_base$VIX) & df_base$VIX <= vix_median, ]
cat(sprintf("  High VIX (>%.1f): n=%d ev=%d\n", vix_median, nrow(df_hi_vix),
            length(unique(df_hi_vix$final_event_id))))
cat(sprintf("  Low  VIX (<=%.1f): n=%d ev=%d\n", vix_median, nrow(df_lo_vix),
            length(unique(df_lo_vix$final_event_id))))

rows_vix_mod <- list()
for (y in c("car_1", "car_20")) {
  r_hi <- extr(run_cr0(df_hi_vix, make_fml(y, "log_news_w1")), "aa_intelligence_index")
  r_lo <- extr(run_cr0(df_lo_vix, make_fml(y, "log_news_w1")), "aa_intelligence_index")
  cat(sprintf("  %-10s | HiVIX: %s (%s) | LoVIX: %s (%s)\n",
              y, fmt(r_hi), fmt_p(r_hi), fmt(r_lo), fmt_p(r_lo)))
  rows_vix_mod <- c(rows_vix_mod,
    list(data.frame(group="high_vix", outcome=y,
                    coef=if(is.null(r_hi)) NA else r_hi$coef,
                    se=if(is.null(r_hi)) NA else r_hi$se,
                    p_value=if(is.null(r_hi)) NA else r_hi$p,
                    stars=if(is.null(r_hi)) "" else r_hi$stars,
                    n=if(is.null(r_hi)) NA else r_hi$n,
                    n_events=if(is.null(r_hi)) NA else r_hi$ncl)),
    list(data.frame(group="low_vix", outcome=y,
                    coef=if(is.null(r_lo)) NA else r_lo$coef,
                    se=if(is.null(r_lo)) NA else r_lo$se,
                    p_value=if(is.null(r_lo)) NA else r_lo$p,
                    stars=if(is.null(r_lo)) "" else r_lo$stars,
                    n=if(is.null(r_lo)) NA else r_lo$n,
                    n_events=if(is.null(r_lo)) NA else r_lo$ncl))
  )
}

# VIX 交互项
cat("\n--- VIX interaction: intelligence × VIX → car_20 ---\n")
df_int <- df_base[!is.na(df_base$car_20) & !is.na(df_base$VIX), ]
df_int$VIX_c <- df_int$VIX - mean(df_int$VIX, na.rm = TRUE)
fml_vix_int <- car_20 ~ aa_intelligence_index + VIX_c +
               aa_intelligence_index:VIX_c +
               size_log_assets + bm_ratio + volatility + momentum + log_news_w1
m_vix_int <- run_cr0(df_int, fml_vix_int)
if (!is.null(m_vix_int)) {
  sm <- summary(m_vix_int)$coefficients
  for (v in c("aa_intelligence_index", "VIX_c", "aa_intelligence_index:VIX_c")) {
    if (v %in% rownames(sm)) {
      b <- sm[v, "Estimate"]; p <- sm[v, "Pr(>|t|)"]
      cat(sprintf("  %-40s  b=%+.5f  p=%.4f%s\n", v, b, p, stars(p)))
    }
  }
}

tbl_vix_mod <- do.call(rbind, rows_vix_mod)
write.csv(tbl_vix_mod, "outputs/07_vix_moderator.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/07_vix_moderator.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 8: 新闻数量调节效应
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 8: NEWS COUNT AS MODERATOR (high vs low attention)\n")
cat(strrep("=", 80), "\n")

# 缺失新闻数量视为 0（无媒体报道）
df_base$news_count_w1_fill <- ifelse(is.na(df_base$news_count_w1), 0, df_base$news_count_w1)
news_median <- median(df_base$news_count_w1_fill[!is.na(df_base$car_20)])
cat(sprintf("news_count_w1 median (missing=0): %.0f\n", news_median))
cat(sprintf("  Zero-news obs: %d (%.1f%%)\n",
            sum(df_base$news_count_w1_fill == 0, na.rm=TRUE),
            100 * mean(df_base$news_count_w1_fill == 0, na.rm=TRUE)))

df_hi_news <- df_base[!is.na(df_base$car_20) & df_base$news_count_w1_fill > news_median, ]
df_lo_news <- df_base[!is.na(df_base$car_20) & df_base$news_count_w1_fill <= news_median, ]
cat(sprintf("  High news (>%d): n=%d ev=%d | Low/zero news (≤%d): n=%d ev=%d\n",
            news_median, nrow(df_hi_news), length(unique(df_hi_news$final_event_id)),
            news_median, nrow(df_lo_news), length(unique(df_lo_news$final_event_id))))

rows_news_mod <- list()
for (y in c("car_1", "car_20")) {
  r_hi <- extr(run_cr0(df_hi_news, make_fml(y, "VIX")), "aa_intelligence_index")
  r_lo <- extr(run_cr0(df_lo_news, make_fml(y, "VIX")), "aa_intelligence_index")
  cat(sprintf("  %-10s | HiNews: %s (%s) | LoNews: %s (%s)\n",
              y, fmt(r_hi), fmt_p(r_hi), fmt(r_lo), fmt_p(r_lo)))
  rows_news_mod <- c(rows_news_mod,
    list(data.frame(group="high_news", outcome=y,
                    coef=if(is.null(r_hi)) NA else r_hi$coef,
                    se=if(is.null(r_hi)) NA else r_hi$se,
                    p_value=if(is.null(r_hi)) NA else r_hi$p,
                    stars=if(is.null(r_hi)) "" else r_hi$stars,
                    n=if(is.null(r_hi)) NA else r_hi$n,
                    n_events=if(is.null(r_hi)) NA else r_hi$ncl)),
    list(data.frame(group="low_news", outcome=y,
                    coef=if(is.null(r_lo)) NA else r_lo$coef,
                    se=if(is.null(r_lo)) NA else r_lo$se,
                    p_value=if(is.null(r_lo)) NA else r_lo$p,
                    stars=if(is.null(r_lo)) "" else r_lo$stars,
                    n=if(is.null(r_lo)) NA else r_lo$n,
                    n_events=if(is.null(r_lo)) NA else r_lo$ncl))
  )
}

# 新闻数量交互项
cat("\n--- News interaction: intelligence × log_news_w1 → car_20 ---\n")
df_ni <- df_base[!is.na(df_base$car_20) & !is.na(df_base$log_news_w1), ]
df_ni$log_news_c <- df_ni$log_news_w1 - mean(df_ni$log_news_w1, na.rm = TRUE)
fml_news_int <- car_20 ~ aa_intelligence_index + log_news_c +
                aa_intelligence_index:log_news_c +
                size_log_assets + bm_ratio + volatility + momentum + VIX
m_news_int <- run_cr0(df_ni, fml_news_int)
if (!is.null(m_news_int)) {
  sm <- summary(m_news_int)$coefficients
  for (v in c("aa_intelligence_index", "log_news_c", "aa_intelligence_index:log_news_c")) {
    if (v %in% rownames(sm)) {
      b <- sm[v, "Estimate"]; p <- sm[v, "Pr(>|t|)"]
      cat(sprintf("  %-45s  b=%+.5f  p=%.4f%s\n", v, b, p, stars(p)))
    }
  }
  cat(sprintf("  n=%d, events=%d, R2=%.4f\n", m_news_int$nobs, m_news_int$nclusters,
              summary(m_news_int)$r.squared))
}

# ─── 交叉：高低新闻 × 开源闭源 ────────────────────────────────────────────────
cat("\n--- Cross: news level × open/closed source → car_1 & car_20 ---\n")
cat(sprintf("  %-25s %4s  %10s %8s  %10s %8s\n", "Group", "ev", "car_1", "p", "car_20", "p"))
cat(sprintf("  %s\n", strrep("-", 75)))

cross_rows <- list()
for (news_grp in c("hi_news", "lo_news")) {
  d_news <- if (news_grp == "hi_news") df_hi_news else df_lo_news
  news_label <- if (news_grp == "hi_news") sprintf("HiNews(>%d)", news_median) else
                                            sprintf("LoNews(≤%d)", news_median)
  for (src_grp in c("open", "closed")) {
    d <- d_news[!is.na(d_news$is_open_weight) &
                d_news$is_open_weight == if (src_grp == "open") 1 else 0, ]
    label <- paste0(news_label, " × ", src_grp)
    m1  <- run_cr0(d, make_fml("car_1",  "VIX"))
    m20 <- run_cr0(d, make_fml("car_20", "VIX"))
    r1  <- extr(m1,  "aa_intelligence_index")
    r20 <- extr(m20, "aa_intelligence_index")
    cat(sprintf("  %-25s %4s  %10s %8s  %10s %8s\n",
                label,
                if(is.null(r20)) length(unique(d$final_event_id)) else r20$ncl,
                if(is.null(r1))  "n/a" else formatC(r1$coef,  format="f", digits=5),
                if(is.null(r1))  "n/a" else sprintf("%.4f%s", r1$p,  r1$stars),
                if(is.null(r20)) "n/a" else formatC(r20$coef, format="f", digits=5),
                if(is.null(r20)) "n/a" else sprintf("%.4f%s", r20$p, r20$stars)))
    cross_rows <- c(cross_rows, list(data.frame(
      news_group = news_grp, source_group = src_grp,
      n_events = if(is.null(r20)) length(unique(d$final_event_id)) else r20$ncl,
      car1_coef  = if(is.null(r1))  NA else r1$coef,
      car1_p     = if(is.null(r1))  NA else r1$p,
      car1_stars = if(is.null(r1))  "" else r1$stars,
      car20_coef = if(is.null(r20)) NA else r20$coef,
      car20_p    = if(is.null(r20)) NA else r20$p,
      car20_stars= if(is.null(r20)) "" else r20$stars
    )))
  }
}
if (length(cross_rows) > 0) {
  tbl_cross <- do.call(rbind, cross_rows)
  write.csv(tbl_cross, "outputs/08b_news_x_source.csv", row.names = FALSE)
  cat("\n  -> Saved: outputs/08b_news_x_source.csv\n")
}

tbl_news_mod <- do.call(rbind, rows_news_mod)
write.csv(tbl_news_mod, "outputs/08_news_moderator.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/08_news_moderator.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 9: 媒体情绪调节
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 9: MEDIA SENTIMENT EFFECT (with VIX+news controls)\n")
cat(strrep("=", 80), "\n")

df_sent <- df_base[!is.na(df_base$sent_mean_w5), ]
cat(sprintf("  Sentiment w5 non-null: %d obs, %d events\n",
            nrow(df_sent), length(unique(df_sent$final_event_id))))

# 情绪作为预测变量 (独立效应)
rows_sent <- list()
for (w_str in c("1","2","5","10","20")) {
  y <- "car_20"
  sent_col <- paste0("sent_mean_w", w_str)
  news_col  <- paste0("log_news_w", w_str)
  if (!sent_col %in% names(df_base)) next
  d <- df_base[!is.na(df_base[[sent_col]]) & !is.na(df_base$car_20), ]
  fml_sent <- as.formula(paste(
    "car_20 ~", sent_col, "+ aa_intelligence_index +",
    paste(base_ctrl, collapse = "+"), "+ VIX +", news_col, "+ factor(release_year)"
  ))
  m <- run_cr0(d, fml_sent)
  r_sent  <- extr(m, sent_col)
  r_intel <- extr(m, "aa_intelligence_index")
  cat(sprintf("  w(%s,%s) | sent: %s (%s) | intel: %s (%s) | n=%s\n",
              w_str, w_str, fmt(r_sent), fmt_p(r_sent), fmt(r_intel), fmt_p(r_intel),
              if(is.null(r_sent)) "n/a" else as.character(r_sent$n)))
  rows_sent <- c(rows_sent, list(data.frame(
    window = w_str,
    var = "sentiment",
    coef = if(is.null(r_sent)) NA else r_sent$coef,
    se   = if(is.null(r_sent)) NA else r_sent$se,
    p_value = if(is.null(r_sent)) NA else r_sent$p,
    stars   = if(is.null(r_sent)) "" else r_sent$stars,
    intel_coef = if(is.null(r_intel)) NA else r_intel$coef,
    intel_p    = if(is.null(r_intel)) NA else r_intel$p,
    intel_stars= if(is.null(r_intel)) "" else r_intel$stars,
    n = if(is.null(r_sent)) NA else r_sent$n,
    n_events = if(is.null(r_sent)) NA else r_sent$ncl
  )))
}
if (length(rows_sent) > 0) {
  tbl_sent <- do.call(rbind, rows_sent)
  write.csv(tbl_sent, "outputs/09_media_sentiment.csv", row.names = FALSE)
  cat("\n  -> Saved: outputs/09_media_sentiment.csv\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# PART 10: 多窗口汇总 (全套 car_1~car_20, 含VIX+news)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 10: ALL WINDOWS SUMMARY (base+VIX+news)\n")
cat(strrep("=", 80), "\n")

all_windows <- c("car_1","car_2","car_3","car_5","car_10","car_15","car_20")
rows_all_win <- list()
df_full <- df[!is.na(df$aa_intelligence_index), ]

cat(sprintf("  %-10s %10s %10s %8s %6s %4s\n",
            "Window", "Coef", "SE", "p", "Sig", "N"))
for (y in all_windows) {
  m <- run_cr0(df_full, make_fml(y, fml_ctrl))
  r <- extr(m, "aa_intelligence_index")
  cat(sprintf("  %-10s %10s %10s %8s %6s %4s\n",
              y,
              if(is.null(r)) "n/a" else formatC(r$coef, format="f", digits=5),
              if(is.null(r)) "" else sprintf("(%.5f)", r$se),
              if(is.null(r)) "n/a" else sprintf("%.4f", r$p),
              if(is.null(r)) "" else r$stars,
              if(is.null(r)) "n/a" else as.character(r$n)))
  rows_all_win <- c(rows_all_win, list(data.frame(
    outcome = y,
    coef = if(is.null(r)) NA else r$coef, se = if(is.null(r)) NA else r$se,
    p_value = if(is.null(r)) NA else r$p, stars = if(is.null(r)) "" else r$stars,
    ci_lo = if(is.null(r)) NA else r$ci_lo, ci_hi = if(is.null(r)) NA else r$ci_hi,
    n = if(is.null(r)) NA else r$n, n_events = if(is.null(r)) NA else r$ncl,
    r2 = if(is.null(r)) NA else r$r2
  )))
}

# FF3 windows
cat("\n  --- FF3 ---\n")
for (y in c("ff3_car_1","ff3_car_5","ff3_car_20")) {
  m <- run_cr0(df_full, make_fml(y, fml_ctrl))
  r <- extr(m, "aa_intelligence_index")
  cat(sprintf("  %-10s %10s %10s %8s %6s %4s\n",
              y,
              if(is.null(r)) "n/a" else formatC(r$coef, format="f", digits=5),
              if(is.null(r)) "" else sprintf("(%.5f)", r$se),
              if(is.null(r)) "n/a" else sprintf("%.4f", r$p),
              if(is.null(r)) "" else r$stars,
              if(is.null(r)) "n/a" else as.character(r$n)))
  rows_all_win <- c(rows_all_win, list(data.frame(
    outcome = y,
    coef = if(is.null(r)) NA else r$coef, se = if(is.null(r)) NA else r$se,
    p_value = if(is.null(r)) NA else r$p, stars = if(is.null(r)) "" else r$stars,
    ci_lo = if(is.null(r)) NA else r$ci_lo, ci_hi = if(is.null(r)) NA else r$ci_hi,
    n = if(is.null(r)) NA else r$n, n_events = if(is.null(r)) NA else r$ncl,
    r2 = if(is.null(r)) NA else r$r2
  )))
}

tbl_all_win <- do.call(rbind, rows_all_win)
write.csv(tbl_all_win, "outputs/10_all_windows_summary.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/10_all_windows_summary.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 11: 开源 vs 闭源 (全窗口)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("PART 11: OPEN vs CLOSED SOURCE\n")
cat(strrep("=", 80), "\n")

df_open   <- df[!is.na(df$aa_intelligence_index) & !is.na(df$is_open_weight) & df$is_open_weight == 1, ]
df_closed <- df[!is.na(df$aa_intelligence_index) & !is.na(df$is_open_weight) & df$is_open_weight == 0, ]
cat(sprintf("Open: n=%d ev=%d | Closed: n=%d ev=%d\n",
            nrow(df_open), length(unique(df_open$final_event_id)),
            nrow(df_closed), length(unique(df_closed$final_event_id))))

rows_oc <- list()
for (y in c("car_1", "car_5", "car_20")) {
  for (spec in list(list("base", character(0)), list("base+VIX+news", fml_ctrl))) {
    r_open   <- extr(run_cr0(df_open,   make_fml(y, spec[[2]])), "aa_intelligence_index")
    r_closed <- extr(run_cr0(df_closed, make_fml(y, spec[[2]])), "aa_intelligence_index")
    cat(sprintf("  %-10s %-20s | Open: %s (%s) | Closed: %s (%s)\n",
                y, spec[[1]], fmt(r_open), fmt_p(r_open), fmt(r_closed), fmt_p(r_closed)))
    for (gr in list(list("open", r_open), list("closed", r_closed))) {
      rows_oc <- c(rows_oc, list(data.frame(
        group = gr[[1]], outcome = y, spec = spec[[1]],
        coef = if(is.null(gr[[2]])) NA else gr[[2]]$coef,
        se   = if(is.null(gr[[2]])) NA else gr[[2]]$se,
        p_value = if(is.null(gr[[2]])) NA else gr[[2]]$p,
        stars   = if(is.null(gr[[2]])) "" else gr[[2]]$stars,
        n = if(is.null(gr[[2]])) NA else gr[[2]]$n,
        n_events = if(is.null(gr[[2]])) NA else gr[[2]]$ncl,
        r2 = if(is.null(gr[[2]])) NA else gr[[2]]$r2
      )))
    }
  }
}
tbl_oc <- do.call(rbind, rows_oc)
write.csv(tbl_oc, "outputs/11_open_vs_closed.csv", row.names = FALSE)
cat("\n  -> Saved: outputs/11_open_vs_closed.csv\n")

# ─── 完成 ─────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 80), "\n")
cat("ALL REGRESSIONS COMPLETE\n")
cat("Output files in: outputs/\n")
cat(strrep("=", 80), "\n")
