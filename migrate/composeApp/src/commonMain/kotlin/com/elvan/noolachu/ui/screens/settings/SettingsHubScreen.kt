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
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.AppSvgs
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
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
    ) {
        // Top spacer driven by One UI collapsible header
        item(key = "shell_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        // ── 0. Mode Switcher & Merchant Settings (Big Pill - borderRadius 999.dp) ──
        item(key = "mode_pill_card") {
            ElvanSectionContainer {
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(999.dp))
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = ShellDefaults.ripple(colors, bounded = true),
                            onClick = { onNavigate(SettingsRoute.Merchant) }
                        ),
                    shape = RoundedCornerShape(999.dp),
                    color = colors.surface,
                    shadowElevation = 0.dp
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(84.dp)
                            .padding(start = 11.dp, end = 16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // The circular Mode Switcher on the left (diameter 62dp, concentric with 84dp pill)
                        Box(
                            modifier = Modifier
                                .size(62.dp)
                                .clip(CircleShape)
                                .background(colors.iconBg)
                                .clickable(
                                    interactionSource = remember { MutableInteractionSource() },
                                    indication = ShellDefaults.ripple(colors, bounded = true),
                                    onClick = { ModeManager.openModeSelector() }
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (currentMode == AppMode.KOOLI) AppSvgs.coolieMode else AppSvgs.silkMode,
                                contentDescription = if (currentMode == AppMode.KOOLI) K.nirilKooli.tr() else K.nirilPattu.tr(),
                                tint = colors.textPrimary,
                                modifier = Modifier.size(30.dp)
                            )
                        }

                        Spacer(modifier = Modifier.width(16.dp))

                        Column(
                            modifier = Modifier.weight(1f),
                            horizontalAlignment = Alignment.Start
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
                            Spacer(modifier = Modifier.height(3.dp))
                            Text(
                                text = if (currentMode == AppMode.KOOLI) K.nirilKooli.tr() else K.nirilPattu.tr(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Medium
                                ),
                                color = colors.textPrimary.copy(alpha = 0.5f),
                                maxLines = 1
                            )
                        }
                    }
                }
            }
        }

        // ── Section 1: Business Identity & Finance (3 items) ──
        item(key = "business_identity_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    if (currentMode == AppMode.KOOLI) {
                        ElvanSettingsRow(
                            icon = MaterialSymbols.Rounded.BusinessCenter,
                            title = K.adaiyaalam.tr(),
                            description = K.kooliNiruvanaAdaiyaalangal.tr(),
                            onClick = { onNavigate(SettingsRoute.KooliIdentity) },
                            colors = colors
                        )
                    } else {
                        ElvanSettingsRow(
                            icon = MaterialSymbols.Rounded.BusinessCenter,
                            title = K.adaiyaalam.tr(),
                            description = K.pattuNiruvanaAdaiyaalangal.tr(),
                            onClick = { onNavigate(SettingsRoute.PattuIdentity) },
                            colors = colors
                        )
                    }

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.LocationOn,
                        title = K.mugavari.tr(),
                        description = K.mugavaritharavugal.tr(),
                        onClick = { onNavigate(SettingsRoute.Address) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.CreditCard,
                        title = K.vangi.tr(),
                        description = K.kanakkuEnIfsc.tr(),
                        onClick = { onNavigate(SettingsRoute.Bank) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 2: Invoicing & Interface (3 items) ──
        item(key = "invoicing_interface_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Description,
                        title = K.uruvaakkuPtn.tr(),
                        description = K.pilVadivamaippuViruppangal.tr(),
                        onClick = { onNavigate(SettingsRoute.InvoiceCreation) },
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

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Translate,
                        title = K.cheyaliMozhi.tr(),
                        description = K.thamizhAangilamThaaniyangu.tr(),
                        onClick = { onNavigate(SettingsRoute.Language) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 3: User Account, Data & Security (3 items) ──
        item(key = "account_data_security_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Person,
                        title = K.payanar.tr(),
                        description = K.payanarAmaippugal.tr(),
                        onClick = { onNavigate(SettingsRoute.UserProfile) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Folder,
                        title = K.chaemippuMatrumKaappu.tr(),
                        description = K.tharavuthalangalKaappaikKaiyaalu.tr(),
                        onClick = { onNavigate(SettingsRoute.StorageBackup) },
                        colors = colors
                    )

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Lock,
                        title = K.paadhugaappu.tr(),
                        description = K.thaekkagathaiazhi.tr(),
                        onClick = { onNavigate(SettingsRoute.Security) },
                        colors = colors
                    )
                }
            }
        }

        // ── Section 4: About & Engine (3 items) ──
        item(key = "about_engine_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Code,
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

                    ElvanSettingsDivider(colors = colors)

                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.AutoAwesome,
                        title = K.navilMozhimatri.tr(),
                        description = K.navilMozhimatriDesc.tr(),
                        onClick = { onNavigate(SettingsRoute.NavilMozhimatri) },
                        colors = colors
                    )
                }
            }
        }
    }
}
