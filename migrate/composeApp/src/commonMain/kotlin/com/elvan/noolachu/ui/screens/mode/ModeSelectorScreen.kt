package com.elvan.noolachu.ui.screens.mode

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.extensions.cssShadow
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.ThemeManager
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.navigation.AppSvgs
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * ModeSelectorScreen — Full screen app mode switcher copied pixel-perfect from Flutter's
 * `ModeSelectorScreen` (`muraimai_thaervu_thirai.dart`) and `AuthLayout` (`ullnuzhaivu_koorugal.dart`).
 */
@Composable
fun ModeSelectorScreen(
    onModeSelected: (AppMode) -> Unit,
    onDismiss: (() -> Unit)? = null,
    canDismiss: Boolean = false
) {
    if (canDismiss && onDismiss != null) {
        AppBackHandler { onDismiss() }
    }

    val isDark = ThemeManager.isDark()
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current

    val bgColor = if (isDark) Color(0xFF0A0A0A) else Color(0xFFFAFAFA)
    val shapeColor = if (isDark) Color.White.copy(alpha = 0.03f) else Color(0xFFEAEAEA)

    // Infinite transitions for animated background shapes
    val infiniteTransition = rememberInfiniteTransition(label = "AuthLayoutBackground")

    // Shape 1: Top Right, Large Rounded Square (60s linear rotation)
    val rotate1 by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 60000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotate1"
    )

    // Shape 2: Bottom Left, Circle (4s ease-in-out float up/down)
    val float1 by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 30f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 4000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "float1"
    )

    // Shape 3: Top Left, Small Rounded Square (40s linear reverse rotation)
    val rotate2 by infiniteTransition.animateFloat(
        initialValue = 360f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 40000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotate2"
    )

    // Shape 4: Center Right, Small Circle (5s ease-in-out float)
    val float2 by infiniteTransition.animateFloat(
        initialValue = 30f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 5000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "float2"
    )

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
    ) {
        val screenWidth = maxWidth
        val screenHeight = maxHeight

        // Shape 1: Top Right, Large Rounded Square
        Box(
            modifier = Modifier
                .offset(
                    x = screenWidth * 0.6f,
                    y = screenHeight * 0.02f
                )
                .size(screenWidth * 0.5f)
                .graphicsLayer { rotationZ = rotate1 }
                .background(shapeColor, RoundedCornerShape(80.dp))
        )

        // Shape 2: Bottom Left, Circle
        Box(
            modifier = Modifier
                .offset(
                    x = -screenWidth * 0.1f,
                    y = screenHeight * 0.75f + float1.dp
                )
                .size(screenWidth * 0.7f)
                .background(shapeColor, CircleShape)
        )

        // Shape 3: Top Left, Small Rounded Square
        Box(
            modifier = Modifier
                .offset(
                    x = screenWidth * 0.05f,
                    y = screenHeight * 0.15f
                )
                .size(screenWidth * 0.2f)
                .graphicsLayer { rotationZ = rotate2 }
                .background(shapeColor, RoundedCornerShape(30.dp))
        )

        // Shape 4: Center Right, Small Circle
        Box(
            modifier = Modifier
                .offset(
                    x = screenWidth * 0.85f,
                    y = screenHeight * 0.55f + float2.dp
                )
                .size(screenWidth * 0.15f)
                .background(shapeColor, CircleShape)
        )

        // Dismiss / Close Button at Top Left (if allowed)
        if (canDismiss && onDismiss != null) {
            Surface(
                shape = CircleShape,
                color = colors.iconBg,
                modifier = Modifier
                    .statusBarsPadding()
                    .padding(start = 16.dp, top = 16.dp)
                    .size(44.dp)
                    .clip(CircleShape)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ShellDefaults.ripple(colors, bounded = true),
                        onClick = onDismiss
                    )
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = MaterialSymbols.Rounded.Close,
                        contentDescription = K.kaividu.tr(),
                        tint = colors.textPrimary,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }
        }

        // Center Content Container
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp)
                .align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // AuthHeader
            Text(
                text = K.endhachCheyalmurai.tr(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 28.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = (-0.5).sp,
                    textAlign = TextAlign.Center
                ),
                color = if (isDark) Color.White else Color(0xFF1A1A1A)
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = K.ungalCheyalmuraiyaithThaerndhedukkavum.tr(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Normal,
                    textAlign = TextAlign.Center
                ),
                color = if (isDark) Color.White.copy(alpha = 0.5f) else Color.Black.copy(alpha = 0.5f)
            )

            Spacer(modifier = Modifier.height(60.dp))

            // Netflix Profile Cards Row
            Row(
                horizontalArrangement = Arrangement.spacedBy(28.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Kooli Profile Card
                NetflixProfileCard(
                    title = K.nirilKooli.tr(),
                    icon = AppSvgs.coolieMode,
                    isDark = isDark,
                    onClick = { onModeSelected(AppMode.KOOLI) }
                )

                // Pattu Profile Card
                NetflixProfileCard(
                    title = K.nirilPattu.tr(),
                    icon = AppSvgs.silkMode,
                    isDark = isDark,
                    onClick = { onModeSelected(AppMode.PATTU) }
                )
            }

            Spacer(modifier = Modifier.height(40.dp))
        }

        // Global Branding Signature at Bottom
        Box(
            modifier = Modifier
                .navigationBarsPadding()
                .padding(bottom = 32.dp)
                .fillMaxWidth()
                .align(Alignment.BottomCenter),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = K.elvanParthasarathy.tr(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Normal,
                    letterSpacing = 1.2.sp
                ),
                color = if (isDark) Color.White.copy(alpha = 0.4f) else Color.Black.copy(alpha = 0.4f)
            )
        }
    }
}

/**
 * NetflixProfileCard — Tactile animated 120dp circular avatar card matching Flutter.
 */
@Composable
private fun NetflixProfileCard(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    isDark: Boolean,
    onClick: () -> Unit
) {
    val ff = LocalAppFontFamily.current
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.94f else 1.0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "cardScale"
    )

    val boxColor = if (isDark) Color(0xFF222222) else Color.White
    val iconColor = if (isDark) Color.White else Color(0xFF111111)
    val textColor = if (isDark) Color(0xFF9E9E9E) else Color(0xFF757575)

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
    ) {
        // 120dp Circle Avatar Box with shadow
        Box(
            modifier = Modifier
                .size(120.dp)
                .cssShadow(
                    color = Color.Black,
                    alpha = if (isDark) 0.20f else 0.08f,
                    borderRadius = 60.dp,
                    blurRadius = 16.dp,
                    offsetY = 8.dp
                )
                .clip(CircleShape)
                .background(boxColor),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = iconColor,
                modifier = Modifier.size(56.dp)
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = title,
            style = TextStyle(
                fontFamily = ff,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            ),
            color = textColor
        )
    }
}
