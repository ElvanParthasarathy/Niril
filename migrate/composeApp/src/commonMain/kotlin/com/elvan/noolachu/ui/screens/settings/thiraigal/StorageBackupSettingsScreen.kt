package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
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
import com.elvan.noolachu.core.backup.getNirilBackupService
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Storage & Backup Screen matching Flutter's `chaemippu_matrum_kaappu_thirai.dart` and
 * `chaemippu_matrum_kaappu_pagudhi.dart` 1:1 pixel-perfect.
 * Features `StorageProjectionPill`, storage stats, backup trigger, and Kooli/Pattu data grids.
 */
@Composable
fun StorageBackupSettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    val scope = rememberCoroutineScope()
    val backupService = remember { getNirilBackupService() }

    var showBackupConfirm by remember { mutableStateOf(false) }
    var isBackingUp by remember { mutableStateOf(false) }
    var backupStats by remember { mutableStateOf(backupService.getBackupStats()) }
    var totalDbSize by remember { mutableStateOf(backupService.getTotalDatabaseSize().coerceAtLeast(128 * 1024L)) }
    var lastBackupTime by remember { 
        mutableStateOf(
            if (backupStats != null) "உள்ளது" else null
        ) 
    }
    val backupSuccessMsg = K.tharavuchaemippuvetri.tr()
    val backupSize = backupStats?.sizeBytes ?: 0L

    fun formatBytes(bytes: Long): String {
        if (bytes <= 0) return "0 B"
        val kb = bytes / 1024.0
        val mb = kb / 1024.0
        return when {
            mb >= 1.0 -> "${(mb * 100).toInt() / 100.0} MB"
            kb >= 1.0 -> "${(kb * 100).toInt() / 100.0} KB"
            else -> "$bytes B"
        }
    }

    val maxSpace = 1024.0 * 1024.0 * 1024.0 // 1 GB
    val progress = (totalDbSize / maxSpace).toFloat().coerceIn(0.02f, 1f)


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

        // ── 1. Storage Projection Pill ──
        item {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(24.dp)),
                shape = RoundedCornerShape(24.dp),
                color = colors.surface,
                shadowElevation = 0.dp
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 14.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Bottom
                    ) {
                        Text(
                            text = K.tharavuthalam.tr(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold
                            ),
                            color = colors.textPrimary
                        )
                        Text(
                            text = "${formatBytes(totalDbSize)} / 1 GB",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Medium
                            ),
                            color = colors.textPrimary.copy(alpha = 0.5f)
                        )
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    val animatedProgress by animateFloatAsState(
                        targetValue = progress,
                        animationSpec = tween(durationMillis = 1000)
                    )

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(28.dp)
                            .clip(RoundedCornerShape(100.dp))
                            .background(colors.textPrimary.copy(alpha = 0.08f))
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth(animatedProgress)
                                .fillMaxHeight()
                                .clip(RoundedCornerShape(100.dp))
                                .background(colors.textPrimary)
                        )
                    }
                }
            }
        }

        // ── 2. Storage Actions Section ──
        item {
            ElvanSettingsSection(colors = colors) {
                // Used Storage
                ElvanSettingsRow(
                    icon = MaterialSymbols.Rounded.Folder,
                    title = K.payanpaduthiyaChaemippu.tr(),
                    description = "${formatBytes(totalDbSize)} ${K.tharavuthalam.tr()}\n${formatBytes(backupSize)} ${K.kaappu.tr()}",
                    onClick = {},
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // Last Auto Backup
                ElvanSettingsRow(
                    icon = MaterialSymbols.Rounded.Schedule,
                    title = K.kadaisiThaaniyakkaKaappu.tr(),
                    description = lastBackupTime ?: K.idhuvuraiKaappuIllai.tr(),
                    onClick = {},
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // Backup Data Button
                ElvanSettingsRow(
                    icon = MaterialSymbols.Rounded.CloudUpload,
                    title = K.tharavuKaappuChei.tr(),
                    description = K.ungalTharavaiChaemikkavum.tr(),
                    onClick = { showBackupConfirm = true },
                    colors = colors
                )
            }
        }

        // ── 3. Mode Databases Grid Section ──
        item {
            ElvanSettingsSection(colors = colors) {
                // Kooli Data Grid
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 14.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Surface(
                            shape = CircleShape,
                            color = colors.iconBg,
                            modifier = Modifier.size(36.dp)
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(
                                    imageVector = AppSvgs.coolieMode,
                                    contentDescription = null,
                                    tint = colors.textPrimary,
                                    modifier = Modifier.size(18.dp)
                                )
                            }
                        }
                        Spacer(modifier = Modifier.width(14.dp))
                        Text(
                            text = K.kooliTharavugal.tr(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Medium
                            ),
                            color = colors.textPrimary
                        )
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    // 2x2 Data Grid
                    val gridStyle = TextStyle(fontFamily = ff, fontSize = 12.sp, color = colors.textPrimary.copy(alpha = 0.5f))
                    Row(modifier = Modifier.fillMaxWidth().padding(start = 50.dp)) {
                        Text("0 ${K.pattiyalgal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                        Text("0 ${K.patrucheettugal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(modifier = Modifier.fillMaxWidth().padding(start = 50.dp)) {
                        Text("0 ${K.vaangunargal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                        Text("0 ${K.porutkal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                    }
                }

                ElvanSettingsDivider(colors = colors)

                // Pattu Data Grid
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 14.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Surface(
                            shape = CircleShape,
                            color = colors.iconBg,
                            modifier = Modifier.size(36.dp)
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(
                                    imageVector = AppSvgs.silkMode,
                                    contentDescription = null,
                                    tint = colors.textPrimary,
                                    modifier = Modifier.size(18.dp)
                                )
                            }
                        }
                        Spacer(modifier = Modifier.width(14.dp))
                        Text(
                            text = K.pattuTharavugal.tr(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Medium
                            ),
                            color = colors.textPrimary
                        )
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    // 2x2 Data Grid
                    val gridStyle = TextStyle(fontFamily = ff, fontSize = 12.sp, color = colors.textPrimary.copy(alpha = 0.5f))
                    Row(modifier = Modifier.fillMaxWidth().padding(start = 50.dp)) {
                        Text("0 ${K.pattiyalgal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                        Text("0 ${K.patrucheettugal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(modifier = Modifier.fillMaxWidth().padding(start = 50.dp)) {
                        Text("0 ${K.vaangunargal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                        Text("0 ${K.porutkal.tr()}", style = gridStyle, modifier = Modifier.weight(1f))
                    }
                }
            }
        }
    }

    // Confirmation & Loading Sheets
    if (showBackupConfirm) {
        ElvanActionSheet(
            title = K.tharavuKaappu.tr(),
            cancelText = K.kaividuPtn.tr(),
            confirmText = K.kaappuCheiPtn.tr(),
            onDismissRequest = { showBackupConfirm = false },
            onConfirm = {
                showBackupConfirm = false
                isBackingUp = true
                scope.launch {
                    delay(300)
                    val success = backupService.createBackup()
                    isBackingUp = false
                    if (success) {
                        backupStats = backupService.getBackupStats()
                        totalDbSize = backupService.getTotalDatabaseSize().coerceAtLeast(128 * 1024L)
                        lastBackupTime = "இன்று"
                        ElvanSnackbar.show(backupSuccessMsg)
                    } else {
                        ElvanSnackbar.show("காப்புப்பிரதி தோல்வியடைந்தது")
                    }
                }
            },
            colors = colors
        )
    }

    if (isBackingUp) {
        ElvanLoadingOverlay(
            text = K.chaemikkappadugiradhu.tr(),
            colors = colors
        )
    }
}
