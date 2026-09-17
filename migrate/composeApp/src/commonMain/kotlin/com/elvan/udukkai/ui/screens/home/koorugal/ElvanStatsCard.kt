package com.elvan.udukkai.ui.screens.home.koorugal

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
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.ui.components.ElvanPothuAttai
import com.elvan.udukkai.theme.LocalShellColors

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
    val iconBoxSize = if (isFullWidth) 44.dp else 38.dp
    val iconSize = if (isFullWidth) 22.dp else 20.dp

    fun adaptiveFontSize(valStr: String, fullWidth: Boolean): Int {
        val len = valStr.length
        return if (fullWidth) {
            when {
                len > 35 -> 12
                len > 25 -> 13
                len > 18 -> 15
                len > 12 -> 17
                else -> 19
            }
        } else {
            when {
                len > 20 -> 12
                len > 14 -> 14
                len > 10 -> 16
                len > 7 -> 18
                else -> 21
            }
        }
    }

    ElvanPothuAttai(
        onClick = onClick,
        modifier = if (isFullWidth) {
            modifier.fillMaxWidth().height(78.dp)
        } else {
            modifier.fillMaxWidth().height(124.dp)
        },
        padding = PaddingValues(
            horizontal = if (isFullWidth) 16.dp else 14.dp,
            vertical = if (isFullWidth) 14.dp else 14.dp
        ),
        borderRadius = 22.dp
    ) {
        if (isFullWidth) {
            Row(
                modifier = Modifier.fillMaxSize(),
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
                        tint = LocalShellColors.current.textPrimary,
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
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = LocalShellColors.current.textSecondary,
                            letterSpacing = (-0.2).sp
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = value.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = adaptiveFontSize(value, true).sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.textPrimary,
                            lineHeight = 22.sp,
                            letterSpacing = if (value.length > 20) (-0.3).sp else 0.sp
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        } else {
            Column(
                modifier = Modifier.fillMaxSize(),
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
                        tint = LocalShellColors.current.textPrimary,
                        modifier = Modifier.size(iconSize)
                    )
                }

                // Text column
                Column(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = label.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = LocalShellColors.current.textSecondary,
                            letterSpacing = (-0.2).sp
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = value.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = adaptiveFontSize(value, false).sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.textPrimary,
                            lineHeight = 22.sp,
                            letterSpacing = if (value.length > 10) (-0.3).sp else 0.sp
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}
