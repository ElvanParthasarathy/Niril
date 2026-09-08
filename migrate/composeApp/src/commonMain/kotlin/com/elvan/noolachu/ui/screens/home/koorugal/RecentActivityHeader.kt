package com.elvan.noolachu.ui.screens.home.koorugal

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Pixel-perfect port of Flutter's RecentActivityHeader.
 * Displays "அண்மைய செயற்பாடுகள்" with "அனைத்தும் >" action navigating to Invoices tab.
 */
@Composable
fun RecentActivityHeader(
    onSeeAll: () -> Unit,
    colors: ShellColors,
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = K.arugilSeyalgal.tr().preventBrokenLigatures(),
            style = TextStyle(
                fontFamily = ff,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = colors.textPrimary
            )
        )

        Row(
            modifier = Modifier
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = ShellDefaults.ripple(colors, bounded = false),
                    onClick = onSeeAll
                )
                .padding(vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = K.anaiththaiyumPaarPtn.tr().preventBrokenLigatures(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                )
            )
            Spacer(modifier = Modifier.width(4.dp))
            Icon(
                imageVector = MaterialSymbols.Rounded.ChevronRight,
                contentDescription = null,
                tint = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f),
                modifier = Modifier.size(18.dp)
            )
        }
    }
}
