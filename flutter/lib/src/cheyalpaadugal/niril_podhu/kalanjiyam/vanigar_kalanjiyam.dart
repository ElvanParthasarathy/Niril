import 'package:drift/drift.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';

/// Repository for Vanigar (Merchant/Customer) CRUD operations.
/// Mode-aware: all queries filter by `seyaliVagai` to keep
/// Coolie and Silk merchants completely isolated.
class VanigarKalanjiyam {
  final AppDatabase _db;

  VanigarKalanjiyam(this._db);

  // ── Read ──────────────────────────────────────────────────────────────

  /// Watch all non-deleted merchants for the given mode.
  Stream<List<VanigarEntry>> watchAllVanigargal(String seyaliVagai) {
    return (_db.select(_db.vanigarTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  /// Get a single merchant by ID.
  Future<VanigarEntry?> getVanigarById(int id) {
    return (_db.select(_db.vanigarTable)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // ── Write ─────────────────────────────────────────────────────────────

  /// Insert or update a merchant.
  /// If [id] is provided, updates the existing row.
  /// Returns the saved entry's ID.
  Future<int> saveVanigar({
    int? id,
    required String seyaliVagai,
    required Map<String, String> peyar,
    Map<String, String> mugavari = const {},
    Map<String, String> oor = const {},
    Map<String, String> maavattam = const {},
    Map<String, String> maanilam = const {},
    Map<String, String> naadu = const {},
    Map<String, String> velinaadMugavari = const {},
    String anjalKuriyeedu = '',
    String gstin = '',
    String minnanjal = '',
    String tholaipaesi = '',
  }) async {
    if (id != null) {
      // Update existing
      await (_db.update(_db.vanigarTable)..where((t) => t.id.equals(id)))
          .write(
        VanigarTableCompanion(
          peyar: Value(peyar),
          mugavari: Value(mugavari),
          oor: Value(oor),
          maavattam: Value(maavattam),
          maanilam: Value(maanilam),
          naadu: Value(naadu),
          velinaadMugavari: Value(velinaadMugavari),
          anjalKuriyeedu: Value(anjalKuriyeedu),
          gstin: Value(gstin),
          minnanjal: Value(minnanjal),
          tholaipaesi: Value(tholaipaesi),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return id;
    } else {
      // Insert new
      return _db.into(_db.vanigarTable).insert(
        VanigarTableCompanion.insert(
          seyaliVagai: seyaliVagai,
          peyar: Value(peyar),
          mugavari: Value(mugavari),
          oor: Value(oor),
          maavattam: Value(maavattam),
          maanilam: Value(maanilam),
          naadu: Value(naadu),
          velinaadMugavari: Value(velinaadMugavari),
          anjalKuriyeedu: Value(anjalKuriyeedu),
          gstin: Value(gstin),
          minnanjal: Value(minnanjal),
          tholaipaesi: Value(tholaipaesi),
        ),
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────

  /// Soft-delete a single merchant.
  Future<void> deleteVanigar(int id) async {
    await (_db.update(_db.vanigarTable)..where((t) => t.id.equals(id))).write(
      VanigarTableCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Bulk soft-delete multiple merchants.
  Future<void> bulkDeleteVanigargal(List<int> ids) async {
    await (_db.update(_db.vanigarTable)..where((t) => t.id.isIn(ids))).write(
      VanigarTableCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Restore a soft-deleted merchant.
  Future<void> restoreVanigar(int id) async {
    await (_db.update(_db.vanigarTable)..where((t) => t.id.equals(id))).write(
      const VanigarTableCompanion(
        isDeleted: Value(false),
        deletedAt: Value(null),
      ),
    );
  }

  /// Bulk restore soft-deleted merchants.
  Future<void> bulkRestoreVanigargal(List<int> ids) async {
    await (_db.update(_db.vanigarTable)..where((t) => t.id.isIn(ids))).write(
      const VanigarTableCompanion(
        isDeleted: Value(false),
        deletedAt: Value(null),
      ),
    );
  }

  /// Permanently delete a merchant (hard delete).
  Future<void> permanentDeleteVanigar(int id) async {
    await (_db.delete(_db.vanigarTable)..where((t) => t.id.equals(id))).go();
  }

  /// Watch all soft-deleted merchants for the given mode (recycle bin).
  Stream<List<VanigarEntry>> watchDeletedVanigargal(String seyaliVagai) {
    return (_db.select(_db.vanigarTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([
            (t) => OrderingTerm.desc(t.deletedAt),
          ]))
        .watch();
  }

  // ── Auto-Purge ─────────────────────────────────────────────────────────

  /// Hard-delete all soft-deleted merchants older than [days] (default 30).
  /// Returns the number of rows permanently removed.
  Future<int> purgeExpiredVanigargal({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.delete(_db.vanigarTable)
          ..where((t) => t.isDeleted.equals(true))
          ..where((t) => t.deletedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }

  /// Permanently delete ALL merchants (hard wipe for erase data).
  Future<void> deleteAllVanigargal() async {
    await _db.delete(_db.vanigarTable).go();
  }
}
