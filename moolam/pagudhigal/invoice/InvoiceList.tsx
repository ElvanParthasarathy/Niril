// @ts-nocheck
import Description from '@mui/icons-material/Description';
import Search from '@mui/icons-material/Search';
import Close from '@mui/icons-material/Close';
import Visibility from '@mui/icons-material/Visibility';
import ContentCopy from '@mui/icons-material/ContentCopy';
import WhatsApp from '@mui/icons-material/WhatsApp';
import Email from '@mui/icons-material/Email';
import Delete from '@mui/icons-material/Delete';
import Add from '@mui/icons-material/Add';
import { useState, useEffect } from 'react';
import { getAllBills, deleteBill, saveBill, getProfile } from '../../Avanam';
import { formatCurrency, INVOICE_TYPES } from '../../Payanpadu';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import { 
  Box, Typography, Button, TextField, InputAdornment, IconButton, 
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow, 
  Paper, Select, MenuItem, Chip, Tooltip, useTheme, Fab, Stack, Divider, Card, CardContent
} from '@mui/material';

export default function InvoiceList({ onView, onDuplicate, onNew, profile }) {
  const { t } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const [bills, setBills] = useState([]);
  const [search, setSearch] = useState('');

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
    const msg = `*Invoice ${bill.invoiceNumber}*\nAmount: ${formatCurrency(bill.totalAmount)}\nDate: ${new Date(bill.invoiceDate).toLocaleDateString('en-IN')}`;
    const encoded = encodeURIComponent(msg);
    const waUrl = tholaipesi ? `https://api.whatsapp.com/send?phone=${tholaipesi}&text=${encoded}` : `https://api.whatsapp.com/send?text=${encoded}`;
    window.location.href = waUrl;
  };

  const shareEmail = (bill) => {
    const subject = `Invoice ${bill.invoiceNumber}`;
    const body = `Dear ${bill.clientName || 'Customer'},\n\nPlease find the details of your invoice:\n\nInvoice No: ${bill.invoiceNumber}\nAmount: ${formatCurrency(bill.totalAmount)}\nDate: ${new Date(bill.invoiceDate).toLocaleDateString('en-IN')}\n\nRegards`;
    window.open(`mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`, '_blank');
  };

  const filteredBills = bills.filter(b => 
    !search.trim() || 
    (b.clientName || '').toLowerCase().includes(search.toLowerCase()) || 
    b.invoiceNumber.toLowerCase().includes(search.toLowerCase())
  ).sort((a, b) => new Date(b.invoiceDate).getTime() - new Date(a.invoiceDate).getTime()).reverse();

  return (
    <Box sx={{ p: { xs: 1.5, sm: 3 }, maxWidth: 1200, margin: '0 auto' }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h4" fontWeight="bold" color="primary.main">
            {t('invoicesCount') || 'Invoices'}
          </Typography>
          <Typography variant="body1" color="text.secondary">
            {t('overviewOfInvoices') || 'Manage all generated bills'}
          </Typography>
        </Box>
        <Button variant="contained" startIcon={<Add sx={{ fontSize: 18 }} />} onClick={onNew} sx={{ display: { xs: 'none', sm: 'inline-flex' } }}>
          {t('newInvoiceBtn') || 'New Invoice'}
        </Button>
      </Box>

      {/* Mobile FAB */}
      <Fab 
        color="primary" 
        onClick={onNew} 
        sx={{ 
          position: 'fixed', bottom: 24, right: 24, 
          display: { xs: 'flex', sm: 'none' }, zIndex: 1000,
          bgcolor: isDark ? 'white' : 'black', color: isDark ? 'black' : 'white',
          '&:hover': { bgcolor: isDark ? '#e5e5e5' : '#333' }
        }}
      >
        <Add />
      </Fab>

      <Paper sx={{ p: 2, mb: 3 }}>
        <TextField
          fullWidth
          placeholder={t('searchInvoices') || 'Search bills...'}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          variant="outlined"
          size="small"
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <Search sx={{ fontSize: 18 }} />
              </InputAdornment>
            ),
            endAdornment: search ? (
              <InputAdornment position="end">
                <IconButton size="small" onClick={() => setSearch('')}>
                  <Close sx={{ fontSize: 16 }} />
                </IconButton>
              </InputAdornment>
            ) : null
          }}
        />
      </Paper>

      <Paper>
        {filteredBills.length === 0 ? (
          <Box sx={{ p: 6, textAlign: 'center' }}>
            <Description sx={{ fontSize: 48 }} htmlColor="#94a3b8" />
            <Typography variant="h6" color="text.secondary" sx={{ mt: 2 }}>
              {search ? 'No invoices found for your search.' : (t('noInvoicesYet') || 'No invoices found.')}
            </Typography>
            {!search && (
              <Button variant="contained" startIcon={<Add sx={{ fontSize: 16 }} />} sx={{ mt: 2 }} onClick={onNew}>
                {t('createInvoiceBtn') || 'Create Invoice'}
              </Button>
            )}
          </Box>
        ) : (
          <>
            {/* Mobile Cards View (xs only) */}
            <Box sx={{ display: { xs: 'block', sm: 'none' }, p: 2, bgcolor: isDark ? '#000' : '#f8f9fa' }}>
              {filteredBills.map(bill => {
                return (
                  <Card key={bill.id} sx={{ mb: 2, borderRadius: 4, border: '1px solid', borderColor: 'divider', boxShadow: '0 2px 8px rgba(0,0,0,0.05)', bgcolor: 'background.paper' }}>
                    <CardContent sx={{ p: 2.5, '&:last-child': { pb: 2.5 } }}>
                      <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={1.5}>
                        <Box sx={{ width: '100%' }}>
                          <Typography variant="subtitle1" fontWeight={700} noWrap>{bill.clientName || '-'}</Typography>
                          <Typography variant="caption" color="text.secondary">{new Date(bill.invoiceDate).toLocaleDateString('en-IN')}</Typography>
                        </Box>
                      </Stack>
                      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
                        <Chip size="small" label={bill.invoiceNumber} sx={{ fontWeight: 600, borderRadius: '999px', bgcolor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)' }} />
                        <Typography variant="h6" fontWeight={800}>
                          {formatCurrency(bill.totalAmount)}
                        </Typography>
                      </Stack>
                      <Divider sx={{ mb: 1.5 }} />
                      <Stack direction="row" spacing={1} justifyContent="space-between" alignItems="center">
                        <Chip label={t(`invoiceTypes_${(bill.invoiceType || 'tax-invoice').replace(/-/g, '_')}`, { defaultValue: INVOICE_TYPES[bill.invoiceType || 'tax-invoice']?.label })} size="small" variant="outlined" sx={{ borderRadius: '999px', borderColor: 'divider', fontSize: '0.7rem' }} />
                        <Stack direction="row" spacing={0.5}>
                          {bill.data && <IconButton size="small" color="primary" onClick={() => onView(bill)}><Visibility sx={{ fontSize: 16 }} /></IconButton>}
                          <IconButton size="small" color="primary" onClick={() => onDuplicate(bill)}><ContentCopy sx={{ fontSize: 16 }} /></IconButton>
                          <IconButton size="small" color="success" onClick={() => shareWhatsApp(bill)}><WhatsApp sx={{ fontSize: 16 }} /></IconButton>
                          <IconButton size="small" color="primary" onClick={() => shareEmail(bill)}><Email sx={{ fontSize: 16 }} /></IconButton>
                          <IconButton size="small" color="error" onClick={() => handleDeleteBill(bill.id)}><Delete sx={{ fontSize: 16 }} /></IconButton>
                        </Stack>
                      </Stack>
                    </CardContent>
                  </Card>
                );
              })}
            </Box>

            {/* Desktop Table View (sm and up) */}
            <TableContainer sx={{ display: { xs: 'none', sm: 'block' } }}>
              <Table sx={{ minWidth: 850 }} size="small">
                <TableHead>
                  <TableRow sx={{ bgcolor: isDark ? 'rgba(255,255,255,0.02)' : 'grey.100' }}>
                    <TableCell>{t('dateCol') || 'Date'}</TableCell>
                  <TableCell>{t('invoiceNoCol') || 'Invoice No.'}</TableCell>
                  <TableCell>Client Name</TableCell>
                  <TableCell>{t('typeCol') || 'Type'}</TableCell>
                  <TableCell align="right">{t('amountCol') || 'Amount'}</TableCell>
                  <TableCell align="center">{t('actionsCol') || 'Actions'}</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredBills.map(bill => {
                  return (
                    <TableRow key={bill.id} hover>
                      <TableCell sx={{ color: 'text.secondary' }}>
                        {new Date(bill.invoiceDate).toLocaleDateString('en-IN')}
                      </TableCell>
                      <TableCell>
                        <Chip label={bill.invoiceNumber} size="small" variant="outlined" />
                      </TableCell>
                      <TableCell>
                        <Box sx={{ maxWidth: 220, overflow: 'hidden' }}>
                          <Typography variant="body2" fontWeight={600} noWrap title={bill.clientName || '-'}>
                            {bill.clientName || '-'}
                          </Typography>
                          {profile?.enableBilingual !== false && (bill.clientNameEn || bill.data?.client?.nameEn) && (
                            <Typography variant="caption" color="text.secondary" noWrap sx={{ display: 'block', fontWeight: 'normal' }} title={bill.clientNameEn || bill.data?.client?.nameEn}>
                              {bill.clientNameEn || bill.data?.client?.nameEn}
                            </Typography>
                          )}
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Chip 
                          label={t(`invoiceTypes_${(bill.invoiceType || 'tax-invoice').replace(/-/g, '_')}`, { defaultValue: INVOICE_TYPES[bill.invoiceType || 'tax-invoice']?.label })} 
                          size="small" 
                          color="primary" 
                          variant="outlined" 
                        />
                      </TableCell>
                      <TableCell align="right" sx={{ fontWeight: 'bold' }}>{formatCurrency(bill.totalAmount)}</TableCell>
                      <TableCell align="center">
                        <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'center' }}>
                          {bill.data && (
                            <Tooltip title="View Invoice">
                              <IconButton size="small" color="primary" onClick={() => onView(bill)}>
                                <Visibility sx={{ fontSize: 16 }} />
                              </IconButton>
                            </Tooltip>
                          )}
                          <Tooltip title="Duplicate Invoice">
                            <IconButton size="small" color="primary" onClick={() => onDuplicate(bill)}>
                              <ContentCopy sx={{ fontSize: 16 }} />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="WhatsApp">
                            <IconButton size="small" color="success" onClick={() => shareWhatsApp(bill)}>
                              <WhatsApp sx={{ fontSize: 16 }} />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="Email">
                            <IconButton size="small" color="primary" onClick={() => shareEmail(bill)}>
                              <Email sx={{ fontSize: 16 }} />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="Delete Invoice">
                            <IconButton size="small" color="error" onClick={() => handleDeleteBill(bill.id)}>
                              <Delete sx={{ fontSize: 16 }} />
                            </IconButton>
                          </Tooltip>
                        </Box>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
          </>
        )}
      </Paper>
    </Box>
  );
}
