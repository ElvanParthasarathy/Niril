import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Paper, TextField, InputAdornment, 
  Grid, MenuItem, Stack, Autocomplete 
} from '@mui/material';
import { saveReceipt, getAllBills, getReceiptNumberSettings, getAllReceipts } from '../Avanam';
import { formatCurrency, getCountryConfig, getDynamicField } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import ElvanEditorLayout from './ElvanEditorLayout';
import ElvanBilingualField from './ElvanBilingualField';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import dayjs from 'dayjs';

const PAYMENT_MODES = ['Bank Transfer', 'UPI', 'Cash', 'Cheque', 'Card', 'Other'];

export default function ReceiptEditor({ profile, onBack, onSaved, editingReceipt }: { profile: any, onBack: () => void, onSaved: () => void, editingReceipt?: any }) {
  const { t } = useLanguage();
  const profileCurrency = getCountryConfig(profile?.country || 'India').currency;
  const currencySymbol = getCountryConfig(profile?.country || 'India').currencySymbol || profileCurrency;
  
  const primaryLang = profile?.primaryDataLanguage || 'Tamil';
  const secondaryLang = profile?.secondaryDataLanguage || 'English';
  
  const [form, setForm] = useState({
    id: editingReceipt?.id || '',
    date: editingReceipt?.date || new Date().toISOString().split('T')[0],
    receiptNo: editingReceipt?.receiptNo || '',
    [`clientName_${primaryLang}`]: editingReceipt?.clientName || '',
    [`clientName_${secondaryLang}`]: editingReceipt?.clientNameEn || '',
    clientAddress: editingReceipt?.clientAddress || '',
    amount: editingReceipt?.amount?.toString() || '',
    paymentMode: editingReceipt?.paymentMode || '',
    referenceNo: editingReceipt?.referenceNo || '',
    againstInvoice: editingReceipt?.againstInvoice || '',
    note: editingReceipt?.note || '',
  });

  const [bills, setBills] = useState<any[]>([]);
  const unpaidBills = bills.filter(b => b.status !== 'paid');

  useEffect(() => {
    const init = async () => {
      try {
        const [recs, bls, settings] = await Promise.all([
          getAllReceipts(),
          getAllBills(),
          getReceiptNumberSettings()
        ]);
        setBills(bls || []);
        
        if (!editingReceipt) {
          // Generate new receipt number
          const count = (recs || []).length + (settings.startNumber || 1);
          const pfx = settings.brandPrefix || 'RCP';
          const sep = settings.separator || '/';
          const padded = String(count).padStart(settings.padDigits || 4, '0');
          let nextNo = `${pfx}${sep}${padded}`;
          
          if (settings.format === 'random') {
            nextNo = `${pfx}${sep}${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
          } else if (settings.showFinYear) {
            const yr = new Date().getFullYear();
            const ny = (yr + 1).toString().slice(-2);
            nextNo = `${pfx}${sep}${yr}-${ny}${sep}${padded}`;
          }
          
          setForm(prev => ({ ...prev, receiptNo: nextNo }));
        }
      } catch (err) {
        console.error(err);
      }
    };
    init();
  }, []);

  const updateField = (field: string, value: any) => setForm(prev => ({ ...prev, [field]: value }));

  const selectInvoice = (bill: any) => {
    setForm(prev => ({
      ...prev,
      [`clientName_${primaryLang}`]: getDynamicField(bill.data?.client, 'name', profile, true) || '',
      [`clientName_${secondaryLang}`]: getDynamicField(bill.data?.client, 'name', profile, false) || '',
      clientAddress: getDynamicField(bill.data?.client, 'mugavari', profile, true) || bill.data?.client?.mugavari || '',
      amount: String(bill.status === 'paid' ? (bill.paidAmount || bill.totalAmount) : Math.max(0, bill.totalAmount - (bill.paidAmount || 0))),
      againstInvoice: bill.invoiceNumber || '',
    }));
  };

  const handleSave = async () => {
    if (!form[`clientName_${primaryLang}`]?.trim()) { thagaval(t('clientNameRequiredToast') || 'Client name is required', 'warning'); return; }
    if (!form.amount || parseFloat(form.amount) <= 0) { thagaval(t('enterValidAmountToast') || 'Enter valid amount', 'warning'); return; }
    if (!form.paymentMode) { thagaval(t('paymentModeLabel') + ' is required', 'warning'); return; }
    try {
      const receipt = {
        ...form,
        clientName: form[`clientName_${primaryLang}`] || '',
        clientNameEn: form[`clientName_${secondaryLang}`] || '',
        referenceNo: form.paymentMode === 'Cash' ? '' : form.referenceNo,
        amount: parseFloat(form.amount),
      };
      delete receipt[`clientName_${primaryLang}`];
      delete receipt[`clientName_${secondaryLang}`];
      
      await saveReceipt(receipt);
      thagaval(t('receiptSavedToast') || 'Receipt Saved!', 'success');
      onSaved();
    } catch {
      thagaval('Failed to save', 'error');
    }
  };

  const renderPaymentModeOption = (mode: string) => {
    const dictionaries: Record<string, Record<string, string>> = {
      'Tamil': { 'Cash': 'பணம்', 'UPI': 'UPI', 'Bank Transfer': 'வங்கிப் பரிமாற்றம்', 'Cheque': 'காசோலை', 'Card': 'கார்டு', 'Other': 'மற்றவை' },
      'Hindi': { 'Cash': 'नकद', 'UPI': 'UPI', 'Bank Transfer': 'बैंक ट्रांसफर', 'Cheque': 'चेक', 'Card': 'कार्ड', 'Other': 'अन्य' },
      'Telugu': { 'Cash': 'నగదు', 'UPI': 'UPI', 'Bank Transfer': 'బ్యాంక్ బదిలీ', 'Cheque': 'చెక్', 'Card': 'కార్డు', 'Other': 'ఇతర' },
      'Kannada': { 'Cash': 'ನಗದು', 'UPI': 'UPI', 'Bank Transfer': 'ಬ್ಯಾಂಕ್ ವರ್ಗಾವಣೆ', 'Cheque': 'ಚೆಕ್', 'Card': 'ಕಾರ್ಡ್', 'Other': 'ಇತರ' },
      'Malayalam': { 'Cash': 'പണം', 'UPI': 'UPI', 'Bank Transfer': 'ബാങ്ക് ട്രാൻസ്ഫർ', 'Cheque': 'ചെക്ക്', 'Card': 'കാർഡ്', 'Other': 'മറ്റ്' },
      'Marathi': { 'Cash': 'रोख', 'UPI': 'UPI', 'Bank Transfer': 'बँक ट्रान्सफर', 'Cheque': 'चेक', 'Card': 'कार्ड', 'Other': 'इतर' },
      'Gujarati': { 'Cash': 'રોકડ', 'UPI': 'UPI', 'Bank Transfer': 'બેંક ટ્રાન્સફર', 'Cheque': 'ચેક', 'Card': 'કાર્ડ', 'Other': 'અન્ય' },
      'Bengali': { 'Cash': 'নগদ', 'UPI': 'UPI', 'Bank Transfer': 'ব্যাঙ্ক ট্রান্সফার', 'Cheque': 'চেক', 'Card': 'কার্ড', 'Other': 'অন্য' }
    };
    
    const primaryLang = profile?.primaryDataLanguage || 'Tamil';
    const secondaryLang = profile?.secondaryDataLanguage || 'English';
    const enableBilingual = profile?.enableBilingual !== false;
    
    const primaryVal = (dictionaries[primaryLang] || {})[mode] || mode;
    const secondaryVal = (dictionaries[secondaryLang] || {})[mode] || mode;
    
    if (enableBilingual && (mode !== 'UPI')) {
      return (
        <Box>
          <Typography variant="body1" sx={{ lineHeight: 1.2 }}>{primaryVal}</Typography>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', lineHeight: 1.2, mt: 0.2 }}>{secondaryVal}</Typography>
        </Box>
      );
    }
    
    return primaryVal;
  };

  return (
    <ElvanEditorLayout
      title={(editingReceipt ? (t('editReceiptTitle') || 'Edit Receipt') : t('newPaymentReceiptTitle')) as string}
      onBack={onBack}
      onSave={handleSave}
      saveButtonText={(t('saveReceiptBtn') || 'Save Receipt') as string}
    >
      {unpaidBills.length > 0 && !form.againstInvoice && (
        <Box sx={{ mb: 4 }}>
          <Typography variant="subtitle2" color="primary" sx={{ mb: 2, fontWeight: 'bold' }}>
            {t('quickSelectUnpaid') || 'Quick Select Unpaid Invoices'}
          </Typography>
          <Stack direction="row" spacing={2} sx={{ overflowX: 'auto', pb: 1 }}>
            {unpaidBills.slice(0, 10).map(bill => (
              <Paper 
                key={bill.id} 
                variant="outlined" 
                sx={{ p: 2, minWidth: 200, cursor: 'pointer', '&:hover': { borderColor: 'primary.main', bgcolor: 'primary.50' }, borderRadius: 2 }}
                onClick={() => selectInvoice(bill)}
              >
                <Typography variant="body2" noWrap sx={{ fontWeight: "bold" }}>{bill.clientName}</Typography>
                <Typography variant="caption" color="text.secondary" gutterBottom sx={{ display: "block" }}>{bill.invoiceNumber}</Typography>
                <Typography variant="body1" color="primary" sx={{ fontWeight: "bold" }}>
                  {formatCurrency(bill.totalAmount - (bill.paidAmount || 0), profileCurrency)}
                </Typography>
              </Paper>
            ))}
          </Stack>
        </Box>
      )}

      <Grid container spacing={3}>
        <Grid size={{ xs: 12, sm: 6 }}>
          <TextField 
            fullWidth size="medium" label={t('receiptNoLabel') as string} 
            value={form.receiptNo} onChange={e => updateField('receiptNo', e.target.value)} 
            slotProps={{ inputLabel: { shrink: true } }}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6 }}>
          <LocalizationProvider dateAdapter={AdapterDayjs}>
            <DatePicker
              label={t('dateLabel') as string}
              value={form.date ? dayjs(form.date) : null}
              onChange={(newValue) => updateField('date', newValue ? newValue.format('YYYY-MM-DD') : '')}
              slotProps={{ textField: { fullWidth: true, size: 'medium' } }}
              format="DD/MM/YYYY"
            />
          </LocalizationProvider>
        </Grid>
        <ElvanBilingualField
          label={t('clientName') as string}
          primaryLang={primaryLang}
          secondaryLang={secondaryLang}
          isBilingual={profile?.enableBilingual !== false}
          primaryValue={form[`clientName_${primaryLang}`] || ''}
          onPrimaryChange={e => updateField(`clientName_${primaryLang}`, e.target.value)}
          secondaryValue={form[`clientName_${secondaryLang}`] || ''}
          onSecondaryChange={e => updateField(`clientName_${secondaryLang}`, e.target.value)}
        />
        <Grid size={{ xs: 12, sm: 6 }}>
          <TextField 
            fullWidth size="medium" label={t('amountLabelStar') as string} type="number"
            value={form.amount} onChange={e => updateField('amount', e.target.value)}
            slotProps={{
              input: { startAdornment: <InputAdornment position="start" sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 24, mt: '0 !important' }}>{currencySymbol}</InputAdornment> },
              inputLabel: { shrink: true }
            }}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6 }}>
          <TextField 
            select
            fullWidth size="medium" 
            label={t('paymentModeLabel') as string} 
            value={form.paymentMode} 
            onChange={e => updateField('paymentMode', e.target.value)} 
            slotProps={{ inputLabel: { shrink: true }, select: { displayEmpty: true } }}
          >
            <MenuItem value=""><em>{t('paymentModeLabel')}...</em></MenuItem>
            {PAYMENT_MODES.map(m => <MenuItem key={m} value={m}>{renderPaymentModeOption(m)}</MenuItem>)}
          </TextField>
        </Grid>
        {form.paymentMode !== 'Cash' && (
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField 
              fullWidth size="medium" label={t('referenceNoLabel') as string} 
              value={form.referenceNo} onChange={e => updateField('referenceNo', e.target.value)} 
              slotProps={{ inputLabel: { shrink: true } }}
            />
          </Grid>
        )}
        <Grid size={{ xs: 12, sm: form.paymentMode === 'Cash' ? 12 : 6 }}>
          <Autocomplete
            fullWidth
            freeSolo
            forcePopupIcon={true}
            sx={{ width: '100%', minWidth: 200 }}
            options={bills}
            getOptionLabel={(option) => {
              if (typeof option === 'string') return option;
              const pName = getDynamicField(option.data?.client, 'name', profile, true);
              return pName ? `${option.invoiceNumber} - ${pName}` : option.invoiceNumber;
            }}
            value={bills.find(b => b.invoiceNumber === form.againstInvoice) || form.againstInvoice}
            onChange={(_, newValue) => {
              if (typeof newValue === 'object' && newValue !== null) {
                selectInvoice(newValue);
              } else {
                setForm(prev => ({
                  ...prev,
                  againstInvoice: typeof newValue === 'string' ? newValue : '',
                  [`clientName_${primaryLang}`]: '',
                  [`clientName_${secondaryLang}`]: '',
                  clientAddress: '',
                  amount: ''
                }));
              }
            }}
            onInputChange={(_, newInputValue) => {
              updateField('againstInvoice', newInputValue);
            }}
            renderOption={(props, option) => {
              if (typeof option === 'string') return <li {...props}>{option}</li>;
              const enableBilingual = profile?.enableBilingual !== false;
              
              const primaryName = getDynamicField(option.data?.client, 'name', profile, true);
              const secondaryName = getDynamicField(option.data?.client, 'name', profile, false);
              
              const primaryText = primaryName ? `${option.invoiceNumber} - ${primaryName}` : option.invoiceNumber;
              const secondaryText = secondaryName ? `${option.invoiceNumber} - ${secondaryName}` : option.invoiceNumber;
              
              return (
                <li {...props} key={option.id}>
                  <Box>
                    <Typography variant="body1" sx={{ lineHeight: 1.2 }}>
                      {primaryText}
                    </Typography>
                    {enableBilingual && (
                      <Typography variant="caption" color="text.secondary" sx={{ display: 'block', lineHeight: 1.2, mt: 0.2 }}>
                        {secondaryText}
                      </Typography>
                    )}
                  </Box>
                </li>
              );
            }}
            renderInput={(params) => (
              <TextField 
                {...params}
                fullWidth size="medium" 
                label={t('againstInvoiceLabel') as string} 
                placeholder={t('againstInvoicePlaceholder') as string}
                InputLabelProps={{ shrink: true }}
              />
            )}
          />
        </Grid>
        <Grid size={{ xs: 12 }}>
          <TextField 
            fullWidth size="medium" label={t('noteOptionalLabel') as string} multiline rows={2}
            value={form.note} onChange={e => updateField('note', e.target.value)} 
            slotProps={{ inputLabel: { shrink: true } }}
          />
        </Grid>
      </Grid>
    </ElvanEditorLayout>
  );
}
