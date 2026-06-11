const fs = require('fs');
const path = require('path');

const coolieFile = path.join(__dirname, 'moolam', 'pagudhigal', 'CoolieBill', 'CoolieReceiptEditor.tsx');
const gstFile = path.join(__dirname, 'moolam', 'pagudhigal', 'ReceiptEditor.tsx');

let content = fs.readFileSync(coolieFile, 'utf8');

// Replace relative imports (one directory up instead of two)
content = content.replace(/\.\.\/\.\.\//g, '../');
content = content.replace(/\.\.\//g, './'); // first do all ../ to ./
content = content.replace(/\.\/Avanam/g, '../Avanam');
content = content.replace(/\.\/Payanpadu/g, '../Payanpadu');
content = content.replace(/\.\/mozhi/g, '../mozhi');
content = content.replace(/\.\/hooks/g, '../hooks');

// But some imports from CoolieReceiptEditor like `import ElvanEditorLayout from '../ElvanEditorLayout'` 
// when converted to './' should be './ElvanEditorLayout' which is correct because ReceiptEditor is in pagudhigal/
// Let's refine the import replacement:
// Original Coolie imports:
// import { saveCoolieReceipt... } from '../../Avanam'; -> from '../Avanam'
// import { formatCurrency... } from '../../Payanpadu'; -> from '../Payanpadu'
// import { thagaval } from '../Thagaval'; -> from './Thagaval'
// import { useLanguage } from '../../mozhi/LanguageContext'; -> from '../mozhi/LanguageContext'
// import ElvanEditorLayout from '../ElvanEditorLayout'; -> from './ElvanEditorLayout'
// import ElvanCard from '../ElvanCard'; -> from './ElvanCard'
// import ElvanBilingualField from '../ElvanBilingualField'; -> from './ElvanBilingualField'
// import { useDraftAndUnsaved } from '../../hooks/useDraftAndUnsaved'; -> from '../hooks/useDraftAndUnsaved'

// Reset content from file
content = fs.readFileSync(coolieFile, 'utf8');
content = content.replace(/from '\.\.\/\.\.\/Avanam'/g, "from '../Avanam'");
content = content.replace(/from '\.\.\/\.\.\/Payanpadu'/g, "from '../Payanpadu'");
content = content.replace(/from '\.\.\/Thagaval'/g, "from './Thagaval'");
content = content.replace(/from '\.\.\/\.\.\/mozhi\/LanguageContext'/g, "from '../mozhi/LanguageContext'");
content = content.replace(/from '\.\.\/ElvanEditorLayout'/g, "from './ElvanEditorLayout'");
content = content.replace(/from '\.\.\/ElvanCard'/g, "from './ElvanCard'");
content = content.replace(/from '\.\.\/ElvanBilingualField'/g, "from './ElvanBilingualField'");
content = content.replace(/from '\.\.\/\.\.\/hooks\/useDraftAndUnsaved'/g, "from '../hooks/useDraftAndUnsaved'");

// Rename functions and components
content = content.replace(/CoolieReceiptEditor/g, 'ReceiptEditor');

// Replace Avanam imports
content = content.replace(/saveCoolieReceipt, getAllCoolieBills, getAllCoolieReceipts, getAllCoolieProfiles, getAllCoolieClients/g, 
  'saveReceipt, getAllBills, getAllReceipts, getAllProfiles, getAllClients');

// In init()
content = content.replace(/getAllCoolieReceipts/g, 'getAllReceipts');
content = content.replace(/getAllCoolieBills/g, 'getAllBills');
content = content.replace(/getAllCoolieProfiles/g, 'getAllProfiles');
content = content.replace(/getAllCoolieClients/g, 'getAllClients');
content = content.replace(/saveCoolieReceipt/g, 'saveReceipt');

// Handle Props and state:
// Original: export default function CoolieReceiptEditor({ onBack, onSaved, editingReceipt }: { onBack: () => void, onSaved: () => void, editingReceipt?: any }) {
// New: export default function ReceiptEditor({ profile, onBack, onSaved, editingReceipt }: { profile: any, onBack: () => void, onSaved: () => void, editingReceipt?: any }) {
content = content.replace(
  /export default function ReceiptEditor\(\{ onBack, onSaved, editingReceipt \}: \{ onBack: \(\) => void, onSaved: \(\) => void, editingReceipt\?: any \}\) \{/g,
  `export default function ReceiptEditor({ profile, onBack, onSaved, editingReceipt }: { profile: any, onBack: () => void, onSaved: () => void, editingReceipt?: any }) {`
);

// We need to use profile passed from props, so remove coolieProfile state
content = content.replace(/const \[coolieProfile, setCoolieProfile\] = useState<any>\(null\);\n/g, '');
content = content.replace(/const \[isLoadingProfile, setIsLoadingProfile\] = useState\(true\);\n/g, '');
content = content.replace(/const activeProfile = coolieProfile \|\| \{\};\n/g, 'const activeProfile = profile || {};\n');

// Update init profile loading logic
// Original:
//           const coolieProf = coolieProfiles && coolieProfiles.length > 0 ? coolieProfiles[0] : null;
//           if (coolieProf) setCoolieProfile(coolieProf);
content = content.replace(/const coolieProf = coolieProfiles && coolieProfiles\.length > 0 \? coolieProfiles\[0\] : null;\n\s+if \(coolieProf\) setCoolieProfile\(coolieProf\);/g, '');

content = content.replace(/} finally {\n\s+setIsLoadingProfile\(false\);\n\s+}/g, '}');

// Remove isLoadingProfile return block
content = content.replace(/if \(isLoadingProfile\) \{\n\s+return <Box sx=\{\{ minHeight: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'center' \}\}\><\/Box>;\n\s+\}/g, '');

// Currency configs:
content = content.replace(/const profileCurrency = 'INR';/g, "const profileCurrency = getCountryConfig(activeProfile?.country || 'India').currency;");
content = content.replace(/const currencySymbol = '₹';/g, "const currencySymbol = getCountryConfig(activeProfile?.country || 'India').currencySymbol || profileCurrency;");

fs.writeFileSync(gstFile, content);
console.log('Successfully refactored ReceiptEditor.tsx');
