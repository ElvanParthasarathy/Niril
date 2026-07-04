const puppeteer = require('puppeteer');
const { spawn } = require('child_process');

(async () => {
  const vite = spawn('npx', ['vite', '--port', '5175'], { shell: true });
  await new Promise(r => setTimeout(r, 5000));
  
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('BROWSER:', msg.text()));
  page.on('pageerror', err => console.log('BROWSER ERR:', err.toString()));
  
  await page.goto('http://localhost:5175', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2000));
  
  const html = await page.content();
  console.log('DOM CONTENT LENGHT:', html.length);
  
  const rootHtml = await page.evaluate(() => document.getElementById('root').innerHTML);
  console.log('ROOT HTML:', rootHtml.substring(0, 500));
  
  await browser.close();
  vite.kill();
  console.log('Done.');
})();
