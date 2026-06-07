import React, { useState, useEffect } from 'react';
import { Box, Typography, Button, TextField, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, Chip } from '@mui/material';
import { Plus, Trash, PencilSimple, Users } from '@phosphor-icons/react';
import { getAllCoolieClients, saveCoolieClient, deleteCoolieClient } from '../../Avanam';
import { useLanguage } from '../../mozhi/LanguageContext';
import ElvanCard from '../ElvanCard';

export default function CoolieMerchants() {
  const { t } = useLanguage();
  const [clients, setClients] = useState<any[]>([]);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingClient, setEditingClient] = useState<any>(null);
  
  // Form state
  const [name, setName] = useState('');
  const [nameEn, setNameEn] = useState('');
  const [city, setCity] = useState('');
  const [cityEn, setCityEn] = useState('');
  const [address, setAddress] = useState('');
  const [addressEn, setAddressEn] = useState('');
  const [phone, setPhone] = useState('');

  useEffect(() => {
    fetchClients();
  }, []);

  const fetchClients = async () => {
    const data = await getAllCoolieClients();
    setClients(data || []);
  };

  const handleOpen = (client = null) => {
    if (client) {
      setEditingClient(client);
      setName(client.name || client.companyName || '');
      setNameEn(client.nameEn || client.companyNameEn || '');
      setCity(client.city || '');
      setCityEn(client.cityEn || '');
      setAddress(client.address || '');
      setAddressEn(client.addressEn || '');
      setPhone(client.phone || '');
    } else {
      setEditingClient(null);
      setName('');
      setNameEn('');
      setCity('');
      setCityEn('');
      setAddress('');
      setAddressEn('');
      setPhone('');
    }
    setIsDialogOpen(true);
  };

  const handleSave = async () => {
    const clientData = {
      id: editingClient?.id || Date.now().toString(),
      name,
      nameEn,
      city,
      cityEn,
      address,
      addressEn,
      phone
    };
    
    await saveCoolieClient(clientData);
    setIsDialogOpen(false);
    fetchClients();
  };

  const handleDelete = async (id) => {
    if (window.confirm("Delete this customer?")) {
      await deleteCoolieClient(id);
      fetchClients();
    }
  };

  return (
    <Box sx={{ maxWidth: '1200px', margin: '0 auto', p: { xs: 2, md: 4 } }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 800 }}>{t('merchants') || 'Merchants'}</Typography>
        <Button variant="contained" startIcon={<Plus />} onClick={() => handleOpen()}>{t('addClient') || 'Add Merchant'}</Button>
      </Box>

      <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 3 }}>
        {clients.map(client => (
          <ElvanCard key={client.id} sx={{ p: 3, position: 'relative' }}>
            <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
              <Box sx={{ width: 40, height: 40, borderRadius: 2, bgcolor: '#e3f2fd', color: '#1976d2', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Users size={20} />
              </Box>
              <Box>
                <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>{client.name || client.nameEn || client.companyName || client.companyNameEn || 'Unknown'}</Typography>
                <Typography variant="body2" color="text.secondary">{client.city || client.cityEn || 'No City'}</Typography>
              </Box>
            </Box>
            
            <Box sx={{ display: 'flex', gap: 1, mb: 2, flexWrap: 'wrap' }}>
              {client.phone && <Chip size="small" variant="outlined" label={client.phone} />}
            </Box>
            
            <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1, mt: 2, borderTop: '1px solid', borderColor: 'divider', pt: 2 }}>
              <IconButton size="small" color="primary" onClick={() => handleOpen(client)}><PencilSimple /></IconButton>
              <IconButton size="small" color="error" onClick={() => handleDelete(client.id)}><Trash /></IconButton>
            </Box>
          </ElvanCard>
        ))}
      </Box>

      {/* Editor Dialog */}
      <Dialog open={isDialogOpen} onClose={() => setIsDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{editingClient ? t('editClientTitle') || 'Edit Merchant' : t('addNewClientTitle') || 'Add New Merchant'}</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
          <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2, mt: 1 }}>
            <TextField label="Name (Tamil)" size="small" value={name} onChange={e => setName(e.target.value)} />
            <TextField label="Name (English)" size="small" value={nameEn} onChange={e => setNameEn(e.target.value)} />
            <TextField label="City (Tamil)" size="small" value={city} onChange={e => setCity(e.target.value)} />
            <TextField label="City (English)" size="small" value={cityEn} onChange={e => setCityEn(e.target.value)} />
          </Box>
          <TextField label="Address (Tamil)" size="small" fullWidth value={address} onChange={e => setAddress(e.target.value)} />
          <TextField label="Address (English)" size="small" fullWidth value={addressEn} onChange={e => setAddressEn(e.target.value)} />
          <TextField label="Phone Number" size="small" fullWidth value={phone} onChange={e => setPhone(e.target.value)} />
        </DialogContent>
        <DialogActions sx={{ p: 3 }}>
          <Button onClick={() => setIsDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
