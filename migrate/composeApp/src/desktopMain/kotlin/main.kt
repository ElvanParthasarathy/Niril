import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.elvan.noolachu.App

fun main() = application {
    com.elvan.noolachu.localization.LanguageManager.init()
    com.elvan.noolachu.theme.ThemeManager.init()

    Window(
        onCloseRequest = ::exitApplication,
        title = "Noolachu",
        state = rememberWindowState(width = 480.dp, height = 720.dp)
    ) {
        App()
    }
}
