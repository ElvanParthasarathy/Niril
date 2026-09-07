package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.background
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
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Kooli Identity & Branding Screen matching Flutter's `kooli_niruvana_adaiyalangal_thirai.dart` 1:1.
 * Supports Logo and Signature (with official signatory name) editing.
 */
@Composable
fun KooliIdentityScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val profile = NiruvanaTharavugalRepository.getProfile(AppMode.KOOLI)
    val ff = LocalAppFontFamily.current

    var editingSection by remember { mutableStateOf<String?>(null) }
    var tempImagePath by remember { mutableStateOf<String?>(null) }
    var tempSignatoryName by remember { mutableStateOf("") }

    val logoPath = profile.oavuru.ifEmpty { null }
    val signaturePath = profile.kaiyoppam.ifEmpty { null }
    val signatoryName = profile.oppamPeyar
    val saveSuccessMsg = K.thannuruChaemikkappattadhu.tr()

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
                // 1. Logo (Niruvanathin Oavuru)
                ElvanSettingsAnimatedExpand(
                    isEditing = editingSection == "logo",
                    displayContent = {
                        ElvanSettingsDisplayRow(
                            title = K.niruvanathinOavuru.tr(),
                            primaryValue = if (logoPath != null) K.niruvanathinOavuru.tr() else K.oavuruIllai.tr(),
                            onEdit = {
                                tempImagePath = logoPath
                                editingSection = "logo"
                            },
                            colors = colors
                        )
                    },
                    editContent = {
                        ElvanSettingsEditContainer(
                            title = K.niruvanathinOavuru.tr(),
                            onCancel = { editingSection = null },
                            onSave = {
                                val updated = profile.copy()
                                updated.oavuru = tempImagePath ?: ""
                                NiruvanaTharavugalRepository.updateProfile(AppMode.KOOLI, updated)
                                editingSection = null
                                ElvanSnackbar.show(saveSuccessMsg)
                            },
                            colors = colors
                        ) {
                            ImageUploadBox(
                                imagePath = tempImagePath,
                                onPick = { tempImagePath = "content://media/logo_sample.png" },
                                onClear = { tempImagePath = null },
                                colors = colors
                            )
                        }
                    }
                )
                ElvanSettingsDivider(colors = colors)

                // 2. Signature (Kaiyoppam & Oppam Peyar)
                ElvanSettingsAnimatedExpand(
                    isEditing = editingSection == "kaiyoppam",
                    displayContent = {
                        ElvanSettingsDisplayRow(
                            title = K.kaiyoppam.tr(),
                            primaryValue = if (signaturePath != null) signatoryName.ifEmpty { "கையொப்பம் உள்ளது" } else K.kaiyoppamIllai.tr(),
                            onEdit = {
                                tempImagePath = signaturePath
                                tempSignatoryName = signatoryName
                                editingSection = "kaiyoppam"
                            },
                            colors = colors
                        )
                    },
                    editContent = {
                        ElvanSettingsEditContainer(
                            title = K.kaiyoppam.tr(),
                            onCancel = { editingSection = null },
                            onSave = {
                                val updated = profile.copy()
                                updated.kaiyoppam = tempImagePath ?: ""
                                updated.oppamPeyar = tempSignatoryName
                                NiruvanaTharavugalRepository.updateProfile(AppMode.KOOLI, updated)
                                editingSection = null
                                ElvanSnackbar.show(saveSuccessMsg)
                            },
                            colors = colors
                        ) {
                            ImageUploadBox(
                                imagePath = tempImagePath,
                                onPick = { tempImagePath = "content://media/sig_sample.png" },
                                onClear = { tempImagePath = null },
                                colors = colors
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            ElvanSettingsTextField(
                                label = K.aluvalkaiyoppam.tr(),
                                value = tempSignatoryName,
                                onValueChange = { tempSignatoryName = it },
                                placeholder = K.aluvalkaiyoppam.tr(),
                                colors = colors
                            )
                        }
                    }
                )
            }
        }
    }
}

@Composable
private fun ImageUploadBox(
    imagePath: String?,
    onPick: () -> Unit,
    onClear: () -> Unit,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    val hasImage = !imagePath.isNullOrEmpty()

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(120.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(colors.iconBg)
            .clickable(onClick = { if (!hasImage) onPick() }),
        contentAlignment = Alignment.Center
    ) {
        if (hasImage) {
            Text(
                text = "படம் பதிவேற்றப்பட்டது ($imagePath)",
                style = TextStyle(fontFamily = ff, fontSize = 13.sp, color = colors.textPrimary)
            )
            // Delete button at top-right
            Surface(
                shape = CircleShape,
                color = colors.surface,
                shadowElevation = 2.dp,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(8.dp)
                    .size(32.dp)
                    .clip(CircleShape)
                    .clickable(onClick = onClear)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = MaterialSymbols.Rounded.DeleteForever,
                        contentDescription = K.azhi.tr(),
                        tint = Color(0xFFBA1A1A),
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        } else {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.CloudUpload,
                    contentDescription = null,
                    tint = colors.textPrimary.copy(alpha = 0.4f),
                    modifier = Modifier.size(32.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = K.padhivaetru.tr(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    ),
                    color = colors.textPrimary.copy(alpha = 0.5f)
                )
            }
        }
    }
}
