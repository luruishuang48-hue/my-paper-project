#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
  library(broom)
})

task_dir <- "agent_tasks/relation_subsample_regressions_20260619-110835"
out_dir <- file.path(task_dir, "outputs_v2")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

panel <- read.csv("data/panel/clean_event_firm_panel.csv", stringsAsFactors = FALSE, check.names = FALSE)
rel <- read.csv("data/panel/specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

# NOTE (v2): updated for the new 8-dimension relationship coding schema.
# Old columns: owner, investor, cloud, business_upstream, real_upstream,
#              business_downstream, real_downstream, competitor
# New columns: upstream_hardware, upstream_cloud, downstream_integrator,
#              downstream_deployer, downstream_enabler, competitor,
#              is_investor, is_owner
rel_vars <- c(
  "final_event_id", "company", "is_owner", "is_investor", "upstream_cloud",
  "upstream_hardware", "downstream_integrator", "downstream_deployer",
  "downstream_enabler", "competitor", "relationship_notes"
)

rel_clean <- rel %>%
  select(any_of(rel_vars)) %>%
  filter(!is.na(final_event_id), final_event_id != "", !is.na(company), company != "") %>%
  distinct(final_event_id, company, .keep_all = TRUE)

df <- panel %>%
  left_join(rel_clean, by = c("final_event_id", "company"))

num_vars <- c(
  "mkt_car_pre", "mkt_car_1", "mkt_car_2", "mkt_car_3", "mkt_car_5",
  "mkt_car_10", "mkt_car_15", "mkt_car_20",
  "ff3_car_pre", "ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_5",
  "ff3_car_10", "ff3_car_15", "ff3_car_20",
  "media_sent_mean_w5", "media_sent_sd_w5",
  "aa_intelligence_index", "aa_coding_index", "aa_math_index",
  "mmlu_pro", "gpqa", "hle", "livecodebench",
  "price_1m_blended_3_to_1", "median_output_tokens_per_second",
  "median_time_to_first_token_seconds",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "release_year", "is_open_weight_or_open_source", "llm_capability_sample_flag",
  "is_owner", "is_investor", "upstream_cloud", "upstream_hardware",
  "downstream_integrator", "downstream_deployer", "downstream_enabler", "competitor"
)
for (v in intersect(num_vars, names(df))) {
  df[[v]] <- suppressWarnings(as.numeric(df[[v]]))
}

flag_vars <- c(
  "is_owner", "is_investor", "upstream_cloud", "upstream_hardware",
  "downstream_integrator", "downstream_deployer", "downstream_enabler", "competitor"
)
for (v in flag_vars) {
  df[[v]] <- ifelse(is.na(df[[v]]), 0, df[[v]])
}

safe_pmax <- function(...) {
  vals <- list(...)
  vals <- lapply(vals, function(x) ifelse(is.na(x), 0, x))
  do.call(pmax, vals)
}

z <- function(x) {
  sx <- sd(x, na.rm = TRUE)
  if (is.na(sx) || sx == 0) return(rep(NA_real_, length(x)))
  as.numeric((x - mean(x, na.rm = TRUE)) / sx)
}

df <- df %>%
  mutate(
    # broad_upstream: any upstream exposure, hardware or cloud (semantic
    # equivalent of old pmax(business_upstream, real_upstream), since the
    # old business/real split was an evidence-strength axis nested within
    # "upstream", not a separate role -- see comparison.md for reasoning).
    broad_upstream = safe_pmax(upstream_hardware, upstream_cloud),
    # broad_downstream: any downstream exposure, across all three new
    # downstream role subtypes. The old business_downstream/real_downstream
    # split was also an evidence-strength axis (real_downstream was a
    # confidence-filtered subset of business_downstream), not a role-type
    # split like R3 vs R4 vs R5. The broadest, most faithful equivalent of
    # "any downstream exposure" is therefore the union of all three new
    # downstream categories, not a single one of them.
    broad_downstream = safe_pmax(downstream_integrator, downstream_deployer, downstream_enabler),
    # positive_exposure: curated "positive" business exposure set. Mirrors
    # the old formula's choice to use owner/investor/cloud plus only the
    # narrower-evidence real_upstream/real_downstream layers (rather than
    # the broad business_upstream/business_downstream). The new schema has
    # no evidence-strength axis on the role columns themselves, so we keep
    # the old formula's structural intent literally: owner + investor +
    # cloud-side relationships, plus the downstream new-columns (the closest
    # available analogue of "real" downstream exposure).
    positive_exposure = safe_pmax(
      is_owner, is_investor, upstream_cloud,
      downstream_integrator, downstream_deployer, downstream_enabler
    ),
    any_relation = safe_pmax(
      upstream_hardware, upstream_cloud, downstream_integrator,
      downstream_deployer, downstream_enabler, competitor, is_investor, is_owner
    ),
    z_intelligence = z(aa_intelligence_index),
    z_coding = z(aa_coding_index),
    z_math = z(aa_math_index),
    z_mmlu = z(mmlu_pro),
    z_gpqa = z(gpqa),
    z_hle = z(hle),
    z_livecode = z(livecodebench),
    z_low_price = z(-log1p(price_1m_blended_3_to_1)),
    z_speed = z(median_output_tokens_per_second),
    z_low_ttft = z(-log1p(median_time_to_first_token_seconds)),
    z_sent_w5 = z(media_sent_mean_w5),
    # Precedence mirrors the old ordering: owner > investor > cloud >
    # narrower/stronger upstream > broader upstream > competitor >
    # narrower/stronger downstream > broader downstream. The new schema has
    # no narrow/broad axis, so upstream_hardware (R1) stands in for the old
    # real_upstream/business_upstream pair, and the three downstream roles
    # are ordered core-product-first (integrator) to least-core (deployer),
    # mirroring real_downstream (narrower/stronger) preceding
    # business_downstream (broader) in the old script.
    primary_relation = case_when(
      is_owner == 1 ~ "is_owner",
      is_investor == 1 ~ "is_investor",
      upstream_cloud == 1 ~ "upstream_cloud",
      upstream_hardware == 1 ~ "upstream_hardware",
      competitor == 1 ~ "competitor",
      downstream_integrator == 1 ~ "downstream_integrator",
      downstream_enabler == 1 ~ "downstream_enabler",
      downstream_deployer == 1 ~ "downstream_deployer",
      TRUE ~ "other_or_no_flag"
    )
  )

role_defs <- tribble(
  ~role, ~role_label, ~var, ~set_type,
  "is_owner", "发布方或所有者", "is_owner", "flag",
  "is_investor", "主要投资者", "is_investor", "flag",
  "upstream_cloud", "云服务方", "upstream_cloud", "flag",
  "upstream_hardware", "硬件上游", "upstream_hardware", "flag",
  "broad_upstream", "上游合并", "broad_upstream", "flag",
  "downstream_integrator", "下游集成者", "downstream_integrator", "flag",
  "downstream_deployer", "下游部署者", "downstream_deployer", "flag",
  "downstream_enabler", "下游赋能者", "downstream_enabler", "flag",
  "broad_downstream", "下游合并", "broad_downstream", "flag",
  "competitor", "直接竞争者", "competitor", "flag",
  "positive_exposure", "正向商业暴露", "positive_exposure", "flag",
  "any_relation", "任一关系", "any_relation", "flag"
)

exclusive_defs <- tribble(
  ~role, ~role_label,
  "is_owner", "互斥 发布方或所有者",
  "is_investor", "互斥 主要投资者",
  "upstream_cloud", "互斥 云服务方",
  "upstream_hardware", "互斥 硬件上游",
  "competitor", "互斥 直接竞争者",
  "downstream_integrator", "互斥 下游集成者",
  "downstream_enabler", "互斥 下游赋能者",
  "downstream_deployer", "互斥 下游部署者",
  "other_or_no_flag", "互斥 其他或无关系旗标"
)

flag_summary <- map_dfr(seq_len(nrow(role_defs)), function(i) {
  d <- df %>% filter(.data[[role_defs$var[i]]] == 1)
  tibble(
    set_type = role_defs$set_type[i],
    role = role_defs$role[i],
    role_label = role_defs$role_label[i],
    n = nrow(d),
    events = n_distinct(d$final_event_id),
    companies = n_distinct(d$company),
    n_intelligence = sum(!is.na(d$z_intelligence)),
    events_intelligence = n_distinct(d$final_event_id[!is.na(d$z_intelligence)]),
    mean_car20 = mean(d$mkt_car_20, na.rm = TRUE),
    open_share = mean(d$is_open_weight_or_open_source == 1, na.rm = TRUE)
  )
})

exclusive_summary <- map_dfr(seq_len(nrow(exclusive_defs)), function(i) {
  d <- df %>% filter(primary_relation == exclusive_defs$role[i])
  tibble(
    set_type = "exclusive",
    role = exclusive_defs$role[i],
    role_label = exclusive_defs$role_label[i],
    n = nrow(d),
    events = n_distinct(d$final_event_id),
    companies = n_distinct(d$company),
    n_intelligence = sum(!is.na(d$z_intelligence)),
    events_intelligence = n_distinct(d$final_event_id[!is.na(d$z_intelligence)]),
    mean_car20 = mean(d$mkt_car_20, na.rm = TRUE),
    open_share = mean(d$is_open_weight_or_open_source == 1, na.rm = TRUE)
  )
})

relationship_sample_summary <- bind_rows(flag_summary, exclusive_summary)
write.csv(relationship_sample_summary, file.path(out_dir, "relationship_sample_summary.csv"), row.names = FALSE)

overlap_flags <- df %>%
  select(all_of(flag_vars)) %>%
  mutate(across(everything(), ~ ifelse(is.na(.x), 0, .x)))
overlap_matrix <- as.matrix(t(overlap_flags) %*% as.matrix(overlap_flags))
write.csv(overlap_matrix, file.path(out_dir, "relationship_overlap_matrix.csv"))

controls_for <- function(y) {
  pre <- ifelse(str_starts(y, "ff3_"), "ff3_car_pre", "mkt_car_pre")
  c(pre, "size_log_assets", "bm_ratio", "volatility", "momentum", "factor(release_year)")
}

fit_model <- function(data, y, xvars, controls = TRUE, min_n = 25, min_events = 4) {
  rhs <- xvars
  if (controls) rhs <- c(rhs, controls_for(y))
  needed <- unique(c(y, xvars, controls_for(y), "final_event_id"))
  needed <- needed[!str_detect(needed, "^factor\\(")]
  needed <- intersect(needed, names(data))
  d <- data %>% filter(if_all(all_of(needed), ~ !is.na(.)))
  if (nrow(d) < min_n || n_distinct(d$final_event_id) < min_events) return(NULL)
  fml <- as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
  tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
}

extract_terms <- function(model, role, role_label, set_type, spec, outcome, keep_terms) {
  if (is.null(model)) return(tibble())
  sm <- summary(model)$coefficients
  cis <- confint(model)
  tibble(
    set_type = set_type,
    role = role,
    role_label = role_label,
    spec = spec,
    outcome = outcome,
    term = rownames(sm),
    coef = unname(sm[, "Estimate"]),
    se = unname(sm[, "Std. Error"]),
    p_value = unname(sm[, "Pr(>|t|)"]),
    ci_lo = cis[, 1],
    ci_hi = cis[, 2],
    n = model$nobs,
    events = model$nclusters,
    r_squared = summary(model)$r.squared
  ) %>%
    filter(term %in% keep_terms)
}

specs <- list(
  no_controls_intelligence = list(x = c("z_intelligence"), controls = FALSE),
  controls_intelligence = list(x = c("z_intelligence"), controls = TRUE),
  controls_closed_intelligence = list(x = c("z_intelligence"), controls = TRUE, closed = TRUE),
  controls_open_interaction = list(
    x = c("z_intelligence", "is_open_weight_or_open_source", "z_intelligence:is_open_weight_or_open_source"),
    controls = TRUE
  ),
  controls_cost_speed = list(
    x = c("z_intelligence", "z_low_price", "z_speed", "z_low_ttft"),
    controls = TRUE
  ),
  controls_sentiment = list(
    x = c("z_intelligence", "z_sent_w5", "z_intelligence:z_sent_w5"),
    controls = TRUE
  )
)

outcomes <- c("mkt_car_1", "mkt_car_5", "mkt_car_20", "ff3_car_20")

run_for_subset <- function(data, role, role_label, set_type) {
  rows <- list()
  for (y in outcomes) {
    for (spec_name in names(specs)) {
      sp <- specs[[spec_name]]
      d <- data
      if (isTRUE(sp$closed)) d <- d %>% filter(is_open_weight_or_open_source == 0)
      min_n <- ifelse(spec_name == "no_controls_intelligence", 8, 20)
      min_events <- ifelse(spec_name == "no_controls_intelligence", 3, 4)
      mod <- fit_model(d, y, sp$x, controls = sp$controls, min_n = min_n, min_events = min_events)
      rows[[length(rows) + 1]] <- extract_terms(
        mod, role, role_label, set_type, spec_name, y, sp$x
      )
    }
  }
  bind_rows(rows)
}

flag_results <- map_dfr(seq_len(nrow(role_defs)), function(i) {
  d <- df %>% filter(.data[[role_defs$var[i]]] == 1)
  run_for_subset(d, role_defs$role[i], role_defs$role_label[i], "flag")
})

exclusive_results <- map_dfr(seq_len(nrow(exclusive_defs)), function(i) {
  d <- df %>% filter(primary_relation == exclusive_defs$role[i])
  run_for_subset(d, exclusive_defs$role[i], exclusive_defs$role_label[i], "exclusive")
})

all_results <- bind_rows(flag_results, exclusive_results)
write.csv(all_results, file.path(out_dir, "relationship_subsample_regressions_all.csv"), row.names = FALSE)

main_table <- all_results %>%
  filter(spec %in% c("controls_intelligence", "no_controls_intelligence"),
         outcome == "mkt_car_20", term == "z_intelligence") %>%
  arrange(set_type, spec, desc(events), role) %>%
  mutate(
    coef_pct = 100 * coef,
    se_pct = 100 * se,
    ci_lo_pct = 100 * ci_lo,
    ci_hi_pct = 100 * ci_hi,
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    )
  )
