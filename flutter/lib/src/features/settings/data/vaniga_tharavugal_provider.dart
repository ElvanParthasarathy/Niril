import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/app_mode.dart';
import '../../../core/services/niril_backup_service.dart';
import 'vaniga_tharavugal.dart';

/// Provider for the Drift database instance.
/// Overridden in main.dart with the actual database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(AppDatabase.openConnection());
  ref.onDispose(() {
    db.close();
  });
  return db;
});

/// Provider for the business profile (வணிக தரவுகள்).
final vanigaTharavugalProvider =
    StateNotifierProvider<VanigaTharavugalNotifier, VanigaTharavugal?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final mode = ref.watch(appModeProvider);
  final backupService = ref.watch(backupServiceProvider);
  return VanigaTharavugalNotifier(db, mode, backupService);
});

class VanigaTharavugalNotifier extends StateNotifier<VanigaTharavugal?> {
  final AppDatabase _db;
  final AppMode? _mode;
  final NirilBackupService _backupService;

  VanigaTharavugalNotifier(this._db, this._mode, this._backupService) : super(null) {
    _loadProfile();
  }

  String get _modeKey => _mode == AppMode.coolie ? 'coolie' : 'silk';

  Future<void> _loadProfile() async {
    if (_mode == null) {
      state = null;
      return;
    }

    try {
      final entry = await (_db.select(_db.vanigaTharavugalTable)
            ..where((t) => t.seyaliVagai.equals(_modeKey)))
          .getSingleOrNull();

      if (entry != null) {
        state = _entryToModel(entry);
      } else {
        state = null;
      }
    } catch (e) {
      print('Error loading profile from Drift: $e');
      state = null;
    }
  }

  /// Update the profile and persist to SQLite.
  Future<void> updateProfile(VanigaTharavugal profile) async {
    if (_mode == null) return;

    state = profile;

    // Check if a row already exists for this mode
    final existing = await (_db.select(_db.vanigaTharavugalTable)
          ..where((t) => t.seyaliVagai.equals(_modeKey)))
        .getSingleOrNull();

    if (existing != null) {
      // Update existing row
      await (_db.update(_db.vanigaTharavugalTable)
            ..where((t) => t.seyaliVagai.equals(_modeKey)))
          .write(_modelToCompanion(profile));
    } else {
      // Insert new row
      await _db.into(_db.vanigaTharavugalTable).insert(
            _modelToCompanion(profile, includeMode: true),
          );
    }

    // Fire-and-forget auto-backup after every save
    _backupService.createBackup();
  }

  /// Clears the profile data for the current mode.
  Future<void> clearProfile() async {
    if (_mode == null) return;

    await (_db.delete(_db.vanigaTharavugalTable)
          ..where((t) => t.seyaliVagai.equals(_modeKey)))
        .go();
    state = null;
  }

  /// DEV UTILITY: Seed mock data.
  Future<void> seedData() async {
    VanigaTharavugal mockProfile;

    if (_mode == AppMode.silk) {
      mockProfile = VanigaTharavugal(
        mudhanMozhi: 'Tamil',
        thunaiMozhi: 'English',
        iruMozhi: true,
        niruvanathinPeyar: {
          'Tamil': 'ஶ்ரீ ஜெய்பிரியா சில்க்ஸ்',
          'English': 'Sri Jaipriya Silks',
        },
        kurumPeyar: 'SJPS',
        adaimozhi: {
          'Tamil': 'கைத்தறி பட்டு சேலைகள் & ராசில்க்',
          'English': 'Handloom Silk Sarees & Rawsilk',
        },
        tholaipesi1: '8144604797',
        tholaipesi2: '9360779191',
        minnanchal: 'srijaipriyasilks@gmail.com',
        gstin: '33ASSPV0378E1ZD',
        mugavari: {
          'Tamil': '4/606, முதல் தெரு, சிவசக்தி நகர்',
          'English': '4/606, First Street, Sivasakthi Nagar',
        },
        oor: {'Tamil': 'ஆரணி', 'English': 'Arani'},
        maavattam: {
          'Tamil': 'திருவண்ணாமலை மாவட்டம்',
          'English': 'Thiruvannamalai District'
        },
        maanilam: {'Tamil': 'தமிழ்நாடு', 'English': 'Tamil Nadu'},
        naadu: {'Tamil': 'இந்தியா', 'English': 'India'},
        anchalkuriyeedu: '632317',
        vangiPeyar: {
          'Tamil': 'தமிழ்நாடு மெர்கன்டைல் வங்கி',
          'English': 'Tamilnad Mercantile Bank',
        },
        kilai: {'Tamil': 'ஆரணி', 'English': 'Arani'},
        vangiKanakku: '309150050800239',
        ifsc: 'TMBL0000309',
        thallaippuVadivu: 'small',
        oppamPeyar: 'பா. வனிதாஶ்ரீ',
      );
    } else {
      mockProfile = VanigaTharavugal(
        mudhanMozhi: 'Tamil',
        thunaiMozhi: 'English',
        iruMozhi: true,
        niruvanathinPeyar: {
          'Tamil': 'வி.ஆர்.எம். பட்டு முறுக்கு ஆலை',
          'English': 'V.R.M. Silk Twisting Factory',
        },
        kurumPeyar: 'VRM',
        tholaipesi1: '8144604797',
        tholaipesi2: '9360779191',
        minnanchal: 'vrmshreesarathy@gmail.com',
        gstin: '',
        mugavari: {
          'Tamil': '4/606, முதல் தெரு, சிவசக்தி நகர்',
          'English': '4/606, First Street, Sivasakthi Nagar',
        },
        oor: {'Tamil': 'ஆரணி', 'English': 'Arani'},
        maavattam: {
          'Tamil': 'திருவண்ணாமலை மாவட்டம்',
          'English': 'Thiruvannamalai District'
        },
        maanilam: {'Tamil': 'தமிழ்நாடு', 'English': 'Tamil Nadu'},
        naadu: {'Tamil': 'இந்தியா', 'English': 'India'},
        anchalkuriyeedu: '632301',
        vangiPeyar: {
          'Tamil': 'தமிழ்நாடு மெர்கன்டைல் வங்கி',
          'English': 'Tamilnad Mercantile Bank',
        },
        kilai: {'Tamil': 'ஆரணி', 'English': 'Arani'},
        vangiKanakku: '309150050800162',
        ifsc: 'TMBL0000309',
        thallaippuVadivu: 'small',
        oppamPeyar: 'இரா. பார்த்தசாரதி',
        thottranNiram: '#6a1b9a',
      );
    }

    await updateProfile(mockProfile);

    // Fire-and-forget auto-backup after seeding
    _backupService.createBackup();
  }

