package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthButton
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthHeader
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthLayout

@Composable
fun NalvaravuThirai(
    onNavigateToLogin: () -> Unit
) {
    AuthLayout(showBranding = true) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            AuthHeader(
                title = K.niril.tr(),
                subtitle = ""
            )

            Spacer(modifier = Modifier.height(16.dp))

            AuthButton(
                text = K.ulnuzhaiga.tr(),
                onClick = onNavigateToLogin
            )

            Text(
                text = "புதிய கணக்கு",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier
                    .clickable { onNavigateToLogin() }
                    .padding(8.dp)
            )
        }
    }
}

