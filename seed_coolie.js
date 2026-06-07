import fs from 'fs';
import path from 'path';

const port = fs.readFileSync(path.resolve('./tharavu/port.txt'), 'utf-8').trim();
const API = `http://127.0.0.1:${port}/api`;

const items = [
  { name: "இரண்டு இழை சப்புரி செய்ய கூலி", nameEn: "Irandu Izhai Sappuri Seiyya Coolie", type: "coolie" },
  { name: "ஜரி தடை செய்ய கூலி", nameEn: "Jari Dhadai Cheiya Coolie", type: "coolie" },
  { name: "மூன்று இழை சப்புரி செய்ய கூலி", nameEn: "Moondru Izhai Sappuri Cheiya Coolie", type: "coolie" },
  { name: "ஓண்டி தடை செய்ய கூலி", nameEn: "Ondi Dhadai Cheiya Coolie", type: "coolie" }
];

async function seed() {
  for (const item of items) {
    const payload = {
      ...item,
      name_Tamil: item.name,
      name_English: item.nameEn
    };
    
    const res = await fetch(`${API}/coolie_porulgal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    
    if (res.ok) {
      console.log(`Added: ${item.name}`);
    } else {
      console.error(`Failed to add: ${item.name}`);
    }
  }
}

seed();
