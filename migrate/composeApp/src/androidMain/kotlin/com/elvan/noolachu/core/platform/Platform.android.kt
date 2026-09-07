package com.elvan.noolachu.core.platform

import android.app.Dialog
import android.content.ContextWrapper
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.ViewParent
import android.view.Window
import android.view.WindowInsetsController
import android.view.WindowManager
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.window.DialogWindowProvider
import androidx.core.view.WindowCompat

actual val currentPlatform: PlatformType = PlatformType.ANDROID

@Composable
actual fun ConfigureDialogWindow(isDark: Boolean) {
    val view = LocalView.current

    fun findDialogWindow(): Window? {
        var current: ViewParent? = view.parent
        while (current != null) {
            if (current is DialogWindowProvider) {
                return current.window
            }
            current = current.parent
        }
        var ctx = view.context
        while (ctx is ContextWrapper) {
            if (ctx is Dialog) {
                return ctx.window
            }
            ctx = ctx.baseContext
        }
        return null
    }

    fun applySystemBars(window: Window) {
        val decorView = window.decorView
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        window.navigationBarColor = Color.TRANSPARENT
        window.statusBarColor = Color.TRANSPARENT

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
            window.isStatusBarContrastEnforced = false
        }

        val insetsController = WindowCompat.getInsetsController(window, decorView)
        insetsController.isAppearanceLightNavigationBars = !isDark
        insetsController.isAppearanceLightStatusBars = !isDark

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.let { controller ->
                val appearance = WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS or
                                 WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS
                if (!isDark) {
                    controller.setSystemBarsAppearance(appearance, appearance)
                } else {
                    controller.setSystemBarsAppearance(0, appearance)
                }
            }
        }

        @Suppress("DEPRECATION")
        var flags = decorView.systemUiVisibility
        flags = if (!isDark) {
            flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
        } else {
            flags and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv() and View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR.inv()
        }
        @Suppress("DEPRECATION")
        decorView.systemUiVisibility = flags
    }

    SideEffect {
        findDialogWindow()?.let { applySystemBars(it) }
    }

    DisposableEffect(isDark) {
        findDialogWindow()?.let { applySystemBars(it) }
        view.post {
            findDialogWindow()?.let { applySystemBars(it) }
        }
        onDispose {}
    }
}
