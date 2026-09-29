library(dplyr)
library(janitor)
library(readr)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)

batting_file <- if (length(args) >= 1) {
  args[[1]]
} else {
  "/Users/ambar/Downloads/Standar Batting Marlins.csv"
}
pitching_file <- if (length(args) >= 2) {
  args[[2]]
} else {
  "/Users/ambar/Downloads/Standard Pitching Marlins.csv"
}
value_pitching_file <- if (length(args) >= 3) {
  args[[3]]
} else {
  "/Users/ambar/Downloads/Value Pitching Marlins.csv"
}
output_dir <- if (length(args) >= 4) args[[4]] else "data"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

decode_rtf_text <- function(x) {
  replacements <- c(
    "\\\\'e1" = "á", "\\\\'e9" = "é", "\\\\'ed" = "í",
    "\\\\'f3" = "ó", "\\\\'fa" = "ú", "\\\\'f1" = "ñ"
  )

  for (pattern in names(replacements)) {
    x <- str_replace_all(x, regex(pattern, ignore_case = TRUE), replacements[[pattern]])
  }

  x
}

read_embedded_csv <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  header_index <- which(str_detect(lines, "^Rk,Player,"))[1]

  if (is.na(header_index)) {
    stop("No embedded Baseball-Reference CSV header was found in: ", path)
  }

  data_lines <- lines[header_index:length(lines)]
  end_index <- which(str_detect(data_lines, "^Provided by "))[1]

  if (!is.na(end_index)) {
    data_lines <- data_lines[seq_len(end_index - 1)]
  }

  data_lines <- data_lines |>
    str_remove("\\\\$") |>
    decode_rtf_text()
  data_lines <- data_lines[str_detect(data_lines, ",")]

  read_csv(
    I(paste(data_lines, collapse = "\n")),
    show_col_types = FALSE,
    na = c("", "NA")
  ) |>
    clean_names()
}

clean_player_name <- function(player) {
  player |>
    str_remove("\\s*\\([^)]*\\)\\s*$") |>
    str_remove("[\\*#]$") |>
    str_squish()
}

batting <- read_embedded_csv(batting_file) |>
  filter(player != "Team Totals", player_additional != "-9999") |>
  mutate(
    player = clean_player_name(player),
    player_type = "Hitter",
    across(c(age, war, g, pa, ab, hr, bb, so, ba, obp, slg, ops, ops_2), as.numeric)
  ) |>
  rename(pos = pos_4, ops_plus = ops_2)

pitching_standard <- read_embedded_csv(pitching_file) |>
  filter(player != "Team Totals", player_additional != "-9999") |>
  mutate(
    player = clean_player_name(player),
    player_type = "Pitcher",
    across(c(age, war, g, gs, ip, era, whip, fip, era_2, so, bb, so9, bb9), as.numeric)
  ) |>
  rename(era_plus = era_2)

pitching_value <- read_embedded_csv(value_pitching_file) |>
  filter(player != "Team Totals", player_additional != "-9999") |>
  mutate(
    player = clean_player_name(player),
    across(c(raa, waa, war, rar, ra9, ra9opp, ra9avg), as.numeric)
  ) |>
  select(player_additional, raa, waa, value_war = war, rar, ra9, ra9opp, ra9avg)

pitching <- pitching_standard |>
  left_join(pitching_value, by = "player_additional")

write_csv(batting, file.path(output_dir, "marlins-batting-clean.csv"), na = "")
write_csv(pitching, file.path(output_dir, "marlins-pitching-clean.csv"), na = "")

audit <- tibble(
  dataset = c("Batting", "Pitching", "Pitching value"),
  source_rows = c(
    nrow(read_embedded_csv(batting_file)),
    nrow(read_embedded_csv(pitching_file)),
    nrow(read_embedded_csv(value_pitching_file))
  ),
  player_rows = c(nrow(batting), nrow(pitching_standard), nrow(pitching_value)),
  duplicate_player_ids = c(
    sum(duplicated(batting$player_additional)),
    sum(duplicated(pitching_standard$player_additional)),
    sum(duplicated(pitching_value$player_additional))
  )
)

write_csv(audit, file.path(output_dir, "data-audit.csv"))
