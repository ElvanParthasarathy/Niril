// @ts-nocheck
// File-based storage via local Express API server
// All data persists as JSON files in the ./data/ folder

const API = '/api';

async function apiFetch(url, options = {}) {
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) throw new Error(`API error: ${res.status}`);
  return res.json();
}

// ---- Invoice Number Settings ----
const DEFAULT_INV_SETTINGS = {
  format: 'branded',      // 'branded' | 'sequential' | 'random'
  brandPrefix: '',         // e.g. 'ACME' — empty means use type prefix (INV/EST/CN/BOS)
  separator: '/',          // '/' | '-' | '#'
  showFinYear: true,       // include 2026-27 financial year
  startNumber: 1,          // starting counter value
  padDigits: 4,            // zero-pad to this many digits
};

export const getInvoiceNumberSettings = async () => {
  const { value } = await apiFetch(`${API}/meta/invoiceNumberSettings`);
  return { ...DEFAULT_INV_SETTINGS, ...(value || {}) };
};

export const saveInvoiceNumberSettings = async (settings) => {
  await apiFetch(`${API}/meta/invoiceNumberSettings`, {
    method: 'POST',
    body: JSON.stringify({ value: settings }),
  });
};

const DEFAULT_RCP_SETTINGS = {
  format: 'branded',
  brandPrefix: 'RCP',
  separator: '/',
  showFinYear: true,
  startNumber: 1,
  padDigits: 4,
};

export const getReceiptNumberSettings = async () => {
  const { value } = await apiFetch(`${API}/meta/receiptNumberSettings`);
  return { ...DEFAULT_RCP_SETTINGS, ...(value || {}) };
};

export const saveReceiptNumberSettings = async (settings) => {
  await apiFetch(`${API}/meta/receiptNumberSettings`, {
    method: 'POST',
    body: JSON.stringify({ value: settings }),
  });
};

// ---- Language-Tagged Data Storage Helpers ----
const isBlankState = () => typeof window !== 'undefined' && window.sessionStorage.getItem('__DEV_BLANK_STATE__') === 'true';

const getLangConfig = async () => {
  try {
    const profile = await apiFetch(`${API}/profile`);
    return {
      primary: profile?.primaryDataLanguage || 'Tamil',
      secondary: profile?.secondaryDataLanguage || 'English'
    };
  } catch {
    return { primary: 'Tamil', secondary: 'English' };
  }
};

const prepareForStorage = async (item, fields) => {
  const { primary, secondary } = await getLangConfig();
  const out = { ...item };
  fields.forEach(f => {
    if (out[f] !== undefined) out[`${f}_${primary}`] = out[f];
    if (out[`${f}En`] !== undefined) out[`${f}_${secondary}`] = out[`${f}En`];
  });
  return out;
};

const restoreFromStorage = async (items, fields) => {
  const { primary, secondary } = await getLangConfig();
  return items.map(item => {
    const out = { ...item };
    fields.forEach(f => {
      const hasAnyTag = Object.keys(item).some(k => k.startsWith(`${f}_`));
      if (hasAnyTag) {
        out[f] = out[`${f}_${primary}`] !== undefined ? out[`${f}_${primary}`] : '';
        out[`${f}En`] = out[`${f}_${secondary}`] !== undefined ? out[`${f}_${secondary}`] : '';
      } else {
        if (out[`${f}_${primary}`] !== undefined) out[f] = out[`${f}_${primary}`];
        if (out[`${f}_${secondary}`] !== undefined) out[`${f}En`] = out[`${f}_${secondary}`];
      }
    });
    return out;
  });
};

const restoreSingleFromStorage = async (item, fields) => {
  if (!item) return item;
  const items = await restoreFromStorage([item], fields);
  return items[0];
};

// ---- Invoice Display Options (checkboxes like showGST, showLogo etc.) ----
export const getInvoiceDisplayOptions = async () => {
  const { value } = await apiFetch(`${API}/meta/invoiceDisplayOptions`);
  return value || null;
};

export const saveInvoiceDisplayOptions = async (options) => {
  await apiFetch(`${API}/meta/invoiceDisplayOptions`, {
    method: 'POST',
    body: JSON.stringify({ value: options }),
  });
};





