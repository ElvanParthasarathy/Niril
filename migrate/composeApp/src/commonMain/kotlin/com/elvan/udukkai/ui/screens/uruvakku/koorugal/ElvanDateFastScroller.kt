package com.elvan.udukkai.ui.screens.uruvakku.koorugal

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.extensions.cssShadow
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.LocalShellColors
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

/**
 * Google Photos-style edge Fast Scroller with an interactive floating Date Pill.
 *
 * Features:
 * - Slender, elegant edge track & thumb matching Elvan design language.
 * - Interactive direct dragging and tap-to-scrub through LazyListState.
 * - Floating Date Pill that pops out beside the thumb with smooth capsule clipping and scale animation.
 * - Date pill is ONLY visible while actively dragging the scroller thumb.
 * - Auto-fades thumb after 1200ms when scrolling halts.
 */
@Composable
fun ElvanDateFastScroller(
    scrollState: LazyListState,
    dateProvider: (Int) -> String,
    modifier: Modifier = Modifier,
    colors: ShellColors = rememberShellColors(),
    topPadding: Dp = 180.dp,
    bottomPadding: Dp = 120.dp
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark
    val density = LocalDensity.current
    val coroutineScope = rememberCoroutineScope()

    var isDragging by remember { mutableStateOf(false) }
    var dragProgress by remember { mutableStateOf<Float?>(null) }
    var lastActiveTime by remember { mutableLongStateOf(0L) }

    val isScrollInProgress = scrollState.isScrollInProgress

    LaunchedEffect(isScrollInProgress, isDragging) {
        if (isScrollInProgress || isDragging) {
            lastActiveTime = System.currentTimeMillis()
        }
    }

    var isVisible by remember { mutableStateOf(false) }
    LaunchedEffect(lastActiveTime, isScrollInProgress, isDragging) {
        if (isScrollInProgress || isDragging) {
            isVisible = true
        } else {
            delay(1200)
            isVisible = false
        }
    }

    val totalItems = scrollState.layoutInfo.totalItemsCount
    if (totalItems <= 3) return

    val firstVisible = scrollState.firstVisibleItemIndex
    val firstOffset = scrollState.firstVisibleItemScrollOffset

    val naturalFraction = remember(firstVisible, firstOffset, totalItems) {
        if (totalItems > 1) {
            (firstVisible.toFloat() / (totalItems - 1).toFloat()).coerceIn(0f, 1f)
        } else 0f
    }

    val activeFraction = if (isDragging && dragProgress != null) dragProgress!! else naturalFraction

    val pillDateText = remember(activeFraction, totalItems, dateProvider) {
        val targetIdx = (activeFraction * (totalItems - 1)).roundToInt().coerceIn(0, totalItems - 1)
        dateProvider(targetIdx)
    }

    // Pill is strictly visible ONLY when user is actively dragging
    val pillAlpha by animateFloatAsState(
        targetValue = if (isDragging && pillDateText.isNotBlank()) 1.0f else 0.0f,
        animationSpec = tween(180, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillAlpha"
    )

    val pillScale by animateFloatAsState(
        targetValue = if (isDragging && pillDateText.isNotBlank()) 1.0f else 0.75f,
        animationSpec = tween(180, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)),
        label = "pillScale"
    )

    val thumbAlpha by animateFloatAsState(
        targetValue = if (isDragging) 0.95f else if (isVisible) (if (isDark) 0.40f else 0.50f) else 0f,
        animationSpec = tween(200),
        label = "thumbAlpha"
    )

    val thumbScale by animateFloatAsState(
        targetValue = if (isDragging) 1.25f else 1.0f,
        animationSpec = tween(150),
        label = "thumbScale"
    )

    BoxWithConstraints(
        modifier = modifier.fillMaxSize()
    ) {
        val containerHeightPx = with(density) { maxHeight.toPx() }
        val topPaddingPx = with(density) { topPadding.toPx() }
        val bottomPaddingPx = with(density) { bottomPadding.toPx() }
        val availableTrackHeight = (containerHeightPx - topPaddingPx - bottomPaddingPx).coerceAtLeast(100f)
        val thumbHeightPx = with(density) { 42.dp.toPx() }
        val maxTravelPx = (availableTrackHeight - thumbHeightPx).coerceAtLeast(1f)

        val thumbYPx = (topPaddingPx + (activeFraction * maxTravelPx)).coerceIn(topPaddingPx, topPaddingPx + maxTravelPx)

        // Gesture detector on the right 36.dp edge
        Box(
            modifier = Modifier
                .align(Alignment.CenterEnd)
                .fillMaxHeight()
                .width(36.dp)
                .pointerInput(totalItems, availableTrackHeight, maxTravelPx, topPaddingPx) {
                    awaitEachGesture {
                        val down = awaitFirstDown(requireUnconsumed = false)
                        val touchY = down.position.y
                        if (touchY in topPaddingPx..(topPaddingPx + availableTrackHeight)) {
                            isDragging = true
                            val relY = (touchY - topPaddingPx - (thumbHeightPx / 2f)).coerceIn(0f, maxTravelPx)
                            val fraction = (relY / maxTravelPx).coerceIn(0f, 1f)
                            dragProgress = fraction

                            val targetIndex = (fraction * (totalItems - 1)).roundToInt().coerceIn(0, totalItems - 1)
                            coroutineScope.launch {
                                scrollState.scrollToItem(targetIndex)
                            }
                        }

                        do {
                            val event = awaitPointerEvent()
                            val change = event.changes.firstOrNull() ?: break
                            if (change.pressed && isDragging) {
                                val currentY = change.position.y
                                val relY = (currentY - topPaddingPx - (thumbHeightPx / 2f)).coerceIn(0f, maxTravelPx)
                                val fraction = (relY / maxTravelPx).coerceIn(0f, 1f)
                                dragProgress = fraction

                                val targetIndex = (fraction * (totalItems - 1)).roundToInt().coerceIn(0, totalItems - 1)
                                coroutineScope.launch {
                                    scrollState.scrollToItem(targetIndex)
                                }
                                change.consume()
                            }
                        } while (event.changes.any { it.pressed })

                        isDragging = false
                        dragProgress = null
                    }
                }
        ) {
            // Track Line (Visible only during active drag)
            if (isDragging) {
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .padding(end = 5.dp)
                        .offset { IntOffset(0, topPaddingPx.roundToInt()) }
                        .width(2.dp)
                        .height(with(density) { availableTrackHeight.toDp() })
                        .background(
                            color = if (isDark) Color.White.copy(alpha = 0.12f) else Color.Black.copy(alpha = 0.08f),
                            shape = CircleShape
                        )
                )
            }

            // Scrollbar Thumb Pill
            if (thumbAlpha > 0.01f) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(end = 4.dp)
                        .offset { IntOffset(0, thumbYPx.roundToInt()) }
                        .width(4.5.dp)
                        .height(with(density) { thumbHeightPx.toDp() })
                        .graphicsLayer {
                            scaleX = thumbScale
                            scaleY = thumbScale
                            alpha = thumbAlpha
                            transformOrigin = TransformOrigin(1f, 0.5f)
                        }
                        .background(
                            color = if (isDragging) colors.textPrimary else (if (isDark) Color(0xFF888888) else Color(0xFF666666)),
                            shape = CircleShape
                        )
                )
            }
        }

        // Floating Date Pill (Pops out to the left of the thumb with smooth clipping)
        if (pillAlpha > 0.01f && pillDateText.isNotBlank()) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(end = 20.dp)
                    .offset {
                        IntOffset(
                            x = 0,
                            y = (thumbYPx + (thumbHeightPx / 2f) - with(density) { 18.dp.toPx() }).roundToInt()
                        )
                    }
                    .graphicsLayer {
                        scaleX = pillScale
                        scaleY = pillScale
                        alpha = pillAlpha
                        transformOrigin = TransformOrigin(1f, 0.5f)
                    }
                    .cssShadow(
                        color = Color.Black,
                        alpha = if (isDark) 0.35f else 0.12f,
                        blurRadius = 14.dp,
                        offsetY = 3.dp
                    )
                    .clip(CircleShape)
                    .background(
                        color = if (isDark) Color(0xFF222222) else Color.White
                    )
                    .border(
                        width = 0.5.dp,
                        color = if (isDark) Color.White.copy(alpha = 0.18f) else Color.Black.copy(alpha = 0.10f),
                        shape = CircleShape
                    )
                    .padding(horizontal = 14.dp, vertical = 7.dp)
            ) {
                Text(
                    text = pillDateText.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 12.5.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}