write.csv(main_table, file.path(out_dir, "relationship_intelligence_car20_main_table.csv"), row.names = FALSE)

closed_table <- all_results %>%
  filter(spec == "controls_closed_intelligence", outcome == "mkt_car_20", term == "z_intelligence") %>%
  mutate(coef_pct = 100 * coef, se_pct = 100 * se)
write.csv(closed_table, file.path(out_dir, "relationship_closed_source_car20.csv"), row.names = FALSE)

mechanism_table <- all_results %>%
  filter(outcome == "mkt_car_20",
         spec %in% c("controls_open_interaction", "controls_cost_speed", "controls_sentiment")) %>%
  mutate(coef_pct = 100 * coef, se_pct = 100 * se)
write.csv(mechanism_table, file.path(out_dir, "relationship_mechanism_car20.csv"), row.names = FALSE)

format_num <- function(x, digits = 3) {
  ifelse(is.na(x), "", formatC(x, format = "f", digits = digits))
}

write_md_table <- function(data, path, title) {
  lines <- c(
    paste0("# ", title),
    "",
    "| 口径 | 关系组 | 规格 | 系数，百分点 | 标准误 | p 值 | N | 事件数 |",
    "|---|---|---|---:|---:|---:|---:|---:|"
  )
  body <- data %>%
    mutate(
      line = paste0(
        "| ", set_type, " | ", role_label, " | ", spec, " | ",
        format_num(coef_pct, 2), stars, " | ",
        format_num(se_pct, 2), " | ",
        format_num(p_value, 3), " | ",
        n, " | ", events, " |"
      )
    ) %>%
    pull(line)
  writeLines(c(lines, body), path)
}

