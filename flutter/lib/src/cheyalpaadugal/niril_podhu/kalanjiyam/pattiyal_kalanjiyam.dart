import 'package:drift/drift.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';

/// Repository for Pattiyal (Invoice/Bill) CRUD operations.
/// Mode-aware: all queries filter by `seyaliVagai` to keep
/// Coolie and Silk invoices completely isolated.
class PattiyalKalanjiyam {
  final AppDatabase _db;

  PattiyalKalanjiyam(this._db);

  // ── Read ──────────────────────────────────────────────────────────────

  /// Watch all non-deleted invoices for the given mode, newest first.
  Stream<List<PatrucheettuEntry>> watchPattiyalgal(String seyaliVagai) {
    return (_db.select(_db.patrucheettuTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.pattiyalNaal),
            (t) => OrderingTerm.desc(t.vanakkam),
          ]))
        .watch();
  }

  /// Get a single invoice by ID.
  Future<PatrucheettuEntry?> getById(int id) {
    return (_db.select(_db.patrucheettuTable)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // ── Write ─────────────────────────────────────────────────────────────

  /// Insert a new invoice. Returns the auto-generated ID.
  Future<int> createPattiyal(PatrucheettuTableCompanion entry) {
    return _db.into(_db.patrucheettuTable).insert(entry);
  }

  /// Update an existing invoice by ID.
  Future<void> updatePattiyal(int id, PatrucheettuTableCompanion entry) async {
    await (_db.update(_db.patrucheettuTable)
          ..where((t) => t.id.equals(id)))
        .write(entry);
  }

  // ── Delete ────────────────────────────────────────────────────────────

  /// Soft-delete an invoice.
  Future<void> deletePattiyal(int id) async {
    await (_db.update(_db.patrucheettuTable)
          ..where((t) => t.id.equals(id)))
        .write(
      PatrucheettuTableCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Bulk soft-delete multiple invoices.
  Future<void> bulkDeletePattiyalgal(List<int> ids) async {
    await (_db.update(_db.patrucheettuTable)
          ..where((t) => t.id.isIn(ids)))
        .write(
      PatrucheettuTableCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Restore a soft-deleted invoice.
  Future<void> restorePattiyal(int id) async {
    await (_db.update(_db.patrucheettuTable)
          ..where((t) => t.id.equals(id)))
        .write(
      const PatrucheettuTableCompanion(
        isDeleted: Value(false),
        deletedAt: Value(null),
      ),
    );
  }

  /// Permanently delete ALL invoices (hard wipe for erase data).
  Future<void> deleteAllPattiyalgal() async {
    await _db.delete(_db.patrucheettuTable).go();
  }

  /// Watch all soft-deleted invoices (recycle bin).
  Stream<List<PatrucheettuEntry>> watchDeletedPattiyalgal(
      String seyaliVagai) {
    return (_db.select(_db.patrucheettuTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([
            (t) => OrderingTerm.desc(t.deletedAt),
          ]))
        .watch();
  }

  // ── Auto-Numbering ────────────────────────────────────────────────────

  /// Get the next sequential number for an invoice within
  /// a given mode + company + financial year.
  /// Uses SQL MAX() — O(1), not full table scan.
  Future<int> getNextVanakkam(
    String seyaliVagai,
    int? niruvanamId,
    int finYear,
  ) async {
    final query = _db.selectOnly(_db.patrucheettuTable)
      ..addColumns([_db.patrucheettuTable.vanakkam.max()])
      ..where(_db.patrucheettuTable.seyaliVagai.equals(seyaliVagai))
      ..where(_db.patrucheettuTable.finYear.equals(finYear));

    if (niruvanamId != null) {
      query.where(
          _db.patrucheettuTable.niruvanamId.equals(niruvanamId));
    } else {
      query.where(_db.patrucheettuTable.niruvanamId.isNull());
    }

    final result = await query.getSingle();
    final maxVal =
        result.read(_db.patrucheettuTable.vanakkam.max());
    return (maxVal ?? 0) + 1;
  }

  /// Format a human-readable invoice number.
  /// Example: `VRM-01`, `VRM-09`, `VRM-10`, `VRM-100`
  /// Single digits are zero-padded (01-09); 10+ are natural.
  String formatPattiyalEn(String prefix, int vanakkam) {
    final padded = vanakkam < 10
        ? vanakkam.toString().padLeft(2, '0')
        : vanakkam.toString();
    return '$prefix-$padded';
  }

  /// Get the current Indian financial year (April = start).
  /// In January-March 2027, this returns 2026.
  /// In April-December 2026, this returns 2026.
  static int getCurrentFinYear() {
    final now = DateTime.now();
    return now.month >= 4 ? now.year : now.year - 1;
  }

  // ── Auto-Purge ─────────────────────────────────────────────────────────

  /// Hard-delete all soft-deleted invoices older than [days] (default 30).
  Future<int> purgeExpiredPattiyalgal({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.delete(_db.patrucheettuTable)
          ..where((t) => t.isDeleted.equals(true))
          ..where((t) => t.deletedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }
}
