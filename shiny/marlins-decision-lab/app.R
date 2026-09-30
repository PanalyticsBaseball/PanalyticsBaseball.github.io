library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
library(scales)

batting <- read.csv("data/marlins-batting-clean.csv", check.names = FALSE)
pitching <- read.csv("data/marlins-pitching-clean.csv", check.names = FALSE)

navy <- "#17324D"
blue <- "#3F7CAC"
red <- "#D97368"
gold <- "#E7B34A"

percentile_rank_safe <- function(x, better = "high") {
  ranked_value <- if (better == "low") -x else x
  dplyr::percent_rank(ranked_value)
}

hitter_pool <- batting |>
  filter(pa > 0) |>
  mutate(
    `OPS+ percentile` = percentile_rank_safe(ops_plus),
    `OBP percentile` = percentile_rank_safe(obp),
    `SLG percentile` = percentile_rank_safe(slg),
    `BB% percentile` = percentile_rank_safe(bb / pa),
    `K% percentile` = percentile_rank_safe(so / pa, "low")
  )

pitcher_pool <- pitching |>
  filter(ip > 0) |>
  mutate(
    `ERA+ percentile` = percentile_rank_safe(era_plus),
    `FIP percentile` = percentile_rank_safe(fip, "low"),
    `WHIP percentile` = percentile_rank_safe(whip, "low"),
    `K/9 percentile` = percentile_rank_safe(so9),
    `BB/9 percentile` = percentile_rank_safe(bb9, "low")
  )

ui <- page_navbar(
  title = "Marlins Decision Lab",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = navy,
    secondary = blue,
    base_font = font_google("Inter")
  ),
  header = tags$div(
    class = "container-fluid py-2 text-secondary",
    "Interactive roster analysis · Data through August 10, 2026"
  ),
  nav_panel(
    "Player profile",
    layout_sidebar(
      sidebar = sidebar(
        radioButtons(
          "player_type", "Player group",
          choices = c("Hitters", "Pitchers"), inline = TRUE
        ),
        uiOutput("player_selector"),
        sliderInput("minimum_sample", "Minimum PA or IP", 0, 150, 25, step = 5),
        checkboxInput("show_values", "Show percentile labels", TRUE),
        downloadButton("download_profile", "Download selected profile")
      ),
      layout_columns(
        col_widths = c(6, 6),
        value_box(
          title = textOutput("headline_label"),
          value = textOutput("headline_value"),
          theme = "primary"
        ),
        value_box(
          title = "Role and sample",
          value = textOutput("sample_value"),
          theme = "secondary"
        )
      ),
      card(
        full_screen = TRUE,
        height = "500px",
        card_header("Team-relative skill profile"),
        plotlyOutput("percentile_profile", height = "440px")
      ),
      card(
        full_screen = TRUE,
        card_header("Selected-player metrics"),
        DTOutput("player_table")
      )
    )
  ),
  nav_panel(
    "Compare players",
    layout_sidebar(
      sidebar = sidebar(
        radioButtons(
          "compare_type", "Player group",
          choices = c("Hitters", "Pitchers"), inline = TRUE
        ),
        uiOutput("comparison_selector"),
        helpText("Select two to four players from the same role group.")
      ),
      card(
        full_screen = TRUE,
        card_header("Comparable percentile profiles"),
        plotlyOutput("comparison_plot", height = "520px")
      )
    )
  ),
  nav_panel(
    "Roster board",
    card(
      card_header("Sortable team leaderboard"),
      radioButtons(
        "board_type", "Player group",
        choices = c("Hitters", "Pitchers"), inline = TRUE
      ),
      DTOutput("roster_board")
    )
  ),
  footer = tags$div(
    class = "container-fluid py-3 text-secondary small",
    "Source: Baseball-Reference team tables. Team-relative percentiles describe this roster snapshot, not MLB-wide percentiles."
  )
)

