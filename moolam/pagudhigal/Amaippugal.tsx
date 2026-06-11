// @ts-nocheck
import Save from '@mui/icons-material/Save';
import { Table as TableIcon } from '@phosphor-icons/react';
import Upload from '@mui/icons-material/Upload';
import Download from '@mui/icons-material/Download';
import Add from '@mui/icons-material/Add';
import Delete from '@mui/icons-material/Delete';
import Edit from '@mui/icons-material/Edit';
import Image from '@mui/icons-material/Image';
import Create from '@mui/icons-material/Create';
import Cloud from '@mui/icons-material/Cloud';
import CloudOff from '@mui/icons-material/CloudOff';
import Business from '@mui/icons-material/Business';
import Tag from '@mui/icons-material/Tag';
import Refresh from '@mui/icons-material/Refresh';
import Close from '@mui/icons-material/Close';
import KeyboardArrowUp from '@mui/icons-material/KeyboardArrowUp';
import KeyboardArrowDown from '@mui/icons-material/KeyboardArrowDown';
import { useState, useEffect, useRef } from 'react';
import { getProfile, saveProfile, exportAllData, importData, inspectBackup, getAllProfiles, saveBusinessProfile, deleteBusinessProfile, getInvoiceNumberSettings, saveInvoiceNumberSettings, getReceiptNumberSettings, saveReceiptNumberSettings } from '../Avanam';
import { ensureToken, findOrCreateFolder, uploadJSON } from '../sevaigal/googleDrive';
import { getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, validateTaxId, detectCountryFromBrowser, getCountriesForRegion, getPaymentAccounts, createEmptyAccount, maskkanakkuEn, reorderAccounts, setDefaultAccount, isValidUpiId, tamilNaduDistricts } from '../Payanpadu';
import { initGoogleDrive, isConnected, disconnect } from '../sevaigal/googleDrive';
import { SettingsSection, SettingsRow } from './ElvanSettingsSection';
import { thagaval } from './Thagaval';
import { useLanguage } from '../mozhi/LanguageContext';
import { motion, AnimatePresence } from 'framer-motion';
import '../styles/settings/shared.css';
import '../styles/settings/hub.css';
import GstSettings from './GstSettings';

// MUI Imports
import { 
  Box, Paper, TextField, Button, Select, MenuItem, Checkbox, Switch,
  FormControlLabel, Typography, IconButton, Grid, Chip, Autocomplete,
  Divider, InputAdornment, FormControl, InputLabel,
  Dialog, DialogTitle, DialogContent, DialogActions, DialogContentText,
  List, ListItem, ListItemText, ListItemSecondaryAction, Tabs, Tab
} from '@mui/material';

import CoolieSettings from './CoolieBill/CoolieSettings';

