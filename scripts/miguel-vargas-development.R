library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)

args <- commandArgs(trailingOnly = TRUE)
input_2025 <- if (length(args) >= 1) args[[1]] else "/Users/ambar/Downloads/miguel_vargas_pitch_by_pitch_2025.csv"
input_2026 <- if (length(args) >= 2) args[[2]] else "/Users/ambar/Downloads/miguel_vargas_pitch_by_pitch_2026.csv"
output_dir <- if (length(args) >= 3) args[[3]] else "assets/img/r-code/miguel-vargas"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

navy <- "#17324D"
blue <- "#5B7DB1"
gold <- "#FDB827"
slate <- "#5F6B76"

swing_descriptions <- c(
  "swinging_strike", "swinging_strike_blocked", "foul", "foul_tip",
  "foul_bunt", "missed_bunt", "hit_into_play"
)
whiff_descriptions <- c("swinging_strike", "swinging_strike_blocked", "missed_bunt")

read_season <- function(path, season) {
  read.csv(path, stringsAsFactors = FALSE) |>
    mutate(
      season = factor(season),
      game_date = as.Date(game_date),
      plate_appearance = !is.na(events) & events != "" & coalesce(woba_denom == 1, FALSE),
      swing = description %in% swing_descriptions,
      whiff = description %in% whiff_descriptions,
      batted_ball = description == "hit_into_play" & !is.na(launch_speed),
      expected_woba = if_else(
        plate_appearance,
        coalesce(estimated_woba_using_speedangle, woba_value),
        NA_real_
      )
    )
}

pitches <- bind_rows(
  read_season(input_2025, 2025),
  read_season(input_2026, 2026)
)

season_summary <- pitches |>
  group_by(season) |>
  summarise(
    PA = sum(plate_appearance),
    xwOBA = mean(expected_woba, na.rm = TRUE),
    `BB%` = 100 * mean(events[plate_appearance] == "walk"),
    `Whiff%` = 100 * sum(whiff) / sum(swing),
    `Barrel%` = 100 * mean(launch_speed_angle[batted_ball] == 6),
    `Hard-hit%` = 100 * mean(launch_speed[batted_ball] >= 95),
    .groups = "drop"
  )

plot_data <- season_summary |>
  select(season, xwOBA, `BB%`, `Whiff%`, `Barrel%`) |>
  mutate(xwOBA = 100 * xwOBA) |>
  pivot_longer(-season, names_to = "metric", values_to = "value") |>
  mutate(
    metric = recode(metric, xwOBA = "xwOBA (×100)"),
    metric = factor(metric, levels = c("xwOBA (×100)", "Barrel%", "BB%", "Whiff%"))
  )

process_plot <- ggplot(plot_data, aes(season, value, fill = season)) +
  geom_col(width = 0.62, show.legend = FALSE) +
  geom_text(
    aes(
      label = ifelse(
        metric == "xwOBA (×100)",
        paste0(".", sprintf("%03d", round(value * 10))),
        paste0(number(value, accuracy = 0.1), "%")
      )
    ),
    vjust = -0.45,
    colour = navy,
    fontface = "bold",
    size = 3.5
  ) +
  facet_wrap(~metric, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = c(`2025` = navy, `2026` = gold)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.20))) +
  labs(
    title = "Vargas added impact and walks without adding swing-and-miss",
    subtitle = "Year-over-year process indicators from Baseball Savant pitch-level data",
    x = NULL,
    y = "Rate",
    caption = "Whiff% = misses / swings. Barrel% uses Statcast launch-speed-angle class 6. xwOBA combines expected contact values with non-contact outcomes."
  ) +
  theme_minimal(base_family = "Arial", base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", colour = navy, size = 18),
    plot.subtitle = element_text(colour = slate, size = 11, margin = margin(b = 12)),
    plot.caption = element_text(colour = slate, size = 8, hjust = 0),
    axis.title = element_text(face = "bold", colour = navy),
    axis.text = element_text(colour = "#263645"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = "#E4E9ED", linewidth = 0.35),
    strip.text = element_text(face = "bold", colour = navy),
    panel.spacing.x = grid::unit(1.2, "lines"),
    plot.margin = margin(18, 22, 16, 18)
  )

ggsave(
  file.path(output_dir, "01-sustainable-improvement.png"),
  process_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

write.csv(
  season_summary,
  file.path(output_dir, "season-summary.csv"),
  row.names = FALSE,
  na = ""
)
