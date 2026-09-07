package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanActionSheet
import com.elvan.noolachu.ui.components.shell.ElvanSnackbar

@Composable
fun NewProfileBottomSheet(
    mode: AppMode,
    onDismissRequest: () -> Unit,
    onSuccess: () -> Unit,
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    var newNamePrimary by remember { mutableStateOf("") }
    var newNameSecondary by remember { mutableStateOf("") }

    val fieldBg = if (colors.isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.06f)

    val maxProfilesMsg = K.perumalavu5thannuru.tr()
    val saveSuccessMsg = K.thannuruChaemikkappattadhu.tr()
    val createTitle = K.pudhiyaThannuruvaiUruvaakku.tr()
    val cancelLabel = K.kaividu.tr()
    val createLabel = K.aakku.tr()

    ElvanActionSheet(
        title = createTitle,
        cancelText = cancelLabel,
        confirmText = createLabel,
        onDismissRequest = onDismissRequest,
        onConfirm = {
            if (newNamePrimary.trim().isNotEmpty()) {
                val profiles = NiruvanaTharavugalRepository.getAllProfiles(mode)
                if (profiles.size >= NiruvanaTharavugalRepository.MAX_PROFILES) {
                    ElvanSnackbar.show(maxProfilesMsg)
                    return@ElvanActionSheet
                }

                val newProfile = NiruvanaTharavugal(
                    mudhanMozhi = "ta",
                    thunaiMozhi = "en",
                    iruMozhi = true,
                    gstPirippugal = mode == AppMode.PATTU,
                    niruvanathinPeyar = mutableMapOf(
                        "ta" to newNamePrimary.trim(),
                        "en" to newNameSecondary.trim()
                    ),
                    kurumPeyar = newNamePrimary.trim().take(15),
                    naadu = mutableMapOf("en" to "India", "ta" to "இந்தியா"),
                    thalaippuVadivu = "small",
                    thoatraNiram = if (mode == AppMode.PATTU) "#6a1b9a" else "#388e3c"
                )
                val success = NiruvanaTharavugalRepository.createProfile(mode, newProfile)
                if (success) {
                    ElvanSnackbar.show(saveSuccessMsg)
                    onSuccess()
                }
            }
        },
        customContent = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Tamil input pill
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                        .background(fieldBg, RoundedCornerShape(100))
                        .padding(horizontal = 20.dp),
                    contentAlignment = Alignment.Center
                ) {
                    if (newNamePrimary.isEmpty()) {
                        Text(
                            text = "${K.niruvanathinPeyar.tr()} (${K.thamizh.tr()})",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 13.sp,
                                textAlign = TextAlign.Center
                            ),
                            color = colors.textPrimary.copy(alpha = 0.4f),
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                    BasicTextField(
                        value = newNamePrimary,
                        onValueChange = { newNamePrimary = it },
                        textStyle = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            color = colors.textPrimary,
                            textAlign = TextAlign.Center
                        ),
                        singleLine = true,
                        cursorBrush = SolidColor(colors.accent),
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                // English input pill
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                        .background(fieldBg, RoundedCornerShape(100))
                        .padding(horizontal = 20.dp),
                    contentAlignment = Alignment.Center
                ) {
                    if (newNameSecondary.isEmpty()) {
                        Text(
                            text = "${K.niruvanathinPeyar.tr()} (${K.aangilam.tr()})",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 13.sp,
                                textAlign = TextAlign.Center
                            ),
                            color = colors.textPrimary.copy(alpha = 0.4f),
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                    BasicTextField(
                        value = newNameSecondary,
                        onValueChange = { newNameSecondary = it },
                        textStyle = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            color = colors.textPrimary,
                            textAlign = TextAlign.Center
                        ),
                        singleLine = true,
                        cursorBrush = SolidColor(colors.accent),
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        }
    )
}
