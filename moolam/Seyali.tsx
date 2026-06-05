// @ts-nocheck
import { CaretDoubleLeft as KeyboardDoubleArrowLeft, CaretDoubleRight as KeyboardDoubleArrowRight, House as Home, FileText as Description, GearSix as Settings, Plus as Add, Users as People, Package as Inventory, ChartBar as BarChart, Wallet as AccountBalanceWallet, ArrowsClockwise as Refresh, Receipt, BookOpen as MenuBook, Moon as DarkMode, Sun as LightMode, DownloadSimple as Download, X as Close, ShoppingCart, CaretDown as KeyboardArrowDown, CaretRight as KeyboardArrowRight, Buildings as Business, PencilSimple as Edit, Question as HelpOutlined, MagnifyingGlass as Search, Command as KeyboardCommandKey, Bell as Notifications, List as Menu, CalendarDots } from '@phosphor-icons/react';
import { useState, useEffect, useRef, useMemo, useCallback } from 'react';
import { Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText, Badge, Box, Typography, Avatar, Divider, Tooltip, IconButton, Collapse, CssBaseline, Dialog, DialogTitle, DialogContent, DialogActions, Button, Backdrop, CircularProgress, InputBase, AppBar, Toolbar, useMediaQuery, Stack } from '@mui/material';
import { ThemeProvider, createTheme, useTheme } from '@mui/material/styles';
import { getAllProfiles, saveProfile, getAllBills, getAllProducts } from './Avanam';
import { jsPDF } from 'jspdf';
import VariArikkaigal from './pagudhigal/VariArikkaigal';
import Mugappu from './pagudhigal/Mugappu';
import InvoiceEditor from './pagudhigal/invoice/InvoiceEditor';
import InvoiceList from './pagudhigal/invoice/InvoiceList';
import InvoiceView from './pagudhigal/invoice/InvoiceView';
import ReceiptView from './pagudhigal/ReceiptView';
import Amaippugal from './pagudhigal/Amaippugal';
import Vanigargal from './pagudhigal/Vanigargal';
import VanigarThoguppu from './pagudhigal/VanigarThoguppu';
import Porul from './pagudhigal/Porul';
import PorulThoguppu from './pagudhigal/PorulThoguppu';
import Arikkaigal from './pagudhigal/Arikkaigal';
import Raseedhu from './pagudhigal/Raseedhu';
import ReceiptEditor from './pagudhigal/ReceiptEditor';

import Nalvaravu from './pagudhigal/Nalvaravu';
import Thagaval from './pagudhigal/Thagaval';
import Pakkapatti from './pagudhigal/Pakkapatti';
import { useLanguage } from './mozhi/LanguageContext';


function ResponsiveDialog({ open, onClose, children, maxWidth = 'sm' }: any) {
  const isMobile = useMediaQuery('(max-width:600px)');
  if (isMobile) {
    return (
      <Drawer anchor="bottom" open={open} onClose={onClose} slotProps={{ paper: { sx: { borderTopLeftRadius: 24, borderTopRightRadius: 24, maxHeight: '90vh' } } }}>
        <Box sx={{ width: 40, height: 4, bgcolor: 'divider', borderRadius: 2, mx: 'auto', mt: 1.5, mb: 0.5 }} />
        {children}
      </Drawer>
    );
  }
  return (
    <Dialog open={open} onClose={onClose} maxWidth={maxWidth} fullWidth slotProps={{ paper: { sx: { borderRadius: 3, overflow: 'hidden' } } }}>
      {children}
    </Dialog>
  );
}

function DevLanguageSwitcher({ profile, setProfile, language, setLanguage }: any) {
  const { t } = useLanguage();
  const [devOpen, setDevOpen] = useState(false);
  const LANGS = ['Tamil', 'English', 'Hindi', 'Telugu', 'Kannada', 'Malayalam', 'Marathi', 'Gujarati', 'Bengali'];

  if (!profile) return null;

  const switchLang = async (primary, secondary) => {
    const updated = { ...profile, primaryDataLanguage: primary, secondaryDataLanguage: secondary };
    setProfile(updated);
    await saveProfile(updated);
  };
  const toggleBilingual = async () => {
    const updated = { ...profile, enableBilingual: profile.enableBilingual === false ? true : false };
    setProfile(updated);
    await saveProfile(updated);
  };

  return (
    <>
      <Box onClick={() => setDevOpen(o => !o)} sx={{
        position: 'fixed', bottom: 24, right: 24, zIndex: 9999,
        width: 48, height: 48, borderRadius: '50%',
        bgcolor: '#6366f1', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', boxShadow: '0 4px 20px rgba(99,102,241,0.5)',
        fontSize: '1.2rem', fontWeight: 700, userSelect: 'none',
        '&:hover': { bgcolor: '#4f46e5', transform: 'scale(1.1)' },
        transition: 'all 0.2s'
      }} title={t('hc_devSwitchBilingualLanguage')}>
        {(profile.primaryDataLanguage || 'Ta').slice(0, 2)}
      </Box>
      {devOpen && (
        <Box sx={{
          position: 'fixed', bottom: 80, right: 24, zIndex: 9999,
          bgcolor: 'background.paper', borderRadius: 2, boxShadow: '0 8px 32px rgba(0,0,0,0.25)',
          p: 2, minWidth: 260, maxHeight: '70vh', overflowY: 'auto',
          border: '2px solid #6366f1'
        }}>
          <Typography variant="caption" color="#6366f1" sx={{ fontWeight: 700, mb: 1, display: 'block' }}>{t('hc_devLanguageSwitcher')}</Typography>
          <Typography variant="caption" color="text.secondary" sx={{ mb: 1.5, display: 'block' }}>Current: {profile.primaryDataLanguage || 'Tamil'} / {profile.secondaryDataLanguage || 'English'}</Typography>
          <Divider sx={{ mb: 1 }} />
          <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, display: 'block' }}>{t('hc_primaryLanguage')}</Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 1.5 }}>
            {LANGS.map(l => (
              <Box key={l} onClick={() => switchLang(l, profile.secondaryDataLanguage || 'English')}
                sx={{
                  px: 1.2, py: 0.4, borderRadius: 1, fontSize: '0.75rem', cursor: 'pointer',
                  bgcolor: (profile.primaryDataLanguage || 'Tamil') === l ? '#6366f1' : 'action.hover',
                  color: (profile.primaryDataLanguage || 'Tamil') === l ? '#fff' : 'text.primary',
                  fontWeight: (profile.primaryDataLanguage || 'Tamil') === l ? 700 : 400,
                  '&:hover': { bgcolor: (profile.primaryDataLanguage || 'Tamil') === l ? '#4f46e5' : 'action.selected' },
                  transition: 'all 0.15s'
                }}>{l}</Box>
            ))}
          </Box>
          <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, display: 'block' }}>{t('hc_secondaryLanguage')}</Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 1.5 }}>
            {LANGS.map(l => (
              <Box key={l} onClick={() => switchLang(profile.primaryDataLanguage || 'Tamil', l)}
                sx={{
                  px: 1.2, py: 0.4, borderRadius: 1, fontSize: '0.75rem', cursor: 'pointer',
                  bgcolor: (profile.secondaryDataLanguage || 'English') === l ? '#6366f1' : 'action.hover',
                  color: (profile.secondaryDataLanguage || 'English') === l ? '#fff' : 'text.primary',
                  fontWeight: (profile.secondaryDataLanguage || 'English') === l ? 700 : 400,
                  '&:hover': { bgcolor: (profile.secondaryDataLanguage || 'English') === l ? '#4f46e5' : 'action.selected' },
                  transition: 'all 0.15s'
                }}>{l}</Box>
            ))}
          </Box>
          <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, display: 'block' }}>{t('hc_bilingualMode')}</Typography>
          <Box
            onClick={toggleBilingual}
            sx={{
              px: 1.2, py: 0.4, borderRadius: 1, fontSize: '0.75rem', cursor: 'pointer',
              bgcolor: profile.enableBilingual !== false ? '#10b981' : 'action.hover',
              color: profile.enableBilingual !== false ? '#fff' : 'text.primary',
              fontWeight: profile.enableBilingual !== false ? 700 : 400,
              textAlign: 'center',
              transition: 'all 0.15s'
            }}>
            {profile.enableBilingual !== false ? 'ON (Bilingual Active)' : 'OFF (Single Language)'}
          </Box>
          <Typography variant="caption" sx={{ fontWeight: 600, mb: 0.5, mt: 1.5, display: 'block' }}>{t('hc_uiLanguage')}</Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mb: 1.5 }}>
            {[{code: 'ta', label: 'Tamil (தமிழ்)'}, {code: 'en', label: 'English'}].map(l => (
              <Box key={l.code} onClick={() => setLanguage(l.code as any)}
                sx={{
                  px: 1.2, py: 0.4, borderRadius: 1, fontSize: '0.75rem', cursor: 'pointer',
                  bgcolor: language === l.code ? '#6366f1' : 'action.hover',
                  color: language === l.code ? '#fff' : 'text.primary',
                  fontWeight: language === l.code ? 700 : 400,
                  '&:hover': { bgcolor: language === l.code ? '#4f46e5' : 'action.selected' },
                  transition: 'all 0.15s'
                }}>{l.label}</Box>
            ))}
          </Box>
        </Box>
      )}
    </>
  );
}

