const fs = require('fs');
const path = require('path');

const replaceMap = {
  'LocationOn': 'MapPin',
  'LocationOnIcon': 'MapPin',
  'ColorLens': 'Palette',
  'ColorLensIcon': 'Palette',
  'Brush': 'PaintBrush',
  'BrushIcon': 'PaintBrush',
  'Delete': 'Trash',
  'DeleteIcon': 'Trash',
  'Image': 'ImageSquare',
  'ImageIcon': 'ImageSquare',
  'Create': 'PencilSimple',
  'CreateIcon': 'PencilSimple',
  'AccountBalance': 'Bank',
  'AccountBalanceIcon': 'Bank',
  'Save': 'FloppyDisk',
  'SaveIcon': 'FloppyDisk',
  'Business': 'Buildings',
  'BusinessIcon': 'Buildings',
  'Settings': 'Gear',
  'SettingsIcon': 'Gear',
  'Add': 'Plus',
  'AddIcon': 'Plus',
  'Close': 'X',
  'CloseIcon': 'X',
  'ArrowBack': 'ArrowLeft',
  'ArrowBackIcon': 'ArrowLeft',
  'Description': 'FileText',
  'Download': 'DownloadSimple',
  'Upload': 'UploadSimple',
  'OpenInNew': 'ArrowSquareOut',
  'CheckCircle': 'CheckCircle',
  'KeyboardArrowDown': 'CaretDown',
  'KeyboardArrowRight': 'CaretRight',
  'Warning': 'Warning',
  'MenuBook': 'BookOpen',
  'BarChart': 'ChartBar'
};

const dir = 'd:/Projects/Elvan Niril/moolam/pagudhigal';

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  if (!content.includes('@mui/icons-material')) return;

  // Step 1: Find all imported MUI icons
  const muiImportRegex = /import\s+(?:{\s*([^}]+)\s*}|([A-Za-z0-9_]+))\s+from\s+['"]@mui\/icons-material(?:\/[^'"]+)?['"];/g;
  let phosphorImports = new Set();
  
  let match;
  while ((match = muiImportRegex.exec(content)) !== null) {
    if (match[1]) {
      match[1].split(',').map(s => s.trim()).forEach(i => {
        if (replaceMap[i]) phosphorImports.add(replaceMap[i]);
      });
    } else if (match[2]) {
      let iconName = match[2];
      if (replaceMap[iconName]) phosphorImports.add(replaceMap[iconName]);
    }
  }

  const singleImportRegex = /import\s+([A-Za-z0-9_]+)\s+from\s+['"]@mui\/icons-material\/[^'"]+['"];/g;
  while ((match = singleImportRegex.exec(content)) !== null) {
    let iconName = match[1];
    if (replaceMap[iconName]) phosphorImports.add(replaceMap[iconName]);
  }

  if (phosphorImports.size > 0) {
    const pImportsStr = `import { ${Array.from(phosphorImports).join(', ')} } from '@phosphor-icons/react';`;
    content = content.replace(/import\s+.*?\s+from\s+['"]@mui\/icons-material.*?['"];?\n/g, '');
    content = content.replace(/(import React.*?;\n)/, `$1${pImportsStr}\n`);

    for (const [muiIcon, pIcon] of Object.entries(replaceMap)) {
      const tagRegex = new RegExp(`<${muiIcon}([^>]*)>`, 'g');
      content = content.replace(tagRegex, `<${pIcon} size={20} weight="fill"$1>`);
      const tagSelfCloseRegex = new RegExp(`<${muiIcon}\\s*\\/>`, 'g');
      content = content.replace(tagSelfCloseRegex, `<${pIcon} size={20} weight="fill" />`);
    }
    
    fs.writeFileSync(filePath, content, 'utf8');
    console.log('Updated', filePath);
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
