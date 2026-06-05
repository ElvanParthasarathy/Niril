import { useLanguage } from '../mozhi/LanguageContext';
// @ts-nocheck
import { Buildings, FileText, ChartBar, ShieldCheck, CaretRight, CaretLeft, Check, ArrowRight, Image, PencilSimple } from '@phosphor-icons/react';
import { useState } from 'react';
import { Box, Typography, Paper, Grid, TextField, FormControl, InputLabel, Select, MenuItem, Button, FormHelperText } from '@mui/material';
import { saveProfile } from '../Avanam';
import { getStatesForCountry, getCountryConfig, getBilingualStateName, detectCountryFromBrowser, createEmptyAccount } from '../Payanpadu';
import { thagaval } from './Thagaval';

const STEPS = [
  { id: 'welcome', title: 'Welcome', icon: FileText },
  { id: 'business', title: 'Business Details', icon: Buildings },
  { id: 'bank', title: 'Bank & UPI', icon: ShieldCheck },
  { id: 'ready', title: 'You\'re Ready!', icon: ChartBar },
];

export default function Nalvaravu({ onComplete }) {
  const { t } = useLanguage();

  const [step, setStep] = useState(0);
  const detectedCountry = detectCountryFromBrowser();
  const [profile, setProfile] = useState({
    niruvanathinPeyar: '', mugavari: '', oor: '', pin: '', maanilam: '', country: detectedCountry, gstin: '', pan: '',
    email: '', tholaipesi: '', vangiPeyar: '', kanakkuEn: '', ifsc: '', swift: '',
    logo: '', signature: '', upiId: '', googleClientId: '', googleDriveFolder: 'GST Billing Invoices',
  });

  const [saving, setSaving] = useState(false);
  const cc = getCountryConfig(profile.country);
  const stateOptions = getStatesForCountry(profile.country);

  const handleChange = (e) => {
    setProfile({ ...profile, [e.target.name]: e.target.value });
  };

  const handleFileUpload = (field) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (!file) return;
      if (file.size > 500 * 1024) {
        thagaval('Image must be under 500KB', 'warning');
        return;
      }
      const reader = new FileReader();
      reader.onload = () => setProfile(p => ({ ...p, [field]: reader.result }));
      reader.readAsDataURL(file);
    };
    input.click();
  };

  const handleFinish = async () => {
    setSaving(true);
    try {

      // Mirror the wizard's flat bank/UPI inputs into a single payment account
      // so the multi-account manager has a starting entry. If the user
      // skipped all bank fields, we don't create an empty account — they can
      // add one later in Settings.
      const hasBank = profile.vangiPeyar || profile.kanakkuEn || profile.ifsc || profile.swift || profile.upiId;
      const profileToSave = hasBank ? {
        ...profile,
        paymentAccounts: [{
          ...createEmptyAccount(profile.vangiPeyar || 'Default account'),
          vangiPeyar: profile.vangiPeyar || '',
          kanakkuEn: profile.kanakkuEn || '',
          ifsc: profile.ifsc || '',
          swift: profile.swift || '',
          upiId: profile.upiId || '',
          isDefault: true,
          isActive: true,
        }],
      } : profile;
      await saveProfile(profileToSave);
      localStorage.setItem('elvanniril_onboarded', 'true');
      thagaval('Setup complete! Start creating invoices.', 'success');
      onComplete(profileToSave);
    } catch {
      thagaval('Failed to save. Try again.', 'error');
    }
    setSaving(false);
  };

  const handleSkip = () => {
    localStorage.setItem('elvanniril_onboarded', 'true');
    onComplete(null);
  };

  const canProceed = () => {
    if (step === 1) return profile.niruvanathinPeyar.trim().length > 0;
    return true;
  };

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '1rem', background: 'var(--bg-primary)' }}>
      <div style={{ maxWidth: '640px', width: '100%' }}>
        {/* Progress */}
        <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '2rem', justifyContent: 'center' }}>
          {STEPS.map((s, i) => (
            <div key={s.id} style={{
              width: i === step ? '3rem' : '2rem', height: '4px', borderRadius: '2px',
              background: i <= step ? 'var(--primary)' : 'var(--border-color)',
              transition: 'all 0.3s ease',
            }} />
          ))}
        </div>

        <Paper elevation={0} sx={{ p: { xs: 2, sm: 5 }, borderRadius: 3, border: '1px solid', borderColor: 'divider', bgcolor: 'background.paper' }}>

          {/* Step 0: Welcome */}
          {step === 0 && (
            <div style={{ textAlign: 'center' }}>
              <div style={{ width: '64px', height: '64px', borderRadius: '16px', background: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem' }}>
                <FileText size={32} weight="regular" color="white" />
              </div>
              <h1 style={{ fontSize: '1.75rem', fontWeight: 700, marginBottom: '0.75rem', color: 'var(--text-primary)' }}>{t('hc_welcomeToElvanNiril')}</h1>
              <p style={{ color: 'var(--text-secondary)', marginBottom: '2rem', lineHeight: 1.6 }}>
                Free, open-source GST billing software that runs 100% on your computer. Your data never leaves your machine.
              </p>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '2rem', textAlign: 'left' }}>
                {[
                  { title: 'Create Invoices', desc: 'Tax Invoice, Proforma, Credit Note, Bill of Supply, Delivery Challan' },
                  { title: 'Auto GST Calculation', desc: 'CGST/SGST for same maanilam, IGST for different maanilam — automatic' },
                  { title: 'GST Filing Ready', desc: 'GSTR-1, GSTR-3B, HSN reports auto-generated. Download CSVs for portal.' },
                  { title: '100% Private', desc: 'All data stored locally as files. No cloud, no signup, no tracking.' },
                ].map((item, i) => (
                  <div key={i} style={{ padding: '1rem', borderRadius: '8px', background: 'var(--bg-secondary)', border: '1px solid var(--border-color)' }}>
                    <div style={{ fontWeight: 600, fontSize: '0.85rem', marginBottom: '0.25rem', color: 'var(--text-primary)' }}>{item.title}</div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', lineHeight: 1.4 }}>{item.desc}</div>
                  </div>
                ))}
              </div>

              <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '1.5rem' }}>
                Let's set up your business profile so your invoices look professional. Takes about 2 minutes.
              </p>


            </div>
          )}

          {/* Step 1: Business Details */}
          {step === 1 && (
            <div>
              <h2 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '0.5rem', color: 'var(--text-primary)' }}>{t('hc_businessDetails')}</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginBottom: '1.5rem' }}>
                This info appears on every invoice you generate. You can change it anytime in Settings.
              </p>

              <Grid container spacing={2}>
                <Grid size={{ xs: 12 }}>
                  <TextField fullWidth size="small" required label={t('hc_businessName')} name="niruvanathinPeyar" value={profile.niruvanathinPeyar} onChange={handleChange} placeholder={t('hc_egSharmaConsultantsPvtLtd')} />
                </Grid>

                <Grid size={{ xs: 12 }}>
                  <TextField fullWidth multiline rows={2} size="small" label="Address" name="mugavari" value={profile.mugavari} onChange={handleChange} placeholder={t('hc_eg42MgRoadSector')} />
                </Grid>

                <Grid size={{ xs: 12, sm: 6 }}>
                  <FormControl fullWidth size="small">
                    {stateOptions.length > 0 ? (
                      <>
                        <InputLabel>{cc.stateLabel}</InputLabel>
                        <Select name="maanilam" value={profile.maanilam} onChange={handleChange} label={cc.stateLabel}>
                          <MenuItem value="">Select {cc.stateLabel.toLowerCase()}</MenuItem>
                          {stateOptions.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { primary: 'Tamil', secondary: 'English', bilingual: true })}</MenuItem>)}
                        </Select>
                      </>
                    ) : (
                      <TextField fullWidth size="small" label={cc.stateLabel} name="maanilam" value={profile.maanilam} onChange={handleChange} placeholder={cc.stateLabel} />
                    )}
                    {profile.country === 'India' && <FormHelperText>{t('hc_neededForAutoCgstsgstVs')}</FormHelperText>}
                  </FormControl>
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label={cc.taxIdLabel} name="gstin" value={profile.gstin} onChange={handleChange} placeholder={cc.taxIdPlaceholder} slotProps={{ htmlInput: { maxLength: 20, style: { textTransform: 'uppercase' } } }} helperText="Leave blank if not registered for tax" />
                </Grid>

                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label="PAN" name="pan" value={profile.pan} onChange={handleChange} placeholder="AAAAA1234A" slotProps={{ htmlInput: { maxLength: 10, style: { textTransform: 'uppercase' } } }} />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label={t('hc_phoneMobile')} name="tholaipesi" value={profile.tholaipesi} onChange={handleChange} placeholder="+91 98765 43210" />
                </Grid>

                <Grid size={{ xs: 12 }}>
                  <TextField fullWidth size="small" type="email" label="Email" name="email" value={profile.email} onChange={handleChange} placeholder="billing@yourbusiness.com" />
                </Grid>
              </Grid>
            </div>
          )}

          {/* Step 2: Bank & UPI */}
          {step === 2 && (
            <div>
              <h2 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '0.5rem', color: 'var(--text-primary)' }}>Bank & UPI Details</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginBottom: '1.5rem' }}>
                Shown on your invoices so clients know where to pay. Optional — you can add this later.
              </p>

              <Grid container spacing={2}>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label={t('hc_bankName')} name="vangiPeyar" value={profile.vangiPeyar} onChange={handleChange} placeholder={t('hc_egHdfcBank')} />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label={t('hc_accountNumber')} name="kanakkuEn" value={profile.kanakkuEn} onChange={handleChange} placeholder={t('hc_eg12345678901234')} />
                </Grid>

                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label={t('hc_ifscCode')} name="ifsc" value={profile.ifsc} onChange={handleChange} placeholder={t('hc_egHdfc0001234')} slotProps={{ htmlInput: { style: { textTransform: 'uppercase' } } }} />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField fullWidth size="small" label={t('hc_upiId')} name="upiId" value={profile.upiId} onChange={handleChange} placeholder={t('hc_egBusinessupi')} helperText="Auto-generates QR code on invoices" />
                </Grid>

                <Grid size={{ xs: 12, sm: 6 }}>
                  <Typography variant="body2" color="text.secondary" gutterBottom>{t('hc_businessLogo')}</Typography>
                  <Button variant="outlined" color="inherit" fullWidth onClick={() => handleFileUpload('logo')} startIcon={<Image size={16} weight="regular" />}>
                    {profile.logo ? 'Change Logo' : 'Upload Logo'}
                  </Button>
                  {profile.logo && <img src={profile.logo} alt="Logo" style={{ height: '40px', marginTop: '0.5rem', objectFit: 'contain' }} />}
                  <FormHelperText>{t('hc_pngjpgMax500kb')}</FormHelperText>
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Typography variant="body2" color="text.secondary" gutterBottom>{t('hc_digitalSignature')}</Typography>
                  <Button variant="outlined" color="inherit" fullWidth onClick={() => handleFileUpload('signature')} startIcon={<PencilSimple size={16} weight="regular" />}>
                    {profile.signature ? 'Change Signature' : 'Upload Signature'}
                  </Button>
                  {profile.signature && <img src={profile.signature} alt="Signature" style={{ height: '40px', marginTop: '0.5rem', objectFit: 'contain' }} />}
                  <FormHelperText>{t('hc_pngjpgMax500kb')}</FormHelperText>
                </Grid>
              </Grid>
            </div>
          )}

          {/* Step 3: Ready */}
          {step === 3 && (
            <div style={{ textAlign: 'center' }}>
              <div style={{ width: '64px', height: '64px', borderRadius: '50%', background: '#059669', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 1.5rem' }}>
                <Check size={32} weight="regular" color="white" />
              </div>
              <h2 style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '0.75rem', color: 'var(--text-primary)' }}>{t('hc_youreAllSet')}</h2>
              <p style={{ color: 'var(--text-secondary)', marginBottom: '2rem', lineHeight: 1.6 }}>
                Your business profile is ready. Here's what to do next:
              </p>

              <div style={{ textAlign: 'left', marginBottom: '2rem' }}>
                {[
                  { num: '1', title: 'Create your first invoice', desc: 'Click "New Invoice" in the sidebar. Pick invoice type, add client details and line items.' },
                  { num: '2', title: 'Download or share', desc: 'Generate PDF, share via WhatsApp or email. UPI QR auto-appears if you added your UPI ID.' },
                  { num: '3', title: 'Check GST reports', desc: 'After a few invoices, go to "Reports & P&L". Your GSTR-1, GSTR-3B, and HSN data is auto-generated.' },
                  { num: '4', title: 'File GST returns', desc: 'Download CSVs from Reports → Upload to GST portal. Follow the built-in "GST Filing" guide for step-by-step help.' },
                ].map((item) => (
                  <div key={item.num} style={{ display: 'flex', gap: '1rem', padding: '0.75rem 0', borderBottom: '1px solid var(--border-color)' }}>
                    <div style={{ width: '28px', height: '28px', borderRadius: '50%', background: 'var(--primary)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.8rem', fontWeight: 700, flexShrink: 0 }}>
                      {item.num}
                    </div>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--text-primary)' }}>{item.title}</div>
                      <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.15rem' }}>{item.desc}</div>
                    </div>
                  </div>
                ))}
              </div>

              <div style={{ padding: '1rem', borderRadius: '8px', background: 'var(--bg-secondary)', border: '1px solid var(--border-color)', marginBottom: '1.5rem' }}>
                <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: 1.5 }}>
                  All your data is stored locally in the <code style={{ background: 'var(--border-color)', padding: '0.1rem 0.3rem', borderRadius: '3px' }}>data/</code> folder on this computer. Nothing is sent to any server. You can export a full backup anytime from Settings.
                </div>
              </div>
            </div>
          )}

          {/* Navigation */}
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 4, pt: 3, borderTop: '1px solid', borderColor: 'divider' }}>
            <Box>
              {step === 0 && (
                <Button variant="text" color="inherit" onClick={handleSkip} sx={{ textTransform: 'none' }}>
                  Skip Setup
                </Button>
              )}
              {step > 0 && step < 3 && (
                <Button variant="outlined" color="inherit" onClick={() => setStep(step - 1)} startIcon={<CaretLeft size={16} weight="regular" />} sx={{ textTransform: 'none' }}>
                  Back
                </Button>
              )}
            </Box>

            <Box sx={{ display: 'flex', gap: 1.5 }}>
              {step < 3 && (
                <Button variant="contained" color="primary" onClick={() => setStep(step + 1)} disabled={!canProceed()} endIcon={<CaretRight size={16} weight="regular" />} sx={{ textTransform: 'none' }}>
                  {step === 0 ? 'Get Started' : 'Next'}
                </Button>
              )}
              {step === 2 && (
                <Button variant="text" color="inherit" onClick={() => setStep(3)} sx={{ textTransform: 'none' }}>
                  Skip, I'll add later
                </Button>
              )}
              {step === 3 && (
                <Button variant="contained" color="primary" onClick={handleFinish} disabled={saving} endIcon={<ArrowRight size={16} weight="regular" />} sx={{ textTransform: 'none' }}>
                  {saving ? 'Saving...' : 'Start Billing'}
                </Button>
              )}
            </Box>
          </Box>
        </Paper>

        {/* Step labels */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '2rem', marginTop: '1rem' }}>
          {STEPS.map((s, i) => (
            <div key={s.id} style={{ fontSize: '0.7rem', color: i === step ? 'var(--primary)' : 'var(--text-muted)', fontWeight: i === step ? 600 : 400, transition: 'all 0.3s' }}>
              {s.title}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
