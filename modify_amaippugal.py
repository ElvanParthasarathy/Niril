import re

file_path = 'moolam/pagudhigal/Amaippugal.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update imports
content = content.replace("getReceiptNumberSettings, saveReceiptNumberSettings } from '../Avanam';", "getReceiptNumberSettings, saveReceiptNumberSettings, getInvoiceDisplayOptions, saveInvoiceDisplayOptions } from '../Avanam';")

# 2. Add constants
constants = """
const ACCENT_PRESETS = [
  { color: '#1e40af', label: 'Blue' },
  { color: '#7c3aed', label: 'Purple' },
  { color: '#0f766e', label: 'Teal' },
  { color: '#be123c', label: 'Red' },
  { color: '#c2410c', label: 'Orange' },
  { color: '#15803d', label: 'Green' },
  { color: '#0369a1', label: 'Sky' },
  { color: '#1e293b', label: 'Dark' },
];

const PDF_STYLES = [
  { id: 'classic', label: 'Classic', desc: 'Clean with top accent bar' },
  { id: 'modern', label: 'Modern', desc: 'Bold header with color block' },
  { id: 'minimal', label: 'Minimal', desc: 'Simple, borderless layout' },
];
"""
content = re.sub(r'(export default function Amaippugal\(\{ onSaved \}\) \{)', constants + r'\n\1', content)

# 3. Add state and effect
state_code = """
  const [invoiceTemplate, setInvoiceTemplate] = useState<any>({});
  
  useEffect(() => {
    const savedLocal = localStorage.getItem('elvanniril_invoiceOptions');
    const local = savedLocal ? JSON.parse(savedLocal) : {};
    getInvoiceDisplayOptions().then(serverOpts => {
      setInvoiceTemplate({ ...local, ...(serverOpts || {}) });
    });
  }, []);

  const handleTemplateChange = (key, val) => {
    const newOpts = { ...invoiceTemplate, [key]: val };
    setInvoiceTemplate(newOpts);
    localStorage.setItem('elvanniril_invoiceOptions', JSON.stringify(newOpts));
    saveInvoiceDisplayOptions(newOpts);
  };
"""
content = re.sub(r'(const \[invNumSaving, setInvNumSaving\] = useState\(false\);)', r'\1\n' + state_code, content)