write_md_table(
  main_table,
  file.path(out_dir, "relationship_intelligence_car20_main_table.md"),
  "关系分组回归，AA Intelligence 与 CAR[0,+20]"
)

summary_md <- c(
  "# 关系样本规模",
  "",
  "| 口径 | 关系组 | 观测 | 事件 | 公司 | 有 Intelligence 的观测 | 有 Intelligence 的事件 | CAR20 均值 | 开源占比 |",
  "|---|---|---:|---:|---:|---:|---:|---:|---:|",
  relationship_sample_summary %>%
    mutate(
      line = paste0(
        "| ", set_type, " | ", role_label, " | ", n, " | ", events, " | ",
        companies, " | ", n_intelligence, " | ", events_intelligence, " | ",
        format_num(mean_car20, 3), " | ", format_num(open_share, 3), " |"
      )
    ) %>%
    pull(line)
)
writeLines(summary_md, file.path(out_dir, "relationship_sample_summary.md"))

plot_data <- main_table %>%
  filter(spec == "controls_intelligence", set_type == "flag") %>%
  filter(!role %in% c("any_relation", "positive_exposure")) %>%
  mutate(role_label = fct_reorder(role_label, coef_pct))

png(file.path(out_dir, "figure_relation_intelligence_car20_flag.png"), width = 1900, height = 1150, res = 180)
ggplot(plot_data, aes(x = role_label, y = coef_pct)) +
  geom_hline(yintercept = 0, color = "grey55", linewidth = 0.4) +
  geom_point(size = 2.7, color = "#4B6F8C") +
  geom_errorbar(aes(ymin = ci_lo_pct, ymax = ci_hi_pct), width = 0.15, color = "#4B6F8C") +
  coord_flip() +
  labs(
    x = NULL,
    y = "Coefficient on standardized AA Intelligence, percentage points",
    title = "Relationship-specific capability pricing, flag subsamples"
  ) +
  theme_minimal(base_size = 12)
dev.off()

plot_ex <- main_table %>%
  filter(spec == "controls_intelligence", set_type == "exclusive") %>%
  mutate(role_label = fct_reorder(role_label, coef_pct))

png(file.path(out_dir, "figure_relation_intelligence_car20_exclusive.png"), width = 1900, height = 1150, res = 180)
ggplot(plot_ex, aes(x = role_label, y = coef_pct)) +
  geom_hline(yintercept = 0, color = "grey55", linewidth = 0.4) +
  geom_point(size = 2.7, color = "#6F5B4B") +
  geom_errorbar(aes(ymin = ci_lo_pct, ymax = ci_hi_pct), width = 0.15, color = "#6F5B4B") +
  coord_flip() +
  labs(
    x = NULL,
    y = "Coefficient on standardized AA Intelligence, percentage points",
    title = "Relationship-specific capability pricing, mutually exclusive groups"
  ) +
  theme_minimal(base_size = 12)
dev.off()

cat("Relationship subsample regressions complete.\n")
cat("Outputs written to ", out_dir, "\n", sep = "")
