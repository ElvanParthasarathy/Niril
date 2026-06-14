import React, { useState, useRef } from 'react';
import { Box, Typography, Button, FormControlLabel, Checkbox, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
import { DownloadSimple, UploadSimple, Cloud, CloudSlash } from '@phosphor-icons/react';
import { SettingsPillContainer, SettingsRow } from '../ElvanSettingsSection';
import { exportAllData, importData, inspectBackup } from '../../Avanam';
import { thagaval } from '../Thagaval';

const ALL_BACKUP_PARTS = [
  { id: 'profile',        label: 'Active business profile',  hint: 'Name, address, GSTIN, bank, logo, signature' },
  { id: 'profiles',       label: 'All business profiles',    hint: 'Multi-business switcher entries' },
  { id: 'bills',          label: 'Invoices / bills',         hint: 'Tax invoices, proforma, credit notes, etc.' },
  { id: 'clients',        label: 'Clients',                  hint: 'Saved client directory' },
  { id: 'products',       label: 'Products / Inventory',     hint: 'Product catalog with HSN, rate, stock' },
  { id: 'receipts',       label: 'Receipts',                 hint: 'Payment receipts' },
  { id: 'meta',           label: 'App settings',             hint: 'Region, modules, invoice number format, display options' },
  { id: 'localStorage',   label: 'Local preferences',        hint: 'Custom units, theme, last region preference' },
];

export default function StorageCloud({ profile, driveConnected, setDriveConnected, connecting, setConnecting, t }) {
  const fileInputRef = useRef(null);

  const [showExportModal, setShowExportModal] = useState(false);
  const [showImportModal, setShowImportModal] = useState(false);
  const [exportSel, setExportSel] = useState(() => Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, true])));
  const [importSel, setImportSel] = useState(() => Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, true])));
  const [importInspection, setImportInspection] = useState<any>(null);
  const [importJsonText, setImportJsonText] = useState('');

  const toggleExport = (id) => setExportSel(prev => ({ ...prev, [id]: !prev[id] }));
  const toggleImport = (id) => setImportSel(prev => ({ ...prev, [id]: !prev[id] }));
  const exportToggleAll = (val) => setExportSel(Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, val])));
  const importToggleAll = (val) => setImportSel(Object.fromEntries(ALL_BACKUP_PARTS.map(p => [p.id, val])));

  const runExport = async () => {
    try {
      const json = await exportAllData(exportSel);
      const fileName = `elvanniril-backup-${new Date().toISOString().split('T')[0]}.json`;

      const blob = new Blob([json], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url; a.download = fileName; a.click();
      URL.revokeObjectURL(url);

      thagaval('Backup downloaded', 'success');
      setShowExportModal(false);
    } catch (err: any) {
      console.error(err);
      thagaval('Export failed: ' + (err.message || 'unknown error'), 'error');
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
      const auto: any = {};
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
      if (importSel.profile && result.counts.profile > 0) parts.push('Active Profile');
      if (importSel.profiles && result.counts.profiles > 0) parts.push(`${result.counts.profiles} profiles`);
      if (importSel.bills && result.counts.bills > 0) parts.push(`${result.counts.bills} bills`);
      if (importSel.clients && result.counts.clients > 0) parts.push(`${result.counts.clients} clients`);
      if (importSel.products && result.counts.products > 0) parts.push(`${result.counts.products} products`);
      if (importSel.receipts && result.counts.receipts > 0) parts.push(`${result.counts.receipts} receipts`);
      
      thagaval(`Imported: ${parts.join(', ')}`, 'success');
      setShowImportModal(false);
      setTimeout(() => window.location.reload(), 1500);
    } catch (err: any) {
      thagaval('Import failed: ' + (err.message || 'unknown error'), 'error');
    }
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
      <SettingsPillContainer>
        <SettingsRow
          icon={<DownloadSimple size={20} weight="fill" />}
          iconColor="blue"
          title={t('exportBackup') || 'Export Backup'}
          description="Save all your profiles and settings to a JSON file."
          control={
            <Button variant="outlined" size="small" sx={{ borderRadius: 8 }} onClick={() => setShowExportModal(true)}>
              Export
            </Button>
          }
        />
        <SettingsRow
          icon={<UploadSimple size={20} weight="fill" />}
          iconColor="orange"
          title={t('importBackup') || 'Import Backup'}
          description="Restore your data from a previous backup file."
          control={
            <>
              <Button variant="outlined" size="small" sx={{ borderRadius: 8 }} onClick={() => (fileInputRef.current as any)?.click()}>
                Import
              </Button>
              <input ref={fileInputRef} type="file" accept=".json" onChange={handleImportPick} style={{ display: 'none' }} />
            </>
          }
        />
      </SettingsPillContainer>

      {/* Export modal */}
      <Dialog open={showExportModal} onClose={() => setShowExportModal(false)} maxWidth="sm" fullWidth disableScrollLock>
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
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setShowExportModal(false)}>Cancel</Button>
          <Button variant="contained" onClick={runExport} disabled={!Object.values(exportSel).some(Boolean)}>
            Download .json
          </Button>
        </DialogActions>
      </Dialog>

      {/* Import modal */}
      <Dialog open={showImportModal} onClose={() => setShowImportModal(false)} maxWidth="sm" fullWidth disableScrollLock>
        <DialogTitle>Import Backup</DialogTitle>
        <DialogContent dividers>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            Select what you want to restore from this file. Existing data might be overwritten!
          </Typography>
          <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
            <Button size="small" variant="outlined" onClick={() => importToggleAll(true)}>Select all</Button>
            <Button size="small" variant="outlined" onClick={() => importToggleAll(false)}>Clear all</Button>
          </Box>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {importInspection && ALL_BACKUP_PARTS.map(p => {
              const count = importInspection.counts[p.id] || 0;
              const hasData = count > 0 || (p.id === 'localStorage' && importInspection.counts[p.id] > 0) || (p.id === 'meta' && count > 0);
              return (
                <FormControlLabel key={p.id} disabled={!hasData} control={<Checkbox checked={!!importSel[p.id]} onChange={() => toggleImport(p.id)} />} label={
                  <Box sx={{ opacity: hasData ? 1 : 0.5 }}>
                    <Typography variant="body2" style={{ fontWeight: 'bold' }}>{p.label}</Typography>
                    <Typography variant="caption" color="text.secondary">
                      {hasData ? (p.id === 'profile' || p.id === 'meta' || p.id === 'localStorage' ? 'Included' : `${count} items found`) : 'None found in file'}
                    </Typography>
                  </Box>
                } />
              );
            })}
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setShowImportModal(false)}>Cancel</Button>
          <Button variant="contained" color="warning" onClick={runImport} disabled={!Object.values(importSel).some(Boolean)}>
            Import Selected
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
