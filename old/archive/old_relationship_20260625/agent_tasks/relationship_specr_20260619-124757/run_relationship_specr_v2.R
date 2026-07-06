#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
  library(broom)
  library(patchwork)
})

# v2: migrated to the new 8-dimension relationship coding (see
# run_relationship_specr_v2_comparison.md for the full mapping rationale).
task_dir <- "agent_tasks/relationship_specr_20260619-124757"
out_dir <- file.path(task_dir, "outputs_v2")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

input_path <- "data/panel/specr_rel_clean.csv"
if (!file.exists(input_path)) {
  stop("Missing input file: ", input_path)
}

df <- read.csv(input_path, stringsAsFactors = FALSE, check.names = FALSE)
input_rows <- nrow(df)
input_cols <- ncol(df)
input_events <- length(unique(df$final_event_id))

# NEW 8-dimension relationship coding (replaces the old owner/investor/cloud/
# business_upstream/real_upstream/business_downstream/real_downstream/competitor set).
rel_flags <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "car_1", "car_2", "car_3", "car_5", "car_10", "car_15", "car_20",
  "aa_intelligence_index",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "release_year", "is_open_weight",
  rel_flags
)
for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (flag in rel_flags) {
  if (!flag %in% names(df)) stop("Missing relationship flag: ", flag)
  df[[flag]] <- ifelse(is.na(df[[flag]]), 0, df[[flag]])
}

safe_max <- function(...) {
  vals <- list(...)
  vals <- lapply(vals, function(x) ifelse(is.na(x), 0, x))
  do.call(pmax, vals)
}

# Mapping notes (old -> new):
#   broad_upstream:   old business_upstream|real_upstream -> new upstream_hardware|upstream_cloud
#   broad_downstream: old business_downstream|real_downstream -> new downstream_integrator|downstream_deployer|downstream_enabler
#     (old had 2 downstream dimensions, new has 3 -- broad_downstream now unions all three)
#   positive_rel:     old owner|investor|cloud|business_upstream|real_upstream
#                      -> new is_owner|is_investor|upstream_cloud|upstream_hardware
#     ("cloud" is absorbed into upstream_cloud, which is broader in the new schema)
#   downstream_comp:  old business_downstream|real_downstream|competitor
#                      -> new downstream_integrator|downstream_deployer|downstream_enabler|competitor
df <- df %>%
  mutate(
    broad_upstream = safe_max(upstream_hardware, upstream_cloud),
    broad_downstream = safe_max(downstream_integrator, downstream_deployer, downstream_enabler),
    positive_rel = safe_max(is_owner, is_investor, upstream_cloud, upstream_hardware),
    downstream_comp = safe_max(downstream_integrator, downstream_deployer, downstream_enabler, competitor)
  )

y_vars <- c("car_1", "car_2", "car_3", "car_5", "car_10", "car_15", "car_20")
control_sets <- list(
  none = character(0),
  size = "size_log_assets",
  full = c("size_log_assets", "bm_ratio", "volatility", "momentum")
)
year_fe_opts <- c(FALSE, TRUE)
min_obs <- 20
min_clusters <- 5

# Old single-flag subsamples (owner, investor, cloud, business_upstream, real_upstream,
# business_downstream, real_downstream, competitor) are replaced 1:1 in spirit by the
# new 8 dimensions (is_owner, is_investor, upstream_cloud, upstream_hardware, etc.).
# broad_upstream / broad_downstream / positive_rel / downstream_comp are recomputed
# composites (see mapping notes above) and kept for continuity with the old report.
subsample_defs <- list(
  all = function(d) rep(TRUE, nrow(d)),
  is_owner = function(d) d$is_owner == 1,
  is_investor = function(d) d$is_investor == 1,
  upstream_cloud = function(d) d$upstream_cloud == 1,
  upstream_hardware = function(d) d$upstream_hardware == 1,
  broad_upstream = function(d) d$broad_upstream == 1,
  downstream_integrator = function(d) d$downstream_integrator == 1,
  downstream_deployer = function(d) d$downstream_deployer == 1,
  downstream_enabler = function(d) d$downstream_enabler == 1,
  broad_downstream = function(d) d$broad_downstream == 1,
  competitor = function(d) d$competitor == 1,
  positive_rel = function(d) d$positive_rel == 1,
  downstream_comp = function(d) d$downstream_comp == 1,
  open_source = function(d) !is.na(d$is_open_weight) & d$is_open_weight == 1,
  closed_source = function(d) !is.na(d$is_open_weight) & d$is_open_weight == 0,
  us_creator = function(d) d$creator_type == "listed_us_company",
  non_us_creator = function(d) d$creator_type != "listed_us_company",
  text_or_reason = function(d) d$model_modality %in% c("text_llm", "reasoning_llm", "coding_llm", "multimodal_llm"),
  media_gen = function(d) d$model_modality %in% c("image_generation", "video_generation", "image_editing")
)

