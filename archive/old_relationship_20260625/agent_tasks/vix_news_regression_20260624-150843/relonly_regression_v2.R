#!/usr/bin/env Rscript
# =============================================================================
# relonly_regression_v2.R
# v2: 迁移到新的 8 维关系编码 schema (data/panel/specr_rel_clean.csv)
#   旧: owner, investor, cloud, business_upstream, real_upstream,
#       business_downstream, real_downstream, competitor
#   新: upstream_hardware, upstream_cloud, downstream_integrator,
#       downstream_deployer, downstream_enabler, competitor,
#       is_investor, is_owner
# 关系列通过 (final_event_id, company_id) 从 specr_rel_clean.csv merge 进来，
# 覆盖 specr_621_clean.csv 里原有的旧 schema 派生列。
# 剔除无关系标签行（relationship IS NULL）后重跑全套主要回归
# 全样本: 5160行 → 有关系行: 3143行（61%，与v1一致，过滤逻辑未变）
# 输出: outputs/r_XX_*_v2.csv（前缀r_、后缀_v2，不覆盖v1结果）
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

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
    list(coef=round(b,6), se=round(se,6), p=signif(p,4),
         ci_lo=round(ci[[1]],6), ci_hi=round(ci[[2]],6),
         stars=stars(p), n=mod$nobs, ncl=mod$nclusters,
         r2=round(summary(mod)$r.squared, 4))
  }, error = function(e) NULL)
}
fmt   <- function(r) if (is.null(r)) "N/A"  else sprintf("%.5f%s", r$coef, r$stars)
fmt_p <- function(r) if (is.null(r)) "n/a"  else sprintf("%.4f%s", r$p, r$stars)

run_cr0 <- function(data, fml) {
  d <- data[complete.cases(data[, all.vars(fml)]), ]
  if (nrow(d) < 20 || length(unique(d$final_event_id)) < 3) return(NULL)
  tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
}

# ─── 路径处理：脚本可从仓库根目录或本目录运行，自动定位 ──────────────────────
# script目录 = agent_tasks/vix_news_regression_20260624-150843/
get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  f <- sub("^--file=", "", args[grepl("^--file=", args)])
  if (length(f) == 0) return(getwd())
  nf <- normalizePath(f)
  dirname(nf)
}
script_dir <- get_script_dir()
# repo根 = script目录向上两级 (agent_tasks/<task>/  ->  agent_tasks/  -> repo root)
repo_root  <- normalizePath(file.path(script_dir, "..", ".."))

# ─── 加载数据 ─────────────────────────────────────────────────────────────────
df_all <- read.csv(file.path(script_dir, "outputs/specr_621_clean.csv"),
                   stringsAsFactors = FALSE, check.names = FALSE)

# ─── v2: 合并新 8 维关系编码（覆盖旧 schema 派生列）──────────────────────────
# specr_621_clean.csv 里的 owner/investor/competitor/business_upstream/
# real_upstream/business_downstream/real_downstream/upstream/downstream 是
# prep_621.py 从旧版 relationship 字符串列派生的，对应旧 schema。
# 这里改为从 data/panel/specr_rel_clean.csv（新 schema 权威源）按
# (final_event_id, company_id) merge 新的 8 个维度，丢弃旧派生列，避免混用。
rel_new <- read.csv(file.path(repo_root, "data/panel/specr_rel_clean.csv"),
                     stringsAsFactors = FALSE, check.names = FALSE)
new_rel_cols <- c("upstream_hardware","upstream_cloud","downstream_integrator",
                   "downstream_deployer","downstream_enabler","competitor",
                   "is_investor","is_owner")
old_rel_cols <- c("owner","investor","competitor","business_upstream","real_upstream",
                   "business_downstream","real_downstream","upstream","downstream")
df_all <- df_all[, !names(df_all) %in% new_rel_cols]          # 防止重名冲突
df_all <- df_all[, !names(df_all) %in% old_rel_cols]          # 移除旧 schema 派生列
df_all <- merge(df_all,
                 rel_new[, c("final_event_id","company_id", new_rel_cols)],
                 by = c("final_event_id","company_id"), all.x = TRUE, sort = FALSE)
stopifnot(nrow(df_all) == 5160)
cat(sprintf("已合并新关系编码: %d 行匹配, %d 行未匹配新schema(NA)\n",
            sum(!is.na(df_all$upstream_hardware)), sum(is.na(df_all$upstream_hardware))))

