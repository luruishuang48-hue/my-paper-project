#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(broom)
  library(ggplot2)
  library(estimatr)
})

input_file <- "data/panel/specr_rel_clean.csv"
out_dir <- "output/paper_plan_core"
table_dir <- file.path(out_dir, "tables")
figure_dir <- file.path(out_dir, "figures")
data_dir <- file.path(out_dir, "data")

dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(input_file, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))

rel_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor",
  "is_investor", "is_owner"
)

num_cols <- c(
  "release_year", "trend_month",
  "car_1", "car_10", "car_15", "car_20",
  "ff3_car_1", "ff3_car_10", "ff3_car_15", "ff3_car_20",
  "aa_intelligence_index", "size_log_assets", "bm_ratio", "volatility",
  "momentum", "is_open_weight", rel_vars
)

for (col in intersect(num_cols, names(df))) {
  df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
}

for (col in rel_vars) {
  if (!col %in% names(df)) stop(paste("Missing relationship variable:", col))
  df[[col]][is.na(df[[col]])] <- 0
  df[[col]] <- ifelse(df[[col]] == 1, 1, 0)
}

df <- df %>%
  mutate(
    upstream_any = as.integer(upstream_hardware == 1 | upstream_cloud == 1),
    downstream_any = as.integer(
      downstream_integrator == 1 |
        downstream_deployer == 1 |
        downstream_enabler == 1
    ),
    strategic_any = as.integer(
      upstream_hardware == 1 |
        upstream_cloud == 1 |
        is_investor == 1 |
        is_owner == 1
    ),
    open_label = if_else(is_open_weight == 1, "Open-weight", "Closed/proprietary")
  )

position_vars <- c(
  "upstream_hardware", "upstream_cloud", "downstream_integrator",
  "downstream_deployer", "downstream_enabler", "competitor"
)

bundle_vars <- c(
  "upstream_any", "strategic_any", "downstream_any", "downstream_deployer"
)

label_map <- c(
  upstream_hardware = "Upstream hardware",
  upstream_cloud = "Upstream cloud",
  downstream_integrator = "Downstream integrator",
  downstream_deployer = "Downstream deployer",
  downstream_enabler = "Downstream enabler",
  competitor = "Direct competitor",
  upstream_any = "Any upstream",
  strategic_any = "Strategic/upstream",
  downstream_any = "Any downstream"
)

outcome_map <- c(
  car_10 = "CAR[0,+10]",
  car_15 = "CAR[0,+15]",
  car_20 = "CAR[0,+20]"
)

firm_controls <- c("size_log_assets", "bm_ratio", "volatility", "momentum")
base_controls <- c(firm_controls, "factor(release_year)")

stars <- function(p) {
  ifelse(is.na(p), "",
    ifelse(p < 0.01, "***",
      ifelse(p < 0.05, "**",
        ifelse(p < 0.10, "*", "")
      )
    )
  )
}

fmt_num <- function(x, digits = 2) {
  ifelse(is.na(x), "--", formatC(x, format = "f", digits = digits))
}

fmt_coef <- function(beta, p, digits = 2) {
  ifelse(is.na(beta), "--", paste0(fmt_num(100 * beta, digits), stars(p)))
}

fmt_se <- function(se, digits = 2) {
  ifelse(is.na(se), "(--)", paste0("(", fmt_num(100 * se, digits), ")"))
}

safe_formula <- function(y, rhs) {
  as.formula(paste(y, "~", paste(rhs, collapse = " + ")))
}

model_data <- function(data, y, rhs_vars) {
  needed <- unique(c(y, "final_event_id", rhs_vars))
  needed <- needed[!grepl("^factor\\(", needed)]
  needed <- needed[needed %in% names(data)]

  out <- data %>%
    filter(!is.na(.data[[y]]), !is.na(final_event_id))

  for (v in setdiff(needed, c(y, "final_event_id"))) {
    out <- out %>% filter(!is.na(.data[[v]]))
  }

  out
}

run_lm <- function(data, y, rhs, terms) {
  rhs_plain <- rhs[!grepl("^factor\\(", rhs)]
  d <- model_data(data, y, rhs_plain)

  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) {
    return(tibble())
  }

  mod <- lm_robust(
    safe_formula(y, rhs),
    data = d,
    clusters = d$final_event_id,
    se_type = "CR0"
  )

  tidy(mod, conf.int = TRUE) %>%
    filter(term %in% terms) %>%
    mutate(
      y_var = y,
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      r_squared = summary(mod)$r.squared
    )
}

