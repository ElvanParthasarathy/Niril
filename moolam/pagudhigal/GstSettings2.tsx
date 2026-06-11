// @ts-nocheck
import React, { useState, useRef, useEffect } from 'react';
import { Table as TableIcon } from '@phosphor-icons/react';
import { 
  Box, Paper, TextField, Button, Select, MenuItem, Typography, IconButton, Grid, 
  InputAdornment, FormControl, InputLabel, Dialog, DialogTitle, DialogContent, DialogActions
} from '@mui/material';
import Save from '@mui/icons-material/Save';
import Delete from '@mui/icons-material/Delete';
import Edit from '@mui/icons-material/Edit';
import Image from '@mui/icons-material/Image';
import Create from '@mui/icons-material/Create';
import Add from '@mui/icons-material/Add';
import Business from '@mui/icons-material/Business';
import Close from '@mui/icons-material/Close';

import { useLanguage } from '../mozhi/LanguageContext';
import { saveProfile, saveBusinessProfile, deleteBusinessProfile, getInvoiceDisplayOptions, saveInvoiceDisplayOptions } from '../Avanam';
import { SettingsSection, SettingsRow } from './ElvanSettingsSection';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion } from '../Payanpadu';
import { thagaval } from './Thagaval';

export default function GstSettings({ 
  profile, setProfile, onSaved, businessProfiles, loadBusinessProfiles, saving, setSaving 
}) {
  const { language, t } = useLanguage();
  
  const [showNewProfileModal, setShowNewProfileModal] = useState(false);
  const [newProfileData, setNewProfileData] = useState({ niruvanathinPeyar: '', gstin: '', mugavari: '' });
  const [creatingProfile, setCreatingProfile] = useState(false);
  const [isEditingCompany, setIsEditingCompany] = useState(false);
  const [showMobileField, setShowMobileField] = useState(false);
  const [taxIdWarning, setTaxIdWarning] = useState('');

  const [invoiceTemplate, setInvoiceTemplate] = useState<any>({});
  useEffect(() => {
    const savedLocal = localStorage.getItem('elvanniril_invoiceOptions');
    const local = savedLocal ? JSON.parse(savedLocal) : {};
    getInvoiceDisplayOptions().then(serverOpts => {
      setInvoiceTemplate({ ...local, ...(serverOpts || {}) });
    });
  }, []);

  const handleTemplateChange = (key, val) => {
    const newOpts = { ...invoiceTemplate, [key]: val };
    setInvoiceTemplate(newOpts);
    localStorage.setItem('elvanniril_invoiceOptions', JSON.stringify(newOpts));
    saveInvoiceDisplayOptions(newOpts);
  };

  const logoInputRef = useRef(null);
  const wideLogoInputRef = useRef(null);
  const sigInputRef = useRef(null);
  const companyFormRef = useRef(null);

  const visibleCountries = getCountriesForRegion();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfile(prev => ({ ...prev, [name]: value }));
  };

  const handleLoadProfile = async (bp) => {
    if (profile.niruvanathinPeyar?.trim()) {
      const existing = businessProfiles.find(p => p.niruvanathinPeyar.trim().toLowerCase() === profile.niruvanathinPeyar.trim().toLowerCase());
      await saveBusinessProfile({ ...profile, id: existing?.id || undefined });
    }
    const loaded = { ...bp };
    delete loaded.id;
    setProfile(loaded);
    await saveProfile(loaded);
    if (onSaved) onSaved(loaded);
    thagaval(`Switched to ${bp.niruvanathinPeyar}`, 'success');
  };

  const handleDeleteProfile = async (id) => {
    if (confirm('Delete this saved business profile?')) {
      await deleteBusinessProfile(id);
      thagaval('Profile deleted', 'success');
      loadBusinessProfiles();
    }
  };

  const handleCreateNewProfile = async () => {
    if (!newProfileData.niruvanathinPeyar.trim()) { thagaval('Business name required', 'warning'); return; }
    setCreatingProfile(true);
    try {
      const freshProfile = {
        niruvanathinPeyar: newProfileData.niruvanathinPeyar,
        niruvanathinPeyarEn: '', mugavari: newProfileData.mugavari, mugavariEn: '', oor: '', oorEn: '', maavattam: '', maavattamEn: '', maanilam: '', maanilamEn: '', pin: '', country: detectCountryFromBrowser(),
        gstin: newProfileData.gstin, pan: '', email: '', tholaipesi: '', mobileNumber: '', vangiPeyar: '', kanakkuEn: '', ifsc: '', swift: '',
        logo: '', wideLogo: '', logoHeight: 48, signature: '', upiId: '', googleClientId: '', googleDriveFolder: 'GST Billing Invoices',
      };
      
      const saved = await saveBusinessProfile(freshProfile);
      
      if (profile.niruvanathinPeyar?.trim()) {
        const existing = businessProfiles.find(p => p.niruvanathinPeyar.trim().toLowerCase() === profile.niruvanathinPeyar.trim().toLowerCase());
        await saveBusinessProfile({ ...profile, id: existing?.id || undefined });
      }
      
      const loaded = { ...saved };
      delete loaded.id;
      setProfile(loaded);
      await saveProfile(loaded);
      if (onSaved) onSaved(loaded);
      
      await loadBusinessProfiles();
      setShowNewProfileModal(false);
      setNewProfileData({ niruvanathinPeyar: '', gstin: '', mugavari: '' });
      thagaval(`Created and switched to ${saved.niruvanathinPeyar}`, 'success');
    } catch (err) {
      thagaval('Failed to create profile', 'error');
    } finally {
      setCreatingProfile(false);
    }
  };

  const handleTaxIdBlur = () => {
    const result = validateTaxId(profile.country, profile.gstin);
    setTaxIdWarning(result.ok ? '' : result.message);
  };

  const handleImageUpload = (field, e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 500 * 1024) { thagaval('Image must be under 500KB', 'warning'); return; }
    const reader = new FileReader();
    reader.onload = (ev) => setProfile(prev => ({ ...prev, [field]: ev.target.result }));
    reader.readAsDataURL(file);
  };

  const removeImage = (field) => setProfile(prev => ({ ...prev, [field]: '' }));

  const handleSave = async (e) => {
    if (e) e.preventDefault();
    try {
      setSaving(true);
      await saveProfile(profile);
      if (onSaved) onSaved(profile);
      setIsEditingCompany(false);
      thagaval('Profile saved!', 'success');
    } catch { thagaval('Failed to save profile', 'error'); }
    finally { setSaving(false); }
  };

  const handleCancelEditCompany = async () => {
    setIsEditingCompany(false);
    setShowMobileField(false);
  };

  return (
    <>
      {/* Top Profile Switcher */}
      <Paper className="s2-group" elevation={2} sx={{ p: { xs: 2, md: 3 }, mb: { xs: 2, md: 3 }, borderRadius: { xs: 0, sm: 2 }, borderX: { xs: 0, sm: undefined }, display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
        <Business sx={{ fontSize: 24, color: 'primary.main' }} />
        <Box sx={{ flexGrow: 1, minWidth: 200 }}>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5, fontWeight: 600 }}>{language === 'ta' ? 'வணிக சுயவிவரம் (Business Profile)' : 'Active Business Profile'}</Typography>
          <Select 
            fullWidth 
            size="small" 
            value={businessProfiles.find(bp => bp.niruvanathinPeyar?.trim().toLowerCase() === profile.niruvanathinPeyar?.trim().toLowerCase())?.id || ''} 
            onChange={(e) => {
              const bp = businessProfiles.find(p => p.id === e.target.value);
              if (bp) handleLoadProfile(bp);
            }}
            displayEmpty
            MenuProps={{ disableScrollLock: true }}
          >
            <MenuItem value="" disabled><em>{profile.niruvanathinPeyar || 'Select Profile'}</em></MenuItem>
            {businessProfiles.map(bp => (
              <MenuItem key={bp.id} value={bp.id}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', width: '100%', alignItems: 'center' }}>
                  {bp.niruvanathinPeyar}
                  <IconButton size="small" color="error" onClick={(ev) => { ev.stopPropagation(); handleDeleteProfile(bp.id); }} onPointerDown={(ev) => ev.stopPropagation()}>
                    <Delete sx={{ fontSize: 16 }} />
                  </IconButton>
                </Box>
              </MenuItem>
            ))}
          </Select>
        </Box>
        <Button variant="contained" onClick={() => setShowNewProfileModal(true)} startIcon={<Add />}>
          {language === 'ta' ? 'புதிய சுயவிவரம்' : 'Add New'}
        </Button>
      </Paper>

      <SettingsSection component="form" onSubmit={handleSave} ref={companyFormRef}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="h6" style={{ fontWeight: 600 }} sx={{ m: 0 }}>
            {t('companyDetailsTitle')}
          </Typography>
          {!isEditingCompany ? (
            <Button variant="outlined" size="small" onClick={() => setIsEditingCompany(true)} startIcon={<Edit sx={{ fontSize: 16 }} />}>
              Edit Details
            </Button>
          ) : (
            <Box sx={{ display: 'flex', gap: 1 }}>
              <Button variant="outlined" size="small" color="inherit" onClick={handleCancelEditCompany}>
                Cancel
              </Button>
              <Button variant="contained" size="small" color="primary" onClick={handleSave} startIcon={<Save sx={{ fontSize: 16 }} />}>
                Save Details
              </Button>
            </Box>
          )}
        </Box>
        {(() => {
          const cc = getCountryConfig(profile.country);
          return (
            <Grid container spacing={3}>
              <Grid item xs={12} sm={profile.enableBilingual !== false ? 6 : 12}>
                <TextField disabled={!isEditingCompany} required fullWidth size="small" label={`${t('businessNameLabel')} (${profile.primaryDataLanguage || 'Tamil'})`} name="niruvanathinPeyar" value={profile.niruvanathinPeyar} onChange={handleChange} />
              </Grid>
              {profile.enableBilingual !== false && (
                <Grid item xs={12} sm={6}>
                  <TextField disabled={!isEditingCompany} fullWidth size="small" label={`Business Name in ${profile.secondaryDataLanguage || 'English'}`} name="niruvanathinPeyarEn" value={profile.niruvanathinPeyarEn || ''} onChange={handleChange} />
                </Grid>
              )}

              <Grid item xs={12} sm={12}>
                <TextField disabled={!isEditingCompany} fullWidth size="small" label={language === 'ta' ? 'குறுகிய வணிக பெயர் (பில் எண்ணுக்கு)' : 'Short Business Name (for Bill No)'} name="shortBusinessName" value={profile.shortBusinessName || ''} onChange={handleChange} placeholder="e.g. SJS" helperText={language === 'ta' ? 'இது தானியங்கி பில் எண்ணில் முன்னொட்டாக பயன்படுத்தப்படும் (உதாரணமாக SJS/2026-27/0001).' : 'Used as the default prefix for your invoice numbers (e.g. SJS/2026-27/0001).'} />
              </Grid>

              <Grid item xs={12} sm={profile.enableBilingual !== false ? 6 : 12}>
                <TextField disabled={!isEditingCompany} fullWidth multiline rows={2} size="small" label={`${t('mugavariLabel')} (${profile.primaryDataLanguage || 'Tamil'})`} name="mugavari" value={profile.mugavari} onChange={handleChange} />
              </Grid>
              {profile.enableBilingual !== false && (
                <Grid item xs={12} sm={6}>
                  <TextField disabled={!isEditingCompany} fullWidth multiline rows={2} size="small" label={`Address in ${profile.secondaryDataLanguage || 'English'}`} name="mugavariEn" value={profile.mugavariEn || ''} onChange={handleChange} />
                </Grid>
              )}

              <Grid item xs={12} sm={profile.enableBilingual !== false ? 6 : 12}>
                <TextField disabled={!isEditingCompany} fullWidth size="small" label={`${t('oorLabel')} (${profile.primaryDataLanguage || 'Tamil'})`} name="oor" value={profile.oor || ''} onChange={handleChange} placeholder={t('e.g. Mumbai' as any)} />
              </Grid>
              {profile.enableBilingual !== false && (
                <Grid item xs={12} sm={6}>
                  <TextField disabled={!isEditingCompany} fullWidth size="small" label={`City in ${profile.secondaryDataLanguage || 'English'}`} name="oorEn" value={profile.oorEn || ''} onChange={handleChange} />
                </Grid>
              )}

              <Grid item xs={12} sm={profile.enableBilingual !== false ? 6 : 12}>
                <TextField disabled={!isEditingCompany} fullWidth size="small" label={`மாவட்டம் (District) (${profile.primaryDataLanguage || 'Tamil'})`} name="maavattam" value={profile.maavattam || ''} onChange={handleChange} placeholder={`மாவட்டம்`} />
              </Grid>
              {profile.enableBilingual !== false && (
                <Grid item xs={12} sm={6}>
                  <TextField disabled={!isEditingCompany} fullWidth size="small" label={`District in ${profile.secondaryDataLanguage || 'English'}`} name="maavattamEn" value={profile.maavattamEn || ''} onChange={handleChange} placeholder={`District`} />
                </Grid>
              )}

              <Grid item xs={12} sm={profile.enableBilingual !== false ? 6 : 12}>
                {(() => {
                  const stateOpts = getStatesForCountry(profile.country || 'India');
                  return stateOpts.length > 0 ? (
                    <FormControl fullWidth size="small" disabled={!isEditingCompany}>
                      <InputLabel>{t(cc.stateLabel as any)} ({profile.primaryDataLanguage || 'Tamil'})</InputLabel>
                      <Select MenuProps={{ disableScrollLock: true }} name="maanilam" value={profile.maanilam} onChange={handleChange} label={`${t(cc.stateLabel as any)} (${profile.primaryDataLanguage || 'Tamil'})`}>
                        <MenuItem value="">{t('Select maanilam' as any)}</MenuItem>
                        {stateOpts.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { ...profile, returnOnlyPrimary: true })}</MenuItem>)}
                      </Select>
                    </FormControl>
                  ) : (
                    <TextField disabled={!isEditingCompany} fullWidth size="small" label={`${t(cc.stateLabel as any)} (${profile.primaryDataLanguage || 'Tamil'})`} name="maanilam" value={profile.maanilam || ''} onChange={handleChange} placeholder={cc.stateLabel} />
                  );
                })()}
              </Grid>
              {profile.enableBilingual !== false && (
                <Grid item xs={12} sm={6}>
                  <TextField fullWidth size="small" disabled={true} 
                    label={`${t(cc.stateLabel as any)} (${profile.secondaryDataLanguage || 'English'})`} 
                    value={profile.maanilam ? getBilingualStateName(profile.maanilam, { ...profile, returnOnlySecondary: true }) : ''} 
                    sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
                </Grid>
              )}

              <Grid item xs={12} sm={profile.enableBilingual !== false ? 6 : 12}>
                {(() => {
                  const isCustomCountry = profile.country === 'Other' || (profile.country && !visibleCountries.some(c => c.name === profile.country));
                  return (
                    <Box>
                      <FormControl fullWidth size="small" disabled={!isEditingCompany} sx={{ mb: isCustomCountry ? 2 : 0 }}>
                        <InputLabel>{t('countryLabel')} ({profile.primaryDataLanguage || 'Tamil'})</InputLabel>
                        <Select MenuProps={{ disableScrollLock: true }} name="country" 
                          value={isCustomCountry ? 'Other' : (profile.country || 'India')} 
                          onChange={(e) => {
                            if (e.target.value === 'Other') {
                              handleChange({ target: { name: 'country', value: 'Other' } } as any);
                              handleChange({ target: { name: 'countryEn', value: '' } } as any);
                            } else {
                              handleChange(e);
                              handleChange({ target: { name: 'countryEn', value: '' } } as any);
                            }
                          }} 
                          label={`${t('countryLabel')} (${profile.primaryDataLanguage || 'Tamil'})`}>
                          {visibleCountries.map(c => <MenuItem key={c.code} value={c.name}>{getBilingualCountryName(c.name, { ...profile, returnOnlyPrimary: true })}</MenuItem>)}
                        </Select>
                      </FormControl>
                      {isCustomCountry && (
                        <TextField fullWidth size="small" 
                          label={`Custom Country (${profile.primaryDataLanguage || 'Tamil'})`}
                          name="country" 
                          value={profile.country === 'Other' ? '' : profile.country} 
                          onChange={handleChange} 
                          placeholder="Enter country name" 
                          disabled={!isEditingCompany} />
                      )}
                    </Box>
                  );
                })()}
              </Grid>
              {profile.enableBilingual !== false && (
                <Grid item xs={12} sm={6}>
                  {(() => {
                    const isCustomCountry = profile.country === 'Other' || (profile.country && !visibleCountries.some(c => c.name === profile.country));
                    return (
                      <Box>
                        {isCustomCountry && <Box sx={{ height: 40, mb: 2 }} />}
                        <TextField fullWidth size="small" disabled={!isCustomCountry || !isEditingCompany} 
                          name={isCustomCountry ? "countryEn" : undefined}
                          onChange={isCustomCountry ? handleChange : undefined}
                          label={`${t('countryLabel')} (${profile.secondaryDataLanguage || 'English'})`} 
                          value={isCustomCountry ? (profile.countryEn || '') : getBilingualCountryName(profile.country || 'India', { ...profile, returnOnlySecondary: true })} 
                          sx={!isCustomCountry ? { '& .MuiInputBase-root': { bgcolor: 'action.hover' } } : {}} />
                      </Box>
                    );
                  })()}
                </Grid>
              )}

              <Grid item xs={12} sm={6}>
                <TextField disabled={!isEditingCompany} fullWidth size="small" label={t('tholaipesiLabel')} name="tholaipesi" value={profile.tholaipesi} onChange={handleChange} />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField disabled={!isEditingCompany} fullWidth size="small" label={t('email') || 'Email'} name="email" value={profile.email || ''} onChange={handleChange} />
              </Grid>

              {!showMobileField && !profile.mobileNumber ? (
                isEditingCompany ? (
                  <Grid item xs={12} sm={6} sx={{ display: 'flex', alignItems: 'center' }}>
                    <Button size="small" variant="text" onClick={() => setShowMobileField(true)} startIcon={<Add sx={{ fontSize: 16 }} />} sx={{ color: 'text.secondary', textTransform: 'none' }}>
                      {language === 'ta' ? 'மாற்று கைபேசி எண் சேர்க்க' : 'Add Alternate Mobile'}
                    </Button>
                  </Grid>
                ) : null
              ) : (
                <Grid item xs={12} sm={6}>
                  <TextField 
                    disabled={!isEditingCompany} 
                    fullWidth 
                    size="small" 
                    label={t('mobileLabel')} 
                    name="mobileNumber" 
                    value={profile.mobileNumber || ''} 
                    onChange={handleChange} 
                    InputProps={{
                        endAdornment: isEditingCompany ? (
                          <InputAdornment position="end">
                            <IconButton 
                              size="small" 
                              onClick={() => {
                                setProfile(prev => ({ ...prev, mobileNumber: '' }));
                                setShowMobileField(false);
                              }}
                              edge="end"
                            >
                              <Close sx={{ fontSize: 16 }} />
                            </IconButton>
                          </InputAdornment>
                        ) : null
                    }}
                  />
                </Grid>
              )}

              <Grid item xs={12} sm={6}>
                <TextField 
                  disabled={!isEditingCompany} 
                  fullWidth 
                  size="small" 
                  label={cc.taxIdLabel || 'GSTIN / Tax ID'} 
                  name="gstin" 
                  value={profile.gstin || ''} 
                  onChange={handleChange} 
                  onBlur={handleTaxIdBlur} 
                  error={!!taxIdWarning} 
                  helperText={taxIdWarning} 
                />
              </Grid>
            </Grid>
          );
        })()}

        {/* Logo & Signature */}
        <Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 4, mb: 2 }}>
          {t('brandingTitle')}
        </Typography>
        <Grid container spacing={3}>
          <Grid item xs={12} sm={4}>
            <Typography variant="subtitle2" gutterBottom>{t('businessLogo')}</Typography>
            <Paper className="s2-group" variant="outlined" sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, borderStyle: 'dashed', height: '100%' }}>
              {profile.logo ? (
                <>
                  <Box sx={{ position: 'relative' }}>
                    <img src={profile.logo} alt="Logo" style={{ maxHeight: '100px', maxWidth: '180px', objectFit: 'contain' }} />
                    <IconButton size="small" color="error" onClick={() => removeImage('logo')} sx={{ position: 'absolute', top: -10, right: -10, bgcolor: 'background.paper', '&:hover': { bgcolor: 'error.light' } }}>
                      <Delete sx={{ fontSize: 14 }} />
                    </IconButton>
                  </Box>

                  <Button size="small" variant="outlined" onClick={() => logoInputRef.current?.click()}>Change Logo</Button>
                </>
              ) : (
                <Button variant="outlined" onClick={() => logoInputRef.current?.click()} startIcon={<Image sx={{ fontSize: 20 }} />} sx={{ flexDirection: 'column', py: 3, gap: 1, height: '100%', width: '100%' }}>
                  {t('uploadLogo')}
                  <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>{t('logoHint')}</Typography>
                </Button>
              )}
              <input ref={logoInputRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={(e) => handleImageUpload('logo', e)} />
            </Paper>
          </Grid>

          <Grid item xs={12} sm={4}>
            <Typography variant="subtitle2" gutterBottom>Vertical / Wide Logo</Typography>
            <Paper className="s2-group" variant="outlined" sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, borderStyle: 'dashed', height: '100%' }}>
              {profile.wideLogo ? (
                <>
                  <Box sx={{ position: 'relative', width: '100%', display: 'flex', justifyContent: 'center' }}>
                    <img src={profile.wideLogo} alt="Wide Logo" style={{ height: '100px', width: '100%', objectFit: 'contain' }} />
                    <IconButton size="small" color="error" onClick={() => removeImage('wideLogo')} sx={{ position: 'absolute', top: -10, right: -10, bgcolor: 'background.paper', '&:hover': { bgcolor: 'error.light' } }}>
                      <Delete sx={{ fontSize: 14 }} />
                    </IconButton>
                  </Box>

                  <Button size="small" variant="outlined" sx={{ mt: 1 }} onClick={() => wideLogoInputRef.current?.click()}>Change Logo</Button>
                </>
              ) : (
                <Button variant="outlined" onClick={() => wideLogoInputRef.current?.click()} startIcon={<Image sx={{ fontSize: 20 }} />} sx={{ flexDirection: 'column', py: 3, gap: 1, height: '100%', width: '100%' }}>
                  Upload Wide Logo
                  <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>Replaces company name in header</Typography>
                </Button>
              )}
              <input ref={wideLogoInputRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={(e) => handleImageUpload('wideLogo', e)} />
            </Paper>
          </Grid>

          <Grid item xs={12} sm={4}>
            <Typography variant="subtitle2" gutterBottom>{t('signature')}</Typography>
            <Paper className="s2-group" variant="outlined" sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, borderStyle: 'dashed', height: '100%' }}>
              {profile.signature ? (
                <>
                  <Box sx={{ position: 'relative' }}>
                    <img src={profile.signature} alt="Signature" style={{ maxHeight: '100px', maxWidth: '200px', objectFit: 'contain' }} />
                    <IconButton size="small" color="error" onClick={() => removeImage('signature')} sx={{ position: 'absolute', top: -10, right: -10, bgcolor: 'background.paper', '&:hover': { bgcolor: 'error.light' } }}>
                      <Delete sx={{ fontSize: 14 }} />
                    </IconButton>
                  </Box>
                </>
              ) : (
                <Button variant="outlined" onClick={() => sigInputRef.current?.click()} startIcon={<Create sx={{ fontSize: 20 }} />} sx={{ flexDirection: 'column', py: 3, gap: 1, height: '100%', width: '100%' }}>
                  {t('uploadSignature')}
                  <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>{t('sigHint')}</Typography>
                </Button>
              )}
              <input ref={sigInputRef} type="file" accept="image/*" style={{ display: 'none' }} onChange={(e) => handleImageUpload('signature', e)} />
            </Paper>
            <TextField fullWidth size="small" sx={{ mt: 2 }} label={language === 'ta' ? 'அங்கீகரிக்கப்பட்ட கையொப்பத்தின் பெயர்' : 'Authorized Signatory Name'} name="authorizedSignatoryName" value={profile.authorizedSignatoryName || ''} onChange={handleChange} placeholder="e.g. V.R.M. Elvan" />
          </Grid>
        </Grid>

        <Box sx={{ mt: 4, display: 'flex', justifyContent: 'flex-end' }}>
          <Button type="submit" variant="contained" color="primary" disabled={saving} startIcon={<Save sx={{ fontSize: 18 }} />}>
            {saving ? (language === 'ta' ? 'சேமிக்கப்படுகிறது...' : 'Saving...') : (language === 'ta' ? 'மாற்றங்களை சேமி' : 'Save Profile')}
          </Button>
        </Box>
      </Paper>

      {/* Data Language Settings */}
      <SettingsSection>
        <Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 0, mb: 0.5 }}>
          {language === 'ta' ? 'தரவு உள்ளீடு மொழிகள்' : 'Data Entry Languages'}
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          {language === 'ta' ? 'பட்டியல் உருவாக்கத்தில் பயன்படுத்தப்படும் மொழிகள்' : 'Languages used for billing and data entry'}
        </Typography>

        <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, display: 'block' }}>{language === 'ta' ? 'முதன்மை மொழி' : 'Primary Language'}</Typography>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 3 }}>
          {['Tamil', 'English'].map(l => (
            <Box key={l} onClick={async () => {
                const updated = { ...profile, primaryDataLanguage: l };
                setProfile(updated);
                await saveProfile(updated);
                if (onSaved) onSaved(updated);
                thagaval(language === 'ta' ? 'அமைப்புகள் சேமிக்கப்பட்டன' : 'Language settings saved!', 'success');
              }}
              sx={{
                px: 2, py: 1, borderRadius: 2, fontSize: '0.9rem', cursor: 'pointer',
                bgcolor: (profile.primaryDataLanguage || 'Tamil') === l ? '#6366f1' : 'action.hover',
                color: (profile.primaryDataLanguage || 'Tamil') === l ? '#fff' : 'text.primary',
                fontWeight: (profile.primaryDataLanguage || 'Tamil') === l ? 700 : 500,
                '&:hover': { bgcolor: (profile.primaryDataLanguage || 'Tamil') === l ? '#4f46e5' : 'action.selected' },
                transition: 'all 0.15s'
              }}>{l}</Box>
          ))}
        </Box>

        <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, display: 'block' }}>{language === 'ta' ? 'இரண்டாம் மொழி' : 'Secondary Language'}</Typography>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 3 }}>
          {['Tamil', 'English'].map(l => (
            <Box key={l} onClick={async () => {
                const updated = { ...profile, secondaryDataLanguage: l };
                setProfile(updated);
                await saveProfile(updated);
                if (onSaved) onSaved(updated);
                thagaval(language === 'ta' ? 'அமைப்புகள் சேமிக்கப்பட்டன' : 'Language settings saved!', 'success');
              }}
              sx={{
                px: 2, py: 1, borderRadius: 2, fontSize: '0.9rem', cursor: 'pointer',
                bgcolor: (profile.secondaryDataLanguage || 'English') === l ? '#6366f1' : 'action.hover',
                color: (profile.secondaryDataLanguage || 'English') === l ? '#fff' : 'text.primary',
                fontWeight: (profile.secondaryDataLanguage || 'English') === l ? 700 : 500,
                '&:hover': { bgcolor: (profile.secondaryDataLanguage || 'English') === l ? '#4f46e5' : 'action.selected' },
                transition: 'all 0.15s'
              }}>{l}</Box>
          ))}
        </Box>

        <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, display: 'block' }}>{language === 'ta' ? 'இருமொழிப் பதிவு' : 'Enable Bilingual Bills'}</Typography>
        <Box
          onClick={async () => {
             const updated = { ...profile, enableBilingual: profile.enableBilingual === false ? true : false };
             setProfile(updated);
             await saveProfile(updated);
             if (onSaved) onSaved(updated);
             thagaval(language === 'ta' ? 'அமைப்புகள் சேமிக்கப்பட்டன' : 'Language settings saved!', 'success');
          }}
          sx={{
            px: 2, py: 1.5, borderRadius: 2, fontSize: '0.95rem', cursor: 'pointer',
            bgcolor: profile.enableBilingual !== false ? '#10b981' : 'action.hover',
            color: profile.enableBilingual !== false ? '#fff' : 'text.primary',
            fontWeight: profile.enableBilingual !== false ? 700 : 500,
            textAlign: 'center',
            transition: 'all 0.15s',
            width: 'fit-content'
          }}>
          {profile.enableBilingual !== false ? 'ON (Bilingual Active)' : 'OFF (Single Language)'}
        </Box>
      </Paper>

      {/* ---- Bank Details ---- */}
      <SettingsSection>
        <Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ m: 0 }}>
          {t('paymentAccountsTitle')}
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5, mb: 3 }}>
          {language === 'ta' ? 'பில்களில் காட்டப்படும் வங்கி விவரங்கள்.' : 'Bank details shown on your invoices.'}
        </Typography>
        <Grid container spacing={3}>
          <Grid item xs={12} sm={6}>
            <TextField fullWidth size="small" label={language === 'ta' ? 'வங்கி பெயர் (தமிழ்)' : 'Bank Name (Tamil)'} name="vangiPeyar" value={profile.vangiPeyar || ''} onChange={handleChange} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField fullWidth size="small" label={language === 'ta' ? 'வங்கி பெயர் (ஆங்கிலம்)' : 'Bank Name (English)'} name="vangiPeyarEn" value={profile.vangiPeyarEn || ''} onChange={handleChange} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField fullWidth size="small" label={language === 'ta' ? 'கிளை பெயர் (தமிழ்)' : 'Branch Name (Tamil)'} name="bankBranch" value={profile.bankBranch || ''} onChange={handleChange} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField fullWidth size="small" label={language === 'ta' ? 'கிளை பெயர் (ஆங்கிலம்)' : 'Branch Name (English)'} name="bankBranchEn" value={profile.bankBranchEn || ''} onChange={handleChange} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField fullWidth size="small" label={language === 'ta' ? 'கணக்கு எண்' : 'Account Number'} name="kanakkuEn" value={profile.kanakkuEn || ''} onChange={handleChange} />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField fullWidth size="small" label="IFSC Code" name="ifsc" value={profile.ifsc || ''} onChange={handleChange} />
          </Grid>
        </Grid>
        <Box sx={{ mt: 3, display: 'flex', justifyContent: 'flex-end' }}>
          <Button type="button" variant="contained" color="primary" onClick={handleSave} disabled={saving} startIcon={<Save sx={{ fontSize: 18 }} />}>
            {saving ? t('saving') : t('saveProfile')}
          </Button>
        </Box>
      </Paper>

      {/* ---- Invoice Template ---- */}
      <SettingsSection>
        <Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 0 }}>
          {t('hc_invoiceTemplate')}
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          Configure default styling and optional fields for all your invoices.
        </Typography>

        {Array.from(new Map(getCountriesForRegion().map(c => [c.currency, c])).values()).length > 1 && (
        <Grid container spacing={3} sx={{ mb: 3 }}>
          <Grid item xs={12} md={invoiceTemplate.currency !== 'INR' ? 6 : 12}>
            <FormControl fullWidth size="small">
              <InputLabel shrink>{t('hc_currency')}</InputLabel>
              <Select value={invoiceTemplate.currency || 'INR'} label={t('hc_currency')} displayEmpty
                onChange={(e) => handleTemplateChange('currency', e.target.value)}>
                {Array.from(new Map(getCountriesForRegion().map(c => [c.currency, c])).values()).map(c => (
                  <MenuItem key={c.currency} value={c.currency}>{c.currency} ({c.currencySymbol === c.currency ? c.name : c.currencySymbol})</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          {invoiceTemplate.currency !== 'INR' && (
            <Grid item xs={12} md={6}>
              <TextField fullWidth size="small" label="Exchange Rate (optional, snapshot)" 
                type="number" slotProps={{ htmlInput: { step: "any", min: 0 } }}
                value={invoiceTemplate.exchangeRate || ''}
                onChange={(e) => handleTemplateChange('exchangeRate', e.target.value)}
                placeholder={`1 ${invoiceTemplate.currency} = ? INR`}
                helperText="Stored on this invoice — historical reports stay accurate even if rates change."
              />
            </Grid>
          )}
        </Grid>
        )}
        

        <Box sx={{ mt: 2, p: 2, borderRadius: 2, bgcolor: 'background.default', border: '1px solid', borderColor: 'divider', display: 'flex', alignItems: 'center', gap: 2 }}>
          <IconButton
            onClick={() => handleTemplateChange('showItemizedTax', !invoiceTemplate.showItemizedTax)}
            sx={{
              bgcolor: invoiceTemplate.showItemizedTax ? 'primary.main' : 'action.hover',
              color: invoiceTemplate.showItemizedTax ? 'primary.contrastText' : 'text.secondary',
              boxShadow: invoiceTemplate.showItemizedTax ? 3 : 0,
              width: 48, height: 48,
              '&:hover': { bgcolor: 'primary.dark', color: 'primary.contrastText' },
            }}
          >
            <TableIcon size={24} weight="bold" />
          </IconButton>
          <Box sx={{ flexGrow: 1, cursor: 'pointer' }} onClick={() => handleTemplateChange('showItemizedTax', !invoiceTemplate.showItemizedTax)}>
            <Typography variant="subtitle1" sx={{ fontWeight: 600 }}>
              {language === 'ta' ? 'விரிவான ஜிஎஸ்டி பட்டியலைக் காட்டு (Itemized GST Table)' : 'Show itemized GST table'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {language === 'ta' ? 'ஒவ்வொரு பொருளுக்கும் தனித்தனியாக ஜிஎஸ்டி விவரங்களை காண்பி' : 'Display detailed itemized GST breakdown columns on the invoice'}
            </Typography>
          </Box>
        </Box>
      </Paper>

      {/* Modals */}
      <Dialog open={showNewProfileModal} onClose={() => setShowNewProfileModal(false)} disableScrollLock>
        <DialogTitle>{language === 'ta' ? 'புதிய சுயவிவரத்தை உருவாக்கு' : 'Create New Profile'}</DialogTitle>
        <DialogContent sx={{ minWidth: { sm: 400 } }}>
          <TextField autoFocus margin="dense" label={language === 'ta' ? 'நிறுவனத்தின் பெயர் *' : 'Business Name *'} fullWidth value={newProfileData.niruvanathinPeyar} onChange={(e) => setNewProfileData({ ...newProfileData, niruvanathinPeyar: e.target.value })} />
          <TextField margin="dense" label="GSTIN / Tax ID" fullWidth value={newProfileData.gstin} onChange={(e) => setNewProfileData({ ...newProfileData, gstin: e.target.value })} />
          <TextField margin="dense" label={language === 'ta' ? 'முகவரி' : 'Address'} fullWidth multiline rows={2} value={newProfileData.mugavari} onChange={(e) => setNewProfileData({ ...newProfileData, mugavari: e.target.value })} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowNewProfileModal(false)}>{language === 'ta' ? 'ரத்து' : 'Cancel'}</Button>
          <Button onClick={handleCreateNewProfile} variant="contained" disabled={creatingProfile}>
            {creatingProfile ? '...' : (language === 'ta' ? 'உருவாக்கு' : 'Create')}
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
}
