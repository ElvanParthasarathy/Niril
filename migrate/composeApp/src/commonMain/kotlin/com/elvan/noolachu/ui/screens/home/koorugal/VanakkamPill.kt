package com.elvan.noolachu.ui.screens.home.koorugal

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.ui.navigation.AppSvgs

/**
 * Pixel-perfect port of Flutter's VanakkamPill.
 * Shows greeting pill with mode icon, "வணக்கம் ✨", and active profile/mode name.
 * Tapping the mode circle switches/toggles mode.
 */
@Composable
fun VanakkamPill(
    colors: ShellColors,
    modifier: Modifier = Modifier,
    onModeClick: () -> Unit = { ModeManager.toggleMode() }
) {
    val mode = LocalAppMode.current
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val profile = NiruvanaTharavugalRepository.getProfile(mode)
    val subtitleText = profile.kurumPeyar.ifEmpty {
        profile.niruvanathinPeyar.values.firstOrNull().orEmpty()
    }.ifEmpty {
        if (mode == AppMode.KOOLI) "நிரல் கூலி" else "நிரல் பட்டு"
    }

    val pillShape = RoundedCornerShape(999.dp)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .height(84.dp)
            .clip(pillShape)
            .background(colors.surface)
            .padding(start = 11.dp, end = 16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Mode Circular Button (62dp concentric with 84dp pill, starting cleanly after the curve)
            Box(
                modifier = Modifier
                    .size(62.dp)
                    .clip(CircleShape)
                    .background(colors.iconBg)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ShellDefaults.ripple(colors, bounded = true),
                        onClick = onModeClick
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (mode == AppMode.KOOLI) AppSvgs.coolieMode else AppSvgs.silkMode,
                    contentDescription = mode.displayName(),
                    tint = colors.textPrimary,
                    modifier = Modifier.size(30.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            // Greeting & Name
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = K.vanakkam.tr().preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = colors.textPrimary,
                            letterSpacing = (-0.02).sp
                        )
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "✨",
                        fontSize = 18.sp
                    )
                }

                Spacer(modifier = Modifier.height(2.dp))

                Text(
                    text = subtitleText.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 13.5.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = if (isDark) Color(0xFF9BA1A6) else Color(0xFF666666)
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}
