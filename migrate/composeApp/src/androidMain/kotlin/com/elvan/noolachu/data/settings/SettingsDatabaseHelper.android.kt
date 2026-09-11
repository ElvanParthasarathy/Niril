package com.elvan.noolachu.data.settings

import android.content.ContentValues
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.platform.AppContext
import java.io.File

class AndroidSettingsDatabaseHelper : SettingsDatabaseHelper {

    private val tag = "SettingsDatabaseHelper"
    private val coolieDbName = "elvan_niril_coolie.db"
    private val silkDbName = "elvan_niril_silk.db"

    private fun resolveActiveDatabase(dbName: String): File? {
        if (!AppContext.isInitialized) {
            Log.w(tag, "AppContext is not initialized yet!")
            return null
        }
        val localDb = AppContext.context.getDatabasePath(dbName)
        localDb.parentFile?.mkdirs()
        return localDb
    }

    override fun scanAndSync(): DatabaseScanReport {
        val coolieFile = resolveActiveDatabase(coolieDbName)
        val silkFile = resolveActiveDatabase(silkDbName)

        val report = DatabaseScanReport(
            isCoolieFound = coolieFile != null && coolieFile.exists(),
            cooliePath = coolieFile?.absolutePath,
            isSilkFound = silkFile != null && silkFile.exists(),
            silkPath = silkFile?.absolutePath,
            message = "Coolie: ${coolieFile?.absolutePath ?: "Not Found"}, Silk: ${silkFile?.absolutePath ?: "Not Found"}"
        )
        Log.i(tag, "Database scan result: ${report.message}")
        return report
    }

    override fun loadProfile(mode: AppMode, profileId: Long?): NiruvanaTharavugal? {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return null

        var db: SQLiteDatabase? = null
        var cursor: Cursor? = null
        try {
            db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            val sql = if (profileId != null) {
                "SELECT * FROM $tableName WHERE id = ? AND is_deleted = 0 LIMIT 1"
            } else {
                "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY id ASC LIMIT 1"
            }
            val args = if (profileId != null) arrayOf(profileId.toString()) else null
            cursor = db.rawQuery(sql, args)
            if (cursor.moveToFirst()) {
                return cursorToProfile(cursor, mode)
            }
        } catch (e: Exception) {
            Log.e(tag, "Error loading profile from $tableName: ${e.message}", e)
        } finally {
            cursor?.close()
            db?.close()
        }
        return null
    }

    override fun loadAllProfiles(mode: AppMode): List<NiruvanaTharavugal> {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return emptyList()

        val list = mutableListOf<NiruvanaTharavugal>()
        var db: SQLiteDatabase? = null
        var cursor: Cursor? = null
        try {
            db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            cursor = db.rawQuery("SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY id ASC", null)
            while (cursor.moveToNext()) {
                list.add(cursorToProfile(cursor, mode))
            }
        } catch (e: Exception) {
            Log.e(tag, "Error loading all profiles from $tableName: ${e.message}", e)
        } finally {
            cursor?.close()
            db?.close()
        }
        return list
    }

    private fun ensureColumns(db: SQLiteDatabase, tableName: String) {
        try {
            val columns = mutableSetOf<String>()
            db.rawQuery("PRAGMA table_info($tableName)", null).use { cursor ->
                val nameIdx = cursor.getColumnIndex("name")
                while (cursor.moveToNext()) {
                    if (nameIdx >= 0) columns.add(cursor.getString(nameIdx).lowercase())
                }
            }
            if (!columns.contains("mudhan_mozhi")) {
                db.execSQL("ALTER TABLE $tableName ADD COLUMN mudhan_mozhi TEXT DEFAULT 'ta'")
            }
            if (!columns.contains("thunai_mozhi")) {
                db.execSQL("ALTER TABLE $tableName ADD COLUMN thunai_mozhi TEXT DEFAULT 'en'")
            }
            if (!columns.contains("iru_mozhi")) {
                db.execSQL("ALTER TABLE $tableName ADD COLUMN iru_mozhi INTEGER DEFAULT 1")
            }
            if (!columns.contains("gst_pirippugal")) {
                db.execSQL("ALTER TABLE $tableName ADD COLUMN gst_pirippugal INTEGER DEFAULT 0")
            }
            if (!columns.contains("thoatra_niram")) {
                db.execSQL("ALTER TABLE $tableName ADD COLUMN thoatra_niram TEXT DEFAULT '#388e3c'")
            }
        } catch (e: Exception) {
            Log.w(tag, "ensureColumns failed on $tableName: ${e.message}")
        }
    }

    override fun saveProfile(mode: AppMode, profile: NiruvanaTharavugal): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return false