core_subsample_defs <- list(
  all = function(d) rep(TRUE, nrow(d)),
  us_creator = function(d) d$creator_type == "listed_us_company",
  non_us_creator = function(d) d$creator_type != "listed_us_company",
  open_source = function(d) !is.na(d$is_open_weight) & d$is_open_weight == 1,
  closed_source = function(d) !is.na(d$is_open_weight) & d$is_open_weight == 0,
  text_or_reason = function(d) d$model_modality %in% c("text_llm", "reasoning_llm", "coding_llm", "multimodal_llm"),
  media_gen = function(d) d$model_modality %in% c("image_generation", "video_generation", "image_editing")
)

fit_one <- function(formula_obj, data, term_name) {
  n_cl <- length(unique(data$final_event_id))
  if (n_cl >= min_clusters) {
    mod <- lm_robust(formula_obj, data = data, clusters = data$final_event_id, se_type = "CR0")
  } else {
    mod <- lm(formula_obj, data = data)
  }
  out <- tidy(mod, conf.int = TRUE)
  out[out$term == term_name, , drop = FALSE]
}

build_data <- function(data, y_var, x_var, ctrl_vars, use_fe) {
  needed <- unique(c("final_event_id", y_var, x_var, ctrl_vars))
  if (use_fe) needed <- unique(c(needed, "release_year"))
  needed <- intersect(needed, names(data))
  data %>% filter(if_all(all_of(needed), ~ !is.na(.x)))
}

run_grid <- function(data, x_vars, subsamples, mode_name) {
  records <- vector("list", 5000)
  idx <- 0L

  for (x_var in x_vars) {
    for (y_var in y_vars) {
      for (ctrl_name in names(control_sets)) {
        ctrl_vars <- control_sets[[ctrl_name]]
        for (ss_name in names(subsamples)) {
          mask <- subsamples[[ss_name]](data)
          d0 <- data[mask %in% TRUE, , drop = FALSE]
          for (use_fe in year_fe_opts) {
            d_sub <- build_data(d0, y_var, x_var, ctrl_vars, use_fe)
            if (nrow(d_sub) < min_obs) next
            if (length(unique(d_sub[[x_var]])) < 2) next

            rhs <- c(x_var, ctrl_vars)
            if (use_fe) rhs <- c(rhs, "factor(release_year)")
            fml <- as.formula(paste(y_var, "~", paste(rhs, collapse = " + ")))

            row <- tryCatch(fit_one(fml, d_sub, x_var), error = function(e) NULL)
            if (is.null(row) || nrow(row) == 0) next

            idx <- idx + 1L
            records[[idx]] <- data.frame(
              mode = mode_name,
              x_var = x_var,
              y_var = y_var,
              controls = ctrl_name,
              subsample = ss_name,
              year_fe = use_fe,
              n = nrow(d_sub),
              n_events = length(unique(d_sub$final_event_id)),
              estimate = row$estimate,
              std.error = row$std.error,
              p.value = row$p.value,
              conf.low = row$conf.low,
              conf.high = row$conf.high,
              sig_05 = row$p.value < 0.05,
              sig_10 = row$p.value < 0.10,
              stringsAsFactors = FALSE
            )
          }
        }
      }
    }
  }

  if (idx == 0L) return(data.frame())
  do.call(rbind, records[seq_len(idx)])
}

summarise_by_subsample <- function(results) {
  results %>%
    group_by(subsample) %>%
    summarise(
      n_specs = n(),
      n_sig_05 = sum(sig_05),
      pct_sig_05 = round(100 * mean(sig_05), 1),
      n_sig_10 = sum(sig_10),
      pct_sig_10 = round(100 * mean(sig_10), 1),
      pct_positive = round(100 * mean(estimate > 0), 1),
      median_est = round(median(estimate), 6),
      mean_est = round(mean(estimate), 6),
      sd_est = round(sd(estimate), 6),
      .groups = "drop"
    ) %>%
    arrange(desc(pct_sig_05), desc(pct_positive), subsample)
}

