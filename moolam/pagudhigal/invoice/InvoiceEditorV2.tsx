import React, { useState, useEffect } from 'react';
import { Box, Typography, Paper, Button, Grid, FormControl, Select, MenuItem, Divider, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions } from '@mui/material';
import { ArrowLeft, FloppyDisk } from '@phosphor-icons/react';
import { ClientState, InvoiceMetadataState, LineItemState, InvoiceSettingsState, InvoiceTotalsState, createEmptyClient, createEmptyLineItem, convertClientToSnapshot, convertItemsToSnapshot } from './v2/InvoiceTypes';
import ClientSelection from './v2/ClientSelection';
import InvoiceMetadata from './v2/InvoiceMetadata';
import LineItemsTable from './v2/LineItemsTable';
import InvoiceTotals from './v2/InvoiceTotals';
import InvoiceNotes from './v2/InvoiceNotes';
import { saveBill, getNextInvoiceNumber } from '../../Avanam';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import { INVOICE_TYPES } from '../../Payanpadu';
import ElvanEditorLayout from '../ElvanEditorLayout';

export default function InvoiceEditorV2({ onBack, onSaved, profile: profileProp, editingBill }: any) {
  const { t } = useLanguage();
  const [client, setClient] = useState<ClientState>(createEmptyClient());
  const [items, setItems] = useState<LineItemState[]>([createEmptyLineItem()]);
  const [totals, setTotals] = useState<InvoiceTotalsState>({
    subtotal: 0,
    totalDiscount: 0,
    cgst: 0,
    sgst: 0,
    igst: 0,
    roundOff: 0,
    tcsAmount: 0,
    tdsAmount: 0,
    total: 0,
    netReceivable: 0,
    amountPaid: 0,
    globalDiscountValue: 0,
    globalDiscountType: 'percentage',
  });
  
  const [customTerms, setCustomTerms] = useState(profileProp?.invoiceTerms || '');
  const [internalNote, setInternalNote] = useState('');
  const [saving, setSaving] = useState(false);
  const [showDiscardModal, setShowDiscardModal] = useState(false);
  
  const [settings, setSettings] = useState<InvoiceSettingsState>({
    taxInclusive: false,
    showDiscountColumn: true,
    showHSN: true,
    showPlaceOfSupply: true,
    showVehicle: false,
    showDueDate: false,
    showTerms: true,
    showBank: true,
    showNotes: true,
    showSignature: true,
  });
  
  const [metadata, setMetadata] = useState<InvoiceMetadataState>({
    invoiceType: 'tax-invoice',
    invoiceNumber: '',
    date: new Date().toISOString().split('T')[0],
    placeOfSupply: '',
  });

  const isBilingual = profileProp?.enableBilingual !== false;
  const primaryLang = profileProp?.primaryDataLanguage || 'Tamil';
  const secondaryLang = profileProp?.secondaryDataLanguage || 'English';

  // Initialize from editing bill or generate new number — exact same logic as v1
  useEffect(() => {
    if (editingBill?.data) {
      const d = editingBill.data;
      if (editingBill._isDuplicate) {
        const convertType = editingBill._convertToType;
        const type = convertType || d.invoiceType || 'tax-invoice';
        const prefix = (INVOICE_TYPES as any)[type]?.prefix || 'INV';
        getNextInvoiceNumber(prefix).then((num: string) => {
          setMetadata(prev => ({ ...prev, invoiceNumber: num, date: new Date().toISOString().split('T')[0] }));
        });
      } else {
        setMetadata(prev => ({
          ...prev,
          invoiceNumber: d.details?.invoiceNumber || prev.invoiceNumber,
          date: d.details?.invoiceDate || prev.date,
          placeOfSupply: d.details?.placeOfSupply || '',
        }));
      }
    } else if (!metadata.invoiceNumber) {
      const prefix = (INVOICE_TYPES as any)[metadata.invoiceType]?.prefix || 'INV';
      getNextInvoiceNumber(prefix).then((num: string) => {
        setMetadata(prev => ({ ...prev, invoiceNumber: num }));
      });
    }
  }, [editingBill]);

  const handleTypeChange = async (e: any) => {
    const type = e.target.value as string;
    const config = (INVOICE_TYPES as any)[type];
    const prefix = config?.prefix || 'INV';
    const num = await getNextInvoiceNumber(prefix);
    setMetadata(prev => ({ ...prev, invoiceType: type, invoiceNumber: num }));

    // Auto-set options based on type — same as v1
    if (type === 'bill-of-supply') {
      setSettings(prev => ({ ...prev, showPlaceOfSupply: false }));
    } else {
      setSettings(prev => ({ ...prev, showPlaceOfSupply: config?.showGST ?? true }));
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      const snapClient = convertClientToSnapshot(client, primaryLang, secondaryLang);
      const snapItems = convertItemsToSnapshot(items, primaryLang, secondaryLang);
      
      // Need a valid invoice number. If empty, generate one (simplified)
      const invNum = metadata.invoiceNumber || `INV-${Date.now()}`;
      
      const bill = {
        id: invNum,
        clientName: client.name.primary || '',
        clientNameEn: client.name.secondary || '',
        invoiceNumber: invNum,
        invoiceDate: metadata.date,
        invoiceType: metadata.invoiceType,
        currency: 'INR',
        totalAmount: totals.total,
        totalTaxAmount: totals.cgst + totals.sgst + totals.igst,
        status: 'paid', // Default to paid as per Legacy behavior
        paidAmount: Math.round(Number(totals.total)) || 0,
        payments: editingBill?.payments || [],
        data: { 
          profile: profileProp, 
          client: snapClient, 
          details: { ...metadata, invoiceNumber: invNum, invoiceDate: metadata.date }, 
          items: snapItems, 
          totals, 
          invoiceType: metadata.invoiceType, 
          customTerms, 
          internalNote, 
          invoiceOptions: settings 
        }
      };
      
      await saveBill(bill);
      thagaval(t('hc_savedSuccessfully') || 'Invoice saved successfully!', 'success');
      if (onSaved) onSaved(bill);
    } catch (err) {
      console.error(err);
      thagaval('Failed to save invoice.', 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <ElvanEditorLayout
      title={(editingBill ? (t('editInvoice') || 'Edit Invoice') : (t('newInvoice') || 'New Invoice')) as string}
      onBack={() => setShowDiscardModal(true)}
      onSave={handleSave}
      saveButtonText={saving ? 'Saving...' : 'Save Invoice'}
    >
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
        
        {/* Client Selection Section */}
      <ClientSelection 
        client={client} 
        setClient={setClient} 
        isBilingual={isBilingual} 
        primaryLang={primaryLang} 
        secondaryLang={secondaryLang}
        profile={profileProp}
        invoiceOptions={settings}
      />

      {/* Metadata Section */}
      <InvoiceMetadata 
        metadata={metadata} 
        setMetadata={setMetadata} 
        isBilingual={isBilingual} 
        primaryLang={primaryLang}
        profile={profileProp}
        client={client}
        settings={settings}
      />

      {/* Line Items Section */}
      <LineItemsTable 
        items={items}
        setItems={setItems}
        settings={settings}
        isBilingual={isBilingual}
        primaryLang={primaryLang}
        secondaryLang={secondaryLang}
        profile={profileProp}
      />

      {/* Totals Section */}
      <InvoiceTotals
        items={items}
        totals={totals}
        setTotals={setTotals}
        settings={settings}
        client={client}
        profileState={profileProp?.maanilam}
        country={profileProp?.country}
      />

      <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

      {/* Invoice Type */}
      <Box sx={{ mb: 2 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2, ml: 2 }}>
          <Box sx={{ width: 24, height: 24, borderRadius: '50%', bgcolor: 'primary.main', color: 'primary.contrastText', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.8rem', fontWeight: 'bold', lineHeight: 1, pt: '1px', mr: 1.5 }}>5</Box>
          <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t("invoiceType")}</Typography>
        </Box>
        <Box sx={{ mb: 2 }}>
          <FormControl variant="filled" fullWidth size="small" sx={{ maxWidth: { sm: 400 } }}>
            <Select 
              value={metadata.invoiceType} 
              onChange={handleTypeChange}
            >
              {Object.entries(INVOICE_TYPES).map(([key, val]) => (
                <MenuItem key={key} value={key}>{t(`invoiceTypes_${key.replace(/-/g, '_')}` as any, { defaultValue: val.label })}</MenuItem>
              ))}
            </Select>
          </FormControl>
        </Box>
      </Box>


      {/* Discard Confirmation Modal */}
      <Dialog open={showDiscardModal} onClose={() => setShowDiscardModal(false)}>
        <DialogTitle>{t('hc_discardChanges') || 'Discard Changes?'}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            {t('hc_discardWarning') || 'Are you sure you want to go back? Any unsaved changes will be lost.'}
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowDiscardModal(false)} color="primary">
            {t('hc_cancel') || 'Cancel'}
          </Button>
          <Button onClick={() => { setShowDiscardModal(false); onBack(); }} color="error" variant="contained">
            {t('hc_discard') || 'Discard'}
          </Button>
        </DialogActions>
      </Dialog>
      </Box>
    </ElvanEditorLayout>
  );
}
