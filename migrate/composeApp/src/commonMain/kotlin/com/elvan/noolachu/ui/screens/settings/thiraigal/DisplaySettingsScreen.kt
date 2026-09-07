package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ThemeManager
import com.elvan.noolachu.theme.ThemeMode
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Display Settings Screen matching Flutter's `kaatchi_amaippugal_thirai.dart` and
 * `elvan_thoatra_thaervu.dart` 1:1 pixel-perfect.
 * Features realistic Light & Dark mockup preview cards and Auto-Theme switch.
 */
@Composable
fun DisplaySettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val currentMode = ThemeManager.currentThemeMode
    val ff = LocalAppFontFamily.current

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = Dimens.ContentPadding,
            end = Dimens.ContentPadding,
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Top spacer driven by One UI collapsible header
        item(key = "shell_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        item {
            ElvanSettingsSection(colors = colors) {
                // ── Preview Boxes Row ──
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 24.dp, horizontal = 16.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Light Mode Preview Option
                    ThemeOptionBox(
                        title = K.oliNilai.tr(),
                        isSelected = currentMode == ThemeMode.LIGHT,
                        isDarkModeDesign = false,
                        onTap = { ThemeManager.setThemeMode(ThemeMode.LIGHT) },
                        colors = colors
                    )

                    // Dark Mode Preview Option
                    ThemeOptionBox(
                        title = K.irulNilai.tr(),
                        isSelected = currentMode == ThemeMode.DARK,
                        isDarkModeDesign = true,
                        onTap = { ThemeManager.setThemeMode(ThemeMode.DARK) },
                        colors = colors
                    )
                }

                // Divider
                ElvanSettingsDivider(colors = colors)

                // ── Auto Mode Row ──
                val isSystem = currentMode == ThemeMode.SYSTEM
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null,
                            onClick = {
                                if (isSystem) {
                                    ThemeManager.setThemeMode(if (colors.isDark) ThemeMode.DARK else ThemeMode.LIGHT)
                                } else {
                                    ThemeManager.setThemeMode(ThemeMode.SYSTEM)
                                }
                            }
                        )
                        .padding(horizontal = 20.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = K.thaaniyangiAmaippu.tr(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.SemiBold,
                            lineHeight = 20.sp
                        ),
                        color = colors.textPrimary,
                        modifier = Modifier.weight(1f)
                    )

                    ElvanSettingsSwitch(
                        checked = isSystem,
                        onCheckedChange = { checked ->
                            if (checked) {
                                ThemeManager.setThemeMode(ThemeMode.SYSTEM)
                            } else {
                                ThemeManager.setThemeMode(if (colors.isDark) ThemeMode.DARK else ThemeMode.LIGHT)
                            }
                        },
                        colors = colors
                    )
                }
            }
        }
    }
}

@Composable
private fun ThemeOptionBox(
    title: String,
    isSelected: Boolean,
    isDarkModeDesign: Boolean,
    onTap: () -> Unit,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    val scale by animateFloatAsState(targetValue = if (isSelected) 1.02f else 1.0f)

    val boxBgColor = if (isDarkModeDesign) Color(0xFF1E1E1E) else Color(0xFFF5F5F5)
    val borderColor = if (isSelected) {
        if (isDarkModeDesign) Color(0xFF888888) else Color(0xFF555555)
    } else {
        if (colors.isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.08f)
    }

    val bar1Color = if (isDarkModeDesign) Color.White.copy(alpha = 0.8f) else Color.Black.copy(alpha = 0.7f)
    val bar2Color = if (isDarkModeDesign) Color(0xFF444444) else Color(0xFFCFCFCF)

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onTap
            )
    ) {
        // Mockup Screen Box
        Surface(
            modifier = Modifier
                .width(110.dp)
                .height(85.dp)
                .scale(scale)
                .border(width = 1.dp, color = borderColor, shape = RoundedCornerShape(24.dp))
                .clip(RoundedCornerShape(24.dp)),
            shape = RoundedCornerShape(24.dp),
            color = boxBgColor
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                verticalArrangement = Arrangement.Top,
                horizontalAlignment = Alignment.Start
            ) {
                // Bar 1 (Accent header)
                Box(
                    modifier = Modifier
                        .width(32.dp)
                        .height(8.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(bar1Color)
                )

                Spacer(modifier = Modifier.height(10.dp))

                // Bar 2 (Full line)
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(6.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(bar2Color)
                )

                Spacer(modifier = Modifier.height(10.dp))

                // Bar 3 (Half line)
                Box(
                    modifier = Modifier
                        .width(48.dp)
                        .height(6.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(bar2Color)
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Title
        Text(
            text = title,
            style = TextStyle(
                fontFamily = ff,
                fontSize = 14.sp,
                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Medium
            ),
            color = if (isSelected) colors.textPrimary else colors.textPrimary.copy(alpha = 0.5f)
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Radio Checkmark Circle
        Surface(
            shape = CircleShape,
            color = if (isSelected) (if (isDarkModeDesign) Color.White else Color.Black) else Color.Transparent,
            modifier = Modifier
                .size(22.dp)
                .border(
                    width = if (isSelected) 0.dp else 1.5.dp,
                    color = Color(0xFF888888),
                    shape = CircleShape
                )
        ) {
            if (isSelected) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = MaterialSymbols.Rounded.Check,
                        contentDescription = null,
                        tint = if (isDarkModeDesign) Color.Black else Color.White,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
        }
    }
}
