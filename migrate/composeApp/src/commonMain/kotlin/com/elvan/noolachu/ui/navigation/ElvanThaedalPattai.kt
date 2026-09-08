package com.elvan.noolachu.ui.navigation

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
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.extensions.cssShadow
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import kotlinx.coroutines.delay

/**
 * ElvanThaedalPattai — Floating bottom search pill.
 * Exact 1:1 Kotlin Compose port of Flutter's ElvanSearchBar (elvan_thaedal_pattai.dart).
 *
 * Sits directly on top of the bottom navbar position and expands across the bottom
 * when activated, providing search input, live filtering, and quick dismiss.
 */
@Composable
fun ElvanThaedalPattai(
    visible: Boolean,
    query: String,
    onQueryChange: (String) -> Unit,
    onClose: () -> Unit,
    colors: ShellColors,
    modifier: Modifier = Modifier
) {
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current
    val focusRequester = remember { FocusRequester() }
    val focusManager = LocalFocusManager.current

    LaunchedEffect(visible) {
        if (visible) {
            delay(150)
            try {
                focusRequester.requestFocus()
            } catch (_: Exception) {}
        } else {
            focusManager.clearFocus()
        }
    }

    BoxWithConstraints(
        modifier = modifier
            .windowInsetsPadding(WindowInsets.navigationBars)
            .padding(bottom = 16.dp),
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
            label = "thaedalPattaiWidth"
        )

        val alpha by animateFloatAsState(
            targetValue = if (visible) 1f else 0f,
            animationSpec = tween(durationMillis = 200),
            label = "thaedalPattaiAlpha"
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
                    .padding(horizontal = 16.dp),
                contentAlignment = Alignment.CenterStart
            ) {
                Row(
                    modifier = Modifier.fillMaxSize(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = MaterialSymbols.Rounded.Search,
                        contentDescription = null,
                        tint = colors.textSecondary,
                        modifier = Modifier.size(20.dp)
                    )

                    Spacer(modifier = Modifier.width(10.dp))

                    Box(
                        modifier = Modifier.weight(1f),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        if (query.isEmpty()) {
                            Text(
                                text = K.thaeduga.tr(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 17.sp,
                                    color = colors.textSecondary.copy(alpha = 0.6f)
                                )
                            )
                        }

                        BasicTextField(
                            value = query,
                            onValueChange = onQueryChange,
                            textStyle = TextStyle(
                                fontFamily = ff,
                                fontSize = 17.sp,
                                color = colors.textPrimary
                            ),
                            singleLine = true,
                            cursorBrush = SolidColor(colors.accent),
                            modifier = Modifier
                                .fillMaxWidth()
                                .focusRequester(focusRequester)
                        )
                    }

                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = ripple(bounded = true, radius = 18.dp),
                                onClick = onClose
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = MaterialSymbols.Rounded.Cancel,
                            contentDescription = K.kaividu.tr(),
                            tint = colors.textSecondary,
                            modifier = Modifier.size(22.dp)
                        )
                    }
                }
            }
        }
    }
}
