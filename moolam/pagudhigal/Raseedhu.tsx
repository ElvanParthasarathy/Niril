// @ts-nocheck
import Receipt from '@mui/icons-material/Receipt';
import Add from '@mui/icons-material/Add';
import Delete from '@mui/icons-material/Delete';
import Search from '@mui/icons-material/Search';
import Print from '@mui/icons-material/Print';
import Close from '@mui/icons-material/Close';
import React, { useState, useEffect, useRef } from 'react';
import { 
  Box, Typography, Button, Paper, TextField, InputAdornment, 
  IconButton, Tooltip, TableContainer, Table, TableHead, TableRow, 
  TableCell, TableBody, Chip, Grid, Select, MenuItem, InputLabel, 
  FormControl, Stack, Dialog, DialogTitle, DialogContent, DialogActions, Autocomplete
} from '@mui/material';
import { getAllReceipts, saveReceipt, deleteReceipt, getAllBills, getProfile, getReceiptNumberSettings } from '../Avanam';
import { formatCurrency, numberToWords, getCountryConfig } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';

const PAYMENT_MODES = ['Bank Transfer', 'UPI', 'Cash', 'Cheque', 'Card', 'Other'];

export default function Raseedhu({ profile: parentProfile, onAddReceipt }: { profile?: any, onAddReceipt?: () => void } = {}) {
  const { t } = useLanguage();
  const [receipts, setReceipts] = useState<any[]>([]);
  const [bills, setBills] = useState<any[]>([]);
  const [localProfile, setLocalProfile] = useState<any>({});
  const profile = parentProfile || localProfile;
  const [search, setSearch] = useState('');
  const [previewReceipt, setPreviewReceipt] = useState<any>(null);
  const receiptRef = useRef<HTMLDivElement>(null);
  
  const profileCurrency = getCountryConfig(profile?.country || 'India').currency;

  const renderLabel = (enLabel: string, taLabel: string) => profile?.enableBilingual !== false ? `${taLabel} / ${enLabel}` : enLabel;
  const renderPaymentMode = (mode: string) => {
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
      return `${primaryVal} / ${secondaryVal}`;
    }
    return primaryVal;
  };

  const getDisplayClientNameEn = (rcp: any) => {
    if (!rcp) return '';
    if (rcp.clientNameEn) return rcp.clientNameEn;
    if (rcp.againstInvoice) {
      const linkedBill = bills.find(b => b.invoiceNumber === rcp.againstInvoice);
      if (linkedBill) {
        return linkedBill.clientNameEn || linkedBill.data?.client?.nameEn || linkedBill.data?.client?.peyarEn || '';
      }
    }
    return '';
  };

  const loadData = async () => {
    try {
      const [recs, bls, prof] = await Promise.all([getAllReceipts(), getAllBills(), getProfile()]);
      setReceipts(recs || []);
      setBills(bls || []);
      setLocalProfile(prof || {});
    } catch {
      thagaval('Failed to load data', 'error');
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const openAdd = () => {
    if (onAddReceipt) onAddReceipt();
  };

  const filtered = search.trim()
    ? receipts.filter(r =>
        (r.clientName || '').toLowerCase().includes(search.toLowerCase()) ||
        (r.receiptNo || '').toLowerCase().includes(search.toLowerCase()))
    : receipts;

  const handleDelete = async (id: string) => {
    if (confirm(t('deleteReceiptConfirmMsg') || 'Delete this receipt?')) {
      try { await deleteReceipt(id); thagaval(t('deletedToast') || 'Deleted!', 'success'); loadData(); }
      catch { thagaval('Failed to delete', 'error'); }
    }
  };

  const executePrint = () => {
    if (!previewReceipt) return;
    const el = receiptRef.current;
    if (!el) return;
    const printWindow = window.open('', '_blank');
    if (!printWindow) return;
    printWindow.document.write(`
      <html><head><title>Receipt ${previewReceipt.receiptNo}</title>
      <style>
        body { font-family: 'Inter', Arial, sans-serif; margin: 0; padding: 2rem; color: #1a1a2e; }
        .receipt-box { max-width: 600px; margin: 0 auto; border: 2px solid #e2e8f0; border-radius: 8px; padding: 2rem; }
        .receipt-header { text-align: center; margin-bottom: 1.5rem; border-bottom: 2px solid #e2e8f0; padding-bottom: 1rem; }
        .receipt-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0; }
        .receipt-subtitle { font-size: 0.8rem; color: #64748b; margin: 0.25rem 0 0; }
        .receipt-row { display: flex; justify-content: space-between; padding: 0.5rem 0; font-size: 0.9rem; border-bottom: 1px solid #f1f5f9; }
        .receipt-label { color: #64748b; font-weight: 500; }
        .receipt-value { color: #1e293b; font-weight: 600; }
        .receipt-amount { font-size: 1.5rem; font-weight: 800; color: #1e40af; text-align: center; margin: 1.5rem 0; padding: 1rem; background: #eff6ff; border-radius: 8px; }
        .receipt-words { font-size: 0.85rem; color: #334155; font-style: italic; text-align: center; margin-bottom: 1.5rem; }
        .receipt-footer { display: flex; justify-content: space-between; margin-top: 3rem; padding-top: 1rem; }
        .receipt-sig { text-align: center; }
        .receipt-sig-line { width: 180px; border-bottom: 1.5px solid #1e293b; margin-bottom: 0.25rem; }
        .receipt-sig-label { font-size: 0.75rem; color: #64748b; }
        .business-name { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.25rem; }
        .business-details { font-size: 0.75rem; color: #64748b; }
        @media print { body { margin: 0; } .receipt-box { border: none; } }
      </style></head><body>
      ${el.innerHTML}
      <script>window.print(); window.close();</script>
      </body></html>
    `);
    printWindow.document.close();
  };

  const unpaidBills = bills.filter(b => b.status !== 'paid');

  return (
    <Box sx={{ p: { xs: 1.5, md: 4 }, maxWidth: 1200, mx: 'auto' }}>
      <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="space-between" alignItems={{ xs: 'flex-start', sm: 'center' }} mb={4} spacing={2}>
        <Box>
          <Typography variant="h4" color="text.primary" sx={{ fontWeight: "bold" }}>
            {t('receipts')}
          </Typography>
          <Typography variant="body1" color="text.secondary">
            {t('receiptsSubtitle')}
          </Typography>
        </Box>
        <Button variant="contained" startIcon={<Add sx={{ fontSize: 18 }} />} onClick={openAdd} sx={{ borderRadius: 50, px: 3, textTransform: 'none', py: 1.5, bgcolor: '#0f172a', '&:hover': { bgcolor: '#1e293b' } }}>
          {t('newReceiptBtn')}
        </Button>
      </Stack>

      {/* Receipt Preview Modal */}
      {previewReceipt && (
        <Dialog open={Boolean(previewReceipt)} onClose={() => setPreviewReceipt(null)} maxWidth="md" fullWidth PaperProps={{ sx: { borderRadius: 3 } }}>
          <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 3, pb: 2 }}>
            <Typography variant="h6" sx={{ fontWeight: "bold" }}>{t('receiptPreview') || 'Receipt Preview'}</Typography>
            <IconButton onClick={() => setPreviewReceipt(null)} size="small"><Close sx={{ fontSize: 20 }} /></IconButton>
          </DialogTitle>
          <DialogContent dividers sx={{ p: 0, bgcolor: '#f8fafc', display: 'flex', justifyContent: 'center' }}>
            <style>{`
              .receipt-box { width: 100%; max-width: 600px; margin: 2rem auto; border: 2px solid #e2e8f0; border-radius: 8px; padding: 2rem; background: white; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); }
              .receipt-header { text-align: center; margin-bottom: 1.5rem; border-bottom: 2px solid #e2e8f0; padding-bottom: 1rem; }
              .receipt-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0; }
              .receipt-subtitle { font-size: 0.8rem; color: #64748b; margin: 0.25rem 0 0; }
              .receipt-row { display: flex; justify-content: space-between; padding: 0.5rem 0; font-size: 0.9rem; border-bottom: 1px solid #f1f5f9; }
              .receipt-label { color: #64748b; font-weight: 500; }
              .receipt-value { color: #1e293b; font-weight: 600; }
              .receipt-amount { font-size: 1.5rem; font-weight: 800; color: #1e40af; text-align: center; margin: 1.5rem 0; padding: 1rem; background: #eff6ff; border-radius: 8px; }
              .receipt-words { font-size: 0.85rem; color: #334155; font-style: italic; text-align: center; margin-bottom: 1.5rem; }
              .receipt-footer { display: flex; justify-content: space-between; margin-top: 3rem; padding-top: 1rem; }
              .receipt-sig { text-align: center; }
              .receipt-sig-line { width: 180px; border-bottom: 1.5px solid #1e293b; margin-bottom: 0.25rem; }
              .receipt-sig-label { font-size: 0.75rem; color: #64748b; }
              .business-name { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.25rem; }
              .business-details { font-size: 0.75rem; color: #64748b; }
            `}</style>
            <div ref={receiptRef} style={{ width: '100%', padding: '1rem' }}>
              <div className="receipt-box">
                <div className="receipt-header">
                  {profile.logo && <img src={profile.logo} alt="Logo" style={{ maxHeight: '80px', marginBottom: '1rem' }} />}
                  <p className="business-name" style={{ lineHeight: '1.4' }}>
                    {profile.niruvanathinPeyar || 'Your Business'}
                    {profile.enableBilingual !== false && profile.niruvanathinPeyarEn && (
                      <><br /><span style={{ fontSize: '0.9rem', color: '#475569', fontWeight: 600 }}>{profile.niruvanathinPeyarEn}</span></>
                    )}
                  </p>
                  
                  <p className="business-details">
                    {[profile.mugavari, profile.oor, profile.maavattam, profile.maanilam, profile.pin].filter(Boolean).join(', ')}
                  </p>
                  
                  {profile.enableBilingual !== false && (profile.mugavariEn || profile.oorEn || profile.maavattamEn || profile.maanilamEn) && (
                    <p className="business-details" style={{ marginTop: '2px' }}>
                      {[profile.mugavariEn, profile.oorEn, profile.maavattamEn, profile.maanilamEn, profile.pin].filter(Boolean).join(', ')}
                    </p>
                  )}
                  
                  <p className="business-details" style={{ marginTop: '4px' }}>
                    {profile.tholaipesi && <span>Phone: {profile.tholaipesi}</span>}
                    {profile.tholaipesi && profile.gstin && <span> | </span>}
                    {profile.gstin && <span>GSTIN: {profile.gstin}</span>}
                  </p>

                  {profile.enableBilingual !== false ? (
                    <div style={{ textAlign: 'center', marginTop: '1.5rem', marginBottom: '1.5rem' }}>
                      <h2 className="receipt-title" style={{ margin: 0, padding: 0 }}>பண ரசீது</h2>
                      <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#64748b', marginTop: '2px', letterSpacing: '0.05em' }}>PAYMENT RECEIPT</div>
                    </div>
                  ) : (
                    <h2 className="receipt-title" style={{ marginTop: '1.5rem', marginBottom: '1.5rem' }}>PAYMENT RECEIPT</h2>
                  )}
                </div>
                <div className="receipt-row"><span className="receipt-label">{renderLabel('Receipt No:', 'ரசீது எண்:')}</span><span className="receipt-value">{previewReceipt.receiptNo}</span></div>
                <div className="receipt-row"><span className="receipt-label">{renderLabel('Date:', 'தேதி:')}</span><span className="receipt-value">{new Date(previewReceipt.date).toLocaleDateString('en-IN')}</span></div>
                <div className="receipt-row"><span className="receipt-label">{renderLabel('Received From:', 'பெறப்பட்டது:')}</span><span className="receipt-value">{previewReceipt.clientName}{profile?.enableBilingual !== false && getDisplayClientNameEn(previewReceipt) ? ` / ${getDisplayClientNameEn(previewReceipt)}` : ''}</span></div>
                <div className="receipt-row"><span className="receipt-label">{renderLabel('Payment Mode:', 'செலுத்தும் முறை:')}</span><span className="receipt-value">{renderPaymentMode(previewReceipt.paymentMode)}</span></div>
                {previewReceipt.referenceNo && <div className="receipt-row"><span className="receipt-label">{renderLabel('Reference No:', 'குறிப்பு எண்:')}</span><span className="receipt-value">{previewReceipt.referenceNo}</span></div>}
                {previewReceipt.againstInvoice && <div className="receipt-row"><span className="receipt-label">{renderLabel('Against Invoice:', 'விலைப்பட்டியலுக்கு எதிராக:')}</span><span className="receipt-value">{previewReceipt.againstInvoice}</span></div>}
                <div className="receipt-amount">{formatCurrency(previewReceipt.amount, profileCurrency)}</div>
                <p className="receipt-words">{numberToWords(previewReceipt.amount, profile?.primaryDataLanguage || 'English', profile?.secondaryDataLanguage || 'English', profile?.enableBilingual !== false)}</p>
                {previewReceipt.note && <p style={{ fontSize: '0.85rem', color: '#64748b' }}>{renderLabel('Note:', 'குறிப்பு:')} {previewReceipt.note}</p>}
                <div className="receipt-footer">
                  <div className="receipt-sig"><div className="receipt-sig-line"></div><span className="receipt-sig-label">{renderLabel('Received By', 'பெற்றவர்')}</span></div>
                  <div className="receipt-sig"><div className="receipt-sig-line"></div><span className="receipt-sig-label">{renderLabel('Authorized Signatory', 'அங்கீகரிக்கப்பட்ட கையொப்பம்')}</span></div>
                </div>
              </div>
            </div>
          </DialogContent>
          <DialogActions sx={{ p: 3 }}>
            <Button onClick={() => setPreviewReceipt(null)} variant="outlined" sx={{ borderRadius: 50, px: 3, textTransform: 'none' }}>{t('cancelModalBtn') || 'Cancel'}</Button>
            <Button onClick={executePrint} variant="contained" startIcon={<Print sx={{ fontSize: 18 }} />} sx={{ borderRadius: 50, px: 4, textTransform: 'none', bgcolor: '#0f172a', '&:hover': { bgcolor: '#1e293b' } }}>Print Receipt</Button>
          </DialogActions>
        </Dialog>
      )}

      {/* Search */}
      <Paper elevation={0} sx={{ p: 2, mb: 4, borderRadius: 3, border: '1px solid', borderColor: 'divider', display: 'flex', alignItems: 'center' }}>
        <TextField
          fullWidth
          variant="outlined"
          size="small"
          placeholder={t('searchReceipts')}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          sx={{ maxWidth: 400, '& fieldset': { border: 'none' } }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <Search sx={{ fontSize: 20 }} htmlColor="#94a3b8" />
              </InputAdornment>
            ),
          }}
        />
      </Paper>

      {/* Receipts Table */}
      <Paper elevation={0} sx={{ borderRadius: 3, border: '1px solid', borderColor: 'divider', overflow: 'hidden' }}>
        <Box sx={{ p: 3, borderBottom: '1px solid', borderColor: 'divider' }}>
          <Typography variant="h6" sx={{ fontWeight: "bold" }}>{t('paymentReceiptsTableTitle')}</Typography>
        </Box>
        
        {filtered.length === 0 ? (
          <Box sx={{ p: 8, textAlign: 'center' }}>
            <Receipt sx={{ fontSize: 64 }} htmlColor="#cbd5e1" style={{ margin: '0 auto', marginBottom: '16px' }} />
            <Typography variant="h6" color="text.secondary" gutterBottom>
              {receipts.length === 0 ? t('noReceiptsYet') : t('noReceiptsMatch')}
            </Typography>
            {receipts.length === 0 && (
              <Button variant="contained" startIcon={<Add sx={{ fontSize: 18 }} />} onClick={openAdd} sx={{ mt: 2, borderRadius: 50, px: 3, textTransform: 'none', bgcolor: '#0f172a' }}>
                {t('createReceiptBtn')}
              </Button>
            )}
          </Box>
        ) : (
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell sx={{ fontWeight: 'bold' }}>{t('dateLabel')}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>{t('receiptNoLabel')}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>{t('clientCol') || 'Client'}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>{t('againstInvoiceLabel')}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }} align="right">{t('amountCol') || 'Amount'}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }}>{t('modeCol') || 'Mode'}</TableCell>
                  <TableCell sx={{ fontWeight: 'bold' }} align="right">{t('actionsCol') || 'Actions'}</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filtered.map(rcp => (
                  <TableRow key={rcp.id} hover sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
                    <TableCell color="text.secondary">
                      {rcp.date ? new Date(rcp.date).toLocaleDateString('en-IN') : '-'}
                    </TableCell>
                    <TableCell>
                      <Chip label={rcp.receiptNo} size="small" sx={{ borderRadius: 1, fontWeight: 'bold', bgcolor: '#f1f5f9' }} />
                    </TableCell>
                    <TableCell sx={{ fontWeight: 500 }}>
                      {rcp.clientName}
                      {profile?.enableBilingual !== false && getDisplayClientNameEn(rcp) && (
                        <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>
                          {getDisplayClientNameEn(rcp)}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      {rcp.againstInvoice ? (
                        <Typography variant="body2" color="text.secondary">{rcp.againstInvoice}</Typography>
                      ) : (
                        <Typography variant="body2" color="text.disabled">-</Typography>
                      )}
                    </TableCell>
                    <TableCell align="right" sx={{ fontWeight: 'bold' }}>
                      {formatCurrency(rcp.amount, profileCurrency)}
                    </TableCell>
                    <TableCell>
                      <Chip label={rcp.paymentMode} size="small" variant="outlined" sx={{ borderRadius: 50 }} />
                    </TableCell>
                    <TableCell align="right">
                      <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
                        <Tooltip title="Preview" arrow>
                          <IconButton size="small" onClick={() => setPreviewReceipt(rcp)} color="primary">
                            <Print sx={{ fontSize: 18 }} />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Delete" arrow>
                          <IconButton size="small" onClick={() => handleDelete(rcp.id)} color="error">
                            <Delete sx={{ fontSize: 18 }} />
                          </IconButton>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Paper>
    </Box>
  );
}
