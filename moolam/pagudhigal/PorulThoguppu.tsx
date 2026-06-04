// @ts-nocheck
import { ArrowLeft, FloppyDisk, Tag, FileText, Package } from '@phosphor-icons/react';
import React, { useState, useEffect } from 'react';
import {
  Box, Typography, Button, Paper, TextField, InputAdornment, IconButton,
  Grid, Select, MenuItem, InputLabel, FormControl, Divider, Stack
} from '@mui/material';
import { saveProduct } from '../Avanam';
import { getAllUnits, getCountryConfig } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';

const emptyForm = {
  name: '', nameEn: '', hsn: '50072010', rate: '', taxPercent: '5', unit: 'Nos', stock: '', description: '', descriptionEn: '',
};

export default function PorulThoguppu({ onBack, onSaved, product, profileSettings, defaultCountry }) {
  const { t } = useLanguage();
  const [form, setForm] = useState({ ...emptyForm });
  const [units, setUnits] = useState(getAllUnits());
  const profileCountry = defaultCountry || 'India';
  const profileCurrency = getCountryConfig(profileCountry).currency;
  const isEditing = !!product?.id;

  useEffect(() => {
    if (product) {
      setForm({
        name: product.name || '',
        nameEn: product.nameEn || '',
        hsn: product.hsn || '',
        rate: product.rate || '',
        taxPercent: product.taxPercent || '',
        unit: product.unit || 'Nos',
        stock: product.stock || '',
        description: product.description || '',
        descriptionEn: product.descriptionEn || '',
      });
    } else {
      setForm({ ...emptyForm });
    }
  }, [product]);

  const handleSave = async () => {
    if (!form.name.trim()) {
      thagaval(t('productNameRequiredToast') || 'Name is required', 'warning');
      return;
    }
    try {
      const productData = {
        ...(isEditing ? { id: product.id } : {}),
        name: form.name?.trim() || '',
        nameEn: form.nameEn?.trim() || '',
        hsn: form.hsn?.trim() || '',
        rate: form.rate ? parseFloat(form.rate as any) : 0,
        taxPercent: form.taxPercent ? parseFloat(form.taxPercent as any) : 0,
        unit: form.unit || 'Nos',
        stock: form.stock ? parseFloat(form.stock as any) : 0,
        description: form.description?.trim() || '',
        descriptionEn: form.descriptionEn?.trim() || '',
      };
      const savedProduct = await saveProduct(productData);
      thagaval(isEditing ? (t('productUpdatedToast') || 'Updated!') : (t('productAddedToast') || 'Added!'), 'success');
      onSaved(savedProduct);
    } catch {
      thagaval(t('failedToSaveProductToast') || 'Error saving', 'error');
    }
  };

  const updateField = (field, value) => {
    setForm(prev => ({ ...prev, [field]: value }));
  };

  return (
    <Box sx={{ p: { xs: 2, md: 4 }, maxWidth: 800, mx: 'auto' }}>
      <Stack direction="row" alignItems="center" spacing={2} mb={3}>
        <IconButton onClick={onBack} sx={{ bgcolor: 'background.paper' }}>
          <ArrowLeft size={20} weight="regular" />
        </IconButton>
        <Typography variant="h5" sx={{ fontWeight: "bold" }}>
          {isEditing ? (t('editProductTitle') || 'Edit Product') : (t('addProductTitle') || 'New Product')}
        </Typography>
      </Stack>

      <Paper elevation={0} sx={{ p: { xs: 2, md: 4 }, borderRadius: 3, border: '1px solid', borderColor: 'divider' }}>
        <datalist id="hsn-list"><option value="50072010" /></datalist>

        <Box component="form" sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          <Box>
            <Typography variant="overline" color="primary" sx={{ fontWeight: 'bold', mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
              <Tag size={16} weight="regular" /> Core Information
            </Typography>
            <Divider sx={{ mb: 3 }} />

            <Grid container spacing={3}>
              <Grid size={{ xs: 12 }}>
                <TextField
                  fullWidth size="small"
                  label={`${t('productNameLabel') || 'Name'} (${profileSettings?.primaryDataLanguage || 'Tamil'})`}
                  value={form.name}
                  onChange={e => updateField('name', e.target.value)}
                  required InputLabelProps={{ shrink: true }}
                />
              </Grid>
              {profileSettings?.enableBilingual !== false && (
                <Grid size={{ xs: 12 }}>
                  <TextField
                    fullWidth size="small"
                    label={`${t('productNameLabel') || 'Name'} (${profileSettings?.secondaryDataLanguage || 'English'})`}
                    value={form.nameEn || ''}
                    onChange={e => updateField('nameEn', e.target.value)}
                    InputLabelProps={{ shrink: true }}
                  />
                </Grid>
              )}
            </Grid>
          </Box>

          <Box sx={{ mt: 2 }}>
            <Typography variant="overline" color="primary" sx={{ fontWeight: 'bold', mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
              <FileText size={16} weight="regular" /> Tax & Pricing
            </Typography>
            <Divider sx={{ mb: 3 }} />

            <Grid container spacing={3}>
              <Grid size={{ xs: 12, sm: 4 }}>
                <TextField
                  fullWidth size="small"
                  label={t('hsnCodeLabel') || 'HSN / SAC Code'}
                  value={form.hsn}
                  onChange={e => updateField('hsn', e.target.value)} slotProps={{ htmlInput: { list: "hsn-list" } }}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid size={{ xs: 12, sm: 4 }}>
                <TextField
                  fullWidth size="small"
                  label={t('rateLabel') || 'Selling Rate'}
                  type="number"
                  value={form.rate}
                  onChange={e => updateField('rate', e.target.value)}
                  InputLabelProps={{ shrink: true }} slotProps={{ htmlInput: { min: 0 }, input: { startAdornment: <InputAdornment position="start">{profileCurrency}</InputAdornment> } }}
                />
              </Grid>
              <Grid size={{ xs: 12, sm: 4 }}>
                <FormControl fullWidth size="small">
                  <InputLabel shrink>{t('gstPercentLabel') || 'GST Rate'}</InputLabel>
                  <Select value={form.taxPercent} label={t('gstPercentLabel') || 'GST Rate'} onChange={e => updateField('taxPercent', e.target.value)} displayEmpty>
                    <MenuItem value="0">GST0 [0%]</MenuItem>
                    <MenuItem value="5">GST5 [5%]</MenuItem>
                    <MenuItem value="12">GST12 [12%]</MenuItem>
                    <MenuItem value="18">GST18 [18%]</MenuItem>
                    <MenuItem value="28">GST28 [28%]</MenuItem>
                  </Select>
                </FormControl>
              </Grid>
            </Grid>
          </Box>


        </Box>
        
        <Box sx={{ mt: 5, display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
          <Button variant="outlined" color="inherit" onClick={onBack} sx={{ height: 42, borderRadius: '50px', textTransform: 'none', px: 4 }}>
            {t('cancelModalBtn') || 'Cancel'}
          </Button>
          <Button variant="contained" onClick={handleSave} startIcon={<FloppyDisk size={18} weight="regular" />} sx={{ height: 42, borderRadius: '50px', textTransform: 'none', px: 4, bgcolor: '#0f172a', color: 'white', '&:hover': { bgcolor: '#1e293b' } }}>
            {isEditing ? (t('updateClientModalBtn') || 'Save Changes') : (t('saveClientModalBtn') || 'Create Product')}
          </Button>
        </Box>
      </Paper>
    </Box>
  );
}
