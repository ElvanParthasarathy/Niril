package com.elvan.noolachu

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import com.elvan.noolachu.core.mode.ProvideModeContext
import com.elvan.noolachu.localization.ProvideAppLanguage
import com.elvan.noolachu.theme.NoolachuTheme
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanBottomSheetController
import com.elvan.noolachu.ui.components.shell.ElvanBottomSheetHost
import com.elvan.noolachu.ui.components.shell.LocalElvanBottomSheetController
import com.elvan.noolachu.ui.screens.home.HomeScreen

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
                        HomeScreen()
                        ElvanBottomSheetHost(bottomSheetController)
                    }
                }
            }
        }
    }
}
