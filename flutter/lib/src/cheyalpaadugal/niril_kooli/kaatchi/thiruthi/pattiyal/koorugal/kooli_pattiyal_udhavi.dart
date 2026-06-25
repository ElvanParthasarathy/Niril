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
    this.selectedVanigarPeyarMap = const {},
    this.selectedVanigarMunvariMap = const {},
    required this.pattiyalNaal,
    this.items = const [],
    this.setharamGrams = 0,
    this.thabaalThogai = 0,
    this.ahimsaPattuThogai = 0,
    this.piraVarivugal = const [],
    this.showBankDetails = true,
    this.invoiceNumberOverride = '',
  });

  final int? selectedNiruvanamId;
  final NiruvanaTharavugal? selectedProfile;
  final int? selectedVanigarId;
  final Map<String, String> selectedVanigarPeyarMap;
  final Map<String, String> selectedVanigarMunvariMap;
  final DateTime pattiyalNaal;
  final List<KooliUrupadi> items;
  final double setharamGrams;
  final double thabaalThogai;
  final double ahimsaPattuThogai;
  final List<PiraVarivu> piraVarivugal;
  final bool showBankDetails;

  /// Manual override for the bill number (e.g. "CB-42").
  /// Empty string means auto-generate.
  final String invoiceNumberOverride;
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
      selectedVanigarPeyarMap: entry.vanigarPeyar,
      selectedVanigarMunvariMap: entry.vanigarMunvari,
      pattiyalNaal: entry.pattiyalNaal,
      items: items,
      setharamGrams: entry.setharamGrams,
      thabaalThogai: entry.thabaalThogai,
      ahimsaPattuThogai: entry.ahimsaPattuThogai,
      piraVarivugal: piraVarivugal,
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Saves the coolie invoice (create or update). Returns error string if any.
  static Future<String?> save({
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

    // Determine final bill number and vanakkam
    late final String finalBillNumber;
    late final int vanakkam;

    if (state.invoiceNumberOverride.isNotEmpty) {
      // Manual override — user typed a custom number
      finalBillNumber = state.invoiceNumberOverride;
      final parts = state.invoiceNumberOverride.split('-');
      vanakkam = int.tryParse(parts.last) ?? 1;
    } else if (editingEntry != null) {
      // Editing without override — keep existing number
      finalBillNumber = editingEntry.patrucheettuEn;
      vanakkam = editingEntry.vanakkam;
    } else {
      // New invoice — auto-generate
      vanakkam = await kalanjiyam.getNextVanakkam(
          'coolie', state.selectedNiruvanamId, finYear);
      finalBillNumber =
          kalanjiyam.formatPattiyalEn(profilePrefix, vanakkam);
    }

    // Duplicate check
    final isDuplicate = await kalanjiyam.isPattiyalEnDuplicate(
      'coolie',
      state.selectedNiruvanamId,
      finYear,
      finalBillNumber,
      excludeId: editingEntry?.id,
    );

    if (isDuplicate) {
      return 'Invoice number $finalBillNumber already exists!';
    }

    if (editingEntry != null) {
      // ── Update ──
      await kalanjiyam.updatePattiyal(
        editingEntry.id,
        PatrucheettuTableCompanion(
          patrucheettuEn: state.invoiceNumberOverride.isNotEmpty
              ? Value(finalBillNumber)
              : const Value.absent(),
          vanakkam: state.invoiceNumberOverride.isNotEmpty
              ? Value(vanakkam)
              : const Value.absent(),
          vanigarId: Value(state.selectedVanigarId),
          vanigarPeyar: Value(state.selectedVanigarPeyarMap),
          vanigarMunvari: Value(state.selectedVanigarMunvariMap),
          niruvanamId: Value(state.selectedNiruvanamId),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.kooliListToJson(validItems)),
          mothaThogai: Value(totals.perumMothangal),
          mothaEdai: Value(totals.mothaEdai),
          setharamGrams: Value(state.setharamGrams),
          thabaalThogai: Value(state.thabaalThogai),
          ahimsaPattuThogai: Value(state.ahimsaPattuThogai),
          piravariVugal: Value(
              PattiyalUthavigal.piraVarivuListToJson(state.piraVarivugal)),
          vangiTharavugal: Value(bankSnapshot),
          createdAt: Value(editingEntry.createdAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // ── Create ──
      await kalanjiyam.createPattiyal(
        PatrucheettuTableCompanion.insert(
          seyaliVagai: 'coolie',
          patrucheettuEn: finalBillNumber,
          finYear: finYear,
          vanakkam: Value(vanakkam),
          niruvanamId: Value(state.selectedNiruvanamId),
          vanigarPeyar: Value(state.selectedVanigarPeyarMap),
          vanigarMunvari: Value(state.selectedVanigarMunvariMap),
          vanigarId: Value(state.selectedVanigarId),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.kooliListToJson(validItems)),
          mothaThogai: Value(totals.perumMothangal),
          mothaEdai: Value(totals.mothaEdai),
          setharamGrams: Value(state.setharamGrams),
          thabaalThogai: Value(state.thabaalThogai),
          ahimsaPattuThogai: Value(state.ahimsaPattuThogai),
          piravariVugal: Value(
              PattiyalUthavigal.piraVarivuListToJson(state.piraVarivugal)),
          vangiTharavugal: Value(bankSnapshot),
        ),
      );
    }
    
    return null;
  }

  // ── Draft persistence ───────────────────────────────────────────────────

  /// Serialises current state to SharedPreferences.
  static Future<void> saveDraft(KooliThiruththiNilaimai state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = jsonEncode({
        'vanigarId': state.selectedVanigarId,
        'vanigarPeyarMap': state.selectedVanigarPeyarMap,
        'vanigarMunvariMap': state.selectedVanigarMunvariMap,
        'niruvanamId': state.selectedNiruvanamId,
        'pattiyalNaal': state.pattiyalNaal.toIso8601String(),
        'items': PattiyalUthavigal.kooliListToJson(state.items),
        'setharamGrams': state.setharamGrams,
        'thabaalThogai': state.thabaalThogai,
        'ahimsaPattuThogai': state.ahimsaPattuThogai,
        'piraVarivugal':
            PattiyalUthavigal.piraVarivuListToJson(state.piraVarivugal),
        'showBankDetails': state.showBankDetails,
        'invoiceNumberOverride': state.invoiceNumberOverride,
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
      final nameMap = (draft['vanigarPeyarMap'] as Map?)?.cast<String, String>() ?? {};
      final addrMap = (draft['vanigarMunvariMap'] as Map?)?.cast<String, String>() ?? {};
      if (items == '[]' && nameMap.isEmpty) {
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
          selectedVanigarPeyarMap: nameMap,
          selectedVanigarMunvariMap: addrMap,
          selectedNiruvanamId: draft['niruvanamId'] as int?,
          pattiyalNaal: DateTime.tryParse(
                  draft['pattiyalNaal'] as String? ?? '') ??
              DateTime.now(),
          items:
              parsedItems.isEmpty ? [const KooliUrupadi()] : parsedItems,
          setharamGrams:
              (draft['setharamGrams'] as num?)?.toDouble() ?? 0,
          thabaalThogai:
              (draft['thabaalThogai'] as num?)?.toDouble() ?? 0,
          ahimsaPattuThogai:
              (draft['ahimsaPattuThogai'] as num?)?.toDouble() ?? 0,
          piraVarivugal: piraVarivugal,
          showBankDetails: draft['showBankDetails'] as bool? ?? true,
          invoiceNumberOverride:
              draft['invoiceNumberOverride'] as String? ?? '',
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
