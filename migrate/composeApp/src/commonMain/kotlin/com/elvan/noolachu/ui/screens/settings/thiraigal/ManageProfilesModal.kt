package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * ManageProfilesModal — Fullscreen modal for business profiles management.
 * 1:1 port of Flutter's `showManageProfilesModal` (`thannuru_maeladukkugal.dart`).
 */
@Composable
fun ManageProfilesModal(
    mode: AppMode,
    onDismissRequest: () -> Unit,
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current

    val profiles = NiruvanaTharavugalRepository.getAllProfiles(mode)
    val activeProfile = NiruvanaTharavugalRepository.getProfile(mode)

    var showNewProfileSheet by remember { mutableStateOf(false) }
    var profileToDelete by remember { mutableStateOf<NiruvanaTharavugal?>(null) }

    val deleteSuccessMsg = K.thannuruNeekkappattadhu.tr()
    val deletePrompt = K.thannuruvaiMutrilumNeekkavaa.tr()
    val cancelLabel = K.kaividu.tr()
    val deleteLabel = K.azhi.tr()

    Dialog(
        onDismissRequest = onDismissRequest,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Scaffold(
            containerColor = colors.background,
            floatingActionButton = {
                if (profiles.size < NiruvanaTharavugalRepository.MAX_PROFILES) {
                    FloatingActionButton(
                        onClick = { showNewProfileSheet = true },
                        shape = CircleShape,
                        containerColor = colors.textPrimary,
                        contentColor = colors.surface,
                        modifier = Modifier.padding(bottom = 32.dp, end = 8.dp)
                    ) {
                        Icon(
                            imageVector = MaterialSymbols.Rounded.Add,
                            contentDescription = "New Profile",
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }
            }
        ) { paddingValues ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .statusBarsPadding()
                    .navigationBarsPadding()
            ) {
                // Top Bar with Back icon and title
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = onDismissRequest) {
                        Icon(
                            imageVector = MaterialSymbols.Rounded.ArrowBack,
                            contentDescription = "Back",
                            tint = colors.textPrimary
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = K.kaiyaalu.tr(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.SemiBold
                        ),
                        color = colors.textPrimary
                    )
                }

                if (profiles.isEmpty()) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = K.thannurukkalIllai.tr(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 16.sp,
                                color = colors.textPrimary.copy(alpha = 0.5f)
                            )
                        )
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        item {
                            ElvanSettingsSection {
                                profiles.forEachIndexed { index, profileItem ->
                                    val isActive = profileItem.id == activeProfile.id
                                    val primaryName = profileItem.getPrimary("niruvanathinPeyar")
                                        .ifEmpty { K.tharpoadhaiyaNiruvanam.tr() }
                                    val secondaryName = if (profileItem.iruMozhi) {
                                        profileItem.getSecondary("niruvanathinPeyar")
                                    } else null

                                    ElvanSettingsDisplayRow(
                                        title = if (isActive) K.tharpoadhaiyaNiruvanam.tr() else "",
                                        primaryValue = primaryName,
                                        secondaryValue = secondaryName,
                                        icon = MaterialSymbols.Rounded.DeleteForever,
                                        iconColor = if (!isActive) MaterialTheme.colorScheme.error else null,
                                        onEdit = if (!isActive) {
                                            { profileToDelete = profileItem }
                                        } else null,
                                        onTap = if (!isActive && profileItem.id != null) {
                                            {
                                                NiruvanaTharavugalRepository.setActiveProfile(mode, profileItem.id!!)
                                            }
                                        } else null
                                    )
                                    if (index < profiles.size - 1) {
                                        ElvanSettingsDivider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Delete Confirm Action Sheet
        profileToDelete?.let { targetProfile ->
            com.elvan.noolachu.ui.components.shell.maeladukkugal.ElvanAzhippuUrudhiMaeladukku(
                onDismissRequest = { profileToDelete = null },
                onConfirm = {
                    val id = targetProfile.id
                    if (id != null) {
                        NiruvanaTharavugalRepository.deleteProfile(mode, id)
                        ElvanSnackbar.show(deleteSuccessMsg)
                    }
                    profileToDelete = null
                },
                colors = colors
            )
        }

        // New Profile Action Sheet
        if (showNewProfileSheet) {
            NewProfileBottomSheet(
                mode = mode,
                onDismissRequest = { showNewProfileSheet = false },
                onSuccess = {
                    showNewProfileSheet = false
                }
            )
        }
    }
}
