import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../../niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';
import '../../../thiraigal/amaippugal/pattu_mugavari_tharavu.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டு பட்டியல் உதவி — Helper for load / save / draft logic
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of all editor state fields.
/// Used to transfer data between helper ↔ widget without tight coupling.
class PattuThiruththiNilaimai {
  const PattuThiruththiNilaimai({
    this.selectedNiruvanamId,
    this.selectedVaangunarId,
    this.selectedVaangunarPeyarMap = const {},
    this.selectedVaangunarMunvariMap = const {},
    this.customerState = '',
    this.pattiyalVagai = 'tax-invoice',
    required this.pattiyalNaal,
    this.placeOfSupply = '',
    this.placeOfSupplyTa = '',
    this.invoiceNumberOverride = '',
    this.items = const [],
    this.globalDiscountValue = 0,
    this.globalDiscountType = 'percentage',
  });

  final int? selectedNiruvanamId;
  final int? selectedVaangunarId;
  final Map<String, String> selectedVaangunarPeyarMap;
  final Map<String, String> selectedVaangunarMunvariMap;
  final String customerState;
  final String pattiyalVagai;
  final DateTime pattiyalNaal;
  final String placeOfSupply;
  final String placeOfSupplyTa;
  final String invoiceNumberOverride;
  final List<PattuUrupadi> items;
  final double globalDiscountValue;
  final String globalDiscountType;
}

/// Pure data helper — no widget dependency. Handles:
///   • Loading from an existing PatrucheettuEntry (edit / duplicate)
///   • Saving (create + update) via PattiyalKalanjiyam
///   • Draft persistence via SharedPreferences
class PattuPattiyalUthavi {
  PattuPattiyalUthavi._();

  static const _draftKey = 'niril_draft_silk_invoice';

  // ── Load from entry (edit OR duplicate) ──────────────────────────────────

