const fs = require('fs');
const path = require('path');

const profilesDir = path.join(__dirname, 'tharavu', 'coolie_suya_vivaram');
const billsDir = path.join(__dirname, 'tharavu', 'coolie_pattiyalkal');

// Build profile prefix map
const prefixes = {};
if (fs.existsSync(profilesDir)) {
  const profileFiles = fs.readdirSync(profilesDir).filter(f => f.endsWith('.json'));
  for (const f of profileFiles) {
    try {
      const data = JSON.parse(fs.readFileSync(path.join(profilesDir, f), 'utf8'));
      prefixes[data.id] = data.shortBusinessName || data.name || 'CB';
    } catch (e) {
      console.error('Error reading profile', f, e);
    }
  }
}

let fixedCount = 0;

if (fs.existsSync(billsDir)) {
  const billFiles = fs.readdirSync(billsDir).filter(f => f.endsWith('.json'));
  for (const f of billFiles) {
    try {
      const filepath = path.join(billsDir, f);
      const data = JSON.parse(fs.readFileSync(filepath, 'utf8'));
      
      const rawNo = String(data.bill_no || '');
      // Check if it's entirely digits, meaning it lacks the prefix
      if (/^\d+$/.test(rawNo)) {
        const num = parseInt(rawNo, 10);
        const prefix = prefixes[data.company_id] || 'CB';
        
        const paddedNext = num < 10 ? `0${num}` : `${num}`;
        const newBillNo = `${prefix}-${paddedNext}`;
        
        data.bill_no = newBillNo;
        fs.writeFileSync(filepath, JSON.stringify(data, null, 2), 'utf8');
        console.log(`Fixed ${f}: ${rawNo} -> ${newBillNo}`);
        fixedCount++;
      }
    } catch (e) {
      console.error('Error fixing bill', f, e);
    }
  }
}

console.log(`Successfully fixed ${fixedCount} bills.`);