// ---- Invoice counter ----
// Uses the atomic /meta/:key/increment endpoint so two concurrent saves can't both
// read 5 and both write 6 (= duplicate invoice numbers, which is a GST audit failure).
export const getNextInvoiceNumber = async (prefix = 'INV') => {
  const settings = await getInvoiceNumberSettings();
  const key = `counter_${prefix}`;
  const { value: next } = await apiFetch(`${API}/meta/${key}/increment`, { method: 'POST', body: JSON.stringify({}) });

  if (settings.format === 'random') {
    const rand = Math.random().toString(36).substring(2, 8).toUpperCase();
    const pfx = settings.brandPrefix || prefix;
    return `${pfx}${settings.separator}${rand}`;
  }

  const sep = settings.separator || '/';
  const pfx = settings.brandPrefix || prefix;
  const padded = String(next).padStart(settings.padDigits || 4, '0');

  if (settings.showFinYear) {
    const currentYear = new Date().getFullYear();
    const nextYear = (currentYear + 1).toString().slice(-2);
    return `${pfx}${sep}${currentYear}-${nextYear}${sep}${padded}`;
  }

  return `${pfx}${sep}${padded}`;
};

// ---- Bills ----
export const saveBill = async (bill) => {
  const taggedBill = { ...bill };
  if (taggedBill.client) taggedBill.client = await prepareForStorage(taggedBill.client, ['name', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country']);
  if (taggedBill.items && Array.isArray(taggedBill.items)) {
    taggedBill.items = await Promise.all(taggedBill.items.map(async item => prepareForStorage(item, ['name', 'description'])));
  }
  return apiFetch(`${API}/pattiyalkal`, { method: 'POST', body: JSON.stringify(taggedBill) });
};

export const getAllBills = async () => {
  if (isBlankState()) return [];
  const bills = await apiFetch(`${API}/pattiyalkal`);
  return Promise.all(bills.map(async bill => {
    const b = { ...bill };
    if (b.client) b.client = await restoreSingleFromStorage(b.client, ['name', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country']);
    if (b.items && Array.isArray(b.items)) {
      b.items = await restoreFromStorage(b.items, ['name', 'description']);
    }
    return b;
  }));
};

export const deleteBill = async (id) => {
  return apiFetch(`${API}/pattiyalkal/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Profile ----
export const saveProfile = async (profile) => {
  const taggedProfile = await prepareForStorage(profile, ['niruvanathinPeyar', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country', 'bankName', 'branch', 'terms']);
  const result = await apiFetch(`${API}/profile`, { method: 'POST', body: JSON.stringify(taggedProfile) });
  window.dispatchEvent(new Event('profileUpdated'));
  return result;
};

export const getProfile = async () => {
  if (isBlankState()) return {};
  const profile = await apiFetch(`${API}/profile`);
  return restoreSingleFromStorage(profile, ['niruvanathinPeyar', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country', 'bankName', 'branch', 'terms']);
};

// ---- Saved Clients ----
export const saveClient = async (client) => {
  const taggedClient = await prepareForStorage(client, ['name', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country']);
  const res = await apiFetch(`${API}/vanigargal`, { method: 'POST', body: JSON.stringify(taggedClient) });
  if (res.id) client.id = res.id;
  return client;
};

export const getAllClients = async () => {
  if (isBlankState()) return [];
  const clients = await apiFetch(`${API}/vanigargal`);
  return restoreFromStorage(clients, ['name', 'mugavari', 'oor', 'maavattam', 'maanilam', 'country']);
};

export const deleteClient = async (id) => {
  return apiFetch(`${API}/vanigargal/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Coolie Clients / Merchants ----
export const getAllCoolieClients = async () => {
  if (isBlankState()) return [];
  const clients = await apiFetch(`${API}/coolie_vanigargal`);
  return restoreFromStorage(clients, ['name', 'city', 'address1']);
};

export const saveCoolieClient = async (client) => {
  const taggedClient = await prepareForStorage(client, ['name', 'city', 'address1']);
  const res = await apiFetch(`${API}/coolie_vanigargal`, { method: 'POST', body: JSON.stringify(taggedClient) });
  if (res.id) client.id = res.id;
  return client;
};

export const deleteCoolieClient = async (id) => {
  return apiFetch(`${API}/coolie_vanigargal/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Coolie Profiles / Settings ----
export const getAllCoolieProfiles = async () => {
  if (isBlankState()) return [];
  const profiles = await apiFetch(`${API}/coolie_suya_vivaram`);
  return restoreFromStorage(profiles, [
    'name', 'address', 'city', 'district', 'bankName', 'branch', 'email'
  ]);
};

export const saveCoolieProfile = async (profile) => {
  const taggedProfile = await prepareForStorage(profile, [
    'name', 'address', 'city', 'district', 'bankName', 'branch', 'email'
  ]);
  const res = await apiFetch(`${API}/coolie_suya_vivaram`, { method: 'POST', body: JSON.stringify(taggedProfile) });
  if (res.id) profile.id = res.id;
  return profile;
};

export const deleteCoolieProfile = async (id) => {
  return apiFetch(`${API}/coolie_suya_vivaram/${encodeURIComponent(id)}`, { method: 'DELETE' });
};


// ---- Products / Inventory ----
export const getAllProducts = async () => {
  if (isBlankState()) return [];
  const products = await apiFetch(`${API}/porulgal`);
  return restoreFromStorage(products, ['name', 'description']);
};

export const saveProduct = async (product) => {
  const taggedProduct = await prepareForStorage(product, ['name', 'description']);
  const res = await apiFetch(`${API}/porulgal`, { method: 'POST', body: JSON.stringify(taggedProduct) });
  if (res.id) product.id = res.id;
  return product;
};

export const deleteProduct = async (id) => {
  return apiFetch(`${API}/porulgal/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Coolie Products / Inventory ----
export const getAllCoolieProducts = async () => {
  if (isBlankState()) return [];
  const products = await apiFetch(`${API}/coolie_porulgal`);
  return restoreFromStorage(products, ['name', 'description']);
};

export const saveCoolieProduct = async (product) => {
  const taggedProduct = await prepareForStorage(product, ['name', 'description']);
  const res = await apiFetch(`${API}/coolie_porulgal`, { method: 'POST', body: JSON.stringify(taggedProduct) });
  if (res.id) product.id = res.id;
  return product;
};

export const deleteCoolieProduct = async (id) => {
  return apiFetch(`${API}/coolie_porulgal/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Coolie Bills ----
export const getAllCoolieBills = async () => {
  if (isBlankState()) return [];
  const bills = await apiFetch(`${API}/coolie_pattiyalkal`);
  return bills || [];
};

export const getNextCoolieBillNumber = async (companyId: string) => {
  if (isBlankState()) return '1';
  try {
    const profiles = await getAllCoolieProfiles();
    const profile = profiles.find((p: any) => p.id === companyId);
    const prefix = profile?.shortBusinessName || profile?.name || 'CB';

    const bills = await apiFetch(`${API}/coolie_pattiyalkal`);
    if (!bills || !Array.isArray(bills)) {
      return `${prefix}-01`;
    }

    const companyBills = bills.filter((b: any) => b.company_id === companyId);
    if (companyBills.length === 0) {
      return `${prefix}-01`;
    }

    const maxNo = Math.max(...companyBills.map((b: any) => {
      const match = String(b.bill_no).match(/\d+/);
      return match ? parseInt(match[0], 10) : 0;
    }));

    const next = maxNo + 1;
    const paddedNext = next < 10 ? `0${next}` : `${next}`;
    
    return `${prefix}-${paddedNext}`;
  } catch (e) {
    return '1';
  }
};


export const saveCoolieBill = async (bill) => {
  const res = await apiFetch(`${API}/coolie_pattiyalkal`, { method: 'POST', body: JSON.stringify(bill) });
  return res;
};

export const deleteCoolieBill = async (id) => {
  const res = await apiFetch(`${API}/coolie_pattiyalkal/${encodeURIComponent(id)}`, { method: 'DELETE' });
  return res;
};


// ---- Receipts / Payment Vouchers ----
export const getAllReceipts = async () => {
  if (isBlankState()) return [];
  return apiFetch(`${API}/raseedhugal`);
};

export const saveReceipt = async (receipt) => {
  const res = await apiFetch(`${API}/raseedhugal`, { method: 'POST', body: JSON.stringify(receipt) });
  if (res.id) receipt.id = res.id;
  return receipt;
};

export const deleteReceipt = async (id) => {
  return apiFetch(`${API}/raseedhugal/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Business Profiles (multi-business) ----
export const getAllProfiles = async () => {
  if (isBlankState()) return [];
  return apiFetch(`${API}/suya_vivaram`);
};

export const saveBusinessProfile = async (profile) => {
  const res = await apiFetch(`${API}/suya_vivaram`, { method: 'POST', body: JSON.stringify(profile) });
  if (res.id) profile.id = res.id;
  return profile;
};

export const deleteBusinessProfile = async (id) => {
  return apiFetch(`${API}/suya_vivaram/${encodeURIComponent(id)}`, { method: 'DELETE' });
};

// ---- Export / Import ----
// localStorage keys that are part of the "user's data" and should ride along in any
// backup. Each key is documented with what it stores and whether losing it matters.
const EXPORTABLE_LOCALSTORAGE_KEYS = [
  'gst_customUnits',          // user-defined units (e.g. Carat, Bundle) for line items
  'gst_enabledModules',        // map of disabled feature toggles
  'freegstbill_invoiceOptions',// per-invoice display preference defaults
  'theme',                     // light/dark
  'freegstbill_onboarded',     // skip welcome wizard on next launch
];

const collectLocalStorage = () => {
  const out = {};
  EXPORTABLE_LOCALSTORAGE_KEYS.forEach(k => {
    try { const v = localStorage.getItem(k); if (v !== null) out[k] = v; } catch { /* sandboxed */ }
  });
  return out;
};

const restoreLocalStorage = (map) => {
  if (!map || typeof map !== 'object') return;
  Object.entries(map).forEach(([k, v]) => {
    if (!EXPORTABLE_LOCALSTORAGE_KEYS.includes(k)) return; // ignore foreign keys
    try { localStorage.setItem(k, v); } catch { /* ignore */ }
  });
};

// Cached app version — pulled from server once per session via /api/version so the
// frontend doesn't have to ship its own copy of package.json. Falls back to 'unknown'
// only if the server is unreachable, which only happens during the brief startup
// window before the user opens the app.
let cachedAppVersion = null;
const getAppVersion = async () => {
  if (cachedAppVersion) return cachedAppVersion;
  try {
    const { current } = await apiFetch(`${API}/version`);
    if (current) { cachedAppVersion = current; return current; }
  } catch { /* server down — best effort */ }
  return 'unknown';
};

// Full export. Returns the JSON-serialised bundle (server data + localStorage).
// Pass `selection` to limit what's included — undefined ⇒ everything.
//
// `selection` shape: { profile, profiles, bills, clients, products,
//   receipts, meta, localStorage } — each bool.
export const exportAllData = async (selection) => {
  const [all, version] = await Promise.all([apiFetch(`${API}/export`), getAppVersion()]);
  const sel = selection || { profile: true, profiles: true, bills: true, clients: true, products: true, receipts: true, meta: true, localStorage: true };

  const data = { exportedAt: new Date().toISOString(), version, __freegstbill_backup: true };
  if (sel.profile)        data.profile = all.profile;
  if (sel.profiles)       data.profiles = all.profiles;
  if (sel.bills)          data.bills = all.bills;
  if (sel.clients)        data.clients = all.clients;
  if (sel.products)       data.products = all.products;


  if (sel.receipts)       data.receipts = all.receipts;

  if (sel.meta)           data.meta = all.meta; // includes enabledModules, etc. on server
  if (sel.localStorage)   data.localStorage = collectLocalStorage();

  return JSON.stringify(data, null, 2);
};

// Inspect a backup file without committing — returns counts so the UI can show
// what's in it before the user picks what to restore.
export const inspectBackup = (jsonString) => {
  let data;
  try { data = JSON.parse(jsonString); }
  catch { throw new Error('Not a valid JSON file'); }
  return {
    valid: !!data && (data.__freegstbill_backup || data.bills || data.profile),
    exportedAt: data.exportedAt || null,
    version: data.version || null,
    counts: {
      profile: data.profile && Object.keys(data.profile).length > 0 ? 1 : 0,
      profiles: Array.isArray(data.profiles) ? data.profiles.length : 0,
      bills: Array.isArray(data.bills) ? data.bills.length : 0,
      clients: Array.isArray(data.clients) ? data.clients.length : 0,
      products: Array.isArray(data.products) ? data.products.length : 0,



      receipts: Array.isArray(data.receipts) ? data.receipts.length : 0,
      meta: data.meta ? Object.keys(data.meta).length : 0,
      localStorage: data.localStorage ? Object.keys(data.localStorage).length : 0,
    },
    raw: data,
  };
};

// Selective import. `selection` is the same shape as for exportAllData.
export const importData = async (jsonString, selection) => {
  const inspected = typeof jsonString === 'string' ? inspectBackup(jsonString) : { raw: jsonString };
  const data = inspected.raw;
  const sel = selection || { profile: true, profiles: true, bills: true, clients: true, products: true, receipts: true, meta: true, localStorage: true };

  // Build a filtered payload — never touch collections the user didn't tick.
  const payload = {};
  if (sel.profile && data.profile)               payload.profile = data.profile;
  if (sel.profiles && data.profiles)             payload.profiles = data.profiles;
  if (sel.bills && data.bills)                   payload.bills = data.bills;
  if (sel.clients && data.clients)               payload.clients = data.clients;
  if (sel.products && data.products)             payload.products = data.products;


  if (sel.receipts && data.receipts)             payload.receipts = data.receipts;

  if (sel.meta && data.meta)                     payload.meta = data.meta;

  const result = await apiFetch(`${API}/import`, { method: 'POST', body: JSON.stringify(payload) });

  if (sel.localStorage && data.localStorage) restoreLocalStorage(data.localStorage);

  return result;
};

// Dummy exports for deleted features to keep VariArikkaigal compiling
export const getAllExpenses = async () => [];
export const getAllPurchases = async () => [];
