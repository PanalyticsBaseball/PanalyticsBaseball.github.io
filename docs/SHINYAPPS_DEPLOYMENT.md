# Deploying Marlins Decision Lab to shinyapps.io

This guide publishes the Shiny application in `shiny/marlins-decision-lab/` as a hosted app on [shinyapps.io](https://www.shinyapps.io/).

## Before deploying

The app directory must contain all files it reads at runtime:

```text
shiny/marlins-decision-lab/
├── app.R
└── data/
    ├── data-audit.csv
    ├── marlins-batting-clean.csv
    └── marlins-pitching-clean.csv
```

The app uses relative paths such as `data/marlins-batting-clean.csv`. Deploy the app directory itself, not the repository root and not the `data/` directory alone.

The included Marlins data is a dated snapshot. Refresh the source tables and rerun `prepare-data.R` before using the app for current baseball decisions.

## 1. Create a shinyapps.io account

1. Open [shinyapps.io](https://www.shinyapps.io/) and create or sign in to an account.
2. Open the account menu and choose **Tokens**.
3. Choose **Show** beside the account token.
4. Keep the token and secret private. Do not commit them to GitHub or paste them into `app.R`.

## 2. Install the deployment package

Run this once in R or RStudio:

```r
install.packages("rsconnect")
```

The application uses `shiny`, `bslib`, `dplyr`, `tidyr`, `ggplot2`, `plotly`, `DT`, and `scales`.

```r
install.packages(c(
  "shiny", "bslib", "dplyr", "tidyr", "ggplot2",
  "plotly", "DT", "scales"
))
```

## 3. Authorize the account

Run the `setAccountInfo()` command supplied by shinyapps.io, replacing the placeholders with the values from the Tokens page:

```r
rsconnect::setAccountInfo(
  name = "YOUR_ACCOUNT_NAME",
  token = "YOUR_TOKEN",
  secret = "YOUR_SECRET"
)
```

This stores deployment credentials in the local R user configuration. It does not change the repository.

## 4. Test the app locally

From the repository root:

```r
shiny::runApp("shiny/marlins-decision-lab")
```

Check that the initial profile loads, switching between hitters and pitchers updates the chart and table, the minimum PA/IP filter changes the eligible players, the comparison tab renders with two or more players, the roster board sorts, and the download button returns a CSV. Stop the local app with `Esc` before deploying.

## 5. Deploy the app

From R or RStudio, run:

```r
rsconnect::deployApp(
  appDir = "shiny/marlins-decision-lab",
  appName = "marlins-decision-lab"
)
```

The first deployment may ask you to select the shinyapps.io account. After the upload finishes, `rsconnect` prints the application URL. If the application already exists, use the same command to publish an update rather than creating a second app.

## 6. Verify the hosted version

Open the URL in a private browser window and verify the profile, filters, comparison chart, roster table, sorting, and CSV download. If a control works locally but not online, open the application logs in shinyapps.io under **Logs**. Missing files and unavailable R packages are the most common causes.

## Common errors

### `cannot open file 'data/...'`

Deploy from `shiny/marlins-decision-lab` and confirm the three CSV files exist under its `data/` directory. Do not use an absolute personal path such as `/Users/ambar/Downloads/...`.

### Package not available

Install the missing package locally and deploy again. The deployment log identifies the package name.

### Application starts locally but fails online

Check for operating-system-specific paths, missing files, unavailable fonts, or packages that are not loaded by the app. Repository-relative paths are required.

### Application sleeps

The free shinyapps.io tier may put inactive applications to sleep. The first request after inactivity can take longer while the process starts.

## Adding the hosted URL to the portfolio

After confirming the app works online, add the URL to the Shiny case-study section of `_pages/r-code.md`:

```liquid
<a class="pb-button" href="YOUR_SHINYAPPS_URL" target="_blank" rel="noopener"> Open live Shiny app </a>
```

Keep the source-code links alongside the live app link so visitors can inspect both the product and the implementation.
