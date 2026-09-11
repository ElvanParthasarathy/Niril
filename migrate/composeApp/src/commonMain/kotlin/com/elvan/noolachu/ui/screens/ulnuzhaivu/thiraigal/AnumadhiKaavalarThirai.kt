package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.platform.PlatformType
import com.elvan.noolachu.core.platform.currentPlatform
import com.elvan.noolachu.core.platform.isStoragePermissionGranted
import com.elvan.noolachu.core.platform.requestStoragePermission
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthAnimatedElement
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthButton
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthHeader
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthLayout
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import kotlinx.coroutines.delay

@Composable
fun AnumadhiKaavalarThirai(
    onPermissionGranted: () -> Unit
) {
    LaunchedEffect(Unit) {
        if (currentPlatform == PlatformType.DESKTOP || isStoragePermissionGranted()) {
            onPermissionGranted()
            return@LaunchedEffect
        }
        while (true) {
            delay(1000)
            if (isStoragePermissionGranted()) {
                onPermissionGranted()
                break
            }
        }
    }

    AuthLayout(showBranding = true) {
        AuthAnimatedElement(delayIndex = 0) {
            Icon(
                imageVector = MaterialSymbols.Rounded.Lock,
                contentDescription = null,
                modifier = Modifier.size(80.dp),
                tint = MaterialTheme.colorScheme.primary
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        AuthHeader(
            title = K.chaemippagaAnumadhiThaevai.tr(),
            subtitle = K.chaemippagaAnumadhiVilakkam.tr()
        )

        Spacer(modifier = Modifier.height(48.dp))

        AuthButton(
            text = K.anumadhiVazhanguPtn.tr(),
            onClick = {
                requestStoragePermission()
            }
        )
    }
}