server <- function(input, output, session) {
  active_pool <- reactive({
    if (input$player_type == "Hitters") {
      hitter_pool |> filter(pa >= input$minimum_sample)
    } else {
      pitcher_pool |> filter(ip >= input$minimum_sample)
    }
  })

  output$player_selector <- renderUI({
    pool <- active_pool() |> arrange(desc(war))
    selectInput(
      "selected_player", "Player",
      choices = pool$player,
      selected = first(pool$player)
    )
  })

  selected_player <- reactive({
    req(input$selected_player)
    active_pool() |> filter(player == input$selected_player)
  })

  profile_data <- reactive({
    player <- selected_player()

    metrics <- if (input$player_type == "Hitters") {
      player |>
        select(
          `OPS+` = `OPS+ percentile`, `On-base` = `OBP percentile`,
          `Slugging` = `SLG percentile`, `Walk rate` = `BB% percentile`,
          `Contact` = `K% percentile`
        )
    } else {
      player |>
        select(
          `ERA+` = `ERA+ percentile`, `FIP` = `FIP percentile`,
          `WHIP` = `WHIP percentile`, `Strikeout rate` = `K/9 percentile`,
          `Walk prevention` = `BB/9 percentile`
        )
    }

    metrics |>
      pivot_longer(everything(), names_to = "metric", values_to = "percentile")
  })

  output$headline_label <- renderText({
    if (input$player_type == "Hitters") "OPS+" else "ERA+"
  })

  output$headline_value <- renderText({
    player <- selected_player()
    if (input$player_type == "Hitters") player$ops_plus else player$era_plus
  })

  output$sample_value <- renderText({
    player <- selected_player()
    if (input$player_type == "Hitters") {
      paste0(player$pos, " · ", player$pa, " PA")
    } else {
      paste0(ifelse(is.na(player$pos), "Pitcher", player$pos), " · ", player$ip, " IP")
    }
  })

  output$percentile_profile <- renderPlotly({
    plot_data <- profile_data()

    chart <- ggplot(
      plot_data,
      aes(
        x = percentile,
        y = reorder(metric, percentile),
        fill = percentile,
        text = paste0(metric, ": ", percent(percentile, accuracy = 1))
      )
    ) +
      geom_col(width = 0.62) +
      geom_vline(xintercept = 0.5, colour = "white", linewidth = 0.8) +
      geom_text(
        aes(label = if (input$show_values) percent(percentile, accuracy = 1) else ""),
        hjust = -0.15,
        colour = navy,
        fontface = "bold"
      ) +
      scale_fill_gradient2(low = blue, mid = "#F4F1EC", high = red, midpoint = 0.5) +
      scale_x_continuous(labels = percent, limits = c(0, 1.08)) +
      labs(x = "Team percentile", y = NULL) +
      theme_minimal(base_family = "Arial", base_size = 12) +
      theme(legend.position = "none", panel.grid.major.y = element_blank())

    ggplotly(chart, tooltip = "text") |> config(displayModeBar = FALSE)
  })

  output$player_table <- renderDT({
    player <- selected_player()

    display <- if (input$player_type == "Hitters") {
      player |> select(Player = player, Age = age, Pos = pos, PA = pa, WAR = war, BA = ba, OBP = obp, SLG = slg, OPS = ops, `OPS+` = ops_plus)
    } else {
      player |> select(Player = player, Age = age, Pos = pos, IP = ip, WAR = war, ERA = era, FIP = fip, WHIP = whip, `ERA+` = era_plus, `K/9` = so9, `BB/9` = bb9)
    }

    datatable(display, rownames = FALSE, options = list(dom = "t", scrollX = TRUE))
  })

  output$comparison_selector <- renderUI({
    pool <- if (input$compare_type == "Hitters") hitter_pool else pitcher_pool
    default_players <- head(pool |> arrange(desc(war)) |> pull(player), 3)
    selectizeInput(
      "comparison_players", "Players",
      choices = pool$player,
      selected = default_players,
      multiple = TRUE,
      options = list(maxItems = 4)
    )
  })

  output$comparison_plot <- renderPlotly({
    req(length(input$comparison_players) >= 2)
    pool <- if (input$compare_type == "Hitters") hitter_pool else pitcher_pool

    comparison <- pool |>
      filter(player %in% input$comparison_players)

    metric_data <- if (input$compare_type == "Hitters") {
      comparison |>
        select(player, `OPS+` = `OPS+ percentile`, `On-base` = `OBP percentile`, `Slugging` = `SLG percentile`, `Walk rate` = `BB% percentile`, Contact = `K% percentile`)
    } else {
      comparison |>
        select(player, `ERA+` = `ERA+ percentile`, FIP = `FIP percentile`, WHIP = `WHIP percentile`, `Strikeout rate` = `K/9 percentile`, `Walk prevention` = `BB/9 percentile`)
    }

    plot_data <- metric_data |>
      pivot_longer(-player, names_to = "metric", values_to = "percentile")

    chart <- ggplot(
      plot_data,
      aes(metric, percentile, colour = player, group = player, text = paste0(player, "<br>", metric, ": ", percent(percentile, accuracy = 1)))
    ) +
      geom_line(linewidth = 0.9) +
      geom_point(size = 3) +
      scale_y_continuous(labels = percent, limits = c(0, 1)) +
      scale_colour_manual(values = c(navy, red, blue, gold)) +
      labs(x = NULL, y = "Team percentile", colour = NULL) +
      theme_minimal(base_family = "Arial", base_size = 12) +
      theme(panel.grid.minor = element_blank(), legend.position = "bottom")

    ggplotly(chart, tooltip = "text") |> config(displayModeBar = FALSE)
  })

  output$roster_board <- renderDT({
    board <- if (input$board_type == "Hitters") {
      hitter_pool |>
        arrange(desc(war)) |>
        select(Player = player, Age = age, Pos = pos, PA = pa, WAR = war, OPS = ops, `OPS+` = ops_plus, HR = hr)
    } else {
      pitcher_pool |>
        arrange(desc(war)) |>
        select(Player = player, Age = age, Pos = pos, IP = ip, WAR = war, ERA = era, FIP = fip, WHIP = whip, `ERA+` = era_plus)
    }

    datatable(
      board,
      rownames = FALSE,
      filter = "top",
      options = list(pageLength = 12, scrollX = TRUE)
    )
  })

  output$download_profile <- downloadHandler(
    filename = function() paste0(gsub(" ", "-", tolower(input$selected_player)), "-profile.csv"),
    content = function(file) write.csv(selected_player(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
