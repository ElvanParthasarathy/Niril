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
import com.elvan.udukkai.core.platform.navigationBarsPaddingIfMobile
import com.elvan.udukkai.localization.K
import com.elvan.udukkai.localization.tr
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.rememberShellColors
import com.elvan.udukkai.ui.navigation.MaterialSymbols

/**
 * ElvanThervuPattai — Floating multi-selection action bar.
 * Matches BottomNavBar position and 56.dp height exactly.
 * Compact width sized strictly to its 3 elements with inset pill-shaped ripples.
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

    val alpha by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        animationSpec = tween(durationMillis = 200, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "thervuPattaiAlpha"
    )

    val scale by animateFloatAsState(
        targetValue = if (visible) 1.0f else 0.92f,
        animationSpec = tween(durationMillis = 200, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "thervuPattaiScale"
    )

    if (visible || alpha > 0f) {
        Box(
            modifier = modifier
                .fillMaxWidth()
                .navigationBarsPaddingIfMobile()
                .padding(bottom = 16.dp)
                .graphicsLayer {
                    this.alpha = alpha
                    this.scaleX = scale
                    this.scaleY = scale
                },
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .width(244.dp)
                    .height(56.dp)
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
                    .padding(horizontal = 6.dp, vertical = 4.dp),
                contentAlignment = Alignment.Center
            ) {
                Row(
                    modifier = Modifier.fillMaxSize(),
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
    val isDark = colors.isDark
    val contentColor = when {
        isDisabled -> colors.textSecondary.copy(alpha = 0.35f)
        isActive -> colors.accent
        else -> colors.textPrimary
    }

    Box(
        modifier = modifier
            .width(74.dp)
            .fillMaxHeight()
            .padding(horizontal = 2.dp, vertical = 2.dp)
            .clip(CircleShape)
            .then(
                if (isActive) {
                    Modifier.background(
                        color = colors.accent.copy(alpha = if (isDark) 0.18f else 0.12f),
                        shape = CircleShape
                    )
                } else Modifier
            )
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(bounded = true, radius = 24.dp),
                enabled = !isDisabled,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = contentColor,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = label,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                textAlign = TextAlign.Center,
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 10.sp,
                    fontWeight = if (isActive) FontWeight.SemiBold else FontWeight.Medium,
                    color = contentColor
                )
            )
        }
    }
}
