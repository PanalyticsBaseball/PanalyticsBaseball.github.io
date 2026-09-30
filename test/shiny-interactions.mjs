import { chromium } from "@playwright/test";
import fs from "node:fs/promises";

const browser = await chromium.launch({
  executablePath: "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
  headless: true,
});

const page = await browser.newPage({
  acceptDownloads: true,
  viewport: { width: 1440, height: 1000 },
});

const failures = [];
const checks = [];
const browserErrors = [];

page.on("pageerror", (error) => browserErrors.push(error.message));
page.on("console", (message) => {
  if (message.type() === "error") browserErrors.push(message.text());
});

async function check(name, action) {
  try {
    await action();
    checks.push({ name, status: "passed" });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    checks.push({ name, status: "failed", message });
    failures.push(`${name}: ${message}`);
  }
}

async function expectText(selector, expected) {
  await page.waitForFunction(
    ({ selector, expected }) => document.querySelector(selector)?.textContent?.includes(expected),
    { selector, expected },
  );
}

await page.goto("http://127.0.0.1:7391", { waitUntil: "networkidle" });

await check("Initial hitter profile loads", async () => {
  await expectText("#headline_value", "130");
  await expectText("#sample_value", "499 PA");
  await expectText("#player_table", "Otto Lopez");
  await page.waitForSelector("#percentile_profile .plotly");
});

await check("Hitter profile download works", async () => {
  const downloadPromise = page.waitForEvent("download");
  await page.locator("#download_profile").click();
  const download = await downloadPromise;
  if (download.suggestedFilename() !== "otto-lopez-profile.csv") {
    throw new Error(`Unexpected filename: ${download.suggestedFilename()}`);
  }
});

await check("Player group switches to pitchers", async () => {
  await page.locator("label").filter({ hasText: "Pitchers" }).first().click();
  await expectText("#headline_label", "ERA+");
  await expectText("#headline_value", "150");
  await expectText("#sample_value", "111 IP");
  await expectText("#player_table", "Max Meyer");
});

await check("Minimum-sample filter updates the eligible player", async () => {
  await page.evaluate(() => {
    window.Shiny.setInputValue("minimum_sample", 120, { priority: "event" });
  });
  await expectText("#player_table", "Sandy Alcantara");
  await expectText("#sample_value", "163.2 IP");
});

await check("Percentile labels can be hidden", async () => {
  await page.locator("#show_values").uncheck();
  await page.waitForTimeout(500);
  const labels = await page.locator("#percentile_profile .textpoint text").count();
  if (labels !== 0) throw new Error(`Expected no bar labels; found ${labels}`);
});

await check("Comparison tab loads hitter comparison", async () => {
  await page.getByRole("tab", { name: "Compare players" }).click();
  await page.waitForSelector("#comparison_plot .plotly");
  const legendCount = await page.locator("#comparison_plot .legendtext").count();
  if (legendCount < 2) throw new Error(`Expected at least two compared hitters; found ${legendCount}`);
});

await check("Comparison switches to pitchers", async () => {
  await page.locator("label").filter({ hasText: "Pitchers" }).first().click();
  await page.waitForFunction(() => {
    const select = document.querySelector("#comparison_players");
    return select && select.value;
  });
  await page.waitForTimeout(800);
  const legends = await page.locator("#comparison_plot .legendtext").allTextContents();
  if (!legends.includes("Max Meyer")) {
    throw new Error(`Pitcher comparison did not include Max Meyer: ${legends.join(", ")}`);
  }
});

await check("Roster board loads hitters", async () => {
  await page.getByRole("tab", { name: "Roster board" }).click();
  await page.waitForSelector("#roster_board table");
  await expectText("#roster_board", "Otto Lopez");
  await expectText("#roster_board", "OPS+");
});

await check("Roster board switches to pitchers", async () => {
  await page.locator("label").filter({ hasText: "Pitchers" }).first().click();
  await expectText("#roster_board", "Max Meyer");
  await expectText("#roster_board", "ERA+");
});

await check("Roster table sorting responds", async () => {
  const warHeader = page.locator("#roster_board th").filter({ hasText: "WAR" }).first();
  await warHeader.click();
  await page.waitForTimeout(300);
  const firstPlayer = await page.locator("#roster_board tbody tr").first().locator("td").first().textContent();
  if (!firstPlayer?.trim()) throw new Error("No first player after sorting");
});

await page.screenshot({
  path: "assets/img/r-code/marlins-shiny/02-roster-interaction-test.png",
  fullPage: true,
});

await fs.writeFile(
  "assets/img/r-code/marlins-shiny/interaction-test-report.json",
  JSON.stringify({ checks, browserErrors }, null, 2),
);

await browser.close();

if (browserErrors.length > 0) {
  failures.push(`Browser console errors: ${browserErrors.join(" | ")}`);
}

if (failures.length > 0) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log(`${checks.length} interaction checks passed.`);
