package com.elvan.noolachu.ui.screens.thiruthi.vaangunar

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.data.IdangalinPeyar
import com.elvan.noolachu.core.data.indhiyaMaanilangal
import com.elvan.noolachu.core.data.tamizhnaattuMaavattangal
import com.elvan.noolachu.core.data.ulagaNaadugal
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
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiThalaippu
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiUlleedu

/**
 * VaangunarThiruthiScreen — Customer / Merchant Editor.
 * 100% feature parity with Flutter's `SilkMerchantEditor` and `CoolieMerchantEditor`.
 *
 * Features:
 * - Bilingual Name input (Tamil + English)
 * - Country picker bottom sheet (`ulagaNaadugal`)
 * - India vs Foreign address branching:
 *   - If Country != India: Single multiline foreign address (`velinaadMugavari`)
 *   - If Country == India:
 *     - State picker bottom sheet (`indhiyaMaanilangal`)
 *     - District picker:
 *       - If State is Tamil Nadu: District picker bottom sheet (`tamizhnaattuMaavattangal`)
 *       - Otherwise: Free-text bilingual input
 *     - Town / City (`oor`)
 *     - Street address (`mugavari`)
 *     - PIN code (`anjalKuriyeedu`, 6 digits)
 * - Silk mode: Contact & Tax (Phone, Email, GSTIN with 15-char regex validation)
 * - Coolie mode: Simplified to Name + Town + Street only
 * - Soft delete confirmation dialog
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
    var velinaadMugavariMap by remember {
        mutableStateOf(merchant?.velinaadMugavari ?: emptyMap())
    }

    var anjalKuriyeedu by remember { mutableStateOf(merchant?.anjalKuriyeedu ?: "") }
    var gstin by remember { mutableStateOf(merchant?.gstin ?: "") }
    var tholaipaesi by remember { mutableStateOf(merchant?.tholaipaesi ?: "") }
    var minnanjal by remember { mutableStateOf(merchant?.minnanjal ?: "") }

    var isCountryPickerOpen by remember { mutableStateOf(false) }
    var isStatePickerOpen by remember { mutableStateOf(false) }
    var isDistrictPickerOpen by remember { mutableStateOf(false) }

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

    // India vs Overseas address check
    val isIndia = remember(naaduMap) {
        val en = naaduMap["en"]?.trim()?.lowercase() ?: ""
        val ta = naaduMap["ta"]?.trim() ?: ""
        naaduMap.isEmpty() || en == "india" || ta == "இந்தியா"
    }

    // Tamil Nadu check for district picker
    val isTamilNadu = remember(maanilamMap) {
        val en = maanilamMap["en"]?.trim()?.lowercase() ?: ""
        val ta = maanilamMap["ta"]?.trim() ?: ""
        en == "tamil nadu" || ta == "தமிழ்நாடு"
    }

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

        val merchantToSave = if (currentMode == AppMode.KOOLI) {
            // Coolie mode: simplified to Name, Town, Street only
            VaangunarTharavuru(
                id = merchant?.id ?: 0L,
                peyar = peyarMap.filterValues { it.isNotBlank() },
                oor = oorMap.filterValues { it.isNotBlank() },
                mugavari = mugavariMap.filterValues { it.isNotBlank() },
                maavattam = emptyMap(),
                maanilam = emptyMap(),
                naadu = emptyMap(),
                velinaadMugavari = emptyMap(),
                anjalKuriyeedu = "",
                gstin = "",
                minnanjal = "",
                tholaipaesi = "",
                isDeleted = false,
                createdAt = merchant?.createdAt ?: System.currentTimeMillis(),
                updatedAt = System.currentTimeMillis()
            )
        } else {
            // Silk mode: full domestic or foreign address + contact & tax
            VaangunarTharavuru(
                id = merchant?.id ?: 0L,
                peyar = peyarMap.filterValues { it.isNotBlank() },
                oor = if (isIndia) oorMap.filterValues { it.isNotBlank() } else emptyMap(),
                mugavari = if (isIndia) mugavariMap.filterValues { it.isNotBlank() } else emptyMap(),
                maavattam = if (isIndia) maavattamMap.filterValues { it.isNotBlank() } else emptyMap(),
                maanilam = if (isIndia) maanilamMap.filterValues { it.isNotBlank() } else emptyMap(),
                naadu = naaduMap.filterValues { it.isNotBlank() },
                velinaadMugavari = if (!isIndia) velinaadMugavariMap.filterValues { it.isNotBlank() } else emptyMap(),
                anjalKuriyeedu = if (isIndia) anjalKuriyeedu.trim() else "",
                gstin = gstin.trim().uppercase(),
                minnanjal = minnanjal.trim(),
                tholaipaesi = tholaipaesi.trim(),
                isDeleted = false,
                createdAt = merchant?.createdAt ?: System.currentTimeMillis(),
                updatedAt = System.currentTimeMillis()
            )
        }

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
    val pillBg = if (colors.isDark) Color.White.copy(alpha = 0.08f) else Color.White

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
                            // Country Selector Pill
                            Column(modifier = Modifier.fillMaxWidth()) {
                                ElvanThiruthiThalaippu(label = K.naadu.tr())
                                val countryText = naaduMap["ta"] ?: naaduMap["en"] ?: "India"
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(45.dp)
                                        .clip(RoundedCornerShape(999.dp))
                                        .background(pillBg)
                                        .clickable { isCountryPickerOpen = true }
                                        .padding(horizontal = 16.dp),
                                    contentAlignment = Alignment.CenterStart
                                ) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(
                                            text = countryText.preventBrokenLigatures(),
                                            style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textPrimary),
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                        Icon(
                                            imageVector = MaterialSymbols.Rounded.ChevronRight,
                                            contentDescription = null,
                                            tint = colors.textSecondary
                                        )
                                    }
                                }
                            }

                            if (isIndia) {
                                // State Selector Pill
                                Column(modifier = Modifier.fillMaxWidth()) {
                                    ElvanThiruthiThalaippu(label = K.maanilam.tr())
                                    val stateText = maanilamMap["ta"] ?: maanilamMap["en"] ?: "Tamil Nadu"
                                    Box(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(45.dp)
                                            .clip(RoundedCornerShape(999.dp))
                                            .background(pillBg)
                                            .clickable { isStatePickerOpen = true }
                                            .padding(horizontal = 16.dp),
                                        contentAlignment = Alignment.CenterStart
                                    ) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Text(
                                                text = stateText.preventBrokenLigatures(),
                                                style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textPrimary),
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis
                                            )
                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.ChevronRight,
                                                contentDescription = null,
                                                tint = colors.textSecondary
                                            )
                                        }
                                    }
                                }

                                // District: Autocomplete if TN, freeform otherwise
                                if (isTamilNadu) {
                                    Column(modifier = Modifier.fillMaxWidth()) {
                                        ElvanThiruthiThalaippu(label = K.maavattam.tr())
                                        val distText = maavattamMap["ta"] ?: maavattamMap["en"] ?: ""
                                        Box(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .height(45.dp)
                                                .clip(RoundedCornerShape(999.dp))
                                                .background(pillBg)
                                                .clickable { isDistrictPickerOpen = true }
                                                .padding(horizontal = 16.dp),
                                            contentAlignment = Alignment.CenterStart
                                        ) {
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                Text(
                                                    text = (if (distText.isNotEmpty()) distText else K.maavattam.tr()).preventBrokenLigatures(),
                                                    style = TextStyle(
                                                        fontFamily = ff,
                                                        fontSize = 14.sp,
                                                        color = if (distText.isNotEmpty()) colors.textPrimary else colors.textSecondary.copy(alpha = 0.5f)
                                                    ),
                                                    maxLines = 1,
                                                    overflow = TextOverflow.Ellipsis
                                                )
                                                Icon(
                                                    imageVector = MaterialSymbols.Rounded.ChevronRight,
                                                    contentDescription = null,
                                                    tint = colors.textSecondary
                                                )
                                            }
                                        }
                                    }
                                } else {
                                    ElvanIrumozhiPulan(
                                        label = K.maavattam.tr(),
                                        value = maavattamMap,
                                        onChanged = { maavattamMap = it },
                                        placeholder = K.maavattam.tr()
                                    )
                                }

                                // Town / City
                                ElvanIrumozhiPulan(
                                    label = K.oor.tr(),
                                    value = oorMap,
                                    onChanged = { oorMap = it },
                                    placeholder = K.oor.tr()
                                )

                                // Street Address
                                ElvanIrumozhiPulan(
                                    label = K.mugavari.tr(),
                                    value = mugavariMap,
                                    onChanged = { mugavariMap = it },
                                    placeholder = K.mugavari.tr(),
                                    maxLines = 2
                                )

                                // PIN Code
                                ElvanThiruthiUlleedu(
                                    label = K.anjalKuriyeedu.tr(),
                                    value = anjalKuriyeedu,
                                    onValueChange = {
                                        if (it.length <= 6 && it.all { ch -> ch.isDigit() }) {
                                            anjalKuriyeedu = it
                                        }
                                    },
                                    placeholder = "631501",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                                )
                            } else {
                                // Overseas Address: Single multiline bilingual text field
                                ElvanIrumozhiPulan(
                                    label = K.velinaadMugavari.tr(),
                                    value = velinaadMugavariMap,
                                    onChanged = { velinaadMugavariMap = it },
                                    placeholder = K.velinaadMugavari.tr(),
                                    maxLines = 4
                                )
                            }
                        } else {
                            // Coolie Mode: only Town and Street Address
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
                                maxLines = 4
                            )
                        }
                    }
                }
            }

            // Section 3: Contact & Tax (Silk mode only)
            if (currentMode == AppMode.PATTU) {
                item(key = "contact_tax_section") {
                    ElvanEditorSection(
                        index = 2,
                        title = K.thodarpuVari.tr()
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

    // Modal: Country Picker
    if (isCountryPickerOpen) {
        ElvanSelectionBottomSheet<IdangalinPeyar>(
            title = K.naadu.tr(),
            items = ulagaNaadugal,
            currentValue = ulagaNaadugal.firstOrNull { it.en == naaduMap["en"] || it.ta == naaduMap["ta"] },
            onSelected = { picked ->
                naaduMap = mapOf("en" to picked.en, "ta" to picked.ta)
                isCountryPickerOpen = false
            },
            onDismissRequest = { isCountryPickerOpen = false },
            itemLabelBuilder = { it.ta.ifEmpty { it.en } },
            subtitleBuilder = { it.en },
            showSearch = true
        )
    }

    // Modal: State Picker
    if (isStatePickerOpen) {
        ElvanSelectionBottomSheet<IdangalinPeyar>(
            title = K.maanilam.tr(),
            items = indhiyaMaanilangal,
            currentValue = indhiyaMaanilangal.firstOrNull { it.en == maanilamMap["en"] || it.ta == maanilamMap["ta"] },
            onSelected = { picked ->
                maanilamMap = mapOf("en" to picked.en, "ta" to picked.ta)
                // If not TN, clear district picker selection
                if (picked.en != "Tamil Nadu" && picked.ta != "தமிழ்நாடு") {
                    maavattamMap = emptyMap()
                }
                isStatePickerOpen = false
            },
            onDismissRequest = { isStatePickerOpen = false },
            itemLabelBuilder = { it.ta.ifEmpty { it.en } },
            subtitleBuilder = { it.en },
            showSearch = true
        )
    }

    // Modal: District Picker (Tamil Nadu)
    if (isDistrictPickerOpen) {
        ElvanSelectionBottomSheet<IdangalinPeyar>(
            title = K.maavattam.tr(),
            items = tamizhnaattuMaavattangal,
            currentValue = tamizhnaattuMaavattangal.firstOrNull { it.en == maavattamMap["en"] || it.ta == maavattamMap["ta"] },
            onSelected = { picked ->
                maavattamMap = mapOf("en" to picked.en, "ta" to picked.ta)
                isDistrictPickerOpen = false
            },
            onDismissRequest = { isDistrictPickerOpen = false },
            itemLabelBuilder = { it.ta.ifEmpty { it.en } },
            subtitleBuilder = { it.en },
            showSearch = true
        )
    }

    // Modal: Delete Confirmation
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
