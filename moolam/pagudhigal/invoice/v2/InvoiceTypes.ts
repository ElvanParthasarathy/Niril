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
    ...client,
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
    // Flat fields for legacy compatibility (reports, PDF, receipt linking)
    name: client.name.primary,
    nameEn: client.name.secondary,
    mugavari: client.mugavari.primary,
    mugavariEn: client.mugavari.secondary,
    oor: client.oor.primary,
    oorEn: client.oor.secondary,
    maavattam: client.maavattam.primary,
    maavattamEn: client.maavattam.secondary,
    maanilam: client.maanilam.primary,
    maanilamEn: client.maanilam.secondary,
    country: client.country.primary,
    countryEn: client.country.secondary,
  };
};

export const convertItemsToSnapshot = (items: LineItemState[], primaryLang: string, secondaryLang: string): any[] => {
  return items.map(item => {
    const calculatedDiscountAmt = item.discountType === 'percentage' 
      ? (item.qty * item.rate) * ((item.discount || 0) / 100) 
      : (item.discount || 0);
      
    return {
      ...item,
      discount: calculatedDiscountAmt,
      rawDiscountValue: item.discount,
      discountType: item.discountType || 'amount',
      quantity: item.qty, // Map qty to quantity for legacy support
      [`name_${primaryLang}`]: item.name.primary,
      [`name_${secondaryLang}`]: item.name.secondary,
      [`description_${primaryLang}`]: item.description.primary,
      [`description_${secondaryLang}`]: item.description.secondary,
      // Flat fields for legacy compatibility (PDF rendering, reports)
      name: item.name.primary,
      nameEn: item.name.secondary,
      description: item.description.primary,
      descriptionEn: item.description.secondary,
    };
  });
};
