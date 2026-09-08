package com.elvan.noolachu.ui.screens.thiruthi.patrucheettu

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
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.data.model.PatrugalTharavuru
import com.elvan.noolachu.data.repository.PatrugalRepository
import com.elvan.noolachu.data.repository.VaangunarRepository
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.components.shell.maeladukkugal.ElvanAzhippuUrudhiMaeladukku
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Receipt Editor Screen (பற்றுச்சீட்டு திருத்தி)
 * Handles creating and editing payment receipts with One UI styling.
 */
@Composable
fun PatrucheettuThiruthiScreen(
    receipt: PatrugalTharavuru? = null,
    onBack: () -> Unit
) {
    val currentMode = LocalAppMode.current
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current
    val isEditing = receipt != null && receipt.id > 0L

    val profiles: List<NiruvanaTharavugal> = NiruvanaTharavugalRepository.getAllProfiles(currentMode)
    var selectedNiruvanamId by remember {
        mutableStateOf(receipt?.niruvanamId ?: profiles.firstOrNull()?.id)
    }

    val merchants = VaangunarRepository.merchants
    var selectedVaangunarId by remember { mutableStateOf(receipt?.vaangunarId) }
    var selectedVaangunarPeyarMap by remember {
        mutableStateOf(receipt?.vaangunarPeyar ?: emptyMap())
    }
    var selectedVaangunarMunvariMap by remember {
        mutableStateOf(receipt?.vaangunarMunvari ?: emptyMap())
    }

    var patruNaal by remember { mutableStateOf(receipt?.patruNaal ?: System.currentTimeMillis()) }
    var patruEn by remember {
        mutableStateOf(
            receipt?.patruEn ?: "PR-${System.currentTimeMillis() % 10000}"
        )
    }
    var thogai by remember {
        mutableStateOf(
            if (receipt != null && receipt.thogai > 0) {
                if (receipt.thogai % 1.0 == 0.0) receipt.thogai.toLong().toString() else receipt.thogai.toString()
            } else ""
        )
    }
    var seluthumMurai by remember {
        mutableStateOf(receipt?.seluthumMurai?.ifEmpty { "vangiMaatram" } ?: "vangiMaatram")
    }
    var parivarthanaiEn by remember { mutableStateOf(receipt?.parivarthanaiEn ?: "") }
    var ullkurippu by remember { mutableStateOf(receipt?.ullkurippu ?: "") }

    var showDeleteConfirm by remember { mutableStateOf(false) }
    var showMerchantPicker by remember { mutableStateOf(false) }
    var showProfilePicker by remember { mutableStateOf(false) }
    var validationError by remember { mutableStateOf<String?>(null) }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaPatrucheettuPtn.tr()
    val thogaiRequiredMsg = K.thogaiChuzhiyaththaiVidaMigudhiyaagaIrukkaVaendum.tr()
    val saveSuccessMsg = K.chaemippuvetri.tr()
    val saveFailedMsg = K.chaemikkaIyalavillai.tr()
    val deleteSuccessMsg = K.azhippuvetri.tr()
    val confirmDeleteTitle = K.nirandharaAzhippuUrudhi.tr()

    fun handleSave() {
        val amount = thogai.trim().toDoubleOrNull() ?: 0.0
        if (amount <= 0.0) {
            validationError = thogaiRequiredMsg
            ElvanSnackbar.show(thogaiRequiredMsg)
            return
        }

        val entryToSave = PatrugalTharavuru(
            id = receipt?.id ?: 0L,
            niruvanamId = selectedNiruvanamId,
            vaangunarId = selectedVaangunarId,
            vaangunarPeyar = selectedVaangunarPeyarMap,
            vaangunarMunvari = selectedVaangunarMunvariMap,
            patruNaal = patruNaal,
            patruEn = patruEn.trim(),
            vanakkam = receipt?.vanakkam ?: 1,
            thogai = amount,
            seluthumMurai = seluthumMurai,
            parivarthanaiEn = parivarthanaiEn.trim(),
            vangiPeyar = null,
            ullkurippu = ullkurippu.trim(),
            createdAt = receipt?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )

        val resultId = PatrugalRepository.save(entryToSave, currentMode)
        if (resultId > 0L) {
            ElvanSnackbar.show(saveSuccessMsg)
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
                bottom = Dimens.SubpageContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
        ) {
            // Top spacer driven by One UI collapsible header
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            // Section 1: Business Profile Selection
            item(key = "profile_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.niruvanam.tr(),
                        colors = colors
                    ) {
                        val activeProfile = profiles.find { it.id == selectedNiruvanamId }
                        val profileDisplayName = if (activeProfile != null) {
                            if (activeProfile.kurumPeyar.isNotEmpty()) activeProfile.kurumPeyar
                            else activeProfile.niruvanathinPeyar.values.firstOrNull().orEmpty()
                        } else {
                            K.niruvanaththaithThaernhedu.tr()
                        }

                        ElvanSettingsRow(
                            title = profileDisplayName,
                            description = activeProfile?.tholaipaesi1,
                            icon = MaterialSymbols.Rounded.BusinessCenter,
                            onClick = {
                                if (profiles.size > 1) {
                                    showProfilePicker = true
                                }
                            },
                            customTrailing = if (profiles.size > 1) {
                                {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.ChevronRight,
                                        contentDescription = null,
                                        tint = colors.textSecondary,
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
                            } else null,
                            colors = colors
                        )
                    }
                }
            }

            // Section 2: Customer (Vaangunar) Selection
            item(key = "customer_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.vaangunar.tr(),
                        colors = colors
                    ) {
                        val customerName = selectedVaangunarPeyarMap.values.firstOrNull()?.ifEmpty { null }
                            ?: K.vaangunarPeyarThaedu.tr()
                        val customerOor = selectedVaangunarMunvariMap.values.firstOrNull()

                        ElvanSettingsRow(
                            title = customerName,
                            description = customerOor,
                            icon = MaterialSymbols.CustomNav.Customers,
                            onClick = { showMerchantPicker = true },
                            customTrailing = {
                                Icon(
                                    imageVector = MaterialSymbols.Rounded.ChevronRight,
                                    contentDescription = null,
                                    tint = colors.textSecondary,
                                    modifier = Modifier.size(20.dp)
                                )
                            },
                            colors = colors
                        )
                    }
                }
            }

            // Section 3: Receipt Metadata (Number and Date)
            item(key = "metadata_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.tharavuthalam.tr(),
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            ElvanSettingsTextField(
                                label = K.en.tr(),
                                value = patruEn,
                                onValueChange = { patruEn = it },
                                placeholder = "PR-001",
                                colors = colors
                            )

                            ElvanSettingsRow(
                                title = DateUtils.formatEpochMillis(patruNaal),
                                description = K.pirandhaThaedhi.tr(),
                                icon = MaterialSymbols.Rounded.CalendarToday,
                                onClick = {
                                    patruNaal = System.currentTimeMillis()
                                },
                                colors = colors
                            )
                        }
                    }
                }
            }

            // Section 4: Amount & Payment Method
            item(key = "payment_details_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.vilaiMatrumVari.tr(),
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            ElvanSettingsTextField(
                                label = "${K.motham.tr()} *",
                                value = thogai,
                                onValueChange = {
                                    thogai = it
                                    validationError = null
                                },
                                placeholder = "0.00",
                                prefixText = "₹ ",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                colors = colors
                            )

                            if (validationError != null) {
                                Text(
                                    text = validationError!!,
                                    style = TextStyle(fontFamily = ff, fontSize = 12.sp, color = MaterialTheme.colorScheme.error),
                                    modifier = Modifier.padding(start = 16.dp, top = 2.dp)
                                )
                            }

                            Text(
                                text = K.endhachCheyalmurai.tr().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = colors.textSecondary
                                )
                            )

                            // Payment mode selector chips
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                val methods = listOf(
                                    "vangiMaatram" to K.vangiParimaatram.tr(),
                                    "rokkam" to K.kaasu.tr(),
                                    "kaasoalaimurai" to K.kaasoalai.tr()
                                )

                                methods.forEach { (key, label) ->
                                    val isSelected = seluthumMurai == key
                                    FilterChip(
                                        selected = isSelected,
                                        onClick = { seluthumMurai = key },
                                        label = {
                                            Text(
                                                text = label.preventBrokenLigatures(),
                                                style = TextStyle(
                                                    fontFamily = ff,
                                                    fontSize = 13.sp,
                                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                                                )
                                            )
                                        },
                                        shape = RoundedCornerShape(100),
                                        colors = FilterChipDefaults.filterChipColors(
                                            selectedContainerColor = colors.accent,
                                            selectedLabelColor = MaterialTheme.colorScheme.onPrimary,
                                            containerColor = colors.iconBg,
                                            labelColor = colors.textPrimary
                                        )
                                    )
                                }
                            }

                            // Optional Transaction ID
                            if (seluthumMurai != "rokkam") {
                                ElvanSettingsTextField(
                                    label = K.kurippuEnParimaatraEn.tr(),
                                    value = parivarthanaiEn,
                                    onValueChange = { parivarthanaiEn = it },
                                    placeholder = "UTR / Ref No",
                                    colors = colors
                                )
                            }
                        }
                    }
                }
            }

            // Section 5: Internal Notes
            item(key = "notes_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.kurippu.tr(),
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp)
                        ) {
                            ElvanSettingsTextField(
                                label = K.kurippu.tr(),
                                value = ullkurippu,
                                onValueChange = { ullkurippu = it },
                                placeholder = "...",
                                singleLine = false,
                                colors = colors
                            )
                        }
                    }
                }
            }

            // Delete Action Section (if editing)
            if (isEditing && receipt != null) {
                item(key = "delete_section") {
                    ElvanSectionContainer {
                        ElvanSettingsSection(colors = colors) {
                            ElvanSettingsRow(
                                title = K.azhi.tr(),
                                icon = MaterialSymbols.Rounded.Delete,
                                iconTint = MaterialTheme.colorScheme.error,
                                iconBgColor = MaterialTheme.colorScheme.error.copy(alpha = 0.12f),
                                titleColor = MaterialTheme.colorScheme.error,
                                onClick = { showDeleteConfirm = true },
                                colors = colors
                            )
                        }
                    }
                }
            }
        }
    }

    // Customer Picker Modal
    if (showMerchantPicker) {
        AlertDialog(
            onDismissRequest = { showMerchantPicker = false },
            title = {
                Text(
                    text = K.vaangunar.tr().preventBrokenLigatures(),
                    style = TextStyle(fontFamily = ff, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                )
            },
            text = {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(max = 350.dp)
                ) {
                    if (merchants.isEmpty()) {
                        item {
                            Text(
                                text = K.vaangunarTharavugal.tr(),
                                style = TextStyle(fontFamily = ff, color = colors.textSecondary)
                            )
                        }
                    } else {
                        items(merchants.size) { idx ->
                            val m = merchants[idx]
                            val mName = m.peyar.values.firstOrNull() ?: ""
                            val mOor = m.oor.values.firstOrNull() ?: ""

                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(12.dp))
                                    .clickable {
                                        selectedVaangunarId = m.id
                                        selectedVaangunarPeyarMap = m.peyar
                                        selectedVaangunarMunvariMap = m.oor
                                        showMerchantPicker = false
                                    }
                                    .padding(vertical = 10.dp, horizontal = 8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = mName.preventBrokenLigatures(),
                                        style = TextStyle(fontFamily = ff, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                                    )
                                    if (mOor.isNotEmpty()) {
                                        Text(
                                            text = mOor.preventBrokenLigatures(),
                                            style = TextStyle(fontFamily = ff, color = colors.textSecondary, fontSize = 12.sp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            },
            confirmButton = {
                TextButton(onClick = { showMerchantPicker = false }) {
                    Text(K.kaividuPtn.tr(), style = TextStyle(fontFamily = ff))
                }
            },
            containerColor = colors.surface,
            titleContentColor = colors.textPrimary,
            textContentColor = colors.textPrimary
        )
    }

    // Business Profile Picker Modal
    if (showProfilePicker) {
        AlertDialog(
            onDismissRequest = { showProfilePicker = false },
            title = {
                Text(
                    text = K.niruvanam.tr().preventBrokenLigatures(),
                    style = TextStyle(fontFamily = ff, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                )
            },
            text = {
                Column(modifier = Modifier.fillMaxWidth()) {
                    profiles.forEach { profile ->
                        val pName = if (profile.kurumPeyar.isNotEmpty()) profile.kurumPeyar
                        else profile.niruvanathinPeyar.values.firstOrNull().orEmpty()

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .clickable {
                                    selectedNiruvanamId = profile.id
                                    showProfilePicker = false
                                }
                                .padding(vertical = 12.dp, horizontal = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = pName.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontWeight = if (selectedNiruvanamId == profile.id) FontWeight.Bold else FontWeight.Normal,
                                    fontSize = 15.sp,
                                    color = if (selectedNiruvanamId == profile.id) colors.accent else colors.textPrimary
                                )
                            )
                        }
                    }
                }
            },
            confirmButton = {
                TextButton(onClick = { showProfilePicker = false }) {
                    Text(K.kaividuPtn.tr(), style = TextStyle(fontFamily = ff))
                }
            },
            containerColor = colors.surface,
            titleContentColor = colors.textPrimary,
            textContentColor = colors.textPrimary
        )
    }

    // Delete Confirmation Modal
    if (showDeleteConfirm && receipt != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = confirmDeleteTitle,
            onConfirm = {
                showDeleteConfirm = false
                PatrugalRepository.delete(receipt.id, currentMode)
                ElvanSnackbar.show(deleteSuccessMsg)
                onBack()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
