import { Package, MagnifyingGlass, Plus, PencilSimple, Trash, X, FloppyDisk, UploadSimple, Tag, FileText } from '@phosphor-icons/react';
import React, { useState, useEffect, useRef } from 'react';
import { useTheme } from '@mui/material/styles';
import {
  Box, Typography, Button, Paper, TextField, InputAdornment, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, Grid, Select, MenuItem,
  InputLabel, FormControl, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Tooltip, Chip, Fade, Zoom, Divider, Slide,
  Card, CardContent, Stack
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
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
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
    <Box sx={{ p: { xs: 1.5, md: 4 }, maxWidth: 1200, mx: 'auto' }}>
      <Box sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h5" sx={{ fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary', ml: 2 }}>
          {t('inventoryTitle') || 'Products'}
        </Typography>
      </Box>

      <Box sx={{ display: 'flex', flexDirection: { xs: 'column', md: 'row' }, gap: 3, mb: 4, px: { xs: 1, md: 0 }, alignItems: { xs: 'stretch', md: 'center' } }}>
        <Typography variant="h5" sx={{ display: { xs: 'block', md: 'none' }, fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary', mb: -1, ml: 1 }}>
          {t('inventoryTitle') || 'Products'}
        </Typography>

        <Paper
          elevation={1}
          className="vanigargal-search"
          sx={{
            flex: 1,
            maxWidth: 400,
            display: 'flex',
            alignItems: 'center',
            gap: 1.25,
            bgcolor: isDark ? 'rgba(255,255,255,0.03)' : '#FFFFFF',
            borderRadius: 100,
            px: 2.5,
            boxShadow: 'none',
            border: 'none',
            transition: 'background 0.3s ease',
          }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, opacity: 0.5 }}>
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            type="text"
            placeholder={t('searchProducts') || 'Search products...'}
            value={search}
            onChange={e => { setSearch(e.target.value); }}
            style={{
              flex: 1,
              minWidth: 0,
              padding: '12px 0',
              fontSize: '0.95rem',
              background: 'transparent',
              border: 'none',
              outline: 'none',
              color: 'inherit',
              fontFamily: 'inherit',
            }}
          />
          {search && (
            <IconButton size="small" onClick={() => { setSearch(''); }} sx={{ flexShrink: 0 }}>
              <X size={14} weight="regular" />
            </IconButton>
          )}
        </Paper>
        <Button variant="contained" sx={{ display: { xs: 'none', md: 'inline-flex' }, flexShrink: 0, height: 45, px: 3, borderRadius: '999px', textTransform: 'none', whiteSpace: 'nowrap', ml: 'auto', bgcolor: isDark ? 'white' : 'black', color: isDark ? 'black' : 'white', fontWeight: 700, boxShadow: 'none', '&:hover': { bgcolor: isDark ? '#e5e5e5' : '#333', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' } }} onClick={openAdd} startIcon={<Plus size={18} weight="bold" />}>
          {t('addProductBtn') || 'Add Product'}
        </Button>
      </Box>

      {filtered.length === 0 ? (
        <ElvanCard boxSx={{ p: 6, textAlign: 'center' }}>
          <Box color="text.secondary" mb={2}>
            <Package size={48} weight="regular" style={{ opacity: 0.5 }} />
          </Box>
          <Typography color="text.secondary" mb={2}>{products.length === 0 ? (t('noProductsYet') || 'No Products Found') : (t('noProductsMatch') || 'No matching products')}</Typography>
          {products.length === 0 && (
            <Button variant="outlined" color="inherit" sx={{ borderRadius: '50px', textTransform: 'none' }} onClick={openAdd} startIcon={<Plus size={16} weight="regular" />}>
              {t('addProductBtn') || 'Add Product'}
            </Button>
          )}
        </ElvanCard>
      ) : (
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr' }, gap: 2 }}>
          {filtered.map((product, index) => {
            return (
              <ElvanCard 
                key={product.id}
                sx={{ height: '100%' }}
                onClick={() => openEdit(product)}
              >
                <Stack direction="row" justifyContent="space-between" alignItems="center" spacing={2} sx={{ height: '100%' }}>
                  <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start', flex: 1, width: '100%' }}>
                    <Box sx={{ 
                      display: 'flex', alignItems: 'center', justifyContent: 'center', 
                      width: 28, height: 28, mt: 0.15, 
                      borderRadius: '50%',
                      bgcolor: isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)',
                      flexShrink: 0
                    }}>
                      <Typography variant="caption" sx={{ fontWeight: 800, color: isDark ? '#FFFFFF' : '#000000', fontSize: '0.7rem', lineHeight: 1, position: 'relative', top: '1px' }}>
                        {(index + 1).toString().padStart(2, '0')}
                      </Typography>
                    </Box>
                    <Box>
                      <Typography variant="subtitle1" sx={{ fontWeight: "bold" }}>
                        {product.name}
                      </Typography>
                      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, color: 'text.secondary', mt: 0.5 }}>
                        {profile?.enableBilingual !== false && product.nameEn && (
                          <Typography variant="body2" sx={{ fontSize: '0.85rem', fontWeight: 500 }}>{product.nameEn}</Typography>
                        )}
                        {product.description && (
                          <Typography variant="body2" sx={{ fontSize: '0.85rem' }}>
                            {product.description}
                          </Typography>
                        )}
                        {(product.hsn || product.taxPercent) && (
                          <Box sx={{ display: 'flex', gap: 1, mt: 0.5, flexWrap: 'wrap' }}>
                            {product.hsn && <Chip size="small" label={`HSN: ${product.hsn}`} variant="outlined" sx={{ borderRadius: 50, color: 'text.secondary', height: 24 }} />}
                            {product.taxPercent && <Chip size="small" label={`Tax: ${product.taxPercent}%`} variant="outlined" sx={{ borderRadius: 50, color: 'text.secondary', height: 24 }} />}
                          </Box>
                        )}
                      </Box>
                    </Box>
                  </Box>
                  <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', flexDirection: 'column', alignSelf: 'stretch', justifyContent: 'center' }}>
                    <Typography variant="h6" color="primary.main" sx={{ fontWeight: "bold" }}>
                      {product.rate ? formatCurrency(product.rate, profileCurrency) : '-'}
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 1 }}>
                      <Tooltip title="Edit">
                        <IconButton size="small" onClick={(e) => { e.stopPropagation(); openEdit(product); }} color="primary">
                          <PencilSimple size={16} weight="regular" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Delete">
                        <IconButton size="small" color="error" onClick={(e) => { e.stopPropagation(); handleDelete(product.id); }}>
                          <Trash size={16} weight="regular" />
                        </IconButton>
                      </Tooltip>
                    </Box>
                  </Box>
                </Stack>
              </ElvanCard>
            );
          })}
        </Box>
      )}

      {/* Floating Add Button for Mobile */}
      <Button 
        variant="contained" 
        onClick={openAdd} 
        sx={{ 
          display: { xs: 'flex', md: 'none' }, 
          position: 'fixed', 
          bottom: 80, 
          right: 16, 
          borderRadius: 50, 
          minWidth: 'auto', 
          width: 56, 
          height: 56, 
          p: 0, 
          boxShadow: '0 4px 20px rgba(0,0,0,0.2)',
          bgcolor: isDark ? 'white' : 'black',
          color: isDark ? 'black' : 'white',
          '&:hover': { bgcolor: isDark ? '#e5e5e5' : '#333' }
        }}
      >
        <Plus size={24} weight="bold" />
      </Button>
    </Box>
  );
}