# 4. Add UI section
ui_code = """
      {/* ---- Invoice Template ---- */}
      <Paper className="s2-group" elevation={2} sx={{ p: { xs: 2, md: 3 }, mb: { xs: 2, md: 3 }, borderRadius: { xs: 0, sm: 2 }, borderX: { xs: 0, sm: undefined } }}>
        <Typography variant="h6" style={{ fontWeight: 600 }} gutterBottom sx={{ mt: 0 }}>
          {t('hc_invoiceTemplate')}
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
          Configure default styling and optional fields for all your invoices.
        </Typography>
        
        <Grid container spacing={3} sx={{ mb: 3 }}>
          <Grid size={{ xs: 12, md: 6 }}>
            <Typography variant="body2" gutterBottom sx={{ fontWeight: 600 }}>{t('hc_pdfStyle')}</Typography>
            <Box sx={{ display: 'flex', gap: 1 }}>
              {PDF_STYLES.map(s => (
                <Chip key={s.id} 
                  label={s.label} 
                  color={(invoiceTemplate.pdfStyle || 'classic') === s.id ? "primary" : "default"} 
                  variant={(invoiceTemplate.pdfStyle || 'classic') === s.id ? "filled" : "outlined"} 
                  onClick={() => handleTemplateChange('pdfStyle', s.id)} 
                  clickable 
                  title={s.desc} 
                />
              ))}
            </Box>
          </Grid>
          <Grid size={{ xs: 12, md: 6 }}>
            <Typography variant="body2" gutterBottom sx={{ fontWeight: 600 }}>{t('hc_accentColor')}</Typography>
            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', alignItems: 'center' }}>
              <Box component="button" type="button" title="Auto (match invoice type)"
                sx={{ width: 28, height: 28, borderRadius: '50%', border: !invoiceTemplate.accentColor ? '2.5px solid #334155' : '2px solid #cbd5e1', background: 'conic-gradient(#1e40af, #7c3aed, #0f766e, #be123c, #1e40af)', cursor: 'pointer', position: 'relative' }}
                onClick={() => handleTemplateChange('accentColor', '')}>
                {!invoiceTemplate.accentColor && <Box component="span" sx={{ position: 'absolute', inset: '3px', borderRadius: '50%', border: '2px solid white' }} />}
              </Box>
              {ACCENT_PRESETS.map(p => (
                <Box key={p.color} component="button" type="button" title={p.label}
                  sx={{ width: 28, height: 28, borderRadius: '50%', backgroundColor: p.color, border: invoiceTemplate.accentColor === p.color ? '2.5px solid #334155' : '2px solid #cbd5e1', cursor: 'pointer', position: 'relative' }}
                  onClick={() => handleTemplateChange('accentColor', p.color)}>
                  {invoiceTemplate.accentColor === p.color && <Box component="span" sx={{ position: 'absolute', inset: '3px', borderRadius: '50%', border: '2px solid white' }} />}
                </Box>
              ))}
            </Box>
          </Grid>
        </Grid>

        <Grid container spacing={3}>
          {[
            { group: 'Header & branding', items: [
              ['showLogo', 'Logo'],
              ['showBusinessAddress', 'Business mugavari'],
              ['showBusinessPhone', 'Business tholaipesi'],
              ['showBusinessEmail', 'Business email'],
              ['showState', 'Business maanilam'],
              ['showDistrict', 'Business district'],
              ['showCountry', 'Business country'],
              ['showGSTIN', 'Tax ID (GSTIN/VAT/etc.)'],
            ]},
            { group: 'Client / Bill-to', items: [
              ['showClientAddress', 'Client mugavari'],
              ['showClientPhone', 'Client tholaipesi'],
              ['showClientEmail', 'Client email'],
              ['showPlaceOfSupply', 'Place of Supply'],
            ]},
            { group: 'Items table', items: [
              ['showHSN', 'HSN/SAC column'],
              ['showItemUnit', 'Unit column'],
              ['showDiscount', 'Discount column'],
              ['showCess', 'GST Cess % column'],
            ]},
            { group: 'Totals', items: [
              ['showAmountWords', 'Amount in words'],
              ['showRoundOff', 'Round-off line'],
            ]},
            { group: 'Compliance', items: [
              ['reverseCharge', 'Reverse Charge applies'],
            ]},
            { group: 'Footer', items: [
              ['showBankDetails', 'Bank details'],
              ['showAccountLabel', 'Show Pay via label'],
              ['showUPI', 'UPI QR (India only)'],
              ['showSignature', 'Signature block'],
              ['showSignatoryText', 'Authorized Signatory caption'],
              ['showTerms', 'Terms & Conditions'],
              ['showNotes', 'Notes / Remarks'],
            ]},
          ].map(section => (
            <Grid size={{ xs: 12, sm: 6, md: 4 }} key={section.group}>
              <Typography variant="overline" color="text.secondary" sx={{ fontWeight: 700, display: 'block', mb: 1 }}>{section.group}</Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column' }}>
                {section.items.map(([key, label]) => {
                  const offByDefault = key === 'showRoundOff' || key === 'showAccountLabel' || key === 'showCess' || key === 'reverseCharge';
                  const checked = offByDefault ? !!invoiceTemplate[key] : invoiceTemplate[key] !== false;
                  return (
                    <FormControlLabel key={key} control={<Checkbox size="small" checked={checked} onChange={(e) => handleTemplateChange(key, !checked)} />} label={<Typography variant="body2">{label}</Typography>} />
                  );
                })}
              </Box>
            </Grid>
          ))}
        </Grid>
      </Paper>
"""

content = content.replace('</Box>); title = "Billing & Payments"; }', ui_code + '\n</Box>); title = "Billing & Payments"; }')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Amaippugal updated successfully.")
