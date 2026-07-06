#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
  library(broom)
})

task_dir <- "agent_tasks/proposal_gap_completion_20260619-104007"
out_dir <- file.path(task_dir, "outputs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

panel_path <- "data/panel/clean_event_firm_panel.csv"
rel_path <- "data/panel/specr_rel_clean.csv"

panel <- read.csv(panel_path, stringsAsFactors = FALSE, check.names = FALSE)
rel <- read.csv(rel_path, stringsAsFactors = FALSE, check.names = FALSE)

rel_vars <- c(
  "final_event_id", "company", "owner", "investor", "cloud",
  "business_upstream", "real_upstream", "business_downstream",
  "real_downstream", "competitor", "relationship_notes"
)

rel_clean <- rel %>%
  select(any_of(rel_vars)) %>%
  distinct(final_event_id, company, .keep_all = TRUE)

df <- panel %>%
  left_join(rel_clean, by = c("final_event_id", "company"))

num_vars <- c(
  "mkt_car_pre", "mkt_car_1", "mkt_car_2", "mkt_car_3", "mkt_car_5",
  "mkt_car_10", "mkt_car_15", "mkt_car_20",
  "ff3_car_pre", "ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_5",
  "ff3_car_10", "ff3_car_15", "ff3_car_20",
  "media_sent_mean_w2", "media_sent_sd_w2", "media_sent_mean_w3",
  "media_sent_sd_w3", "media_sent_mean_w5", "media_sent_sd_w5",
  "media_sent_mean_w10", "media_sent_sd_w10", "media_sent_mean_w15",
  "media_sent_sd_w15", "media_sent_mean_w20", "media_sent_sd_w20",
  "aa_intelligence_index", "aa_coding_index", "aa_math_index",
  "mmlu_pro", "gpqa", "hle", "livecodebench", "scicode",
  "math_500", "aime", "price_1m_input_tokens",
  "price_1m_output_tokens", "price_1m_blended_3_to_1",
  "median_output_tokens_per_second",
  "median_time_to_first_token_seconds",
  "median_time_to_first_answer_token", "aa_media_elo", "aa_media_rank",
  "aa_media_ci95", "aa_media_appearances", "size_log_assets",
  "bm_ratio", "volatility", "momentum", "release_year",
  "trend_month_since_2022_11", "is_open_weight_or_open_source",
  "is_reasoning_model", "is_coding_model", "is_media_generation_model",
  "is_model_family", "is_multimodal", "is_chinese_model",
  "llm_capability_sample_flag", "media_capability_sample_flag",
  "owner", "investor", "cloud", "business_upstream", "real_upstream",
  "business_downstream", "real_downstream", "competitor"
)
for (v in intersect(num_vars, names(df))) {
  df[[v]] <- suppressWarnings(as.numeric(df[[v]]))
}

flag_vars <- c(
  "owner", "investor", "cloud", "business_upstream", "real_upstream",
  "business_downstream", "real_downstream", "competitor"
)
for (v in intersect(flag_vars, names(df))) {
  df[[v]] <- ifelse(is.na(df[[v]]), 0, df[[v]])
}

z <- function(x) {
  sx <- sd(x, na.rm = TRUE)
  if (is.na(sx) || sx == 0) return(rep(NA_real_, length(x)))
  as.numeric((x - mean(x, na.rm = TRUE)) / sx)
}

safe_pmax <- function(...) {
  vals <- list(...)
  vals <- lapply(vals, function(x) ifelse(is.na(x), 0, x))
  do.call(pmax, vals)
}

df <- df %>%
  mutate(
    broad_upstream = safe_pmax(business_upstream, real_upstream),
    broad_downstream = safe_pmax(business_downstream, real_downstream),
    positive_exposure = safe_pmax(owner, investor, cloud, real_upstream, real_downstream),
    any_relationship = safe_pmax(
      owner, investor, cloud, business_upstream, real_upstream,
      business_downstream, real_downstream, competitor
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
    price_efficiency = ifelse(
      !is.na(price_1m_blended_3_to_1) & price_1m_blended_3_to_1 > 0,
      aa_intelligence_index / price_1m_blended_3_to_1,
      NA_real_
    ),
    z_price_efficiency = z(price_efficiency),
    speed_adjusted_capability = aa_intelligence_index * median_output_tokens_per_second,
    z_speed_adjusted_capability = z(speed_adjusted_capability),
    z_sent_w5 = z(media_sent_mean_w5),
    z_sent_sd_w5 = z(media_sent_sd_w5),
    z_sent_w20 = z(media_sent_mean_w20),
    z_sent_sd_w20 = z(media_sent_sd_w20),
    sent_w5_negative = ifelse(!is.na(media_sent_mean_w5) & media_sent_mean_w5 < 0, 1, 0),
    sent_w5_positive = ifelse(!is.na(media_sent_mean_w5) & media_sent_mean_w5 > 0, 1, 0),
    sent_w5_pos_part = ifelse(!is.na(z_sent_w5), pmax(z_sent_w5, 0), NA_real_),
    sent_w5_neg_abs = ifelse(!is.na(z_sent_w5), pmax(-z_sent_w5, 0), NA_real_),
    sent_w20_pos_part = ifelse(!is.na(z_sent_w20), pmax(z_sent_w20, 0), NA_real_),
    sent_w20_neg_abs = ifelse(!is.na(z_sent_w20), pmax(-z_sent_w20, 0), NA_real_)
  )

car_windows <- c(
  "mkt_car_1", "mkt_car_2", "mkt_car_3", "mkt_car_5",
  "mkt_car_10", "mkt_car_15", "mkt_car_20"
)

cluster_boot_mean <- function(data, y, n_boot = 199) {
  d <- data %>% filter(!is.na(.data[[y]]), !is.na(final_event_id))
  event_values <- split(d[[y]], d$final_event_id)
  if (nrow(d) < 5 || length(event_values) < 2) return(c(NA_real_, NA_real_))
  event_names <- names(event_values)
  means <- replicate(n_boot, {
    sampled <- sample(event_names, length(event_names), replace = TRUE)
    mean(unlist(event_values[sampled], use.names = FALSE), na.rm = TRUE)
  })
  as.numeric(quantile(means, c(0.025, 0.975), na.rm = TRUE))
}

role_defs <- tribble(
  ~role, ~role_label, ~var,
  "owner", "发布方或所有者", "owner",
  "investor", "主要投资者", "investor",
  "cloud", "云服务方", "cloud",
  "upstream", "上游算力", "broad_upstream",
  "downstream", "下游应用", "broad_downstream",
  "competitor", "直接竞争者", "competitor",
  "positive_exposure", "正向商业暴露", "positive_exposure"
)

role_summary_rows <- list()
owner_values <- df %>% filter(owner == 1)
for (r in seq_len(nrow(role_defs))) {
  role_var <- role_defs$var[r]
  role_data <- df %>% filter(.data[[role_var]] == 1)
  for (y in car_windows) {
    vals <- role_data[[y]]
    vals <- vals[!is.na(vals)]
    owner_vals <- owner_values[[y]]
    owner_vals <- owner_vals[!is.na(owner_vals)]
    ci <- cluster_boot_mean(role_data, y)
    role_summary_rows[[length(role_summary_rows) + 1]] <- tibble(
      role = role_defs$role[r],
      role_label = role_defs$role_label[r],
      outcome = y,
      n = length(vals),
      events = n_distinct(role_data$final_event_id[!is.na(role_data[[y]])]),
      mean = mean(vals, na.rm = TRUE),
      sd = sd(vals, na.rm = TRUE),
      positive_share = mean(vals > 0, na.rm = TRUE),
      t_p_value = ifelse(length(vals) > 2, t.test(vals)$p.value, NA_real_),
      boot_ci_lo = ci[1],
      boot_ci_hi = ci[2],
      p_vs_owner = ifelse(
        length(vals) > 2 && length(owner_vals) > 2,
        t.test(vals, owner_vals)$p.value,
        NA_real_
      )
    )
  }
}
role_summary <- bind_rows(role_summary_rows)
write.csv(role_summary, file.path(out_dir, "role_car_mean_tests.csv"), row.names = FALSE)

downstream_detail <- df %>%
  filter(broad_downstream == 1) %>%
  mutate(
    downstream_subrole = case_when(
      real_downstream == 1 & business_downstream == 1 ~ "real_and_business_downstream",
      real_downstream == 1 ~ "real_downstream",
      business_downstream == 1 ~ "business_downstream",
      TRUE ~ "other_downstream"
    )
  ) %>%
  group_by(downstream_subrole) %>%
  summarise(
    n = sum(!is.na(mkt_car_20)),
    events = n_distinct(final_event_id[!is.na(mkt_car_20)]),
    mean_mkt_car_1 = mean(mkt_car_1, na.rm = TRUE),
    mean_mkt_car_20 = mean(mkt_car_20, na.rm = TRUE),
    sd_mkt_car_20 = sd(mkt_car_20, na.rm = TRUE),
    positive_share_car20 = mean(mkt_car_20 > 0, na.rm = TRUE),
    .groups = "drop"
  )
write.csv(downstream_detail, file.path(out_dir, "downstream_subrole_car_tests.csv"), row.names = FALSE)

controls_for <- function(y) {
  pre <- ifelse(str_starts(y, "ff3_"), "ff3_car_pre", "mkt_car_pre")
  c(pre, "size_log_assets", "bm_ratio", "volatility", "momentum", "factor(release_year)")
}

fit_cluster <- function(data, y, xvars, add_controls = TRUE) {
  rhs <- xvars
  if (add_controls) rhs <- c(rhs, controls_for(y))
  needed <- unique(c(y, xvars, controls_for(y), "final_event_id"))
  needed <- needed[!str_detect(needed, "^factor\\(")]
  needed <- intersect(needed, names(data))
  d <- data %>% filter(if_all(all_of(needed), ~ !is.na(.)))
  if (nrow(d) < 40 || n_distinct(d$final_event_id) < 5) return(NULL)
  fml <- as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
  tryCatch(
    lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
    error = function(e) NULL
  )
}

extract_model_terms <- function(model, label, outcome, sample_name) {
  if (is.null(model)) return(tibble())
  sm <- summary(model)$coefficients
  cis <- confint(model)
  tibble(
    label = label,
    outcome = outcome,
    sample = sample_name,
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
    filter(term != "(Intercept)", !str_detect(term, "^factor\\(release_year\\)"))
}

sent_rows <- list()
sent_specs <- list(
  "sentiment mean w5" = c("z_sent_w5"),
  "sentiment mean and disagreement w5" = c("z_sent_w5", "z_sent_sd_w5"),
  "sentiment asymmetry w5" = c("sent_w5_pos_part", "sent_w5_neg_abs"),
  "sentiment negative interaction w5" = c("z_sent_w5", "sent_w5_negative", "z_sent_w5:sent_w5_negative"),
  "sentiment disagreement x intelligence" = c("z_sent_w5", "z_sent_sd_w5", "z_intelligence", "z_sent_sd_w5:z_intelligence"),
  "sentiment mean and disagreement w20" = c("z_sent_w20", "z_sent_sd_w20"),
  "sentiment asymmetry w20" = c("sent_w20_pos_part", "sent_w20_neg_abs")
)
for (y in c("mkt_car_1", "mkt_car_5", "mkt_car_20", "ff3_car_20")) {
  for (nm in names(sent_specs)) {
    mod <- fit_cluster(df, y, sent_specs[[nm]])
    sent_rows[[length(sent_rows) + 1]] <- extract_model_terms(mod, nm, y, "all event-firm panel") %>%
      filter(term %in% sent_specs[[nm]])
  }
}
sentiment_results <- bind_rows(sent_rows)
write.csv(sentiment_results, file.path(out_dir, "sentiment_asymmetry_disagreement_results.csv"), row.names = FALSE)

role_sent_rows <- list()
for (role_var in c("owner", "broad_upstream", "broad_downstream", "competitor", "cloud", "investor")) {
  term <- paste0("z_sent_w5:", role_var)
  mod <- fit_cluster(df, "mkt_car_20", c("z_sent_w5", role_var, term))
  role_sent_rows[[length(role_sent_rows) + 1]] <- extract_model_terms(
    mod, paste("sentiment w5 x", role_var), "mkt_car_20", "relationship sentiment interaction"
  ) %>% filter(term %in% c("z_sent_w5", role_var, paste0("z_sent_w5:", role_var)))
}
role_sent_results <- bind_rows(role_sent_rows)
write.csv(role_sent_results, file.path(out_dir, "sentiment_relationship_interactions.csv"), row.names = FALSE)

mechanism_specs <- list(
  "AA intelligence" = c("z_intelligence"),
  "AA coding" = c("z_coding"),
  "AA math" = c("z_math"),
  "MMLU-Pro" = c("z_mmlu"),
  "GPQA" = c("z_gpqa"),
  "HLE" = c("z_hle"),
  "LiveCodeBench" = c("z_livecode"),
  "Lower blended price" = c("z_low_price"),
  "Output speed" = c("z_speed"),
  "Lower TTFT" = c("z_low_ttft"),
  "Price efficiency" = c("z_price_efficiency"),
  "Speed-adjusted capability" = c("z_speed_adjusted_capability"),
  "Intelligence x lower price" = c("z_intelligence", "z_low_price", "z_intelligence:z_low_price"),
  "Intelligence x speed" = c("z_intelligence", "z_speed", "z_intelligence:z_speed"),
  "Intelligence x open weight" = c("z_intelligence", "is_open_weight_or_open_source", "z_intelligence:is_open_weight_or_open_source"),
  "Intelligence x upstream x open weight" = c(
    "z_intelligence", "broad_upstream", "is_open_weight_or_open_source",
    "z_intelligence:broad_upstream", "z_intelligence:is_open_weight_or_open_source",
    "broad_upstream:is_open_weight_or_open_source",
    "z_intelligence:broad_upstream:is_open_weight_or_open_source"
  ),
  "Intelligence x downstream x open weight" = c(
    "z_intelligence", "broad_downstream", "is_open_weight_or_open_source",
    "z_intelligence:broad_downstream", "z_intelligence:is_open_weight_or_open_source",
    "broad_downstream:is_open_weight_or_open_source",
    "z_intelligence:broad_downstream:is_open_weight_or_open_source"
  )
)

mechanism_rows <- list()
for (y in c("mkt_car_1", "mkt_car_5", "mkt_car_20", "ff3_car_20")) {
  for (nm in names(mechanism_specs)) {
    mod <- fit_cluster(df, y, mechanism_specs[[nm]])
    mechanism_rows[[length(mechanism_rows) + 1]] <- extract_model_terms(
      mod, nm, y, "all event-firm panel"
    ) %>%
      filter(term %in% mechanism_specs[[nm]])
  }
}
mechanism_results <- bind_rows(mechanism_rows)
write.csv(mechanism_results, file.path(out_dir, "cost_efficiency_capability_results.csv"), row.names = FALSE)

event_feature_summary <- df %>%
  group_by(final_event_id) %>%
  slice(1) %>%
  ungroup() %>%
  summarise(
    events = n(),
    release_start = min(as.character(release_date), na.rm = TRUE),
    release_end = max(as.character(release_date), na.rm = TRUE),
    llm_capability_events = sum(llm_capability_sample_flag == 1, na.rm = TRUE),
    media_capability_events = sum(media_capability_sample_flag == 1, na.rm = TRUE),
    multimodal_events = sum(is_multimodal == 1, na.rm = TRUE),
    reasoning_events = sum(is_reasoning_model == 1, na.rm = TRUE),
    coding_events = sum(is_coding_model == 1, na.rm = TRUE),
    media_generation_events = sum(is_media_generation_model == 1, na.rm = TRUE),
    open_weight_events = sum(is_open_weight_or_open_source == 1, na.rm = TRUE),
    chinese_model_events = sum(is_chinese_model == 1, na.rm = TRUE),
    events_with_price = sum(!is.na(price_1m_blended_3_to_1)),
    events_with_speed = sum(!is.na(median_output_tokens_per_second)),
    events_with_ttft = sum(!is.na(median_time_to_first_token_seconds)),
    events_with_sentiment_w5 = sum(!is.na(media_sent_mean_w5)),
    events_with_sentiment_sd_w5 = sum(!is.na(media_sent_sd_w5)),
    asvi_or_search_columns = sum(str_detect(names(df), regex("asvi|google|search_volume|trends|attention", ignore_case = TRUE))),
    confound_columns = sum(str_detect(names(df), regex("confound|混淆", ignore_case = TRUE)))
  )
write.csv(event_feature_summary, file.path(out_dir, "proposal_data_availability_update.csv"), row.names = FALSE)

role_map <- tribble(
  ~proposal_role, ~current_proxy, ~interpretation,
  "publisher", "owner", "当前数据把发布方或所有者合并在 owner 中，不能严格区分上市发布者和母公司。",
  "parent_company", "owner", "若模型发布者是上市公司控股主体，最接近 owner。",
  "strategic_partner", "investor/cloud/relationship_notes", "当前没有独立 strategic_partner dummy，只能由投资方、云服务方和备注近似。",
  "major_investor", "investor", "主要投资者已有独立标记。",
  "cloud_provider", "cloud", "云服务方已有独立标记。",
  "distribution_partner", "relationship_notes", "没有独立 dummy，需要人工从关系备注重新编码。",
  "direct_competitor", "competitor", "直接竞争者已有独立标记。",
  "compute_supplier", "business_upstream/real_upstream", "上游算力由商业上游和真实上游共同近似。",
  "application_exposed_firm", "business_downstream/real_downstream", "应用层暴露由商业下游和真实下游共同近似。",
  "ai_basket_member", "not available", "当前没有 AI basket 成员变量。",
  "weak_related_entity", "relationship_notes/manual coding needed", "当前没有弱关联独立标记。"
)
write.csv(role_map, file.path(out_dir, "proposal_to_current_role_mapping.csv"), row.names = FALSE)

main_formula_vars <- c("z_intelligence")
full_mod <- fit_cluster(df, "mkt_car_20", main_formula_vars)
closed_mod <- fit_cluster(df %>% filter(is_open_weight_or_open_source == 0), "mkt_car_20", main_formula_vars)

influence_fit <- function(data, label) {
  needed <- c("mkt_car_20", "z_intelligence", controls_for("mkt_car_20"), "final_event_id")
  needed <- needed[!str_detect(needed, "^factor\\(")]
  d <- data %>% filter(if_all(all_of(intersect(needed, names(.))), ~ !is.na(.)))
  if (nrow(d) < 40 || n_distinct(d$final_event_id) < 5) return(tibble())
  lm_plain <- lm(
    mkt_car_20 ~ z_intelligence + mkt_car_pre + size_log_assets + bm_ratio +
      volatility + momentum + factor(release_year),
    data = d
  )
  cutoff <- 4 / nrow(d)
  d2 <- d %>% mutate(cooks_d = cooks.distance(lm_plain)) %>% filter(cooks_d <= cutoff)
  m1 <- fit_cluster(d, "mkt_car_20", "z_intelligence")
  m2 <- fit_cluster(d2, "mkt_car_20", "z_intelligence")
  bind_rows(
    extract_model_terms(m1, label, "mkt_car_20", "baseline") %>% filter(term == "z_intelligence"),
    extract_model_terms(m2, label, "mkt_car_20", "drop CookD > 4/N") %>% filter(term == "z_intelligence")
  ) %>%
    mutate(dropped_obs = nrow(d) - nrow(d2), cook_cutoff = cutoff)
}

influence_results <- bind_rows(
  influence_fit(df, "full sample"),
  influence_fit(df %>% filter(is_open_weight_or_open_source == 0), "closed source sample")
)
write.csv(influence_results, file.path(out_dir, "influence_robustness_results.csv"), row.names = FALSE)

leave_event_out <- function(data, label) {
  events <- unique(data$final_event_id)
  base <- fit_cluster(data, "mkt_car_20", "z_intelligence")
  base_row <- extract_model_terms(base, label, "mkt_car_20", "all events") %>% filter(term == "z_intelligence")
  rows <- map_dfr(events, function(ev) {
    mod <- fit_cluster(data %>% filter(final_event_id != ev), "mkt_car_20", "z_intelligence")
    extract_model_terms(mod, label, "mkt_car_20", paste("drop event", ev)) %>%
      filter(term == "z_intelligence") %>%
      mutate(dropped_event = ev)
  })
  bind_rows(base_row %>% mutate(dropped_event = NA), rows)
}

loo_results <- bind_rows(
  leave_event_out(df, "full sample"),
  leave_event_out(df %>% filter(is_open_weight_or_open_source == 0), "closed source sample")
)
write.csv(loo_results, file.path(out_dir, "leave_one_event_out_intelligence.csv"), row.names = FALSE)

role_plot <- role_summary %>%
  filter(outcome == "mkt_car_20", role != "positive_exposure") %>%
  mutate(role_label = factor(role_label, levels = role_defs$role_label[role_defs$role != "positive_exposure"]))

png(file.path(out_dir, "figure_role_car20_means.png"), width = 1800, height = 1100, res = 180)
ggplot(role_plot, aes(x = role_label, y = mean)) +
  geom_hline(yintercept = 0, linewidth = 0.4, color = "grey55") +
  geom_col(fill = "#4B6F8C", width = 0.68) +
  geom_errorbar(aes(ymin = boot_ci_lo, ymax = boot_ci_hi), width = 0.18, linewidth = 0.5) +
  coord_flip() +
  labs(x = NULL, y = "Mean CAR[0,+20]", title = "CAR[0,+20] by event-firm exposure role") +
  theme_minimal(base_size = 12)
dev.off()

sent_plot <- sentiment_results %>%
  filter(outcome == "mkt_car_20", label == "sentiment asymmetry w5",
         term %in% c("sent_w5_pos_part", "sent_w5_neg_abs")) %>%
  mutate(term_label = recode(term, sent_w5_pos_part = "positive sentiment", sent_w5_neg_abs = "negative sentiment abs."))

png(file.path(out_dir, "figure_sentiment_asymmetry_car20.png"), width = 1500, height = 1000, res = 180)
ggplot(sent_plot, aes(x = term_label, y = coef)) +
  geom_hline(yintercept = 0, linewidth = 0.4, color = "grey55") +
  geom_point(size = 2.8, color = "#8C4B4B") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.12, linewidth = 0.5, color = "#8C4B4B") +
  labs(x = NULL, y = "Coefficient on CAR[0,+20]", title = "Asymmetric media sentiment association") +
  theme_minimal(base_size = 12)
dev.off()

cat("Missing analyses complete.\n")
cat("Outputs written to ", out_dir, "\n", sep = "")
