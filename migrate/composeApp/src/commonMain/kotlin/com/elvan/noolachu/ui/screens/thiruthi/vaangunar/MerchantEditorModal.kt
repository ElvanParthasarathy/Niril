package com.elvan.noolachu.ui.screens.thiruthi.vaangunar

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.ConfigureDialogWindow
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.repository.VaangunarRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanSettingsSection
import com.elvan.noolachu.ui.components.shell.ElvanSettingsTextField
import com.elvan.noolachu.ui.components.shell.ElvanSnackbar
import com.elvan.noolachu.ui.components.shell.maeladukkugal.ElvanAzhippuUrudhiMaeladukku
import com.elvan.noolachu.ui.components.shell.maeladukkugal.ElvanMaeladukkuThalaipu
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * MerchantEditorModal — Modal bottom sheet to create or edit a customer/merchant.
 * Supports Coolie & Silk modes.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MerchantEditorModal(
    merchant: VaangunarTharavuru? = null,
    onDismiss: () -> Unit,
    mode: AppMode = LocalAppMode.current,
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark
    val sheetBg = if (isDark) Color(0xFF111111) else Color.White
    val isEditing = merchant != null && merchant.id > 0L

    var nameTa by remember { mutableStateOf(merchant?.peyar?.get("ta") ?: "") }
    var nameEn by remember { mutableStateOf(merchant?.peyar?.get("en") ?: "") }

    var oorTa by remember { mutableStateOf(merchant?.oor?.get("ta") ?: "") }
    var oorEn by remember { mutableStateOf(merchant?.oor?.get("en") ?: "") }

    var mugavariTa by remember { mutableStateOf(merchant?.mugavari?.get("ta") ?: "") }
    var mugavariEn by remember { mutableStateOf(merchant?.mugavari?.get("en") ?: "") }

    // Silk Mode specific fields
    var maavattam by remember { mutableStateOf(merchant?.maavattam?.get("ta") ?: merchant?.maavattam?.get("en") ?: "") }
    var maanilam by remember { mutableStateOf(merchant?.maanilam?.get("ta") ?: merchant?.maanilam?.get("en") ?: "") }
    var anjalKuriyeedu by remember { mutableStateOf(merchant?.anjalKuriyeedu ?: "") }
    var gstin by remember { mutableStateOf(merchant?.gstin ?: "") }
    var tholaipaesi by remember { mutableStateOf(merchant?.tholaipaesi ?: "") }
    var minnanjal by remember { mutableStateOf(merchant?.minnanjal ?: "") }

    var showDeleteConfirm by remember { mutableStateOf(false) }
    var nameValidationError by remember { mutableStateOf<String?>(null) }
    var gstinValidationError by remember { mutableStateOf<String?>(null) }

    val modalTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaAakkam.tr()
    val nameRequiredMsg = K.vaangunarPeyarThaevai.tr()
    val gstinErrorMsg = K.gstinTavaru.tr()
    val savedMsg = K.vaangunarChaemikkappattadhu.tr()
    val saveFailedMsg = K.chaemikkaIyalavillai.tr()
    val deletedMsg = K.vaangunarAzhikkappattadhu.tr()
    val confirmDeleteTitle = K.nirandharaAzhippuUrudhi.tr()

    fun validateGstin(value: String): Boolean {
        if (value.isBlank()) return true
        val upper = value.trim().uppercase()
        if (upper.length != 15) return false
        val gstinRegex = Regex("^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$")
        return gstinRegex.matches(upper)
    }

    fun handleSave() {
        if (nameTa.trim().isEmpty() && nameEn.trim().isEmpty()) {
            nameValidationError = nameRequiredMsg
            ElvanSnackbar.show(nameRequiredMsg)
            return
        }

        if (mode == AppMode.PATTU && gstin.isNotBlank()) {
            if (!validateGstin(gstin)) {
                gstinValidationError = gstinErrorMsg
                ElvanSnackbar.show(gstinErrorMsg)
                return
            }
        }

        val peyarMap = mutableMapOf<String, String>()
        if (nameTa.isNotBlank()) peyarMap["ta"] = nameTa.trim()
        if (nameEn.isNotBlank()) peyarMap["en"] = nameEn.trim()

        val oorMap = mutableMapOf<String, String>()
        if (oorTa.isNotBlank()) oorMap["ta"] = oorTa.trim()
        if (oorEn.isNotBlank()) oorMap["en"] = oorEn.trim()

        val mugavariMap = mutableMapOf<String, String>()
        if (mugavariTa.isNotBlank()) mugavariMap["ta"] = mugavariTa.trim()
        if (mugavariEn.isNotBlank()) mugavariMap["en"] = mugavariEn.trim()

        val maavattamMap = mutableMapOf<String, String>()
        if (maavattam.isNotBlank()) {
            maavattamMap["ta"] = maavattam.trim()
            maavattamMap["en"] = maavattam.trim()
        }

        val maanilamMap = mutableMapOf<String, String>()
        if (maanilam.isNotBlank()) {
            maanilamMap["ta"] = maanilam.trim()
            maanilamMap["en"] = maanilam.trim()
        }

        val merchantToSave = VaangunarTharavuru(
            id = merchant?.id ?: 0L,
            peyar = peyarMap,
            oor = oorMap,
            mugavari = mugavariMap,
            maavattam = if (mode == AppMode.PATTU) maavattamMap else emptyMap(),
            maanilam = if (mode == AppMode.PATTU) maanilamMap else emptyMap(),
            naadu = mapOf("en" to "India", "ta" to "இந்தியா"),
            anjalKuriyeedu = if (mode == AppMode.PATTU) anjalKuriyeedu.trim() else "",
            gstin = if (mode == AppMode.PATTU) gstin.trim().uppercase() else "",
            minnanjal = if (mode == AppMode.PATTU) minnanjal.trim() else "",
            tholaipaesi = if (mode == AppMode.PATTU) tholaipaesi.trim() else "",
            createdAt = merchant?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )

        val savedId = VaangunarRepository.save(merchantToSave, mode)
        if (savedId > 0L) {
            ElvanSnackbar.show(savedMsg)
            onDismiss()
        } else {
            ElvanSnackbar.show(saveFailedMsg)
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
        containerColor = sheetBg,
        scrimColor = Color.Black.copy(alpha = 0.45f),
        dragHandle = { BottomSheetDefaults.DragHandle() }
    ) {
        ConfigureDialogWindow(isDark = isDark)

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .imePadding()
        ) {
            // Header
            ElvanMaeladukkuThalaipu(
                title = modalTitle,
                colors = colors
            )

            // Scrollable Content
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f, fill = false)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Section 1: Customer / Business Name
                ElvanSettingsSection(
                    title = K.vaangunarTharavugal.tr(),
                    colors = colors
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        ElvanSettingsTextField(
                            label = "${K.vaangunarPeyar.tr()} (${K.thamizh.tr()})",
                            value = nameTa,
                            onValueChange = {
                                nameTa = it
                                nameValidationError = null
                            },
                            placeholder = K.vaangunarPeyar.tr(),
                            colors = colors
                        )

                        ElvanSettingsTextField(
                            label = "${K.vaangunarPeyar.tr()} (${K.aangilam.tr()})",
                            value = nameEn,
                            onValueChange = {
                                nameEn = it
                                nameValidationError = null
                            },
                            placeholder = "Customer / Business Name",
                            colors = colors
                        )

                        if (nameValidationError != null) {
                            Text(
                                text = nameValidationError!!,
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    color = MaterialTheme.colorScheme.error
                                ),
                                modifier = Modifier.padding(start = 16.dp)
                            )
                        }
                    }
                }

                // Section 2: Address
                ElvanSettingsSection(
                    title = K.mugavaritharavugal.tr(),
                    colors = colors
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        // Town / City
                        ElvanSettingsTextField(
                            label = "${K.oor.tr()} (${K.thamizh.tr()})",
                            value = oorTa,
                            onValueChange = { oorTa = it },
                            placeholder = K.oor.tr(),
                            colors = colors
                        )

                        ElvanSettingsTextField(
                            label = "${K.oor.tr()} (${K.aangilam.tr()})",
                            value = oorEn,
                            onValueChange = { oorEn = it },
                            placeholder = "Town / City",
                            colors = colors
                        )

                        // Address Lines
                        ElvanSettingsTextField(
                            label = "${K.mugavari.tr()} (${K.thamizh.tr()})",
                            value = mugavariTa,
                            onValueChange = { mugavariTa = it },
                            placeholder = K.mugavari.tr(),
                            singleLine = false,
                            colors = colors
                        )

                        ElvanSettingsTextField(
                            label = "${K.mugavari.tr()} (${K.aangilam.tr()})",
                            value = mugavariEn,
                            onValueChange = { mugavariEn = it },
                            placeholder = "Address line",
                            singleLine = false,
                            colors = colors
                        )

                        // Silk Mode: District, State, Pincode
                        if (mode == AppMode.PATTU) {
                            ElvanSettingsTextField(
                                label = K.maavattam.tr(),
                                value = maavattam,
                                onValueChange = { maavattam = it },
                                placeholder = K.maavattam.tr(),
                                colors = colors
                            )

                            ElvanSettingsTextField(
                                label = K.maanilam.tr(),
                                value = maanilam,
                                onValueChange = { maanilam = it },
                                placeholder = K.maanilam.tr(),
                                colors = colors
                            )

                            ElvanSettingsTextField(
                                label = K.anjalKuriyeedu.tr(),
                                value = anjalKuriyeedu,
                                onValueChange = { anjalKuriyeedu = it },
                                placeholder = "600001",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                maxLength = 6,
                                colors = colors
                            )
                        }
                    }
                }

                // Silk Mode: Section 3: Tax & Contact
                if (mode == AppMode.PATTU) {
                    ElvanSettingsSection(
                        title = "${K.gstin.tr()} • ${K.thodarpuVari.tr()}",
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            ElvanSettingsTextField(
                                label = K.gstinVariAdaiyaalaEn.tr(),
                                value = gstin,
                                onValueChange = {
                                    gstin = it.uppercase().take(15)
                                    gstinValidationError = null
                                },
                                placeholder = "33AAAAA0000A1Z5",
                                maxLength = 15,
                                colors = colors
                            )

                            if (gstinValidationError != null) {
                                Text(
                                    text = gstinValidationError!!,
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 12.sp,
                                        color = MaterialTheme.colorScheme.error
                                    ),
                                    modifier = Modifier.padding(start = 16.dp)
                                )
                            }

                            ElvanSettingsTextField(
                                label = K.paesiEn.tr(),
                                value = tholaipaesi,
                                onValueChange = { tholaipaesi = it },
                                placeholder = "9876543210",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                                colors = colors
                            )

                            ElvanSettingsTextField(
                                label = K.minnanjal.tr(),
                                value = minnanjal,
                                onValueChange = { minnanjal = it },
                                placeholder = "customer@example.com",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                                colors = colors
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))
            }

            // Bottom Action Bar
            Surface(
                modifier = Modifier.fillMaxWidth(),
                color = sheetBg,
                shadowElevation = 0.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (isEditing) {
                        IconButton(
                            onClick = { showDeleteConfirm = true },
                            modifier = Modifier
                                .size(48.dp)
                                .clip(CircleShape)
                                .background(MaterialTheme.colorScheme.error.copy(alpha = 0.12f))
                        ) {
                            Icon(
                                imageVector = MaterialSymbols.Rounded.Delete,
                                contentDescription = K.azhi.tr(),
                                tint = MaterialTheme.colorScheme.error,
                                modifier = Modifier.size(22.dp)
                            )
                        }
                    }

                    OutlinedButton(
                        onClick = onDismiss,
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp),
                        shape = RoundedCornerShape(100)
                    ) {
                        Text(
                            text = K.kaividu.tr(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        )
                    }

                    Button(
                        onClick = { handleSave() },
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp),
                        shape = RoundedCornerShape(100),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = colors.accent,
                            contentColor = Color.White
                        )
                    ) {
                        Text(
                            text = K.chaemi.tr(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                }
            }
        }
    }

    if (showDeleteConfirm && merchant != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = confirmDeleteTitle,
            onConfirm = {
                showDeleteConfirm = false
                VaangunarRepository.delete(merchant.id, mode)
                ElvanSnackbar.show(deletedMsg)
                onDismiss()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
