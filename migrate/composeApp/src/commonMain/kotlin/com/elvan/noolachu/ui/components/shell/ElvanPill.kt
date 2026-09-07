package com.elvan.noolachu.ui.components.shell

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.extensions.cssShadow
import com.elvan.noolachu.theme.ShellColors

@Composable
fun ElvanPill(
    liftProgress: Float,
    colors: ShellColors,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val isDark = colors.isDark || colors.background == Color.Black || colors.background.red < 0.2f
    val pillBgColor = if (isDark) Color(0xFF1E1E1E) else Color(0xFFFFFFFF)
    val pillBorderColor = if (isDark) Color(0xFF333333).copy(alpha = 0.15f * liftProgress)
                          else Color(0xFFFFFFFF).copy(alpha = 0.6f * liftProgress)

    Box(
        modifier = modifier
            .height(50.dp)
            .widthIn(min = 50.dp)
            .cssShadow(
                color = Color.Black,
                alpha = 0.05f * liftProgress,
                blurRadius = 16.dp,
                offsetY = 4.dp
            )
            .background(
                color = pillBgColor.copy(alpha = 0.88f * liftProgress),
                shape = CircleShape
            )
            .border(
                width = 0.5.dp,
                color = pillBorderColor,
                shape = CircleShape
            ),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .fillMaxHeight()
                .padding(horizontal = 5.dp),
            contentAlignment = Alignment.Center
        ) {
            content()
        }
    }
}

