package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.*
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanRadioSettingsRow
import com.elvan.noolachu.ui.components.shell.ElvanSettingsDivider
import com.elvan.noolachu.ui.components.shell.ElvanSettingsSection
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight

/**
 * Language Settings Screen matching Flutter's `mozhi_amaippugal_thirai.dart` 1:1.
 * Features 4 radio options: Automatic (தானியங்கி அமைப்பு), தமிழ், English, and Tamil Latin.
 */
@Composable
fun LanguageSettingsScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val currentLang = LanguageManager.currentLanguage

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = Dimens.ContentPadding,
            end = Dimens.ContentPadding,
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Top spacer driven by One UI collapsible header
        item(key = "shell_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

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
