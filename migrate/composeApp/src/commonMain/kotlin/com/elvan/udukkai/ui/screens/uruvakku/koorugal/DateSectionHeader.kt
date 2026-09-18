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
import com.elvan.udukkai.localization.LocalAppLanguage
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.LocalShellColors
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors

/**
 * Google Photos-style clean monolingual date section header for Invoices and Receipts lists.
 * Bound directly to the application's UI language.
 */
@Composable
fun DateSectionHeader(
    dateMillis: Long,
    colors: ShellColors = rememberShellColors(),
    language: String = LocalAppLanguage.current,
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val (primaryDate, _) = DateGroupUtils.formatDateHeader(dateMillis, isBilingual = false, primaryLang = language)
    val weekdaySubtitle = DateGroupUtils.getWeekdaySubtitle(dateMillis, isBilingual = false, primaryLang = language)

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
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
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f, fill = false)
        )

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
