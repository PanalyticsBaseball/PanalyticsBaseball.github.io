library(dplyr)
library(ggplot2)
library(ggrepel)
library(scales)
library(tidyr)

args <- commandArgs(trailingOnly = TRUE)
input_file <- if (length(args) >= 1) args[[1]] else "/Users/ambar/Downloads/Bubba_Chandler_pitch_by_pitch_2026.csv"
output_dir <- if (length(args) >= 2) args[[2]] else "assets/img/player-analysis/bubba-chandler"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

navy <- "#17324D"
blue <- "#5B7DB1"
light_blue <- "#AFC3DF"
gold <- "#FDB827"
red <- "#C94C4C"
slate <- "#5F6B76"
light_gray <- "#EEF2F5"

theme_portfolio <- function() {
  theme_minimal(base_family = "Arial", base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", colour = navy, size = 18),
      plot.subtitle = element_text(colour = slate, size = 11, margin = margin(b = 12)),
      plot.caption = element_text(colour = slate, size = 8, hjust = 0),
      axis.title = element_text(face = "bold", colour = navy),
      axis.text = element_text(colour = "#263645"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#E4E9ED", linewidth = 0.35),
      strip.text = element_text(face = "bold", colour = navy),
      legend.position = "top",
      legend.title = element_text(face = "bold"),
      plot.margin = margin(18, 22, 16, 18)
    )
}

phase_levels <- c("High slot", "Transition", "Low slot", "Late rebound")
phase_colors <- c(
  "High slot" = navy,
  "Transition" = gold,
  "Low slot" = blue,
  "Late rebound" = red
)
phase_shapes <- c(
  "High slot" = 21,
  "Transition" = 24,
  "Low slot" = 22,
  "Late rebound" = 23
)
pitch_shapes <- c(FF = 21, SL = 22, CH = 24, CU = 23, SI = 25, ST = 8)

swing_descriptions <- c(
  "swinging_strike", "swinging_strike_blocked", "foul", "foul_tip",
  "foul_bunt", "missed_bunt", "hit_into_play"
)
whiff_descriptions <- c("swinging_strike", "swinging_strike_blocked", "missed_bunt")

pitches <- read.csv(input_file, stringsAsFactors = FALSE) |>
  mutate(
    game_date = as.Date(game_date),
    phase = case_when(
      game_date <= as.Date("2026-06-13") ~ "High slot",
      game_date <= as.Date("2026-07-22") ~ "Transition",
      game_date <= as.Date("2026-09-13") ~ "Low slot",
      TRUE ~ "Late rebound"
    ),
    phase = factor(phase, levels = phase_levels),
    swing = description %in% swing_descriptions,
    whiff = description %in% whiff_descriptions,
    called_strike = description == "called_strike",
    in_zone = zone >= 1 & zone <= 9,
    plate_appearance = !is.na(events) & events != "",
    batted_ball = description == "hit_into_play" & !is.na(launch_speed)
  )

game_slot <- pitches |>
  group_by(game_date, game_pk, phase) |>
  summarise(
    arm_angle = mean(arm_angle, na.rm = TRUE),
    pitches = n(),
    .groups = "drop"
  )

phase_bands <- tibble(
  phase = factor(phase_levels, levels = phase_levels),
  xmin = as.Date(c("2026-03-31", "2026-06-14", "2026-07-23", "2026-09-14")),
  xmax = as.Date(c("2026-06-13", "2026-07-22", "2026-09-13", "2026-09-25")),
  ymin = -Inf,
  ymax = Inf
)

phase_labels <- game_slot |>
  group_by(phase) |>
  summarise(
    x = as.Date(mean(as.numeric(game_date))),
    y = mean(arm_angle),
    label = paste0(levels(phase)[as.integer(first(phase))], "\n", number(y, accuracy = 0.1), "°"),
    .groups = "drop"
  )

arm_slot_plot <- ggplot() +
  geom_rect(
    data = phase_bands,
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = phase),
    alpha = 0.10,
    inherit.aes = FALSE
  ) +
  geom_line(
    data = game_slot,
    aes(game_date, arm_angle),
    colour = navy,
    linewidth = 1
  ) +
  geom_point(
    data = game_slot,
    aes(game_date, arm_angle, fill = phase, shape = phase),
    colour = "white",
    stroke = 0.8,
    size = 3.4
  ) +
  geom_text(
    data = phase_labels,
    aes(x, y + 3.5, label = label, colour = phase),
    fontface = "bold",
    lineheight = 0.95,
    size = 3.5,
    show.legend = FALSE
  ) +
  geom_vline(
    xintercept = as.Date(c("2026-06-19", "2026-07-28", "2026-09-19")),
    linetype = "dashed",
    colour = slate,
    linewidth = 0.45
  ) +
  annotate("text", x = as.Date("2026-06-19"), y = 52.5, label = "Transition begins", angle = 90, vjust = -0.5, size = 3, colour = slate) +
  annotate("text", x = as.Date("2026-07-28"), y = 52.5, label = "Low-slot system", angle = 90, vjust = -0.5, size = 3, colour = slate) +
  annotate("text", x = as.Date("2026-09-19"), y = 52.5, label = "Late rebound", angle = 90, vjust = -0.5, size = 3, colour = slate) +
  scale_fill_manual(values = phase_colors, name = "Mechanical phase") +
  scale_colour_manual(values = phase_colors, guide = "none") +
  scale_shape_manual(values = phase_shapes, name = "Mechanical phase") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %d", expand = expansion(mult = c(0.01, 0.05))) +
  scale_y_continuous(limits = c(35, 54), breaks = seq(36, 52, 4)) +
  labs(
    title = "Bubba Chandler lowered his arm slot throughout the season",
    subtitle = "Average arm angle by game, with the mechanical phases used in the performance comparison",
    x = NULL,
    y = "Arm angle (degrees)",
    caption = "Source: Baseball Savant pitch-by-pitch data through September 25, 2026. Phase boundaries reflect sustained game-level changes, not a single-pitch threshold."
  ) +
  theme_portfolio()

