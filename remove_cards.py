import re

file_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace opening and closing tags
content = content.replace('<ElvanCard sx={{ mb: 3 }}>', '<Box sx={{ mb: 5 }}>')
# Let's replace closing tags with a Box and a Divider, EXCEPT the very last one.
# We can find all </ElvanCard> and replace.
parts = content.split('</ElvanCard>')
new_content = ""
for i in range(len(parts) - 1):
    new_content += parts[i] + '</Box>\n          <Divider sx={{ mb: 5, borderColor: \'divider\', opacity: 0.5 }} />'
new_content += parts[-1]

# Remove the import of ElvanCard if we want, or leave it. It's safe to leave.
# Let's remove the divider after the last section (Terms). 
# Actually the last part has terms and then Back Confirmation Dialog. 
# The last </ElvanCard> was at line 1449.
# The `new_content` string appended the divider. Let's just do a clean replace.

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Removed ElvanCard containers and added dividers.")
