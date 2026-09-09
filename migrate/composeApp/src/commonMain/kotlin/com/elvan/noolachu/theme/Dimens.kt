package com.elvan.noolachu.theme

import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

object Dimens {
    val ContentPadding = 12.dp
    val SectionSpacing = 16.dp

    val ContentPaddingBottom: Dp
        @Composable
        get() {
            val navBarsPadding = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
            val imePadding = WindowInsets.ime.asPaddingValues().calculateBottomPadding()
            return if (imePadding > 0.dp) imePadding + 90.dp else 110.dp + navBarsPadding
        }

    val SubpageContentPaddingBottom: Dp
        @Composable
        get() {
            val navBarsPadding = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()
            val imePadding = WindowInsets.ime.asPaddingValues().calculateBottomPadding()
            return if (imePadding > 0.dp) 40.dp else 32.dp + navBarsPadding
        }

    val ContentPaddingTop = 85.dp
    val HeaderMarginTop = 20.dp
    val HeaderGap = 8.dp
    val HeaderPillPadding = 12.dp
}
