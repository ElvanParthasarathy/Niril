package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*

/**
 * User Profile Settings Screen matching Flutter's `payanar_amaippugal_thirai.dart` 1:1.
 * Supports First Name, Last Name, and Date of Birth with accordion animated expand.
 */
@Composable
fun UserProfileSettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    var mudhalPeyar by remember { mutableStateOf("பார்த்தசாரதி") }
    var irudhiPeyar by remember { mutableStateOf("ர") }
    var pirandhaThaedhi by remember { mutableStateOf("15/08/1990") }

    var editingSection by remember { mutableStateOf<String?>(null) }
    var tempVal by remember { mutableStateOf("") }

    fun beginEdit(section: String, initial: String) {
        editingSection = section
        tempVal = initial
    }

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
                // 1. First Name (Mudhal Peyar)
                ElvanSettingsAnimatedExpand(
                    isEditing = editingSection == "mudhalPeyar",
                    displayContent = {
                        ElvanSettingsDisplayRow(
                            title = K.mudhalPeyar.tr(),
                            primaryValue = mudhalPeyar,
                            onEdit = { beginEdit("mudhalPeyar", mudhalPeyar) },
                            colors = colors
                        )
                    },
                    editContent = {
                        ElvanSettingsEditContainer(
                            title = K.mudhalPeyar.tr(),
                            onCancel = { editingSection = null },
                            onSave = {
                                mudhalPeyar = tempVal
                                editingSection = null
                            },
                            colors = colors
                        ) {
                            ElvanSettingsTextField(
                                label = K.mudhalPeyar.tr(),
                                value = tempVal,
                                onValueChange = { tempVal = it },
                                colors = colors
                            )
                        }
                    }
                )
                ElvanSettingsDivider(colors = colors)

                // 2. Last Name (Irudhi Peyar)
                ElvanSettingsAnimatedExpand(
                    isEditing = editingSection == "irudhiPeyar",
                    displayContent = {
                        ElvanSettingsDisplayRow(
                            title = K.irudhiPeyar.tr(),
                            primaryValue = irudhiPeyar,
                            onEdit = { beginEdit("irudhiPeyar", irudhiPeyar) },
                            colors = colors
                        )
                    },
                    editContent = {
                        ElvanSettingsEditContainer(
                            title = K.irudhiPeyar.tr(),
                            onCancel = { editingSection = null },
                            onSave = {
                                irudhiPeyar = tempVal
                                editingSection = null
                            },
                            colors = colors
                        ) {
                            ElvanSettingsTextField(
                                label = K.irudhiPeyar.tr(),
                                value = tempVal,
                                onValueChange = { tempVal = it },
                                colors = colors
                            )
                        }
                    }
                )
                ElvanSettingsDivider(colors = colors)

                // 3. Date of Birth (Pirandha Thaedhi)
                ElvanSettingsAnimatedExpand(
                    isEditing = editingSection == "pirandhaThaedhi",
                    displayContent = {
                        ElvanSettingsDisplayRow(
                            title = K.pirandhaThaedhi.tr(),
                            primaryValue = pirandhaThaedhi,
                            onEdit = { beginEdit("pirandhaThaedhi", pirandhaThaedhi) },
                            colors = colors
                        )
                    },
                    editContent = {
                        ElvanSettingsEditContainer(
                            title = K.pirandhaThaedhi.tr(),
                            onCancel = { editingSection = null },
                            onSave = {
                                pirandhaThaedhi = tempVal
                                editingSection = null
                            },
                            colors = colors
                        ) {
                            ElvanSettingsTextField(
                                label = K.pirandhaThaedhi.tr(),
                                value = tempVal,
                                placeholder = "DD/MM/YYYY",
                                onValueChange = { tempVal = it },
                                colors = colors
                            )
                        }
                    }
                )
            }
        }
    }
}
