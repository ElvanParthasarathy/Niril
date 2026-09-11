package com.elvan.noolachu.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ripple
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.theme.rememberShellColors

/**
 * A completely reusable Elvan Card component.
 * Exact 1:1 Kotlin Compose port of Flutter's ElvanPothuAttai.
 *
 * It wraps the content to provide the native ripple effect upon tap.
 * It also smoothly animates press scale (0.985f) and background color changes
 * when `isSelected` changes.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun ElvanPothuAttai(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    onLongClick: (() -> Unit)? = null,
    isSelected: Boolean = false,
    padding: PaddingValues = PaddingValues(16.dp),
    borderRadius: Dp = 24.dp,
    content: @Composable () -> Unit
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark

    val defaultBg = if (isDark) Color(0xFF111111) else Color.White
    val selectedBg = if (isDark) Color(0xFF1A1A1A) else Color.Black.copy(alpha = 0.04f)
    val bgColor = if (isSelected) selectedBg else defaultBg

    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    val scale by animateFloatAsState(
        targetValue = if (isPressed && (onClick != null || onLongClick != null)) 0.985f else 1.0f,
        animationSpec = tween(
            durationMillis = if (isPressed) 100 else 200
        ),
        label = "pothuAttaiPressScale"
    )

    val shape = RoundedCornerShape(borderRadius)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clip(shape)
            .background(bgColor)
            .then(
                if (onClick != null || onLongClick != null) {
                    Modifier.combinedClickable(
                        interactionSource = interactionSource,
                        indication = ripple(bounded = true, color = colors.ripple),
                        onClick = { onClick?.invoke() },
                        onLongClick = onLongClick
                    )
                } else Modifier
            )
            .padding(padding)
    ) {
        content()
    }
}
