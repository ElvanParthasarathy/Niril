import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { LanguageProvider } from './mozhi/LanguageContext';
import ReceiptView from './pagudhigal/GstBill/Receipts/ReceiptView';
import CoolieReceiptView from './pagudhigal/CoolieBill/CoolieReceiptView';
import './fonts.css';

// Minimal theme without CssBaseline to ensure transparency
const theme = createTheme({
  palette: {
    background: {
      default: 'transparent',
      paper: 'transparent'
    }
  }
});

function App() {
  const [receipt, setReceipt] = useState({});
  const [isDark, setIsDark] = useState(false);
  const [receiptType, setReceiptType] = useState('GST');

  useEffect(() => {
    // Read data safely from the Kotlin bridge
    if (typeof window !== 'undefined' && (window as any).FlutterBridge) {
      try {
        const receiptData = (window as any).FlutterBridge.getReceiptData();
        const profileData = (window as any).FlutterBridge.getProfileData();
        const parsedReceipt = JSON.parse(receiptData);
        parsedReceipt._companyProfile = JSON.parse(profileData);
        
        const recType = (window as any).FlutterBridge.getReceiptType ? (window as any).FlutterBridge.getReceiptType() : 'GST';
        setReceiptType(recType);

        if (recType !== 'COOLIE') {
            // Transform Silk invoice flat format to nested React format expected by SjsTheme
            let items = [];
            try {
                items = typeof parsedReceipt.tharavugal === 'string' ? JSON.parse(parsedReceipt.tharavugal) : (parsedReceipt.tharavugal || []);
            } catch(e) {}
            
            let options = {};
            try {
                options = typeof parsedReceipt.sonthaViruppangal === 'string' ? JSON.parse(parsedReceipt.sonthaViruppangal) : (parsedReceipt.sonthaViruppangal || {});
            } catch(e) {}

            const mappedItems = items.map((it: any, i: number) => {
                const qty = Number(it.alavu) || 0;
                const rate = Number(it.vilai) || 0;
                const baseAmt = qty * rate;
                const thallupadi = Number(it.thallupadi) || 0;
                const discAmt = it.thallupadiVagai === '%' ? baseAmt * (thallupadi / 100) : thallupadi;

                return {
                    id: String(i),
                    name: it.porulPeyar || '',
                    name_Tamil: it.porulPeyar || '',
                    name_English: it.porulPeyarEn || '',
                    description: '',
                    qty: qty,
                    quantity: qty,
                    rate: rate,
                    unit: it.alagu || 'Nos',
                    hsn: it.hsnKuriyeedu || '',
                    taxPercent: Number(it.variVizhukkaadu) || 0,
                    discount: discAmt,
                };
            });

            // Reconstruct totals
            const total = Number(parsedReceipt.mothaThogai) || 0;
            const subtotal = mappedItems.reduce((acc: number, it: any) => acc + (it.qty * it.rate), 0);
            const totalDiscount = mappedItems.reduce((acc: number, it: any) => acc + it.discount, 0);

            // Reconstruct client
            const client = parsedReceipt._client || {};

            parsedReceipt.data = {
                profile: parsedReceipt._companyProfile,
                client: client,
                details: {
                    invoiceNumber: parsedReceipt.patrucheettuEn || '',
                    invoiceDate: parsedReceipt.naal || '',
                    invoiceType: parsedReceipt.pattiyalVagai || 'receipt',
                    placeOfSupply: options.placeOfSupply || client.maanilam || ''
                },
                items: mappedItems,
                totals: {
                    total: total,
                    subtotal: subtotal,
                    totalDiscount: totalDiscount,
                    cgst: 0,
                    sgst: 0,
                    igst: 0,
                    cess: 0,
                    taxInclusive: false
                },
                invoiceType: parsedReceipt.pattiyalVagai || 'receipt',
                customTerms: parsedReceipt.ullkurippu || '',
                invoiceOptions: options
            };
        } else {
            // Also handle the _client object that we attach from Flutter for Coolie if any
            if (parsedReceipt._client) {
               parsedReceipt.client = parsedReceipt._client;
            }
        }

        setReceipt(parsedReceipt);
        setIsDark((window as any).FlutterBridge.isDarkMode());
      } catch (e) {
        console.error("Failed to parse bridge data", e);
      }
    } else {
      // Fallback for browser testing
      console.warn("FlutterBridge not found.");
    }
  }, []);

  return (
    <ThemeProvider theme={theme}>
      <LanguageProvider initialProfile={(receipt as any)._companyProfile || {}}>
        <div style={{ padding: 0, margin: 0, background: 'transparent' }}>
          {receiptType === 'COOLIE' ? (
            <CoolieReceiptView
              receipt={receipt}
              profile={(receipt as any)._companyProfile || {}}
              isDark={isDark}
            />
          ) : (
            <ReceiptView 
              receipt={receipt}
              profile={(receipt as any)._companyProfile || {}}
              isDark={isDark}
            />
          )}
        </div>
      </LanguageProvider>
    </ThemeProvider>
  );
}

const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(<App />);
}
