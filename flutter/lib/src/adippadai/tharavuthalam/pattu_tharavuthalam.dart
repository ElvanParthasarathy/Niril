import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'mozhi_map_converter.dart';

part 'pattu_tharavuthalam.g.dart';

// ── Table: நிறுவனத் தரவுகள் (Business Data) ──
@DataClassName('PattuNiruvanaTharavugalEntry')
class PattuNiruvanaTharavugalTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ── மொழி அமைப்பு (Language Config) ──
  TextColumn get mudhanMozhi => text().withDefault(const Constant('Tamil'))();
  TextColumn get thunaiMozhi => text().withDefault(const Constant('English'))();
  BoolColumn get iruMozhi => boolean().withDefault(const Constant(false))();

  // ── நிறுவனத் தரவு (Business Details) ──
  TextColumn get niruvanathinPeyar =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get kurumPeyar => text().withDefault(const Constant(''))();
  TextColumn get tholaipaesi1 => text().withDefault(const Constant(''))();
  TextColumn get tholaipaesi2 => text().withDefault(const Constant(''))();
  TextColumn get minnanjal => text().withDefault(const Constant(''))();
  TextColumn get gstin => text().withDefault(const Constant(''))();

  // ── முகவரி (Address) ──
  TextColumn get mugavari =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get oor =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get maavattam =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get maanilam =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get naadu =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{"en": "India", "ta": "இந்தியா"}'))();
  TextColumn get anjalKuriyeedu => text().withDefault(const Constant(''))();

  // ── வங்கி (Bank Details) ──
  TextColumn get vangiPeyar =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get kilai =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get vangiKanakku => text().withDefault(const Constant(''))();
  TextColumn get ifsc => text().withDefault(const Constant(''))();

  // ── அடையாளங்கள் (Branding) ──
  TextColumn get oavuru => text().withDefault(const Constant(''))();
  TextColumn get agalaOavuru => text().withDefault(const Constant(''))();
  TextColumn get thalaippuVadivu =>
      text().withDefault(const Constant('small'))();
  TextColumn get kaiyoppam => text().withDefault(const Constant(''))();
  TextColumn get oppamPeyar => text().withDefault(const Constant(''))();

  // ── கூடுதல் (Additional) ──
  TextColumn get adaimozhi =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get upiId => text().withDefault(const Constant(''))();

  // ── Audit & Soft Delete ──
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Table: வணிகர் (Customer / Merchant) ──
@DataClassName('PattuVaangunarEntry')
class PattuVaangunarTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // ── Bilingual fields (stored as JSON map via MozhiMapConverter) ──
  TextColumn get peyar =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get mugavari =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get oor =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get maavattam =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get maanilam =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get naadu =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{"en": "India", "ta": "இந்தியா"}'))();

  // ── Non-India: single multiline bilingual address ──
  TextColumn get velinaadMugavari =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();

  // ── Single-value fields ──
  TextColumn get anjalKuriyeedu => text().withDefault(const Constant(''))();
  TextColumn get gstin => text().withDefault(const Constant(''))();
  TextColumn get minnanjal => text().withDefault(const Constant(''))();
  TextColumn get tholaipaesi => text().withDefault(const Constant(''))();

  // Audit
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Table: பொருள் (Items / Products) ──
@DataClassName('PattuPorulEntry')
class PattuPorulTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Bilingual name: {"Tamil": "...", "English": "..."}
  TextColumn get porulPeyar =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get hsnCode => text().withDefault(const Constant(''))();
  RealColumn get vilai => real().withDefault(const Constant(0.0))();
  RealColumn get variVeetham => real().withDefault(const Constant(0.0))(); // GST %

  // Measure: 'quantity' | 'weight'
  TextColumn get alavuVagai => text().withDefault(const Constant('quantity'))();
  // Unit: 'Nos' | 'kg'
  TextColumn get alagu => text().withDefault(const Constant('Nos'))();

  // Audit
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Table: பற்றுச்சீட்டு (Invoice) ──
@DataClassName('PattuPatrucheettuEntry')
class PattuPatrucheettuTable extends Table {
  // ── Identity ──
  IntColumn get id => integer().autoIncrement()();
  IntColumn get niruvanamId => integer().nullable()(); // FK → PattuNiruvanaTharavugalTable

