package com.elvan.noolachu.ui.screens.thiruthi.vaangunar

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.repository.VaangunarRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.components.shell.maeladukkugal.ElvanAzhippuUrudhiMaeladukku
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.screens.thiruthi.ElvanEditorSection
import com.elvan.noolachu.ui.screens.thiruthi.ElvanIrumozhiPulan
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiAttai
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiUlleedu

/**
 * VaangunarThiruthiScreen — Full subpage to create or edit a customer/merchant.
 * Supports Coolie & Silk modes using Flutter's boxed card editor layout.
 */
@Composable
fun VaangunarThiruthiScreen(
    merchant: VaangunarTharavuru? = null,
    onBack: () -> Unit
) {
    val currentMode = LocalAppMode.current
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current
    val isEditing = merchant != null && merchant.id > 0L

    var peyarMap by remember {
        mutableStateOf(merchant?.peyar ?: emptyMap())
    }
    var oorMap by remember {
        mutableStateOf(merchant?.oor ?: emptyMap())
    }
    var mugavariMap by remember {
        mutableStateOf(merchant?.mugavari ?: emptyMap())
    }
    var maavattamMap by remember {
        mutableStateOf(merchant?.maavattam ?: emptyMap())
    }
    var maanilamMap by remember {
        mutableStateOf(merchant?.maanilam ?: mapOf("en" to "Tamil Nadu", "ta" to "தமிழ்நாடு"))
    }
    var naaduMap by remember {
        mutableStateOf(merchant?.naadu ?: mapOf("en" to "India", "ta" to "இந்தியா"))
    }

    var anjalKuriyeedu by remember { mutableStateOf(merchant?.anjalKuriyeedu ?: "") }
    var gstin by remember { mutableStateOf(merchant?.gstin ?: "") }
    var tholaipaesi by remember { mutableStateOf(merchant?.tholaipaesi ?: "") }
    var minnanjal by remember { mutableStateOf(merchant?.minnanjal ?: "") }

    var showDeleteConfirm by remember { mutableStateOf(false) }
    var nameValidationError by remember { mutableStateOf<String?>(null) }
    var gstinValidationError by remember { mutableStateOf<String?>(null) }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaAakkam.tr()
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
        if (peyarMap.values.none { it.isNotBlank() }) {
            nameValidationError = nameRequiredMsg
            ElvanSnackbar.show(nameRequiredMsg)
            return
        }

        if (currentMode == AppMode.PATTU && gstin.isNotBlank()) {
            if (!validateGstin(gstin)) {
                gstinValidationError = gstinErrorMsg
                ElvanSnackbar.show(gstinErrorMsg)
                return
            }
        }

        val merchantToSave = VaangunarTharavuru(
            id = merchant?.id ?: 0L,
            peyar = peyarMap.filterValues { it.isNotBlank() },
            oor = oorMap.filterValues { it.isNotBlank() },
            mugavari = mugavariMap.filterValues { it.isNotBlank() },
            maavattam = maavattamMap.filterValues { it.isNotBlank() },
            maanilam = maanilamMap.filterValues { it.isNotBlank() },
            naadu = naaduMap.filterValues { it.isNotBlank() },
            velinaadMugavari = emptyMap(),
            anjalKuriyeedu = anjalKuriyeedu.trim(),
            gstin = gstin.trim().uppercase(),
            minnanjal = minnanjal.trim(),
            tholaipaesi = tholaipaesi.trim(),
            isDeleted = false,
            createdAt = merchant?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )

        val savedId = VaangunarRepository.save(merchantToSave, currentMode)
        if (savedId > 0L) {
            ElvanSnackbar.show(savedMsg)
            onBack()
        } else {
            ElvanSnackbar.show(saveFailedMsg)
        }
    }

    AppBackHandler(enabled = true) {
        onBack()
    }

    val scrollState = rememberLazyListState()

    ElvanSubShell(
        title = pageTitle,
        onBack = onBack,
        scrollState = scrollState,
        hasActions = true,
        actions = {
            ElvanCheyalPothan(
                label = K.chaemiPtn.tr(),
                onClick = { handleSave() }
            )
        }
    ) {
        LazyColumn(
            state = scrollState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                bottom = Dimens.SubpageContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Top spacer driven by One UI collapsible header
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            // Section 1: Customer Details (வணிகர் தரவுகள்)
            item(key = "merchant_details_section") {
                ElvanEditorSection(
                    index = 0,
                    title = K.vaangunarTharavugal.tr()
                ) {
                    ElvanThiruthiAttai {
                        ElvanIrumozhiPulan(
                            label = K.vaangunarPeyar.tr(),
                            value = peyarMap,
                            onChanged = {
                                peyarMap = it
                                nameValidationError = null
                            },
                            placeholder = K.vaangunarPeyar.tr()
                        )

                        if (nameValidationError != null) {
                            Text(
                                text = nameValidationError!!,
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    color = MaterialTheme.colorScheme.error
                                ),
                                modifier = Modifier.padding(start = 4.dp)
                            )
                        }
                    }
                }
            }

            // Section 2: Address (முகவரி)
            item(key = "address_section") {
                ElvanEditorSection(
                    index = 1,
                    title = K.mugavari.tr()
                ) {
                    ElvanThiruthiAttai {
                        if (currentMode == AppMode.PATTU) {
                            ElvanIrumozhiPulan(
                                label = K.maanilam.tr(),
                                value = maanilamMap,
                                onChanged = { maanilamMap = it },
                                placeholder = "Tamil Nadu"
                            )

                            ElvanIrumozhiPulan(
                                label = K.maavattam.tr(),
                                value = maavattamMap,
                                onChanged = { maavattamMap = it },
                                placeholder = "Kanchipuram"
                            )
                        }

                        ElvanIrumozhiPulan(
                            label = K.oor.tr(),
                            value = oorMap,
                            onChanged = { oorMap = it },
                            placeholder = K.oor.tr()
                        )

                        ElvanIrumozhiPulan(
                            label = K.mugavari.tr(),
                            value = mugavariMap,
                            onChanged = { mugavariMap = it },
                            placeholder = K.mugavari.tr(),
                            maxLines = 2
                        )

                        if (currentMode == AppMode.PATTU) {
                            ElvanThiruthiUlleedu(
                                label = K.anjalKuriyeedu.tr(),
                                value = anjalKuriyeedu,
                                onValueChange = { anjalKuriyeedu = it },
                                placeholder = "631501",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                            )
                        }
                    }
                }
            }

            // Section 3: Contact & Tax (தொடர்பு மற்றும் வரி)
            item(key = "contact_tax_section") {
                ElvanEditorSection(
                    index = 2,
                    title = if (currentMode == AppMode.PATTU) K.thodarpuVari.tr() else K.tholaipaesi.tr()
                ) {
                    ElvanThiruthiAttai {
                        ElvanThiruthiUlleedu(
                            label = K.tholaipaesi.tr(),
                            value = tholaipaesi,
                            onValueChange = { tholaipaesi = it },
                            placeholder = "+91 98765 43210",
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
                        )

                        ElvanThiruthiUlleedu(
                            label = K.minnanjal.tr(),
                            value = minnanjal,
                            onValueChange = { minnanjal = it },
                            placeholder = "merchant@example.com",
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email)
                        )

                        if (currentMode == AppMode.PATTU) {
                            ElvanThiruthiUlleedu(
                                label = K.gstin.tr(),
                                value = gstin,
                                onValueChange = {
                                    gstin = it.uppercase()
                                    gstinValidationError = null
                                },
                                placeholder = "33AAAAA0000A1Z5",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
                                errorMessage = gstinValidationError
                            )
                        }
                    }
                }
            }

            // Delete Card (if editing existing)
            if (isEditing && merchant != null) {
                item(key = "delete_section") {
                    ElvanThiruthiAttai(
                        onClick = { showDeleteConfirm = true },
                        backgroundColor = MaterialTheme.colorScheme.error.copy(alpha = 0.08f)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.Center,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = MaterialSymbols.Rounded.Delete,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.error,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = K.azhi.tr().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 15.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = MaterialTheme.colorScheme.error
                                )
                            )
                        }
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
                VaangunarRepository.delete(merchant.id, currentMode)
                ElvanSnackbar.show(deletedMsg)
                onBack()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
