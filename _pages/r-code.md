---
layout: page
title: R Code
permalink: /r-code/
description: Reproducible R workflows connecting Baseball Savant data, visual analysis, and player-development decisions.
nav: true
nav_order: 5
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-eyebrow">Reproducible Baseball Research</p>

<h2 class="pb-section-heading">From pitch-level data to baseball decisions</h2>

<p class="pb-lead">These examples show how Gabriel uses R to structure baseball data, test player-development questions, build portfolio-ready graphics, and translate results into interactive decision tools. The featured workflows cover pitching adjustments, offensive development, data cleaning, visualization, and Shiny product development.</p>

<div class="pb-actions">
  <a class="pb-button" href="{{ '/scripts/bubba-chandler-arm-slot.R' | relative_url }}">View complete R script</a>
  <a class="pb-button pb-button-secondary" href="{{ '/player-analysis/bubba-chandler/' | relative_url }}">Read the player report</a>
  <a class="pb-button pb-button-secondary" href="{{ '/assets/img/player-analysis/bubba-chandler/phase-summary.csv' | relative_url }}">Download phase summary</a>
</div>

<section class="pb-code-section" aria-labelledby="phase-design">
  <p class="pb-eyebrow">01 · Research design</p>
  <h3 id="phase-design">Turn a mechanical change into testable periods</h3>
  <p>Instead of imposing a generic first-half and second-half split, the workflow assigns each pitch to one of four periods that follow Chandler's actual arm-slot progression.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
pitches <- read.csv(input_file) |>
  mutate(
    game_date = as.Date(game_date),
    phase = case_when(
      game_date <= as.Date("2026-06-13") ~ "High slot",
      game_date <= as.Date("2026-07-22") ~ "Transition",
      game_date <= as.Date("2026-09-13") ~ "Low slot",
      TRUE ~ "Late rebound"
    ),
    swing = description %in% swing_descriptions,
    whiff = description %in% whiff_descriptions,
    in_zone = zone >= 1 & zone <= 9
  )
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/player-analysis/bubba-chandler/01-arm-slot-timeline.png' | relative_url }}" alt="Bubba Chandler arm-slot timeline produced in R">
      <figcaption>The resulting timeline identifies the periods used throughout the study.</figcaption>
    </figure>

  </div>
</section>

<section class="pb-code-section" aria-labelledby="metric-construction">
  <p class="pb-eyebrow">02 · Metric construction</p>
  <h3 id="metric-construction">Compare command, deception, and contact quality</h3>
  <p>The summary keeps denominators explicit. Whiff% uses swings, Chase% uses pitches outside the zone, and plate-appearance outcomes are calculated separately from pitch-level behavior.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
phase_summary <- pitches |>
  group_by(phase) |>
  summarise(
    pitches = n(),
    pa = sum(plate_appearance),
    `K%` = 100 * mean(events[plate_appearance] == "strikeout"),
    `BB%` = 100 * mean(events[plate_appearance] == "walk"),
    `Zone%` = 100 * mean(in_zone, na.rm = TRUE),
    `CSW%` = 100 * mean(called_strike | whiff),
    `Whiff%` = 100 * sum(whiff) / sum(swing),
    `Chase%` = 100 * mean(swing[!in_zone]),
    xwOBA = mean(estimated_woba_using_speedangle,
                 na.rm = TRUE)
  )
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/player-analysis/bubba-chandler/02-deception-by-arm-slot.png' | relative_url }}" alt="Chase whiff swing and strikeout comparison produced in R">
      <figcaption>The lower slot improved strike efficiency but did not create more chase or swing-and-miss.</figcaption>
    </figure>

  </div>
</section>

<section class="pb-code-section" aria-labelledby="visual-encoding">
  <p class="pb-eyebrow">03 · Visual communication</p>
  <h3 id="visual-encoding">Use color, geometry, and movement together</h3>
  <p>Pitch type is encoded with geometric shape, mechanical period with color, and usage with point size. The chart remains interpretable even when color differences are difficult to distinguish.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
pitch_shapes <- c(
  FF = 21, SL = 22, CH = 24,
  CU = 23, SI = 25, ST = 8
)

ggplot(breaking_summary,
       aes(horizontal_break, vertical_break,
           colour = phase,
           shape = pitch_type,
           size = usage)) +
  geom_path(aes(group = pitch_type),
            linetype = "dashed") +
  geom_point(alpha = 0.9, stroke = 1) +
  scale_shape_manual(values = pitch_shapes) +
  coord_equal()
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/player-analysis/bubba-chandler/04-breaking-ball-shape.png' | relative_url }}" alt="Breaking-ball movement comparison with colors and geometric shapes">
      <figcaption>The movement map shows how the breaking-ball system changed with the arm slot.</figcaption>
    </figure>

  </div>
