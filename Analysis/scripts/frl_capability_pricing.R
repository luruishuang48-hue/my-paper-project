#!/usr/bin/env Rscript
# Capability metrics, abnormal returns, and the hardware interaction.
suppressPackageStartupMessages(library(estimatr))

args <- commandArgs(trailingOnly = FALSE)
script_dir <- dirname(sub("--file=", "", args[grep("--file=", args)]))
root_env <- Sys.getenv("FRL_PROJECT_ROOT")
root <- if (nzchar(root_env)) {
  normalizePath(root_env)
} else {
  normalizePath(file.path(script_dir, "..", ".."))
}
panel_path <- Sys.getenv(
  "FRL_PANEL_PATH",
  unset = file.path(root, "Analysis", "processed", "event_firm_panel.csv")
)
df <- read.csv(panel_path,
               stringsAsFactors = FALSE, check.names = FALSE)

num <- c("car_mm_spy_0_20","car_mm_spy_0_10","car_ff3_0_20","aa_intelligence_index",
         "size_log_assets","bm_ratio","volatility","momentum",
         "rel_upstream_hardware","rel_upstream_cloud","rel_downstream_integrator",
         "rel_downstream_deployer","rel_downstream_enabler","rel_competitor",
         "rel_is_investor","rel_is_owner",
         "is_open_weight_or_open_source")
for (c in num) df[[c]] <- suppressWarnings(as.numeric(df[[c]]))
df$release_year <- substr(df$event_trading_date, 1, 4)

base <- df[df$is_main_ndxt == "True" & df$event_excluded_identity == "False" &
           !is.na(df$car_mm_spy_0_20) & !is.na(df$size_log_assets) &
           !is.na(df$volatility) & !is.na(df$momentum) &
           !is.na(df$aa_intelligence_index), ]
base$bm_missing <- as.numeric(is.na(base$bm_ratio))
base$bm_ratio[is.na(base$bm_ratio)] <- 0

# --- 能力惊喜：指数相对"此前事件前沿"（按事件交易日排序的运行最大值） ---
ev <- unique(base[, c("event_id", "event_trading_date", "aa_intelligence_index")])
ev <- ev[order(ev$event_trading_date), ]
ev$frontier_before <- c(NA, cummax(ev$aa_intelligence_index)[-nrow(ev)])
ev$intel_surprise <- ev$aa_intelligence_index - ev$frontier_before
ev$is_frontier <- as.numeric(ev$intel_surprise > 0)
base <- merge(base, ev[, c("event_id", "intel_surprise", "is_frontier")], by = "event_id")

base$intel_c <- base$aa_intelligence_index - mean(base$aa_intelligence_index)
base$open <- base$is_open_weight_or_open_source
base$related <- as.numeric(base$rel_upstream_hardware == 1 | base$rel_upstream_cloud == 1 |
                           base$rel_downstream_integrator == 1 | base$rel_downstream_deployer == 1 |
                           base$rel_downstream_enabler == 1 |
                           base$rel_competitor == 1 | base$rel_is_investor == 1 | base$rel_is_owner == 1)

sd_intel <- sd(base$aa_intelligence_index)
cat("LLM 指数样本:", nrow(base), "行 |", length(unique(base$event_id)), "事件 | 指数 SD =",
    round(sd_intel, 1), "\n")
cat("闭源事件:", length(unique(base$event_id[base$open == 0])),
    "| 开源事件:", length(unique(base$event_id[base$open == 1])),
    "| 前沿突破事件:", length(unique(base$event_id[base$is_frontier == 1])), "\n\n")

CTRL <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum + factor(release_year)"

run <- function(dat, rhs_key, label, y = "car_mm_spy_0_20") {
  f <- as.formula(paste(y, "~", rhs_key, "+", CTRL))
  m <- lm_robust(f, data = dat, clusters = dat$event_id, se_type = "CR2")
  s <- summary(m)$coefficients
  keep <- !grepl("factor\\(|Intercept|size_log|bm_|volatility|momentum", rownames(s))
  for (t in rownames(s)[keep]) {
    cat(sprintf("%-34s %-28s %10.5f (%8.5f) p=%6.4f n=%d ev=%d\n",
                label, t, s[t, "Estimate"], s[t, "Std. Error"], s[t, "Pr(>|t|)"],
                nobs(m), length(unique(dat$event_id))))
  }
  invisible(m)
}

cat("== Capability specifications ==\n")
run(base,                       "aa_intelligence_index", "F1_全样本能力水平")
run(base[base$open == 0, ],     "aa_intelligence_index", "F2_仅闭源")
run(base[base$open == 1, ],     "aa_intelligence_index", "F3_仅开源")
run(base,                       "intel_c*open",          "F4_能力×开源交互")

cat("\n== 新角度 ==\n")
run(base,                       "intel_surprise",        "N1_能力惊喜(相对前沿)")
run(base,                       "is_frontier",           "N2_前沿突破 dummy")
run(base[base$open == 0, ],     "intel_surprise",        "N3_惊喜·仅闭源")
run(base[base$related == 1, ],  "aa_intelligence_index", "N4_能力·仅相关公司")
run(base[base$related == 0, ],  "aa_intelligence_index", "N5_能力·仅无关公司(安慰剂)")
run(base[base$related == 1 & base$open == 0, ], "aa_intelligence_index", "N6_能力·相关×闭源")
run(base,                       "intel_c*rel_upstream_hardware", "N7_能力×上游硬件")
run(base[base$open == 0, ],     "aa_intelligence_index", "N8_闭源·窗口[0,10]", y = "car_mm_spy_0_10")
run(base[base$open == 0, ],     "aa_intelligence_index", "N9_闭源·FF3", y = "car_ff3_0_20")
