package com.elvan.noolachu.ui.screens.uruvakku.koorugal

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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.utils.CurrencyUtils
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.components.ElvanPothuAttai
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Pixel-perfect port of Flutter's KooliPattiyalAttai for the Invoices list.
 */
@Composable
fun KooliPattiyalAttai(
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

    val profile = NiruvanaTharavugalRepository.getProfile(AppMode.KOOLI)
    val isBilingual = profile.iruMozhi
    val primaryLang = profile.mudhanMozhi.ifEmpty { "ta" }
    val secondaryLang = profile.thunaiMozhi.ifEmpty { "en" }

    val primary = pattiyal.vaangunarPeyar[primaryLang]
        ?: pattiyal.vaangunarPeyar["ta"]
        ?: pattiyal.vaangunarPeyar["en"]
        ?: pattiyal.vaangunarPeyar.values.firstOrNull()
        ?: "-"

    val secondary = if (isBilingual) pattiyal.vaangunarPeyar[secondaryLang].orEmpty() else ""
    val showSecondary = isBilingual && secondary.isNotBlank() && secondary != primary

    val primaryOor = pattiyal.vaangunarMunvari[primaryLang]
        ?: pattiyal.vaangunarMunvari["ta"]
        ?: pattiyal.vaangunarMunvari["en"]
        ?: pattiyal.vaangunarMunvari.values.firstOrNull()
        ?: ""

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
                        if (isSelectionMode && isSelected) (if (isDark) Color.White else Color.Black)
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
                        tint = if (isDark) Color.Black else Color.White
                    )
                } else {
                    Text(
                        text = (index + 1).toString().padStart(2, '0'),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 11.2.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = if (isDark) Color.White else Color.Black,
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
                // Row 1: Name + Chevron
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.Top
                ) {
                    Column(
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(
                            text = primary.preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 16.5.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = colors.textPrimary
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        if (showSecondary) {
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = secondary.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 13.5.sp,
                                    color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                                ),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }

                    Icon(
                        imageVector = MaterialSymbols.Rounded.ChevronRight,
                        contentDescription = null,
                        tint = if (isDark) Color(0xFF555555) else Color(0xFFAAAAAA),
                        modifier = Modifier.size(18.dp)
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Row 2: Invoice #  •  Date
                Text(
                    text = "${pattiyal.patrucheettuEn}  •  $dateStr",
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 13.5.sp,
                        color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Row 3: Oor (Place) + Amount
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Bottom
                ) {
                    Text(
                        text = primaryOor.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.5.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                        ),
                        modifier = Modifier.weight(1f, fill = false),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.width(8.dp))

                    Text(
                        text = amountStr,
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = if (amountStr.length > 11) 12.5.sp else 14.5.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.textPrimary
                        )
                    )
                }
            }
        }
    }
}
