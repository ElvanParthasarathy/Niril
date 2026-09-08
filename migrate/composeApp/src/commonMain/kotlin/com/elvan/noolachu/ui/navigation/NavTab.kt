package com.elvan.noolachu.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.vector.ImageVector
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr

enum class NavTab(
    val icon: ImageVector,
    val activeIcon: ImageVector,
    val titleKey: String,
    val headerTitleKey: String = titleKey
) {
    Home(
        icon = MaterialSymbols.Rounded.Home,
        activeIcon = MaterialSymbols.Rounded.HomeFill,
        titleKey = K.mugappu,
        headerTitleKey = K.niril
    ),
    Create(
        icon = MaterialSymbols.Rounded.AddCircle,
        activeIcon = MaterialSymbols.Rounded.AddCircle,
        titleKey = K.aakku,
        headerTitleKey = K.uruvaakkuPtn
    ),
    Products(
        icon = MaterialSymbols.Rounded.Inventory2,
        activeIcon = MaterialSymbols.Rounded.Inventory2,
        titleKey = K.porul,
        headerTitleKey = K.porutkal
    ),
    Customers(
        icon = MaterialSymbols.Rounded.Person,
        activeIcon = MaterialSymbols.Rounded.Person,
        titleKey = K.vaangunar,
        headerTitleKey = K.vaangunargal
    );

    @Composable
    fun getLocalizedLabel(): String = titleKey.tr()

    @Composable
    fun getLocalizedHeader(): String = headerTitleKey.tr()
}
