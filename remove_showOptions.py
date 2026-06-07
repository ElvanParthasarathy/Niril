import re

file_path = 'moolam/pagudhigal/invoice/InvoiceEditor.tsx'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove state
content = re.sub(r'  const \[showOptions, setShowOptions\] = useState\(false\);\n', '', content)

# 2. Remove button
btn_pattern = r'<Button variant="outlined" size="small" onClick=\{\(\) => setShowOptions\(!showOptions\)\} startIcon=\{<GearSix size=\{15\} weight="regular"\s+/>\}>\s*\{showOptions \? \'Hide Options\' : t\(\'customize\'\)\}\s*</Button>'
content = re.sub(btn_pattern, '', content)

# 3. Unwrap the Box
content = content.replace("{/* Customization Options */}\n            {showOptions && (\n              <Box sx={{ mt: 3, p: 2, bgcolor: 'background.default', border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>\n\n                {/* Payment account */}", "{/* Payment account */}")
content = content.replace("                })()}\n\n                \n              </Box>\n            )}\n          </ElvanCard>", "                })()}\n          </ElvanCard>")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