</section>

<section class="pb-code-section" aria-labelledby="sequence-analysis">
  <p class="pb-eyebrow">04 · Sequence analysis</p>
  <h3 id="sequence-analysis">Evaluate pitch order instead of pitches in isolation</h3>
  <p>Each pitch is linked to the preceding pitch within the same plate appearance. The analysis then compares frequency, Whiff%, and xwOBA for the second pitch in each pairing.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
sequenced_pitches <- pitches |>
  arrange(game_pk, at_bat_number, pitch_number) |>
  group_by(game_pk, at_bat_number) |>
  mutate(previous_pitch = lag(pitch_type)) |>
  ungroup()

sequence_summary <- sequenced_pitches |>
  filter(!is.na(previous_pitch)) |>
  group_by(previous_pitch, pitch_type) |>
  summarise(
    pitches = n(),
    whiff_rate = 100 * sum(whiff) / sum(swing),
    xwOBA = mean(estimated_woba_using_speedangle,
                 na.rm = TRUE)
  )
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/player-analysis/bubba-chandler/07-sequence-effectiveness.png' | relative_url }}" alt="Bubba Chandler pitch sequence effectiveness chart produced in R">
      <figcaption>Four-seam followed by slider was considerably stronger than the reverse sequence.</figcaption>
    </figure>

  </div>
</section>

<section class="pb-code-section" aria-labelledby="vargas-sustainability">
  <p class="pb-eyebrow">Case study 02 · Hitter development</p>
  <h3 id="vargas-sustainability">Test whether a breakout is supported by process</h3>
  <p>The Vargas workflow compares expected production, swing decisions, and contact quality across seasons. The key question is whether added damage came with a larger swing-and-miss cost.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
season_summary <- pitches |>
  group_by(season) |>
  summarise(
    PA = sum(plate_appearance),
    xwOBA = mean(expected_woba, na.rm = TRUE),
    `BB%` = 100 * mean(
      events[plate_appearance] == "walk"
    ),
    `Whiff%` = 100 * sum(whiff) / sum(swing),
    `Barrel%` = 100 * mean(
      launch_speed_angle[batted_ball] == 6
    ),
    `Hard-hit%` = 100 * mean(
      launch_speed[batted_ball] >= 95
    )
  )
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/r-code/miguel-vargas/01-sustainable-improvement.png' | relative_url }}" alt="Miguel Vargas year-over-year expected production and process metrics produced in R">
      <figcaption>Vargas increased xwOBA, Barrel%, and BB% while keeping Whiff% essentially unchanged.</figcaption>
    </figure>

  </div>

  <div class="pb-actions">
    <a class="pb-button" href="{{ '/scripts/miguel-vargas-development.R' | relative_url }}">View Miguel Vargas R script</a>
    <a class="pb-button pb-button-secondary" href="{{ '/player-analysis/miguel-vargas/' | relative_url }}">Read the Vargas report</a>
    <a class="pb-button pb-button-secondary" href="{{ '/assets/img/r-code/miguel-vargas/season-summary.csv' | relative_url }}">Download season summary</a>
  </div>
</section>

<section class="pb-code-section" aria-labelledby="contreras-zone-cleaning">
  <p class="pb-eyebrow">Case study 03 · Data cleaning + visualization</p>
  <h3 id="contreras-zone-cleaning">Build a trustworthy strike-zone sample</h3>
  <p>A Statcast download contains one row per pitch, but a hitter's outcome belongs only to the terminal pitch of a plate appearance. This workflow removes non-terminal rows, defines official at-bats, validates zones 1–9, resolves missing expected values, and audits every reduction before plotting.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
clean_pitches <- raw_pitches |>
  mutate(
    terminal_pa = !is.na(events) & events != "",
    official_ab = events %in% official_ab_events,
    valid_zone = zone %in% 1:9,
    expected_woba = coalesce(
      estimated_woba_using_speedangle,
      woba_value
    )
  )

analysis_sample <- clean_pitches |>
  filter(
    terminal_pa, official_ab, valid_zone,
    !is.na(expected_woba)
  )

