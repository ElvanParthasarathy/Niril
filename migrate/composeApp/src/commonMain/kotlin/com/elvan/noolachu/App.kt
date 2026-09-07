package com.elvan.noolachu

import androidx.compose.runtime.Composable
import com.elvan.noolachu.core.mode.ProvideModeContext
import com.elvan.noolachu.localization.ProvideAppLanguage
import com.elvan.noolachu.theme.NoolachuTheme
import com.elvan.noolachu.ui.screens.home.HomeScreen

@Composable
fun App() {
    NoolachuTheme {
        ProvideAppLanguage {
            ProvideModeContext {
                HomeScreen()
            }
        }
    }
}
