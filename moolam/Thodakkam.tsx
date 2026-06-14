// @ts-nocheck
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { registerSW } from 'virtual:pwa-register'
import Seyali from './Seyali'
import './vadivam.css'

import { LanguageProvider } from './mozhi/LanguageContext'

import { BrowserRouter } from 'react-router-dom';

// Register service worker with auto-update
const updateSW = registerSW({
  onNeedRefresh() {
    // Auto-update when new content is available
    updateSW(true)
  },
  onOfflineReady() {
    console.log('App ready to work offline')
  },
})

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <LanguageProvider>
      <BrowserRouter>
        <Seyali />
      </BrowserRouter>
    </LanguageProvider>
  </StrictMode>,
)
