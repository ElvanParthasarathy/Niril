import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'seyali_tharavuthalam.g.dart';

// ── Type Converter: Map<String, String> ↔ JSON text ──
// Used for all bilingual fields (நிறுவனத்தின் பெயர், முகவரி, etc.)
class MozhiMapConverter extends TypeConverter<Map<String, String>, String> {
  const MozhiMapConverter();

  @override
  Map<String, String> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '{}') return {};
    try {
      final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  @override
  String toSql(Map<String, String> value) {
    return jsonEncode(value);
  }
}

// ── Table: வணிக தரவுகள் (Business Data) ──
@DataClassName('VanigaTharavugalEntry')
class VanigaTharavugalTable extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // App mode: 'gst' or 'coolie'
  TextColumn get seyaliVagai => text()();

  // ── மொழி அமைப்பு (Language Config) ──
  TextColumn get mudhanMozhi => text().withDefault(const Constant('Tamil'))();
  TextColumn get thunaiMozhi => text().withDefault(const Constant('English'))();
  BoolColumn get iruMozhi => boolean().withDefault(const Constant(false))();

  // ── வணிகத் தரவு (Business Details) ──
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
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
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
  TextColumn get thoatraNiram => text().withDefault(const Constant(''))();

  // ── Audit & Soft Delete ──
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Table: வணிகர் (Customer / Merchant) ──
@DataClassName('VanigarEntry')
class VanigarTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get seyaliVagai => text()(); // 'gst' or 'coolie'

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
      text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();

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
@DataClassName('PorulEntry')
class PorulTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get seyaliVagai => text()();
  
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
@DataClassName('PatrucheettuEntry')
class PatrucheettuTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get seyaliVagai => text()();
  
  // Financial Data
  TextColumn get patrucheettuEn => text()(); // e.g. INV/2026-27/001
  IntColumn get finYear => integer()(); // e.g. 2026
  
  // Customer Snapshot (In case customer is deleted/changed later)
  IntColumn get vanigarId => integer().nullable()();
  TextColumn get vanigarPeyar => text()();
  TextColumn get vanigarTholaipaesi => text().withDefault(const Constant(''))();
  
  // Totals
  RealColumn get mothaThogai => real().withDefault(const Constant(0.0))();
  
  // Items JSON Snapshot
  TextColumn get tharavugal => text().withDefault(const Constant('[]'))();

  // Audit
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Database ──
@DriftDatabase(tables: [
  VanigaTharavugalTable,
  VanigarTable,
  PorulTable,
  PatrucheettuTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 3) {
            // Add new audit columns to existing VanigaTharavugalTable
            await m.addColumn(vanigaTharavugalTable, vanigaTharavugalTable.createdAt);
            await m.addColumn(vanigaTharavugalTable, vanigaTharavugalTable.updatedAt);
            await m.addColumn(vanigaTharavugalTable, vanigaTharavugalTable.isDeleted);
            await m.addColumn(vanigaTharavugalTable, vanigaTharavugalTable.deletedAt);
            
            // Create new tables added in version 3
            await m.createTable(vanigarTable);
            await m.createTable(porulTable);
            await m.createTable(patrucheettuTable);
          }
          if (from < 4) {
            // v4: Add measureType + unit columns to PorulTable
            await m.addColumn(porulTable, porulTable.alavuVagai);
            await m.addColumn(porulTable, porulTable.alagu);
          }
          if (from < 5) {
            // v5: Expand VanigarTable — bilingual fields + new columns
            // peyar was plain text, now MozhiMap — migration: wrap old value
            // New columns with defaults:
            await m.addColumn(vanigarTable, vanigarTable.oor);
            await m.addColumn(vanigarTable, vanigarTable.maavattam);
            await m.addColumn(vanigarTable, vanigarTable.maanilam);
            await m.addColumn(vanigarTable, vanigarTable.naadu);
            await m.addColumn(vanigarTable, vanigarTable.velinaadMugavari);
            await m.addColumn(vanigarTable, vanigarTable.anjalKuriyeedu);
            await m.addColumn(vanigarTable, vanigarTable.minnanjal);

            // Migrate old plain-text peyar & mugavari to JSON map format
            await customStatement(
              "UPDATE vanigar_table SET peyar = '{\"en\":' || '\"' || peyar || '\"' || '}' "
              "WHERE peyar NOT LIKE '{%}'",
            );
            await customStatement(
              "UPDATE vanigar_table SET mugavari = '{\"en\":' || '\"' || mugavari || '\"' || '}' "
              "WHERE mugavari NOT LIKE '{%}' AND mugavari != ''",
            );
            // Set empty mugavari to default JSON
            await customStatement(
              "UPDATE vanigar_table SET mugavari = '{}' WHERE mugavari = ''",
            );
          }
        },
      );

  /// Opens the SQLite file safely on all platforms.
  static LazyDatabase openConnection() {
    return LazyDatabase(() async {
      // Use Support Directory instead of Documents Directory.
      // Windows Documents dir is often locked by OneDrive or permissions, preventing SQLite journaling.
      final dbFolder = await getApplicationSupportDirectory();

      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }

      final file = File(p.join(dbFolder.path, 'elvan_niril.db'));

      if (Platform.isWindows) {
        // Essential for Windows: tell SQLite where to store temporary files (like WAL journals)
        // Otherwise, changes might be lost when the app closes.
        sqlite3.tempDirectory = dbFolder.path;
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}
