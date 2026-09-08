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
        icon = MaterialSymbols.CustomNav.Home,
        activeIcon = MaterialSymbols.CustomNav.HomeFill,
        titleKey = K.mugappu,
        headerTitleKey = K.niril
    ),
    Create(
        icon = MaterialSymbols.CustomNav.Create,
        activeIcon = MaterialSymbols.CustomNav.CreateFill,
        titleKey = K.aakku,
        headerTitleKey = K.uruvaakkuPtn
    ),
    Products(
        icon = MaterialSymbols.CustomNav.Products,
        activeIcon = MaterialSymbols.CustomNav.ProductsFill,
        titleKey = K.porul,
        headerTitleKey = K.porutkal
    ),
    Customers(
        icon = MaterialSymbols.CustomNav.Customers,
        activeIcon = MaterialSymbols.CustomNav.CustomersFill,
        titleKey = K.vaangunar,
        headerTitleKey = K.vaangunargal
    );

    @Composable
    fun getLocalizedLabel(): String = titleKey.tr()

    @Composable
    fun getLocalizedHeader(): String = headerTitleKey.tr()
}
