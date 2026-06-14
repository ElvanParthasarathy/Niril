import React, { useState } from 'react';
import { SettingsPillContainer, SettingsRow } from '../ElvanSettingsSection';
import { ArrowsClockwise } from '@phosphor-icons/react';
import { Button, Box } from '@mui/material';
import { thagaval } from '../Thagaval';

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

    </Box>
  );
}
