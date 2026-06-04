const fs = require('fs');

function fixFile(f) {
  let code = fs.readFileSync(f, 'utf8');
  
  // Replace standard cases
  code = code.replace(/<Grid size=\{\{\s*xs:\s*12\s*\}\}/g, '<Grid item xs={12}');
  code = code.replace(/<Grid size=\{\{\s*xs:\s*12,\s*sm:\s*6\s*\}\}/g, '<Grid item xs={12} sm={6}');
  code = code.replace(/<Grid size=\{\{\s*xs:\s*12,\s*sm:\s*12\s*\}\}/g, '<Grid item xs={12} sm={12}');
  
  // Replace the complex cases
  code = code.replace(/<Grid size=\{\{\s*xs:\s*12,\s*sm:\s*profileSettings\?\.enableBilingual !== false \? 6 : 12\s*\}\}/g, '<Grid item xs={12} sm={profileSettings?.enableBilingual !== false ? 6 : 12}');
  code = code.replace(/<Grid size=\{\{\s*xs:\s*12,\s*sm:\s*profileSettings\?\.bilingual \? 6 : 12\s*\}\}/g, '<Grid item xs={12} sm={profileSettings?.bilingual ? 6 : 12}');

  fs.writeFileSync(f, code);
}

fixFile('d:/Projects/Elvan Niril/moolam/pagudhigal/VanigarThoguppu.tsx');
fixFile('d:/Projects/Elvan Niril/moolam/pagudhigal/VanigarThirai.tsx');
console.log('Fixed files');
