package com.elvan.noolachu.ui.screens.home.koorugal

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Pixel-perfect port of Flutter's MugappuEmptyState.
 */
@Composable
fun MugappuEmptyState(
    colors: ShellColors,
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 48.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = MaterialSymbols.Rounded.Description,
                contentDescription = null,
                tint = if (isDark) Color.White.copy(alpha = 0.24f) else Color.Black.copy(alpha = 0.26f),
                modifier = Modifier.size(48.dp)
            )
            Spacer(modifier = Modifier.height(14.dp))
            Text(
                text = K.pattiyalgalIllai.tr().preventBrokenLigatures(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 15.sp,
                    color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
                )
            )
        }
    }
}
