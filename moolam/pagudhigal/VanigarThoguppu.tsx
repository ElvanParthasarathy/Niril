// @ts-nocheck
import { FloppyDisk } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion } from '../Payanpadu';
import { useLanguage } from '../mozhi/LanguageContext';
import { TextField, MenuItem, Button, Grid, Typography, Box, Divider } from '@mui/material';
import { saveClient } from '../Avanam';
import { thagaval } from './Thagaval';
import { FloatingBackButton } from './FloatingBackButton';

export default function VanigarThoguppu({ onBack, onSaved, client, profileSettings, defaultCountry }) {
  const { t } = useLanguage();
  const fallbackCountry = defaultCountry || detectCountryFromBrowser();
  const emptyForm = { name: '', nameEn: '', mugavari: '', mugavariEn: '', oor: '', oorEn: '', maavattam: '', maavattamEn: '', pin: '', maanilam: '', maanilamEn: '', gstin: '', email: '', tholaipesi: '', country: fallbackCountry, countryEn: '', isSEZ: false };
  const [form, setForm] = useState({ ...emptyForm });
  const [taxIdWarning, setTaxIdWarning] = useState('');
  const isEditing = !!client?.id;

  useEffect(() => {
    if (client) {
      setForm({
        name: client.name || '', nameEn: client.nameEn || '', mugavari: client.mugavari || '', mugavariEn: client.mugavariEn || '', oor: client.oor || '', oorEn: client.oorEn || '',
        maavattam: client.maavattam || '', maavattamEn: client.maavattamEn || '',
        pin: client.pin || '', maanilam: client.maanilam || '', maanilamEn: client.maanilamEn || '', gstin: client.gstin || '',
        email: client.email || '', tholaipesi: client.tholaipesi || '', country: client.country || fallbackCountry, countryEn: client.countryEn || '',
        isSEZ: !!client.isSEZ,
      });
    } else {
      setForm({ ...emptyForm });
    }
    setTaxIdWarning('');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [client]);

  const cc = getCountryConfig(form.country);
  const stateOptions = getStatesForCountry(form.country);

  const handleTaxIdBlur = () => {
    const result = validateTaxId(form.country, form.gstin);
    setTaxIdWarning(result.ok ? '' : result.message);
  };

  const handleSave = async () => {
    if (!form.name.trim()) { thagaval('Client name is required', 'warning'); return; }
    try {
      const data = { ...form };
      if (isEditing) data.id = client.id;
      const savedClient = await saveClient(data);
      thagaval(isEditing ? 'Client updated' : 'Client added', 'success');
      onSaved(savedClient);
    } catch {
      thagaval('Failed to save client', 'error');
    }
  };

  const isBilingual = profileSettings?.enableBilingual !== false;
  const primaryLangSuffix = isBilingual ? ` (${t((profileSettings?.primaryDataLanguage?.toLowerCase() || 'tamil') as any) || profileSettings?.primaryDataLanguage || 'Tamil'})` : '';
  const secondaryLangSuffix = ` (${t((profileSettings?.secondaryDataLanguage?.toLowerCase() || 'english') as any) || profileSettings?.secondaryDataLanguage || 'English'})`;
  const visibleCountries = getCountriesForRegion();
  const isCustomCountry = form.country === 'Other' || (form.country && !visibleCountries.some(c => c.name === form.country));

  return (
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', position: 'relative' }}>
      
      <Box sx={{ px: { xs: 2, md: 0 }, mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h5" sx={{ ml: 2, fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary' }}>
          {isEditing ? t('editClientTitle') : t('addNewClientTitle')}
        </Typography>
        <FloatingBackButton onBack={onBack} label={t('back') as string} className="back-pill" />
      </Box>

      <Box sx={{ px: { xs: 2, md: 0 } }}>
        {/* Form Fields Start */}
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3 }}>
          <TextField fullWidth size="medium" label={`${t('clientBusinessName')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={form.name} onChange={e => setForm(prev => ({ ...prev, name: e.target.value }))} placeholder={t('clientNamePlaceholder')} />
          
          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('clientBusinessName')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.nameEn || ''} onChange={e => setForm(prev => ({ ...prev, nameEn: e.target.value }))} placeholder={t('clientNamePlaceholder')} />
          )}
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
          <TextField fullWidth size="medium" label={`${t('billingAddress')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={form.mugavari} onChange={e => setForm(prev => ({ ...prev, mugavari: e.target.value }))} placeholder={t('streetAddressPlaceholder')} />

          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('billingAddress')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.mugavariEn || ''} onChange={e => setForm(prev => ({ ...prev, mugavariEn: e.target.value }))} placeholder={t('streetAddressPlaceholder')} />
          )}

          <TextField fullWidth size="medium" label={`${t('city')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={form.oor} onChange={e => setForm(prev => ({ ...prev, oor: e.target.value }))} placeholder={t('cityPlaceholder')} />

          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('city')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.oorEn || ''} onChange={e => setForm(prev => ({ ...prev, oorEn: e.target.value }))} placeholder={t('cityPlaceholder')} />
          )}

          <TextField fullWidth size="medium" label={`${t('district')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={form.maavattam || ''} onChange={e => setForm(prev => ({ ...prev, maavattam: e.target.value }))} placeholder={t('districtPlaceholder')} />

          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('district')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.maavattamEn || ''} onChange={e => setForm(prev => ({ ...prev, maavattamEn: e.target.value }))} placeholder={t('districtPlaceholder')} />
          )}

          {stateOptions.length > 0 ? (
            <TextField select fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.maanilam} onChange={e => setForm(prev => ({ ...prev, maanilam: e.target.value }))}>
              <MenuItem value="">{t('selectLabel')} {t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}</MenuItem>
              {stateOptions.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true })}</MenuItem>)}
            </TextField>
          ) : (
            <TextField fullWidth size="medium" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.maanilam} onChange={e => setForm(prev => ({ ...prev, maanilam: e.target.value }))} placeholder={cc.stateLabel} />
          )}

          {isBilingual && (
            <TextField fullWidth size="medium" disabled label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.maanilam ? getBilingualStateName(form.maanilam, { ...profileSettings, returnOnlySecondary: true }) : ''} sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
          )}

          <TextField select fullWidth size="medium" label={`${t('country')}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={isCustomCountry ? 'Other' : form.country}
            onChange={e => {
              const val = e.target.value;
              if (val === 'Other') {
                setForm(prev => ({ ...prev, country: 'Other', countryEn: '', maanilam: '', maanilamEn: '' }));
              } else {
                setForm(prev => ({ ...prev, country: val, countryEn: '', maanilam: '', maanilamEn: '' }));
              }
            }}>
            {getCountriesForRegion().map(c => <MenuItem key={c.code} value={c.name}>{getBilingualCountryName(c.name, { ...profileSettings, returnOnlyPrimary: true })}</MenuItem>)}
            <MenuItem value="Other">Other (Custom)</MenuItem>
          </TextField>

          {isBilingual && (
            <TextField fullWidth size="medium" disabled={!isCustomCountry} label={`${t('country')}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={isCustomCountry ? (form.countryEn || '') : (form.country ? getBilingualCountryName(form.country, { ...profileSettings, returnOnlySecondary: true }) : '')}
              onChange={e => isCustomCountry ? setForm(prev => ({ ...prev, countryEn: e.target.value })) : null}
              sx={!isCustomCountry ? { '& .MuiInputBase-root': { bgcolor: 'action.hover' } } : {}}
              placeholder={t('country')} />
          )}

          <TextField fullWidth size="medium" label={t(cc.postalLabel as any, { defaultValue: cc.postalLabel })} slotProps={{ inputLabel: { shrink: true } }}
            value={form.pin} onChange={e => setForm(prev => ({ ...prev, pin: e.target.value }))} placeholder={cc.postalLabel} />
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
          <TextField fullWidth size="medium" label={t(cc.taxIdLabel as any) || cc.taxIdLabel}
            error={!!taxIdWarning} helperText={taxIdWarning || ' '}
            value={form.gstin} onChange={e => { setForm(prev => ({ ...prev, gstin: e.target.value.toUpperCase() })); if (taxIdWarning) setTaxIdWarning(''); }}
            onBlur={handleTaxIdBlur} placeholder={cc.taxIdPlaceholder} slotProps={{ inputLabel: { shrink: true }, htmlInput: { maxLength: 20 } }} />

          <TextField fullWidth size="medium" label={t('emailLabel')} slotProps={{ inputLabel: { shrink: true } }} type="email"
            value={form.email} onChange={e => setForm(prev => ({ ...prev, email: e.target.value }))} placeholder={t('emailPlaceholder')} />
          
          <TextField fullWidth size="medium" label={t('phoneLabel')} slotProps={{ inputLabel: { shrink: true } }} type="tel"
            value={form.tholaipesi} onChange={e => setForm(prev => ({ ...prev, tholaipesi: e.target.value }))} placeholder={t('phonePlaceholder')} />
        </Box>
        
      </Box>

      <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mb: 6, mt: 5, px: { xs: 2, md: 0 } }}>
        <Button variant="outlined" color="inherit" onClick={onBack} sx={{ height: 48, borderRadius: '999px', textTransform: 'none', px: 4, fontWeight: 700, fontSize: '1rem' }}>
          {t('cancelModalBtn')}
        </Button>
        <Button variant="contained" onClick={handleSave} startIcon={<FloppyDisk size={20} weight="bold" />} sx={{ height: 48, borderRadius: '999px', textTransform: 'none', px: 5, fontSize: '1rem', bgcolor: (theme) => theme.palette.mode === 'dark' ? 'white' : 'black', color: (theme) => theme.palette.mode === 'dark' ? 'black' : 'white', fontWeight: 700, boxShadow: 'none', '&:hover': { bgcolor: (theme) => theme.palette.mode === 'dark' ? '#e5e5e5' : '#333', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' } }}>
          {isEditing ? t('updateClientModalBtn') : t('saveClientModalBtn')}
        </Button>
      </Box>
    </Box>
  );
}
