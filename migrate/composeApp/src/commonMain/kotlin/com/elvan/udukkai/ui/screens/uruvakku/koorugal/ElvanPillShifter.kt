package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.extensions.cssShadow
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.LocalShellColors
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors
import kotlin.math.floor
import kotlin.math.roundToInt

data class PillShifterItem(
    val label: String,
    val icon: ImageVector? = null,
    val activeIcon: ImageVector? = icon
)

/**
 * Pixel-perfect responsive Pill Shifter matching React's CSS & Neram's interactive thumb tracking.
 *
 * Features:
 * - Fluid pointer dragging and real-time thumb tracking.
 * - Auto-adapting dynamic slot width with edge-to-edge support via BoxWithConstraints.
 * - React MUI ToggleButtonGroup parity:
 *     - Outer container: `rgba(255,255,255,0.05)` dark / `rgba(0,0,0,0.04)` light
 *     - Sliding thumb: `surface` / `paper` with `0 2px 8px rgba(0,0,0,0.2)` shadow
 * - Distinct active & inactive colors and icon variants.
 */
@Composable
fun ElvanPillShifter(
    items: List<PillShifterItem>,
    selectedIndex: Int,
    onIndexSelected: (Int) -> Unit,
    colors: ShellColors = rememberShellColors(),
    modifier: Modifier = Modifier,
    onInteraction: (Boolean) -> Unit = {},
    onDragProgress: (Float) -> Unit = {}
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark
    val itemCount = items.size.coerceAtLeast(1)
    val actualIndex = selectedIndex.coerceIn(0, itemCount - 1)

    val density = LocalDensity.current

    var isInteracting by remember { mutableStateOf(false) }
    var dragOffsetPx by remember { mutableStateOf<Float?>(null) }
    var touchOffsetFromCenterPx by remember { mutableStateOf(0f) }
    var hoverIndex by remember { mutableStateOf<Int?>(null) }
    var localLockedIndex by remember { mutableStateOf<Int?>(null) }
    var snapNextFrame by remember { mutableStateOf(false) }

    LaunchedEffect(actualIndex) {
        localLockedIndex = null
        snapNextFrame = true
    }
    LaunchedEffect(snapNextFrame) {
        if (snapNextFrame) {
            kotlinx.coroutines.yield()
            snapNextFrame = false
        }
    }

    val activeVisualIndex = if (isInteracting && hoverIndex != null) {
        hoverIndex!!
    } else {
        localLockedIndex ?: actualIndex
    }

    // Outer AnimatedScale: 1.02x on interaction
    val containerScale by animateFloatAsState(
        targetValue = if (isInteracting) 1.02f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "containerScale"
    )

    // Pill scale on interaction: subtle expansion
    val pillScaleX by animateFloatAsState(
        targetValue = if (isInteracting) 1.04f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillScaleX"
    )
    val pillScaleY by animateFloatAsState(
        targetValue = if (isInteracting) 1.08f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillScaleY"
    )

    BoxWithConstraints(
        modifier = modifier
            .graphicsLayer {
                scaleX = containerScale
                scaleY = containerScale
                clip = false
            }
            .height(46.dp),
        contentAlignment = Alignment.Center
    ) {
        val totalAvailableWidth = maxWidth
        val horizontalPadding = 4.dp
        val verticalPadding = 4.dp
        val availableWidth = (totalAvailableWidth - (horizontalPadding * 2)).coerceAtLeast(0.dp)
        val layoutWidth = availableWidth / itemCount
        val bgWidth = layoutWidth

        val layoutWidthPx = with(density) { layoutWidth.toPx() }
        val bgWidthPx = layoutWidthPx

        val maxLeftPx = (itemCount - 1) * layoutWidthPx
        val minLeftPx = 0f

        val targetLeftPx = if (isInteracting && dragOffsetPx != null) {
            (dragOffsetPx!! - (bgWidthPx / 2f)).coerceIn(minLeftPx, maxLeftPx)
        } else {
            (activeVisualIndex * layoutWidthPx).coerceIn(minLeftPx, maxLeftPx)
        }

        val animatedLeftPx by animateFloatAsState(
            targetValue = targetLeftPx,
            animationSpec = if (snapNextFrame || (isInteracting && dragOffsetPx != null)) {
                snap()
            } else {
                tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f))
            },
            label = "pillX"
        )

        // Layer 1: Outer Container matching React CSS:
        // bgcolor: isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.04)'
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(
                    color = if (isDark) Color.White.copy(alpha = 0.05f) else Color.Black.copy(alpha = 0.04f),
                    shape = CircleShape
                )
        )

        // Layer 2: Foreground & Draggable Content
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = horizontalPadding, vertical = verticalPadding)
                .pointerInput(itemCount, layoutWidthPx) {
                    if (layoutWidthPx <= 0f) return@pointerInput
                    awaitEachGesture {
                        val down = awaitFirstDown(requireUnconsumed = false)
                        isInteracting = true
                        onInteraction(true)

                        val initialX = down.position.x
                        hoverIndex = floor(initialX / layoutWidthPx).toInt().coerceIn(0, itemCount - 1)
                        val slotCenter = (hoverIndex!! * layoutWidthPx) + (layoutWidthPx / 2f)
                        touchOffsetFromCenterPx = initialX - slotCenter
                        dragOffsetPx = null

                        var isDrag = false
                        val pointerId = down.id

                        while (true) {
                            val event = awaitPointerEvent()
                            val change = event.changes.firstOrNull { it.id == pointerId } ?: break
                            if (!change.pressed) {
                                break
                            }
                            val currentPos = change.position
                            if (kotlin.math.abs(currentPos.x - down.position.x) > 4f) {
                                isDrag = true
                                val targetCenter = currentPos.x - touchOffsetFromCenterPx
                                dragOffsetPx = targetCenter
                                hoverIndex = floor(targetCenter / layoutWidthPx).toInt().coerceIn(0, itemCount - 1)
                                onDragProgress(targetCenter / layoutWidthPx)
                                change.consume()
                            }
                        }

                        val finalIndex = hoverIndex
                        if (finalIndex != null) {
                            localLockedIndex = finalIndex
                            onIndexSelected(finalIndex)
                        }
                        isInteracting = false
                        onInteraction(false)
                        dragOffsetPx = null
                        hoverIndex = null
                    }
                },
            contentAlignment = Alignment.CenterStart
        ) {
            Box(
                modifier = Modifier
                    .width(availableWidth)
                    .fillMaxHeight()
            ) {
                // Master Background Pill (Detached & Draggable)
                // bgcolor: 'background.paper', boxShadow: '0 2px 8px rgba(0,0,0,0.2)'
                Box(
                    modifier = Modifier
                        .offset { IntOffset(animatedLeftPx.roundToInt(), 0) }
                        .fillMaxHeight()
                        .width(bgWidth)
                        .graphicsLayer {
                            scaleX = pillScaleX
                            scaleY = pillScaleY
                            transformOrigin = TransformOrigin.Center
                            clip = false
                        }
                        .cssShadow(
                            color = Color.Black,
                            alpha = if (isDark) 0.35f else 0.15f,
                            borderRadius = 50.dp,
                            blurRadius = 8.dp,
                            offsetY = 2.dp
                        )
                        .background(
                            color = if (isDark) colors.surface else Color.White,
                            shape = CircleShape
                        )
                )

                // Foreground Tabs Content
                Row(
                    modifier = Modifier.fillMaxSize(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    items.forEachIndexed { index, item ->
                        val isActive = index == activeVisualIndex
                        val itemColor = if (isActive) {
                            LocalShellColors.current.textPrimary
                        } else {
                            LocalShellColors.current.textSecondary
                        }

                        Box(
                            modifier = Modifier
                                .width(layoutWidth)
                                .fillMaxHeight(),
                            contentAlignment = Alignment.Center
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.Center
                            ) {
                                if (item.icon != null) {
                                    Icon(
                                        imageVector = if (isActive) (item.activeIcon ?: item.icon) else item.icon,
                                        contentDescription = item.label,
                                        tint = itemColor,
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                }
                                Text(
                                    text = item.label.preventBrokenLigatures(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = if (itemCount > 2) 13.sp else 14.sp,
                                        fontWeight = if (isActive) FontWeight.SemiBold else FontWeight.Medium
                                    ),
                                    color = itemColor,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