function Seyali() {
  const { t, language, setLanguage } = useLanguage();
  const [currentView, setCurrentView] = useState(() => {
    // PWA manifest "shortcuts" deep-link in via ?view=Close (e.g. right-clicking
    // the pinned taskbar icon → "New Invoice" opens /?view=new). Honour that
    // before falling back to whatever the user was last looking at.
    try {
      const params = new URLSearchParams(window.location.search);
      const v = params.get('view');
      const valid = ['dashboard', 'new', 'invoice-editor', 'invoice-list', 'invoice-view', 'clients', 'client-editor', 'inventory', 'product-editor', 'receipts', 'receipt-editor', 'receipt-view', 'reports', 'filing', 'settings'];
      if (v && valid.includes(v)) {
        return v === 'new' ? 'invoice-editor' : v;
      }
    } catch { /* sandboxed history API — fall through */ }
    return sessionStorage.getItem('gst_currentView') || 'dashboard';
  });

  // Handle browser back/forward buttons
  useEffect(() => {
    const handlePopState = (event) => {
      if (event.state && event.state.view) {
        setCurrentView(event.state.view);
      } else {
        const params = new URLSearchParams(window.location.search);
        const v = params.get('view') || 'dashboard';
        setCurrentView(v);
      }
    };
    window.addEventListener('popstate', handlePopState);
    
    // Initially replace state so first back navigation works correctly
    window.history.replaceState({ view: currentView }, '', window.location.pathname + window.location.search);
    
    return () => window.removeEventListener('popstate', handlePopState);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Sync state to URL and history stack when changed programmatically
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const urlView = params.get('view') || 'dashboard';
    
    if (urlView !== currentView) {
      const newParams = new URLSearchParams(window.location.search);
      if (currentView === 'dashboard') {
        newParams.delete('view');
      } else {
        newParams.set('view', currentView);
      }
      const qs = newParams.toString();
      const newUrl = window.location.pathname + (qs ? '?' + qs : '');
      window.history.pushState({ view: currentView }, '', newUrl);
    }
  }, [currentView]);
  const [profile, setProfile] = useState(null);
  const [editingBill, setEditingBill] = useState(() => {
    try {
      const saved = sessionStorage.getItem('gst_editingBill');
      return saved ? JSON.parse(saved) : null;
    } catch { return null; }
  });
  const [editingClient, setEditingClient] = useState<any>(null);
  const [editingProduct, setEditingProduct] = useState<any>(null);
  const [editingReceipt, setEditingReceipt] = useState<any>(null);
  const [darkMode, setDarkMode] = useState(() => {
    return localStorage.getItem('elvanniril_theme') === 'dark';
  });
  const [isCollapsed, setIsCollapsed] = useState(() => localStorage.getItem('elvanniril_sidebar_collapsed') === 'true');
  const [isHovered, setIsHovered] = useState(false);
  const [showWelcome, setShowWelcome] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const handleDrawerToggle = () => setMobileOpen(!mobileOpen);
  const [showInstallBanner, setShowInstallBanner] = useState(false);
  const [serverDown, setServerDown] = useState(false);
  const deferredPrompt = useRef(null);
  const retryTimer = useRef(null);

  const [serverStatus, setServerStatus] = useState('checking'); // 'checking' | 'online' | 'offline'
  const profileLoaded = useRef(false);
  const [allProfiles, setAllProfiles] = useState([]);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const profileMenuRef = useRef(null);

  // Update notification maanilam. Auto-checks GitHub on mount + every 6h.
  // The user can dismiss a specific version (stored in localStorage) so the
  // banner doesn't keep nagging once they've seen it. A NEW version released
  // after that dismissal will re-show the banner.
  const [updateInfo, setUpdateInfo] = useState(null);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const updateBannerVisible = updateInfo?.updateAvailable
    && localStorage.getItem('elvanniril_dismissedUpdate') !== updateInfo.latest;

  useEffect(() => {
    let cancelled = false;
    const check = async () => {
      try {
        const res = await fetch('/api/check-update');
        const data = await res.json();
        if (!cancelled) setUpdateInfo(data);
      } catch { /* offline — quietly skip */ }
    };
    // First check ~5 seconds after mount so it doesn't fight the initial load.
    const initial = setTimeout(check, 5000);
    // Then re-check every 6 hours while the app is open.
    const interval = setInterval(check, 6 * 60 * 60 * 1000);
    return () => { cancelled = true; clearTimeout(initial); clearInterval(interval); };
  }, []);

  // ---- Notification centre ----
  // Computed from server data on app boot + every 10 minutes; tucked under a
  // bell icon next to dark-mode toggle in the sidebar. Each section is one
  // click away from the relevant page.

  // ---- Keyboard shortcuts + command palette ----
  // Ctrl+K opens a Spotlight-style command palette; Ctrl+N starts a new
  // invoice from anywhere; Ctrl+/ shows the full shortcuts list. Ctrl+S /
  // Ctrl+P live in InvoiceGenerator (they need invoice-form context). All
  // global handlers also accept Meta (⌘) for macOS users.
  const [showPalette, setShowPalette] = useState(false);
  const [paletteQuery, setPaletteQuery] = useState('');
  const [paletteIdx, setPaletteIdx] = useState(0);
  const [showShortcutsHelp, setShowShortcutsHelp] = useState(false);

  // Palette useMemo + dependent effects are declared further down, AFTER
  // `navItems` and `handleNewInvoice` exist. Declaring them up here would
  // throw "Cannot access 'Close' before initialization" at render time because
  // useMemo's dependency array is evaluated synchronously every render.

  const dismissUpdate = () => {
    if (updateInfo?.latest) {
      localStorage.setItem('elvanniril_dismissedUpdate', updateInfo.latest);
      setUpdateInfo(prev => prev ? { ...prev } : prev); // trigger re-render
    }
    setShowUpdateModal(false);
  };

  // Check if server is running — continuously monitors
  useEffect(() => {
    let cancelled = false;

    const checkServer = async () => {
      try {
        const res = await fetch('/api/profile', { signal: AbortSignal.timeout(3000) });
        if (res.ok) {
          if (cancelled) return;
          setServerDown(false);
          setServerStatus('online');
          if (!profileLoaded.current) {
            profileLoaded.current = true;
            const p = await res.json();
            setProfile(p);
            if (!p.niruvanathinPeyar && !localStorage.getItem('elvanniril_onboarded')) {
              setShowWelcome(true);
            }
            
            // --- SEED TEST DATA ---
            const IS_TESTING_MODE = true; // TODO: Change to false to stop generating test data
            if (IS_TESTING_MODE) {
              try {
                const { getAllClients, saveClient, getAllProducts, saveProduct, saveProfile } = await import('./Avanam');
                const clients = await getAllClients().catch(() => []);
                const products = await getAllProducts().catch(() => []);
                const profiles = await getAllProfiles().catch(() => []);
                
                if (clients.length === 0) {
                  await saveClient({ 
                    name: 'ஸ்ரீ சிவராம் சில்க் சாரீஸ் ஆரணி', nameEn: 'SRI SIVARAM SILK SAREES ARANI', 
                    mugavari: '6, NA, ஒளவையார் தெரு', mugavariEn: '6, NA, AVVAIYAAR STREET',
                    oor: 'ஆரணி', oorEn: 'ARANI', 
                    pin: '632301', 
                    maanilam: 'Tamil Nadu', maanilamEn: '', 
                    gstin: '33AYGPS0561E1ZN', 
                    country: 'India' 
                  });
                }
                if (products.length === 0) {
                  const TEST_ITEMS = [
                    { name: 'ஃபேன்ஸி சேலை', nameEn: 'Fancy Saree', hsn: '', rate: 7900, taxPercent: 5, cessPercent: 0, stock: 10, unit: 'Nos' },
                    { name: 'ஃபேன்ஸி முத்து சேலை', nameEn: 'Fancy Muthu Saree', hsn: '', rate: 8100, taxPercent: 5, cessPercent: 0, stock: 10, unit: 'Nos' },
                    { name: 'ஃபேன்ஸி முத்து முந்தி கட்டம் சேலை', nameEn: 'Fancy Muthu Mundhi Kattam Saree', hsn: '', rate: 8200, taxPercent: 5, cessPercent: 0, stock: 10, unit: 'Nos' },
                    { name: 'ஃபேன்ஸி கட்டம் புட்டா', nameEn: 'Fancy Checked Butta', hsn: '', rate: 8500, taxPercent: 5, cessPercent: 0, stock: 10, unit: 'Nos' },
                    { name: 'ஃபேன்ஸி கட்டம் புட்டா', nameEn: 'Fancy Checked Butta', hsn: '', rate: 8700, taxPercent: 5, cessPercent: 0, stock: 10, unit: 'Nos' },
                  ];
                  for (const item of TEST_ITEMS) {
                    await saveProduct(item);
                  }
                }
                if (profiles.length === 0 && (!p || !p.niruvanathinPeyar)) {
                  const testProfile = {
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
                  };
                  await saveProfile(testProfile);
                  setProfile(testProfile);
                  setAllProfiles([testProfile]);
                  setShowWelcome(false);
                }
              } catch (e) {
                console.error('Failed to seed test data', e);
              }
            }
          }
          return;
        }
        throw new Error('not ok');
      } catch {
        if (!cancelled) {
          setServerDown(true);
          setServerStatus('offline');
        }
      }
    };

    checkServer();
    // Keep checking every 5 seconds (fast when down, normal heartbeat when up)
    retryTimer.current = setInterval(checkServer, 5000);

    return () => {
      cancelled = true;
      if (retryTimer.current) clearInterval(retryTimer.current);
    };
  }, []);

  // Capture PWA install prompt. Banner re-appears 14 days after dismissal
  // (was: dismissed forever — too aggressive, users who closed it during
  // a busy moment never saw it again).
  useEffect(() => {
    const dismissedAt = localStorage.getItem('elvanniril_pwa_dismissed_at');
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches
      || (window.navigator as any).standalone === true; // iOS Safari
    if (isStandalone) return;
    // 14-day cool-down on dismissal
    if (dismissedAt) {
      const days = (Date.now() - Number(dismissedAt)) / 86400000;
      if (days < 14) return;
    }

    const handler = (e) => {
      e.preventDefault();
      deferredPrompt.current = e;
      setShowInstallBanner(true);
    };
    window.addEventListener('beforeinstallprompt', handler);
    return () => window.removeEventListener('beforeinstallprompt', handler);
  }, []);

  useEffect(() => {
    sessionStorage.setItem('gst_currentView', currentView);
  }, [currentView]);

  useEffect(() => {
    if (editingBill) {
      sessionStorage.setItem('gst_editingBill', JSON.stringify(editingBill));
    } else {
      sessionStorage.removeItem('gst_editingBill');
    }
  }, [editingBill]);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', darkMode ? 'dark' : 'light');
    localStorage.setItem('elvanniril_theme', darkMode ? 'dark' : 'light');
  }, [darkMode]);

  // Load all saved business profiles
  useEffect(() => {
    if (serverStatus === 'online') {
      getAllProfiles().then(setAllProfiles).catch(() => {});
    }
  }, [serverStatus]);

  // Close profile menu on outside click
  useEffect(() => {
    if (!showProfileMenu) return;
    const handler = (e) => {
      if (profileMenuRef.current && !profileMenuRef.current.contains(e.target)) {
        setShowProfileMenu(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [showProfileMenu]);

  const handleSwitchProfile = async (bp) => {
    setShowProfileMenu(false);
    const loaded = { ...bp };
    delete loaded.id;
    await saveProfile(loaded);
    setProfile(loaded);
  };

  const handleNewInvoice = () => {
    sessionStorage.removeItem('gst_invoiceDraft');
    setEditingBill(null);
    setCurrentView('invoice-editor');
  };

  const handleEditInvoice = (bill) => {
    sessionStorage.removeItem('gst_invoiceDraft');
    setEditingBill(bill);
    setCurrentView('invoice-editor');
  };

  const handleDuplicateInvoice = (bill) => {
    sessionStorage.removeItem('gst_invoiceDraft');
    const clone = JSON.parse(JSON.stringify(bill));
    clone._isDuplicate = true;
    setEditingBill(clone);
    setCurrentView('invoice-editor');
  };

  const handleViewInvoice = (bill) => {
    sessionStorage.removeItem('gst_invoiceDraft');
    setEditingBill(bill);
    setCurrentView('invoice-view');
  };

  const handleInstallPWA = async () => {
    if (!deferredPrompt.current) return;
    deferredPrompt.current.prompt();
    const result = await deferredPrompt.current.userChoice;
    if (result.outcome === 'accepted') {
      setShowInstallBanner(false);
    }
    deferredPrompt.current = null;
  };

  const dismissInstallBanner = () => {
    setShowInstallBanner(false);
    // Timestamp-based dismissal — the 14-day cool-down in the install-prompt
    // effect uses this to decide whether to re-show. Old boolean key kept for
    // back-compat with v1.6.0 — readers that find only the legacy key treat
    // it as "permanently dismissed" (same as today's behaviour for them).
    localStorage.setItem('elvanniril_pwa_dismissed_at', String(Date.now()));
  };

  const handleConvertToInvoice = (bill) => {
    sessionStorage.removeItem('gst_invoiceDraft');
    const clone = JSON.parse(JSON.stringify(bill));
    clone._isDuplicate = true;
    clone._convertToType = 'tax-invoice';
    setEditingBill(clone);
    setCurrentView('invoice-editor');
  };

  const mainNavItems = [
    { id: 'dashboard', icon: Home, label: t('home') },
    { id: 'invoice-list', icon: Description, label: t('invoicesCount') || 'Invoices' },
    { id: 'clients', icon: People, label: t('merchants') },
    { id: 'inventory', icon: Inventory, label: t('inventory') },
    { id: 'receipts', icon: Receipt, label: t('receipts') },
  ];

  const accountingItems = [];

  const reportsItems = [
    { id: 'reports', icon: BarChart, label: t('reports') },
    { id: 'gst-returns', icon: Description, label: t('gstReturns') },
  ];

  const allNavItems = [...mainNavItems, ...accountingItems, ...reportsItems].filter(Boolean);

  // KeyboardCommandKey palette actions — declared here (not earlier) because the deps
  // array references `allNavItems` and `handleNewInvoice`, which are consts.
  // Reading a const before its declaration triggers a Temporal Dead Zone
  // ReferenceError ("Cannot access 'Close' before initialization") at runtime.
  const paletteActions = useMemo(() => {
    const acts = [
      { label: 'New Invoice', hint: 'Ctrl+N', run: () => { handleNewInvoice(); } },
    ];
    allNavItems.forEach(item => {
      if (item.id === 'new') return; // already covered above
      acts.push({ label: `Go to ${item.label}`, hint: '', run: item.onClick || (() => setCurrentView(item.id)) });
    });
    acts.push({ label: 'Go to Settings', hint: '', run: () => setCurrentView('settings') });
    acts.push({ label: 'Toggle dark mode', hint: '', run: () => setDarkMode(d => !d) });
    acts.push({ label: 'Show keyboard shortcuts', hint: 'Ctrl+/', run: () => setShowShortcutsHelp(true) });
    if (updateInfo?.updateAvailable) {
      acts.push({ label: `View update — v${updateInfo.latest}`, hint: '', run: () => setShowUpdateModal(true) });
    }
    return acts;
  }, [allNavItems, updateInfo, handleNewInvoice]);

  const filteredPalette = paletteActions.filter(a =>
    !paletteQuery.trim() || a.label.toLowerCase().includes(paletteQuery.toLowerCase())
  );

  // Global keyboard shortcuts. Lives down here for the same TDZ reason —
  // the handler closes over `handleNewInvoice` which is declared above only.
  useEffect(() => {
    const onKey = (e) => {
      const mod = e.ctrlKey || e.metaKey;
      if (!mod) return;
      const tag = (e.target?.tagName || '').toLowerCase();
      const editable = tag === 'input' || tag === 'textarea' || e.target?.isContentEditable;
      if (e.key === 'k' || e.key === 'K') {
        e.preventDefault();
        setShowPalette(p => !p);
        setPaletteQuery('');
        setPaletteIdx(0);
      } else if (e.key === '/') {
        e.preventDefault();
        setShowShortcutsHelp(s => !s);
      } else if ((e.key === 'n' || e.key === 'N') && !editable) {
        e.preventDefault();
        handleNewInvoice();
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Palette-only arrow / Enter / Esc nav. Filtered list dep keeps the
  // handler in sync with the user's current query.
  useEffect(() => {
    if (!showPalette) return;
    const onKey = (e) => {
      if (e.key === 'Escape') { e.preventDefault(); setShowPalette(false); return; }
      if (e.key === 'ArrowDown') { e.preventDefault(); setPaletteIdx(i => Math.min(i + 1, filteredPalette.length - 1)); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); setPaletteIdx(i => Math.max(i - 1, 0)); }
      else if (e.key === 'Enter') {
        e.preventDefault();
        const action = filteredPalette[paletteIdx];
        if (action) { action.run(); setShowPalette(false); }
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [showPalette, paletteIdx, filteredPalette]);

  const muiTheme = useMemo(() => createTheme({
    palette: {
      mode: darkMode ? 'dark' : 'light',
      primary: { main: darkMode ? '#FFFFFF' : '#000000' },
      secondary: { main: darkMode ? '#8E8E93' : '#3C3C43' },
      background: {
        default: darkMode ? '#000000' : '#F3F4F6',
        paper: darkMode ? '#1C1C1E' : '#FFFFFF',
      },
      error: { main: darkMode ? '#FF453A' : '#FF3B30' },
      success: { main: darkMode ? '#32D74B' : '#34C759' },
      warning: { main: darkMode ? '#FF9F0A' : '#FF9500' },
      info: { main: '#3b82f6' },
    },
    typography: {
      fontFamily: '"Elvan Sans", sans-serif',
    },
    shape: {
      borderRadius: 12,
    },
    components: {
      MuiInputBase: {
        styleOverrides: {
          input: {
            fontSize: '16px', // Pre-empt iOS Safari zoom on focus
          }
        }
      },
      MuiTextField: {
        defaultProps: {
          variant: 'filled',
          InputLabelProps: { shrink: true }
        },
        styleOverrides: {
          root: {
            marginTop: 24, // Increased space for the floating label above
          }
        }
      },
      MuiInputLabel: {
        styleOverrides: {
          root: {
            transform: 'translate(16px, -26px) scale(0.85) !important',
            fontWeight: 500, // Reduced from 600 to make it less bold
            color: 'text.secondary',
          }
        }
      },
      MuiFilledInput: {
        styleOverrides: {
          root: {
            borderRadius: 50,
            overflow: 'hidden',
            backgroundColor: 'action.hover',
            '&::before, &::after': {
              display: 'none',
            },
            '&.Mui-focused': {
              backgroundColor: 'action.selected',
            },
            '&.MuiInputBase-multiline': {
              borderRadius: 24,
            }
          },
          input: {
            padding: '12px 24px !important', // Reduced padding since label is no longer inside
            '&:-webkit-autofill, &:-webkit-autofill:hover, &:-webkit-autofill:focus, &:-webkit-autofill:active': {
              transition: 'background-color 5000s ease-in-out 0s',
              WebkitBoxShadow: darkMode ? '0 0 0 100px #262626 inset' : '0 0 0 100px #E8E8E8 inset',
              WebkitTextFillColor: darkMode ? '#fff' : '#000',
              caretColor: darkMode ? '#fff' : '#000',
              borderRadius: 0,
              border: 'none',
              outline: 'none',
            }
          }
        }
      },
      MuiOutlinedInput: {
        styleOverrides: {
          root: {
            borderRadius: 50,
          }
        }
      },
      MuiPickersTextField: {
        defaultProps: {
          variant: 'filled',
        },
        styleOverrides: {
          root: {
            marginTop: 24,
          }
        }
      },
      MuiPickersFilledInput: {
        defaultProps: {
          disableUnderline: true,
        },
        styleOverrides: {
          root: {
            borderRadius: 50,
            overflow: 'hidden',
            backgroundColor: 'action.hover',
            '&::before, &::after': {
              display: 'none',
            },
            '&.Mui-focused': {
              backgroundColor: 'action.selected',
            },
            paddingRight: '20px',
          },
          sectionsContainer: {
            padding: '12px 24px !important',
          }
        }
      },
      MuiDatePicker: {
        defaultProps: {
          slots: {
            openPickerIcon: () => <CalendarDots size={20} weight="duotone" />,
          },
        },
      },
      MuiButton: {
        styleOverrides: {
          root: {
            borderRadius: 50,
            textTransform: 'none',
            fontWeight: 600,
            padding: '8px 24px',
            '@media (max-width:600px)': {
              minHeight: 48,
            }
          }
        }
      },
      MuiListItemButton: {
        styleOverrides: {
          root: {
            '@media (max-width:600px)': {
              minHeight: 48,
            }
          }
        }
      },
      MuiAutocomplete: {
        styleOverrides: {
          inputRoot: {
            paddingTop: '0px !important',
            paddingBottom: '0px !important',
            paddingLeft: '0px !important',
            paddingRight: '40px !important',
          }
        }
      },
      MuiPaginationItem: {
        styleOverrides: {
          root: {
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            paddingTop: '2px',
          }
        }
      },
      MuiButtonBase: {
        styleOverrides: {
          root: {
            ...(darkMode && {
              '& .MuiTouchRipple-child': {
                backgroundColor: 'rgba(0, 0, 0, 0.8)'
              }
            })
          }
        }
      },
      MuiCardActionArea: {
        styleOverrides: {
          focusHighlight: {
            ...(darkMode && {
              backgroundColor: 'rgba(0, 0, 0, 0.5)'
            })
          }
        }
      }
    }
  }), [darkMode]);

  if (serverDown) {
    return (
      <Backdrop open={true} sx={{ color: '#fff', zIndex: 9999, flexDirection: 'column', bgcolor: 'rgba(0,0,0,0.85)' }}>
        <Box sx={{ bgcolor: 'background.paper', color: 'text.primary', p: 4, borderRadius: 3, maxWidth: 500, width: '90%', textAlign: 'center', boxShadow: 24 }}>
          <Box sx={{ display: 'flex', justifyContent: 'center', mb: 2 }}>
            <Description size={48} weight="regular" color="#3b82f6" />
          </Box>
          <Typography variant="h5" sx={{ fontWeight: 700 }} gutterBottom>
            Elvan Niril Needs a Quick Start
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Your data is <strong>{t('hc_100Safe')}</strong> on your computer — nothing is lost.
            The app just needs to be started once.
          </Typography>
          <Button variant="contained" color="primary" href="elvanniril://start" sx={{ textTransform: 'none', mb: 3 }}>
            Open GST Billing
          </Button>
          <Box sx={{ textAlign: 'left', bgcolor: 'action.hover', p: 2, borderRadius: 2, mb: 3 }}>
            <Typography variant="caption" gutterBottom sx={{ fontWeight: 600, display: 'block' }}>{t('hc_orStartManually')}</Typography>
            <Typography variant="caption" sx={{ display: 'block' }}>{t('hc_1Doubleclick')}<strong>Elvan Niril</strong>{t('hc_onYourDesktop')}</Typography>
            <Typography variant="caption" sx={{ display: 'block' }}>{t('hc_2OrSearch')}<strong>"Elvan Niril"</strong>{t('hc_inStartMenu')}</Typography>
          </Box>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 2 }}>
            All your invoices, clients, and data are safely stored on your computer. They are never deleted or shared.
          </Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 1.5, color: 'text.secondary' }}>
            <CircularProgress size={16} color="inherit" />
            <Typography variant="caption">{t('hc_startingThisPageWillOpen')}</Typography>
          </Box>
        </Box>
      </Backdrop>
    );
  }

  if (showWelcome) {
    return (
      <>
        <Nalvaravu onComplete={(p) => {
          if (p) setProfile(p);
          setShowWelcome(false);
        }} />
        <Thagaval />
      </>
    );
  }

    
  const isEditorView = ['client-editor', 'product-editor', 'invoice-editor', 'receipt-editor', 'invoice-view', 'receipt-view'].includes(currentView);
  const isPrintView = ['invoice-view', 'receipt-view'].includes(currentView);
    
  const getTopBarTitle = () => {
    if (currentView === 'dashboard') return t('appName');
    if (currentView === 'settings') return t('settingsTitle');
    if (currentView === 'invoice-editor' || currentView === 'invoice-view') return t('invoices');
    if (currentView === 'receipt-editor' || currentView === 'receipt-view') return t('receipts');
    const navItem = allNavItems.find(item => item && item.id === currentView);
    return navItem ? navItem.label : t('appName');
  };

  return (
    <ThemeProvider theme={muiTheme}>
      <CssBaseline />
      
      {/* Dev-only floating blank state toggle */}
      <IconButton 
        onClick={() => {
          const isBlank = sessionStorage.getItem('__DEV_BLANK_STATE__') === 'true';
          sessionStorage.setItem('__DEV_BLANK_STATE__', isBlank ? 'false' : 'true');
          window.location.reload();
        }}
        sx={{ 
          position: 'fixed', top: 12, right: 56, zIndex: 9999, 
          bgcolor: sessionStorage.getItem('__DEV_BLANK_STATE__') === 'true' ? 'rgba(255,69,58,0.8)' : (darkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)'),
          backdropFilter: 'blur(8px)', width: 32, height: 32,
          '&:hover': { bgcolor: sessionStorage.getItem('__DEV_BLANK_STATE__') === 'true' ? 'rgba(255,69,58,1)' : (darkMode ? 'rgba(255,255,255,0.2)' : 'rgba(0,0,0,0.1)') }
        }}
        title="Toggle Blank State (Dev Only)"
      >
        <div style={{ width: 12, height: 12, borderRadius: '50%', border: '2px solid', borderColor: darkMode ? "#ffffff" : "#000000" }} />
      </IconButton>

      {/* Dev-only floating dark mode toggle */}
      <IconButton 
        onClick={() => setDarkMode(!darkMode)}
        sx={{ 
          position: 'fixed', top: 12, right: 16, zIndex: 9999, 
          bgcolor: darkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)',
          backdropFilter: 'blur(8px)', width: 32, height: 32,
          '&:hover': { bgcolor: darkMode ? 'rgba(255,255,255,0.2)' : 'rgba(0,0,0,0.1)' }
        }}
        title="Toggle Theme (Dev Only)"
      >
        {darkMode ? <LightMode size={16} weight="bold" color="#ffffff" /> : <DarkMode size={16} weight="bold" color="#000000" />}
      </IconButton>
      <Box sx={{ display: 'flex', height: '100vh', overflow: 'hidden' }}>
        <Pakkapatti
          mobileOpen={mobileOpen}
          handleDrawerToggle={handleDrawerToggle}
          isCollapsed={isCollapsed}
          setIsCollapsed={setIsCollapsed}
        currentView={currentView}
        setCurrentView={setCurrentView}
        mainNavItems={mainNavItems}
        accountingItems={accountingItems}
        reportsItems={reportsItems}
        updateBannerVisible={updateBannerVisible}
        updateInfo={updateInfo}
        setShowUpdateModal={setShowUpdateModal}

        darkMode={darkMode}
        setDarkMode={setDarkMode}
        serverStatus={serverStatus}
        profile={profile}
        allProfiles={allProfiles}
        showProfileMenu={showProfileMenu}
        setShowProfileMenu={setShowProfileMenu}
        handleSwitchProfile={handleSwitchProfile}
      />


      <Box component="main" sx={{ 
        flexGrow: 1, 
        display: 'flex', 
        flexDirection: 'column', 
        height: '100vh', 
        overflow: 'hidden',
        bgcolor: { xs: darkMode ? '#000000' : '#F3F4F6', md: 'background.default' } 
      }}>
        {/* New Mobile AMOLED Top Bar */}
        <Box sx={{ display: { xs: 'flex', md: 'none' }, px: 2, py: 1.5, alignItems: 'center', justifyContent: 'space-between', bgcolor: 'transparent', zIndex: 1100, minHeight: 64 }}>
          <Box id="mobile-topbar-left" sx={{ display: 'flex', alignItems: 'center' }} />
          {!isEditorView && (
            <Typography variant="h6" sx={{ ml: 1.5, fontWeight: 800, fontSize: '1.25rem', letterSpacing: '-0.5px', color: darkMode ? '#FFFFFF' : '#000000', flexGrow: 1 }}>
              {getTopBarTitle()}
            </Typography>
          )}
          <Box id="mobile-topbar-right" sx={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end' }}>
            {currentView === 'dashboard' && (
              <Stack direction="row" spacing={0.5}>
                <IconButton onClick={() => setCurrentView('reports')} sx={{ 
                  color: currentView === 'reports' ? 'primary.main' : (darkMode ? '#aaa' : '#666'),
                  '&:active svg': { transform: 'scale(0.85)' },
                  '& svg': { transition: 'transform 0.15s cubic-bezier(0.4, 0, 0.2, 1)' }
                }}>
                  <BarChart size={24} weight={currentView === 'reports' ? "fill" : "regular"} />
                </IconButton>
                <IconButton onClick={() => setCurrentView('gst-returns')} sx={{ 
                  color: currentView === 'gst-returns' ? 'primary.main' : (darkMode ? '#aaa' : '#666'),
                  '&:active svg': { transform: 'scale(0.85)' },
                  '& svg': { transition: 'transform 0.15s cubic-bezier(0.4, 0, 0.2, 1)' }
                }}>
                  <Description size={24} weight={currentView === 'gst-returns' ? "fill" : "regular"} />
                </IconButton>
                <IconButton onClick={() => setCurrentView('settings')} sx={{ 
                  color: currentView === 'settings' ? 'primary.main' : (darkMode ? '#aaa' : '#666'),
                  '&:active svg': { transform: 'scale(0.85)' },
                  '& svg': { transition: 'transform 0.15s cubic-bezier(0.4, 0, 0.2, 1)' }
                }}>
                  <Settings size={24} weight={currentView === 'settings' ? "fill" : "regular"} />
                </IconButton>
              </Stack>
            )}
          </Box>
        </Box>

        {/* Global Floating Shell */}
        <Box sx={{ 
          flexGrow: 1, 
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          mx: { xs: isPrintView ? 0 : 1.5, md: 0 },
          mb: { xs: isPrintView ? 0 : (isEditorView ? 1.5 : '85px'), md: 0 }, // Stops before bottom nav or gives small bottom gap
          borderRadius: { xs: isPrintView ? 0 : '24px', md: 0 },
          bgcolor: { xs: darkMode ? '#000000' : '#F3F4F6', md: 'transparent' },
          boxShadow: { xs: darkMode ? 'none' : '0 8px 30px rgba(0,0,0,0.04)', md: 'none' }
        }}>
          {/* Inner scrollable area inside the shell */}
          <Box sx={{ 
            flexGrow: 1, 
            overflowY: 'scroll',
            pb: { xs: isPrintView ? 0 : 2, md: 0 } // small padding at the bottom of the scroll inside the shell
          }}>
          {currentView === 'dashboard' && (
          <Mugappu onViewAll={() => setCurrentView('invoice-list')} onNew={handleNewInvoice} onEdit={handleViewInvoice} onDuplicate={handleDuplicateInvoice} onConvert={handleConvertToInvoice} profile={profile} />
        )}
        {currentView === 'invoice-editor' && (
          <InvoiceEditor
            onBack={() => {
              if (editingBill && !editingBill._isDuplicate) {
                setCurrentView('invoice-view');
              } else {
                setEditingBill(null);
                setCurrentView('invoice-list');
              }
            }}
            onSaved={(bill) => { setEditingBill(bill); setCurrentView('invoice-view'); }}
            profile={profile} editingBill={editingBill}
          />
        )}
        {currentView === 'invoice-view' && editingBill && (
          <InvoiceView
            bill={editingBill}
            profile={profile}
            onBack={() => { setEditingBill(null); setCurrentView('invoice-list'); }}
            onEdit={handleEditInvoice}
            onDuplicate={handleDuplicateInvoice}
          />
        )}
        {currentView === 'invoice-view' && !editingBill && (
           <Mugappu onViewAll={() => setCurrentView('invoice-list')} onNew={handleNewInvoice} onEdit={handleViewInvoice} onDuplicate={handleDuplicateInvoice} onConvert={handleConvertToInvoice} profile={profile} />
        )}
        {currentView === 'invoice-list' && (
          <InvoiceList onNew={handleNewInvoice} onView={handleViewInvoice} onDuplicate={handleDuplicateInvoice} profile={profile} />
        )}
        {currentView === 'clients' && (
          <Vanigargal onNew={handleNewInvoice} onEdit={handleEditInvoice} onDuplicate={handleDuplicateInvoice} profile={profile}
            onAddClient={(prefill) => { setEditingClient(prefill); setCurrentView('client-editor'); }}
            onEditClient={(client) => { setEditingClient(client); setCurrentView('client-editor'); }} 
          />
        )}
        {currentView === 'client-editor' && (
          <VanigarThoguppu 
            client={editingClient} 
            onBack={() => { setEditingClient(null); setCurrentView('clients'); }} 
            onSaved={(client) => { setEditingClient(null); setCurrentView('clients'); }} 
            profileSettings={profile} 
            defaultCountry={profile?.country}
          />
        )}
        {currentView === 'inventory' && (
          <Porul 
            onAddProduct={() => { setEditingProduct(null); setCurrentView('product-editor'); }}
            onEditProduct={(p) => { setEditingProduct(p); setCurrentView('product-editor'); }} 
            profile={profile}
          />
        )}
        {currentView === 'product-editor' && (
          <PorulThoguppu 
            product={editingProduct} 
            onBack={() => { setEditingProduct(null); setCurrentView('inventory'); }} 
            onSaved={(p) => { setEditingProduct(null); setCurrentView('inventory'); }} 
            profileSettings={profile} 
            defaultCountry={profile?.country}
          />
        )}


        {currentView === 'receipts' && (
          <Raseedhu 
            profile={profile} 
            onAddReceipt={() => { setEditingReceipt(null); setCurrentView('receipt-editor'); }} 
            onEditReceipt={(rcp) => { setEditingReceipt(rcp); setCurrentView('receipt-editor'); }} 
            onViewReceipt={(rcp) => { setEditingReceipt(rcp); setCurrentView('receipt-view'); }}
          />
        )}
        {currentView === 'receipt-editor' && (
          <ReceiptEditor 
            profile={profile} 
            editingReceipt={editingReceipt} 
            onBack={() => { setEditingReceipt(null); setCurrentView('receipts'); }} 
            onSaved={() => { setEditingReceipt(null); setCurrentView('receipts'); }} 
          />
        )}
        {currentView === 'receipt-view' && editingReceipt && (
          <ReceiptView
            receipt={editingReceipt}
            profile={profile}
            onBack={() => { setEditingReceipt(null); setCurrentView('receipts'); }}
            onEdit={(rcp) => { setEditingReceipt(rcp); setCurrentView('receipt-editor'); }}
          />
        )}
        {currentView === 'reports' && (
          <Arikkaigal />
        )}
        {currentView === 'gst-returns' && (
          <VariArikkaigal profile={profile} />
        )}

        {currentView === 'settings' && (
          <Amaippugal onSaved={(p) => setProfile(p)} />
        )}
          </Box>
        </Box>
        
        {/* New Mobile AMOLED Bottom Navigation */}
        {!isEditorView && (
        <Box sx={{ 
          display: { xs: 'flex', md: 'none' }, 
          position: 'fixed', bottom: 0, left: 0, right: 0, 
          bgcolor: darkMode ? '#000000' : '#F3F4F6', 
          borderTop: 'none',
          px: 1, pt: 1.5, pb: 'calc(env(safe-area-inset-bottom, 0px) + 16px)',
          justifyContent: 'space-around', alignItems: 'center', zIndex: 1100
        }}>
          {[
            { id: 'dashboard', icon: Home, label: t('home') },
            { id: 'invoice-list', icon: Description, label: t('invoices') },
            { id: 'clients', icon: People, label: t('merchants') },
            { id: 'inventory', icon: Inventory, label: t('inventory') },
            { id: 'receipts', icon: Receipt, label: t('receipts') },
          ].map((item) => {
            const isActive = currentView === item.id;
            return (
              <Box 
                key={item.id}
                onClick={() => setCurrentView(item.id as any)}
                sx={{
                  display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                  width: '64px', cursor: 'pointer',
                  userSelect: 'none',
                  WebkitTapHighlightColor: 'transparent',
                  color: isActive ? (darkMode ? '#FFFFFF' : 'primary.main') : 'text.secondary',
                  '&:active .nav-icon-pill svg': {
                    transform: 'scale(0.85)',
                  }
                }}
              >
                <Box 
                  className="nav-icon-pill"
                  sx={{
                    px: 2.2, py: 0.4, mb: 0.5, borderRadius: '16px',
                    bgcolor: isActive ? (darkMode ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)') : 'transparent',
                    transition: 'all 0.2s cubic-bezier(0.25, 1, 0.5, 1)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    transform: 'scale(1)',
                    '& svg': {
                      transition: 'transform 0.15s cubic-bezier(0.4, 0, 0.2, 1)',
                    }
                  }}
                >
                  <item.icon size={24} weight={isActive ? "fill" : "regular"} />
                </Box>
                <Typography variant="caption" sx={{ fontSize: '0.65rem', fontWeight: isActive ? 700 : 500, opacity: isActive ? 1 : 0.8 }}>
                  {item.label}
                </Typography>
              </Box>
            );
          })}
        </Box>
        )}

        {/* Mobile squircle FAB for page-specific adding actions */}
        {['dashboard', 'invoice-list', 'clients', 'inventory', 'receipts'].includes(currentView as string) && (
          <Button
            variant="contained"
            color="primary"
            onClick={() => {
              if (currentView === 'clients') {
                setEditingClient(null);
                setCurrentView('client-editor');
              } else if (currentView === 'inventory') {
                setEditingProduct(null);
                setCurrentView('product-editor');
              } else if (currentView === 'receipts') {
                setEditingReceipt(null);
                setCurrentView('receipt-editor');
              } else {
                handleNewInvoice();
              }
            }}
            sx={{
              display: { xs: 'flex', md: 'none' },
              position: 'fixed',
              bottom: 'calc(env(safe-area-inset-bottom, 0px) + 95px)',
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
            <Add size={28} weight="bold" />
          </Button>
        )}
      </Box>

      {/* Update modal — release notes + Export-backup-first nudge + Update Now */}
      {/* Notification popover — rendered as a click-out modal so it works on
          tablets too. Grouped by category with a navigate-to button per group. */}


      {/* KeyboardCommandKey palette — Ctrl/Cmd+K */}
      <ResponsiveDialog open={showPalette} onClose={() => setShowPalette(false)}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 1.5, borderBottom: '1px solid', borderColor: 'divider' }}>
          <Search size={20} weight="regular" />
          <InputBase
            autoFocus
            placeholder={t('hc_typeACommandOrPage')}
            value={paletteQuery}
            onChange={e => { setPaletteQuery(e.target.value); setPaletteIdx(0); }}
            sx={{ flex: 1, fontSize: '1rem' }}
          />
          <Typography variant="caption" color="text.secondary">Esc</Typography>
        </Box>
        <List sx={{ maxHeight: 360, overflowY: 'auto', p: 0 }}>
          {filteredPalette.length === 0 && (
            <Box sx={{ p: 3, textAlign: 'center' }}>
              <Typography variant="body2" color="text.secondary">Nothing matches "{paletteQuery}".</Typography>
            </Box>
          )}
          {filteredPalette.map((a, i) => (
            <ListItemButton
              key={a.label}
              onClick={() => { a.run(); setShowPalette(false); }}
              onMouseEnter={() => setPaletteIdx(i)}
              selected={i === paletteIdx}
              sx={{ py: 1.5, '&.Mui-selected': { bgcolor: 'action.selected' } }}
            >
              <ListItemText primary={<Typography variant="body2">{a.label}</Typography>} />
              {a.hint && <Typography variant="caption" color="text.secondary">{a.hint}</Typography>}
            </ListItemButton>
          ))}
        </List>
        <Box sx={{ p: 1.5, borderTop: '1px solid', borderColor: 'divider', display: 'flex', justifyContent: 'space-between', alignItems: 'center', bgcolor: 'background.default' }}>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', alignItems: 'center' }}>
            <KeyboardCommandKey size={14} weight="regular" style={{ marginRight: 4 }} /> Ctrl+K to toggle · ↑↓ navigate · Enter run
          </Typography>
          <Button size="small" variant="text" onClick={() => { setShowPalette(false); setShowShortcutsHelp(true); }} sx={{ textTransform: 'none', fontSize: '0.75rem' }}>
            All shortcuts (Ctrl+/)
          </Button>
        </Box>
      </ResponsiveDialog>

      {/* Keyboard-shortcuts help — Ctrl/Cmd+/. Single-pane reference. */}
      <ResponsiveDialog open={showShortcutsHelp} onClose={() => setShowShortcutsHelp(false)}>
        <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          Keyboard Shortcuts
          <IconButton onClick={() => setShowShortcutsHelp(false)} size="small"><Close size={18} weight="regular" /></IconButton>
        </DialogTitle>
        <DialogContent dividers>
          <List dense>
            {[
              { k: 'Ctrl + K', v: 'Open command palette (jump to any page)' },
              { k: 'Ctrl + N', v: 'New invoice' },
              { k: 'Ctrl + S', v: 'Save current invoice (when on the invoice form)' },
              { k: 'Ctrl + P', v: 'Download PDF (when on the invoice form)' },
              { k: 'Ctrl + /', v: 'Toggle this help' },
              { k: 'Esc', v: 'Close any open modal' }
            ].map((shortcut, i) => (
              <ListItem key={i} sx={{ px: 0, py: 0.5 }}>
                <ListItemText primary={<Typography variant="body2" sx={{ fontFamily: 'monospace', bgcolor: 'action.hover', px: 1, py: 0.5, borderRadius: 1, display: 'inline-block' }}>{shortcut.k}</Typography>} sx={{ flex: '0 0 120px' }} />
                <ListItemText primary={<Typography variant="body2">{shortcut.v}</Typography>} />
              </ListItem>
            ))}
          </List>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 2 }}>
            On macOS, use ⌘ instead of Ctrl.
          </Typography>
        </DialogContent>
      </ResponsiveDialog>

      {showUpdateModal && updateInfo && (
        <ResponsiveDialog open={showUpdateModal} onClose={() => setShowUpdateModal(false)}>
          <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <Box>
              <Typography variant="h6" sx={{ fontWeight: 700 }}>
                Update available — v{updateInfo.latest}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                You're on v{updateInfo.current}
                {updateInfo.releasePublishedAt && ` · released ${new Date(updateInfo.releasePublishedAt).toLocaleDateString()}`}
              </Typography>
            </Box>
            <IconButton onClick={() => setShowUpdateModal(false)} size="small" sx={{ mt: -0.5, mr: -0.5 }}><Close size={20} weight="regular" /></IconButton>
          </DialogTitle>
          <DialogContent dividers sx={{ pb: 3 }}>
            {/* Data-safety reassurance */}
            <Box sx={{ display: 'flex', gap: 1.5, p: 2,  borderRadius: 2, mb: 2, bgcolor: 'rgba(59, 130, 246, 0.1)', color: 'info.main' }}>
              <Typography variant="body1">🔒</Typography>
              <Typography variant="body2">
                <strong>{t('hc_yourDataIsSafe')}</strong>{t('hc_updatesOnlyRefreshTheApp')}<code>data/</code> folder (invoices, clients, products, settings) and <code>Saved Invoices/</code>{t('hc_pdfArchiveAre')}<strong>{t('hc_neverTouched')}</strong>. The updater pulls the latest source from GitHub and rebuilds, then restarts.
              </Typography>
            </Box>

            {/* Release notes */}
            <Box sx={{ p: 2, bgcolor: 'background.default', borderRadius: 2, mb: 2, maxHeight: 200, overflowY: 'auto', border: '1px solid', borderColor: 'divider' }}>
              <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap' }}>
                {updateInfo.releaseNotes || (
                  <span style={{ color: 'var(--text-muted)' }}>
                    No release notes available — see the full changelog at{' '}
                    <a href={updateInfo.releaseUrl || 'https://github.com/ElvanParthasarathy/Niril/releases'} target="_blank" rel="noopener noreferrer" style={{ color: 'inherit' }}>{t('hc_githubReleases')}</a>.
                  </span>
                )}
              </Typography>
            </Box>

            {/* Suggested pre-update step: export a backup */}
            <Box sx={{ display: 'flex', gap: 1.5, p: 2,  borderRadius: 2, mb: 1, bgcolor: 'rgba(245, 158, 11, 0.1)', color: 'warning.main' }}>
              <Typography variant="body1">💡</Typography>
              <Typography variant="body2">
                <strong>{t('hc_recommended')}</strong> export a backup before updating, just in case.{' '}
                <Box component="span" onClick={() => { setShowUpdateModal(false); setCurrentView('settings'); }} sx={{ cursor: 'pointer', textDecoration: 'underline', fontWeight: 600 }}>Open Settings → Data Management</Box>{' '}
                and click <em>{t('hc_exportBackup')}</em>.
              </Typography>
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2, pt: 1.5, flexDirection: 'column', alignItems: 'stretch' }}>
            <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end', flexWrap: 'wrap', width: '100%' }}>
              <Button onClick={dismissUpdate} color="inherit">{t('hc_skipThisVersion')}</Button>
              <Button onClick={() => setShowUpdateModal(false)} color="inherit">Remind me later</Button>
              {updateInfo.releaseUrl && (
                <Button href={updateInfo.releaseUrl} target="_blank" color="inherit">{t('hc_viewOnGithub')}</Button>
              )}
              <Button variant="contained" color="primary" href="elvanniril-update://run" startIcon={<Download size={16} weight="regular" />}>{t('hc_updateNow')}</Button>
            </Box>
            <Typography variant="caption" color="text.secondary" sx={{ mt: 1.5, textAlign: 'right' }}>
              <em>{t('hc_updateNow')}</em>{t('hc_launches')}<code>Update ElvanNiril.bat</code> in a window. Wait for it to finish (~30 seconds), then refresh this page.
            </Typography>
          </DialogActions>
        </ResponsiveDialog>
      )}

      <Thagaval />

      {/* ── DEV: Floating bilingual language switcher ── */}
      <DevLanguageSwitcher profile={profile} setProfile={setProfile} language={language} setLanguage={setLanguage} />

      </Box>
    </ThemeProvider>
  );
}

export default Seyali;
