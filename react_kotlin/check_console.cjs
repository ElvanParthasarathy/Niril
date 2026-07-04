const puppeteer = require('puppeteer');
const { spawn } = require('child_process');

(async () => {
  console.log('Starting Vite server...');
  const vite = spawn('npx', ['vite', '--port', '5174'], { shell: true });
  
  vite.stdout.on('data', (d) => console.log('VITE:', d.toString()));
  vite.stderr.on('data', (d) => console.error('VITE ERR:', d.toString()));

  // Wait for Vite to start
  await new Promise(r => setTimeout(r, 4000));

  console.log('Launching Puppeteer...');
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  page.on('console', msg => {
    if (msg.type() === 'error') {
      console.log('BROWSER ERROR:', msg.text());
    } else {
      console.log('BROWSER LOG:', msg.text());
    }
  });

  page.on('pageerror', err => {
    console.log('BROWSER UNCAUGHT EXCEPTION:', err.toString());
  });

  console.log('Navigating to localhost:5174...');
  await page.goto('http://localhost:5174', { waitUntil: 'networkidle2' });
  
  await new Promise(r => setTimeout(r, 2000));

  await browser.close();
  vite.kill();
  console.log('Done.');
})();
