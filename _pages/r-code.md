---
layout: page
title: R Code
permalink: /r-code/
description: R & Baseball Analytics workflows explained for both technical and non-technical baseball audiences.
nav: true
nav_order: 5
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<h2 class="pb-section-heading">R &amp; Baseball Analytics</h2>

<p class="pb-lead">A practical view of how Gabriel uses R to prepare baseball data, build clear visuals, compare players, test questions, and create interactive tools.</p>

<p class="pb-placeholder"><strong>Code status:</strong> The short snippets below are clearly labeled starter placeholders. Replace them with concise excerpts from Gabriel's verified repositories and connect each section to its full GitHub source.</p>

<section class="pb-code-section" aria-labelledby="data-cleaning">
  <h3 id="data-cleaning">Data Cleaning</h3>
  <p>Transforms raw files into consistent, analysis-ready tables while preserving the fields needed to answer a baseball question.</p>

```r
# PLACEHOLDER — replace with a verified project excerpt
clean_data <- raw_data |>
  janitor::clean_names() |>
  dplyr::filter(!is.na(player_id))
```

<span class="pb-button pb-button-disabled" aria-disabled="true">View Full Code on GitHub · [ADD URL]</span>

</section>

<section class="pb-code-section" aria-labelledby="data-visualization">
  <h3 id="data-visualization">Data Visualization</h3>
  <p>Turns metrics into readable graphics that help coaches, analysts, and recruiters identify patterns quickly.</p>

```r
# PLACEHOLDER — replace variables and styling with final work
ggplot(player_data, aes(x = metric_x, y = metric_y)) +
  geom_point() +
  theme_minimal()
```

<div class="pb-scouting-block">[ADD OPTIONAL VISUALIZATION OR CHART PREVIEW]</div>
<span class="pb-button pb-button-disabled" aria-disabled="true">View Full Code on GitHub · [ADD URL]</span>
</section>

<section class="pb-code-section" aria-labelledby="player-comparisons">
  <h3 id="player-comparisons">Player Comparisons</h3>
  <p>Creates fair, transparent comparisons by selecting relevant samples, roles, and contextual variables.</p>

```r
# PLACEHOLDER — define the comparison group and verified metrics
comparison <- player_data |>
  dplyr::group_by(player_name) |>
  dplyr::summarise(across(selected_metrics, mean, na.rm = TRUE))
```

<span class="pb-button pb-button-disabled" aria-disabled="true">View Full Code on GitHub · [ADD URL]</span>

</section>

<section class="pb-code-section" aria-labelledby="statistical-analysis">
  <h3 id="statistical-analysis">Statistical Analysis</h3>
  <p>Uses appropriately scoped models to explore relationships, quantify uncertainty, and support—not replace—baseball judgment.</p>

```r
# PLACEHOLDER — document the sample, assumptions, and outcome
model <- lm(outcome_metric ~ input_metric + context_variable,
            data = analysis_data)
```

<span class="pb-button pb-button-disabled" aria-disabled="true">View Full Code on GitHub · [ADD URL]</span>

</section>

<section class="pb-code-section" aria-labelledby="shiny-development">
  <h3 id="shiny-development">Shiny Development</h3>
  <p>Packages analysis into interactive interfaces so users can filter players, explore visuals, and answer follow-up questions.</p>

```r
# PLACEHOLDER — replace with a concise, verified module
output$player_plot <- renderPlot({
  build_player_plot(filtered_data())
})
```

<div class="pb-scouting-block">[ADD OPTIONAL SHINY SCREENSHOT OR FEATURE PREVIEW]</div>
<span class="pb-button pb-button-disabled" aria-disabled="true">View Full Code on GitHub · [ADD URL]</span>
</section>
