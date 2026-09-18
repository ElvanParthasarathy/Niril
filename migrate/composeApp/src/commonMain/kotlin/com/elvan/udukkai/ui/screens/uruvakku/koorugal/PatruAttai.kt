package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.elvan.udukkai.core.mode.LocalAppMode
import com.elvan.udukkai.core.utils.CurrencyUtils
import com.elvan.udukkai.core.utils.DateUtils
import com.elvan.udukkai.data.model.PatrugalTharavuru
import com.elvan.udukkai.data.settings.NiruvanaTharavugalRepository
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.ui.components.ElvanPothuAttai
import com.elvan.udukkai.ui.navigation.MaterialSymbols
import com.elvan.udukkai.theme.LocalShellColors

/**
 * Pixel-perfect port of Receipt Card matching the exact card design of Invoices.
 */
@Composable
fun PatruAttai(
    index: Int,
    receipt: PatrugalTharavuru,
    colors: ShellColors,
    modifier: Modifier = Modifier,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onClick: () -> Unit = {},
    onLongClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val currentMode = LocalAppMode.current
    val profile = NiruvanaTharavugalRepository.getProfile(currentMode)
    val primaryLang = profile.mudhanMozhi.ifEmpty { "ta" }
    val secondaryLang = profile.thunaiMozhi.ifEmpty { "en" }

    val primary = receipt.vaangunarPeyar[primaryLang]
        ?: receipt.vaangunarPeyar["ta"]
        ?: receipt.vaangunarPeyar["en"]
        ?: receipt.vaangunarPeyar.values.firstOrNull()
        ?: receipt.patruEn

    val secondary = receipt.vaangunarPeyar[secondaryLang].orEmpty()
    val showSecondary = secondary.isNotBlank() && secondary != primary

    val dateStr = DateUtils.formatEpochMillis(receipt.patruNaal)
    val amountStr = CurrencyUtils.formatInr(receipt.thogai)

    val (badgeText, badgeColor) = when (receipt.seluthumMurai.lowercase()) {
        "cash" -> "ரொக்கம்" to if (isDark) Color(0xFF81C784) else Color(0xFF2E7D32)
        "upi" -> "UPI" to if (isDark) Color(0xFFBA68C8) else Color(0xFF7B1FA2)
        "bank_transfer" -> "வங்கி" to if (isDark) Color(0xFF64B5F6) else Color(0xFF1565C0)
        "cheque" -> "காசோலை" to if (isDark) Color(0xFFFFB74D) else Color(0xFFEF6C00)
        "card" -> "அட்டை" to if (isDark) Color(0xFF4DB6AC) else Color(0xFF00796B)
        else -> receipt.seluthumMurai to if (isDark) Color.White.copy(0.7f) else Color.Black.copy(0.7f)
    }

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
                                    color = LocalShellColors.current.textSecondary
                                ),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }

                    Icon(
                        imageVector = MaterialSymbols.Rounded.ChevronRight,
                        contentDescription = null,
                        tint = LocalShellColors.current.border,
                        modifier = Modifier.size(18.dp)
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Row 2: Receipt #  •  Date
                Text(
                    text = "${receipt.patruEn}  •  $dateStr",
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 13.5.sp,
                        color = LocalShellColors.current.textSecondary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(4.dp))

                // Row 3: Payment mode badge on left + Amount on right
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Bottom
                ) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(badgeColor.copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 2.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = badgeText.preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = badgeColor
                            )
                        )
                    }

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
