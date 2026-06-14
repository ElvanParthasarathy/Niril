import React, { useState } from 'react';
import { SettingsPillContainer, SettingsRow } from '../ElvanSettingsSection';
import { ArrowsClockwise, Trash } from '@phosphor-icons/react';
import { LockKeyhole } from 'lucide-react';
import { Button, Box } from '@mui/material';
import { thagaval } from '../Thagaval';
import { signOut } from 'firebase/auth';
import { auth } from '../../firebase';

export default function SystemUpdates({ t }: { t: (key: string) => string }) {
  const [updateInfo, setUpdateInfo] = useState<any>(null);
  const [checkingUpdate, setCheckingUpdate] = useState(false);
  const showAppVersion = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' || !!(window as any).Capacitor || window.matchMedia('(display-mode: standalone)').matches;

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
      {showAppVersion && (
      <SettingsPillContainer>
        <SettingsRow
          icon={<ArrowsClockwise size={20} weight="fill" />}
          iconColor="blue"
          title="App Version"
          description={updateInfo ? `Current: v${updateInfo.current}${updateInfo.latest ? ` | Latest: v${updateInfo.latest}` : ''}` : "Checking for updates manually."}
          control={
            <Button variant="outlined" size="small" disabled={checkingUpdate} onClick={async () => {
              setCheckingUpdate(true);
              try {
                const res = await fetch('/api/check-update');
                const data = await res.json();
                setUpdateInfo(data);
                if (data.updateAvailable) {
                  thagaval(`Update available: v${data.latest}`, 'info');
                } else if (data.error) {
                  thagaval('Could not check for updates. Check internet connection.', 'warning');
                } else {
                  thagaval('You are on the latest version!', 'success');
                }
              } catch {
                thagaval('Could not check for updates.', 'error');
              }
              setCheckingUpdate(false);
            }}>
              {checkingUpdate ? (t('checkingUpdate') || 'Checking...') : (t('checkForUpdates') || 'Check for Updates')}
            </Button>
          }
        />

        {updateInfo?.updateAvailable && (
          <SettingsRow
            title="New Version Available"
            description={`v${updateInfo.latest} is ready to install.`}
            control={
              <Button component="a" href="elvanniril-update://run" variant="contained" color="primary" size="small">
                Update Now
              </Button>
            }
          />
        )}
      </SettingsPillContainer>
      )}

      <SettingsPillContainer>
        <SettingsRow 
          icon={<Trash size={20} weight="fill" />} 
          iconColor="monochrome"
          title={t('clearCacheTitle') !== 'clearCacheTitle' ? t('clearCacheTitle') : 'Clear Cache'}
          description={t('clearCacheDesc') !== 'clearCacheDesc' ? t('clearCacheDesc') : 'Clear local cache to fix issues.'}
          control={
            <Button variant="outlined" color="inherit" size="small" sx={{ borderRadius: 10, px: 2 }} onClick={() => {
              if (confirm('Clear local cache and reload? You will need to log in again if using Google Drive.')) {
                localStorage.clear();
                window.location.reload();
              }
            }}>
              {t('clearCacheBtn') !== 'clearCacheBtn' ? t('clearCacheBtn') : 'Clear Cache'}
            </Button>
          }
        />
        <SettingsRow 
          icon={<LockKeyhole size={20} />} 
          iconColor="monochrome"
          title="Account Security"
          description="Sign out of Firebase to lock your database access on this device."
          control={
            <Button variant="outlined" color="inherit" size="small" sx={{ borderRadius: 8 }} onClick={() => { signOut(auth); }}>
              Sign Out
            </Button>
          }
        />
      </SettingsPillContainer>
    </Box>
  );
}
