package com.elvan.noolachu.data.settings

import com.elvan.noolachu.core.mode.AppMode
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.sql.Connection
import java.sql.DriverManager
import java.sql.ResultSet

class DesktopSettingsDatabaseHelper : SettingsDatabaseHelper {

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

    private fun resolveActiveDatabase(dbName: String): File? {
        val candidates = getCandidatePaths(dbName)
        for (candidate in candidates) {
            if (candidate.exists() && candidate.length() > 0) {
                return candidate
            }
        }
        return null
    }

    private fun getConnection(file: File): Connection {
        Class.forName("org.sqlite.JDBC")
        return DriverManager.getConnection("jdbc:sqlite:${file.absolutePath}")
    }

    override fun scanAndSync(): DatabaseScanReport {
        val coolie = resolveActiveDatabase(coolieDbName)
        val silk = resolveActiveDatabase(silkDbName)
        return DatabaseScanReport(
            isCoolieFound = coolie != null && coolie.exists(),
            cooliePath = coolie?.absolutePath,
            isSilkFound = silk != null && silk.exists(),
            silkPath = silk?.absolutePath,
            message = "Desktop Coolie: ${coolie?.absolutePath ?: "Not found"}, Silk: ${silk?.absolutePath ?: "Not found"}"
        )
    }

