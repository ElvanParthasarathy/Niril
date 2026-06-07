import React, { useState, useEffect } from 'react';
import { Box, Typography, TextField, Button, Stack, Autocomplete, IconButton, Divider, Select, MenuItem, FormControl, InputLabel, useTheme } from '@mui/material';
import { X, Plus, FloppyDisk } from '@phosphor-icons/react';
import { getAllCoolieClients, getAllCoolieProducts, getAllCoolieProfiles, saveCoolieBill } from '../../Avanam';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import ElvanCard from '../ElvanCard';
import ElvanEditorLayout from '../ElvanEditorLayout';
import { useDraftAndUnsaved } from '../../hooks/useDraftAndUnsaved';

export default function CoolieInvoiceEditor({ onBack, onSaved, existingBill }) {
  const { t, language } = useLanguage();
  const theme = useTheme();
  
  // State from Kananam Coolie Bill
  const [billNo, setBillNo] = useState('');
  const [date, setDate] = useState(new Date().toLocaleDateString('en-GB')); // DD/MM/YYYY
  const [companyId, setCompanyId] = useState('');
  const [customerName, setCustomerName] = useState('');
  const [address, setAddress] = useState('');
  const [city, setCity] = useState('');
  const [items, setItems] = useState([{ porul: '', coolie: '', kg: '', name_english: '', name_tamil: '' }]);
  const [setharamGrams, setSetharamGrams] = useState('');
  const [courierRs, setCourierRs] = useState('');
  const [ahimsaSilkRs, setAhimsaSilkRs] = useState('');
  const [customChargeName, setCustomChargeName] = useState('');
  const [customChargeRs, setCustomChargeRs] = useState('');
  const [bankDetails, setBankDetails] = useState('');
  const [accountNo, setAccountNo] = useState('');
  const [ifsc, setIfsc] = useState('');
  
  // Options
  const [clientOptions, setClientOptions] = useState<any[]>([]);
  const [productOptions, setProductOptions] = useState<any[]>([]);
  const [profileOptions, setProfileOptions] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const formState = {
    billNo, date, companyId, customerName,
    address, city, items, setharamGrams, courierRs, ahimsaSilkRs, customChargeName,
    customChargeRs, bankDetails, accountNo, ifsc
  };

  const setFormState = (s) => {
    if (s.billNo !== undefined) setBillNo(s.billNo);
    if (s.date !== undefined) setDate(s.date);
    if (s.companyId !== undefined) setCompanyId(s.companyId);
    if (s.customerName !== undefined) setCustomerName(s.customerName);
    if (s.address !== undefined) setAddress(s.address);
    if (s.city !== undefined) setCity(s.city);
    if (s.items !== undefined) setItems(s.items);
    if (s.setharamGrams !== undefined) setSetharamGrams(s.setharamGrams);
    if (s.courierRs !== undefined) setCourierRs(s.courierRs);
    if (s.ahimsaSilkRs !== undefined) setAhimsaSilkRs(s.ahimsaSilkRs);
    if (s.customChargeName !== undefined) setCustomChargeName(s.customChargeName);
    if (s.customChargeRs !== undefined) setCustomChargeRs(s.customChargeRs);
    if (s.bankDetails !== undefined) setBankDetails(s.bankDetails);
    if (s.accountNo !== undefined) setAccountNo(s.accountNo);
    if (s.ifsc !== undefined) setIfsc(s.ifsc);
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
          setFormState({
            billNo: existingBill.bill_no || '',
            date: existingBill.date || new Date().toLocaleDateString('en-GB'),
            companyId: existingBill.company_id || (profiles && profiles.length > 0 ? profiles[0].id : ''),
            customerName: existingBill.customer_name || '',
            address: existingBill.address || '',
            city: existingBill.city || '',
            items: existingBill.items && existingBill.items.length > 0 ? existingBill.items : [{ porul: '', coolie: '', kg: '', name_english: '', name_tamil: '' }],
            setharamGrams: existingBill.setharam_grams || '',
            courierRs: existingBill.courier_rs || '',
            ahimsaSilkRs: existingBill.ahimsa_silk_rs || '',
            customChargeName: existingBill.custom_charge_name || '',
            customChargeRs: existingBill.custom_charge_rs || '',
            bankDetails: existingBill.bank_details || '',
            accountNo: existingBill.account_no || '',
            ifsc: existingBill.ifsc || ''
          });
        } else if (profiles && profiles.length > 0) {
          setCompanyId(profiles[0].id);
          const bankName = profiles[0].bankNameTamil || profiles[0].bankName || '';
          const branch = profiles[0].branchTamil || profiles[0].branch || '';
          setBankDetails([bankName, branch].filter(Boolean).join(', '));
          setAccountNo(profiles[0].accountNo || '');
          setIfsc(profiles[0].ifsc || '');
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
      address,
      city,
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
      grand_total: grandTotal
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
      setAddress('');
      setCity('');
      return;
    }
    
    if (typeof val === 'string') {
      setCustomerName(val);
      return;
    }
    
    setCustomerName(val.name || '');
    setAddress(val.address || '');
    setCity(val.city || '');
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
      <Stack spacing={4}>
        {/* Card 1: Invoice Meta & Customer Details */}
        <ElvanCard sx={{ p: 3 }}>
          <Typography variant="h6" sx={{ fontWeight: 700, mb: 3 }}>{t('invoiceDetails') || 'Invoice Details'}</Typography>
          
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr 1fr' }, gap: 3, mb: 4 }}>
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

          <Divider sx={{ mb: 4 }} />

          <Typography variant="subtitle1" sx={{ fontWeight: 700, mb: 2 }}>{t('customer') || 'Customer'}</Typography>
          
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '2fr 1fr 1fr' }, gap: 3, mb: 2 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
              <Autocomplete
                freeSolo
                options={clientOptions}
                getOptionLabel={(option) => typeof option === 'string' ? option : (option.name || '')}
                onChange={handleCustomerSelect}
                renderOption={(props, option) => (
                    <li {...props}>
                        <Box>
                          <Typography variant="body1">{option.name}</Typography>
                          {option.city && <Typography variant="caption" color="text.secondary">{option.city}</Typography>}
                        </Box>
                    </li>
                )}
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
        </ElvanCard>

        {/* Card 2: Items Table */}
        <ElvanCard sx={{ p: { xs: 2, md: 3 } }}>
          <Typography variant="h6" sx={{ fontWeight: 700, mb: 3 }}>{t('itemsList') || 'Items'}</Typography>
          
          <Box sx={{ display: { xs: 'none', md: 'block' } }}>
            <Box sx={{ display: 'grid', gridTemplateColumns: '40% 15% 15% 20% 5%', gap: 2, mb: 2, px: 2 }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>{t('itemName') || 'Item Details'}</Typography>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, textAlign: 'right' }}>{t('quantity') || 'Weight'}</Typography>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, textAlign: 'right' }}>{t('rate') || 'Rate'}</Typography>
              <Typography variant="subtitle2" sx={{ fontWeight: 600, textAlign: 'right' }}>{t('amount') || 'Amount'}</Typography>
            </Box>
            
            {items.map((item, index) => (
              <Box key={index} sx={{ display: 'grid', gridTemplateColumns: '40% 15% 15% 20% 5%', gap: 2, alignItems: 'center', mb: 2, px: 2 }}>
                <Autocomplete
                  freeSolo
                  options={productOptions}
                  getOptionLabel={(option) => typeof option === 'string' ? option : (option.nameTamil || option.nameEnglish || '')}
                  onChange={(e, val) => {
                    const newItems = [...items];
                    if (typeof val === 'string') {
                      newItems[index].porul = val;
                    } else if (val) {
                      newItems[index].porul = val.nameTamil || val.nameEnglish || '';
                      newItems[index].name_tamil = val.nameTamil || '';
                      newItems[index].name_english = val.nameEnglish || '';
                      if (val.rate) newItems[index].coolie = val.rate;
                    } else {
                      newItems[index].porul = '';
                    }
                    setItems(newItems);
                  }}
                  inputValue={item.porul}
                  onInputChange={(e, val) => {
                    const newItems = [...items];
                    newItems[index].porul = val;
                    setItems(newItems);
                  }}
                  renderInput={(params) => <TextField {...params} size="small" placeholder={t('typeItemName') || 'Type Item Name'} />}
                />
                
                <TextField size="small" type="number" inputProps={{ step: '0.001', style: { textAlign: 'right' } }} value={item.kg} onChange={e => { const i = [...items]; i[index].kg = e.target.value; setItems(i); }} />
                <TextField size="small" type="number" inputProps={{ style: { textAlign: 'right' } }} value={item.coolie} onChange={e => { const i = [...items]; i[index].coolie = e.target.value; setItems(i); }} />
                
                <Typography sx={{ textAlign: 'right', fontWeight: 600 }}>{calculateRowTotal(item)}</Typography>
                <IconButton color="error" onClick={() => setItems(items.filter((_, i) => i !== index))}><X size={18} weight="bold" /></IconButton>
              </Box>
            ))}
          </Box>
          
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
                  getOptionLabel={(option) => typeof option === 'string' ? option : (option.nameTamil || option.nameEnglish || '')}
                  onChange={(e, val) => {
                    const newItems = [...items];
                    if (typeof val === 'string') {
                      newItems[index].porul = val;
                    } else if (val) {
                      newItems[index].porul = val.nameTamil || val.nameEnglish || '';
                      newItems[index].name_tamil = val.nameTamil || '';
                      newItems[index].name_english = val.nameEnglish || '';
                      if (val.rate) newItems[index].coolie = val.rate;
                    } else {
                      newItems[index].porul = '';
                    }
                    setItems(newItems);
                  }}
                  inputValue={item.porul}
                  onInputChange={(e, val) => {
                    const newItems = [...items];
                    newItems[index].porul = val;
                    setItems(newItems);
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
          </Box>
          
          <Button startIcon={<Plus />} onClick={() => setItems([...items, { porul: '', coolie: '', kg: '', name_english: '', name_tamil: '' }])} sx={{ mt: 3 }}>
            {t('addAnotherItem') || 'Add Item'}
          </Button>
        </ElvanCard>

        {/* Card 3: Footer Calculations */}
        <Box sx={{ display: 'flex', flexDirection: { xs: 'column', md: 'row' }, gap: 3 }}>
          <ElvanCard sx={{ flex: 1, p: 3 }}>
            <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>{t('bankDetails') || 'Bank Details'}</Typography>
            <Box sx={{ mb: 2 }}>
              <Typography variant="caption" color="text.secondary">{t('bankNamePlace') || 'Bank & Branch'}</Typography>
              <Typography variant="body1" fontWeight={500}>{bankDetails || '-'}</Typography>
            </Box>
            <Box sx={{ mb: 2 }}>
              <Typography variant="caption" color="text.secondary">{t('accountNo') || 'Account Number'}</Typography>
              <Typography variant="body1" fontWeight={500}>{accountNo || '-'}</Typography>
            </Box>
            <Box>
              <Typography variant="caption" color="text.secondary">{t('ifscCode') || 'IFSC Code'}</Typography>
              <Typography variant="body1" fontWeight={500}>{ifsc || '-'}</Typography>
            </Box>
          </ElvanCard>
          
          <ElvanCard sx={{ flex: 1.5, p: 3, bgcolor: theme.palette.mode === 'dark' ? 'background.paper' : '#fcfcfc' }}>
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
                <Typography variant="h6" fontWeight={700}>{t('total') || 'Total Amount'}</Typography>
                <Typography variant="h5" color="primary" fontWeight={800}>₹ {calculateGrandTotal().toLocaleString('en-IN')}</Typography>
              </Box>
            </Stack>
          </ElvanCard>
        </Box>
      </Stack>
    </ElvanEditorLayout>
  );
}
