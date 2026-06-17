const fs = require('fs');
const path = require('path');

const taExport = require('./ta.cjs');
const enExport = require('./en.cjs');

const ta = taExport.ta || taExport;
const en = enExport.en || enExport;

function writeDartMap(name, obj) {
  let dartCode = `const Map<String, String> ${name} = {\n`;
  for (const [key, value] of Object.entries(obj)) {
    if (typeof value === 'string') {
      const safeKey = key.replace(/'/g, "\\'").replace(/\n/g, "\\n").replace(/\$/g, "\\$");
      const safeValue = value.replace(/'/g, "\\'").replace(/\n/g, "\\n").replace(/\$/g, "\\$");
      dartCode += `  '${safeKey}': '${safeValue}',\n`;
    }
  }
  dartCode += `};\n`;
  return dartCode;
}

const dartCode = writeDartMap('ta', ta) + '\n' + writeDartMap('en', en);
fs.writeFileSync('./flutter/lib/src/localization/translations.dart', dartCode);
console.log('Translations exported to Dart!');
