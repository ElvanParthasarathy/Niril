package com.elvan.noolachu

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.zIndex
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.core.mode.ProvideModeContext
import com.elvan.noolachu.localization.ProvideAppLanguage
import com.elvan.noolachu.theme.NoolachuTheme
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanBottomSheetController
import com.elvan.noolachu.ui.components.shell.ElvanBottomSheetHost
import com.elvan.noolachu.ui.components.shell.LocalElvanBottomSheetController
import com.elvan.noolachu.ui.screens.home.HomeScreen
import com.elvan.noolachu.ui.screens.mode.ModeSelectorScreen

@Composable
fun App() {
    NoolachuTheme {
        ProvideAppLanguage {
            ProvideModeContext {
                val bottomSheetController = remember { ElvanBottomSheetController() }
                val colors = rememberShellColors()
                CompositionLocalProvider(
                    LocalElvanBottomSheetController provides bottomSheetController
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(colors.background)
                    ) {
                        if (!ModeManager.hasSelectedModeAtStartup) {
                            ModeSelectorScreen(
                                onModeSelected = { selectedMode ->
                                    ModeManager.setMode(selectedMode)
                                },
                                canDismiss = false
                            )
                        } else {
                            HomeScreen()

                            AnimatedVisibility(
                                visible = ModeManager.isModeSelectorOpen,
                                modifier = Modifier.zIndex(100f),
                                enter = fadeIn(animationSpec = tween(300)),
                                exit = fadeOut(animationSpec = tween(250))
                            ) {
                                ModeSelectorScreen(
                                    onModeSelected = { selectedMode ->
                                        ModeManager.setMode(selectedMode)
                                    },
                                    onDismiss = {
                                        ModeManager.closeModeSelector()
                                    },
                                    canDismiss = true
                                )
                            }
                        }

                        ElvanBottomSheetHost(bottomSheetController)
                    }
                }
            }
        }
    }
}
