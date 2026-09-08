package com.elvan.noolachu

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
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
import com.elvan.noolachu.theme.ThemeManager
import com.elvan.noolachu.ui.screens.mode.ModeSelectorContent
import com.elvan.noolachu.ui.screens.splash.SplashBackground
import com.elvan.noolachu.ui.screens.splash.SplashContent
import kotlinx.coroutines.delay

@Composable
fun App() {
    var isSplashVisible by remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        delay(1600)
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
                        if (!ModeManager.hasSelectedModeAtStartup) {
                            SplashBackground(isDark = ThemeManager.isDark()) {
                                ModeSelectorContent(
                                    onModeSelected = { selectedMode ->
                                        ModeManager.setMode(selectedMode)
                                    },
                                    canDismiss = false
                                )

                                AnimatedVisibility(
                                    visible = isSplashVisible,
                                    modifier = Modifier.fillMaxSize().zIndex(200f),
                                    enter = fadeIn(),
                                    exit = fadeOut(animationSpec = tween(durationMillis = 400))
                                ) {
                                    SplashContent()
                                }
                            }
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

                            // Animated Splash Screen overlay for already-selected mode startup
                            AnimatedVisibility(
                                visible = isSplashVisible,
                                modifier = Modifier.zIndex(200f),
                                enter = fadeIn(),
                                exit = fadeOut(animationSpec = tween(durationMillis = 400))
                            ) {
                                SplashBackground(isDark = ThemeManager.isDark()) {
                                    SplashContent()
                                }
                            }
                        }

                        ElvanBottomSheetHost(bottomSheetController)
                    }
                }
            }
        }
    }
}
