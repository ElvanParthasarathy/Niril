// @ts-nocheck
import { Users, MagnifyingGlass, FileText, CaretDown, CaretUp, Trash, X, WhatsappLogo, EnvelopeSimple, Plus, PencilSimple, Copy, UploadSimple, CheckSquare, Square, ListDashes } from '@phosphor-icons/react';
import { useState, useEffect, useRef } from 'react';
import { getAllClients, getAllBills, deleteClient, saveClient, deleteBill, saveBill, getProfile } from '../Avanam';
import { formatCurrency, INVOICE_TYPES } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import { Button, TextField, InputAdornment, IconButton, Typography, Box, Stack, Card, Avatar, Paper, useTheme, Toolbar, Tooltip, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, alpha, Pagination } from '@mui/material';
import { getSearchPaperSx, searchInputStyle, getEditPaperSx, getEditIconButtonSx, getAddButtonSx } from './commonStyles';
import ElvanCard from './ElvanCard';

const STATUS_COLORS = {
  unpaid: { label: 'Unpaid', color: '#f59e0b', bg: '#fffbeb' },
  partial: { label: 'Partial', color: '#8b5cf6', bg: '#f5f3ff' },
  paid: { label: 'Paid', color: '#059669', bg: '#ecfdf5' },
  overdue: { label: 'Overdue', color: '#dc2626', bg: '#fef2f2' },
};

