package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal.varavaerpu_padigal

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.LanguageManager
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthBackButton
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthHeader
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.LanguageTile

@Composable
fun AppLanguageStep(
    onBack: () -> Unit,
    onLanguageSelected: () -> Unit
) {
    val languages = listOf(
        Pair("ta", "தமிழ்"),
        Pair("en", "English"),
        Pair("ta-Latn", "Tamil (Latin)")
    )
    val currentLang = LanguageManager.activeLanguageCode

    Column(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        AuthBackButton(onClick = onBack)
        
        AuthHeader(
            title = K.mozhiThaervu.tr(),
            subtitle = K.viruppaMozhiThaervu.tr()
        )

        Spacer(modifier = Modifier.height(16.dp))

        languages.forEach { (code, name) ->
            LanguageTile(
                name = name,
                isSelected = currentLang == code,
                onClick = {
                    LanguageManager.setLanguageByCode(code)
                    onLanguageSelected()
                }
            )
        }
    }
}

