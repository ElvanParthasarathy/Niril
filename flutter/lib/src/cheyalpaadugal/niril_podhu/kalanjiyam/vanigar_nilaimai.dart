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

// ── Mode-Aware Merchant Stream ──────────────────────────────────────────────

/// Watches all merchants for the current app mode.
/// Coolie merchants and Silk merchants are completely isolated.
final vanigargalStreamProvider = StreamProvider<List<VanigarEntry>>((ref) {
  final kalanjiyam = ref.watch(vanigarKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchAllVanigargal(seyaliVagai);
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

/// Watches all soft-deleted merchants for the current app mode.
final deletedVanigargalStreamProvider =
    StreamProvider<List<VanigarEntry>>((ref) {
  final kalanjiyam = ref.watch(vanigarKalanjiyamProvider);
  final mode = ref.watch(appModeProvider);

  final seyaliVagai = mode == AppMode.coolie ? 'coolie' : 'silk';
  return kalanjiyam.watchDeletedVanigargal(seyaliVagai);
});
