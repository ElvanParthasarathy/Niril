import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { LanguageProvider } from './mozhi/LanguageContext';
import ReceiptView from './pagudhigal/GstBill/Receipts/ReceiptView';

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

  useEffect(() => {
    // Read data safely from the Kotlin bridge
    if (window.FlutterBridge) {
      try {
        const receiptData = window.FlutterBridge.getReceiptData();
        const profileData = window.FlutterBridge.getProfileData();
        setReceipt(JSON.parse(receiptData));
        setProfile(JSON.parse(profileData));
        setIsDark(window.FlutterBridge.isDarkMode());
      } catch (e) {
        console.error("Error parsing bridge data", e);
      }
    } else {
      // Fallback for browser testing
      console.warn("FlutterBridge not found.");
    }
  }, []);

  const handleBack = () => {
    if (window.FlutterBridge) {
      window.FlutterBridge.closeReceipt();
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <LanguageProvider>
        <ReceiptView 
          receipt={receipt} 
          profile={profile} 
          onBack={handleBack}
        />
      </LanguageProvider>
    </ThemeProvider>
  );
}

const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(<App />);
}
