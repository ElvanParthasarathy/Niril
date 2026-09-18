package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.utils.DateGroupUtils
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.LocalShellColors
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors

/**
 * Google Photos-style clean date section header for Invoices and Receipts lists.
 */
@Composable
fun DateSectionHeader(
    dateMillis: Long,
    isBilingual: Boolean,
    primaryLang: String,
    colors: ShellColors = rememberShellColors(),
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val (primaryDate, secondaryDate) = DateGroupUtils.formatDateHeader(dateMillis, isBilingual, primaryLang)
    val weekdaySubtitle = DateGroupUtils.getWeekdaySubtitle(dateMillis, isBilingual, primaryLang)

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            modifier = Modifier.weight(1f, fill = false)
        ) {
            Text(
                text = primaryDate.preventBrokenLigatures(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = colors.textPrimary
                ),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            if (isBilingual && secondaryDate.isNotBlank() && secondaryDate != primaryDate) {
                Spacer(modifier = Modifier.height(1.5.dp))
                Text(
                    text = secondaryDate.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 12.5.sp,
                        fontWeight = FontWeight.Medium,
                        color = LocalShellColors.current.textSecondary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        Spacer(modifier = Modifier.width(12.dp))

        Text(
            text = weekdaySubtitle.preventBrokenLigatures(),
            style = TextStyle(
                fontFamily = ff,
                fontSize = 12.5.sp,
                fontWeight = FontWeight.Medium,
                color = LocalShellColors.current.textTertiary
            ),
            maxLines = 1
        )
    }
}