num_cols <- c(
  "release_year","trend_month","VIX",
  "car_1","car_2","car_3","car_5","car_10","car_15","car_20",
  "ff3_car_1","ff3_car_5","ff3_car_10","ff3_car_20",
  "size_log_assets","bm_ratio","volatility","momentum",
  "aa_intelligence_index","aa_coding_index","aa_math_index","aa_media_elo",
  "is_open_weight","is_chinese_model","is_reasoning_model","is_coding_model",
  "is_multimodal","is_media_generation_model",
  "upstream_hardware","upstream_cloud","downstream_integrator",
  "downstream_deployer","downstream_enabler","competitor",
  "is_investor","is_owner",
  "sent_mean_w1","sent_mean_w20",
  "news_count_w1","log_news_w1","log_news_w20"
)
for (col in num_cols) {
  if (col %in% names(df_all)) df_all[[col]] <- as.numeric(df_all[[col]])
}

# v2: 新 schema 没有旧的复合 upstream/downstream 列，按角色映射重新构造，
# 用于与 v1 的 "upstream" / "downstream" 子样本对照（见 codebook 角色映射）：
#   旧 upstream  (business_upstream | real_upstream)  -> upstream_hardware | upstream_cloud
#   旧 downstream(business_downstream | real_downstream) -> integrator | deployer | enabler
df_all$upstream_any   <- as.integer(df_all$upstream_hardware == 1 | df_all$upstream_cloud == 1)
df_all$downstream_any <- as.integer(df_all$downstream_integrator == 1 |
                                     df_all$downstream_deployer   == 1 |
                                     df_all$downstream_enabler    == 1)

# ─── 核心过滤：只保留有关系标签的行（CSV里空值读成""而非NA）────────────────
df <- df_all[!is.na(df_all$relationship) & trimws(df_all$relationship) != "", ]

cat(sprintf("全样本:      %d 行, %d 事件\n", nrow(df_all), length(unique(df_all$final_event_id))))
cat(sprintf("有关系标签:  %d 行, %d 事件 (%.1f%%)\n",
            nrow(df), length(unique(df$final_event_id)),
            100 * nrow(df) / nrow(df_all)))
cat(sprintf("剔除无标签:  %d 行 (%.1f%%)\n",
            nrow(df_all) - nrow(df), 100 * (1 - nrow(df)/nrow(df_all))))

cat("\n关系标签分布:\n")
print(table(df$relationship))
cat("\n")

# 控制变量
base_ctrl <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
fml_ctrl  <- c("VIX", "log_news_w1")
make_fml  <- function(y, extra = character(0)) {
  rhs <- paste(c("aa_intelligence_index", base_ctrl, extra, "factor(release_year)"),
               collapse = " + ")
  as.formula(paste(y, "~", rhs))
}

df_base <- df[!is.na(df$aa_intelligence_index), ]
cat(sprintf("有AA指数的有关系行: %d 行, %d 事件\n\n",
            nrow(df_base), length(unique(df_base$final_event_id))))

# ─────────────────────────────────────────────────────────────────────────────
# PART R1: 主回归（与全样本对比）
# ─────────────────────────────────────────────────────────────────────────────
cat(strrep("=", 70), "\n")
cat("PART R1: 主回归（仅有关系标签行）\n")
cat(strrep("=", 70), "\n")

