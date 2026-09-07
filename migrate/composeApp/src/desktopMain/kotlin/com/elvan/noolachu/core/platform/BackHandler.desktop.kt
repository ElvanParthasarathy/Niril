package com.elvan.noolachu.core.platform

import androidx.compose.runtime.Composable

@Composable
actual fun AppBackHandler(enabled: Boolean, onBack: () -> Unit) {
    // Desktop platform does not have a physical back button
}
