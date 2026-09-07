package com.elvan.noolachu.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

enum class ThemeMode {
    SYSTEM,
    LIGHT,
    DARK
}

object ThemeManager {
    var currentThemeMode by mutableStateOf(ThemeMode.SYSTEM)
        private set

    fun setThemeMode(mode: ThemeMode) {
        currentThemeMode = mode
    }

    fun toggleTheme(isSystemDark: Boolean = false) {
        currentThemeMode = when (currentThemeMode) {
            ThemeMode.LIGHT -> ThemeMode.DARK
            ThemeMode.DARK -> ThemeMode.LIGHT
            ThemeMode.SYSTEM -> if (isSystemDark) ThemeMode.LIGHT else ThemeMode.DARK
        }
    }

    @Composable
    fun isDark(): Boolean = when (currentThemeMode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
}
