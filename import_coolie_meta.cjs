const fs = require('fs');
const path = require('path');

const OLD_DATA_FILE = path.join(__dirname, 'niril old.json');
const CLIENTS_DIR = path.join(__dirname, 'data', 'coolie_vanigargal');
const ITEMS_DIR = path.join(__dirname, 'data', 'coolie_porulgal');

if (!fs.existsSync(CLIENTS_DIR)) fs.mkdirSync(CLIENTS_DIR, { recursive: true });
if (!fs.existsSync(ITEMS_DIR)) fs.mkdirSync(ITEMS_DIR, { recursive: true });

try {
  const fileData = fs.readFileSync(OLD_DATA_FILE, 'utf8');
  const parsed = JSON.parse(fileData);
  
  // Import Customers
  const coolieCustomers = parsed.data.coolie_customers;
  if (coolieCustomers && Array.isArray(coolieCustomers)) {
    let clientsCount = 0;
    for (const c of coolieCustomers) {
      if (!c.id) continue;
      const clientData = {
        id: c.id,
        nameTamil: c.name_tamil || '',
        name: c.name || '',
        companyNameTamil: c.company_name_tamil || '',
        companyName: c.company_name || '',
        cityTamil: c.city_tamil || '',
        city: c.city || '',
        addressTamil: c.address_tamil || '',
        address: c.address_line1 || '',
        phone: c.phone || ''
      };
      const safeName = c.id.replace(/[^a-z0-9_-]/gi, '_');
      fs.writeFileSync(path.join(CLIENTS_DIR, `${safeName}.json`), JSON.stringify(clientData, null, 2));
      clientsCount++;
    }
    console.log(`Imported ${clientsCount} coolie customers.`);
  }
  
  // Extract and Import Items from Bills
  const coolieBills = parsed.data.coolie_bills;
  if (coolieBills && Array.isArray(coolieBills)) {
    const itemsMap = new Map();
    for (const bill of coolieBills) {
      if (bill.items && Array.isArray(bill.items)) {
        for (const item of bill.items) {
          const tamilName = item.name_tamil || item.porul;
          const key = tamilName.trim();
          if (!key) continue;
          
          if (!itemsMap.has(key)) {
            itemsMap.set(key, {
              id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
              nameTamil: tamilName,
              name: item.name_english || '',
              defaultRate: item.coolie || ''
            });
          }
        }
      }
    }
    
    let itemsCount = 0;
    for (const [_, itemData] of itemsMap) {
      const safeName = itemData.id;
      fs.writeFileSync(path.join(ITEMS_DIR, `${safeName}.json`), JSON.stringify(itemData, null, 2));
      itemsCount++;
    }
    console.log(`Extracted and imported ${itemsCount} unique coolie items from bills.`);
  }
  
} catch (e) {
  console.error("Error reading or parsing niril old.json:", e);
}
