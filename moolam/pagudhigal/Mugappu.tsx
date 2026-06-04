// @ts-nocheck
import { CurrencyInr, Receipt, TrendUp, Package, CaretRight } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { getAllBills, getAllProducts, getAllClients } from '../Avanam';
import { formatCurrency, INVOICE_TYPES } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import {
  Box, Typography, Button, Card, CardContent,
  Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, Chip, Stack,
  useTheme, Divider, Avatar
} from '@mui/material';
import ElvanCard from './ElvanCard';

export default function Mugappu({ onViewAll, onNew, onEdit, onDuplicate, onConvert, profile }: any) {
  const { t, language } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';

  const [bills, setBills] = useState([]);
  const [stats, setStats] = useState({ byCurrency: {}, count: 0 });
  const [lowStockProducts, setLowStockProducts] = useState([]);

  const loadBills = async () => {
    try {
      const data = await getAllBills();
      setBills(data);

      const byCurrency = {};
      for (const b of data) {
        const cur = b.currency || b.data?.invoiceOptions?.currency || 'INR';
        if (!byCurrency[cur]) byCurrency[cur] = { total: 0, tax: 0 };
        byCurrency[cur].total += b.totalAmount || 0;
        byCurrency[cur].tax += b.totalTaxAmount || 0;
      }
      setStats({ byCurrency, count: data.length });
    } catch {
      thagaval('Failed to load invoices', 'error');
    }
  };

  useEffect(() => {
    loadBills();
    getAllProducts().then(prods => {
      setLowStockProducts(prods.filter(p => (p.stock ?? 0) <= 5));
    }).catch(() => {});
  }, []);

  const handleView = (bill) => {
    if (bill.data) onEdit(bill);
    else thagaval('No editable data saved for this invoice', 'warning');
  };

  const recentBills = [...bills]
    .sort((a, b) => new Date(b.invoiceDate).getTime() - new Date(a.invoiceDate).getTime())
    .slice(0, 6);

  return (
    <Box sx={{ pt: { xs: 2, md: 4 }, px: { xs: 0, md: 4 }, pb: { xs: 2, md: 4 }, maxWidth: 1200, mx: 'auto' }}>
      {/* Desktop Page Title Area (Creates space at top for future buttons) */}
      <Box sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h5" sx={{ fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary', ml: 2 }}>
          {language === 'ta' ? 'முகப்பு' : 'Dashboard'}
        </Typography>
        {/* Empty Box here ensures future right-aligned items push to the edge */}
        <Box />
      </Box>

      {/* Header */}
      <Box sx={{ display: 'flex', flexDirection: { xs: 'column', sm: 'row' }, justifyContent: 'space-between', alignItems: { xs: 'flex-start', sm: 'center' }, gap: 2, mb: 4 }}>
        <Paper elevation={1} sx={{ 
          display: 'flex', 
          alignItems: 'center',
          bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF', 
          color: isDark ? '#FFFFFF' : '#000000', 
          borderRadius: '999px', 
          p: 1.5,
          pr: 4,
          boxShadow: 'none',
          border: 'none',
          width: { xs: '100%', sm: 'auto' }
        }}>
          <Avatar 
            src={profile?.logo || undefined} 
            sx={{ width: 48, height: 48, mr: 2, bgcolor: isDark ? '#333' : '#eee', color: isDark ? '#fff' : '#000', fontWeight: 'bold' }}
          >
            {(language === 'en' ? (profile?.personNameEn || profile?.personName || profile?.niruvanathinPeyarEn || profile?.niruvanathinPeyar || 'U') : (profile?.personName || profile?.personNameEn || profile?.niruvanathinPeyar || profile?.niruvanathinPeyarEn || 'U')).charAt(0).toUpperCase()}
          </Avatar>
          <Box sx={{ display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" sx={{ fontWeight: 800, letterSpacing: '-0.02em', lineHeight: 1.2 }}>
              {language === 'ta' ? 'வணக்கம்! ✨' : 'Vanakkam! ✨'}
            </Typography>
            <Typography variant="body2" sx={{ fontWeight: 600, color: isDark ? '#9BA1A6' : '#666', mt: 0.3 }}>
              {language === 'en' 
                ? (profile?.personNameEn || profile?.personName || profile?.niruvanathinPeyarEn || profile?.niruvanathinPeyar || 'Elvan Niril')
                : (profile?.personName || profile?.personNameEn || profile?.niruvanathinPeyar || profile?.niruvanathinPeyarEn || 'Elvan Niril')}
            </Typography>
          </Box>
        </Paper>
        <Button 
          variant="contained" 
          onClick={onNew} 
          sx={{ 
            display: { xs: 'none', md: 'inline-flex' },
            borderRadius: '999px', 
            px: 3, 
            py: 1.2, 
            bgcolor: isDark ? 'white' : 'black', 
            color: isDark ? 'black' : 'white',
            fontWeight: 700,
            textTransform: 'none',
            boxShadow: 'none',
            '&:hover': { bgcolor: isDark ? '#e5e5e5' : '#333', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' } 
          }}>
          + {t('newInvoice')}
        </Button>
      </Box>

      {/* Stats Grid - Bento Box Layout on Mobile */}
      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: 'repeat(2, 1fr)', md: 'repeat(3, 1fr)' }, gap: { xs: 2, md: 3 }, mb: 4 }}>
        <Card sx={{ borderRadius: '24px', boxShadow: 'none', border: 'none', display: 'flex', flexDirection: 'column', bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF' }}>
          <CardContent sx={{ display: 'flex', flexDirection: { xs: 'column', sm: 'row' }, alignItems: 'flex-start', p: { xs: 2, sm: 3 }, flexGrow: 1 }}>
            <Box sx={{ width: 48, height: 48, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, borderRadius: '16px', bgcolor: isDark ? 'rgba(255,255,255,0.05)' : '#f5f5f5', color: 'text.primary', mr: { xs: 0, sm: 2 }, mb: { xs: 1.5, sm: 0 } }}>
              <CurrencyInr size={24} weight="regular" />
            </Box>
            <Box>
              <Typography variant="body2" color="text.secondary" mb={0.5} sx={{ fontWeight: 600 }}>{t('totalInvoiced')}</Typography>
              {Object.entries(stats.byCurrency).map(([cur, v]) => (
                <Typography key={cur} variant="h5" color="text.primary" sx={{ fontWeight: 800 }}>
                  {formatCurrency(v.total, cur)}
                </Typography>
              ))}
              {Object.keys(stats.byCurrency).length === 0 && <Typography variant="h5" color="text.secondary" sx={{ fontWeight: 800 }}>—</Typography>}
            </Box>
          </CardContent>
        </Card>
        
        <Card sx={{ borderRadius: '24px', boxShadow: 'none', border: 'none', display: 'flex', flexDirection: 'column', bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF' }}>
          <CardContent sx={{ display: 'flex', flexDirection: { xs: 'column', sm: 'row' }, alignItems: 'flex-start', p: { xs: 2, sm: 3 }, flexGrow: 1 }}>
            <Box sx={{ width: 48, height: 48, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, borderRadius: '16px', bgcolor: isDark ? 'rgba(255,255,255,0.05)' : '#f5f5f5', color: 'text.primary', mr: { xs: 0, sm: 2 }, mb: { xs: 1.5, sm: 0 } }}>
              <TrendUp size={24} weight="regular" />
            </Box>
            <Box>
              <Typography variant="body2" color="text.secondary" mb={0.5} sx={{ fontWeight: 600 }}>{t('taxCollected')}</Typography>
              {Object.entries(stats.byCurrency).map(([cur, v]) => (
                <Typography key={cur} variant="h5" color="text.primary" sx={{ fontWeight: 800 }}>
                  {formatCurrency(v.tax, cur)}
                </Typography>
              ))}
              {Object.keys(stats.byCurrency).length === 0 && <Typography variant="h5" color="text.secondary" sx={{ fontWeight: 800 }}>—</Typography>}
            </Box>
          </CardContent>
        </Card>

        {/* Third Card: Invoice Count (Desktop Only) */}
        <Card sx={{ display: { xs: 'none', md: 'flex' }, borderRadius: '24px', boxShadow: 'none', border: 'none', flexDirection: 'column', bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF' }}>
          <CardContent sx={{ display: 'flex', flexDirection: { xs: 'column', sm: 'row' }, alignItems: 'flex-start', p: { xs: 2, sm: 3 }, flexGrow: 1 }}>
            <Box sx={{ width: 48, height: 48, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, borderRadius: '16px', bgcolor: isDark ? 'rgba(255,255,255,0.05)' : '#f5f5f5', color: 'text.primary', mr: { xs: 0, sm: 2 }, mb: { xs: 1.5, sm: 0 } }}>
              <Receipt size={24} weight="regular" />
            </Box>
            <Box>
              <Typography variant="body2" color="text.secondary" mb={0.5} sx={{ fontWeight: 600 }}>
                {language === 'ta' ? 'பட்டியல் எண்ணிக்கை' : 'Invoice Count'}
              </Typography>
              <Typography variant="h5" color="text.primary" sx={{ fontWeight: 800 }}>
                {stats.count}
              </Typography>
            </Box>
          </CardContent>
        </Card>


      </Box>

      {/* Low Stock Alerts */}
      {lowStockProducts.length > 0 && (
        <Paper elevation={0} sx={{ p: 2, mb: 4, borderRadius: '24px', bgcolor: isDark ? 'rgba(255,255,255,0.03)' : 'rgba(0,0,0,0.02)' }}>
          <Stack direction="row" alignItems="center" spacing={1} mb={2}>
            <Package size={20} weight="regular" color={isDark ? "#fff" : "#000"} />
            <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>
              Low Stock Alert ({lowStockProducts.length} item{lowStockProducts.length > 1 ? 's' : ''})
            </Typography>
          </Stack>
          <Stack direction="row" flexWrap="wrap" gap={1}>
            {lowStockProducts.map(p => {
              const isOut = (p.stock ?? 0) <= 0;
              return (
                <Chip 
                  key={p.id}
                  label={
                    <Box component="span">
                      <Box component="strong" mr={0.5}>{p.name}</Box>
                      {p.hsn && <Box component="span" sx={{ opacity: 0.7, mr: 0.5 }}>({p.hsn})</Box>}
                      <Box component="span" fontWeight={700}>{isOut ? 'Out of Stock' : `Stock: ${p.stock}`}</Box>
                    </Box>
                  }
                  variant="outlined"
                  size="small"
                  sx={{ borderColor: 'divider', color: 'text.primary', borderRadius: '999px', bgcolor: isDark ? 'rgba(255,255,255,0.05)' : '#fff' }}
                />
              );
            })}
          </Stack>
        </Paper>
      )}

      {/* Recent Activity Area */}
      <Paper elevation={0} sx={{ borderRadius: '24px', overflow: 'hidden', bgcolor: 'transparent' }}>
        <Box sx={{ px: 0, pt: 3, pb: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6" sx={{ fontWeight: 700, display: 'flex', alignItems: 'center', ml: 1.5 }}>
            {t('recentActivity')}
          </Typography>
          <Button 
            onClick={onViewAll} 
            endIcon={<CaretRight size={16} weight="regular" />}
            sx={{ fontWeight: 600, color: 'text.secondary', textTransform: 'none', '&:hover': { color: 'text.primary', bgcolor: 'transparent' }, mr: 1.5 }}
            disableRipple
          >
            {t('seeAll')}
          </Button>
        </Box>

        {recentBills.length === 0 ? (
          <Box sx={{ py: 10, textAlign: 'center' }}>
            <Receipt size={48} weight="regular" color={isDark ? '#475569' : '#cbd5e1'} style={{ margin: '0 auto', marginBottom: '16px' }} />
            <Typography color="text.secondary" mb={2}>
              {t('noInvoicesYet')}
            </Typography>
          </Box>
        ) : (
          <>
            {/* Responsive Bento Card Grid */}
            <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' }, gap: 2, pb: 3, px: 0 }}>
              {recentBills.map((bill) => {
                const billCurrency = bill.currency || bill.data?.invoiceOptions?.currency || 'INR';
                return (
                  <ElvanCard key={bill.id} onClick={() => handleView(bill)}>
                        <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={1}>
                        <Box sx={{ width: 'calc(100% - 30px)' }}>
                          <Typography variant="subtitle1" noWrap sx={{ fontWeight: 700 }}>{bill.clientName || '-'}</Typography>
                          {profile?.enableBilingual !== false && (bill.clientNameEn || bill.data?.client?.nameEn) && (
                            <Typography variant="caption" color="text.secondary" noWrap sx={{ display: 'block', fontWeight: 'normal' }}>
                              {bill.clientNameEn || bill.data?.client?.nameEn}
                            </Typography>
                          )}
                          <Typography variant="caption" color="text.secondary">{new Date(bill.invoiceDate).toLocaleDateString('en-IN')}</Typography>
                        </Box>
                        <CaretRight size={18} weight="regular" color={isDark ? "#555" : "#aaa"} style={{ marginTop: '4px' }} />
                      </Stack>
                      <Stack direction="row" justifyContent="space-between" alignItems="flex-end">
                        <Box sx={{ flex: 1, minWidth: 0, mr: 2 }}>
                          <Typography variant="body2" sx={{ fontWeight: 600 }} noWrap>{bill.invoiceNumber}</Typography>
                          <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>{(INVOICE_TYPES[bill.invoiceType || 'tax-invoice'])?.label}</Typography>
                        </Box>
                        <Typography variant="subtitle2" sx={{ fontWeight: 800, flexShrink: 0 }}>
                          {formatCurrency(bill.totalAmount, billCurrency)}
                        </Typography>
                      </Stack>
                  </ElvanCard>
                );
              })}
            </Box>
          </>
        )}
      </Paper>
    </Box>
  );
}