run_single_position <- function(x, y) {
  run_lm(df, y, c(x, base_controls), x) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      outcome_label = unname(outcome_map[y]),
      table_family = "single_position"
    )
}

table2 <- crossing(variable = position_vars, y_var = names(outcome_map)) %>%
  mutate(res = map2(variable, y_var, run_single_position)) %>%
  select(res) %>%
  unnest(res)

run_joint_positions <- function(y) {
  rhs <- c(position_vars, base_controls)
  run_lm(df, y, rhs, position_vars) %>%
    mutate(
      variable = term,
      variable_label = unname(label_map[term]),
      outcome_label = unname(outcome_map[y]),
      table_family = "joint_positions"
    )
}

table3_joint <- map_dfr(names(outcome_map), run_joint_positions)

run_bundle <- function(x, y) {
  run_lm(df, y, c(x, base_controls), x) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      outcome_label = unname(outcome_map[y]),
      table_family = "bundle_position"
    )
}

table3_bundle <- crossing(variable = bundle_vars, y_var = names(outcome_map)) %>%
  mutate(res = map2(variable, y_var, run_bundle)) %>%
  select(res) %>%
  unnest(res)

linear_combo <- function(mod, terms, weights) {
  b <- coef(mod)
  v <- vcov(mod)
  common <- intersect(names(weights), names(b))
  w <- weights[common]
  est <- sum(w * b[common])
  vv <- v[common, common, drop = FALSE]
  se <- sqrt(as.numeric(t(w) %*% vv %*% w))
  p <- 2 * pnorm(abs(est / se), lower.tail = FALSE)
  tibble(
    term = terms,
    estimate = est,
    std.error = se,
    p.value = p,
    conf.low = est - 1.96 * se,
    conf.high = est + 1.96 * se
  )
}

run_open_interaction <- function(x, y = "car_20") {
  rhs <- c(paste0(x, " * is_open_weight"), base_controls)
  rhs_plain <- c(x, "is_open_weight", firm_controls)
  d <- model_data(df, y, rhs_plain)

  if (nrow(d) < 30 || n_distinct(d$final_event_id) < 5) {
    return(tibble())
  }

  mod <- lm_robust(
    safe_formula(y, rhs),
    data = d,
    clusters = d$final_event_id,
    se_type = "CR0"
  )

  interaction_term <- paste0(x, ":is_open_weight")
  if (!interaction_term %in% names(coef(mod))) {
    interaction_term <- paste0("is_open_weight:", x)
  }

  closed <- linear_combo(mod, "Closed/proprietary", c(setNames(1, x)))
  open <- linear_combo(mod, "Open-weight", c(setNames(1, x), setNames(1, interaction_term)))
  diff <- linear_combo(mod, "Open minus closed", c(setNames(1, interaction_term)))

  bind_rows(closed, open, diff) %>%
    mutate(
      variable = x,
      variable_label = unname(label_map[x]),
      y_var = y,
      outcome_label = unname(outcome_map[y]),
      n = nobs(mod),
      n_events = n_distinct(d$final_event_id),
      table_family = "open_interaction"
    )
}

table4 <- map_dfr(
  c("upstream_hardware", "upstream_cloud", "downstream_deployer", "downstream_enabler", "competitor"),
  run_open_interaction
)

write_csv(table2, file.path(data_dir, "table2_baseline_position.csv"))
write_csv(table3_joint, file.path(data_dir, "table3_joint_positions.csv"))
write_csv(table3_bundle, file.path(data_dir, "table3_bundle_positions.csv"))
write_csv(table4, file.path(data_dir, "table4_open_closed_interactions.csv"))

