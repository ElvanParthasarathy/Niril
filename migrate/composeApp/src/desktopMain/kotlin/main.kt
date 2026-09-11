import androidx.compose.ui.Alignment
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowPosition
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.elvan.noolachu.App

fun main() {
    Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
        System.err.println("UNCAUGHT on ${thread.name}: ${throwable.message}")
        throwable.printStackTrace()
    }

    println(">>> Starting Elvan Niril Desktop App...")

    application {
        com.elvan.noolachu.localization.LanguageManager.init()
        com.elvan.noolachu.theme.ThemeManager.init()

        Window(
            onCloseRequest = ::exitApplication,
            title = "Elvan Niril",
            state = rememberWindowState(
                width = 1180.dp,
                height = 800.dp,
                position = WindowPosition.Aligned(Alignment.Center)
            )
        ) {
            App()
        }
    }
}
