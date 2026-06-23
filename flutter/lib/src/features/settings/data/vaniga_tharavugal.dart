/// வணிக தரவுகள் — Business profile data model.

/// வணிக தரவுகள் — Business profile data model.
///
/// This is the domain model used by UI code. It maps to/from
/// the Drift-generated `VanigaTharavugalEntry` for database storage.
///
/// All bilingual fields are stored as `Map<String, String>` where the key is
/// the language name (e.g., 'Tamil', 'English'). This allows easy scaling to
/// new languages without changing the model.
class VanigaTharavugal {
  // ── Database ID (for multi-profile support) ──
  int? id; // Database row ID — null for unsaved profiles

  // ── Language Config (மொழி அமைப்பு) ──
  String mudhanMozhi; // முதன் மொழி — Primary data language
  String thunaiMozhi; // துணை மொழி — Secondary data language
  bool iruMozhi; // இரு மொழி — Bilingual enabled

  // ── Business Details (வணிகத் தரவு) ──
  Map<String, String> niruvanathinPeyar; // நிறுவனத்தின் பெயர் — Business name
  String kurumPeyar; // குறும்பெயர் — Short business name
  String tholaipesi1; // தொலைபேசி 1
  String tholaipesi2; // தொலைபேசி 2
  String minnanchal; // மின்னஞ்சல் — Email
  String gstin; // GSTIN (acronym, silk only)

  // ── Address (முகவரி) ──
  Map<String, String> mugavari; // முகவரி — Street address
  Map<String, String> oor; // ஊர் — City
  Map<String, String> maavattam; // மாவட்டம் — District
  Map<String, String> maanilam; // மாநிலம் — State (silk only)
  Map<String, String> naadu; // நாடு — Country (silk only)
  String anchalkuriyeedu; // அஞ்சல் குறியீடு — Pincode

  // ── Bank Details (வங்கி) ──
  Map<String, String> vangiPeyar; // வங்கிப் பெயர் — Bank name
  Map<String, String> kilai; // கிளை — Branch
  String vangiKanakku; // வங்கிக் கணக்கு — Account number
  String ifsc; // IFSC (acronym)

  // ── Branding (அடையாளங்கள்) ──
  String ovuru; // ஓவுரு — Business logo
  String agalaOvuru; // அகல ஓவுரு — Wide logo (silk only)
  String thallaippuVadivu; // தலைப்பு வடிவு — Header style (silk only)
  String kaiyoppam; // கையொப்பம் — Signature image
  String oppamPeyar; // ஒப்பம் பெயர் — Signatory name

  // ── Additional ──
  Map<String, String> adaimozhi; // அடைமொழி — Tagline (silk only)
  String upiId; // UPI (acronym, silk only)
  String thottranNiram; // தோற்ற நிறம் — Theme color (coolie only)

  VanigaTharavugal({
    this.id,
    this.mudhanMozhi = 'Tamil',
    this.thunaiMozhi = 'English',
    this.iruMozhi = true,
    Map<String, String>? niruvanathinPeyar,
    this.kurumPeyar = '',
    this.tholaipesi1 = '',
    this.tholaipesi2 = '',
    this.minnanchal = '',
    this.gstin = '',
    Map<String, String>? mugavari,
    Map<String, String>? oor,
    Map<String, String>? maavattam,
    Map<String, String>? maanilam,
    Map<String, String>? naadu,
    this.anchalkuriyeedu = '',
    Map<String, String>? vangiPeyar,
    Map<String, String>? kilai,
    this.vangiKanakku = '',
    this.ifsc = '',
    this.ovuru = '',
    this.agalaOvuru = '',
    this.thallaippuVadivu = 'small',
    this.kaiyoppam = '',
    this.oppamPeyar = '',
    Map<String, String>? adaimozhi,
    this.upiId = '',
    this.thottranNiram = '',
  })  : niruvanathinPeyar = niruvanathinPeyar ?? {},
        mugavari = mugavari ?? {},
        oor = oor ?? {},
        maavattam = maavattam ?? {},
        maanilam = maanilam ?? {},
        naadu = naadu ?? {},
        vangiPeyar = vangiPeyar ?? {},
        kilai = kilai ?? {},
        adaimozhi = adaimozhi ?? {};

