#!/usr/bin/env Rscript
# =============================================================================
# T9 稳健性矩阵：核心问题——上游硬件与竞争者正溢价是否稳健；
# 下游部署零效应与开源交互零效应是否在所有设定下都成立。
# 每个设定跑同一个位置回归，记录 4 个关键系数。
# =============================================================================
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
report_dir <- Sys.getenv(
  "FRL_REPORT_DIR",
  unset = file.path(root, "Analysis", "reports")
)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
df <- read.csv(panel_path,
               stringsAsFactors = FALSE, check.names = FALSE)

num <- c("car_mm_spy_0_20","car_mm_qqq_0_20","car_mm_soxx_0_20","car_ff3_0_20",
         "car_mm_spy_0_10","car_mm_spy_0_15","car_mm_spy_pre_m10_m2",
         "size_log_assets","bm_ratio","volatility","momentum",
         "rel_upstream_hardware","rel_upstream_cloud","rel_downstream_integrator",
         "rel_downstream_deployer","rel_downstream_enabler","rel_competitor",
         "rel_is_investor","rel_is_owner",
         "is_open_weight_or_open_source","aa_intelligence_index")
for (c in num) df[[c]] <- suppressWarnings(as.numeric(df[[c]]))
df$release_year <- substr(df$event_trading_date, 1, 4)

base <- df[df$is_main_ndxt == "True" & df$event_excluded_identity == "False" &
           !is.na(df$size_log_assets) & !is.na(df$volatility) & !is.na(df$momentum), ]
base$bm_missing <- as.numeric(is.na(base$bm_ratio))
base$bm_ratio[is.na(base$bm_ratio)] <- 0

POS <- c("rel_upstream_hardware","rel_upstream_cloud","rel_downstream_integrator",
         "rel_downstream_deployer","rel_downstream_enabler","rel_competitor",
         "rel_is_investor","rel_is_owner")
CTRL <- "size_log_assets + bm_ratio + bm_missing + volatility + momentum"

run_spec <- function(dat, ycol, label, extra_rhs = "", fe = "factor(release_year)",
                     interact_open = FALSE) {
  dat <- dat[!is.na(dat[[ycol]]), ]
  rhs <- paste(c(POS, CTRL, fe, extra_rhs)[c(POS, CTRL, fe, extra_rhs) != ""], collapse = " + ")
  if (interact_open) rhs <- paste("rel_upstream_hardware*is_open_weight_or_open_source +",
                                  paste(POS[-1], collapse = " + "), "+", CTRL, "+", fe)
  m <- tryCatch(lm_robust(as.formula(paste(ycol, "~", rhs)), data = dat,
                          clusters = dat$event_id, se_type = "CR0"),
                error = function(e) NULL)
  if (is.null(m)) return(NULL)
  s <- summary(m)$coefficients
  pick <- function(term) if (term %in% rownames(s))
      c(s[term, "Estimate"], s[term, "Pr(>|t|)"]) else c(NA, NA)
  hw <- pick("rel_upstream_hardware"); dp <- pick("rel_downstream_deployer")
  cp <- pick("rel_competitor")
  ix <- pick("rel_upstream_hardware:is_open_weight_or_open_source")
  data.frame(spec = label, n = nobs(m), events = length(unique(dat$event_id)),
             hw_coef = hw[1], hw_p = hw[2], deploy_coef = dp[1], deploy_p = dp[2],
             comp_coef = cp[1], comp_p = cp[2], open_ix_coef = ix[1], open_ix_p = ix[2])
}

res <- list(); i <- 0; add <- function(x) { i <<- i + 1; res[[i]] <<- x }

add(run_spec(base, "car_mm_spy_0_20",  "S01_基准 SPY [0,20]"))
add(run_spec(base, "car_mm_spy_0_20",  "S02_基准+开源交互", interact_open = TRUE))
add(run_spec(base, "car_mm_qqq_0_20",  "S03_QQQ 基准"))
add(run_spec(base, "car_mm_soxx_0_20", "S04_SOXX 基准"))
add(run_spec(base, "car_ff3_0_20",     "S05_FF3"))
add(run_spec(base, "car_mm_spy_0_10",  "S06_窗口 [0,10]"))
add(run_spec(base, "car_mm_spy_0_15",  "S07_窗口 [0,15]"))
add(run_spec(base, "car_mm_spy_0_20",  "S08_控制 CAR_pre",
             extra_rhs = "car_mm_spy_pre_m10_m2"))
add(run_spec(base[base$multi_component_date_flag == "False", ], "car_mm_spy_0_20",
             "S09_剔除多组件事件"))
add(run_spec(base[base$date_confidence == "high", ], "car_mm_spy_0_20",
             "S10_仅高置信度日期"))
add(run_spec(base[base$event_trading_date >= "2024-04-01", ], "car_mm_spy_0_20",
             "S11_2024-04 后事件"))
add(run_spec(base[base$event_trading_date < "2025-01-01", ], "car_mm_spy_0_20",
             "S12_仅 2022-2024"))
add(run_spec(base[base$event_trading_date >= "2025-01-01", ], "car_mm_spy_0_20",
             "S13_仅 2025-2026"))
add(run_spec(base[base$aa_metric_type == "llm", ], "car_mm_spy_0_20", "S14_仅 LLM 事件"))
add(run_spec(base[base$aa_metric_type == "media", ], "car_mm_spy_0_20", "S15_仅媒体事件"))
add(run_spec(base, "car_mm_spy_0_20", "S16_事件固定效应", fe = "factor(event_id)"))
add(run_spec(base[base$is_reasoning_model == "1", ], "car_mm_spy_0_20", "S17_仅推理模型事件"))
add(run_spec(base[base$is_chinese_model == "1", ], "car_mm_spy_0_20", "S18_仅中国模型事件"))
add(run_spec(base[base$is_chinese_model == "0", ], "car_mm_spy_0_20", "S19_仅非中国模型事件"))
# winsorize CAR at 1/99
w <- base; q <- quantile(w$car_mm_spy_0_20, c(.01, .99), na.rm = TRUE)
w$car_mm_spy_0_20 <- pmin(pmax(w$car_mm_spy_0_20, q[1]), q[2])
add(run_spec(w, "car_mm_spy_0_20", "S20_CAR winsorize 1/99"))

out <- do.call(rbind, res)
write.csv(out, file.path(report_dir, "t9_robustness_matrix.csv"), row.names = FALSE)
star <- function(p) ifelse(is.na(p), "", ifelse(p < .01, "***", ifelse(p < .05, "**", ifelse(p < .1, "*", ""))))
cat(sprintf("%-28s %6s %4s | %9s %-3s | %9s %-3s | %9s %-3s | %9s %-3s\n",
            "spec", "n", "ev", "硬件", "", "部署", "", "竞争", "", "开源交互", ""))
for (j in seq_len(nrow(out))) {
  r <- out[j, ]
  cat(sprintf("%-28s %6d %4d | %9.4f %-3s | %9.4f %-3s | %9.4f %-3s | %9.4f %-3s\n",
      r$spec, r$n, r$events,
      r$hw_coef, star(r$hw_p), r$deploy_coef, star(r$deploy_p),
      r$comp_coef, star(r$comp_p),
      ifelse(is.na(r$open_ix_coef), NA, r$open_ix_coef), star(r$open_ix_p)))
}
