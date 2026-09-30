import { chromium } from "@playwright/test";

const browser = await chromium.launch({
  executablePath: "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
  headless: true,
});

const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
await page.goto("http://127.0.0.1:7391", { waitUntil: "networkidle" });
await page.screenshot({
  path: "assets/img/r-code/marlins-shiny/01-dashboard-preview.png",
  fullPage: true,
});

await browser.close();
