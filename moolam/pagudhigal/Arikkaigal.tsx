// @ts-nocheck
import { TrendUp, TrendDown, Wallet, ChartBar, Clock, MagnifyingGlass, X } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { Box, Typography, Paper, Grid, FormControl, InputLabel, Select, MenuItem, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Stack, Skeleton } from '@mui/material';
import { getAllBills } from '../Avanam';
import { formatCurrency } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';



function getFYOptions() {
  const now = new Date();
  const currentYear = now.getMonth() >= 3 ? now.getFullYear() : now.getFullYear() - 1;
  const options = [];
  for (let i = 0; i < 5; i++) {
    const y = currentYear - i;
    options.push({ value: `${y}-${y + 1}`, label: `FY ${y}-${String(y + 1).slice(-2)}`, from: `${y}-04-01`, to: `${y + 1}-03-31` });
  }
  return options;
}

const getBillCurrency = (b) => b.currency || b.data?.invoiceOptions?.currency || 'INR';

export default function Arikkaigal() {
  const { t } = useLanguage();
  const MONTHS = [t('january'), t('february'), t('march'), t('april'), t('may'), t('june'), t('july'), t('august'), t('september'), t('october'), t('november'), t('december')];

  const [bills, setBills] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [filterMode, setFilterMode] = useState('fy');
  const [fyFilter, setFyFilter] = useState('');
  const [monthFilter, setMonthFilter] = useState('');
  const [yearFilter, setYearFilter] = useState('');
  const [currencyFilter, setCurrencyFilter] = useState('INR');

  const fyOptions = getFYOptions();
  const currentYear = new Date().getFullYear();
  const yearOptions = [];
  for (let y = currentYear; y >= currentYear - 5; y--) yearOptions.push(y);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [billData] = await Promise.all([getAllBills()]);
      setBills(billData);
    } catch {
      thagaval(t('failedToLoadProductsToast'), 'error');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    const now = new Date();
    const fy = fyOptions[0];
    if (fy) setFyFilter(fy.value);
    setYearFilter(String(now.getFullYear()));
    setMonthFilter(String(now.getMonth()));
    loadData();
  }, []);

  const filterByPeriod = (date) => {
    if (!date) return false;
    if (filterMode === 'fy') {
      const fy = fyOptions.find(f => f.value === fyFilter);
      return fy ? date >= fy.from && date <= fy.to : true;
    } else {
      const d = new Date(date);
      return d.getFullYear() === parseInt(yearFilter) && d.getMonth() === parseInt(monthFilter);
    }
  };

  const allFilteredBills = bills.filter(bill => bill.data && filterByPeriod(bill.invoiceDate));

  // All distinct currencies in the filtered period
  const allCurrencies = [...new Set(allFilteredBills.map(getBillCurrency))].sort();
  // Set currency filter to first available if current selection not in list
  useEffect(() => {
    if (allCurrencies.length > 0 && !allCurrencies.includes(currencyFilter)) {
      setCurrencyFilter(allCurrencies[0]);
    }
  }, [allCurrencies.join(',')]);

  // Bills for P&L — only selected currency
  const plBills = allFilteredBills.filter(b => getBillCurrency(b) === currencyFilter);

  // P&L
  const totalRevenue = plBills.reduce((s, b) => s + (b.totalAmount || 0), 0);
  const totalTaxCollected = plBills.reduce((s, b) => s + (b.totalTaxAmount || 0), 0);
  const revenueExTax = totalRevenue - totalTaxCollected;

  // Monthly breakdown — per selected currency
  const monthlyPL = {};
  plBills.forEach(b => {
    if (!b.invoiceDate) return;
    const key = b.invoiceDate.substring(0, 7);
    if (!monthlyPL[key]) monthlyPL[key] = { revenue: 0, tax: 0 };
    monthlyPL[key].revenue += b.totalAmount || 0;
    monthlyPL[key].tax += b.totalTaxAmount || 0;
  });
  const monthlyKeys = Object.keys(monthlyPL).sort();


  return (
    <Box sx={{ p: { xs: 2, md: 4 }, maxWidth: 1200, mx: 'auto' }}>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" color="text.primary" gutterBottom sx={{ fontWeight: "bold" }}>
          {t('reports')}
        </Typography>
        <Typography variant="body1" color="text.secondary">
          {t('reportsSubtitle')}
        </Typography>
      </Box>

      {/* Period + Currency Selector */}
      <Paper elevation={2} sx={{ p: 3, mb: 3, borderRadius: 2 }}>
        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} sx={{ alignItems: { xs: 'stretch', sm: 'center' } }}>
          <FormControl size="small" sx={{ minWidth: 150 }}>
            <InputLabel>{t('filterByLabel')}</InputLabel>
            <Select value={filterMode} onChange={e => setFilterMode(e.target.value)} label={t('filterByLabel')}>
              <MenuItem value="fy">{t('fiscalYearLabel')}</MenuItem>
              <MenuItem value="month">{t('monthYearLabel')}</MenuItem>
            </Select>
          </FormControl>
          {filterMode === 'fy' ? (
            <FormControl size="small" sx={{ minWidth: 150 }}>
              <InputLabel>{t('fiscalYearLabel')}</InputLabel>
              <Select value={fyFilter} onChange={e => setFyFilter(e.target.value)} label={t('fiscalYearLabel')}>
                {fyOptions.map(fy => <MenuItem key={fy.value} value={fy.value}>{fy.label}</MenuItem>)}
              </Select>
            </FormControl>
          ) : (
            <>
              <FormControl size="small" sx={{ minWidth: 150 }}>
                <InputLabel>{t('monthLabel')}</InputLabel>
                <Select value={monthFilter} onChange={e => setMonthFilter(e.target.value)} label={t('monthLabel')}>
                  {MONTHS.map((m, i) => <MenuItem key={i} value={i}>{m}</MenuItem>)}
                </Select>
              </FormControl>
              <FormControl size="small" sx={{ minWidth: 100 }}>
                <InputLabel>{t('yearLabel')}</InputLabel>
                <Select value={yearFilter} onChange={e => setYearFilter(e.target.value)} label={t('yearLabel')}>
                  {yearOptions.map(y => <MenuItem key={y} value={y}>{y}</MenuItem>)}
                </Select>
              </FormControl>
            </>
          )}
          {allCurrencies.length > 1 && (
            <FormControl size="small" sx={{ minWidth: 120 }}>
              <InputLabel>{t('currencyLabel')}</InputLabel>
              <Select value={currencyFilter} onChange={e => setCurrencyFilter(e.target.value)} label={t('currencyLabel')}>
                {allCurrencies.map(c => <MenuItem key={c} value={c}>{c}</MenuItem>)}
              </Select>
            </FormControl>
          )}
        </Stack>
      </Paper>

      {/* P&L Summary Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <Paper elevation={2} sx={{ p: 3, borderRadius: 2, display: 'flex', alignItems: 'center', gap: 2 }}>
            <Box sx={{ p: 1.5, borderRadius: '50%', bgcolor: 'success.light', color: 'success.dark', display: 'flex' }}>
              <TrendUp size={24} weight="fill" />
            </Box>
            <Box sx={{ flex: 1 }}>
              <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>{t('revenueExTax')}</Typography>
              {isLoading ? (
                <Skeleton variant="text" width="80%" height={32} />
              ) : (
                <Typography variant="h5" color="success.main" sx={{ fontWeight: "bold" }}>
                  {formatCurrency(revenueExTax, currencyFilter)}
                </Typography>
              )}
            </Box>
          </Paper>
        </Grid>
      </Grid>

      {/* P&L Statement */}
      <Paper elevation={2} sx={{ mb: 3, borderRadius: 2, overflow: 'hidden' }}>
        <Box sx={{ px: 3, py: 2, borderBottom: '1px solid', borderColor: 'divider', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6" sx={{ m: 0 ,  fontWeight: 600 }}>
            {t('salesSummaryTitle')}
          </Typography>
          {allCurrencies.length > 1 && (
            <Typography variant="body2" color="text.secondary">
              Showing {currencyFilter} {t('showingCurrencyInvoicesOnly')}
            </Typography>
          )}
        </Box>
        <Box sx={{ p: 3, maxWidth: 500, mx: 'auto' }}>
          {isLoading ? (
            <Stack spacing={2}>
              <Skeleton variant="text" width="100%" height={24} />
              <Skeleton variant="text" width="100%" height={24} />
              <Skeleton variant="text" width="100%" height={32} />
            </Stack>
          ) : (
            <>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', py: 1.5, borderBottom: '1px solid', borderColor: 'divider' }}>
                <Typography variant="body1" color="text.secondary" sx={{ fontWeight: 500 }}>{t('totalRevenueLabel')}</Typography>
                <Typography variant="body1" sx={{ fontWeight: 600 }}>{formatCurrency(totalRevenue, currencyFilter)}</Typography>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', py: 1.5, borderBottom: '1px solid', borderColor: 'divider' }}>
                <Typography variant="body1" color="text.secondary" sx={{ fontWeight: 500 }}>{t('lessGstCollectedLabel')}</Typography>
                <Typography variant="body1" color="error.main">-{formatCurrency(totalTaxCollected, currencyFilter)}</Typography>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', py: 1.5, borderBottom: '2px solid', borderColor: 'divider' }}>
                <Typography variant="h6" sx={{ fontWeight: 700 }}>{t('netRevenueLabel')}</Typography>
                <Typography variant="h6" sx={{ fontWeight: 700 }}>{formatCurrency(revenueExTax, currencyFilter)}</Typography>
              </Box>
            </>
          )}
        </Box>
      </Paper>

      {/* Monthly Breakdown */}
      {monthlyKeys.length > 0 && (
        <Paper elevation={2} sx={{ borderRadius: 2, overflow: 'hidden' }}>
          <Box sx={{ px: 3, py: 2, borderBottom: '1px solid', borderColor: 'divider' }}>
            <Typography variant="h6" sx={{ m: 0 ,  fontWeight: 600 }}>
              {t('monthlySalesTitle')}
            </Typography>
          </Box>
          <TableContainer>
            <Table sx={{ minWidth: 600 }}>
              <TableHead>
                <TableRow sx={{ bgcolor: 'action.hover' }}>
                  <TableCell>{t('monthLabel')}</TableCell>
                  <TableCell align="right">{t('revenueCol')}</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {monthlyKeys.map(key => {
                  const m = monthlyPL[key];
                  const rev = m.revenue - m.tax;
                  const [y, mo] = key.split('-');
                  return (
                    <TableRow key={key} hover>
                      <TableCell sx={{ fontWeight: 500 }}>{MONTHS[parseInt(mo) - 1]} {y}</TableCell>
                      <TableCell align="right">{formatCurrency(rev, currencyFilter)}</TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

    </Box>
  );
}
