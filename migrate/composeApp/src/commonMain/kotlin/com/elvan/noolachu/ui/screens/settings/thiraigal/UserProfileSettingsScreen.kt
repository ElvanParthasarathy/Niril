package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.utils.DateUtils
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
 * User Profile Settings Screen matching Flutter's `payanar_amaippugal_thirai.dart` 1:1.
 * Supports First Name, Last Name, and Date of Birth with accordion animated expand.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UserProfileSettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    var mudhalPeyar by remember { mutableStateOf("பார்த்தசாரதி") }
    var irudhiPeyar by remember { mutableStateOf("ர") }
    var pirandhaThaedhi by remember { mutableStateOf("15/08/1990") }

    var editingSection by remember { mutableStateOf<String?>(null) }
    var tempVal by remember { mutableStateOf("") }
    val saveSuccessMsg = K.thannuruChaemikkappattadhu.tr()

    fun beginEdit(section: String, initial: String) {
        editingSection = section
        tempVal = initial
    }

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

        item(key = "profile_section") {
            ElvanSectionContainer {
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
                                ElvanSnackbar.show(saveSuccessMsg)
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
                                ElvanSnackbar.show(saveSuccessMsg)
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
                var showDatePicker by remember { mutableStateOf(false) }
                val initialMillis = remember(tempVal) {
                    DateUtils.parseToEpochMillis(tempVal) ?: DateUtils.parseToEpochMillis("15/08/1990")
                }
                val datePickerState = rememberDatePickerState(
                    initialSelectedDateMillis = initialMillis
                )

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
                                ElvanSnackbar.show(saveSuccessMsg)
                            },
                            colors = colors
                        ) {
                            Column(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalAlignment = Alignment.Start
                            ) {
                                Text(
                                    text = K.pirandhaThaedhi.tr(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Normal,
                                        letterSpacing = 0.3.sp
                                    ),
                                    color = colors.textPrimary.copy(alpha = 0.5f),
                                    modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
                                )

                                Surface(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(48.dp)
                                        .clip(RoundedCornerShape(100))
                                        .clickable(
                                            interactionSource = remember { MutableInteractionSource() },
                                            indication = ShellDefaults.ripple(colors, bounded = true),
                                            onClick = { showDatePicker = true }
                                        ),
                                    shape = RoundedCornerShape(100),
                                    color = colors.iconBg,
                                    shadowElevation = 0.dp
                                ) {
                                    Row(
                                        modifier = Modifier
                                            .fillMaxSize()
                                            .padding(horizontal = 20.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Icon(
                                            imageVector = MaterialSymbols.Rounded.CalendarToday,
                                            contentDescription = null,
                                            tint = colors.textPrimary.copy(alpha = 0.6f),
                                            modifier = Modifier.size(20.dp)
                                        )
                                        Spacer(modifier = Modifier.width(12.dp))
                                        Text(
                                            text = tempVal.ifEmpty { "DD/MM/YYYY" },
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 14.sp,
                                                fontWeight = FontWeight.Normal,
                                                color = if (tempVal.isEmpty()) colors.textPrimary.copy(alpha = 0.35f) else colors.textPrimary
                                            )
                                        )
                                    }
                                }
                            }

                            if (showDatePicker) {
                                DatePickerDialog(
                                    onDismissRequest = { showDatePicker = false },
                                    confirmButton = {
                                        TextButton(
                                            onClick = {
                                                datePickerState.selectedDateMillis?.let {
                                                    tempVal = DateUtils.formatEpochMillis(it)
                                                }
                                                showDatePicker = false
                                            }
                                        ) {
                                            Text(K.urudhi.tr(), color = colors.accent)
                                        }
                                    },
                                    dismissButton = {
                                        TextButton(onClick = { showDatePicker = false }) {
                                            Text(K.kaividu.tr(), color = colors.textPrimary.copy(alpha = 0.7f))
                                        }
                                    },
                                    colors = DatePickerDefaults.colors(
                                        containerColor = colors.surface
                                    )
                                ) {
                                    DatePicker(
                                        state = datePickerState,
                                        colors = DatePickerDefaults.colors(
                                            containerColor = colors.surface,
                                            titleContentColor = colors.textPrimary,
                                            headlineContentColor = colors.textPrimary,
                                            weekdayContentColor = colors.textPrimary.copy(alpha = 0.6f),
                                            subheadContentColor = colors.textPrimary.copy(alpha = 0.8f),
                                            yearContentColor = colors.textPrimary,
                                            currentYearContentColor = colors.accent,
                                            selectedYearContentColor = colors.background,
                                            selectedYearContainerColor = colors.accent,
                                            dayContentColor = colors.textPrimary,
                                            selectedDayContentColor = colors.background,
                                            selectedDayContainerColor = colors.accent,
                                            todayContentColor = colors.accent,
                                            todayDateBorderColor = colors.accent
                                        )
                                    )
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
