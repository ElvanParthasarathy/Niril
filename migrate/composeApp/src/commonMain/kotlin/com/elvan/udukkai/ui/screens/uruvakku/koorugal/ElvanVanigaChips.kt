package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
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
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors
import com.elvan.udukkai.ui.navigation.MaterialSymbols

data class VanigaChipItem(
    val label: String,
    val icon: ImageVector? = null
)

/**
 * Material 3 Filter Chips for business profiles (ALL, VRM, PVS, etc.):
 * - Pill-shaped (CircleShape).
 * - No outline/border (border = null).
 * - M3 Elevated/Filled style:
 *   - Selected: elevated surface with soft drop shadow, bold textPrimary, and M3 checkmark icon.
 *   - Unselected: subtle tonal filled surface (0.06f white in dark / 0.05f black in light), textSecondary, leading icon.
 * - Responsive: equal weight across available width extending cleanly to screen edges.
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
                    if (isDark) Color(0xFF222222) else Color.White
                } else {
                    if (isDark) Color.White.copy(alpha = 0.06f) else Color.Black.copy(alpha = 0.05f)
                },
                animationSpec = tween(durationMillis = 200),
                label = "chipBgColor"
            )

            val contentColor by animateColorAsState(
                targetValue = if (isSelected) {
                    colors.textPrimary
                } else {
                    colors.textSecondary
                },
                animationSpec = tween(durationMillis = 200),
                label = "chipContentColor"
            )

            val shadowModifier = if (isSelected) {
                Modifier.cssShadow(
                    color = Color.Black,
                    alpha = if (isDark) 0.35f else 0.12f,
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
                    .height(38.dp)
                    .then(shadowModifier)
                    .clip(CircleShape)
                    .background(animBgColor, CircleShape)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(color = colors.ripple, bounded = true),
                        onClick = { onIndexSelected(index) }
                    ),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    val leadingIcon = if (isSelected) {
                        MaterialSymbols.Rounded.Check
                    } else {
                        item.icon
                    }

                    if (leadingIcon != null) {
                        Icon(
                            imageVector = leadingIcon,
                            contentDescription = null,
                            tint = contentColor,
                            modifier = Modifier.size(15.dp)
                        )
                        Spacer(modifier = Modifier.width(5.dp))
                    }
                    Text(
                        text = item.label.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = if (items.size > 3) 11.5.sp else 13.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
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
