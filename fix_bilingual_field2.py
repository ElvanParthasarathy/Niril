import re
with open('moolam/pagudhigal/VanigarThoguppu.tsx', 'r', encoding='utf-8') as f:
    vt = f.read()

vt = vt.replace(
    "sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined} sx={{ mb: isCustomCountry ? 2 : 0 }}",
    "sx={{ mb: isCustomCountry ? 2 : 0, ...(!isBilingual && { gridColumn: { sm: '1 / -1' } }) }}"
)

with open('moolam/pagudhigal/VanigarThoguppu.tsx', 'w', encoding='utf-8') as f:
    f.write(vt)
