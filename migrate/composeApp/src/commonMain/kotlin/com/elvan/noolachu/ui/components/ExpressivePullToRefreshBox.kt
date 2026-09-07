package com.elvan.noolachu.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.pulltorefresh.PullToRefreshState
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.theme.Animations
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors

/**
 * ExpressivePullToRefreshBox - Shared component for consistent pull-to-refresh UX.
 * Ported from Neram's ExpressivePullToRefreshBox for Compose Multiplatform.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpressivePullToRefreshBox(
    isRefreshing: Boolean,
    onRefresh: () -> Unit,
    modifier: Modifier = Modifier,
    pullRefreshState: PullToRefreshState = rememberPullToRefreshState(),
    colors: ShellColors = rememberShellColors(),
    showIndicator: Boolean = true,
    overlay: Boolean = false,
    content: @Composable BoxScope.() -> Unit
) {
    val fraction = pullRefreshState.distanceFraction

    val targetOffset = if (isRefreshing) 80f else (fraction * Animations.PullRefresh.MaxOffset).coerceIn(0f, Animations.PullRefresh.MaxOffset)
    val animatedOffset by animateFloatAsState(
        targetValue = targetOffset,
        label = "offset"
    )

    PullToRefreshBox(
        state = pullRefreshState,
        isRefreshing = isRefreshing,
        onRefresh = onRefresh,
        modifier = modifier.fillMaxSize(),
        indicator = {
            if (showIndicator && (isRefreshing || fraction > 0f)) {
                ExpressiveRefreshIndicator(
                    isRefreshing = isRefreshing,
                    fraction = fraction,
                    colors = colors,
                    animatedOffset = animatedOffset,
                    modifier = Modifier.align(Alignment.TopCenter)
                )
            }
        },
        content = {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .graphicsLayer {
                        translationY = if (overlay) 0f else animatedOffset
                    }
            ) {
                content()
            }
        }
    )
}

@Composable
fun ExpressiveRefreshIndicator(
    isRefreshing: Boolean,
    fraction: Float,
    colors: ShellColors,
    animatedOffset: Float,
    modifier: Modifier = Modifier
) {
    val targetScale = if (isRefreshing) 1f else fraction.coerceIn(0f, 1f)
    val animatedScale by animateFloatAsState(
        targetValue = targetScale,
        label = "scale"
    )

    Box(
        modifier = modifier
            .graphicsLayer {
                translationY = animatedOffset
                scaleX = animatedScale
                scaleY = animatedScale
                alpha = animatedScale
            },
        contentAlignment = Alignment.Center
    ) {
        if (isRefreshing) {
            CircularProgressIndicator(
                modifier = Modifier.size(36.dp),
                color = colors.accent,
                trackColor = colors.border
            )
        } else {
            CircularProgressIndicator(
                progress = { fraction.coerceIn(0f, 1f) },
                modifier = Modifier.size(36.dp),
                color = colors.accent,
                trackColor = colors.border
            )
        }
    }
}
