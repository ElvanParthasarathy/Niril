package com.elvan.noolachu.ui.components.shell.maeladukkugal

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanActionSheet

/**
 * ElvanAzhippuUrudhiMaeladukku — Delete confirmation action sheet matching Flutter's `elvan_azhippu_urudhi_maeladukku.dart`.
 */
@Composable
fun ElvanAzhippuUrudhiMaeladukku(
    onConfirm: () -> Unit,
    onDismissRequest: () -> Unit,
    title: String = K.thannuruvaiMutrilumNeekkavaa.tr(),
    cancelText: String = K.kaividu.tr(),
    confirmText: String = K.azhi.tr(),
    colors: ShellColors = rememberShellColors()
) {
    ElvanActionSheet(
        title = title,
        cancelText = cancelText,
        confirmText = confirmText,
        confirmColor = MaterialTheme.colorScheme.error,
        onDismissRequest = onDismissRequest,
        onConfirm = onConfirm,
        colors = colors
    )
}
