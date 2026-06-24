import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';

/// வழக்கு வரை — FK Resolution Helpers
///
/// Industry-standard pattern: FK-first, snapshot-fallback.
/// Used to resolve live names from foreign key references in invoices,
/// with graceful fallback to stored snapshot strings for deleted records.

/// Resolves customer FK → live merchant name, or snapshot if deleted/missing.
///
/// [vanigarId] — FK to VanigarTable (nullable)
/// [snapshot] — stored vanigarPeyar string from invoice
/// [vanigargal] — current list of all merchants
String resolveVanigarPeyar({
  required int? vanigarId,
  required String snapshot,
  required List<VanigarEntry> vanigargal,
}) {
  if (vanigarId == null) return snapshot;
  final match = vanigargal
      .where((v) => v.id == vanigarId && !v.isDeleted)
      .firstOrNull;
  if (match == null) return snapshot;
  // peyar is Map<String, String> from Drift — no JSON decode needed
  final name = match.peyar['Tamil'] ?? match.peyar['English'] ?? '';
  return name.isNotEmpty ? name : snapshot;
}

/// Resolves product FK → live product name, or snapshot if deleted/missing.
///
/// [porulId] — FK to PorulTable (stored as String? in line item JSON)
/// [snapshot] — stored porulPeyar string from line item
/// [porulgal] — current list of all products
String resolvePorulPeyar({
  required String? porulId,
  required String snapshot,
  required List<PorulEntry> porulgal,
}) {
  if (porulId == null || porulId.isEmpty) return snapshot;
  final id = int.tryParse(porulId);
  if (id == null) return snapshot;
  final match = porulgal
      .where((p) => p.id == id && !p.isDeleted)
      .firstOrNull;
  if (match == null) return snapshot;
  // porulPeyar is Map<String, String> from Drift — no JSON decode needed
  final name = match.porulPeyar['Tamil'] ?? match.porulPeyar['English'] ?? '';
  return name.isNotEmpty ? name : snapshot;
}
