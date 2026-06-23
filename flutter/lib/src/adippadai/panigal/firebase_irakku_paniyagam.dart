import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../tharavuthalam/seyali_tharavuthalam.dart';
import '../../cheyalpaadugal/niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../cheyalpaadugal/niril_podhu/kalanjiyam/pattiyal_kalanjiyam.dart';

/// Firebase RTDB export → local Drift DB import service.
///
/// Reads the exported JSON file and inserts invoices, mapping
/// Firebase UUIDs to local integer FKs by matching `kurumPeyar`.
class FirebaseIrakkuPaniyagam {
  final AppDatabase _db;
  final PattiyalKalanjiyam _kalanjiyam;

  FirebaseIrakkuPaniyagam(this._db, this._kalanjiyam);

  /// Import all data from a Firebase RTDB export JSON file.
  /// Returns a summary map with counts of imported records.
  Future<Map<String, int>> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Build profile lookup: Firebase UUID → local DB ID (by kurumPeyar)
    final profileLookup = await _buildProfileLookup();

    // Build customer lookup: customer name (Tamil) → local VanigarTable ID
    final customerLookup = await _buildCustomerLookup();

    int coolieCount = 0;
    int silkCount = 0;

    // ── Import Coolie Invoices ──
    final cooliePattiyalkal =
        data['coolie_pattiyalkal'] as Map<String, dynamic>?;
    if (cooliePattiyalkal != null) {
      for (final entry in cooliePattiyalkal.entries) {
        final inv = entry.value as Map<String, dynamic>;
        await _importCoolieInvoice(inv, profileLookup, customerLookup);
        coolieCount++;
      }
    }

    // ── Import Silk Invoices ──
    final pattiyalkal = data['pattiyalkal'] as Map<String, dynamic>?;
    if (pattiyalkal != null) {
      for (final entry in pattiyalkal.entries) {
        final inv = entry.value as Map<String, dynamic>;
        await _importSilkInvoice(
            inv, entry.key, profileLookup, customerLookup);
        silkCount++;
      }
    }

