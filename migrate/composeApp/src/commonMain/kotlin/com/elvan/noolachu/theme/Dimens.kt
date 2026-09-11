package com.elvan.noolachu.theme

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.platform.getImeBottomPadding
import com.elvan.noolachu.core.platform.getNavBarBottomPadding

object Dimens {
    val ContentPadding = 12.dp
    val SectionSpacing = 16.dp

    val ContentPaddingBottom: Dp
        @Composable
        get() {
            val navBarsPadding = getNavBarBottomPadding()
            val imePadding = getImeBottomPadding()
            return if (imePadding > 0.dp) imePadding + 90.dp else 110.dp + navBarsPadding
        }

    val SubpageContentPaddingBottom: Dp
        @Composable
        get() {
            val navBarsPadding = getNavBarBottomPadding()
            val imePadding = getImeBottomPadding()
            return if (imePadding > 0.dp) 40.dp else 32.dp + navBarsPadding
        }

    val ContentPaddingTop = 85.dp
    val HeaderMarginTop = 20.dp
    val HeaderGap = 8.dp
    val HeaderPillPadding = 12.dp
}
