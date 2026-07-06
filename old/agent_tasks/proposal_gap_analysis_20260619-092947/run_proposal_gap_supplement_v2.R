#!/usr/bin/env Rscript
#
# v2: re-coded relationship variables.
#
# This script replays run_proposal_gap_supplement.R but reads the NEW
# 8-dimension relationship coding from data/panel/specr_rel_clean.csv instead
# of the OLD 8-column coding that the original script pulled from
# output/data/specr_rel_clean.csv (a stale copy of the OLD schema).
#
# Role mapping (see data/relationships/relationship_codebook.md):
#   owner               -> is_owner                              (near 1:1)
#   investor            -> is_investor                            (near 1:1, new slightly broader)
#   cloud               -> upstream_cloud                          (new much broader)
#   business_upstream + real_upstream   -> upstream_hardware, upstream_cloud (regrouped/split)
#   business_downstream + real_downstream -> downstream_integrator, downstream_deployer,
#                                              downstream_enabler (regrouped/split into three)
#   competitor          -> competitor                              (same name, slightly broader)
#
# Composite variables in the original script (pos_exposure, broad_upstream,
# broad_downstream, any_relationship) were unions (pmax) of OLD sub-columns
# that jointly spanned a single underlying concept (e.g. "any upstream
# relationship" = business_upstream OR real_upstream). Because the new schema
# instead splits/regroups those same underlying concepts into named
# categories (upstream_hardware/upstream_cloud; downstream_integrator/
# downstream_deployer/downstream_enabler), the semantically-correct
# translation is to take the union (pmax) of ALL new sub-columns that
# replaced the old ones being combined. This preserves the original
# variable's intended meaning ("does this company have an upstream
# relationship of any kind to this event, under whichever taxonomy
# (hardware or cloud) it now falls into") rather than picking one new
# column arbitrarily.
#
#   pos_exposure (old: max(owner, investor, cloud, real_upstream, real_downstream))
#     -> max(is_owner, is_investor, upstream_cloud, upstream_hardware,
#            downstream_integrator, downstream_deployer, downstream_enabler)
#        Rationale: "real_upstream"/"real_downstream" in the old coding meant
#        a tangible (not just nominal) supply-chain link; the new schema no
#        longer distinguishes "real" vs "business" sub-types, so the closest
#        semantic equivalent is "any" upstream or downstream relationship.
#        We therefore use ALL upstream/downstream new columns here, matching
#        how broad_upstream/broad_downstream below are defined, so
#        pos_exposure remains "owner OR investor OR cloud OR any structural
#        upstream/downstream link."
#
#   broad_upstream (old: max(business_upstream, real_upstream))
#     -> max(upstream_hardware, upstream_cloud)
#        Rationale: business_upstream + real_upstream jointly captured "any
#        upstream supply-chain relationship" without distinguishing hardware
#        vs cloud; the new schema splits this exact concept into
#        upstream_hardware and upstream_cloud. Union of both reproduces the
#        old variable's scope.
#
#   broad_downstream (old: max(business_downstream, real_downstream))
#     -> max(downstream_integrator, downstream_deployer, downstream_enabler)
#        Rationale: analogous regrouping on the downstream side -- the new
#        schema splits "any downstream AI-adoption relationship" into three
#        mutually-exclusive sub-roles (integrator/deployer/enabler).
#
#   any_relationship (old: max of ALL eight old columns)
#     -> max of all eight new columns (is_owner, is_investor, upstream_cloud,
#        upstream_hardware, downstream_integrator, downstream_deployer,
#        downstream_enabler, competitor)
#
# The `relation_terms` vector used in the interaction grid is updated from
# c("owner","investor","cloud","real_upstream","real_downstream","competitor",
#   "broad_upstream","broad_downstream","pos_exposure")
# to
# c("is_owner","is_investor","upstream_cloud","upstream_hardware",
#   "downstream_integrator_or_deployer_or_enabler" [renamed broad_downstream],
#   "competitor","broad_upstream","broad_downstream","pos_exposure")
# -- i.e. "real_upstream" and "real_downstream" (old single-channel,
# "tangible" sub-types) are replaced by "upstream_hardware" and
# "broad_downstream" respectively, since the new schema has no single column
# that means exactly "real_upstream"/"real_downstream"; upstream_hardware is
# the closest tangible/physical-channel analogue on the upstream side, and
# broad_downstream (the union) is used on the downstream side since the old
# real_downstream had very few 1s (81) and no single new column is a clean
# 1:1 analogue.
#
# The "relationship bundle" joint model swaps in is_owner, is_investor,
# upstream_cloud, upstream_hardware, broad_downstream, competitor in place of
# owner, investor, cloud, real_upstream, real_downstream, competitor.
#
# Output paths all get a _v2 suffix so original outputs are untouched.

