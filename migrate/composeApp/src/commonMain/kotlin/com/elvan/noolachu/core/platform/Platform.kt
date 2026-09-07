package com.elvan.noolachu.core.platform

enum class PlatformType { ANDROID, DESKTOP }

expect val currentPlatform: PlatformType

@androidx.compose.runtime.Composable
expect fun ConfigureDialogWindow(isDark: Boolean)
