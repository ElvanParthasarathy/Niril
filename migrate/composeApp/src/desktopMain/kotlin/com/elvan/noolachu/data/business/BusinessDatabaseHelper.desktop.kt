package com.elvan.noolachu.data.business

import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.settings.MozhiJsonConverter
import java.io.File
import java.sql.Connection
import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.Statement
import java.sql.Types

class DesktopBusinessDatabaseHelper : BusinessDatabaseHelper {

    private val coolieDbName = "elvan_niril_coolie.db"
    private val silkDbName = "elvan_niril_silk.db"

    private fun getCandidatePaths(dbName: String): List<File> {
        val list = mutableListOf<File>()
        list.add(File(dbName))
        list.add(File("scratch", dbName))
        list.add(File("databases", dbName))
        list.add(File("d:/Things/Padaippugal/Nadappil/Elvan Niril/scratch", dbName))
        list.add(File("C:/Users/Elvan/.gemini/antigravity/brain/f1302e69-9da7-4bd7-8cc2-64c24935afae/scratch", dbName))

        val userHome = System.getProperty("user.home")
        if (userHome != null) {
            list.add(File(userHome, "Documents/$dbName"))
            list.add(File(userHome, "AppData/Roaming/Elvan Niril/$dbName"))
            list.add(File(userHome, "AppData/Local/Elvan Niril/$dbName"))
        }
        return list
    }

    private fun resolveActiveDatabase(dbName: String): File {
        val candidates = getCandidatePaths(dbName)
        for (candidate in candidates) {
            if (candidate.exists() && candidate.length() > 0) {
                return candidate
            }
        }
        return File(dbName)
    }

    private fun getConnection(file: File): Connection {
        Class.forName("org.sqlite.JDBC")
        file.parentFile?.mkdirs()
        return DriverManager.getConnection("jdbc:sqlite:${file.absolutePath}")
    }

    private fun ensureTables(conn: Connection, mode: AppMode) {
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

        conn.createStatement().use { stmt ->
            stmt.execute(createVaangunarSql)
            stmt.execute(createPorulSql)
        }
    }