  // ── Conversion: Drift entry → domain model ──
  VanigaTharavugal _entryToModel(VanigaTharavugalEntry entry) {
    return VanigaTharavugal(
      mudhanMozhi: entry.mudhanMozhi,
      thunaiMozhi: entry.thunaiMozhi,
      iruMozhi: entry.iruMozhi,
      niruvanathinPeyar: entry.niruvanathinPeyar,
      kurumPeyar: entry.kurumPeyar,
      tholaipesi1: entry.tholaipesi1,
      tholaipesi2: entry.tholaipesi2,
      minnanchal: entry.minnanchal,
      gstin: entry.gstin,
      mugavari: entry.mugavari,
      oor: entry.oor,
      maavattam: entry.maavattam,
      maanilam: entry.maanilam,
      naadu: entry.naadu,
      anchalkuriyeedu: entry.anchalkuriyeedu,
      vangiPeyar: entry.vangiPeyar,
      kilai: entry.kilai,
      vangiKanakku: entry.vangiKanakku,
      ifsc: entry.ifsc,
      ovuru: entry.ovuru,
      agalaOvuru: entry.agalaOvuru,
      thallaippuVadivu: entry.thallaippuVadivu,
      kaiyoppam: entry.kaiyoppam,
      oppamPeyar: entry.oppamPeyar,
      adaimozhi: entry.adaimozhi,
      upiId: entry.upiId,
      thottranNiram: entry.thottranNiram,
    );
  }

  // ── Conversion: domain model → Drift companion (for insert/update) ──
  VanigaTharavugalTableCompanion _modelToCompanion(
    VanigaTharavugal model, {
    bool includeMode = false,
  }) {
    return VanigaTharavugalTableCompanion(
      seyaliVagai: includeMode ? Value(_modeKey) : const Value.absent(),
      mudhanMozhi: Value(model.mudhanMozhi),
      thunaiMozhi: Value(model.thunaiMozhi),
      iruMozhi: Value(model.iruMozhi),
      niruvanathinPeyar: Value(model.niruvanathinPeyar),
      kurumPeyar: Value(model.kurumPeyar),
      tholaipesi1: Value(model.tholaipesi1),
      tholaipesi2: Value(model.tholaipesi2),
      minnanchal: Value(model.minnanchal),
      gstin: Value(model.gstin),
      mugavari: Value(model.mugavari),
      oor: Value(model.oor),
      maavattam: Value(model.maavattam),
      maanilam: Value(model.maanilam),
      naadu: Value(model.naadu),
      anchalkuriyeedu: Value(model.anchalkuriyeedu),
      vangiPeyar: Value(model.vangiPeyar),
      kilai: Value(model.kilai),
      vangiKanakku: Value(model.vangiKanakku),
      ifsc: Value(model.ifsc),
      ovuru: Value(model.ovuru),
      agalaOvuru: Value(model.agalaOvuru),
      thallaippuVadivu: Value(model.thallaippuVadivu),
      kaiyoppam: Value(model.kaiyoppam),
      oppamPeyar: Value(model.oppamPeyar),
      adaimozhi: Value(model.adaimozhi),
      upiId: Value(model.upiId),
      thottranNiram: Value(model.thottranNiram),
    );
  }
}
