import React, { useState, useEffect } from 'react';
import { Box, Typography, Button, TextField, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, Table, TableBody, TableCell, TableHead, TableRow, Paper, TableContainer } from '@mui/material';
import { Plus, Trash, PencilSimple, Package } from '@phosphor-icons/react';
import { getAllCoolieProducts, saveCoolieProduct, deleteCoolieProduct } from '../../Avanam';
import { useLanguage } from '../../mozhi/LanguageContext';

export default function CoolieItems() {
  const { t } = useLanguage();
  const [items, setItems] = useState<any[]>([]);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  
  // Form state
  const [name, setName] = useState('');
  const [nameEn, setNameEn] = useState('');

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    const data = await getAllCoolieProducts();
    setItems(data || []);
  };

  const handleOpen = (item = null) => {
    if (item) {
      setEditingItem(item);
      setName(item.name || '');
      setNameEn(item.nameEn || '');
    } else {
      setEditingItem(null);
      setName('');
      setNameEn('');
    }
    setIsDialogOpen(true);
  };

  const handleSave = async () => {
    const itemData = {
      id: editingItem?.id || Date.now().toString(),
      name,
      nameEn
    };
    
    await saveCoolieProduct(itemData);
    setIsDialogOpen(false);
    fetchItems();
  };

  const handleDelete = async (id) => {
    if (window.confirm("Delete this item?")) {
      await deleteCoolieProduct(id);
      fetchItems();
    }
  };

  return (
    <Box sx={{ maxWidth: '1000px', margin: '0 auto', p: { xs: 2, md: 4 } }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 800 }}>{t('itemsTitle') || 'Coolie Items'}</Typography>
        <Button variant="contained" startIcon={<Plus />} onClick={() => handleOpen()}>{t('addItemBtn') || 'Add Item'}</Button>
      </Box>

      <TableContainer component={Paper} sx={{ borderRadius: 3, boxShadow: '0 4px 20px rgba(0,0,0,0.05)' }}>
        <Table>
          <TableHead sx={{ bgcolor: 'background.default' }}>
            <TableRow>
              <TableCell sx={{ fontWeight: 700 }}>Name (Tamil)</TableCell>
              <TableCell sx={{ fontWeight: 700 }}>Name (English)</TableCell>
              <TableCell sx={{ fontWeight: 700, textAlign: 'right' }}>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {items.map((item) => (
              <TableRow key={item.id} hover>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                    <Package size={20} color="#666" />
                    <Typography fontWeight={600}>{item.name}</Typography>
                  </Box>
                </TableCell>
                <TableCell>{item.nameEn}</TableCell>
                <TableCell align="right">
                  <IconButton color="primary" onClick={() => handleOpen(item)}><PencilSimple size={18} /></IconButton>
                  <IconButton color="error" onClick={() => handleDelete(item.id)}><Trash size={18} /></IconButton>
                </TableCell>
              </TableRow>
            ))}
            {items.length === 0 && (
              <TableRow>
                <TableCell colSpan={3} align="center" sx={{ py: 4, color: 'text.secondary' }}>
                  No items found. Add your first coolie product.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Editor Dialog */}
      <Dialog open={isDialogOpen} onClose={() => setIsDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>{editingItem ? 'Edit Item' : 'Add Item'}</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 3, pt: 2 }}>
          <TextField label="Name (Tamil)" size="small" fullWidth value={name} onChange={e => setName(e.target.value)} sx={{ mt: 1 }} />
          <TextField label="Name (English)" size="small" fullWidth value={nameEn} onChange={e => setNameEn(e.target.value)} />
        </DialogContent>
        <DialogActions sx={{ p: 3 }}>
          <Button onClick={() => setIsDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
