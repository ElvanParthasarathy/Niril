// @ts-nocheck
import { Plus, X, Trash, Eye, Copy, WhatsappLogo, EnvelopeSimple, FileText, PencilSimple, CheckSquare, Square } from '@phosphor-icons/react';
import React, { useState, useEffect, useRef } from 'react';
import { useTheme } from '@mui/material/styles';
import {
  Box, Typography, Button, IconButton, Tooltip, Chip, Stack,
  Paper, Pagination, Toolbar, Dialog, DialogTitle, DialogContent, DialogActions
} from '@mui/material';
import { getAllBills, deleteBill, saveBill, getProfile } from '../../Avanam';
import { formatCurrency, INVOICE_TYPES, getCountryConfig } from '../../Payanpadu';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import { getSearchPaperSx, searchInputStyle, getAddButtonSx, getEditPaperSx, getEditIconButtonSx } from '../commonStyles';
import ElvanCard from '../ElvanCard';

export default function InvoiceList({ onView, onDuplicate, onNew, profile }) {
  const { t } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const [bills, setBills] = useState([]);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [isSelectionMode, setIsSelectionMode] = useState(false);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [confirmDialog, setConfirmDialog] = useState<{ open: boolean; title: string; message: string; action: (() => void) | null }>({ open: false, title: '', message: '', action: null });
  const topRef = useRef<HTMLDivElement>(null);

  const profileCurrency = getCountryConfig(profile?.country || 'India').currency;

  const loadData = async () => {
    try {
      const b = await getAllBills();
      setBills(b);
    } catch {
      thagaval('Failed to load invoices', 'error');
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleDeleteBill = async (id) => {
    if (confirm(t('deleteInvoiceConfirm') || 'Are you sure you want to delete this invoice?')) {
      try { await deleteBill(id); thagaval(t('invoiceDeleted') || 'Invoice deleted', 'success'); loadData(); }
      catch { thagaval(t('failedToDelete') || 'Failed to delete', 'error'); }
    }
  };

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

  const filteredBills = bills.filter(b =>
    !search.trim() ||
    (b.clientName || '').toLowerCase().includes(search.toLowerCase()) ||
    b.invoiceNumber.toLowerCase().includes(search.toLowerCase())
  ).sort((a, b) => new Date(b.invoiceDate).getTime() - new Date(a.invoiceDate).getTime());

  const ITEMS_PER_PAGE = 6;
  const totalPages = Math.ceil(filteredBills.length / ITEMS_PER_PAGE);
  const safePage = Math.max(1, Math.min(page, totalPages === 0 ? 1 : totalPages));
  const paginatedBills = filteredBills.slice((safePage - 1) * ITEMS_PER_PAGE, safePage * ITEMS_PER_PAGE);

  const handleSelectAll = () => {
    if (selectedIds.length === paginatedBills.length) {
      setSelectedIds([]);
    } else {
      setSelectedIds(paginatedBills.map(b => b.id));
    }
  };

  const toggleSelection = (id: string) => {
    setSelectedIds(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  const handleCopySelected = () => {
    setConfirmDialog({
      open: true,
      title: t('duplicateProductsTitle') || 'Duplicate Invoices?',
      message: t('duplicateProductsMessage') || 'Are you sure you want to create copies of the selected invoice(s)?',
      action: async () => {
        try {
          const selected = bills.filter(b => selectedIds.includes(b.id));
          for (const b of selected) {
            const { id, ...rest } = b;
            await saveBill({ ...rest, invoiceNumber: `${b.invoiceNumber} (Copy)` });
          }
          thagaval(t('productsDuplicatedSuccess') || 'Invoices duplicated successfully', 'success');
          setSelectedIds([]);
          setIsSelectionMode(false);
          loadData();
        } catch (e) {
          thagaval(t('errorDuplicating') || 'Error duplicating', 'error');
        }
      }
    });
  };

  const handleDeleteSelected = () => {
    setConfirmDialog({
      open: true,
      title: t('deleteProductsTitle') || 'Delete Invoices?',
      message: t('deleteProductsMessage') || 'Are you sure you want to delete the selected invoice(s)? This action cannot be undone.',
      action: async () => {
        try {
          for (const id of selectedIds) {
            await deleteBill(id);
          }
          thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
          setSelectedIds([]);
          setIsSelectionMode(false);
          loadData();
        } catch (e) {
          thagaval(t('errorDeleting') || 'Error deleting', 'error');
        }
      }
    });
  };

  return (
    <Box ref={topRef} sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto' }}>
      <Box sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h5" sx={{ fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary', ml: 2 }}>
          {t('invoicesCount') || 'Invoices'}
        </Typography>
      </Box>

      <Box sx={{ mb: 4 }}>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
          <Paper elevation={1} className="vanigargal-search" sx={getSearchPaperSx(isDark)}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, opacity: 0.5 }}>
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
            <input
              type="text"
              placeholder={t('searchInvoices') || 'Search invoices...'}
              value={search}
              onChange={e => { setSearch(e.target.value); setPage(1); }}
              style={searchInputStyle}
            />
            {search && (
              <IconButton size="small" onClick={() => { setSearch(''); setPage(1); }} sx={{ flexShrink: 0 }}>
                <X size={14} weight="regular" />
              </IconButton>
            )}
          </Paper>

          <Paper
            elevation={1}
            sx={getEditPaperSx(isDark, isSelectionMode)}
          >
            <IconButton
              onClick={() => { setIsSelectionMode(!isSelectionMode); setSelectedIds([]); }}
              sx={getEditIconButtonSx(isDark)}
            >
              <PencilSimple size={18} weight={isSelectionMode ? 'fill' : 'regular'} color={isDark ? '#fff' : '#000'} />
            </IconButton>
          </Paper>
          <Button variant="contained" sx={getAddButtonSx(isDark)} onClick={onNew} startIcon={<Plus size={18} weight="bold" />}>
            {t('newInvoiceBtn') || 'New Invoice'}
          </Button>
        </Box>
      </Box>

      {isSelectionMode && (
        <Toolbar
          component={Paper}
          elevation={1}
          variant="dense"
          sx={{
            boxShadow: 'none',
            pl: { sm: 2 },
            pr: { xs: 1, sm: 1 },
            mt: 0,
            minHeight: '48px !important',
            mb: 4,
            borderRadius: '24px',
            bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF',
          }}
        >
          <IconButton onClick={handleSelectAll} color="primary" sx={{ mr: 1 }}>
            {selectedIds.length > 0 && selectedIds.length === paginatedBills.length ? <CheckSquare size={24} weight="fill" /> : <Square size={24} />}
          </IconButton>

          <Typography sx={{ flex: '1 1 100%', fontWeight: 600, display: 'flex', alignItems: 'center', lineHeight: 1, mt: 0.3 }} color="primary" variant="subtitle1" component="div">
            {selectedIds.length} {t('selected') || 'Selected'}
          </Typography>

          <Stack direction="row" spacing={1}>
            <Tooltip title={t('saveDuplicate') || 'Copy / Duplicate'}>
              <IconButton onClick={handleCopySelected} color="primary">
                <Copy size={20} />
              </IconButton>
            </Tooltip>
            <Tooltip title={t('delete') || 'Delete'}>
              <IconButton onClick={handleDeleteSelected} color="error">
                <Trash size={20} />
              </IconButton>
            </Tooltip>
          </Stack>
        </Toolbar>
      )}

      {filteredBills.length === 0 ? (
        <ElvanCard boxSx={{ p: 6, textAlign: 'center' }}>
          <Box color="text.secondary" mb={2}>
            <FileText size={48} weight="regular" style={{ opacity: 0.5 }} />
          </Box>
          <Typography color="text.secondary" mb={2}>{bills.length === 0 ? (t('noInvoicesYet') || 'No invoices yet') : (t('noInvoicesMatch') || 'No invoices match your search')}</Typography>
          {bills.length === 0 && (
            <Button variant="outlined" color="inherit" sx={{ borderRadius: '50px', textTransform: 'none' }} onClick={onNew} startIcon={<Plus size={16} weight="regular" />}>
              {t('createInvoiceBtn') || 'Create Invoice'}
            </Button>
          )}
        </ElvanCard>
      ) : (
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 2 }}>
          {paginatedBills.map((bill, index) => {
            const globalIndex = (safePage - 1) * ITEMS_PER_PAGE + index;
            const isSelected = selectedIds.includes(bill.id);
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
                      <Tooltip title="Duplicate">
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
          })}
        </Box>
      )}

      {totalPages > 1 && (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
          <Pagination
            count={totalPages}
            page={safePage}
            onChange={(e, val) => {
              setPage(val);
              if (topRef.current) {
                topRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
              }
            }}
            color="primary"
            size="large"
            sx={{
              '& .MuiPaginationItem-root': {
                fontWeight: 600,
              }
            }}
          />
        </Box>
      )}

      {/* Confirmation Dialog */}
      <Dialog open={confirmDialog.open} onClose={() => setConfirmDialog(prev => ({ ...prev, open: false }))} PaperProps={{ sx: { borderRadius: 3 } }}>
        <DialogTitle sx={{ fontWeight: 700 }}>{confirmDialog.title}</DialogTitle>
        <DialogContent>
          <Typography color="text.secondary">{confirmDialog.message}</Typography>
        </DialogContent>
        <DialogActions sx={{ p: 2, pt: 0 }}>
          <Button onClick={() => setConfirmDialog(prev => ({ ...prev, open: false }))} sx={{ borderRadius: 50, textTransform: 'none' }}>
            {t('cancelModalBtn') || 'Cancel'}
          </Button>
          <Button
            onClick={() => {
              if (confirmDialog.action) confirmDialog.action();
              setConfirmDialog(prev => ({ ...prev, open: false }));
            }}
            variant="contained"
            color={confirmDialog.title.includes('Delete') ? 'error' : 'primary'}
            sx={{ borderRadius: 50, textTransform: 'none', px: 3 }}
          >
            {t('confirmModalBtn') || 'Confirm'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
