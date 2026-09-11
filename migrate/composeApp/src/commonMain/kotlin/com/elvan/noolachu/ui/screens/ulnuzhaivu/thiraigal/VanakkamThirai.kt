package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.auth.AuthManager
import com.elvan.noolachu.core.backup.getNirilBackupService
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.*
import kotlinx.coroutines.launch

@Composable
fun VanakkamThirai(
    billingLanguage: String = "ta",
    onSetupComplete: () -> Unit,
    onBack: (() -> Unit)? = null
) {
    val coroutineScope = rememberCoroutineScope()
    
    val missingProfiles = remember { AuthManager.missingProfiles }
    var currentIndex by remember { mutableStateOf(0) }
    var businessName by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }

    if (missingProfiles.isEmpty() || currentIndex >= missingProfiles.size) {
        LaunchedEffect(Unit) {
            onSetupComplete()
        }
        return
    }
    
    val currentProfile = missingProfiles[currentIndex]
    val title = when (currentProfile.lowercase()) {
        "kooli" -> "கூலிப் பெயர்"
        "pattu" -> "பட்டுப் பெயர்"
        else -> "நிறுவனப் பெயர்"
    }

    AuthLayout(showBranding = true) {
        if (onBack != null) {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.Start
            ) {
                AuthBackButton(onClick = onBack)
            }
        }

        AuthHeader(
            title = title,
            subtitle = "தயவுசெய்து உங்கள் நிறுவனத்தின் பெயரை உள்ளிடவும்"
        )
        
        Spacer(modifier = Modifier.height(32.dp))

        AuthInput(
            value = businessName,
            onValueChange = { businessName = it },
            label = title,
            helperText = "பெயரை உள்ளிடவும்"
        )
        
        Spacer(modifier = Modifier.height(32.dp))

        AuthButton(
            text = "சேமி",
            loading = isLoading,
            onClick = {
                if (businessName.isNotBlank()) {
                    isLoading = true
                    coroutineScope.launch {
                        try {
                            val mode = if (currentProfile.lowercase() == "kooli") AppMode.KOOLI else AppMode.PATTU
                            val profile = NiruvanaTharavugal(
                                mudhanMozhi = billingLanguage,
                                niruvanathinPeyar = mutableMapOf(billingLanguage to businessName),
                                kurumPeyar = businessName
                            )
                            NiruvanaTharavugalRepository.createProfile(mode, profile)
                            
                            if (currentIndex < missingProfiles.size - 1) {
                                currentIndex++
                                businessName = ""
                            } else {
                                AuthManager.refreshProfileStatus()
                                getNirilBackupService().createBackup()
                                onSetupComplete()
                            }
                        } finally {
                            isLoading = false
                        }
                    }
                }
            }
        )
    }
}

