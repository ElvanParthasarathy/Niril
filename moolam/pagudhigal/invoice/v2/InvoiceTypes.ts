export interface BilingualField {
  primary: string;
  secondary: string;
}

export interface ClientState {
  id?: string;
  name: BilingualField;
  mugavari: BilingualField;
  oor: BilingualField;
  maavattam: BilingualField;
  maanilam: BilingualField;
  country: BilingualField;
  pin: string;
  gstin: string;
}

export interface LineItemState {
  id: string;
  isTemp?: boolean;
  productId?: string | null;
  name: { primary: string; secondary: string };
  description: { primary: string; secondary: string };
  hsn: string;
  rate: number;
  qty: number;
  unit: string;
  taxPercent: number;
  cessPercent?: number;
  discount: number;
  discountType?: 'percentage' | 'amount';
}

export interface InvoiceMetadataState {
  invoiceType: 'tax-invoice' | 'proforma';
  invoiceNumber: string;
  date: string;
  placeOfSupply: string;
}

export interface InvoiceTotalsState {
  subtotal: number;
  totalDiscount: number;
  cgst: number;
  sgst: number;
  igst: number;
  roundOff: number;
  tcsAmount: number;
  tdsAmount: number;
  total: number;
  netReceivable: number;
  amountPaid: number;
  globalDiscountValue?: number;
  globalDiscountType?: 'percentage' | 'amount';
  globalDiscountAmount?: number;
  itemDiscounts?: number;
}

export interface InvoiceSettingsState {
  taxInclusive: boolean;
  showDiscountColumn: boolean;
  showHSN: boolean;
  showPlaceOfSupply: boolean;
  showVehicle: boolean;
  showDueDate: boolean;
  showTerms: boolean;
  showBank: boolean;
  showNotes: boolean;
  showSignature: boolean;
  showCess?: boolean;
  currency?: string;
}

export interface InvoiceDocumentState {
  client: ClientState;
  metadata: InvoiceMetadataState;
  items: LineItemState[];
  settings: InvoiceSettingsState;
  customTerms: string;
  internalNote: string;
}

export const createEmptyClient = (): ClientState => ({
  name: { primary: '', secondary: '' },
  mugavari: { primary: '', secondary: '' },
  oor: { primary: '', secondary: '' },
  maavattam: { primary: '', secondary: '' },
  maanilam: { primary: '', secondary: '' },
  country: { primary: 'India', secondary: '' },
  pin: '',
  gstin: '',
});

export const createEmptyLineItem = (): LineItemState => ({
  id: Date.now().toString() + Math.random().toString(36).substring(2),
  name: { primary: '', secondary: '' },
  description: { primary: '', secondary: '' },
  hsn: '',
  rate: 0,
  qty: 1,
  unit: 'Nos',
  taxPercent: 0,
  discount: 0,
  discountType: 'amount',
});

export const convertClientToSnapshot = (client: ClientState, primaryLang: string, secondaryLang: string): any => {
  return {
    id: client.id,
    gstin: client.gstin,
    pin: client.pin,
    // Bilingual lang-tagged keys (source of truth)
    [`name_${primaryLang}`]: client.name.primary,
    [`name_${secondaryLang}`]: client.name.secondary,
    [`mugavari_${primaryLang}`]: client.mugavari.primary,
    [`mugavari_${secondaryLang}`]: client.mugavari.secondary,
    [`oor_${primaryLang}`]: client.oor.primary,
    [`oor_${secondaryLang}`]: client.oor.secondary,
    [`maavattam_${primaryLang}`]: client.maavattam.primary,
    [`maavattam_${secondaryLang}`]: client.maavattam.secondary,
    [`maanilam_${primaryLang}`]: client.maanilam.primary,
    [`maanilam_${secondaryLang}`]: client.maanilam.secondary,
    [`country_${primaryLang}`]: client.country.primary,
    [`country_${secondaryLang}`]: client.country.secondary,
    // Functional flat fields (needed for state/country matching logic)
    maanilam: client.maanilam.primary,
    country: client.country.primary,
  };
};

export const convertItemsToSnapshot = (items: LineItemState[], primaryLang: string, secondaryLang: string): any[] => {
  return items.map(item => {
    const calculatedDiscountAmt = item.discountType === 'percentage' 
      ? (item.qty * item.rate) * ((item.discount || 0) / 100) 
      : (item.discount || 0);
      
    return {
      id: item.id,
      productId: item.productId,
      isTemp: item.isTemp,
      hsn: item.hsn,
      rate: item.rate,
      qty: item.qty,
      quantity: item.qty, // Backward compat for PDF renderer & GST reports
      unit: item.unit,
      taxPercent: item.taxPercent,
      cessPercent: item.cessPercent,
      discount: calculatedDiscountAmt,
      rawDiscountValue: item.discount,
      discountType: item.discountType || 'amount',
      // Bilingual lang-tagged keys (source of truth)
      [`name_${primaryLang}`]: item.name.primary,
      [`name_${secondaryLang}`]: item.name.secondary,
      [`description_${primaryLang}`]: item.description.primary,
      [`description_${secondaryLang}`]: item.description.secondary,
    };
  });
};

// Convert old-format client data (flat keys / lang-tagged) into V2 internal state
export const convertLoadedClient = (raw: any, primaryLang: string, secondaryLang: string): ClientState => {
  const get = (field: string): BilingualField => {
    const val = raw[field];
    // Already V2 format (object with primary/secondary)
    if (val && typeof val === 'object' && 'primary' in val) return val;
    return {
      primary: raw[`${field}_${primaryLang}`] || (typeof val === 'string' ? val : '') || '',
      secondary: raw[`${field}_${secondaryLang}`] || raw[`${field}En`] || '',
    };
  };
  return {
    id: raw.id,
    name: get('name'),
    mugavari: get('mugavari'),
    oor: get('oor'),
    maavattam: get('maavattam'),
    maanilam: get('maanilam'),
    country: get('country').primary ? get('country') : { primary: 'India', secondary: '' },
    pin: raw.pin || '',
    gstin: raw.gstin || '',
  };
};

// Convert old-format item data (flat keys / lang-tagged) into V2 internal state
export const convertLoadedItem = (raw: any, primaryLang: string, secondaryLang: string): LineItemState => {
  const get = (field: string): BilingualField => {
    const val = raw[field];
    if (val && typeof val === 'object' && 'primary' in val) return val;
    return {
      primary: raw[`${field}_${primaryLang}`] || (typeof val === 'string' ? val : '') || '',
      secondary: raw[`${field}_${secondaryLang}`] || raw[`${field}En`] || '',
    };
  };
  return {
    id: raw.id || Date.now().toString() + Math.random().toString(36).substring(2),
    isTemp: raw.isTemp,
    productId: raw.productId || null,
    name: get('name'),
    description: get('description'),
    hsn: raw.hsn || '',
    rate: Number(raw.rate) || 0,
    qty: Number(raw.quantity ?? raw.qty) || 1,
    unit: raw.unit || 'Nos',
    taxPercent: Number(raw.taxPercent) || 0,
    cessPercent: Number(raw.cessPercent) || 0,
    discount: Number(raw.rawDiscountValue ?? raw.discount) || 0,
    discountType: raw.discountType || 'amount',
  };
};
