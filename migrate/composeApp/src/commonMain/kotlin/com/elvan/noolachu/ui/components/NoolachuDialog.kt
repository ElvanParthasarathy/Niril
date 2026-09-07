package com.elvan.noolachu.ui.components

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanActionSheet

/**
 * Modern One UI modal popup for Noolachu, backed by ElvanActionSheet.
 */
@Composable
fun NoolachuDialog(
    title: String,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
    message: String? = null,
    confirmText: String? = null,
    dismissText: String? = null,
    confirmColor: Color? = null,
    isConfirmFilled: Boolean = false,
    colors: ShellColors = rememberShellColors(),
    customContent: (@Composable () -> Unit)? = null
) {
    ElvanActionSheet(
        title = title,
        cancelText = dismissText ?: K.kaividu.tr(),
        confirmText = confirmText ?: K.urudhi.tr(),
        onDismissRequest = onDismiss,
        onConfirm = onConfirm,
        confirmColor = confirmColor,
        isConfirmFilled = isConfirmFilled,
        colors = colors,
        customContent = customContent ?: if (!message.isNullOrEmpty()) {
            {
                Text(
                    text = message,
                    style = TextStyle(
                        fontFamily = LocalAppFontFamily.current,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Normal
                    ),
                    color = colors.textPrimary.copy(alpha = 0.7f),
                    textAlign = TextAlign.Center
                )
            }
        } else null
    )
}
