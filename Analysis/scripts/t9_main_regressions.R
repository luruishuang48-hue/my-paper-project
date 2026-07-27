#!/usr/bin/env Rscript
# =============================================================================
# T9 主回归（新样本首跑，2026-07-03）
# 面板：Analysis/processed/event_firm_panel.csv（125 事件 × 45 只 NDXT 证券）
# Design decisions are recorded in 事件集筛选/decisions/analysis_design_decisions.md.
#   主基准 SPY（P4）；剔除 event_excluded_identity（D1）；聚类 SE 按事件（D6）
# 三组规格：
#   A. 生态位置 → CAR[0,20]（假说1/2）
#   B. 上游硬件 × 开源 交互（假说3）
#   C. AA 智能指数 → CAR（能力定价，LLM 事件子样本）
# =============================================================================
suppressPackageStartupMessages({
  library(estimatr)
})

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
out_dir <- Sys.getenv(
  "FRL_REPORT_DIR",
  unset = file.path(root, "Analysis", "reports")
)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

df <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)

num_cols <- c("car_mm_spy_0_20", "car_mm_spy_0_1", "car_ff3_0_20",
              "aa_intelligence_index", "size_log_assets", "bm_ratio",
              "volatility", "momentum",
              "rel_upstream_hardware", "rel_upstream_cloud",
              "rel_downstream_integrator", "rel_downstream_deployer",
              "rel_downstream_enabler",
              "rel_competitor", "rel_is_investor", "rel_is_owner",
              "is_open_weight_or_open_source")
for (col in num_cols) df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
df$release_year <- substr(df$event_trading_date, 1, 4)
df$negative_equity <- df$negative_equity == "True"

# 主样本：纳指100 + 剔除 D1 事件 + CAR 与控制变量齐全
base <- df[df$is_main_ndxt == "True" &
           df$event_excluded_identity == "False" &
           !is.na(df$car_mm_spy_0_20) &
           !is.na(df$size_log_assets) & !is.na(df$volatility) &
           !is.na(df$momentum), ]
# bm 缺失（负权益/半年报）以 dummy + 填 0 保样本
base$bm_missing <- as.numeric(is.na(base$bm_ratio))
base$bm_ratio[is.na(base$bm_ratio)] <- 0

cat("主样本:", nrow(base), "行 |", length(unique(base$event_id)), "事件 |",
    length(unique(base$ticker)), "公司\n\n")

controls <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum + factor(release_year)"

run <- function(fml, dat, label) {
  m <- lm_robust(as.formula(fml), data = dat, clusters = dat$event_id, se_type = "CR0")
  s <- summary(m)$coefficients
  keep <- !grepl("factor\\(|Intercept", rownames(s))
  out <- data.frame(spec = label, term = rownames(s)[keep],
                    coef = s[keep, "Estimate"], se = s[keep, "Std. Error"],
                    p = s[keep, "Pr(>|t|)"], n = nobs(m),
                    n_events = length(unique(dat$event_id)))
  out
}

res <- list()

# --- A. 生态位置 → CAR[0,20] 与 CAR[0,1] ---
fA <- paste("~ rel_upstream_hardware + rel_upstream_cloud + rel_downstream_integrator +",
            "rel_downstream_deployer + rel_downstream_enabler + rel_competitor +",
            "rel_is_investor + rel_is_owner +", controls)
res[[1]] <- run(paste("car_mm_spy_0_20", fA), base, "A1_position_car0_20")
res[[2]] <- run(paste("car_mm_spy_0_1", fA), base, "A2_position_car0_1")
res[[3]] <- run(paste("car_ff3_0_20", fA), base, "A3_position_ff3_0_20")

# --- B. 上游硬件 × 开源（假说3） ---
fB <- paste("car_mm_spy_0_20 ~ rel_upstream_hardware * is_open_weight_or_open_source +",
            "rel_upstream_cloud + rel_downstream_integrator + rel_downstream_deployer +",
            "rel_downstream_enabler + rel_competitor + rel_is_investor + rel_is_owner +", controls)
res[[4]] <- run(fB, base, "B_hardware_x_open")

# --- C. AA 智能指数（LLM 事件子样本） ---
llm <- base[!is.na(base$aa_intelligence_index), ]
fC <- paste("car_mm_spy_0_20 ~ aa_intelligence_index +", controls)
res[[5]] <- run(fC, llm, "C_capability_llm_events")

all <- do.call(rbind, res)
all$stars <- cut(all$p, c(-1, .001, .01, .05, .1, 2),
                 labels = c("***", "**", "*", ".", ""))
out_path <- file.path(out_dir, "t9_main_regressions.csv")
write.csv(all, out_path, row.names = FALSE)

cat(sprintf("%-24s %-38s %10s %9s %8s\n", "spec", "term", "coef", "se", "p"))
for (i in seq_len(nrow(all))) {
  cat(sprintf("%-24s %-38s %10.5f %9.5f %8.4f %s\n",
              all$spec[i], all$term[i], all$coef[i], all$se[i], all$p[i], all$stars[i]))
}
cat("\n写出:", out_path, "\n")
