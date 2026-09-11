package com.elvan.noolachu.ui.components.shell

import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import kotlinx.coroutines.delay

/**
 * Global Snackbar/Toast controller matching Flutter's ElvanSnackbar (elvan_siruseidhi.dart).
 */
object ElvanSnackbar {
    var currentMessage by mutableStateOf<String?>(null)
        private set

    private var messageId by mutableStateOf(0L)

    fun show(message: String) {
        currentMessage = message
        messageId++
    }

    fun dismiss() {
        currentMessage = null
    }

    val activeMessageId: Long
        get() = messageId
}

/**
 * Floating pill toast host matching Flutter's ElvanSnackbar appearance:
 * - Rounded pill shape (100.dp)
 * - Contrast surface color (onSurface background, surface text)
 * - Auto-dismiss after 2.5 seconds
 */
@Composable
fun ElvanSnackbarHost(
    modifier: Modifier = Modifier,
    bottomPadding: Int = 32,
    colors: ShellColors = rememberShellColors()
) {
    val message = ElvanSnackbar.currentMessage
    val msgId = ElvanSnackbar.activeMessageId
    val ff = LocalAppFontFamily.current

    LaunchedEffect(msgId) {
        if (message != null) {
            delay(2500)
            ElvanSnackbar.dismiss()
        }
    }

    val navBarsPadding = com.elvan.noolachu.core.platform.getNavBarBottomPadding()
    // When the system 3-button navigation bar is present (>= 36.dp, typically 48.dp),
    // elevate the snackbar cleanly above the navbar with comfortable breathing room.
    // For others (gesture navigation, desktop, etc.), maintain the normal 32.dp offset.
    val isThreeButtonNav = navBarsPadding >= 36.dp
    val effectiveBottomPadding = if (isThreeButtonNav) {
        maxOf(bottomPadding.dp, navBarsPadding + 20.dp)
    } else {
        bottomPadding.dp
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .zIndex(999f),
        contentAlignment = Alignment.BottomCenter
    ) {
        AnimatedVisibility(
            visible = message != null,
            enter = fadeIn() + slideInVertically { it / 2 },
            exit = fadeOut() + slideOutVertically { it / 2 }
        ) {
            if (message != null) {
                Surface(
                    shape = RoundedCornerShape(100),
                    color = colors.textPrimary,
                    shadowElevation = 8.dp,
                    modifier = Modifier
                        .padding(horizontal = 24.dp)
                        .padding(bottom = effectiveBottomPadding)
                ) {
                    Text(
                        text = message,
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium,
                            color = colors.background,
                            textAlign = TextAlign.Center
                        ),
                        modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp)
                    )
                }
            }
        }
    }
}
