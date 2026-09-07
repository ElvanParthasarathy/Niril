package com.elvan.noolachu.navigation

sealed class Routes(val route: String) {
    data object Home : Routes("home")
    data object Settings : Routes("settings")
}
