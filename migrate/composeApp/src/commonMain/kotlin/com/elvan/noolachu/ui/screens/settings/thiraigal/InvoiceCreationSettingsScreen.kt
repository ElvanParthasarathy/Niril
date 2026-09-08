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

    val bottomSheet = LocalElvanBottomSheetController.current
    val pdfThemeTitle = K.pdfThoatram.tr()
    val saveSuccessMsg = K.thannuruChaemikkappattadhu.tr()

    val greenLabel = K.pachai.tr()
    val purpleLabel = K.oodhaa.tr()
    val tamilLabel = K.thamizh.tr()
    val englishLabel = K.aangilam.tr()

    fun getLanguageName(code: String): String {
        return if (code.lowercase().startsWith("ta")) tamilLabel else englishLabel
    }

    fun getThemeName(hex: String): String {
        return when (hex.lowercase()) {
            "#388e3c" -> greenLabel
            "#6a1b9a" -> purpleLabel
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

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            state = scrollState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(
            start = Dimens.ContentPadding,
            end = Dimens.ContentPadding,
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
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
                                    description = getLanguageName(profile.mudhanMozhi),
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
                                        description = getLanguageName(profile.thunaiMozhi),
                                        colors = colors
                                    )
                                }
                            }
                        },
                        editContent = {
                            ElvanSettingsEditContainer(
                                onCancel = { isEditingLanguages = false },
                                onSave = {
                                    val updated = profile.copy()
                                    updated.mudhanMozhi = tempPrimaryLang
                                    updated.thunaiMozhi = tempSecondaryLang
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                    isEditingLanguages = false
                                    ElvanSnackbar.show(saveSuccessMsg)
                                },
                                colors = colors
                            ) {
                                // Primary Language Dropdown (Pill triggering bottom sheet)
                                ElvanSettingsDropdown(
                                    label = K.mudhanmaiMozhi.tr(),
                                    value = tempPrimaryLang,
                                    items = listOf("ta", "en"),
                                    itemLabelBuilder = { getLanguageName(it) },
                                    onChanged = { selectedLang ->
                                        if (selectedLang == tempSecondaryLang) {
                                            tempSecondaryLang = tempPrimaryLang
                                        }
                                        tempPrimaryLang = selectedLang
                                    },
                                    colors = colors
                                )

                                if (profile.iruMozhi) {
                                    Spacer(modifier = Modifier.height(16.dp))
                                    // Secondary Language Dropdown (Pill triggering bottom sheet)
                                    ElvanSettingsDropdown(
                                        label = K.irandaamMozhi.tr(),
                                        value = tempSecondaryLang,
                                        items = listOf("ta", "en"),
                                        itemLabelBuilder = { getLanguageName(it) },
                                        onChanged = { selectedLang ->
                                            if (selectedLang == tempPrimaryLang) {
                                                tempPrimaryLang = tempSecondaryLang
                                            }
                                            tempSecondaryLang = selectedLang
                                        },
                                        colors = colors
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
                                    ElvanSnackbar.show(saveSuccessMsg)
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
                                    ElvanSnackbar.show(saveSuccessMsg)
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
                                description = getLanguageName(profile.mudhanMozhi),
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
                                onCancel = { isEditingLanguages = false },
                                onSave = {
                                    val updated = profile.copy()
                                    updated.mudhanMozhi = tempPrimaryLang
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                    isEditingLanguages = false
                                    ElvanSnackbar.show(saveSuccessMsg)
                                },
                                colors = colors
                            ) {
                                ElvanSettingsDropdown(
                                    label = K.pattiyalPatrucheettuMozhi.tr(),
                                    value = tempPrimaryLang,
                                    items = listOf("ta", "en"),
                                    itemLabelBuilder = { getLanguageName(it) },
                                    onChanged = { tempPrimaryLang = it },
                                    colors = colors
                                )
                            }
                        }
                    )
                    ElvanSettingsDivider(colors = colors)

                    // 2. PDF Theme Row
                    val currentThemeColorHex = profile.thoatraNiram.ifEmpty { "#388e3c" }
                    val currentColor = parseColor(currentThemeColorHex)

                    ElvanSettingsDisplayRow(
                        title = K.pdfThoatram.tr(),
                        primaryValue = getThemeName(currentThemeColorHex),
                        primaryWidget = {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier
                                        .size(14.dp)
                                        .clip(CircleShape)
                                        .background(currentColor)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = getThemeName(currentThemeColorHex),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Medium
                                    ),
                                    color = colors.textPrimary
                                )
                            }
                        },
                        onEdit = {
                            bottomSheet.showSelection(
                                title = pdfThemeTitle,
                                items = listOf("#388e3c", "#6a1b9a"),
                                currentValue = profile.thoatraNiram.ifEmpty { "#388e3c" },
                                itemLabelBuilder = { getThemeName(it) },
                                leadingBuilder = { colorHex ->
                                    Box(
                                        modifier = Modifier
                                            .size(24.dp)
                                            .clip(CircleShape)
                                            .background(parseColor(colorHex))
                                    )
                                },
                                onSelected = { selectedColor ->
                                    val updated = profile.copy()
                                    updated.thoatraNiram = selectedColor
                                    NiruvanaTharavugalRepository.updateProfile(currentMode, updated)
                                    ElvanSnackbar.show(saveSuccessMsg)
                                }
                            )
                        },
                        colors = colors
                    )
                }
            }
        }
    }
}
}
