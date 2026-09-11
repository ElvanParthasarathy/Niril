package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal.varavaerpu_padigal

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthBackButton
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthButton
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthHeader
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.LanguageTile

@Composable
fun BillingLanguageStep(
    billingLanguage: String,
    onBack: () -> Unit,
    onLanguageSelected: (String) -> Unit,
    onContinue: () -> Unit
) {
    val languages = listOf(
        Pair("ta", "தமிழ்"),
        Pair("en", "English")
    )

    Column(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        AuthBackButton(onClick = onBack)
        
        AuthHeader(
            title = K.pattiyalMudhanmozhi.tr(),
            subtitle = K.pattiyalmozhi.tr()
        )

        Spacer(modifier = Modifier.height(16.dp))

        languages.forEach { (code, name) ->
            LanguageTile(
                name = name,
                isSelected = billingLanguage == code,
                onClick = { onLanguageSelected(code) }
            )
        }

        Spacer(modifier = Modifier.weight(1f))

        AuthButton(
            text = "தொடரு",
            onClick = onContinue
        )
    }
}

