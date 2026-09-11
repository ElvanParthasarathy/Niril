package com.elvan.noolachu.core.platform

import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp

@Composable
actual fun getStatusBarTopPadding(): Dp =
    WindowInsets.statusBars.asPaddingValues().calculateTopPadding()

@Composable
actual fun getNavBarBottomPadding(): Dp =
    WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()

@Composable
actual fun getImeBottomPadding(): Dp =
    WindowInsets.ime.asPaddingValues().calculateBottomPadding()

@Composable
actual fun Modifier.navigationBarsPaddingIfMobile(): Modifier =
    this.windowInsetsPadding(WindowInsets.navigationBars)
