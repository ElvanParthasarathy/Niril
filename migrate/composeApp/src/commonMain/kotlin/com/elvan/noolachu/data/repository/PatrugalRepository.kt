package com.elvan.noolachu.data.repository

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.data.business.getBusinessDatabaseHelper
import com.elvan.noolachu.data.model.PatrugalTharavuru

/**
 * Reactive repository managing payment receipts (Patrugal) for both Coolie and Silk modes.
 */
object PatrugalRepository {

    var receipts by mutableStateOf<List<PatrugalTharavuru>>(emptyList())
        private set

    var searchQuery by mutableStateOf("")

    val filteredReceipts: List<PatrugalTharavuru>
        get() {
            val q = searchQuery.trim().lowercase()
            if (q.isEmpty()) return receipts

            return receipts.filter { receipt ->
                val enMatches = receipt.patruEn.lowercase().contains(q)
                val peyarMatches = receipt.vaangunarPeyar.values.any { it.lowercase().contains(q) }
                val muraiMatches = receipt.seluthumMurai.lowercase().contains(q)
                val vangiMatches = receipt.vangiPeyar?.lowercase()?.contains(q) == true
                enMatches || peyarMatches || muraiMatches || vangiMatches
            }
        }

    val overallTotal: Double
        get() = receipts.sumOf { it.thogai }

    init {
        loadAll()
    }

    fun loadAll(mode: AppMode = ModeManager.currentMode) {
        try {
            val helper = getBusinessDatabaseHelper()
            receipts = helper.loadAllReceipts(mode)
        } catch (_: Exception) {
            receipts = emptyList()
        }
    }

    fun save(receipt: PatrugalTharavuru, mode: AppMode = ModeManager.currentMode): Long {
        return try {
            val helper = getBusinessDatabaseHelper()
            val id = helper.saveReceipt(mode, receipt)
            if (id > 0L) {
                loadAll(mode)
            }
            id
        } catch (_: Exception) {
            -1L
        }
    }

    fun delete(id: Long, mode: AppMode = ModeManager.currentMode): Boolean {
        return try {
            val helper = getBusinessDatabaseHelper()
            val success = helper.deleteReceipt(mode, id)
            if (success) {
                loadAll(mode)
            }
            success
        } catch (_: Exception) {
            false
        }
    }

    fun getById(id: Long): PatrugalTharavuru? {
        return receipts.find { it.id == id }
    }
}
