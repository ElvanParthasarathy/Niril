const fs = require('fs');
const path = require('path');

const dir = 'd:/Projects/Elvan Niril/moolam/pagudhigal';

function processFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  content = content.replace(/<Gear size=\{20\} weight=\"fill\"PillRow/g, '<SettingsPillRow');
  content = content.replace(/<Gear size=\{20\} weight=\"fill\"PillContainer/g, '<SettingsPillContainer');
  content = content.replace(/<Gear size=\{20\} weight=\"fill\"Row/g, '<SettingsRow');
  content = content.replace(/<Gear size=\{20\} weight=\"fill\"Section/g, '<SettingsSection');
  content = content.replace(/<Gear size=\{20\} weight=\"fill\"Group/g, '<SettingsGroup');
  content = content.replace(/<Gear size=\{20\} weight=\"fill\"Item/g, '<SettingsItem');
  content = content.replace(/<Gear size=\{20\} weight=\"fill\"Divider/g, '<SettingsDivider');
  
  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log('Fixed', filePath);
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
