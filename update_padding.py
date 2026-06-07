import re

file_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace Box mb: 5 with Box py: 4
content = content.replace('<Box sx={{ mb: 5 }}>', "<Box sx={{ py: 3 }}>")
content = content.replace("<Divider sx={{ mb: 5, borderColor: 'divider', opacity: 0.5 }} />", "<Divider sx={{ my: 1, borderColor: 'divider', opacity: 0.5 }} />")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated padding.")
