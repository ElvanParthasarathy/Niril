// @ts-nocheck
import { FloppyDisk } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion } from '../Payanpadu';
import { useLanguage } from '../mozhi/LanguageContext';
import { TextField, Button, Box, Autocomplete, Typography } from '@mui/material';
import { saveClient } from '../Avanam';
import { thagaval } from './Thagaval';
import { FloatingBackButton } from './FloatingBackButton';

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
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', position: 'relative' }}>
      
      <Box sx={{ px: { xs: 2, md: 0 }, mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h5" sx={{ ml: 2, fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary' }}>
          {isEditing ? t('editClientTitle') : t('addNewClientTitle')}
        </Typography>
        <FloatingBackButton onBack={onBack} label={t('back') as string} className="back-pill" />
      </Box>

      <Box sx={{ px: { xs: 2, md: 0 } }}>
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3 }}>
          <TextField fullWidth size="medium" label={`${t('clientBusinessName')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={getField('name', primaryLang)} onChange={e => updateField('name', primaryLang, e.target.value)} placeholder={t('clientNamePlaceholder')} />
          
          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('clientBusinessName')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={getField('name', secondaryLang)} onChange={e => updateField('name', secondaryLang, e.target.value)} placeholder={t('clientNamePlaceholder')} />
          )}
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
          <TextField fullWidth size="medium" label={`${t('billingAddress')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={getField('mugavari', primaryLang)} onChange={e => updateField('mugavari', primaryLang, e.target.value)} placeholder={t('streetAddressPlaceholder')} />

          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('billingAddress')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={getField('mugavari', secondaryLang)} onChange={e => updateField('mugavari', secondaryLang, e.target.value)} placeholder={t('streetAddressPlaceholder')} />
          )}

          <TextField fullWidth size="medium" label={`${t('city')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={getField('oor', primaryLang)} onChange={e => updateField('oor', primaryLang, e.target.value)} placeholder={t('cityPlaceholder')} />

          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('city')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={getField('oor', secondaryLang)} onChange={e => updateField('oor', secondaryLang, e.target.value)} placeholder={t('cityPlaceholder')} />
          )}

          <TextField fullWidth size="medium" label={`${t('district')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={getField('maavattam', primaryLang)} onChange={e => updateField('maavattam', primaryLang, e.target.value)} placeholder={t('districtPlaceholder')} />

          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('district')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={getField('maavattam', secondaryLang)} onChange={e => updateField('maavattam', secondaryLang, e.target.value)} placeholder={t('districtPlaceholder')} />
          )}

          {stateOptions.length > 0 ? (
            <Autocomplete
              options={stateOptions}
              getOptionLabel={(s) => getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true }) || s}
              value={getField('maanilam', primaryLang) || null}
              onChange={(e, newValue) => updateField('maanilam', primaryLang, newValue || '')}
              renderInput={(params) => (
                <TextField {...params} fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} InputLabelProps={{ shrink: true }} placeholder={`${t('selectLabel')} ${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}`} />
              )}
            />
          ) : (
            <TextField fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={getField('maanilam', primaryLang)} onChange={e => updateField('maanilam', primaryLang, e.target.value)} placeholder={cc.stateLabel} />
          )}

          {isBilingual && (
            <TextField fullWidth size="medium" disabled label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={getField('maanilam', primaryLang) ? getBilingualStateName(getField('maanilam', primaryLang), { ...profileSettings, returnOnlySecondary: true }) : ''} sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
          )}

          <Box>
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
                <TextField {...params} fullWidth size="medium" sx={{ mb: isCustomCountry ? 2 : 0 }} label={`${t('country')}${primaryLangSuffix}`} InputLabelProps={{ shrink: true }} />
              )}
            />
            {isCustomCountry && (
              <TextField fullWidth size="medium" 
                value={getField('country', primaryLang)} 
                onChange={e => updateField('country', primaryLang, e.target.value)} 
                placeholder="Enter country name" />
            )}
          </Box>

          {isBilingual && (
            <Box>
              {isCustomCountry && <Box sx={{ height: 40, mb: 2 }} />}
              <TextField fullWidth size="medium" disabled={!isCustomCountry} label={`${t('country')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
                value={isCustomCountry ? getField('country', secondaryLang) : (formCountry ? getBilingualCountryName(formCountry, { ...profileSettings, returnOnlySecondary: true }) : '')}
                onChange={e => isCustomCountry ? updateField('country', secondaryLang, e.target.value) : null}
                sx={!isCustomCountry ? { '& .MuiInputBase-root': { bgcolor: 'action.hover' } } : {}}
                placeholder={t('country')} />
            </Box>
          )}

          <TextField fullWidth size="medium" label={t(cc.postalLabel as any, { defaultValue: cc.postalLabel })} slotProps={{ inputLabel: { shrink: true } }}
            value={form.pin || ''} onChange={e => updateField('pin', null, e.target.value)} placeholder={cc.postalLabel} />
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
          <TextField fullWidth size="medium" label={t(cc.taxIdLabel as any) || cc.taxIdLabel}
            error={!!taxIdWarning} helperText={taxIdWarning || ' '}
            value={form.gstin || ''} onChange={e => { updateField('gstin', null, e.target.value.toUpperCase()); if (taxIdWarning) setTaxIdWarning(''); }}
            onBlur={handleTaxIdBlur} placeholder={cc.taxIdPlaceholder} slotProps={{ inputLabel: { shrink: true }, htmlInput: { maxLength: 20 } }} />

          <TextField fullWidth size="medium" label={t('emailLabel')} slotProps={{ inputLabel: { shrink: true } }} type="email"
            value={form.email || ''} onChange={e => updateField('email', null, e.target.value)} placeholder={t('emailPlaceholder')} />
          
          <TextField fullWidth size="medium" label={t('phoneLabel')} slotProps={{ inputLabel: { shrink: true } }} type="tel"
            value={form.tholaipesi || ''} onChange={e => updateField('tholaipesi', null, e.target.value)} placeholder={t('phonePlaceholder')} />
        </Box>
        
      </Box>

      <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mb: 6, mt: 5, px: { xs: 2, md: 0 } }}>
        <Button variant="contained" disableElevation onClick={onBack} sx={{ height: 40, minHeight: 40, maxHeight: 40, px: 3, borderRadius: '50px', bgcolor: 'background.paper', color: 'text.primary', '&:hover': { bgcolor: 'action.hover' } }}>
          {t('cancelModalBtn')}
        </Button>
        <Button variant="contained" color="primary" disableElevation onClick={handleSave} startIcon={<FloppyDisk size={20} weight="bold" />} sx={{ height: 40, minHeight: 40, maxHeight: 40, px: 3, borderRadius: '50px' }}>
          {isEditing ? t('updateClientModalBtn') : t('saveClientModalBtn')}
        </Button>
      </Box>
    </Box>
  );
}
