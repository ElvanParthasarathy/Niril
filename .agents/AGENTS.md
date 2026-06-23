# Agent Customization Rules

## Language Policy for Elvan Niril
1. **Pure Tamil (Senthamizh) Only**: When creating Tamil translations or UI labels (e.g., in `ta.dart`), STRICTLY use Pure Tamil words. 
2. **NO Sanskrit**: Do NOT use Sanskrit-derived words.
   - *Bad*: விவரங்கள் (Vivarangal), வசூல் (Vasool), ஆயத்தம் (Aayatham), மகா/மாகாணம் (Maha/Maakaanam), சின்னம் (Chinnam), திட்டம் (Thittam), விகிதம் (Vigitham).
   - *Good*: தரவுகள் (Tharavugal), திரட்டல் (Thirattal), ஒருக்கம்/நிறைவு (Orukkam/Niraivu), ஆள்நிலம் (Aalnilam), ஓவுரு (Ovuru), எடுத்துக்காட்டு (Eduthukaattu), வீதம் (Veetham).
3. **NO Urdu/Arabic**: Avoid non-native administrative words like வசூல் (Vasool - use திரட்டிய/பெற்ற).
4. **No Direct English Transliterations**: Do not transliterate English words directly into Tamil script (e.g., do not use "கவுண்டி" for County, or "செஸ்" for Cess). Translate them into meaningful native Tamil words (e.g., மண்டலம் for County, மேல்வரி for Cess). 
   - *Exception*: Standard global acronyms like "GST" or "PDF" can be used as-is in English letters.
5. **Add Grammar Markers**: Always add the correct Tamil conjunction markers (e.g., 'ப்') when combining words, like நிறுவனப் பெயர் (not நிறுவன பெயர்), வங்கிப் பெயர், கிளைப் பெயர்.
