library(dplyr)
library(ggplot2)
library(scales)

args <- commandArgs(trailingOnly = TRUE)
input_file <- if (length(args) >= 1) {
  args[[1]]
} else {
  "/Users/ambar/Downloads/willson_contreras_pitch_by_pitch_2026.csv"
}
output_dir <- if (length(args) >= 2) {
  args[[2]]
} else {
  "assets/img/r-code/willson-contreras"
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

navy <- "#17324D"
blue <- "#3F7CAC"
warm_red <- "#D97368"
slate <- "#5F6B76"

official_ab_events <- c(
  "single", "double", "triple", "home_run", "field_out", "force_out",
  "grounded_into_double_play", "field_error", "fielders_choice",
  "fielders_choice_out", "strikeout", "strikeout_double_play",
  "double_play", "triple_play"
)

format_average <- function(value) {
  sub("^0", "", sprintf("%.3f", value))
}

raw_pitches <- read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE)

clean_pitches <- raw_pitches |>
  mutate(
    game_date = as.Date(game_date),
    terminal_pa = !is.na(events) & events != "",
    official_ab = events %in% official_ab_events,
    valid_zone = !is.na(zone) & zone %in% 1:9,
    expected_woba = coalesce(estimated_woba_using_speedangle, woba_value),
    total_bases = case_when(
      events == "single" ~ 1,
      events == "double" ~ 2,
      events == "triple" ~ 3,
      events == "home_run" ~ 4,
      TRUE ~ 0
    )
  )

analysis_sample <- clean_pitches |>
  filter(terminal_pa, official_ab, valid_zone, !is.na(expected_woba))

zone_summary <- analysis_sample |>
  group_by(zone) |>
  summarise(
    AB = n(),
    xwOBA = mean(expected_woba),
    SLG = sum(total_bases) / AB,
    .groups = "drop"
  ) |>
  mutate(
    column = ((zone - 1) %% 3) + 1,
    row = 3 - ((zone - 1) %/% 3),
    label = paste0(
      "Zone ", zone, "\n",
      "xwOBA ", vapply(xwOBA, format_average, character(1)), "\n",
      "SLG ", vapply(SLG, format_average, character(1)), "\n",
      AB, " AB"
    )
  )

audit_summary <- tibble(
  stage = c(
    "Raw pitch rows",
    "Terminal PA rows",
    "Official at-bats",
    "Official AB in zones 1–9",
    "Complete xwOBA records"
  ),
  rows = c(
    nrow(clean_pitches),
    sum(clean_pitches$terminal_pa),
    sum(clean_pitches$terminal_pa & clean_pitches$official_ab),
    sum(clean_pitches$terminal_pa & clean_pitches$official_ab & clean_pitches$valid_zone),
    nrow(analysis_sample)
  )
)

league_center <- weighted.mean(zone_summary$xwOBA, zone_summary$AB)

zone_plot <- ggplot(zone_summary, aes(column, row, fill = xwOBA)) +
  geom_tile(colour = "white", linewidth = 4) +
  geom_text(
    aes(label = label, colour = xwOBA < 0.31 | xwOBA > 0.52),
    lineheight = 1.15,
    fontface = "bold",
    size = 4.1
  ) +
  scale_fill_gradient2(
    low = blue,
    mid = "#F4F1EC",
    high = warm_red,
    midpoint = league_center,
    limits = range(zone_summary$xwOBA)
  ) +
  scale_colour_manual(values = c(`FALSE` = navy, `TRUE` = "white"), guide = "none") +
  coord_equal(expand = FALSE) +
  scale_x_continuous(breaks = NULL) +
  scale_y_continuous(breaks = NULL) +
  labs(
    title = "Cleaning the sample reveals Contreras's lower-zone damage",
    subtitle = paste0(
      comma(nrow(raw_pitches)), " pitch rows → ",
      comma(nrow(analysis_sample)),
      " official at-bats ending in Statcast zones 1–9 · catcher's view"
    ),
    x = NULL,
    y = NULL,
    fill = "xwOBA",
    caption = paste0(
      "Blue = below the in-zone sample average (",
      format_average(league_center),
      "); warm red = above. xwOBA uses expected contact value and actual non-contact outcomes."
    )
  ) +
  theme_void(base_family = "Arial", base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", colour = navy, size = 18),
    plot.subtitle = element_text(colour = slate, size = 10.5, margin = margin(b = 12)),
    plot.caption = element_text(colour = slate, size = 8.5, hjust = 0, margin = margin(t = 10)),
    legend.position = "right",
    legend.title = element_text(face = "bold", colour = navy),
    legend.text = element_text(colour = slate),
    plot.margin = margin(18, 22, 16, 18)
  )

ggsave(
  file.path(output_dir, "01-clean-zone-production.png"),
  zone_plot,
  width = 9.4,
  height = 7.2,
  dpi = 180,
  bg = "white"
)

write.csv(
  zone_summary |> select(zone, AB, xwOBA, SLG),
  file.path(output_dir, "zone-summary.csv"),
  row.names = FALSE,
  na = ""
)

write.csv(
  audit_summary,
  file.path(output_dir, "data-quality-audit.csv"),
  row.names = FALSE,
  na = ""
)
