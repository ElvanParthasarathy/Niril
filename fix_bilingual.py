import re
with open('moolam/pagudhigal/ElvanBilingualField.tsx', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    '<Grid size={{ xs: 12, sm: isBilingual ? 6 : 12 }}>',
    '<Grid size={{ xs: 12, sm: isBilingual ? 6 : 12 }} sx={!isBilingual ? { gridColumn: { sm: \'1 / -1\' } } : undefined}>'
)

with open('moolam/pagudhigal/ElvanBilingualField.tsx', 'w', encoding='utf-8') as f:
    f.write(content)

with open('moolam/pagudhigal/VanigarThoguppu.tsx', 'r', encoding='utf-8') as f:
    vt = f.read()

# Fix State Autocomplete
vt = vt.replace(
    'renderInput={(params) => (\n              <TextField {...params} fullWidth size="medium"',
    'renderInput={(params) => (\n              <TextField {...params} fullWidth size="medium" sx={!isBilingual ? { gridColumn: { sm: \'1 / -1\' } } : undefined}'
)
# Fix State TextField
vt = vt.replace(
    '<TextField fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}\n            value={getField(\'maanilam\', primaryLang)}',
    '<TextField fullWidth size="medium" sx={!isBilingual ? { gridColumn: { sm: \'1 / -1\' } } : undefined} label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}\n            value={getField(\'maanilam\', primaryLang)}'
)
# Fix Country Box
vt = vt.replace(
    '<Box>\n          <Autocomplete\n            options={[...visibleCountries.map',
    '<Box sx={!isBilingual ? { gridColumn: { sm: \'1 / -1\' } } : undefined}>\n          <Autocomplete\n            options={[...visibleCountries.map'
)

with open('moolam/pagudhigal/VanigarThoguppu.tsx', 'w', encoding='utf-8') as f:
    f.write(vt)
