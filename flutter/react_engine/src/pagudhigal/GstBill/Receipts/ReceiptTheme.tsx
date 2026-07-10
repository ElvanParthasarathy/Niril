import React, { useState } from 'react';
import { useLanguage } from '../../../mozhi/LanguageContext';
import { en } from '../../../mozhi/en';
import { ta } from '../../../mozhi/ta';
import { formatCurrency, numberToWords, getCountryConfig, getDynamicField, getBilingualStateName, getBilingualCountryName } from '../../../Payanpadu';
import '../../CoolieBill/print.css';

const IconPhone = ({ size = 14, className = '', style = {} }) => (
    <svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} viewBox="0 0 24 24" fill="currentColor" className={className} style={style}>
        <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z" />
    </svg>
);

const IconMail = ({ size = 14, className = '', style = {} }) => (
    <svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className} style={style}>
        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
        <polyline points="22,6 12,13 2,6"></polyline>
    </svg>
);

const ReceiptTheme = React.forwardRef(({ profile = {}, client = {}, details = {}, items = [], totals = {}, invoiceType = 'receipt', customTerms, options = {} }: any, ref: any) => {
  // Map destructured props back to the 'receipt' object structure the template expects
  const receipt = {
    client,
    details,
    items,
    totals,
    invoiceType,
    customTerms,
    invoiceOptions: options
  };

  const { t } = useLanguage();
  const profileCurrency = profile?.currency || 'INR';

  // Dynamic logo layout states
  const [logoX, setLogoX] = useState(profile?.wideLogoX || 0);
  const [logoY, setLogoY] = useState(profile?.wideLogoY || 0);
  const logoScale = profile?.wideLogoScale || 1;
  const isLogoAbsolute = profile?.wideLogoPosition === 'absolute';

  const RECEIPT_LABELS = {
    'Tamil': { hc_paymentReceipt: 'பண ரசீது', receiptNoLabel: 'ரசீது எண்:', dateLabel: 'தேதி:', receivedFromLabel: 'பெறப்பட்டது:', paymentModeLabel: 'செலுத்தும் முறை:', referenceNoLabel: 'குறிப்பு எண்:', againstInvoiceLabel: 'விலைப்பட்டியலுக்கு எதிராக:', noteLabel: 'குறிப்பு:', receivedBy: 'பெற்றவர்', authorizedSignatory: 'அங்கீகரிக்கப்பட்ட கையொப்பம்', phoneLabel: 'தொலைபேசி:', mobileLabel: 'கைப்பேசி:' },
    'English': { hc_paymentReceipt: 'Payment Receipt', receiptNoLabel: 'Receipt No:', dateLabel: 'Date:', receivedFromLabel: 'Received From:', paymentModeLabel: 'Payment Mode:', referenceNoLabel: 'Reference No:', againstInvoiceLabel: 'Against Invoice:', noteLabel: 'Note:', receivedBy: 'Received By', authorizedSignatory: 'Authorized Signatory', phoneLabel: 'Phone:', mobileLabel: 'Mobile:' },
    'Hindi': { hc_paymentReceipt: 'भुगतान रसीद', receiptNoLabel: 'रसीद संख्या:', dateLabel: 'तारीख:', receivedFromLabel: 'से प्राप्त:', paymentModeLabel: 'भुगतान मोड:', referenceNoLabel: 'संदर्भ संख्या:', againstInvoiceLabel: 'इनवॉयस के विरुद्ध:', noteLabel: 'नोट:', receivedBy: 'प्राप्तकर्ता', authorizedSignatory: 'अधिकृत हस्ताक्षरकर्ता', phoneLabel: 'फोन:', mobileLabel: 'मोबाइल:' },
    'Telugu': { hc_paymentReceipt: 'చెల్లింపు రసీదు', receiptNoLabel: 'రసీదు సంఖ్య:', dateLabel: 'తేదీ:', receivedFromLabel: 'నుండి స్వీకరించబడింది:', paymentModeLabel: 'చెల్లింపు పద్ధతి:', referenceNoLabel: 'సూచన సంఖ్య:', againstInvoiceLabel: 'ఇన్వాయిస్కు వ్యతిరేకంగా:', noteLabel: 'గమనిక:', receivedBy: 'స్వీకరించినవారు', authorizedSignatory: 'అధీకృత సంతకందారు', phoneLabel: 'ఫోన్:', mobileLabel: 'మొబైల్:' },
    'Kannada': { hc_paymentReceipt: 'ಪಾವತಿ ರಸೀದಿ', receiptNoLabel: 'ರಸೀದಿ ಸಂಖ್ಯೆ:', dateLabel: 'ದಿನಾಂಕ:', receivedFromLabel: 'ಇವರಿಂದ ಸ್ವೀಕರಿಸಲಾಗಿದೆ:', paymentModeLabel: 'ಪಾವತಿ ವಿಧಾನ:', referenceNoLabel: 'ಉಲ್ಲೇಖ ಸಂಖ್ಯೆ:', againstInvoiceLabel: 'ಇನ್ವಾಯ್ಸ್ ವಿರುದ್ಧ:', noteLabel: 'ಸೂಚನೆ:', receivedBy: 'ಸ್ವೀಕರಿಸಿದವರು', authorizedSignatory: 'ಅಧಿಕೃತ ಸಹಿದಾರ', phoneLabel: 'ಫೋನ್:', mobileLabel: 'ಮೊಬೈಲ್:' },
    'Malayalam': { hc_paymentReceipt: 'പേയ്മെന്റ് രസീത്', receiptNoLabel: 'രസീത് നമ്പർ:', dateLabel: 'തീയതി:', receivedFromLabel: 'ഇതിൽ നിന്ന് ലഭിച്ചു:', paymentModeLabel: 'പേയ്മെന്റ് രീതി:', referenceNoLabel: 'റഫറൻസ് നമ്പർ:', againstInvoiceLabel: 'ഇൻവോയ്സിനെതിരെ:', noteLabel: 'കുറിപ്പ്:', receivedBy: 'ലഭിച്ചത്', authorizedSignatory: 'അംഗീകൃത ഒപ്പിട്ടയാൾ', phoneLabel: 'ഫോൺ:', mobileLabel: 'മൊബൈൽ:' },
    'Marathi': { hc_paymentReceipt: 'पेमेंट पावती', receiptNoLabel: 'पावती क्रमांक:', dateLabel: 'तारीख:', receivedFromLabel: 'कडून प्राप्त:', paymentModeLabel: 'पेमेंट पद्धत:', referenceNoLabel: 'संदर्भ क्रमांक:', againstInvoiceLabel: 'इनव्हॉइस विरुद्ध:', noteLabel: 'टीप:', receivedBy: 'प्राप्तकर्ता', authorizedSignatory: 'अधिकृत स्वाक्षरीकर्ता', phoneLabel: 'फोन:', mobileLabel: 'मोबाईल:' },
    'Gujarati': { hc_paymentReceipt: 'ચુકવણી પહોંચ', receiptNoLabel: 'પહોંચ નંબર:', dateLabel: 'તારીખ:', receivedFromLabel: 'તરફથી પ્રાપ્ત:', paymentModeLabel: 'ચુકવણી પદ્ધતિ:', referenceNoLabel: 'સંદર્ભ નંબર:', againstInvoiceLabel: 'ઇન્વૉઇસ સામે:', noteLabel: 'નોંધ:', receivedBy: 'પ્રાપ્તકર્તા', authorizedSignatory: 'અધિકૃત સહી', phoneLabel: 'ફોન:', mobileLabel: 'મોબાઇલ:' },
    'Bengali': { hc_paymentReceipt: 'পেমেন্ট রসিদ', receiptNoLabel: 'রসিদ নম্বর:', dateLabel: 'তারিখ:', receivedFromLabel: 'থেকে প্রাপ্ত:', paymentModeLabel: 'পেমেন্ট পদ্ধতি:', referenceNoLabel: 'রেফারেন্স নম্বর:', againstInvoiceLabel: 'ইনভয়েসের বিপরীতে:', noteLabel: 'নোট:', receivedBy: 'প্রাপক', authorizedSignatory: 'অনুমোদিত স্বাক্ষরকারী', phoneLabel: 'ফোন:', mobileLabel: 'মোবাইল:' }
  };

  const getLangStr = (lang: string, key: string, enDefault: string, taDefault: string) => {
    // @ts-ignore
    if (RECEIPT_LABELS[lang]?.[key]) return RECEIPT_LABELS[lang][key];
    // @ts-ignore
    if (lang === 'Tamil') return ta[key] || taDefault || enDefault || key;
    // @ts-ignore
    if (lang === 'English') return en[key] || enDefault || taDefault || key;
    return '';
  };
  
  const renderPaymentMode = (mode: string) => {
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
    const secondaryLang = profile?.secondaryDataLanguage || 'English';
    // @ts-ignore
    const pStr = (dictionaries[primaryLang] || {})[mode] || mode;
    // @ts-ignore
    const sStr = secondaryLang === 'English' ? mode : ((dictionaries[secondaryLang] || {})[mode] || mode);

    if (profile?.enableBilingual !== false && pStr !== sStr) {
      return (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
          <span>{pStr}</span>
          <span style={{ fontSize: '0.6em', fontWeight: 500, opacity: 0.85, letterSpacing: '0.02em', marginTop: '-1px' }}>{sStr}</span>
        </div>
      );
    }
    return pStr;
  };

  const renderKey = (key: string, enDefault: string, taDefault: string) => {
    const primaryLang = profile?.primaryDataLanguage || 'Tamil';
    const secondaryLang = profile?.secondaryDataLanguage || 'English';
    const pStr = getLangStr(primaryLang, key, enDefault, taDefault);
    const sStr = getLangStr(secondaryLang, key, enDefault, taDefault);
    if (profile?.enableBilingual !== false && pStr !== sStr) {
      return (
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          <span>{pStr}</span>
          <span style={{ fontSize: '0.65em', fontWeight: 500, opacity: 0.85, letterSpacing: '0.02em', marginTop: '-1px' }}>{sStr}</span>
        </div>
      );
    }
    return pStr;
  };

  const addr1_eng = [getDynamicField(profile, 'mugavari', profile, false), getDynamicField(profile, 'oor', profile, false)].filter(Boolean).join(', ');
  const addr1_tam = [getDynamicField(profile, 'mugavari', profile, true), getDynamicField(profile, 'oor', profile, true)].filter(Boolean).join(', ');
  const addr1 = (addr1_eng || addr1_tam) + (profile?.pin ? ` - ${profile.pin}` : '');
  
  const country_eng = profile?.enableBilingual === false ? '' : (getBilingualCountryName(profile?.country, { ...profile, returnOnlySecondary: true, fallbackEnglishName: profile?.country_English }) || profile?.country_English || profile?.country);
  const country_tam = getBilingualCountryName(profile?.country, { ...profile, returnOnlyPrimary: true }) || profile?.country;

  const dist_eng = [getDynamicField(profile, 'maavattam', profile, false), getBilingualStateName(profile.maanilam, { ...profile, returnOnlySecondary: true, fallbackEnglishName: profile.maanilamEn }), country_eng].filter(Boolean).join(', ');
  const dist_tam = [getDynamicField(profile, 'maavattam', profile, true), getBilingualStateName(profile.maanilam, { ...profile, returnOnlyPrimary: true }), country_tam].filter(Boolean).join(', ');
  const dist = dist_eng || dist_tam;
  const addr2 = dist;
  
  const email = profile?.email || profile?.minnanjal || '';

  const phoneArr = [];
  if (profile?.phoneNumbers && Array.isArray(profile.phoneNumbers)) phoneArr.push(...profile.phoneNumbers);
  if (!phoneArr.length && profile?.tholaippaesi) phoneArr.push(...(Array.isArray(profile.tholaippaesi) ? profile.tholaippaesi : String(profile.tholaippaesi).split(',')));
  if (profile?.mobileNumber) phoneArr.push(...(Array.isArray(profile.mobileNumber) ? profile.mobileNumber : String(profile.mobileNumber).split(',')));
  const phone = phoneArr.map(p => p.trim()).filter(Boolean);

  return (
    <div ref={ref} className="receipt-box" style={{ 
      position: 'relative',
      fontFamily: profile.themeFont || 'Inter, sans-serif'
    }}>
      <style>{`
        .receipt-box { width: 100%; background: transparent; display: flex; flex-direction: column; flex-grow: 1; padding: 1rem; }
        .receipt-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid ${profile.themeColor ? `${profile.themeColor}30` : '#e2e8f0'}; position: relative; }
        .header-left { display: flex; align-items: center; gap: 1rem; flex: 1; }
        .header-right { text-align: right; }
        .logo-placeholder { width: 60px; height: 60px; background: ${profile.themeColor ? `${profile.themeColor}15` : '#f1f5f9'}; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-weight: bold; color: ${profile.themeColor || '#94a3b8'}; }
        .receipt-row { display: flex; justify-content: space-between; padding: 0.75rem 0; border-bottom: 1px dashed #e2e8f0; align-items: center; }
        .receipt-label { font-weight: 600; color: #64748b; font-size: 0.95rem; }
        .receipt-value { font-weight: 500; color: #1e293b; font-size: 1.05rem; }
        .receipt-amount { font-size: 2.2rem; font-weight: 800; color: #0f172a; text-align: center; margin: 2rem 0 0.5rem; letter-spacing: -0.02em; }
        .receipt-words { text-align: center; color: #64748b; font-style: italic; margin-bottom: 2rem; font-size: 0.9rem; }
        .receipt-footer { display: flex; justify-content: flex-end; margin-top: auto; padding-top: 1.5rem; }
        .rcpt-contact-section { margin-top: 2rem; padding: 1.25rem; border-radius: 8px; background: ${profile.themeColor ? `${profile.themeColor}08` : '#f8fafc'}; font-size: 0.9rem; color: #475569; display: flex; flex-direction: column; gap: 0.75rem; border: 1px solid ${profile.themeColor ? `${profile.themeColor}20` : '#e2e8f0'}; }
        .rcpt-contact-title { font-weight: 600; font-size: 0.95rem; color: ${profile.themeColor || '#334155'}; text-transform: uppercase; letter-spacing: 0.05em; }
        .rcpt-contact-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; }
        .rcpt-contact-left { display: flex; flex-direction: column; gap: 0.5rem; flex: 1; }
        .rcpt-contact-address { line-height: 1.4; }
        .rcpt-contact-email { display: flex; alignItems: center; gap: 6px; }
        .rcpt-contact-phones { text-align: right; }
      `}</style>
      
      <div className="receipt-header">
        <div className="header-left">
          {profile?.wideLogo ? (
            <div style={{ position: 'relative', width: '250px', height: '60px' }}>
              <img 
                src={profile.wideLogo} 
                alt="Logo" 
                style={{ 
                  maxWidth: '100%', 
                  maxHeight: '100%',
                  objectFit: 'contain',
                  position: isLogoAbsolute ? 'absolute' : 'relative',
                  left: isLogoAbsolute ? `${logoX}px` : 0,
                  top: isLogoAbsolute ? `${logoY}px` : 0,
                  transform: `scale(${logoScale})`,
                  transformOrigin: 'top left',
                }}
              />
            </div>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              {profile?.logo ? (
                <img src={profile.logo} alt="Logo" style={{ width: '60px', height: '60px', objectFit: 'contain', borderRadius: '8px' }} />
              ) : (
                <div className="logo-placeholder">{getDynamicField(profile, 'niruvanathinPeyar', profile, false)?.charAt(0) || 'L'}</div>
              )}
              <div>
                <div className="font-tamil" style={{ fontSize: '1.4rem', fontWeight: 800, color: '#0f172a', letterSpacing: '-0.02em', lineHeight: 1.2 }}>
                  {getDynamicField(profile, 'niruvanathinPeyar', profile, true) || getDynamicField(profile, 'niruvanathinPeyar', profile, false) || 'Company Name'}
                </div>
                {profile?.enableBilingual !== false && getDynamicField(profile, 'niruvanathinPeyar', profile, false) !== getDynamicField(profile, 'niruvanathinPeyar', profile, true) && (
                  <div style={{ fontSize: '0.85rem', color: '#64748b', fontWeight: 500, marginTop: '2px' }}>
                    {getDynamicField(profile, 'niruvanathinPeyar', profile, false)}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
        <div className="header-right">
          <div className="font-tamil" style={{ color: profile.themeColor || '#388e3c', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', fontWeight: 700, fontSize: '1.2rem' }}>
            {profile.enableBilingual !== false && getLangStr(profile?.primaryDataLanguage || 'Tamil', 'hc_paymentReceipt', 'Payment Receipt', 'பண ரசீது') !== getLangStr(profile?.secondaryDataLanguage || 'English', 'hc_paymentReceipt', 'Payment Receipt', 'பண ரசீது') ? (
              <>
                <div>{getLangStr(profile?.primaryDataLanguage || 'Tamil', 'hc_paymentReceipt', 'Payment Receipt', 'பண ரசீது')}</div>
                <div style={{ fontSize: '0.55em', fontWeight: 500, opacity: 0.85, letterSpacing: '0.02em', marginTop: '2px' }}>{getLangStr(profile?.secondaryDataLanguage || 'English', 'hc_paymentReceipt', 'Payment Receipt', 'பண ரசீது')}</div>
              </>
            ) : (
              getLangStr(profile?.enableBilingual === false ? (profile?.primaryDataLanguage || 'Tamil') : 'English', 'hc_paymentReceipt', 'Payment Receipt', 'பண ரசீது')
            )}
          </div>
        </div>
      </div>
      
      <div className="receipt-row"><span className="receipt-label" style={{ color: profile.themeColor || '#388e3c' }}>{renderKey('receiptNoLabel', 'Receipt No:', 'ரசீது எண்:')}</span><span className="receipt-value">{receipt.details?.invoiceNumber}</span></div>
      <div className="receipt-row"><span className="receipt-label" style={{ color: profile.themeColor || '#388e3c' }}>{renderKey('dateLabel', 'Date:', 'தேதி:')}</span><span className="receipt-value">{new Date(receipt.details?.invoiceDate || new Date()).toLocaleDateString('en-IN')}</span></div>
      <div className="receipt-row"><span className="receipt-label" style={{ color: profile.themeColor || '#388e3c' }}>{renderKey('receivedFromLabel', 'Received From:', 'பெறப்பட்டது:')}</span><span className="receipt-value">
        {profile?.enableBilingual !== false && (receipt.client?.nameEn || receipt.client?.name_English) ? (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
            <span>{receipt.client?.peyar || receipt.client?.name}</span>
            <span style={{ fontSize: '0.6em', fontWeight: 500, opacity: 0.85, letterSpacing: '0.02em', marginTop: '-1px' }}>{receipt.client?.nameEn || receipt.client?.name_English}</span>
          </div>
        ) : (receipt.client?.peyar || receipt.client?.name)}
      </span></div>
      <div className="receipt-row"><span className="receipt-label" style={{ color: profile.themeColor || '#388e3c' }}>{renderKey('paymentModeLabel', 'Payment Mode:', 'செலுத்தும் முறை:')}</span><span className="receipt-value">{renderPaymentMode(receipt.invoiceOptions?.paymentMode || receipt.details?.paymentMode || 'Cash')}</span></div>
      {(receipt.invoiceOptions?.referenceNo || receipt.details?.referenceNo) && <div className="receipt-row"><span className="receipt-label" style={{ color: profile.themeColor || '#388e3c' }}>{renderKey('referenceNoLabel', 'Reference No:', 'குறிப்பு எண்:')}</span><span className="receipt-value">{receipt.invoiceOptions?.referenceNo || receipt.details?.referenceNo}</span></div>}
      {(receipt.invoiceOptions?.againstInvoice || receipt.details?.againstInvoice) && <div className="receipt-row"><span className="receipt-label" style={{ color: profile.themeColor || '#388e3c' }}>{renderKey('againstInvoiceLabel', 'Against Invoice:', 'விலைப்பட்டியலுக்கு எதிராக:')}</span><span className="receipt-value">{receipt.invoiceOptions?.againstInvoice || receipt.details?.againstInvoice}</span></div>}
      
      <div style={{ marginTop: 'auto', marginBottom: 'auto' }}>
        <div className="receipt-amount" style={{ color: profile.themeColor || '#388e3c', backgroundColor: profile.themeColor ? `${profile.themeColor}15` : '#e8f5e9' }}>{formatCurrency(receipt.totals?.total || 0, profileCurrency)}</div>
        <div className="receipt-words" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          {(() => {
            const words = numberToWords(receipt.totals?.total || 0, profile?.primaryDataLanguage || 'English', profile?.secondaryDataLanguage || 'English', profile?.enableBilingual !== false);
            if (words.includes(' / ')) {
              const [pStr, sStr] = words.split(' / ');
              return (
                <>
                  <span>{pStr}</span>
                  <span style={{ fontSize: '0.65em', fontWeight: 400, opacity: 0.85, letterSpacing: '0.02em', marginTop: '3px' }}>{sStr}</span>
                </>
              );
            }
            return words;
          })()}
        </div>
      </div>
      
      {receipt.customTerms && <p style={{ fontSize: '0.85rem', color: '#64748b' }}>{renderKey('noteLabel', 'Note:', 'குறிப்பு:')} {receipt.customTerms}</p>}
      
      <div className="receipt-footer">
        <div className="preview-footer-right">
          <div className="sign-company" style={{ color: profile.themeColor || '#388e3c', position: 'relative', zIndex: 10, fontSize: '1.05rem', fontWeight: 600 }}>
            {getDynamicField(profile, 'niruvanathinPeyar', profile, false) || getDynamicField(profile, 'niruvanathinPeyar', profile, true) || 'Your Business'}
          </div>
          <div className="sign-space" style={{ position: 'relative' }}>
            {profile?.signature && (
                <img src={profile.signature} alt="Signature" style={{ position: 'absolute', top: '50%', transform: 'translateY(-50%)', right: '-10px', maxHeight: '95px', maxWidth: '200px', objectFit: 'contain', pointerEvents: 'none' }} />
            )}
          </div>
          <div className="sign-label" style={{ position: 'relative', zIndex: 10 }}>{profile?.authorizedSignatoryName ? `(${profile.authorizedSignatoryName})` : getLangStr(profile?.primaryDataLanguage || 'Tamil', 'authorizedSignatory', '(Authorized Signatory)', '(கையொப்பம்)')}</div>
        </div>
      </div>

      {/* Contact Section */}
      <div className="rcpt-contact-section" style={{ background: profile.themeColor ? `${profile.themeColor}15` : '#e8f5e9' }}>
        <div className="rcpt-contact-title" style={{ color: profile.themeColor || '#388e3c' }}>{getLangStr(profile?.primaryDataLanguage || 'Tamil', 'contactUsLabel', 'Contact Us', 'தொடர்பு கொள்ள')}</div>
        <div className="rcpt-contact-row">
          <div className="rcpt-contact-left">
            <div className="rcpt-contact-address">
              <div style={{ marginBottom: '4px' }}>{addr1}</div>
              {addr2 && <div>{addr2}</div>}
            </div>
            {email && (
              <div className="rcpt-contact-email">
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '16px', color: profile.themeColor || '#388e3c', marginTop: '-2px' }}>
                  <IconMail size={14} />
                </div>
                <span>{email}</span>
              </div>
            )}
          </div>
          {phone.length > 0 && (
            <div className="rcpt-contact-phones" style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
              {phone.map((num, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '6px' }}>
                  <span>{num}</span>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '14px', color: profile.themeColor || '#388e3c', marginTop: '-2px' }}>
                    <IconPhone size={13} />
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

    </div>
  );
});

export default ReceiptTheme;
