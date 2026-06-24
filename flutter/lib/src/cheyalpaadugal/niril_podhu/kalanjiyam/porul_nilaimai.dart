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

// ── Mode-Aware Product Stream ───────────────────────────────────────────────

/// Watches all products for the current app mode.
/// Coolie products and Silk products are completely isolated.
final porulgalStreamProvider = StreamProvider<List<PorulEntry>>((ref) {
  final kalanjiyam = ref.watch(porulKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchAllPorulgal(seyaliVagai);
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

/// Watches all soft-deleted products for the current app mode.
final deletedPorulgalStreamProvider = StreamProvider<List<PorulEntry>>((ref) {
  final kalanjiyam = ref.watch(porulKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchDeletedPorulgal(seyaliVagai);
});
