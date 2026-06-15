import React, { useState } from 'react';
import { SettingsPillContainer, SettingsRow, SettingsDivider } from '../ElvanSettingsSection';
import { ArrowsClockwise, Trash, WarningCircle } from '@phosphor-icons/react';
import { LockKeyhole } from 'lucide-react';
import { Box, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Typography, CircularProgress, Button } from '@mui/material';
import { thagaval } from '../Thagaval';
import { signOut, EmailAuthProvider, reauthenticateWithCredential } from 'firebase/auth';
import { auth, rtdb } from '../../firebase';
import { ref, remove } from 'firebase/database';

export default function SystemUpdates({ t }: { t: (key: string) => string }) {
  const [eraseDialogOpen, setEraseDialogOpen] = useState(false);
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

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>

      <SettingsPillContainer>
        <SettingsRow 
          icon={<Trash size={20} weight="fill" />} 
          iconColor="monochrome"
          title={t('clearCacheTitle') !== 'clearCacheTitle' ? t('clearCacheTitle') : 'Clear Cache'}
          description="Fix issues by clearing local cache"
          onClick={() => {
            if (confirm('Clear local cache and reload? You will need to log in again if using Google Drive.')) {
              localStorage.clear();
              window.location.replace('/');
            }
          }}
        />
        <SettingsDivider />
        <SettingsRow 
          icon={<LockKeyhole size={20} />} 
          iconColor="monochrome"
          title={t('accountSecurityTitle') !== 'accountSecurityTitle' ? t('accountSecurityTitle') : 'Sign Out'}
          description="Lock database access on this device"
          onClick={async () => { await signOut(auth); window.location.replace('/'); }}
        />
        <SettingsDivider />
        <SettingsRow 
          icon={<WarningCircle size={20} weight="fill" />} 
          iconColor="red"
          title={t('eraseAppDataTitle') !== 'eraseAppDataTitle' ? t('eraseAppDataTitle') : 'Erase App Data'}
          description="Permanently wipe all database records"
          onClick={() => setEraseDialogOpen(true)}
        />
      </SettingsPillContainer>

      <Dialog open={eraseDialogOpen} onClose={() => !erasing && setEraseDialogOpen(false)} maxWidth="xs" fullWidth slotProps={{ paper: { sx: { borderRadius: 3 } } }}>
        <DialogTitle sx={{ color: 'error.main', fontWeight: 'bold' }}>Erase All App Data</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 3 }}>
            This action will permanently delete all your data, bills, receipts, and settings from the database. This cannot be undone unless you have a backup file to import later.
          </Typography>
          <Typography variant="body2" sx={{ mb: 1, fontWeight: 'bold' }}>
            Account ID (Email)
          </Typography>
          <TextField
            fullWidth
            size="small"
            value={eraseEmail}
            disabled
            sx={{ mb: 2 }}
          />
          <Typography variant="body2" sx={{ mb: 1, fontWeight: 'bold' }}>
            Password to Confirm
          </Typography>
          <TextField
            fullWidth
            size="small"
            type="password"
            placeholder="Enter your password"
            value={erasePassword}
            onChange={(e) => setErasePassword(e.target.value)}
            disabled={erasing}
            autoFocus
          />
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setEraseDialogOpen(false)} disabled={erasing} color="inherit">Cancel</Button>
          <Button onClick={handleEraseApp} disabled={!erasePassword || erasing} color="error" variant="contained" sx={{ borderRadius: 8, px: 3 }}>
            {erasing ? <CircularProgress size={20} color="inherit" /> : 'Erase Everything'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