    override fun loadProfile(mode: AppMode, profileId: Long?): NiruvanaTharavugal? {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val file = resolveActiveDatabase(dbName) ?: return null

        try {
            getConnection(file).use { conn ->
                val sql = if (profileId != null) {
                    "SELECT * FROM $tableName WHERE id = ? AND is_deleted = 0 LIMIT 1"
                } else {
                    "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY id ASC LIMIT 1"
                }
                conn.prepareStatement(sql).use { stmt ->
                    if (profileId != null) {
                        stmt.setLong(1, profileId)
                    }
                    stmt.executeQuery().use { rs ->
                        if (rs.next()) {
                            return rsToProfile(rs, mode)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Desktop error loading profile from $tableName: ${e.message}")
        }
        return null
    }

    override fun loadAllProfiles(mode: AppMode): List<NiruvanaTharavugal> {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val file = resolveActiveDatabase(dbName) ?: return emptyList()

        val list = mutableListOf<NiruvanaTharavugal>()
        try {
            getConnection(file).use { conn ->
                val sql = "SELECT * FROM $tableName WHERE is_deleted = 0 ORDER BY id ASC"
                conn.createStatement().use { stmt ->
                    stmt.executeQuery(sql).use { rs ->
                        while (rs.next()) {
                            list.add(rsToProfile(rs, mode))
                        }
                    }
                }
            }
        } catch (e: Exception) {
            println("Desktop error loading all profiles from $tableName: ${e.message}")
        }
        return list
    }

    override fun saveProfile(mode: AppMode, profile: NiruvanaTharavugal): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val file = resolveActiveDatabase(dbName) ?: return false

        try {
            getConnection(file).use { conn ->
                val isPattu = mode == AppMode.PATTU
                val isUpdate = profile.id != null

                val sql = if (isUpdate) {
                    if (isPattu) {
                        """
                        UPDATE $tableName SET
                            mudhan_mozhi = ?, thunai_mozhi = ?, iru_mozhi = ?, gst_pirippugal = ?,
                            niruvanathin_peyar = ?, kurum_peyar = ?, tholaipaesi1 = ?, tholaipaesi2 = ?,
                            minnanjal = ?, gstin = ?, mugavari = ?, oor = ?, maavattam = ?, maanilam = ?,
                            naadu = ?, anjal_kuriyeedu = ?, vangi_peyar = ?, kilai = ?, vangi_kanakku = ?,
                            ifsc = ?, oavuru = ?, agala_oavuru = ?, thalaippu_vadivu = ?, kaiyoppam = ?,
                            oppam_peyar = ?, adaimozhi = ?, upi_id = ?, thoatra_niram = ?, updated_at = ?
                        WHERE id = ?
                        """.trimIndent()
                    } else {
                        """
                        UPDATE $tableName SET
                            niruvanathin_peyar = ?, kurum_peyar = ?, tholaipaesi1 = ?, tholaipaesi2 = ?,
                            minnanjal = ?, gstin = ?, mugavari = ?, oor = ?, maavattam = ?, maanilam = ?,
                            naadu = ?, anjal_kuriyeedu = ?, vangi_peyar = ?, kilai = ?, vangi_kanakku = ?,
                            ifsc = ?, oavuru = ?, agala_oavuru = ?, thalaippu_vadivu = ?, kaiyoppam = ?,
                            oppam_peyar = ?, adaimozhi = ?, upi_id = ?, thoatra_niram = ?, updated_at = ?
                        WHERE id = ?
                        """.trimIndent()
                    }
                } else {
                    if (isPattu) {
                        """
                        INSERT INTO $tableName (
                            mudhan_mozhi, thunai_mozhi, iru_mozhi, gst_pirippugal,
                            niruvanathin_peyar, kurum_peyar, tholaipaesi1, tholaipaesi2,
                            minnanjal, gstin, mugavari, oor, maavattam, maanilam,
                            naadu, anjal_kuriyeedu, vangi_peyar, kilai, vangi_kanakku,
                            ifsc, oavuru, agala_oavuru, thalaippu_vadivu, kaiyoppam,
                            oppam_peyar, adaimozhi, upi_id, thoatra_niram, updated_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """.trimIndent()
                    } else {
                        """
                        INSERT INTO $tableName (
                            niruvanathin_peyar, kurum_peyar, tholaipaesi1, tholaipaesi2,
                            minnanjal, gstin, mugavari, oor, maavattam, maanilam,
                            naadu, anjal_kuriyeedu, vangi_peyar, kilai, vangi_kanakku,
                            ifsc, oavuru, agala_oavuru, thalaippu_vadivu, kaiyoppam,
                            oppam_peyar, adaimozhi, upi_id, thoatra_niram, updated_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """.trimIndent()
                    }
                }

                conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS).use { stmt ->
                    var idx = 1
                    if (isPattu) {
                        stmt.setString(idx++, profile.mudhanMozhi)
                        stmt.setString(idx++, profile.thunaiMozhi)
                        stmt.setInt(idx++, if (profile.iruMozhi) 1 else 0)
                        stmt.setInt(idx++, if (profile.gstPirippugal) 1 else 0)
                    }
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.niruvanathinPeyar))
                    stmt.setString(idx++, profile.kurumPeyar)
                    stmt.setString(idx++, profile.tholaipaesi1)
                    stmt.setString(idx++, profile.tholaipaesi2)
                    stmt.setString(idx++, profile.minnanjal)
                    stmt.setString(idx++, profile.gstin)
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.mugavari))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.oor))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.maavattam))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.maanilam))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.naadu))
                    stmt.setString(idx++, profile.anjalKuriyeedu)
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.vangiPeyar))
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.kilai))
                    stmt.setString(idx++, profile.vangiKanakku)
                    stmt.setString(idx++, profile.ifsc)
                    stmt.setString(idx++, profile.oavuru)
                    stmt.setString(idx++, profile.agalaOavuru)
                    stmt.setString(idx++, profile.thalaippuVadivu)
                    stmt.setString(idx++, profile.kaiyoppam)
                    stmt.setString(idx++, profile.oppamPeyar)
                    stmt.setString(idx++, MozhiJsonConverter.stringify(profile.adaimozhi))
                    stmt.setString(idx++, profile.upiId)
                    stmt.setString(idx++, profile.thoatraNiram)
                    stmt.setLong(idx++, System.currentTimeMillis() / 1000)

                    if (isUpdate) {
                        stmt.setLong(idx++, profile.id ?: 1L)
                    }

                    val affected = stmt.executeUpdate()
                    if (!isUpdate && affected > 0) {
                        stmt.generatedKeys.use { gks ->
                            if (gks.next()) {
                                profile.id = gks.getLong(1)
                            }
                        }
                    }
                    return affected > 0
                }
            }
        } catch (e: Exception) {
            println("Desktop error saving profile to $tableName: ${e.message}")
            return false
        }
    }

    override fun deleteProfile(mode: AppMode, profileId: Long): Boolean {
        val dbName = if (mode == AppMode.KOOLI) coolieDbName else silkDbName
        val tableName = if (mode == AppMode.KOOLI) "kooli_niruvana_tharavugal_table" else "pattu_niruvana_tharavugal_table"
        val file = resolveActiveDatabase(dbName) ?: return false

        try {
            getConnection(file).use { conn ->
                val sql = "UPDATE $tableName SET is_deleted = 1, updated_at = ? WHERE id = ?"
                conn.prepareStatement(sql).use { stmt ->
                    stmt.setLong(1, System.currentTimeMillis() / 1000)
                    stmt.setLong(2, profileId)
                    val updated = stmt.executeUpdate()
                    return updated > 0
                }
            }
        } catch (e: Exception) {
            println("Desktop error deleting profile $profileId from $tableName: ${e.message}")
            return false
        }
    }

    private fun rsToProfile(rs: ResultSet, mode: AppMode): NiruvanaTharavugal {
        fun getString(col: String): String {
            return try { rs.getString(col) ?: "" } catch (_: Exception) { "" }
        }
        fun getLong(col: String): Long? {
            return try { val v = rs.getLong(col); if (rs.wasNull()) null else v } catch (_: Exception) { null }
        }
        fun getInt(col: String, defaultVal: Int): Int {
            return try { val v = rs.getInt(col); if (rs.wasNull()) defaultVal else v } catch (_: Exception) { defaultVal }
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

private val desktopHelperInstance by lazy { DesktopSettingsDatabaseHelper() }

actual fun getSettingsDatabaseHelper(): SettingsDatabaseHelper = desktopHelperInstance
