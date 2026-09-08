package com.elvan.noolachu.ui.components.shell

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.rememberShellColors

@Composable
fun ElvanCheyalPothan(
    label: String = K.chaemiPtn.tr(),
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true
) {
    val colors = rememberShellColors()
    TextButton(
        onClick = onClick,
        enabled = enabled,
        shape = CircleShape,
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
        modifier = modifier.height(44.dp)
    ) {
        Text(
            text = label,
            color = if (enabled) colors.accent else colors.textSecondary.copy(alpha = 0.4f),
            fontWeight = FontWeight.Bold,
            fontSize = 15.sp,
            fontFamily = LocalAppFontFamily.current
        )
    }
}
