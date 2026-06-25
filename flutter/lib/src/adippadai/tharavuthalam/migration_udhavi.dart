import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'kooli_tharavuthalam.dart';
import 'pattu_tharavuthalam.dart';
import 'seyali_tharavuthalam.dart';
import 'seyali_tharavuthalam.dart';

/// Service to migrate data from the legacy AppDatabase (elvan_niril.db) 
/// to the new split databases (elvan_niril_silk.db and elvan_niril_coolie.db).
class MigrationUdhavi {
  final AppDatabase oldDb;
  final PattuDatabase pattuDb;
  final KooliDatabase kooliDb;

  MigrationUdhavi({
    required this.oldDb,
    required this.pattuDb,
    required this.kooliDb,
  });

  Future<void> runMigration() async {
    debugPrint('Starting database migration...');

    try {
      await _migrateNiruvanaTharavugal();
      await _migrateVaangunargal();
      await _migratePorulgal();
      await _migratePatrucheettugal();
      await _migratePatrugal();
      
      debugPrint('Migration completed successfully!');
    } catch (e, stack) {
      debugPrint('Migration failed: $e\n$stack');
      rethrow;
    }
  }

  Future<void> _migrateNiruvanaTharavugal() async {
    final entries = await oldDb.select(oldDb.niruvanaTharavugalTable).get();
    
    for (final entry in entries) {
      if (entry.seyaliVagai == 'silk') {
        await pattuDb.into(pattuDb.pattuNiruvanaTharavugalTable).insert(
          PattuNiruvanaTharavugalTableCompanion.insert(
            id: Value(entry.id),
            niruvanamPeyar: entry.niruvanamPeyar,
            mugavari: entry.mugavari,
            minnanjal: entry.minnanjal,
            tholaipaesi: entry.tholaipaesi,
            gstin: entry.gstin,
            panEn: entry.panEn,
            vangiTharavugal: entry.vangiTharavugal,
            oavuruTharavugal: entry.oavuruTharavugal,
            upiTharavugal: entry.upiTharavugal,
            pattiyalThalaippu: entry.pattiyalThalaippu,
            pattiyalArikkai: entry.pattiyalArikkai,
            nibandhanaigal: entry.nibandhanaigal,
            sonthaViruppangal: entry.sonthaViruppangal,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (entry.seyaliVagai == 'coolie') {
        await kooliDb.into(kooliDb.kooliNiruvanaTharavugalTable).insert(
          KooliNiruvanaTharavugalTableCompanion.insert(
            id: Value(entry.id),
            niruvanamPeyar: entry.niruvanamPeyar,
            mugavari: entry.mugavari,
            minnanjal: entry.minnanjal,
            tholaipaesi: entry.tholaipaesi,
            gstin: entry.gstin,
            panEn: entry.panEn,
            vangiTharavugal: entry.vangiTharavugal,
            oavuruTharavugal: entry.oavuruTharavugal,
            upiTharavugal: entry.upiTharavugal,
            pattiyalThalaippu: entry.pattiyalThalaippu,
            pattiyalArikkai: entry.pattiyalArikkai,
            nibandhanaigal: entry.nibandhanaigal,
            sonthaViruppangal: entry.sonthaViruppangal,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
  }

  Future<void> _migrateVaangunargal() async {
    final entries = await oldDb.select(oldDb.vaangunarTable).get();
    
    for (final entry in entries) {
      if (entry.seyaliVagai == 'silk') {
        await pattuDb.into(pattuDb.pattuVaangunarTable).insert(
          PattuVaangunarTableCompanion.insert(
            id: Value(entry.id),
            peyar: Value(entry.peyar),
            mugavari: Value(entry.mugavari),
            oor: Value(entry.oor),
            maavattam: Value(entry.maavattam),
            maanilam: Value(entry.maanilam),
            naadu: Value(entry.naadu),
            velinaadMugavari: Value(entry.velinaadMugavari),
            anjalKuriyeedu: Value(entry.anjalKuriyeedu),
            gstin: Value(entry.gstin),
            minnanjal: Value(entry.minnanjal),
            tholaipaesi: Value(entry.tholaipaesi),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (entry.seyaliVagai == 'coolie') {
        await kooliDb.into(kooliDb.kooliVaangunarTable).insert(
          KooliVaangunarTableCompanion.insert(
            id: Value(entry.id),
            peyar: Value(entry.peyar),
            mugavari: Value(entry.mugavari),
            oor: Value(entry.oor),
            maavattam: Value(entry.maavattam),
            maanilam: Value(entry.maanilam),
            naadu: Value(entry.naadu),
            velinaadMugavari: Value(entry.velinaadMugavari),
            anjalKuriyeedu: Value(entry.anjalKuriyeedu),
            gstin: Value(entry.gstin),
            minnanjal: Value(entry.minnanjal),
            tholaipaesi: Value(entry.tholaipaesi),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
  }

  Future<void> _migratePorulgal() async {
    final entries = await oldDb.select(oldDb.porulTable).get();
    
    for (final entry in entries) {
      if (entry.seyaliVagai == 'silk') {
        await pattuDb.into(pattuDb.pattuPorulTable).insert(
          PattuPorulTableCompanion.insert(
            id: Value(entry.id),
            porulPeyar: Value(entry.porulPeyar),
            hsnCode: Value(entry.hsnCode),
            vilai: Value(entry.vilai),
            variVeetham: Value(entry.variVeetham),
            alavuVagai: Value(entry.alavuVagai),
            alagu: Value(entry.alagu),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (entry.seyaliVagai == 'coolie') {
        await kooliDb.into(kooliDb.kooliPorulTable).insert(
          KooliPorulTableCompanion.insert(
            id: Value(entry.id),
            porulPeyar: Value(entry.porulPeyar),
            hsnCode: Value(entry.hsnCode),
            vilai: Value(entry.vilai),
            variVeetham: Value(entry.variVeetham),
            alavuVagai: Value(entry.alavuVagai),
            alagu: Value(entry.alagu),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
  }

  Future<void> _migratePatrucheettugal() async {
    final entries = await oldDb.select(oldDb.patrucheettuTable).get();
    
    for (final entry in entries) {
      if (entry.seyaliVagai == 'silk') {
        await pattuDb.into(pattuDb.pattuPatrucheettuTable).insert(
          PattuPatrucheettuTableCompanion.insert(
            id: Value(entry.id),
            niruvanamId: Value(entry.niruvanamId),
            patrucheettuEn: entry.patrucheettuEn,
            finYear: entry.finYear,
            vanakkam: entry.vanakkam,
            pattiyalVagai: entry.pattiyalVagai,
            vaangunarId: Value(entry.vaangunarId),
            vaangunarPeyar: Value(entry.vaangunarPeyar),
            vaangunarMunvari: Value(entry.vaangunarMunvari),
            pattiyalNaal: entry.pattiyalNaal,
            tharavugal: entry.tharavugal,
            mothaThogai: entry.mothaThogai,
            thallupadi: Value(entry.thallupadi),
            variThogai: entry.variThogai,
            variTharavugal: entry.variTharavugal,
            sonthaViruppangal: Value(entry.sonthaViruppangal),
            nibandhanaigal: Value(entry.nibandhanaigal),
            ullkurippu: Value(entry.ullkurippu),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (entry.seyaliVagai == 'coolie') {
        await kooliDb.into(kooliDb.kooliPatrucheettuTable).insert(
          KooliPatrucheettuTableCompanion.insert(
            id: Value(entry.id),
            niruvanamId: Value(entry.niruvanamId),
            patrucheettuEn: entry.patrucheettuEn,
            finYear: entry.finYear,
            vanakkam: entry.vanakkam,
            pattiyalVagai: entry.pattiyalVagai,
            vaangunarId: Value(entry.vaangunarId),
            vaangunarPeyar: Value(entry.vaangunarPeyar),
            vaangunarMunvari: Value(entry.vaangunarMunvari),
            pattiyalNaal: entry.pattiyalNaal,
            tharavugal: entry.tharavugal,
            mothaThogai: entry.mothaThogai,
            thallupadi: Value(entry.thallupadi),
            variThogai: entry.variThogai,
            variTharavugal: entry.variTharavugal,
            mothaEdai: entry.mothaEdai,
            setharamGrams: entry.setharamGrams,
            thabaalThogai: entry.thabaalThogai,
            ahimsaPattuThogai: entry.ahimsaPattuThogai,
            piravariVugal: entry.piravariVugal,
            vangiTharavugal: Value(entry.vangiTharavugal),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
  }

  Future<void> _migratePatrugal() async {
    // Patrugal
    final patrugalEntries = await oldDb.select(oldDb.patrugalTable).get();
    
    for (final entry in patrugalEntries) {
      if (entry.seyaliVagai == 'silk') {
        await pattuDb.into(pattuDb.pattuPatrugalTable).insert(
          PattuPatrugalTableCompanion.insert(
            id: Value(entry.id),
            niruvanamId: Value(entry.niruvanamId),
            patruEn: entry.patruEn,
            vanakkam: entry.vanakkam,
            finYear: entry.finYear,
            vaangunarId: Value(entry.vaangunarId),
            vaangunarPeyar: Value(entry.vaangunarPeyar),
            patruNaal: entry.patruNaal,
            thogai: entry.thogai,
            seluthumMurai: entry.seluthumMurai,
            vangiPeyar: Value(entry.vangiPeyar),
            parivarthanaiEn: Value(entry.parivarthanaiEn),
            ullkurippu: Value(entry.ullkurippu),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (entry.seyaliVagai == 'coolie') {
        await kooliDb.into(kooliDb.kooliPatrugalTable).insert(
          KooliPatrugalTableCompanion.insert(
            id: Value(entry.id),
            niruvanamId: Value(entry.niruvanamId),
            patruEn: entry.patruEn,
            vanakkam: entry.vanakkam,
            finYear: entry.finYear,
            vaangunarId: Value(entry.vaangunarId),
            vaangunarPeyar: Value(entry.vaangunarPeyar),
            patruNaal: entry.patruNaal,
            thogai: entry.thogai,
            seluthumMurai: entry.seluthumMurai,
            vangiPeyar: Value(entry.vangiPeyar),
            parivarthanaiEn: Value(entry.parivarthanaiEn),
            ullkurippu: Value(entry.ullkurippu),
            isDeleted: Value(entry.isDeleted),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(entry.updatedAt),
            deletedAt: Value(entry.deletedAt),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }

    // PatruPattiyal Inaippu (Links)
    final links = await oldDb.select(oldDb.patruPattiyalTable).get();
    
    for (final link in links) {
      // Find which DB to put it in based on the patru entry
      final patru = patrugalEntries.where((p) => p.id == link.patruId).firstOrNull;
      if (patru == null) continue;

      if (patru.seyaliVagai == 'silk') {
        await pattuDb.into(pattuDb.pattuPatruPattiyalTable).insert(
          PattuPatruPattiyalTableCompanion.insert(
            patruId: link.patruId,
            pattiyalId: link.pattiyalId,
            poruthiyaThogai: Value(link.poruthiyaThogai),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (patru.seyaliVagai == 'coolie') {
        await kooliDb.into(kooliDb.kooliPatruPattiyalTable).insert(
          KooliPatruPattiyalTableCompanion.insert(
            patruId: link.patruId,
            pattiyalId: link.pattiyalId,
            poruthiyaThogai: Value(link.poruthiyaThogai),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
  }
}

final migrationUdhaviProvider = Provider<MigrationUdhavi>((ref) {
  return MigrationUdhavi(
    oldDb: ref.watch(appDatabaseProvider),
    pattuDb: ref.watch(pattuDatabaseProvider),
    kooliDb: ref.watch(kooliDatabaseProvider),
  );
});