ggsave(
  file.path(output_dir, "01-arm-slot-timeline.png"),
  arm_slot_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

phase_summary <- pitches |>
  group_by(phase) |>
  summarise(
    games = n_distinct(game_pk),
    pitches = n(),
    pa = sum(plate_appearance),
    arm_angle = mean(arm_angle, na.rm = TRUE),
    `K%` = 100 * mean(events[plate_appearance] %in% c("strikeout", "strikeout_double_play")),
    `BB%` = 100 * mean(events[plate_appearance] %in% c("walk", "intent_walk")),
    `Swing%` = 100 * mean(swing),
    `Zone%` = 100 * mean(in_zone, na.rm = TRUE),
    `CSW%` = 100 * mean(called_strike | whiff),
    `Called strike%` = 100 * mean(called_strike),
    `Whiff%` = 100 * sum(whiff) / sum(swing),
    `Chase%` = 100 * mean(swing[!is.na(in_zone) & !in_zone]),
    `Zone contact%` = 100 * (1 - sum(whiff & in_zone, na.rm = TRUE) / sum(swing & in_zone, na.rm = TRUE)),
    `Soft contact%` = 100 * mean(launch_speed[batted_ball] < 80),
    `Hard-hit%` = 100 * mean(launch_speed[batted_ball] >= 95),
    `Avg EV` = mean(launch_speed[batted_ball], na.rm = TRUE),
    xwOBA = mean(estimated_woba_using_speedangle[plate_appearance], na.rm = TRUE),
    .groups = "drop"
  )

deception_metrics <- phase_summary |>
  filter(phase != "Late rebound") |>
  select(phase, `K%`, `Swing%`, `Whiff%`, `Chase%`) |>
  pivot_longer(-phase, names_to = "metric", values_to = "value") |>
  mutate(
    metric = factor(metric, levels = c("Swing%", "Chase%", "Whiff%", "K%")),
    phase = factor(phase, levels = phase_levels)
  )

deception_plot <- ggplot(deception_metrics, aes(value, phase, colour = phase, shape = phase)) +
  geom_segment(
    aes(x = 0, xend = value, y = phase, yend = phase),
    colour = "#D8E0E6",
    linewidth = 1.2
  ) +
  geom_point(size = 4.5) +
  geom_text(
    aes(label = paste0(number(value, accuracy = 0.1), "%")),
    hjust = -0.3,
    size = 3.4,
    fontface = "bold",
    show.legend = FALSE
  ) +
  facet_wrap(~metric, scales = "free_x", ncol = 2) +
  scale_colour_manual(values = phase_colors, name = "Mechanical phase") +
  scale_shape_manual(values = phase_shapes) +
  scale_x_continuous(labels = label_percent(scale = 1), expand = expansion(mult = c(0, 0.24))) +
  labs(
    title = "The lower slot improved neither deception nor strikeout rate",
    subtitle = "High slot generated the most swings, chases, whiffs, and strikeouts; the late two-start rebound is excluded",
    x = "Rate",
    y = NULL,
    colour = "Mechanical phase",
    caption = "Whiff% = misses / swings. Chase% = swings at pitches outside the strike zone. K% = strikeouts / plate appearances."
  ) +
  theme_portfolio() +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

ggsave(
  file.path(output_dir, "02-deception-by-arm-slot.png"),
  deception_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

contact_metrics <- phase_summary |>
  filter(phase != "Late rebound") |>
  select(phase, `Soft contact%`, `Hard-hit%`, xwOBA) |>
  mutate(
    xwOBA = xwOBA * 100,
    phase = factor(phase, levels = phase_levels)
  ) |>
  pivot_longer(-phase, names_to = "metric", values_to = "value") |>
  mutate(
    metric = recode(metric, xwOBA = "xwOBA (×100)"),
    metric = factor(metric, levels = c("Soft contact%", "Hard-hit%", "xwOBA (×100)"))
  )

contact_plot <- ggplot(contact_metrics, aes(phase, value, fill = phase)) +
  geom_col(width = 0.62, show.legend = FALSE) +
  geom_text(
    aes(label = ifelse(metric == "xwOBA (×100)", paste0(".", sprintf("%03d", round(value * 10))), paste0(number(value, accuracy = 0.1), "%"))),
    vjust = -0.45,
    size = 3.4,
    fontface = "bold",
    colour = navy
  ) +
  facet_wrap(~metric, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = phase_colors) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "The low slot traded some command gains for mixed contact quality",
    subtitle = "Soft contact increased, but hard-hit rate also rose and expected results deteriorated after the transition phase",
    x = NULL,
    y = "Rate",
    caption = "Soft contact = batted balls below 80 mph. Hard-hit = batted balls at 95+ mph. xwOBA uses plate-appearance outcomes and expected contact values."
  ) +
  theme_portfolio() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid.major.x = element_blank()
  )