summarise_by_x <- function(results) {
  results %>%
    group_by(x_var) %>%
    summarise(
      n_specs = n(),
      n_sig_05 = sum(sig_05),
      pct_sig_05 = round(100 * mean(sig_05), 1),
      n_sig_10 = sum(sig_10),
      pct_sig_10 = round(100 * mean(sig_10), 1),
      pct_positive = round(100 * mean(estimate > 0), 1),
      median_est = round(median(estimate), 6),
      mean_est = round(mean(estimate), 6),
      sd_est = round(sd(estimate), 6),
      .groups = "drop"
    ) %>%
    arrange(desc(pct_sig_05), desc(pct_positive), x_var)
}

plot_curve <- function(results, title_text, subtitle_prefix = "") {
  d <- results %>%
    arrange(estimate) %>%
    mutate(
      rank = row_number(),
      sig_label = ifelse(sig_05, "p<0.05", "p>=0.05"),
      year_fe = ifelse(year_fe, "Year FE", "No FE")
    )

  p_top <- ggplot(d, aes(x = rank, y = estimate)) +
    geom_hline(yintercept = 0, color = "#c0392b", linewidth = 0.45, linetype = "dashed") +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = sig_label), alpha = 0.22) +
    geom_point(aes(color = sig_label), size = 0.6) +
    scale_color_manual(values = c("p<0.05" = "#2166ac", "p>=0.05" = "#9aa0a6"), name = NULL) +
    scale_fill_manual(values = c("p<0.05" = "#2166ac", "p>=0.05" = "#c7cbd1"), name = NULL) +
    labs(
      title = title_text,
      subtitle = paste0(subtitle_prefix, nrow(d), " specs, ", sum(d$sig_05), " p<0.05"),
      x = NULL,
      y = "Estimate"
    ) +
    theme_bw(base_size = 10) +
    theme(
      legend.position = c(0.02, 0.98),
      legend.justification = c(0, 1),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      panel.grid.minor = element_blank()
    )

  d_long <- d %>%
    select(rank, x_var, y_var, controls, subsample, year_fe) %>%
    pivot_longer(-rank, names_to = "dim", values_to = "val") %>%
    mutate(
      dim = factor(
        dim,
        levels = c("year_fe", "subsample", "controls", "y_var", "x_var"),
        labels = c("Year FE", "Subsample", "Controls", "Outcome", "X")
      )
    )

  p_bot <- ggplot(d_long, aes(x = rank, y = val)) +
    geom_point(shape = "|", size = 1.5, color = "#2c3e50") +
    facet_grid(dim ~ ., scales = "free_y", space = "free_y") +
    labs(x = "Specifications ranked by estimate", y = NULL) +
    theme_bw(base_size = 8.5) +
    theme(
      strip.text.y = element_text(angle = 0, hjust = 0, size = 7.5),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    )

  p_top / p_bot + plot_layout(heights = c(2.3, 2.2))
}

validation <- data.frame(
  item = c(
    "rows", "columns", "events",
    rel_flags
  ),
  value = c(
    input_rows, input_cols, input_events,
    sapply(rel_flags, function(v) sum(df[[v]] == 1, na.rm = TRUE))
  ),
  stringsAsFactors = FALSE
)
write.csv(validation, file.path(out_dir, "relationship_specr_validation.csv"), row.names = FALSE)

message("Running relationship subsample specr")
subsample_results <- run_grid(
  df,
  x_vars = "aa_intelligence_index",
  subsamples = subsample_defs,
  mode_name = "relationship_subsample"
)
subsample_summary <- summarise_by_subsample(subsample_results)

write.csv(subsample_results, file.path(out_dir, "relationship_subsample_specr_results_all.csv"), row.names = FALSE)
write.csv(subsample_summary, file.path(out_dir, "relationship_subsample_specr_summary.csv"), row.names = FALSE)

message("Running relationship-as-X specr")
relationship_x_results <- run_grid(
  df,
  x_vars = rel_flags,
  subsamples = core_subsample_defs,
  mode_name = "relationship_x"
)
relationship_x_summary <- summarise_by_x(relationship_x_results)

write.csv(relationship_x_results, file.path(out_dir, "relationship_x_specr_results_all.csv"), row.names = FALSE)
write.csv(relationship_x_summary, file.path(out_dir, "relationship_x_specr_summary.csv"), row.names = FALSE)

