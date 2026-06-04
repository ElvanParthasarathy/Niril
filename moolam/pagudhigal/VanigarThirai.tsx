// @ts-nocheck
import { X } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion } from '../Payanpadu';
import { getProfile } from '../Avanam';
import { useLanguage } from '../mozhi/LanguageContext';
import { Dialog, DialogTitle, DialogContent, DialogActions, TextField, MenuItem, Button, IconButton, Grid, Typography, useMediaQuery, useTheme } from '@mui/material';

export default function VanigarThirai({ show, onClose, onSave, client, isEditing, defaultCountry, profileSettings }) {
  const { t } = useLanguage();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  // Country defaults: explicit prop (active business profile) → browser locale → 'India'.
  const fallbackCountry = defaultCountry || detectCountryFromBrowser();
  const emptyForm = { name: '', nameEn: '', mugavari: '', mugavariEn: '', oor: '', oorEn: '', maavattam: '', maavattamEn: '', pin: '', maanilam: '', maanilamEn: '', gstin: '', email: '', tholaipesi: '', country: fallbackCountry, countryEn: '', isSEZ: false };
  const [form, setForm] = useState({ ...emptyForm });
  const [taxIdWarning, setTaxIdWarning] = useState('');

  useEffect(() => {
    if (show && client) {
      setForm({
        name: client.name || '', nameEn: client.nameEn || '', mugavari: client.mugavari || '', mugavariEn: client.mugavariEn || '', oor: client.oor || '', oorEn: client.oorEn || '',
        maavattam: client.maavattam || '', maavattamEn: client.maavattamEn || '',
        pin: client.pin || '', maanilam: client.maanilam || '', maanilamEn: client.maanilamEn || '', gstin: client.gstin || '',
        email: client.email || '', tholaipesi: client.tholaipesi || '', country: client.country || fallbackCountry, countryEn: client.countryEn || '',
        isSEZ: !!client.isSEZ,
      });
    } else if (show) {
      setForm({ ...emptyForm });
    }
    setTaxIdWarning('');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [show, client]);

  if (!show) return null;

  const cc = getCountryConfig(form.country);
  const stateOptions = getStatesForCountry(form.country);

  const handleTaxIdBlur = () => {
    const result = validateTaxId(form.country, form.gstin);
    setTaxIdWarning(result.ok ? '' : result.message);
  };

  const handleSave = () => {
    if (!form.name.trim()) return;
    onSave(form);
  };

  return (
    <Dialog fullScreen={isMobile} open={show} onClose={onClose} maxWidth="sm" fullWidth slotProps={{ paper: { sx: { borderRadius: isMobile ? 0 : 3 } } }}>
      <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', pb: 2 }}>
        <Typography variant="h6" sx={{ fontWeight: "bold" }}>
          {isEditing ? t('editClientTitle') : t('addNewClientTitle')}
        </Typography>
        <IconButton onClick={onClose} size="small"><X size={20} weight="regular" /></IconButton>
      </DialogTitle>
      
      <DialogContent dividers>
        <Grid container spacing={3} sx={{ mt: 0.5 }}>
          <Grid size={{ xs: 12 }}>
            <TextField fullWidth size="small" label={`${t('clientBusinessName')}${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
              value={form.name} onChange={e => setForm(prev => ({ ...prev, name: e.target.value }))} placeholder="e.g. Acme Corp" />
          </Grid>
          
          {profileSettings?.bilingual && (
            <Grid size={{ xs: 12 }}>
              <TextField fullWidth size="small" label={`${t('clientBusinessName')} (${profileSettings?.secondaryDataLanguage || 'English'})`} InputLabelProps={{ shrink: true }}
                value={form.nameEn || ''} onChange={e => setForm(prev => ({ ...prev, nameEn: e.target.value }))} placeholder="e.g. Acme Corp (English)" />
            </Grid>
          )}

          <Grid size={{ xs: 12 }}>
            <TextField fullWidth size="small" label={`${t('billingAddress')}${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
              value={form.mugavari} onChange={e => setForm(prev => ({ ...prev, mugavari: e.target.value }))} placeholder={t('streetAddressPlaceholder')} />
          </Grid>

          {profileSettings?.bilingual && (
            <Grid size={{ xs: 12 }}>
              <TextField fullWidth size="small" label={`${t('billingAddress')} (${profileSettings?.secondaryDataLanguage || 'English'})`} InputLabelProps={{ shrink: true }}
                value={form.mugavariEn || ''} onChange={e => setForm(prev => ({ ...prev, mugavariEn: e.target.value }))} placeholder="Address in English" />
            </Grid>
          )}

          <Grid size={{ xs: 12, sm: profileSettings?.bilingual ? 6 : 12 }}>
            <TextField fullWidth size="small" label={`${t('city')}${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
              value={form.oor} onChange={e => setForm(prev => ({ ...prev, oor: e.target.value }))} placeholder={t('cityPlaceholder')} />
          </Grid>

          {profileSettings?.bilingual && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField fullWidth size="small" label={`${t('city')} (${profileSettings?.secondaryDataLanguage || 'English'})`} InputLabelProps={{ shrink: true }}
                value={form.oorEn || ''} onChange={e => setForm(prev => ({ ...prev, oorEn: e.target.value }))} placeholder="City in English" />
            </Grid>
          )}

          <Grid size={{ xs: 12, sm: profileSettings?.bilingual ? 6 : 12 }}>
            <TextField fullWidth size="small" label={`மாவட்டம் (District)${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
              value={form.maavattam || ''} onChange={e => setForm(prev => ({ ...prev, maavattam: e.target.value }))} placeholder="மாவட்டம்" />
          </Grid>

          {profileSettings?.bilingual && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField fullWidth size="small" label={`District (${profileSettings?.secondaryDataLanguage || 'English'})`} InputLabelProps={{ shrink: true }}
                value={form.maavattamEn || ''} onChange={e => setForm(prev => ({ ...prev, maavattamEn: e.target.value }))} placeholder="District" />
            </Grid>
          )}

          <Grid size={{ xs: 12, sm: profileSettings?.bilingual ? 6 : 12 }}>
            {stateOptions.length > 0 ? (
              <TextField select fullWidth size="small" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
                value={form.maanilam} onChange={e => setForm(prev => ({ ...prev, maanilam: e.target.value }))}>
                <MenuItem value="">{t('selectLabel')} {t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}</MenuItem>
                {stateOptions.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { ...profileSettings, returnOnlyPrimary: true })}</MenuItem>)}
              </TextField>
            ) : (
              <TextField fullWidth size="small" label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })}${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
                value={form.maanilam} onChange={e => setForm(prev => ({ ...prev, maanilam: e.target.value }))} placeholder={cc.stateLabel} />
            )}
          </Grid>

          {profileSettings?.bilingual && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField fullWidth size="small" disabled label={`${t(cc.stateLabel as any, { defaultValue: cc.stateLabel })} (${profileSettings?.secondaryDataLanguage || 'English'})`} InputLabelProps={{ shrink: true }}
                value={form.maanilam ? getBilingualStateName(form.maanilam, { ...profileSettings, returnOnlySecondary: true }) : ''} sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
            </Grid>
          )}

          {(() => {
            const visible = getCountriesForRegion();
            const isCustomCountry = form.country === 'Other' || (form.country && !visible.some(c => c.name === form.country));
            return (
              <>
                <Grid size={{ xs: 12, sm: profileSettings?.bilingual ? 6 : 12 }}>
                  <TextField select fullWidth size="small" label={`${t('country')}${profileSettings?.bilingual ? ` (${profileSettings?.primaryDataLanguage || 'Tamil'})` : ''}`} InputLabelProps={{ shrink: true }}
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
                {profileSettings?.bilingual && (
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField fullWidth size="small" disabled={!isCustomCountry} label={`${t('country')} (${profileSettings?.secondaryDataLanguage || 'English'})`} InputLabelProps={{ shrink: true }}
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
            <TextField fullWidth size="small" label={t(cc.postalLabel as any, { defaultValue: cc.postalLabel })} InputLabelProps={{ shrink: true }}
              value={form.pin} onChange={e => setForm(prev => ({ ...prev, pin: e.target.value }))} placeholder={cc.postalLabel} />
          </Grid>
          
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t(cc.taxIdLabel as any, { defaultValue: cc.taxIdLabel })} InputLabelProps={{ shrink: true }}
              error={!!taxIdWarning} helperText={taxIdWarning || ' '}
              value={form.gstin} onChange={e => { setForm(prev => ({ ...prev, gstin: e.target.value.toUpperCase() })); if (taxIdWarning) setTaxIdWarning(''); }}
              onBlur={handleTaxIdBlur} placeholder={cc.taxIdPlaceholder} slotProps={{ htmlInput: { maxLength: 20 } }} />
          </Grid>

          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t('emailLabel')} InputLabelProps={{ shrink: true }} type="email"
              value={form.email} onChange={e => setForm(prev => ({ ...prev, email: e.target.value }))} placeholder={t('emailPlaceholder')} />
          </Grid>
          
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField fullWidth size="small" label={t('phoneLabel')} InputLabelProps={{ shrink: true }} type="tel"
              value={form.tholaipesi} onChange={e => setForm(prev => ({ ...prev, tholaipesi: e.target.value }))} placeholder={t('phonePlaceholder')} />
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions sx={{ p: 2, px: 3 }}>
        <Button variant="outlined" color="inherit" onClick={onClose} sx={{ height: 42, borderRadius: '50px', textTransform: 'none', px: 3, whiteSpace: 'nowrap' }}>
          {t('cancelModalBtn')}
        </Button>
        <Button variant="contained" onClick={handleSave} sx={{ height: 42, borderRadius: '50px', textTransform: 'none', px: 3, bgcolor: '#0f172a', color: 'white', '&:hover': { bgcolor: '#1e293b' }, whiteSpace: 'nowrap' }}>
          {isEditing ? t('updateClientModalBtn') : t('saveClientModalBtn')}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
