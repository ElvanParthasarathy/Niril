import React, { useState, useEffect } from 'react';
import { Box, TextField, InputAdornment } from '@mui/material';
import { saveProduct } from '../Avanam';
import { getCountryConfig } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import ElvanEditorLayout from './ElvanEditorLayout';
import ElvanBilingualField from './ElvanBilingualField';

export default function PorulThoguppu({ onBack, onSaved, product, profileSettings, defaultCountry }) {
  const { t } = useLanguage();
  const [form, setForm] = useState({});
  const profileCountry = defaultCountry || 'India';
  const isEditing = !!product?.id;

  const isBilingual = profileSettings?.enableBilingual !== false;
  const primaryLang = profileSettings?.primaryDataLanguage || 'Tamil';
  const secondaryLang = profileSettings?.secondaryDataLanguage || 'English';

  const primaryLangSuffix = isBilingual ? ` (${t(primaryLang.toLowerCase() as any) || primaryLang})` : '';
  const secondaryLangSuffix = isBilingual ? ` (${t(secondaryLang.toLowerCase() as any) || secondaryLang})` : '';

  useEffect(() => {
    if (product) {
      setForm({ ...product });
    } else {
      setForm({ hsn: '50072010', taxPercent: '5', unit: 'Nos', rate: '', stock: '' });
    }
  }, [product]);

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

  const handleSave = async () => {
    const primaryName = getField('name', primaryLang);
    if (!primaryName.trim()) {
      thagaval(t('productNameRequiredToast') || 'Name is required', 'warning');
      return;
    }
    try {
      const productData = {
        ...form,
        ...(isEditing ? { id: product.id } : {}),
        name: primaryName.trim(),
        nameEn: getField('name', secondaryLang).trim(),
        hsn: form.hsn?.trim() || '',
        rate: form.rate ? parseFloat(form.rate as any) : 0,
        taxPercent: form.taxPercent ? parseFloat(form.taxPercent as any) : 0,
        unit: form.unit || 'Nos',
        stock: form.stock ? parseFloat(form.stock as any) : 0,
        description: getField('description', primaryLang).trim(),
        descriptionEn: getField('description', secondaryLang).trim(),
      };
      const savedProduct = await saveProduct(productData);
      thagaval(isEditing ? (t('productUpdatedToast') || 'Updated!') : (t('productAddedToast') || 'Added!'), 'success');
      onSaved(savedProduct);
    } catch {
      thagaval(t('failedToSaveProductToast') || 'Error saving', 'error');
    }
  };

  return (
    <ElvanEditorLayout
      title={(isEditing ? (t('editProductTitle') || 'Edit Product') : (t('addProductTitle') || 'New Product')) as string}
      onBack={onBack}
      onSave={handleSave}
      saveButtonText={(isEditing ? (t('updateClientModalBtn') || 'Save Changes') : (t('saveClientModalBtn') || 'Create Product')) as string}
    >
      <datalist id="hsn-list"><option value="50072010" /></datalist>
      <datalist id="gst-list">
        <option value="0" />
        <option value="5" />
        <option value="12" />
        <option value="18" />
        <option value="28" />
      </datalist>

      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3 }}>
        <ElvanBilingualField
          label={(t('productNameLabel') || 'Name') as string}
          primaryLang={primaryLang}
          secondaryLang={secondaryLang}
          isBilingual={isBilingual}
          primaryValue={getField('name', primaryLang)}
          onPrimaryChange={e => updateField('name', primaryLang, e.target.value)}
          secondaryValue={getField('name', secondaryLang)}
          onSecondaryChange={e => updateField('name', secondaryLang, e.target.value)}
          required
          placeholder={(t('productNameLabel') || 'Product Name') as string}
        />
      </Box>

      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)' }, gap: 3, mt: 8 }}>
        <TextField fullWidth size="medium" label={(t('hsnCodeLabel') || 'HSN / SAC Code') as string} 
          slotProps={{ 
            inputLabel: { shrink: true }, 
            htmlInput: { list: "hsn-list" },
            input: {
              sx: { 
                '& input::-webkit-calendar-picker-indicator': { 
                  position: 'absolute', 
                  right: 16, 
                  top: '50%', 
                  transform: 'translateY(-50%)',
                  cursor: 'pointer',
                  opacity: 0.6
                } 
              }
            }
          }}
          value={form.hsn || ''} onChange={e => updateField('hsn', null, e.target.value)} placeholder="50072010" />

        <TextField fullWidth size="medium" label={(t('rateLabel') || 'Selling Rate') as string} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0 }, input: { startAdornment: <InputAdornment position="start" sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 24, mt: '0 !important' }}>{getCountryConfig(profileCountry).currencySymbol || getCountryConfig(profileCountry).currency}</InputAdornment> } }}
          value={form.rate || ''} onChange={e => updateField('rate', null, e.target.value)} placeholder="0.00" />

        <TextField fullWidth size="medium" label={(t('gstPercentLabel') || 'GST Rate') as string} type="number" 
          slotProps={{ 
            inputLabel: { shrink: true }, 
            htmlInput: { min: 0, list: "gst-list" }, 
            input: { 
              endAdornment: <InputAdornment position="end" sx={{ mt: '0 !important', mr: 1.5, color: 'text.secondary' }}>%</InputAdornment>,
              sx: { 
                '& input::-webkit-calendar-picker-indicator': { 
                  position: 'absolute', 
                  right: 36, 
                  top: '50%', 
                  transform: 'translateY(-50%)',
                  cursor: 'pointer',
                  opacity: 0.6
                } 
              }
            } 
          }}
          value={form.taxPercent || ''} onChange={e => updateField('taxPercent', null, e.target.value)} placeholder="0" />
      </Box>
    </ElvanEditorLayout>
  );
}
