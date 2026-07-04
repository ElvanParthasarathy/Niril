/**
 * Post-build script: strips the Content-Security-Policy meta tag and
 * font preload crossorigin attributes from dist/index.html so the
 * bundle works correctly inside an Android WebView loading from file://.
 */
const fs = require('fs');
const path = require('path');

const indexPath = path.join(__dirname, 'dist', 'index.html');
let html = fs.readFileSync(indexPath, 'utf-8');

// Remove the CSP meta tag entirely (it blocks scripts/styles in file:// context)
html = html.replace(/<!--[\s\S]*?Content Security Policy[\s\S]*?-->\s*<meta\s+http-equiv="Content-Security-Policy"[\s\S]*?\/>\s*/g, '');

// Remove crossorigin from font preloads (file:// doesn't support CORS)
html = html.replace(/(<link\s+rel="preload"[^>]*)\s+crossorigin\s*/g, '$1 ');

// Remove crossorigin from script/modulepreload tags too
html = html.replace(/(<(?:script|link)\s+[^>]*)\s+crossorigin\s*/g, '$1 ');

fs.writeFileSync(indexPath, html, 'utf-8');
console.log('✅ Stripped CSP and crossorigin attributes from dist/index.html');
