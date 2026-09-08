package com.elvan.noolachu.ui.navigation

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.extensions.cssShadow
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.floor
import kotlin.math.roundToInt

/**
 * Noolachu Floating Draggable Bottom Navigation Bar
 * Ported directly from Neram's ElvanKizhPattaiBase
 */
@Composable
fun BottomNavBar(
    selectedTab: NavTab?,
    onTabSelected: (NavTab, Boolean) -> Unit,
    onInteraction: (Boolean) -> Unit = {},
    onDragProgress: (Float) -> Unit = {},
    hideContent: Boolean = false,
    modifier: Modifier = Modifier
) {
    val tabs = NavTab.entries
    val coroutineScope = rememberCoroutineScope()
    val colors = rememberShellColors()
    val isDark = colors.isDark

    val itemCount = tabs.size
    val layoutWidth = if (itemCount <= 4) 67.dp else 61.dp
    val bgWidth = if (itemCount <= 4) 75.dp else 69.dp
    val horizontalPadding = 8.dp
    val verticalPadding = 4.dp
    val totalWidth = (layoutWidth * itemCount) + (horizontalPadding * 2)

    var isInteracting by remember { mutableStateOf(false) }
    var dragOffsetPx by remember { mutableStateOf<Float?>(null) }
    var touchOffsetFromCenterPx by remember { mutableStateOf(0f) }
    var hoverIndex by remember { mutableStateOf<Int?>(null) }
    var localLockedIndex by remember { mutableStateOf<Int?>(null) }
    var snapNextFrame by remember { mutableStateOf(false) }

    val density = LocalDensity.current
    val layoutWidthPx = with(density) { layoutWidth.toPx() }
    val bgWidthPx = with(density) { bgWidth.toPx() }

    val currentOnTabSelected by rememberUpdatedState(onTabSelected)
    val currentOnInteraction by rememberUpdatedState(onInteraction)
    val currentOnDragProgress by rememberUpdatedState(onDragProgress)

    val actualIndex = tabs.indexOf(selectedTab).coerceAtLeast(0)
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

    val containerScale by animateFloatAsState(
        targetValue = if (isInteracting) 1.02f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "containerScale"
    )

    val pillScale by animateFloatAsState(
        targetValue = if (isInteracting) 1.30f else 1.0f,
        animationSpec = tween(150, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillScale"
    )

    val contentAlpha by animateFloatAsState(
        targetValue = if (hideContent) 0f else 1f,
        animationSpec = tween(150),
        label = "contentAlpha"
    )

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

    val navBarAlpha by animateFloatAsState(
        targetValue = if (hideContent) 0f else 1f,
        animationSpec = tween(200, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "navBarAlpha"
    )

    if (navBarAlpha > 0f) {
        Box(
            modifier = modifier
                .windowInsetsPadding(WindowInsets.navigationBars)
                .padding(bottom = 16.dp)
                .graphicsLayer {
                    scaleX = containerScale
                    scaleY = containerScale
                    alpha = navBarAlpha
                    clip = false
                }
                .height(60.dp)
                .width(totalWidth),
            contentAlignment = Alignment.Center
        ) {
        // Layer 1: Background Capsule & Border
        Box(
            modifier = Modifier
                .matchParentSize()
                .cssShadow(color = Color.Black, alpha = 0.05f, blurRadius = 16.dp, offsetY = 4.dp)
                .background(
                    color = colors.floatingBg.copy(alpha = 0.88f),
                    shape = CircleShape
                )
                .border(
                    width = 0.5.dp,
                    color = colors.floatingBorder.copy(alpha = if (isDark) 0.15f else 0.6f),
                    shape = CircleShape
                )
        )

        // Layer 2: Foreground Content with Gesture Drag
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = horizontalPadding, vertical = verticalPadding)
                .then(
                    if (!hideContent) {
                        Modifier.pointerInput(hideContent) {
                            awaitEachGesture {
                        val down = awaitFirstDown(requireUnconsumed = false)
                        isInteracting = true
                        currentOnInteraction(true)

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
                                currentOnDragProgress(targetCenter / layoutWidthPx)
                                change.consume()
                            }
                        }

                        val finalIndex = hoverIndex
                        if (finalIndex != null) {
                            localLockedIndex = finalIndex
                        }
                        isInteracting = false
                        currentOnInteraction(false)
                        dragOffsetPx = null
                        hoverIndex = null

                        if (finalIndex != null) {
                            coroutineScope.launch {
                                delay(150)
                                currentOnTabSelected(tabs[finalIndex], isDrag)
                            }
                        }
                    }
                }
            } else Modifier
        ),
            contentAlignment = Alignment.CenterStart
        ) {
            Box(
                modifier = Modifier
                    .graphicsLayer {
                        alpha = contentAlpha
                        clip = false
                    }
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
                            scaleX = pillScale
                            scaleY = pillScale
                            transformOrigin = TransformOrigin.Center
                            clip = false
                        }
                        .then(
                            if (!isDark) Modifier.cssShadow(color = Color.Black, alpha = 0.04f, blurRadius = 4.dp, offsetY = 1.dp) else Modifier
                        )
                        .background(
                            color = if (isDark) Color(0xFF333333)
                                    else Color(0xFFE5E5E5),
                            shape = CircleShape
                        )
                )

                // Foreground Content (Icons & Labels)
                Row(
                    modifier = Modifier.fillMaxSize(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    tabs.forEachIndexed { index, tab ->
                        val isActive = index == activeVisualIndex
                        val color = if (isActive) colors.textPrimary else colors.textSecondary

                        Column(
                            modifier = Modifier
                                .fillMaxHeight()
                                .width(layoutWidth),
                            verticalArrangement = Arrangement.Center,
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = if (isActive) tab.activeIcon else tab.icon,
                                contentDescription = tab.getLocalizedLabel(),
                                tint = color,
                                modifier = Modifier.size(23.dp)
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = tab.getLocalizedLabel(),
                                color = color,
                                fontSize = 9.5.sp,
                                fontWeight = if (isActive) FontWeight.SemiBold else FontWeight.Normal,
                                fontFamily = LocalAppFontFamily.current,
                                maxLines = 1,
                                lineHeight = 11.sp
                            )
                        }
                    }
                }
            }
        }
    }
}
}