rows_main <- list()
for (y in c("car_1", "car_5", "car_20")) {
  for (spec_name in c("base", "base+VIX", "base+VIX+news")) {
    extra <- switch(spec_name,
                    "base"         = character(0),
                    "base+VIX"     = "VIX",
                    "base+VIX+news"= c("VIX","log_news_w1"))
    m <- run_cr0(df_base, make_fml(y, extra))
    r <- extr(m, "aa_intelligence_index")
    cat(sprintf("  %-8s %-20s: %s  p=%s  n=%s\n",
                y, spec_name, fmt(r), fmt_p(r),
                if (is.null(r)) "n/a" else as.character(r$n)))
    rows_main[[length(rows_main)+1]] <- data.frame(
      outcome=y, spec=spec_name, sample="rel_only",
      coef=if(is.null(r)) NA else r$coef,
      se=if(is.null(r)) NA else r$se,
      p_value=if(is.null(r)) NA else r$p,
      stars=if(is.null(r)) "" else r$stars,
      n=if(is.null(r)) NA else r$n,
      n_events=if(is.null(r)) NA else r$ncl,
      r2=if(is.null(r)) NA else r$r2
    )
  }
  # 闭源子样本
  df_cl <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 0, ]
  m_cl <- run_cr0(df_cl, make_fml(y, c("VIX","log_news_w1")))
  r_cl <- extr(m_cl, "aa_intelligence_index")
  cat(sprintf("  %-8s %-20s: %s  p=%s  n=%s [闭源]\n",
              y, "base+VIX+news", fmt(r_cl), fmt_p(r_cl),
              if (is.null(r_cl)) "n/a" else as.character(r_cl$n)))
  rows_main[[length(rows_main)+1]] <- data.frame(
    outcome=y, spec="base+VIX+news", sample="rel_only_closed",
    coef=if(is.null(r_cl)) NA else r_cl$coef,
    se=if(is.null(r_cl)) NA else r_cl$se,
    p_value=if(is.null(r_cl)) NA else r_cl$p,
    stars=if(is.null(r_cl)) "" else r_cl$stars,
    n=if(is.null(r_cl)) NA else r_cl$n,
    n_events=if(is.null(r_cl)) NA else r_cl$ncl,
    r2=if(is.null(r_cl)) NA else r_cl$r2
  )
}
tbl_main <- do.call(rbind, rows_main)
write.csv(tbl_main, file.path(script_dir, "outputs/r_01_main_regression_v2.csv"), row.names=FALSE)
cat("-> 已保存: outputs/r_01_main_regression_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART R2: 关系子样本
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R2: 关系子样本\n")
cat(strrep("=", 70), "\n")

# v2 子样本映射（见脚本顶部角色映射说明 / relonly_regression_v2_comparison.md）：
#   competitor    -> competitor（同名，新版略宽，旧1全部保留为新1）
#   downstream    -> downstream_any (= integrator|deployer|enabler 并集，对应旧 downstream)
#   biz_down/real_down -> 旧的 business/real 划分轴与新的 integrator/deployer/enabler
#                          角色划分轴是不同维度（经验交叉表显示二者无清晰对应），
#                          故不再保留 biz_down/real_down，替换为三个新维度的独立子样本
#   upstream      -> upstream_any (= upstream_hardware|upstream_cloud 并集，对应旧 upstream)
#   owner_invest  -> is_owner | is_investor
rel_subs <- list(
  "competitor"   = df_base[!is.na(df_base$competitor)   & df_base$competitor   == 1, ],
  "downstream"   = df_base[!is.na(df_base$downstream_any) & df_base$downstream_any == 1, ],
  "downstream_integrator" = df_base[!is.na(df_base$downstream_integrator) & df_base$downstream_integrator == 1, ],
  "downstream_deployer"   = df_base[!is.na(df_base$downstream_deployer)   & df_base$downstream_deployer   == 1, ],
  "downstream_enabler"    = df_base[!is.na(df_base$downstream_enabler)    & df_base$downstream_enabler    == 1, ],
  "upstream"     = df_base[!is.na(df_base$upstream_any) & df_base$upstream_any == 1, ],
  "upstream_hardware" = df_base[!is.na(df_base$upstream_hardware) & df_base$upstream_hardware == 1, ],
  "upstream_cloud"    = df_base[!is.na(df_base$upstream_cloud)    & df_base$upstream_cloud    == 1, ],
  "owner_invest" = df_base[(!is.na(df_base$is_owner) & df_base$is_owner == 1) |
                            (!is.na(df_base$is_investor) & df_base$is_investor == 1), ]
)

rows_rel <- list()
for (rn in names(rel_subs)) {
  sub <- rel_subs[[rn]]
  cat(sprintf("\n  [%s] n=%d, ev=%d\n", rn, nrow(sub), length(unique(sub$final_event_id))))
  for (y in c("car_1", "car_5", "car_20")) {
    m_b  <- run_cr0(sub, make_fml(y))
    r_b  <- extr(m_b, "aa_intelligence_index")
    m_vn <- run_cr0(sub, make_fml(y, fml_ctrl))
    r_vn <- extr(m_vn, "aa_intelligence_index")
    cat(sprintf("    %-8s base: %s (%s) | +VIX+news: %s (%s)\n",
                y, fmt(r_b), fmt_p(r_b), fmt(r_vn), fmt_p(r_vn)))
    for (sp_pair in list(list("base", r_b), list("base+VIX+news", r_vn))) {
      r <- sp_pair[[2]]
      rows_rel[[length(rows_rel)+1]] <- data.frame(
        relationship=rn, outcome=y, spec=sp_pair[[1]],
        coef=if(is.null(r)) NA else r$coef,
        se=if(is.null(r)) NA else r$se,
        p_value=if(is.null(r)) NA else r$p,
        stars=if(is.null(r)) "" else r$stars,
        n=if(is.null(r)) NA else r$n,
        n_events=if(is.null(r)) NA else r$ncl,
        r2=if(is.null(r)) NA else r$r2
      )
    }
  }
}
tbl_rel <- do.call(rbind, rows_rel)
write.csv(tbl_rel, file.path(script_dir, "outputs/r_02_relationship_subsamples_v2.csv"), row.names=FALSE)
cat("\n-> 已保存: outputs/r_02_relationship_subsamples_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART R3: 行业异质性
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R3: 行业异质性\n")
cat(strrep("=", 70), "\n")

top_industries <- c("软件","半导体和半导体设备","技术硬件、存储和外围设备",
                    "IT服务","互联网服务和基础设施","互联网零售")
df_base$ind_group <- ifelse(df_base$industry_2 %in% top_industries,
                             df_base$industry_2, "其他/非IT")

rows_ind <- list()
for (g in c(top_industries, "其他/非IT")) {
  sub <- df_base[df_base$ind_group == g & !is.na(df_base$car_20), ]
  if (nrow(sub) < 20) { cat(sprintf("  %-40s n=%d 太少，跳过\n", g, nrow(sub))); next }
  m <- run_cr0(sub, make_fml("car_20", fml_ctrl))
  r <- extr(m, "aa_intelligence_index")
  cat(sprintf("  %-40s n=%4d ev=%2d  coef=%s  p=%s\n",
              g, if(is.null(r)) nrow(sub) else r$n,
                 if(is.null(r)) length(unique(sub$final_event_id)) else r$ncl,
                 fmt(r), fmt_p(r)))
  rows_ind[[length(rows_ind)+1]] <- data.frame(
    industry=g,
    n=if(is.null(r)) nrow(sub) else r$n,
    n_events=if(is.null(r)) length(unique(sub$final_event_id)) else r$ncl,
    coef=if(is.null(r)) NA else r$coef,
    se=if(is.null(r)) NA else r$se,
    p_value=if(is.null(r)) NA else r$p,
    stars=if(is.null(r)) "" else r$stars,
    r2=if(is.null(r)) NA else r$r2
  )
}
if (length(rows_ind) > 0) {
  write.csv(do.call(rbind,rows_ind), file.path(script_dir, "outputs/r_03_industry_v2.csv"), row.names=FALSE)
  cat("-> 已保存: outputs/r_03_industry_v2.csv\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# PART R4: VIX 调节效应
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R4: VIX 调节效应\n")
cat(strrep("=", 70), "\n")

vix_med <- median(df_base$VIX, na.rm=TRUE)
df_hi_vix <- df_base[!is.na(df_base$VIX) & df_base$VIX > vix_med, ]
df_lo_vix <- df_base[!is.na(df_base$VIX) & df_base$VIX <= vix_med, ]
cat(sprintf("VIX 中位数分割: %.2f\n", vix_med))
cat(sprintf("  高VIX: n=%d ev=%d | 低VIX: n=%d ev=%d\n",
            nrow(df_hi_vix), length(unique(df_hi_vix$final_event_id)),
            nrow(df_lo_vix), length(unique(df_lo_vix$final_event_id))))

rows_vix <- list()
for (y in c("car_1", "car_20")) {
  r_hi <- extr(run_cr0(df_hi_vix, make_fml(y, "log_news_w1")), "aa_intelligence_index")
  r_lo <- extr(run_cr0(df_lo_vix, make_fml(y, "log_news_w1")), "aa_intelligence_index")
  cat(sprintf("  %-8s 高VIX: %s (%s) | 低VIX: %s (%s)\n",
              y, fmt(r_hi), fmt_p(r_hi), fmt(r_lo), fmt_p(r_lo)))
  for (gr in list(list("high_vix",r_hi), list("low_vix",r_lo))) {
    r <- gr[[2]]
    rows_vix[[length(rows_vix)+1]] <- data.frame(
      group=gr[[1]], outcome=y,
      coef=if(is.null(r)) NA else r$coef,
      se=if(is.null(r)) NA else r$se,
      p_value=if(is.null(r)) NA else r$p,
      stars=if(is.null(r)) "" else r$stars,
      n=if(is.null(r)) NA else r$n,
      n_events=if(is.null(r)) NA else r$ncl
    )
  }
}
# VIX 交互项
cat("\n--- 交互项: intelligence × VIX_c → car_20 ---\n")
df_int <- df_base[!is.na(df_base$car_20) & !is.na(df_base$VIX), ]
df_int$VIX_c <- df_int$VIX - mean(df_int$VIX, na.rm=TRUE)
m_int <- run_cr0(df_int,
  car_20 ~ aa_intelligence_index + VIX_c + aa_intelligence_index:VIX_c +
  size_log_assets + bm_ratio + volatility + momentum + log_news_w1)
if (!is.null(m_int)) {
  sm <- summary(m_int)$coefficients
  for (v in c("aa_intelligence_index","VIX_c","aa_intelligence_index:VIX_c")) {
    if (v %in% rownames(sm)) {
      b <- sm[v,"Estimate"]; p <- sm[v,"Pr(>|t|)"]
      cat(sprintf("  %-42s b=%+.5f  p=%.4f%s\n", v, b, p, stars(p)))
    }
  }
  cat(sprintf("  n=%d, ev=%d, R2=%.4f\n", m_int$nobs, m_int$nclusters,
              summary(m_int)$r.squared))
}
write.csv(do.call(rbind,rows_vix), file.path(script_dir, "outputs/r_04_vix_moderator_v2.csv"), row.names=FALSE)
cat("-> 已保存: outputs/r_04_vix_moderator_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART R5: 新闻数量调节效应
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R5: 新闻数量调节效应\n")
cat(strrep("=", 70), "\n")

df_base$news_fill <- ifelse(is.na(df_base$news_count_w1), 0, df_base$news_count_w1)
news_med <- median(df_base$news_fill[!is.na(df_base$car_20)])
cat(sprintf("新闻中位数（缺失=0）: %.0f\n", news_med))
cat(sprintf("  零新闻: %d (%.1f%%)\n",
            sum(df_base$news_fill==0, na.rm=TRUE),
            100*mean(df_base$news_fill==0, na.rm=TRUE)))

df_hi_n <- df_base[!is.na(df_base$car_20) & df_base$news_fill > news_med, ]
df_lo_n <- df_base[!is.na(df_base$car_20) & df_base$news_fill <= news_med, ]
cat(sprintf("  高新闻(>%d): n=%d ev=%d | 低/零新闻(≤%d): n=%d ev=%d\n",
            news_med, nrow(df_hi_n), length(unique(df_hi_n$final_event_id)),
            news_med, nrow(df_lo_n), length(unique(df_lo_n$final_event_id))))

rows_news <- list()
for (y in c("car_1", "car_20")) {
  r_hi <- extr(run_cr0(df_hi_n, make_fml(y, "VIX")), "aa_intelligence_index")
  r_lo <- extr(run_cr0(df_lo_n, make_fml(y, "VIX")), "aa_intelligence_index")
  cat(sprintf("  %-8s 高新闻: %s (%s) | 低新闻: %s (%s)\n",
              y, fmt(r_hi), fmt_p(r_hi), fmt(r_lo), fmt_p(r_lo)))
  for (gr in list(list("high_news",r_hi), list("low_news",r_lo))) {
    r <- gr[[2]]
    rows_news[[length(rows_news)+1]] <- data.frame(
      group=gr[[1]], outcome=y,
      coef=if(is.null(r)) NA else r$coef,
      se=if(is.null(r)) NA else r$se,
      p_value=if(is.null(r)) NA else r$p,
      stars=if(is.null(r)) "" else r$stars,
      n=if(is.null(r)) NA else r$n,
      n_events=if(is.null(r)) NA else r$ncl
    )
  }
}
# 新闻交互项
cat("\n--- 交互项: intelligence × log_news_c → car_20 ---\n")
df_ni <- df_base[!is.na(df_base$car_20) & !is.na(df_base$log_news_w1), ]
df_ni$log_news_c <- df_ni$log_news_w1 - mean(df_ni$log_news_w1, na.rm=TRUE)
m_ni <- run_cr0(df_ni,
  car_20 ~ aa_intelligence_index + log_news_c + aa_intelligence_index:log_news_c +
  size_log_assets + bm_ratio + volatility + momentum + VIX)
if (!is.null(m_ni)) {
  sm <- summary(m_ni)$coefficients
  for (v in c("aa_intelligence_index","log_news_c","aa_intelligence_index:log_news_c")) {
    if (v %in% rownames(sm)) {
      b <- sm[v,"Estimate"]; p <- sm[v,"Pr(>|t|)"]
      cat(sprintf("  %-44s b=%+.5f  p=%.4f%s\n", v, b, p, stars(p)))
    }
  }
  cat(sprintf("  n=%d, ev=%d, R2=%.4f\n", m_ni$nobs, m_ni$nclusters,
              summary(m_ni)$r.squared))
}
write.csv(do.call(rbind,rows_news), file.path(script_dir, "outputs/r_05_news_moderator_v2.csv"), row.names=FALSE)
cat("-> 已保存: outputs/r_05_news_moderator_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART R6: 开源 vs 闭源
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R6: 开源 vs 闭源\n")
cat(strrep("=", 70), "\n")

df_open   <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 1, ]
df_closed <- df_base[!is.na(df_base$is_open_weight) & df_base$is_open_weight == 0, ]
cat(sprintf("开源: n=%d ev=%d | 闭源: n=%d ev=%d\n",
            nrow(df_open), length(unique(df_open$final_event_id)),
            nrow(df_closed), length(unique(df_closed$final_event_id))))

rows_oc <- list()
for (y in c("car_1", "car_5", "car_20")) {
  r_op <- extr(run_cr0(df_open,   make_fml(y, fml_ctrl)), "aa_intelligence_index")
  r_cl <- extr(run_cr0(df_closed, make_fml(y, fml_ctrl)), "aa_intelligence_index")
  cat(sprintf("  %-8s 开源: %s (%s) | 闭源: %s (%s)\n",
              y, fmt(r_op), fmt_p(r_op), fmt(r_cl), fmt_p(r_cl)))
  for (gr in list(list("open",r_op), list("closed",r_cl))) {
    r <- gr[[2]]
    rows_oc[[length(rows_oc)+1]] <- data.frame(
      group=gr[[1]], outcome=y,
      coef=if(is.null(r)) NA else r$coef,
      se=if(is.null(r)) NA else r$se,
      p_value=if(is.null(r)) NA else r$p,
      stars=if(is.null(r)) "" else r$stars,
      n=if(is.null(r)) NA else r$n,
      n_events=if(is.null(r)) NA else r$ncl,
      r2=if(is.null(r)) NA else r$r2
    )
  }
}
write.csv(do.call(rbind,rows_oc), file.path(script_dir, "outputs/r_06_open_vs_closed_v2.csv"), row.names=FALSE)
cat("-> 已保存: outputs/r_06_open_vs_closed_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART R7: FF3 稳健性
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R7: FF3 稳健性\n")
cat(strrep("=", 70), "\n")

rows_ff3 <- list()
for (y in c("ff3_car_1", "ff3_car_20")) {
  for (spec in list(list("base",character(0)), list("base+VIX+news",fml_ctrl))) {
    m <- run_cr0(df_base, make_fml(y, spec[[2]]))
    r <- extr(m, "aa_intelligence_index")
    cat(sprintf("  %-15s %-20s: %s  p=%s  n=%s\n",
                y, spec[[1]], fmt(r), fmt_p(r),
                if(is.null(r)) "n/a" else as.character(r$n)))
    rows_ff3[[length(rows_ff3)+1]] <- data.frame(
      outcome=y, spec=spec[[1]],
      coef=if(is.null(r)) NA else r$coef,
      se=if(is.null(r)) NA else r$se,
      p_value=if(is.null(r)) NA else r$p,
      stars=if(is.null(r)) "" else r$stars,
      n=if(is.null(r)) NA else r$n,
      n_events=if(is.null(r)) NA else r$ncl,
      r2=if(is.null(r)) NA else r$r2
    )
  }
}
write.csv(do.call(rbind,rows_ff3), file.path(script_dir, "outputs/r_07_ff3_robustness_v2.csv"), row.names=FALSE)
cat("-> 已保存: outputs/r_07_ff3_robustness_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART R8: Mag7 vs non-Mag7
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("PART R8: Mag7 vs non-Mag7\n")
cat(strrep("=", 70), "\n")

mag7 <- c("苹果","微软","英伟达","Alphabet（谷歌）","亚马逊","Meta（Facebook）","特斯拉")
df_m7  <- df_base[df_base$company %in% mag7, ]
df_nm7 <- df_base[!df_base$company %in% mag7, ]
cat(sprintf("Mag7: n=%d ev=%d | non-Mag7: n=%d ev=%d\n",
            nrow(df_m7), length(unique(df_m7$final_event_id)),
            nrow(df_nm7), length(unique(df_nm7$final_event_id))))

rows_mag <- list()
for (y in c("car_1","car_5","car_20")) {
  r7  <- extr(run_cr0(df_m7,  make_fml(y, fml_ctrl)), "aa_intelligence_index")
  rn7 <- extr(run_cr0(df_nm7, make_fml(y, fml_ctrl)), "aa_intelligence_index")
  cat(sprintf("  %-8s Mag7: %s (%s) | non-Mag7: %s (%s)\n",
              y, fmt(r7), fmt_p(r7), fmt(rn7), fmt_p(rn7)))
  for (gr in list(list("mag7",r7), list("non_mag7",rn7))) {
    r <- gr[[2]]
    rows_mag[[length(rows_mag)+1]] <- data.frame(
      group=gr[[1]], outcome=y,
      coef=if(is.null(r)) NA else r$coef,
      se=if(is.null(r)) NA else r$se,
      p_value=if(is.null(r)) NA else r$p,
      stars=if(is.null(r)) "" else r$stars,
      n=if(is.null(r)) NA else r$n,
      n_events=if(is.null(r)) NA else r$ncl,
      r2=if(is.null(r)) NA else r$r2
    )
  }
}
write.csv(do.call(rbind,rows_mag), file.path(script_dir, "outputs/r_08_mag7_v2.csv"), row.names=FALSE)
cat("-> 已保存: outputs/r_08_mag7_v2.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# 汇总对比：全样本 vs 有关系行
# ─────────────────────────────────────────────────────────────────────────────
cat("\n", strrep("=", 70), "\n")
cat("汇总对比：全样本 vs 有关系标签子样本（主回归，base+VIX+news）\n")
cat(strrep("=", 70), "\n")

old <- read.csv(file.path(script_dir, "outputs/01_main_regression.csv"))
new <- tbl_main
# 全样本
old_s <- old[old$spec == "base+VIX+news" & old$sample == "all",
             c("outcome","coef","se","p_value","stars","n","n_events")]
new_s <- new[new$spec == "base+VIX+news" & new$sample == "rel_only",
             c("outcome","coef","se","p_value","stars","n","n_events")]

cat(sprintf("  %-8s  %20s  %20s\n", "窗口", "全样本（含无关系行）", "仅有关系行"))
cat(sprintf("  %-8s  %8s %8s %6s  %8s %8s %6s\n",
            "", "系数", "p值", "n", "系数", "p值", "n"))
cat(strrep("-", 65), "\n")
for (y in c("car_1","car_5","car_20")) {
  o <- old_s[old_s$outcome == y, ]
  n <- new_s[new_s$outcome == y, ]
  cat(sprintf("  %-8s  %8.5f%s %6.3f %6d  %8.5f%s %6.3f %6d\n",
              y,
              ifelse(nrow(o)>0, o$coef, NA), ifelse(nrow(o)>0, o$stars, ""),
              ifelse(nrow(o)>0, o$p_value, NA), ifelse(nrow(o)>0, o$n, NA),
              ifelse(nrow(n)>0, n$coef, NA), ifelse(nrow(n)>0, n$stars, ""),
              ifelse(nrow(n)>0, n$p_value, NA), ifelse(nrow(n)>0, n$n, NA)))
}

cat("\n显著性标注: * p<0.10, ** p<0.05, *** p<0.01\n")
cat("SE 按 final_event_id 聚类 (CR0)\n")