    return {
      'coolie': coolieCount,
      'silk': silkCount,
    };
  }

  // ── Profile Lookup Builder ──

  /// Maps Firebase company UUID → local DB id by matching `kurumPeyar`
  /// extracted from the `bill_no` prefix.
  /// Also builds a direct kurumPeyar → id map.
  Future<Map<String, int>> _buildProfileLookup() async {
    final entries = await _db.select(_db.vanigaTharavugalTable).get();
    final lookup = <String, int>{};
    for (final e in entries) {
      if (e.kurumPeyar.isNotEmpty) {
        lookup[e.kurumPeyar.toUpperCase()] = e.id;
      }
    }
    return lookup;
  }

  /// Maps customer Tamil name → local VanigarTable ID.
  Future<Map<String, int>> _buildCustomerLookup() async {
    final entries = await _db.select(_db.vanigarTable).get();
    final lookup = <String, int>{};
    for (final e in entries) {
      // peyar is Map<String, String> via MozhiMapConverter
      final tamilName = e.peyar['Tamil'] ?? '';
      if (tamilName.isNotEmpty) {
        lookup[tamilName] = e.id;
      }
      final englishName = e.peyar['English'] ?? '';
      if (englishName.isNotEmpty) {
        lookup[englishName] = e.id;
      }
    }
    return lookup;
  }

  // ── Coolie Invoice Import ──

  Future<void> _importCoolieInvoice(
    Map<String, dynamic> inv,
    Map<String, int> profileLookup,
    Map<String, int> customerLookup,
  ) async {
    final billNo = inv['bill_no'] as String? ?? '';
    final vanakkam = _extractNumber(billNo);
    final prefix = _extractPrefix(billNo);

    // Resolve niruvanamId from prefix
    final niruvanamId = profileLookup[prefix.toUpperCase()];

    // Resolve customer
    final customerName = inv['customer_name'] as String? ?? '';
    final customerNameEn = inv['customer_name_en'] as String? ?? '';
    final vanigarId = customerLookup[customerName] ??
        customerLookup[customerNameEn];

    // Parse date (DD/MM/YYYY)
    final dateStr = inv['date'] as String? ?? '';
    final pattiyalNaal = _parseDdMmYyyy(dateStr);

    // Parse items
    final rawItems = inv['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final m = item as Map<String, dynamic>;
      return KooliUrupadi(
        porulPeyar: m['name_tamil'] as String? ?? m['porul'] as String? ?? '',
        edai: double.tryParse('${m['kg'] ?? 0}') ?? 0,
        vilai: double.tryParse('${m['coolie'] ?? 0}') ?? 0,
      );
    }).toList();

    // Parse charges
    final setharamGrams =
        double.tryParse('${inv['setharam_grams'] ?? 0}') ?? 0;
    final courierRs =
        double.tryParse('${inv['courier_rs'] ?? 0}') ?? 0;
    final ahimsaRs =
        double.tryParse('${inv['ahimsa_silk_rs'] ?? 0}') ?? 0;
    final grandTotal =
        (inv['grand_total'] as num?)?.toDouble() ?? 0;

    // Custom charges → PiraVarivu
    final customChargeName =
        inv['custom_charge_name'] as String? ?? '';
    final customChargeRs =
        (inv['custom_charge_rs'] as num?)?.toDouble() ?? 0;
    final piraVarivugal = <PiraVarivu>[];
    if (customChargeName.isNotEmpty && customChargeRs > 0) {
      piraVarivugal.add(PiraVarivu(
          peyar: customChargeName, thogai: customChargeRs));
    }

    // Bank snapshot
    final bankSnapshot = jsonEncode({
      'vangiPeyar': inv['bank_details'] ?? '',
      'kanakkuEn': inv['account_no'] ?? '',
      'ifsc': inv['ifsc'] ?? '',
    });

    // Compute total weight
    final mothaEdai = items.fold<double>(0, (sum, i) => sum + i.edai);

    // Financial year from date
    final finYear = pattiyalNaal.month >= 4
        ? pattiyalNaal.year
        : pattiyalNaal.year - 1;

    // Check for duplicate (same bill number)
    final existing = await (_db.select(_db.patrucheettuTable)
          ..where((t) => t.patrucheettuEn.equals(billNo))
          ..where((t) => t.seyaliVagai.equals('coolie')))
        .get();
    if (existing.isNotEmpty) return; // Skip duplicates

    await _kalanjiyam.createPattiyal(
      PatrucheettuTableCompanion.insert(
        seyaliVagai: 'coolie',
        patrucheettuEn: billNo,
        finYear: finYear,
        vanakkam: Value(vanakkam),
        niruvanamId: Value(niruvanamId),
        vanigarPeyar: customerName,
        vanigarId: Value(vanigarId),
        pattiyalNaal: Value(pattiyalNaal),
        tharavugal: Value(PattiyalUthavigal.kooliListToJson(items)),
        mothaThogai: Value(grandTotal),
        mothaEdai: Value(mothaEdai),
        setharamGrams: Value(setharamGrams),
        thapaalThogai: Value(courierRs),
        ahimsaPattuThogai: Value(ahimsaRs),
        piravariVugal:
            Value(PattiyalUthavigal.piraVarivuListToJson(piraVarivugal)),
        vangiTharavugal: Value(bankSnapshot),
      ),
    );
  }

  // ── Silk Invoice Import ──

  Future<void> _importSilkInvoice(
    Map<String, dynamic> inv,
    String invoiceKey,
    Map<String, int> profileLookup,
    Map<String, int> customerLookup,
  ) async {
    final invoiceNumber =
        inv['invoiceNumber'] as String? ?? invoiceKey;
    final vanakkam = _extractNumber(invoiceNumber);
    final prefix = _extractPrefix(invoiceNumber);

    // Resolve niruvanamId from prefix
    final niruvanamId = profileLookup[prefix.toUpperCase()];

    // Resolve customer
    final clientName = inv['clientName'] as String? ?? '';
    final clientNameEn = inv['clientNameEn'] as String? ?? '';
    final vanigarId =
        customerLookup[clientName] ?? customerLookup[clientNameEn];

    // Parse nested data
    final data = inv['data'] as Map<String, dynamic>? ?? {};
    final details = data['details'] as Map<String, dynamic>? ?? {};
    final dateStr = details['invoiceDate'] as String? ??
        details['date'] as String? ??
        inv['date'] as String? ??
        '';
    final pattiyalNaal = _parseIsoOrDdMm(dateStr);

    final invoiceType =
        details['invoiceType'] as String? ?? 'tax-invoice';

    // Parse items
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final m = item as Map<String, dynamic>;
      return PattuUrupadi(
        porulPeyar: m['name_Tamil'] as String? ?? m['name_English'] as String? ?? '',
        hsnKuriyeedu: m['hsn'] as String? ?? '',
        alavu: double.tryParse('${m['qty'] ?? 1}') ?? 1,
        alagu: m['unit'] as String? ?? 'Nos',
        vilai: (m['rate'] as num?)?.toDouble() ?? 0,
        variVizhukkaadu: (m['taxPercent'] as num?)?.toDouble() ?? 0,
        thallupadi: (m['discount'] as num?)?.toDouble() ?? 0,
        thallupadiVagai: m['discountType'] as String? ?? 'amount',
      );
    }).toList();

    final grandTotal =
        (inv['grandTotal'] as num?)?.toDouble() ?? 0;
    final totalTax =
        (inv['totalTaxAmount'] as num?)?.toDouble() ?? 0;

    // Invoice options → sonthaViruppangal
    final invoiceOptions =
        data['invoiceOptions'] as Map<String, dynamic>? ?? {};
    final settingsJson = jsonEncode({
      ...invoiceOptions,
      'globalDiscountValue': 0,
      'globalDiscountType': 'percentage',
    });

    // Terms / notes
    final customTerms = data['customTerms'] as String? ?? '';
    final internalNote = data['internalNote'] as String? ?? '';

    // Financial year
    final finYear = pattiyalNaal.month >= 4
        ? pattiyalNaal.year
        : pattiyalNaal.year - 1;

    // Check for duplicate
    final existing = await (_db.select(_db.patrucheettuTable)
          ..where((t) => t.patrucheettuEn.equals(invoiceNumber))
          ..where((t) => t.seyaliVagai.equals('silk')))
        .get();
    if (existing.isNotEmpty) return; // Skip duplicates

    await _kalanjiyam.createPattiyal(
      PatrucheettuTableCompanion.insert(
        seyaliVagai: 'silk',
        patrucheettuEn: invoiceNumber,
        finYear: finYear,
        vanakkam: Value(vanakkam),
        niruvanamId: Value(niruvanamId),
        vanigarPeyar: clientName,
        vanigarId: Value(vanigarId),
        pattiyalVagai: Value(invoiceType),
        pattiyalNaal: Value(pattiyalNaal),
        tharavugal: Value(PattiyalUthavigal.pattuListToJson(items)),
        mothaThogai: Value(grandTotal),
        variThogai: Value(totalTax),
        sonthaViruppangal: Value(settingsJson),
        nibandhanaigal: Value(customTerms),
        ullkurippu: Value(internalNote),
      ),
    );
  }

  // ── Helpers ──

  /// Extract numeric part from bill number: "VRM-103" → 103
  int _extractNumber(String billNo) {
    final match = RegExp(r'(\d+)$').firstMatch(billNo);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// Extract prefix from bill number: "VRM-103" → "VRM"
  String _extractPrefix(String billNo) {
    final parts = billNo.split('-');
    return parts.isNotEmpty ? parts.first : '';
  }

  /// Parse DD/MM/YYYY format date
  DateTime _parseDdMmYyyy(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return DateTime.now();
  }

  /// Parse ISO (YYYY-MM-DD) or DD/MM/YYYY format
  DateTime _parseIsoOrDdMm(String dateStr) {
    // Try ISO format first
    try {
      if (dateStr.contains('-') && !dateStr.contains('/')) {
        return DateTime.parse(dateStr);
      }
    } catch (_) {}
    // Fall back to DD/MM/YYYY
    return _parseDdMmYyyy(dateStr);
  }
}
