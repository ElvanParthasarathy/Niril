import React, { useState, useEffect } from 'react';
import { Box, Typography, TextField, Button, Stack, Autocomplete, IconButton, Divider, Select, MenuItem, FormControl, InputLabel, useTheme, Switch, FormControlLabel, createFilterOptions } from '@mui/material';
import { styled } from '@mui/material/styles';

const MD3Switch = styled(Switch)(({ theme }) => ({
  width: 52,
  height: 32,
  padding: 0,
  '& .MuiSwitch-switchBase': {
    padding: 0,
    margin: 4,
    transitionDuration: '300ms',
    '&.Mui-checked': {
      transform: 'translateX(20px)',
      color: theme.palette.primary.contrastText,
      '& + .MuiSwitch-track': {
        backgroundColor: theme.palette.primary.main,
        opacity: 1,
        border: 0,
      },
      '& .MuiSwitch-thumb': {
        width: 24,
        height: 24,
        margin: 0,
        backgroundColor: theme.palette.primary.contrastText,
      },
    },
  },
  '& .MuiSwitch-thumb': {
    boxSizing: 'border-box',
    width: 16,
    height: 16,
    margin: 4,
    boxShadow: 'none',
    backgroundColor: theme.palette.mode === 'dark' ? '#cfd8dc' : '#fff',
    transition: theme.transitions.create(['width', 'height', 'margin'], {
      duration: 200,
    }),
  },
  '& .MuiSwitch-track': {
    borderRadius: 32 / 2,
    backgroundColor: theme.palette.mode === 'dark' ? '#39393D' : '#E9E9EA',
    opacity: 1,
    transition: theme.transitions.create(['background-color', 'border'], {
      duration: 300,
    }),
    border: `2px solid ${theme.palette.mode === 'dark' ? '#8f9bb3' : '#8f9bb3'}`,
    boxSizing: 'border-box',
  },
  '& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track': {
    border: '2px solid transparent',
  }
}));
import { X, Plus, FloppyDisk } from '@phosphor-icons/react';
import { getAllCoolieClients, getAllCoolieProducts, getAllCoolieProfiles, saveCoolieBill, getNextCoolieBillNumber } from '../../Avanam';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import ElvanCard from '../ElvanCard';
import ElvanEditorLayout from '../ElvanEditorLayout';
import { useDraftAndUnsaved } from '../../hooks/useDraftAndUnsaved';

const filter = createFilterOptions({
  stringify: (option: any) => {
    if (typeof option === 'string') return option;
    return `${option.name || ''} ${option.nameEn || ''}`;
  }
});

const clientFilter = createFilterOptions({
  stringify: (option: any) => {
    if (typeof option === 'string') return option;
    return `${option.name || ''} ${option.nameEn || ''} ${option.city || ''} ${option.cityEn || ''}`;
  }
});

