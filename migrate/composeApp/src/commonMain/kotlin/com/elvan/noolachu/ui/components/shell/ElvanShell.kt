package com.elvan.noolachu.ui.components.shell

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch

val LocalElvanScrollState = compositionLocalOf<LazyListState?> { null }
val LocalElvanTopSpacerHeight = compositionLocalOf<Dp> { 280.dp - Dimens.SectionSpacing }
val LocalGlobalHeaderExpanded = compositionLocalOf<MutableState<Boolean>> { mutableStateOf(true) }

class ElvanShellController(
    val toggleHeader: () -> Unit = {},
    val expandHeader: () -> Unit = {},
    val collapseHeader: () -> Unit = {}
)
val LocalElvanShellController = compositionLocalOf { ElvanShellController() }

@Composable
fun ElvanShell(
    scrollState: LazyListState,
    title: String = "",
    useNewDesign: Boolean = true,
    showNavbar: Boolean = true,
    onBack: (() -> Unit)? = null,
    leadingIcon: ImageVector? = null,
    hasActions: Boolean = false,
    actions: @Composable RowScope.() -> Unit = {},
    navbar: @Composable () -> Unit = {},
    content: @Composable () -> Unit
) {
    val colors = rememberShellColors()
    var isNavbarVisible by remember { mutableStateOf(true) }
    val coroutineScope = rememberCoroutineScope()

    val expandedHeight = 280.dp
    val pillHeight = 50.dp
    val statusBarHeight = WindowInsets.statusBars.asPaddingValues().calculateTopPadding()
    val ceiling = statusBarHeight + 20.dp
    val density = LocalDensity.current

    val collisionOffsetDp = expandedHeight - (ceiling + pillHeight)
    val collisionOffsetPx = with(density) { collisionOffsetDp.toPx() }

    val handoffShrinkOffsetDp = 196.dp - statusBarHeight
    val handoffShrinkOffsetPx = with(density) { handoffShrinkOffsetDp.toPx() }

    val globalHeaderExpanded = LocalGlobalHeaderExpanded.current

    var headerCollapsePx by remember(scrollState) {
        mutableFloatStateOf(if (globalHeaderExpanded.value) 0f else handoffShrinkOffsetPx)
    }

    LaunchedEffect(headerCollapsePx, handoffShrinkOffsetPx) {
        if (headerCollapsePx >= handoffShrinkOffsetPx && globalHeaderExpanded.value) {
            globalHeaderExpanded.value = false
        } else if (headerCollapsePx == 0f && !globalHeaderExpanded.value) {
            globalHeaderExpanded.value = true
        }
    }

    val rawScrollOffset = if (scrollState.firstVisibleItemIndex == 0) {
        scrollState.firstVisibleItemScrollOffset.toFloat()
    } else {
        with(density) { expandedHeight.toPx() }
    }
    val currentScrollOffset = (headerCollapsePx + rawScrollOffset).coerceAtMost(with(density) { expandedHeight.toPx() })

    val topSpacerHeight = (expandedHeight - Dimens.SectionSpacing - with(density) { headerCollapsePx.toDp() }).coerceAtLeast(0.dp)

    var isHeaderExpanded by remember(scrollState) {
        mutableStateOf(
            scrollState.firstVisibleItemIndex == 0 &&
            currentScrollOffset < handoffShrinkOffsetPx
        )
    }

    LaunchedEffect(scrollState, handoffShrinkOffsetPx, headerCollapsePx) {
        snapshotFlow {
            scrollState.firstVisibleItemIndex > 0 || currentScrollOffset >= handoffShrinkOffsetPx
        }.distinctUntilChanged().collect { isPastBoundary ->
            if (isPastBoundary && isHeaderExpanded) {
                isHeaderExpanded = false
            }
        }
    }

    var isFlinging by remember { mutableStateOf(false) }

    val nestedScrollConnection = remember(scrollState, handoffShrinkOffsetPx, collisionOffsetPx, density) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                val delta = available.y
                val isItem0 = scrollState.firstVisibleItemIndex == 0
                val isListAtTop = isItem0 && scrollState.firstVisibleItemScrollOffset == 0

                // 1. Dragging UP: Header collapses FIRST before list scrolls
                if (delta < 0f && headerCollapsePx < handoffShrinkOffsetPx) {
                    val newCollapse = (headerCollapsePx - delta).coerceIn(0f, handoffShrinkOffsetPx)
                    val consumedY = -(newCollapse - headerCollapsePx)
                    headerCollapsePx = newCollapse
                    return Offset(0f, consumedY)
                }

                // 2. Dragging DOWN: Expand header when list is at top
                if (delta > 0f && isListAtTop && headerCollapsePx > 0f) {
                    if (source == NestedScrollSource.UserInput) {
                        isHeaderExpanded = true
                        val newCollapse = (headerCollapsePx - delta).coerceIn(0f, handoffShrinkOffsetPx)
                        val consumedY = -(newCollapse - headerCollapsePx)
                        headerCollapsePx = newCollapse
                        return Offset(0f, consumedY)
                    } else {
                        return Offset(0f, delta)
                    }
                }

                // 3. Brick Wall Brake
                if (delta > 0f && source != NestedScrollSource.UserInput) {
                    if (isListAtTop && headerCollapsePx >= handoffShrinkOffsetPx) {
                        return Offset(0f, delta)
                    }
                }

                // 4. Navbar hide/show logic matching Flutter One UI Physics
                val reachedPill = !isItem0 || currentScrollOffset >= (collisionOffsetPx - with(density) { 4.dp.toPx() })
                if (delta > 2f && !isNavbarVisible) {
                    // Scrolling UP (finger moving down) -> Show immediately!
                    isNavbarVisible = true
                } else if (delta < -2f && isNavbarVisible && reachedPill) {
                    // Scrolling DOWN past header (finger moving up) -> Hide!
                    isNavbarVisible = false
                }
                return Offset.Zero
            }

            override fun onPostScroll(consumed: Offset, available: Offset, source: NestedScrollSource): Offset {
                val isItem0 = scrollState.firstVisibleItemIndex == 0
                val isListAtTop = isItem0 && scrollState.firstVisibleItemScrollOffset == 0
                if (available.y > 0f && isListAtTop && headerCollapsePx > 0f) {
                    if (source == NestedScrollSource.UserInput) {
                        val newCollapse = (headerCollapsePx - available.y).coerceIn(0f, handoffShrinkOffsetPx)
                        val consumedY = -(newCollapse - headerCollapsePx)
                        headerCollapsePx = newCollapse
                        return Offset(0f, consumedY)
                    } else {
                        return Offset(0f, available.y)
                    }
                }
                return Offset.Zero
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                val isItem0 = scrollState.firstVisibleItemIndex == 0
                val isListAtTop = isItem0 && scrollState.firstVisibleItemScrollOffset == 0
                val isSubpage = onBack != null

                if (headerCollapsePx > 0f && headerCollapsePx < handoffShrinkOffsetPx && isListAtTop) {
                    val currentProgress = headerCollapsePx / handoffShrinkOffsetPx
                    val target = when {
                        isSubpage && available.y < -100f -> handoffShrinkOffsetPx
                        available.y < -500f -> handoffShrinkOffsetPx
                        available.y > 500f -> 0f
                        isSubpage && currentProgress >= 0.2f -> handoffShrinkOffsetPx
                        currentProgress >= 0.4f -> handoffShrinkOffsetPx
                        else -> 0f
                    }
                    androidx.compose.animation.core.animate(
                        initialValue = headerCollapsePx,
                        targetValue = target,
                        animationSpec = tween(
                            durationMillis = 260,
                            easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)
                        )
                    ) { value, _ -> headerCollapsePx = value }
                    return available
                }

                if (available.y < -300f) {
                    val reachedPill = !isItem0 || currentScrollOffset >= (collisionOffsetPx - with(density) { 4.dp.toPx() })
                    if (reachedPill && isNavbarVisible) {
                        isNavbarVisible = false
                    }
                }
                return Velocity.Zero
            }

            override suspend fun onPostFling(consumed: Velocity, available: Velocity): Velocity {
                isFlinging = false
                if (!isNavbarVisible) isNavbarVisible = true
                return Velocity.Zero
            }
        }
    }

    val isTruePill = currentScrollOffset >= (collisionOffsetPx - with(density) { 4.dp.toPx() })
    LaunchedEffect(isTruePill) {
        if (!isTruePill && !isNavbarVisible) {
            isNavbarVisible = true
        }
    }

    // Restore navbar when scrolling stops (ScrollEndNotification equivalent)
    LaunchedEffect(scrollState.isScrollInProgress) {
        if (!scrollState.isScrollInProgress && !isNavbarVisible) {
            isNavbarVisible = true
        }
    }

    // Always restore navbar when at the top of the list
    LaunchedEffect(scrollState.firstVisibleItemIndex, scrollState.firstVisibleItemScrollOffset) {
        if (scrollState.firstVisibleItemIndex == 0 && scrollState.firstVisibleItemScrollOffset == 0) {
            if (!isNavbarVisible) isNavbarVisible = true
        }
    }

    val navOpacity by animateFloatAsState(
        targetValue = if (isNavbarVisible) 1.0f else 0.0f,
        animationSpec = tween(
            durationMillis = 280,
            easing = if (isNavbarVisible)
                CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)
            else
                CubicBezierEasing(0.4f, 0.0f, 1.0f, 1.0f)
        ),
        label = "navOpacity"
    )

    val effectiveNavOpacity = if (isTruePill) navOpacity else 1.0f

    val shellController = remember(scrollState, handoffShrinkOffsetPx, globalHeaderExpanded) {
        ElvanShellController(
            toggleHeader = {
                coroutineScope.launch {
                    if (scrollState.firstVisibleItemIndex > 0 || scrollState.firstVisibleItemScrollOffset > 0) {
                        scrollState.animateScrollToItem(0, 0)
                    } else {
                        val willExpand = headerCollapsePx > handoffShrinkOffsetPx / 2f
                        val target = if (willExpand) 0f else handoffShrinkOffsetPx
                        androidx.compose.animation.core.animate(
                            initialValue = headerCollapsePx,
                            targetValue = target,
                            animationSpec = tween(
                                durationMillis = 280,
                                easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)
                            )
                        ) { value, _ -> headerCollapsePx = value }
                        globalHeaderExpanded.value = willExpand
                    }
                }
            },
            expandHeader = {
                coroutineScope.launch {
                    if (scrollState.firstVisibleItemIndex > 0 || scrollState.firstVisibleItemScrollOffset > 0) {
                        scrollState.scrollToItem(0, 0)
                    }
                    androidx.compose.animation.core.animate(
                        initialValue = headerCollapsePx,
                        targetValue = 0f,
                        animationSpec = tween(280, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f))
                    ) { value, _ -> headerCollapsePx = value }
                    globalHeaderExpanded.value = true
                }
            },
            collapseHeader = {
                coroutineScope.launch {
                    androidx.compose.animation.core.animate(
                        initialValue = headerCollapsePx,
                        targetValue = handoffShrinkOffsetPx,
                        animationSpec = tween(280, easing = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f))
                    ) { value, _ -> headerCollapsePx = value }
                    globalHeaderExpanded.value = false
                }
            }
        )
    }

    CompositionLocalProvider(
        LocalElvanScrollState provides scrollState,
        LocalElvanTopSpacerHeight provides topSpacerHeight,
        LocalElvanShellController provides shellController
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(colors.background)
                .nestedScroll(nestedScrollConnection)
        ) {
            // Layer 1: Content
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .then(if (!showNavbar) Modifier.imePadding() else Modifier)
            ) {
                content()
            }

            if (useNewDesign) {
                // Layer 2: Top Fade Mask (Solid at top, fading down)
                Box(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .fillMaxWidth()
                        .height(96.dp)
                        .zIndex(10f)
                        .background(
                            Brush.verticalGradient(
                                0.0f to colors.background,
                                0.35f to colors.background.copy(alpha = 0.55f),
                                0.7f to colors.background.copy(alpha = 0.16f),
                                1.0f to Color.Transparent
                            )
                        )
                )

                // Layer 2.5: The Expanded Header scaling down
                Box(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .zIndex(100f)
                ) {
                    ElvanExpandedBar(
                        title = title,
                        colors = colors,
                        scrollOffsetPx = currentScrollOffset,
                        collisionOffsetPx = collisionOffsetPx,
                        expandedHeight = expandedHeight,
                        hasLeadingWidget = onBack != null,
                        onBack = onBack,
                        hasActions = hasActions,
                        actions = actions
                    )
                }

                // Layer 3: ElvanCollapsedBar (Pill) — Fades in only on card collision
                ElvanCollapsedBar(
                    scrollOffset = currentScrollOffset,
                    collisionOffsetPx = collisionOffsetPx,
                    colors = colors,
                    expandedHeight = expandedHeight,
                    title = if (useNewDesign) null else title,
                    onBack = onBack,
                    leadingIcon = leadingIcon,
                    navOpacity = effectiveNavOpacity,
                    hasActions = hasActions,
                    actions = actions
                )
            } else {
                ElvanCollapsedBar(
                    scrollOffset = currentScrollOffset,
                    collisionOffsetPx = collisionOffsetPx,
                    colors = colors,
                    expandedHeight = expandedHeight,
                    title = title,
                    onBack = onBack,
                    leadingIcon = leadingIcon,
                    navOpacity = effectiveNavOpacity,
                    hasActions = hasActions,
                    actions = actions
                )
            }

            // Layer 4: Bottom Fade Mask and Navbar
            val navBarsPadding = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()

            if (showNavbar) {
                // Fade mask is ALWAYS present when showNavbar is true
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .height(96.dp + 60.dp + 16.dp + navBarsPadding)
                        .zIndex(180f)
                        .background(
                            Brush.verticalGradient(
                                0.0f to Color.Transparent,
                                0.3f to colors.background.copy(alpha = 0.16f),
                                0.65f to colors.background.copy(alpha = 0.55f),
                                1.0f to colors.background
                            )
                        )
                )

                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .zIndex(200f)
                        .graphicsLayer {
                            alpha = effectiveNavOpacity
                        },
                    contentAlignment = Alignment.BottomCenter
                ) {
                    navbar()
                }
            } else {
                // Subpages: Bottom Shadow Fade Mask above System Navigation Bar
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .height(48.dp + navBarsPadding)
                        .zIndex(180f)
                        .background(
                            Brush.verticalGradient(
                                0.0f to Color.Transparent,
                                0.3f to colors.background.copy(alpha = 0.16f),
                                0.65f to colors.background.copy(alpha = 0.55f),
                                1.0f to colors.background
                            )
                        )
                )
            }
        }
    }
}

