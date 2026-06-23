import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../amaippugal/tharavu/vaniga_tharavugal_provider.dart';
import 'patru_kalanjiyam.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final patruKalanjiyamProvider = Provider<PatruKalanjiyam>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PatruKalanjiyam(db);
});

// ── Mode-Aware Receipt Stream ───────────────────────────────────────────────

/// Watches all receipts for the current app mode.
/// Coolie receipts and Silk receipts are completely isolated.
final patrugalStreamProvider =
    StreamProvider<List<PatrugalEntry>>((ref) {
  final kalanjiyam = ref.watch(patruKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchPatrugal(seyaliVagai);
});

// ── Unpaid Invoices (for receipt editor picker) ─────────────────────────────

/// Watches all invoices for the current mode (the editor filters further
/// by checking paid amounts to identify unpaid/partially-paid invoices).
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
