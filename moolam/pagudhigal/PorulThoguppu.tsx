// @ts-nocheck
import { FloppyDisk } from '@phosphor-icons/react';
import React, { useState, useEffect } from 'react';
import {
  Box, Button, TextField, InputAdornment, MenuItem, Typography, Autocomplete
} from '@mui/material';
import { saveProduct } from '../Avanam';
import { getAllUnits, getCountryConfig } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import { FloatingBackButton } from './FloatingBackButton';

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

  const isBilingual = profileSettings?.enableBilingual !== false;
  const primaryLangSuffix = isBilingual ? ` (${t((profileSettings?.primaryDataLanguage?.toLowerCase() || 'tamil') as any) || profileSettings?.primaryDataLanguage || 'Tamil'})` : '';
  const secondaryLangSuffix = isBilingual ? ` (${t((profileSettings?.secondaryDataLanguage?.toLowerCase() || 'english') as any) || profileSettings?.secondaryDataLanguage || 'English'})` : '';

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
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', position: 'relative' }}>
      <Box sx={{ px: { xs: 2, md: 0 }, mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h5" sx={{ ml: 2, fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary' }}>
          {isEditing ? (t('editProductTitle') || 'Edit Product') : (t('addProductTitle') || 'New Product')}
        </Typography>
        <FloatingBackButton onBack={onBack} label={t('back') as string} className="back-pill" />
      </Box>

      <Box sx={{ px: { xs: 2, md: 0 } }}>
        <datalist id="hsn-list"><option value="50072010" /></datalist>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3 }}>
          <TextField fullWidth size="medium" label={`${t('productNameLabel') || 'Name'}${primaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
            value={form.name} onChange={e => updateField('name', e.target.value)} required placeholder={t('productNameLabel') || 'Product Name'} />
            
          {isBilingual && (
            <TextField fullWidth size="medium" label={`${t('productNameLabel') || 'Name'}${secondaryLangSuffix}`} slotProps={{ inputLabel: { shrink: true } }}
              value={form.nameEn || ''} onChange={e => updateField('nameEn', e.target.value)} placeholder={t('productNameLabel') || 'Product Name'} />
          )}
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
          <TextField fullWidth size="medium" label={t('hsnCodeLabel') || 'HSN / SAC Code'} slotProps={{ inputLabel: { shrink: true }, htmlInput: { list: "hsn-list" } }}
            value={form.hsn} onChange={e => updateField('hsn', e.target.value)} placeholder="50072010" />

          <TextField fullWidth size="medium" label={t('rateLabel') || 'Selling Rate'} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0 }, input: { startAdornment: <InputAdornment position="start" sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 24, mt: '0 !important' }}>{getCountryConfig(profileCountry).currencySymbol || getCountryConfig(profileCountry).currency}</InputAdornment> } }}
            value={form.rate} onChange={e => updateField('rate', e.target.value)} placeholder="0.00" />

          <TextField fullWidth size="medium" label={t('gstPercentLabel') || 'GST Rate'} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0 }, input: { endAdornment: <InputAdornment position="end" sx={{ mt: '0 !important', mr: 1.5, color: 'text.secondary' }}>%</InputAdornment> } }}
            value={form.taxPercent} onChange={e => updateField('taxPercent', e.target.value)} placeholder="0" />
        </Box>
      </Box>

      <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mb: 6, mt: 5, px: { xs: 2, md: 0 } }}>
        <Button variant="contained" disableElevation onClick={onBack} sx={{ height: 40, minHeight: 40, maxHeight: 40, px: 3, borderRadius: '50px', bgcolor: 'background.paper', color: 'text.primary', '&:hover': { bgcolor: 'action.hover' } }}>
          {t('cancelModalBtn') || 'Cancel'}
        </Button>
        <Button variant="contained" color="primary" disableElevation onClick={handleSave} startIcon={<FloppyDisk size={20} weight="bold" />} sx={{ height: 40, minHeight: 40, maxHeight: 40, px: 3, borderRadius: '50px' }}>
          {isEditing ? (t('updateClientModalBtn') || 'Save Changes') : (t('saveClientModalBtn') || 'Create Product')}
        </Button>
      </Box>
    </Box>
  );
}
