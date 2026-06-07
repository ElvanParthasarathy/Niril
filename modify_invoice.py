import re

# 1. Update InvoiceEditor.tsx
editor_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(editor_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the customize options
start_marker = r"<Grid container spacing=\{2\} sx=\{\{ mb: 3 \}\}>\s*<Grid size=\{\{ xs: 12, md: 6 \}\}>\s*<Typography variant=\"body2\" gutterBottom sx=\{\{ fontWeight: 600 \}\}>\{t\('hc_pdfStyle'\)\}</Typography>"
end_marker = r"\}\}>\{t\('hc_hideAll'\)\}</Button>\s*<Button variant=\"outlined\" size=\"small\" onClick=\{\(\) => setInvoiceOptions\(DEFAULT_OPTIONS\)\}>Reset to default</Button>\s*</Box>"

pattern = re.compile(start_marker + r".*?" + end_marker, re.DOTALL)
if pattern.search(content):
    content = pattern.sub('', content)
    print("Found and removed options in InvoiceEditor")
else:
    print("Could not find options in InvoiceEditor")

with open(editor_path, 'w', encoding='utf-8') as f:
    f.write(content)