export default function CoolieInvoiceEditor({ onBack, onSaved, existingBill }) {
  const { t, language } = useLanguage();
  const theme = useTheme();
  
  // State from Kananam Coolie Bill
  const [billNo, setBillNo] = useState('');
  const [date, setDate] = useState(new Date().toLocaleDateString('en-GB')); // DD/MM/YYYY
  const [companyId, setCompanyId] = useState('');
  const [customerName, setCustomerName] = useState('');
  const [customerNameEn, setCustomerNameEn] = useState('');
  const [address, setAddress] = useState('');
  const [addressEn, setAddressEn] = useState('');
  const [city, setCity] = useState('');
  const [cityEn, setCityEn] = useState('');
  const [items, setItems] = useState<any[]>([{ porul: '', kg: '', coolie: '', name_tamil: '', name_english: '' }]);
  const [setharamGrams, setSetharamGrams] = useState('');
  const [courierRs, setCourierRs] = useState('');
  const [ahimsaSilkRs, setAhimsaSilkRs] = useState('');
  const [customChargeName, setCustomChargeName] = useState('');
  const [customChargeRs, setCustomChargeRs] = useState('');
  const [bankDetails, setBankDetails] = useState('');
  const [accountNo, setAccountNo] = useState('');
  const [ifsc, setIfsc] = useState('');
  const [showBankDetails, setShowBankDetails] = useState(true);
  const [showIfsc, setShowIfsc] = useState(true);
  
  // Options
  const [clientOptions, setClientOptions] = useState<any[]>([]);
  const [productOptions, setProductOptions] = useState<any[]>([]);
  const [profileOptions, setProfileOptions] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const formState = {
    billNo, date, companyId, customerName, customerNameEn,
    address, addressEn, city, cityEn, items, setharamGrams, courierRs, ahimsaSilkRs, customChargeName,
    customChargeRs, bankDetails, accountNo, ifsc, showBankDetails, showIfsc
  };

  const setFormState = (s) => {
    if (s.billNo !== undefined) setBillNo(s.billNo);
    if (s.date !== undefined) setDate(s.date);
    if (s.companyId !== undefined) setCompanyId(s.companyId);
    if (s.customerName !== undefined) setCustomerName(s.customerName);
    if (s.customerNameEn !== undefined) setCustomerNameEn(s.customerNameEn);
    if (s.address !== undefined) setAddress(s.address);
    if (s.addressEn !== undefined) setAddressEn(s.addressEn);
    if (s.city !== undefined) setCity(s.city);
    if (s.cityEn !== undefined) setCityEn(s.cityEn);
    if (s.items !== undefined) setItems(s.items);
    if (s.setharamGrams !== undefined) setSetharamGrams(s.setharamGrams);
    if (s.courierRs !== undefined) setCourierRs(s.courierRs);
    if (s.ahimsaSilkRs !== undefined) setAhimsaSilkRs(s.ahimsaSilkRs);
    if (s.customChargeName !== undefined) setCustomChargeName(s.customChargeName);
    if (s.customChargeRs !== undefined) setCustomChargeRs(s.customChargeRs);
    if (s.bankDetails !== undefined) setBankDetails(s.bankDetails);
    if (s.accountNo !== undefined) setAccountNo(s.accountNo);
    if (s.ifsc !== undefined) setIfsc(s.ifsc);
    if (s.showBankDetails !== undefined) setShowBankDetails(s.showBankDetails);
    if (s.showIfsc !== undefined) setShowIfsc(s.showIfsc);
  };

  const getIsBlank = (f) => {
    return !f.customerName && f.items.length === 1 && !f.items[0].porul;
  };

  const [initialForm] = useState({ ...formState });
  
  const isEditMode = !!existingBill;
  const { hasUnsavedChanges, clearDraft } = useDraftAndUnsaved(
    'niril_draft_coolie_bill',
    initialForm,
    formState,
    setFormState,
    isEditMode,
    getIsBlank
  );

  useEffect(() => {
    async function loadData() {
      setIsLoading(true);
      try {
        const [clients, products, profiles] = await Promise.all([
          getAllCoolieClients(),
          getAllCoolieProducts(),
          getAllCoolieProfiles()
        ]);
        setClientOptions(clients || []);
        setProductOptions(products || []);
        setProfileOptions(profiles || []);
        
        if (existingBill) {
          const compProfile = (profiles || []).find(p => p.id === existingBill.company_id);
          setFormState({
            billNo: existingBill.bill_no || '',
            date: existingBill.date || new Date().toLocaleDateString('en-GB'),
            companyId: existingBill.company_id || (profiles && profiles.length > 0 ? profiles[0].id : ''),
            customerName: existingBill.customer_name || '',
            customerNameEn: existingBill.customer_name_en || '',
            address: existingBill.address || '',
            addressEn: existingBill.address_en || '',
            city: existingBill.city || '',
            cityEn: existingBill.city_en || '',
            items: Array.isArray(existingBill.items) && existingBill.items.length > 0 ? existingBill.items : [{ porul: '', coolie: '', kg: '', name_english: '', name_tamil: '' }],
            setharamGrams: existingBill.setharam_grams || '',
            courierRs: existingBill.courier_rs || '',
            ahimsaSilkRs: existingBill.ahimsa_silk_rs || '',
            customChargeName: existingBill.custom_charge_name || '',
            customChargeRs: existingBill.custom_charge_rs || '',
            bankDetails: existingBill.bank_details || '',
            accountNo: existingBill.account_no || '',
            ifsc: existingBill.ifsc || compProfile?.ifsc || '',
            showBankDetails: existingBill.show_bank_details !== false,
            showIfsc: existingBill.show_ifsc !== false
          });
        } else if (profiles && profiles.length > 0) {
          setCompanyId(profiles[0].id);
          const bankName = profiles[0].bankNameTamil || profiles[0].bankName || '';
          const branch = profiles[0].branchTamil || profiles[0].branch || '';
          setBankDetails([bankName, branch].filter(Boolean).join(', '));
          setAccountNo(profiles[0].accountNo || '');
          setIfsc(profiles[0].ifsc || '');
          
          if (!existingBill) {
            const nextNum = await getNextCoolieBillNumber(profiles[0].id);
            setBillNo(nextNum);
          }
        }
      } catch (e) {
        console.error(e);
      } finally {
        setIsLoading(false);
      }
    }
    loadData();
  }, []);

  const handleCompanyChange = (e) => {
    const pId = e.target.value;
    setCompanyId(pId);
    const profile = profileOptions.find(p => p.id === pId);
    if (profile) {
      const bankName = profile.bankNameTamil || profile.bankName || '';
      const branch = profile.branchTamil || profile.branch || '';
      setBankDetails([bankName, branch].filter(Boolean).join(', '));
      setAccountNo(profile.accountNo || '');
      setIfsc(profile.ifsc || '');
    }
    
    if (!isEditMode) {
      getNextCoolieBillNumber(pId).then(nextNum => setBillNo(nextNum));
    }
  };

  // Calculations (Exact Logic Ported from Kananam)
  const calculateRowTotal = (item) => {
    if (!item) return '0';
    const qty = parseFloat(item.kg) || 0;
    const rate = parseFloat(item.coolie) || 0;
    return Math.floor(qty * rate);
  };

  const calculateSubtotal = () => {
    return items.reduce((sum, item) => sum + (parseFloat(calculateRowTotal(item).toString()) || 0), 0);
  };

  const calculateTotalKg = () => {
    const itemKg = items.reduce((sum, item) => sum + (parseFloat(item.kg) || 0), 0);
    const setharamKg = (parseFloat(setharamGrams) || 0) / 1000;
    return itemKg + setharamKg;
  };

  const calculateGrandTotal = () => {
    const subtotal = calculateSubtotal();
    const courier = Math.floor(parseFloat(courierRs) || 0);
    const ahimsa = Math.floor(parseFloat(ahimsaSilkRs) || 0);
    const other = Math.floor(parseFloat(customChargeRs) || 0);
    return Math.floor(subtotal + courier + ahimsa + other);
  };

  const handleSave = async () => {
    if (!billNo || !customerName) {
      alert("Bill Number and Customer Name are required");
      return;
    }
    
    const grandTotal = calculateGrandTotal();
    
    const billData = {
      id: existingBill?.id || `cbill_${Date.now()}`,
      bill_no: billNo,
      date,
      customer_name: customerName,
      customer_name_en: customerNameEn,
      address,
      address_en: addressEn,
      city,
      city_en: cityEn,
      items,
      setharam_grams: setharamGrams,
      courier_rs: courierRs,
      ahimsa_silk_rs: ahimsaSilkRs,
      custom_charge_name: customChargeName,
      custom_charge_rs: customChargeRs,
      bank_details: bankDetails,
      account_no: accountNo,
      ifsc: ifsc,
      company_id: companyId,
      grand_total: grandTotal,
      show_bank_details: showBankDetails,
      show_ifsc: showIfsc
    };
    
    await saveCoolieBill(billData);
    clearDraft();
    if (onSaved) {
      onSaved(billData);
    } else {
      alert("Bill Saved Successfully!");
    }
  };

  const updateCustomerName = (customer) => {
    setCustomerName(customer.name || '');
  };

  const handleCustomerSelect = (e, val) => {
    if (!val) {
      setCustomerName('');
      setCustomerNameEn('');
      setAddress('');
      setAddressEn('');
      setCity('');
      setCityEn('');
      return;
    }
    
    if (typeof val === 'string') {
      setCustomerName(val);
      setCustomerNameEn('');
      return;
    }
    
    setCustomerName(val.name || '');
    setCustomerNameEn(val.nameEn || '');
    setAddress(val.address || '');
    setAddressEn(val.addressEn || '');
    setCity(val.city || '');
    setCityEn(val.cityEn || '');
  };

  return (
    <ElvanEditorLayout
      title={t('coolieBill') || 'Coolie Bill'}
      onBack={onBack}
      onSave={handleSave}
      saveButtonText={t('save') || 'Save'}
      hasUnsavedChanges={hasUnsavedChanges}
      onDiscard={() => {
        clearDraft();
        if (onBack) onBack();
      }}
    >
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
        
        {/* Section 1: Metadata */}
        <Box sx={{ mb: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2, ml: 2 }}>
            <Box sx={{ width: 24, height: 24, borderRadius: '50%', bgcolor: 'primary.main', color: 'primary.contrastText', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.8rem', fontWeight: 'bold', lineHeight: 1, pt: '1px', mr: 1.5 }}>1</Box>
            <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t('invoiceDetails') || 'Invoice Details'}</Typography>
          </Box>
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr 1fr' }, gap: 3, mb: 2 }}>
            <TextField 
              label={t('billNo') || 'Bill No'} 
              value={billNo} 
              onChange={e => setBillNo(e.target.value)} 
              size="small" 
              fullWidth
              required
            />
            <TextField 
              label={t('date') || 'Date'} 
              value={date} 
              onChange={e => setDate(e.target.value)} 
              size="small" 
              placeholder="DD/MM/YYYY"
              fullWidth
              required
            />
            <FormControl size="small" fullWidth>
              <InputLabel>{t('company') || 'Company'}</InputLabel>
              <Select value={companyId} onChange={handleCompanyChange} label={t('company') || 'Company'}>
                {profileOptions.map(p => (
                  <MenuItem key={p.id} value={p.id}>{p.nameTamil || p.name || 'Unknown'}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
        </Box>

        <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

        {/* Section 2: Customer */}
        <Box sx={{ mb: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2, ml: 2 }}>
            <Box sx={{ width: 24, height: 24, borderRadius: '50%', bgcolor: 'primary.main', color: 'primary.contrastText', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.8rem', fontWeight: 'bold', lineHeight: 1, pt: '1px', mr: 1.5 }}>2</Box>
            <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t('customer') || 'Customer'}</Typography>
          </Box>
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '2fr 1fr 1fr' }, gap: 3, mb: 2 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
              <Autocomplete
                freeSolo
                options={clientOptions}
                filterOptions={clientFilter}
                getOptionLabel={(option) => typeof option === 'string' ? option : (option.name || option.nameEn || '')}
                onChange={handleCustomerSelect}
                value={customerName || ''}
                inputValue={customerName || ''}
                onInputChange={(e, val) => setCustomerName(val || '')}
                renderOption={(props, option, { index }) => {
                    const { key, ...optionProps } = props as any;
                    if (typeof option === 'string') {
                      return <li key={`client-opt-${index}`} {...optionProps}><Typography variant="body1">{option}</Typography></li>;
                    }
                    return (
                      <li key={`client-opt-${index}`} {...optionProps} style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start', borderBottom: '1px solid rgba(128,128,128,0.1)' }}>
                        <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 1 }}>
                          <Typography variant="body1" color="primary" sx={{ fontWeight: 700 }}>{option.name}</Typography>
                          {option.nameEn && <Typography variant="body2" sx={{ color: 'text.secondary' }}>{option.nameEn}</Typography>}
                        </Box>
                        {(option.city || option.cityEn) && (
                          <Box sx={{ display: 'flex', alignItems: 'baseline', gap: 0.5, mt: 0.5 }}>
                            {option.city && <Typography variant="caption" sx={{ color: 'text.secondary' }}>{option.city}</Typography>}
                            {option.cityEn && <Typography variant="caption" sx={{ color: 'text.secondary' }}>({option.cityEn})</Typography>}
                          </Box>
                        )}
                      </li>
                    );
                }}
                renderInput={(params) => <TextField {...params} label={t('name') || 'Name'} size="small" required />}
              />
            </Box>
            <TextField 
              label={t('address') || 'Address'} 
              value={address} 
              onChange={e => setAddress(e.target.value)} 
              size="small" 
              fullWidth 
            />
            <TextField 
              label={t('city') || 'City'} 
              value={city} 
              onChange={e => setCity(e.target.value)} 
              size="small" 
              fullWidth 
            />
          </Box>
        </Box>

        <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

        {/* Section 3: Items Table */}
        <Box sx={{ mb: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2, ml: 2 }}>
            <Box sx={{ width: 24, height: 24, borderRadius: '50%', bgcolor: 'primary.main', color: 'primary.contrastText', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.8rem', fontWeight: 'bold', lineHeight: 1, pt: '1px', mr: 1.5 }}>3</Box>
            <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t('itemsList') || 'Items'}</Typography>
          </Box>
          
          <Box sx={{ display: { xs: 'none', md: 'block' }, bgcolor: theme.palette.mode === 'dark' ? 'rgba(255,255,255,0.02)' : '#fcfcfc', border: '1px solid', borderColor: 'divider', borderRadius: 2, p: 2 }}>
            <Box sx={{ display: 'grid', gridTemplateColumns: '40% 15% 15% 20% 5%', gap: 2, mb: 2, px: 1 }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, color: 'text.secondary' }}>{t('itemName') || 'Item Details'}</Typography>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, textAlign: 'right', color: 'text.secondary' }}>{t('quantity') || 'Weight'}</Typography>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, textAlign: 'right', color: 'text.secondary' }}>{t('rate') || 'Rate'}</Typography>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, textAlign: 'right', color: 'text.secondary' }}>{t('amount') || 'Amount'}</Typography>
            </Box>
            
            <Divider sx={{ mb: 2 }} />

            {items.map((item, index) => (
              <Box key={index} sx={{ display: 'grid', gridTemplateColumns: '40% 15% 15% 20% 5%', gap: 2, alignItems: 'center', mb: 2, px: 1 }}>
                <Autocomplete
                  freeSolo
                  options={productOptions}
                  filterOptions={filter}
                  getOptionLabel={(option) => typeof option === 'string' ? option : (option.name || option.nameEn || '')}
                  onChange={(e, val) => {
                    setItems(prev => {
                      const newItems = [...prev];
                      const updatedItem = { ...newItems[index] };
                      if (typeof val === 'string') {
                        updatedItem.porul = val;
                      } else if (val) {
                        updatedItem.porul = val.name || val.nameEn || '';
                        updatedItem.name_tamil = val.name || '';
                        updatedItem.name_english = val.nameEn || '';
                        if (val.rate) updatedItem.coolie = val.rate;
                      } else {
                        updatedItem.porul = '';
                      }
                      newItems[index] = updatedItem;
                      return newItems;
                    });
                  }}
                  value={item.porul || ''}
                  inputValue={item.porul || ''}
                  onInputChange={(e, val) => {
                    setItems(prev => {
                      const newItems = [...prev];
                      newItems[index] = { ...newItems[index], porul: val || '' };
                      return newItems;
                    });
                  }}
                  renderOption={(props, option, { index }) => {
                      const { key, ...optionProps } = props as any;
                      if (typeof option === 'string') {
                        return (
                          <li key={`item-opt-d-${index}`} {...optionProps}>
                            <Typography variant="body2">{option}</Typography>
                          </li>
                        );
                      }
                      return (
                        <li key={`item-opt-d-${index}`} {...optionProps} style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
                          <Typography variant="body2" sx={{ fontWeight: 500 }}>{option.name}</Typography>
                          {option.nameEn && <Typography variant="caption" sx={{ color: 'text.secondary' }}>{option.nameEn}</Typography>}
                        </li>
                      );
                  }}
                  renderInput={(params) => <TextField {...params} size="small" placeholder={t('typeItemName') || 'Type Item Name'} />}
                />
                
                <TextField size="small" type="number" inputProps={{ step: '0.001', style: { textAlign: 'right' } }} value={item.kg} onChange={e => { const i = [...items]; i[index].kg = e.target.value; setItems(i); }} />
                <TextField size="small" type="number" inputProps={{ style: { textAlign: 'right' } }} value={item.coolie} onChange={e => { const i = [...items]; i[index].coolie = e.target.value; setItems(i); }} />
                
                <Typography sx={{ textAlign: 'right', fontWeight: 600 }}>{calculateRowTotal(item)}</Typography>
                <IconButton color="error" onClick={() => setItems(items.filter((_, i) => i !== index))}><X size={18} weight="bold" /></IconButton>
              </Box>
            ))}
            
            <Button startIcon={<Plus />} onClick={() => setItems([...items, { porul: '', coolie: '', kg: '', name_english: '', name_tamil: '' }])} sx={{ mt: 1 }}>
              {t('addAnotherItem') || 'Add Item'}
            </Button>
          </Box>
          
          {/* Mobile view for items */}
          <Box sx={{ display: { xs: 'flex', md: 'none' }, flexDirection: 'column', gap: 3 }}>
            {items.map((item, index) => (
              <Box key={index} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2, p: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                  <Typography variant="subtitle2" color="primary" fontWeight={700}>Item #{index + 1}</Typography>
                  <IconButton color="error" size="small" onClick={() => setItems(items.filter((_, i) => i !== index))}><X size={16} weight="bold" /></IconButton>
                </Box>
                <Autocomplete
                  freeSolo
                  options={productOptions}
                  filterOptions={filter}
                  getOptionLabel={(option) => typeof option === 'string' ? option : (option.name || option.nameEn || '')}
                  onChange={(e, val) => {
                    setItems(prev => {
                      const newItems = [...prev];
                      const updatedItem = { ...newItems[index] };
                      if (typeof val === 'string') {
                        updatedItem.porul = val;
                      } else if (val) {
                        updatedItem.porul = val.name || val.nameEn || '';
                        updatedItem.name_tamil = val.name || '';
                        updatedItem.name_english = val.nameEn || '';
                        if (val.rate) updatedItem.coolie = val.rate;
                      } else {
                        updatedItem.porul = '';
                      }
                      newItems[index] = updatedItem;
                      return newItems;
                    });
                  }}
                  value={item.porul || ''}
                  inputValue={item.porul || ''}
                  onInputChange={(e, val) => {
                    setItems(prev => {
                      const newItems = [...prev];
                      newItems[index] = { ...newItems[index], porul: val || '' };
                      return newItems;
                    });
                  }}
                  renderOption={(props, option, { index }) => {
                      const { key, ...optionProps } = props as any;
                      if (typeof option === 'string') {
                        return (
                          <li key={`item-opt-m-${index}`} {...optionProps}>
                            <Typography variant="body2">{option}</Typography>
                          </li>
                        );
                      }
                      return (
                        <li key={`item-opt-m-${index}`} {...optionProps} style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
                          <Typography variant="body2" sx={{ fontWeight: 500 }}>{option.name}</Typography>
                          {option.nameEn && <Typography variant="caption" sx={{ color: 'text.secondary' }}>{option.nameEn}</Typography>}
                        </li>
                      );
                  }}
                  renderInput={(params) => <TextField {...params} size="small" fullWidth label={t('itemName') || 'Item Name'} sx={{ mb: 2 }} />}
                />
                <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2, mb: 2 }}>
                  <TextField size="small" label={t('quantity') || 'Weight'} type="number" inputProps={{ step: '0.001' }} value={item.kg} onChange={e => { const i = [...items]; i[index].kg = e.target.value; setItems(i); }} />
                  <TextField size="small" label={t('rate') || 'Rate'} type="number" value={item.coolie} onChange={e => { const i = [...items]; i[index].coolie = e.target.value; setItems(i); }} />
                </Box>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', pt: 1, borderTop: '1px dashed', borderColor: 'divider' }}>
                  <Typography variant="body2">{t('amount') || 'Amount'}</Typography>
                  <Typography variant="subtitle1" fontWeight={700}>₹ {calculateRowTotal(item)}</Typography>
                </Box>
              </Box>
            ))}
            <Button startIcon={<Plus />} onClick={() => setItems([...items, { porul: '', coolie: '', kg: '', name_english: '', name_tamil: '' }])}>
              {t('addAnotherItem') || 'Add Item'}
            </Button>
          </Box>
        </Box>

        <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

        {/* Section 4: Totals and Bank */}
        <Box sx={{ display: 'flex', flexDirection: { xs: 'column', md: 'row' }, gap: 4, mb: 2 }}>
          {/* Bank Details */}
          <Box sx={{ flex: 1 }}>
            <Box sx={{ gridColumn: { xs: '1', md: 'span 1' } }}>
              <Box sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 3, p: 3, bgcolor: 'background.paper', mb: 3 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                  <Typography variant="subtitle1" color="primary" fontWeight={700}>
                    <Box component="span" sx={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 24, height: 24, borderRadius: '50%', bgcolor: 'text.primary', color: 'background.paper', mr: 1.5, fontSize: '0.85rem' }}>4</Box>
                    {t('bankDetails') || 'Bank Details'}
                  </Typography>
                  <FormControlLabel 
                    control={<MD3Switch checked={showBankDetails} onChange={(e) => setShowBankDetails(e.target.checked)} />} 
                    label={<Typography variant="caption" sx={{ ml: 1, fontWeight: 600 }}>{showBankDetails ? 'Show' : 'Hide'}</Typography>}
                  />
                </Box>
                {/* The details are always visible in the editor so the user can verify them, but opacity reflects print status */}
                <Stack spacing={2.5} sx={{ mt: 2 }}>
                  <Box sx={{ opacity: showBankDetails ? 1 : 0.5, transition: 'opacity 0.2s' }}>
                    <Typography variant="caption" color="text.secondary">{t('bankNamePlace') || 'Bank Name & Place'}</Typography>
                    <Typography variant="body1" fontWeight={500}>{bankDetails || '-'}</Typography>
                  </Box>
                  <Box sx={{ opacity: showBankDetails ? 1 : 0.5, transition: 'opacity 0.2s' }}>
                    <Typography variant="caption" color="text.secondary">{t('accountNo') || 'Account Number'}</Typography>
                    <Typography variant="body1" fontWeight={500} sx={{ fontFamily: 'monospace', fontSize: '1rem' }}>{accountNo || '-'}</Typography>
                  </Box>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', opacity: showIfsc ? 1 : 0.5, transition: 'opacity 0.2s' }}>
                    <Box>
                      <Typography variant="caption" color="text.secondary">{t('ifscCode') || 'IFSC Code'}</Typography>
                      <Typography variant="body1" fontWeight={500}>{ifsc || '-'}</Typography>
                    </Box>
                    <FormControlLabel 
                      control={<MD3Switch checked={showIfsc} onChange={(e) => setShowIfsc(e.target.checked)} />} 
                      label={<Typography variant="caption" sx={{ ml: 1, fontWeight: 600 }}>{showIfsc ? 'Show IFSC' : 'Hide IFSC'}</Typography>}
                    />
                  </Box>
                </Stack>
              </Box>
            </Box>
          </Box>
          
          {/* Totals */}
          <Box sx={{ flex: 1.5, bgcolor: theme.palette.mode === 'dark' ? 'rgba(255,255,255,0.02)' : '#fcfcfc', border: '1px solid', borderColor: 'divider', borderRadius: 2, p: 3 }}>
            <Stack spacing={2}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="subtitle2" color="text.secondary">{t('subTotal') || 'Sub Total'}</Typography>
                <Typography variant="subtitle1" fontWeight={600}>₹ {calculateSubtotal().toLocaleString('en-IN')}</Typography>
              </Box>
              
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2 }}>
                <Typography variant="subtitle2" color="text.secondary" sx={{ flex: 1 }}>{t('setharam') || 'Setharam'} (Grams)</Typography>
                <TextField size="small" type="number" inputProps={{ step: '0.001', style: { textAlign: 'right' } }} value={setharamGrams} onChange={e => setSetharamGrams(e.target.value)} sx={{ width: '120px' }} />
              </Box>
              
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2 }}>
                <Typography variant="subtitle2" color="text.secondary" sx={{ flex: 1 }}>{t('ahimsaSilk') || 'Ahimsa Silk (Rs)'}</Typography>
                <TextField size="small" type="number" inputProps={{ style: { textAlign: 'right' } }} value={ahimsaSilkRs} onChange={e => setAhimsaSilkRs(e.target.value)} sx={{ width: '120px' }} />
              </Box>
              
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2 }}>
                <Typography variant="subtitle2" color="text.secondary" sx={{ flex: 1 }}>{t('courier') || 'Courier Charge'}</Typography>
                <TextField size="small" type="number" inputProps={{ style: { textAlign: 'right' } }} value={courierRs} onChange={e => setCourierRs(e.target.value)} sx={{ width: '120px' }} />
              </Box>
              
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 2 }}>
                <TextField size="small" placeholder={t('otherCharges') || 'Other Charges'} value={customChargeName} onChange={e => setCustomChargeName(e.target.value)} sx={{ flex: 1 }} />
                <TextField size="small" type="number" inputProps={{ style: { textAlign: 'right' } }} value={customChargeRs} onChange={e => setCustomChargeRs(e.target.value)} sx={{ width: '120px' }} />
              </Box>
              
              <Divider sx={{ my: 1 }} />
              
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="h6" fontWeight={700}>{t('total') || 'Total'}</Typography>
                <Box sx={{ textAlign: 'right' }}>
                  <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 600, mb: 0.5 }}>{calculateTotalKg().toFixed(3)} Kg</Typography>
                  <Typography variant="h5" color="primary" fontWeight={800}>₹ {calculateGrandTotal().toLocaleString('en-IN')}</Typography>
                </Box>
              </Box>
            </Stack>
          </Box>
        </Box>

      </Box>
    </ElvanEditorLayout>
  );
}
