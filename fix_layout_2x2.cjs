const fs = require('fs');
const filePath = 'd:/Projects/Elvan Niril/moolam/pagudhigal/VanigarThoguppu.tsx';
let code = fs.readFileSync(filePath, 'utf8');

// Tax Section: Make GSTIN sm=6
code = code.replace(
  /<Grid item xs=\{12\} sm=\{12\}>\s*<TextField fullWidth size="medium" label=\{t\(cc\.taxIdLabel/g,
  '<Grid item xs={12} sm={6}>\n            <TextField fullWidth size="medium" label={t(cc.taxIdLabel'
);

// City Tamil
code = code.replace(
  /<Grid item xs=\{12\} sm=\{profileSettings\?\.enableBilingual !== false \? 6 : 12\}>\s*<TextField fullWidth size="medium" label=\{\`\$\{\(t\('city' as any/g,
  '<Grid item xs={12} sm={profileSettings?.enableBilingual !== false ? 3 : 6}>\n            <TextField fullWidth size="medium" label={`${(t(\'city\' as any'
);

// City English
code = code.replace(
  /<Grid item xs=\{12\} sm=\{6\}>\s*<TextField fullWidth size="medium" label=\{\`\$\{\(t\('city' as any\) \|\| 'City'\)\} \(\$\{profileSettings\?\.secondaryDataLanguage/g,
  '<Grid item xs={12} sm={3}>\n              <TextField fullWidth size="medium" label={`${(t(\'city\' as any) || \'City\')} (${profileSettings?.secondaryDataLanguage'
);

// District Tamil
code = code.replace(
  /<Grid item xs=\{12\} sm=\{profileSettings\?\.enableBilingual !== false \? 6 : 12\}>\s*<TextField fullWidth size="medium" label=\{\`மாவட்டம் \(District\)/g,
  '<Grid item xs={12} sm={profileSettings?.enableBilingual !== false ? 3 : 6}>\n            <TextField fullWidth size="medium" label={`மாவட்டம் (District)'
);

// District English
code = code.replace(
  /<Grid item xs=\{12\} sm=\{6\}>\s*<TextField fullWidth size="medium" label=\{\`District \(\$\{profileSettings\?\.secondaryDataLanguage \|\| 'English'\}\)\`/g,
  '<Grid item xs={12} sm={3}>\n              <TextField fullWidth size="medium" label={`District (${profileSettings?.secondaryDataLanguage || \'English\'})`'
);

// State Tamil
code = code.replace(
  /<Grid item xs=\{12\} sm=\{profileSettings\?\.enableBilingual !== false \? 6 : 12\}>\s*\{stateOptions\.length > 0 \? \(/g,
  '<Grid item xs={12} sm={profileSettings?.enableBilingual !== false ? 3 : 6}>\n            {stateOptions.length > 0 ? ('
);

// State English
code = code.replace(
  /<Grid item xs=\{12\} sm=\{6\}>\s*<TextField fullWidth size="medium" disabled label=\{\`\$\{t\(cc\.stateLabel/g,
  '<Grid item xs={12} sm={3}>\n              <TextField fullWidth size="medium" disabled label={`${t(cc.stateLabel'
);

// Country Tamil
code = code.replace(
  /<Grid item xs=\{12\} sm=\{profileSettings\?\.enableBilingual !== false \? 6 : 12\}>\s*<TextField select fullWidth size="medium" label=\{\`\$\{t\('country'\)/g,
  '<Grid item xs={12} sm={profileSettings?.enableBilingual !== false ? 3 : 6}>\n                  <TextField select fullWidth size="medium" label={`${t(\'country\')'
);

// Country English
code = code.replace(
  /<Grid item xs=\{12\} sm=\{6\}>\s*<TextField fullWidth size="medium" disabled=\{!isCustomCountry\} label=\{\`\$\{t\('country'\)/g,
  '<Grid item xs={12} sm={3}>\n                    <TextField fullWidth size="medium" disabled={!isCustomCountry} label={`${t(\'country\')'
);

// PIN Code
code = code.replace(
  /<Grid item xs=\{12\} sm=\{6\}>\s*<TextField fullWidth size="medium" label=\{t\(cc\.postalLabel/g,
  '<Grid item xs={12} sm={3}>\n            <TextField fullWidth size="medium" label={t(cc.postalLabel'
);

fs.writeFileSync(filePath, code);
console.log('Grid items updated for 2x2 layout!');
