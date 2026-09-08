package com.elvan.noolachu.ui.screens.uruvakku.koorugal

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
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.floor
import kotlin.math.roundToInt

data class PillShifterItem(
    val label: String,
    val icon: ImageVector,
    val activeIcon: ImageVector = icon
)

/**
 * Pixel-perfect port of Neram's Schedule ViewTypeTabsRow Pill Shifter.
 *
 * Features:
 * - Fluid pointer dragging and real-time thumb tracking.
 * - Symmetrical 4dp expansion in all directions when pressed/dragged (pillScaleX=1.055, pillScaleY=1.20).
 * - 1.02x outer container interactive zoom on touch.
 * - Snap-to-slot animation with smooth easing curve.
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

    val coroutineScope = rememberCoroutineScope()
    val density = LocalDensity.current

    // Exact Schedule ViewTypeTabsRow matching layout dimensions
    val layoutWidth = 136.dp
    val bgWidth = 144.dp
    val horizontalPadding = 8.dp
    val verticalPadding = 4.dp
    val totalWidth = (layoutWidth * itemCount) + (horizontalPadding * 2)

    var isInteracting by remember { mutableStateOf(false) }
    var dragOffsetPx by remember { mutableStateOf<Float?>(null) }
    var touchOffsetFromCenterPx by remember { mutableStateOf(0f) }
    var hoverIndex by remember { mutableStateOf<Int?>(null) }
    var localLockedIndex by remember { mutableStateOf<Int?>(null) }
    var snapNextFrame by remember { mutableStateOf(false) }

    val layoutWidthPx = with(density) { layoutWidth.toPx() }
    val bgWidthPx = with(density) { bgWidth.toPx() }

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

    // Outer AnimatedScale: 1.02x on interaction (BottomNavBar / Schedule match)
    val containerScale by animateFloatAsState(
        targetValue = if (isInteracting) 1.02f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "containerScale"
    )

    // Pill scale on interaction: Symmetrical expansion in all directions
    val pillScaleX by animateFloatAsState(
        targetValue = if (isInteracting) 1.055f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillScaleX"
    )
    val pillScaleY by animateFloatAsState(
        targetValue = if (isInteracting) 1.20f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillScaleY"
    )

    // Exact pixel offset clamping
    val overlapPx = (bgWidthPx - layoutWidthPx) / 2f
    val maxLeftPx = ((itemCount - 1) * layoutWidthPx) - overlapPx
    val minLeftPx = -overlapPx

    val targetLeftPx = if (isInteracting && dragOffsetPx != null) {
        (dragOffsetPx!! - (bgWidthPx / 2f)).coerceIn(minLeftPx, maxLeftPx)
    } else {
        ((activeVisualIndex * layoutWidthPx) - overlapPx).coerceIn(minLeftPx, maxLeftPx)
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

    Box(
        modifier = modifier
            .graphicsLayer {
                scaleX = containerScale
                scaleY = containerScale
                clip = false
            }
            .height(48.dp)
            .width(totalWidth),
        contentAlignment = Alignment.Center
    ) {
        // Layer 1: Outer Container (Matches card/surface background, no outline, no shadow)
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(
                    color = colors.surface,
                    shape = CircleShape
                )
        )

        // Layer 2: Foreground & Draggable Content
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = horizontalPadding, vertical = verticalPadding)
                .pointerInput(Unit) {
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
                        }
                        isInteracting = false
                        onInteraction(false)
                        dragOffsetPx = null
                        hoverIndex = null

                        if (finalIndex != null) {
                            coroutineScope.launch {
                                delay(150)
                                onIndexSelected(finalIndex)
                            }
                        }
                    }
                },
            contentAlignment = Alignment.CenterStart
        ) {
            Box(
                modifier = Modifier
                    .width(layoutWidth * itemCount)
                    .fillMaxHeight()
            ) {
                // Master Background Pill (Detached & Draggable)
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
                        .background(
                            color = if (isDark) Color(0xFF333333)
                            else Color(0xFFE5E5E5),
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
                            if (isDark) Color.White else Color(0xFF1A1A1A)
                        } else {
                            if (isDark) Color(0xFF9E9E9E) else Color(0xFF7C7C80)
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
                                Icon(
                                    imageVector = if (isActive) item.activeIcon else item.icon,
                                    contentDescription = item.label,
                                    tint = itemColor,
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = item.label.preventBrokenLigatures(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 14.sp,
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
