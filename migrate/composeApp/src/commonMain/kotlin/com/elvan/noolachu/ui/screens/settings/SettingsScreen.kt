package com.elvan.noolachu.ui.screens.settings

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
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
import com.elvan.noolachu.data.database.DatabaseProvider
import com.elvan.noolachu.localization.*
import com.elvan.noolachu.theme.*
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * One UI styled Settings Screen matching Neram's settings layout.
 */
@Composable
fun SettingsScreen(
    onBack: () -> Unit = {},
    scrollState: LazyListState = LocalElvanScrollState.current ?: rememberLazyListState()
) {
    val currentMode = LocalAppMode.current
    val billingConfig = AchuMozhiManager.getConfig(currentMode)
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current
    var showSignOutDialog by remember { mutableStateOf(false) }

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = Dimens.SubpageContentPaddingBottom),
        verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
    ) {
        item(key = "spacer_top") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        // 1. Mode Switcher & Database Capsule Card (Big Pill)
        item(key = "mode_pill_card") {
            ElvanSectionContainer {
                ElvanProfilePillCard(
                    title = currentMode.displayName(),
                    subtitle = "${K.tharavuthalam.tr()}: ${DatabaseProvider.currentDatabaseName()}",
                    onClick = { ModeManager.toggleMode() },
                    iconWidget = {
                        Box(
                            modifier = Modifier
                                .size(32.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .border(1.5.dp, colors.textPrimary, RoundedCornerShape(8.dp)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = if (currentMode == AppMode.KOOLI) "கூ" else "ப",
                                color = colors.textPrimary,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.offset(y = (-1).dp)
                            )
                        }
                    },
                    trailing = {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(100))
                                .border(1.dp, colors.accent.copy(alpha = 0.5f), RoundedCornerShape(100))
                                .padding(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Text(
                                text = "${K.maatru.tr()} ⇄",
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = colors.accent
                                )
                            )
                        }
                    },
                    colors = colors
                )
            }
        }

        // 2. Settings Group: தோற்றம் (Appearance / Theme)
        item(key = "appearance_group") {
            ElvanSectionContainer {
                ElvanSettingsSection(
                    title = K.thoatram.tr(),
                    colors = colors
                ) {
                    ElvanRadioSettingsRow(
                        title = K.thaaniyangki.tr(),
                        description = K.thaaniyangkiVilakkam.tr(),
                        value = ThemeMode.SYSTEM,
                        groupValue = ThemeManager.currentThemeMode,
                        onSelected = { ThemeManager.setThemeMode(it) },
                        colors = colors
                    )
                    ElvanSettingsDivider(colors = colors)
                    ElvanRadioSettingsRow(
                        title = K.olirNilai.tr(),
                        value = ThemeMode.LIGHT,
                        groupValue = ThemeManager.currentThemeMode,
                        onSelected = { ThemeManager.setThemeMode(it) },
                        colors = colors
                    )
                    ElvanSettingsDivider(colors = colors)
                    ElvanRadioSettingsRow(
                        title = K.irulNilai.tr(),
                        value = ThemeMode.DARK,
                        groupValue = ThemeManager.currentThemeMode,
                        onSelected = { ThemeManager.setThemeMode(it) },
                        colors = colors
                    )
                }
            }
        }

        // 3. Settings Group: செயலி மொழி (UI Language - Screen only)
        item(key = "ui_language_group") {
            ElvanSectionContainer {
                ElvanSettingsSection(
                    title = K.cheyaliMozhi.tr(),
                    colors = colors
                ) {
                    Language.entries.forEachIndexed { index, lang ->
                        if (index > 0) ElvanSettingsDivider(colors = colors)
                        ElvanRadioSettingsRow(
                            title = lang.displayName,
                            description = if (lang == Language.TAMIL) K.senthamizh.tr() else K.aangilam.tr(),
                            value = lang,
                            groupValue = LanguageManager.currentLanguage,
                            onSelected = { LanguageManager.setLanguage(it) },
                            colors = colors
                        )
                    }
                }
            }
        }

        // 4. Settings Group: பட்டியல் / அச்சு மொழி (Print & Billing Language - Brick Wall Decoupled)
        item(key = "billing_language_group") {
            ElvanSectionContainer {
                ElvanSettingsSection(
                    title = "${K.pattiyalmozhi.tr()} (${currentMode.displayName()})",
                    colors = colors
                ) {
                    BillingLanguage.entries.forEachIndexed { index, bLang ->
                        if (index > 0) ElvanSettingsDivider(colors = colors)
                        ElvanRadioSettingsRow(
                            title = bLang.displayName,
                            description = "${K.munvaraivu.tr()}: ${if (bLang == BillingLanguage.TAMIL) "பட்டியல்" else "Invoice"}",
                            value = bLang,
                            groupValue = billingConfig.primaryLanguage,
                            onSelected = { AchuMozhiManager.setPrimaryLanguage(currentMode, it) },
                            colors = colors
                        )
                    }
                }
            }
        }

        // 5. Settings Group: தரவுத்தளம் (Database & Storage)
        item(key = "database_group") {
            ElvanSectionContainer {
                ElvanSettingsSection(
                    title = K.tharavuthalam.tr(),
                    colors = colors
                ) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Storage,
                        title = "${K.thanithTharavuthalam.tr()} (${currentMode.displayName()})",
                        description = DatabaseProvider.currentDatabaseName(),
                        onClick = {},
                        colors = colors
                    )
                    ElvanSettingsDivider(colors = colors)
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.SwapHoriz,
                        title = K.endhachCheyalmurai.tr(),
                        description = K.thanithTharavuVilakkam.tr(),
                        onClick = { ModeManager.toggleMode() },
                        customTrailing = {
                            Text(
                                text = if (ModeManager.isKooli) K.noolachuPattu.tr() else K.noolachuKooli.tr(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = colors.accent
                                )
                            )
                        },
                        colors = colors
                    )
                }
            }
        }

        // 6. Settings Group: செயலி குறித்து (About & Brand)
        item(key = "about_group") {
            ElvanSectionContainer {
                ElvanSettingsSection(
                    title = K.kurithu.tr(),
                    colors = colors
                ) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Info,
                        title = K.appPeyar.tr(),
                        description = "${K.pathippu.tr()} 1.0.0",
                        onClick = {},
                        colors = colors
                    )
                    ElvanSettingsDivider(colors = colors)
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Palette,
                        title = K.elvanSansFont.tr(),
                        description = K.senthamizhKolkaei.tr(),
                        onClick = {},
                        colors = colors
                    )
                }
            }
        }

        // 7. Settings Group: வெளியேறு (Sign Out)
        item(key = "signout_group") {
            ElvanSectionContainer {
                ElvanSettingsSection(
                    colors = colors
                ) {
                    ElvanSettingsRow(
                        icon = MaterialSymbols.Rounded.Logout,
                        title = K.veliyaeru.tr(),
                        description = K.veliyaeruVilakkam.tr(),
                        onClick = { showSignOutDialog = true },
                        titleColor = Color(0xFFBA1A1A),
                        iconTint = Color(0xFFBA1A1A),
                        colors = colors
                    )
                }
            }
        }
    }

    // Sign Out Action Sheet Popup (Matching Neram)
    if (showSignOutDialog) {
        ElvanActionSheet(
            title = K.veliyaeruUrudhi.tr(),
            cancelText = K.kaividu.tr(),
            confirmText = K.veliyaeru.tr(),
            onDismissRequest = { showSignOutDialog = false },
            onConfirm = {
                showSignOutDialog = false
                onBack()
            },
            confirmColor = Color(0xFFBA1A1A),
            colors = colors
        )
    }
}
