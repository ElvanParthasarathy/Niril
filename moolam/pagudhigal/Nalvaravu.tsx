import { useLanguage } from '../mozhi/LanguageContext';
// @ts-nocheck
import { Buildings, FileText, Check, ArrowRight } from '@phosphor-icons/react';
import { useState } from 'react';
import { Box, Typography, Paper, Grid, TextField, Button } from '@mui/material';
import { saveProfile, saveCoolieProfile } from '../Avanam';
import { thagaval } from './Thagaval';

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
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '1rem', background: 'var(--bg-primary)' }}>
      <div style={{ maxWidth: '480px', width: '100%' }}>
        <Paper elevation={0} sx={{ p: { xs: 3, sm: 5 }, borderRadius: 3, border: '1px solid', borderColor: 'divider', bgcolor: 'background.paper' }}>
          <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
            <div style={{ width: '64px', height: '64px', borderRadius: '16px', background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem' }}>
              <Buildings size={32} weight="regular" color="white" />
            </div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, marginBottom: '0.75rem', color: 'var(--text-primary)' }}>{t('hc_welcomeToElvanNiril') || 'Welcome'}</h1>
            <p style={{ color: 'var(--text-secondary)', lineHeight: 1.6 }}>
              Let's get started. Please enter your business names below to set up your profiles.
            </p>
          </div>

          <Grid container spacing={3}>
            <Grid size={{ xs: 12 }}>
              <TextField 
                fullWidth 
                size="medium" 
                required 
                label={t('hc_businessName') || 'GST Business Name'} 
                value={gstBusinessName} 
                onChange={(e) => setGstBusinessName(e.target.value)} 
                placeholder="e.g. Sharma Consultants Pvt Ltd" 
                helperText="Used for regular GST invoices."
              />
            </Grid>

            <Grid size={{ xs: 12 }}>
              <TextField 
                fullWidth 
                size="medium" 
                required 
                label="Coolie Business Name" 
                value={coolieBusinessName} 
                onChange={(e) => setCoolieBusinessName(e.target.value)} 
                placeholder="e.g. Sharma Coolie Works" 
                helperText="Used for Coolie bills and receipts."
              />
            </Grid>
          </Grid>

          <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 4, pt: 3, borderTop: '1px solid', borderColor: 'divider' }}>
            <Button 
              variant="contained" 
              color="primary" 
              onClick={handleFinish} 
              disabled={saving || !gstBusinessName.trim() || !coolieBusinessName.trim()} 
              endIcon={<ArrowRight size={16} weight="regular" />} 
              sx={{ textTransform: 'none', px: 4, py: 1 }}
            >
              {saving ? 'Saving...' : 'Start Billing'}
            </Button>
          </Box>
        </Paper>
      </div>
    </div>
  );
}
