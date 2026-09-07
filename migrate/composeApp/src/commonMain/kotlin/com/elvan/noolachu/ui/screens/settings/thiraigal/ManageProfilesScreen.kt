package com.elvan.noolachu.ui.screens.settings.thiraigal

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
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
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
 * ManageProfilesScreen — Subpage for business profiles management.
 * Opened from the briefcase button in MerchantSettingsScreen with a bottom-up animation.
 */
@Composable
fun ManageProfilesScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val currentMode = LocalAppMode.current
    val ff = LocalAppFontFamily.current

    val profiles = NiruvanaTharavugalRepository.getAllProfiles(currentMode)
    val activeProfile = NiruvanaTharavugalRepository.getProfile(currentMode)

    var showNewProfileSheet by remember { mutableStateOf(false) }
    var profileToDelete by remember { mutableStateOf<NiruvanaTharavugal?>(null) }

    val deleteSuccessMsg = K.thannuruNeekkappattadhu.tr()

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            state = scrollState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                bottom = 48.dp + 72.dp
            ),
            verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
        ) {
            item(key = "spacer_top") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            if (profiles.isEmpty()) {
                item(key = "empty_state") {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
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
                }
            } else {
                item(key = "profiles_list") {
                    ElvanSectionContainer {
                        ElvanSettingsSection(colors = colors) {
                            profiles.forEachIndexed { index, profileItem ->
                                val isActive = profileItem.id == activeProfile.id
                                val primaryName = profileItem.getPrimary("niruvanathinPeyar")
                                    .ifEmpty { K.tharpoadhaiyaNiruvanam.tr() }

                                ElvanSettingsDisplayRow(
                                    title = if (isActive) K.tharpoadhaiyaNiruvanam.tr() else "",
                                    primaryValue = primaryName,
                                    secondaryValue = null,
                                    icon = MaterialSymbols.Rounded.Delete,
                                    iconColor = null,
                                    onEdit = { profileToDelete = profileItem },
                                    onTap = if (!isActive && profileItem.id != null) {
                                        {
                                            NiruvanaTharavugalRepository.setActiveProfile(currentMode, profileItem.id!!)
                                        }
                                    } else null,
                                    colors = colors
                                )
                                if (index < profiles.size - 1) {
                                    ElvanSettingsDivider(colors = colors)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Floating Action Button to add new profile (squircle shape with 48.dp bottom padding)
        if (profiles.size < NiruvanaTharavugalRepository.MAX_PROFILES) {
            FloatingActionButton(
                onClick = { showNewProfileSheet = true },
                shape = RoundedCornerShape(16.dp),
                containerColor = colors.textPrimary,
                contentColor = colors.surface,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(bottom = 48.dp, end = 20.dp)
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.Add,
                    contentDescription = "New Profile",
                    modifier = Modifier.size(24.dp)
                )
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
                    NiruvanaTharavugalRepository.deleteProfile(currentMode, id)
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
            mode = currentMode,
            onDismissRequest = { showNewProfileSheet = false },
            onSuccess = {
                showNewProfileSheet = false
            },
            colors = colors
        )
    }
}
