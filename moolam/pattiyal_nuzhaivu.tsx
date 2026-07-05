import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { LanguageProvider } from './mozhi/LanguageContext';
import CoolieInvoiceView from './pagudhigal/CoolieBill/CoolieInvoiceView';

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
  const [bill, setBill] = useState({});
  const [isDark, setIsDark] = useState(false);
  const [invoiceType, setInvoiceType] = useState('COOLIE');

  useEffect(() => {
    // Read data safely from the Kotlin bridge
    if (typeof window !== 'undefined' && (window as any).FlutterBridge) {
      try {
        const invoiceData = (window as any).FlutterBridge.getInvoiceData();
        const profileData = (window as any).FlutterBridge.getProfileData();
        const parsedBill = JSON.parse(invoiceData);
        parsedBill._companyProfile = JSON.parse(profileData);
        setBill(parsedBill);
        setIsDark((window as any).FlutterBridge.isDarkMode());
        if ((window as any).FlutterBridge.getInvoiceType) {
          setInvoiceType((window as any).FlutterBridge.getInvoiceType());
        }
      } catch (e) {
        console.error("Failed to parse bridge data", e);
      }
    }
  }, []);

  return (
    <ThemeProvider theme={theme}>
      <LanguageProvider initialProfile={(bill as any)._companyProfile || {}}>
        <div style={{ padding: 0, margin: 0, background: 'transparent' }}>
          {invoiceType === 'COOLIE' ? (
            <CoolieInvoiceView 
              bill={bill} 
              onClose={() => {
                if (typeof window !== 'undefined' && (window as any).FlutterBridge && (window as any).FlutterBridge.closeInvoice) {
                  (window as any).FlutterBridge.closeInvoice();
                }
              }}
              onEdit={() => {}}
            />
          ) : (
            <div style={{ padding: 20, textAlign: 'center' }}>Silk Invoice Component Not Wired Yet</div>
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
