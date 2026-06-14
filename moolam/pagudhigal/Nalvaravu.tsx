import { useLanguage } from '../mozhi/LanguageContext';
// @ts-nocheck
import { Buildings, FileText, Check, ArrowRight } from '@phosphor-icons/react';
import { useState } from 'react';
import { Box, Typography, Paper, Grid, TextField, Button } from '@mui/material';
import { saveProfile, saveCoolieProfile } from '../Avanam';
import { thagaval } from './Thagaval';

import { AuthLayout, AuthHeader, AuthInput, AuthButton } from './auth/AuthComponents';

export default function Nalvaravu({ onComplete }) {
  const { t } = useLanguage();

  const [gstBusinessName, setGstBusinessName] = useState('');
  const [coolieBusinessName, setCoolieBusinessName] = useState('');
  const [saving, setSaving] = useState(false);

  const handleFinish = async () => {
    if (!gstBusinessName.trim() || !coolieBusinessName.trim()) {
      thagaval('Please enter both business names.', 'warning');
      return;
    }
    
    setSaving(true);
    try {
      const gstProfile = { niruvanathinPeyar: gstBusinessName.trim() };
      await saveProfile(gstProfile);
      
      const coolieProfile = { name: coolieBusinessName.trim() };
      await saveCoolieProfile(coolieProfile);
      
      localStorage.setItem('elvanniril_onboarded', 'true');
      thagaval('Setup complete! Start creating invoices.', 'success');
      onComplete(gstProfile);
    } catch {
      thagaval('Failed to save. Try again.', 'error');
    }
    setSaving(false);
  };

  return (
    <AuthLayout>
      <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
        <div style={{ width: '64px', height: '64px', borderRadius: '16px', background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem', boxShadow: '0 20px 40px var(--auth-glow)' }}>
          <Buildings size={32} weight="regular" color="white" />
        </div>
        <AuthHeader 
          title={t('hc_welcomeToElvanNiril') || 'Welcome'} 
          subtitle="Let's get started. Please enter your business names below to set up your profiles." 
        />
      </div>

      <div style={{ width: '100%', maxWidth: '360px', margin: '0 auto', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
        <AuthInput 
          variant="filled"
          label={t('hc_businessName') || 'GST Business Name'}
          value={gstBusinessName}
          onChange={(e) => setGstBusinessName(e.target.value)}
          placeholder="e.g. Sharma Consultants Pvt Ltd"
          helperText="Used for regular GST invoices."
        />

        <AuthInput 
          variant="filled"
          label="Coolie Business Name"
          value={coolieBusinessName}
          onChange={(e) => setCoolieBusinessName(e.target.value)}
          placeholder="e.g. Sharma Coolie Works"
          helperText="Used for Coolie bills and receipts."
        />

        <Box sx={{ mt: 2 }}>
          <AuthButton 
            onClick={handleFinish} 
            disabled={saving || !gstBusinessName.trim() || !coolieBusinessName.trim()} 
            loading={saving}
          >
            Start Billing
          </AuthButton>
        </Box>
      </div>
    </AuthLayout>
  );
}
