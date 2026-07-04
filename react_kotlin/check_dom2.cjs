const puppeteer = require('puppeteer');
const { spawn } = require('child_process');

(async () => {
  const vite = spawn('npx', ['vite', '--port', '5176'], { shell: true });
  await new Promise(r => setTimeout(r, 4000));
  
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('BROWSER:', msg.text()));
  page.on('pageerror', err => console.log('BROWSER ERR:', err.toString()));
  
  try {
    await page.goto('http://localhost:5176', { waitUntil: 'load', timeout: 15000 });
  } catch (e) {
    console.log('GOTO ERR:', e.toString());
  }
  await new Promise(r => setTimeout(r, 2000));
  
  const html = await page.content();
  console.log('DOM CONTENT LENGHT:', html.length);
  
  const rootHtml = await page.evaluate(() => document.getElementById('root') ? document.getElementById('root').innerHTML : 'NO ROOT');
  console.log('ROOT HTML:', rootHtml.substring(0, 500));
  
  await browser.close();
  vite.kill();
  console.log('Done.');
})();
