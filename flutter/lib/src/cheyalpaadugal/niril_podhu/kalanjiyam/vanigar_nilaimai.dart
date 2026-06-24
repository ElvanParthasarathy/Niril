import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'vanigar_kalanjiyam.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final vanigarKalanjiyamProvider = Provider<VanigarKalanjiyam>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VanigarKalanjiyam(db);
});

// ── Mode-Aware Merchant List (one-shot, pull-to-refresh) ────────────────────

/// Fetches all merchants once for the current app mode.
/// Call `ref.invalidate(vanigargalProvider)` after any CRUD to refresh.
final vanigargalProvider = FutureProvider<List<VanigarEntry>>((ref) {
  final kalanjiyam = ref.watch(vanigarKalanjiyamProvider);

  // Defer mode-change invalidation to avoid setState-during-build
  ref.listen(appModeProvider, (_, __) {
    Future.microtask(() => ref.invalidateSelf());
  });
  final mode = ref.read(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.getAllVanigargal(seyaliVagai);
});

// ── Editing State ───────────────────────────────────────────────────────────

/// Holds the merchant currently being edited (null = creating new).
final editingVanigarProvider = StateProvider<VanigarEntry?>((ref) => null);

// ── Selection Mode ──────────────────────────────────────────────────────────

/// Whether the merchant list is in selection mode.
final vanigarSelectionModeProvider = StateProvider<bool>((ref) => false);

/// Set of currently selected merchant IDs.
final selectedVanigarIdsProvider = StateProvider<Set<int>>((ref) => {});

// ── Recycle Bin (Meetpagam) ──────────────────────────────────────────────────

/// Fetches all soft-deleted merchants once for the current app mode.
/// Call `ref.invalidate(deletedVanigargalProvider)` after restore/purge.
final deletedVanigargalProvider =
    FutureProvider<List<VanigarEntry>>((ref) {
  final kalanjiyam = ref.watch(vanigarKalanjiyamProvider);

  ref.listen(appModeProvider, (_, __) {
    Future.microtask(() => ref.invalidateSelf());
  });
  final mode = ref.read(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchDeletedVanigargal(seyaliVagai).first;
});
