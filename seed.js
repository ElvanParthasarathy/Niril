import fs from 'fs';
import path from 'path';

const dataDir = path.join('d:', 'Projects', 'Elvan Niril', 'tharavu');

// Ensure directories
['pattiyalkal', 'vanigargal', 'porulgal'].forEach(dir => {
  const p = path.join(dataDir, dir);
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
});

// Profile
const profile = {
  niruvanathinPeyar_Tamil: "ஸ்ரீ ஜெயப்ரியா சில்க்ஸ்",
  niruvanathinPeyar_English: "Sri Jaipriya Silks",
  tagline_Tamil: "கைத்தறி பட்டு சேலைகள் & ராசில்க்",
  tagline_English: "Handloom Silk Sarees & Rawsilk",
  mugavari_Tamil: "6/606, முதல் தெரு, சிவசக்தி நகர்",
  mugavari_English: "6/606, First Street, Sivasakthi Nagar",
  oor_Tamil: "ஆரணி",
  oor_English: "Arani - 632317",
  maavattam_Tamil: "திருவண்ணாமலை மாவட்டம்",
  maavattam_English: "T.V.M Dist",
  maanilam_Tamil: "தமிழ்நாடு",
  maanilam_English: "Tamil Nadu",
  country_Tamil: "இந்தியா",
  country_English: "India",
  pin: "632317",
  gstin: "33ASSPV0378E1ZD",
  phone: "8144604797, 9360779191",
  email: "srijaipriyasilks@gmail.com",
  signatureName: "VANITHASREE P",
  enableBilingual: true,
  primaryDataLanguage: "Tamil",
  secondaryDataLanguage: "English"
};
fs.writeFileSync(path.join(dataDir, 'profile.json'), JSON.stringify(profile, null, 2));

// Client
const client = {
  id: "cli_1",
  name_Tamil: "ஸ்ரீ சிவராம் சில்க் சாரீஸ் ஆரணி",
  name_English: "SRI SIVARAM SILK SAREES ARANI",
  mugavari_Tamil: "6, NA, ஒளவையார் தெரு, ஆரணி",
  mugavari_English: "6, NA, AVVAIYAAR STREET, ARANI",
  pin: "632301",
  country_Tamil: "இந்தியா",
  country_English: "India",
  gstin: "33AYGPS0561E1ZN"
};
fs.writeFileSync(path.join(dataDir, 'vanigargal', 'cli_1.json'), JSON.stringify(client, null, 2));

// Products
const products = [
  { id: "prod_1", name_Tamil: "ஃபேன்ஸி சேலை", name_English: "Fancy Saree", rate: 7900, unit: "Nos", taxPercent: 5, hsn: "50072010" },
  { id: "prod_2", name_Tamil: "ஃபேன்ஸி முத்து சேலை", name_English: "Fancy Muthu Saree", rate: 8100, unit: "Nos", taxPercent: 5, hsn: "50072010" },
  { id: "prod_3", name_Tamil: "ஃபேன்ஸி முத்து முந்தி கட்டம் சேலை", name_English: "Fancy Muthu Mundhi Kattam Saree", rate: 8200, unit: "Nos", taxPercent: 5, hsn: "50072010" },
  { id: "prod_4", name_Tamil: "ஃபேன்ஸி கட்டம் புட்டா", name_English: "Fancy Checked Butta", rate: 8500, unit: "Nos", taxPercent: 5, hsn: "50072010" }
];
products.forEach(p => fs.writeFileSync(path.join(dataDir, 'porulgal', p.id + '.json'), JSON.stringify(p, null, 2)));

// Invoice
const invoice = {
  id: "inv_INV-562",
  type: "TAX",
  invoiceNumber: "INV-562",
  invoiceDate: "2026-05-02T00:00:00.000Z",
  dueDate: "2026-05-02T00:00:00.000Z",
  terms: "Due on Receipt",
  clientId: "cli_1",
  clientName: "ஸ்ரீ சிவராம் சில்க் சாரீஸ் ஆரணி",
  clientNameEn: "SRI SIVARAM SILK SAREES ARANI",
  clientGstin: "33AYGPS0561E1ZN",
  placeOfSupply: "33",
  placeOfSupplyEn: "Tamil Nadu",
  items: [
    { id: "prod_1", name_Tamil: "ஃபேன்ஸி சேலை", name_English: "Fancy Saree", qty: 1, rate: 7900, taxPercent: 5, unit: "Nos", hsn: "50072010" },
    { id: "prod_2", name_Tamil: "ஃபேன்ஸி முத்து சேலை", name_English: "Fancy Muthu Saree", qty: 2, rate: 8100, taxPercent: 5, unit: "Nos", hsn: "50072010" },
    { id: "prod_3", name_Tamil: "ஃபேன்ஸி முத்து முந்தி கட்டம் சேலை", name_English: "Fancy Muthu Mundhi Kattam Saree", qty: 4, rate: 8200, taxPercent: 5, unit: "Nos", hsn: "50072010" },
    { id: "prod_4", name_Tamil: "ஃபேன்ஸி கட்டம் புட்டா", name_English: "Fancy Checked Butta", qty: 1, rate: 8500, taxPercent: 5, unit: "Nos", hsn: "50072010" },
    { id: "prod_5", name_Tamil: "ஃபேன்ஸி கட்டம் புட்டா", name_English: "Fancy Checked Butta", qty: 2, rate: 8700, taxPercent: 5, unit: "Nos", hsn: "50072010" }
  ],
  subtotal: 82800,
  taxTotal: 4140,
  total: 86940,
  amountPaid: 0,
  balance: 86940,
  status: "UNPAID",
  notes: "Thanks for shopping with us! Visit Again!",
  data: { client }
};
fs.writeFileSync(path.join(dataDir, 'pattiyalkal', 'inv_INV-562.json'), JSON.stringify(invoice, null, 2));

console.log('Seed data successfully written.');
