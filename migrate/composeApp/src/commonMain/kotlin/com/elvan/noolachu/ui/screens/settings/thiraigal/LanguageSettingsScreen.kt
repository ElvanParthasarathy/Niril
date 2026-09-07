package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.*
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanRadioSettingsRow
import com.elvan.noolachu.ui.components.shell.ElvanSettingsDivider
import com.elvan.noolachu.ui.components.shell.ElvanSettingsSection

/**
 * Language Settings Screen matching Flutter's `mozhi_amaippugal_thirai.dart` 1:1.
 * Features 4 radio options: Automatic (தானியங்கி அமைப்பு), தமிழ், English, and Tamil Latin.
 */
@Composable
fun LanguageSettingsScreen(
    colors: ShellColors = rememberShellColors()
) {
    val currentLang = LanguageManager.currentLanguage

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            ElvanSettingsSection(colors = colors) {
                // 1. Automatic (தானியங்கி அமைப்பு)
                ElvanRadioSettingsRow(
                    title = K.thaaniyangiAmaippu.tr(),
                    value = Language.SYSTEM,
                    groupValue = currentLang,
                    onSelected = { LanguageManager.setLanguage(it) },
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // 2. Tamil (தமிழ்)
                ElvanRadioSettingsRow(
                    title = K.thamizh.tr(),
                    value = Language.TAMIL,
                    groupValue = currentLang,
                    onSelected = { LanguageManager.setLanguage(it) },
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // 3. English (English)
                ElvanRadioSettingsRow(
                    title = K.aangilam.tr(),
                    value = Language.ENGLISH,
                    groupValue = currentLang,
                    onSelected = { LanguageManager.setLanguage(it) },
                    colors = colors
                )
                ElvanSettingsDivider(colors = colors)

                // 4. Tamil Latin (Tamil Latin)
                ElvanRadioSettingsRow(
                    title = K.tamilLatin.tr(),
                    value = Language.TAMIL_LATIN,
                    groupValue = currentLang,
                    onSelected = { LanguageManager.setLanguage(it) },
                    colors = colors
                )
            }
        }
    }
}
