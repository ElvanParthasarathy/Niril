import androidx.compose.ui.Alignment
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowPosition
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.elvan.noolachu.App

fun main() = application {
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