ggsave(
  file.path(output_dir, "03-contact-results-by-arm-slot.png"),
  contact_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

phase_pitch_totals <- pitches |>
  filter(!is.na(pitch_type), pitch_type != "") |>
  count(phase, name = "phase_pitches")

breaking_summary <- pitches |>
  filter(pitch_type %in% c("SL", "ST", "CU"), phase %in% c("High slot", "Transition", "Low slot")) |>
  group_by(phase, pitch_type, pitch_name) |>
  summarise(
    pitches = n(),
    velocity = mean(release_speed, na.rm = TRUE),
    hb = 12 * mean(pfx_x, na.rm = TRUE),
    ivb = 12 * mean(pfx_z, na.rm = TRUE),
    whiff = 100 * sum(whiff) / sum(swing),
    chase = 100 * mean(swing[!is.na(in_zone) & !in_zone]),
    xwoba = mean(estimated_woba_using_speedangle[plate_appearance], na.rm = TRUE),
    .groups = "drop"
  ) |>
  left_join(phase_pitch_totals, by = "phase") |>
  mutate(
    usage = 100 * pitches / phase_pitches,
    pitch_label = recode(pitch_type, SL = "Slider", ST = "Sweeper", CU = "Curveball"),
    label = paste0(pitch_label, "\n", number(velocity, accuracy = 0.1), " mph"),
    phase = factor(phase, levels = phase_levels)
  )

breaking_plot <- ggplot(breaking_summary, aes(hb, ivb, colour = phase, fill = phase, shape = pitch_type)) +
  geom_hline(yintercept = 0, colour = "#D8DEE4", linewidth = 0.4) +
  geom_vline(xintercept = 0, colour = "#D8DEE4", linewidth = 0.4) +
  geom_path(aes(group = pitch_label), colour = "#B8C2CC", linewidth = 0.8, linetype = "dashed") +
  geom_point(aes(size = usage), alpha = 0.9, stroke = 1) +
  geom_text_repel(
    aes(label = label),
    size = 3,
    colour = navy,
    box.padding = 0.45,
    point.padding = 0.35,
    min.segment.length = 0,
    show.legend = FALSE,
    seed = 18
  ) +
  scale_colour_manual(values = phase_colors) +
  scale_fill_manual(values = phase_colors, guide = "none") +
  scale_shape_manual(
    values = c(SL = 21, ST = 22, CU = 24),
    labels = c(SL = "Slider", ST = "Sweeper", CU = "Curveball"),
    name = "Pitch type"
  ) +
  scale_size_continuous(range = c(4, 10), breaks = c(3, 10, 20), labels = function(x) paste0(x, "%")) +
  guides(
    shape = guide_legend(order = 1, nrow = 1, byrow = TRUE),
    colour = guide_legend(order = 2, nrow = 1, byrow = TRUE, override.aes = list(size = 4)),
    size = guide_legend(order = 3, nrow = 1, byrow = TRUE)
  ) +
  coord_equal(xlim = c(-1.5, 10.5), ylim = c(-5, 8.5), clip = "off") +
  labs(
    title = "Lower slot reshaped the breaking-ball mix",
    subtitle = "The sweeper disappeared, while the curveball gained a larger role and more depth",
    x = "Horizontal break (inches)",
    y = "Induced vertical break (inches)",
    colour = "Mechanical phase",
    size = "Usage",
    caption = "Movement is shown from the pitcher's perspective. Point size represents pitch usage within each mechanical phase."
  ) +
  theme_portfolio() +
  theme(
    legend.position = "right",
    legend.box = "vertical",
    legend.box.just = "left"
  )

ggsave(
  file.path(output_dir, "04-breaking-ball-shape.png"),
  breaking_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

write.csv(
  phase_summary,
  file.path(output_dir, "phase-summary.csv"),
  row.names = FALSE,
  na = ""
)

sequenced_pitches <- pitches |>
  arrange(game_pk, at_bat_number, pitch_number) |>
  group_by(game_pk) |>
  mutate(
    game_pitch = row_number(),
    fatigue_bucket = cut(
      game_pitch,
      breaks = c(0, 25, 50, 75, Inf),
      labels = c("1–25", "26–50", "51–75", "76+")
    )
  ) |>
  group_by(game_pk, at_bat_number) |>
  mutate(previous_pitch = lag(pitch_type)) |>
  ungroup()

exposure_summary <- pitches |>
  filter(!is.na(n_thruorder_pitcher), n_thruorder_pitcher <= 3) |>
  mutate(
    exposure = recode(
      as.character(n_thruorder_pitcher),
      `1` = "First PA",
      `2` = "Second PA",
      `3` = "Third+ PA"
    ),
    exposure = factor(exposure, levels = c("First PA", "Second PA", "Third+ PA"))
  ) |>
  group_by(exposure) |>
  summarise(
    pa = sum(plate_appearance),
    `K%` = 100 * mean(events[plate_appearance] %in% c("strikeout", "strikeout_double_play")),
    `BB%` = 100 * mean(events[plate_appearance] %in% c("walk", "intent_walk")),
    xwOBA = mean(estimated_woba_using_speedangle[plate_appearance], na.rm = TRUE),
    .groups = "drop"
  )

exposure_plot_data <- exposure_summary |>
  mutate(`xwOBA (×100)` = 100 * xwOBA) |>
  select(exposure, `K%`, `BB%`, `xwOBA (×100)`) |>
  pivot_longer(-exposure, names_to = "metric", values_to = "value") |>
  mutate(metric = factor(metric, levels = c("K%", "BB%", "xwOBA (×100)")))

exposure_plot <- ggplot(exposure_plot_data, aes(exposure, value, fill = exposure)) +
  geom_col(width = 0.62, show.legend = FALSE) +
  geom_text(
    aes(label = ifelse(metric == "xwOBA (×100)", paste0(".", sprintf("%03d", round(value * 10))), paste0(number(value, accuracy = 0.1), "%"))),
    vjust = -0.45,
    colour = navy,
    fontface = "bold",
    size = 3.5
  ) +
  facet_wrap(~metric, scales = "free_y", nrow = 1) +
  scale_fill_manual(values = c("First PA" = navy, "Second PA" = gold, "Third+ PA" = blue)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Effectiveness declines as hitters see the arsenal again",
    subtitle = "Strikeouts fall in the Second PA, while walks and expected damage rise by the Third+ PA",
    x = NULL,
    y = "Rate",
    caption = "First PA, Second PA, and Third+ PA refer to each hitter's successive plate appearances against Chandler within the same game."
  ) +
  theme_portfolio() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.spacing.x = grid::unit(1.6, "lines")
  )

ggsave(
  file.path(output_dir, "05-results-by-hitter-exposure.png"),
  exposure_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

fatigue_summary <- sequenced_pitches |>
  group_by(fatigue_bucket) |>
  summarise(
    `Four-seam velocity` = mean(release_speed[pitch_type == "FF"], na.rm = TRUE),
    `Four-seam IVB` = 12 * mean(pfx_z[pitch_type == "FF"], na.rm = TRUE),
    `Arm angle` = mean(arm_angle, na.rm = TRUE),
    .groups = "drop"
  ) |>
  pivot_longer(-fatigue_bucket, names_to = "metric", values_to = "value") |>
  mutate(
    metric = factor(metric, levels = c("Four-seam velocity", "Four-seam IVB", "Arm angle")),
    fatigue_bucket = factor(fatigue_bucket, levels = c("1–25", "26–50", "51–75", "76+"))
  )

fatigue_plot <- ggplot(fatigue_summary, aes(fatigue_bucket, value, group = metric, shape = fatigue_bucket)) +
  geom_line(colour = blue, linewidth = 1.1) +
  geom_point(fill = blue, colour = "white", size = 4, stroke = 0.8) +
  geom_text(
    aes(label = number(value, accuracy = 0.1)),
    vjust = -0.75,
    colour = navy,
    fontface = "bold",
    size = 3.4
  ) +
  facet_wrap(~metric, scales = "free_y", nrow = 1) +
  scale_shape_manual(values = c("1–25" = 21, "26–50" = 24, "51–75" = 22, "76+" = 23), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0.16, 0.22))) +
  labs(
    title = "The raw four-seam traits remain stable deep into starts",
    subtitle = "Velocity and induced vertical break hold through 76+ pitches, while arm angle continues its gradual seasonal pattern",
    x = "Pitch count within game",
    y = NULL,
    caption = "Velocity is measured in mph; IVB in inches; arm angle in degrees. Stable stuff shifts attention toward exposure, location, and sequencing."
  ) +
  theme_portfolio() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.spacing.x = grid::unit(1.6, "lines")
  )

