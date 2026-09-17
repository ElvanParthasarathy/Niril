package com.elvan.udukkai.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
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
    val textTertiary: Color,
    val textQuaternary: Color,
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
    val icon: Color,
    val iconInactive: Color
)

val LocalShellColors = staticCompositionLocalOf<ShellColors> {
    error("No ShellColors provided")
}

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
                textSecondary = Color.White.copy(alpha = 0.54f),
                textTertiary = Color.White.copy(alpha = 0.38f),
                textQuaternary = Color.White.copy(alpha = 0.24f),
                border = Color(0xFF555555), // Updated to match hardcoded 0xFF555555
                glassBorder = Color(0x1AFFFFFF),
                pillBackground = Color(0xFF1E1E1E),
                pillBorder = Color(0xFF333333),
                ripple = Color.White.copy(alpha = 0.16f),
                floatingBg = Color(0xFF1E1E1E),
                floatingBorder = Color(0xFF333333),
                iconBg = Color.White.copy(alpha = 0.08f),
                divider = Color.White.copy(alpha = 0.04f),
                icon = Color.White,
                iconInactive = Color.White.copy(alpha = 0.45f)
            )
        } else {
            ShellColors(
                isDark = false,
                background = Color(0xFFF5F5F7),
                surface = Color.White,
                accent = Color(0xFF1D1D1F),
                textPrimary = Color.Black,
                textSecondary = Color.Black.copy(alpha = 0.54f),
                textTertiary = Color.Black.copy(alpha = 0.38f),
                textQuaternary = Color.Black.copy(alpha = 0.26f),
                border = Color(0xFFAAAAAA), // Updated to match hardcoded 0xFFAAAAAA
                glassBorder = Color(0x14000000),
                pillBackground = Color.White,
                pillBorder = Color.White,
                ripple = Color.Black.copy(alpha = 0.08f),
                floatingBg = Color.White,
                floatingBorder = Color.White,
                iconBg = Color.Black.copy(alpha = 0.06f),
                divider = Color.Black.copy(alpha = 0.04f),
                icon = Color.Black,
                iconInactive = Color.Black.copy(alpha = 0.45f)
            )
        }
    }
}
