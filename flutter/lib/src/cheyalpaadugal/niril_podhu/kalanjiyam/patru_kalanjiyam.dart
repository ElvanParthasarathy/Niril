import 'package:drift/drift.dart';
import '../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';

/// Data class for receipt ↔ invoice junction rows (used in insert/update).
class PatruPattiyalLink {
  final int pattiyalId;
  final double poruthiyaThogai;

  const PatruPattiyalLink({
    required this.pattiyalId,
    required this.poruthiyaThogai,
  });
}

/// Repository for Receipt (Patru) CRUD operations.
/// All mutations run inside transactions for atomicity.
/// Receipt + junction rows are always inserted/updated/deleted together.
class PatruKalanjiyam {
  final AppDatabase _db;

  PatruKalanjiyam(this._db);

  // ── Read ──────────────────────────────────────────────────────────────

  /// Watch all non-deleted receipts for the given mode, newest first.
  Stream<List<PatrugalEntry>> watchPatrugal(String seyaliVagai) {
    return (_db.select(_db.patrugalTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.patruNaal),
            (t) => OrderingTerm.desc(t.vanakkam),
          ]))
        .watch();
  }

  /// Get all non-deleted receipts for the given mode (one-shot).
  Future<List<PatrugalEntry>> getPatrugal(String seyaliVagai) {
    return (_db.select(_db.patrugalTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.patruNaal),
            (t) => OrderingTerm.desc(t.vanakkam),
          ]))
        .get();
  }

  /// Get a single receipt by ID.
  Future<PatrugalEntry?> getById(int id) {
    return (_db.select(_db.patrugalTable)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Get all junction rows for a receipt.
  Future<List<PatruPattiyalEntry>> getLinksForPatru(int patruId) {
    return (_db.select(_db.patruPattiyalTable)
          ..where((t) => t.patruId.equals(patruId)))
        .get();
  }

  // ── Write (Transactional) ─────────────────────────────────────────────

  /// Insert a new receipt with its invoice links. Returns the auto-generated ID.
  /// Runs inside a transaction — if any step fails, everything rolls back.
  Future<int> insertPatru(
    PatrugalTableCompanion data,
    List<PatruPattiyalLink> links,
  ) {
    return _db.transaction(() async {
      final patruId = await _db.into(_db.patrugalTable).insert(data);

      // Insert junction rows
      for (final link in links) {
        await _db.into(_db.patruPattiyalTable).insert(
              PatruPattiyalTableCompanion.insert(
                patruId: patruId,
                pattiyalId: link.pattiyalId,
                poruthiyaThogai: Value(link.poruthiyaThogai),
              ),
            );
      }

      return patruId;
    });
  }

  /// Update an existing receipt and replace its invoice links.
  /// Deletes old links and inserts new ones (full replacement).
  Future<void> updatePatru(
    int id,
    PatrugalTableCompanion data,
    List<PatruPattiyalLink> links,
  ) {
    return _db.transaction(() async {
      // Update receipt row
      await (_db.update(_db.patrugalTable)..where((t) => t.id.equals(id)))
          .write(data);

      // Delete old junction rows
      await (_db.delete(_db.patruPattiyalTable)
            ..where((t) => t.patruId.equals(id)))
          .go();

      // Insert new junction rows
      for (final link in links) {
        await _db.into(_db.patruPattiyalTable).insert(
              PatruPattiyalTableCompanion.insert(
                patruId: id,
                pattiyalId: link.pattiyalId,
                poruthiyaThogai: Value(link.poruthiyaThogai),
              ),
            );
      }
    });
  }

  // ── Delete ────────────────────────────────────────────────────────────

  /// Soft-delete a receipt and remove its junction rows.
  Future<void> deletePatru(int id) {
    return _db.transaction(() async {
      // Soft-delete the receipt
      await (_db.update(_db.patrugalTable)..where((t) => t.id.equals(id)))
          .write(PatrugalTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));

      // Remove junction rows (so invoice balance recalculates)
      await (_db.delete(_db.patruPattiyalTable)
            ..where((t) => t.patruId.equals(id)))
          .go();
    });
  }

  /// Bulk soft-delete multiple receipts.
  Future<void> bulkDeletePatrugal(List<int> ids) {
    return _db.transaction(() async {
      await (_db.update(_db.patrugalTable)..where((t) => t.id.isIn(ids)))
          .write(const PatrugalTableCompanion(
        isDeleted: Value(true),
        // deletedAt: Value.ofNonNull(null), // TODO: Use actual timestamp if needed
      ));

      // Remove all junction rows for deleted receipts
      await (_db.delete(_db.patruPattiyalTable)
            ..where((t) => t.patruId.isIn(ids)))
          .go();
    });
  }

  /// Hard delete all receipts (for dev seeding)
  Future<void> deleteAllPatrugal() {
    return _db.transaction(() async {
      await _db.delete(_db.patruPattiyalTable).go();
      await _db.delete(_db.patrugalTable).go();
    });
  }

  // ── Invoice Payment Tracking ──────────────────────────────────────────

  /// Watch total paid amount for a specific invoice.
  /// This is the SUM of all `poruthiyaThogai` linked to this invoice.
  Stream<double> watchPaidAmount(int pattiyalId) {
    final query = _db.selectOnly(_db.patruPattiyalTable)
      ..addColumns([_db.patruPattiyalTable.poruthiyaThogai.sum()])
      ..where(_db.patruPattiyalTable.pattiyalId.equals(pattiyalId));

    return query.watchSingle().map((row) {
      return row.read(_db.patruPattiyalTable.poruthiyaThogai.sum()) ?? 0.0;
    });
  }

  /// Get total paid amount for an invoice (one-shot).
  Future<double> getPaidAmount(int pattiyalId) async {
    final query = _db.selectOnly(_db.patruPattiyalTable)
      ..addColumns([_db.patruPattiyalTable.poruthiyaThogai.sum()])
      ..where(_db.patruPattiyalTable.pattiyalId.equals(pattiyalId));

    final row = await query.getSingle();
    return row.read(_db.patruPattiyalTable.poruthiyaThogai.sum()) ?? 0.0;
  }

  /// Watch all unpaid/partially-paid invoices for a given mode.
  /// An invoice is "unpaid" if SUM(poruthiyaThogai) < mothaThogai.
  Stream<List<PatrucheettuEntry>> watchUnpaidInvoices(String seyaliVagai) {
    // We use a raw-ish approach: watch all invoices, then filter client-side
    // using the paid amounts. This is simpler and more maintainable than
    // a complex JOIN query in Drift.
    return (_db.select(_db.patrucheettuTable)
          ..where((t) => t.seyaliVagai.equals(seyaliVagai))
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.pattiyalNaal),
          ]))
        .watch();
    // Note: The editor will further filter these by comparing with paid amounts.
  }

  /// Get pending balance for an invoice (mothaThogai - paid).
  Future<double> getPendingBalance(int pattiyalId) async {
    final invoice = await (_db.select(_db.patrucheettuTable)
          ..where((t) => t.id.equals(pattiyalId)))
        .getSingleOrNull();
    if (invoice == null) return 0.0;

    final paid = await getPaidAmount(pattiyalId);
    return (invoice.mothaThogai - paid).clamp(0.0, double.infinity);
  }

  /// Get a map of pattiyalId → paid amount for a batch of invoices.
  /// Used in the invoice list to show payment status badges efficiently.
  Future<Map<int, double>> getPaidAmountsForInvoices(
      List<int> pattiyalIds) async {
    if (pattiyalIds.isEmpty) return {};

    final query = _db.selectOnly(_db.patruPattiyalTable)
      ..addColumns([
        _db.patruPattiyalTable.pattiyalId,
        _db.patruPattiyalTable.poruthiyaThogai.sum(),
      ])
      ..where(_db.patruPattiyalTable.pattiyalId.isIn(pattiyalIds))
      ..groupBy([_db.patruPattiyalTable.pattiyalId]);

    final rows = await query.get();
    final result = <int, double>{};
    for (final row in rows) {
      final id = row.read(_db.patruPattiyalTable.pattiyalId)!;
      final sum =
          row.read(_db.patruPattiyalTable.poruthiyaThogai.sum()) ?? 0.0;
      result[id] = sum;
    }
    return result;
  }

  // ── Auto-Numbering ────────────────────────────────────────────────────

  /// Get the next sequential number for a receipt within a given scope.
  /// Uses SQL MAX() — O(1), not full table scan.
  Future<int> getNextVanakkam(String seyaliVagai, int? niruvanamId) async {
    final query = _db.selectOnly(_db.patrugalTable)
      ..addColumns([_db.patrugalTable.vanakkam.max()])
      ..where(_db.patrugalTable.seyaliVagai.equals(seyaliVagai));

    if (niruvanamId != null) {
      query.where(_db.patrugalTable.niruvanamId.equals(niruvanamId));
    } else {
      query.where(_db.patrugalTable.niruvanamId.isNull());
    }

    final result = await query.getSingle();
    final maxVal = result.read(_db.patrugalTable.vanakkam.max());
    return (maxVal ?? 0) + 1;
  }

  /// Format a receipt number.
  /// Example: `RCP/SJS/01`, `RCP/SJS/10`, `RCP/SJS/100`
  String formatPatruEn(String bizShort, int vanakkam) {
    final padded = vanakkam < 10
        ? vanakkam.toString().padLeft(2, '0')
        : vanakkam.toString();
    return 'RCP/$bizShort/$padded';
  }

  // ── Validation ────────────────────────────────────────────────────────

  /// Checks if a receipt number already exists for the given mode and company.
  /// Check is case-insensitive.
  Future<bool> isPatruEnDuplicate(
    String seyaliVagai,
    int? niruvanamId,
    String patruEn, {
    int? excludeId,
  }) async {
    final query = _db.select(_db.patrugalTable)
      ..where((t) => t.seyaliVagai.equals(seyaliVagai))
      ..where((t) => t.patruEn.upper().equals(patruEn.toUpperCase()));

    if (niruvanamId != null) {
      query.where((t) => t.niruvanamId.equals(niruvanamId));
    } else {
      query.where((t) => t.niruvanamId.isNull());
    }

    if (excludeId != null) {
      query.where((t) => t.id.isNotValue(excludeId));
    }

    final existing = await query.get();
    return existing.isNotEmpty;
  }

  /// Validate that the receipt amount doesn't exceed invoice balances.
  /// Returns null if valid, or an error message string if invalid.
  Future<String?> validateLinks(
    List<PatruPattiyalLink> links, {
    int? excludePatruId, // Exclude this receipt when editing
  }) async {
    for (final link in links) {
      final invoice = await (_db.select(_db.patrucheettuTable)
            ..where((t) => t.id.equals(link.pattiyalId)))
          .getSingleOrNull();
      if (invoice == null) {
        return 'Invoice #${link.pattiyalId} not found';
      }

      // Get total already paid (excluding the receipt being edited)
      double alreadyPaid = await getPaidAmount(link.pattiyalId);
      if (excludePatruId != null) {
        final existingLinks = await getLinksForPatru(excludePatruId);
        for (final existing in existingLinks) {
          if (existing.pattiyalId == link.pattiyalId) {
            alreadyPaid -= existing.poruthiyaThogai;
          }
        }
      }

      final remaining = invoice.mothaThogai - alreadyPaid;
      if (link.poruthiyaThogai > remaining + 0.01) {
        // 0.01 tolerance for floating point
        return 'Amount ₹${link.poruthiyaThogai.toStringAsFixed(2)} exceeds '
            'remaining balance ₹${remaining.toStringAsFixed(2)} for '
            '${invoice.patrucheettuEn}';
      }
    }
    return null; // All valid
  }
}