ggsave(
  file.path(output_dir, "06-stuff-by-pitch-count.png"),
  fatigue_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

sequence_summary <- sequenced_pitches |>
  filter(
    !is.na(previous_pitch), previous_pitch != "",
    !is.na(pitch_type), pitch_type != ""
  ) |>
  group_by(previous_pitch, pitch_type) |>
  summarise(
    pitches = n(),
    swings = sum(swing),
    whiffs = sum(whiff),
    whiff_rate = 100 * whiffs / swings,
    chase_rate = 100 * mean(swing[!is.na(in_zone) & !in_zone]),
    pa = sum(plate_appearance),
    strikeouts = sum(events %in% c("strikeout", "strikeout_double_play"), na.rm = TRUE),
    xwoba = mean(estimated_woba_using_speedangle[plate_appearance], na.rm = TRUE),
    .groups = "drop"
  ) |>
  filter(pitches >= 35, !is.na(xwoba)) |>
  mutate(
    pair = paste0(previous_pitch, " → ", pitch_type),
    highlight = pair %in% c("FF → SL", "SL → FF", "CH → CH", "FF → CH")
  )

sequence_plot <- ggplot(sequence_summary, aes(xwoba, whiff_rate)) +
  geom_hline(yintercept = mean(sequence_summary$whiff_rate), colour = "#D8E0E6", linetype = "dashed") +
  geom_vline(xintercept = mean(sequence_summary$xwoba), colour = "#D8E0E6", linetype = "dashed") +
  geom_point(aes(size = pitches, colour = highlight, shape = pitch_type), stroke = 0.9, alpha = 0.92) +
  geom_text_repel(
    aes(label = pair),
    size = 3.2,
    colour = navy,
    box.padding = 0.5,
    point.padding = 0.35,
    min.segment.length = 0,
    seed = 29
  ) +
  scale_colour_manual(values = c(`TRUE` = gold, `FALSE` = blue), guide = "none") +
  scale_shape_manual(values = pitch_shapes, name = "Second pitch") +
  scale_size_continuous(range = c(4, 12), breaks = c(50, 100, 200, 500)) +
  scale_x_continuous(labels = function(x) sub("^0", "", sprintf("%.3f", x))) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title = "Fastball → slider pairs misses with lower expected damage",
    subtitle = "The reverse sequence produces less swing-and-miss and more expected damage in a similarly sized sample",
    x = "xwOBA on the second pitch",
    y = "Whiff% on the second pitch",
    size = "Pitches",
    caption = "Only pitch pairs used at least 35 times are shown. Sequence results describe the second pitch in each pair."
  ) +
  theme_portfolio()