export default function Amaippugal({ onSaved, appMode }) {
  const { language, setLanguage, t } = useLanguage();
  const [profile, setProfile] = useState<any>({
    niruvanathinPeyar: '', niruvanathinPeyarEn: '', mugavari: '', mugavariEn: '', oor: '', oorEn: '', maavattam: '', maavattamEn: '', maanilam: '', maanilamEn: '', gstin: '', pan: '',
    email: '', tholaipesi: '', mobileNumber: '', vangiPeyar: '', kanakkuEn: '', ifsc: '',
    logo: '', logoHeight: 48, signature: '', upiId: '', googleClientId: '', googleDriveFolder: 'GST Billing Invoices',
    primaryDataLanguage: 'Tamil', secondaryDataLanguage: 'English', enableBilingual: true,
    invoiceTerms: '',
  });
  const [saving, setSaving] = useState(false);
  const [driveConnected, setDriveConnected] = useState(false);
  const [connecting, setConnecting] = useState(false);
  const [businessProfiles, setBusinessProfiles] = useState([]);
  const [invNumSettings, setInvNumSettings] = useState({
    format: 'branded', brandPrefix: '', separator: '/', showFinYear: true, startNumber: 1, padDigits: 4,
  });
  const [invNumSaving, setInvNumSaving] = useState(false);

  const [showNewProfileModal, setShowNewProfileModal] = useState(false);
  const [newProfileData, setNewProfileData] = useState({ niruvanathinPeyar: '', gstin: '', mugavari: '' });
  const [creatingProfile, setCreatingProfile] = useState(false);


  const [rcpNumSettings, setRcpNumSettings] = useState({
    format: 'branded', brandPrefix: 'RCP', separator: '/', showFinYear: true, startNumber: 1, padDigits: 4,
  });
  const [rcpNumSaving, setRcpNumSaving] = useState(false);
  const [updateInfo, setUpdateInfo] = useState(null);
  const [checkingUpdate, setCheckingUpdate] = useState(false);
  const [editingLangSettings, setEditingLangSettings] = useState(false);

  const [isEditingCompany, setIsEditingCompany] = useState(false);
  const [showMobileField, setShowMobileField] = useState(false);
  const [activeTab, setActiveTab] = useState(0);
  const [isMobile, setIsMobile] = useState(window.innerWidth <= 768);
  const [direction, setDirection] = useState(0);
  const [currentView, setCurrentView] = useState(window.innerWidth <= 768 ? 'hub' : 0);
  
  useEffect(() => {
    const handleResize = () => {
        const mobile = window.innerWidth <= 768;
        setIsMobile(mobile);
        if (!mobile && currentView === 'hub') setCurrentView(0);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, [currentView]);

  const handleNavigate = (viewId) => {
    setDirection(1);
    setCurrentView(viewId);
  };

  const goHub = () => {
    setDirection(-1);
    setCurrentView(isMobile ? 'hub' : 0);
  };

  const saveLangSettings = async () => {
    await saveProfile(profile);
    if (onSaved) onSaved(profile);
    setEditingLangSettings(false);
    thagaval(language === 'ta' ? 'அமைப்புகள் சேமிக்கப்பட்டன' : 'Language settings saved!', 'success');
  };


  const fileInputRef = useRef(null);
  const logoInputRef = useRef(null);
  const wideLogoInputRef = useRef(null);
  const sigInputRef = useRef(null);
  const companyFormRef = useRef(null);
  const visibleCountries = getCountriesForRegion();

  useEffect(() => {
    getProfile().then(p => {
      setProfile({
        ...profile,
        ...p,
        primaryDataLanguage: p?.primaryDataLanguage || 'Tamil',
        secondaryDataLanguage: p?.secondaryDataLanguage || 'English',
        enableBilingual: p?.enableBilingual !== false
      });
    });
    loadBusinessProfiles();
    setDriveConnected(isConnected());
    getInvoiceNumberSettings().then(setInvNumSettings);
    getReceiptNumberSettings().then(setRcpNumSettings);
  }, []);

  const loadBusinessProfiles = async () => setBusinessProfiles(await getAllProfiles());

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfile(prev => ({ ...prev, [name]: value }));
  };

  // ---- Payment Accounts manager ----
  // `editingAccount` = null ⇒ closed; an account object ⇒ form open for that
  // account; a fresh `createEmptyAccount()` ⇒ Add new flow. Saving merges back
  // into profile.paymentAccounts; profile.upiId/vangiPeyar/etc. are mirrored to
  // the DEFAULT account on save so legacy code paths and v1.4.x backups keep
  // working without a data migration.
  const [editingAccount, setEditingAccount] = useState(null);
  const [accountUpiWarning, setAccountUpiWarning] = useState('');

  const updateAccounts = (nextAccounts) => {
    // Mirror the default account's fields onto the profile's flat bank/UPI
    // fields. Means: a v1.4.x reader of the same profile.json still sees the
    // current default account's details, and the existing flat-field code
    // paths (e.g. legacy fallback in InvoicePreview) continue to work.
    const def = nextAccounts.find(a => a.isDefault) || nextAccounts[0];
    setProfile(prev => ({
      ...prev,
      paymentAccounts: nextAccounts,
      ...(def ? {
        vangiPeyar: def.vangiPeyar || '',
        kanakkuEn: def.kanakkuEn || '',
        ifsc: def.ifsc || '',
        swift: def.swift || '',
        upiId: def.upiId || '',
      } : {}),
    }));
  };

  const openAddAccount = () => {
    const fresh = createEmptyAccount();
    const existing = getPaymentAccounts(profile);
    // First account auto-marks Primary so the user never sees a "no default" maanilam.
    if (existing.length === 0) fresh.isDefault = true;
    setEditingAccount(fresh);
    setAccountUpiWarning('');
  };

  const openEditAccount = (acc) => {
    setEditingAccount({ ...acc });
    setAccountUpiWarning('');
  };

  const cancelAccount = () => { setEditingAccount(null); setAccountUpiWarning(''); };

  const saveAccountForm = () => {
    if (!editingAccount) return;
    const existing = getPaymentAccounts(profile).filter(a => a.id !== 'legacy');
    const idx = existing.findIndex(a => a.id === editingAccount.id);
    const next = idx >= 0 ? existing.map((a, i) => i === idx ? editingAccount : a) : [...existing, editingAccount];
    // Enforce: exactly one default (or zero if list empty).
    if (editingAccount.isDefault) {
      next.forEach(a => { if (a.id !== editingAccount.id) a.isDefault = false; });
    } else if (!next.some(a => a.isDefault) && next.length > 0) {
      next[0].isDefault = true;
    }
    updateAccounts(next);
    setEditingAccount(null);
    setAccountUpiWarning('');
    thagaval(idx >= 0 ? 'Account updated' : 'Account added', 'success');
  };

  const removeAccount = (acc) => {
    if (!confirm(`Delete payment account "${acc.label || acc.vangiPeyar || 'this account'}"? Existing invoices that used it keep their PDFs.`)) return;
    const next = getPaymentAccounts(profile).filter(a => a.id !== 'legacy' && a.id !== acc.id);
    if (next.length > 0 && !next.some(a => a.isDefault)) next[0].isDefault = true;
    updateAccounts(next);
    thagaval('Account removed', 'success');
  };

  const markDefault = (acc) => {
    const next = setDefaultAccount(getPaymentAccounts(profile).filter(a => a.id !== 'legacy'), acc.id);
    updateAccounts(next);
    thagaval(`Default → ${acc.label || acc.vangiPeyar || 'account'}`, 'success');
  };

  const toggleAccountActive = (acc) => {
    const next = getPaymentAccounts(profile)
      .filter(a => a.id !== 'legacy')
      .map(a => a.id === acc.id ? { ...a, isActive: !(a.isActive !== false) } : a);
    updateAccounts(next);
  };

  const moveAccountIdx = (idx, delta) => {
    const list = getPaymentAccounts(profile).filter(a => a.id !== 'legacy');
    const next = reorderAccounts(list, idx, idx + delta);
    updateAccounts(next);
  };

  const importLegacyAsAccount = () => {
    const fresh = createEmptyAccount(profile.vangiPeyar || 'Default account');
    fresh.vangiPeyar = profile.vangiPeyar || '';
    fresh.kanakkuEn = profile.kanakkuEn || '';
    fresh.ifsc = profile.ifsc || '';
    fresh.swift = profile.swift || '';
    fresh.upiId = profile.upiId || '';
    fresh.isDefault = true;
    updateAccounts([fresh]);
    thagaval('Imported existing bank details as your first account', 'success');
  };

  const handleImageUpload = (field, e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 500 * 1024) { thagaval('Image must be under 500KB', 'warning'); return; }
    const reader = new FileReader();
    reader.onload = (ev) => setProfile(prev => ({ ...prev, [field]: ev.target.result }));
    reader.readAsDataURL(file);
  };

  const removeImage = (field) => setProfile(prev => ({ ...prev, [field]: '' }));

  const handleSave = async (e) => {
    if (e) e.preventDefault();
    try {
      setSaving(true);
      await saveProfile(profile);
      if (onSaved) onSaved(profile);
      setIsEditingCompany(false);
      thagaval('Profile saved!', 'success');
    } catch { thagaval('Failed to save profile', 'error'); }
    finally { setSaving(false); }
  };

  const handleCancelEditCompany = async () => {
    const p = await getProfile();
    setProfile({
      ...profile,
      ...p,
      primaryDataLanguage: p?.primaryDataLanguage || 'Tamil',
      secondaryDataLanguage: p?.secondaryDataLanguage || 'English',
      enableBilingual: p?.enableBilingual !== false
    });
    setIsEditingCompany(false);
    setShowMobileField(false);
  };

  // Invoice Number Settings
  const handleInvNumChange = (field, value) => {
    setInvNumSettings(prev => ({ ...prev, [field]: value }));
  };

  const handleSaveInvNumSettings = async () => {
    setInvNumSaving(true);
    try {
      await saveInvoiceNumberSettings(invNumSettings);
      thagaval('Invoice number settings saved!', 'success');
    } catch { thagaval('Failed to save settings', 'error'); }
    finally { setInvNumSaving(false); }
  };

  const getInvNumPreview = () => {
    const s = invNumSettings;
    const pfx = s.brandPrefix || 'INV';
    const sep = s.separator || '/';
    const padded = String(s.startNumber || 1).padStart(s.padDigits || 4, '0');
    if (s.format === 'random') {
      return `${pfx}${sep}A3X9K2`;
    }
    if (s.showFinYear) {
      const yr = new Date().getFullYear();
      const ny = (yr + 1).toString().slice(-2);
      return `${pfx}${sep}${yr}-${ny}${sep}${padded}`;
    }
    return `${pfx}${sep}${padded}`;
  };

  const handleRcpNumChange = (field, value) => {
    setRcpNumSettings(prev => ({ ...prev, [field]: value }));
  };

  const handleSaveRcpNumSettings = async () => {
    setRcpNumSaving(true);
    try {
      await saveReceiptNumberSettings(rcpNumSettings);
      thagaval('Receipt number settings saved!', 'success');
    } catch { thagaval('Failed to save settings', 'error'); }
    finally { setRcpNumSaving(false); }
  };

  const getRcpNumPreview = () => {
    const s = rcpNumSettings;
    const pfx = s.brandPrefix || 'RCP';
    const sep = s.separator || '/';
    const padded = String(s.startNumber || 1).padStart(s.padDigits || 4, '0');
    if (s.format === 'random') {
      return `${pfx}${sep}A3X9K2`;
    }
    if (s.showFinYear) {
      const yr = new Date().getFullYear();
      const ny = (yr + 1).toString().slice(-2);
      return `${pfx}${sep}${yr}-${ny}${sep}${padded}`;
    }
    return `${pfx}${sep}${padded}`;
  };

  // Google Drive
  const handleConnectDrive = async () => {
    if (!profile.googleClientId.trim()) {
      thagaval('Enter your Google OAuth Client ID first', 'warning');
      return;
    }
    setConnecting(true);
    try {
      const result = (await initGoogleDrive(profile.googleClientId)) as any;
      if (result.success) {
        setDriveConnected(true);
        thagaval('Connected to Google Drive!', 'success');
      } else {
        thagaval('Failed: ' + (result.error || 'Unknown error'), 'error');
      }
    } catch (err) {
      thagaval('Connection failed: ' + err.message, 'error');
    }
    setConnecting(false);
  };

  const handleDisconnectDrive = () => {
    disconnect();
    setDriveConnected(false);
    thagaval('Disconnected from Google Drive', 'info');
  };

  // Export / Import (granular)
  const ALL_BACKUP_PARTS = [
    { id: 'profile',        label: 'Active business profile',  hint: 'Name, mugavari, GSTIN, bank, logo, signature' },
    { id: 'profiles',       label: 'All business profiles',    hint: 'Multi-business switcher entries' },
    { id: 'bills',          label: 'Invoices / bills',         hint: 'Tax invoices, proforma, credit notes, etc.' },
    { id: 'clients',        label: 'Clients',                  hint: 'Saved client directory' },
    { id: 'products',       label: 'Products / Inventory',     hint: 'Product catalog with HSN, rate, stock' },



    { id: 'receipts',       label: 'Receipts',                 hint: 'Payment receipts' },
    { id: 'meta',           label: 'App settings',             hint: 'Region, modules, invoice number format, display options' },
    { id: 'localStorage',   label: 'Local preferences',        hint: 'Custom units, theme, last region preference' },
  ];

  const [showExportModal, setShowExportModal] = useState(false);
  const [showImportModal, setShowImportModal] = useState(false);
  const [exportSel, setExportSel] = useState(() => Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, true])));
  const [importSel, setImportSel] = useState(() => Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, true])));
  const [importInspection, setImportInspection] = useState(null);
  const [importJsonText, setImportJsonText] = useState('');
  const [exportToDrive, setExportToDrive] = useState(false);
  const [drivePending, setDrivePending] = useState(false);

  const toggleExport = (id) => setExportSel(prev => ({ ...prev, [id]: !prev[id] }));
  const toggleImport = (id) => setImportSel(prev => ({ ...prev, [id]: !prev[id] }));
  const exportToggleAll = (val) => setExportSel(Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, val])));
  const importToggleAll = (val) => setImportSel(Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, val])));

  const runExport = async () => {
    try {
      const json = await exportAllData(exportSel);
      const fileName = `elvanniril-backup-${new Date().toISOString().split('T')[0]}.json`;

      // Local download (always)
      const blob = new Blob([json], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url; a.download = fileName; a.click();
      URL.revokeObjectURL(url);

      // Optional Google Drive copy
      if (exportToDrive) {
        if (!profile?.googleClientId) {
          thagaval('Google Drive not configured. Set Google Client ID in Settings to enable Drive backups.', 'warning');
        } else {
          setDrivePending(true);
          const ok = await ensureToken(profile.googleClientId);
          if (!ok) { thagaval('Drive auth failed — backup downloaded locally only', 'warning'); }
          else {
            const folderName = (profile.googleDriveFolder || 'GST Billing Invoices') + ' - Backups';
            const folderId = await findOrCreateFolder(folderName);
            const result = await uploadJSON(fileName, json, folderId);
            thagaval(`Saved to Drive — ${result.name}`, 'success');
          }
          setDrivePending(false);
        }
      }

      thagaval('Backup downloaded', 'success');
      setShowExportModal(false);
    } catch (err) {
      console.error(err);
      thagaval('Export failed: ' + (err.message || 'unknown error'), 'error');
      setDrivePending(false);
    }
  };

  const handleImportPick = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    try {
      const text = await file.text();
      const inspection = inspectBackup(text);
      if (!inspection.valid) { thagaval("This file doesn't look like a Elvan Niril backup.", 'error'); return; }
      setImportInspection(inspection);
      setImportJsonText(text);
      // Auto-tick only the parts that actually have data in the file
      const auto = {};
      ALL_BACKUP_PARTS.forEach(p => { auto[p.id] = (inspection.counts[p.id] || 0) > 0; });
      setImportSel(auto);
      setShowImportModal(true);
    } catch { thagaval('Could not read the file', 'error'); }
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const runImport = async () => {
    try {
      const result = await importData(importJsonText, importSel);
      const parts = [];
      if (result.billCount) parts.push(`${result.billCount} invoice(s)`);
      if (result.hasProfile) parts.push('profile');
      if (result.templateCount) parts.push(`${result.templateCount} template(s)`);
      if (result.clientCount) parts.push(`${result.clientCount} client(s)`);
      if (result.productCount) parts.push(`${result.productCount} product(s)`);
      thagaval(parts.length ? `Restored: ${parts.join(', ')}` : 'Restore complete', 'success');
      if (importSel.profile) { const p = await getProfile(); setProfile(p); if (onSaved) onSaved(p); }
      if (importSel.profiles) loadBusinessProfiles();
      setShowImportModal(false);
      setImportInspection(null);
      setImportJsonText('');
    } catch (err) {
      console.error(err);
      thagaval('Import failed: ' + (err.message || 'unknown error'), 'error');
    }
  };

  // Multi-business profiles


  const handleLoadProfile = async (bp) => {
    // Auto-save current profile before switching (so it's not lost)
    if (profile.niruvanathinPeyar?.trim()) {
      const existing = businessProfiles.find(p => p.niruvanathinPeyar.trim().toLowerCase() === profile.niruvanathinPeyar.trim().toLowerCase());
      await saveBusinessProfile({ ...profile, id: existing?.id || undefined });
    }
    const loaded = { ...bp };
    delete loaded.id;
    setProfile(loaded);
    await saveProfile(loaded);
    if (onSaved) onSaved(loaded);
    thagaval(`Switched to ${bp.niruvanathinPeyar}`, 'success');
  };

  const handleDeleteProfile = async (id) => {
    if (confirm('Delete this saved business profile?')) {
      await deleteBusinessProfile(id);
      thagaval('Profile deleted', 'success');
      loadBusinessProfiles();
    }
  };

  const handleCreateNewProfile = async () => {
    if (!newProfileData.niruvanathinPeyar.trim()) { thagaval('Business name required', 'warning'); return; }
    setCreatingProfile(true);
    try {
      const freshProfile = {
        niruvanathinPeyar: newProfileData.niruvanathinPeyar,
        niruvanathinPeyarEn: '', mugavari: newProfileData.mugavari, mugavariEn: '', oor: '', oorEn: '', maavattam: '', maavattamEn: '', maanilam: '', maanilamEn: '', pin: '', country: detectCountryFromBrowser(),
        gstin: newProfileData.gstin, pan: '', email: '', tholaipesi: '', mobileNumber: '', vangiPeyar: '', kanakkuEn: '', ifsc: '', swift: '',
        logo: '', wideLogo: '', logoHeight: 48, signature: '', upiId: '', googleClientId: '', googleDriveFolder: 'GST Billing Invoices',
      };
      
      const saved = await saveBusinessProfile(freshProfile);
      
      // Auto-save current profile before switching
      if (profile.niruvanathinPeyar?.trim()) {
        const existing = businessProfiles.find(p => p.niruvanathinPeyar.trim().toLowerCase() === profile.niruvanathinPeyar.trim().toLowerCase());
        await saveBusinessProfile({ ...profile, id: existing?.id || undefined });
      }
      
      const loaded = { ...saved };
      delete loaded.id;
      setProfile(loaded);
      await saveProfile(loaded);
      if (onSaved) onSaved(loaded);
      
      await loadBusinessProfiles();
      setShowNewProfileModal(false);
      setNewProfileData({ niruvanathinPeyar: '', gstin: '', mugavari: '' });
      thagaval(`Created and switched to ${saved.niruvanathinPeyar}`, 'success');
    } catch (err) {
      thagaval('Failed to create profile', 'error');
    } finally {
      setCreatingProfile(false);
    }
  };

  const [taxIdWarning, setTaxIdWarning] = useState('');
  const handleTaxIdBlur = () => {
    const result = validateTaxId(profile.country, profile.gstin);
    setTaxIdWarning(result.ok ? '' : result.message);
  };



  const variants = {
    enter: (direction) => ({ x: direction > 0 ? "100%" : (direction < 0 ? "-100%" : 0), opacity: 0, zIndex: 1 }),
    center: { x: 0, opacity: 1, zIndex: 0 },
    exit: (direction) => ({ x: direction < 0 ? "100%" : (direction > 0 ? "-100%" : 0), opacity: 0, zIndex: 0 })
  };
  const transition = { type: "spring", stiffness: 300, damping: 30 };

  const renderDetailView = () => {
    let content = null;
    let title = "";
    if (currentView === 0) { 
      content = (<Box sx={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      {appMode === 'COOLIE' ? (
        <CoolieSettings />
      ) : (
        <>
          <GstSettings 
            profile={profile} 
            setProfile={setProfile} 
            onSaved={onSaved} 
            businessProfiles={businessProfiles} 
            loadBusinessProfiles={loadBusinessProfiles} 
            saving={saving} 
            setSaving={setSaving} 
          />
        </>
      )}
      </Box>); title = appMode === 'COOLIE' ? "Coolie Settings" : "GST Settings"; }
    else if (currentView === 1) { content = (<Box sx={{ display: 'flex', flexDirection: 'column', gap: 0 }}>      {/* ---- Language Preference ---- */}
      <SettingsSection title="Language Preferences" description="Select the language for the user interface.">
        <SettingsRow
          title="தமிழ் (Tamil)"
          description="முழுக்க தமிழில்"
          control={
            <Box sx={{ width: 24, height: 24, borderRadius: '50%', border: '2px solid', borderColor: language === 'ta' ? 'primary.main' : 'divider', display: 'flex', alignItems: 'center', justifyContent: 'center', bgcolor: language === 'ta' ? 'primary.main' : 'transparent' }}>
              {language === 'ta' && <Box sx={{ width: 10, height: 10, borderRadius: '50%', bgcolor: 'white' }} />}
            </Box>
          }
          onClick={() => {
            setLanguage('ta');
            thagaval('மொழி தமிழுக்கு மாற்றப்பட்டது', 'success');
          }}
        />
        <SettingsRow
          title="English"
          description="English only"
          control={
            <Box sx={{ width: 24, height: 24, borderRadius: '50%', border: '2px solid', borderColor: language === 'en' ? 'primary.main' : 'divider', display: 'flex', alignItems: 'center', justifyContent: 'center', bgcolor: language === 'en' ? 'primary.main' : 'transparent' }}>
              {language === 'en' && <Box sx={{ width: 10, height: 10, borderRadius: '50%', bgcolor: 'white' }} />}
            </Box>
          }
          onClick={() => {
            setLanguage('en');
            thagaval('Language changed to English', 'success');
          }}
        />
      </SettingsSection>
      </Box>); title = "App Preferences"; }
    else if (currentView === 2) { content = (<Box sx={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      <SettingsSection title={t('dataManagementTitle')} description={<span dangerouslySetInnerHTML={{ __html: t('dataNoticeText') as string }} />}>
        <SettingsRow
          icon={<Download />}
          title={t('exportBackup')}
          description="Save all your profiles and settings to a JSON file."
          control={
            <Button variant="outlined" size="small" onClick={() => setShowExportModal(true)}>
              Export
            </Button>
          }
        />
        <SettingsRow
          icon={<Upload />}
          title={t('importBackup')}
          description="Restore your data from a previous backup file."
          control={
            <>
              <Button variant="outlined" size="small" onClick={() => fileInputRef.current?.click()}>
                Import
              </Button>
              <input ref={fileInputRef} type="file" accept=".json" onChange={handleImportPick} style={{ display: 'none' }} />
            </>
          }
        />
      </SettingsSection>
      </Box>); title = "Storage & Cloud"; }
    else if (currentView === 3) { content = (<Box sx={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
      <SettingsSection title={t('appUpdatesTitle')} description={t('appUpdatesDesc')}>
        <SettingsRow
          icon={<Refresh />}
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
              {checkingUpdate ? t('checkingUpdate') : t('checkForUpdates')}
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
        <SettingsRow
          icon={<Delete />}
          title={t('clearCacheTitle')}
          description={t('clearCacheDesc')}
          control={
            <Button variant="contained" color="error" size="small" onClick={() => {
              if (confirm('Clear local cache and reload? You will need to log in again if using Google Drive.')) {
                localStorage.clear();
                window.location.reload();
              }
            }}>
              {t('clearCacheBtn')}
            </Button>
          }
        />
      </SettingsSection>
</Box>); title = "System & Updates"; }

    return (
      <Box sx={{ width: '100%', pb: 10 }}>
        {isMobile && (
           <div className="s2-sub-header" style={{ display: 'flex', alignItems: 'center', marginBottom: 24, padding: '0 8px' }}>
              <button className="s2-back-btn" onClick={goHub} type="button">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M15 18l-6-6 6-6" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
              </button>
              <div className="s2-sub-title" style={{ fontSize: 22, marginLeft: 8 }}>{title}</div>
           </div>
        )}
        {!isMobile && (
           <div className="s2-sub-header" style={{ display: 'none', alignItems: 'center', marginBottom: 24 }}>
              <div className="s2-sub-title">{title}</div>
           </div>
        )}
        {content}
      </Box>
    );
  };

  const detailContent = renderDetailView();

  const renderHub = () => (
    <div style={{ paddingBottom: 100 }}>
       <div className="s2-sub-header" style={{ display: 'none', marginBottom: 24, padding: '0 8px' }}>
           <div className="s2-sub-title">{t('settingsTitle')}</div>
       </div>

       <div className="s2-profile-card" onClick={() => handleNavigate(0)} style={{ marginBottom: 32 }}>
          <div className="s2-avatar">
              {profile.logo ? <img src={profile.logo} alt="Logo" /> : <Business className="s2-avatar-icon" />}
          </div>
          <div className="s2-profile-text">
              <div className="s2-profile-title">{profile.niruvanathinPeyar || 'Business Profile'}</div>
              <div className="s2-profile-sub">{profile.email || 'Configure your details'}</div>
          </div>
          <div style={{ color: 'var(--mac-text-secondary)', paddingRight: 8 }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M9 18l6-6-6-6" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
          </div>
       </div>

       <div className="s2-section-label">Preferences</div>
       <div className="s2-group" style={{ marginBottom: 32 }}>
          <div className="s2-item" onClick={() => handleNavigate(1)}>
              <div className="s2-icon-circle blue"><Tag fontSize="small" /></div>
              <div className="s2-item-text">
                  <div className="s2-item-title">App Preferences</div>
                  <div className="s2-item-desc">UI language, Theme</div>
              </div>
          </div>
       </div>

       <div className="s2-section-label">Advanced</div>
       <div className="s2-group" style={{ marginBottom: 32 }}>
          <div className="s2-item" onClick={() => handleNavigate(2)}>
              <div className="s2-icon-circle purple"><Cloud fontSize="small" /></div>
              <div className="s2-item-text">
                  <div className="s2-item-title">Storage & Cloud</div>
                  <div className="s2-item-desc">Google Drive, Local Backups</div>
              </div>
          </div>
          <div className="s2-divider"></div>
          <div className="s2-item" onClick={() => handleNavigate(3)}>
              <div className="s2-icon-circle orange"><Refresh fontSize="small" /></div>
              <div className="s2-item-text">
                  <div className="s2-item-title">System & Updates</div>
                  <div className="s2-item-desc">App versions, Cache</div>
              </div>
          </div>
       </div>
    </div>
  );

  return (
    <div className="s2-page-view" style={isMobile ? { position: 'relative', overflow: 'hidden', height: 'calc(100vh - 60px)', paddingTop: 16, fontFamily: '"Elvan Sans", sans-serif' } : { paddingTop: 0, fontFamily: '"Elvan Sans", sans-serif' }}>
      {isMobile ? (
          <AnimatePresence mode="popLayout" custom={direction} initial={false}>
              {currentView === 'hub' ? (
                  <motion.div
                  key="hub"
                      custom={direction}
                      variants={variants}
                      initial="enter"
                      animate="center"
                      exit="exit"
                      transition={transition}
                      className="s2-col-left"
                      style={{ width: '100%', height: '100%' }}
                  >
                      {renderHub()}
                  </motion.div>
              ) : (
                  <motion.div
                      key="detail"
                      custom={direction}
                      variants={variants}
                      initial="enter"
                      animate="center"
                      exit="exit"
                      transition={transition}
                      className="s2-col-right"
                      style={{ width: '100%', height: '100%' }}
                  >
                      {detailContent}
                  </motion.div>
              )}
          </AnimatePresence>
      ) : (
          <Box sx={{ width: '100%', maxWidth: 1200, mx: 'auto', mt: 0, pt: { xs: 2, md: 4 }, pb: { xs: 2, md: 4 }, px: { xs: 0, md: 4 } }}>
              <Typography variant="h5" sx={{ mb: 4, fontWeight: 700, ml: { xs: 1.5, md: 2 } }}>{t('settingsTitle') || 'Settings'}</Typography>
              <Tabs 
                  value={currentView === 'hub' ? 0 : currentView} 
                  onChange={(_e, val) => handleNavigate(val)}
                  variant="scrollable"
                  scrollButtons="auto"
                  sx={{
                      mb: 4,
                      borderBottom: 1,
                      borderColor: 'divider',
                      '& .MuiTabs-indicator': {
                          height: 3,
                          borderTopLeftRadius: 3,
                          borderTopRightRadius: 3,
                      },
                      '& .MuiTab-root': {
                          textTransform: 'none',
                          fontWeight: 600,
                          fontSize: '0.95rem',
                          minHeight: 48,
                          px: 3
                      }
                  }}
              >
                  <Tab value={0} label={appMode === 'COOLIE' ? 'Coolie Settings' : 'GST Settings'} />
                  <Tab value={1} label="App Preferences" />
                  <Tab value={2} label="Storage & Cloud" />
                  <Tab value={3} label="System & Updates" />
              </Tabs>
              <Box>
                  {detailContent || <div className="s2-welcome-card">Select a setting</div>}
              </Box>
          </Box>
      )}

      {/* ----------------------- Export modal ----------------------- */}
      <Dialog open={showExportModal} onClose={() => !drivePending && setShowExportModal(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Export Backup</DialogTitle>
        <DialogContent dividers>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            Choose what to include. Everything is on by default — uncheck anything you don't want.
          </Typography>
          <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
            <Button size="small" variant="outlined" onClick={() => exportToggleAll(true)}>Select all</Button>
            <Button size="small" variant="outlined" onClick={() => exportToggleAll(false)}>Clear all</Button>
          </Box>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {ALL_BACKUP_PARTS.map(p => (
              <FormControlLabel key={p.id} control={<Checkbox checked={!!exportSel[p.id]} onChange={() => toggleExport(p.id)} />} label={
                <Box>
                  <Typography variant="body2" style={{ fontWeight: 'bold' }}>{p.label}</Typography>
                  <Typography variant="caption" color="text.secondary">{p.hint}</Typography>
                </Box>
              } />
            ))}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button color="inherit" onClick={() => setShowExportModal(false)} disabled={drivePending}>{t('cancel')}</Button>
          <Button variant="contained" onClick={runExport} disabled={drivePending || !Object.values(exportSel).some(Boolean)}>
            {drivePending ? 'Uploading…' : <><Download sx={{ fontSize: 16 }} style={{ marginRight: 6 }} /> Download Backup</>}
          </Button>
        </DialogActions>
      </Dialog>

      {/* ----------------------- Import modal ----------------------- */}
      {importInspection && (
        <Dialog open={showImportModal} onClose={() => setShowImportModal(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Restore from Backup</DialogTitle>
          <DialogContent dividers>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              File contents preview
              {importInspection.exportedAt && <span> — exported {new Date(importInspection.exportedAt).toLocaleString()}</span>}
              {importInspection.version && <span> · v{importInspection.version}</span>}
            </Typography>
            <Paper className="s2-group" elevation={0} sx={{ p: 1.5, bgcolor: 'warning.light', color: 'warning.contrastText', mb: 2 }}>
              <Typography variant="body2">
                ⚠ Restoring will <strong>overwrite matching records by ID</strong> in the categories you select. Records you didn't tick are untouched. We recommend exporting a fresh backup of your current data first.
              </Typography>
            </Paper>
            <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
              <Button size="small" variant="outlined" onClick={() => importToggleAll(true)}>Select all (with data)</Button>
              <Button size="small" variant="outlined" onClick={() => importToggleAll(false)}>Clear all</Button>
            </Box>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
              {ALL_BACKUP_PARTS.map(p => {
                const count = importInspection.counts[p.id] || 0;
                return (
                  <Box key={p.id} sx={{ display: 'flex', alignItems: 'center', opacity: count === 0 ? 0.5 : 1 }}>
                    <FormControlLabel sx={{ flex: 1 }} control={<Checkbox checked={!!importSel[p.id]} disabled={count === 0} onChange={() => toggleImport(p.id)} />} label={
                      <Box>
                        <Typography variant="body2" style={{ fontWeight: 'bold' }}>{p.label}</Typography>
                        <Typography variant="caption" color="text.secondary">{p.hint}</Typography>
                      </Box>
                    } />
                    <Typography variant="caption" sx={{ fontWeight: count > 0 ? 'bold' : 'normal', color: count > 0 ? 'success.main' : 'text.secondary' }}>
                      {count > 0 ? `${count} item${count !== 1 ? 's' : ''}` : 'empty'}
                    </Typography>
                  </Box>
                );
              })}
            </Box>
          </DialogContent>
          <DialogActions>
            <Button color="inherit" onClick={() => setShowImportModal(false)}>{t('cancel')}</Button>
            <Button variant="contained" onClick={runImport} disabled={!Object.values(importSel).some(Boolean)} startIcon={<Upload sx={{ fontSize: 16 }} />}>
              Restore selected
            </Button>
          </DialogActions>
        </Dialog>
      )}
      {/* ----------------------- New Profile Modal ----------------------- */}
      <Dialog open={showNewProfileModal} onClose={() => setShowNewProfileModal(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{language === 'ta' ? 'புதிய வணிக சுயவிவரத்தை உருவாக்கு' : 'Create New Business Profile'}</DialogTitle>
        <DialogContent dividers>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, py: 1 }}>
            <TextField 
              fullWidth size="small" autoFocus required
              label={language === 'ta' ? 'நிறுவனத்தின் பெயர் (Business Name)' : 'Business Name'} 
              value={newProfileData.niruvanathinPeyar} 
              onChange={(e) => setNewProfileData(prev => ({ ...prev, niruvanathinPeyar: e.target.value }))} 
            />
            <TextField 
              fullWidth size="small" 
              label={language === 'ta' ? 'GSTIN (விரும்பினால்)' : 'GSTIN (Optional)'} 
              value={newProfileData.gstin} 
              onChange={(e) => setNewProfileData(prev => ({ ...prev, gstin: e.target.value }))} 
            />
            <TextField 
              fullWidth size="small" multiline rows={3}
              label={language === 'ta' ? 'முகவரி (Address)' : 'Address (Optional)'} 
              value={newProfileData.mugavari} 
              onChange={(e) => setNewProfileData(prev => ({ ...prev, mugavari: e.target.value }))} 
            />
            <Typography variant="caption" color="text.secondary">
              {language === 'ta' ? 'பிற விவரங்களை பின்னர் அமைப்புகள் மூலம் சேர்க்கலாம்.' : 'You can fill in the rest of the details later from Settings.'}
            </Typography>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button color="inherit" onClick={() => setShowNewProfileModal(false)} disabled={creatingProfile}>{t('cancel' as any) || 'Cancel'}</Button>
          <Button variant="contained" onClick={handleCreateNewProfile} disabled={creatingProfile || !newProfileData.niruvanathinPeyar.trim()}>
            {creatingProfile ? (language === 'ta' ? 'உருவாக்குகிறது...' : 'Creating...') : (language === 'ta' ? 'உருவாக்கு' : 'Create')}
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
}

function EditIcon({ size }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z" /><path d="m15 5 4 4" />
    </svg>
  );
}
