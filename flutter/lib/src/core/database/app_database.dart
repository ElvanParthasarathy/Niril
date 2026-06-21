import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

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
  TextColumn get niruvanathinPeyar => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get kurumPeyar => text().withDefault(const Constant(''))();
  TextColumn get tholaipesi1 => text().withDefault(const Constant(''))();
  TextColumn get tholaipesi2 => text().withDefault(const Constant(''))();
  TextColumn get minnanchal => text().withDefault(const Constant(''))();
  TextColumn get gstin => text().withDefault(const Constant(''))();

  // ── முகவரி (Address) ──
  TextColumn get mugavari => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get oor => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get maavattam => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get maanilam => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get naadu => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get anchalkuriyeedu => text().withDefault(const Constant(''))();

  // ── வங்கி (Bank Details) ──
  TextColumn get vangiPeyar => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get kilai => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get vangiKanakku => text().withDefault(const Constant(''))();
  TextColumn get ifsc => text().withDefault(const Constant(''))();

  // ── அடையாளங்கள் (Branding) ──
  TextColumn get ovuru => text().withDefault(const Constant(''))();
  TextColumn get agalaOvuru => text().withDefault(const Constant(''))();
  TextColumn get thallaippuVadivu => text().withDefault(const Constant('small'))();
  TextColumn get kaiyoppam => text().withDefault(const Constant(''))();
  TextColumn get oppamPeyar => text().withDefault(const Constant(''))();

  // ── கூடுதல் (Additional) ──
  TextColumn get adaimozhi => text().map(const MozhiMapConverter()).withDefault(const Constant('{}'))();
  TextColumn get upiId => text().withDefault(const Constant(''))();
  TextColumn get thottranNiram => text().withDefault(const Constant(''))();
}

// ── Database ──
@DriftDatabase(tables: [VanigaTharavugalTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Version 2 removed SeyaliAmaippugalTable. No action needed.
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
