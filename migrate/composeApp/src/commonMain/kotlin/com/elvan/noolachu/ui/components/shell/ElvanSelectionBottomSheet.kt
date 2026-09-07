package com.elvan.noolachu.ui.components.shell

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.core.platform.ConfigureDialogWindow
import com.elvan.noolachu.ui.components.shell.maeladukkugal.*

/**
 * ElvanSelectionBottomSheet — Flutter-matching selection bottom sheet.
 * Replicates `showElvanSelectionBottomSheet` and `ElvanSelectionBottomSheet` in Flutter (`elvan_kizh_maeladukku.dart`).
 * Modular architecture using:
 * - `ElvanMaeladukkuThalaipu` (Header)
 * - `ElvanMaeladukkuThaedal` (Cupertino Search Pill)
 * - `ElvanMaeladukkuUrupadi` (List Item with Monochrome Checkmark)
 * - `ElvanMaeladukkuPudhiyaPothan` (Centered Add New Action)
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun <T> ElvanSelectionBottomSheet(
    title: String,
    items: List<T>,
    currentValue: T?,
    onSelected: (T) -> Unit,
    onDismissRequest: () -> Unit,
    modifier: Modifier = Modifier,
    colors: ShellColors = rememberShellColors(),
    itemLabelBuilder: (T) -> String,
    subtitleBuilder: ((T) -> String?)? = null,
    leadingBuilder: (@Composable (T) -> Unit)? = null,
    showSearch: Boolean = false,
    searchFilter: ((T, String) -> Boolean)? = null,
    onRequestAddNew: (() -> Unit)? = null,
    addNewLabel: String? = null
) {
    val isDark = colors.isDark
    val sheetBg = if (isDark) Color(0xFF111111) else Color.White
    var searchQuery by remember { mutableStateOf("") }

    val filteredItems = remember(items, searchQuery) {
        if (searchQuery.isBlank()) {
            items
        } else if (searchFilter != null) {
            items.filter { searchFilter(it, searchQuery) }
        } else {
            items.filter { item ->
                itemLabelBuilder(item).contains(searchQuery, ignoreCase = true) ||
                        (subtitleBuilder?.invoke(item)?.contains(searchQuery, ignoreCase = true) == true)
            }
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismissRequest,
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
        containerColor = sheetBg,
        scrimColor = Color.Black.copy(alpha = 0.45f),
        dragHandle = { BottomSheetDefaults.DragHandle() },
        modifier = modifier
    ) {
        ConfigureDialogWindow(isDark = isDark)
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .imePadding()
        ) {
            // 1. Title matching Flutter's ElvanMaeladukkuThalaipu
            ElvanMaeladukkuThalaipu(
                title = title,
                colors = colors
            )

            // 2. Search pill if enabled matching Flutter's ElvanMaeladukkuThaedal
            if (showSearch) {
                ElvanMaeladukkuThaedal(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    colors = colors
                )
            }

            // 3. Items list with items matching Flutter's ElvanMaeladukkuUrupadi
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 420.dp)
                    .padding(bottom = 8.dp)
            ) {
                items(filteredItems) { item ->
                    val isSelected = item == currentValue
                    val subtitle = subtitleBuilder?.invoke(item)

                    ElvanMaeladukkuUrupadi(
                        title = itemLabelBuilder(item),
                        subtitle = subtitle,
                        isSelected = isSelected,
                        onTap = {
                            onSelected(item)
                            onDismissRequest()
                        },
                        leading = leadingBuilder?.let { { it(item) } },
                        colors = colors
                    )
                }
            }

            // 4. Optional "+ Add New" button matching Flutter's ElvanMaeladukkuPudhiyaPothan
            if (onRequestAddNew != null) {
                ElvanMaeladukkuPudhiyaPothan(
                    onTap = {
                        onDismissRequest()
                        onRequestAddNew()
                    },
                    label = addNewLabel ?: com.elvan.noolachu.localization.K.pudhiyaChaerkkai.tr(),
                    colors = colors
                )
            }
        }
    }
}
