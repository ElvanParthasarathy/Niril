package com.elvan.noolachu.ui.screens.settings

import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanActionSheet
import com.elvan.noolachu.ui.components.shell.ElvanSubShell
import com.elvan.noolachu.ui.screens.settings.thiraigal.*

/**
 * Master One UI Settings Screen with subpage routing and Brick Wall architecture.
 */
@Composable
fun SettingsScreen(
    onBack: () -> Unit = {}
) {
    var currentRoute by remember { mutableStateOf<SettingsRoute>(SettingsRoute.Hub) }
    var showSignOutDialog by remember { mutableStateOf(false) }
    val colors = rememberShellColors()

    val hubScrollState = rememberLazyListState()
    val subpageScrollState = rememberLazyListState()

    val handleBack: () -> Unit = {
        if (currentRoute != SettingsRoute.Hub) {
            currentRoute = SettingsRoute.Hub
        } else {
            onBack()
        }
    }

    AppBackHandler(enabled = true) {
        handleBack()
    }

    val pageTitle = when (currentRoute) {
        SettingsRoute.Hub -> K.amaippugal.tr()
        SettingsRoute.Display -> K.thoatram.tr()
        SettingsRoute.Language -> K.cheyaliMozhi.tr()
        SettingsRoute.Merchant -> K.niruvanaAmaippugal.tr()
        SettingsRoute.KooliIdentity -> K.kooliNiruvanaAdaiyaalangal.tr()
        SettingsRoute.PattuIdentity -> K.pattuNiruvanaAdaiyaalangal.tr()
        SettingsRoute.Address -> K.mugavari.tr()
        SettingsRoute.Bank -> K.vangi.tr()
        SettingsRoute.InvoiceCreation -> K.uruvaakkuPtn.tr()
        SettingsRoute.UserProfile -> K.payanar.tr()
        SettingsRoute.StorageBackup -> K.chaemippuMatrumKaappu.tr()
        SettingsRoute.Security -> K.paadhugaappu.tr()
        SettingsRoute.AboutDeveloper -> K.menporulVadivaalar.tr()
        SettingsRoute.AboutApp -> K.cheyaliPatri.tr()
    }

    ElvanSubShell(
        title = pageTitle,
        onBack = handleBack,
        scrollState = if (currentRoute == SettingsRoute.Hub) hubScrollState else subpageScrollState
    ) {
        when (currentRoute) {
            SettingsRoute.Hub -> SettingsHubScreen(
                onNavigate = { currentRoute = it },
                onSignOutClick = { showSignOutDialog = true },
                scrollState = hubScrollState,
                colors = colors
            )
            SettingsRoute.Display -> DisplaySettingsScreen(colors)
            SettingsRoute.Language -> LanguageSettingsScreen(colors)
            SettingsRoute.Merchant -> MerchantSettingsScreen(colors)
            SettingsRoute.KooliIdentity -> KooliIdentityScreen(colors)
            SettingsRoute.PattuIdentity -> PattuIdentityScreen(colors)
            SettingsRoute.Address -> AddressSettingsScreen(colors)
            SettingsRoute.Bank -> BankSettingsScreen(colors)
            SettingsRoute.InvoiceCreation -> InvoiceCreationSettingsScreen(colors)
            SettingsRoute.UserProfile -> UserProfileSettingsScreen(colors)
            SettingsRoute.StorageBackup -> StorageBackupSettingsScreen(colors)
            SettingsRoute.Security -> SecuritySettingsScreen(colors)
            SettingsRoute.AboutDeveloper -> AboutDeveloperScreen(colors)
            SettingsRoute.AboutApp -> AboutAppScreen(colors)
        }
    }

    if (showSignOutDialog) {
        ElvanActionSheet(
            title = K.veliyaeruUrudhi.tr(),
            cancelText = K.kaividu.tr(),
            confirmText = K.veliyaeru.tr(),
            onDismissRequest = { showSignOutDialog = false },
            onConfirm = {
                showSignOutDialog = false
                onBack()
            },
            confirmColor = Color(0xFFBA1A1A),
            colors = colors
        )
    }
}
