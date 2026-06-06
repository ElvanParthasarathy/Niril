import { useState, useEffect } from 'react';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion } from '../Payanpadu';
import { useLanguage } from '../mozhi/LanguageContext';
import { TextField, Box, Autocomplete } from '@mui/material';
import { saveClient } from '../Avanam';
import { thagaval } from './Thagaval';
import ElvanEditorLayout from './ElvanEditorLayout';
import ElvanBilingualField from './ElvanBilingualField';

export default function VanigarThoguppu({ onBack, onSaved, client, profileSettings, defaultCountry }) {
  const { t } = useLanguage();
  const fallbackCountry = defaultCountry || detectCountryFromBrowser();
  const [form, setForm] = useState({});
  const [taxIdWarning, setTaxIdWarning] = useState('');
  const isEditing = !!client?.id;

  const isBilingual = profileSettings?.enableBilingual !== false;
  const primaryLang = profileSettings?.primaryDataLanguage || 'Tamil';
  const secondaryLang = profileSettings?.secondaryDataLanguage || 'English';

  const primaryLangSuffix = isBilingual ? ` (${t(primaryLang.toLowerCase() as any) || primaryLang})` : '';
  const secondaryLangSuffix = isBilingual ? ` (${t(secondaryLang.toLowerCase() as any) || secondaryLang})` : '';

  useEffect(() => {
    if (client) {
      setForm({ ...client });
    } else {
      setForm({ country: fallbackCountry, isSEZ: false });
    }
    setTaxIdWarning('');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [client]);

  const updateField = (field, lang, value) => {
    if (lang) {
      setForm(prev => ({ ...prev, [`${field}_${lang}`]: value }));
    } else {
      setForm(prev => ({ ...prev, [field]: value }));
    }
  };

  const getField = (field, lang) => {
    return form[`${field}_${lang}`] || '';
  };

  const formCountry = form.country || fallbackCountry;
  const cc = getCountryConfig(formCountry);
  const stateOptions = getStatesForCountry(formCountry);
  const visibleCountries = getCountriesForRegion();
  const isCustomCountry = formCountry === 'Other' || (formCountry && !visibleCountries.some(c => c.name === formCountry));

  const handleTaxIdBlur = () => {
    const result = validateTaxId(formCountry, form.gstin);
    setTaxIdWarning(result.ok ? '' : result.message);
  };

  const handleSave = async () => {
    const primaryName = getField('name', primaryLang);
    if (!primaryName.trim()) { thagaval('Client name is required', 'warning'); return; }
    try {
      const data = { 
        ...form,
        ...(isEditing ? { id: client.id } : {}),
        name: primaryName.trim(),
        nameEn: getField('name', secondaryLang).trim(),
        mugavari: getField('mugavari', primaryLang).trim(),
        mugavariEn: getField('mugavari', secondaryLang).trim(),
        oor: getField('oor', primaryLang).trim(),
        oorEn: getField('oor', secondaryLang).trim(),
        maavattam: getField('maavattam', primaryLang).trim(),
        maavattamEn: getField('maavattam', secondaryLang).trim(),
        maanilam: getField('maanilam', primaryLang).trim(),
        maanilamEn: getField('maanilam', secondaryLang).trim(),
        country: isCustomCountry ? getField('country', primaryLang).trim() : formCountry,
        countryEn: isCustomCountry ? getField('country', secondaryLang).trim() : '',
        pin: form.pin || '',
        gstin: form.gstin || '',
        email: form.email || '',
        tholaipesi: form.tholaipesi || '',
      };
      
      const savedClient = await saveClient(data);
      thagaval(isEditing ? 'Client updated' : 'Client added', 'success');
      onSaved(savedClient);
    } catch {
      thagaval('Failed to save client', 'error');
    }
  };

  return (
    <ElvanEditorLayout
      title={(isEditing ? t('editClientTitle') : t('addNewClientTitle')) as string}
      onBack={onBack}
      onSave={handleSave}
      saveButtonText={(isEditing ? t('updateClientModalBtn') : t('saveClientModalBtn')) as string}
    >
      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3 }}>
        <ElvanBilingualField
          label={t('clientBusinessName') as string}
          primaryLang={primaryLang}
          secondaryLang={secondaryLang}
          isBilingual={isBilingual}
          primaryValue={getField('name', primaryLang)}
          onPrimaryChange={e => updateField('name', primaryLang, e.target.value)}
          secondaryValue={getField('name', secondaryLang)}
          onSecondaryChange={e => updateField('name', secondaryLang, e.target.value)}
          placeholder={t('clientNamePlaceholder') as string}
        />
      </Box>

      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
        <ElvanBilingualField
          label={t('billingAddress') as string}
          primaryLang={primaryLang}
          secondaryLang={secondaryLang}
          isBilingual={isBilingual}
          primaryValue={getField('mugavari', primaryLang)}
          onPrimaryChange={e => updateField('mugavari', primaryLang, e.target.value)}
          secondaryValue={getField('mugavari', secondaryLang)}
          onSecondaryChange={e => updateField('mugavari', secondaryLang, e.target.value)}
          placeholder={t('streetAddressPlaceholder') as string}
        />

        <ElvanBilingualField
          label={t('city') as string}
          primaryLang={primaryLang}
          secondaryLang={secondaryLang}
          isBilingual={isBilingual}
          primaryValue={getField('oor', primaryLang)}
          onPrimaryChange={e => updateField('oor', primaryLang, e.target.value)}
          secondaryValue={getField('oor', secondaryLang)}
          onSecondaryChange={e => updateField('oor', secondaryLang, e.target.value)}
          placeholder={t('cityPlaceholder') as string}
        />

        <ElvanBilingualField
          label={t('district') as string}
          primaryLang={primaryLang}
          secondaryLang={secondaryLang}
          isBilingual={isBilingual}
          primaryValue={getField('maavattam', primaryLang)}
          onPrimaryChange={e => updateField('maavattam', primaryLang, e.target.value)}
          secondaryValue={getField('maavattam', secondaryLang)}
          onSecondaryChange={e => updateField('maavattam', secondaryLang, e.target.value)}
          placeholder={t('districtPlaceholder') as string}
        />

        {stateOptions.length > 0 ? (
          <Autocomplete
            options={stateOptions}
            getOptionLabel={(s) => getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true }) || s}
            value={getField('maanilam', primaryLang) || null}
            onChange={(e, newValue) => updateField('maanilam', primaryLang, newValue || '')}
            sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined}
            renderInput={(params) => (
              <TextField {...params} fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} InputLabelProps={{ ...params.InputLabelProps, shrink: true }} placeholder={`${t('selectLabel')} ${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}`} />
            )}
          />
        ) : (
          <TextField fullWidth size="medium" sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined} label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={getField('maanilam', primaryLang)} onChange={e => updateField('maanilam', primaryLang, e.target.value)} placeholder={cc.stateLabel} />
        )}

        {isBilingual && (
          <TextField fullWidth size="medium" disabled label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={getField('maanilam', primaryLang) ? getBilingualStateName(getField('maanilam', primaryLang), { ...profileSettings, returnOnlySecondary: true }) : ''} sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
        )}

        <Box sx={!isBilingual ? { gridColumn: { sm: '1 / -1' } } : undefined}>
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
          />
          {isCustomCountry && (
            <TextField fullWidth size="medium" 
              value={getField('country', primaryLang)} 
              onChange={e => updateField('country', primaryLang, e.target.value)} 
              placeholder={t('hc_enterCountryName') as string} />
          )}
        </Box>

        {isBilingual && (
          <Box>
            {isCustomCountry && <Box sx={{ height: 40, mb: 2 }} />}
            <TextField fullWidth size="medium" disabled={!isCustomCountry} label={`${t('country')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={isCustomCountry ? getField('country', secondaryLang) : (formCountry ? getBilingualCountryName(formCountry, { ...profileSettings, returnOnlySecondary: true }) : '')}
              onChange={e => isCustomCountry ? updateField('country', secondaryLang, e.target.value) : null}
              sx={!isCustomCountry ? { '& .MuiInputBase-root': { bgcolor: 'action.hover' } } : {}}
              placeholder={t('country') as string} />
          </Box>
        )}

        <TextField fullWidth size="medium" label={t(cc.postalLabel as any, { defaultValue: cc.postalLabel }) as string} slotProps={{ inputLabel: { shrink: true } }}
          value={form.pin || ''} onChange={e => updateField('pin', null, e.target.value)} placeholder={cc.postalLabel} />
      </Box>

      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
        <TextField fullWidth size="medium" label={t(cc.taxIdLabel as any) || cc.taxIdLabel}
          error={!!taxIdWarning} helperText={taxIdWarning || ' '}
          value={form.gstin || ''} onChange={e => { updateField('gstin', null, e.target.value.toUpperCase()); if (taxIdWarning) setTaxIdWarning(''); }}
          onBlur={handleTaxIdBlur} placeholder={cc.taxIdPlaceholder} slotProps={{ inputLabel: { shrink: true }, htmlInput: { maxLength: 20 } }} />

        <TextField fullWidth size="medium" label={t('emailLabel') as string} slotProps={{ inputLabel: { shrink: true } }} type="email"
          value={form.email || ''} onChange={e => updateField('email', null, e.target.value)} placeholder={t('emailPlaceholder') as string} />
        
        <TextField fullWidth size="medium" label={t('phoneLabel') as string} slotProps={{ inputLabel: { shrink: true } }} type="tel"
          value={form.tholaipesi || ''} onChange={e => updateField('tholaipesi', null, e.target.value)} placeholder={t('phonePlaceholder') as string} />
      </Box>
    </ElvanEditorLayout>
  );
}
