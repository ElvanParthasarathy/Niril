package com.elvan.noolachu.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Surface
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.pulltorefresh.PullToRefreshState
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors

private const val PULL_REFRESH_MAX_OFFSET = 180f
private const val PULL_REFRESH_REFRESHING_OFFSET = 180f
private val REFRESH_INDICATOR_SIZE = 48.dp

/**
 * ExpressivePullToRefreshBox - Shared component for consistent pull-to-refresh UX.
 * Ported directly from Neram's ExpressivePullToRefreshBox.
 *
 * Wraps Material3 PullToRefreshBox and provides the standard "Expressive"
 * contained loading indicator animation with smooth translation and scale dynamics.
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

    // Smoothly animate the offset to prevent jumps between pull and refresh states
    val targetOffset = if (isRefreshing) {
        PULL_REFRESH_REFRESHING_OFFSET
    } else {
        (fraction * PULL_REFRESH_MAX_OFFSET).coerceIn(0f, PULL_REFRESH_MAX_OFFSET)
    }
    val animatedOffset by animateFloatAsState(
        targetValue = targetOffset,
        label = "pull_offset"
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
                        // If overlay is true, do NOT translate content
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
    // Smoothly animate scale to prevent "breaking" appearance/disappearance
    val targetScale = if (isRefreshing) 1f else fraction.coerceIn(0f, 1f)
    val animatedScale by animateFloatAsState(
        targetValue = targetScale,
        label = "pull_scale"
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
        Surface(
            modifier = Modifier.size(REFRESH_INDICATOR_SIZE),
            shape = CircleShape,
            color = colors.surface,
            shadowElevation = 6.dp,
            tonalElevation = 2.dp
        ) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                if (isRefreshing) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(24.dp),
                        color = colors.accent,
                        strokeWidth = 2.5.dp,
                        trackColor = colors.accent.copy(alpha = 0.2f)
                    )
                } else {
                    CircularProgressIndicator(
                        progress = { fraction.coerceIn(0f, 1f) },
                        modifier = Modifier.size(24.dp),
                        color = colors.accent,
                        strokeWidth = 2.5.dp,
                        trackColor = colors.border
                    )
                }
            }
        }
    }
}
