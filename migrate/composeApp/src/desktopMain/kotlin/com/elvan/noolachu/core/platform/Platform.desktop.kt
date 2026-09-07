package com.elvan.noolachu.core.platform

actual val currentPlatform: PlatformType = PlatformType.DESKTOP

@androidx.compose.runtime.Composable
actual fun ConfigureDialogWindow(isDark: Boolean) {
    // No-op on desktop
}
