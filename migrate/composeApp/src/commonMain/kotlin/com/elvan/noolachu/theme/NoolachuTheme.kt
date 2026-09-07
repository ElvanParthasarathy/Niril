package com.elvan.noolachu.theme

import androidx.compose.foundation.LocalIndication
import androidx.compose.material.ripple.LocalRippleTheme
import androidx.compose.material.ripple.RippleAlpha
import androidx.compose.material.ripple.RippleTheme
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density

private val LightColorScheme = lightColorScheme(
    primary = PrimaryLight,
    onPrimary = OnPrimaryLight,
    primaryContainer = PrimaryContainerLight,
    onPrimaryContainer = OnPrimaryContainerLight,
    background = BackgroundLight,
    onBackground = OnBackgroundLight,
    surface = SurfaceLight,
    onSurface = OnSurfaceLight,
    surfaceVariant = Color(0xFFF0F0F0),
    onSurfaceVariant = Color(0xFF49454F),
    error = ErrorLight
)

private val DarkColorScheme = darkColorScheme(
    primary = PrimaryDark,
    onPrimary = OnPrimaryDark,
    primaryContainer = PrimaryContainerDark,
    onPrimaryContainer = OnPrimaryContainerDark,
    background = Color.Black,
    onBackground = Color.White,
    surface = Color.Black,
    onSurface = Color.White,
    surfaceVariant = Color(0xFF1C1C1C),
    onSurfaceVariant = Color(0xFFE0E0E0),
    surfaceContainer = Color.Black,
    surfaceContainerLow = Color.Black,
    surfaceContainerLowest = Color.Black,
    surfaceContainerHigh = Color(0xFF1C1C1C),
    surfaceContainerHighest = Color(0xFF2C2C2C),
    error = ErrorDark
)

@Immutable
private class NoolachuRippleTheme(
    private val isDark: Boolean
) : RippleTheme {
    @Composable
    override fun defaultColor(): Color =
        if (isDark) Color.White else Color.Black

    @Composable
    override fun rippleAlpha(): RippleAlpha =
        if (isDark) {
            RippleAlpha(
                draggedAlpha = 0.20f,
                focusedAlpha = 0.16f,
                hoveredAlpha = 0.10f,
                pressedAlpha = 0.16f
            )
        } else {
            RippleTheme.defaultRippleAlpha(
                Color.Black,
                lightTheme = true
            )
        }
}

@Composable
fun NoolachuTheme(
    darkTheme: Boolean = ThemeManager.isDark(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val rippleColor = if (darkTheme) Color.White else Color.Black

    val currentDensity = LocalDensity.current
    val density = if (currentDensity.fontScale > 1.0f) {
        Density(currentDensity.density, fontScale = 1.0f)
    } else {
        currentDensity
    }

    CompositionLocalProvider(
        LocalDensity provides density
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = NoolachuTypography,
            shapes = NoolachuShapes
        ) {
            CompositionLocalProvider(
                LocalRippleTheme provides NoolachuRippleTheme(isDark = darkTheme),
                LocalIndication provides rememberRipple(
                    bounded = true,
                    color = rippleColor
                )
            ) {
                content()
            }
        }
    }
}
