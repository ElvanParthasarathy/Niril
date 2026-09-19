package com.elvan.udukkai.ui.components.shell

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.extensions.cssShadow
import com.elvan.udukkai.localization.K
import com.elvan.udukkai.localization.tr
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.rememberShellColors
import com.elvan.udukkai.ui.navigation.MaterialSymbols

/**
 * ElvanThervuPattai — Floating multi-selection action bar.
 * Exact 1:1 Kotlin Compose port matching Flutter's choreographed overlay container transform.
 * Expands across the bottom navbar with the exact same animation, size, and position as ElvanThaedalPattai.
 */
@Composable
fun ElvanThervuPattai(
    visible: Boolean,
    selectedCount: Int,
    onSelectAll: () -> Unit,
    onDelete: () -> Unit,
    onCancel: () -> Unit,
    colors: ShellColors = rememberShellColors(),
    modifier: Modifier = Modifier
) {
    val isDark = colors.isDark
    val navBottom = com.elvan.udukkai.core.platform.getNavBarBottomPadding()
    val effectiveBottomPadding = navBottom + 16.dp

    BoxWithConstraints(
        modifier = modifier
            .padding(bottom = effectiveBottomPadding),
        contentAlignment = Alignment.Center
    ) {
        val screenWidth = maxWidth
        val minWidth = 284.dp
        val maxWidthTarget = (screenWidth - 32.dp).coerceAtLeast(minWidth)

        val animatedWidth by animateDpAsState(
            targetValue = if (visible) maxWidthTarget else minWidth,
            animationSpec = tween(
                durationMillis = 300,
                easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)
            ),
            label = "thervuPattaiWidth"
        )

        val alpha by animateFloatAsState(
            targetValue = if (visible) 1f else 0f,
            animationSpec = tween(durationMillis = 200),
            label = "thervuPattaiAlpha"
        )

        if (visible || alpha > 0f) {
            Box(
                modifier = Modifier
                    .width(animatedWidth)
                    .height(60.dp)
                    .graphicsLayer { this.alpha = alpha }
                    .cssShadow(
                        color = Color.Black,
                        alpha = 0.05f,
                        blurRadius = 16.dp,
                        offsetY = 4.dp
                    )
                    .background(
                        color = colors.floatingBg.copy(alpha = 0.88f),
                        shape = CircleShape
                    )
                    .border(
                        width = 0.5.dp,
                        color = colors.floatingBorder.copy(alpha = if (isDark) 0.15f else 0.6f),
                        shape = CircleShape
                    )
                    .padding(horizontal = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 4.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Action 1: Select All / Count
                    ThervuPattaiAction(
                        icon = if (selectedCount > 0) MaterialSymbols.Rounded.CheckBox else MaterialSymbols.Rounded.CheckBoxOutlineBlank,
                        label = if (selectedCount > 0) "$selectedCount ${K.select.tr()}" else K.selectAllBtn.tr(),
                        isActive = selectedCount > 0,
                        isDisabled = false,
                        colors = colors,
                        onClick = onSelectAll
                    )

                    // Action 2: Delete
                    ThervuPattaiAction(
                        icon = MaterialSymbols.Rounded.Delete,
                        label = K.deleteBtn.tr(),
                        isActive = false,
                        isDisabled = selectedCount == 0,
                        colors = colors,
                        onClick = { if (selectedCount > 0) onDelete() }
                    )

                    // Action 3: Cancel
                    ThervuPattaiAction(
                        icon = MaterialSymbols.Rounded.Close,
                        label = K.cancelBtn.tr(),
                        isActive = false,
                        isDisabled = false,
                        colors = colors,
                        onClick = onCancel
                    )
                }
            }
        }
    }
}

@Composable
private fun ThervuPattaiAction(
    icon: ImageVector,
    label: String,
    isActive: Boolean,
    isDisabled: Boolean,
    colors: ShellColors,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val contentColor = when {
        isDisabled -> colors.textSecondary.copy(alpha = 0.35f)
        isActive -> colors.accent
        else -> colors.textPrimary
    }

    Column(
        modifier = modifier
            .widthIn(min = 68.dp, max = 96.dp)
            .fillMaxHeight()
            .clip(CircleShape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(bounded = true),
                enabled = !isDisabled,
                onClick = onClick
            ),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = label,
            tint = contentColor,
            modifier = Modifier.size(22.dp)
        )
        Spacer(modifier = Modifier.height(2.dp))
        Text(
            text = label,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center,
            style = TextStyle(
                fontFamily = ff,
                fontSize = 11.sp,
                fontWeight = if (isActive) FontWeight.SemiBold else FontWeight.Normal,
                color = contentColor
            )
        )
    }
}
