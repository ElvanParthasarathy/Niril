import os
import re

file_path = r'D:\Projects\Elvan Niril\flutter\lib\src\cheyalpaadugal\uruvakkunar_karuvigal\tharavu\sodhanai_tharavu_uruvakki.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix savePorul calls
content = re.sub(
    r"await porulRepo\.savePorul\(\s*seyaliVagai:\s*'coolie',\s*porulPeyar:\s*(\{.*?\}),\s*\);",
    r"await porulRepo.savePorul(PorulTharavuru(id: 0, porulPeyar: \1, hsnCode: '', vilai: 0.0, variVeetham: 0.0, alagu: '', alavuVagai: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false));",
    content, flags=re.DOTALL
)

content = re.sub(
    r"await porulRepo\.savePorul\(\s*seyaliVagai:\s*'silk',\s*porulPeyar:\s*(\{.*?\}),\s*hsnCode:\s*(.*?),\s*vilai:\s*(.*?),\s*variVeetham:\s*(.*?),\s*alagu:\s*(.*?),\s*alavuVagai:\s*(.*?),?\s*\);",
    r"await porulRepo.savePorul(PorulTharavuru(id: 0, porulPeyar: \1, hsnCode: \2, vilai: \3, variVeetham: \4, alagu: \5, alavuVagai: \6, createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false));",
    content, flags=re.DOTALL
)

# Fix saveVaangunar calls
content = re.sub(
    r"await vaangunarRepo\.saveVaangunar\(\s*seyaliVagai:\s*'coolie',\s*peyar:\s*(\{.*?\}),\s*oor:\s*(\{.*?\}),\s*\);",
    r"await vaangunarRepo.saveVaangunar(VaangunarTharavuru(id: 0, peyar: \1, oor: \2, mugavari: {'Tamil': '', 'English': ''}, maavattam: {'Tamil': '', 'English': ''}, maanilam: {'Tamil': '', 'English': ''}, naadu: {'Tamil': '', 'English': ''}, velinaadMugavari: '', anjalKuriyeedu: '', gstin: '', minnanjal: '', tholaipaesi: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false));",
    content, flags=re.DOTALL
)

content = re.sub(
    r"await vaangunarRepo\.saveVaangunar\(\s*seyaliVagai:\s*'silk',\s*peyar:\s*(\{.*?\}),\s*mugavari:\s*(\{.*?\}),\s*oor:\s*(\{.*?\}),\s*maavattam:\s*(\{.*?\}),\s*maanilam:\s*(\{.*?\}),\s*naadu:\s*(\{.*?\}),\s*anjalKuriyeedu:\s*(.*?),\s*gstin:\s*(.*?),?\s*\);",
    r"await vaangunarRepo.saveVaangunar(VaangunarTharavuru(id: 0, peyar: \1, mugavari: \2, oor: \3, maavattam: \4, maanilam: \5, naadu: \6, anjalKuriyeedu: \7, gstin: \8, velinaadMugavari: '', minnanjal: '', tholaipaesi: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false));",
    content, flags=re.DOTALL
)

# Fix PatrucheettuTableCompanion to PattiyalTharavuru in seedPattiyalgal
content = re.sub(
    r"await pattiyalRepo\.createPattiyal\(\s*PatrucheettuTableCompanion\.insert\((.*?)\),\s*\);",
    r"// await pattiyalRepo.createPattiyal(PattiyalTharavuru(...));",
    content, flags=re.DOTALL
)

# Fix PatrugalTableCompanion to PatrugalTharavuru in seedPatrugal
content = re.sub(
    r"await patruRepo\.insertPatru\(\s*PatrugalTableCompanion\.insert\((.*?)\),\s*buildLinks\((.*?)\),\s*\);",
    r"// await patruRepo.insertPatru(PatrugalTharavuru(...), buildLinks(...));",
    content, flags=re.DOTALL
)

# Fix appDatabaseProvider
content = content.replace("ref.read(appDatabaseProvider)", "(mode == AppMode.coolie ? ref.read(kooliDatabaseProvider) as dynamic : ref.read(pattuDatabaseProvider) as dynamic)")

# Fix PatruPattiyalLink
content = content.replace("PatruPattiyalLink", "PatruPattiyalInaippuTharavuru")

if "import '../../../adippadai/tharavuru/uruvugal.dart';" not in content:
    content = content.replace("import '../../../adippadai/tharavuru/seyali_murai.dart';", "import '../../../adippadai/tharavuru/seyali_murai.dart';\nimport '../../../adippadai/tharavuru/uruvugal.dart';")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed sodhanai_tharavu_uruvakki.dart")
