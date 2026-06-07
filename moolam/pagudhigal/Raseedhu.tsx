import { X, Receipt as PhosphorReceipt, CheckSquare, Square } from '@phosphor-icons/react';
import React, { useState, useEffect, useRef } from 'react';
import { useTheme } from '@mui/material/styles';
import { Box, Typography, Button, IconButton, Tooltip, Stack, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
import { getAllReceipts, saveReceipt, deleteReceipt, getAllBills, getProfile } from '../Avanam';
import { formatCurrency, numberToWords, getCountryConfig, getDynamicField } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import ElvanCard from './ElvanCard';
import ElvanListView from './ElvanListView';

export default function Raseedhu({ profile: parentProfile, onAddReceipt, onEditReceipt, onViewReceipt }: { profile?: any, onAddReceipt?: () => void, onEditReceipt?: (rcp: any) => void, onViewReceipt?: (rcp: any) => void } = {}) {
  const { t } = useLanguage();
  const [receipts, setReceipts] = useState<any[]>([]);
  const [bills, setBills] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [localProfile, setLocalProfile] = useState<any>({});
  const profile = parentProfile || localProfile;
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
        return linkedBill.clientNameEn || getDynamicField(linkedBill.data?.client, 'name', profile, false) || linkedBill.data?.client?.nameEn || linkedBill.data?.client?.peyarEn || '';
      }
    }
    return '';
  };

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [recs, bls, prof] = await Promise.all([getAllReceipts(), getAllBills(), getProfile()]);
      setReceipts(recs || []);
      setBills(bls || []);
      setLocalProfile(prof || {});
    } catch {
      thagaval('Failed to load data', 'error');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const filterFn = (r, search) => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    const searchable = [
      r.receiptNo, r.clientName, r.clientNameEn, r.paymentMode, 
      r.referenceNo, r.againstInvoice, r.note, r.amount?.toString()
    ].filter(Boolean).join(' ').toLowerCase();
    return searchable.includes(term);
  };

  const handleBulkDelete = async (ids, onProgress) => {
    try {
      let count = 0;
      for (const id of ids) {
        await deleteReceipt(id);
        count++;
        if (onProgress) onProgress(count, ids.length);
      }
      thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
      loadData();
    } catch (e) {
      thagaval(t('errorDeleting') || 'Error deleting', 'error');
    }
  };

  const handleBulkDuplicate = async (ids, onProgress) => {
    try {
      const selected = receipts.filter(r => ids.includes(r.id));
      let count = 0;
      for (const r of selected) {
        const { id, ...rest } = r;
        await saveReceipt({ ...rest, receiptNo: `${r.receiptNo} (Copy)` });
        count++;
        if (onProgress) onProgress(count, selected.length);
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
        onClick={() => isSelectionMode ? toggleSelection(rcp.id) : (onViewReceipt && onViewReceipt(rcp))}
      >
        <Stack direction="row" spacing={2} sx={{ justifyContent: 'space-between', alignItems: 'center', height: '100%' }}>
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
              </Box>
            </Box>
          </Box>
          <Box sx={{ display: 'flex', gap: 1, alignItems: 'flex-end', flexDirection: 'column', alignSelf: 'stretch', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', gap: 0.5, mt: -0.5, mr: -0.5 }}>
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
        isLoading={isLoading}
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
    </>
  );
}