pdf(file.path(out_dir, "relationship_subsample_specr_curve_all.pdf"), width = 14, height = 10)
print(plot_curve(subsample_results, "Relationship subsample specification curve", "X = aa_intelligence_index, "))
dev.off()

pdf(file.path(out_dir, "relationship_x_specr_curve_by_x.pdf"), width = 14, height = 10)
for (xv in rel_flags) {
  d_x <- relationship_x_results %>% filter(x_var == xv)
  if (nrow(d_x) > 0) {
    print(plot_curve(d_x, paste0("Relationship flag as X: ", xv), "Binary relationship flag, "))
  }
}
dev.off()

car20_subsample <- subsample_results %>%
  filter(y_var == "car_20", controls == "full", year_fe == TRUE) %>%
  arrange(desc(estimate)) %>%
  select(subsample, n, n_events, estimate, std.error, p.value, conf.low, conf.high)

car20_x <- relationship_x_results %>%
  filter(y_var == "car_20", controls == "full", subsample == "all", year_fe == TRUE) %>%
  arrange(desc(estimate)) %>%
  select(x_var, n, n_events, estimate, std.error, p.value, conf.low, conf.high)

write.csv(car20_subsample, file.path(out_dir, "relationship_subsample_car20_full_yearfe.csv"), row.names = FALSE)
write.csv(car20_x, file.path(out_dir, "relationship_x_car20_full_yearfe.csv"), row.names = FALSE)

fmt_pct <- function(x) sprintf("%.1f%%", x)
fmt_num <- function(x, digits = 4) {
  ifelse(is.na(x), "NA", formatC(x, format = "f", digits = digits))
}
sig_mark <- function(p) {
  ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ifelse(p < 0.10, "+", ""))))
}

top_sub <- subsample_summary %>% slice_head(n = 6)
top_x <- relationship_x_summary %>% slice_head(n = 8)

report_lines <- c(
  "# 关系变量 Specr 报告（v2，新 8 维关系编码）",
  "",
  paste0("生成时间 2026-06-25，任务目录 `", task_dir, "`（v2 重跑，输出目录 `outputs_v2`）。"),
  "",
  "## 做了什么",
  "",
  "本次跑两套规格曲线。第一套把关系变量作为子样本，用 `aa_intelligence_index` 解释不同 CAR 窗口。第二套把关系旗标逐个作为主解释变量，检验某类关系本身是否对应更强或更弱的异常收益。",
  "",
  "两套分析都使用 `data/panel/specr_rel_clean.csv`（新 8 维关系编码：upstream_hardware, upstream_cloud, downstream_integrator, downstream_deployer, downstream_enabler, competitor, is_investor, is_owner）。回归使用 `lm_robust`，标准误按 `final_event_id` 聚类。聚类数不足 5 时退回普通 OLS。控制变量组为无控制、仅规模、完整控制。完整控制包括规模、账面市值比、波动率和动量。年份固定效应按规格开关。",
  "",
  "## 数据校验",
  "",
  paste0("- 输入维度  ", input_rows, " 行，", input_cols, " 列。"),
  paste0("- 事件数  ", input_events, "。"),
  paste0("- 关系旗标计数（新 8 维编码）  upstream_hardware ", validation$value[validation$item == "upstream_hardware"],
         "，upstream_cloud ", validation$value[validation$item == "upstream_cloud"],
         "，downstream_integrator ", validation$value[validation$item == "downstream_integrator"],
         "，downstream_deployer ", validation$value[validation$item == "downstream_deployer"],
         "，downstream_enabler ", validation$value[validation$item == "downstream_enabler"],
         "，competitor ", validation$value[validation$item == "competitor"],
         "，is_investor ", validation$value[validation$item == "is_investor"],
         "，is_owner ", validation$value[validation$item == "is_owner"], "。"),
  "",
  "## 关系作子样本",
  "",
  paste0("有效规格数为 ", nrow(subsample_results), "。显著率最高的子样本如下。"),
  "",
  "| 子样本 | 规格数 | p<0.05 比例 | 正向比例 | 中位系数 |",
  "|---|---:|---:|---:|---:|"
)

for (i in seq_len(nrow(top_sub))) {
  report_lines <- c(
    report_lines,
    paste0(
      "| ", top_sub$subsample[i],
      " | ", top_sub$n_specs[i],
      " | ", fmt_pct(top_sub$pct_sig_05[i]),
      " | ", fmt_pct(top_sub$pct_positive[i]),
      " | ", fmt_num(top_sub$median_est[i], 6),
      " |"
    )
  )
}

