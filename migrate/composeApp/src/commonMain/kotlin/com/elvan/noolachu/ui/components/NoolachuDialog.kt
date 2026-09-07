package com.elvan.noolachu.ui.components

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr

@Composable
fun NoolachuDialog(
    title: String,
    message: String,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
    confirmText: String? = null,
    dismissText: String? = null
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = { Text(message) },
        confirmButton = {
            TextButton(onClick = onConfirm) {
                Text(confirmText ?: K.urudhi.tr())
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(dismissText ?: K.kaividu.tr())
            }
        }
    )
}