  // ── Helper: Get the primary language value of a bilingual field ──
  String getPrimary(String fieldName) {
    final map = _getBilingualMap(fieldName);
    return map[mudhanMozhi] ?? '';
  }

  // ── Helper: Get the secondary language value of a bilingual field ──
  String getSecondary(String fieldName) {
    final map = _getBilingualMap(fieldName);
    return map[thunaiMozhi] ?? '';
  }

  // ── Helper: Set a bilingual field value for a specific language ──
  void setBilingual(String fieldName, String language, String value) {
    final map = _getBilingualMap(fieldName);
    map[language] = value;
  }

  Map<String, String> _getBilingualMap(String fieldName) {
    switch (fieldName) {
      case 'niruvanathinPeyar':
        return niruvanathinPeyar;
      case 'mugavari':
        return mugavari;
      case 'oor':
        return oor;
      case 'maavattam':
        return maavattam;
      case 'maanilam':
        return maanilam;
      case 'naadu':
        return naadu;
      case 'vangiPeyar':
        return vangiPeyar;
      case 'kilai':
        return kilai;
      case 'adaimozhi':
        return adaimozhi;
      default:
        return {};
    }
  }

  // ── Supported languages for language tag resolution ──
  static const List<String> supportedLanguages = [
    'Tamil',
    'English',
  ];

  /// Creates a deep copy.
  VanigaTharavugal copyWith({
    int? id,
    String? mudhanMozhi,
    String? thunaiMozhi,
    bool? iruMozhi,
    Map<String, String>? niruvanathinPeyar,
    String? kurumPeyar,
    String? tholaipesi1,
    String? tholaipesi2,
    String? minnanchal,
    String? gstin,
    Map<String, String>? mugavari,
    Map<String, String>? oor,
    Map<String, String>? maavattam,
    Map<String, String>? maanilam,
    Map<String, String>? naadu,
    String? anchalkuriyeedu,
    Map<String, String>? vangiPeyar,
    Map<String, String>? kilai,
    String? vangiKanakku,
    String? ifsc,
    String? ovuru,
    String? agalaOvuru,
    String? thallaippuVadivu,
    String? kaiyoppam,
    String? oppamPeyar,
    Map<String, String>? adaimozhi,
    String? upiId,
    String? thottranNiram,
  }) {
    return VanigaTharavugal(
      id: id ?? this.id,
      mudhanMozhi: mudhanMozhi ?? this.mudhanMozhi,
      thunaiMozhi: thunaiMozhi ?? this.thunaiMozhi,
      iruMozhi: iruMozhi ?? this.iruMozhi,
      niruvanathinPeyar:
          niruvanathinPeyar ?? Map<String, String>.from(this.niruvanathinPeyar),
      kurumPeyar: kurumPeyar ?? this.kurumPeyar,
      tholaipesi1: tholaipesi1 ?? this.tholaipesi1,
      tholaipesi2: tholaipesi2 ?? this.tholaipesi2,
      minnanchal: minnanchal ?? this.minnanchal,
      gstin: gstin ?? this.gstin,
      mugavari: mugavari ?? Map<String, String>.from(this.mugavari),
      oor: oor ?? Map<String, String>.from(this.oor),
      maavattam: maavattam ?? Map<String, String>.from(this.maavattam),
      maanilam: maanilam ?? Map<String, String>.from(this.maanilam),
      naadu: naadu ?? Map<String, String>.from(this.naadu),
      anchalkuriyeedu: anchalkuriyeedu ?? this.anchalkuriyeedu,
      vangiPeyar: vangiPeyar ?? Map<String, String>.from(this.vangiPeyar),
      kilai: kilai ?? Map<String, String>.from(this.kilai),
      vangiKanakku: vangiKanakku ?? this.vangiKanakku,
      ifsc: ifsc ?? this.ifsc,
      ovuru: ovuru ?? this.ovuru,
      agalaOvuru: agalaOvuru ?? this.agalaOvuru,
      thallaippuVadivu: thallaippuVadivu ?? this.thallaippuVadivu,
      kaiyoppam: kaiyoppam ?? this.kaiyoppam,
      oppamPeyar: oppamPeyar ?? this.oppamPeyar,
      adaimozhi: adaimozhi ?? Map<String, String>.from(this.adaimozhi),
      upiId: upiId ?? this.upiId,
      thottranNiram: thottranNiram ?? this.thottranNiram,
    );
  }
}
