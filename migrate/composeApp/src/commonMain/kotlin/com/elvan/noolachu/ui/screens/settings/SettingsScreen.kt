package com.elvan.noolachu.ui.screens.settings

import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Transitions
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanActionSheet
import com.elvan.noolachu.ui.components.shell.ElvanSnackbarHost
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
    val subpageScrollStates = remember { mutableStateMapOf<SettingsRoute, LazyListState>() }

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

    Box(modifier = Modifier.fillMaxSize()) {
        AnimatedContent(
            targetState = currentRoute,
            modifier = Modifier.fillMaxSize(),
            transitionSpec = {
                Transitions.sharedAxisX(forward = targetState != SettingsRoute.Hub)
            },
            label = "SettingsRouteTransition"
        ) { route ->
            val scrollState = if (route == SettingsRoute.Hub) hubScrollState else subpageScrollStates.getOrPut(route) { LazyListState() }
            val pageTitle = when (route) {
                SettingsRoute.Hub -> K.amaippugal.tr()
                SettingsRoute.Display -> K.thoatram.tr()
                SettingsRoute.Language -> K.cheyaliMozhi.tr()
                SettingsRoute.Merchant -> K.niruvanam.tr()
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
            scrollState = scrollState
        ) {
            when (route) {
                SettingsRoute.Hub -> SettingsHubScreen(
                    onNavigate = { currentRoute = it },
                    onSignOutClick = { showSignOutDialog = true },
                    scrollState = scrollState,
                    colors = colors
                )
                SettingsRoute.Display -> DisplaySettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.Language -> LanguageSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.Merchant -> MerchantSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.KooliIdentity -> KooliIdentityScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.PattuIdentity -> PattuIdentityScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.Address -> AddressSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.Bank -> BankSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.InvoiceCreation -> InvoiceCreationSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.UserProfile -> UserProfileSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.StorageBackup -> StorageBackupSettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.Security -> SecuritySettingsScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.AboutDeveloper -> AboutDeveloperScreen(scrollState = scrollState, colors = colors)
                SettingsRoute.AboutApp -> AboutAppScreen(scrollState = scrollState, colors = colors)
            }
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

    ElvanSnackbarHost(colors = colors)
    }
}
