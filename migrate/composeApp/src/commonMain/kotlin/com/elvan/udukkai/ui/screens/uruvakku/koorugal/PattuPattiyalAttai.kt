package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.mode.AppMode
import com.elvan.udukkai.core.utils.CurrencyUtils
import com.elvan.udukkai.core.utils.DateUtils
import com.elvan.udukkai.data.model.PattiyalTharavuru
import com.elvan.udukkai.data.settings.NiruvanaTharavugalRepository
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.ui.components.ElvanPothuAttai
import com.elvan.udukkai.ui.navigation.MaterialSymbols
import com.elvan.udukkai.theme.LocalShellColors

/**
 * Pixel-perfect port of Flutter's PattuPattiyalAttai for the Invoices list.
 */
@Composable
fun PattuPattiyalAttai(
    index: Int,
    pattiyal: PattiyalTharavuru,
    colors: ShellColors,
    modifier: Modifier = Modifier,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onClick: () -> Unit = {},
    onLongClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val profile = NiruvanaTharavugalRepository.getProfile(AppMode.PATTU)
    val primaryLang = profile.mudhanMozhi.ifEmpty { "ta" }
    val secondaryLang = profile.thunaiMozhi.ifEmpty { "en" }

    val name = pattiyal.vaangunarPeyar[primaryLang]
        ?: pattiyal.vaangunarPeyar[secondaryLang]
        ?: pattiyal.vaangunarPeyar.values.firstOrNull()
        ?: "-"

    val amountStr = CurrencyUtils.formatInr(pattiyal.mothaThogai)
    val dateStr = DateUtils.formatEpochMillis(pattiyal.pattiyalNaal)

    ElvanPothuAttai(
        onClick = onClick,
        onLongClick = onLongClick,
        isSelected = isSelected,
        modifier = modifier,
        padding = PaddingValues(16.dp),
        borderRadius = 24.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top
        ) {
            // Index circle / Selection checkbox (28x28)
            Box(
                modifier = Modifier
                    .padding(top = 1.dp)
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        if (isSelectionMode && isSelected) (LocalShellColors.current.textPrimary)
                        else if (isDark) Color.White.copy(alpha = 0.12f)
                        else Color.Black.copy(alpha = 0.08f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isSelectionMode && isSelected) {
                    Icon(
                        imageVector = MaterialSymbols.Rounded.Check,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                        tint = LocalShellColors.current.surface
                    )
                } else {
                    Text(
                        text = (index + 1).toString().padStart(2, '0'),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 11.2.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = LocalShellColors.current.textPrimary,
                            lineHeight = 11.2.sp
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Content
            Column(
                modifier = Modifier.weight(1f)
            ) {
                // Row 1: Customer Name + Chevron
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = name.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 15.5.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.textPrimary
                        ),
                        modifier = Modifier.weight(1f),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Icon(
                        imageVector = MaterialSymbols.Rounded.ChevronRight,
                        contentDescription = null,
                        tint = LocalShellColors.current.border,
                        modifier = Modifier.size(18.dp)
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                // Row 2: Invoice #  •  Date
                Text(
                    text = "${pattiyal.patrucheettuEn}  •  $dateStr",
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 13.5.sp,
                        color = LocalShellColors.current.textSecondary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Row 3: Right-aligned Amount
                Text(
                    text = amountStr,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = if (amountStr.length > 11) 13.sp else 15.5.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = colors.accent
                    ),
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.End
                )
            }
        }
    }
}
