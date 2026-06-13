const fs = require('fs');
const path = require('path');

const dir = 'd:/Projects/Elvan Niril/moolam/pagudhigal';

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let phosphorImports = content.match(/import\s+\{[^}]+\}\s+from\s+['"]@phosphor-icons\/react['"];/g);
  if (phosphorImports && phosphorImports.length > 1) {
    console.log('Multiple Phosphor imports in:', filePath);
  }
}

function walkDir(d) {
  const files = fs.readdirSync(d);
  for (const f of files) {
    const full = path.join(d, f);
    if (fs.statSync(full).isDirectory()) {
      walkDir(full);
    } else if (full.endsWith('.tsx') || full.endsWith('.ts')) {
      processFile(full);
    }
  }
}

walkDir(dir);
