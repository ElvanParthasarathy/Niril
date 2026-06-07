import re

file_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Box py: 3, px: { xs: 2, md: 3 } with Box py: 3
content = content.replace('<Box sx={{ py: 3, px: { xs: 2, md: 3 } }}>', "<Box sx={{ py: 3 }}>")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Removed inner horizontal padding.")
