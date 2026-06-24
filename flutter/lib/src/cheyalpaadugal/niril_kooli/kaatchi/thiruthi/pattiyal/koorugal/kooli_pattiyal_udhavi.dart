import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const _draftKey = 'niril_draft_coolie_invoice';

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

  // ── Draft persistence ───────────────────────────────────────────────────

  /// Serialises current state to SharedPreferences.
  static Future<void> saveDraft(KooliThiruththiNilaimai state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = jsonEncode({
        'vanigarId': state.selectedVanigarId,
        'vanigarPeyar': state.selectedVanigarPeyar,
        'niruvanamId': state.selectedNiruvanamId,
        'pattiyalNaal': state.pattiyalNaal.toIso8601String(),
        'items': PattiyalUthavigal.kooliListToJson(state.items),
        'setharamGrams': state.setharamGrams,
        'thapaalThogai': state.thapaalThogai,
        'ahimsaPattuThogai': state.ahimsaPattuThogai,
        'piraVarivugal':
            PattiyalUthavigal.piraVarivuListToJson(state.piraVarivugal),
        'showBankDetails': state.showBankDetails,
      });
      await prefs.setString(_draftKey, draft);
    } catch (_) {}
  }

  /// Attempts to restore a draft. Returns null if no valid draft exists
  /// or if the user declines. Shows a dialog for confirmation.
  static Future<KooliThiruththiNilaimai?> tryRestoreDraft(
      BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString(_draftKey);
      if (draftJson == null || draftJson.isEmpty) return null;

      final draft = jsonDecode(draftJson) as Map<String, dynamic>;
      final items = draft['items'] as String? ?? '[]';
      final name = draft['vanigarPeyar'] as String? ?? '';
      if (items == '[]' && name.isEmpty) {
        await prefs.remove(_draftKey);
        return null;
      }

      if (!context.mounted) return null;

      final restore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('வரைவு மீட்கவா?'),
          content: const Text('சேமிக்காத வரைவு உள்ளது. மீட்டமைக்கவா?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('நிராகரி'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('மீட்கவும்'),
            ),
          ],
        ),
      );

      if (restore == true) {
        final parsedItems = PattiyalUthavigal.kooliListFromJson(items);
        final piraVarivugal = PattiyalUthavigal.piraVarivuListFromJson(
            draft['piraVarivugal'] as String? ?? '[]');
        return KooliThiruththiNilaimai(
          selectedVanigarId: draft['vanigarId'] as int?,
          selectedVanigarPeyar: draft['vanigarPeyar'] as String? ?? '',
          selectedNiruvanamId: draft['niruvanamId'] as int?,
          pattiyalNaal: DateTime.tryParse(
                  draft['pattiyalNaal'] as String? ?? '') ??
              DateTime.now(),
          items:
              parsedItems.isEmpty ? [const KooliUrupadi()] : parsedItems,
          setharamGrams:
              (draft['setharamGrams'] as num?)?.toDouble() ?? 0,
          thapaalThogai:
              (draft['thapaalThogai'] as num?)?.toDouble() ?? 0,
          ahimsaPattuThogai:
              (draft['ahimsaPattuThogai'] as num?)?.toDouble() ?? 0,
          piraVarivugal: piraVarivugal,
          showBankDetails: draft['showBankDetails'] as bool? ?? true,
        );
      } else {
        await prefs.remove(_draftKey);
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Removes the saved draft.
  static Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }
}
