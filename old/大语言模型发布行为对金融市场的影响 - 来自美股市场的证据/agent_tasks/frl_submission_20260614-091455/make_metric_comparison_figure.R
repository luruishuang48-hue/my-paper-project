library(readr)
library(dplyr)
library(ggplot2)
library(scales)

root <- normalizePath(file.path(getwd(), "..", ".."))
data_path <- file.path(root, "output", "tables", "specr_results_all.csv")
out_dir <- file.path(getwd(), "figures")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

metric_labels <- c(
  aa_intelligence_index = "AA Intelligence",
  aa_coding_index = "AA Coding",
  aa_math_index = "AA Math",
  aa_media_elo = "AA Media Elo"
)

d <- read_csv(data_path, show_col_types = FALSE) |>
  filter(y_var == "car_20", x_var %in% names(metric_labels)) |>
  group_by(x_var) |>
  summarise(
    n_specs = n(),
    median_est = median(estimate, na.rm = TRUE),
    sig_share = mean(sig_05, na.rm = TRUE),
    positive_share = mean(estimate > 0, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    metric = factor(metric_labels[x_var],
                    levels = c("AA Math", "AA Media Elo", "AA Coding", "AA Intelligence")),
    sig_label = paste0(round(100 * sig_share, 1), "% significant"),
    pos_label = paste0(round(100 * positive_share, 1), "% positive")
  )

p <- ggplot(d, aes(x = median_est, y = metric)) +
  geom_vline(xintercept = 0, linewidth = 0.4, linetype = "dashed", color = "gray45") +
  geom_segment(aes(x = 0, xend = median_est, yend = metric), linewidth = 0.7, color = "gray70") +
  geom_point(aes(size = sig_share), color = "#1f5f8b") +
  geom_text(aes(label = sig_label), hjust = -0.12, size = 3.0, color = "gray20") +
  scale_x_continuous(labels = label_number(accuracy = 0.0001),
                     expand = expansion(mult = c(0.06, 0.28))) +
  scale_size_continuous(range = c(2.8, 7), guide = "none") +
  labs(
    x = "Median coefficient across CAR[0,+20] specifications",
    y = NULL
  ) +
  theme_classic(base_size = 10) +
  theme(
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.text.y = element_text(color = "gray15"),
    axis.title.x = element_text(color = "gray20"),
    plot.margin = margin(8, 18, 8, 8)
  )

ggsave(file.path(out_dir, "figure_metric_comparison_car20.pdf"), p, width = 6.6, height = 3.2)
ggsave(file.path(out_dir, "figure_metric_comparison_car20.png"), p, width = 6.6, height = 3.2, dpi = 300)
