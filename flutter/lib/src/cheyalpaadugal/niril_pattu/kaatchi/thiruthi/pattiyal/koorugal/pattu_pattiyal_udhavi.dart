import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;

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
    this.selectedVanigarId,
    this.selectedVanigarPeyar = '',
    this.customerState = '',
    this.pattiyalVagai = 'tax-invoice',
    required this.pattiyalNaal,
    this.placeOfSupply = '',
    this.placeOfSupplyTa = '',
    this.invoiceNumberOverride = '',
    this.items = const [],
    this.globalDiscountValue = 0,
    this.globalDiscountType = 'percentage',
    this.nibandhanaigal = '',
    this.ullkurippu = '',
  });

  final int? selectedNiruvanamId;
  final int? selectedVanigarId;
  final String selectedVanigarPeyar;
  final String customerState;
  final String pattiyalVagai;
  final DateTime pattiyalNaal;
  final String placeOfSupply;
  final String placeOfSupplyTa;
  final String invoiceNumberOverride;
  final List<PattuUrupadi> items;
  final double globalDiscountValue;
  final String globalDiscountType;
  final String nibandhanaigal;
  final String ullkurippu;
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
      selectedVanigarId: entry.vanigarId,
      selectedVanigarPeyar: entry.vanigarPeyar,
      pattiyalVagai: entry.pattiyalVagai,
      pattiyalNaal: isDuplicate ? DateTime.now() : entry.pattiyalNaal,
      placeOfSupply: placeOfSupply,
      placeOfSupplyTa: placeOfSupplyTa,
      invoiceNumberOverride: isDuplicate ? '' : entry.patrucheettuEn,
      items: items,
      globalDiscountValue: globalDiscountValue,
      globalDiscountType: globalDiscountType,
      nibandhanaigal: entry.nibandhanaigal,
      ullkurippu: entry.ullkurippu,
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Saves the invoice (create or update) and returns the generated number.
  static Future<void> save({
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

    if (editingEntry != null) {
      // ── Update ──
      final invNumChanged =
          state.invoiceNumberOverride != editingEntry.patrucheettuEn;
      await kalanjiyam.updatePattiyal(
        editingEntry.id,
        PatrucheettuTableCompanion(
          patrucheettuEn: invNumChanged
              ? Value(state.invoiceNumberOverride)
              : const Value.absent(),
          niruvanamId: Value(state.selectedNiruvanamId),
          vanigarId: Value(state.selectedVanigarId),
          vanigarPeyar: Value(state.selectedVanigarPeyar),
          pattiyalVagai: Value(state.pattiyalVagai),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.pattuListToJson(validItems)),
          mothaThogai: Value(totals.mothaMothangal),
          thallupadi: Value(totals.thallupadiMothangal),
          variThogai: Value(totals.variMothangal),
          variTharavugal: Value(jsonEncode(totals.variToJson())),
          sonthaViruppangal: Value(settingsJson),
          nibandhanaigal: Value(state.nibandhanaigal),
          ullkurippu: Value(state.ullkurippu),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // ── Create ──
      String invoiceNumber;
      int vanakkam;
      if (state.invoiceNumberOverride.isNotEmpty) {
        invoiceNumber = state.invoiceNumberOverride;
        vanakkam = await kalanjiyam.getNextVanakkam(
            'silk', state.selectedNiruvanamId, finYear);
      } else {
        vanakkam = await kalanjiyam.getNextVanakkam(
            'silk', state.selectedNiruvanamId, finYear);
        invoiceNumber =
            kalanjiyam.formatPattiyalEn(profilePrefix, vanakkam);
      }

      await kalanjiyam.createPattiyal(
        PatrucheettuTableCompanion.insert(
          seyaliVagai: 'silk',
          patrucheettuEn: invoiceNumber,
          finYear: finYear,
          vanakkam: Value(vanakkam),
          niruvanamId: Value(state.selectedNiruvanamId),
          vanigarPeyar: state.selectedVanigarPeyar,
          vanigarId: Value(state.selectedVanigarId),
          pattiyalVagai: Value(state.pattiyalVagai),
          pattiyalNaal: Value(state.pattiyalNaal),
          tharavugal: Value(PattiyalUthavigal.pattuListToJson(validItems)),
          mothaThogai: Value(totals.mothaMothangal),
          thallupadi: Value(totals.thallupadiMothangal),
          variThogai: Value(totals.variMothangal),
          variTharavugal: Value(jsonEncode(totals.variToJson())),
          sonthaViruppangal: Value(settingsJson),
          nibandhanaigal: Value(state.nibandhanaigal),
          ullkurippu: Value(state.ullkurippu),
        ),
      );
    }
  }

  // ── Draft persistence ───────────────────────────────────────────────────

  /// Serialises current state to SharedPreferences.
  static Future<void> saveDraft(PattuThiruththiNilaimai state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = jsonEncode({
        'vanigarId': state.selectedVanigarId,
        'vanigarPeyar': state.selectedVanigarPeyar,
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
        'nibandhanaigal': state.nibandhanaigal,
        'ullkurippu': state.ullkurippu,
      });
      await prefs.setString(_draftKey, draft);
    } catch (_) {}
  }

  /// Attempts to restore a draft. Returns null if no valid draft exists
  /// or if the user declines. Shows a dialog for confirmation.
  static Future<PattuThiruththiNilaimai?> tryRestoreDraft(
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
        final parsedItems = PattiyalUthavigal.pattuListFromJson(items);
        return PattuThiruththiNilaimai(
          selectedVanigarId: draft['vanigarId'] as int?,
          selectedVanigarPeyar: draft['vanigarPeyar'] as String? ?? '',
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
          nibandhanaigal: draft['nibandhanaigal'] as String? ?? '',
          ullkurippu: draft['ullkurippu'] as String? ?? '',
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