ggsave(
  file.path(output_dir, "07-sequence-effectiveness.png"),
  sequence_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

two_strike_summary <- pitches |>
  filter(strikes == 2, pitch_type %in% c("FF", "SL", "CH", "CU", "SI", "ST")) |>
  group_by(pitch_type, pitch_name) |>
  summarise(
    pitches = n(),
    whiff_rate = 100 * sum(whiff) / sum(swing),
    chase_rate = 100 * mean(swing[!is.na(in_zone) & !in_zone]),
    xwoba = mean(estimated_woba_using_speedangle[plate_appearance], na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    label = recode(
      pitch_type,
      FF = "Four-seam", SL = "Slider", CH = "Changeup",
      CU = "Curveball", SI = "Sinker", ST = "Sweeper"
    )
  )

two_strike_plot <- ggplot(two_strike_summary, aes(xwoba, whiff_rate)) +
  geom_point(aes(size = pitches, fill = pitch_type, colour = pitch_type, shape = pitch_type), stroke = 0.9, alpha = 0.95) +
  geom_text_repel(
    aes(label = label),
    size = 3.3,
    colour = navy,
    box.padding = 0.5,
    point.padding = 0.4,
    min.segment.length = 0,
    seed = 44
  ) +
  scale_fill_manual(values = c(FF = navy, SL = blue, CH = gold, CU = "#7A5195", SI = slate, ST = red), guide = "none") +
  scale_colour_manual(values = c(FF = navy, SL = blue, CH = gold, CU = "#7A5195", SI = slate, ST = red), guide = "none") +
  scale_shape_manual(values = pitch_shapes, guide = "none") +
  scale_size_continuous(range = c(4, 13), breaks = c(40, 100, 200, 400)) +
  scale_x_continuous(labels = function(x) sub("^0", "", sprintf("%.3f", x))) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title = "The two-strike plan has several usable weapons but no dominant finisher",
    subtitle = "Four-seam and changeup suppress expected results; sweeper whiffs are promising but come from a small sample",
    x = "Two-strike xwOBA",
    y = "Two-strike Whiff%",
    size = "Pitches",
    caption = "Point size represents two-strike usage. Lower xwOBA and higher Whiff% are better."
  ) +
  theme_portfolio()

ggsave(
  file.path(output_dir, "08-two-strike-pitch-options.png"),
  two_strike_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

slider_location <- pitches |>
  filter(
    pitch_type == "SL",
    phase %in% c("High slot", "Low slot"),
    between(plate_x, -2, 2),
    between(plate_z, 0.5, 4.5)
  ) |>
  mutate(
    x_bin = floor((plate_x + 2) / 0.25) * 0.25 - 1.875,
    z_bin = floor((plate_z - 0.5) / 0.25) * 0.25 + 0.625
  ) |>
  count(phase, x_bin, z_bin, name = "pitches") |>
  group_by(phase) |>
  mutate(density = pitches / sum(pitches)) |>
  ungroup()

home_plate <- data.frame(
  x = c(-0.85, 0.85, 0.85, 0, -0.85),
  y = c(0.38, 0.38, 0.20, 0.05, 0.20)
)

slider_location_plot <- ggplot(slider_location, aes(x_bin, z_bin, fill = density)) +
  geom_tile(width = 0.25, height = 0.25) +
  annotate("rect", xmin = -0.83, xmax = 0.83, ymin = 1.5, ymax = 3.5, fill = NA, colour = navy, linewidth = 0.9) +
  geom_polygon(data = home_plate, aes(x, y), inherit.aes = FALSE, fill = "#E7EBEF", colour = slate, linewidth = 0.55) +
  facet_wrap(~phase, nrow = 1) +
  scale_fill_gradient2(
    low = "#557DB8",
    mid = "#F7F7F7",
    high = "#D94B4B",
    midpoint = 0.012,
    labels = label_percent(accuracy = 0.1)
  ) +
  coord_fixed(xlim = c(-2, 2), ylim = c(0, 4.5), clip = "off") +
  labs(
    title = "The low-slot slider moved into the strike zone",
    subtitle = "A harder, more vertical slider produced more strikes but fewer misses",
    x = "Horizontal location (catcher's view)",
    y = "Vertical location (feet)",
    fill = "Pitch share",
    caption = "Red indicates the most-used locations and blue the least-used locations within each phase. The strike zone uses a fixed visual reference."
  ) +
  theme_portfolio() +
  theme(panel.grid = element_blank())

ggsave(
  file.path(output_dir, "09-slider-location-by-arm-slot.png"),
  slider_location_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)

handedness_summary <- pitches |>
  filter(pitch_type %in% c("FF", "SL", "CH", "CU", "SI", "ST")) |>
  group_by(stand, pitch_type) |>
  summarise(
    pitches = n(),
    whiff_rate = 100 * sum(whiff) / sum(swing),
    pa = sum(plate_appearance),
    xwoba = mean(estimated_woba_using_speedangle[plate_appearance], na.rm = TRUE),
    .groups = "drop"
  ) |>
  group_by(stand) |>
  mutate(usage = 100 * pitches / sum(pitches)) |>
  ungroup() |>
  filter(pa >= 10) |>
  mutate(
    batter_side = recode(stand, L = "vs LHB", R = "vs RHB"),
    label = recode(
      pitch_type,
      FF = "Four-seam", SL = "Slider", CH = "Changeup",
      CU = "Curveball", SI = "Sinker", ST = "Sweeper"
    )
  )

handedness_plot <- ggplot(handedness_summary, aes(xwoba, whiff_rate)) +
  geom_point(aes(size = usage, fill = pitch_type, colour = pitch_type, shape = pitch_type), stroke = 0.9, alpha = 0.95) +
  geom_text_repel(
    aes(label = label),
    size = 3.1,
    colour = navy,
    box.padding = 0.45,
    point.padding = 0.35,
    min.segment.length = 0,
    seed = 52
  ) +
  facet_wrap(~batter_side, nrow = 1) +
  scale_fill_manual(values = c(FF = navy, SL = blue, CH = gold, CU = "#7A5195", SI = slate, ST = red), guide = "none") +
  scale_colour_manual(values = c(FF = navy, SL = blue, CH = gold, CU = "#7A5195", SI = slate, ST = red), guide = "none") +
  scale_shape_manual(values = pitch_shapes, guide = "none") +
  scale_size_continuous(range = c(4, 13), breaks = c(5, 10, 20, 40), labels = function(x) paste0(x, "%")) +
  scale_x_continuous(labels = function(x) sub("^0", "", sprintf("%.3f", x))) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title = "The current pitch mix leaves platoon-specific opportunities",
    subtitle = "Changeup and sweeper show upside against right-handed hitters; four-seam and sinker results are weaker against left-handed hitters",
    x = "xwOBA",
    y = "Whiff%",
    size = "Usage",
    caption = "Pitch families with at least 10 completed plate appearances against the batter side are shown. Point size represents usage."
  ) +
  theme_portfolio()

ggsave(
  file.path(output_dir, "10-pitch-plan-by-batter-side.png"),
  handedness_plot,
  width = 10,
  height = 5.7,
  dpi = 180,
  bg = "white"
)
