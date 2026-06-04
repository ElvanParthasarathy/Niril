// @ts-nocheck
import { Package, MagnifyingGlass, Plus, PencilSimple, Trash, X, FloppyDisk, UploadSimple, Tag, Stack, FileText } from '@phosphor-icons/react';
import React, { useState, useEffect, useRef } from 'react';
import {
  Box, Typography, Button, Paper, TextField, InputAdornment, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, Grid, Select, MenuItem,
  InputLabel, FormControl, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Tooltip, Chip, Fade, Zoom, Divider, Slide,
  Card, CardContent
} from '@mui/material';
import { getAllProducts, saveProduct, deleteProduct, getProfile } from '../Avanam';
import { getAllUnits, getCountryConfig, formatCurrency } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import ElvanCard from './ElvanCard';

const emptyForm = {
  name: '', nameEn: '', hsn: '50072010', rate: '', taxPercent: '5', unit: 'Nos', stock: '', description: '', descriptionEn: '',
};

const Transition = React.forwardRef(function Transition(props: any, ref: any) {
  return <Slide direction="up" ref={ref} {...props} />;
});

export default function Porul({ onAddProduct, onEditProduct, profile }) {
  const { t } = useLanguage();
  const [products, setProducts] = useState([]);
  const [search, setSearch] = useState('');
  const [units, setUnits] = useState(getAllUnits());
  const [profileSettings, setProfileSettings] = useState({ primary: 'Tamil', secondary: 'English', bilingual: true });
  const [profileCountry, setProfileCountry] = useState('India');
  const profileCurrency = getCountryConfig(profileCountry).currency;

  const loadProducts = async () => {
    try {
      const data = await getAllProducts();
      setProducts(data);
    } catch {
      thagaval(t('failedToLoadProductsToast') || 'Failed to load products', 'error');
    }
  };

  useEffect(() => {
    loadProducts();
    setUnits(getAllUnits());
    getProfile().then(p => { if (p?.country) setProfileCountry(p.country); if (p) setProfileSettings({ primary: p.primaryDataLanguage || 'Tamil', secondary: p.secondaryDataLanguage || 'English', bilingual: p.enableBilingual !== false }); }).catch(() => { });
  }, []);

  const filtered = search.trim()
    ? products.filter(p =>
      (p.name || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.hsn || '').toLowerCase().includes(search.toLowerCase())
    )
    : products;

  const openAdd = () => {
    onAddProduct(null);
  };

  const openEdit = (product) => {
    onEditProduct(product);
  };

  const handleDelete = async (id) => {
    if (confirm(t('deleteProductConfirmMsg') || 'Are you sure?')) {
      try {
        await deleteProduct(id);
        thagaval(t('productDeletedToast') || 'Deleted!', 'success');
        loadProducts();
      } catch {
        thagaval('Failed to delete', 'error');
      }
    }
  };





  return (
    <Box sx={{ p: { xs: 1.5, md: 4 }, maxWidth: 1400, mx: 'auto' }}>
      {/* Header Area */}
      <Box sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h5" sx={{ fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary', ml: 2 }}>
          {t('inventoryTitle') || 'Products'}
        </Typography>
        <Box sx={{ display: 'flex', gap: 1.5, overflowX: 'auto', width: { xs: '100%', sm: 'auto' }, pb: { xs: 1, sm: 0 }, '&::-webkit-scrollbar': { display: 'none' } }}>
          <Button
            variant="contained"
            startIcon={<Plus size={20} weight="regular" />}
            onClick={openAdd}
            sx={{ display: { xs: 'none', md: 'inline-flex' }, flexShrink: 0, borderRadius: 50, textTransform: "none", px: 4, py: 1, boxShadow: 'none' }}
          >
            {t('addProductBtn') || 'Add Product'}
          </Button>
        </Box>
      </Box>

      {/* Toolbar (Search & Filters) */}
      <Box sx={{ mb: 3 }}>
        {/* @ts-ignore */}
        <TextField
          fullWidth
          placeholder={t('searchProducts') || 'Search products by name or HSN...'}
          value={search}
          onChange={e => setSearch(e.target.value)}
          variant="outlined"
          sx={{ '& .MuiOutlinedInput-root': { borderRadius: 50 } }}
          slotProps={{
            input: {
              startAdornment: <InputAdornment position="start"><MagnifyingGlass size={20} weight="regular" /></InputAdornment>,
              endAdornment: search ? (
                <InputAdornment position="end">
                  <IconButton size="small" onClick={() => setSearch('')}><X size={16} weight="regular" /></IconButton>
                </InputAdornment>
              ) : null
            }
          }}
        />
      </Box>

      {/* Main Table Area */}
      <Paper elevation={1} sx={{ borderRadius: 4, overflow: 'hidden' }}>
        {filtered.length === 0 ? (
          <Box sx={{ p: 6, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
            <Package size={40} weight="regular" color="#9ca3af" style={{ marginBottom: '16px' }} />
            <Typography variant="h6" gutterBottom color="text.primary">
              {products.length === 0 ? (t('noProductsYet') || 'No Products Found') : (t('noProductsMatch') || 'No matching products')}
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
              {products.length === 0 ? 'Start building your inventory by adding your first product or service.' : 'Try adjusting your search criteria to find what you are looking for.'}
            </Typography>
            {products.length === 0 && (
              <Button variant="contained" startIcon={<Plus size={18} weight="regular" />} onClick={openAdd} sx={{ borderRadius: 50, px: 3, textTransform: 'none', boxShadow: 'none' }}>
                {t('addProductBtn') || 'Add Product'}
              </Button>
            )}
          </Box>
        ) : (
          <>
            {/* Desktop Table View */}
            <TableContainer sx={{ display: { xs: 'none', md: 'block' }, maxHeight: 'calc(100vh - 350px)', overflowX: 'auto' }}>
              <Table stickyHeader sx={{ minWidth: 700 }}>
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ fontWeight: 'bold' }}>{t('nameCol') || 'Product Name'}</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>{t('hsnCol') || 'HSN / SAC'}</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>{t('rateCol') || 'Selling Rate'}</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>{t('gstPercentLabel') || 'Tax %'}</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }} align="right">Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {filtered.map(product => (
                    <TableRow key={product.id} hover sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
                      <TableCell>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                          <Stack size={20} weight="regular" color="#64748b" />
                          <Box>
                            <Typography variant="body1">
                              {product.name}
                            </Typography>
                            {profile?.enableBilingual !== false && product.nameEn && (
                              <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>
                                {product.nameEn}
                              </Typography>
                            )}
                            {product.description && (
                              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 0.5, maxWidth: 300, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                                {product.description}
                              </Typography>
                            )}
                          </Box>
                        </Box>
                      </TableCell>
                      <TableCell>
                        {product.hsn ? (
                          <Chip size="small" label={product.hsn} variant="outlined" sx={{ borderRadius: 50 }} />
                        ) : <Typography color="text.disabled">-</Typography>}
                      </TableCell>
                      <TableCell>
                        <Typography>
                          {product.rate ? formatCurrency(product.rate, profileCurrency) : '-'}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        {product.taxPercent ? (
                          <Chip size="small" label={`${product.taxPercent}%`} variant="outlined" sx={{ borderRadius: 50 }} />
                        ) : <Typography color="text.disabled">-</Typography>}
                      </TableCell>
                      <TableCell align="right">
                        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
                          <Tooltip title="Edit" arrow>
                            <IconButton size="small" onClick={() => openEdit(product)} color="primary">
                              <PencilSimple size={18} weight="regular" />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="Delete" arrow>
                            <IconButton size="small" onClick={() => handleDelete(product.id)} color="error">
                              <Trash size={18} weight="regular" />
                            </IconButton>
                          </Tooltip>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>

            {/* Mobile Card View */}
            <Box sx={{ display: { xs: 'flex', md: 'none' }, flexDirection: 'column', gap: 2, p: 2 }}>
              {filtered.map(product => (
                <ElvanCard key={product.id}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                    <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 1.5 }}>
                      <Box sx={{ mt: 0.5 }}>
                        <Stack size={18} weight="regular" color="#64748b" />
                      </Box>
                      <Box>
                        <Typography variant="subtitle1" sx={{ lineHeight: 1.2, mb: 0.5 ,  fontWeight: "bold" }}>
                          {product.name}
                        </Typography>
                        {profile?.enableBilingual !== false && product.nameEn && (
                          <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500, mb: 0.5 }}>
                            {product.nameEn}
                          </Typography>
                        )}
                        {product.description && (
                          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
                            {product.description}
                          </Typography>
                        )}
                      </Box>
                    </Box>
                  </Box>

                  <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 2, ml: 4 }}>
                    {product.hsn && (
                      <Chip size="small" label={`HSN: ${product.hsn}`} variant="outlined" sx={{ borderRadius: 50, color: 'text.secondary' }} />
                    )}
                    {product.taxPercent ? (
                      <Chip size="small" label={`Tax: ${product.taxPercent}%`} variant="outlined" sx={{ borderRadius: 50, color: 'text.secondary' }} />
                    ) : null}
                  </Box>
                  
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', ml: 4, pt: 1, borderTop: '1px dashed', borderColor: 'divider' }}>
                    <Typography variant="h6" color="primary.main" sx={{ fontWeight: "bold" }}>
                      {product.rate ? formatCurrency(product.rate, profileCurrency) : '-'}
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 1 }}>
                      <Button variant="outlined" color="inherit" size="small" sx={{ height: 32, borderRadius: '50px', minWidth: 'auto', px: 1.5 }} onClick={() => openEdit(product)}>
                        <PencilSimple size={14} weight="regular" />
                      </Button>
                      <Button variant="outlined" color="error" size="small" sx={{ height: 32, borderRadius: '50px', minWidth: 'auto', px: 1.5 }} onClick={() => handleDelete(product.id)}>
                        <Trash size={14} weight="regular" />
                      </Button>
                    </Box>
                  </Box>
                </ElvanCard>
              ))}
            </Box>
          </>
        )}
      </Paper>
    </Box>
  );
}
