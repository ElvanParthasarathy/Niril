// @ts-nocheck
import { ArrowLeft, PencilSimple, DownloadSimple, WhatsappLogo, Truck } from '@phosphor-icons/react';
import { useRef, useState } from 'react';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
import InvoicePreview from './InvoicePreview';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import { formatCurrency, INVOICE_TYPES } from '../../Payanpadu';
import { saveBill } from '../../Avanam';
import { ensureToken, findOrCreateFolder, uploadPDF } from '../../sevaigal/googleDrive';
import { Box, Button, Typography, Paper } from '@mui/material';

export default function InvoiceView({ bill, profile, onBack, onEdit }) {
  const { t } = useLanguage();
  const printRef = useRef(null);
  const [saving, setSaving] = useState(false);

  const {
    profile: snapshotProfile, client, details, items, totals, invoiceType = 'tax-invoice',
    customTerms, invoiceOptions
  } = bill.data || {};

  const typeConfig = INVOICE_TYPES[invoiceType || 'tax-invoice'] || INVOICE_TYPES['tax-invoice'];

  // Upload PDF to Google Drive if configured
  const uploadToGoogleDrive = async (pdfBlob, fileName) => {
    try {
      const clientId = profile.googleClientId;
      const folderName = profile.googleDriveFolder || 'GST Billing Invoices';
      if (!clientId) return;

      const hasToken = await ensureToken(clientId);
      if (!hasToken) {
        thagaval('Google Drive: Please reconnect in Settings', 'warning');
        return;
      }

      const folderId = await findOrCreateFolder(folderName);
      await uploadPDF(fileName, pdfBlob, folderId);
      thagaval(`Saved to Google Drive → ${folderName}`, 'success');
    } catch (err) {
      console.error('Google Drive upload error:', err);
      thagaval('Google Drive upload failed: ' + err.message, 'warning');
    }
  };

  const buildPDF = async () => {
    const paperEl = printRef.current.closest('.invoice-paper');
    const origTransform = paperEl ? paperEl.style.transform : '';
    const origZoom = paperEl ? paperEl.style.zoom : '';
    if (paperEl) {
      paperEl.style.transform = 'none';
      paperEl.style.zoom = '1';
    }

    const pdf = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4', compress: true });
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfPageHeight = pdf.internal.pageSize.getHeight();
    const extraPages = printRef.current.querySelectorAll('[data-pdf-page]');
    const renderScale = Math.max(3, Math.round((window.devicePixelRatio || 1) * 2));

    const captureOptions = (el) => ({
      scale: renderScale,
      useCORS: true,
      logging: false,
      letterRendering: true,
      backgroundColor: '#ffffff',
      imageTimeout: 0,
      width: el.scrollWidth,
      height: el.scrollHeight,
    });

    extraPages.forEach(el => el.style.display = 'none');
    const mainCanvas = await html2canvas(printRef.current, {
      ...captureOptions(printRef.current),
      onclone: (clonedDoc) => {
        clonedDoc.querySelectorAll('*').forEach(n => { n.style.letterSpacing = '0px'; n.style.wordSpacing = '0px'; });
        const inv = clonedDoc.getElementById('invoice-preview');
        if (inv) { inv.style.width = '210mm'; inv.style.overflow = 'visible'; inv.style.minHeight = 'unset'; inv.style.border = 'none'; inv.style.boxShadow = 'none'; inv.style.borderRadius = '0'; }
        clonedDoc.querySelectorAll('[data-pdf-page]').forEach(el => el.style.display = 'none');
      }
    });
    extraPages.forEach(el => el.style.display = '');

    const mainImg = mainCanvas.toDataURL('image/jpeg', 0.95);
    const mainImgHeight = (mainCanvas.height * pdfWidth) / mainCanvas.width;
    if (mainImgHeight <= pdfPageHeight + 2) {
      pdf.addImage(mainImg, 'JPEG', 0, 0, pdfWidth, Math.min(mainImgHeight, pdfPageHeight), undefined, 'MEDIUM');
    } else {
      let heightLeft = mainImgHeight, position = 0;
      pdf.addImage(mainImg, 'JPEG', 0, position, pdfWidth, mainImgHeight, undefined, 'MEDIUM');
      heightLeft -= pdfPageHeight;
      while (heightLeft > 2) { position -= pdfPageHeight; pdf.addPage(); pdf.addImage(mainImg, 'JPEG', 0, position, pdfWidth, mainImgHeight, undefined, 'MEDIUM'); heightLeft -= pdfPageHeight; }
    }

    for (const pageEl of extraPages) {
      const c = await html2canvas(pageEl, {
        ...captureOptions(pageEl),
        onclone: (cd) => { cd.querySelectorAll('*').forEach(n => { n.style.letterSpacing = '0px'; n.style.wordSpacing = '0px'; }); }
      });
      pdf.addPage();
      pdf.addImage(c.toDataURL('image/jpeg', 0.95), 'JPEG', 0, 0, pdfWidth, Math.min((c.height * pdfWidth) / c.width, pdfPageHeight), undefined, 'MEDIUM');
    }

    if (paperEl) {
      paperEl.style.transform = origTransform;
      paperEl.style.zoom = origZoom;
    }
    return pdf;
  };

  const generatePDF = async () => {
    if (!printRef.current) return;
    try {
      setSaving(true);
      const pdf = await buildPDF();
      const fileName = `${typeConfig.prefix}_${details.invoiceNumber.replace(/\//g, '-')}.pdf`;
      pdf.save(fileName);
      
      const pdfBlob = pdf.output('blob');
      const invoiceDate = details.invoiceDate ? new Date(details.invoiceDate) : new Date();
      const monthName = invoiceDate.toLocaleString('en-IN', { month: 'long', year: 'numeric' });
      const clientName = client?.name || 'General';
      const params = new URLSearchParams({ name: fileName, client: clientName, month: monthName });
      fetch(`/api/save-pdf?${params}`, { method: 'POST', headers: { 'Content-Type': 'application/pdf' }, body: pdfBlob }).catch(() => {});

      thagaval(`Invoice downloaded & saved to Saved Invoices/${clientName}/`, 'success');
      uploadToGoogleDrive(pdfBlob, fileName);
    } catch (err) {
      console.error(err);
      thagaval('Failed to generate PDF.', 'error');
    } finally {
      setSaving(false);
    }
  };

  const shareWhatsApp = () => {
    const tholaipesi = client?.tholaipesi ? client.tholaipesi.replace(/\D/g, '') : '';
    const amount = formatCurrency(items.reduce((s, i) => s + (i.quantity * i.rate), 0));
    const msg = `*Invoice: ${details.invoiceNumber}*\nClient: ${client?.name || ''}\nAmount: ${amount}\nDate: ${details.invoiceDate}`;
    const encoded = encodeURIComponent(msg);
    const waUrl = tholaipesi ? `https://api.whatsapp.com/send?tholaipesi=${tholaipesi}&text=${encoded}` : `https://api.whatsapp.com/send?text=${encoded}`;
    window.location.href = waUrl;
  };

  return (
    <Box sx={{ p: { xs: 1, sm: 2 }, bgcolor: 'background.default', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Header Toolbar */}
      <Box sx={{ display: 'flex', flexDirection: { xs: 'column', sm: 'row' }, gap: { xs: 1, sm: 2 }, justifyContent: 'space-between', alignItems: { xs: 'stretch', sm: 'center' }, mb: { xs: 2, sm: 3 } }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Button variant="outlined" startIcon={<ArrowLeft size={18} weight="regular" />} onClick={onBack} size="small" sx={{ borderRadius: '999px', minHeight: 40 }}>
            Back
          </Button>
          <Typography variant="subtitle1" fontWeight="bold" noWrap sx={{ maxWidth: { xs: 180, sm: 'auto' } }}>
            {details?.invoiceNumber}
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 0.75, overflowX: 'auto', width: '100%', pb: { xs: 0.5, sm: 0 }, '&::-webkit-scrollbar': { display: 'none' }, WebkitOverflowScrolling: 'touch' }}>
          <Button variant="outlined" onClick={() => onEdit(bill)} startIcon={<PencilSimple size={16} weight="regular" />} size="small" sx={{ whiteSpace: 'nowrap', borderRadius: '999px', minHeight: 40, flexShrink: 0 }}>
            Edit
          </Button>
          <Button variant="contained" color="primary" onClick={generatePDF} disabled={saving} startIcon={<DownloadSimple size={16} weight="regular" />} size="small" sx={{ whiteSpace: 'nowrap', borderRadius: '999px', minHeight: 40, flexShrink: 0 }}>
            {saving ? 'Gen...' : 'PDF'}
          </Button>
          <Button variant="contained" onClick={shareWhatsApp} disabled={saving} startIcon={<WhatsappLogo size={16} weight="regular" />} size="small" sx={{ bgcolor: '#25d366', color: '#fff', '&:hover': { bgcolor: '#20bd5a' }, whiteSpace: 'nowrap', borderRadius: '999px', minHeight: 40, flexShrink: 0 }}>
            WhatsApp
          </Button>
        </Box>
      </Box>

      {/* Centered Preview Container */}
      <Box sx={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'flex-start', overflowX: 'hidden', pb: 4 }}>
        <Paper elevation={3} className="invoice-paper" sx={{ 
          p: 0, overflow: 'hidden', minWidth: '210mm', width: '210mm', m: '0 auto',
          zoom: { xs: 0.43, sm: 0.7, md: 0.85, lg: 1 },
          '@supports not (zoom: 1)': {
            transformOrigin: 'top center',
            transform: { xs: 'scale(0.43)', sm: 'scale(0.7)', md: 'scale(0.85)', lg: 'none' },
            mb: { xs: '-55%', sm: '-25%', md: '-10%', lg: 0 }
          }
        }}>
          <InvoicePreview ref={printRef} profile={profile} client={client} details={details}
            items={items} totals={totals} invoiceType={invoiceType} customTerms={customTerms}
            options={invoiceOptions} />
        </Paper>
      </Box>
    </Box>
  );
}
