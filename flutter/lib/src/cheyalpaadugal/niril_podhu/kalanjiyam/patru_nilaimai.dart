import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'patru_kalanjiyam.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final patruKalanjiyamProvider = Provider<PatruKalanjiyam>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PatruKalanjiyam(db);
});

// ── Mode-Aware Receipt List (one-shot, pull-to-refresh) ─────────────────────

/// Fetches all receipts once for the current app mode.
/// Call `ref.invalidate(patrugalProvider)` after any CRUD to refresh.
final patrugalProvider =
    FutureProvider<List<PatrugalEntry>>((ref) {
  final kalanjiyam = ref.watch(patruKalanjiyamProvider);

  // Defer mode-change invalidation to avoid setState-during-build
  ref.listen(appModeProvider, (_, __) {
    Future.microtask(() => ref.invalidateSelf());
  });
  final mode = ref.read(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.getPatrugal(seyaliVagai);
});

// ── Unpaid Invoices (for receipt editor picker) ─────────────────────────────

/// Watches all invoices for the current mode (the editor filters further
/// by checking paid amounts to identify unpaid/partially-paid invoices).
/// NOTE: kept as StreamProvider — used in editor, not scrolling list.
final unpaidPattiyalgalProvider =
    StreamProvider<List<PatrucheettuEntry>>((ref) {
  final kalanjiyam = ref.watch(patruKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchUnpaidInvoices(seyaliVagai);
});

// ── Selection Mode ──────────────────────────────────────────────────────────

/// Whether the receipt list is in selection mode.
final patruSelectionModeProvider = StateProvider<bool>((ref) => false);

/// Set of currently selected receipt IDs.
final selectedPatruIdsProvider = StateProvider<Set<int>>((ref) => {});

// ── Invoice Payment Status ──────────────────────────────────────────────────

/// Per-invoice paid amount (reactive stream).
/// Used by invoice list cards to show payment status badges.
/// NOTE: kept as StreamProvider — used per-invoice, not in scrolling list.
final paidAmountProvider = StreamProvider.family<double, int>((ref, pattiyalId) {
  final kalanjiyam = ref.watch(patruKalanjiyamProvider);
  return kalanjiyam.watchPaidAmount(pattiyalId);
});
