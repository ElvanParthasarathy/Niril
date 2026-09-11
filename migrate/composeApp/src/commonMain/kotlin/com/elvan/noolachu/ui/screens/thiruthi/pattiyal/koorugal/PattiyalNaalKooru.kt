package com.elvan.noolachu.ui.screens.thiruthi.pattiyal.koorugal

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
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
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiThalaippu

/**
 * Tappable date display pill that opens a DatePickerDialog.
 * Matches Flutter's `pattiyal_naal_kooru.dart` 1:1.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PattiyalNaalKooru(
    selectedDate: Long,
    onDateChanged: (Long) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    var isPickerOpen by remember { mutableStateOf(false) }
    val containerBg = colors.iconBg

    Column(modifier = modifier.fillMaxWidth()) {
        if (!label.isNullOrBlank()) {
            ElvanThiruthiThalaippu(label = label)
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
                .clip(RoundedCornerShape(100.dp))
                .background(containerBg)
                .clickable { isPickerOpen = true }
                .padding(horizontal = 20.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = DateUtils.formatEpochMillis(selectedDate).preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = colors.textPrimary
                    )
                )

                Icon(
                    imageVector = MaterialSymbols.Rounded.CalendarToday,
                    contentDescription = null,
                    tint = colors.textSecondary,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }

    if (isPickerOpen) {
        val datePickerState = rememberDatePickerState(initialSelectedDateMillis = selectedDate)
        val dialogBg = if (isDark) Color(0xFF1E1E1E) else Color.White

        DatePickerDialog(
            onDismissRequest = { isPickerOpen = false },
            confirmButton = {
                TextButton(
                    onClick = {
                        datePickerState.selectedDateMillis?.let { onDateChanged(it) }
                        isPickerOpen = false
                    }
                ) {
                    Text(
                        text = K.urudhi.tr(),
                        style = TextStyle(fontFamily = ff, fontWeight = FontWeight.Bold, color = colors.accent)
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { isPickerOpen = false }) {
                    Text(
                        text = K.kaividu.tr(),
                        style = TextStyle(fontFamily = ff, color = colors.textSecondary)
                    )
                }
            },
            colors = DatePickerDefaults.colors(
                containerColor = dialogBg
            )
        ) {
            DatePicker(
                state = datePickerState,
                colors = DatePickerDefaults.colors(
                    containerColor = dialogBg,
                    selectedDayContainerColor = colors.accent,
                    todayDateBorderColor = colors.accent
                )
            )
        }
    }
}
