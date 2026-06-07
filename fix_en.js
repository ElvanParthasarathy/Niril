import fs from 'fs';

const taContent = fs.readFileSync('moolam/mozhi/ta.ts', 'utf8');
let enContent = fs.readFileSync('moolam/mozhi/en.ts', 'utf8');

const keyRegex = /^(?:\s*)((?:'[a-zA-Z0-9_ ]+'|[a-zA-Z0-9_]+))(?:\s*):/gm;

const taKeys = new Set();
let match;
while ((match = keyRegex.exec(taContent)) !== null) {
    let key = match[1];
    if (key.startsWith("'") && key.endsWith("'")) {
        key = key.slice(1, -1);
    }
    taKeys.add(key);
}

const enKeys = new Set();
while ((match = keyRegex.exec(enContent)) !== null) {
    let key = match[1];
    if (key.startsWith("'") && key.endsWith("'")) {
        key = key.slice(1, -1);
    }
    enKeys.add(key);
}

function makeEnglish(key) {
  const overrides = {
    "hsnSacCol": "HSN/SAC",
    "gstinNotSet": "GSTIN not set. Please add it in Settings.",
    "gstReturnsSubtitle": "Manage your GST Returns and filing status",
    "cgstCol": "CGST",
    "sgstCol": "SGST",
    "igstCol": "IGST",
    "b2bSalesTable": "B2B Sales",
    "b2cSalesTable": "B2C Sales",
    "hsnSummaryTable": "HSN Summary",
    "docSummaryTable": "Document Summary",
    "gstr1Tab": "GSTR-1",
    "gstr3bTab": "GSTR-3B",
    "gstr2bReconTab": "GSTR-2B Recon",
    "importCSV": "Import CSV",
    "exportCsvBtn": "Export CSV",
    "clientsSubtitle": "Manage clients and view outstandings",
    "inventorySubtitle": "Manage your products and services",
    "receiptsSubtitle": "Manage payment receipts",
    "expensesSubtitle": "Track business expenses",
    "purchasesSubtitle": "Track supplier bills for ITC",
    "recurringInvoicesSubtitle": "Automate invoices for regular clients",
    "reportsSubtitle": "Financial reports and aging analysis",
    "gstReturnsTitle": "GST Returns",
    "notificationsTitle": "Notifications",
    "clientsTitle": "Clients",
    "inventoryTitle": "Products",
    "totalDueLabel": "Total Due",
    "b3Pending": "3B Pending",
    "r1Pending": "R1 Pending",
    "gstr1SummaryTotals": "GSTR-1 Summary Totals"
  };
  
  if (overrides[key]) return overrides[key];

  let str = key
    .replace(/Btn$/i, '')
    .replace(/Col$/i, '')
    .replace(/Label$/i, '')
    .replace(/Toast$/i, '')
    .replace(/Notif$/i, '')
    .replace(/Msg$/i, '')
    .replace(/Star$/i, '')
    .replace(/Word$/i, '')
    .replace(/Tab$/i, '')
    .replace(/Title$/i, '')
    .replace(/Card$/i, '');
    
  // Handle numbers with d (like 30d -> 30 days)
  str = str.replace(/([0-9]+)d/gi, '$1 Days');
  
  // Add spaces around numbers
  str = str.replace(/([0-9]+)/g, ' $1 ');

  // Convert camelCase to space separated
  str = str.replace(/([A-Z])/g, ' $1');
  
  // Collapse spaces
  str = str.replace(/\s+/g, ' ');
  
  // Capitalize first letter
  str = str.charAt(0).toUpperCase() + str.slice(1);
  return str.trim();
}

const missingInEn = [];
for (const key of taKeys) {
    if (!enKeys.has(key)) {
        missingInEn.push(key);
    }
}

if (missingInEn.length > 0) {
  let appendStr = "";
  for (const key of missingInEn) {
    const englishVal = makeEnglish(key);
    const safeKey = key.includes(' ') || key.includes('-') ? `'${key}'` : key;
    appendStr += `  ${safeKey}: "${englishVal}",\n`;
  }
  
  // Insert before the last closing brace
  const lastBraceIndex = enContent.lastIndexOf('}');
  if (lastBraceIndex !== -1) {
    const beforeBrace = enContent.substring(0, lastBraceIndex).trim();
    const needsComma = !beforeBrace.endsWith(',');
    
    enContent = enContent.substring(0, lastBraceIndex) + 
                (needsComma ? ',\n\n  // Auto-added missing keys\n' : '\n  // Auto-added missing keys\n') + 
                appendStr.replace(/,\n$/, '\n') + 
                enContent.substring(lastBraceIndex);
                
    fs.writeFileSync('moolam/mozhi/en.ts', enContent, 'utf8');
    console.log(`Successfully added ${missingInEn.length} missing keys to en.ts`);
  }
} else {
  console.log("No missing keys found.");
}
