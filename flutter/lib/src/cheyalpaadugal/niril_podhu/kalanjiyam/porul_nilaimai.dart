import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import 'porul_kalanjiyam.dart';

// ── Repository Provider ─────────────────────────────────────────────────────

final porulKalanjiyamProvider = Provider<PorulKalanjiyam>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PorulKalanjiyam(db);
});

// ── Mode-Aware Product List (one-shot, pull-to-refresh) ─────────────────────

/// Fetches all products once for the current app mode.
/// Call `ref.invalidate(porulgalProvider)` after any CRUD to refresh.
final porulgalProvider = FutureProvider<List<PorulEntry>>((ref) {
  final kalanjiyam = ref.watch(porulKalanjiyamProvider);

  // Defer mode-change invalidation to avoid setState-during-build
  ref.listen(appModeProvider, (_, __) {
    Future.microtask(() => ref.invalidateSelf());
  });
  final mode = ref.read(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.getAllPorulgal(seyaliVagai);
});

// ── Editing State ───────────────────────────────────────────────────────────

/// Holds the product currently being edited (null = creating new).
final editingPorulProvider = StateProvider<PorulEntry?>((ref) => null);

// ── Selection Mode ──────────────────────────────────────────────────────────

/// Whether the product list is in selection mode.
final porulSelectionModeProvider = StateProvider<bool>((ref) => false);

/// Set of currently selected product IDs.
final selectedPorulIdsProvider = StateProvider<Set<int>>((ref) => {});

// ── Recycle Bin (Meetpagam) ──────────────────────────────────────────────────

/// Fetches all soft-deleted products once for the current app mode.
/// Call `ref.invalidate(deletedPorulgalProvider)` after restore/purge.
final deletedPorulgalProvider = FutureProvider<List<PorulEntry>>((ref) {
  final kalanjiyam = ref.watch(porulKalanjiyamProvider);

  ref.listen(appModeProvider, (_, __) {
    Future.microtask(() => ref.invalidateSelf());
  });
  final mode = ref.read(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchDeletedPorulgal(seyaliVagai).first;
});
