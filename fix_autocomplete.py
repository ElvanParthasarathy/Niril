import re
with open('moolam/pagudhigal/VanigarThoguppu.tsx', 'r', encoding='utf-8') as f:
    vt = f.read()

# Replace sx on Autocomplete
vt = vt.replace(
    '''<Autocomplete
            options={stateOptions}
            getOptionLabel={(s) => getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true }) || s}
            value={getField('maanilam', primaryLang) || null}
            onChange={(e, newValue) => updateField('maanilam', primaryLang, newValue || '')}
            renderInput={(params) => (
              <TextField {...params} fullWidth size="medium" sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined} label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} InputLabelProps={{ ...params.InputLabelProps, shrink: true }} placeholder={`${t('selectLabel')} ${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}`} />
            )}
          />''',
    '''<Autocomplete
            options={stateOptions}
            getOptionLabel={(s) => getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true }) || s}
            value={getField('maanilam', primaryLang) || null}
            onChange={(e, newValue) => updateField('maanilam', primaryLang, newValue || '')}
            sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined}
            renderInput={(params) => (
              <TextField {...params} fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} InputLabelProps={{ ...params.InputLabelProps, shrink: true }} placeholder={`${t('selectLabel')} ${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}`} />
            )}
          />'''
)

# And replace the Box sx for custom country
vt = vt.replace(
    '''<Box sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined}>
          <Autocomplete
            options={[...visibleCountries.map(c => c.name), 'Other']}
            getOptionLabel={(c) => c === 'Other' ? 'Other (Custom)' : (getBilingualCountryName(c, { ...profileSettings, returnOnlyPrimary: true }) || c)}
            value={isCustomCountry ? 'Other' : (formCountry || null)}
            onChange={(e, newValue) => {
              const val = newValue || '';
              if (val === 'Other') {
                updateField('country', null, 'Other');
                updateField('country', primaryLang, '');
                updateField('country', secondaryLang, '');
                updateField('maanilam', primaryLang, '');
                updateField('maanilam', secondaryLang, '');
              } else {
                updateField('country', null, val);
                updateField('country', primaryLang, val);
                updateField('country', secondaryLang, '');
                updateField('maanilam', primaryLang, '');
                updateField('maanilam', secondaryLang, '');
              }
            }}
            renderInput={(params) => (
              <TextField {...params} fullWidth size="medium" sx={{ mb: isCustomCountry ? 2 : 0, ...(!isBilingual && { gridColumn: { sm: '1 / -1' } }) }} label={`${t('country')}${primaryLangSuffix}`} InputLabelProps={{ ...params.InputLabelProps, shrink: true }} />
            )}
          />''',
    '''<Box sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined}>
          <Autocomplete
            options={[...visibleCountries.map(c => c.name), 'Other']}
            getOptionLabel={(c) => c === 'Other' ? 'Other (Custom)' : (getBilingualCountryName(c, { ...profileSettings, returnOnlyPrimary: true }) || c)}
            value={isCustomCountry ? 'Other' : (formCountry || null)}
            onChange={(e, newValue) => {
              const val = newValue || '';
              if (val === 'Other') {
                updateField('country', null, 'Other');
                updateField('country', primaryLang, '');
                updateField('country', secondaryLang, '');
                updateField('maanilam', primaryLang, '');
                updateField('maanilam', secondaryLang, '');
              } else {
                updateField('country', null, val);
                updateField('country', primaryLang, val);
                updateField('country', secondaryLang, '');
                updateField('maanilam', primaryLang, '');
                updateField('maanilam', secondaryLang, '');
              }
            }}
            renderInput={(params) => (
              <TextField {...params} fullWidth size="medium" sx={{ mb: isCustomCountry ? 2 : 0 }} label={`${t('country')}${primaryLangSuffix}`} InputLabelProps={{ ...params.InputLabelProps, shrink: true }} />
            )}
          />'''
)

with open('moolam/pagudhigal/VanigarThoguppu.tsx', 'w', encoding='utf-8') as f:
    f.write(vt)
