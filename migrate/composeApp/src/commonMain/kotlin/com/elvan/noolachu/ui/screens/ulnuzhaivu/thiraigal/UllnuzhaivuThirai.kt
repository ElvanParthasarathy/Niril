package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal

import androidx.compose.foundation.layout.*
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

/**
 * Login Page matching Flutter's LoginPage (ullnuzhaivu_thirai.dart) 1:1.
 */
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
        // Back Button
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Start
        ) {
            AuthBackButton(onClick = onBack)
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Header: Brand Name + Subtitle
        AuthHeader(
            title = K.niril.tr(),
            subtitle = K.cheyaliyaiAnugaUlnuzhaiyavum.tr()
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Email Input with proper label & placeholder
        AuthInput(
            value = email,
            onValueChange = { 
                email = it
                if (errorText != null) errorText = null 
            },
            label = K.minnanjalMugavari.tr(),
            placeholder = K.minnanjalaiUllidavum.tr()
        )

        // Password Input with proper label, placeholder, eye toggle, and error text
        AuthInput(
            value = password,
            onValueChange = { 
                password = it
                if (errorText != null) errorText = null 
            },
            label = K.kadavuchol.tr(),
            placeholder = K.kadavuchollaiUllidavum.tr(),
            isPassword = true,
            errorText = errorText
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Login Action Button
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
