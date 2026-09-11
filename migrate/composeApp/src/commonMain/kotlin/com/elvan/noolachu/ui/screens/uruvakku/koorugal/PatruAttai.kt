package com.elvan.noolachu.ui.screens.uruvakku.koorugal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
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
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.utils.CurrencyUtils
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.data.model.PatrugalTharavuru
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.components.ElvanPothuAttai
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Pixel-perfect port of Flutter's _PatruCard for the Payment Receipts list.
 */
@Composable
fun PatruAttai(
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

    val name = receipt.vaangunarPeyar[primaryLang]
        ?: receipt.vaangunarPeyar[secondaryLang]
        ?: receipt.vaangunarPeyar.values.firstOrNull()
        ?: receipt.patruEn

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
        borderRadius = 20.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (isSelectionMode) {
                Icon(
                    imageVector = if (isSelected) MaterialSymbols.Rounded.CheckCircleFill else MaterialSymbols.Rounded.RadioButtonUnchecked,
                    contentDescription = null,
                    modifier = Modifier.size(22.dp),
                    tint = if (isSelected) (if (isDark) Color.White else Color.Black)
                    else (if (isDark) Color.White.copy(alpha = 0.30f) else Color.Black.copy(alpha = 0.26f))
                )
                Spacer(modifier = Modifier.width(12.dp))
            }
            Column(
                modifier = Modifier.weight(1f)
            ) {
                // Row 1: Customer Name + Date
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                Text(
                    text = name.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    ),
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.width(8.dp))

                Text(
                    text = dateStr,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 12.sp,
                        color = if (isDark) Color.White.copy(alpha = 0.4f) else Color.Black.copy(alpha = 0.4f)
                    )
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Row 2: Receipt # + Payment Method Badge + Amount + Chevron
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = receipt.patruEn,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 12.5.sp,
                        color = if (isDark) Color.White.copy(alpha = 0.45f) else Color.Black.copy(alpha = 0.45f)
                    )
                )

                Spacer(modifier = Modifier.width(8.dp))

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

                Spacer(modifier = Modifier.weight(1f))

                Text(
                    text = amountStr,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 14.5.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = if (isDark) Color(0xFF81C784) else Color(0xFF2E7D32)
                    )
                )

                Spacer(modifier = Modifier.width(6.dp))

                Icon(
                    imageVector = MaterialSymbols.Rounded.ChevronRight,
                    contentDescription = null,
                    tint = if (isDark) Color.White.copy(alpha = 0.25f) else Color.Black.copy(alpha = 0.25f),
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}
}
