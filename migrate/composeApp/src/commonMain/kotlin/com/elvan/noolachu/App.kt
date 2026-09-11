package com.elvan.noolachu

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.compose.ui.zIndex
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.core.mode.ProvideModeContext
import com.elvan.noolachu.localization.ProvideAppLanguage
import com.elvan.noolachu.theme.NoolachuTheme
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.dev.ElvanUruvakkunarMenu
import com.elvan.noolachu.ui.components.shell.ElvanBottomSheetController
import com.elvan.noolachu.ui.components.shell.ElvanBottomSheetHost
import com.elvan.noolachu.ui.components.shell.LocalElvanBottomSheetController
import com.elvan.noolachu.ui.screens.home.HomeScreen
import com.elvan.noolachu.ui.screens.mode.ModeSelectorScreen
import com.elvan.noolachu.theme.ThemeManager
import com.elvan.noolachu.ui.screens.mode.ModeSelectorContent
import com.elvan.noolachu.ui.screens.splash.SplashBackground
import com.elvan.noolachu.ui.screens.splash.SplashContent
import kotlinx.coroutines.delay

@Composable
fun App() {
    var isSplashVisible by rememberSaveable { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        delay(600)
        isSplashVisible = false
    }

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
                        AnimatedContent(
                            targetState = ModeManager.hasSelectedModeAtStartup,
                            transitionSpec = {
                                fadeIn(animationSpec = tween(280)) togetherWith
                                    fadeOut(animationSpec = tween(200))
                            },
                            label = "startup_flow"
                        ) { hasSelectedMode ->
                            if (!hasSelectedMode) {
                                SplashBackground(isDark = ThemeManager.isDark()) {
                                    AnimatedContent(
                                        targetState = isSplashVisible,
                                        transitionSpec = {
                                            fadeIn(animationSpec = tween(280)) togetherWith
                                                fadeOut(animationSpec = tween(200))
                                        },
                                        label = "splash_to_mode_selector"
                                    ) { showSplash ->
                                        if (showSplash) {
                                            SplashContent()
                                        } else {
                                            ModeSelectorContent(
                                                onModeSelected = { selectedMode ->
                                                    ModeManager.setMode(selectedMode)
                                                },
                                                canDismiss = false
                                            )
                                        }
                                    }
                                }
                            } else {
                                Box(modifier = Modifier.fillMaxSize()) {
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
                            }
                        }

                        ElvanBottomSheetHost(bottomSheetController)

                        Box(modifier = Modifier.fillMaxSize().zIndex(999f)) {
                            ElvanUruvakkunarMenu()
                        }
                    }
                }
            }
        }
    }
}