suppressPackageStartupMessages({
  library(tidyverse)
  library(estimatr)
})

task_dir <- "agent_tasks/proposal_gap_analysis_20260619-092947"
out_dir <- file.path(task_dir, "outputs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

panel <- read.csv("output/data/clean_event_firm_panel.csv", stringsAsFactors = FALSE, check.names = FALSE)
rel <- read.csv("data/panel/specr_rel_clean.csv", stringsAsFactors = FALSE, check.names = FALSE)

rel_vars <- c(
  "final_event_id", "company", "is_owner", "is_investor", "upstream_cloud",
  "upstream_hardware", "downstream_integrator", "downstream_deployer",
  "downstream_enabler", "competitor", "relationship_confidence",
  "relationship_justification"
)
df <- panel %>%
  left_join(rel %>% select(any_of(rel_vars)), by = c("final_event_id", "company"))

num_vars <- c(
  "mkt_car_pre", "mkt_car_1", "mkt_car_2", "mkt_car_3", "mkt_car_5",
  "mkt_car_10", "mkt_car_15", "mkt_car_20",
  "ff3_car_pre", "ff3_car_1", "ff3_car_2", "ff3_car_3", "ff3_car_5",
  "ff3_car_10", "ff3_car_15", "ff3_car_20",
  "media_sent_mean_w2", "media_sent_mean_w5", "media_sent_mean_w10",
  "media_sent_mean_w20", "media_sent_sd_w5", "media_sent_sd_w20",
  "aa_intelligence_index", "aa_coding_index", "aa_math_index",
  "mmlu_pro", "gpqa", "hle", "livecodebench", "scicode", "math_500", "aime",
  "price_1m_input_tokens", "price_1m_output_tokens", "price_1m_blended_3_to_1",
  "median_output_tokens_per_second", "median_time_to_first_token_seconds",
  "aa_media_elo", "aa_media_rank", "aa_media_ci95", "aa_media_appearances",
  "size_log_assets", "bm_ratio", "volatility", "momentum",
  "release_year", "trend_month_since_2022_11",
  "is_open_weight_or_open_source", "is_reasoning_model", "is_coding_model",
  "is_media_generation_model", "is_model_family", "is_chinese_model",
  "is_owner", "is_investor", "upstream_cloud", "upstream_hardware",
  "downstream_integrator", "downstream_deployer", "downstream_enabler", "competitor"
)
for (v in intersect(num_vars, names(df))) df[[v]] <- suppressWarnings(as.numeric(df[[v]]))

z <- function(x) {
  sx <- sd(x, na.rm = TRUE)
  if (is.na(sx) || sx == 0) return(rep(NA_real_, length(x)))
  as.numeric((x - mean(x, na.rm = TRUE)) / sx)
}

df <- df %>%
  mutate(
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
    z_media_elo = z(aa_media_elo),
    z_media_rank_good = z(-aa_media_rank),
    z_sent_w5 = z(media_sent_mean_w5),
    z_sent_w20 = z(media_sent_mean_w20),
    # broad_upstream: union of the two new upstream categories that jointly
    # replace old business_upstream + real_upstream (see header note)
    broad_upstream = pmax(upstream_hardware, upstream_cloud, na.rm = TRUE),
    # broad_downstream: union of the three new downstream categories that
    # jointly replace old business_downstream + real_downstream
    broad_downstream = pmax(downstream_integrator, downstream_deployer,
                            downstream_enabler, na.rm = TRUE),
    # pos_exposure: old max(owner, investor, cloud, real_upstream, real_downstream)
    # -> max(is_owner, is_investor, upstream_cloud, upstream_hardware,
    #        downstream_integrator, downstream_deployer, downstream_enabler)
    pos_exposure = pmax(is_owner, is_investor, upstream_cloud, upstream_hardware,
                        downstream_integrator, downstream_deployer,
                        downstream_enabler, na.rm = TRUE),
    # any_relationship: union of all eight new indicators
    any_relationship = pmax(is_owner, is_investor, upstream_cloud, upstream_hardware,
                            downstream_integrator, downstream_deployer,
                            downstream_enabler, competitor, na.rm = TRUE)
  )

df$pos_exposure[is.infinite(df$pos_exposure)] <- NA
df$broad_upstream[is.infinite(df$broad_upstream)] <- NA
df$broad_downstream[is.infinite(df$broad_downstream)] <- NA
df$any_relationship[is.infinite(df$any_relationship)] <- NA

event_metrics <- df %>%
  group_by(final_event_id) %>%
  summarise(
    release_date = first(release_date),
    release_year = first(release_year),
    release_quarter = first(release_quarter),
    true_model_creator = first(true_model_creator),
    model_family = first(model_family),
    aa_intelligence_index = first(aa_intelligence_index),
    aa_coding_index = first(aa_coding_index),
    aa_math_index = first(aa_math_index),
    price_1m_blended_3_to_1 = first(price_1m_blended_3_to_1),
    median_output_tokens_per_second = first(median_output_tokens_per_second),
    .groups = "drop"
  ) %>%
  arrange(true_model_creator, release_date, final_event_id) %>%
  group_by(true_model_creator) %>%
  mutate(
    leap_intelligence_creator = aa_intelligence_index - lag(aa_intelligence_index),
    leap_coding_creator = aa_coding_index - lag(aa_coding_index),
    leap_math_creator = aa_math_index - lag(aa_math_index),
    leap_low_price_creator = -log1p(price_1m_blended_3_to_1) - lag(-log1p(price_1m_blended_3_to_1)),
    leap_speed_creator = median_output_tokens_per_second - lag(median_output_tokens_per_second)
  ) %>%
  ungroup() %>%
  mutate(
    z_leap_intelligence = z(leap_intelligence_creator),
    z_leap_coding = z(leap_coding_creator),
    z_leap_math = z(leap_math_creator),
    z_leap_low_price = z(leap_low_price_creator),
    z_leap_speed = z(leap_speed_creator)
  ) %>%
  select(final_event_id, starts_with("leap_"), starts_with("z_leap_"))

df <- df %>% left_join(event_metrics, by = "final_event_id")

controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
year_fe <- "factor(release_year)"
cluster_fit <- function(data, y, xvars, add_controls = TRUE) {
  rhs <- xvars
  if (add_controls) rhs <- c(rhs, controls, year_fe)
  needed <- unique(c(y, rhs, "final_event_id"))
  needed <- needed[!grepl("^factor\\(", needed)]
  d <- data %>% filter(if_all(all_of(intersect(needed, names(.))), ~ !is.na(.)))
  if (nrow(d) < 40 || n_distinct(d$final_event_id) < 5) return(NULL)
  fml <- as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
  tryCatch(lm_robust(fml, data = d, clusters = d$final_event_id, se_type = "CR0"),
           error = function(e) NULL)
}

extract_term <- function(model, term, label, outcome, sample_name, n_events = NA_integer_) {
  if (is.null(model)) return(NULL)
  sm <- summary(model)$coefficients
  if (!term %in% rownames(sm)) return(NULL)
  data.frame(
    label = label,
    outcome = outcome,
    sample = sample_name,
    term = term,
    coef = unname(sm[term, "Estimate"]),
    se = unname(sm[term, "Std. Error"]),
    p_value = unname(sm[term, "Pr(>|t|)"]),
    ci_lo = unname(confint(model)[term, 1]),
    ci_hi = unname(confint(model)[term, 2]),
    n = model$nobs,
    n_events = ifelse(is.na(n_events), model$nclusters, n_events),
    r_squared = summary(model)$r.squared,
    stringsAsFactors = FALSE
  )
}

run_metric_grid <- function(data, outcome, metrics, sample_name) {
  rows <- list()
  for (m in names(metrics)) {
    x <- metrics[[m]]
    mod <- cluster_fit(data, outcome, x)
    rows[[length(rows) + 1]] <- extract_term(mod, x, m, outcome, sample_name)
  }
  bind_rows(rows)
}

metric_set <- c(
  "AA intelligence" = "z_intelligence",
  "AA coding" = "z_coding",
  "AA math" = "z_math",
  "MMLU-Pro" = "z_mmlu",
  "GPQA" = "z_gpqa",
  "HLE" = "z_hle",
  "LiveCodeBench" = "z_livecode",
  "Lower blended price" = "z_low_price",
  "Output speed" = "z_speed",
  "Lower TTFT" = "z_low_ttft",
  "Media Elo" = "z_media_elo",
  "Better media rank" = "z_media_rank_good",
  "Media sentiment w5" = "z_sent_w5",
  "Media sentiment w20" = "z_sent_w20",
  "Creator intelligence leap" = "z_leap_intelligence",
  "Creator coding leap" = "z_leap_coding",
  "Creator math leap" = "z_leap_math",
  "Creator price-efficiency leap" = "z_leap_low_price",
  "Creator speed leap" = "z_leap_speed"
)

capability_rows <- bind_rows(
  run_metric_grid(df, "mkt_car_1", metric_set, "all event-firm panel"),
  run_metric_grid(df, "mkt_car_5", metric_set, "all event-firm panel"),
  run_metric_grid(df, "mkt_car_20", metric_set, "all event-firm panel"),
  run_metric_grid(df, "ff3_car_20", metric_set, "all event-firm panel")
)
write.csv(capability_rows, file.path(out_dir, "proposal_capability_mechanisms_v2.csv"), row.names = FALSE)

# relation_terms: old real_upstream/real_downstream replaced by
# upstream_hardware (closest tangible/physical upstream analogue) and
# broad_downstream (union of the three new downstream categories, since no
# single new column corresponds 1:1 to the old "real_downstream" tangible
# subtype, which had only 81 positive observations).
relation_terms <- c("is_owner", "is_investor", "upstream_cloud", "upstream_hardware",
                    "competitor", "broad_upstream", "broad_downstream", "pos_exposure")
interaction_specs <- expand.grid(
  metric_label = c("AA intelligence", "AA coding", "AA math", "Lower blended price", "Output speed"),
  relation = relation_terms,
  stringsAsFactors = FALSE
)
metric_lookup <- c(
  "AA intelligence" = "z_intelligence",
  "AA coding" = "z_coding",
  "AA math" = "z_math",
  "Lower blended price" = "z_low_price",
  "Output speed" = "z_speed"
)
interaction_rows <- list()
for (i in seq_len(nrow(interaction_specs))) {
  metric <- metric_lookup[[interaction_specs$metric_label[i]]]
  relv <- interaction_specs$relation[i]
  term <- paste0(metric, ":", relv)
  mod <- cluster_fit(df, "mkt_car_20", c(metric, relv, term))
  interaction_rows[[length(interaction_rows) + 1]] <- extract_term(
    mod, term,
    paste(interaction_specs$metric_label[i], "x", relv),
    "mkt_car_20", "relationship interaction"
  )
}
interaction_rows <- bind_rows(interaction_rows)
write.csv(interaction_rows, file.path(out_dir, "proposal_relationship_interactions_v2.csv"), row.names = FALSE)

joint_specs <- list(
  "technical bundle" = c("z_intelligence", "z_coding", "z_math", "z_low_price", "z_speed", "z_low_ttft"),
  "technical plus sentiment" = c("z_intelligence", "z_coding", "z_math", "z_low_price", "z_speed", "z_sent_w5"),
  "event type bundle" = c("z_intelligence", "is_open_weight_or_open_source", "is_reasoning_model",
                          "is_coding_model", "is_model_family", "is_chinese_model"),
  # relationship bundle: is_owner/is_investor/upstream_cloud/upstream_hardware
  # replace owner/investor/cloud; broad_downstream (union of the three new
  # downstream categories) replaces real_downstream/real_upstream's downstream
  # half, and upstream_hardware retains the tangible upstream channel.
  "relationship bundle" = c("z_intelligence", "is_owner", "is_investor", "upstream_cloud",
                            "upstream_hardware", "broad_downstream", "competitor")
)
joint_rows <- list()
for (nm in names(joint_specs)) {
  mod <- cluster_fit(df, "mkt_car_20", joint_specs[[nm]])
  for (term in joint_specs[[nm]]) {
    joint_rows[[length(joint_rows) + 1]] <- extract_term(mod, term, nm, "mkt_car_20", "joint model")
  }
}
joint_rows <- bind_rows(joint_rows)
write.csv(joint_rows, file.path(out_dir, "proposal_joint_models_v2.csv"), row.names = FALSE)

time_specs <- c(
  "AA intelligence" = "z_intelligence",
  "AA coding" = "z_coding",
  "AA math" = "z_math",
  "Lower blended price" = "z_low_price",
  "Output speed" = "z_speed",
  "Media sentiment w5" = "z_sent_w5"
)
time_rows <- list()
for (nm in names(time_specs)) {
  x <- time_specs[[nm]]
  term <- paste0(x, ":trend_month_since_2022_11")
  mod <- cluster_fit(df, "mkt_car_20", c(x, "trend_month_since_2022_11", term), add_controls = TRUE)
  time_rows[[length(time_rows) + 1]] <- extract_term(mod, term, paste(nm, "x trend"), "mkt_car_20", "time interaction")
}
time_rows <- bind_rows(time_rows)
write.csv(time_rows, file.path(out_dir, "proposal_time_learning_interactions_v2.csv"), row.names = FALSE)

event_order <- df %>%
  group_by(final_event_id) %>%
  summarise(release_date = first(release_date), .groups = "drop") %>%
  arrange(release_date, final_event_id) %>%
  mutate(event_order = row_number())
df_roll <- df %>% left_join(event_order, by = "final_event_id")

roll_rows <- list()
window_size <- 18
max_start <- max(event_order$event_order, na.rm = TRUE) - window_size + 1
for (s in seq_len(max_start)) {
  event_ids <- event_order %>%
    filter(event_order >= s, event_order < s + window_size) %>%
    pull(final_event_id)
  d <- df_roll %>% filter(final_event_id %in% event_ids)
  mod <- cluster_fit(d, "mkt_car_20", "z_intelligence", add_controls = TRUE)
  row <- extract_term(mod, "z_intelligence", paste0("events ", s, "-", s + window_size - 1),
                      "mkt_car_20", "rolling 18-event window",
                      n_events = length(event_ids))
  if (!is.null(row)) {
    row$start_event_order <- s
    row$end_event_order <- s + window_size - 1
    row$start_date <- min(event_order$release_date[event_order$final_event_id %in% event_ids], na.rm = TRUE)
    row$end_date <- max(event_order$release_date[event_order$final_event_id %in% event_ids], na.rm = TRUE)
    roll_rows[[length(roll_rows) + 1]] <- row
  }
}
roll_rows <- bind_rows(roll_rows)
write.csv(roll_rows, file.path(out_dir, "proposal_rolling_event_window_v2.csv"), row.names = FALSE)

event_summary <- df %>%
  group_by(final_event_id) %>%
  slice(1) %>%
  ungroup() %>%
  summarise(
    n_events = n(),
    n_llm_capability_events = sum(llm_capability_sample_flag == 1, na.rm = TRUE),
    n_media_capability_events = sum(media_capability_sample_flag == 1, na.rm = TRUE),
    n_events_with_intelligence = sum(!is.na(aa_intelligence_index)),
    n_events_with_coding = sum(!is.na(aa_coding_index)),
    n_events_with_math = sum(!is.na(aa_math_index)),
    n_events_with_price = sum(!is.na(price_1m_blended_3_to_1)),
    n_events_with_speed = sum(!is.na(median_output_tokens_per_second)),
    n_events_with_media_elo = sum(!is.na(aa_media_elo)),
    n_events_with_sentiment_w5 = sum(!is.na(media_sent_mean_w5)),
    n_events_with_creator_intelligence_leap = sum(!is.na(leap_intelligence_creator)),
    n_events_with_creator_price_leap = sum(!is.na(leap_low_price_creator)),
    n_events_with_asvi_columns = sum(grepl("asvi|search_volume|google_trends|attention", names(df), ignore.case = TRUE)),
    n_events_with_confound_columns = sum(grepl("confound|混淆", names(df), ignore.case = TRUE))
  )
write.csv(event_summary, file.path(out_dir, "proposal_gap_data_availability_v2.csv"), row.names = FALSE)

topline <- capability_rows %>%
  filter(outcome == "mkt_car_20") %>%
  arrange(p_value) %>%
  mutate(across(c(coef, se, p_value, ci_lo, ci_hi, r_squared), ~ round(.x, 5)))
write.csv(topline, file.path(out_dir, "proposal_topline_capability_car20_v2.csv"), row.names = FALSE)

cat("Supplement analysis (v2, new relationship coding) complete.\n")
cat("Outputs written to", out_dir, "\n")
