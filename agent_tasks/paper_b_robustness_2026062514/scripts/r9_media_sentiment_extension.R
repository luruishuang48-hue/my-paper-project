#!/usr/bin/env Rscript

# R9: Media sentiment moderation. Continuous interaction between
# event-level mean media sentiment over [0,+20] and position effects.
# Replicates the exact spec of scripts/analysis/paper_plan_core_outputs.R
# (lm_robust, CR0, clustered by final_event_id, base_controls).

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(broom)
  library(estimatr)
  library(ggplot2)
})

input_file <- "data/panel/specr_rel_clean.csv"
out_dir <- "agent_tasks/paper_b_robustness_2026062514/outputs"
figure_dir <- "output/paper_plan_core/figures"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(input_file, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year", "car_1", "car_10", "car_15", "car_20",
  "size_log_assets", "bm_ratio", "volatility",
  "momentum", "is_open_weight", "is_chinese_model", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

names(df)[names(df) == "媒体态度均值(20,20)"] <- "media_sentiment_20"
df$media_sentiment_20 <- suppressWarnings(as.numeric(df$media_sentiment_20))

mu <- mean(df$media_sentiment_20, na.rm = TRUE)
sdv <- sd(df$media_sentiment_20, na.rm = TRUE)
df$media_sentiment_z <- (df$media_sentiment_20 - mu) / sdv

df <- df %>%
  mutate(
    upstream_any = as.integer(upstream_hardware == 1 | upstream_cloud == 1),
    downstream_any = as.integer(
      downstream_integrator == 1 | downstream_deployer == 1 | downstream_enabler == 1
    )
  )

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "factor(release_year)")

label_map <- c(
  upstream_hardware = "Upstream hardware",
  upstream_any = "Any upstream",
  downstream_any = "Any downstream",
  downstream_deployer = "Downstream deployer"
)

safe_formula <- function(y, rhs) as.formula(paste(y, "~", paste(rhs, collapse = " + ")))

model_data <- function(data, y, rhs_vars) {
  needed <- unique(c(y, "final_event_id", rhs_vars))
  needed <- needed[!grepl("^factor\\(", needed)]
  needed <- needed[needed %in% names(data)]
  out <- data %>% filter(!is.na(.data[[y]]), !is.na(final_event_id))
  for (v in setdiff(needed, c(y, "final_event_id"))) {
    out <- out %>% filter(!is.na(.data[[v]]))
  }
  out
}

linear_combo <- function(mod, terms, weights) {
  b <- coef(mod)
  v <- vcov(mod)
  common <- intersect(names(weights), names(b))
  w <- weights[common]
  est <- sum(w * b[common])
  vv <- v[common, common, drop = FALSE]
  se <- sqrt(as.numeric(t(w) %*% vv %*% w))
  p <- 2 * pnorm(abs(est / se), lower.tail = FALSE)
  tibble(term = terms, estimate = est, std.error = se, p.value = p,
         conf.low = est - 1.96 * se, conf.high = est + 1.96 * se)
}

run_continuous_interaction <- function(x, mod_var = "media_sentiment_z", y = "car_20") {
  rhs <- c(paste0(x, " * ", mod_var), base_controls)
  rhs_plain <- c(x, mod_var, firm_controls)
  d <- model_data(df, y, rhs_plain)
  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) return(tibble())

  mod <- lm_robust(safe_formula(y, rhs), data = d, clusters = d$final_event_id, se_type = "CR0")

  interaction_term <- paste0(x, ":", mod_var)
  if (!interaction_term %in% names(coef(mod))) {
    interaction_term <- paste0(mod_var, ":", x)
  }

  main_x <- linear_combo(mod, "Position main effect (at mean sentiment)", c(setNames(1, x)))
  main_mod <- linear_combo(mod, "Sentiment main effect", c(setNames(1, mod_var)))
  interaction <- linear_combo(mod, "Interaction (position x sentiment)", c(setNames(1, interaction_term)))
  low_sent <- linear_combo(mod, "Position effect at -1 SD sentiment", c(setNames(1, x), setNames(-1, interaction_term)))
  high_sent <- linear_combo(mod, "Position effect at +1 SD sentiment", c(setNames(1, x), setNames(1, interaction_term)))

  bind_rows(main_x, main_mod, interaction, low_sent, high_sent) %>%
    mutate(variable = x, variable_label = unname(label_map[x]), y_var = y,
           n = nobs(mod), n_events = n_distinct(d$final_event_id), moderator = mod_var)
}

vars_to_run <- c("upstream_hardware", "upstream_any", "downstream_any", "downstream_deployer")

table_media <- map_dfr(vars_to_run, ~run_continuous_interaction(.x))
write_csv(table_media, file.path(out_dir, "r9_media_sentiment_interaction.csv"))

cat("Event-level media sentiment coverage:\n")
ev <- df %>% distinct(final_event_id, media_sentiment_20)
cat(sum(!is.na(ev$media_sentiment_20)), "of", nrow(ev), "events\n")
cat("mean:", round(mu, 4), "sd:", round(sdv, 4), "\n\n")

cat("=== Media sentiment interaction (car_20) ===\n")
print(table_media %>% select(variable, term, estimate, std.error, p.value, n, n_events))

## ---- Figure ----

plot_data_5 <- table_media %>%
  filter(term %in% c("Position effect at -1 SD sentiment", "Position effect at +1 SD sentiment")) %>%
  mutate(
    group = ifelse(term == "Position effect at -1 SD sentiment", "Sentiment -1 SD", "Sentiment +1 SD"),
    variable_label = factor(variable_label, levels = rev(c(
      "Downstream deployer", "Any downstream", "Any upstream", "Upstream hardware"
    ))),
    estimate_pp = 100 * estimate,
    conf.low_pp = 100 * conf.low,
    conf.high_pp = 100 * conf.high
  )

p5 <- ggplot(plot_data_5, aes(x = estimate_pp, y = variable_label, color = group)) +
  geom_vline(xintercept = 0, linewidth = 0.4, linetype = "dashed", color = "gray45") +
  geom_errorbar(
    aes(xmin = conf.low_pp, xmax = conf.high_pp),
    orientation = "y", width = 0, linewidth = 0.65,
    position = position_dodge(width = 0.55)
  ) +
  geom_point(size = 2.4, position = position_dodge(width = 0.55)) +
  scale_color_manual(values = c(
    "Sentiment -1 SD" = "#1f5a85", "Sentiment +1 SD" = "#8b2f2f"
  )) +
  labs(x = "CAR[0,+20] effect, percentage points", y = NULL, color = NULL,
       title = "Position effects at low vs. high media sentiment") +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave(file.path(figure_dir, "figure5_media_sentiment_effects.pdf"), p5, width = 7, height = 4.5)
ggsave(file.path(figure_dir, "figure5_media_sentiment_effects.png"), p5, width = 7, height = 4.5, dpi = 300)

cat("\nFigure written to", figure_dir, "\n")
