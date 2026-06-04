// @ts-nocheck
import { ArrowLeft, FloppyDisk } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion } from '../Payanpadu';
import { useLanguage } from '../mozhi/LanguageContext';
import { TextField, MenuItem, Button, IconButton, Grid, Typography, Box, Paper, Stack } from '@mui/material';
import { saveClient } from '../Avanam';
import { thagaval } from './Thagaval';

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

  return (
    <Box sx={{ p: { xs: 2, md: 4 }, maxWidth: 800, mx: 'auto' }}>
      <Stack direction="row" alignItems="center" spacing={2} mb={3}>
        <IconButton onClick={onBack} sx={{ bgcolor: 'background.paper' }}>
          <ArrowLeft size={20} weight="regular" />
        </IconButton>
        <Typography variant="h5" sx={{ fontWeight: "bold" }}>
          {isEditing ? t('editClientTitle') : t('addNewClientTitle')}
        </Typography>
      </Stack>

      <Paper elevation={0} sx={{ p: { xs: 2, md: 4 }, borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
        <Grid container spacing={3}>
          <Grid size={{ xs: 12 }}>
            <TextField fullWidth size="small" label={`${t('clientBusinessName')}${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.name} onChange={e => setForm(prev => ({ ...prev, name: e.target.value }))} placeholder="e.g. Acme Corp" />
          </Grid>
          
          {profileSettings?.enableBilingual !== false && (
            <Grid size={{ xs: 12 }}>
              <TextField fullWidth size="small" label={`${t('clientBusinessName')} (${profileSettings?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.nameEn || ''} onChange={e => setForm(prev => ({ ...prev, nameEn: e.target.value }))} placeholder="e.g. Acme Corp (English)" />
            </Grid>
          )}

          <Grid size={{ xs: 12 }}>
            <TextField fullWidth size="small" label={`${t('billingAddress')}${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.mugavari} onChange={e => setForm(prev => ({ ...prev, mugavari: e.target.value }))} placeholder={t('streetAddressPlaceholder')} />
          </Grid>

          {profileSettings?.enableBilingual !== false && (
            <Grid size={{ xs: 12 }}>
              <TextField fullWidth size="small" label={`${t('billingAddress')} (${profileSettings?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.mugavariEn || ''} onChange={e => setForm(prev => ({ ...prev, mugavariEn: e.target.value }))} placeholder="Address in English" />
            </Grid>
          )}

          <Grid size={{ xs: 12, sm: profileSettings?.enableBilingual !== false ? 6 : 12 }}>
            <TextField fullWidth size="small" label={`${(t('city' as any) || 'City')}${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.oor} onChange={e => setForm(prev => ({ ...prev, oor: e.target.value }))} placeholder={t('cityPlaceholder')} />
          </Grid>

          {profileSettings?.enableBilingual !== false && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField fullWidth size="small" label={`${(t('city' as any) || 'City')} (${profileSettings?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.oorEn || ''} onChange={e => setForm(prev => ({ ...prev, oorEn: e.target.value }))} placeholder="City in English" />
            </Grid>
          )}

          <Grid size={{ xs: 12, sm: profileSettings?.enableBilingual !== false ? 6 : 12 }}>
            <TextField fullWidth size="small" label={`மாவட்டம் (District)${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.maavattam || ''} onChange={e => setForm(prev => ({ ...prev, maavattam: e.target.value }))} placeholder="மாவட்டம்" />
          </Grid>

          {profileSettings?.enableBilingual !== false && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField fullWidth size="small" label={`District (${profileSettings?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.maavattamEn || ''} onChange={e => setForm(prev => ({ ...prev, maavattamEn: e.target.value }))} placeholder="District" />
            </Grid>
          )}

          <Grid size={{ xs: 12, sm: profileSettings?.enableBilingual !== false ? 6 : 12 }}>
            {stateOptions.length > 0 ? (
              <TextField select fullWidth size="small" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.maanilam} onChange={e => setForm(prev => ({ ...prev, maanilam: e.target.value }))}>
                <MenuItem value="">{t('selectLabel')} {t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}</MenuItem>
                {stateOptions.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true })}</MenuItem>)}
              </TextField>
            ) : (
              <TextField fullWidth size="small" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.maanilam} onChange={e => setForm(prev => ({ ...prev, maanilam: e.target.value }))} placeholder={cc.stateLabel} />
            )}
          </Grid>

          {profileSettings?.enableBilingual !== false && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField fullWidth size="small" disabled label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })} (${profileSettings?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                value={form.maanilam ? getBilingualStateName(form.maanilam, { ...profileSettings, returnOnlySecondary: true }) : ''} sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
            </Grid>
          )}

          {(() => {
            const visible = getCountriesForRegion();
            const isCustomCountry = form.country === 'Other' || (form.country && !visible.some(c => c.name === form.country));
            return (
              <>
                <Grid size={{ xs: 12, sm: profileSettings?.enableBilingual !== false ? 6 : 12 }}>
                  <TextField select fullWidth size="small" label={`${t('country')}${profileSettings?.enableBilingual !== false ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                    value={isCustomCountry ? 'Other' : form.country} sx={{ mb: isCustomCountry ? 2 : 0 }}
                    onChange={e => {
                      if (e.target.value === 'Other') {
                        setForm(prev => ({ ...prev, country: 'Other', countryEn: '', maanilam: '', maanilamEn: '' }));
                      } else {
                        setForm(prev => ({ ...prev, country: e.target.value, countryEn: '', maanilam: '', maanilamEn: '' }));
                      }
                    }}>
                    {visible.map(c => <MenuItem key={c.code} value={c.name}>{getBilingualCountryName(c.name, { ...profileSettings, returnOnlyPrimary: true })}</MenuItem>)}
                    <MenuItem value="Other">Other (Custom)</MenuItem>
                  </TextField>
                  {isCustomCountry && (
                    <TextField fullWidth size="small" value={form.country === 'Other' ? '' : form.country} onChange={e => setForm(prev => ({ ...prev, country: e.target.value }))} placeholder="Enter country name" />
                  )}
                </Grid>
                {profileSettings?.enableBilingual !== false && (
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField fullWidth size="small" disabled={!isCustomCountry} label={`${t('country')} (${profileSettings?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                      value={isCustomCountry ? (form.countryEn || '') : (form.country ? getBilingualCountryName(form.country, { ...profileSettings, returnOnlySecondary: true }) : '')}
                      onChange={e => isCustomCountry ? setForm(prev => ({ ...prev, countryEn: e.target.value })) : null}
                      sx={!isCustomCountry ? { '& .MuiInputBase-root': { bgcolor: 'action.hover' } } : {}}
                      placeholder="Country in English" />
                  </Grid>
                )}
              </>
            );
          })()}

          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t(cc.postalLabel as any, { defaultValue: cc.postalLabel })} slotProps={{ inputLabel: { shrink: true } }}
              value={form.pin} onChange={e => setForm(prev => ({ ...prev, pin: e.target.value }))} placeholder={cc.postalLabel} />
          </Grid>
          
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t(cc.taxIdLabel as any) || cc.taxIdLabel}
              error={!!taxIdWarning} helperText={taxIdWarning || ' '}
              value={form.gstin} onChange={e => { setForm(prev => ({ ...prev, gstin: e.target.value.toUpperCase() })); if (taxIdWarning) setTaxIdWarning(''); }}
              onBlur={handleTaxIdBlur} placeholder={cc.taxIdPlaceholder} slotProps={{ inputLabel: { shrink: true }, htmlInput: { maxLength: 20 } }} />
          </Grid>

          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t('emailLabel')} slotProps={{ inputLabel: { shrink: true } }} type="email"
              value={form.email} onChange={e => setForm(prev => ({ ...prev, email: e.target.value }))} placeholder={t('emailPlaceholder')} />
          </Grid>
          
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t('phoneLabel')} slotProps={{ inputLabel: { shrink: true } }} type="tel"
              value={form.tholaipesi} onChange={e => setForm(prev => ({ ...prev, tholaipesi: e.target.value }))} placeholder={t('phonePlaceholder')} />
          </Grid>
        </Grid>
        
        <Box sx={{ mt: 5, display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
          <Button variant="outlined" color="inherit" onClick={onBack} sx={{ height: 42, borderRadius: '50px', textTransform: 'none', px: 4 }}>
            {t('cancelModalBtn')}
          </Button>
          <Button variant="contained" onClick={handleSave} startIcon={<FloppyDisk size={18} weight="regular" />} sx={{ height: 42, borderRadius: '50px', textTransform: 'none', px: 4, bgcolor: '#0f172a', color: 'white', '&:hover': { bgcolor: '#1e293b' } }}>
            {isEditing ? t('updateClientModalBtn') : t('saveClientModalBtn')}
          </Button>
        </Box>
      </Paper>
    </Box>
  );
}
