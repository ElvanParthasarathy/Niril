import { X, Printer as PrintIcon, Receipt as PhosphorReceipt, CheckSquare, Square } from '@phosphor-icons/react';
import React, { useState, useEffect, useRef } from 'react';
import { useTheme } from '@mui/material/styles';
import { Box, Typography, Button, IconButton, Tooltip, Stack, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
import { getAllReceipts, saveReceipt, deleteReceipt, getAllBills, getProfile } from '../Avanam';
import { formatCurrency, numberToWords, getCountryConfig } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import ElvanCard from './ElvanCard';
import ElvanListView from './ElvanListView';

export default function Raseedhu({ profile: parentProfile, onAddReceipt, onEditReceipt }: { profile?: any, onAddReceipt?: () => void, onEditReceipt?: (rcp: any) => void } = {}) {
  const { t } = useLanguage();
  const [receipts, setReceipts] = useState<any[]>([]);
  const [bills, setBills] = useState<any[]>([]);
  const [localProfile, setLocalProfile] = useState<any>({});
  const profile = parentProfile || localProfile;
  const [previewReceipt, setPreviewReceipt] = useState<any>(null);
  const receiptRef = useRef<HTMLDivElement>(null);
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  
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
    const primaryVal = (dictionaries[primaryLang] || {})[mode] || mode;
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

  const filterFn = (r, search) => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    const searchable = [
      r.receiptNo, r.clientName, r.clientNameEn, r.paymentMode, 
      r.referenceNo, r.againstInvoice, r.note, r.amount?.toString()
    ].filter(Boolean).join(' ').toLowerCase();
    return searchable.includes(term);
  };

  const handleBulkDelete = async (ids) => {
    try {
      for (const id of ids) await deleteReceipt(id);
      thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
      loadData();
    } catch (e) {
      thagaval(t('errorDeleting') || 'Error deleting', 'error');
    }
  };

  const handleBulkDuplicate = async (ids) => {
    try {
      const selected = receipts.filter(r => ids.includes(r.id));
      for (const r of selected) {
        const { id, ...rest } = r;
        await saveReceipt({ ...rest, receiptNo: `${r.receiptNo} (Copy)` });
      }
      thagaval(t('productsDuplicatedSuccess') || 'Receipts duplicated successfully', 'success');
      loadData();
    } catch (e) {
      thagaval(t('errorDuplicating') || 'Error duplicating', 'error');
    }
  };

  const renderCard = (rcp, globalIndex, isSelectionMode, isSelected, toggleSelection) => {
    return (
      <ElvanCard 
        key={rcp.id} 
        sx={{ 
          height: '100%', 
          cursor: 'pointer',
          ...(isSelectionMode && isSelected ? { bgcolor: isDark ? 'rgba(255,255,255,0.06) !important' : 'rgba(0,0,0,0.04) !important' } : {})
        }} 
        onClick={() => isSelectionMode ? toggleSelection(rcp.id) : (onEditReceipt && onEditReceipt(rcp))}
      >
        <Stack direction="row" justifyContent="space-between" alignItems="center" spacing={2} sx={{ height: '100%' }}>
          <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start', flex: 1, width: '100%' }}>
            {isSelectionMode ? (
              <IconButton 
                size="small" 
                onClick={(e) => { e.stopPropagation(); toggleSelection(rcp.id); }} 
                sx={{ color: isSelected ? 'primary.main' : 'text.disabled', p: 0, mt: 0.2 }}
              >
                {isSelected ? <CheckSquare size={24} weight="fill" /> : <Square size={24} />}
              </IconButton>
            ) : (
              <Box sx={{ 
                display: 'flex', alignItems: 'center', justifyContent: 'center', 
                width: 28, height: 28, mt: 0.15, 
                borderRadius: '50%',
                bgcolor: isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)',
                flexShrink: 0
              }}>
                <Typography variant="caption" sx={{ fontWeight: 800, color: isDark ? '#FFFFFF' : '#000000', fontSize: '0.7rem', lineHeight: 1, position: 'relative', top: '1px' }}>
                  {(globalIndex + 1).toString().padStart(2, '0')}
                </Typography>
              </Box>
            )}
            <Box>
              <Typography variant="subtitle1" sx={{ fontWeight: "bold" }}>
                {rcp.clientName}
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, color: 'text.secondary', mt: 0.5 }}>
                {profile?.enableBilingual !== false && getDisplayClientNameEn(rcp) && (
                  <Typography variant="body2" sx={{ fontSize: '0.85rem', fontWeight: 500 }}>{getDisplayClientNameEn(rcp)}</Typography>
                )}
                <Typography variant="body2" sx={{ fontSize: '0.85rem', mt: 0.5 }}>
                  {rcp.receiptNo} <span style={{ opacity: 0.6, margin: '0 6px' }}>•</span> {rcp.date ? new Date(rcp.date).toLocaleDateString('en-IN') : '-'}
                </Typography>
                <Typography variant="body2" sx={{ fontSize: '0.85rem', mt: 0.5 }}>
                  {t('modeCol') || 'Mode'}: {rcp.paymentMode}
                  {rcp.againstInvoice && <><span style={{ opacity: 0.6, margin: '0 6px' }}>•</span> Inv: {rcp.againstInvoice}</>}
                </Typography>
              </Box>
            </Box>
          </Box>
          <Box sx={{ display: 'flex', gap: 1, alignItems: 'flex-end', flexDirection: 'column', alignSelf: 'stretch', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', gap: 0.5, mt: -0.5, mr: -0.5 }}>
              <Tooltip title="Preview">
                <IconButton size="small" onClick={(e) => { e.stopPropagation(); setPreviewReceipt(rcp); }} color="primary">
                  <PrintIcon size={20} weight="regular" />
                </IconButton>
              </Tooltip>
            </Box>
            <Typography variant="subtitle1" color="primary.main" sx={{ fontWeight: 800 }}>
              {formatCurrency(rcp.amount, profileCurrency)}
            </Typography>
          </Box>
        </Stack>
      </ElvanCard>
    );
  };

  return (
    <>
      <ElvanListView 
        title={t('receipts') || 'Receipts'}
        searchPlaceholder={t('search') || 'Search...'}
        addButtonText={t('newReceiptBtn') || 'Add Receipt'}
        onAdd={onAddReceipt ? () => onAddReceipt() : undefined}
        items={receipts}
        filterFn={filterFn}
        renderCard={renderCard}
        emptyIcon={<PhosphorReceipt size={48} weight="regular" style={{ opacity: 0.5 }} />}
        emptyText={receipts.length === 0 ? (t('noReceiptsYet') || 'No receipts yet') : (t('noReceiptsMatch') || 'No receipts match')}
        onDeleteSelected={handleBulkDelete}
        onDuplicateSelected={handleBulkDuplicate}
        deleteConfirmTitle={t('deleteProductsTitle') || 'Delete Receipts?'}
        deleteConfirmMessage={() => t('deleteProductsMessage') || 'Are you sure you want to delete the selected receipt(s)? This action cannot be undone.'}
        duplicateConfirmTitle={t('duplicateProductsTitle') || 'Duplicate Receipts?'}
        duplicateConfirmMessage={() => t('duplicateProductsMessage') || 'Are you sure you want to create copies of the selected receipt(s)?'}
      />

      {/* Receipt Preview Modal */}
      {previewReceipt && (
        <Dialog open={Boolean(previewReceipt)} onClose={() => setPreviewReceipt(null)} maxWidth="md" fullWidth PaperProps={{ sx: { borderRadius: 3 } }}>
          <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 3, pb: 2 }}>
            <Typography variant="h6" sx={{ fontWeight: "bold" }}>{t('receiptPreview') || 'Receipt Preview'}</Typography>
            <IconButton onClick={() => setPreviewReceipt(null)} size="small"><X size={20} /></IconButton>
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
                      <h2 className="receipt-title" style={{ margin: 0, padding: 0 }}>{t('emptyKey')}</h2>
                      <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#64748b', marginTop: '2px', letterSpacing: '0.05em' }}>{t('hc_paymentReceipt')}</div>
                    </div>
                  ) : (
                    <h2 className="receipt-title" style={{ marginTop: '1.5rem', marginBottom: '1.5rem' }}>{t('hc_paymentReceipt')}</h2>
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
            <Button onClick={executePrint} variant="contained" startIcon={<PrintIcon size={18} />} sx={{ borderRadius: 50, px: 4, textTransform: 'none', bgcolor: '#0f172a', '&:hover': { bgcolor: '#1e293b' } }}>Print Receipt</Button>
          </DialogActions>
        </Dialog>
      )}
    </>
  );
}
