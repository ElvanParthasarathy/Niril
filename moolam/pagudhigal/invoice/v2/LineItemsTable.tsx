import React, { useState, useEffect } from 'react';
import { Box, Typography, Paper, TextField, IconButton, Button, Divider, List, ListItem, ListItemButton, ListItemText, InputAdornment, Select, MenuItem } from '@mui/material';
import { Trash, Plus } from '@phosphor-icons/react';
import { useLanguage } from '../../../mozhi/LanguageContext';
import { LineItemState, InvoiceSettingsState, createEmptyLineItem } from './InvoiceTypes';
import { getAllProducts } from '../../../Avanam';
import { formatCurrency } from '../../../Payanpadu';

interface LineItemsTableProps {
  items: LineItemState[];
  setItems: (items: LineItemState[] | ((prev: LineItemState[]) => LineItemState[])) => void;
  settings: InvoiceSettingsState;
  isBilingual: boolean;
  primaryLang: string;
  secondaryLang: string;
  profile: any;
}

export default function LineItemsTable({
  items,
  setItems,
  settings,
  isBilingual,
  primaryLang,
  secondaryLang,
  profile
}: LineItemsTableProps) {
  const { t } = useLanguage();
  
  const [products, setProducts] = useState<any[]>([]);
  const [activeSuggestionRow, setActiveSuggestionRow] = useState<string | null>(null);

  useEffect(() => {
    getAllProducts().then(setProducts);
  }, []);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (!target.closest('.suggestion-dropdown') && !target.closest('.suggestion-input')) {
        setActiveSuggestionRow(null);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const getItemField = (item: LineItemState, field: string, lang: string) => {
    if (field === 'name' || field === 'description') {
      const val = item[field];
      if (typeof val === 'object' && val !== null) {
         return lang === primaryLang ? val.primary : val.secondary;
      }
    }
    return (item as any)[field] || '';
  };

  const handleItemChange = (id: string, field: string, value: any) => {
    setItems(prev => prev.map(item => {
      if (item.id === id) {
        if (field === 'name' || field === `name_${primaryLang}`) {
          return { ...item, name: { ...item.name, primary: value } };
        }
        if (field === 'quantity') {
          return { ...item, qty: value };
        }
        return { ...item, [field]: value };
      }
      return item;
    }));
  };

  const selectProduct = (id: string, product: any) => {
    setItems(prev => prev.map(item => {
      if (item.id === id) {
        return {
          ...item,
          productId: product.id,
          name: {
            primary: product.name || product[`name_${primaryLang}`] || '',
            secondary: product.descriptionEn || product.nameEn || product[`name_${secondaryLang}`] || ''
          },
          description: {
            primary: product.description || product[`description_${primaryLang}`] || '',
            secondary: product.descriptionEn || product.nameEn || product[`description_${secondaryLang}`] || ''
          },
          hsn: product.hsn || '',
          rate: product.rate || 0,
          unit: product.unit || item.unit || 'Nos',
          taxPercent: product.taxPercent || item.taxPercent || 0,
          cessPercent: product.cessPercent || 0,
        };
      }
      return item;
    }));
    setActiveSuggestionRow(null);
  };

  const removeItem = (id: string) => {
    setItems(prev => prev.length > 1 ? prev.filter(i => i.id !== id) : prev);
  };

  const addItem = () => {
    setItems(prev => [...prev, createEmptyLineItem()]);
  };

  const clampNonNeg = (v: any) => {
    if (v === '' || v === null || v === undefined) return '';
    const n = parseFloat(v);
    if (!isFinite(n) || n < 0) return 0;
    return n;
  };

  const currency = settings.currency || 'INR';

  return (
    <Box sx={{ py: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, ml: 1.5 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
          <Box sx={{ width: 18, height: 18, borderRadius: '50%', bgcolor: 'primary.main', color: 'primary.contrastText', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.65rem', fontWeight: 'bold' }}>3</Box>
          <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600, lineHeight: 1 }}>{t('lineItems')}</Typography>
        </Box>
      </Box>
      
      {items.map((item: any, index) => (
        <Box key={item.id} sx={{ mb: 2 }}>
          <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 1 }}>
            {t('item')} #{index + 1}
          </Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, p: 2, bgcolor: 'action.hover', borderRadius: '16px' }}>
            
            {/* Product Search */}
            <Box sx={{ flex: '3 1 250px', position: 'relative' }}>
              <TextField 
                fullWidth size="small" 
                label={t("descriptionCol")} slotProps={{ inputLabel: { shrink: true } }}
                placeholder={t('hc_searchSavedItems') || 'Search saved items'}
                value={getItemField(item, 'name', primaryLang)}
                className="suggestion-input"
                onChange={(e) => {
                  handleItemChange(item.id, 'productId', null);
                  handleItemChange(item.id, 'name', e.target.value);
                  setActiveSuggestionRow(item.id);
                }}
                onFocus={() => setActiveSuggestionRow(item.id)}
                autoComplete="off"
              />

              {activeSuggestionRow === item.id && (
                <Paper className="suggestion-dropdown" elevation={4} sx={{ position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 10, mt: 0.5, maxHeight: 300, overflow: 'auto' }}>
                  <List disablePadding>
                    {(() => {
                      const q = (getItemField(item, 'name', primaryLang) || '').toLowerCase();
                      const getProdName = (p: any, lang: string) => {
                        if (typeof p.name === 'object' && p.name !== null) {
                          return lang === primaryLang ? p.name.primary : p.name.secondary;
                        }
                        return lang === primaryLang ? p.name : p.nameEn;
                      };
                      
                      const filtered = products.filter(p => {
                        const pName = getProdName(p, primaryLang) || '';
                        const pNameSec = getProdName(p, secondaryLang) || '';
                        return !q || (pName.toLowerCase().includes(q) || pNameSec.toLowerCase().includes(q) || p.hsn?.toLowerCase().includes(q));
                      });
                      
                      if (filtered.length === 0) {
                        return (
                          <ListItem>
                            <ListItemText primary={q ? "No saved items found." : "Type to search items"} />
                          </ListItem>
                        );
                      }
                      
                      const mappedProducts = filtered.map(p => {
                        const pName = getProdName(p, primaryLang);
                        const pNameSec = getProdName(p, secondaryLang);
                        return (
                          <ListItem key={p.id} disablePadding>
                            <ListItemButton onClick={() => selectProduct(item.id, p)}>
                              <ListItemText 
                                primary={pName}
                                secondary={[
                                  pNameSec,
                                  p.hsn ? `HSN: ${p.hsn}` : '',
                                  p.rate ? formatCurrency(p.rate, currency) : '',
                                  p.unit || '',
                                ].filter(Boolean).join(' · ')}
                              />
                            </ListItemButton>
                          </ListItem>
                        );
                      });

                      return (
                        <>
                          {mappedProducts}
                          <Divider />
                          <ListItem disablePadding>
                            <ListItemButton 
                              onClick={() => {
                                // Navigate to product editor
                                window.location.href = window.location.pathname + '?view=product-editor';
                              }} 
                              sx={{ color: 'primary.main' }}
                            >
                              <Plus size={18} weight="bold" style={{ marginRight: 8 }} />
                              <ListItemText primary={t('hc_addNewProduct') || 'Add New Product'} primaryTypographyProps={{ fontWeight: 600 }} />
                            </ListItemButton>
                          </ListItem>
                        </>
                      );
                    })()}
                  </List>
                </Paper>
              )}

              {/* Show selected product details as a compact chip/summary */}
              {item.productId && (
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 0.5 }}>
                  {[
                    getItemField(item, 'name', secondaryLang),
                    item.hsn ? `HSN: ${item.hsn}` : '',
                    item.unit || '',
                    item.taxPercent ? `GST ${item.taxPercent}%` : '',
                  ].filter(Boolean).join(' · ')}
                </Typography>
              )}
            </Box>

            {/* Qty */}
            <Box sx={{ flex: '0.7 1 80px' }}>
              <TextField fullWidth size="small" label={t('qty')} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0, step: "any" } }} 
                value={item.qty} onChange={(e) => handleItemChange(item.id, 'quantity', clampNonNeg(e.target.value))} />
            </Box>

            {/* Rate */}
            <Box sx={{ flex: '1 1 120px' }}>
              <TextField fullWidth size="small" label={t("rateCol")} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0, step: "any" } }} 
                value={item.rate} onChange={(e) => handleItemChange(item.id, 'rate', clampNonNeg(e.target.value))} />
            </Box>

            {/* Discount */}
            {settings.showDiscountColumn && (
              <Box sx={{ flex: '0.8 1 100px' }}>
                <TextField fullWidth size="small" label={t('discount')} type="number" 
                  slotProps={{ 
                    inputLabel: { shrink: true }, 
                    htmlInput: { min: 0, step: "any" },
                    input: {
                      endAdornment: (
                        <InputAdornment position="end" sx={{ mr: -1.7 }}>
                          <Select
                            variant="standard"
                            disableUnderline
                            size="small"
                            value={item.discountType || 'amount'}
                            onChange={(e) => handleItemChange(item.id, 'discountType', e.target.value)}
                            sx={{ minWidth: 45, bgcolor: 'action.hover', px: 1, py: 0.5, borderTopRightRadius: 4, borderBottomRightRadius: 4, height: '100%', '& .MuiSelect-select': { py: 0 } }}
                          >
                            <MenuItem value="amount">₹</MenuItem>
                            <MenuItem value="percentage">%</MenuItem>
                          </Select>
                        </InputAdornment>
                      )
                    }
                  }} 
                  value={item.discount} onChange={(e) => handleItemChange(item.id, 'discount', clampNonNeg(e.target.value))} />
              </Box>
            )}

            {/* Line Total */}
            <Box sx={{ flex: '1 1 120px', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', justifyContent: 'center', bgcolor: 'background.paper', p: 1, borderRadius: 1, border: '1px dashed', borderColor: 'divider' }}>
              {(() => {
                 const qty = Number(item.qty) || 0;
                 const rate = Number(item.rate) || 0;
                 const rawDiscount = Number(item.discount) || 0;
                 const discountAmt = item.discountType === 'percentage' ? (qty * rate) * (rawDiscount / 100) : rawDiscount;
                 const taxable = (qty * rate) - discountAmt;
                 const taxAmt = (taxable > 0 ? taxable : 0) * ((item.taxPercent || 0) / 100);
                 const cessAmt = settings.showCess ? (taxable > 0 ? taxable : 0) * ((item.cessPercent || 0) / 100) : 0;
                 const total = (taxable > 0 ? taxable : 0) + taxAmt + cessAmt;
                 return (
                   <>
                     {taxAmt > 0 && (
                       <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', justifyContent: 'space-between', width: '100%' }}>
                         <span>{t('hc_tax')}:</span> <span>{formatCurrency(taxAmt, currency)}</span>
                       </Typography>
                     )}
                     <Typography variant="subtitle2" sx={{ display: 'flex', justifyContent: 'space-between', width: '100%', fontWeight: 600 }}>
                       <span>{t('hc_total')}:</span> <span>{formatCurrency(total, currency)}</span>
                     </Typography>
                   </>
                 );
              })()}
            </Box>

            {/* Delete */}
            <Box sx={{ flex: '0 0 auto', display: 'flex', alignItems: 'center' }}>
              <IconButton color="error" onClick={() => removeItem(item.id)} title={t('hc_remove')}><Trash size={18} weight="regular" /></IconButton>
            </Box>
          </Box>
        </Box>
      ))}
      <Button variant="outlined" startIcon={<Plus size={18} weight="regular" />} onClick={addItem} sx={{ mt: 1 }}>Add Item</Button>
    </Box>
  );
}
