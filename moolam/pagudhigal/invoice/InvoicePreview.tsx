// @ts-nocheck
import { useLanguage } from '../../mozhi/LanguageContext';
import React, { useState, useEffect } from 'react';
import QRCode from 'qrcode';
import DOMPurify from 'dompurify';
import { numberToWords, formatCurrency, INVOICE_TYPES, getCountryConfig, CURRENCY_NAMES, formatExchangeRateLine, getAccountById, getBilingualStateName, getBilingualCountryName } from '../../Payanpadu';

const PattiyalMunnotam = React.forwardRef(({ profile, client, details, items, totals, invoiceType = 'tax-invoice', customTerms, options = {} }, ref) => {
  const { t } = useLanguage();
  const businessState = profile?.maanilam?.trim().toLowerCase();
  const clientState = client?.maanilam?.trim().toLowerCase();
  const isInterstate = businessState && clientState && businessState !== clientState;
  const typeConfig = INVOICE_TYPES[invoiceType] || INVOICE_TYPES['tax-invoice'];
  // Seller's country drives tax label (GST / VAT / SST / MwSt etc.) and bank label.
  const sellerCC = getCountryConfig(profile?.country);
  const isIndia = (profile?.country || 'India') === 'India';
  const taxLabel = sellerCC.taxLabel || 'GST';

  // Resolve the payment account once per render. Falls back to the synthesised
  // legacy account (built from flat profile bank fields) when no array exists,
  // so v1.4.3 invoices render byte-identical with no `selectedAccountId`.
  const account = getAccountById(profile, options.selectedAccountId);
  const showAccountLabel = options.showAccountLabel === true;

  // Options with defaults. Each toggle defaults to ON so old invoices keep rendering as
  // before; users opt INTO hiding fields via Customize.
  const opt = (key, fallback = true) => options[key] !== undefined ? options[key] : fallback;
  const showGST = opt('showGST', typeConfig.showGST);
  const showState = opt('showState');
  const showDistrict = opt('showDistrict');
  const showCountry = opt('showCountry');
  const showGSTIN = opt('showGSTIN');
  const showPlaceOfSupply = opt('showPlaceOfSupply', showGST);
  const showHSN = opt('showHSN');
  const showDiscount = opt('showDiscount');
  const showBankDetails = opt('showBankDetails');
  const showUPI = opt('showUPI');
  const showLogo = opt('showLogo');
  const showSignature = opt('showSignature');
  const showSignatoryText = opt('showSignatoryText');
  const showTerms = opt('showTerms');
  const showNotes = opt('showNotes');
  const showAmountWords = opt('showAmountWords');
  const showItemQty = opt('showItemQty');
  const showItemUnit = opt('showItemUnit');
  const showRateColumn = opt('showRateColumn');
  const showSubtotal = opt('showSubtotal');
  // Header / client meta — default ON
  const showniruvanathinPeyar = opt('showniruvanathinPeyar');
  const showBusinessAddress = opt('showBusinessAddress');
  const showBusinessPhone = opt('showBusinessPhone');
  const showBusinessEmail = opt('showBusinessEmail');
  const showClientAddress = opt('showClientAddress');
  const showClientPhone = opt('showClientPhone');
  const showClientEmail = opt('showClientEmail');
  const showInvoiceNumber = opt('showInvoiceNumber');
  const showInvoiceDate = opt('showInvoiceDate');
  const customTitle = options.customTitle || typeConfig.title;
  const currencySymbol = options.currency || 'INR';

  const renderLabel = (enLabel, taLabel) => profile?.enableBilingual !== false ? `${taLabel} / ${enLabel}` : enLabel;

  const renderState = (val, customEn) => {
    if (!val) return '';
    if (customEn) return `${val} / ${customEn}`;
    return getBilingualStateName(val, profile);
  };

  const renderCountry = (val, customEn) => {
    if (!val) return '';
    if (customEn) return `${val} / ${customEn}`;
    return getBilingualCountryName(val, profile);
  };

  const fmt = (amount) => {
    if (currencySymbol === 'INR') return formatCurrency(amount);
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: currencySymbol, minimumFractionDigits: 2 }).format(amount || 0);
  };

  const amountInWords = (num) => {
    if (currencySymbol === 'INR') return numberToWords(num, profile?.primaryDataLanguage || 'English', profile?.secondaryDataLanguage || 'English', profile?.enableBilingual !== false);
    const a = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const b = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    const convert = (n) => {
      if (n === 0) return 'Zero';
      let result = '';
      if (n >= 1000000) { result += convert(Math.floor(n / 1000000)) + ' Million '; n %= 1000000; }
      if (n >= 1000) { result += convert(Math.floor(n / 1000)) + ' Thousand '; n %= 1000; }
      if (n >= 100) { result += a[Math.floor(n / 100)] + ' Hundred '; n %= 100; }
      if (n >= 20) { result += b[Math.floor(n / 10)] + ' '; if (n % 10) result += a[n % 10] + ' '; }
      else if (n > 0) { result += a[n] + ' '; }
      return result.trim();
    };
    const names = CURRENCY_NAMES[currencySymbol] || { major: currencySymbol, minor: 'Cents' };
    const rounded = Math.round(num * 100) / 100;
    const whole = Math.floor(rounded);
    const cents = Math.round((rounded - whole) * 100);
    let result = convert(whole) + ' ' + names.major;
    if (cents > 0) result += ' and ' + convert(cents) + ' ' + names.minor;
    return result + ' Only';
  };

  const [qrDataUrl, setQrDataUrl] = useState('');

  // Generate UPI QR code. The VPA now comes from the selected payment account
  // (so switching account swaps both bank block + QR), with fallback to the
  // legacy flat profile.upiId for invoices that pre-date multi-account support.
  const upiId = account?.upiId || profile?.upiId || '';
  useEffect(() => {
    if (!showUPI || !upiId || !totals.total || currencySymbol !== 'INR') {
      setQrDataUrl('');
      return;
    }
    const upiUrl = `upi://pay?pa=${encodeURIComponent(upiId)}&pn=${encodeURIComponent(profile?.niruvanathinPeyar || '')}&am=${totals.total.toFixed(2)}&cu=INR&tn=${encodeURIComponent(`Payment for ${details?.invoiceNumber || 'Invoice'}`)}`;
    QRCode.toDataURL(upiUrl, { width: 120, margin: 1, errorCorrectionLevel: 'M' })
      .then(setQrDataUrl)
      .catch(() => setQrDataUrl(''));
  }, [showUPI, upiId, profile?.niruvanathinPeyar, totals.total, details?.invoiceNumber, currencySymbol]);

  const accentColors = {
    'tax-invoice': '#1e40af',
    'proforma': '#7c3aed',
    'bill-of-supply': '#0f766e',
    'credit-note': '#be123c',
  };
  const accent = options.accentColor || accentColors[invoiceType] || accentColors['tax-invoice'];
  const pdfStyle = options.pdfStyle || 'classic';

  // Check if any item has discount
  const hasAnyDiscount = showDiscount && items.some(item => (item.discount || 0) > 0);

  // Header renderers per style
  const renderModernHeader = () => (
    <>
      <div style={{ background: accent, padding: '1.5rem 2rem', color: '#fff', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          {showLogo && profile?.logo && (
            <img src={profile.logo} alt="Logo" style={{ maxHeight: `${profile.logoHeight || 48}px`, maxWidth: '180px', objectFit: 'contain', marginBottom: '0.5rem', display: 'block', filter: 'brightness(0) invert(1)' }} />
          )}
          <h1 style={{ fontSize: '1.4rem', fontWeight: 800, margin: 0, letterSpacing: '0.08em' }}>{customTitle}</h1>
          {invoiceType === 'proforma' && (
            <p style={{ fontSize: '0.7rem', color: 'rgba(255,255,255,0.7)', fontStyle: 'italic', margin: '0.25rem 0 0' }}>{t('hc_forEstimationPurposesOnly')}</p>
          )}
        </div>
        <div style={{ textAlign: 'right' }}>
          {showniruvanathinPeyar && <h2 style={{ fontSize: '1rem', fontWeight: 700, margin: '0 0 0.25rem' }}>{profile?.niruvanathinPeyar || 'Your Business'}{profile?.businessNameEn ? <><br/><span style={{fontSize: '0.85em', fontWeight: 500, color: 'rgba(255,255,255,0.9)'}}>{profile.businessNameEn}</span></> : ''}</h2>}
          <div style={{ fontSize: '0.7rem', color: 'rgba(255,255,255,0.85)', lineHeight: 1.6 }}>
            {showBusinessAddress && profile?.mugavari && <p style={{ margin: 0 }}>{profile.mugavari}{profile?.addressEn ? ` / ${profile.addressEn}` : ''}</p>}
            {showBusinessAddress && (profile?.oor || profile?.pin) && <p style={{ margin: 0 }}>{[profile.oor ? profile.oor + (profile.oorEn ? ` / ${profile.oorEn}` : '') : '', profile.pin].filter(Boolean).join(' - ')}</p>}
            {showState && profile?.maanilam && <p style={{ margin: 0 }}>{renderState(profile.maanilam, profile?.stateEn)}</p>}
            {showDistrict && profile?.maavattam && <p style={{ margin: 0 }}>{profile.maavattam}{profile?.maavattamEn ? ` / ${profile.maavattamEn}` : ''}</p>}
            {showCountry && profile?.country && <p style={{ margin: 0 }}>{renderCountry(profile.country, profile?.countryEn)}</p>}
            {showGSTIN && profile?.gstin && <p style={{ margin: 0 }}>{getCountryConfig(profile?.country).taxIdLabel}: {profile.gstin}</p>}
            {showBusinessEmail && profile?.email && <p style={{ margin: 0 }}>{profile.email}</p>}
            {showBusinessPhone && profile?.tholaipesi && <p style={{ margin: 0 }}>Ph: {profile.tholaipesi}</p>}
            {showBusinessPhone && profile?.mobileNumber && <p style={{ margin: 0 }}>Mob: {profile.mobileNumber}</p>}
          </div>
        </div>
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0.75rem 2rem', background: '#f8fafc', borderBottom: '1px solid #e2e8f0' }}>
        <div style={{ display: 'flex', gap: '1.5rem', fontSize: '0.78rem' }}>
          {showInvoiceNumber && <span><strong style={{ color: '#64748b' }}>No.</strong> {details?.invoiceNumber}</span>}
          {showInvoiceDate && <span><strong style={{ color: '#64748b' }}>Date</strong> {details?.invoiceDate ? new Date(details.invoiceDate).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) : ''}</span>}
        </div>
        {invoiceType === 'credit-note' && details?.originalInvoiceRef && (
          <span style={{ fontSize: '0.75rem', color: '#64748b' }}>{t('hc_against')}<strong style={{ color: '#334155' }}>{details.originalInvoiceRef}</strong></span>
        )}
      </div>
    </>
  );

  const renderMinimalHeader = () => (
    <div style={{ padding: '2rem 2rem 1rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '1.5rem' }}>
        <div>
          {showLogo && profile?.logo && (
            <img src={profile.logo} alt="Logo" style={{ maxHeight: `${profile.logoHeight || 48}px`, maxWidth: '180px', objectFit: 'contain', marginBottom: '0.5rem', display: 'block' }} />
          )}
          {showniruvanathinPeyar && <h2 style={{ fontSize: '0.95rem', fontWeight: 700, color: '#1e293b', margin: 0 }}>{profile?.niruvanathinPeyar || 'Your Business'}{profile?.businessNameEn ? <><br/><span style={{fontSize: '0.85em', fontWeight: 500, color: '#64748b'}}>{profile.businessNameEn}</span></> : ''}</h2>}
          <div style={{ fontSize: '0.7rem', color: '#94a3b8', lineHeight: 1.6, marginTop: '0.25rem' }}>
            {showBusinessAddress && profile?.mugavari && <p style={{ margin: 0 }}>{profile.mugavari}{profile?.addressEn ? ` / ${profile.addressEn}` : ''}</p>}
            {showBusinessAddress && (profile?.oor || profile?.pin) && <p style={{ margin: 0 }}>{[profile.oor ? profile.oor + (profile.oorEn ? ` / ${profile.oorEn}` : '') : '', profile.pin].filter(Boolean).join(' - ')}</p>}
            {showState && profile?.maanilam && <p style={{ margin: 0 }}>{renderState(profile.maanilam, profile?.stateEn)}</p>}
            {showDistrict && profile?.maavattam && <p style={{ margin: 0 }}>{profile.maavattam}{profile?.maavattamEn ? ` / ${profile.maavattamEn}` : ''}</p>}
            {showCountry && profile?.country && <p style={{ margin: 0 }}>{renderCountry(profile.country, profile?.countryEn)}</p>}
            {showGSTIN && profile?.gstin && <p style={{ margin: 0 }}>{getCountryConfig(profile?.country).taxIdLabel}: {profile.gstin}</p>}
            {showBusinessEmail && profile?.email && <p style={{ margin: 0 }}>{profile.email}</p>}
            {showBusinessPhone && profile?.tholaipesi && <p style={{ margin: 0 }}>Ph: {profile.tholaipesi}</p>}
            {showBusinessPhone && profile?.mobileNumber && <p style={{ margin: 0 }}>Mob: {profile.mobileNumber}</p>}
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <h1 style={{ fontSize: '1.1rem', fontWeight: 700, color: accent, margin: '0 0 0.5rem', letterSpacing: '0.05em' }}>{customTitle}</h1>
          <div style={{ fontSize: '0.78rem', color: '#64748b', lineHeight: 1.8 }}>
            {showInvoiceNumber && <p style={{ margin: 0 }}>{details?.invoiceNumber}</p>}
            {showInvoiceDate && <p style={{ margin: 0 }}>{details?.invoiceDate ? new Date(details.invoiceDate).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) : ''}</p>}
          </div>
        </div>
      </div>
      {invoiceType === 'proforma' && (
        <p style={{ fontSize: '0.7rem', color: '#94a3b8', fontStyle: 'italic', margin: '0 0 0.5rem' }}>{t('hc_thisIsNotATax')}</p>
      )}
      <div style={{ borderBottom: `1.5px solid ${accent}`, marginBottom: '0' }} />
    </div>
  );

  const renderClassicHeader = () => (
    <>
      <div style={{ height: '6px', background: `linear-gradient(90deg, ${accent}, ${accent}cc, ${accent}88)` }} />
      <div className="inv-header">
        <div className="inv-header-left">
          {showLogo && profile?.logo && (
            <img src={profile.logo} alt="Logo" style={{ maxHeight: `${profile.logoHeight || 48}px`, maxWidth: '180px', objectFit: 'contain', marginBottom: '0.75rem', display: 'block' }} />
          )}
          <h1 className="inv-title" style={{ color: accent }}>{customTitle}</h1>
          {invoiceType === 'proforma' && (
            <p style={{ fontSize: '0.7rem', color: '#94a3b8', fontStyle: 'italic', marginBottom: '0.75rem' }}>{t('hc_thisIsNotATax')}</p>
          )}
          {invoiceType === 'credit-note' && details?.originalInvoiceRef && (
            <p style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.75rem' }}>{t('hc_againstInvoice')}<strong style={{ color: '#334155' }}>{details.originalInvoiceRef}</strong></p>
          )}
          <div className="inv-meta">
            {showInvoiceNumber && <div className="inv-meta-row"><span className="inv-meta-label">No.</span><span className="inv-meta-value">{details?.invoiceNumber}</span></div>}
            {showInvoiceDate && <div className="inv-meta-row"><span className="inv-meta-label">Date</span><span className="inv-meta-value">{details?.invoiceDate ? new Date(details.invoiceDate).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }) : ''}</span></div>}
          </div>
        </div>
        <div className="inv-header-right">
          {showniruvanathinPeyar && <h2 className="inv-business-name">{profile?.niruvanathinPeyar || 'Your Business'}{profile?.businessNameEn ? <><br/><span style={{fontSize: '0.85em', fontWeight: 500, color: '#64748b'}}>{profile.businessNameEn}</span></> : ''}</h2>}
          <div className="inv-business-details">
            {showBusinessAddress && profile?.mugavari && <p>{profile.mugavari}{profile?.addressEn ? ` / ${profile.addressEn}` : ''}</p>}
            {showBusinessAddress && (profile?.oor || profile?.pin) && <p>{[profile.oor ? profile.oor + (profile.oorEn ? ` / ${profile.oorEn}` : '') : '', profile.pin].filter(Boolean).join(' - ')}</p>}
            {showState && profile?.maanilam && <p>{renderState(profile.maanilam, profile?.stateEn)}</p>}
            {showDistrict && profile?.maavattam && <p>{profile.maavattam}{profile?.maavattamEn ? ` / ${profile.maavattamEn}` : ''}</p>}
            {showCountry && profile?.country && <p>{renderCountry(profile.country, profile?.countryEn)}</p>}
            {showGSTIN && profile?.gstin && <p>{getCountryConfig(profile?.country).taxIdLabel}: <strong>{profile.gstin}</strong></p>}
            {showBusinessEmail && profile?.email && <p>{profile.email}</p>}
            {showBusinessPhone && profile?.tholaipesi && <p>Ph: {profile.tholaipesi}</p>}
            {showBusinessPhone && profile?.mobileNumber && <p>Mob: {profile.mobileNumber}</p>}
          </div>
        </div>
      </div>
    </>
  );

  // Billing parties section (shared but styled per variant)
  const renderParties = () => {
    const padStyle = pdfStyle === 'modern' ? { padding: '1rem 2rem' } : pdfStyle === 'minimal' ? { padding: '0 2rem 1rem', border: 'none' } : {};
    return (
      <div className="inv-parties" style={padStyle}>
        <div className="inv-party">
          <h4 className="inv-section-label">{renderLabel('BILL TO', 'பட்டியல் பெறுபவர்')}</h4>
          <p className="inv-party-name">{client?.name || 'Client Name'}{client?.nameEn ? <><br/><span style={{fontSize: '0.85em', fontWeight: 500, color: '#64748b'}}>{client.nameEn}</span></> : ''}</p>
          <div className="inv-party-details">
            {showClientAddress && client?.mugavari && <p>{client.mugavari}{client?.mugavariEn ? ` / ${client.mugavariEn}` : ''}</p>}
            {showClientAddress && (client?.oor || client?.pin) && <p>{[client.oor ? client.oor + (client.oorEn ? ` / ${client.oorEn}` : '') : '', client.pin].filter(Boolean).join(' - ')}</p>}
            {showState && client?.maanilam && <p>{renderState(client.maanilam, client?.maanilamEn)}</p>}
            {showDistrict && client?.maavattam && <p>{client.maavattam}{client?.maavattamEn ? ` / ${client.maavattamEn}` : ''}</p>}
            {showCountry && client?.country && <p>{renderCountry(client.country, client?.countryEn)}</p>}
            {showGSTIN && client?.gstin && <p>{getCountryConfig(profile?.country).taxIdLabel}: <strong>{client.gstin}</strong></p>}
            {showClientEmail && client?.email && <p>{client.email}</p>}
            {showClientPhone && client?.tholaipesi && <p>Ph: {client.tholaipesi}</p>}
          </div>
        </div>
        {showPlaceOfSupply && (
          <div className="inv-party inv-party-right">
            <h4 className="inv-section-label">{renderLabel('PLACE OF SUPPLY', 'வழங்கும் இடம்')}</h4>
            <p className="inv-party-name">{details?.placeOfSupply ? renderState(details.placeOfSupply, null) : (client?.maanilam ? renderState(client.maanilam, client?.maanilamEn) : '-')}</p>
            {showGST && isIndia && isInterstate && <span className="inv-tax-badge">Interstate (IGST)</span>}
            {showGST && isIndia && !isInterstate && businessState && clientState && <span className="inv-tax-badge inv-tax-badge-green">Intrastate (CGST + SGST)</span>}
            {showGST && !isIndia && <span className="inv-tax-badge inv-tax-badge-green">{taxLabel}</span>}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="invoice-preview-container" ref={ref} id="invoice-preview">
      {pdfStyle === 'modern' && renderModernHeader()}
      {pdfStyle === 'minimal' && renderMinimalHeader()}
      {pdfStyle === 'classic' && renderClassicHeader()}

      {renderParties()}

      {/* Items table */}
      <table className="inv-table" style={{ tableLayout: 'auto', ...(pdfStyle === 'modern' ? { margin: '0 2rem', width: 'calc(100% - 4rem)' } : pdfStyle === 'minimal' ? { margin: '0 2rem', width: 'calc(100% - 4rem)', borderTop: 'none' } : {}) }}>
        <thead>
          {showGST ? (
            isIndia && isInterstate ? (
              <>
                <tr>
                  <th className="inv-th" rowSpan="2">#</th>
                  <th className="inv-th" rowSpan="2">Description</th>
                  {showHSN && <th className="inv-th inv-th-center" rowSpan="2">HSN/SAC</th>}
                  {showItemQty && <th className="inv-th inv-th-center" rowSpan="2">Qty</th>}
                  {showRateColumn && <th className="inv-th inv-th-right" rowSpan="2">Rate</th>}
                  {hasAnyDiscount && <th className="inv-th inv-th-right" rowSpan="2">{t('hc_disc')}</th>}
                  <th className="inv-th inv-th-center" colSpan="2" style={{ borderBottom: '1px solid #cbd5e1' }}>IGST</th>
                  <th className="inv-th inv-th-right" rowSpan="2">Amount</th>
                </tr>
                <tr>
                  <th className="inv-th inv-th-center">%</th>
                  <th className="inv-th inv-th-right">Amt</th>
                </tr>
              </>
            ) : isIndia ? (
              <>
                <tr>
                  <th className="inv-th" rowSpan="2">#</th>
                  <th className="inv-th" rowSpan="2">Description</th>
                  {showHSN && <th className="inv-th inv-th-center" rowSpan="2">HSN/SAC</th>}
                  {showItemQty && <th className="inv-th inv-th-center" rowSpan="2">Qty</th>}
                  {showRateColumn && <th className="inv-th inv-th-right" rowSpan="2">Rate</th>}
                  {hasAnyDiscount && <th className="inv-th inv-th-right" rowSpan="2">{t('hc_disc')}</th>}
                  <th className="inv-th inv-th-center" colSpan="2" style={{ borderBottom: '1px solid #cbd5e1' }}>CGST</th>
                  <th className="inv-th inv-th-center" colSpan="2" style={{ borderBottom: '1px solid #cbd5e1' }}>SGST</th>
                  <th className="inv-th inv-th-right" rowSpan="2">Amount</th>
                </tr>
                <tr>
                  <th className="inv-th inv-th-center">%</th>
                  <th className="inv-th inv-th-right">Amt</th>
                  <th className="inv-th inv-th-center">%</th>
                  <th className="inv-th inv-th-right">Amt</th>
                </tr>
              </>
            ) : (
              // Foreign: single tax column (VAT/SST/etc.) — no CGST/SGST/IGST split
              <>
                <tr>
                  <th className="inv-th" rowSpan="2">#</th>
                  <th className="inv-th" rowSpan="2">Description</th>
                  {showHSN && <th className="inv-th inv-th-center" rowSpan="2">HSN/SAC</th>}
                  {showItemQty && <th className="inv-th inv-th-center" rowSpan="2">Qty</th>}
                  {showRateColumn && <th className="inv-th inv-th-right" rowSpan="2">Rate</th>}
                  {hasAnyDiscount && <th className="inv-th inv-th-right" rowSpan="2">{t('hc_disc')}</th>}
                  <th className="inv-th inv-th-center" colSpan="2" style={{ borderBottom: '1px solid #cbd5e1' }}>{taxLabel}</th>
                  <th className="inv-th inv-th-right" rowSpan="2">Amount</th>
                </tr>
                <tr>
                  <th className="inv-th inv-th-center">%</th>
                  <th className="inv-th inv-th-right">Amt</th>
                </tr>
              </>
            )
          ) : (
            <tr>
              <th className="inv-th">#</th>
              <th className="inv-th">Description</th>
              {showHSN && <th className="inv-th inv-th-center">HSN/SAC</th>}
              {showItemQty && <th className="inv-th inv-th-center">Qty</th>}
              {showRateColumn && <th className="inv-th inv-th-right">Rate</th>}
              {hasAnyDiscount && <th className="inv-th inv-th-right">{t('hc_disc')}</th>}
              <th className="inv-th inv-th-right">Amount</th>
            </tr>
          )}
        </thead>
        <tbody>
          {items.map((item, index) => {
            const lineAmount = item.quantity * item.rate;
            const discount = item.discount || 0;
            const grossAfterDiscount = lineAmount - discount;
            const taxRate = item.taxPercent || 0;
            const isTaxInclusive = totals.taxInclusive;
            const afterDiscount = isTaxInclusive && showGST ? grossAfterDiscount / (1 + taxRate / 100) : grossAfterDiscount;
            const taxAmount = isTaxInclusive && showGST ? grossAfterDiscount - afterDiscount : afterDiscount * taxRate / 100;
            const halfRate = taxRate / 2;
            const halfTax = taxAmount / 2;
            return (
              <tr key={item.id} className={index % 2 === 0 ? 'inv-tr-even' : ''}>
                <td className="inv-td inv-td-muted">{index + 1}</td>
                <td className="inv-td inv-td-name">
                  <div style={{ fontWeight: 500 }}>{item.name || '-'}</div>
                  {item.nameEn && <div style={{ fontSize: '0.85em', color: '#64748b', marginTop: '2px' }}>{item.nameEn}</div>}
                  {item.description && <div style={{ fontSize: '0.8em', color: '#94a3b8', marginTop: '2px' }}>{item.description}</div>}
                  {item.descriptionEn && <div style={{ fontSize: '0.8em', color: '#94a3b8', marginTop: '1px' }}>{item.descriptionEn}</div>}
                </td>
                {showHSN && <td className="inv-td inv-td-center inv-td-muted">{item.hsn || '-'}</td>}
                {showItemQty && <td className="inv-td inv-td-center">{item.quantity}{showItemUnit && item.unit ? ` ${item.unit}` : ''}</td>}
                {showRateColumn && <td className="inv-td inv-td-right">{fmt(item.rate)}</td>}
                {hasAnyDiscount && <td className="inv-td inv-td-right">{discount > 0 ? fmt(discount) : '-'}</td>}
                {showGST && (
                  isIndia && isInterstate ? (
                    <>
                      <td className="inv-td inv-td-center">{taxRate}%</td>
                      <td className="inv-td inv-td-right">{fmt(taxAmount)}</td>
                    </>
                  ) : isIndia ? (
                    <>
                      <td className="inv-td inv-td-center">{halfRate}%</td>
                      <td className="inv-td inv-td-right">{fmt(halfTax)}</td>
                      <td className="inv-td inv-td-center">{halfRate}%</td>
                      <td className="inv-td inv-td-right">{fmt(halfTax)}</td>
                    </>
                  ) : (
                    <>
                      <td className="inv-td inv-td-center">{taxRate}%</td>
                      <td className="inv-td inv-td-right">{fmt(taxAmount)}</td>
                    </>
                  )
                )}
                <td className="inv-td inv-td-right inv-td-amount">{fmt(afterDiscount)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>

      {/* Totals section */}
      <div className="inv-totals-section" style={pdfStyle !== 'classic' ? { padding: '1rem 2rem' } : {}}>
        <div className="inv-words">
          {showAmountWords && (
            <>
              <h4 className="inv-section-label">{renderLabel('AMOUNT IN WORDS', 'எழுத்துக்களில்')}</h4>
              <p className="inv-words-text">{amountInWords(totals.total)}</p>
            </>
          )}
          {/* UPI QR Code */}
          {qrDataUrl && (
            <div style={{ marginTop: '1.25rem' }}>
              <h4 className="inv-section-label">{renderLabel('SCAN TO PAY (UPI)', 'ஸ்கேன் செய்து செலுத்த')}</h4>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                <img src={qrDataUrl} alt="UPI QR" style={{ width: '90px', height: '90px', borderRadius: '6px', border: '1px solid #e2e8f0' }} />
                <div style={{ fontSize: '0.7rem', color: '#94a3b8', lineHeight: 1.5 }}>
                  <p style={{ margin: 0, color: '#94a3b8' }}>UPI ID:</p>
                  <p style={{ margin: 0, color: '#334155', fontWeight: 600, fontSize: '0.75rem' }}>{upiId}</p>
                  <p style={{ margin: '0.25rem 0 0', color: '#94a3b8' }}>{fmt(totals.total)}</p>
                </div>
              </div>
            </div>
          )}
        </div>

        <div className="inv-totals">
          {showSubtotal && (
            <div className="inv-total-row">
              <span>{t('hc_subtotal')}</span>
              <span>{fmt(totals.subtotal)}</span>
            </div>
          )}
          {totals.totalDiscount > 0 && (
            <div className="inv-total-row" style={{ color: '#dc2626' }}>
              <span>Discount</span>
              <span>- {fmt(totals.totalDiscount)}</span>
            </div>
          )}
          {showGST && (
            isIndia && isInterstate ? (
              <div className="inv-total-row">
                <span>IGST</span>
                <span>{fmt(totals.igst)}</span>
              </div>
            ) : isIndia ? (
              <>
                <div className="inv-total-row">
                  <span>CGST</span>
                  <span>{fmt(totals.cgst)}</span>
                </div>
                <div className="inv-total-row">
                  <span>SGST</span>
                  <span>{fmt(totals.sgst)}</span>
                </div>
              </>
            ) : (
              <div className="inv-total-row">
                <span>{taxLabel}</span>
                <span>{fmt((totals.cgst || 0) + (totals.sgst || 0) + (totals.igst || 0))}</span>
              </div>
            )
          )}
          {totals.cess > 0 && (
            <div className="inv-total-row">
              <span>{t('hc_gstCess')}</span>
              <span>{fmt(totals.cess)}</span>
            </div>
          )}
          {totals.tcsAmount > 0 && (
            <div className="inv-total-row">
              <span>TCS{options.tcsSection ? ` (${options.tcsSection} @ ${options.tcsRate}%)` : ''}</span>
              <span>{fmt(totals.tcsAmount)}</span>
            </div>
          )}
          {totals.roundOff !== undefined && totals.roundOff !== 0 && (
            <div className="inv-total-row" style={{ color: '#64748b', fontStyle: 'italic' }}>
              <span>{t('hc_roundoff')}</span>
              <span>{totals.roundOff > 0 ? '+' : ''}{fmt(totals.roundOff)}</span>
            </div>
          )}
          {pdfStyle === 'modern' ? (
            <div className="inv-total-row inv-total-final inv-total-modern" style={{ background: accent, color: '#fff', borderRadius: '6px', padding: '0.6rem 0.75rem', marginTop: '0.25rem' }}>
              <span style={{ color: '#fff' }}>{invoiceType === 'credit-note' ? 'Credit Amount' : 'Total Due'}</span>
              <span style={{ color: '#fff' }}>{fmt(totals.total)}</span>
            </div>
          ) : (
            <div className="inv-total-row inv-total-final">
              <span>{invoiceType === 'credit-note' ? 'Credit Amount' : 'Total Due'}</span>
              <span style={{ color: accent }}>{fmt(totals.total)}</span>
            </div>
          )}
          {totals.tdsAmount > 0 && (
            <>
              <div className="inv-total-row" style={{ color: '#64748b', fontSize: '0.75rem', marginTop: '0.25rem', borderTop: '1px dashed #e2e8f0', paddingTop: '0.4rem' }}>
                <span>Less: TDS{options.tdsSection ? ` (${options.tdsSection} @ ${options.tdsRate}%)` : ''}</span>
                <span>− {fmt(totals.tdsAmount)}</span>
              </div>
              <div className="inv-total-row" style={{ fontWeight: 600, color: '#0f766e', fontSize: '0.78rem' }}>
                <span>{t('hc_netReceivable')}</span>
                <span>{fmt(totals.netReceivable)}</span>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Reverse-charge declaration (India) — printed prominently between the
          tax block and the footer when the seller has flagged this invoice as
          RCM. The buyer is responsible for paying GST under Section 9(3)/9(4). */}
      {options.reverseCharge && isIndia && showGST && (
        <div style={{ margin: '0 2rem 0.5rem', padding: '0.5rem 0.75rem', background: 'var(--warn-bg)', border: '1px solid var(--warn-border)', borderRadius: 4, fontSize: '0.78rem', color: 'var(--warn-text)' }}>
          <strong>{t('hc_reverseChargeApplicable')}</strong> GST is payable by the recipient under Section 9(3)/9(4) of the CGST Act.
        </div>
      )}

      {/* Composition-scheme mandatory declaration — Rule 46A of CGST Rules. The
          exact wording is prescribed; do not paraphrase. */}
      {invoiceType === 'composition' && (
        <div style={{ margin: '0 2rem 0.5rem', padding: '0.5rem 0.75rem', background: 'var(--info-bg)', border: '1px solid var(--info-border)', borderRadius: 4, fontSize: '0.78rem', color: 'var(--info-text)', fontStyle: 'italic' }}>
          "Composition taxable person, not eligible to collect tax on supplies."
          &nbsp;<span style={{ fontStyle: 'normal', fontSize: '0.7rem' }}>(Rule 46A, CGST Rules)</span>
        </div>
      )}

      {/* Footer */}
      <div className="inv-footer" style={pdfStyle !== 'classic' ? { padding: '1rem 2rem' } : {}}>
        <div className="inv-footer-left">
          {/* Bank details render from the resolved payment account. Account fields
              fall back to the flat profile fields when neither array entry nor flat
              field exists — guarantees byte-identical PDFs for v1.4.3 invoices. */}
          {showBankDetails && (account?.vangiPeyar || profile?.vangiPeyar) && (
            <div className="inv-footer-block">
              <h4 className="inv-section-label">{renderLabel('BANK DETAILS', 'வங்கி விவரங்கள்')}</h4>
              {showAccountLabel && account?.label && (
                <p style={{ margin: '0 0 0.25rem', fontSize: '0.75rem', color: '#64748b', fontStyle: 'italic' }}>
                  Pay via: <strong style={{ color: '#334155' }}>{account.label}</strong>
                </p>
              )}
              <div className="inv-footer-details">
                <p><span className="inv-detail-label">{renderLabel('Bank:', 'வங்கி:')}</span> {account?.vangiPeyar || profile.vangiPeyar}</p>
                <p><span className="inv-detail-label">{renderLabel('A/C No:', 'கணக்கு எண்:')}</span> {account?.kanakkuEn || profile.kanakkuEn}</p>
                {(account?.ifsc || profile.ifsc) && <p><span className="inv-detail-label">{renderLabel(sellerCC.bankLabel || 'IFSC:', 'IFSC:')}</span> {account?.ifsc || profile.ifsc}</p>}
                {(account?.swift || profile.swift) && <p><span className="inv-detail-label">SWIFT/BIC:</span> {account?.swift || profile.swift}</p>}
                {profile.pan && isIndia && <p><span className="inv-detail-label">PAN:</span> {profile.pan}</p>}
              </div>
            </div>
          )}
          {options.exchangeRate && currencySymbol !== 'INR' && (
            <div className="inv-footer-block">
              <h4 className="inv-section-label">{t('hc_exchangeRate')}</h4>
              <p className="inv-terms">{formatExchangeRateLine(currencySymbol, options.exchangeRate, profile?.country === 'India' || !profile?.country ? 'INR' : sellerCC.currency)}</p>
            </div>
          )}
          {/* Terms and notes accept rich HTML; same DOMPurify sanitization the extraSections
              block uses, which keeps b/i/u/lists/links/headings and strips everything else. */}
          {(() => {
            const termsHtml = customTerms ? DOMPurify.sanitize(customTerms) : '';
            const hasTerms = termsHtml && termsHtml.replace(/<[^>]*>/g, '').trim();
            return showTerms && hasTerms ? (
              <div className="inv-footer-block">
                <h4 className="inv-section-label">TERMS & CONDITIONS</h4>
                <div className="inv-terms inv-rich" dangerouslySetInnerHTML={{ __html: termsHtml }} />
              </div>
            ) : null;
          })()}
        </div>
        {showSignature && profile?.signature && (
          <div className="inv-signature">
            {showSignatoryText && <p className="inv-sig-label">Authorized Signatory</p>}
            <img src={profile.signature} alt="Signature" style={{
              maxHeight: '60px', maxWidth: '180px', objectFit: 'contain',
              display: 'block', marginLeft: 'auto', marginBottom: '0.4rem'
            }} />
            <p className="inv-sig-name">{profile?.niruvanathinPeyar}</p>
          </div>
        )}
      </div>

      {/* Watermark for proforma */}
      {invoiceType === 'proforma' && (
        <div style={{
          position: 'absolute', top: '50%', left: '50%',
          transform: 'translate(-50%, -50%) rotate(-35deg)',
          fontSize: '5rem', fontWeight: 800, color: `${accent}0a`,
          pointerEvents: 'none', whiteSpace: 'nowrap'
        }}>
          ESTIMATE
        </div>
      )}

      {/* Bottom bar for modern style */}
      {pdfStyle === 'modern' && (
        <div style={{ height: '4px', background: accent, marginTop: 'auto' }} />
      )}
    </div>
  );
});

export default PattiyalMunnotam;
