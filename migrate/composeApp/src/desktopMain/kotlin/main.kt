import androidx.compose.ui.Alignment
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.WindowPosition
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.elvan.noolachu.App

fun main() {
    Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
        println(">>> UNCAUGHT EXCEPTION on thread ${thread.name}: ${throwable.message}")
        throwable.printStackTrace()
    }

    println(">>> Starting Elvan Niril Desktop...")
    try {
        println(">>> java.awt.GraphicsEnvironment.isHeadless(): ${java.awt.GraphicsEnvironment.isHeadless()}")
        val ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment()
        println(">>> Screen devices count: ${ge.screenDevices.size}")

        application {
            println(">>> Inside application scope")
            try {
                com.elvan.noolachu.localization.LanguageManager.init()
                println(">>> LanguageManager initialized")
                com.elvan.noolachu.theme.ThemeManager.init()
                println(">>> ThemeManager initialized")
            } catch (e: Throwable) {
                println(">>> Error in init: ${e.message}")
                e.printStackTrace()
            }

            Window(
                onCloseRequest = ::exitApplication,
                title = "Elvan Niril",
                visible = true,
                alwaysOnTop = false,
                state = rememberWindowState(
                    width = 1180.dp,
                    height = 800.dp,
                    position = WindowPosition.Aligned(Alignment.Center)
                )
            ) {
                println(">>> Inside Window block, window class: ${window.javaClass.name}")
                println(">>> window isVisible: ${window.isVisible}, isShowing: ${window.isShowing}")

                androidx.compose.runtime.LaunchedEffect(Unit) {
                    println(">>> Window LaunchedEffect: window.isVisible=${window.isVisible}, isShowing=${window.isShowing}")
                    java.awt.EventQueue.invokeLater {
                        window.isVisible = true
                        window.extendedState = java.awt.Frame.NORMAL
                        window.toFront()
                        window.requestFocus()
                        println(">>> On EDT: window.isVisible=${window.isVisible}, isShowing=${window.isShowing}, bounds=${window.bounds}")
                    }
                }

                println(">>> Calling App()...")
                App()
            }
        }
    } catch (e: Throwable) {
        println(">>> Application crashed: ${e.message}")
        e.printStackTrace()
    }
}

