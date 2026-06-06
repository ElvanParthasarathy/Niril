import React, { useEffect } from 'react';
import { Box, Typography, Paper, Grid, TextField, MenuItem, Select, InputAdornment } from '@mui/material';
import { useLanguage } from '../../../mozhi/LanguageContext';
import { LineItemState, InvoiceTotalsState, InvoiceSettingsState, ClientState } from './InvoiceTypes';

interface InvoiceTotalsProps {
  items: LineItemState[];
  totals: InvoiceTotalsState;
  setTotals: (totals: InvoiceTotalsState) => void;
  settings: InvoiceSettingsState;
  client: ClientState;
  profileState?: string;
  country?: string;
}

export default function InvoiceTotals({
  items,
  totals,
  setTotals,
  settings,
  client,
  profileState,
  country,
}: InvoiceTotalsProps) {
  const { t } = useLanguage();

  const { globalDiscountValue = 0, globalDiscountType = 'percentage' } = totals;

  useEffect(() => {
    let rawSubtotal = 0;
    let itemDiscounts = 0;

    items.forEach(item => {
      const amount = item.qty * item.rate;
      const rawDiscount = item.discount || 0;
      const discountAmount = item.discountType === 'percentage' ? (amount * (rawDiscount / 100)) : rawDiscount;
      
      rawSubtotal += amount;
      itemDiscounts += discountAmount;
    });

    const globalDiscountAmount = globalDiscountType === 'percentage' 
      ? (rawSubtotal - itemDiscounts) * (globalDiscountValue / 100)
      : globalDiscountValue;

    const totalDiscount = itemDiscounts + globalDiscountAmount;

    let taxTotal = 0;
    items.forEach(item => {
      const amount = item.qty * item.rate;
      const rawDiscount = item.discount || 0;
      const itemDiscount = item.discountType === 'percentage' ? (amount * (rawDiscount / 100)) : rawDiscount;
      let afterItemDiscount = amount - itemDiscount;

      // Distribute global discount proportionally across items
      const itemWeight = (rawSubtotal - itemDiscounts) > 0 ? (afterItemDiscount / (rawSubtotal - itemDiscounts)) : 0;
      const itemGlobalDiscount = globalDiscountAmount * itemWeight;
      
      const taxableAmount = afterItemDiscount - itemGlobalDiscount;
      
      taxTotal += ((taxableAmount > 0 ? taxableAmount : 0) * (item.taxPercent || 0)) / 100;
    });

    const isIndia = (country || 'India') === 'India';
    const clientState = client.maanilam.primary?.trim().toLowerCase();
    const businessState = profileState?.trim().toLowerCase();
    
    // Interstate if seller state != buyer state
    const isInterstate = isIndia && (businessState && clientState && businessState !== clientState);

    const cgst = isIndia ? (isInterstate ? 0 : taxTotal / 2) : 0;
    const sgst = isIndia ? (isInterstate ? 0 : taxTotal / 2) : 0;
    const igst = isIndia ? (isInterstate ? taxTotal : 0) : taxTotal;

    const baseTotal = rawSubtotal - totalDiscount + taxTotal;
    
    const round2 = (n: number) => Math.round(n * 100) / 100;
    
    // Keep it simple for now, can add TCS/TDS logic later
    const tcsAmount = 0;
    const tdsAmount = 0;

    const totalBeforeRound = baseTotal + tcsAmount;
    
    const finalTotal = Math.round(totalBeforeRound);
    const roundOff = round2(finalTotal - totalBeforeRound);

    setTotals({
      ...totals,
      subtotal: round2(rawSubtotal),
      totalDiscount: round2(totalDiscount),
      cgst: round2(cgst),
      sgst: round2(sgst),
      igst: round2(igst),
      roundOff: round2(roundOff),
      tcsAmount: round2(tcsAmount),
      tdsAmount: round2(tdsAmount),
      total: round2(finalTotal),
      netReceivable: round2(finalTotal - tdsAmount),
      amountPaid: totals.amountPaid || 0,
      globalDiscountAmount: round2(globalDiscountAmount),
      itemDiscounts: round2(itemDiscounts),
    });
  }, [items, client.maanilam.primary, profileState, country, globalDiscountValue, globalDiscountType]);

  return (
    <Box sx={{ width: '100%', maxWidth: { xs: '100%', sm: 400 }, ml: 'auto' }}>
      
      {/* Global Discount Input (Outside the Totals Card) */}
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start', mb: 2, gap: 1 }}>
        <Typography color="text.secondary" variant="body2">{t('discount') || 'Discount'}</Typography>
        <Box sx={{ display: 'flex', width: '100%' }}>
          <TextField 
            fullWidth
            size="small" 
            type="number"
            placeholder="0"
            value={totals.globalDiscountValue === undefined ? '' : totals.globalDiscountValue}
            onChange={(e) => setTotals({ ...totals, globalDiscountValue: e.target.value === '' ? '' as any : Number(e.target.value) })}
            slotProps={{
              input: {
                endAdornment: (
                  <InputAdornment position="end" sx={{ mr: -1.7 }}>
                    <Select
                      variant="standard"
                      disableUnderline
                      size="small"
                      value={totals.globalDiscountType || 'percentage'}
                      onChange={(e) => setTotals({ ...totals, globalDiscountType: e.target.value as any })}
                      sx={{ minWidth: 45, px: 1, py: 0.5, borderTopRightRadius: 4, borderBottomRightRadius: 4, height: '100%', '& .MuiSelect-select': { py: 0 } }}
                    >
                      <MenuItem value="percentage">%</MenuItem>
                      <MenuItem value="amount">₹</MenuItem>
                    </Select>
                  </InputAdornment>
                )
              }
            }}
          />
        </Box>
      </Box>

      <Paper sx={{ p: 3, borderRadius: '24px', boxShadow: 'none', bgcolor: (theme) => theme.palette.mode === 'dark' ? 'rgba(255,255,255,0.03)' : '#FFFFFF' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
          <Typography color="text.secondary">{t('subtotal') || 'Subtotal'}</Typography>
          <Typography>₹ {totals.subtotal.toFixed(2)}</Typography>
        </Box>

        {totals.totalDiscount > 0 && (
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1, mt: 1 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column' }}>
              <Typography color="error" variant="body2">{t('totalDiscountAmt') || 'Total Discount applied'}</Typography>
              {totals.globalDiscountType === 'percentage' && totals.globalDiscountValue && totals.globalDiscountValue > 0 ? (
                <Typography color="error" variant="caption" sx={{ opacity: 0.8 }}>
                  ({totals.globalDiscountValue}% of ₹{(totals.subtotal - (totals.itemDiscounts || 0)).toFixed(2)})
                </Typography>
              ) : null}
            </Box>
            <Typography color="error" variant="body2">- ₹ {totals.totalDiscount.toFixed(2)}</Typography>
          </Box>
        )}

        {totals.cgst > 0 && (
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
            <Typography color="text.secondary">CGST</Typography>
            <Typography>₹ {totals.cgst.toFixed(2)}</Typography>
          </Box>
        )}

        {totals.sgst > 0 && (
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
            <Typography color="text.secondary">SGST</Typography>
            <Typography>₹ {totals.sgst.toFixed(2)}</Typography>
          </Box>
        )}

        {totals.igst > 0 && (
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
            <Typography color="text.secondary">IGST</Typography>
            <Typography>₹ {totals.igst.toFixed(2)}</Typography>
          </Box>
        )}

        {totals.roundOff !== 0 && (
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
            <Typography color="text.secondary">{t('roundOff') || 'Round Off'}</Typography>
            <Typography>₹ {totals.roundOff.toFixed(2)}</Typography>
          </Box>
        )}

        <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 2, pt: 2, borderTop: 1, borderColor: 'divider' }}>
          <Typography variant="h6" sx={{ fontWeight: 'bold' }}>{t('total') || 'Total'}</Typography>
          <Typography variant="h6" sx={{ fontWeight: 'bold' }}>₹ {totals.total.toFixed(2)}</Typography>
        </Box>
      </Paper>
    </Box>
  );
}
