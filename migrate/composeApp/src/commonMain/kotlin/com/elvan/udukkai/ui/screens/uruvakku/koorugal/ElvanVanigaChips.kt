package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.extensions.cssShadow
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.LocalShellColors
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors

data class VanigaChipItem(
    val label: String,
    val icon: ImageVector? = null
)

/**
 * Filter Chips for business profiles (ALL, VRM, PVS, etc.) matching React's CSS styles:
 * - Each chip auto-adapts to screen width with equal weight and spacing.
 * - Active chip: elevated surface with 0 2px 8px shadow and semi-bold text.
 * - Inactive chip: translucent React bgcolor rgba(255,255,255,0.05) / rgba(0,0,0,0.04) with thin border.
 */
@Composable
fun ElvanVanigaChips(
    items: List<VanigaChipItem>,
    selectedIndex: Int,
    onIndexSelected: (Int) -> Unit,
    colors: ShellColors = rememberShellColors(),
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        items.forEachIndexed { index, item ->
            val isSelected = index == selectedIndex

            val animBgColor by animateColorAsState(
                targetValue = if (isSelected) {
                    if (isDark) colors.surface else Color.White
                } else {
                    if (isDark) Color.White.copy(alpha = 0.05f) else Color.Black.copy(alpha = 0.04f)
                },
                animationSpec = tween(durationMillis = 200),
                label = "chipBgColor"
            )

            val animBorderColor by animateColorAsState(
                targetValue = if (isSelected) {
                    if (isDark) Color.White.copy(alpha = 0.20f) else Color.Black.copy(alpha = 0.12f)
                } else {
                    if (isDark) Color.White.copy(alpha = 0.06f) else Color.Black.copy(alpha = 0.06f)
                },
                animationSpec = tween(durationMillis = 200),
                label = "chipBorderColor"
            )

            val contentColor by animateColorAsState(
                targetValue = if (isSelected) {
                    LocalShellColors.current.textPrimary
                } else {
                    LocalShellColors.current.textSecondary
                },
                animationSpec = tween(durationMillis = 200),
                label = "chipContentColor"
            )

            val shadowModifier = if (isSelected) {
                Modifier.cssShadow(
                    color = Color.Black,
                    alpha = if (isDark) 0.35f else 0.15f,
                    borderRadius = 50.dp,
                    blurRadius = 8.dp,
                    offsetY = 2.dp
                )
            } else {
                Modifier
            }

            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(42.dp)
                    .then(shadowModifier)
                    .clip(CircleShape)
                    .background(animBgColor, CircleShape)
                    .border(
                        width = if (isSelected) 1.dp else 0.5.dp,
                        color = animBorderColor,
                        shape = CircleShape
                    )
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(color = colors.ripple, bounded = true),
                        onClick = { onIndexSelected(index) }
                    ),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    if (item.icon != null) {
                        Icon(
                            imageVector = item.icon,
                            contentDescription = item.label,
                            tint = contentColor,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                    }
                    Text(
                        text = item.label.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = if (items.size > 3) 12.sp else 13.5.sp,
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Medium
                        ),
                        color = contentColor,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}
