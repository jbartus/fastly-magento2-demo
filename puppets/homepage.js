const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({headless: "new"});
  const page = await browser.newPage();
  await page.setViewport({width: 1600, height: 900});
  await page.goto(process.env.SITE_URL);
  await page.mouse.wheel({deltaY: 1000});
  await page.waitForTimeout(100);
  await page.mouse.wheel({deltaY: 1000});
  await page.waitForTimeout(100);
  //await page.screenshot({ path: 'homepage.png' });
  await browser.close();
})();