report_lines <- c(
  report_lines,
  "",
  "主读 `car_20 + 完整控制 + 年份固定效应` 时，关系组内的能力定价排序如下。",
  "",
  "| 子样本 | N | 事件数 | 系数 | 标准误 | p 值 |",
  "|---|---:|---:|---:|---:|---:|"
)

for (i in seq_len(min(10, nrow(car20_subsample)))) {
  report_lines <- c(
    report_lines,
    paste0(
      "| ", car20_subsample$subsample[i],
      " | ", car20_subsample$n[i],
      " | ", car20_subsample$n_events[i],
      " | ", fmt_num(car20_subsample$estimate[i], 5), sig_mark(car20_subsample$p.value[i]),
      " | ", fmt_num(car20_subsample$std.error[i], 5),
      " | ", signif(car20_subsample$p.value[i], 3),
      " |"
    )
  )
}

report_lines <- c(
  report_lines,
  "",
  "## 关系旗标作 X",
  "",
  paste0("有效规格数为 ", nrow(relationship_x_results), "。各关系旗标逐个进入回归，避免多个重叠旗标同时进入导致解释不清。"),
  "",
  "| 关系旗标 | 规格数 | p<0.05 比例 | 正向比例 | 中位系数 |",
  "|---|---:|---:|---:|---:|"
)

for (i in seq_len(nrow(top_x))) {
  report_lines <- c(
    report_lines,
    paste0(
      "| ", top_x$x_var[i],
      " | ", top_x$n_specs[i],
      " | ", fmt_pct(top_x$pct_sig_05[i]),
      " | ", fmt_pct(top_x$pct_positive[i]),
      " | ", fmt_num(top_x$median_est[i], 6),
      " |"
    )
  )
}

report_lines <- c(
  report_lines,
  "",
  "全样本 `car_20 + 完整控制 + 年份固定效应` 下，关系旗标本身的估计如下。",
  "",
  "| 关系旗标 | N | 事件数 | 系数 | 标准误 | p 值 |",
  "|---|---:|---:|---:|---:|---:|"
)

for (i in seq_len(nrow(car20_x))) {
  report_lines <- c(
    report_lines,
    paste0(
      "| ", car20_x$x_var[i],
      " | ", car20_x$n[i],
      " | ", car20_x$n_events[i],
      " | ", fmt_num(car20_x$estimate[i], 5), sig_mark(car20_x$p.value[i]),
      " | ", fmt_num(car20_x$std.error[i], 5),
      " | ", signif(car20_x$p.value[i], 3),
      " |"
    )
  )
}

report_lines <- c(
  report_lines,
  "",
  "## 解读口径",
  "",
  "- 关系作子样本回答的是，模型能力信号在哪些关系组内更容易被市场定价。",
  "- 关系旗标作 X 回答的是，某种公司和模型发布者关系本身是否对应更高或更低 CAR。",
  "- is_owner、is_investor 和 upstream_cloud 样本仍然偏小（is_owner、is_investor 尤其小），只适合作为探索性证据。报告和正文不宜把这些组写成强结论。",
  "- 关系旗标不是互斥分类。某家公司可以同时是投资者、云服务方或竞争者。关系旗标作 X 的结果应读成单旗标相关性，不应读成互斥身份差异。",
  "",
  "## 输出文件",
  "",
  "- `outputs_v2/relationship_subsample_specr_results_all.csv`",
  "- `outputs_v2/relationship_subsample_specr_summary.csv`",
  "- `outputs_v2/relationship_x_specr_results_all.csv`",
  "- `outputs_v2/relationship_x_specr_summary.csv`",
  "- `outputs_v2/relationship_subsample_specr_curve_all.pdf`",
  "- `outputs_v2/relationship_x_specr_curve_by_x.pdf`",
  "- `outputs_v2/relationship_specr_validation.csv`",
  "- `outputs_v2/relationship_subsample_car20_full_yearfe.csv`",
  "- `outputs_v2/relationship_x_car20_full_yearfe.csv`"
)

writeLines(report_lines, file.path(out_dir, "relationship_specr_report.md"), useBytes = TRUE)

cat("Done\n")
cat("Subsample specs:", nrow(subsample_results), "\n")
cat("Relationship-X specs:", nrow(relationship_x_results), "\n")
cat("Output dir:", out_dir, "\n")