make_reg_table <- function(data, vars, outcomes, caption, label, note, path) {
  lines <- c(
    "\\begin{table}[!htbp]",
    "\\centering",
    "\\small",
    paste0("\\caption{", caption, "}"),
    paste0("\\label{", label, "}"),
    paste0("\\begin{tabular}{l", paste(rep("c", length(outcomes)), collapse = ""), "}"),
    "\\toprule",
    paste(c("Position", unname(outcome_map[outcomes])), collapse = " & "),
    "\\\\",
    "\\midrule"
  )

  for (v in vars) {
    row <- data %>% filter(variable == v)
    coef_cells <- map_chr(outcomes, function(y) {
      r <- row %>% filter(y_var == y)
      if (nrow(r) == 0) return("--")
      fmt_coef(r$estimate[1], r$p.value[1])
    })
    se_cells <- map_chr(outcomes, function(y) {
      r <- row %>% filter(y_var == y)
      if (nrow(r) == 0) return("(--)")
      fmt_se(r$std.error[1])
    })
    lines <- c(
      lines,
      paste(c(unname(label_map[v]), coef_cells), collapse = " & "),
      "\\\\",
      paste(c("", se_cells), collapse = " & "),
      "\\\\"
    )
  }

  n_row <- map_chr(outcomes, function(y) {
    r <- data %>% filter(y_var == y)
    if (nrow(r) == 0) return("--")
    as.character(r$n[1])
  })

  lines <- c(
    lines,
    "\\midrule",
    paste(c("Observations", n_row), collapse = " & "),
    "\\\\",
    "\\bottomrule",
    "\\end{tabular}",
    paste0("\\begin{minipage}{0.94\\linewidth}\\vspace{0.4em}\\footnotesize ", note, "\\end{minipage}"),
    "\\end{table}"
  )

  writeLines(lines, path, useBytes = TRUE)
}

make_reg_table(
  table2,
  position_vars,
  names(outcome_map),
  "Baseline ecosystem position effects",
  "tab:baseline_position_effects",
  "Notes: Coefficients are percentage points. Each row comes from a separate regression of CAR on the listed position indicator. All specifications control for firm size, book-to-market, volatility, momentum, and year fixed effects. Standard errors, shown in parentheses, are clustered by event. * p<0.10, ** p<0.05, *** p<0.01.",
  file.path(table_dir, "table2_baseline_position.tex")
)

make_reg_table(
  table3_joint,
  position_vars,
  names(outcome_map),
  "Joint position regressions",
  "tab:joint_position_effects",
  "Notes: Coefficients are percentage points. All six position indicators enter simultaneously, so estimates should be read as conditional effects net of overlapping ecosystem positions. Controls and clustered standard errors match Table \\ref{tab:baseline_position_effects}. * p<0.10, ** p<0.05, *** p<0.01.",
  file.path(table_dir, "table3_joint_positions.tex")
)

make_reg_table(
  table3_bundle,
  bundle_vars,
  names(outcome_map),
  "Bundled ecosystem position effects",
  "tab:bundle_position_effects",
  "Notes: Coefficients are percentage points. Each row comes from a separate regression using a bundled position indicator. This table is designed to summarize the upstream-versus-downstream contrast. Controls and clustered standard errors match Table \\ref{tab:baseline_position_effects}. * p<0.10, ** p<0.05, *** p<0.01.",
  file.path(table_dir, "table3_bundle_positions.tex")
)

make_table4 <- function(data, path) {
  wide <- data %>%
    mutate(
      cell = paste0(fmt_coef(estimate, p.value), " ", fmt_se(std.error))
    ) %>%
    select(variable, variable_label, term, cell) %>%
    pivot_wider(names_from = term, values_from = cell)

  lines <- c(
    "\\begin{table}[!htbp]",
    "\\centering",
    "\\small",
    "\\caption{Open-weight releases and ecosystem position effects}",
    "\\label{tab:open_closed_position_effects}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "Position & Closed/proprietary & Open-weight & Open minus closed \\\\",
    "\\midrule"
  )

  for (i in seq_len(nrow(wide))) {
    lines <- c(
      lines,
      paste(
        wide$variable_label[i],
        wide$`Closed/proprietary`[i],
        wide$`Open-weight`[i],
        wide$`Open minus closed`[i],
        sep = " & "
      ),
      "\\\\"
    )
  }

  lines <- c(
    lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{minipage}{0.94\\linewidth}\\vspace{0.4em}\\footnotesize Notes: Coefficients are percentage points for CAR[0,+20]. The first two columns report the estimated position effect for closed/proprietary and open-weight releases. The last column reports the interaction difference. All models control for firm size, book-to-market, volatility, momentum, and year fixed effects. Standard errors are clustered by event. * p<0.10, ** p<0.05, *** p<0.01.\\end{minipage}",
    "\\end{table}"
  )

  writeLines(lines, path, useBytes = TRUE)
}

