const fs = require('fs');

let code = fs.readFileSync('pagudhigal/Amaippugal.tsx', 'utf8');

// 1. Add activeTab state
if (!code.includes('const [activeTab, setActiveTab]')) {
  code = code.replace(
    'const [showMobileField, setShowMobileField] = useState(false);',
    'const [showMobileField, setShowMobileField] = useState(false);\n  const [activeTab, setActiveTab] = useState(0);'
  );
}

// Ensure ElvanCard is imported if needed, but for now we'll just use Paper to be safe,
// or we can import it.
if (!code.includes('import ElvanCard')) {
  code = code.replace(/import \{ useLanguage \} from '\.\.\/mozhi\/LanguageContext';/, "import { useLanguage } from '../mozhi/LanguageContext';\nimport ElvanCard from './ElvanCard';");
}

// 2. Extract sections using regex
function extractSection(startMarker, endMarker) {
  const startIndex = code.indexOf(startMarker);
  if (startIndex === -1) throw new Error("Could not find start marker: " + startMarker);
  
  let endIndex;
  if (endMarker === 'END_OF_UI') {
    endIndex = code.indexOf('{/* ----------------------- Export modal ----------------------- */}');
  } else {
    endIndex = code.indexOf(endMarker);
  }
  
  if (endIndex === -1) throw new Error("Could not find end marker: " + endMarker);
  
  return code.substring(startIndex, endIndex);
}

const secDataLang = extractSection('{/* Data Language Settings */}', '{/* ---- Language Preference ---- */}');
const secLangPref = extractSection('{/* ---- Language Preference ---- */}', '{/* ---- Business Profile ---- */}');
const secBusiness = extractSection('{/* ---- Business Profile ---- */}', '{/* ---- Payment Accounts ---- */}');
const secPayment = extractSection('{/* ---- Payment Accounts ---- */}', '{/* Invoice Number Format */}');
const secInvFormat = extractSection('{/* Invoice Number Format */}', '{/* Receipt Number Format */}');
const secRcpFormat = extractSection('{/* Receipt Number Format */}', '{/* Logo & Signature */}');
const secBranding = extractSection('{/* Logo & Signature */}', '<Box sx={{ mt: 4, display: \\'flex\\', justifyContent: \\'flex-end\\' }}>\\n          <Button type="submit" variant="contained" color="primary" disabled={saving} startIcon={<Save sx={{ fontSize: 18 }} />}>\\n            {saving ? t(\\'saving\\') : t(\\'saveProfile\\')}\\n          </Button>\\n        </Box>\\n      </Paper>');
// Branding is inside the Business Profile Paper. Wait, let's look closer at the original code.

// Let's use a simpler replacement strategy. We will replace everything from `{/* Data Language Settings */}` down to just before `{/* ----------------------- Export modal ----------------------- */}`.

