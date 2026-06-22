/// Mock Profile Data — Pure Tamil Transliteration Keys with Language Tags
///
/// Key naming rules:
/// - All keys use pure Tamil transliteration (no English, no Sanskrit)
/// - Bilingual fields use `_Tamil` / `_English` suffix (language tags)
/// - Universal acronyms (gstin, ifsc, upi) stay as-is
/// - Non-bilingual fields (numbers, emails, codes) have no suffix

// ─────────────────────────────────────────────────────────────────────────────
// SILK MODE PROFILE (GST Billing)
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, dynamic> mockProfileData = {
  // ── Language Config (மொழி அமைப்பு) ──
  'mudhanMozhi': 'Tamil', // முதன் மொழி — Primary data language
  'thunaiMozhi': 'English', // துணை மொழி — Secondary data language
  'iruMozhi': true, // இரு மொழி — Bilingual enabled

  // ── Business Details (வணிக விவரங்கள்) ──
  'niruvanathinPeyar_Tamil': 'ஶ்ரீ ஜெய்பிரியா சில்க்ஸ்',
  'niruvanathinPeyar_English': 'Sri Jaipriya Silks',
  'kurumPeyar': 'SJPS', // குறும்பெயர் — Short business name (any lang)
  'tholaipesi_1': '8144604797', // தொலைபேசி 1
  'tholaipesi_2': '9360779191', // தொலைபேசி 2
  'minnanchal': 'srijaipriyasilks@gmail.com', // மின்னஞ்சல்
  'gstin': '33ASSPV0378E1ZD', // GSTIN (acronym)

  // ── Address (முகவரி) ──
  'mugavari_Tamil': '4/606, முதல் தெரு, சிவசக்தி நகர்',
  'mugavari_English': '4/606, First Street, Sivasakthi Nagar',
  'oor_Tamil': 'ஆரணி',
  'oor_English': 'Arani',
  'maavattam_Tamil': 'திருவண்ணாமலை மாவட்டம்',
  'maavattam_English': 'Thiruvannamalai District',
  'maanilam_Tamil': 'Tamil Nadu',
  'maanilam_English': 'Tamil Nadu',
  'naadu_Tamil': '',
  'naadu_English': '',
  'anchalkuriyeedu': '632317', // அஞ்சல் குறியீடு — Pincode

  // ── Bank Details (வங்கி விவரங்கள்) ──
  'vangiPeyar_Tamil': 'தமிழ்நாடு மெர்கன்டைல் வங்கி',
  'vangiPeyar_English': 'Tamilnad Mercantile Bank',
  'kilai_Tamil': 'ஆரணி',
  'kilai_English': 'Arani',
  'vangiKanakku': '309150050800239', // வங்கிக் கணக்கு — Account number
  'ifsc': 'TMBL0000309', // IFSC (acronym)

  // ── Branding (வணிக அடையாளங்கள்) ──
  'ovuru': '', // ஓவுரு — Business logo
  'ovuruUyaram': 80, // ஓவுரு உயரம் — Logo height
  'agalaOvuru': '', // அகல ஓவுரு — Wide logo
  'agalaOvuruAlavu': 0.95, // அகல ஓவுரு அளவு — Wide logo scale
  'agalaOvuruX': -29, // Wide logo X offset
  'agalaOvuruY': -40, // Wide logo Y offset
  'thallaippuVadivu': 'small', // தலைப்பு வடிவு — Header style (small/wide)
  'kaiyoppam': '', // கையொப்பம் — Signature image
  'oppamPeyar': 'பா. வனிதாஶ்ரீ', // ஒப்பம் பெயர் — Signatory name

  // ── Additional ──
  'adaimozhi_Tamil': 'கைத்தறி பட்டு சேலைகள் & ராசில்க்', // அடைமொழி — Tagline
  'adaimozhi_English': 'Handloom Silk Sarees & Rawsilk',
  'upiId': '', // UPI (acronym)
};

// ─────────────────────────────────────────────────────────────────────────────
// COOLIE MODE PROFILE (Labour Billing)
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, dynamic> mockCoolieProfileData = {
  // ── Language Config ──
  'mudhanMozhi': 'Tamil',
  'thunaiMozhi': 'English',
  'iruMozhi': false, // Coolie uses single-language billing but stores both

  // ── Business Details ──
  'niruvanathinPeyar_Tamil': 'வி.ஆர்.எம். பட்டு முறுக்கு ஆலை',
  'niruvanathinPeyar_English': 'V.R.M. Silk Twisting Factory',
  'kurumPeyar': 'VRM',
  'tholaipesi_1': '8144604797',
  'tholaipesi_2': '9360779191',
  'minnanchal': 'vrmshreesarathy@gmail.com',

  // ── Address ──
  'mugavari_Tamil': '4/606, முதல் தெரு, சிவசக்தி நகர்',
  'mugavari_English': '4/606, First Street, Sivasakthi Nagar',
  'oor_Tamil': 'ஆரணி',
  'oor_English': 'Arani',
  'maavattam_Tamil': 'திருவண்ணாமலை மாவட்டம்',
  'maavattam_English': 'Thiruvannamalai District',
  'anchalkuriyeedu': '632301',

  // ── Bank Details ──
  'vangiPeyar_Tamil': 'தமிழ்நாடு மெர்கன்டைல் வங்கி',
  'vangiPeyar_English': 'Tamilnad Mercantile Bank',
  'kilai_Tamil': 'ஆரணி',
  'kilai_English': 'Arani',
  'vangiKanakku': '309150050800162',
  'ifsc': 'TMBL0000309',

  // ── Branding ──
  'ovuru': '', // Logo
  'kaiyoppam': '', // Signature
  'oppamPeyar': 'இரா. பார்த்தசாரதி',

  // ── Additional ──
  'thottranNiram': '#6a1b9a', // தோற்ற நிறம் — Theme color
};
