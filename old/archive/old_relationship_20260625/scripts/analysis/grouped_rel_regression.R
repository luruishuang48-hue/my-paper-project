#!/usr/bin/env Rscript
# =============================================================================
# grouped_rel_regression.R
# 按关系类型分组，对每组分别回归 aa_intelligence_index → CAR[1] / CAR[20]
# 输出：控制台 + grouped_rel_regression_results.csv
# =============================================================================

suppressPackageStartupMessages({
  library(estimatr)
})

stars <- function(p) {
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
}

df <- read.csv("specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

# ── 数值化 ────────────────────────────────────────────────────────────────────
num_cols <- c(
  "car_1", "car_20", "aa_intelligence_index",
  "size_log_assets", "bm_ratio", "volatility", "momentum", "release_year",
  "owner", "investor", "cloud", "real_upstream", "business_upstream",
  "downstream_integrator", "downstream_deployer", "downstream_enabler",
  "competitor", "is_open_weight"
)
for (col in num_cols) if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])

ctrl  <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
ctrl_str <- paste(ctrl, collapse = " + ")

make_fml <- function(y, x_extra = NULL) {
  xs <- paste(c("aa_intelligence_index", ctrl, "factor(release_year)"), collapse = " + ")
  as.formula(paste(y, "~", xs))
}

# ── 单次回归辅助函数 ──────────────────────────────────────────────────────────
run_reg <- function(label, d, y) {
  d <- d[!is.na(d[[y]]) & !is.na(d$aa_intelligence_index) &
           !is.na(d$size_log_assets) & !is.na(d$bm_ratio) &
           !is.na(d$volatility) & !is.na(d$momentum), ]
  n_events <- length(unique(d$final_event_id))
  if (nrow(d) < 30 || n_events < 5) {
    return(data.frame(
      label = label, outcome = y,
      N = nrow(d), events = n_events,
      beta = NA, se = NA, p = NA, stars = "(insuf.)",
      stringsAsFactors = FALSE
    ))
  }
  fml  <- make_fml(y)
  mod  <- tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
  if (is.null(mod)) return(data.frame(
    label = label, outcome = y,
    N = nrow(d), events = n_events,
    beta = NA, se = NA, p = NA, stars = "(error)",
    stringsAsFactors = FALSE
  ))
  b  <- coef(mod)[["aa_intelligence_index"]]
  se <- sqrt(diag(vcov(mod)))[["aa_intelligence_index"]]
  p  <- as.numeric(summary(mod)$coefficients["aa_intelligence_index", "Pr(>|t|)"])
  data.frame(
    label = label, outcome = y,
    N = nrow(d), events = n_events,
    beta = round(b, 6), se = round(se, 6),
    p = round(p, 4), stars = stars(p),
    stringsAsFactors = FALSE
  )
}

# ── 分组定义 ──────────────────────────────────────────────────────────────────
groups <- list(
  "① 全样本"                    = df,
  "② 发布者 (owner)"            = df[!is.na(df$owner)    & df$owner    == 1, ],
  "③ 投资方 (investor)"         = df[!is.na(df$investor) & df$investor == 1, ],
  "④ 云服务商 (cloud)"          = df[!is.na(df$cloud)    & df$cloud    == 1, ],
  "⑤ 硬件上游 (real_upstream)"  = df[!is.na(df$real_upstream) & df$real_upstream == 1, ],
  "⑥ 任意上游 (biz_upstream)"   = df[!is.na(df$business_upstream) & df$business_upstream == 1, ],
  "⑦ AI核心整合商 (R3)"         = df[!is.na(df$downstream_integrator) & df$downstream_integrator == 1, ],
  "⑧ AI效率部署商 (R4)"         = df[!is.na(df$downstream_deployer)   & df$downstream_deployer   == 1, ],
  "⑨ IT服务使能商 (R5)"         = df[!is.na(df$downstream_enabler)    & df$downstream_enabler    == 1, ],
  "⑩ 任意下游 (biz_downstream)" = df[!is.na(df$business_downstream) & df$business_downstream == 1, ],
  "⑪ 竞争者 (competitor)"       = df[!is.na(df$competitor) & df$competitor == 1, ],
  "⑫ 无关系 (no_relation)"      = df[
    (is.na(df$owner)    | df$owner    == 0) &
    (is.na(df$investor) | df$investor == 0) &
    (is.na(df$cloud)    | df$cloud    == 0) &
    (is.na(df$real_upstream) | df$real_upstream == 0) &
    (is.na(df$downstream_integrator) | df$downstream_integrator == 0) &
    (is.na(df$downstream_deployer)   | df$downstream_deployer   == 0) &
    (is.na(df$downstream_enabler)    | df$downstream_enabler    == 0) &
    (is.na(df$competitor) | df$competitor == 0), ]
)

# ── 运行所有回归 ──────────────────────────────────────────────────────────────
results <- do.call(rbind, lapply(names(groups), function(nm) {
  d <- groups[[nm]]
  rbind(run_reg(nm, d, "car_1"), run_reg(nm, d, "car_20"))
}))

# ── 打印宽表 ──────────────────────────────────────────────────────────────────
cat(paste(rep("=", 100), collapse = ""), "\n")
cat("分组回归：aa_intelligence_index → CAR  |  按关系类型分层\n")
cat(paste(rep("=", 100), collapse = ""), "\n")
cat(sprintf("\n%-32s %6s %7s | %9s %8s %8s   %-4s | %9s %8s %8s   %-4s\n",
            "关系类型 / Group", "N", "Events",
            "β (CAR1)", "SE", "p", "sig",
            "β (CAR20)", "SE", "p", "sig"))
cat(paste(rep("-", 100), collapse = ""), "\n")

group_names <- unique(results$label)
for (nm in group_names) {
  r1  <- results[results$label == nm & results$outcome == "car_1",  ]
  r20 <- results[results$label == nm & results$outcome == "car_20", ]
  fmt_num <- function(x) if (is.na(x)) sprintf("%9s", "—") else sprintf("%9.5f", x)
  fmt_p   <- function(x) if (is.na(x)) sprintf("%8s", "—") else sprintf("%8.4f", x)
  fmt_s   <- function(s) if (is.null(s) || is.na(s)) "    " else sprintf("%-4s", s)
  cat(sprintf("%-32s %6d %7d | %9s %8s %8s %-4s | %9s %8s %8s %-4s\n",
    nm,
    ifelse(is.na(r1$N), r20$N, r1$N),
    ifelse(is.na(r1$events), r20$events, r1$events),
    fmt_num(r1$beta), fmt_num(r1$se), fmt_p(r1$p), fmt_s(r1$stars),
    fmt_num(r20$beta), fmt_num(r20$se), fmt_p(r20$p), fmt_s(r20$stars)
  ))
}
cat(paste(rep("=", 100), collapse = ""), "\n")
cat("* p<0.10  ** p<0.05  *** p<0.01\n")
cat("Controls: size_log_assets, bm_ratio, volatility, momentum + Year FE\n")
cat("SE: clustered by final_event_id (CR0)\n")
cat("(insuf.): N<30 或事件数<5，不报告\n\n")

# ── 保存 ─────────────────────────────────────────────────────────────────────
write.csv(results, "grouped_rel_regression_results.csv", row.names = FALSE)
cat("Saved: grouped_rel_regression_results.csv\n")
