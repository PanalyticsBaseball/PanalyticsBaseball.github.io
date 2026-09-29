# Panalytics Baseball

Panalytics Baseball is a portfolio of reproducible baseball research workflows designed to turn public data into clear player-development and roster decisions.

**Live portfolio:** [panalyticsbaseball.github.io](https://panalyticsbaseball.github.io)

## Featured workflows

- **Bubba Chandler:** pitching mechanics, arm-slot phases, breaking-ball movement, and sequencing. See the [report](https://panalyticsbaseball.github.io/player-analysis/bubba-chandler/) and [R script](scripts/bubba-chandler-arm-slot.R).
- **Miguel Vargas:** year-over-year process indicators including xwOBA, BB%, Whiff%, Barrel%, and hard-hit rate. See the [report](https://panalyticsbaseball.github.io/player-analysis/miguel-vargas/) and [R script](scripts/miguel-vargas-development.R).
- **Willson Contreras:** Statcast data cleaning, terminal plate-appearance logic, valid strike-zone samples, xwOBA, and SLG by location. See the [report](https://panalyticsbaseball.github.io/player-analysis/willson-contreras/) and [R script](scripts/willson-contreras-zone-cleaning.R).
- **Marlins Decision Lab:** a Shiny app with reactive filters, team-relative percentiles, player comparisons, sortable roster tables, Plotly tooltips, and downloadable profiles. See the [app source](shiny/marlins-decision-lab/app.R) and [data-preparation script](shiny/marlins-decision-lab/prepare-data.R).

## Skills demonstrated

1. Research design with explicit samples and denominators.
2. Player-development analysis and sustainability questions.
3. Data cleaning and decision-focused visualization.
4. Interactive Shiny product development.

## Repository structure

```text
_pages/r-code.md                         Portfolio page for the R workflows
_players/                                 Player reports
scripts/                                  Reproducible player-analysis scripts
shiny/marlins-decision-lab/              Shiny app and cleaned data
assets/img/r-code/                        Result graphics and downloadable summaries
test/                                     Style, visual, and interaction checks
```

## Reproducing the work

Run the player workflows from the repository root with R and the input CSV paths supplied by the analysis. For example:

```bash
Rscript scripts/miguel-vargas-development.R \
  /path/to/miguel_vargas_pitch_by_pitch_2025.csv \
  /path/to/miguel_vargas_pitch_by_pitch_2026.csv \
  assets/img/r-code/miguel-vargas
```

Prepare the Marlins tables with:

```bash
Rscript shiny/marlins-decision-lab/prepare-data.R \
  "/path/to/Standar Batting Marlins.csv" \
  "/path/to/Standard Pitching Marlins.csv" \
  "/path/to/Value Pitching Marlins.csv" \
  shiny/marlins-decision-lab/data
```

Run the Shiny application locally:

```r
shiny::runApp("shiny/marlins-decision-lab")
```

## Definitions and data standards

- Whiff% is misses divided by swings.
- Chase% is swings at pitches outside the strike zone.
- xwOBA uses expected contact values when available and recorded non-contact outcomes as a fallback.
- Zone maps use the Statcast 1–9 convention and are shown from the catcher's view unless noted otherwise.
- Small samples are labeled rather than treated as stable estimates.
- Reports distinguish descriptive relationships from causal conclusions.

## Data sources

The work uses public Baseball Savant Statcast exports and Baseball-Reference team tables. Each report states its coverage window and sample definition. Generated summaries are tied to the dated snapshot used for each analysis and should be refreshed before current-season decisions.

## Site foundation

The portfolio is built with Jekyll and the al-folio starter, hosted on GitHub Pages, with custom CSS for baseball reports and R/Plotly/Shiny for analysis and interactive tools. The original site documentation remains available under [`docs/`](docs/).
