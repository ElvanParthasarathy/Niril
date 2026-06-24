import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'pattiyal_kalanjiyam.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final pattiyalKalanjiyamProvider = Provider<PattiyalKalanjiyam>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PattiyalKalanjiyam(db);
});

// ── Mode-Aware Invoice List (one-shot, pull-to-refresh) ─────────────────────

/// Fetches all invoices once for the current app mode.
/// Call `ref.invalidate(pattiyalgalProvider)` after any CRUD to refresh.
final pattiyalgalProvider =
    FutureProvider<List<PatrucheettuEntry>>((ref) {
  final kalanjiyam = ref.watch(pattiyalKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.getPattiyalgal(seyaliVagai);
});

// ── Editing State ───────────────────────────────────────────────────────────

/// Holds the invoice currently being edited (null = creating new).
final editingPattiyalProvider =
    StateProvider<PatrucheettuEntry?>((ref) => null);

// ── Selection Mode ──────────────────────────────────────────────────────────

/// Whether the invoice list is in selection mode.
final pattiyalSelectionModeProvider = StateProvider<bool>((ref) => false);

/// Set of currently selected invoice IDs.
final selectedPattiyalIdsProvider = StateProvider<Set<int>>((ref) => {});

// ── Recycle Bin (Meetpagam) ──────────────────────────────────────────────────

/// Fetches all soft-deleted invoices once for the current app mode.
/// Call `ref.invalidate(deletedPattiyalgalProvider)` after restore/purge.
final deletedPattiyalgalProvider =
    FutureProvider<List<PatrucheettuEntry>>((ref) {
  final kalanjiyam = ref.watch(pattiyalKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.getDeletedPattiyalgal(seyaliVagai);
});
