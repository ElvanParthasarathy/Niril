// @ts-nocheck
import { Capacitor } from '@capacitor/core';

export const getPrintHeadContent = async () => {
  let headHtml = document.head.innerHTML;
  
  if (Capacitor.isNativePlatform()) {
    let inlineStyles = '';
    const links = document.querySelectorAll('link[rel="stylesheet"]');
    for (const link of Array.from(links)) {
      if (link.href) {
        try {
          const response = await fetch(link.href);
          let cssText = await response.text();
          // Fix relative font URLs
          cssText = cssText.replace(/url\(\/([^)]+)\)/g, 'url(file:///android_asset/public/$1)');
          inlineStyles += cssText + '\n';
        } catch (e) {
          console.error('Failed to inline CSS', e);
        }
      }
    }
    
    const parser = new DOMParser();
    const doc = parser.parseFromString(`<html><head>${headHtml}</head></html>`, 'text/html');
    
    // Remove original links to prevent failure loading
    const headLinks = doc.querySelectorAll('link[rel="stylesheet"]');
    headLinks.forEach(l => l.remove());
    
    // Fix all absolute paths in HTML elements
    const elementsWithSrc = doc.querySelectorAll('[src^="/"], [href^="/"]');
    elementsWithSrc.forEach(el => {
      if (el.hasAttribute('src') && el.getAttribute('src').startsWith('/')) {
        el.setAttribute('src', 'file:///android_asset/public' + el.getAttribute('src'));
      }
      if (el.hasAttribute('href') && el.getAttribute('href').startsWith('/')) {
        el.setAttribute('href', 'file:///android_asset/public' + el.getAttribute('href'));
      }
    });

    return doc.head.innerHTML + `<style>${inlineStyles}</style>`;
  }
  
  return headHtml;
};

export const getDynamicField = (obj: any, fieldName: string, profile: any, isPrimary = true): string => {
  if (!obj) return '';
  const enableBilingual = profile?.iruMozhi ?? (profile?.enableBilingual !== false);
  
  // SHIELD: If bilingual mode is OFF, never return secondary fields.
  if (!enableBilingual && !isPrimary) {
    return '';
  }

  const primaryLang = profile?.mudhanMozhi ?? profile?.primaryDataLanguage ?? 'ta';
  const secondaryLang = profile?.thunaiMozhi ?? profile?.secondaryDataLanguage ?? 'en';
  
  // Normalize legacy 'Tamil'/'English' to 'ta'/'en'
  const normPrimary = primaryLang.toLowerCase() === 'tamil' ? 'ta' : (primaryLang.toLowerCase() === 'english' ? 'en' : primaryLang);
  const normSecondary = secondaryLang.toLowerCase() === 'tamil' ? 'ta' : (secondaryLang.toLowerCase() === 'english' ? 'en' : secondaryLang);
  
  const langCode = isPrimary ? normPrimary : normSecondary;
  const legacyLangName = langCode === 'ta' ? 'Tamil' : 'English';

  // 1. Try modern Flutter Map format (e.g. obj.amountInWords.ta)
  if (obj[fieldName] && typeof obj[fieldName] === 'object') {
    const val = obj[fieldName][langCode];
    if (val) return val;
  }

  // 2. Try legacy format (e.g. obj.vaangunarPeyar_Tamil)
  const exactVal = obj[`${fieldName}_${legacyLangName}`];
  if (exactVal) {
    if (legacyLangName !== 'Tamil' && /[\u0B80-\u0BFF]/.test(exactVal)) return '';
    return exactVal;
  }

  // 3. Fallback to base field (e.g. obj.vaangunarPeyar)
  const baseVal = obj[fieldName];
  if (baseVal && typeof baseVal === 'string') {
    if (legacyLangName !== 'Tamil' && /[\u0B80-\u0BFF]/.test(baseVal)) return '';
    return baseVal;
  }

  // CRITICAL FIX for Monolingual mode
  if (!enableBilingual && isPrimary) {
    if (obj[fieldName] && typeof obj[fieldName] === 'object') {
        const fallbackVal = obj[fieldName][normSecondary];
        if (fallbackVal) return fallbackVal;
    }
    const fallbackLegacy = obj[`${fieldName}_${normSecondary === 'ta' ? 'Tamil' : 'English'}`];
    if (fallbackLegacy) return fallbackLegacy;
  }
  
  return '';
};

export const formatCurrency = (amount, currency = 'INR') => {
  if (!amount && amount !== 0) return '';
  try {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: currency,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  } catch (e) {
    // Fallback if currency code is invalid or missing
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  }
};
