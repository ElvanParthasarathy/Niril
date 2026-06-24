import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// கூலிப் பட்டியல் உதவி — Helper for load / save logic
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of all coolie editor state fields.
/// Used to transfer data between helper ↔ widget without tight coupling.
class KooliThiruththiNilaimai {
  const KooliThiruththiNilaimai({
    this.selectedNiruvanamId,
    this.selectedProfile,
    this.selectedVanigarId,
    this.selectedVanigarPeyar = '',
    required this.pattiyalNaal,
    this.items = const [],
    this.setharamGrams = 0,
    this.thapaalThogai = 0,
    this.ahimsaPattuThogai = 0,
    this.piraVarivugal = const [],
    this.showBankDetails = true,
  });

  final int? selectedNiruvanamId;
  final NiruvanaTharavugal? selectedProfile;
  final int? selectedVanigarId;
  final String selectedVanigarPeyar;
  final DateTime pattiyalNaal;
  final List<KooliUrupadi> items;
  final double setharamGrams;
  final double thapaalThogai;
  final double ahimsaPattuThogai;
  final List<PiraVarivu> piraVarivugal;
  final bool showBankDetails;
}

/// Pure data helper — no widget dependency. Handles:
///   • Loading from an existing PatrucheettuEntry (edit)
///   • Saving (create + update) via PattiyalKalanjiyam
class KooliPattiyalUthavi {
  KooliPattiyalUthavi._();

  // ── Load from entry (edit) ────────────────────────────────────────────────

  /// Parses a [PatrucheettuEntry] into a state snapshot for editing.
  static KooliThiruththiNilaimai loadFromEntry(PatrucheettuEntry entry) {
    // Parse items
    var items = PattiyalUthavigal.kooliListFromJson(entry.tharavugal);
    if (items.isEmpty) items = [const KooliUrupadi()];

    // Parse other charges
    final piraVarivugal =
        PattiyalUthavigal.piraVarivuListFromJson(entry.piravariVugal);

    return KooliThiruththiNilaimai(
      selectedNiruvanamId: entry.niruvanamId,
      selectedVanigarId: entry.vanigarId,
      selectedVanigarPeyar: entry.vanigarPeyar,
      pattiyalNaal: entry.pattiyalNaal,
      items: items,
      setharamGrams: entry.setharamGrams,
      thapaalThogai: entry.thapaalThogai,
      ahimsaPattuThogai: entry.ahimsaPattuThogai,
      piraVarivugal: piraVarivugal,
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Saves the coolie invoice (create or update).
  static Future<void> save({
    required PattiyalKalanjiyam kalanjiyam,
    required KooliThiruththiNilaimai state,
    required KooliMothangal totals,
    required String profilePrefix,
    required NiruvanaTharavugal profile,
    PatrucheettuEntry? editingEntry,
  }) async {
    final finYear = PattiyalKalanjiyam.getCurrentFinYear();
    final validItems =
        state.items.where((i) => i.edai > 0 && i.vilai > 0).toList();

    // Bank snapshot from profile
    final bankSnapshot = jsonEncode({
      'vangiPeyar': profile.vangiPeyar,
      'kilai': profile.kilai,
      'vangiKanakku': profile.vangiKanakku,
      'ifsc': profile.ifsc,
      'upiId': profile.upiId,
    });

    if (editingEntry != null) {
      // ── Update ──
      await kalanjiyam.updatePattiyal(
        editingEntry.id,
        PatrucheettuTableCompanion(
          vanigarId: Value(state.selectedVanigarId),
          vanigarPeyar: Value(state.selectedVanigarPeyar),
          niruvanamId: Value(state.selectedNiruvanamId),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.kooliListToJson(validItems)),
          mothaThogai: Value(totals.perumMothangal),
          mothaEdai: Value(totals.mothaEdai),
          setharamGrams: Value(state.setharamGrams),
          thapaalThogai: Value(state.thapaalThogai),
          ahimsaPattuThogai: Value(state.ahimsaPattuThogai),
          piravariVugal: Value(
              PattiyalUthavigal.piraVarivuListToJson(state.piraVarivugal)),
          vangiTharavugal: Value(bankSnapshot),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // ── Create ──
      final vanakkam = await kalanjiyam.getNextVanakkam(
          'coolie', state.selectedNiruvanamId, finYear);
      final billNumber =
          kalanjiyam.formatPattiyalEn(profilePrefix, vanakkam);

      await kalanjiyam.createPattiyal(
        PatrucheettuTableCompanion.insert(
          seyaliVagai: 'coolie',
          patrucheettuEn: billNumber,
          finYear: finYear,
          vanakkam: Value(vanakkam),
          niruvanamId: Value(state.selectedNiruvanamId),
          vanigarPeyar: state.selectedVanigarPeyar,
          vanigarId: Value(state.selectedVanigarId),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.kooliListToJson(validItems)),
          mothaThogai: Value(totals.perumMothangal),
          mothaEdai: Value(totals.mothaEdai),
          setharamGrams: Value(state.setharamGrams),
          thapaalThogai: Value(state.thapaalThogai),
          ahimsaPattuThogai: Value(state.ahimsaPattuThogai),
          piravariVugal: Value(
              PattiyalUthavigal.piraVarivuListToJson(state.piraVarivugal)),
          vangiTharavugal: Value(bankSnapshot),
        ),
      );
    }
  }
}
