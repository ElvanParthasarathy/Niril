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
      thagaval(t('enterPassword') || 'Please enter your password', 'warning');
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
      
      thagaval(t('dataErasedSuccess') || 'App data erased.', 'success');
      localStorage.clear();
      await signOut(auth);
      window.location.replace('/');
    } catch (error: any) {
      console.error(error);
      if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
        thagaval(t('incorrectPassword') || 'Incorrect password.', 'error');
      } else if (error.code === 'auth/too-many-requests') {
        thagaval(t('tooManyRequests') || 'Too many attempts. Try later.', 'error');
      } else {
        thagaval(t('errorOccurred') || 'Failed to erase data.', 'error');
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
          description={t('clearCacheDesc') !== 'clearCacheDesc' ? t('clearCacheDesc') : 'Fix issues by clearing cache'}
          onClick={() => setCacheDialogOpen(true)}
        />
        <SettingsRow 
          icon={<SignOut size={20} weight="fill" />} 
          iconColor="monochrome"
          title={t('accountSecurityTitle') !== 'accountSecurityTitle' ? t('accountSecurityTitle') : 'Sign Out'}
          description={t('accountSecurityDesc') !== 'accountSecurityDesc' ? t('accountSecurityDesc') : 'Lock app access'}
          onClick={async () => { await signOut(auth); window.location.replace('/'); }}
        />
        <SettingsRow 
          icon={<WarningCircle size={20} weight="fill" />} 
          iconColor="red"
          title={t('eraseAppDataTitle') !== 'eraseAppDataTitle' ? t('eraseAppDataTitle') : 'Erase App Data'}
          description={t('eraseAppDataDesc') !== 'eraseAppDataDesc' ? t('eraseAppDataDesc') : 'Permanently wipe all records'}
          onClick={() => setEraseDialogOpen(true)}
        />
      </SettingsPillContainer>

      {/* Clear Cache Dialog */}
      <Dialog open={cacheDialogOpen} onClose={() => setCacheDialogOpen(false)} maxWidth="xs" fullWidth slotProps={{ paper: { sx: { borderRadius: 3 } } }}>
        <DialogTitle sx={{ fontWeight: 600, pb: 1, fontSize: '1.125rem' }}>{t('clearCacheTitle') !== 'clearCacheTitle' ? t('clearCacheTitle') : 'Clear Cache?'}</DialogTitle>
        <DialogContent sx={{ color: 'text.secondary', fontSize: '0.875rem' }}>
          {t('clearCacheConfirmDesc') !== 'clearCacheConfirmDesc' ? t('clearCacheConfirmDesc') : 'This will reload the app. You may need to sign in again.'}
        </DialogContent>
        <DialogActions sx={{ p: 2, pt: 0 }}>
          <Button onClick={() => setCacheDialogOpen(false)} sx={{ color: 'text.secondary', fontWeight: 600, borderRadius: 2, fontSize: '0.875rem', textTransform: 'none' }}>
            {t('cancel') !== 'cancel' ? t('cancel') : 'Cancel'}
          </Button>
          <Button onClick={handleClearCache} variant="contained" disableElevation sx={{ bgcolor: 'black', color: 'white', borderRadius: 2, px: 3, fontWeight: 600, fontSize: '0.875rem', textTransform: 'none', '&:hover': { bgcolor: '#333' } }}>
            {t('clearCacheBtn') !== 'clearCacheBtn' ? t('clearCacheBtn') : 'Clear'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Erase App Data Dialog */}
      <Dialog open={eraseDialogOpen} onClose={() => !erasing && setEraseDialogOpen(false)} maxWidth="xs" fullWidth slotProps={{ paper: { sx: { borderRadius: 3 } } }}>
        <DialogTitle sx={{ color: 'error.main', fontWeight: 600, fontSize: '1.125rem' }}>{t('eraseAppDataTitle') !== 'eraseAppDataTitle' ? t('eraseAppDataTitle') : 'Erase All Data?'}</DialogTitle>
        <DialogContent>
          <Typography sx={{ mb: 2, color: 'text.secondary', fontSize: '0.875rem' }}>
            {t('eraseConfirmDesc') !== 'eraseConfirmDesc' ? t('eraseConfirmDesc') : 'Permanently deletes all cloud data. This cannot be undone.'}
          </Typography>
          <Typography sx={{ mb: 1, fontSize: '0.8125rem', fontWeight: 500 }}>
            {t('confirmPassword') !== 'confirmPassword' ? t('confirmPassword') : 'Confirm Password'}:
          </Typography>
          <TextField
            fullWidth
            type="password"
            size="small"
            variant="outlined"
            disabled={erasing}
            value={erasePassword}
            onChange={(e) => setErasePassword(e.target.value)}
            placeholder={t('password') !== 'password' ? t('password') : 'Password'}
            sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, fontSize: '0.875rem' } }}
          />
        </DialogContent>
        <DialogActions sx={{ p: 2, pt: 0 }}>
          <Button disabled={erasing} onClick={() => setEraseDialogOpen(false)} sx={{ color: 'text.secondary', fontWeight: 600, borderRadius: 2, fontSize: '0.875rem', textTransform: 'none' }}>
            {t('cancel') !== 'cancel' ? t('cancel') : 'Cancel'}
          </Button>
          <Button 
            disabled={erasing || !erasePassword} 
            onClick={handleEraseApp} 
            variant="contained" 
            color="error"
            disableElevation
            sx={{ borderRadius: 2, px: 3, fontWeight: 600, fontSize: '0.875rem', textTransform: 'none', '&:hover': { boxShadow: 'none' } }}
            startIcon={erasing ? <CircularProgress size={16} color="inherit" /> : <WarningCircle />}
          >
            {erasing ? (t('erasing') !== 'erasing' ? t('erasing') : 'Erasing...') : (t('eraseDataBtn') !== 'eraseDataBtn' ? t('eraseDataBtn') : 'Erase')}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
