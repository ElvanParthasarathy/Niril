import React, { useRef, useState } from 'react';
import { ArrowLeft, Printer as PrintIcon, ShareNetwork, Spinner, DownloadSimple, PencilSimple, DotsThreeVertical } from '@phosphor-icons/react';
import { FloatingBackButton } from './FloatingBackButton';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
import { ensureToken, findOrCreateFolder, uploadPDF } from '../sevaigal/googleDrive';
import { useLanguage } from '../mozhi/LanguageContext';
import { formatCurrency, numberToWords, getCountryConfig } from '../Payanpadu';
import { Box, Paper } from '@mui/material';
import { ViewHeader } from './ViewHeader';
import { thagaval } from './Thagaval';

export default function ReceiptView({ receipt, profile, onBack, onEdit }) {
  const { t } = useLanguage();
  const printRef = useRef(null);
  const [sharing, setSharing] = useState(false);
  const [saving, setSaving] = useState(false);

  const profileCurrency = getCountryConfig(profile?.country || 'India').currency;

  const renderLabel = (enLabel, taLabel) => profile?.enableBilingual !== false ? `${taLabel} / ${enLabel}` : enLabel;
  
  const renderPaymentMode = (mode) => {
    const dictionaries = {
      'Tamil': { 'Cash': 'பணம்', 'UPI': 'UPI', 'Bank Transfer': 'வங்கிப் பரிமாற்றம்', 'Cheque': 'காசோலை', 'Card': 'கார்டு', 'Other': 'மற்றவை' },
      'Hindi': { 'Cash': 'नकद', 'UPI': 'UPI', 'Bank Transfer': 'बैंक ट्रांसफर', 'Cheque': 'चेक', 'Card': 'कार्ड', 'Other': 'अन्य' },
      'Telugu': { 'Cash': 'నగదు', 'UPI': 'UPI', 'Bank Transfer': 'బ్యాంక్ బదిలీ', 'Cheque': 'చెక్', 'Card': 'కార్డు', 'Other': 'ఇతర' },
      'Kannada': { 'Cash': 'ನಗದು', 'UPI': 'UPI', 'Bank Transfer': 'ಬ್ಯಾಂಕ್ ವರ್ಗಾವಣೆ', 'Cheque': 'ಚೆಕ್', 'Card': 'ಕಾರ್ಡ್', 'Other': 'ಇತರ' },
      'Malayalam': { 'Cash': 'പണം', 'UPI': 'UPI', 'Bank Transfer': 'ബാങ്ക് ട്രാൻസ്ഫർ', 'Cheque': 'ചെക്ക്', 'Card': 'കാർഡ്', 'Other': 'മറ്റ്' },
      'Marathi': { 'Cash': 'रोख', 'UPI': 'UPI', 'Bank Transfer': 'बँक ट्रान्सफर', 'Cheque': 'चेक', 'Card': 'कार्ड', 'Other': 'इतर' },
      'Gujarati': { 'Cash': 'રોકડ', 'UPI': 'UPI', 'Bank Transfer': 'બેંક ટ્રાન્સફર', 'Cheque': 'ચેક', 'Card': 'કાર્ડ', 'Other': 'અન્ય' },
      'Bengali': { 'Cash': 'নগদ', 'UPI': 'UPI', 'Bank Transfer': 'ব্যাঙ্ক ট্রান্সফার', 'Cheque': 'চেক', 'Card': 'কার্ড', 'Other': 'অন্য' }
    };
    const primaryLang = profile?.primaryDataLanguage || 'Tamil';
    return (dictionaries[primaryLang] || {})[mode] || mode;
  };

  const executePrint = () => {
    const el = printRef.current;
    if (!el) return;
    const printWindow = window.open('', '_blank');
    if (!printWindow) return;
    printWindow.document.write(`
      <html><head><title>Receipt ${receipt.receiptNo}</title>
      <style>
        body { font-family: 'Inter', Arial, sans-serif; margin: 0; padding: 2rem; color: #1a1a2e; }
        .receipt-box { max-width: 600px; margin: 0 auto; border: 2px solid #e2e8f0; border-radius: 8px; padding: 2rem; }
        .receipt-header { text-align: center; margin-bottom: 1.5rem; border-bottom: 2px solid #e2e8f0; padding-bottom: 1rem; }
        .receipt-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0; }
        .receipt-subtitle { font-size: 0.8rem; color: #64748b; margin: 0.25rem 0 0; }
        .receipt-row { display: flex; justify-content: space-between; padding: 0.5rem 0; font-size: 0.9rem; border-bottom: 1px solid #f1f5f9; }
        .receipt-label { color: #64748b; font-weight: 500; }
        .receipt-value { color: #1e293b; font-weight: 600; }
        .receipt-amount { font-size: 1.5rem; font-weight: 800; color: #1e40af; text-align: center; margin: 1.5rem 0; padding: 1rem; background: #eff6ff; border-radius: 8px; }
        .receipt-words { font-size: 0.85rem; color: #334155; font-style: italic; text-align: center; margin-bottom: 1.5rem; }
        .receipt-footer { display: flex; justify-content: space-between; margin-top: 3rem; padding-top: 1rem; }
        .receipt-sig { text-align: center; }
        .receipt-sig-line { width: 180px; border-bottom: 1.5px solid #1e293b; margin-bottom: 0.25rem; }
        .receipt-sig-label { font-size: 0.75rem; color: #64748b; }
        .business-name { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.25rem; }
        .business-details { font-size: 0.75rem; color: #64748b; }
        @media print { body { margin: 0; } .receipt-box { border: none; } }
      </style></head><body>
      ${el.innerHTML}
      <script>window.print(); window.close();</script>
      </body></html>
    `);
    printWindow.document.close();
  };

  // Upload PDF to Google Drive if configured
  const uploadToGoogleDrive = async (pdfBlob, fileName) => {
    try {
      const clientId = profile.googleClientId;
      const folderName = profile.googleDriveFolder || 'GST Billing Invoices'; // we'll use same folder or should we use Receipts? Wait, I'll use GST Billing Invoices to be consistent or 'GST Billing Receipts' if they want. Let's just use 'GST Billing Invoices' as default like in InvoiceView.
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
    const paperEl = printRef.current.closest('.MuiPaper-root');
    const origTransform = paperEl ? paperEl.style.transform : '';
    const origZoom = paperEl ? paperEl.style.zoom : '';
    if (paperEl) {
      paperEl.style.transform = 'none';
      paperEl.style.zoom = '1';
    }

    const pdf = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4', compress: true });
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfPageHeight = pdf.internal.pageSize.getHeight();
    const renderScale = Math.max(3, Math.round((window.devicePixelRatio || 1) * 2));

    const mainCanvas = await html2canvas(printRef.current, {
      scale: renderScale,
      useCORS: true,
      logging: false,
      letterRendering: true,
      backgroundColor: '#ffffff',
      imageTimeout: 0,
      width: printRef.current.scrollWidth,
      height: printRef.current.scrollHeight,
      onclone: (clonedDoc) => {
        clonedDoc.querySelectorAll('*').forEach(n => { n.style.letterSpacing = '0px'; n.style.wordSpacing = '0px'; });
        const inv = clonedDoc.querySelector('.receipt-box');
        if (inv) { inv.style.width = '100%'; inv.style.maxWidth = '190mm'; inv.style.overflow = 'visible'; inv.style.minHeight = 'unset'; inv.style.border = 'none'; inv.style.boxShadow = 'none'; inv.style.borderRadius = '0'; }
      }
    });

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
      const fileName = `RCPT_${receipt.receiptNo.replace(/\//g, '-')}.pdf`;
      pdf.save(fileName);
      
      const pdfBlob = pdf.output('blob');
      const clientName = receipt.clientName || 'General';
      const rcpDate = receipt.date ? new Date(receipt.date) : new Date();
      const monthName = rcpDate.toLocaleString('en-IN', { month: 'long', year: 'numeric' });
      const params = new URLSearchParams({ name: fileName, client: clientName, month: monthName });
      fetch(`/api/save-pdf?${params}`, { method: 'POST', headers: { 'Content-Type': 'application/pdf' }, body: pdfBlob }).catch(() => {});

      thagaval(`Receipt downloaded & saved to Saved Invoices/${clientName}/`, 'success');
      uploadToGoogleDrive(pdfBlob, fileName);
    } catch (err) {
      console.error(err);
      thagaval('Failed to generate PDF.', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleNativeShare = async () => {
    if (sharing) return;
    const amount = formatCurrency(receipt.amount, profileCurrency);
    const msg = `*Receipt: ${receipt.receiptNo}*\nReceived From: ${receipt.clientName}\nAmount: ${amount}\nDate: ${new Date(receipt.date).toLocaleDateString('en-IN')}`;
    
    if (navigator.share) {
      setSharing(true);
      try {
        const pdf = await buildPDF();
        const fileName = `RCPT_${receipt.receiptNo.replace(/\//g, '-')}.pdf`;
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
          pdf.save(fileName);
        }
      } catch (error) {
        console.error('PDF Generation failed', error);
        thagaval('Failed to generate PDF for sharing', 'error');
      } finally {
        setTimeout(() => setSharing(false), 2000);
      }
    } else {
      thagaval(t('featureNotSupported') || 'Native sharing not supported on this device.', 'warning');
    }
  };

  return (
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 0, md: 4 }, maxWidth: 1200, mx: 'auto', width: '100%', position: 'relative', bgcolor: 'background.default', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <ViewHeader 
        onEdit={onEdit ? () => onEdit(receipt) : undefined}
        onPrint={executePrint}
        onPDF={generatePDF}
        onShare={handleNativeShare}
        saving={saving}
        sharing={sharing}
        title={receipt?.receiptNo}
        onBack={onBack}
      />

      {/* Centered Preview Container */}
      <Box sx={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'flex-start', overflowX: 'hidden', pb: 4 }}>
        <style>{`
          .receipt-box { width: 100%; max-width: 600px; margin: 0 auto; border: 2px solid #e2e8f0; border-radius: 8px; padding: 2rem; background: white; }
          .receipt-header { text-align: center; margin-bottom: 1.5rem; border-bottom: 2px solid #e2e8f0; padding-bottom: 1rem; }
          .receipt-title { font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0; }
          .receipt-subtitle { font-size: 0.8rem; color: #64748b; margin: 0.25rem 0 0; }
          .receipt-row { display: flex; justify-content: space-between; padding: 0.5rem 0; font-size: 0.9rem; border-bottom: 1px solid #f1f5f9; }
          .receipt-label { color: #64748b; font-weight: 500; }
          .receipt-value { color: #1e293b; font-weight: 600; text-align: right; }
          .receipt-amount { font-size: 1.5rem; font-weight: 800; color: #1e40af; text-align: center; margin: 1.5rem 0; padding: 1rem; background: #eff6ff; border-radius: 8px; }
          .receipt-words { font-size: 0.85rem; color: #334155; font-style: italic; text-align: center; margin-bottom: 1.5rem; }
          .receipt-footer { display: flex; justify-content: space-between; margin-top: 3rem; padding-top: 1rem; }
          .receipt-sig { text-align: center; }
          .receipt-sig-line { width: 180px; border-bottom: 1.5px solid #1e293b; margin-bottom: 0.25rem; }
          .receipt-sig-label { font-size: 0.75rem; color: #64748b; }
          .business-name { font-size: 1.1rem; font-weight: 700; margin-bottom: 0.25rem; color: #000; }
          .business-details { font-size: 0.75rem; color: #64748b; }
        `}</style>
        <Paper elevation={3} sx={{ 
          p: 0, overflow: 'hidden', minWidth: 'min(100%, 600px)', m: '0 auto',
          zoom: { xs: 0.8, sm: 1 },
          '@supports not (zoom: 1)': {
            transformOrigin: 'top center',
            transform: { xs: 'scale(0.8)', sm: 'none' },
            mb: { xs: '-20%', sm: 0 }
          }
        }}>
          <div ref={printRef} style={{ width: '100%' }}>
            <div className="receipt-box">
              <div className="receipt-header">
                {profile.logo && <img src={profile.logo} alt="Logo" style={{ maxHeight: '80px', marginBottom: '1rem' }} />}
                <p className="business-name" style={{ lineHeight: '1.4' }}>
                  {profile.niruvanathinPeyar || 'Your Business'}
                  {profile.enableBilingual !== false && profile.niruvanathinPeyarEn && (
                    <><br /><span style={{ fontSize: '0.9rem', color: '#475569', fontWeight: 600 }}>{profile.niruvanathinPeyarEn}</span></>
                  )}
                </p>
                
                <p className="business-details">
                  {[profile.mugavari, profile.oor, profile.maavattam, profile.maanilam, profile.pin].filter(Boolean).join(', ')}
                </p>
                
                {profile.enableBilingual !== false && (profile.mugavariEn || profile.oorEn || profile.maavattamEn || profile.maanilamEn) && (
                  <p className="business-details" style={{ marginTop: '2px' }}>
                    {[profile.mugavariEn, profile.oorEn, profile.maavattamEn, profile.maanilamEn, profile.pin].filter(Boolean).join(', ')}
                  </p>
                )}
                
                <p className="business-details" style={{ marginTop: '4px' }}>
                  {profile.tholaipesi && <span>Phone: {profile.tholaipesi}</span>}
                  {profile.tholaipesi && profile.gstin && <span> | </span>}
                  {profile.gstin && <span>GSTIN: {profile.gstin}</span>}
                </p>

                {profile.enableBilingual !== false ? (
                  <div style={{ textAlign: 'center', marginTop: '1.5rem', marginBottom: '1.5rem' }}>
                    <h2 className="receipt-title" style={{ margin: 0, padding: 0 }}>{t('emptyKey')}</h2>
                    <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#64748b', marginTop: '2px', letterSpacing: '0.05em' }}>{t('hc_paymentReceipt') || 'PAYMENT RECEIPT'}</div>
                  </div>
                ) : (
                  <h2 className="receipt-title" style={{ marginTop: '1.5rem', marginBottom: '1.5rem' }}>{t('hc_paymentReceipt') || 'PAYMENT RECEIPT'}</h2>
                )}
              </div>
              <div className="receipt-row"><span className="receipt-label">{renderLabel('Receipt No:', 'ரசீது எண்:')}</span><span className="receipt-value">{receipt.receiptNo}</span></div>
              <div className="receipt-row"><span className="receipt-label">{renderLabel('Date:', 'தேதி:')}</span><span className="receipt-value">{new Date(receipt.date).toLocaleDateString('en-IN')}</span></div>
              <div className="receipt-row"><span className="receipt-label">{renderLabel('Received From:', 'பெறப்பட்டது:')}</span><span className="receipt-value">{receipt.clientName}{profile?.enableBilingual !== false && receipt.clientNameEn ? ` / ${receipt.clientNameEn}` : ''}</span></div>
              <div className="receipt-row"><span className="receipt-label">{renderLabel('Payment Mode:', 'செலுத்தும் முறை:')}</span><span className="receipt-value">{renderPaymentMode(receipt.paymentMode)}</span></div>
              {receipt.referenceNo && <div className="receipt-row"><span className="receipt-label">{renderLabel('Reference No:', 'குறிப்பு எண்:')}</span><span className="receipt-value">{receipt.referenceNo}</span></div>}
              {receipt.againstInvoice && <div className="receipt-row"><span className="receipt-label">{renderLabel('Against Invoice:', 'விலைப்பட்டியலுக்கு எதிராக:')}</span><span className="receipt-value">{receipt.againstInvoice}</span></div>}
              <div className="receipt-amount">{formatCurrency(receipt.amount, profileCurrency)}</div>
              <p className="receipt-words">{numberToWords(receipt.amount, profile?.primaryDataLanguage || 'English', profile?.secondaryDataLanguage || 'English', profile?.enableBilingual !== false)}</p>
              {receipt.note && <p style={{ fontSize: '0.85rem', color: '#64748b' }}>{renderLabel('Note:', 'குறிப்பு:')} {receipt.note}</p>}
              <div className="receipt-footer">
                <div className="receipt-sig"><div className="receipt-sig-line"></div><span className="receipt-sig-label">{renderLabel('Received By', 'பெற்றவர்')}</span></div>
                <div className="receipt-sig"><div className="receipt-sig-line"></div><span className="receipt-sig-label">{renderLabel('Authorized Signatory', 'அங்கீகரிக்கப்பட்ட கையொப்பம்')}</span></div>
              </div>
            </div>
          </div>
        </Paper>
      </Box>
    </Box>
  );
}
