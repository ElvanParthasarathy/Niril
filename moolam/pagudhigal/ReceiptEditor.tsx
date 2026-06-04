// @ts-nocheck
import { ArrowLeft, FloppyDisk } from '@phosphor-icons/react';
import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Button, Paper, TextField, InputAdornment, 
  Grid, Select, MenuItem, InputLabel, FormControl, Stack, Autocomplete, IconButton 
} from '@mui/material';
import { saveReceipt, getAllBills, getReceiptNumberSettings, getAllReceipts } from '../Avanam';
import { formatCurrency, getCountryConfig } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';

const PAYMENT_MODES = ['Bank Transfer', 'UPI', 'Cash', 'Cheque', 'Card', 'Other'];

export default function ReceiptEditor({ profile, onBack, onSaved }: { profile: any, onBack: () => void, onSaved: () => void }) {
  const { t } = useLanguage();
  const profileCurrency = getCountryConfig(profile?.country || 'India').currency;
  
  const [form, setForm] = useState({
    date: new Date().toISOString().split('T')[0],
    receiptNo: '',
    clientName: '',
    clientNameEn: '',
    clientAddress: '',
    amount: '',
    paymentMode: '',
    referenceNo: '',
    againstInvoice: '',
    note: '',
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
      clientName: bill.clientName || '',
      clientNameEn: bill.clientNameEn || bill.data?.client?.nameEn || '',
      clientAddress: bill.data?.client?.mugavari || '',
      amount: String(bill.status === 'paid' ? (bill.paidAmount || bill.totalAmount) : Math.max(0, bill.totalAmount - (bill.paidAmount || 0))),
      againstInvoice: bill.invoiceNumber || '',
    }));
  };

  const handleSave = async () => {
    if (!form.clientName.trim()) { thagaval(t('clientNameRequiredToast') || 'Client name is required', 'warning'); return; }
    if (!form.amount || parseFloat(form.amount) <= 0) { thagaval(t('enterValidAmountToast') || 'Enter valid amount', 'warning'); return; }
    if (!form.paymentMode) { thagaval(t('paymentModeLabel') + ' is required', 'warning'); return; }
    try {
      const receipt = {
        ...form,
        referenceNo: form.paymentMode === 'Cash' ? '' : form.referenceNo,
        amount: parseFloat(form.amount),
      };
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
    
    const primaryVal = (dictionaries[primaryLang] || {})[mode] || mode;
    const secondaryVal = (dictionaries[secondaryLang] || {})[mode] || mode;
    
    if (profile?.enableBilingual !== false && primaryVal !== secondaryVal) {
      return `${primaryVal} (${secondaryVal})`;
    }
    return primaryVal;
  };

  return (
    <Box sx={{ p: { xs: 2, md: 4 }, maxWidth: 800, mx: 'auto' }}>
      <Stack direction="row" alignItems="center" spacing={2} mb={4}>
        <IconButton onClick={onBack} sx={{ bgcolor: 'white', border: '1px solid', borderColor: 'divider' }}>
          <ArrowLeft size={20} weight="regular" />
        </IconButton>
        <Typography variant="h4" color="text.primary" sx={{ fontWeight: "bold" }}>
          {t('newPaymentReceiptTitle')}
        </Typography>
      </Stack>

      <Paper sx={{ p: 4, borderRadius: 3, border: '1px solid', borderColor: 'divider' }} elevation={0}>
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
              fullWidth size="small" label={t('receiptNoLabel')} 
              value={form.receiptNo} onChange={e => updateField('receiptNo', e.target.value)} 
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField 
              fullWidth size="small" label={t('dateLabel')} type="date"
              value={form.date} onChange={e => updateField('date', e.target.value)} 
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 12, sm: profile?.enableBilingual !== false ? 6 : 12 }}>
            <TextField 
              fullWidth size="small" label={t('receivedFromLabel')} 
              value={form.clientName} onChange={e => updateField('clientName', e.target.value)} 
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          {profile?.enableBilingual !== false && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField 
                fullWidth size="small" label="Received From (English)" 
                value={form.clientNameEn || ''} onChange={e => updateField('clientNameEn', e.target.value)} 
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
          )}
          <Grid size={{ xs: 12, sm: 6 }}>
            <TextField 
              fullWidth size="small" label={t('amountLabelStar')} type="number"
              value={form.amount} onChange={e => updateField('amount', e.target.value)} slotProps={{ input: { startAdornment: <InputAdornment position="start">{profileCurrency}</InputAdornment> } }}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 12, sm: 6 }}>
            <FormControl fullWidth size="small">
              <InputLabel shrink>{t('paymentModeLabel')}</InputLabel>
              <Select value={form.paymentMode} onChange={e => updateField('paymentMode', e.target.value)} label={t('paymentModeLabel')} displayEmpty>
                <MenuItem value=""><em>{t('paymentModeLabel')}...</em></MenuItem>
                {PAYMENT_MODES.map(m => <MenuItem key={m} value={m}>{renderPaymentModeOption(m)}</MenuItem>)}
              </Select>
            </FormControl>
          </Grid>
          {form.paymentMode !== 'Cash' && (
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField 
                fullWidth size="small" label={t('referenceNoLabel')} 
                value={form.referenceNo} onChange={e => updateField('referenceNo', e.target.value)} 
                InputLabelProps={{ shrink: true }}
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
              getOptionLabel={(option) => typeof option === 'string' ? option : `${option.invoiceNumber} - ${option.clientName}`}
              value={bills.find(b => b.invoiceNumber === form.againstInvoice) || form.againstInvoice}
              onChange={(_, newValue) => {
                if (typeof newValue === 'object' && newValue !== null) {
                  selectInvoice(newValue);
                } else {
                  updateField('againstInvoice', newValue || '');
                }
              }}
              onInputChange={(_, newInputValue) => {
                updateField('againstInvoice', newInputValue);
              }}
              renderInput={(params) => (
                <TextField 
                  {...params}
                  fullWidth size="small" 
                  label={t('againstInvoiceLabel')} 
                  placeholder={t('againstInvoicePlaceholder')}
                  InputLabelProps={params.InputLabelProps}
                />
              )}
            />
          </Grid>
          <Grid size={{ xs: 12 }}>
            <TextField 
              fullWidth size="small" label={t('noteOptionalLabel')} multiline rows={2}
              value={form.note} onChange={e => updateField('note', e.target.value)} 
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
        </Grid>

        <Box sx={{ mt: 4, pt: 3, borderTop: '1px solid', borderColor: 'divider', display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
          <Button onClick={onBack} variant="outlined" color="inherit" sx={{ borderRadius: 50, textTransform: 'none', px: 3 }}>
            {t('cancelModalBtn')}
          </Button>
          <Button onClick={handleSave} variant="contained" startIcon={<FloppyDisk size={18} weight="regular" />} sx={{ borderRadius: 50, textTransform: 'none', px: 4, bgcolor: '#0f172a', '&:hover': { bgcolor: '#1e293b' } }}>
            {t('saveReceiptBtn')}
          </Button>
        </Box>
      </Paper>
    </Box>
  );
}
