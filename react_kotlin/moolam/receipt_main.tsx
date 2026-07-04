import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material';
import ReceiptView from './components/ReceiptView';
import { LanguageProvider } from './mozhi/LanguageContext';
import './vadivu.css';

const theme = createTheme({});

declare global {
  interface Window {
    setReactData: (receiptJson: any, profileJson: any) => void;
  }
}

function ReceiptApp() {
  const [receipt, setReceipt] = useState(null);
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    // Expose a global function for Flutter to call directly via runJavaScript
    window.setReactData = (receiptJson, profileJson) => {
      try {
        const parsedReceipt = typeof receiptJson === 'string' ? JSON.parse(receiptJson) : receiptJson;
        const parsedProfile = typeof profileJson === 'string' ? JSON.parse(profileJson) : profileJson;
        setReceipt(parsedReceipt);
        setProfile(parsedProfile);
      } catch (e) {
        console.error("Failed to parse receipt data", e);
      }
    };

    // Also listen to postMessage as a fallback
    const handleMessage = (event) => {
      try {
        const data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
        if (data && data.type === 'SET_RECEIPT_DATA') {
          setReceipt(data.receipt);
          setProfile(data.profile);
        }
      } catch (e) {
        console.error("Failed to parse message", e);
      }
    };
    
    window.addEventListener('message', handleMessage);
    
    // Notify Flutter that the WebView has loaded React and is ready to receive data
    if (window.ReceiptBridge && window.ReceiptBridge.postMessage) {
      window.ReceiptBridge.postMessage('READY');
    }
    
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  if (!receipt) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', fontFamily: 'sans-serif', color: '#666' }}>
        Loading Receipt...
      </div>
    );
  }

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <LanguageProvider>
        <ReceiptView receipt={receipt} profile={profile} onBack={() => {}} onEdit={() => {}} />
      </LanguageProvider>
    </ThemeProvider>
  );
}

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <ReceiptApp />
  </React.StrictMode>
);