  // ── Invoice Header ──
  TextColumn get patrucheettuEn => text()(); // Display: SJS/2026-27/001
  IntColumn get finYear => integer()(); // e.g. 2026
  IntColumn get vanakkam =>
      integer().withDefault(const Constant(1))(); // Seq # within FY+company
  TextColumn get pattiyalVagai =>
      text().withDefault(const Constant('tax-invoice'))(); // Silk: tax-invoice / proforma

  // ── Customer (FK — not snapshot) ──
  IntColumn get vaangunarId => integer().nullable()(); // FK → PattuVaangunarTable
  TextColumn get vaangunarPeyar =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get vaangunarMunvari =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();

  // ── Date ──
  DateTimeColumn get pattiyalNaal =>
      dateTime().withDefault(currentDateAndTime)(); // Invoice date (not created date)

  // ── Line Items (JSON array) ──
  TextColumn get tharavugal =>
      text().withDefault(const Constant('[]'))();

  // ── Financial Results (stored at save, never re-calculated) ──
  RealColumn get mothaThogai =>
      real().withDefault(const Constant(0.0))(); // Grand total
  RealColumn get thallupadi =>
      real().withDefault(const Constant(0.0))(); // Total discount
  RealColumn get variThogai =>
      real().withDefault(const Constant(0.0))(); // Total tax
  TextColumn get variTharavugal =>
      text().withDefault(const Constant('{}'))(); // {cgst, sgst, igst}

  // ── Pattu-specific ──
  TextColumn get sonthaViruppangal =>
      text().withDefault(const Constant('{}'))(); // Invoice settings JSON
  TextColumn get nibandhanaigal =>
      text().withDefault(const Constant(''))(); // Custom terms
  TextColumn get ullkurippu =>
      text().withDefault(const Constant(''))(); // Internal note

  // ── Audit ──
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Receipt Table ──
@DataClassName('PattuPatrugalEntry')
class PattuPatrugalTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get niruvanamId =>
      integer().nullable()(); // FK → PattuNiruvanaTharavugalTable

  // ── Receipt Identity ──
  TextColumn get patruEn => text()();
  TextColumn get finYear => text().withDefault(const Constant(''))();
  IntColumn get vanakkam =>
      integer().withDefault(const Constant(1))(); // Seq # for auto-numbering

  // ── Customer (FK-first, fallback snapshot) ──
  IntColumn get vaangunarId =>
      integer().nullable()(); // FK → PattuVaangunarTable
  TextColumn get vaangunarPeyar =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get vaangunarMunvari =>
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();

  // ── Receipt Data ──
  DateTimeColumn get patruNaal =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get thogai =>
      real().withDefault(const Constant(0.0))(); // Amount received

  // ── Payment ──
  TextColumn get seluthumMurai => text().withDefault(const Constant('cash'))();
  TextColumn get vangiPeyar => text().nullable()(); // 'cash'|'upi'|'bank_transfer'|'cheque'|'card'
  TextColumn get parivarthanaiEn => text().nullable()(); // Reference/Transaction ID

  // ── Note ──
  TextColumn get ullkurippu =>
      text().withDefault(const Constant(''))();

  // ── Audit ──
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Receipt ↔ Invoice Junction Table ──
@DataClassName('PattuPatruPattiyalEntry')
class PattuPatruPattiyalTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patruId => integer()(); // FK → PattuPatrugalTable
  IntColumn get pattiyalId => integer()(); // FK → PattuPatrucheettuTable
  RealColumn get poruthiyaThogai =>
      real().withDefault(const Constant(0.0))(); // Amount applied to this invoice
}

// ── Database ──
@DriftDatabase(tables: [
  PattuNiruvanaTharavugalTable,
  PattuVaangunarTable,
  PattuPorulTable,
  PattuPatrucheettuTable,
  PattuPatrugalTable,
  PattuPatruPattiyalTable,
])
class PattuDatabase extends _$PattuDatabase {
  PattuDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations
        },
      );

  /// Opens the SQLite file safely on all platforms.
  static LazyDatabase openConnection(String dbName) {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationSupportDirectory();

      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }

      final file = File(p.join(dbFolder.path, dbName));

      // MIGRATION LOGIC: If DB exists but new tables don't, copy data
      // This is handled by Drift's onCreate or custom startup logic,
      // but since we keep the file name 'elvan_niril_silk.db', the file exists.
      // We will handle data migration in a separate startup function.

      if (Platform.isWindows) {
        sqlite3.tempDirectory = dbFolder.path;
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}
