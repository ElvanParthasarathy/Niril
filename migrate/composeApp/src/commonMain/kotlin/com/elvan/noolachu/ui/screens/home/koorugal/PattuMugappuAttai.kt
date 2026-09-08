package com.elvan.noolachu.ui.screens.home.koorugal

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
import com.elvan.noolachu.core.utils.CurrencyUtils
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.localization.LocalAppLanguage
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.components.ElvanPothuAttai
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Pixel-perfect port of Flutter's PattuMugappuAttai.
 */
@Composable
fun PattuMugappuAttai(
    index: Int,
    pattiyal: PattiyalTharavuru,
    colors: ShellColors,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {}
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark
    val currentLang = LocalAppLanguage.current

    val name = pattiyal.vaangunarPeyar[currentLang]
        ?: pattiyal.vaangunarPeyar["ta"]
        ?: pattiyal.vaangunarPeyar["en"]
        ?: pattiyal.vaangunarPeyar.values.firstOrNull()
        ?: "-"

    val amountStr = CurrencyUtils.formatInr(pattiyal.mothaThogai)
    val dateStr = DateUtils.formatEpochMillis(pattiyal.pattiyalNaal)

    ElvanPothuAttai(
        onClick = onClick,
        modifier = modifier,
        padding = PaddingValues(16.dp),
        borderRadius = 24.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top
        ) {
            // Index circle (28x28)
            Box(
                modifier = Modifier
                    .padding(top = 1.dp)
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        if (isDark) Color.White.copy(alpha = 0.12f)
                        else Color.Black.copy(alpha = 0.08f)
                    ),
                contentAlignment = Alignment.Center
            ) {
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
                        tint = if (isDark) Color(0xFF555555) else Color(0xFFAAAAAA),
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
                        color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
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
