package com.elvan.noolachu.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.vector.ImageVector
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr

enum class NavTab(
    val icon: ImageVector,
    val activeIcon: ImageVector,
    val titleKey: String
) {
    Home(
        icon = MaterialSymbols.Rounded.Home,
        activeIcon = MaterialSymbols.Rounded.HomeFill,
        titleKey = K.mugappu
    ),
    Invoices(
        icon = MaterialSymbols.Rounded.Description,
        activeIcon = MaterialSymbols.Rounded.DescriptionFill,
        titleKey = K.pattiyal
    ),
    Receipts(
        icon = MaterialSymbols.Rounded.Notes,
        activeIcon = MaterialSymbols.Rounded.NotesFill,
        titleKey = K.patrucheettu
    );

    @Composable
    fun getLocalizedLabel(): String = titleKey.tr()
}
