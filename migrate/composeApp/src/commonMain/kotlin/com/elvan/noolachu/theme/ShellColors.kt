package com.elvan.noolachu.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Color

@Immutable
data class ShellColors(
    val isDark: Boolean,
    val background: Color,
    val surface: Color,
    val accent: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val border: Color,
    val glassBorder: Color,
    val pillBackground: Color,
    val pillBorder: Color,
    // Centralized tokens (eliminate duplication)
    val ripple: Color,
    val floatingBg: Color,
    val floatingBorder: Color,
    val iconBg: Color,
    val divider: Color,
)

@Composable
fun rememberShellColors(): ShellColors {
    val isDark = ThemeManager.isDark()
    return remember(isDark) {
        if (isDark) {
            ShellColors(
                isDark = true,
                background = Color.Black,
                surface = Color(0xFF111111),
                accent = Color.White,
                textPrimary = Color.White,
                textSecondary = Color(0xFF9CA3AF),
                border = Color(0x1AFFFFFF),
                glassBorder = Color(0x1AFFFFFF),
                pillBackground = Color(0xFF1E1E1E),
                pillBorder = Color(0xFF333333),
                ripple = Color.White.copy(alpha = 0.16f),
                floatingBg = Color(0xFF1E1E1E),
                floatingBorder = Color(0xFF333333),
                iconBg = Color.White.copy(alpha = 0.08f),
                divider = Color.White.copy(alpha = 0.04f),
            )
        } else {
            ShellColors(
                isDark = false,
                background = Color(0xFFF5F5F7),
                surface = Color.White,
                accent = Color(0xFF1D1D1F),
                textPrimary = Color(0xFF1D1D1F),
                textSecondary = Color(0xFF6B7280),
                border = Color(0x14000000),
                glassBorder = Color(0x14000000),
                pillBackground = Color.White,
                pillBorder = Color.White,
                ripple = Color.Black.copy(alpha = 0.08f),
                floatingBg = Color.White,
                floatingBorder = Color.White,
                iconBg = Color.Black.copy(alpha = 0.06f),
                divider = Color.Black.copy(alpha = 0.04f),
            )
        }
    }
}
