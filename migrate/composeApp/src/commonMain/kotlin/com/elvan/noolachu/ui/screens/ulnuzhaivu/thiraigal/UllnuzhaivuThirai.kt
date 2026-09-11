package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.auth.AuthManager
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun UllnuzhaivuThirai(
    onBack: () -> Unit,
    onLoginSuccess: () -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var errorText by remember { mutableStateOf<String?>(null) }
    var loading by remember { mutableStateOf(false) }
    val emptyFieldsError = K.vidupattaPulangalaiNirappavum.tr()
    val scope = rememberCoroutineScope()

    AuthLayout(showBranding = true) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Start
        ) {
            AuthBackButton(onClick = onBack)
        }

        AuthHeader(
            title = K.niril.tr(),
            subtitle = K.cheyaliyaiAnugaUlnuzhaiyavum.tr()
        )
        
        Spacer(modifier = Modifier.height(48.dp))
        
        AuthInput(
            value = email,
            onValueChange = { email = it; errorText = null },
            label = K.minnanjalMugavari.tr(),
            helperText = K.minnanjalaiUllidavum.tr()
        )
        
        Spacer(modifier = Modifier.height(24.dp))
        
        AuthInput(
            value = password,
            onValueChange = { password = it; errorText = null },
            label = K.kadavuchol.tr(),
            isPassword = true,
            helperText = K.kadavuchollaiUllidavum.tr()
        )
        
        if (errorText != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = errorText!!,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )
        }
        
        Spacer(modifier = Modifier.height(48.dp))
        
        AuthButton(
            text = K.ulnuzhaiga.tr(),
            loading = loading,
            onClick = {
                if (email.isBlank() || password.isBlank()) {
                    errorText = emptyFieldsError
                    return@AuthButton
                }
                loading = true
                errorText = null
                scope.launch {
                    delay(1000)
                    AuthManager.login(email, password)
                    loading = false
                    onLoginSuccess()
                }
            }
        )
    }
}
