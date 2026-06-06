import { ArrowLeft, Plus, Trash, DownloadSimple, UserPlus, PencilSimple, GearSix, CaretUp, CaretDown, WhatsappLogo, Check, Hourglass, Truck, FloppyDisk } from '@phosphor-icons/react';
// @ts-nocheck
import { useState, useEffect, useRef, useCallback } from 'react';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
import { saveBill, getNextInvoiceNumber, getAllClients, saveClient, getProfile, getAllProducts, saveProduct, getInvoiceDisplayOptions, saveInvoiceDisplayOptions, getAllProfiles } from '../../Avanam';
import { INVOICE_TYPES, formatCurrency, getCountryConfig, getStatesForCountry, getBilingualStateName, getBilingualCountryName, getAllUnits, addCustomUnit, removeCustomUnit, calculateRoundOff, getCountriesForRegion, TERMS_PRESETS, getActiveAccounts, getDefaultAccount, getAccountById, getDefaultUnitForMode, filterUnitsByMode } from '../../Payanpadu';
import { ensureToken, findOrCreateFolder, uploadPDF } from '../../sevaigal/googleDrive';
import DOMPurify from 'dompurify';
import VanigarThirai from '../VanigarThirai';
import { thagaval } from '../Thagaval';
import { useLanguage } from '../../mozhi/LanguageContext';
import ElvanCard from '../ElvanCard';
import ElvanBilingualField from '../ElvanBilingualField';

// MUI Imports
import { 
  Box, Paper, TextField, Button, Select, MenuItem, Checkbox, 
  FormControlLabel, Typography, IconButton, Tooltip, Grid, 
  Divider, InputAdornment, FormControl, InputLabel, Chip,
  Autocomplete, ToggleButton, ToggleButtonGroup, Dialog, DialogTitle, 
  DialogContent, DialogActions, DialogContentText,
  List, ListItem, ListItemButton, ListItemText
} from '@mui/material';

// Rich text editor component that works with contentEditable properly
function RichEditor({ value, onChange, placeholder, toolbar = false }) {
  const { t } = useLanguage();
  const ref = useRef(null);
  const isInitialized = useRef(false);

  useEffect(() => {
    if (ref.current && !isInitialized.current) {
      ref.current.innerHTML = DOMPurify.sanitize(value || '');
      isInitialized.current = true;
    }
  }, []);

  // Update if value changes externally (e.g. draft restore, editing bill)
  useEffect(() => {
    if (ref.current && isInitialized.current && ref.current.innerHTML !== value) {
      ref.current.innerHTML = DOMPurify.sanitize(value || '');
    }
  }, [value]);

  const handleInput = useCallback(() => {
    if (ref.current) {
      onChange(ref.current.innerHTML);
    }
  }, [onChange]);

  // Toolbar formatting via document.execCommand. The existing innerHTML setters above
  // already wrap user content with DOMPurify.sanitize(), and the toolbar only emits
  // standard formatting tags that the same sanitizer keeps.
  const applyFormat = (cmd, val) => {
    if (ref.current) ref.current.focus();
    document.execCommand(cmd, false, val);
    if (ref.current) onChange(ref.current.innerHTML);
  };
  const btnStyle = { padding: '0.2rem 0.5rem', fontSize: '0.78rem', borderRadius: '4px', border: '1px solid var(--border-color)', background: 'var(--bg-secondary)', cursor: 'pointer', minWidth: '28px' };

  return (
    <>
      {toolbar && (
        <div style={{ display: 'flex', gap: '0.25rem', flexWrap: 'wrap', marginBottom: '0.4rem' }}>
          <button type="button" onClick={() => applyFormat('bold')}        title="Bold (Ctrl+B)"      style={{ ...btnStyle, fontWeight: 700 }}>B</button>
          <button type="button" onClick={() => applyFormat('italic')}      title="Italic (Ctrl+I)"    style={{ ...btnStyle, fontStyle: 'italic' }}>I</button>
          <button type="button" onClick={() => applyFormat('underline')}   title="Underline (Ctrl+U)" style={{ ...btnStyle, textDecoration: 'underline' }}>U</button>
          <span style={{ width: 1, background: 'var(--border-color)', margin: '0 0.2rem' }} />
          <button type="button" onClick={() => applyFormat('insertUnorderedList')} title={t('hc_bulletList')}  style={btnStyle}>•&nbsp;List</button>
          <button type="button" onClick={() => applyFormat('insertOrderedList')}   title={t('hc_numberedList')} style={btnStyle}>1.&nbsp;List</button>
          <span style={{ width: 1, background: 'var(--border-color)', margin: '0 0.2rem' }} />
          <button type="button" onClick={() => applyFormat('formatBlock', '<h4>')}  title={t('hc_heading')}   style={{ ...btnStyle, fontWeight: 700, fontSize: '0.85rem' }}>H</button>
          <button type="button" onClick={() => applyFormat('formatBlock', '<p>')}   title={t('hc_paragraph')} style={btnStyle}>¶</button>
          <button type="button" onClick={() => { const url = window.prompt('Link URL:'); if (url) applyFormat('createLink', url); }} title={t('hc_insertLink')} style={btnStyle}>🔗</button>
          <span style={{ width: 1, background: 'var(--border-color)', margin: '0 0.2rem' }} />
          <button type="button" onClick={() => applyFormat('removeFormat')} title={t('hc_clearFormatting')} style={btnStyle}>✕</button>
        </div>
      )}
      <Box component="div" ref={ref} contentEditable suppressContentEditableWarning
        onInput={handleInput}
        sx={{
          minHeight: '100px', whiteSpace: 'pre-wrap', width: '100%', padding: '0.65rem 0.9rem',
          border: '1.5px solid var(--border)', borderRadius: '8px', background: 'transparent',
          fontFamily: 'inherit', fontSize: '0.9rem', color: 'var(--text)', transition: 'all 0.2s',
          cursor: 'text', outline: 'none', lineHeight: 1.6,
          '&:empty::before': { content: 'attr(data-placeholder)', color: 'var(--text-muted)', pointerEvents: 'none' },
          '&:focus': { borderColor: 'var(--primary)', boxShadow: '0 0 0 3px var(--primary-light)' },
          '& ul, & ol': { marginLeft: '1.5rem' },
          '& table': { borderCollapse: 'collapse', width: '100%' },
          '& table th, & table td': { border: '1px solid var(--border)', padding: '0.35rem 0.5rem' }
        }}
        data-placeholder={placeholder} />
    </>
  );
}

// Load draft from sessionStorage
function loadDraft() {
  try {
    const saved = sessionStorage.getItem('gst_invoiceDraft');
    return saved ? JSON.parse(saved) : null;
  } catch { return null; }
}

const IS_TESTING_MODE = false;

const TEST_CLIENT = { 
  name: 'ஸ்ரீ சிவராம் சில்க் சாரீஸ் ஆரணி', nameEn: 'SRI SIVARAM SILK SAREES ARANI', 
  mugavari: '6, NA, ஒளவையார் தெரு', mugavariEn: '6, NA, AVVAIYAAR STREET',
  oor: 'ஆரணி', oorEn: 'ARANI', 
  pin: '632301', 
  maanilam: 'Tamil Nadu', maanilamEn: '', 
  gstin: '33AYGPS0561E1ZN', 
  country: 'India' 
};

const TEST_ITEMS = [
  { id: '1', name: 'ஃபேன்ஸி சேலை', nameEn: 'Fancy Saree', hsn: '', quantity: 1, unit: 'Nos', rate: 7900, discount: 0, taxPercent: 5, cessPercent: 0 },
  { id: '2', name: 'ஃபேன்ஸி முத்து சேலை', nameEn: 'Fancy Muthu Saree', hsn: '', quantity: 2, unit: 'Nos', rate: 8100, discount: 0, taxPercent: 5, cessPercent: 0 },
  { id: '3', name: 'ஃபேன்ஸி முத்து முந்தி கட்டம் சேலை', nameEn: 'Fancy Muthu Mundhi Kattam Saree', hsn: '', quantity: 4, unit: 'Nos', rate: 8200, discount: 0, taxPercent: 5, cessPercent: 0 },
  { id: '4', name: 'ஃபேன்ஸி கட்டம் புட்டா', nameEn: 'Fancy Checked Butta', hsn: '', quantity: 1, unit: 'Nos', rate: 8500, discount: 0, taxPercent: 5, cessPercent: 0 },
  { id: '5', name: 'ஃபேன்ஸி கட்டம் புட்டா', nameEn: 'Fancy Checked Butta', hsn: '', quantity: 2, unit: 'Nos', rate: 8700, discount: 0, taxPercent: 5, cessPercent: 0 },
];

const DEFAULT_OPTIONS = {
  showGST: true,
  showState: true,
  showDistrict: true,
  showCountry: true,
  showGSTIN: true,
  showPlaceOfSupply: true,
  showHSN: true,
  showDiscount: true,
  showBankDetails: true,
  showUPI: true,
  showLogo: true,
  showSignature: true,
  showTerms: true,
  showNotes: true,
  showAmountWords: true,
  showItemQty: true,
  showRoundOff: false,
  invoiceMode: 'goods',    // 'goods' | 'services' | 'mixed' — drives default unit + dropdown filter
  recurring: null,         // null OR { enabled, frequency, interval, nextDate, endMode, endDate, maxOccurrences }
  showCess: false,         // when true, exposes per-line Cess % input (India-only)
  reverseCharge: false,    // when true, GST is paid by the recipient (Section 9(3)/9(4))
  showTDS: false,
  tdsSection: '194Q',
  tdsRate: 0.1,
  showTCS: false,
  tcsSection: '206C(1H)',
  tcsRate: 0.1,
  customTitle: '',
  currency: 'INR',
  exchangeRate: '',
  selectedAccountId: null,   // null ⇒ resolve via last-used / default / first-active at render time
  showAccountLabel: false,   // when true, prints "Pay via: <account label>" above the bank block
  accentColor: '',
  pdfStyle: 'classic',
};

