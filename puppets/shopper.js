const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({headless: "new"});
  const page = await browser.newPage();
  await page.setViewport({width: 1600, height: 900});
  await page.goto(process.env.SITE_URL);
  await new Promise(resolve => setTimeout(resolve, 2000));
  await page.click('a[href$="sale.html"]');
  await new Promise(resolve => setTimeout(resolve, 2000));
  await page.click('#maincontent > div.columns > div.sidebar.sidebar-main > div > div > ul:nth-child(2) > li:nth-child(2) > a');
  await new Promise(resolve => setTimeout(resolve, 2000));
  await page.mouse.wheel({deltaY: 500});
  await new Promise(resolve => setTimeout(resolve, 100));
  await page.click('#product-item-info_1316 > a > span > span > img');
  await new Promise(resolve => setTimeout(resolve, 2000));
  await page.click('#option-label-size-144-item-168');
  await new Promise(resolve => setTimeout(resolve, 500));
  await page.click('#option-label-color-93-item-56');
  await new Promise(resolve => setTimeout(resolve, 500));
  await page.click('#product-addtocart-button > span');
  await new Promise(resolve => setTimeout(resolve, 2000));
  await page.click('#maincontent > div.page.messages > div:nth-child(2) > div > div > div > a');
  await new Promise(resolve => setTimeout(resolve, 2000));
  //await page.screenshot({ path: 'shopper.png' });
  await browser.close();
})();