let replacement = `
      <Grid container spacing={3}>
        {/* Left Sidebar / Top Tabs */}
        <Grid size={{ xs: 12, md: 3 }}>
          <Paper elevation={0} sx={{ 
            display: { xs: 'flex', md: 'block' }, 
            overflowX: 'auto', 
            bgcolor: 'transparent',
            borderRadius: { xs: 0, md: 2 }, 
            borderBottom: { xs: 1, md: 0 }, 
            borderColor: 'divider',
            mb: { xs: 2, md: 0 },
            '&::-webkit-scrollbar': { display: 'none' },
            msOverflowStyle: 'none',
            scrollbarWidth: 'none',
          }}>
            {[
              { id: 0, label: 'Profile & Accounts', icon: <Business fontSize="small" /> },
              { id: 1, label: 'Display & Languages', icon: <Tag fontSize="small" /> },
              { id: 2, label: 'Billing & Payments', icon: <Tag fontSize="small" /> },
              { id: 3, label: 'Storage & Cloud', icon: <Cloud fontSize="small" /> },
              { id: 4, label: 'System & Updates', icon: <Refresh fontSize="small" /> },
            ].map(item => (
              <Button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                fullWidth
                variant={activeTab === item.id ? 'contained' : 'text'}
                color={activeTab === item.id ? 'primary' : 'inherit'}
                startIcon={item.icon}
                sx={{
                  justifyContent: 'flex-start',
                  px: 2, py: 1.5,
                  mb: { xs: 0, md: 0.5 },
                  mr: { xs: 1, md: 0 },
                  borderRadius: 50,
                  flexShrink: 0,
                  whiteSpace: 'nowrap',
                  fontWeight: activeTab === item.id ? 700 : 500,
                  color: activeTab === item.id ? 'primary.contrastText' : 'text.secondary',
                  bgcolor: activeTab === item.id ? 'primary.main' : 'transparent',
                  '&:hover': {
                    bgcolor: activeTab === item.id ? 'primary.dark' : 'action.hover',
                  }
                }}
              >
                {item.label}
              </Button>
            ))}
          </Paper>
        </Grid>

        {/* Right Content Area */}
        <Grid size={{ xs: 12, md: 9 }}>
          <Box sx={{ px: { xs: 2, md: 0 }, pb: 4 }}>
            
            {activeTab === 0 && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                __SEC_BUSINESS__
                __SEC_MULTI_BUSINESS__
              </Box>
            )}

            {activeTab === 1 && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                __SEC_UI_LANG__
                __SEC_DATA_LANG__
              </Box>
            )}

            {activeTab === 2 && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                __SEC_PAYMENT__
                <Paper elevation={2} sx={{ p: { xs: 2, md: 3 }, borderRadius: { xs: 0, sm: 2 }, borderX: { xs: 0, sm: undefined } }}>
                  __SEC_INV_FORMAT__
                  __SEC_RCP_FORMAT__
                </Paper>
                __SEC_TERMS__
              </Box>
            )}

            {activeTab === 3 && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                __SEC_ADVANCED__
                __SEC_DATA_MGMT__
              </Box>
            )}

            {activeTab === 4 && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                __SEC_APP_UPDATES__
              </Box>
            )}

          </Box>
        </Grid>
      </Grid>
`;

// Now let's extract the actual code blocks
function getBlock(start, end) {
  const s = code.indexOf(start);
  const e = code.indexOf(end, s);
  if (s === -1 || e === -1) {
    console.error("Missing block:", start);
    return "";
  }
  return code.substring(s, e);
}

const bDataLang = getBlock('{/* Data Language Settings */}', '{/* ---- Language Preference ---- */}');
const bUiLang = getBlock('{/* ---- Language Preference ---- */}', '{/* ---- Business Profile ---- */}');

// The business profile block has </Paper> but also contains the forms.
// Actually, Business Profile contains branding inside it currently. Let's extract the whole Business Profile paper.
const bBusiness = getBlock('{/* ---- Business Profile ---- */}', '{/* ---- Advanced Settings ---- */}');

const bAdvanced = getBlock('{/* ---- Advanced Settings ---- */}', '{/* ---- Invoice Terms & Conditions ---- */}');
const bTerms = getBlock('{/* ---- Invoice Terms & Conditions ---- */}', '{/* ---- Multi-Business Profiles ---- */}');
const bMultiBus = getBlock('{/* ---- Multi-Business Profiles ---- */}', '{/* ---- Data Management ---- */}');
// Wait, App Updates is BEFORE Data Management.
// Let's re-extract.
const bMultiBusFull = getBlock('{/* ---- Multi-Business Profiles ---- */}', '<Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 0, mb: 0.5 }}>\\n          {t(\\'appUpdatesTitle\\')}');
const bAppUpdates = getBlock('<Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 0, mb: 0.5 }}>\\n          {t(\\'appUpdatesTitle\\')}', '<Paper elevation={2} sx={{ p: { xs: 2, md: 3 }, mb: { xs: 2, md: 3 }, borderRadius: { xs: 0, sm: 2 }, borderX: { xs: 0, sm: undefined } }}>\\n        <Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 0 }}>\\n          {t(\\'dataManagementTitle\\')}');
// Wait, bAppUpdates starts inside a Paper.
// Let's use simple replace_file_content logic instead. I will just write a script that does exact string replacements.

`;
fs.writeFileSync('reformat_settings_v2.js', replacement);