export default function Vanigargal({ onEdit, onDuplicate, onNew, onAddClient, onEditClient, profile }) {
  const { t } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const [clients, setClients] = useState([]);
  const [bills, setBills] = useState([]);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [isSelectionMode, setIsSelectionMode] = useState(false);
  const [selectedClientIds, setSelectedClientIds] = useState([]);
  const [copyConfirmOpen, setCopyConfirmOpen] = useState(false);
  const [confirmDialog, setConfirmDialog] = useState({ open: false, title: '', message: '', action: null });
  const topRef = useRef(null);

  const [expandedClient, setExpandedClient] = useState(null);
  const profileCountry = profile?.country || 'India';
  const profileSettings = { primary: profile?.primaryDataLanguage || 'Tamil', secondary: profile?.secondaryDataLanguage || 'English', bilingual: profile?.enableBilingual !== false };



  const loadData = async () => {
    try {
      const [c, b] = await Promise.all([getAllClients(), getAllBills()]);
      setClients(c);
      setBills(b);
    } catch {
      thagaval('Failed to load data', 'error');
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  // Group bills by client name
  const getClientBills = (clientName) => {
    return bills.filter(b => (b.clientName || '').toLowerCase() === clientName.toLowerCase())
      .sort((a, b) => new Date(b.invoiceDate).getTime() - new Date(a.invoiceDate).getTime());
  };

  const getClientStats = (clientName) => {
    const cBills = getClientBills(clientName);
    const total = cBills.reduce((s, b) => s + (b.totalAmount || 0), 0);
    const paid = cBills.reduce((s, b) => {
      if (b.status === 'paid') return s + (b.totalAmount || 0);
      if (b.status === 'partial') return s + (b.paidAmount || 0);
      return s;
    }, 0);
    const unpaid = total - paid;
    return { total, paid, unpaid, count: cBills.length };
  };

  const filteredClients = clients.filter(c => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    const searchable = [
      c.name, c.nameEn, c.gstin, c.tholaipesi, c.email, 
      c.mugavari, c.mugavariEn, c.oor, c.oorEn, c.pin, 
      c.maanilam, c.maanilamEn, c.country
    ].filter(Boolean).join(' ').toLowerCase();
    return searchable.includes(term);
  });
  const ITEMS_PER_PAGE = 6;
  const totalPages = Math.ceil(filteredClients.length / ITEMS_PER_PAGE);
  const safePage = Math.max(1, Math.min(page, totalPages === 0 ? 1 : totalPages));
  const paginatedClients = filteredClients.slice((safePage - 1) * ITEMS_PER_PAGE, safePage * ITEMS_PER_PAGE);

  const handleDeleteClient = (id) => {
    setConfirmDialog({
      open: true,
      title: 'Delete Merchant?',
      message: t('removeSavedClientConfirm'),
      action: async () => {
        await deleteClient(id);
        thagaval(t('clientRemoved'), 'success');
        loadData();
      }
    });
  };

  const handleDeleteBill = (id) => {
    setConfirmDialog({
      open: true,
      title: 'Delete Invoice?',
      message: t('deleteInvoiceConfirm'),
      action: async () => {
        try { await deleteBill(id); thagaval(t('invoiceDeleted'), 'success'); loadData(); }
        catch { thagaval(t('failedToDelete'), 'error'); }
      }
    });
  };

  const changeStatus = async (bill, newStatus) => {
    const updated = { ...bill, status: newStatus };
    if (newStatus === 'paid') updated.paidAmount = bill.totalAmount;
    await saveBill(updated);
    thagaval(`Marked as ${STATUS_COLORS[newStatus]?.label || newStatus}`, 'info');
    loadData();
  };

  const openAddClient = (prefill) => {
    onAddClient(prefill || null);
  };

  const openEditClient = (client) => {
    onEditClient(client);
  };



  const shareWhatsApp = (bill) => {
    const tholaipesi = bill.clientPhone ? bill.clientPhone.replace(/\D/g, '') : '';
    const msg = `*Invoice ${bill.invoiceNumber}*\nAmount: ${formatCurrency(bill.totalAmount)}\nDate: ${new Date(bill.invoiceDate).toLocaleDateString('en-IN')}\nStatus: ${(bill.status || 'unpaid').toUpperCase()}`;
    const encoded = encodeURIComponent(msg);

    const waUrl = tholaipesi ? `https://api.whatsapp.com/send?tholaipesi=${tholaipesi}&text=${encoded}` : `https://api.whatsapp.com/send?text=${encoded}`;
    window.location.href = waUrl;
  };

  const shareEmail = (bill) => {
    const subject = `Invoice ${bill.invoiceNumber}`;
    const body = `Dear ${bill.clientName},\n\nPlease find the details of your invoice:\n\nInvoice No: ${bill.invoiceNumber}\nAmount: ${formatCurrency(bill.totalAmount)}\nDate: ${new Date(bill.invoiceDate).toLocaleDateString('en-IN')}\nDue: ${bill.status === 'paid' ? 'Paid' : 'Pending'}\n\nRegards`;
    window.open(`mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`, '_blank');
  };



  const handleSelectAll = () => {
    if (selectedClientIds.length === filteredClients.length) {
      setSelectedClientIds([]);
    } else {
      setSelectedClientIds(filteredClients.map(c => c.id));
    }
  };

  const handleCopySelected = () => {
    if (selectedClientIds.length === 0) return;
    setCopyConfirmOpen(true);
  };

  const executeCopy = async () => {
    try {
      const selected = clients.filter(c => selectedClientIds.includes(c.id));
      for (const client of selected) {
        const { id, ...rest } = client;
        await saveClient({ ...rest, name: `${client.name} (Copy)` });
      }
      setSelectedClientIds([]);
      setCopyConfirmOpen(false);
      loadData();
      thagaval(t('customersDuplicatedSuccess') || 'Customers duplicated successfully', 'success');
    } catch (e) {
      thagaval(t('errorDuplicating') || 'Error duplicating customers', 'error');
    }
  };

  const handleDeleteSelected = () => {
    if (selectedClientIds.length === 0) return;
    setConfirmDialog({
      open: true,
      title: t('deleteMerchantsTitle') || 'Delete Merchants?',
      message: (t('deleteMerchantsMessage') || 'Are you sure you want to delete {count} merchant(s)? This action cannot be undone.').replace('{count}', selectedClientIds.length.toString()),
      action: async () => {
        try {
          for (const id of selectedClientIds) {
            await deleteClient(id);
          }
          setSelectedClientIds([]);
          setIsSelectionMode(false);
          loadData();
          thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
        } catch (e) {
          thagaval(t('errorDeleting') || 'Error deleting', 'error');
        }
      }
    });
  };

  const toggleSelection = (id) => {
    if (selectedClientIds.includes(id)) {
      setSelectedClientIds(selectedClientIds.filter(i => i !== id));
    } else {
      setSelectedClientIds([...selectedClientIds, id]);
    }
  };

  return (
    <Box ref={topRef} sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto' }}>
      <Box sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h5" sx={{ fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary', ml: 2 }}>
          {t('merchants')}
        </Typography>
      </Box>

      {/* Search and Selection */}
      <Box sx={{ mb: 4 }}>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
          <Paper
            elevation={1}
            className="vanigargal-search"
            sx={getSearchPaperSx(isDark)}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, opacity: 0.5 }}>
          <circle cx="11" cy="11" r="8" />
          <line x1="21" y1="21" x2="16.65" y2="16.65" />
        </svg>
        <input
          type="text"
          placeholder={t('search')}
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
              onClick={() => { setIsSelectionMode(!isSelectionMode); setSelectedClientIds([]); }}
              sx={getEditIconButtonSx(isDark)}
            >
              <PencilSimple size={18} weight={isSelectionMode ? 'fill' : 'regular'} color={isDark ? '#fff' : '#000'} />
            </IconButton>
          </Paper>
          <Button variant="contained" sx={getAddButtonSx(isDark)} onClick={openAddClient} startIcon={<Plus size={18} weight="bold" />}>
            {t('addClient')}
          </Button>
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
            mt: 3,
            minHeight: '48px !important',
            borderRadius: '24px',
            bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF',
          }}
        >
          <IconButton onClick={handleSelectAll} color="primary" sx={{ mr: 1 }}>
            {selectedClientIds.length === filteredClients.length && filteredClients.length > 0 ? <CheckSquare size={24} weight="fill" /> : <Square size={24} weight="regular" />}
          </IconButton>
          
          <Typography sx={{ flex: '1 1 100%', fontWeight: 600, display: 'flex', alignItems: 'center', lineHeight: 1, mt: 0.3 }} color="primary" variant="subtitle1" component="div">
            {selectedClientIds.length} {t('selected') || 'Selected'}
          </Typography>

          <Stack direction="row" spacing={1}>
            <Tooltip title={t('copyDuplicate') || 'Copy / Duplicate'}>
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
    </Box>

      {filteredClients.length === 0 ? (
        <ElvanCard boxSx={{ p: 6, textAlign: 'center' }}>
          <Box color="text.secondary" mb={2}>
            <Users size={48} weight="regular" style={{ opacity: 0.5 }} />
          </Box>
          <Typography color="text.secondary" mb={2}>{t('noClientsFound')}</Typography>
          <Button variant="outlined" color="inherit" sx={{ borderRadius: '50px', textTransform: 'none' }} onClick={() => openAddClient(null)} startIcon={<Plus size={16} weight="regular" />}>
            {t('addFirstClient')}
          </Button>
        </ElvanCard>
      ) : (
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 2 }}>
          {paginatedClients.map((client, index) => {
              const globalIndex = (safePage - 1) * ITEMS_PER_PAGE + index;
              return (
                <ElvanCard 
                  key={client.id}
                  sx={{ 
                    height: '100%',
                    ...(isSelectionMode && selectedClientIds.includes(client.id) ? { bgcolor: isDark ? 'rgba(255,255,255,0.06) !important' : 'rgba(0,0,0,0.04) !important' } : {})
                  }}
                  onClick={() => isSelectionMode ? toggleSelection(client.id) : openEditClient(client)}
                >
                  <Stack direction="row" justifyContent="space-between" alignItems="center" spacing={2} sx={{ height: '100%' }}>
                    <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start', flex: 1, width: '100%' }}>
                      {!isSelectionMode ? (
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
                      ) : (
                        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 28, height: 28, mt: 0.15, color: selectedClientIds.includes(client.id) ? 'primary.main' : 'text.secondary', flexShrink: 0 }}>
                          {selectedClientIds.includes(client.id) ? <CheckSquare size={24} weight="fill" /> : <Square size={24} weight="regular" />}
                        </Box>
                      )}
                      <Box>
                      <Typography variant="subtitle1" sx={{ fontWeight: "bold" }}>
                        {client.name}
                      </Typography>
                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, color: 'text.secondary', mt: 0.5 }}>
                          {profile?.enableBilingual !== false && client.nameEn && (
                            <Typography variant="body2" sx={{ fontSize: '0.85rem', fontWeight: 500 }}>{client.nameEn}</Typography>
                          )}
                          {client.oor && (
                            <Typography variant="body2" sx={{ fontSize: '0.85rem' }}>
                              {client.oor}{profile?.enableBilingual !== false && client.oorEn ? <span style={{ opacity: 0.6, margin: '0 6px' }}>•</span> : ''}{profile?.enableBilingual !== false && client.oorEn ? client.oorEn : ''}
                            </Typography>
                          )}
                          {client.gstin && (
                            <Typography variant="body2" sx={{ fontSize: '0.85rem', fontWeight: 500, mt: 0.5 }}>
                              GSTIN: {client.gstin}
                            </Typography>
                          )}
                        </Box>
                      </Box>
                    </Box>
                    <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                      {isSelectionMode && (
                        <Tooltip title="Delete">
                          <IconButton color="error" onClick={(e) => { e.stopPropagation(); handleDeleteClient(client.id); }}>
                            <Trash size={20} weight="regular" />
                          </IconButton>
                        </Tooltip>
                      )}
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
      <Dialog open={copyConfirmOpen} onClose={() => setCopyConfirmOpen(false)} PaperProps={{ elevation: 8, sx: { borderRadius: '24px', p: 1 } }}>
        <DialogTitle sx={{ fontWeight: 800 }}>{t('duplicateCustomersTitle') || 'Duplicate Customers?'}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            {(t('duplicateCustomersMessage') || 'Are you sure you want to create copies of the {count} selected customer(s)?').replace('{count}', selectedClientIds.length.toString())}
          </DialogContentText>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setCopyConfirmOpen(false)} color="inherit" sx={{ borderRadius: '50px', textTransform: 'none', px: 3 }}>{t('cancel') || 'Cancel'}</Button>
          <Button onClick={executeCopy} variant="contained" color="primary" sx={{ borderRadius: '50px', textTransform: 'none', px: 3, boxShadow: 'none' }}>{t('saveDuplicate') || 'Save (Duplicate)'}</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={confirmDialog.open} onClose={() => setConfirmDialog({ ...confirmDialog, open: false })} PaperProps={{ elevation: 8, sx: { borderRadius: '24px', p: 1 } }}>
        <DialogTitle sx={{ fontWeight: 800 }}>{confirmDialog.title}</DialogTitle>
        <DialogContent>
          <DialogContentText>{confirmDialog.message}</DialogContentText>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={() => setConfirmDialog({ ...confirmDialog, open: false })} color="inherit" sx={{ borderRadius: '50px', textTransform: 'none', px: 3 }}>{t('cancel') || 'Cancel'}</Button>
          <Button onClick={async () => { await confirmDialog.action(); setConfirmDialog({ ...confirmDialog, open: false }); }} variant="contained" color="primary" sx={{ borderRadius: '50px', textTransform: 'none', px: 3, boxShadow: 'none' }}>{t('delete') || 'Delete'}</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
