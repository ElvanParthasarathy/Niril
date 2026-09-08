package com.elvan.noolachu.ui.components.shell

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.elvan.noolachu.core.platform.ConfigureDialogWindow
import com.elvan.noolachu.core.platform.PlatformType
import com.elvan.noolachu.core.platform.currentPlatform
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors

/**
 * ElvanLoadingOverlay — Replicates Flutter's `showElvanLoadingOverlay` (`elvan_aetrum_maeladukku.dart`) 1:1 pixel-perfect.
 *
 * Visual spec:
 * - On Mobile: Floating bottom sheet (`ModalBottomSheet`) with 32.dp rounded corners, 16.dp horizontal & 24.dp bottom margin.
 * - On Desktop: Centered Dialog with maxWidth 480.dp.
 * - Translucent glass surface (0xFF151515 at 88% alpha in dark / 0xFFFFFFFF at 92% alpha in light).
 * - Thin border (0.5.dp) for crisp edge definition.
 * - Centered text: 18.sp, FontWeight.SemiBold (w600).
 * - 24.dp spacer.
 * - LinearProgressIndicator: 6.dp height, fully rounded pill ends (100.dp radius),
 *   trackColor: textPrimary at 10% alpha, color: textPrimary.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ElvanLoadingOverlay(
    text: String,
    onDismissRequest: () -> Unit = {},
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark
    val bgLoader = if (isDark) Color(0xFF151515).copy(alpha = 0.88f) else Color.White.copy(alpha = 0.92f)
    val borderColor = if (isDark) Color.White.copy(alpha = 0.10f) else Color.Black.copy(alpha = 0.08f)

    @Composable
    fun LoadingContent() {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = text,
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center
                ),
                color = colors.textPrimary
            )

            Spacer(modifier = Modifier.height(24.dp))

            LinearProgressIndicator(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(RoundedCornerShape(100)),
                color = colors.textPrimary,
                trackColor = colors.textPrimary.copy(alpha = 0.10f)
            )
        }
    }

    if (currentPlatform == PlatformType.DESKTOP) {
        Dialog(
            onDismissRequest = onDismissRequest,
            properties = DialogProperties(
                dismissOnBackPress = false,
                dismissOnClickOutside = false
            )
        ) {
            Surface(
                shape = RoundedCornerShape(32.dp),
                color = bgLoader,
                modifier = Modifier
                    .widthIn(max = 480.dp)
                    .fillMaxWidth()
                    .border(0.5.dp, borderColor, RoundedCornerShape(32.dp))
            ) {
                LoadingContent()
            }
        }
    } else {
        ModalBottomSheet(
            onDismissRequest = onDismissRequest,
            shape = RoundedCornerShape(32.dp),
            containerColor = Color.Transparent,
            scrimColor = Color.Black.copy(alpha = 0.45f),
            dragHandle = null
        ) {
            ConfigureDialogWindow(isDark = isDark)
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .navigationBarsPadding()
                    .padding(start = 16.dp, end = 16.dp, bottom = 24.dp)
            ) {
                Surface(
                    shape = RoundedCornerShape(32.dp),
                    color = bgLoader,
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(0.5.dp, borderColor, RoundedCornerShape(32.dp))
                ) {
                    LoadingContent()
                }
            }
        }
    }
}
