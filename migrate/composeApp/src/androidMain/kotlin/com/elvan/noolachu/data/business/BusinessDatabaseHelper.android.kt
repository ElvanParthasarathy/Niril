package com.elvan.noolachu.data.business

import android.content.ContentValues
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.os.Environment
import android.util.Log
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.platform.AppContext
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.settings.MozhiJsonConverter
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class AndroidBusinessDatabaseHelper : BusinessDatabaseHelper {

    private val tag = "BusinessDbHelper"
    private val coolieDbName = "elvan_niril_coolie.db"
    private val silkDbName = "elvan_niril_silk.db"

    private fun getCandidatePaths(dbName: String): List<File> {
        val list = mutableListOf<File>()
        if (AppContext.isInitialized) {
            val ctx = AppContext.context
            list.add(ctx.getDatabasePath(dbName))
            list.add(File(ctx.filesDir, dbName))
            ctx.getExternalFilesDir(null)?.let {
                list.add(File(it, dbName))
            }
        }
        list.add(File("/sdcard/$dbName"))
        list.add(File("/storage/emulated/0/$dbName"))
        list.add(File(Environment.getExternalStorageDirectory(), dbName))
        list.add(File("/sdcard/Download/$dbName"))
        list.add(File("/sdcard/Documents/$dbName"))
        list.add(File("/sdcard/ElvanNiril/$dbName"))
        list.add(File("/data/user/0/com.elvan.niril/files/$dbName"))
        list.add(File("/data/data/com.elvan.niril/files/$dbName"))
        list.add(File("/data/user/0/com.elvan.niril/databases/$dbName"))
        return list
    }

    private fun resolveActiveDatabase(dbName: String): File? {
        if (!AppContext.isInitialized) {
            Log.w(tag, "AppContext is not initialized yet!")
            return null
        }
        val ctx = AppContext.context
        val localDb = ctx.getDatabasePath(dbName)
        localDb.parentFile?.mkdirs()

        val candidates = getCandidatePaths(dbName)
        for (candidate in candidates) {
            if (candidate.absolutePath == localDb.absolutePath) continue
            try {
                if (candidate.exists() && candidate.canRead() && candidate.length() > 0) {
                    if (!localDb.exists() || localDb.length() == 0L || candidate.lastModified() > localDb.lastModified()) {
                        Log.d(tag, "Syncing database from ${candidate.absolutePath} to ${localDb.absolutePath}")
                        copyFile(candidate, localDb)
                        break
                    }
                }
            } catch (_: Exception) {}
        }

        if (localDb.exists() && localDb.length() > 0) {
            return localDb
        }

        val filesDb = File(ctx.filesDir, dbName)
        if (filesDb.exists() && filesDb.length() > 0) {
            try {
                copyFile(filesDb, localDb)
                return localDb
            } catch (_: Exception) {
                return filesDb
            }
        }

        for (candidate in candidates) {
            try {
                if (candidate.exists() && candidate.canRead() && candidate.length() > 0) {
                    return candidate
                }
            } catch (_: Exception) {}
        }

        return localDb
    }

    private fun copyFile(src: File, dst: File) {
        try {
            dst.parentFile?.mkdirs()
            FileInputStream(src).use { input ->
                FileOutputStream(dst).use { output ->
                    input.copyTo(output)
                }
            }
        } catch (e: Exception) {
            Log.e(tag, "Failed to copy ${src.absolutePath} to ${dst.absolutePath}: ${e.message}")
        }
    }

    private fun ensureTables(db: SQLiteDatabase, mode: AppMode) {
        val vaangunarTable = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val porulTable = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"

        val createVaangunarSql = """
            CREATE TABLE IF NOT EXISTS "$vaangunarTable" (
                "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                "peyar" TEXT NOT NULL DEFAULT '{}',
                "mugavari" TEXT NOT NULL DEFAULT '{}',
                "oor" TEXT NOT NULL DEFAULT '{}',
                "maavattam" TEXT NOT NULL DEFAULT '{}',
                "maanilam" TEXT NOT NULL DEFAULT '{}',
                "naadu" TEXT NOT NULL DEFAULT '{"en": "India", "ta": "இந்தியா"}',
                "velinaad_mugavari" TEXT NOT NULL DEFAULT '{}',
                "anjal_kuriyeedu" TEXT NOT NULL DEFAULT '',
                "gstin" TEXT NOT NULL DEFAULT '',
                "minnanjal" TEXT NOT NULL DEFAULT '',
                "tholaipaesi" TEXT NOT NULL DEFAULT '',
                "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
                "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
                "is_deleted" INTEGER NOT NULL DEFAULT 0 CHECK ("is_deleted" IN (0, 1)),
                "deleted_at" INTEGER NULL
            )
        """.trimIndent()

        val createPorulSql = """
            CREATE TABLE IF NOT EXISTS "$porulTable" (
                "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                "porul_peyar" TEXT NOT NULL DEFAULT '{}',
                "hsn_code" TEXT NOT NULL DEFAULT '',
                "vilai" REAL NOT NULL DEFAULT 0.0,
                "vari_veetham" REAL NOT NULL DEFAULT 0.0,
                "alavu_vagai" TEXT NOT NULL DEFAULT 'quantity',
                "alagu" TEXT NOT NULL DEFAULT 'Nos',
                "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
                "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
                "is_deleted" INTEGER NOT NULL DEFAULT 0 CHECK ("is_deleted" IN (0, 1)),
                "deleted_at" INTEGER NULL
            )
        """.trimIndent()

        db.execSQL(createVaangunarSql)
        db.execSQL(createPorulSql)
    }

    override fun loadAllMerchants(mode: AppMode): List<VaangunarTharavuru> {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return emptyList()

        val list = mutableListOf<VaangunarTharavuru>()
        var db: SQLiteDatabase? = null
        var cursor: Cursor? = null
        try {
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureTables(db, mode)
            val sql = "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY updated_at DESC, id DESC"
            cursor = db.rawQuery(sql, null)
            while (cursor.moveToNext()) {
                list.add(cursorToMerchant(cursor))
            }
        } catch (e: Exception) {
            Log.e(tag, "Error loading merchants from $tableName: ${e.message}", e)
        } finally {
            cursor?.close()
            db?.close()
        }
        return list
    }

    override fun saveMerchant(mode: AppMode, merchant: VaangunarTharavuru): Long {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return -1L

        var db: SQLiteDatabase? = null
        try {
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureTables(db, mode)

            val nowSec = System.currentTimeMillis() / 1000
            val values = ContentValues().apply {
                put("peyar", MozhiJsonConverter.stringify(merchant.peyar))
                put("mugavari", MozhiJsonConverter.stringify(merchant.mugavari))
                put("oor", MozhiJsonConverter.stringify(merchant.oor))
                put("maavattam", MozhiJsonConverter.stringify(merchant.maavattam))
                put("maanilam", MozhiJsonConverter.stringify(merchant.maanilam))
                put("naadu", MozhiJsonConverter.stringify(merchant.naadu))
                put("velinaad_mugavari", MozhiJsonConverter.stringify(merchant.velinaadMugavari))
                put("anjal_kuriyeedu", merchant.anjalKuriyeedu)
                put("gstin", merchant.gstin)
                put("minnanjal", merchant.minnanjal)
                put("tholaipaesi", merchant.tholaipaesi)
                put("updated_at", nowSec)
                put("is_deleted", if (merchant.isDeleted) 1 else 0)
                if (merchant.deletedAt != null) {
                    val delSec = if (merchant.deletedAt > 10000000000L) merchant.deletedAt / 1000 else merchant.deletedAt
                    put("deleted_at", delSec)
                } else {
                    putNull("deleted_at")
                }
            }

            val resultId: Long
            if (merchant.id > 0L) {
                val updated = db.update(tableName, values, "id = ?", arrayOf(merchant.id.toString()))
                resultId = if (updated > 0) merchant.id else -1L
            } else {
                val createdSec = if (merchant.createdAt > 10000000000L) merchant.createdAt / 1000 else if (merchant.createdAt > 0L) merchant.createdAt else nowSec
                values.put("created_at", createdSec)
                resultId = db.insert(tableName, null, values)
            }

            try {
                val backupFile = File("/sdcard/$dbName")
                if (backupFile.exists() && backupFile.canWrite()) {
                    copyFile(dbFile, backupFile)
                }
            } catch (_: Exception) {}

            return resultId
        } catch (e: Exception) {
            Log.e(tag, "Error saving merchant to $tableName: ${e.message}", e)
            return -1L
        } finally {
            db?.close()
        }
    }

    override fun deleteMerchant(mode: AppMode, id: Long): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return false

        var db: SQLiteDatabase? = null
        try {
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureTables(db, mode)
            val nowSec = System.currentTimeMillis() / 1000
            val values = ContentValues().apply {
                put("is_deleted", 1)
                put("deleted_at", nowSec)
                put("updated_at", nowSec)
            }
            val rows = db.update(tableName, values, "id = ?", arrayOf(id.toString()))

            try {
                val backupFile = File("/sdcard/$dbName")
                if (backupFile.exists() && backupFile.canWrite()) {
                    copyFile(dbFile, backupFile)
                }
            } catch (_: Exception) {}

            return rows > 0
        } catch (e: Exception) {
            Log.e(tag, "Error deleting merchant $id from $tableName: ${e.message}", e)
            return false
        } finally {
            db?.close()
        }
    }

    override fun loadAllItems(mode: AppMode): List<PorulTharavuru> {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return emptyList()

        val list = mutableListOf<PorulTharavuru>()
        var db: SQLiteDatabase? = null
        var cursor: Cursor? = null
        try {
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureTables(db, mode)
            val sql = "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY updated_at DESC, id DESC"
            cursor = db.rawQuery(sql, null)
            while (cursor.moveToNext()) {
                list.add(cursorToItem(cursor))
            }
        } catch (e: Exception) {
            Log.e(tag, "Error loading items from $tableName: ${e.message}", e)
        } finally {
            cursor?.close()
            db?.close()
        }
        return list
    }

    override fun saveItem(mode: AppMode, item: PorulTharavuru): Long {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return -1L

        var db: SQLiteDatabase? = null
        try {
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureTables(db, mode)

            val nowSec = System.currentTimeMillis() / 1000
            val values = ContentValues().apply {
                put("porul_peyar", MozhiJsonConverter.stringify(item.porulPeyar))
                put("hsn_code", item.hsnCode)
                put("vilai", item.vilai)
                put("vari_veetham", item.variVeetham)
                put("alavu_vagai", item.alavuVagai)
                put("alagu", item.alagu)
                put("updated_at", nowSec)
                put("is_deleted", if (item.isDeleted) 1 else 0)
                if (item.deletedAt != null) {
                    val delSec = if (item.deletedAt > 10000000000L) item.deletedAt / 1000 else item.deletedAt
                    put("deleted_at", delSec)
                } else {
                    putNull("deleted_at")
                }
            }

            val resultId: Long
            if (item.id > 0L) {
                val updated = db.update(tableName, values, "id = ?", arrayOf(item.id.toString()))
                resultId = if (updated > 0) item.id else -1L
            } else {
                val createdSec = if (item.createdAt > 10000000000L) item.createdAt / 1000 else if (item.createdAt > 0L) item.createdAt else nowSec
                values.put("created_at", createdSec)
                resultId = db.insert(tableName, null, values)
            }

            try {
                val backupFile = File("/sdcard/$dbName")
                if (backupFile.exists() && backupFile.canWrite()) {
                    copyFile(dbFile, backupFile)
                }
            } catch (_: Exception) {}

            return resultId
        } catch (e: Exception) {
            Log.e(tag, "Error saving item to $tableName: ${e.message}", e)
            return -1L
        } finally {
            db?.close()
        }
    }

    override fun deleteItem(mode: AppMode, id: Long): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return false

        var db: SQLiteDatabase? = null
        try {
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureTables(db, mode)
            val nowSec = System.currentTimeMillis() / 1000
            val values = ContentValues().apply {
                put("is_deleted", 1)
                put("deleted_at", nowSec)
                put("updated_at", nowSec)
            }
            val rows = db.update(tableName, values, "id = ?", arrayOf(id.toString()))

            try {
                val backupFile = File("/sdcard/$dbName")
                if (backupFile.exists() && backupFile.canWrite()) {
                    copyFile(dbFile, backupFile)
                }
            } catch (_: Exception) {}

            return rows > 0
        } catch (e: Exception) {
            Log.e(tag, "Error deleting item $id from $tableName: ${e.message}", e)
            return false
        } finally {
            db?.close()
        }
    }

    private fun cursorToMerchant(cursor: Cursor): VaangunarTharavuru {
        fun getString(col: String): String {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getString(idx) else ""
        }
        fun getLong(col: String, defaultVal: Long = 0L): Long {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getLong(idx) else defaultVal
        }
        fun getNullableLong(col: String): Long? {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getLong(idx) else null
        }
        fun getInt(col: String, defaultVal: Int = 0): Int {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getInt(idx) else defaultVal
        }

        val naaduMap = MozhiJsonConverter.parse(getString("naadu"))
        val naadu = if (naaduMap.isEmpty()) mapOf("en" to "India", "ta" to "இந்தியா") else naaduMap
        val rawCreatedAt = getLong("created_at")
        val createdAt = if (rawCreatedAt in 1..9999999999L) rawCreatedAt * 1000 else rawCreatedAt
        val rawUpdatedAt = getLong("updated_at")
        val updatedAt = if (rawUpdatedAt in 1..9999999999L) rawUpdatedAt * 1000 else rawUpdatedAt
        val rawDeletedAt = getNullableLong("deleted_at")
        val deletedAt = if (rawDeletedAt != null && rawDeletedAt in 1..9999999999L) rawDeletedAt * 1000 else rawDeletedAt

        return VaangunarTharavuru(
            id = getLong("id"),
            peyar = MozhiJsonConverter.parse(getString("peyar")),
            mugavari = MozhiJsonConverter.parse(getString("mugavari")),
            oor = MozhiJsonConverter.parse(getString("oor")),
            maavattam = MozhiJsonConverter.parse(getString("maavattam")),
            maanilam = MozhiJsonConverter.parse(getString("maanilam")),
            naadu = naadu,
            velinaadMugavari = MozhiJsonConverter.parse(getString("velinaad_mugavari")),
            anjalKuriyeedu = getString("anjal_kuriyeedu"),
            gstin = getString("gstin"),
            minnanjal = getString("minnanjal"),
            tholaipaesi = getString("tholaipaesi"),
            createdAt = createdAt,
            updatedAt = updatedAt,
            isDeleted = getInt("is_deleted", 0) == 1,
            deletedAt = deletedAt
        )
    }

    private fun cursorToItem(cursor: Cursor): PorulTharavuru {
        fun getString(col: String): String {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getString(idx) else ""
        }
        fun getLong(col: String, defaultVal: Long = 0L): Long {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getLong(idx) else defaultVal
        }
        fun getNullableLong(col: String): Long? {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getLong(idx) else null
        }
        fun getInt(col: String, defaultVal: Int = 0): Int {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getInt(idx) else defaultVal
        }
        fun getDouble(col: String, defaultVal: Double = 0.0): Double {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getDouble(idx) else defaultVal
        }

        val rawCreatedAt = getLong("created_at")
        val createdAt = if (rawCreatedAt in 1..9999999999L) rawCreatedAt * 1000 else rawCreatedAt
        val rawUpdatedAt = getLong("updated_at")
        val updatedAt = if (rawUpdatedAt in 1..9999999999L) rawUpdatedAt * 1000 else rawUpdatedAt
        val rawDeletedAt = getNullableLong("deleted_at")
        val deletedAt = if (rawDeletedAt != null && rawDeletedAt in 1..9999999999L) rawDeletedAt * 1000 else rawDeletedAt

        return PorulTharavuru(
            id = getLong("id"),
            porulPeyar = MozhiJsonConverter.parse(getString("porul_peyar")),
            hsnCode = getString("hsn_code"),
            vilai = getDouble("vilai"),
            variVeetham = getDouble("vari_veetham"),
            alavuVagai = getString("alavu_vagai").ifEmpty { "quantity" },
            alagu = getString("alagu").ifEmpty { "Nos" },
            createdAt = createdAt,
            updatedAt = updatedAt,
            isDeleted = getInt("is_deleted", 0) == 1,
            deletedAt = deletedAt
        )
    }
}

private val androidBusinessHelperInstance by lazy { AndroidBusinessDatabaseHelper() }

actual fun getBusinessDatabaseHelper(): BusinessDatabaseHelper = androidBusinessHelperInstance
