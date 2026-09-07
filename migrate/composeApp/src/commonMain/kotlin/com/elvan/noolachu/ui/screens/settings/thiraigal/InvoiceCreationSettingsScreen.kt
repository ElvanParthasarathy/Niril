package com.elvan.noolachu.ui.screens.settings.thiraigal

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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Invoice Creation Settings Screen matching Flutter's `uruvakku_amaippugal_thirai.dart` 1:1.
 * Dynamically handles Kooli (`kooli_uruvakku_amaippu.dart` with single language + PDF color theme)
 * and Pattu (`pattu_uruvakku_amaippu.dart` with dual language, bilingual toggle, GST split toggle).
 */
@Composable
fun InvoiceCreationSettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val currentMode = LocalAppMode.current
    val profile = NiruvanaTharavugalRepository.getProfile(currentMode)
    val isPattu = currentMode == AppMode.PATTU
    val ff = LocalAppFontFamily.current

    var isEditingLanguages by remember { mutableStateOf(false) }
    var tempPrimaryLang by remember { mutableStateOf(profile.mudhanMozhi) }
    var tempSecondaryLang by remember { mutableStateOf(profile.thunaiMozhi) }

    var isEditingTheme by remember { mutableStateOf(false) }
    var tempThemeColor by remember { mutableStateOf(profile.thoatraNiram.ifEmpty { "#388e3c" }) }

    @Composable
    fun getThemeName(hex: String): String {
        return when (hex.lowercase()) {
            "#388e3c" -> K.pachai.tr()
            "#6a1b9a" -> K.oodhaa.tr()
            else -> hex
        }
    }

    fun parseColor(hex: String): Color {
        return try {
            val cleanHex = hex.removePrefix("#")
            Color(cleanHex.toLong(16) or 0x00000000FF000000L)
        } catch (_: Exception) {
            Color(0xFF388E3C)
        }
    }

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = Dimens.ContentPadding,
            end = Dimens.ContentPadding,
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        // Top spacer driven by One UI collapsible header
        item(key = "shell_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }
        if (isPattu) {
            // ── Pattu Section 1: Languages ──
            item {
                ElvanSettingsSection(colors = colors) {
                    ElvanSettingsAnimatedExpand(
                        isEditing = isEditingLanguages,
                        displayContent = {
                            Column {
                                ElvanSimpleSettingsRow(
                                    title = K.mudhanmaiMozhi.tr(),
                                    description = if (profile.mudhanMozhi.lowercase().startsWith("ta")) K.thamizh.tr() else K.aangilam.tr(),
                                    trailing = {
                                        Surface(
                                            shape = CircleShape,
                                            color = colors.iconBg,
                                            modifier = Modifier
                                                .size(40.dp)
                                                .clip(CircleShape)
                                                .clickable(
                                                    interactionSource = remember { MutableInteractionSource() },
                                                    indication = ShellDefaults.ripple(colors, bounded = true),
                                                    onClick = {
                                                        tempPrimaryLang = profile.mudhanMozhi
                                                        tempSecondaryLang = profile.thunaiMozhi
                                                        isEditingLanguages = true
                                                    }
                                                )
                                        ) {
                                            Box(contentAlignment = Alignment.Center) {
                                                Icon(
                                                    imageVector = MaterialSymbols.Rounded.Edit,
                                                    contentDescription = K.thiruthu.tr(),
                                                    tint = colors.textPrimary.copy(alpha = 0.6f),
                                                    modifier = Modifier.size(20.dp)
                                                )
                                            }
                                        }
                                    },
                                    colors = colors
                                )

                                if (profile.iruMozhi) {
                                    ElvanSettingsDivider(colors = colors)
                                    ElvanSimpleSettingsRow(
                                        title = K.irandaamMozhi.tr(),
                                        description = if (profile.thunaiMozhi.lowercase().startsWith("ta")) K.thamizh.tr() else K.aangilam.tr(),
                                        colors = colors
                                    )
                                }
                            }
                        },
                        editContent = {
                            ElvanSettingsEditContainer(
                                title = K.mudhanmaiMozhi.tr(),
                                onCancel = { isEditingLanguages = false },
                                onSave = {
                                    val updated = profile.copy()
                                    updated.mudhanMozhi = tempPrimaryLang
                                    updated.thunaiMozhi = tempSecondaryLang
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                    isEditingLanguages = false
                                },
                                colors = colors
                            ) {
                                // Primary Language Picker
                                Text(
                                    text = K.mudhanmaiMozhi.tr(),
                                    style = TextStyle(fontFamily = ff, fontSize = 12.sp, color = colors.textPrimary.copy(alpha = 0.5f)),
                                    modifier = Modifier.padding(start = 8.dp, bottom = 6.dp)
                                )
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    FilterChip(
                                        selected = tempPrimaryLang == "ta",
                                        onClick = {
                                            tempPrimaryLang = "ta"
                                            if (tempSecondaryLang == "ta") tempSecondaryLang = "en"
                                        },
                                        label = { Text(K.thamizh.tr()) }
                                    )
                                    FilterChip(
                                        selected = tempPrimaryLang == "en",
                                        onClick = {
                                            tempPrimaryLang = "en"
                                            if (tempSecondaryLang == "en") tempSecondaryLang = "ta"
                                        },
                                        label = { Text(K.aangilam.tr()) }
                                    )
                                }

                                Spacer(modifier = Modifier.height(16.dp))

                                // Secondary Language Picker
                                Text(
                                    text = K.irandaamMozhi.tr(),
                                    style = TextStyle(fontFamily = ff, fontSize = 12.sp, color = colors.textPrimary.copy(alpha = 0.5f)),
                                    modifier = Modifier.padding(start = 8.dp, bottom = 6.dp)
                                )
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    FilterChip(
                                        selected = tempSecondaryLang == "ta",
                                        onClick = {
                                            tempSecondaryLang = "ta"
                                            if (tempPrimaryLang == "ta") tempPrimaryLang = "en"
                                        },
                                        label = { Text(K.thamizh.tr()) }
                                    )
                                    FilterChip(
                                        selected = tempSecondaryLang == "en",
                                        onClick = {
                                            tempSecondaryLang = "en"
                                            if (tempPrimaryLang == "en") tempPrimaryLang = "ta"
                                        },
                                        label = { Text(K.aangilam.tr()) }
                                    )
                                }
                            }
                        }
                    )
                }
            }

            // ── Pattu Section 2: Switches ──
            item {
                ElvanSettingsSection(colors = colors) {
                    // Bilingual Mode Toggle
                    ElvanSimpleSettingsRow(
                        title = K.irumozhiMurai.tr(),
                        trailing = {
                            ElvanSettingsSwitch(
                                checked = profile.iruMozhi,
                                onCheckedChange = {
                                    val updated = profile.copy()
                                    updated.iruMozhi = it
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                },
                                colors = colors
                            )
                        },
                        colors = colors
                    )
                    ElvanSettingsDivider(colors = colors)

                    // GST Split Toggle
                    ElvanSimpleSettingsRow(
                        title = K.gstpirippugal.tr(),
                        trailing = {
                            ElvanSettingsSwitch(
                                checked = profile.gstPirippugal,
                                onCheckedChange = {
                                    val updated = profile.copy()
                                    updated.gstPirippugal = it
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                },
                                colors = colors
                            )
                        },
                        colors = colors
                    )
                }
            }
        } else {
            // ── Kooli Mode ──
            item {
                ElvanSettingsSection(colors = colors) {
                    // 1. Language Row
                    ElvanSettingsAnimatedExpand(
                        isEditing = isEditingLanguages,
                        displayContent = {
                            ElvanSimpleSettingsRow(
                                title = K.pattiyalPatrucheettuMozhi.tr(),
                                description = if (profile.mudhanMozhi.lowercase().startsWith("ta")) K.thamizh.tr() else K.aangilam.tr(),
                                trailing = {
                                    Surface(
                                        shape = CircleShape,
                                        color = colors.iconBg,
                                        modifier = Modifier
                                            .size(40.dp)
                                            .clip(CircleShape)
                                            .clickable(
                                                interactionSource = remember { MutableInteractionSource() },
                                                indication = ShellDefaults.ripple(colors, bounded = true),
                                                onClick = {
                                                    tempPrimaryLang = profile.mudhanMozhi
                                                    isEditingLanguages = true
                                                }
                                            )
                                    ) {
                                        Box(contentAlignment = Alignment.Center) {
                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.Edit,
                                                contentDescription = K.thiruthu.tr(),
                                                tint = colors.textPrimary.copy(alpha = 0.6f),
                                                modifier = Modifier.size(20.dp)
                                            )
                                        }
                                    }
                                },
                                colors = colors
                            )
                        },
                        editContent = {
                            ElvanSettingsEditContainer(
                                title = K.pattiyalPatrucheettuMozhi.tr(),
                                onCancel = { isEditingLanguages = false },
                                onSave = {
                                    val updated = profile.copy()
                                    updated.mudhanMozhi = tempPrimaryLang
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                    isEditingLanguages = false
                                },
                                colors = colors
                            ) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    FilterChip(
                                        selected = tempPrimaryLang == "ta",
                                        onClick = { tempPrimaryLang = "ta" },
                                        label = { Text(K.thamizh.tr()) }
                                    )
                                    FilterChip(
                                        selected = tempPrimaryLang == "en",
                                        onClick = { tempPrimaryLang = "en" },
                                        label = { Text(K.aangilam.tr()) }
                                    )
                                }
                            }
                        }
                    )
                    ElvanSettingsDivider(colors = colors)

                    // 2. PDF Theme Row
                    val currentThemeColorHex = profile.thoatraNiram.ifEmpty { "#388e3c" }
                    val currentColor = parseColor(currentThemeColorHex)

                    ElvanSettingsAnimatedExpand(
                        isEditing = isEditingTheme,
                        displayContent = {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp, vertical = 14.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = K.pdfThoatram.tr(),
                                        style = TextStyle(
                                            fontFamily = ff,
                                            fontSize = 15.sp,
                                            fontWeight = FontWeight.Medium
                                        ),
                                        color = colors.textPrimary
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Box(
                                            modifier = Modifier
                                                .size(12.dp)
                                                .clip(CircleShape)
                                                .background(currentColor)
                                        )
                                        Spacer(modifier = Modifier.width(8.dp))
                                        Text(
                                            text = getThemeName(currentThemeColorHex),
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 13.sp,
                                                fontWeight = FontWeight.Normal
                                            ),
                                            color = colors.textPrimary.copy(alpha = 0.6f)
                                        )
                                    }
                                }

                                Surface(
                                    shape = CircleShape,
                                    color = colors.iconBg,
                                    modifier = Modifier
                                        .size(40.dp)
                                        .clip(CircleShape)
                                        .clickable(
                                            interactionSource = remember { MutableInteractionSource() },
                                            indication = ShellDefaults.ripple(colors, bounded = true),
                                            onClick = {
                                                tempThemeColor = currentThemeColorHex
                                                isEditingTheme = true
                                            }
                                        )
                                ) {
                                    Box(contentAlignment = Alignment.Center) {
                                        Icon(
                                            imageVector = MaterialSymbols.Rounded.Edit,
                                            contentDescription = K.thiruthu.tr(),
                                            tint = colors.textPrimary.copy(alpha = 0.6f),
                                            modifier = Modifier.size(20.dp)
                                        )
                                    }
                                }
                            }
                        },
                        editContent = {
                            ElvanSettingsEditContainer(
                                title = K.pdfThoatram.tr(),
                                onCancel = { isEditingTheme = false },
                                onSave = {
                                    val updated = profile.copy()
                                    updated.thoatraNiram = tempThemeColor
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                    isEditingTheme = false
                                },
                                colors = colors
                            ) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                                ) {
                                    // Green Option (#388e3c)
                                    val isGreenSelected = tempThemeColor.equals("#388e3c", ignoreCase = true)
                                    Surface(
                                        shape = RoundedCornerShape(12.dp),
                                        color = if (isGreenSelected) colors.iconBg else Color.Transparent,
                                        modifier = Modifier
                                            .border(
                                                width = if (isGreenSelected) 1.5.dp else 1.dp,
                                                color = if (isGreenSelected) colors.accent else colors.border,
                                                shape = RoundedCornerShape(12.dp)
                                            )
                                            .clip(RoundedCornerShape(12.dp))
                                            .clickable { tempThemeColor = "#388e3c" }
                                            .padding(horizontal = 16.dp, vertical = 10.dp)
                                    ) {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            Box(
                                                modifier = Modifier
                                                    .size(16.dp)
                                                    .clip(CircleShape)
                                                    .background(Color(0xFF388E3C))
                                            )
                                            Spacer(modifier = Modifier.width(8.dp))
                                            Text(
                                                text = K.pachai.tr(),
                                                style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.Medium),
                                                color = colors.textPrimary
                                            )
                                        }
                                    }

                                    // Purple Option (#6a1b9a)
                                    val isPurpleSelected = tempThemeColor.equals("#6a1b9a", ignoreCase = true)
                                    Surface(
                                        shape = RoundedCornerShape(12.dp),
                                        color = if (isPurpleSelected) colors.iconBg else Color.Transparent,
                                        modifier = Modifier
                                            .border(
                                                width = if (isPurpleSelected) 1.5.dp else 1.dp,
                                                color = if (isPurpleSelected) colors.accent else colors.border,
                                                shape = RoundedCornerShape(12.dp)
                                            )
                                            .clip(RoundedCornerShape(12.dp))
                                            .clickable { tempThemeColor = "#6a1b9a" }
                                            .padding(horizontal = 16.dp, vertical = 10.dp)
                                    ) {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            Box(
                                                modifier = Modifier
                                                    .size(16.dp)
                                                    .clip(CircleShape)
                                                    .background(Color(0xFF6A1B9A))
                                            )
                                            Spacer(modifier = Modifier.width(8.dp))
                                            Text(
                                                text = K.oodhaa.tr(),
                                                style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.Medium),
                                                color = colors.textPrimary
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}
