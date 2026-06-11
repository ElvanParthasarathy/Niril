import React, { useState, useEffect } from 'react';
import { FloppyDisk, Plus, Storefront, Palette, MapPin, Bank, X, AddressBook } from '@phosphor-icons/react';
import { Box, Typography, Button, TextField, Select, MenuItem, useTheme, useMediaQuery, Stack, FormControl, InputLabel, Divider } from '@mui/material';
import { getAllCoolieProfiles, saveCoolieProfile } from '../../Avanam';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import { SettingsSection, SettingsRow } from '../ElvanSettingsSection';

export default function CoolieSettings() {
  const { t, language } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));

  const [profiles, setProfiles] = useState([]);
  const [selectedId, setSelectedId] = useState('new');
  const [isLoading, setIsLoading] = useState(true);

  const [phones, setPhones] = useState(['']);

  const [formData, setFormData] = useState({
    name: '', nameEn: '', shortBusinessName: '',
    address: '', addressEn: '',
    city: '', cityEn: '',
    district: '', districtEn: '',
    pincode: '',
    bankName: '', bankNameEn: '',
    accountNo: '',
    ifsc: '',
    branch: '', branchEn: '',
    email: '',
    logo: '',
    signature: '',
    authorizedSignatoryName: '',
    themeColor: '#388e3c',
    defaultPrintLanguage: 'ta',
    receiptLanguage: 'ta'
  });

  const loadProfiles = async () => {
    setIsLoading(true);
    try {
      const data = await getAllCoolieProfiles();
      setProfiles(data);
      if (data.length > 0 && selectedId === 'new') {
        selectProfile(data[0]);
      } else if (data.length === 0) {
        handleAddNew();
      } else {
        const current = data.find(p => p.id === selectedId);
        if (current) selectProfile(current);
      }
    } catch {
      thagaval(t('error') || 'Error loading profiles', 'error');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadProfiles();
  }, []);

  const selectProfile = (p) => {
    setSelectedId(p.id);
    setFormData({
      name: p.name || '', nameEn: p.nameEn || '', shortBusinessName: p.shortBusinessName || '',
      address: p.address || '', addressEn: p.addressEn || '',
      city: p.city || '', cityEn: p.cityEn || '',
      district: p.district || '', districtEn: p.districtEn || '',
      pincode: p.pincode || '',
      bankName: p.bankName || '', bankNameEn: p.bankNameEn || '',
      accountNo: p.accountNo || '',
      ifsc: p.ifsc || '',
      branch: p.branch || '', branchEn: p.branchEn || '',
      email: p.email || '',
      logo: p.logo || '',
      signature: p.signature || '',
      authorizedSignatoryName: p.authorizedSignatoryName || '',
      themeColor: p.themeColor || '#388e3c',
      defaultPrintLanguage: p.defaultPrintLanguage || 'ta',
      receiptLanguage: p.receiptLanguage || 'ta'
    });
    setPhones(p.phone ? p.phone.split(',').filter(Boolean) : ['']);
  };

  const handleAddNew = () => {
    setSelectedId('new');
    setFormData({
      name: '', nameEn: '', shortBusinessName: '',
      address: '', addressEn: '',
      city: '', cityEn: '',
      district: '', districtEn: '',
      pincode: '',
      bankName: '', bankNameEn: '',
      accountNo: '', ifsc: '',
      branch: '', branchEn: '',
      email: '',
      logo: '',
      signature: '',
      authorizedSignatoryName: '',
      themeColor: '#388e3c',
      defaultPrintLanguage: 'ta',
      receiptLanguage: 'ta'
    });
    setPhones(['']);
  };

  const handleLogoChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({ ...prev, logo: reader.result }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSignatureChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setFormData(prev => ({ ...prev, signature: reader.result }));
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSave = async () => {
    if (!formData.name && !formData.nameEn) {
      thagaval(t('orgNameRequired') || 'Organization Name is required', 'warning');
      return;
    }

    try {
      const payload = {
        ...formData,
        phone: phones.filter(x => x.trim() !== '').join(','),
        ...(selectedId !== 'new' ? { id: selectedId } : {})
      };
      
      const saved = await saveCoolieProfile(payload);
      setSelectedId(saved.id);
      loadProfiles();
      thagaval(t('profileSaved') || 'Profile Saved successfully', 'success');
    } catch (error) {
      thagaval(`Error: ${error.message}`, 'error');
    }
  };

  const useTamilFirst = language === 'ta_mixed' || language === 'ta_only';

  if (isLoading) {
    return <Box sx={{ minHeight: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'center' }}></Box>;
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      
      {/* Header */}
      <Box sx={{ display: 'flex', flexDirection: isMobile ? 'column' : 'row', justifyContent: 'space-between', alignItems: isMobile ? 'stretch' : 'center', mb: 4, gap: 2 }}>
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: 'text.primary', letterSpacing: '-0.5px' }}>
            {t('businessProfile') || 'நிறுவனத்தின் விவரம்'}
          </Typography>
          <Typography variant="subtitle2" sx={{ color: 'text.secondary', mt: 0.5 }}>
            Coolie Business Settings
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', flexDirection: isMobile ? 'column' : 'row', gap: 2 }}>
          <FormControl size="small" sx={{ minWidth: 240 }}>
            <Select
              value={selectedId}
              onChange={(e) => {
                const val = e.target.value;
                if (val === 'new') handleAddNew();
                else selectProfile(profiles.find(p => p.id === val));
              }}
              sx={{ borderRadius: '50px', bgcolor: 'background.paper', fontWeight: 600 }}
            >
              {profiles.map(p => (
                <MenuItem key={p.id} value={p.id} sx={{ fontWeight: 600 }}>
                  {useTamilFirst ? (p.name || p.nameEn) : (p.nameEn || p.name)}
                </MenuItem>
              ))}
              {profiles.length > 0 && <Divider />}
              <MenuItem value="new" sx={{ fontWeight: 700, color: 'primary.main' }}>
                <Plus size={16} weight="bold" style={{ marginRight: 8 }} /> {t('addNew') || 'Add New Profile'}
              </MenuItem>
            </Select>
          </FormControl>
          <Button
            variant="contained"
            color="primary"
            startIcon={<FloppyDisk size={20} weight="bold" />}
            onClick={handleSave}
            sx={{ borderRadius: '50px', px: 3, textTransform: 'none', fontWeight: 700, boxShadow: 'none' }}
          >
            {t('save') || 'Save'}
          </Button>
        </Box>
      </Box>

      <Stack spacing={3}>
        {/* 1. Identity & Appearance */}
        <SettingsSection title={t('appearance') || 'Identity & Appearance'} sx={{ p: 0 }}>
          <Box sx={{ p: { xs: 2, md: 3 }, display: 'flex', flexDirection: 'column', gap: 3 }}>
            <Box sx={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: 3 }}>
              <Box sx={{ gridColumn: 'span 2' }}>
                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                  {t('organizationLogo') || 'Organization Logo'}
                </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                {formData.logo && (
                  <Box sx={{ height: 80, width: 120, border: '1px solid', borderColor: 'divider', borderRadius: 2, display: 'flex', justifyContent: 'center', alignItems: 'center', bgcolor: 'background.paper' }}>
                    <img src={formData.logo} alt="Logo" style={{ maxHeight: '100%', maxWidth: '100%', objectFit: 'contain' }} />
                  </Box>
                )}
                <Button variant="outlined" component="label" sx={{ borderRadius: '50px', textTransform: 'none', px: 3 }}>
                  Upload Logo
                  <input type="file" hidden accept="image/*" onChange={handleLogoChange} />
                </Button>
              </Box>
            </Box>

            <Box sx={{ gridColumn: 'span 2' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                {t('signature') || 'Signature'}
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                {formData.signature && (
                  <Box sx={{ height: 80, width: 120, border: '1px solid', borderColor: 'divider', borderRadius: 2, display: 'flex', justifyContent: 'center', alignItems: 'center', bgcolor: 'background.paper', position: 'relative' }}>
                    <img src={formData.signature} alt="Signature" style={{ maxHeight: '100%', maxWidth: '100%', objectFit: 'contain' }} />
                    <Button size="small" color="error" onClick={() => setFormData(prev => ({ ...prev, signature: '' }))} sx={{ position: 'absolute', top: -10, right: -10, minWidth: 'auto', p: 0.5, bgcolor: 'background.paper', borderRadius: '50%', '&:hover': { bgcolor: 'error.light', color: 'white' } }}>
                      <X size={14} weight="bold" />
                    </Button>
                  </Box>
                )}
                <Button variant="outlined" component="label" sx={{ borderRadius: '50px', textTransform: 'none', px: 3 }}>
                  Upload Signature
                  <input type="file" hidden accept="image/*" onChange={handleSignatureChange} />
                </Button>
              </Box>
            </Box>

            <Box sx={{ gridColumn: 'span 2' }}>
              <TextField
                fullWidth
                label={t('authorizedSignatoryName') || 'Authorized Signatory Name (e.g. V.R.M. Elvan)'}
                value={formData.authorizedSignatoryName}
                onChange={(e) => setFormData(prev => ({ ...prev, authorizedSignatoryName: e.target.value }))}
                placeholder="(Authorized Signature)"
                sx={{
                  '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: 'background.paper' }
                }}
              />
            </Box>

            <Box sx={{ gridColumn: 'span 2' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                {t('billTheme') || 'Bill Theme Color'}
              </Typography>
              <Box sx={{ display: 'flex', gap: 2 }}>
                {[
                  { name: t('green') || 'Green', val: '#388e3c' },
                  { name: t('violet') || 'Violet', val: '#6a1b9a' }
                ].map(themeOpt => (
                  <Box 
                    key={themeOpt.val}
                    onClick={() => setFormData({ ...formData, themeColor: themeOpt.val })}
                    sx={{ 
                      width: 48, height: 48, borderRadius: '50%', bgcolor: themeOpt.val, 
                      cursor: 'pointer', border: formData.themeColor === themeOpt.val ? '4px solid' : '4px solid transparent',
                      borderColor: formData.themeColor === themeOpt.val ? 'text.primary' : 'transparent',
                      transition: 'all 0.2s', boxShadow: 2
                    }}
                  />
                ))}
              </Box>
            </Box>

            <Box sx={{ gridColumn: 'span 2', display: 'flex', gap: 4 }}>
              <Box>
                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                  {t('defaultPrintLanguage') || 'Default Print Language'}
                </Typography>
                <FormControl size="small" sx={{ width: 200 }}>
                  <Select
                    value={formData.defaultPrintLanguage || 'ta'}
                    onChange={e => setFormData({ ...formData, defaultPrintLanguage: e.target.value })}
                  >
                    <MenuItem value="ta">{t('tamil') || 'Tamil'}</MenuItem>
                    <MenuItem value="en">{t('english') || 'English'}</MenuItem>
                  </Select>
                </FormControl>
              </Box>
              <Box>
                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                  Receipt Language
                </Typography>
                <FormControl size="small" sx={{ width: 200 }}>
                  <Select
                    value={formData.receiptLanguage || 'ta'}
                    onChange={e => setFormData({ ...formData, receiptLanguage: e.target.value })}
                  >
                    <MenuItem value="ta">{t('tamil') || 'Tamil'}</MenuItem>
                    <MenuItem value="en">{t('english') || 'English'}</MenuItem>
                  </Select>
                </FormControl>
              </Box>
            </Box>
            </Box>
          </Box>
        </SettingsSection>

        {/* 2. Basic Info */}
        <SettingsSection title={t('basicInfo') || 'Basic Information'} sx={{ p: 0 }}>
          <Box sx={{ p: { xs: 2, md: 3 }, display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: 3 }}>
            <TextField label={t('companyNameTamil') || 'Organization Name (Tamil)'} value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} fullWidth size="small" sx={{ gridColumn: 'span 2' }} />
            <TextField label={t('companyNameEnglish') || 'Organization Name (English)'} value={formData.nameEn} onChange={e => setFormData({ ...formData, nameEn: e.target.value })} fullWidth size="small" sx={{ gridColumn: 'span 2' }} />
            <TextField label={t('shortBusinessName') || 'Short Business Name (For Filters)'} value={formData.shortBusinessName} onChange={e => setFormData({ ...formData, shortBusinessName: e.target.value })} fullWidth size="small" sx={{ gridColumn: 'span 2' }} placeholder="e.g., VRM, PVS" />
          </Box>
        </SettingsSection>

        {/* 3. Address Details */}
        <SettingsSection title={t('addressDetails') || 'Address Details'} sx={{ p: 0 }}>
          <Box sx={{ p: { xs: 2, md: 3 }, display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: 3 }}>
            <TextField label={t('addressTamil') || 'Address (Tamil)'} value={formData.address} onChange={e => setFormData({ ...formData, address: e.target.value })} fullWidth multiline rows={2} size="small" sx={{ gridColumn: 'span 2' }} />
            <TextField label={t('addressEnglish') || 'Address (English)'} value={formData.addressEn} onChange={e => setFormData({ ...formData, addressEn: e.target.value })} fullWidth multiline rows={2} size="small" sx={{ gridColumn: 'span 2' }} />
            
            <TextField label={t('cityTamil') || 'City (Tamil)'} value={formData.city} onChange={e => setFormData({ ...formData, city: e.target.value })} fullWidth size="small" />
            <TextField label={t('cityEnglish') || 'City (English)'} value={formData.cityEn} onChange={e => setFormData({ ...formData, cityEn: e.target.value })} fullWidth size="small" />

            <TextField label={t('districtTamil') || 'District (Tamil)'} value={formData.district} onChange={e => setFormData({ ...formData, district: e.target.value })} fullWidth size="small" />
            <TextField label={t('districtEnglish') || 'District (English)'} value={formData.districtEn} onChange={e => setFormData({ ...formData, districtEn: e.target.value })} fullWidth size="small" />

            <TextField label={t('pincode') || 'Pincode'} value={formData.pincode} onChange={e => setFormData({ ...formData, pincode: e.target.value })} fullWidth size="small" sx={{ gridColumn: 'span 2' }} />
          </Box>
        </SettingsSection>

        {/* 4. Bank & Contact */}
        <SettingsSection title={t('bankAndContact') || 'Bank Details'} sx={{ p: 0 }}>
          <Box sx={{ p: { xs: 2, md: 3 }, display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: 3 }}>
            <TextField label={t('bankNameTamil') || 'Bank Name (Tamil)'} value={formData.bankName} onChange={e => setFormData({ ...formData, bankName: e.target.value })} fullWidth size="small" />
            <TextField label={t('bankNameEnglish') || 'Bank Name (English)'} value={formData.bankNameEn} onChange={e => setFormData({ ...formData, bankNameEn: e.target.value })} fullWidth size="small" />
            
            <TextField label={t('branchTamil') || 'Branch Name (Tamil)'} value={formData.branch} onChange={e => setFormData({ ...formData, branch: e.target.value })} fullWidth size="small" />
            <TextField label={t('branchEnglish') || 'Branch Name (English)'} value={formData.branchEn} onChange={e => setFormData({ ...formData, branchEn: e.target.value })} fullWidth size="small" />

            <TextField label={t('accountNo') || 'Account Number'} value={formData.accountNo} onChange={e => setFormData({ ...formData, accountNo: e.target.value })} fullWidth size="small" />
            <TextField label={t('ifscCode') || 'IFSC Code'} value={formData.ifsc} onChange={e => setFormData({ ...formData, ifsc: e.target.value })} fullWidth size="small" />
          </Box>
        </SettingsSection>

        {/* 5. Contact Info */}
        <SettingsSection title={t('contactInformation') || 'Contact Information'} sx={{ p: 0 }}>
          <Box sx={{ p: { xs: 2, md: 3 }, display: 'flex', flexDirection: 'column', gap: 3 }}>
            <Box>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                {t('phoneNumbers') || 'Phone Numbers'}
              </Typography>
              <Stack spacing={2}>
                {phones.map((phone, index) => (
                  <Box key={index} sx={{ display: 'flex', gap: 1 }}>
                    <TextField 
                      fullWidth 
                      size="small" 
                      value={phone} 
                      onChange={(e) => {
                        const newPhones = [...phones];
                        newPhones[index] = e.target.value;
                        setPhones(newPhones);
                      }} 
                    />
                    <Button 
                      variant="contained" 
                      color="error" 
                      sx={{ minWidth: 40, px: 0, borderRadius: 1 }}
                      onClick={() => setPhones(phones.filter((_, i) => i !== index))}
                    >
                      <X size={18} weight="bold" />
                    </Button>
                  </Box>
                ))}
                <Box>
                  <Button 
                    variant="outlined" 
                    startIcon={<Plus size={16} weight="bold" />} 
                    onClick={() => setPhones([...phones, ''])}
                    sx={{ textTransform: 'none', borderRadius: '50px' }}
                  >
                    {t('addPhoneNumber') || 'Add Phone Number'}
                  </Button>
                </Box>
              </Stack>
            </Box>

            <Box>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary', mb: 1 }}>
                {t('email') || 'Email'}
              </Typography>
              <TextField 
                fullWidth 
                size="small" 
                value={formData.email} 
                onChange={e => setFormData({ ...formData, email: e.target.value })} 
              />
            </Box>
          </Box>
        </SettingsSection>
      </Stack>
    </Box>
  );
}
