package com.elvan.udukkai.core.platform

enum class PlatformType { ANDROID, DESKTOP }

expect val currentPlatform: PlatformType

@androidx.compose.runtime.Composable
expect fun ConfigureDialogWindow(isDark: Boolean)
