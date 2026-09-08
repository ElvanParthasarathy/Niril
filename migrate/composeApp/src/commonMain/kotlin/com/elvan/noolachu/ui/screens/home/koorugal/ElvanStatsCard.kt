package com.elvan.noolachu.ui.screens.home.koorugal

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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.components.ElvanPothuAttai

/**
 * Pixel-perfect port of Flutter's ElvanStatsCard bento grid card.
 */
@Composable
fun ElvanStatsCard(
    icon: ImageVector,
    label: String,
    value: String,
    colors: ShellColors,
    modifier: Modifier = Modifier,
    isFullWidth: Boolean = false,
    onClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val iconBoxShape = RoundedCornerShape(if (isFullWidth) 14.dp else 12.dp)
    val iconBoxSize = if (isFullWidth) 44.dp else 40.dp
    val iconSize = if (isFullWidth) 22.dp else 20.dp

    fun adaptiveFontSize(valStr: String): Int {
        return when {
            valStr.length > 20 -> 13
            valStr.length > 14 -> 15
            valStr.length > 11 -> 17
            else -> 21
        }
    }

    ElvanPothuAttai(
        onClick = onClick,
        modifier = modifier,
        padding = PaddingValues(16.dp),
        borderRadius = 24.dp
    ) {
        if (isFullWidth) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Icon box
                Box(
                    modifier = Modifier
                        .size(iconBoxSize)
                        .clip(iconBoxShape)
                        .background(
                            if (isDark) Color.White.copy(alpha = 0.06f)
                            else Color(0xFFF5F5F5)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = icon,
                        contentDescription = label,
                        tint = if (isDark) Color.White else Color.Black,
                        modifier = Modifier.size(iconSize)
                    )
                }

                Spacer(modifier = Modifier.width(14.dp))

                // Text column
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(
                        text = label.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = value.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = adaptiveFontSize(value).sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.textPrimary,
                            lineHeight = 22.sp
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        } else {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                // Icon box
                Box(
                    modifier = Modifier
                        .size(iconBoxSize)
                        .clip(iconBoxShape)
                        .background(
                            if (isDark) Color.White.copy(alpha = 0.06f)
                            else Color(0xFFF5F5F5)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = icon,
                        contentDescription = label,
                        tint = if (isDark) Color.White else Color.Black,
                        modifier = Modifier.size(iconSize)
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Text column
                Column(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = label.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = value.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = adaptiveFontSize(value).sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.textPrimary,
                            lineHeight = 22.sp
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}
