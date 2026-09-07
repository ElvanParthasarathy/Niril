package com.elvan.noolachu.ui.screens.settings

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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Settings Hub Screen matching Flutter's `amaippugal_thirai.dart` 1:1.
 * Provides One UI card sections, Big Mode Switcher Pill, and all 13 subpages.
 */
@Composable
fun SettingsHubScreen(
    onNavigate: (SettingsRoute) -> Unit,
    onSignOutClick: () -> Unit = {},
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val currentMode = LocalAppMode.current
    val ff = LocalAppFontFamily.current

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            top = 16.dp,
            bottom = 48.dp
        ),
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // ── 0. Mode Switcher & Merchant Settings (Big Pill - borderRadius 999.dp) ──
        item(key = "mode_pill_card") {
            ElvanSectionContainer {
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(999.dp)),
                    shape = RoundedCornerShape(999.dp),
                    color = colors.surface,
                    shadowElevation = 0.dp
                ) {
                    Box(modifier = Modifier.fillMaxWidth()) {
                        // The main pill body (Navigates to Merchant Settings)
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable(
                                    interactionSource = remember { MutableInteractionSource() },
                                    indication = ShellDefaults.ripple(colors, bounded = true),
                                    onClick = { onNavigate(SettingsRoute.Merchant) }
                                )
                                .padding(start = 92.dp, end = 24.dp, top = 14.dp, bottom = 14.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(
                                modifier = Modifier
                                    .weight(1f)
                                    .height(64.dp),
                                verticalArrangement = Arrangement.Center
                            ) {
                                Text(
                                    text = K.niruvanaAmaippugal.tr(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.SemiBold,
                                        lineHeight = 22.sp
                                    ),
                                    color = colors.textPrimary
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = if (currentMode == AppMode.KOOLI) K.nirilKooli.tr() else K.nirilPattu.tr(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.SemiBold
                                    ),
                                    color = colors.textPrimary.copy(alpha = 0.5f)
                                )
                            }
                        }

                        // The circular Mode Switcher on the left (diameter 64dp)
                        Box(
                            modifier = Modifier
                                .padding(14.dp)
                                .size(64.dp)
                                .clip(CircleShape)
                                .background(colors.iconBg)
                                .clickable(
                                    interactionSource = remember { MutableInteractionSource() },
                                    indication = ShellDefaults.ripple(colors, bounded = true),
                                    onClick = { ModeManager.toggleMode() }
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(34.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .border(1.5.dp, colors.textPrimary, RoundedCornerShape(8.dp)),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = if (currentMode == AppMode.KOOLI) "கூ" else "ப",
                                    color = colors.textPrimary,
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.offset(y = (-1).dp)
                                )
                            }
                        }
                    }
                }
            }
        }

        // ── Section 1: Business Profile & Identity ──
        item(key = "identity_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    if (currentMode == AppMode.KOOLI) {
                        ElvanSettingsRow(
                            icon = MaterialSymbols.Rounded.Palette,
                            title = K.adaiyaalam.tr(),
                            description = K.kooliNiruvanaAdaiyaalangal.tr(),
                            onClick = { onNavigate(SettingsRoute.KooliIdentity) },
                            colors = colors
                        )
                    } else {
                        ElvanSettingsRow(
                            icon = MaterialSymbols.Rounded.Palette,
                            title = K.adaiyaalam.tr(),
                            description = K.pattuNiruvanaAdaiyaalangal.tr(),
                            onClick = { onNavigate(SettingsRoute.PattuIdentity) },
                            colors = colors
                        )
                    }

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Home,
                        title = K.mugavari.tr(),
                        description = K.mugavaritharavugal.tr(),
                        onClick = { onNavigate(SettingsRoute.Address) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 2: Finance & Creation ──
        item(key = "finance_creation_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Description,
                        title = K.vangi.tr(),
                        description = K.kanakkuEnIfsc.tr(),
                        onClick = { onNavigate(SettingsRoute.Bank) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Description,
                        title = K.uruvaakkuPtn.tr(),
                        description = K.pilVadivamaippuViruppangal.tr(),
                        onClick = { onNavigate(SettingsRoute.InvoiceCreation) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 3: User & Display ──
        item(key = "user_display_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Home,
                        title = K.payanar.tr(),
                        description = K.payanarAmaippugal.tr(),
                        onClick = { onNavigate(SettingsRoute.UserProfile) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.LightMode,
                        title = K.thirai.tr(),
                        description = K.olirIrulThaaniyangu.tr(),
                        onClick = { onNavigate(SettingsRoute.Display) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 4: Language & Security ──
        item(key = "language_security_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Translate,
                        title = K.cheyaliMozhi.tr(),
                        description = K.thamizhAangilamThaaniyangu.tr(),
                        onClick = { onNavigate(SettingsRoute.Language) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Storage,
                        title = K.chaemippuMatrumKaappu.tr(),
                        description = K.tharavuthalangalKaappaikKaiyaalu.tr(),
                        onClick = { onNavigate(SettingsRoute.StorageBackup) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Logout,
                        title = K.paadhugaappu.tr(),
                        description = K.thaekkagathaiazhi.tr(),
                        onClick = { onNavigate(SettingsRoute.Security) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 5: System & About ──
        item(key = "about_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Info,
                        title = K.menporulVadivaalar.tr(),
                        description = K.elvanPatriMaelumAriga.tr(),
                        onClick = { onNavigate(SettingsRoute.AboutDeveloper) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Info,
                        title = K.cheyaliPatri.tr(),
                        description = K.cheyalipadhippu.tr(),
                        onClick = { onNavigate(SettingsRoute.AboutApp) },
                        colors = colors
                    )
                }
            }
        }
    }
}
