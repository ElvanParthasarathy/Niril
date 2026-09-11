package com.elvan.noolachu.ui.screens.paarvai

import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.ui.components.shell.ElvanCheyalPothan
import com.elvan.noolachu.ui.components.shell.ElvanSubShell

/**
 * Universal View Shell (Paarvai) for Compose Multiplatform.
 * Replicates Flutter's `elvan_paarvai_oadu.dart`.
 * Wraps read-only detail & print views with optional "அச்சிடு" (Print) and "மாற்றியமை" (Edit) actions.
 */
@Composable
fun ElvanPaarvaiOadu(
    title: String,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
    scrollState: LazyListState = rememberLazyListState(),
    onEdit: (() -> Unit)? = null,
    onPrint: (() -> Unit)? = null,
    content: @Composable () -> Unit
) {
    ElvanSubShell(
        title = title,
        onBack = onBack,
        scrollState = scrollState,
        hasActions = onEdit != null || onPrint != null,
        actions = {
            if (onPrint != null) {
                ElvanCheyalPothan(
                    label = K.achadiPtn.tr(),
                    onClick = onPrint
                )
            }
            if (onEdit != null) {
                ElvanCheyalPothan(
                    label = K.maatriyamai.tr(),
                    onClick = onEdit
                )
            }
        },
        content = content
    )
}