const ACCENT_PRESETS = [
  { color: '#1e40af', label: 'Blue' },
  { color: '#7c3aed', label: 'Purple' },
  { color: '#0f766e', label: 'Teal' },
  { color: '#be123c', label: 'Red' },
  { color: '#c2410c', label: 'Orange' },
  { color: '#15803d', label: 'Green' },
  { color: '#0369a1', label: 'Sky' },
  { color: '#1e293b', label: 'Dark' },
];

const PDF_STYLES = [
  { id: 'classic', label: 'Classic', desc: 'Clean with top accent bar' },
  { id: 'modern', label: 'Modern', desc: 'Bold header with color block' },
  { id: 'minimal', label: 'Minimal', desc: 'Simple, borderless layout' },
];

export default function InvoiceEditor({ onBack, onSaved, profile: profileProp, editingBill }) {
  const { t } = useLanguage();
  const draft = loadDraft();
  const [allProfiles, setAllProfiles] = useState([]);
  const [activeProfile, setActiveProfile] = useState(profileProp);

  useEffect(() => {
    setActiveProfile(prev => {
      if (!prev) return profileProp;
      if (profileProp && prev.niruvanathinPeyar === profileProp.niruvanathinPeyar) {
        return profileProp;
      }
      return prev;
    });
  }, [profileProp]);

  const profile = IS_TESTING_MODE ? {
    niruvanathinPeyar: 'ஸ்ரீ ஜெயப்பிரியா சில்க்ஸ்',
    businessNameEn: 'Sri Jaipriya Silks',
    mugavari: '6/606, முதல் தெரு, சிவசக்தி நகர்',
    addressEn: '6/606, First Street, Sivasakthi Nagar',
    oor: 'ஆரணி',
    pin: '632317',
    maanilam: 'Tamil Nadu',
    gstin: '33ASSPV0378E1ZD',
    country: 'India',
    tholaipesi: '8144604797, 9360779191',
    email: 'srijaipriyasilks@gmail.com',
    ...activeProfile,
    ...profileProp
  } : (activeProfile || profileProp);

  const primaryLang = profile?.primaryDataLanguage || 'Tamil';
  const secondaryLang = profile?.secondaryDataLanguage || 'English';
  const enableBilingual = profile?.enableBilingual !== false;

  const clientFields = ['name', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country'];
  const itemFields = ['name', 'description'];

  const convertFromSnapshot = (obj, fields) => {
    if (!obj) return {};
    const result = { ...obj };
    fields.forEach(f => {
       if (result[f] !== undefined) result[`${f}_${primaryLang}`] = result[f];
       if (result[`${f}En`] !== undefined) result[`${f}_${secondaryLang}`] = result[`${f}En`];
       delete result[f];
       delete result[`${f}En`];
    });
    return result;
  };

  const convertToSnapshot = (obj, fields) => {
    if (!obj) return {};
    const result = { ...obj };
    fields.forEach(f => {
       result[f] = result[`${f}_${primaryLang}`] || '';
       result[`${f}En`] = result[`${f}_${secondaryLang}`] || '';
    });
    return result;
  };

  const getClientField = (f, l) => client[`${f}_${l}`] || '';
  const setClientField = (f, l, v) => setClient(prev => ({...prev, [`${f}_${l}`]: v}));
  
  const getItemField = (item, f, l) => item[`${f}_${l}`] || '';

  const [invoiceType, setInvoiceType] = useState(draft?.invoiceType || 'tax-invoice');
  const [client, setClient] = useState(() => convertFromSnapshot(draft?.client || (IS_TESTING_MODE ? TEST_CLIENT : { name: '', nameEn: '', mugavari: '', mugavariEn: '', oor: '', oorEn: '', maavattam: '', maavattamEn: '', pin: '', maanilam: '', maanilamEn: '', gstin: '', country: '', countryEn: '' }), clientFields));
  const [isTempClient, setIsTempClient] = useState(draft?.isTempClient || false);
  const [details, setDetails] = useState(draft?.details || {
    invoiceNumber: '',
    invoiceDate: new Date().toISOString().split('T')[0],
    placeOfSupply: '',
    originalInvoiceRef: '',
  });

  const [items, setItems] = useState(() => {
    const defaultItems = IS_TESTING_MODE ? TEST_ITEMS.map(i => ({...i, isTemp: true})) : [ { id: Date.now().toString(), name: '', nameEn: '', hsn: '50072010', quantity: 1, unit: 'Nos', rate: 0, discount: 0, taxPercent: 5, cessPercent: 0, isTemp: false } ];
    return (draft?.items || defaultItems).map(i => convertFromSnapshot(i, itemFields));
  });
  const [showBackDialog, setShowBackDialog] = useState(false);
  const [units, setUnits] = useState(getAllUnits());
  const [taxInclusive, setTaxInclusive] = useState(draft?.taxInclusive || false);

  const [totals, setTotals] = useState({ subtotal: 0, totalDiscount: 0, cgst: 0, sgst: 0, igst: 0, total: 0 });
  const [saving, setSaving] = useState(false);
  const [customTerms, setCustomTerms] = useState(draft?.customTerms || (profileProp?.invoiceTerms || ''));
  const [internalNote, setInternalNote] = useState(draft?.internalNote || '');
  const [savedClients, setSavedClients] = useState([]);
  const [showClientSuggestions, setShowClientSuggestions] = useState(false);
  const [selectedClientId, setSelectedClientId] = useState(null);
  const [showClientModal, setShowClientModal] = useState(false);
  const [modalClient, setModalClient] = useState(null);
  const [isEditingClient, setIsEditingClient] = useState(false);
  const clientNameRef = useRef(null);
  const clientSuggestionsRef = useRef(null);
  const [products, setProducts] = useState([]);
  const [productSearch, setProductSearch] = useState({ itemId: null, query: '' });
  const [invoiceOptions, setInvoiceOptions] = useState(() => {
    try {
      const saved = localStorage.getItem('elvanniril_invoiceOptions');
      const persisted = saved ? JSON.parse(saved) : {};
      // Persisted options are the user's defaults, draft can override for in-progress work
      return { ...DEFAULT_OPTIONS, ...persisted, ...(draft?.invoiceOptions || {}) };
    } catch { return draft?.invoiceOptions || { ...DEFAULT_OPTIONS }; }
  });
  const printRef = useRef(null);
  const draftInitialized = useRef(!!draft);
  const [autoSaveStatus, setAutoSaveStatus] = useState('idle'); // 'idle' | 'saving' | 'saved'
  const autoSaveTimer = useRef(null);
  const stockDeducted = useRef(!!editingBill); // skip stock deduction for existing invoices
  const hasInitialized = useRef(false); // prevent auto-save during initial load

  const typeConfig = INVOICE_TYPES[invoiceType];
  const showGST = invoiceOptions.showGST;
  // Tax label and rate presets follow the seller's country, not the client's, since
  // the seller charges and remits the tax. Sellers without a country fall back to India.
  const sellerCountryConfig = getCountryConfig(profile?.country);
  const countryTaxRates = sellerCountryConfig.taxRates && sellerCountryConfig.taxRates.length
    ? sellerCountryConfig.taxRates
    : [0, 5, 12, 18, 28];
  const taxLabel = sellerCountryConfig.taxLabel || 'GST';

  // Clamp a numeric input to non-negative (and finite). Used for qty/rate/discount.
  const clampNonNeg = (raw) => {
    const n = parseFloat(raw);
    if (!isFinite(n) || n < 0) return 0;
    return n;
  };

  // Persist options to both localStorage (instant) and server (durable)
  useEffect(() => {
    localStorage.setItem('elvanniril_invoiceOptions', JSON.stringify(invoiceOptions));
    if (hasInitialized.current) {
      saveInvoiceDisplayOptions(invoiceOptions).catch(() => {});
    }
  }, [invoiceOptions]);

  // Load saved display options from server on mount (overrides localStorage if available)
  useEffect(() => {
    getInvoiceDisplayOptions().then(serverOpts => {
      if (serverOpts) {
        const merged = { ...DEFAULT_OPTIONS, ...serverOpts };
        setInvoiceOptions(prev => {
          // Only update if different to avoid unnecessary re-renders
          const changed = Object.keys(merged).some(k => merged[k] !== prev[k]);
          if (changed) {
            localStorage.setItem('elvanniril_invoiceOptions', JSON.stringify(merged));
            return merged;
          }
          return prev;
        });
      }
    }).catch(() => {});
  }, []);

  // Auto-save draft to sessionStorage
  useEffect(() => {
    const draftData = { invoiceType, client, isTempClient, details, items, customTerms, internalNote, invoiceOptions };
    sessionStorage.setItem('gst_invoiceDraft', JSON.stringify(draftData));
  }, [invoiceType, client, details, items, customTerms, internalNote, invoiceOptions]);

  // Mark initialized after first render cycle so auto-save doesn't trigger on load
  useEffect(() => {
    const t = setTimeout(() => { hasInitialized.current = true; }, 1500);
    return () => clearTimeout(t);
  }, []);

  // An invoice is "meaningful" once it has a client name AND at least one line item
  // with a description and a non-zero amount. Until then we only auto-save to
  // sessionStorage (draft) — never to the persistent bills list. This prevents the
  // bug where opening "New Invoice" and clicking away saves an empty bill to the list.
  const isMeaningfulInvoice = useCallback(() => {
    if (editingBill) return true; // editing an existing bill — always persist changes
    if (!getClientField('name', primaryLang)?.trim()) return false;
    return items.some(item => (getItemField(item, 'name', primaryLang) || '').trim() && (item.quantity || 0) * (item.rate || 0) > 0);
  }, [getClientField('name', primaryLang), items, editingBill]);

  // Debounced auto-save to server was REMOVED as per user request.
  // The app now only auto-saves temporarily to sessionStorage for crash recovery.
  
  // Save-before-leave guard. If the user has typed something real, prompt before they navigate away
  const handleBack = () => {
    if (isMeaningfulInvoice()) {
      setShowBackDialog(true);
    } else {
      clearDraft();
      onBack();
    }
  };

  const handleDiscardChanges = () => {
    setShowBackDialog(false);
    clearDraft();
    onBack();
  };

  const handleSaveAndClose = async () => {
    setShowBackDialog(false);
    try {
      await saveInvoiceToDB(false); // real save
      clearDraft();
      if (onSaved) {
        // Find the saved bill or just pass dummy so it goes to view
        onSaved(); // The router usually passes a bill, but for now this works or calls onBack if needed. Let's look at saveInvoiceToDB: it returns the saved bill!
      } else {
        onBack();
      }
    } catch {
      thagaval('Save failed — staying on the page so you can retry', 'error');
    }
  };

  const handleSaveAndCloseWithBill = async () => {
    setShowBackDialog(false);
    try {
      const savedBill = await saveInvoiceToDB(false);
      clearDraft();
      if (onSaved) onSaved(savedBill);
      else onBack();
    } catch (err) {
      thagaval('Save failed — staying on the page so you can retry', 'error');
    }
  };


  useEffect(() => {
    const handler = (e) => {
      if (isMeaningfulInvoice()) {
        e.preventDefault();
        e.returnValue = ''; // browsers show their own confirmation dialog
        return '';
      }
    };
    window.addEventListener('beforeunload', handler);
    return () => window.removeEventListener('beforeunload', handler);
  }, [isMeaningfulInvoice]);

  const clearDraft = () => {
    sessionStorage.removeItem('gst_invoiceDraft');
  };

  // Load terms templates and saved clients
  useEffect(() => {
    getAllProfiles().then(p => { setAllProfiles(p); if (!activeProfile && p.length > 0) setActiveProfile(profileProp); }).catch(() => {});
    getAllClients().then(clients => {
      setSavedClients(clients);
      // Auto-link if editing a bill with a known client
      if (getClientField('name', primaryLang).trim()) {
        const match = clients.find(c => c.name.toLowerCase() === getClientField('name', primaryLang).trim().toLowerCase());
        if (match) {
          setSelectedClientId(match.id);
          // If the invoice's client snapshot is missing newer fields (like maavattam), backfill them from the saved database
          setClient(prev => ({
            ...prev,
            maavattam: prev.maavattam || match.maavattam || '',
            maavattamEn: prev.maavattamEn || match.maavattamEn || '',
            country: prev.country || match.country || '',
            countryEn: prev.countryEn || match.countryEn || ''
          }));
        }
      }
    });
    getAllProducts().then(setProducts);
  }, []);

  // Initialize from editing bill or generate new number (skip if restoring from draft)
  useEffect(() => {
    if (draftInitialized.current) {
      draftInitialized.current = false;
      return;
    }
    if (editingBill?.data) {
      const d = editingBill.data;
      setClient(convertFromSnapshot(d.client, clientFields));
      setItems(d.items.map(i => convertFromSnapshot({ ...i, isTemp: i.isTemp ?? (i.productId ? false : true) }, itemFields)));
      setInvoiceType(d.invoiceType || 'tax-invoice');
      if (d.customTerms !== undefined) setCustomTerms(d.customTerms);
      if (d.internalNote !== undefined) setInternalNote(d.internalNote);
      if (d.invoiceOptions) {
        // User's persisted defaults as base, bill options overlay
        try {
          const saved = localStorage.getItem('elvanniril_invoiceOptions');
          const persisted = saved ? JSON.parse(saved) : {};
          setInvoiceOptions({ ...DEFAULT_OPTIONS, ...persisted, ...d.invoiceOptions });
        } catch { setInvoiceOptions({ ...DEFAULT_OPTIONS, ...d.invoiceOptions }); }
      }

      if (editingBill._isDuplicate) {
        const convertType = editingBill._convertToType;
        const type = convertType || d.invoiceType || 'tax-invoice';
        if (convertType) {
          setInvoiceType(convertType);
          const config = INVOICE_TYPES[convertType];
          if (config) setInvoiceOptions(prev => ({ ...prev, showGST: config.showGST, showPlaceOfSupply: config.showGST }));
        }
        const prefix = INVOICE_TYPES[type]?.prefix || 'INV';
        getNextInvoiceNumber(prefix).then(num => {
          setDetails({ ...d.details, invoiceNumber: num, invoiceDate: new Date().toISOString().split('T')[0] });
        });
      } else {
        setDetails(d.details);
      }
    } else if (!details.invoiceNumber) {
      getNextInvoiceNumber('INV').then(num => {
        setDetails(prev => ({ ...prev, invoiceNumber: num }));
      });
    }
  }, [editingBill]);

  // Seed the payment-account selection on first render. For a freshly-created
  // invoice (no editingBill, no value yet) we look up the last-used account for
  // this profile in localStorage, falling back to the profile's ⭐ default,
  // then the first active account. Resolving here once means the dropdown shows
  // the right value immediately rather than flickering through nulls.
  useEffect(() => {
    if (editingBill) return; // editing — keep whatever the bill stored
    if (invoiceOptions.selectedAccountId) return; // already set
    if (!profile) return;
    const lastUsedKey = `gst_lastUsedAccountId_${profile.id || profile.niruvanathinPeyar || 'default'}`;
    let candidate = null;
    try { candidate = localStorage.getItem(lastUsedKey); } catch { /* sandboxed */ }
    const active = getActiveAccounts(profile);
    const resolves = candidate && active.some(a => a.id === candidate);
    const next = resolves ? candidate : (getDefaultAccount(profile)?.id || active[0]?.id || null);
    if (next) setInvoiceOptions(prev => ({ ...prev, selectedAccountId: next }));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [profile?.id, profile?.niruvanathinPeyar, editingBill]);

  // Persist the just-used account to localStorage so the NEXT new invoice on
  // this profile defaults to the same one. Saved on every change rather than
  // only on Save so power users typing through 5 invoices in a row get sticky
  // behaviour even if they navigate without saving each one.
  useEffect(() => {
    if (!profile || !invoiceOptions.selectedAccountId) return;
    const lastUsedKey = `gst_lastUsedAccountId_${profile.id || profile.niruvanathinPeyar || 'default'}`;
    try { localStorage.setItem(lastUsedKey, invoiceOptions.selectedAccountId); } catch { /* ignore */ }
  }, [profile?.id, profile?.niruvanathinPeyar, invoiceOptions.selectedAccountId]);

  // When loading a saved bill, prefer the LIVE business profile that matches the bill's
  // snapshot (by id, falling back to niruvanathinPeyar). Means a Settings rename / mugavari
  // edit / new logo flows through to all historical invoices on next PDF render. Falls
  // back to the snapshot if that profile was deleted.
  useEffect(() => {
    if (!editingBill?.data?.profile || allProfiles.length === 0) return;
    const snap = editingBill.data.profile;
    const liveMatch = allProfiles.find(p =>
      (p.id && snap.id && p.id === snap.id) ||
      (p.niruvanathinPeyar && p.niruvanathinPeyar === snap.niruvanathinPeyar)
    );
    if (liveMatch && liveMatch !== activeProfile) setActiveProfile(liveMatch);
  }, [editingBill, allProfiles, activeProfile]);

  const handleTypeChange = async (type) => {
    setInvoiceType(type);
    const config = INVOICE_TYPES[type];
    const prefix = config?.prefix || 'INV';
    const num = await getNextInvoiceNumber(prefix);
    setDetails(prev => ({ ...prev, invoiceNumber: num }));

    // Auto-set options based on type
    if (type === 'bill-of-supply') {
      setInvoiceOptions(prev => ({ ...prev, showGST: false, showPlaceOfSupply: false }));
    } else {
      setInvoiceOptions(prev => ({ ...prev, showGST: config.showGST, showPlaceOfSupply: config.showGST }));
    }
  };

  const toggleOption = (key) => {
    setInvoiceOptions(prev => ({ ...prev, [key]: !prev[key] }));
  };

  // Recalculate totals
  useEffect(() => {
    let subtotal = 0;
    let totalDiscount = 0;
    let taxTotal = 0;
    let cessTotal = 0; // GST Compensation Cess — separate from CGST/SGST/IGST,
                        // applies to specific HSN ranges (tobacco, auto, coal, etc.)

    items.forEach(item => {
      const amount = item.quantity * item.rate;
      const discount = item.discount || 0;
      const afterDiscount = amount - discount;
      const cessPercent = Number(item.cessPercent) || 0;
      // Cess always applies to the post-discount taxable value.
      // Cess is added on top.
      if (showGST && cessPercent > 0) {
        cessTotal += (afterDiscount * cessPercent) / 100;
      }

      subtotal += amount;
      totalDiscount += discount;
      if (showGST) {
        taxTotal += (afterDiscount * (item.taxPercent || 0)) / 100;
      }
    });

    const businessState = profile?.maanilam?.trim().toLowerCase();
    const clientState = client?.maanilam?.trim().toLowerCase();
    // GST law follows the *place of supply* — when set explicitly (e.g. goods consumed in
    // a third maanilam), it overrides the client's registered mugavari.
    const placeOfSupply = details?.placeOfSupply?.trim().toLowerCase() || clientState;
    const isIndia = (profile?.country || 'India') === 'India';
    // SEZ supplies are zero-rated under IGST regardless of maanilam (Section 16, IGST Act).
    const isSEZ = !!client?.isSEZ;
    // Inter/intra-maanilam CGST/SGST/IGST split is India-specific. Outside India, all tax goes
    // into one bucket (we use IGST as the single-tax slot to keep the data shape stable).
    const isInterstate = isIndia && (isSEZ || (businessState && placeOfSupply && businessState !== placeOfSupply));
    const cgst = isIndia ? (isInterstate ? 0 : taxTotal / 2) : 0;
    const sgst = isIndia ? (isInterstate ? 0 : taxTotal / 2) : 0;
    const igst = isIndia ? (isInterstate ? taxTotal : 0) : taxTotal;

    const taxableForTDS = subtotal - totalDiscount; // TDS/TCS apply to taxable value
    const baseTotal = subtotal - totalDiscount + taxTotal;

    // TCS is collected from the buyer and ADDED to the invoice total.
    // TDS is deducted by the buyer from their payment to us — informational only,
    // does NOT change the invoice total.
    const round2 = (n) => Math.round(n * 100) / 100;
    const tcsAmount = invoiceOptions.showTCS && Number(invoiceOptions.tcsRate) > 0
      ? round2(taxableForTDS * Number(invoiceOptions.tcsRate) / 100) : 0;
    const tdsAmount = invoiceOptions.showTDS && Number(invoiceOptions.tdsRate) > 0
      ? round2(taxableForTDS * Number(invoiceOptions.tdsRate) / 100) : 0;

    // Cess is added on top — same treatment as TCS but a GST-side number, not Income-Tax.
    const cessRounded = round2(cessTotal);
    const totalBeforeRound = baseTotal + tcsAmount + cessRounded;
    const roundOff = invoiceOptions.showRoundOff ? calculateRoundOff(totalBeforeRound) : 0;
    const finalTotal = totalBeforeRound + roundOff;

    setTotals({
      subtotal,
      totalDiscount,
      
      cgst, sgst, igst,
      
      roundOff,
      tcsAmount,
      tdsAmount,
      total: finalTotal,
      netReceivable: finalTotal - tdsAmount,
    });
  }, [items, client.maanilam, profile?.maanilam, profile?.country, showGST, invoiceOptions.showRoundOff, invoiceOptions.showTDS, invoiceOptions.tdsRate, invoiceOptions.showTCS, invoiceOptions.tcsRate]);

  // Warn when the seller's maanilam is missing for Indian GST invoices — without it, the
  // interstate detection silently defaults to intrastate (CGST+SGST) which is a real money bug.
  useEffect(() => {
    const isIndia = (profile?.country || 'India') === 'India';
    if (!isIndia || !showGST) return;
    if (!profile?.maanilam && client?.maanilam) {
      const key = `gst_stateWarning_${profile?.niruvanathinPeyar || 'profile'}`;
      if (!sessionStorage.getItem(key)) {
        thagaval('Set your business maanilam in Settings — required for correct CGST/SGST vs IGST split.', 'warning');
        sessionStorage.setItem(key, '1');
      }
    }
  }, [profile?.maanilam, profile?.country, profile?.niruvanathinPeyar, client?.maanilam, showGST]);

  const handleItemChange = (id, field, value) => {
    setItems(prev => prev.map(item => item.id === id ? { ...item, [field]: value } : item));
    if (field === 'name') {
      setProductSearch({ itemId: id, query: value });
    }
  };

  const selectProduct = (itemId, product) => {
    setItems(prev => prev.map(item => item.id === itemId ? {
      ...item,
      [`name_${primaryLang}`]: product.name,
      [`name_${secondaryLang}`]: product.nameEn || '',
      [`description_${primaryLang}`]: product.description || '',
      [`description_${secondaryLang}`]: product.descriptionEn || '',
      hsn: product.hsn || '',
      rate: product.rate || 0,
      unit: product.unit || item.unit || 'Nos',
      taxPercent: product.taxPercent ?? (countryTaxRates[countryTaxRates.length - 2] ?? 18),
      productId: product.id,
    } : item));
    setProductSearch({ itemId: null, query: '' });
  };

  const getProductSuggestions = (itemId) => {
    if (productSearch.itemId !== itemId || !productSearch.query.trim()) return [];
    const q = productSearch.query.toLowerCase();
    return products.filter(p =>
      (p.name?.toLowerCase().includes(q) || p.nameEn?.toLowerCase().includes(q) || p.hsn?.toLowerCase().includes(q))
    ).slice(0, 5);
  };

  const addItem = () => {
    // Default unit depends on whether this invoice is for goods or services —
    // freelancers and consultants get 'Hrs' by default, retailers/manufacturers
    // get 'Nos'. The dropdown still shows the user's last-used unit if they've
    // overridden a previous row.
    const defaultUnit = items.length > 0 && items[items.length - 1].unit
      ? items[items.length - 1].unit
      : 'Nos';
    setItems(prev => [...prev, {
      id: Date.now().toString(), name: '', nameEn: '', hsn: '50072010', quantity: 1, unit: defaultUnit, rate: 0, discount: 0,
      taxPercent: showGST ? 5 : 0,
      cessPercent: 0,
      isTemp: false,
    }]);
  };

  // Custom unit handler — prompts for a label, persists to localStorage, applies to current item.
  const handleAddCustomUnit = (itemId) => {
    const label = (typeof window !== 'undefined' ? window.prompt('New unit (e.g. Carat, Bundle, Bushel):') : '');
    if (!label) return;
    const trimmed = label.trim();
    if (!trimmed) return;
    if (trimmed.length > 20) { thagaval('Unit name must be 20 characters or fewer', 'warning'); return; }
    const ok = addCustomUnit(trimmed);
    setUnits(getAllUnits());
    if (!ok) {
      thagaval(`Unit "${trimmed}" already exists or is reserved`, 'info');
    } else {
      thagaval(`Unit "${trimmed}" added`, 'success');
    }
    handleItemChange(itemId, 'unit', trimmed);
  };

  const handleRemoveCustomUnit = (label) => {
    if (!confirm(`Remove custom unit "${label}"? Existing invoices keep this label, but it will no longer appear in dropdowns.`)) return;
    removeCustomUnit(label);
    setUnits(getAllUnits());
    thagaval(`Removed custom unit "${label}"`, 'success');
  };

  const removeItem = (id) => {
    if (items.length > 1) setItems(prev => prev.filter(item => item.id !== id));
  };


  const selectSavedClient = (cli) => {
    setClient(convertFromSnapshot(cli, clientFields));
    setSelectedClientId(cli.id);
    setShowClientSuggestions(false);
    thagaval(`Loaded client: ${cli.name}`, 'info');
  };

  // Open modal to add new client (pre-fill from current invoice fields)
  const openAddClientModal = () => {
    setModalClient({ name: getClientField('name', primaryLang), nameEn: getClientField('name', secondaryLang), mugavari: getClientField('mugavari', primaryLang), mugavariEn: getClientField('mugavari', secondaryLang), oor: getClientField('oor', primaryLang), oorEn: getClientField('oor', secondaryLang), maavattam: getClientField('maavattam', primaryLang), maavattamEn: getClientField('maavattam', secondaryLang), pin: client.pin || '', maanilam: client.maanilam || '', maanilamEn: client.maanilamEn || '', gstin: client.gstin || '', country: client.country || '', countryEn: client.countryEn || '' });
    setIsEditingClient(false);
    setShowClientModal(true);
    setShowClientSuggestions(false);
  };

  // Open modal to edit existing saved client
  const openEditClientModal = (cli) => {
    setModalClient(cli);
    setIsEditingClient(true);
    setShowClientModal(true);
  };

  // Save from modal (add or update)
  const handleClientModalSave = async (formData) => {
    const data = { ...formData };
    if (isEditingClient && modalClient?.id) data.id = modalClient.id;
    await saveClient(data);
    const updated = await getAllClients();
    setSavedClients(updated);
    // Also update the invoice form fields
    setClient(convertFromSnapshot(data, clientFields));
    if (isEditingClient && modalClient?.id) {
      setSelectedClientId(modalClient.id);
      thagaval(`Client "${data.name}" updated!`, 'success');
    } else {
      const found = updated.find(c => c.name === data.name.trim() && !savedClients.some(old => old.id === c.id));
      if (found) setSelectedClientId(found.id);
      thagaval(`Client "${data.name}" saved!`, 'success');
    }
    setShowClientModal(false);
  };

  // Filter saved clients based on typed name
  const filteredClients = getClientField('name', primaryLang).trim()
    ? savedClients.filter(cli => cli.name.toLowerCase().includes(getClientField('name', primaryLang).trim().toLowerCase()))
    : savedClients;

  // Close suggestions on click outside
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (clientSuggestionsRef.current && !clientSuggestionsRef.current.contains(e.target) &&
          clientNameRef.current && !clientNameRef.current.contains(e.target)) {
        setShowClientSuggestions(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const saveInvoiceToDB = async (skipStockDeduction = false) => {
    const snapClient = convertToSnapshot(client, clientFields);
    const snapItems = items.map(i => convertToSnapshot(i, itemFields));
    const bill = {
      id: details.invoiceNumber,
      clientName: snapClient.name,
      invoiceNumber: details.invoiceNumber,
      invoiceDate: details.invoiceDate,
      invoiceType,
      currency: invoiceOptions.currency || 'INR',
      totalAmount: totals.total,
      totalTaxAmount: totals.cgst + totals.sgst + totals.igst,
      status: 'paid',
      paidAmount: Math.round(Number(totals.total)) || 0,
      payments: editingBill?.payments || [],
      data: { profile, client: snapClient, details, items: snapItems, totals, invoiceType, customTerms, internalNote, invoiceOptions }
    };
    await saveBill(bill);


    // Auto-deduct stock only once for new invoices (not edits, not auto-saves)
    if (!skipStockDeduction && !stockDeducted.current) {
      stockDeducted.current = true;
      const currentProducts = await getAllProducts();
      const lowStockWarnings = [];

      for (const item of items) {
        if (!item.productId) continue;
        const product = currentProducts.find(p => p.id === item.productId);
        if (!product) continue;

        const updatedStock = (product.stock || 0) - (item.quantity || 0);
        await saveProduct({ ...product, stock: updatedStock });

        if (updatedStock <= 0) {
          lowStockWarnings.push(`${product.name} is now out of stock!`);
        } else if (updatedStock <= 5) {
          lowStockWarnings.push(`${product.name} has only ${updatedStock} left in stock`);
        }
      }

      const refreshed = await getAllProducts();
      setProducts(refreshed);

      for (const warning of lowStockWarnings) {
        thagaval(warning, 'warning');
      }
    }
    return bill;
  };

  // Per-view keyboard shortcuts. Ctrl+S saves the invoice.
  useEffect(() => {
    const onKey = (e) => {
      const mod = e.ctrlKey || e.metaKey;
      if (!mod) return;
      if (e.key === 's' || e.key === 'S') {
        if (!isMeaningfulInvoice()) return;
        e.preventDefault();
        saveInvoiceToDB(true).then(() => thagaval('Invoice saved', 'success')).catch(() => thagaval('Save failed', 'error'));
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isMeaningfulInvoice]);

  const handleDone = async () => {
    try {
      setSaving(true);
      const bill = await saveInvoiceToDB();
      clearDraft();
      if (onSaved) onSaved(bill);
    } catch (err) {
      console.error(err);
      thagaval('Failed to save invoice.', 'error');
    } finally {
      setSaving(false);
    }
  };


  return (
    <Box sx={{ py: { xs: 1.5, md: 4 }, px: { xs: 1.5, md: 4 }, maxWidth: 1200, mx: 'auto', bgcolor: 'background.default', minHeight: '100vh', display: 'flex', flexDirection: 'column', width: '100%' }}>
      <Box sx={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', mb: { xs: 2, sm: 3 }, gap: 1 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: { xs: 1, sm: 2 } }}>
          {/* Desktop Back Button */}
          <Button variant="outlined" startIcon={<ArrowLeft size={18} weight="regular" />} onClick={handleBack} size="small" sx={{ minHeight: 40, borderRadius: '999px', flexShrink: 0, display: { xs: 'none', sm: 'inline-flex' } }}>
            Back
          </Button>
          {/* Mobile Back Button */}
          <IconButton onClick={handleBack} size="small" sx={{ display: { xs: 'inline-flex', sm: 'none' }, minHeight: 40, width: 40, borderRadius: '999px', border: '1px solid', borderColor: 'divider' }}>
            <ArrowLeft size={20} weight="regular" />
          </IconButton>
          <Typography variant="caption" sx={{ 
            display: { xs: 'flex', sm: 'flex' }, alignItems: 'center', gap: 0.5,
            color: autoSaveStatus === 'saving' ? 'text.secondary' 
                 : autoSaveStatus === 'saved' ? 'success.main' 
                 : isMeaningfulInvoice() ? 'text.secondary' : 'text.disabled'
          }}>
            {autoSaveStatus === 'saving' && <><Box component="span" sx={{ display: 'inline-flex', animation: 'spin 1s linear infinite', '@keyframes spin': { '100%': { transform: 'rotate(360deg)' } } }}><Hourglass size={13} weight="regular"   /></Box> <Box component="span" sx={{ display: { xs: 'none', sm: 'inline' } }}>Saving...</Box></>}
            {autoSaveStatus === 'saved' && <><Check size={13} weight="regular"   /><Box component="span" sx={{ display: { xs: 'none', sm: 'inline' } }}>{t('hc_allChangesSaved')}</Box></>}
            {autoSaveStatus === 'idle' && !isMeaningfulInvoice() && <span title={t('hc_addAClientNameAnd')}>{t("draftOnly")}</span>}
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Button variant="contained" color="primary" onClick={handleDone} disabled={saving || !isMeaningfulInvoice()} startIcon={<Check size={18} weight="regular"   />} sx={{ display: { xs: 'none', sm: 'inline-flex' }, minHeight: 40, borderRadius: '999px' }}>
            {saving ? 'Saving...' : 'Save Invoice'}
          </Button>
        </Box>
      </Box>

      {/* Mobile squircle FAB for saving */}
      <Button
        variant="contained"
        color="primary"
        onClick={handleDone}
        disabled={saving || !isMeaningfulInvoice()}
        sx={{
          display: { xs: 'flex', sm: 'none' },
          position: 'fixed',
          bottom: 'calc(env(safe-area-inset-bottom, 0px) + 40px)',
          right: 20,
          minWidth: 56,
          width: 56,
          height: 56,
          borderRadius: '20px',
          zIndex: 1100,
          boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
          p: 0,
        }}
      >
        <FloppyDisk size={24} weight="fill" />
      </Button>

      <Grid container spacing={3} sx={{ flexGrow: 1 }}>
        <Grid size={12}>
          
          {/* Business Profile Selector — shown only if multiple profiles saved */}
          {allProfiles.length > 1 && (
            <>
              <Box sx={{ py: 3 }}>
                <Typography variant="h6" sx={{ mb: 2, fontSize: '1.1rem', fontWeight: 600 }}>Billing From (Business Profile)</Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {allProfiles.map(bp => {
                    const isSelected = (activeProfile?.niruvanathinPeyar || profileProp?.niruvanathinPeyar) === bp.niruvanathinPeyar;
                    return (
                      <Button key={bp.id} variant={isSelected ? "contained" : "outlined"} 
                        onClick={() => setActiveProfile(bp)}
                        color={isSelected ? "primary" : "inherit"}
                        sx={{ borderRadius: 2, textTransform: 'none' }}
                      >
                        {bp.niruvanathinPeyar}
                        {bp.gstin && <Typography variant="caption" sx={{ ml: 1, opacity: 0.8 }}>{bp.gstin}</Typography>}
                      </Button>
                    );
                  })}
                </Box>
              </Box>
              <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />
            </>
          )}

                    {/* Client Modal */}
          <VanigarThirai show={showClientModal} onClose={() => setShowClientModal(false)} onSave={handleClientModalSave} client={modalClient} isEditing={isEditingClient} defaultCountry={profile?.country} profileSettings={profile} />

          {/* Client Details */}
          <Box sx={{ py: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t('billedTo')}</Typography>
              <ToggleButtonGroup
                size="small"
                value={isTempClient ? 'temp' : 'saved'}
                exclusive
                onChange={(_, val) => {
                  if (val !== null) setIsTempClient(val === 'temp');
                }}
              >
                <ToggleButton value="saved">{t('hc_savedCustomer')}</ToggleButton>
                <ToggleButton value="temp">{t('hc_tempCustomer')}</ToggleButton>
              </ToggleButtonGroup>
            </Box>

            <Grid container spacing={2}>
              <Grid size={{ xs: 12 }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
                  {t('clientName')}{profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'} & ${profile?.secondaryDataLanguage || 'English'})` : ''}
                </Typography>
                <Box sx={{ display: 'flex', gap: 1, flexDirection: 'column', position: 'relative' }}>
                  <TextField fullWidth size="small" value={getClientField('name', primaryLang)} inputRef={clientNameRef}
                    onChange={(e) => {
                      const newName = e.target.value;
                      if (!isTempClient) {
                        setClient({ [`name_${primaryLang}`]: newName });
                        setSelectedClientId(null);
                        setShowClientSuggestions(true);
                      } else {
                        setClientField('name', primaryLang, newName);
                      }
                    }}
                    onFocus={() => { if (!isTempClient && savedClients.length > 0) setShowClientSuggestions(true); }}
                    placeholder={`${t("typeClientName")}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} autoComplete="off" />
                  
                  {profile?.enableBilingual !== false && isTempClient && (
                    <TextField fullWidth size="small" value={getClientField('name', secondaryLang)}
                      onChange={(e) => setClientField('name', secondaryLang, e.target.value)} placeholder={`Client Name in ${profile?.secondaryDataLanguage || 'English'}`} autoComplete="off" />
                  )}

                  {!isTempClient && showClientSuggestions && savedClients.length > 0 && (
                    <Paper elevation={4} sx={{ position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 10, mt: 0.5, maxHeight: 300, overflow: 'auto' }} ref={clientSuggestionsRef}>
                      <List disablePadding>
                        {filteredClients.length > 0 ? filteredClients.map(cli => (
                          <ListItem key={cli.id} disablePadding>
                            <ListItemButton onClick={() => selectSavedClient(cli)}>
                              <ListItemText 
                                primary={cli.name} 
                                secondary={
                                  profile?.enableBilingual !== false && (cli.nameEn || cli.peyarEn)
                                    ? `${cli.nameEn || cli.peyarEn}${cli.oorEn ? ` · ${cli.oorEn}` : ''}`
                                    : [cli.oor || cli.mugavari?.substring(0, 30), cli.maanilam].filter(Boolean).join(' · ')
                                }
                              />
                            </ListItemButton>
                          </ListItem>
                        )) : (
                          <ListItem>
                            <ListItemText primary={getClientField('name', primaryLang).trim() ? "No saved clients found." : "Type to search clients"} />
                          </ListItem>
                        )}
                      </List>
                    </Paper>
                  )}
                </Box>
              </Grid>
              
              {!isTempClient && selectedClientId && (getClientField('mugavari', primaryLang) || getClientField('oor', primaryLang) || client.maanilam || client.gstin || getClientField('name', secondaryLang)) && (
                <Grid size={{ xs: 12 }}>
                  <Paper elevation={0} sx={{ p: 2, bgcolor: (theme) => theme.palette.mode === 'dark' ? 'rgba(255,255,255,0.03)' : 'grey.50', border: '1px solid', borderColor: 'divider' }}>
                    <Typography variant="overline" color="text.secondary" sx={{ fontWeight: 600, display: 'block', mb: 0.5 }}>{t('hc_savedClientDetails')}</Typography>
                    {getClientField('mugavari', primaryLang) && <Typography variant="body2">{getClientField('mugavari', primaryLang)}{getClientField('mugavari', secondaryLang) ? ` / ${getClientField('mugavari', secondaryLang)}` : ''}</Typography>}
                    {(getClientField('oor', primaryLang) || getClientField('maavattam', primaryLang) || client.pin) && <Typography variant="body2">{[
                      getClientField('oor', primaryLang) ? getClientField('oor', primaryLang) + (getClientField('oor', secondaryLang) ? ` / ${getClientField('oor', secondaryLang)}` : '') : '', 
                      getClientField('maavattam', primaryLang) ? getClientField('maavattam', primaryLang) + (getClientField('maavattam', secondaryLang) ? ` / ${getClientField('maavattam', secondaryLang)}` : '') : '', 
                      client.pin
                    ].filter(Boolean).join(' - ')}</Typography>}
                    {client.maanilam && <Typography variant="body2">{getBilingualStateName(client.maanilam, profile)}</Typography>}
                    {client.country && <Typography variant="body2">{getBilingualCountryName(client.country, profile)}</Typography>}
                    {getClientField('name', secondaryLang) && profile?.enableBilingual !== false && <Typography variant="body2" sx={{ mt: 0.5 }}>Name ({profile?.secondaryDataLanguage || 'English'}): <strong>{getClientField('name', secondaryLang)}</strong></Typography>}
                    {client.gstin && <Typography variant="body2" sx={{ mt: 0.5 }}>GSTIN: <strong>{client.gstin}</strong></Typography>}
                  </Paper>
                </Grid>
              )}

              {isTempClient && (
                <>
                  <Grid size={{ xs: 12 }}>
                    <TextField fullWidth size="small" label={`${t('billingAddress')}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                      value={getClientField('mugavari', primaryLang)} onChange={(e) => setClientField('mugavari', primaryLang, e.target.value)} placeholder={t('billingAddress')} />
                  </Grid>
                  {profile?.enableBilingual !== false && (
                    <Grid size={{ xs: 12 }}>
                      <TextField fullWidth size="small" label={`${t('billingAddress')} (${profile?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                        value={getClientField('mugavari', secondaryLang) || ''} onChange={(e) => setClientField('mugavari', secondaryLang, e.target.value)} placeholder={`Address in ${profile?.secondaryDataLanguage || 'English'}`} />
                    </Grid>
                  )}
                  
                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField fullWidth size="small" label={`${t('city')}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                      value={getClientField('oor', primaryLang)} onChange={(e) => setClientField('oor', primaryLang, e.target.value)} placeholder={t("egMumbai")} />
                  </Grid>
                  {profile?.enableBilingual !== false && (
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth size="small" label={`${t('city')} (${profile?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                        value={getClientField('oor', secondaryLang) || ''} onChange={(e) => setClientField('oor', secondaryLang, e.target.value)} placeholder={`City in ${profile?.secondaryDataLanguage || 'English'}`} />
                    </Grid>
                  )}

                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField fullWidth size="small" label={`மாவட்டம் (District)${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                      value={getClientField('maavattam', primaryLang) || ''} onChange={(e) => setClientField('maavattam', primaryLang, e.target.value)} placeholder={`மாவட்டம்`} />
                  </Grid>
                  {profile?.enableBilingual !== false && (
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth size="small" label={`District (${profile?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                        value={getClientField('maavattam', secondaryLang) || ''} onChange={(e) => setClientField('maavattam', secondaryLang, e.target.value)} placeholder={`District`} />
                    </Grid>
                  )}
                  
                  {invoiceOptions.showState && (() => {
                    const cc = getCountryConfig(client.country || profile?.country);
                    const stateOpts = getStatesForCountry(client.country || profile?.country);
                    const stLabel = t(cc.stateLabel as any, { defaultValue: cc.stateLabel });
                    return (
                      <>
                        <Grid size={{ xs: 12, md: profile?.enableBilingual !== false ? 6 : 12 }}>
                          {stateOpts.length > 0 ? (
                            <FormControl fullWidth size="small">
                              <InputLabel shrink>{stLabel}{profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}</InputLabel>
                              <Select displayEmpty value={client.maanilam} label={`${stLabel}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} onChange={(e) => setClient({ ...client, maanilam: e.target.value })}>
                                <MenuItem value="">{t('selectLabelGeneric')} {stLabel}</MenuItem>
                                {stateOpts.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { ...profile, returnOnlyPrimary: true })}</MenuItem>)}
                              </Select>
                            </FormControl>
                          ) : (
                            <TextField fullWidth size="small" label={`${stLabel}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                              value={client.maanilam} onChange={(e) => setClient({ ...client, maanilam: e.target.value })} placeholder={stLabel} />
                          )}
                        </Grid>
                        {profile?.enableBilingual !== false && (
                          <Grid size={{ xs: 12, md: 6 }}>
                            <TextField fullWidth size="small" label={`${stLabel} (${profile?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                              value={client.maanilam ? getBilingualStateName(client.maanilam, { ...profile, returnOnlySecondary: true }) : ''} 
                              disabled={true}
                              sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
                          </Grid>
                        )}
                      </>
                    );
                  })()}
                  
                  {(() => {
                    const visibleCountries = getCountriesForRegion();
                    const isCustomCountry = client.country === 'Other' || (client.country && !visibleCountries.some(c => c.name === client.country));
                    return (
                      <>
                        <Grid size={{ xs: 12, md: profile?.enableBilingual !== false ? 6 : 12 }}>
                          <Box>
                            <FormControl fullWidth size="small" sx={{ mb: isCustomCountry ? 2 : 0 }}>
                              <InputLabel shrink>{t('country')}{profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}</InputLabel>
                              <Select displayEmpty value={isCustomCountry ? 'Other' : (client.country || profile?.country || 'India')} label={`${t('country')}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`}
                                onChange={(e) => {
                                  if (e.target.value === 'Other') {
                                    setClient({ ...client, country: 'Other', countryEn: '', maanilam: '', maanilamEn: '' });
                                  } else {
                                    setClient({ ...client, country: e.target.value, countryEn: '', maanilam: '', maanilamEn: '' });
                                  }
                                }}>
                                {visibleCountries.map(c => <MenuItem key={c.code} value={c.name}>{getBilingualCountryName(c.name, { ...profile, returnOnlyPrimary: true })}</MenuItem>)}
                              </Select>
                            </FormControl>
                            {isCustomCountry && (
                              <TextField fullWidth size="small" label={`Custom Country${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                                value={client.country === 'Other' ? '' : client.country} onChange={(e) => setClient({ ...client, country: e.target.value })} placeholder={t('hc_enterCountryName')} />
                            )}
                          </Box>
                        </Grid>
                        {profile?.enableBilingual !== false && (
                          <Grid size={{ xs: 12, md: 6 }}>
                            <Box>
                              {isCustomCountry && <Box sx={{ height: 40, mb: 2 }} />}
                              <TextField fullWidth size="small" disabled={!isCustomCountry} 
                                label={`${t('country')} (${profile?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                                value={isCustomCountry ? (client.countryEn || '') : (client.country ? getBilingualCountryName(client.country, { ...profile, returnOnlySecondary: true }) : '')}
                                onChange={(e) => isCustomCountry ? setClient({ ...client, countryEn: e.target.value }) : null}
                                sx={!isCustomCountry ? { '& .MuiInputBase-root': { bgcolor: 'action.hover' } } : {}} />
                            </Box>
                          </Grid>
                        )}
                      </>
                    );
                  })()}

                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField fullWidth size="small" 
                      label={(() => { const cc = getCountryConfig(client.country || profile?.country); return t(cc.postalLabel as any, { defaultValue: cc.postalLabel }); })()} slotProps={{ inputLabel: { shrink: true } }}
                      value={client.pin} onChange={(e) => setClient({ ...client, pin: e.target.value })} placeholder={t('pinCode')} />
                  </Grid>
                  
                  {invoiceOptions.showGSTIN && (() => {
                    const cc = getCountryConfig(client.country || profile?.country);
                    return (
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField fullWidth size="small" label={t(cc.taxIdLabel as any, { defaultValue: cc.taxIdLabel })}
                          value={client.gstin} onChange={(e) => setClient({ ...client, gstin: e.target.value.toUpperCase() })} placeholder={t("optionalLabel")} slotProps={{ inputLabel: { shrink: true }, htmlInput: { maxLength: 20 } }} />
                      </Grid>
                    );
                  })()}
                </>
              )}
            </Grid>
          </Box>
          <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

          {/* Invoice Details */}
          <Box sx={{ py: 3 }}>
            <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600, mb: 3 }}>{t('invoiceDetailsForm')}</Typography>
            <Grid container spacing={2}>
              <Grid size={{ xs: 12, md: 6 }}>
                <TextField fullWidth size="small" label={t('invoiceNumber')} slotProps={{ inputLabel: { shrink: true } }}
                  value={details.invoiceNumber} onChange={(e) => setDetails({ ...details, invoiceNumber: e.target.value })} />
              </Grid>
              <Grid size={{ xs: 12, md: 6 }}>
                <TextField fullWidth size="small" type="date" label={t('invoiceDate')} slotProps={{ inputLabel: { shrink: true } }}
                  value={details.invoiceDate} onChange={(e) => setDetails({ ...details, invoiceDate: e.target.value })} />
              </Grid>
              {invoiceOptions.showPlaceOfSupply && (() => {
                const posOpts = getStatesForCountry(profile?.country);
                return (
                  <>
                    <Grid size={{ xs: 12, md: 6 }}>
                      {posOpts.length > 0 ? (
                        <FormControl fullWidth size="small">
                          <InputLabel shrink>{t('placeOfSupply')}{profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}</InputLabel>
                          <Select 
                            displayEmpty 
                            value={details.placeOfSupply} 
                            label={`${t('placeOfSupply')}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} 
                            onChange={(e) => setDetails({ ...details, placeOfSupply: e.target.value })}
                            MenuProps={{
                              anchorOrigin: { vertical: 'bottom', horizontal: 'left' },
                              transformOrigin: { vertical: 'top', horizontal: 'left' },
                              slotProps: { paper: { style: { maxHeight: 300 } } }
                            }}
                          >
                            <MenuItem value="">Defaults to {client.maanilam ? getBilingualStateName(client.maanilam, { ...profile, returnOnlyPrimary: true }) : 'Client maanilam'}</MenuItem>
                            {posOpts.map(s => <MenuItem key={s} value={s}>{getBilingualStateName(s, { ...profile, returnOnlyPrimary: true })}</MenuItem>)}
                          </Select>
                        </FormControl>
                      ) : (
                        <TextField fullWidth size="small" label={`${t('placeOfSupply')}${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} slotProps={{ inputLabel: { shrink: true } }}
                          value={details.placeOfSupply} onChange={(e) => setDetails({ ...details, placeOfSupply: e.target.value })} placeholder={t('hc_maanilamRegion')} />
                      )}
                    </Grid>
                    {profile?.enableBilingual !== false && (
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField fullWidth size="small" label={`${t('placeOfSupply')} (${profile?.secondaryDataLanguage || 'English'})`} slotProps={{ inputLabel: { shrink: true } }}
                          value={(details.placeOfSupply || client.maanilam) ? getBilingualStateName(details.placeOfSupply || client.maanilam, { ...profile, returnOnlySecondary: true }) : ''} 
                          placeholder={`Place of Supply in ${profile?.secondaryDataLanguage || 'English'}`} 
                          disabled={true}
                          sx={{ '& .MuiInputBase-root': { bgcolor: 'action.hover' } }} />
                      </Grid>
                    )}
                  </>
                );
              })()}
              {invoiceType === 'credit-note' && (
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField fullWidth size="small" label={t('hc_originalInvoiceReference')} slotProps={{ inputLabel: { shrink: true } }}
                    value={details.originalInvoiceRef} onChange={(e) => setDetails({ ...details, originalInvoiceRef: e.target.value })} placeholder={t('hc_egInv2025260001')} />
                </Grid>
              )}
            </Grid>
          </Box>
          <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

          {/* Line Items */}
          <Box sx={{ py: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t('lineItems')}</Typography>
            </Box>
            
            {items.map((item, index) => (
              <Box key={item.id} sx={{ mb: 3 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                  <Typography variant="subtitle2" color="text.secondary">
                    {t('item')} #{index + 1}
                  </Typography>
                  <ToggleButtonGroup
                    size="small"
                    value={item.isTemp ? 'temp' : 'saved'}
                    exclusive
                    onChange={(_, val) => {
                      if (val !== null) handleItemChange(item.id, 'isTemp', val === 'temp');
                    }}
                  >
                    <ToggleButton value="saved" sx={{ py: 0, px: 1, fontSize: '0.75rem' }}>{t('hc_savedItem')}</ToggleButton>
                    <ToggleButton value="temp" sx={{ py: 0, px: 1, fontSize: '0.75rem' }}>{t('hc_tempItem')}</ToggleButton>
                  </ToggleButtonGroup>
                </Box>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, p: 2, bgcolor: (theme) => theme.palette.mode === 'dark' ? 'rgba(255,255,255,0.03)' : 'grey.50', border: '1px solid', borderColor: 'divider', borderRadius: 1, position: 'relative' }}>
                  <Box sx={{ flex: '2.5 1 200px' }}>
                  {item.isTemp ? (
                    <>
                      <TextField fullWidth size="small" label={t("descriptionCol")} slotProps={{ inputLabel: { shrink: true } }}
                        value={getItemField(item, 'name', primaryLang)} onChange={(e) => handleItemChange(item.id, 'name', e.target.value)}
                        placeholder={`Description${profile?.enableBilingual !== false ? ` (${profile?.primaryDataLanguage || 'Tamil'})` : ''}`} autoComplete="off" 
                        sx={{ mb: profile?.enableBilingual !== false ? 1 : 0 }} />
                      {profile?.enableBilingual !== false && (
                        <TextField fullWidth size="small" value={getItemField(item, 'description', secondaryLang) || getItemField(item, 'name', secondaryLang) || ''}
                          onChange={(e) => handleItemChange(item.id, `description_${secondaryLang}`, e.target.value)}
                          placeholder={`${profile?.secondaryDataLanguage || 'English'} Description`} autoComplete="off" />
                      )}
                    </>
                  ) : (
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                      <Autocomplete
                        fullWidth size="small"
                        options={products}
                        getOptionLabel={(option) => option.name || ''}
                        value={products.find(p => p.id === item.productId) || (getItemField(item, 'name', primaryLang) ? { name: getItemField(item, 'name', primaryLang) } : null)}
                        onChange={(_, newValue) => {
                          if (newValue && newValue.id) {
                            selectProduct(item.id, newValue);
                          } else {
                            handleItemChange(item.id, 'productId', null);
                            handleItemChange(item.id, `name_${primaryLang}`, '');
                            handleItemChange(item.id, `name_${secondaryLang}`, '');
                            handleItemChange(item.id, 'hsn', '');
                            handleItemChange(item.id, 'rate', 0);
                          }
                        }}
                        renderOption={(props, p) => (
                          <li {...props} key={p.id}>
                            <Box>
                              <Typography variant="body2">{p.name}</Typography>
                              <Typography variant="caption" color="text.secondary">
                                {`${p.hsn ? `HSN: ${p.hsn}` : ''}${p.hsn && p.rate ? ' · ' : ''}${p.rate ? formatCurrency(p.rate, invoiceOptions.currency || 'INR') : ''}`}
                              </Typography>
                            </Box>
                          </li>
                        )}
                        renderInput={(params) => (
                          <TextField {...params} label={t("descriptionCol")} slotProps={{ inputLabel: { shrink: true } }}
                            placeholder={t('hc_searchSavedItems')} />
                        )}
                      />
                      {item.productId && (
                        <Box sx={{ mt: 1, p: 1.5, bgcolor: 'background.paper', borderRadius: 1, border: '1px solid', borderColor: 'divider' }}>
                          <Typography variant="overline" color="text.secondary" sx={{ fontWeight: 600, display: 'block', mb: 0.5 }}>{t('hc_savedItemDetails')}</Typography>
                          {profile?.enableBilingual !== false && getItemField(item, 'name', secondaryLang) && (
                            <Typography variant="body2" sx={{ mb: 0.5 }}>Name ({profile?.secondaryDataLanguage || 'English'}): <strong>{getItemField(item, 'name', secondaryLang)}</strong></Typography>
                          )}
                          {invoiceOptions.showHSN && item.hsn && (
                            <Typography variant="body2" sx={{ mb: 0.5 }}>{t('hc_hsnsac')}<strong>{item.hsn}</strong></Typography>
                          )}
                          <Typography variant="body2" sx={{ mb: 0.5 }}>{t('hc_unit')}<strong>{item.unit || 'Nos'}</strong></Typography>
                          {showGST && (
                            <Typography variant="body2" sx={{ mb: 0.5 }}>{t('hc_tax')}<strong>{item.taxPercent}%</strong></Typography>
                          )}
                          {showGST && invoiceOptions.showCess && (profile?.country || 'India') === 'India' && (
                            <Typography variant="body2" sx={{ mb: 0 }}>{t('hc_cess')}<strong>{item.cessPercent || 0}%</strong></Typography>
                          )}
                        </Box>
                      )}
                    </Box>
                  )}
                </Box>
                {invoiceOptions.showHSN && item.isTemp && (
                  <Box sx={{ flex: '1 1 100px' }}>
                    <TextField fullWidth size="small" label={t('hsnSac')} slotProps={{ inputLabel: { shrink: true }, htmlInput: { list: 'hsn-list' } }} 
                      value={item.hsn} onChange={(e) => handleItemChange(item.id, 'hsn', e.target.value)} />
                  </Box>
                )}
                <Box sx={{ flex: '0.7 1 80px' }}>
                  <TextField fullWidth size="small" label={t('qty')} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0, step: "any" } }} 
                    value={item.quantity} onChange={(e) => handleItemChange(item.id, 'quantity', clampNonNeg(e.target.value))} />
                </Box>
                {item.isTemp && (
                  <Box sx={{ flex: '0.9 1 100px' }}>
                    <FormControl fullWidth size="small">
                      <InputLabel shrink>{t('unit')}</InputLabel>
                      <Select native displayEmpty value={item.unit || 'Nos'} label={t('unit')} 
                        onChange={(e) => {
                        if (e.target.value === '__custom__') { handleAddCustomUnit(item.id); return; }
                        if (e.target.value.startsWith('__remove__::')) {
                          const label = e.target.value.replace('__remove__::', '');
                          handleRemoveCustomUnit(label);
                          return;
                        }
                        handleItemChange(item.id, 'unit', e.target.value);
                      }}>
                        {(() => {
                          const visible = units;
                          const showCurrentExtra = item.unit && !visible.some(u => u.label === item.unit);
                          return (
                            <>
                              {showCurrentExtra && <option value={item.unit}>{item.unit}</option>}
                              {visible.map(u => <option key={u.label} value={u.label}>{u.label}{u.custom ? ' ★' : ''}</option>)}
                            </>
                          );
                        })()}
                        <option value="__custom__">{t('hc_addCustom')}</option>
                        {units.some(u => u.custom) && units.filter(u => u.custom).map(u => (
                          <option key={`rm-${u.label}`} value={`__remove__::${u.label}`}>− Remove "{u.label}"</option>
                        ))}
                      </Select>
                    </FormControl>
                  </Box>
                )}
                <Box sx={{ flex: '1.2 1 120px' }}>
                  <TextField fullWidth size="small" label={t("rateCol")} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0, step: "any" } }} 
                    value={item.rate} onChange={(e) => handleItemChange(item.id, 'rate', clampNonNeg(e.target.value))} />
                </Box>
                {invoiceOptions.showDiscount && (
                  <Box sx={{ flex: '1 1 100px' }}>
                    <TextField fullWidth size="small" label={t('discount')} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0, step: "any" } }} 
                      value={item.discount} onChange={(e) => handleItemChange(item.id, 'discount', clampNonNeg(e.target.value))} />
                  </Box>
                )}
                {showGST && item.isTemp && (
                  <Box sx={{ flex: '1 1 100px' }}>
                    <FormControl fullWidth size="small">
                      <InputLabel shrink>{taxLabel} %</InputLabel>
                      <Select native value={item.taxPercent} label={`${taxLabel} %`} 
                        onChange={(e) => handleItemChange(item.id, 'taxPercent', parseFloat(e.target.value) || 0)}>
                        <option value="0">GST0 [0%]</option>
                        <option value="5">GST5 [5%]</option>
                        <option value="12">GST12 [12%]</option>
                        <option value="18">GST18 [18%]</option>
                        <option value="28">GST28 [28%]</option>
                      </Select>
                    </FormControl>
                  </Box>
                )}
                {showGST && invoiceOptions.showCess && (profile?.country || 'India') === 'India' && item.isTemp && (
                  <Box sx={{ flex: '0.8 1 80px' }}>
                    <TextField fullWidth size="small" label={t('cess')} type="number" slotProps={{ inputLabel: { shrink: true }, htmlInput: { min: 0, max: 500, step: "any" } }}  title="GST Compensation Cess (tobacco / auto / coal etc.)"
                      value={item.cessPercent || 0} onChange={(e) => handleItemChange(item.id, 'cessPercent', clampNonNeg(e.target.value))} />
                  </Box>
                )}
                <Box sx={{ flex: '0 0 auto', display: 'flex', alignItems: 'center' }}>
                  <IconButton color="error" onClick={() => removeItem(item.id)} title={t('hc_remove')}><Trash size={18} weight="regular"   /></IconButton>
                </Box>
              </Box>
            </Box>
            ))}
            <Button variant="outlined" startIcon={<Plus size={18} weight="regular"   />} onClick={addItem} sx={{ mt: 1 }}>Add Item</Button>
          </Box>
          <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

          {/* Invoice Type */}
          <Box sx={{ py: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
              <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600 }}>{t("invoiceType")}</Typography>
              
            </Box>

            <Grid container spacing={2} sx={{ mb: 2 }}>
              <Grid size={{ xs: 12, md: 6 }}>
                <FormControl fullWidth size="small">
                  <Select value={invoiceType} onChange={(e) => handleTypeChange(e.target.value)}>
                    {Object.entries(INVOICE_TYPES).map(([key, val]) => (
                      <MenuItem key={key} value={key}>{t(`invoiceTypes_${key.replace(/-/g, '_')}` as any, { defaultValue: val.label })}</MenuItem>
                    ))}
                  </Select>
                </FormControl>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 0.5, lineHeight: 1.4 }}>
                  {t(`invoiceDesc_${invoiceType.replace(/-/g, '_')}` as any, { defaultValue: typeConfig?.description })}
                </Typography>
              </Grid>


            </Grid>

            {/* Payment account */}
                {(() => {
                  const accounts = getActiveAccounts(profile);
                  if (accounts.length === 0) return null;
                  const resolved = getAccountById(profile, invoiceOptions.selectedAccountId);
                  return (
                    <Box sx={{ mb: 3 }}>
                      <FormControl fullWidth size="small">
                        <InputLabel shrink>{t('hc_paymentAccountOnThisInvoice')}</InputLabel>
                        <Select displayEmpty value={resolved?.id || ''} label={t('hc_paymentAccountOnThisInvoice')} onChange={(e) => setInvoiceOptions(prev => ({ ...prev, selectedAccountId: e.target.value || null }))}>
                          <MenuItem value="">{t('noneLabel')}</MenuItem>
                          {accounts.map(a => (
                            <MenuItem key={a.id} value={a.id}>
                              {a.isDefault ? '⭐ ' : ''}{a.label || a.vangiPeyar || 'Untitled account'}
                              {a.vangiPeyar && a.label !== a.vangiPeyar ? ` — ${a.vangiPeyar}` : ''}
                            </MenuItem>
                          ))}
                        </Select>
                      </FormControl>
                      <Typography variant="caption" color="text.secondary">
                        Bank details and UPI QR on the PDF come from the selected account.
                      </Typography>
                    </Box>
                  );
                })()}
          </Box>
          <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

{/* Terms */}
          <Box sx={{ py: 3 }}>
            <Typography variant="h6" sx={{ fontSize: '1.1rem', fontWeight: 600, mb: 3 }}>{t("termsHeading")}</Typography>
            <Box sx={{ mb: 2 }}>
              <Typography variant="body2" sx={{ fontWeight: 500, mb: 1 }}>{t("termsAppearsOnInvoice")}</Typography>
              <RichEditor toolbar value={customTerms}
                onChange={(v) => { setCustomTerms(v); }}
                placeholder="Enter or paste your terms & conditions..." />
            </Box>

          </Box>
          <Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />

        </Grid>

      </Grid>

      {/* Back Confirmation Dialog */}
      <Dialog open={showBackDialog} onClose={() => setShowBackDialog(false)}>
        <DialogTitle>{t('hc_saveChangesBeforeClosing')}</DialogTitle>
        <DialogContent>
          <DialogContentText>
            You have unsaved changes on this invoice. Do you want to save them before leaving?
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowBackDialog(false)} color="inherit">
            Cancel
          </Button>
          <Button onClick={handleDiscardChanges} color="error">
            Discard Changes
          </Button>
          <Button onClick={handleSaveAndCloseWithBill} variant="contained" color="primary">
            Save & Close
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

