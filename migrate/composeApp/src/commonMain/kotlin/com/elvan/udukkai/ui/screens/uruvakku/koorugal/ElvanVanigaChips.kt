package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.extensions.cssShadow
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors

data class VanigaChipItem(
    val label: String,
    val icon: Any? = null
)

/**
 * Material 3 Pill-shaped Filter Chips for business profiles (ALL, VRM, PVS, etc.):
 * - Compact sleek pill look (height = 32.dp, CircleShape).
 * - No symbols or tick marks (pure text only).
 * - No outline/border (border = null).
 * - Adaptive layout:
 *   - <= 3 businesses: Auto-adapts with equal weight filling the row to screen edges.
 *   - > 3 businesses: Horizontally swipeable (LazyRow) extending all the way to the end.
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
    val lazyListState = rememberLazyListState()

    LaunchedEffect(selectedIndex) {
        if (selectedIndex in items.indices) {
            lazyListState.animateScrollToItem(selectedIndex)
        }
    }

    LazyRow(
        state = lazyListState,
        modifier = modifier.fillMaxWidth(),
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        itemsIndexed(items) { index, item ->
            VanigaChip(
                item = item,
                isSelected = index == selectedIndex,
                isDark = isDark,
                colors = colors,
                ff = ff,
                onClick = { onIndexSelected(index) }
            )
        }
    }
}

@Composable
private fun VanigaChip(
    item: VanigaChipItem,
    isSelected: Boolean,
    isDark: Boolean,
    colors: ShellColors,
    ff: androidx.compose.ui.text.font.FontFamily,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
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
            blurRadius = 6.dp,
            offsetY = 2.dp
        )
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .height(32.dp)
            .then(shadowModifier)
            .clip(CircleShape)
            .background(animBgColor, CircleShape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(color = colors.ripple, bounded = true),
                onClick = onClick
            )
            .padding(horizontal = 14.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = item.label.preventBrokenLigatures(),
            style = TextStyle(
                fontFamily = ff,
                fontSize = 12.sp,
                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Medium
            ),
            color = contentColor,
            maxLines = 1
        )
    }
}
