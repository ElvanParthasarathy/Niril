import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'vaangunar_kalanjiyam.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final vaangunarKalanjiyamProvider = Provider<VaangunarKalanjiyam>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VaangunarKalanjiyam(db);
});

// ── Mode-Aware Merchant List (one-shot, pull-to-refresh) ────────────────────

/// Fetches all merchants once for the current app mode.
/// Call `ref.invalidate(vaangunargalProvider)` after any CRUD to refresh.
final vaangunargalProvider = FutureProvider<List<VaangunarEntry>>((ref) {
  final kalanjiyam = ref.watch(vaangunarKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.getAllVaangunargal(seyaliVagai);
});

// ── Editing State ───────────────────────────────────────────────────────────

/// Holds the merchant currently being edited (null = creating new).
final editingVaangunarProvider = StateProvider<VaangunarEntry?>((ref) => null);

// ── Selection Mode ──────────────────────────────────────────────────────────

/// Whether the merchant list is in selection mode.
final vaangunarSelectionModeProvider = StateProvider<bool>((ref) => false);

/// Set of currently selected merchant IDs.
final selectedVaangunarIdsProvider = StateProvider<Set<int>>((ref) => {});

// ── Recycle Bin (Meetpagam) ──────────────────────────────────────────────────

/// Fetches all soft-deleted merchants once for the current app mode.
/// Call `ref.invalidate(deletedVaangunargalProvider)` after restore/purge.
final deletedVaangunargalProvider =
    FutureProvider<List<VaangunarEntry>>((ref) {
  final kalanjiyam = ref.watch(vaangunarKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchDeletedVaangunargal(seyaliVagai).first;
});