  /// Parses a [PatrucheettuEntry] into a state snapshot.
  /// When [isDuplicate] is true, the invoice number is cleared and date is
  /// set to now (creating a fresh copy).
  static PattuThiruththiNilaimai loadFromEntry(
    PatrucheettuEntry entry, {
    bool isDuplicate = false,
  }) {
    // Parse items
    var items = PattiyalUthavigal.pattuListFromJson(entry.tharavugal);
    if (items.isEmpty) items = [const PattuUrupadi()];

    // Parse settings
    double globalDiscountValue = 0;
    String globalDiscountType = 'percentage';
    String placeOfSupply = '';
    String placeOfSupplyTa = '';
    try {
      final settings =
          jsonDecode(entry.sonthaViruppangal) as Map<String, dynamic>;
      globalDiscountValue =
          (settings['globalDiscountValue'] as num?)?.toDouble() ?? 0;
      globalDiscountType =
          settings['globalDiscountType'] as String? ?? 'percentage';
      placeOfSupply = settings['placeOfSupply'] as String? ?? '';
      placeOfSupplyTa = settings['placeOfSupplyTa'] as String? ?? '';
    } catch (_) {}

    // Resolve Tamil for Place of Supply if missing
    if (placeOfSupply.isNotEmpty && placeOfSupplyTa.isEmpty) {
      final match = silkIndianStates.where(
        (s) => (s['en'] ?? '').toLowerCase() == placeOfSupply.toLowerCase(),
      ).firstOrNull;
      if (match != null) placeOfSupplyTa = match['ta'] ?? '';
    }

    return PattuThiruththiNilaimai(
      selectedNiruvanamId: entry.niruvanamId,
      selectedVaangunarId: entry.vaangunarId,
      selectedVaangunarPeyarMap: entry.vaangunarPeyar,
      selectedVaangunarMunvariMap: entry.vaangunarMunvari,
      pattiyalVagai: entry.pattiyalVagai,
      pattiyalNaal: isDuplicate ? DateTime.now() : entry.pattiyalNaal,
      placeOfSupply: placeOfSupply,
      placeOfSupplyTa: placeOfSupplyTa,
      invoiceNumberOverride: isDuplicate ? '' : entry.patrucheettuEn,
      items: items,
      globalDiscountValue: globalDiscountValue,
      globalDiscountType: globalDiscountType,
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Saves the invoice (create or update) and returns the generated number. Returns error string if any.
  static Future<String?> save({
    required PattiyalKalanjiyam kalanjiyam,
    required PattuThiruththiNilaimai state,
    required PattuMothangal totals,
    required String profilePrefix,
    PatrucheettuEntry? editingEntry,
  }) async {
    final finYear = PattiyalKalanjiyam.getCurrentFinYear();
    final validItems =
        state.items.where((i) => i.alavu > 0 && i.vilai > 0).toList();

    final settingsJson = jsonEncode({
      'globalDiscountValue': state.globalDiscountValue,
      'globalDiscountType': state.globalDiscountType,
      'placeOfSupply': state.placeOfSupply,
      'placeOfSupplyTa': state.placeOfSupplyTa,
    });

    // Determine final bill number
    late final String finalBillNumber;
    late final int vanakkam;

    if (state.invoiceNumberOverride.isNotEmpty) {
      finalBillNumber = state.invoiceNumberOverride;
      vanakkam = await kalanjiyam.getNextVanakkam(
          'silk', state.selectedNiruvanamId, finYear);
    } else if (editingEntry != null) {
      finalBillNumber = editingEntry.patrucheettuEn;
      vanakkam = editingEntry.vanakkam;
    } else {
      vanakkam = await kalanjiyam.getNextVanakkam(
          'silk', state.selectedNiruvanamId, finYear);
      finalBillNumber =
          kalanjiyam.formatPattiyalEn(profilePrefix, vanakkam);
    }

    // Duplicate check
    final isDuplicate = await kalanjiyam.isPattiyalEnDuplicate(
      'silk',
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
      final invNumChanged =
          state.invoiceNumberOverride != editingEntry.patrucheettuEn;
      await kalanjiyam.updatePattiyal(
        editingEntry.id,
        PatrucheettuTableCompanion(
          patrucheettuEn: invNumChanged
              ? Value(finalBillNumber)
              : const Value.absent(),
          niruvanamId: Value(state.selectedNiruvanamId),
          vaangunarId: Value(state.selectedVaangunarId),
          vaangunarPeyar: Value(state.selectedVaangunarPeyarMap),
          vaangunarMunvari: Value(state.selectedVaangunarMunvariMap),
          pattiyalVagai: Value(state.pattiyalVagai),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.pattuListToJson(validItems)),
          mothaThogai: Value(totals.mothaMothangal),
          thallupadi: Value(totals.thallupadiMothangal),
          variThogai: Value(totals.variMothangal),
          variTharavugal: Value(jsonEncode(totals.variToJson())),
          sonthaViruppangal: Value(settingsJson),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // ── Create ──
      await kalanjiyam.createPattiyal(
        PatrucheettuTableCompanion.insert(
          seyaliVagai: 'silk',
          patrucheettuEn: finalBillNumber,
          finYear: finYear,
          vanakkam: Value(vanakkam),
          niruvanamId: Value(state.selectedNiruvanamId),
          vaangunarPeyar: Value(state.selectedVaangunarPeyarMap),
          vaangunarMunvari: Value(state.selectedVaangunarMunvariMap),
          vaangunarId: Value(state.selectedVaangunarId),
          pattiyalVagai: Value(state.pattiyalVagai),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.pattuListToJson(validItems)),
          mothaThogai: Value(totals.mothaMothangal),
          thallupadi: Value(totals.thallupadiMothangal),
          variThogai: Value(totals.variMothangal),
          variTharavugal: Value(jsonEncode(totals.variToJson())),
          sonthaViruppangal: Value(settingsJson),
        ),
      );
    }
    
    return null;
  }

  // ── Draft persistence ───────────────────────────────────────────────────

  /// Serialises current state to SharedPreferences.
  static Future<void> saveDraft(PattuThiruththiNilaimai state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = jsonEncode({
        'vaangunarId': state.selectedVaangunarId,
        'vaangunarPeyarMap': state.selectedVaangunarPeyarMap,
        'vaangunarMunvariMap': state.selectedVaangunarMunvariMap,
        'customerState': state.customerState,
        'niruvanamId': state.selectedNiruvanamId,
        'pattiyalVagai': state.pattiyalVagai,
        'pattiyalNaal': state.pattiyalNaal.toIso8601String(),
        'placeOfSupply': state.placeOfSupply,
        'placeOfSupplyTa': state.placeOfSupplyTa,
        'invoiceNumberOverride': state.invoiceNumberOverride,
        'items': PattiyalUthavigal.pattuListToJson(state.items),
        'globalDiscountValue': state.globalDiscountValue,
        'globalDiscountType': state.globalDiscountType,
      });
      await prefs.setString(_draftKey, draft);
    } catch (_) {}
  }

  /// Attempts to restore a draft. Returns null if no valid draft exists
  /// or if the user declines. Shows a dialog for confirmation.
  static Future<PattuThiruththiNilaimai?> tryRestoreDraft(
      BuildContext context, WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString(_draftKey);
      if (draftJson == null || draftJson.isEmpty) return null;

      final draft = jsonDecode(draftJson) as Map<String, dynamic>;
      final items = draft['items'] as String? ?? '[]';
      final nameMap = (draft['vaangunarPeyarMap'] as Map?)?.cast<String, String>() ?? {};
      final addrMap = (draft['vaangunarMunvariMap'] as Map?)?.cast<String, String>() ?? {};
      if (items == '[]' && nameMap.isEmpty) {
        await prefs.remove(_draftKey);
        return null;
      }

      if (!context.mounted) return null;

      final restore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(K.varaivuMeetka.tr(context, ref)),
          content: Text(K.chaemikkaadhaVaraivu.tr(context, ref)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(K.purakkaniPtn.tr(context, ref)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(K.meetkavum.tr(context, ref)),
            ),
          ],
        ),
      );

      if (restore == true) {
        final parsedItems = PattiyalUthavigal.pattuListFromJson(items);
        return PattuThiruththiNilaimai(
          selectedVaangunarId: draft['vaangunarId'] as int?,
          selectedVaangunarPeyarMap: nameMap,
          selectedVaangunarMunvariMap: addrMap,
          customerState: draft['customerState'] as String? ?? '',
          selectedNiruvanamId: draft['niruvanamId'] as int?,
          pattiyalVagai: draft['pattiyalVagai'] as String? ?? 'tax-invoice',
          pattiyalNaal: DateTime.tryParse(
                  draft['pattiyalNaal'] as String? ?? '') ??
              DateTime.now(),
          placeOfSupply: draft['placeOfSupply'] as String? ?? '',
          placeOfSupplyTa: draft['placeOfSupplyTa'] as String? ?? '',
          invoiceNumberOverride:
              draft['invoiceNumberOverride'] as String? ?? '',
          items: parsedItems.isEmpty ? [const PattuUrupadi()] : parsedItems,
          globalDiscountValue:
              (draft['globalDiscountValue'] as num?)?.toDouble() ?? 0,
          globalDiscountType:
              draft['globalDiscountType'] as String? ?? 'percentage',
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