zone_summary <- analysis_sample |>
  group_by(zone) |>
  summarise(
    AB = n(),
    xwOBA = mean(expected_woba),
    SLG = sum(total_bases) / AB
  )
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/r-code/willson-contreras/01-clean-zone-production.png' | relative_url }}" alt="Willson Contreras xwOBA and slugging by strike-zone location after cleaning Statcast pitch-level data">
      <figcaption>The audited sample falls from 2,072 pitch rows to 285 official at-bats with valid in-zone endpoints. The result isolates Contreras's strongest damage areas without counting every pitch as an outcome.</figcaption>
    </figure>

  </div>

  <div class="pb-actions">
    <a class="pb-button" href="{{ '/scripts/willson-contreras-zone-cleaning.R' | relative_url }}">View cleaning and visualization script</a>
    <a class="pb-button pb-button-secondary" href="{{ '/player-analysis/willson-contreras/' | relative_url }}">Read the Contreras report</a>
    <a class="pb-button pb-button-secondary" href="{{ '/assets/img/r-code/willson-contreras/data-quality-audit.csv' | relative_url }}">Download data-quality audit</a>
    <a class="pb-button pb-button-secondary" href="{{ '/assets/img/r-code/willson-contreras/zone-summary.csv' | relative_url }}">Download zone summary</a>
  </div>
</section>

<section class="pb-code-section" aria-labelledby="marlins-shiny">
  <p class="pb-eyebrow">Case study 04 · Shiny application</p>
  <h3 id="marlins-shiny">Turn a roster snapshot into an interactive decision tool</h3>
  <p>The Marlins Decision Lab converts cleaned Baseball-Reference tables into a responsive player-profile, comparison, and roster-ranking application. Reactive filters control the eligible sample, every player selection updates the metrics and Plotly graphic, and users can export the selected profile.</p>

  <div class="pb-code-result-grid">
    <div class="pb-code-panel">

{% highlight r %}
active_pool <- reactive({
  if (input$player_type == "Hitters") {
    hitter_pool |>
      filter(pa >= input$minimum_sample)
  } else {
    pitcher_pool |>
      filter(ip >= input$minimum_sample)
  }
})

selected_player <- reactive({
  req(input$selected_player)
  active_pool() |>
    filter(player == input$selected_player)
})

output$percentile_profile <- renderPlotly({
  plot_data <- profile_data()

  chart <- ggplot(
    plot_data,
    aes(percentile, reorder(metric, percentile),
        fill = percentile,
        text = paste0(metric, ": ", percent(percentile)))
  ) +
    geom_col(width = 0.62) +
    scale_fill_gradient2(
      low = blue, mid = "white", high = red,
      midpoint = 0.5
    )

  ggplotly(chart, tooltip = "text") |>
    config(displayModeBar = FALSE)
})
{% endhighlight %}

    </div>
    <figure class="pb-code-result">
      <img src="{{ '/assets/img/r-code/marlins-shiny/01-dashboard-preview.png' | relative_url }}" alt="Marlins Decision Lab Shiny dashboard with player filters, value boxes, percentile profile, and interactive table">
      <figcaption>The interface lets a user switch between hitters and pitchers, set a minimum sample, inspect a team-relative skill profile, compare players, sort the roster, and download results.</figcaption>
    </figure>

  </div>

  <div class="pb-actions">
    <a class="pb-button" href="{{ '/shiny/marlins-decision-lab/app.R' | relative_url }}">View complete Shiny app</a>
    <a class="pb-button pb-button-secondary" href="{{ '/shiny/marlins-decision-lab/prepare-data.R' | relative_url }}">View data-preparation script</a>
    <a class="pb-button pb-button-secondary" href="{{ '/shiny/marlins-decision-lab/data/data-audit.csv' | relative_url }}">Download data audit</a>
  </div>
</section>

<section class="pb-code-section" aria-labelledby="workflow-principles">
  <p class="pb-eyebrow">Workflow principles</p>
  <h3 id="workflow-principles">What the code is designed to demonstrate</h3>

  <div class="pb-grid pb-grid-two">
    <article class="pb-scouting-block">
      <h4>Reproducibility</h4>
      <p>One script reads the pitch-level CSV, defines the samples, calculates the metrics, and exports every figure used in the report.</p>
    </article>
    <article class="pb-scouting-block">
      <h4>Transparent definitions</h4>
      <p>Rates state their denominators, small samples are identified, and descriptive findings are separated from causal conclusions.</p>
    </article>
    <article class="pb-scouting-block">
      <h4>Baseball context</h4>
      <p>The workflow starts with a player-development question rather than selecting metrics without a decision in mind.</p>
    </article>
    <article class="pb-scouting-block">
      <h4>Communication</h4>
      <p>Every visualization supports a specific conclusion and uses consistent terminology, colors, and accessible geometric symbols.</p>
    </article>
  </div>
</section>

<div class="pb-scouting-block">
  <strong>Selected portfolio:</strong> These four workflows were chosen to show complementary skills without repeating the same analytical pattern: research design, player-development analysis, data cleaning and visualization, and interactive Shiny development.
</div>