    override fun loadAllMerchants(mode: AppMode): List<VaangunarTharavuru> {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val file = resolveActiveDatabase(dbName)

        val list = mutableListOf<VaangunarTharavuru>()
        try {
            getConnection(file).use { conn ->
                ensureTables(conn, mode)
                val sql = "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY updated_at DESC, id DESC"
                conn.createStatement().use { stmt ->
                    stmt.executeQuery(sql).use { rs ->
                        while (rs.next()) {
                            list.add(rsToMerchant(rs))
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Desktop error loading merchants from $tableName: ${e.message}")
        }
        return list
    }

    override fun saveMerchant(mode: AppMode, merchant: VaangunarTharavuru): Long {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val file = resolveActiveDatabase(dbName)

        try {
            getConnection(file).use { conn ->
                ensureTables(conn, mode)
                val nowSec = System.currentTimeMillis() / 1000
                val isUpdate = merchant.id > 0L

                val sql = if (isUpdate) {
                    """
                    UPDATE $tableName SET
                        peyar = ?, mugavari = ?, oor = ?, maavattam = ?, maanilam = ?, naadu = ?,
                        velinaad_mugavari = ?, anjal_kuriyeedu = ?, gstin = ?, minnanjal = ?, tholaipaesi = ?,
                        updated_at = ?, is_deleted = ?, deleted_at = ?
                    WHERE id = ?
                    """.trimIndent()
                } else {
                    """
                    INSERT INTO $tableName (
                        peyar, mugavari, oor, maavattam, maanilam, naadu,
                        velinaad_mugavari, anjal_kuriyeedu, gstin, minnanjal, tholaipaesi,
                        created_at, updated_at, is_deleted, deleted_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """.trimIndent()
                }

                conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS).use { stmt ->
                    var idx = 1
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.peyar))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.mugavari))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.oor))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.maavattam))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.maanilam))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.naadu))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(merchant.velinaadMugavari))
                    stmt.setString(idx++, merchant.anjalKuriyeedu)
                    stmt.setString(idx++, merchant.gstin)
                    stmt.setString(idx++, merchant.minnanjal)
                    stmt.setString(idx++, merchant.tholaipaesi)

                    if (!isUpdate) {
                        val createdSec = if (merchant.createdAt > 10000000000L) merchant.createdAt / 1000 else if (merchant.createdAt > 0L) merchant.createdAt else nowSec
                        stmt.setLong(idx++, createdSec)
                    }

                    stmt.setLong(idx++, nowSec)
                    stmt.setInt(idx++, if (merchant.isDeleted) 1 else 0)

                    if (merchant.deletedAt != null) {
                        val delSec = if (merchant.deletedAt > 10000000000L) merchant.deletedAt / 1000 else merchant.deletedAt
                        stmt.setLong(idx++, delSec)
                    } else {
                        stmt.setNull(idx++, Types.INTEGER)
                    }

                    if (isUpdate) {
                        stmt.setLong(idx++, merchant.id)
                    }

                    val affected = stmt.executeUpdate()
                    if (isUpdate) {
                        return if (affected > 0) merchant.id else -1L
                    } else {
                        stmt.generatedKeys.use { gks ->
                            if (gks.next()) {
                                return gks.getLong(1)
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Desktop error saving merchant to $tableName: ${e.message}")
        }
        return -1L
    }

    override fun deleteMerchant(mode: AppMode, id: Long): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_vaangunar_table" else "pattu_vaangunar_table"
        val file = resolveActiveDatabase(dbName)

        try {
            getConnection(file).use { conn ->
                ensureTables(conn, mode)
                val sql = "UPDATE $tableName SET is_deleted = 1, deleted_at = ?, updated_at = ? WHERE id = ?"
                conn.prepareStatement(sql).use { stmt ->
                    val nowSec = System.currentTimeMillis() / 1000
                    stmt.setLong(1, nowSec)
                    stmt.setLong(2, nowSec)
                    stmt.setLong(3, id)
                    val updated = stmt.executeUpdate()
                    return updated > 0
                }
            }
        } catch (e: Exception) {
            println("Desktop error deleting merchant $id from $tableName: ${e.message}")
            return false
        }
    }

    override fun loadAllItems(mode: AppMode): List<PorulTharavuru> {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"
        val file = resolveActiveDatabase(dbName)

        val list = mutableListOf<PorulTharavuru>()
        try {
            getConnection(file).use { conn ->
                ensureTables(conn, mode)
                val sql = "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY updated_at DESC, id DESC"
                conn.createStatement().use { stmt ->
                    stmt.executeQuery(sql).use { rs ->
                        while (rs.next()) {
                            list.add(rsToItem(rs))
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Desktop error loading items from $tableName: ${e.message}")
        }
        return list
    }

    override fun saveItem(mode: AppMode, item: PorulTharavuru): Long {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"
        val file = resolveActiveDatabase(dbName)

        try {
            getConnection(file).use { conn ->
                ensureTables(conn, mode)
                val nowSec = System.currentTimeMillis() / 1000
                val isUpdate = item.id > 0L

                val sql = if (isUpdate) {
                    """
                    UPDATE $tableName SET
                        porul_peyar = ?, hsn_code = ?, vilai = ?, vari_veetham = ?, alavu_vagai = ?, alagu = ?,
                        updated_at = ?, is_deleted = ?, deleted_at = ?
                    WHERE id = ?
                    """.trimIndent()
                } else {
                    """
                    INSERT INTO $tableName (
                        porul_peyar, hsn_code, vilai, vari_veetham, alavu_vagai, alagu,
                        created_at, updated_at, is_deleted, deleted_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """.trimIndent()
                }

                conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS).use { stmt ->
                    var idx = 1
                    stmt.setString(idx++, MozhiJsonConverter.stringify(item.porulPeyar))
                    stmt.setString(idx++, item.hsnCode)
                    stmt.setDouble(idx++, item.vilai)
                    stmt.setDouble(idx++, item.variVeetham)
                    stmt.setString(idx++, item.alavuVagai)
                    stmt.setString(idx++, item.alagu)

                    if (!isUpdate) {
                        val createdSec = if (item.createdAt > 10000000000L) item.createdAt / 1000 else if (item.createdAt > 0L) item.createdAt else nowSec
                        stmt.setLong(idx++, createdSec)
                    }

                    stmt.setLong(idx++, nowSec)
                    stmt.setInt(idx++, if (item.isDeleted) 1 else 0)

                    if (item.deletedAt != null) {
                        val delSec = if (item.deletedAt > 10000000000L) item.deletedAt / 1000 else item.deletedAt
                        stmt.setLong(idx++, delSec)
                    } else {
                        stmt.setNull(idx++, Types.INTEGER)
                    }

                    if (isUpdate) {
                        stmt.setLong(idx++, item.id)
                    }

                    val affected = stmt.executeUpdate()
                    if (isUpdate) {
                        return if (affected > 0) item.id else -1L
                    } else {
                        stmt.generatedKeys.use { gks ->
                            if (gks.next()) {
                                return gks.getLong(1)
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Desktop error saving item to $tableName: ${e.message}")
        }
        return -1L
    }

    override fun deleteItem(mode: AppMode, id: Long): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_porul_table" else "pattu_porul_table"
        val file = resolveActiveDatabase(dbName)

        try {
            getConnection(file).use { conn ->
                ensureTables(conn, mode)
                val sql = "UPDATE $tableName SET is_deleted = 1, deleted_at = ?, updated_at = ? WHERE id = ?"
                conn.prepareStatement(sql).use { stmt ->
                    val nowSec = System.currentTimeMillis() / 1000
                    stmt.setLong(1, nowSec)
                    stmt.setLong(2, nowSec)
                    stmt.setLong(3, id)
                    val updated = stmt.executeUpdate()
                    return updated > 0
                }
            }
        } catch (e: Exception) {
            println("Desktop error deleting item $id from $tableName: ${e.message}")
            return false
        }
    }

    private fun rsToMerchant(rs: ResultSet): VaangunarTharavuru {
        fun getString(col: String): String {
            return try { rs.getString(col) ?: "" } catch (_: Exception) { "" }
        }
        fun getLong(col: String, defaultVal: Long = 0L): Long {
            return try { val v = rs.getLong(col); if (rs.wasNull()) defaultVal else v } catch (_: Exception) { defaultVal }
        }
        fun getNullableLong(col: String): Long? {
            return try { val v = rs.getLong(col); if (rs.wasNull()) null else v } catch (_: Exception) { null }
        }
        fun getInt(col: String, defaultVal: Int = 0): Int {
            return try { val v = rs.getInt(col); if (rs.wasNull()) defaultVal else v } catch (_: Exception) { defaultVal }
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

    private fun rsToItem(rs: ResultSet): PorulTharavuru {
        fun getString(col: String): String {
            return try { rs.getString(col) ?: "" } catch (_: Exception) { "" }
        }
        fun getLong(col: String, defaultVal: Long = 0L): Long {
            return try { val v = rs.getLong(col); if (rs.wasNull()) defaultVal else v } catch (_: Exception) { defaultVal }
        }
        fun getNullableLong(col: String): Long? {
            return try { val v = rs.getLong(col); if (rs.wasNull()) null else v } catch (_: Exception) { null }
        }
        fun getInt(col: String, defaultVal: Int = 0): Int {
            return try { val v = rs.getInt(col); if (rs.wasNull()) defaultVal else v } catch (_: Exception) { defaultVal }
        }
        fun getDouble(col: String, defaultVal: Double = 0.0): Double {
            return try { val v = rs.getDouble(col); if (rs.wasNull()) defaultVal else v } catch (_: Exception) { defaultVal }
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

private val desktopBusinessHelperInstance by lazy { DesktopBusinessDatabaseHelper() }

actual fun getBusinessDatabaseHelper(): BusinessDatabaseHelper = desktopBusinessHelperInstance
