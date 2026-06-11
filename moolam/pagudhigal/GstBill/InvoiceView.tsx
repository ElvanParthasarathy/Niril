// @ts-nocheck
import { ArrowLeft, PencilSimple, DownloadSimple, ShareNetwork, Printer as PrintIcon, Copy, DotsThreeVertical, SlidersHorizontal } from '@phosphor-icons/react';
import { useRef, useState } from 'react';
import { FloatingBackButton } from '../FloatingBackButton';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
import InvoicePreview from './InvoicePreview';
import SjsTheme from './SjsTheme';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import { formatCurrency, INVOICE_TYPES } from '../../Payanpadu';
import { saveBill } from '../../Avanam';
import { ensureToken, findOrCreateFolder, uploadPDF } from '../../sevaigal/googleDrive';
import { Box, Paper } from '@mui/material';
import { ViewHeader } from '../ViewHeader';

export default function InvoiceView({ bill, profile, onBack, onEdit, onDuplicate }) {
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
        if (inv) { inv.style.width = '210mm'; inv.style.overflow = 'visible'; inv.style.minHeight = '297mm'; inv.style.border = 'none'; inv.style.boxShadow = 'none'; inv.style.borderRadius = '0'; }
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

  const handleNativeShare = async () => {
    const amount = formatCurrency(items.reduce((s, i) => s + ((i.qty || i.quantity) * i.rate), 0));
    const msg = `*Invoice: ${details.invoiceNumber}*\nClient: ${client?.name || ''}\nAmount: ${amount}\nDate: ${details.invoiceDate}`;
    
    if (navigator.share) {
      setSaving(true);
      try {
        const pdf = await buildPDF();
        const fileName = `${typeConfig.prefix}_${details.invoiceNumber.replace(/\//g, '-')}.pdf`;
        const pdfBlob = pdf.output('blob');
        const file = new File([pdfBlob], fileName, { type: 'application/pdf' });
        
        if (navigator.canShare && navigator.canShare({ files: [file] })) {
          navigator.share({ files: [file], title: fileName, text: msg }).catch((err) => {
            if (err.name === 'InvalidStateError') {
              thagaval('Share menu is already open! Please check your taskbar or behind your browser window.', 'warning');
            } else if (err.name !== 'AbortError') {
              console.error('Share failed', err);
            }
          });
        } else {
          navigator.share({ title: fileName, text: msg }).catch((err) => {
            if (err.name === 'InvalidStateError') {
              thagaval('Share menu is already open! Please check your taskbar or behind your browser window.', 'warning');
            } else if (err.name !== 'AbortError') {
              console.error('Share failed', err);
            }
          });
          // If files can't be shared via native share, download it instead
          pdf.save(fileName);
        }
      } catch (error) {
        console.error('PDF Generation failed', error);
        thagaval('Failed to generate PDF for sharing', 'error');
      } finally {
        setTimeout(() => setSaving(false), 2000);
      }
    } else {
      thagaval(t('featureNotSupported') || 'Native sharing not supported on this device.', 'warning');
    }
  };

  const handlePrint = () => {
    const printContent = printRef.current;
    if (!printContent) return;

    const iframe = document.createElement('iframe');
    iframe.style.position = 'fixed';
    iframe.style.right = '0';
    iframe.style.bottom = '0';
    iframe.style.width = '0';
    iframe.style.height = '0';
    iframe.style.border = '0';
    document.body.appendChild(iframe);

    const title = details?.invoiceNumber ? `Invoice-${details.invoiceNumber}` : 'Print';
    const headContent = document.head.innerHTML;

    const doc = iframe.contentWindow.document;
    doc.open();
    doc.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>${title}</title>
          ${headContent}
          <style>
            @media print {
              @page { size: A4; margin: 0; }
              html { font-size: 16px !important; }
              body, html { background-color: white !important; margin: 0; padding: 0; }
              .invoice-paper, .a4-paper { box-shadow: none !important; margin: 0 !important; border: none !important; width: 100% !important; }
              .no-print { display: none !important; }
              #invoice-preview { padding: 0 !important; }
              #invoice-preview .inv-classic-header { padding-left: 1.5rem !important; padding-right: 1.5rem !important; padding-top: 1rem !important; }
              #invoice-preview .inv-parties { padding-left: 1.5rem !important; padding-right: 1.5rem !important; }
              #invoice-preview .unified-table-box { margin-left: 1.5rem !important; margin-right: 1.5rem !important; }
              #invoice-preview .inv-footer { margin-left: 1.5rem !important; margin-right: 1.5rem !important; }
              #invoice-preview .inv-contact-block { padding-left: 1.5rem !important; padding-right: 1.5rem !important; }
            }
          </style>
        </head>
        <body style="background-color: white; margin: 0; padding: 0;">
          ${printContent.outerHTML}
        </body>
      </html>
    `);
    doc.close();

    setTimeout(() => {
      iframe.contentWindow.focus();
      iframe.contentWindow.print();
      setTimeout(() => { document.body.removeChild(iframe); }, 1000);
    }, 500);
  };

  return (
    <Box className="print-wrapper" sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', width: '100%', position: 'relative', bgcolor: 'background.default', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <ViewHeader 
        className="no-print"
        onEdit={() => onEdit(bill)}
        onPrint={handlePrint}
        onPDF={generatePDF}
        onShare={handleNativeShare}
        saving={saving}
        title={details?.invoiceNumber}
        onBack={onBack}
      />

      {/* Centered Preview Container */}
      <Box className="print-wrapper" sx={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'flex-start', overflowX: 'hidden', pb: 4 }}>
        <Paper elevation={3} className="invoice-paper print-wrapper" sx={{ 
          p: 0, overflow: 'hidden', minWidth: '210mm', width: '210mm', m: '0 auto',
          zoom: { xs: 0.43, sm: 0.7, md: 0.85, lg: 1 },
          '@supports not (zoom: 1)': {
            transformOrigin: 'top center',
            transform: { xs: 'scale(0.43)', sm: 'scale(0.7)', md: 'scale(0.85)', lg: 'none' },
            mb: { xs: '-55%', sm: '-25%', md: '-10%', lg: 0 }
          }
        }}>
          {profile?.invoiceTheme === 'sjs' ? (
            <SjsTheme ref={printRef} profile={profile} client={client} details={details}
              items={items} totals={totals} invoiceType={invoiceType} customTerms={customTerms}
              options={invoiceOptions} />
          ) : (
            <InvoicePreview ref={printRef} profile={profile} client={client} details={details}
              items={items} totals={totals} invoiceType={invoiceType} customTerms={customTerms}
              options={invoiceOptions} />
          )}
        </Paper>
      </Box>
    </Box>
  );
}
