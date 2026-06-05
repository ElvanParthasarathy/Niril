import { FileText, Copy, WhatsappLogo, EnvelopeSimple, CheckSquare, Square } from '@phosphor-icons/react';
import React, { useState, useEffect } from 'react';
import { useTheme } from '@mui/material/styles';
import { Box, Typography, IconButton, Tooltip, Stack } from '@mui/material';
import { getAllBills, deleteBill, saveBill } from '../../Avanam';
import { formatCurrency, INVOICE_TYPES, getCountryConfig } from '../../Payanpadu';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import ElvanCard from '../ElvanCard';
import ElvanListView from '../ElvanListView';

export default function InvoiceList({ onView, onDuplicate, onNew, profile }) {
  const { t } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const [bills, setBills] = useState([]);

  const profileCurrency = getCountryConfig(profile?.country || 'India').currency;

  const loadData = async () => {
    try {
      const b = await getAllBills();
      // sort bills by date
      setBills(b.sort((a, b) => new Date(b.invoiceDate).getTime() - new Date(a.invoiceDate).getTime()));
    } catch {
      thagaval('Failed to load invoices', 'error');
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const shareWhatsApp = (bill) => {
    const tholaipesi = bill.clientPhone ? bill.clientPhone.replace(/\D/g, '') : '';
    const msg = `*Invoice ${bill.invoiceNumber}*\nAmount: ${formatCurrency(bill.totalAmount, profileCurrency)}\nDate: ${new Date(bill.invoiceDate).toLocaleDateString('en-IN')}`;
    const encoded = encodeURIComponent(msg);
    const waUrl = tholaipesi ? `https://api.whatsapp.com/send?phone=${tholaipesi}&text=${encoded}` : `https://api.whatsapp.com/send?text=${encoded}`;
    window.location.href = waUrl;
  };

  const shareEmail = (bill) => {
    const subject = `Invoice ${bill.invoiceNumber}`;
    const body = `Dear ${bill.clientName || 'Customer'},\n\nPlease find the details of your invoice:\n\nInvoice No: ${bill.invoiceNumber}\nAmount: ${formatCurrency(bill.totalAmount, profileCurrency)}\nDate: ${new Date(bill.invoiceDate).toLocaleDateString('en-IN')}\n\nRegards`;
    window.open(`mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`, '_blank');
  };

  const filterFn = (b, search) => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    const itemsText = b.items ? b.items.map((i) => `${i.name || ''} ${i.nameEn || ''}`).join(' ') : '';
    const searchable = [
      b.invoiceNumber, b.clientName, b.clientNameEn, b.clientPhone, b.clientEmail, b.clientGstin,
      b.totalAmount?.toString(), b.status, b.invoiceType, b.poNumber, itemsText
    ].filter(Boolean).join(' ').toLowerCase();
    return searchable.includes(term);
  };

  const handleBulkDelete = async (ids) => {
    try {
      for (const id of ids) {
        await deleteBill(id);
      }
      thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
      loadData();
    } catch (e) {
      thagaval(t('errorDeleting') || 'Error deleting', 'error');
    }
  };

  const handleBulkDuplicate = async (ids) => {
    try {
      const selected = bills.filter(b => ids.includes(b.id));
      for (const b of selected) {
        const { id, ...rest } = b;
        await saveBill({ ...rest, invoiceNumber: `${b.invoiceNumber} (Copy)` });
      }
      thagaval(t('productsDuplicatedSuccess') || 'Invoices duplicated successfully', 'success');
      loadData();
    } catch (e) {
      thagaval(t('errorDuplicating') || 'Error duplicating', 'error');
    }
  };

  const renderCard = (bill, globalIndex, isSelectionMode, isSelected, toggleSelection) => {
    const invoiceTypeKey = (bill.invoiceType || 'tax-invoice').replace(/-/g, '_');
    const invoiceTypeLabel = t(`invoiceTypes_${invoiceTypeKey}`, { defaultValue: INVOICE_TYPES[bill.invoiceType || 'tax-invoice']?.label });
    
    return (
      <ElvanCard
        key={bill.id}
        sx={{
          height: '100%',
          cursor: 'pointer',
          ...(isSelectionMode && isSelected ? { bgcolor: isDark ? 'rgba(255,255,255,0.06) !important' : 'rgba(0,0,0,0.04) !important' } : {})
        }}
        onClick={() => isSelectionMode ? toggleSelection(bill.id) : (onView && onView(bill))}
      >
        <Stack direction="row" justifyContent="space-between" alignItems="center" spacing={2} sx={{ height: '100%' }}>
          <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start', flex: 1, width: '100%' }}>
            {isSelectionMode ? (
              <IconButton
                size="small"
                onClick={(e) => { e.stopPropagation(); toggleSelection(bill.id); }}
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
                {bill.clientName || '-'}
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, color: 'text.secondary', mt: 0.5 }}>
                {profile?.enableBilingual !== false && (bill.clientNameEn || bill.data?.client?.nameEn) && (
                  <Typography variant="body2" sx={{ fontSize: '0.85rem', fontWeight: 500 }}>{bill.clientNameEn || bill.data?.client?.nameEn}</Typography>
                )}
                <Typography variant="body2" sx={{ fontSize: '0.85rem', mt: 0.5 }}>
                  {bill.invoiceNumber} <span style={{ opacity: 0.6, margin: '0 6px' }}>•</span> {bill.invoiceDate ? new Date(bill.invoiceDate).toLocaleDateString('en-IN') : '-'}
                </Typography>
                <Typography variant="body2" sx={{ fontSize: '0.85rem', mt: 0.5 }}>
                  {invoiceTypeLabel}
                </Typography>
              </Box>
            </Box>
          </Box>
          <Box sx={{ display: 'flex', gap: 1, alignItems: 'flex-end', flexDirection: 'column', alignSelf: 'stretch', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', gap: 0.5, mt: -0.5, mr: -0.5 }}>
              <Tooltip title={t('saveDuplicate') || 'Duplicate'}>
                <IconButton size="small" onClick={(e) => { e.stopPropagation(); onDuplicate(bill); }} color="primary">
                  <Copy size={18} weight="regular" />
                </IconButton>
              </Tooltip>
              <Tooltip title="WhatsApp">
                <IconButton size="small" onClick={(e) => { e.stopPropagation(); shareWhatsApp(bill); }} sx={{ color: '#25D366' }}>
                  <WhatsappLogo size={18} weight="regular" />
                </IconButton>
              </Tooltip>
              <Tooltip title="Email">
                <IconButton size="small" onClick={(e) => { e.stopPropagation(); shareEmail(bill); }} color="primary">
                  <EnvelopeSimple size={18} weight="regular" />
                </IconButton>
              </Tooltip>
            </Box>
            <Typography variant="subtitle1" color="primary.main" sx={{ fontWeight: 800 }}>
              {formatCurrency(bill.totalAmount, profileCurrency)}
            </Typography>
          </Box>
        </Stack>
      </ElvanCard>
    );
  };

  return (
    <ElvanListView 
      title={t('invoicesCount') || 'Invoices'}
      searchPlaceholder={t('search') || 'Search...'}
      addButtonText={t('newInvoiceBtn') || 'New Invoice'}
      onAdd={() => onNew()}
      items={bills}
      filterFn={filterFn}
      renderCard={renderCard}
      emptyIcon={<FileText size={48} weight="regular" style={{ opacity: 0.5 }} />}
      emptyText={bills.length === 0 ? (t('noInvoicesYet') || 'No invoices yet') : (t('noInvoicesMatch') || 'No invoices match your search')}
      onDeleteSelected={handleBulkDelete}
      onDuplicateSelected={handleBulkDuplicate}
      deleteConfirmTitle={t('deleteProductsTitle') || 'Delete Invoices?'}
      deleteConfirmMessage={() => t('deleteProductsMessage') || 'Are you sure you want to delete the selected invoice(s)? This action cannot be undone.'}
      duplicateConfirmTitle={t('duplicateProductsTitle') || 'Duplicate Invoices?'}
      duplicateConfirmMessage={() => t('duplicateProductsMessage') || 'Are you sure you want to create copies of the selected invoice(s)?'}
    />
  );
}
