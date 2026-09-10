package com.elvan.noolachu.ui.screens.settings

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
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
import com.elvan.noolachu.ui.navigation.MaterialSymbols
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
        if (currentRoute == SettingsRoute.ManageProfiles) {
            currentRoute = SettingsRoute.Merchant
        } else if (currentRoute != SettingsRoute.Hub) {
            currentRoute = SettingsRoute.Hub
        } else {
            onBack()
        }
    }

    AppBackHandler(enabled = true) {
        handleBack()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.background)
    ) {
        AnimatedContent(
            targetState = currentRoute,
            modifier = Modifier
                .fillMaxSize()
                .background(colors.background),
            transitionSpec = {
                if (targetState == SettingsRoute.ManageProfiles) {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Up,
                        animationSpec = spring(stiffness = Spring.StiffnessLow, dampingRatio = Spring.DampingRatioNoBouncy)
                    ) togetherWith fadeOut(targetAlpha = 0.9f, animationSpec = tween(durationMillis = 50))
                } else if (initialState == SettingsRoute.ManageProfiles) {
                    fadeIn(initialAlpha = 0.9f) togetherWith slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Down,
                        animationSpec = spring(stiffness = Spring.StiffnessLow, dampingRatio = Spring.DampingRatioNoBouncy)
                    )
                } else {
                    val isForward = targetState != SettingsRoute.Hub
                    if (isForward) {
                        slideIntoContainer(
                            towards = AnimatedContentTransitionScope.SlideDirection.Left,
                            animationSpec = spring(stiffness = Spring.StiffnessLow, dampingRatio = Spring.DampingRatioNoBouncy)
                        ) togetherWith fadeOut(targetAlpha = 0.9f, animationSpec = tween(durationMillis = 50))
                    } else {
                        fadeIn(initialAlpha = 0.9f) togetherWith slideOutOfContainer(
                            towards = AnimatedContentTransitionScope.SlideDirection.Right,
                            animationSpec = spring(stiffness = Spring.StiffnessLow, dampingRatio = Spring.DampingRatioNoBouncy)
                        )
                    }
                }
            },
            label = "SettingsRouteTransition"
        ) { route ->
            val scrollState = if (route == SettingsRoute.Hub) hubScrollState else subpageScrollStates.getOrPut(route) { LazyListState() }
            val pageTitle = when (route) {
                SettingsRoute.Hub -> K.amaippugal.tr()
                SettingsRoute.Display -> K.thoatram.tr()
                SettingsRoute.Language -> K.cheyaliMozhi.tr()
                SettingsRoute.Merchant -> K.niruvanam.tr()
                SettingsRoute.ManageProfiles -> K.kaiyaalu.tr()
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
                SettingsRoute.ElvanNavil -> K.navilMozhimatri.tr()
                SettingsRoute.NavilMozhimatri -> K.navilMozhimatri.tr()
            }

            val leadingIcon = if (route == SettingsRoute.ManageProfiles) {
                MaterialSymbols.Rounded.Close
            } else {
                null
            }

            ElvanSubShell(
                title = pageTitle,
                onBack = handleBack,
                leadingIcon = leadingIcon,
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
                    SettingsRoute.Merchant -> MerchantSettingsScreen(
                        onNavigateToManageProfiles = { currentRoute = SettingsRoute.ManageProfiles },
                        scrollState = scrollState,
                        colors = colors
                    )
                    SettingsRoute.ManageProfiles -> ManageProfilesScreen(scrollState = scrollState, colors = colors)
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
                    SettingsRoute.ElvanNavil -> NavilMozhimatriScreen(scrollState = scrollState, colors = colors)
                    SettingsRoute.NavilMozhimatri -> NavilMozhimatriScreen(scrollState = scrollState, colors = colors)
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
