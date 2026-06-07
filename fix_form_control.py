import re

file_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace FormControl without variant
content = content.replace('<FormControl fullWidth size="small">', '<FormControl variant="filled" fullWidth size="small">')
content = content.replace('<FormControl fullWidth size="small" sx=', '<FormControl variant="filled" fullWidth size="small" sx=')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Added variant='filled' to all FormControl elements.")
