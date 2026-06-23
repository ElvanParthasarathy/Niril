import 'package:drift/drift.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';

/// Repository for Porul (Product) CRUD operations.
/// Mode-aware: all queries filter by `seyaliVagai` to keep
/// Coolie and Silk products completely isolated.
class PorulKalanjiyam {
  final AppDatabase _db;

  PorulKalanjiyam(this._db);

  // ── Read ──────────────────────────────────────────────────────────────

  /// Watch all non-deleted products for the given mode.
  Stream<List<PorulEntry>> watchAllPorulgal(String seyaliVagai) {
    return (_db.select(_db.porulTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  /// Get a single product by ID.
  Future<PorulEntry?> getPorulById(int id) {
    return (_db.select(_db.porulTable)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // ── Write ─────────────────────────────────────────────────────────────

  /// Insert or update a product.
  /// If [id] is provided, updates the existing row.
  /// Returns the saved entry's ID.
  Future<int> savePorul({
    int? id,
    required String seyaliVagai,
    required Map<String, String> porulPeyar,
    String hsnCode = '',
    double vilai = 0.0,
    double variVeetham = 0.0,
    String alavuVagai = 'quantity',
    String alagu = 'Nos',
  }) async {
    if (id != null) {
      // Update existing
      await (_db.update(_db.porulTable)..where((t) => t.id.equals(id))).write(
        PorulTableCompanion(
          porulPeyar: Value(porulPeyar),
          hsnCode: Value(hsnCode),
          vilai: Value(vilai),
          variVeetham: Value(variVeetham),
          alavuVagai: Value(alavuVagai),
          alagu: Value(alagu),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return id;
    } else {
      // Insert new
      return _db.into(_db.porulTable).insert(
        PorulTableCompanion.insert(
          seyaliVagai: seyaliVagai,
          porulPeyar: Value(porulPeyar),
          hsnCode: Value(hsnCode),
          vilai: Value(vilai),
          variVeetham: Value(variVeetham),
          alavuVagai: Value(alavuVagai),
          alagu: Value(alagu),
        ),
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────

  /// Soft-delete a single product.
  Future<void> deletePorul(int id) async {
    await (_db.update(_db.porulTable)..where((t) => t.id.equals(id))).write(
      PorulTableCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Bulk soft-delete multiple products.
  Future<void> bulkDeletePorulgal(List<int> ids) async {
    await (_db.update(_db.porulTable)..where((t) => t.id.isIn(ids))).write(
      PorulTableCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Restore a soft-deleted product.
  Future<void> restorePorul(int id) async {
    await (_db.update(_db.porulTable)..where((t) => t.id.equals(id))).write(
      const PorulTableCompanion(
        isDeleted: Value(false),
        deletedAt: Value(null),
      ),
    );
  }

  /// Bulk restore soft-deleted products.
  Future<void> bulkRestorePorulgal(List<int> ids) async {
    await (_db.update(_db.porulTable)..where((t) => t.id.isIn(ids))).write(
      const PorulTableCompanion(
        isDeleted: Value(false),
        deletedAt: Value(null),
      ),
    );
  }

  /// Permanently delete a product (hard delete).
  Future<void> permanentDeletePorul(int id) async {
    await (_db.delete(_db.porulTable)..where((t) => t.id.equals(id))).go();
  }

  /// Watch all soft-deleted products for the given mode (recycle bin).
  Stream<List<PorulEntry>> watchDeletedPorulgal(String seyaliVagai) {
    return (_db.select(_db.porulTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([
            (t) => OrderingTerm.desc(t.deletedAt),
          ]))
        .watch();
  }

  // ── Auto-Purge ─────────────────────────────────────────────────────────

  /// Hard-delete all soft-deleted products older than [days] (default 30).
  /// Returns the number of rows permanently removed.
  Future<int> purgeExpiredPorulgal({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.delete(_db.porulTable)
          ..where((t) => t.isDeleted.equals(true))
          ..where((t) => t.deletedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }
}
