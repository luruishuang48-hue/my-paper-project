#!/usr/bin/env Rscript
# 论文全部表格数字的单一来源。输出 Analysis/reports/paper_numbers.csv
suppressPackageStartupMessages(library(estimatr))
args <- commandArgs(trailingOnly = FALSE)
sd <- dirname(sub("--file=", "", args[grep("--file=", args)]))
root_env <- Sys.getenv("FRL_PROJECT_ROOT")
root <- if (nzchar(root_env)) {
  normalizePath(root_env)
} else {
  normalizePath(file.path(sd, "..", ".."))
}
panel_path <- Sys.getenv(
  "FRL_PANEL_PATH",
  unset = file.path(root, "Analysis/processed/event_firm_panel.csv")
)
volume_path <- Sys.getenv(
  "FRL_VOLUME_PATH",
  unset = file.path(root, "Analysis/processed/event_firm_abnormal_volume.csv")
)
report_dir <- Sys.getenv(
  "FRL_REPORT_DIR",
  unset = file.path(root, "Analysis/reports")
)
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
df <- read.csv(panel_path, stringsAsFactors=FALSE, check.names=FALSE)
av <- read.csv(volume_path, stringsAsFactors=FALSE)
df <- merge(df, av, by=c("event_id","ticker"), all.x=TRUE)
num <- c(grep("^car_mm_spy|^car_ff3_0_20|^av_", names(df), value=TRUE),
         "aa_intelligence_index","size_log_assets","bm_ratio","volatility","momentum",
         "rel_upstream_hardware","rel_upstream_cloud","rel_downstream_integrator",
         "rel_downstream_deployer","rel_downstream_enabler","rel_competitor",
         "rel_is_investor","rel_is_owner",
         "is_open_weight_or_open_source")
for (c in unique(num)) df[[c]] <- suppressWarnings(as.numeric(df[[c]]))
df$release_year <- substr(df$event_trading_date,1,4)
b <- df[df$is_main_ndxt=="True" & df$event_excluded_identity=="False" &
        !is.na(df$size_log_assets) & !is.na(df$volatility) & !is.na(df$momentum), ]
b$bm_missing <- as.numeric(is.na(b$bm_ratio)); b$bm_ratio[is.na(b$bm_ratio)] <- 0
b$related <- as.numeric(b$rel_upstream_hardware==1|b$rel_upstream_cloud==1|b$rel_downstream_integrator==1|
                        b$rel_downstream_deployer==1|b$rel_downstream_enabler==1|b$rel_competitor==1|
                        b$rel_is_investor==1|b$rel_is_owner==1)
POS0 <- "rel_upstream_hardware+rel_upstream_cloud+rel_downstream_integrator+rel_downstream_deployer+rel_downstream_enabler+rel_competitor+rel_is_investor+rel_is_owner"
CTRL <- "size_log_assets+bm_ratio+bm_missing+volatility+momentum"
POS <- paste(POS0, "+", CTRL)
out <- list(); i <- 0
grab <- function(dat, y, rhs, fe, block, terms=NULL) {
  d <- dat[!is.na(dat[[y]]),]
  m <- tryCatch(lm_robust(as.formula(paste(y,"~",rhs,"+",fe)), data=d, clusters=d$event_id, se_type="CR2"),
                error=function(e) NULL)
  if (is.null(m)) return()
  s <- summary(m)$coefficients
  if (is.null(terms)) terms <- rownames(s)[!grepl("factor|Intercept|size_log|bm_|volatility|momentum",rownames(s))]
  for (t in terms) if (t %in% rownames(s)) {
    i <<- i+1
    out[[i]] <<- data.frame(block=block, y=y, term=t, coef=s[t,1], se=s[t,2], p=s[t,4],
                            n=nobs(m), events=length(unique(d$event_id)))
  }
}
y2526 <- b[b$event_trading_date>="2025-01-01",]
reas  <- b[b$is_reasoning_model=="1",]
# 基准表三列
grab(b, "car_mm_spy_0_20", POS, "factor(release_year)", "baseline_mm")
grab(b, "car_ff3_0_20",    POS, "factor(release_year)", "baseline_ff3")
grab(b, "car_mm_spy_0_20", POS, "factor(event_id)",     "baseline_evfe")
# 量表：两样本×两窗×全部位置
for (w in c("av_pre_m10_m2","av_0_1")) { grab(b, w, POS, "factor(event_id)", "vol_full"); grab(y2526, w, POS, "factor(event_id)", "vol_2526") }
# 分期×类型
for (per in list(c("p2024","2024-01-01","2025-01-01"), c("p2526","2025-01-01","2027-01-01"), c("p2223","2022-01-01","2024-01-01"))) {
  sub <- b[b$event_trading_date>=per[2] & b$event_trading_date<per[3],]
  for (ty in c("llm","media")) grab(sub[sub$aa_metric_type==ty,], "car_mm_spy_0_20", POS, "factor(event_id)",
                                    paste0("phase_",per[1],"_",ty), "rel_upstream_hardware")
}
# 能力表五列
bi <- b[!is.na(b$aa_intelligence_index),]
bi$intel_c <- bi$aa_intelligence_index - mean(bi$aa_intelligence_index)
grab(bi, "car_mm_spy_0_20", "aa_intelligence_index", paste(CTRL,"+factor(release_year)"), "cap_all", "aa_intelligence_index")
grab(bi[bi$is_open_weight_or_open_source==0,], "car_mm_spy_0_20", "aa_intelligence_index", paste(CTRL,"+factor(release_year)"), "cap_closed", "aa_intelligence_index")
grab(bi[bi$is_open_weight_or_open_source==1,], "car_mm_spy_0_20", "aa_intelligence_index", paste(CTRL,"+factor(release_year)"), "cap_open", "aa_intelligence_index")
grab(bi[bi$related==0,], "car_mm_spy_0_20", "aa_intelligence_index", paste(CTRL,"+factor(release_year)"), "cap_placebo", "aa_intelligence_index")
grab(bi, "car_mm_spy_0_20", "intel_c*rel_upstream_hardware", paste(CTRL,"+factor(release_year)"), "cap_ix")
# 窗口剖面：3 样本 × 9 窗 × 3 位置
wins <- c("car_mm_spy_pre_m10_m2","car_mm_spy_0_0","car_mm_spy_0_1","car_mm_spy_0_2","car_mm_spy_0_3",
          "car_mm_spy_0_5","car_mm_spy_0_10","car_mm_spy_0_15","car_mm_spy_0_20")
for (w in wins) { grab(b, w, POS, "factor(release_year)", "prof_full",
                       c("rel_upstream_hardware","rel_competitor","rel_downstream_deployer"))
                  grab(y2526, w, POS, "factor(release_year)", "prof_2526",
                       c("rel_upstream_hardware","rel_competitor","rel_downstream_deployer"))
                  grab(reas, w, POS, "factor(release_year)", "prof_reas",
                       c("rel_upstream_hardware","rel_competitor","rel_downstream_deployer")) }
res <- do.call(rbind, out)
write.csv(res, file.path(report_dir,"paper_numbers.csv"), row.names=FALSE)
cat("rows:", nrow(res), "\n")
