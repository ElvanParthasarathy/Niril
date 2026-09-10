package com.elvan.noolachu.localization

import androidx.compose.runtime.*
import com.elvan.noolachu.core.navil.NavilMozhimaatri
import com.elvan.noolachu.localization.language_keys.en
import com.elvan.noolachu.localization.language_keys.ta
import com.elvan.noolachu.localization.language_keys.taLatn

/**
 * Supported UI Language codes: Tamil and English.
 */
enum class Language(val code: String, val displayName: String) {
    SYSTEM("system", "தானியங்கி அமைப்பு"),
    TAMIL("ta", "தமிழ்"),
    ENGLISH("en", "English"),
    TAMIL_LATIN("ta-Latn", "Tamil Latin");

    companion object {
        fun fromCode(code: String): Language =
            entries.firstOrNull { it.code == code } ?: SYSTEM
    }
}

/**
 * CompositionLocal holding the currently active UI language code.
 */
val LocalAppLanguage = compositionLocalOf { Language.TAMIL.code }

/**
 * UI Language state manager.
 */
object LanguageManager {
    var currentLanguage by mutableStateOf(Language.TAMIL)
        private set

    fun setLanguage(language: Language) {
        currentLanguage = language
    }

    fun setLanguageByCode(code: String) {
        currentLanguage = Language.fromCode(code)
    }

    fun toggleLanguage() {
        currentLanguage = if (currentLanguage == Language.TAMIL) Language.ENGLISH else Language.TAMIL
    }
}

/**
 * Provider composable wrapping the tree with the selected UI language.
 */
@Composable
fun ProvideAppLanguage(
    language: Language = LanguageManager.currentLanguage,
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(LocalAppLanguage provides language.code) {
        content()
    }
}

/**
 * Extension on String for reactive translations in Compose UI.
 * Usage:
 *   Text(K.pattiyal.tr())
 */
@Composable
fun String.tr(): String {
    val currentLang = LocalAppLanguage.current
    return trWithLang(currentLang)
}

/**
 * Translates this string key explicitly into the requested language code.
 */
fun String.trWithLang(langCode: String): String {
    return when (langCode) {
        "ta" -> ta[this] ?: this
        "en" -> en[this] ?: this
        "ta-Latn" -> taLatn[this] ?: ta[this]?.let { NavilMozhimaatri.transliterate(it) } ?: NavilMozhimaatri.transliterate(this)
        else -> ta[this] ?: en[this] ?: this
    }
}
