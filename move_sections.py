import re

file_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract Invoice Type block
invoice_type_start = content.find('{/* Invoice Type */}')
invoice_type_end = content.find('          {/* Client Modal */}')

if invoice_type_start != -1 and invoice_type_end != -1:
    invoice_type_block = content[invoice_type_start:invoice_type_end]
    content = content[:invoice_type_start] + content[invoice_type_end:]
    
    # We want to place it before Terms
    terms_start = content.find('{/* Terms */}')
    if terms_start != -1:
        content = content[:terms_start] + invoice_type_block + content[terms_start:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Moved Invoice Type section.")
else:
    print("Could not find sections.")