        var db: SQLiteDatabase? = null
        try {
            db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            ensureColumns(db, tableName)

            val values = ContentValues().apply {
                put("niruvanathin_peyar", MozhiJsonConverter.stringify(profile.niruvanathinPeyar))
                put("kurum_peyar", profile.kurumPeyar)
                put("tholaipaesi1", profile.tholaipaesi1)
                put("tholaipaesi2", profile.tholaipaesi2)
                put("minnanjal", profile.minnanjal)
                put("gstin", profile.gstin)
                put("mugavari", MozhiJsonConverter.stringify(profile.mugavari))
                put("oor", MozhiJsonConverter.stringify(profile.oor))
                put("maavattam", MozhiJsonConverter.stringify(profile.maavattam))
                put("maanilam", MozhiJsonConverter.stringify(profile.maanilam))
                put("naadu", MozhiJsonConverter.stringify(profile.naadu))
                put("anjal_kuriyeedu", profile.anjalKuriyeedu)
                put("vangi_peyar", MozhiJsonConverter.stringify(profile.vangiPeyar))
                put("kilai", MozhiJsonConverter.stringify(profile.kilai))
                put("vangi_kanakku", profile.vangiKanakku)
                put("ifsc", profile.ifsc)
                put("oavuru", profile.oavuru)
                put("agala_oavuru", profile.agalaOavuru)
                put("thalaippu_vadivu", profile.thalaippuVadivu)
                put("kaiyoppam", profile.kaiyoppam)
                put("oppam_peyar", profile.oppamPeyar)
                put("adaimozhi", MozhiJsonConverter.stringify(profile.adaimozhi))
                put("upi_id", profile.upiId)
                put("thoatra_niram", profile.thoatraNiram)
                put("updated_at", System.currentTimeMillis() / 1000)

                if (mode == AppMode.PATTU) {
                    put("mudhan_mozhi", profile.mudhanMozhi)
                    put("thunai_mozhi", profile.thunaiMozhi)
                    put("iru_mozhi", if (profile.iruMozhi) 1 else 0)
                    put("gst_pirippugal", if (profile.gstPirippugal) 1 else 0)
                }
            }

            var rowsAffected = if (profile.id != null && profile.id!! > 0L) {
                db.update(tableName, values, "id = ?", arrayOf(profile.id.toString()))
            } else 0

            if (rowsAffected == 0) {
                values.put("is_deleted", 0)
                val newId = db.insert(tableName, null, values)
                if (newId > 0) {
                    profile.id = newId
                    rowsAffected = 1
                }
            }

            return rowsAffected > 0
        } catch (e: Exception) {
            Log.e(tag, "Error saving profile to $tableName: ${e.message}", e)
            return false
        } finally {
            db?.close()
        }
    }

    override fun deleteProfile(mode: AppMode, profileId: Long): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return false

        var db: SQLiteDatabase? = null
        try {
            db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            val values = ContentValues().apply {
                put("is_deleted", 1)
                put("updated_at", System.currentTimeMillis() / 1000)
            }
            val rows = db.update(tableName, values, "id = ?", arrayOf(profileId.toString()))
            return rows > 0
        } catch (e: Exception) {
            Log.e(tag, "Error deleting profile $profileId from $tableName: ${e.message}", e)
            return false
        } finally {
            db?.close()
        }
    }

    override fun clearProfiles(mode: AppMode): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val dbFile = resolveActiveDatabase(dbName) ?: return false

        var db: SQLiteDatabase? = null
        return try {
            db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
            db.delete(tableName, null, null)
            true
        } catch (e: Exception) {
            Log.e(tag, "Error clearing profiles for $mode: ${e.message}", e)
            false
        } finally {
            db?.close()
        }
    }

    private fun cursorToProfile(cursor: Cursor, mode: AppMode): NiruvanaTharavugal {
        fun getString(col: String): String {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getString(idx) else ""
        }
        fun getLong(col: String): Long? {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getLong(idx) else null
        }
        fun getInt(col: String, defaultVal: Int): Int {
            val idx = cursor.getColumnIndex(col)
            return if (idx >= 0 && !cursor.isNull(idx)) cursor.getInt(idx) else defaultVal
        }

        val isPattu = mode == AppMode.PATTU
        val mudhan = if (isPattu) getString("mudhan_mozhi").ifEmpty { "ta" } else "ta"
        val thunai = if (isPattu) getString("thunai_mozhi").ifEmpty { "en" } else "en"
        val iru = if (isPattu) getInt("iru_mozhi", 1) == 1 else true
        val gstPirippugal = if (isPattu) getInt("gst_pirippugal", 0) == 1 else false

        return NiruvanaTharavugal(
            id = getLong("id"),
            mudhanMozhi = mudhan,
            thunaiMozhi = thunai,
            iruMozhi = iru,
            gstPirippugal = gstPirippugal,
            niruvanathinPeyar = MozhiJsonConverter.parse(getString("niruvanathin_peyar")),
            kurumPeyar = getString("kurum_peyar"),
            tholaipaesi1 = getString("tholaipaesi1"),
            tholaipaesi2 = getString("tholaipaesi2"),
            minnanjal = getString("minnanjal"),
            gstin = getString("gstin"),
            mugavari = MozhiJsonConverter.parse(getString("mugavari")),
            oor = MozhiJsonConverter.parse(getString("oor")),
            maavattam = MozhiJsonConverter.parse(getString("maavattam")),
            maanilam = MozhiJsonConverter.parse(getString("maanilam")),
            naadu = MozhiJsonConverter.parse(getString("naadu")).ifEmpty { mutableMapOf("en" to "India", "ta" to "இந்தியா") },
            anjalKuriyeedu = getString("anjal_kuriyeedu"),
            vangiPeyar = MozhiJsonConverter.parse(getString("vangi_peyar")),
            kilai = MozhiJsonConverter.parse(getString("kilai")),
            vangiKanakku = getString("vangi_kanakku"),
            ifsc = getString("ifsc"),
            oavuru = getString("oavuru"),
            agalaOavuru = getString("agala_oavuru"),
            thalaippuVadivu = getString("thalaippu_vadivu").ifEmpty { "small" },
            kaiyoppam = getString("kaiyoppam"),
            oppamPeyar = getString("oppam_peyar"),
            adaimozhi = MozhiJsonConverter.parse(getString("adaimozhi")),
            upiId = getString("upi_id"),
            thoatraNiram = getString("thoatra_niram").ifEmpty { if (isPattu) "#6a1b9a" else "#388e3c" }
        )
    }
}

private val androidHelperInstance by lazy { AndroidSettingsDatabaseHelper() }

actual fun getSettingsDatabaseHelper(): SettingsDatabaseHelper = androidHelperInstance
