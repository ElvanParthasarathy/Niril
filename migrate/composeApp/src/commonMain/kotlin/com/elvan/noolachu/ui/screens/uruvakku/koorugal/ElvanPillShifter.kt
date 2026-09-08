package com.elvan.noolachu.ui.screens.uruvakku.koorugal

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures

data class PillShifterItem(
    val label: String,
    val icon: ImageVector
)

/**
 * Pixel-perfect port of Flutter's ElvanPillShifter.
 * An iOS / One UI style floating segmented switcher with animated indicator.
 */
@Composable
fun ElvanPillShifter(
    items: List<PillShifterItem>,
    selectedIndex: Int,
    onIndexSelected: (Int) -> Unit,
    colors: ShellColors,
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val pillShape = CircleShape

    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        val totalWidth = maxWidth
        val count = items.size.coerceAtLeast(1)
        val itemWidth = totalWidth / count

        val targetBias = selectedIndex.toFloat() / (count - 1).coerceAtLeast(1)
        val animatedBias by animateFloatAsState(
            targetValue = targetBias,
            animationSpec = spring(stiffness = Spring.StiffnessMediumLow, dampingRatio = Spring.DampingRatioNoBouncy),
            label = "pillIndicatorPosition"
        )

        // Outer container
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
                .clip(pillShape)
                .background(
                    if (isDark) Color(0xFF161616).copy(alpha = 0.95f)
                    else Color(0xFFFFFFFF).copy(alpha = 0.95f)
                )
                .border(
                    width = 0.5.dp,
                    color = if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.06f),
                    shape = pillShape
                )
                .padding(4.dp)
        ) {
            // Animated indicator thumb
            val indicatorOffset = (totalWidth - 8.dp - (itemWidth - 4.dp)) * animatedBias
            Box(
                modifier = Modifier
                    .offset(x = indicatorOffset)
                    .width(itemWidth - 4.dp)
                    .fillMaxHeight()
                    .clip(pillShape)
                    .background(
                        if (isDark) Color(0xFF262626)
                        else Color(0xFFE8E8EC)
                    )
            )

            // Segment tabs row
            Row(
                modifier = Modifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                items.forEachIndexed { index, item ->
                    val isSelected = index == selectedIndex
                    val itemColor = if (isSelected) {
                        if (isDark) Color.White else Color(0xFF111111)
                    } else {
                        if (isDark) Color.White.copy(alpha = 0.44f) else Color.Black.copy(alpha = 0.44f)
                    }

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clip(pillShape)
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = null,
                                onClick = { onIndexSelected(index) }
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = item.icon,
                                contentDescription = item.label,
                                tint = itemColor,
                                modifier = Modifier.size(17.dp)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = item.label.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 14.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                    color = itemColor
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}
