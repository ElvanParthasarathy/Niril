package com.elvan.noolachu.core.mode

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

/**
 * Manages the current operating mode (Kooli vs Pattu).
 *
 * THE WALL:
 * - Each mode gets its own database file (noolachu_kooli.db / noolachu_pattu.db)
 * - Each mode gets its own preferences namespace
 * - Each mode gets its own file storage directory
 * - Switching modes = switching to a completely different data universe
 *
 * Usage:
 *   ModeManager.setMode(AppMode.KOOLI)
 *   val db = ModeManager.currentDatabaseName  // "noolachu_kooli.db"
 *   val prefsKey = ModeManager.prefsNamespace  // "noolachu_kooli_"
 */
object ModeManager {

    var currentMode by mutableStateOf(AppMode.KOOLI)
        private set

    /** Database file name for the current mode */
    val currentDatabaseName: String
        get() = currentMode.databaseName

    /** Preferences namespace prefix for the current mode */
    val prefsNamespace: String
        get() = "noolachu_${currentMode.key}_"

    /** Storage directory name for the current mode */
    val storageDir: String
        get() = "noolachu_${currentMode.key}"

    /**
     * Switch the app to a different mode.
     * This will cause the entire UI to re-compose with the new mode's data.
     */
    fun setMode(mode: AppMode) {
        currentMode = mode
    }

    fun toggleMode() {
        currentMode = if (currentMode == AppMode.KOOLI) AppMode.PATTU else AppMode.KOOLI
    }

    /** Check if we are in Kooli mode */
    val isKooli: Boolean get() = currentMode == AppMode.KOOLI

    /** Check if we are in Pattu mode */
    val isPattu: Boolean get() = currentMode == AppMode.PATTU
}
