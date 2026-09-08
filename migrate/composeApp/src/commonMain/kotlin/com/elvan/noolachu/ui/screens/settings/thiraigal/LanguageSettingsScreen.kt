package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.localization.*
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*

private data class LanguageSettingItem(
    val language: Language,
    val title: String,
    val descriptionKey: String?
)

private val languageSettingsOptions = listOf(
    LanguageSettingItem(Language.SYSTEM, "", null),
    LanguageSettingItem(Language.TAMIL, "தமிழ்", K.tamil),
    LanguageSettingItem(Language.TAMIL_LATIN, "Thamizh", K.tamilLatin),
    LanguageSettingItem(Language.ENGLISH, "English", K.english),
)

/**
 * Language Settings Screen matching Neram's `LanguageSettingsScreen.kt` 1:1.
 * Features native script titles paired with localized subtitles and live updates.
 */
@Composable
fun LanguageSettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val currentLang = LanguageManager.currentLanguage
    val ff = LocalAppFontFamily.current

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
    ) {
        // Top spacer driven by One UI collapsible header
        item(key = "shell_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        item(key = "language_section") {
            ElvanSectionContainer {
                ElvanSettingsSection(colors = colors) {
                    languageSettingsOptions.forEachIndexed { index, option ->
                        val title = if (option.language == Language.SYSTEM) K.thaaniyangiAmaippu.tr() else option.title
                        val description = option.descriptionKey?.let { it.tr() }

                        ElvanRadioSettingsRow(
                            title = title,
                            description = description,
                            value = option.language,
                            groupValue = currentLang,
                            onSelected = { LanguageManager.setLanguage(it) },
                            colors = colors
                        )

                        if (index < languageSettingsOptions.size - 1) {
                            ElvanSettingsDivider(colors = colors)
                        }
                    }
                }
            }
        }

        item(key = "info_text") {
            ElvanSectionContainer {
                Text(
                    text = K.languageInfo.tr(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 13.sp,
                        lineHeight = 18.sp
                    ),
                    color = colors.textPrimary.copy(alpha = 0.5f),
                    modifier = Modifier.padding(horizontal = 8.dp)
                )
            }
        }
    }
}
