package com.elvan.udukkai.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import com.elvan.udukkai.core.mode.AppMode
import com.elvan.udukkai.core.mode.LocalAppMode

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
    val iconInactive: Color,
    // Mode-aware design system tokens
    val accentBright: Color = accent,
    val accentDark: Color = accent,
    val accentContainer: Color = accent.copy(alpha = 0.15f),
    val secondaryAccent: Color = accent,
    val iconAccent: Color = accent,
    val error: Color = if (isDark) Color(0xFFFFB4AB) else Color(0xFFBA1A1A)
)

val LocalShellColors = staticCompositionLocalOf<ShellColors> {
    error("No ShellColors provided")
}

@Composable
fun rememberShellColors(mode: AppMode = LocalAppMode.current): ShellColors {
    val isDark = ThemeManager.isDark()
    return remember(isDark, mode) {
        val isCoolie = mode == AppMode.KOOLI

        if (isDark) {
            val accent = if (isCoolie) Color(0xFF087F8C) else Color(0xFF6B3F68)
            val accentBright = if (isCoolie) Color(0xFF4DD0DC) else Color(0xFFCE85CA)
            val accentDark = if (isCoolie) Color(0xFF066A75) else Color(0xFF522B4F)
            val accentContainer = if (isCoolie) Color(0xFF123C40) else Color(0xFF3D1B3B)
            val secondaryAccent = if (isCoolie) Color(0xFF6B3F68) else Color(0xFF087F8C)
            val iconAccent = accentBright

            ShellColors(
                isDark = true,
                background = Color.Black,
                surface = Color(0xFF111111),
                accent = accent,
                textPrimary = Color.White,
                textSecondary = Color.White.copy(alpha = 0.54f),
                textTertiary = Color.White.copy(alpha = 0.38f),
                textQuaternary = Color.White.copy(alpha = 0.24f),
                border = Color(0xFF555555),
                glassBorder = Color(0x1AFFFFFF),
                pillBackground = Color(0xFF1E1E1E),
                pillBorder = Color(0xFF333333),
                ripple = Color.White.copy(alpha = 0.16f),
                floatingBg = Color(0xFF1E1E1E),
                floatingBorder = Color(0xFF333333),
                iconBg = Color.White.copy(alpha = 0.08f),
                divider = Color.White.copy(alpha = 0.04f),
                icon = Color.White,
                iconInactive = Color.White.copy(alpha = 0.45f),
                accentBright = accentBright,
                accentDark = accentDark,
                accentContainer = accentContainer,
                secondaryAccent = secondaryAccent,
                iconAccent = iconAccent,
                error = Color(0xFFFFB4AB)
            )
        } else {
            val accent = if (isCoolie) Color(0xFF087F8C) else Color(0xFF6B3F68)
            val accentBright = if (isCoolie) Color(0xFF4DD0DC) else Color(0xFFCE85CA)
            val accentDark = if (isCoolie) Color(0xFF066A75) else Color(0xFF522B4F)
            val accentContainer = if (isCoolie) Color(0xFFD5F3F5) else Color(0xFFF5E8F4)
            val secondaryAccent = if (isCoolie) Color(0xFF6B3F68) else Color(0xFF087F8C)
            val iconAccent = accent

            ShellColors(
                isDark = false,
                background = Color(0xFFF5F5F7),
                surface = Color.White,
                accent = accent,
                textPrimary = Color.Black,
                textSecondary = Color.Black.copy(alpha = 0.54f),
                textTertiary = Color.Black.copy(alpha = 0.38f),
                textQuaternary = Color.Black.copy(alpha = 0.26f),
                border = Color(0xFFAAAAAA),
                glassBorder = Color(0x14000000),
                pillBackground = Color.White,
                pillBorder = Color(0xFFE5E5E7),
                ripple = Color.Black.copy(alpha = 0.08f),
                floatingBg = Color.White,
                floatingBorder = Color.White,
                iconBg = Color.Black.copy(alpha = 0.06f),
                divider = Color.Black.copy(alpha = 0.04f),
                icon = Color.Black,
                iconInactive = Color.Black.copy(alpha = 0.45f),
                accentBright = accentBright,
                accentDark = accentDark,
                accentContainer = accentContainer,
                secondaryAccent = secondaryAccent,
                iconAccent = iconAccent,
                error = Color(0xFFBA1A1A)
            )
        }
    }
}
