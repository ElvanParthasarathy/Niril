import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { LanguageProvider } from './mozhi/LanguageContext';
import ReceiptView from './pagudhigal/GstBill/Receipts/ReceiptView';
import CoolieReceiptView from './pagudhigal/CoolieBill/CoolieReceiptView';

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
  const [profile, setProfile] = useState({});
  const [isDark, setIsDark] = useState(false);
  const [receiptType, setReceiptType] = useState('GST');

  useEffect(() => {
    // Read data safely from the Kotlin bridge
    if (window.FlutterBridge) {
      try {
        const receiptData = window.FlutterBridge.getReceiptData();
        const profileData = window.FlutterBridge.getProfileData();
        setReceipt(JSON.parse(receiptData));
        setProfile(JSON.parse(profileData));
        setIsDark(window.FlutterBridge.isDarkMode());
        if (window.FlutterBridge.getReceiptType) {
          setReceiptType(window.FlutterBridge.getReceiptType());
        }
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
      <LanguageProvider initialProfile={profile}>
        <div style={{ padding: 0, margin: 0, background: 'transparent' }}>
          {receiptType === 'COOLIE' ? (
            <CoolieReceiptView
              receipt={receipt}
              profile={profile}
              isDark={isDark}
            />
          ) : (
            <ReceiptView 
              receipt={receipt}
              profile={profile}
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