make_table4(table4, file.path(table_dir, "table4_open_closed_position_effects.tex"))

plot_data_1 <- table2 %>%
  filter(y_var == "car_20") %>%
  mutate(
    variable_label = factor(variable_label, levels = rev(unname(label_map[position_vars]))),
    estimate_pp = 100 * estimate,
    conf.low_pp = 100 * conf.low,
    conf.high_pp = 100 * conf.high
  )

p1 <- ggplot(plot_data_1, aes(x = estimate_pp, y = variable_label)) +
  geom_vline(xintercept = 0, linewidth = 0.4, linetype = "dashed", color = "gray45") +
  geom_errorbar(
    aes(xmin = conf.low_pp, xmax = conf.high_pp),
    orientation = "y",
    width = 0,
    linewidth = 0.7,
    color = "gray35"
  ) +
  geom_point(size = 2.5, color = "#1f5a85") +
  labs(
    x = "CAR[0,+20] effect, percentage points",
    y = NULL,
    title = "Ecosystem position effects"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave(file.path(figure_dir, "figure1_position_effects.pdf"), p1, width = 7, height = 4.5)
ggsave(file.path(figure_dir, "figure1_position_effects.png"), p1, width = 7, height = 4.5, dpi = 300)

plot_data_2 <- table4 %>%
  filter(term %in% c("Closed/proprietary", "Open-weight")) %>%
  mutate(
    variable_label = factor(
      variable_label,
      levels = rev(unname(label_map[c(
        "upstream_hardware", "upstream_cloud", "downstream_deployer",
        "downstream_enabler", "competitor"
      )]))
    ),
    estimate_pp = 100 * estimate,
    conf.low_pp = 100 * conf.low,
    conf.high_pp = 100 * conf.high
  )

p2 <- ggplot(plot_data_2, aes(x = estimate_pp, y = variable_label, color = term)) +
  geom_vline(xintercept = 0, linewidth = 0.4, linetype = "dashed", color = "gray45") +
  geom_errorbar(
    aes(xmin = conf.low_pp, xmax = conf.high_pp),
    orientation = "y",
    width = 0,
    linewidth = 0.65,
    position = position_dodge(width = 0.55)
  ) +
  geom_point(size = 2.4, position = position_dodge(width = 0.55)) +
  scale_color_manual(values = c("Closed/proprietary" = "#8b2f2f", "Open-weight" = "#1f6f5b")) +
  labs(
    x = "CAR[0,+20] effect, percentage points",
    y = NULL,
    color = NULL,
    title = "Open-weight versus proprietary releases"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave(file.path(figure_dir, "figure2_open_closed_effects.pdf"), p2, width = 7, height = 4.5)
ggsave(file.path(figure_dir, "figure2_open_closed_effects.png"), p2, width = 7, height = 4.5, dpi = 300)

summary_lines <- c(
  "# Paper plan core outputs",
  "",
  paste0("Input file: `", input_file, "`"),
  paste0("Rows: ", nrow(df)),
  paste0("Events: ", n_distinct(df$final_event_id)),
  "",
  "## Outputs",
  "",
  "- `tables/table2_baseline_position.tex`",
  "- `tables/table3_joint_positions.tex`",
  "- `tables/table3_bundle_positions.tex`",
  "- `tables/table4_open_closed_position_effects.tex`",
  "- `figures/figure1_position_effects.pdf`",
  "- `figures/figure2_open_closed_effects.pdf`",
  "",
  "## Main CAR[0,+20] baseline effects",
  ""
)

summary_table <- table2 %>%
  filter(y_var == "car_20") %>%
  transmute(
    line = paste0(
      "- ", variable_label, ": ",
      fmt_coef(estimate, p.value), ", SE ", fmt_num(100 * std.error, 2),
      ", p = ", fmt_num(p.value, 4)
    )
  ) %>%
  pull(line)

writeLines(c(summary_lines, summary_table), file.path(out_dir, "README.md"), useBytes = TRUE)

cat("Generated paper plan core outputs in: ", out_dir, "\n", sep = "")
