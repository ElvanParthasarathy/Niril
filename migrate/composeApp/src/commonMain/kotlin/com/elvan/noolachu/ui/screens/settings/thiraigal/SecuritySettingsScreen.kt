package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Security Settings Screen matching Flutter's `paadhugaappu_amaippugal_thirai.dart` and
 * `kanakku_paadhugaappu_pagudhi.dart` 1:1 pixel-perfect.
 * Features Sync App, Sign Out, and 2-Step Erase App Data with modal flows.
 */
@Composable
fun SecuritySettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    val scope = rememberCoroutineScope()

    var showSyncLoading by remember { mutableStateOf(false) }
    var showSignOutConfirm by remember { mutableStateOf(false) }
    var showSignOutLoading by remember { mutableStateOf(false) }

    var showEraseStep1 by remember { mutableStateOf(false) }
    var showEraseStep2 by remember { mutableStateOf(false) }
    var showEraseLoading by remember { mutableStateOf(false) }

    var emailInput by remember { mutableStateOf("") }
    var passwordInput by remember { mutableStateOf("") }

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
                // 1. Sync App (Orunginai Cheyali)
                ElvanSettingsRow(
                    icon = MaterialSymbols.Rounded.Sync,
                    title = K.orunginaiCheyaliPtn.tr(),
                    description = K.orunginaiCheyaliVilakkam.tr(),
                    onClick = {
                        showSyncLoading = true
                        scope.launch {
                            delay(800)
                            showSyncLoading = false
                        }
                    },
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // 2. Sign Out (Veliyaeru)
                ElvanSettingsRow(
                    icon = MaterialSymbols.Rounded.Logout,
                    title = K.veliyaeru.tr(),
                    description = K.cheyaliyilirundhuVeliyaeravum.tr(),
                    onClick = { showSignOutConfirm = true },
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // 3. Erase App Data (Cheyalith Tharavai Azhi)
                ElvanSettingsRow(
                    icon = MaterialSymbols.Rounded.DeleteForever,
                    title = K.cheyalithTharavaiAzhi.tr(),
                    description = K.tharavaiazhi.tr(),
                    onClick = {
                        emailInput = ""
                        passwordInput = ""
                        showEraseStep1 = true
                    },
                    titleColor = Color(0xFFBA1A1A),
                    iconTint = Color(0xFFBA1A1A),
                    colors = colors
                )
            }
        }
    }

    // ── Sync Loading Modal ──
    if (showSyncLoading) {
        AlertDialog(
            onDismissRequest = {},
            confirmButton = {},
            text = {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    CircularProgressIndicator(
                        color = colors.textPrimary,
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.5.dp
                    )
                    Spacer(modifier = Modifier.width(16.dp))
                    Text(
                        text = K.orunginaikkiRadhu.tr(),
                        style = TextStyle(fontFamily = ff, fontSize = 14.sp),
                        color = colors.textPrimary
                    )
                }
            },
            shape = RoundedCornerShape(20.dp),
            containerColor = colors.surface
        )
    }

    // ── Sign Out Confirmation Modal ──
    if (showSignOutConfirm) {
        ElvanActionSheet(
            title = K.veliyaeraVaendumaa.tr(),
            cancelText = K.kaividuPtn.tr(),
            confirmText = K.veliyaeruPtn.tr(),
            confirmColor = Color(0xFFBA1A1A),
            onDismissRequest = { showSignOutConfirm = false },
            onConfirm = {
                showSignOutConfirm = false
                showSignOutLoading = true
                scope.launch {
                    delay(1000)
                    showSignOutLoading = false
                }
            },
            colors = colors
        )
    }

    if (showSignOutLoading) {
        AlertDialog(
            onDismissRequest = {},
            confirmButton = {},
            text = {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    CircularProgressIndicator(
                        color = colors.textPrimary,
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.5.dp
                    )
                    Spacer(modifier = Modifier.width(16.dp))
                    Text(
                        text = K.veliyaerugiradhu.tr(),
                        style = TextStyle(fontFamily = ff, fontSize = 14.sp),
                        color = colors.textPrimary
                    )
                }
            },
            shape = RoundedCornerShape(20.dp),
            containerColor = colors.surface
        )
    }

    // ── Erase Step 1: Email Confirmation ──
    if (showEraseStep1) {
        ElvanActionSheet(
            title = K.cheyalithTharavaiAzhi.tr(),
            cancelText = K.kaividuPtn.tr(),
            confirmText = K.thodaravum.tr(),
            customContent = {
                ElvanSettingsTextField(
                    label = K.minnanjal.tr(),
                    value = emailInput,
                    onValueChange = { emailInput = it },
                    placeholder = K.minnanjalaiUrudhiseiga.tr(),
                    colors = colors
                )
            },
            onDismissRequest = { showEraseStep1 = false },
            onConfirm = {
                showEraseStep1 = false
                showEraseStep2 = true
            },
            colors = colors
        )
    }

    // ── Erase Step 2: Password Confirmation ──
    if (showEraseStep2) {
        ElvanActionSheet(
            title = K.kadavuchollaiUllidavum.tr(),
            cancelText = K.kaividuPtn.tr(),
            confirmText = K.tharavaiAzhiPtn.tr(),
            confirmColor = Color(0xFFBA1A1A),
            customContent = {
                ElvanSettingsTextField(
                    label = K.kadavuchol.tr(),
                    value = passwordInput,
                    onValueChange = { passwordInput = it },
                    placeholder = K.kadavuchol.tr(),
                    colors = colors
                )
            },
            onDismissRequest = { showEraseStep2 = false },
            onConfirm = {
                showEraseStep2 = false
                showEraseLoading = true
                scope.launch {
                    delay(1500)
                    showEraseLoading = false
                }
            },
            colors = colors
        )
    }

    if (showEraseLoading) {
        AlertDialog(
            onDismissRequest = {},
            confirmButton = {},
            text = {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    CircularProgressIndicator(
                        color = Color(0xFFBA1A1A),
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.5.dp
                    )
                    Spacer(modifier = Modifier.width(16.dp))
                    Text(
                        text = K.azhikkiradhu.tr(),
                        style = TextStyle(fontFamily = ff, fontSize = 14.sp),
                        color = colors.textPrimary
                    )
                }
            },
            shape = RoundedCornerShape(20.dp),
            containerColor = colors.surface
        )
    }
}
