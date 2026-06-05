import { Users, Trash, CheckSquare, Square } from '@phosphor-icons/react';
import { useState, useEffect } from 'react';
import { getAllClients, getAllBills, deleteClient, saveClient } from '../Avanam';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import { Typography, Box, Stack, IconButton, Tooltip, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, Button } from '@mui/material';
import { useTheme } from '@mui/material/styles';
import ElvanCard from './ElvanCard';
import ElvanListView from './ElvanListView';

export default function Vanigargal({ onEditClient, onAddClient, profile }) {
  const { t } = useLanguage();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';
  const [clients, setClients] = useState([]);
  const [bills, setBills] = useState([]);
  const [confirmDialog, setConfirmDialog] = useState({ open: false, title: '', message: '', action: null });

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

  const filterFn = (c, search) => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    const searchable = [
      c.name, c.nameEn, c.gstin, c.tholaipesi, c.email, 
      c.mugavari, c.mugavariEn, c.oor, c.oorEn, c.pin, 
      c.maanilam, c.maanilamEn, c.country
    ].filter(Boolean).join(' ').toLowerCase();
    return searchable.includes(term);
  };

  const handleBulkDelete = async (ids) => {
    try {
      for (const id of ids) await deleteClient(id);
      thagaval(t('deletedSuccessfully') || 'Deleted successfully', 'success');
      loadData();
    } catch (e) {
      thagaval(t('errorDeleting') || 'Error deleting', 'error');
    }
  };

  const handleBulkDuplicate = async (ids) => {
    try {
      const selected = clients.filter(c => ids.includes(c.id));
      for (const client of selected) {
        const { id, ...rest } = client;
        await saveClient({ ...rest, name: `${client.name} (Copy)` });
      }
      loadData();
      thagaval(t('customersDuplicatedSuccess') || 'Customers duplicated successfully', 'success');
    } catch (e) {
      thagaval(t('errorDuplicating') || 'Error duplicating customers', 'error');
    }
  };

  const handleDeleteSingle = (id) => {
    setConfirmDialog({
      open: true,
      title: t('delete') || 'Delete?',
      message: t('removeSavedClientConfirm') || 'Are you sure you want to remove this client?',
      action: async () => {
        await deleteClient(id);
        thagaval(t('clientRemoved') || 'Client removed', 'success');
        loadData();
      }
    });
  };

  const renderCard = (client, globalIndex, isSelectionMode, isSelected, toggleSelection) => {
    return (
      <ElvanCard 
        key={client.id}
        sx={{ 
          height: '100%',
          ...(isSelectionMode && isSelected ? { bgcolor: isDark ? 'rgba(255,255,255,0.06) !important' : 'rgba(0,0,0,0.04) !important' } : {})
        }}
        onClick={() => isSelectionMode ? toggleSelection(client.id) : onEditClient(client)}
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
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 28, height: 28, mt: 0.15, color: isSelected ? 'primary.main' : 'text.secondary', flexShrink: 0 }}>
                {isSelected ? <CheckSquare size={24} weight="fill" /> : <Square size={24} weight="regular" />}
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
              <Tooltip title={t('delete') || 'Delete'}>
                <IconButton color="error" onClick={(e) => { e.stopPropagation(); handleDeleteSingle(client.id); }}>
                  <Trash size={20} weight="regular" />
                </IconButton>
              </Tooltip>
            )}
          </Box>
        </Stack>
      </ElvanCard>
    );
  };

  return (
    <>
      <ElvanListView 
        title={t('merchants')}
        searchPlaceholder={t('search')}
        addButtonText={t('addClient')}
        onAdd={() => onAddClient(null)}
        items={clients}
        filterFn={filterFn}
        renderCard={renderCard}
        emptyIcon={<Users size={48} weight="regular" style={{ opacity: 0.5 }} />}
        emptyText={t('noClientsFound')}
        onDeleteSelected={handleBulkDelete}
        onDuplicateSelected={handleBulkDuplicate}
        deleteConfirmTitle={t('deleteMerchantsTitle') || 'Delete Merchants?'}
        deleteConfirmMessage={(count) => (t('deleteMerchantsMessage') || 'Are you sure you want to delete {count} merchant(s)?').replace('{count}', count.toString())}
        duplicateConfirmTitle={t('duplicateCustomersTitle') || 'Duplicate Customers?'}
        duplicateConfirmMessage={(count) => (t('duplicateCustomersMessage') || 'Are you sure you want to create copies of the {count} selected customer(s)?').replace('{count}', count.toString())}
      />
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
    </>
  );
}
