import { Package, MagnifyingGlass, Plus, PencilSimple, Trash, X, FloppyDisk, UploadSimple, Tag, FileText, CheckSquare, Square, Copy } from '@phosphor-icons/react';
import React, { useState, useEffect, useRef } from 'react';
import { useTheme } from '@mui/material/styles';
import {
  Box, Typography, Button, Paper, TextField, InputAdornment, IconButton,
  Dialog, DialogTitle, DialogContent, DialogActions, DialogContentText, Grid, Select, MenuItem,
  InputLabel, FormControl, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Tooltip, Chip, Fade, Zoom, Divider, Slide,
  Card, CardContent, Stack, Toolbar, Pagination
} from '@mui/material';
import { getAllProducts, saveProduct, deleteProduct, getProfile } from '../Avanam';
import { getAllUnits, getCountryConfig, formatCurrency } from '../Payanpadu';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import { getSearchPaperSx, searchInputStyle, getEditPaperSx, getEditIconButtonSx, getAddButtonSx } from './commonStyles';
import ElvanCard from './ElvanCard';

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

  const [page, setPage] = useState(1);
  const [isSelectionMode, setIsSelectionMode] = useState(false);
  const [selectedProductIds, setSelectedProductIds] = useState([]);
  const [copyConfirmOpen, setCopyConfirmOpen] = useState(false);
  const [confirmDialog, setConfirmDialog] = useState({ open: false, title: '', message: '', action: null });
  const topRef = useRef(null);

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

  const filtered = products.filter(p => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    const searchable = [
      p.name, p.nameEn, p.hsn, p.rate?.toString(), p.taxPercent?.toString(),
      p.description, p.descriptionEn, p.unit
    ].filter(Boolean).join(' ').toLowerCase();
    return searchable.includes(term);
  });

  const ITEMS_PER_PAGE = 6;
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE);
  const safePage = Math.max(1, Math.min(page, totalPages === 0 ? 1 : totalPages));
  const paginatedProducts = filtered.slice((safePage - 1) * ITEMS_PER_PAGE, safePage * ITEMS_PER_PAGE);

  const openAdd = () => {
    onAddProduct(null);
  };

  const openEdit = (product) => {
    onEditProduct(product);
  };

  const handleDelete = (id) => {
    setConfirmDialog({
      open: true,
      title: 'Delete Product?',
      message: t('deleteProductConfirmMsg') || 'Are you sure you want to delete this product?',
      action: async () => {
        try {
          await deleteProduct(id);
          thagaval(t('productDeletedToast') || 'Deleted successfully', 'success');
          loadProducts();
        } catch {
          thagaval('Failed to delete', 'error');
        }
      }
    });
  };

  const handleSelectAll = () => {
    if (selectedProductIds.length === filtered.length) {
      setSelectedProductIds([]);
    } else {
      setSelectedProductIds(filtered.map(p => p.id));
    }
  };

  const toggleSelection = (id) => {
    setSelectedProductIds(prev =>
      prev.includes(id) ? prev.filter(pId => pId !== id) : [...prev, id]
    );
  };

  const handleCopySelected = () => {
    if (selectedProductIds.length === 0) return;
    setCopyConfirmOpen(true);
  };

  const executeCopy = async () => {
    try {
      const selected = products.filter(p => selectedProductIds.includes(p.id));
      for (const product of selected) {
        const { id, ...rest } = product;
        await saveProduct({ ...rest, name: `${product.name} (Copy)` });
      }
      setSelectedProductIds([]);
      setCopyConfirmOpen(false);
      loadProducts();
      thagaval(t('productsDuplicatedSuccess') || 'Products duplicated successfully', 'success');
    } catch (e) {
      thagaval(t('errorDuplicating') || 'Error duplicating', 'error');
    }
  };

  const handleDeleteSelected = () => {
    if (selectedProductIds.length === 0) return;
    setConfirmDialog({
      open: true,
      title: t('deleteProductsTitle') || 'Delete Products?',
      message: (t('deleteProductsMessage') || 'Are you sure you want to delete {count} product(s)? This action cannot be undone.').replace('{count}', selectedProductIds.length.toString()),
      action: async () => {
        try {
          for (const id of selectedProductIds) {
            await deleteProduct(id);
          }
          setSelectedProductIds([]);
          setIsSelectionMode(false);
          loadProducts();
          thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
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
          {t('inventoryTitle') || 'Products'}
        </Typography>
      </Box>

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
            placeholder={t('searchProducts') || 'Search products...'}
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
            onClick={() => { setIsSelectionMode(!isSelectionMode); setSelectedProductIds([]); }}
            sx={getEditIconButtonSx(isDark)}
          >
            <PencilSimple size={18} weight={isSelectionMode ? 'fill' : 'regular'} color={isDark ? '#fff' : '#000'} />
          </IconButton>
          </Paper>
          <Button variant="contained" sx={getAddButtonSx(isDark)} onClick={openAdd} startIcon={<Plus size={18} weight="bold" />}>
            {t('addProductBtn') || 'Add Product'}
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
            {selectedProductIds.length === filtered.length && filtered.length > 0 ? <CheckSquare size={24} weight="fill" /> : <Square size={24} weight="regular" />}
          </IconButton>
          
          <Typography sx={{ flex: '1 1 100%', fontWeight: 600, display: 'flex', alignItems: 'center', lineHeight: 1, mt: 0.3 }} color="primary" variant="subtitle1" component="div">
            {selectedProductIds.length} {t('selected') || 'Selected'}
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
          {paginatedProducts.map((product, index) => {
            const globalIndex = (safePage - 1) * ITEMS_PER_PAGE + index;
            return (
              <ElvanCard 
                key={product.id}
                sx={{ 
                  height: '100%',
                  ...(isSelectionMode && selectedProductIds.includes(product.id) ? { bgcolor: isDark ? 'rgba(255,255,255,0.06) !important' : 'rgba(0,0,0,0.04) !important' } : {})
                }}
                onClick={() => isSelectionMode ? toggleSelection(product.id) : openEdit(product)}
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
                      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 28, height: 28, mt: 0.15, color: selectedProductIds.includes(product.id) ? 'primary.main' : 'text.secondary', flexShrink: 0 }}>
                        {selectedProductIds.includes(product.id) ? <CheckSquare size={24} weight="fill" /> : <Square size={24} weight="regular" />}
                      </Box>
                    )}
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
                          <Typography variant="body2" sx={{ fontSize: '0.85rem', mt: 0.5 }}>
                            {product.hsn ? `HSN: ${product.hsn}` : ''}
                            {product.hsn && product.taxPercent ? <span style={{ opacity: 0.6, margin: '0 6px' }}>•</span> : ''}
                            {product.taxPercent ? `Tax: ${product.taxPercent}%` : ''}
                          </Typography>
                        )}
                      </Box>
                    </Box>
                  </Box>
                  <Box sx={{ display: 'flex', gap: 1, alignItems: 'flex-end', flexDirection: 'column', alignSelf: 'stretch', justifyContent: isSelectionMode ? 'space-between' : 'flex-end' }}>
                    {isSelectionMode && (
                      <Tooltip title="Delete">
                        <IconButton color="error" size="small" onClick={(e) => { e.stopPropagation(); handleDelete(product.id); }} sx={{ mt: -0.5, mr: -0.5 }}>
                          <Trash size={20} weight="regular" />
                        </IconButton>
                      </Tooltip>
                    )}
                    <Typography variant="subtitle1" color="primary.main" sx={{ fontWeight: 800 }}>
                      {product.rate ? formatCurrency(product.rate, profileCurrency) : '-'}
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

      <Dialog open={copyConfirmOpen} onClose={() => setCopyConfirmOpen(false)} PaperProps={{ elevation: 8, sx: { borderRadius: '24px', p: 1 } }}>
        <DialogTitle sx={{ fontWeight: 800 }}>{t('duplicateProductsTitle') || 'Duplicate Products?'}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            {(t('duplicateProductsMessage') || 'Are you sure you want to create copies of the {count} selected product(s)?').replace('{count}', selectedProductIds.length.toString())}
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
