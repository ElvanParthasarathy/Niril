import React, { useState } from 'react';
import { SettingsPillContainer, SettingsRow } from '../ElvanSettingsSection';
import { ArrowsClockwise, Trash, WarningCircle, SignOut } from '@phosphor-icons/react';
import { Box, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Typography, CircularProgress, Button } from '@mui/material';
import { thagaval } from '../Thagaval';
import { signOut, EmailAuthProvider, reauthenticateWithCredential } from 'firebase/auth';
import { auth, rtdb } from '../../firebase';
import { ref, remove } from 'firebase/database';

export default function SystemUpdates({ t }: { t: (key: string) => string }) {
  const [eraseDialogOpen, setEraseDialogOpen] = useState(false);
  const [cacheDialogOpen, setCacheDialogOpen] = useState(false);
  const [eraseEmail, setEraseEmail] = useState(auth.currentUser?.email || '');
  const [erasePassword, setErasePassword] = useState('');
  const [erasing, setErasing] = useState(false);

  const handleEraseApp = async () => {
    if (!erasePassword) {
      thagaval('Please enter your password to confirm.', 'warning');
      return;
    }
    setErasing(true);
    try {
      if (auth.currentUser?.email) {
        const credential = EmailAuthProvider.credential(auth.currentUser.email, erasePassword);
        await reauthenticateWithCredential(auth.currentUser, credential);
      } else {
        throw new Error("No user email found.");
      }

      // Wiping the entire database (safely by deleting top-level nodes instead of root if root is blocked)
      const pathsToClear = [
        'pattiyalkal', 'vanigargal', 'porulgal', 'patrugal', 'thannilai', 'mathirigal',
        'coolie_pattiyalkal', 'coolie_vanigargal', 'coolie_porulgal', 'coolie_patrugal', 'coolie_thannilai',
        'profile', 'meta'
      ];
      await Promise.all(pathsToClear.map(p => remove(ref(rtdb, p))));
      
      thagaval('App data completely erased.', 'success');
      localStorage.clear();
      await signOut(auth);
      window.location.replace('/');
    } catch (error: any) {
      console.error(error);
      if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
        thagaval('Incorrect password. Cannot erase data.', 'error');
      } else if (error.code === 'auth/too-many-requests') {
        thagaval('Too many failed attempts. Please try again later.', 'error');
      } else {
        thagaval('Failed to erase data. Check console for details.', 'error');
      }
    }
    setErasing(false);
  };

  const handleClearCache = () => {
    localStorage.clear();
    window.location.replace('/');
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>

      <SettingsPillContainer>
        <SettingsRow 
          icon={<Trash size={20} weight="fill" />} 
          iconColor="monochrome"
          title={t('clearCacheTitle') !== 'clearCacheTitle' ? t('clearCacheTitle') : 'Clear Cache'}
          description="Fix issues by clearing local cache"
          onClick={() => setCacheDialogOpen(true)}
        />
        <SettingsRow 
          icon={<SignOut size={20} weight="fill" />} 
          iconColor="monochrome"
          title={t('accountSecurityTitle') !== 'accountSecurityTitle' ? t('accountSecurityTitle') : 'Sign Out'}
          description="Lock database access on this device"
          onClick={async () => { await signOut(auth); window.location.replace('/'); }}
        />
        <SettingsRow 
          icon={<WarningCircle size={20} weight="fill" />} 
          iconColor="red"
          title={t('eraseAppDataTitle') !== 'eraseAppDataTitle' ? t('eraseAppDataTitle') : 'Erase App Data'}
          description="Permanently wipe all database records"
          onClick={() => setEraseDialogOpen(true)}
        />
      </SettingsPillContainer>

      {/* Clear Cache Dialog */}
      <Dialog open={cacheDialogOpen} onClose={() => setCacheDialogOpen(false)} maxWidth="xs" fullWidth slotProps={{ paper: { sx: { borderRadius: 3 } } }}>
        <DialogTitle sx={{ fontWeight: 600, pb: 1 }}>Clear Local Cache?</DialogTitle>
        <DialogContent sx={{ color: 'text.secondary' }}>
          Are you sure you want to clear the local cache and reload? You will need to log in again if using Google Drive.
        </DialogContent>
        <DialogActions sx={{ p: 2, pt: 0 }}>
          <Button onClick={() => setCacheDialogOpen(false)} sx={{ color: 'text.secondary', fontWeight: 600, borderRadius: 2 }}>
            Cancel
          </Button>
          <Button onClick={handleClearCache} variant="contained" sx={{ bgcolor: 'var(--mac-selection-hover)', color: 'var(--mac-text)', borderRadius: 2, px: 3, fontWeight: 600, boxShadow: 'none', '&:hover': { bgcolor: 'action.hover', boxShadow: 'none' } }}>
            Clear Cache
          </Button>
        </DialogActions>
      </Dialog>

      {/* Erase App Data Dialog */}
      <Dialog open={eraseDialogOpen} onClose={() => !erasing && setEraseDialogOpen(false)} maxWidth="xs" fullWidth slotProps={{ paper: { sx: { borderRadius: 3 } } }}>
        <DialogTitle sx={{ color: 'error.main', fontWeight: 600 }}>Erase All App Data?</DialogTitle>
        <DialogContent>
          <Typography sx={{ mb: 2, color: 'text.secondary' }}>
            This action will <b>permanently delete</b> all invoices, inventory, and profile settings from the cloud database. This cannot be undone.
          </Typography>
          <Typography sx={{ mb: 1, fontSize: '0.875rem', fontWeight: 500 }}>
            Confirm your password ({eraseEmail}):
          </Typography>
          <TextField
            fullWidth
            type="password"
            size="small"
            variant="outlined"
            disabled={erasing}
            value={erasePassword}
            onChange={(e) => setErasePassword(e.target.value)}
            placeholder="Firebase Password"
            sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
          />
        </DialogContent>
        <DialogActions sx={{ p: 2, pt: 0 }}>
          <Button disabled={erasing} onClick={() => setEraseDialogOpen(false)} sx={{ color: 'text.secondary', fontWeight: 600, borderRadius: 2 }}>
            Cancel
          </Button>
          <Button 
            disabled={erasing || !erasePassword} 
            onClick={handleEraseApp} 
            variant="contained" 
            color="error"
            sx={{ borderRadius: 2, px: 3, fontWeight: 600, boxShadow: 'none', '&:hover': { boxShadow: 'none' } }}
            startIcon={erasing ? <CircularProgress size={16} color="inherit" /> : <WarningCircle />}
          >
            {erasing ? 'Erasing...' : 'Permanently Erase'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
