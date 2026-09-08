package com.elvan.noolachu.ui.screens.thiruthi.patrucheettu

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
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
import com.elvan.noolachu.ui.screens.thiruthi.ElvanEditorSection
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiAttai
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiKeezhvirivu
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiUlleedu

/**
 * Receipt Editor Screen (பற்றுச்சீட்டு திருத்தி)
 * Handles creating and editing payment receipts with Flutter's 1:1 boxed card layout and synced scroll state.
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

    var customerSearchQuery by remember { mutableStateOf("") }

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
    var validationError by remember { mutableStateOf<String?>(null) }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaPatrucheettuPtn.tr()
    val thogaiRequiredMsg = K.thogaiChuzhiyaththaiVidaMigudhiyaagaIrukkaVaendum.tr()
    val saveSuccessMsg = K.chaemippuvetri.tr()
    val saveFailedMsg = K.chaemikkaIyalavillai.tr()
    val deletedMsg = K.azhippuvetri.tr()
    val confirmDeleteTitle = K.nirandharaAzhippuUrudhi.tr()

    fun handleSave() {
        val amount = thogai.trim().toDoubleOrNull() ?: 0.0
        if (amount <= 0.0) {
            validationError = thogaiRequiredMsg
            ElvanSnackbar.show(thogaiRequiredMsg)
            return
        }

        val finalPeyarMap = if (selectedVaangunarPeyarMap.isNotEmpty()) {
            selectedVaangunarPeyarMap
        } else {
            mapOf("ta" to "பொது வாடிக்கையாளர்", "en" to "General Customer")
        }

        val entryToSave = PatrugalTharavuru(
            id = receipt?.id ?: 0L,
            niruvanamId = selectedNiruvanamId,
            vaangunarId = selectedVaangunarId,
            vaangunarPeyar = finalPeyarMap,
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

            // Section 1: Customer (பெறுநர்)
            item(key = "customer_section") {
                ElvanEditorSection(
                    index = 0,
                    title = K.vaangunar.tr()
                ) {
                    val hasCustomer = selectedVaangunarId != null || selectedVaangunarPeyarMap.isNotEmpty()

                    if (hasCustomer) {
                        val customerName = selectedVaangunarPeyarMap.values.firstOrNull()?.ifEmpty { null }
                            ?: K.vaangunar.tr()
                        val customerAddress = selectedVaangunarMunvariMap.values.firstOrNull()?.ifEmpty { null }

                        ElvanThiruthiAttai {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.Top
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = K.chaemiththaTharavugal.tr().preventBrokenLigatures(),
                                        style = TextStyle(
                                            fontFamily = ff,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.SemiBold,
                                            color = colors.textSecondary
                                        )
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = customerName.preventBrokenLigatures(),
                                        style = TextStyle(
                                            fontFamily = ff,
                                            fontSize = 16.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = colors.textPrimary
                                        )
                                    )
                                    if (!customerAddress.isNullOrBlank()) {
                                        Spacer(modifier = Modifier.height(2.dp))
                                        Text(
                                            text = customerAddress.preventBrokenLigatures(),
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 13.sp,
                                                color = colors.textSecondary
                                            )
                                        )
                                    }
                                }

                                Box(
                                    modifier = Modifier
                                        .size(32.dp)
                                        .clip(CircleShape)
                                        .background(colors.iconBg)
                                        .clickable {
                                            selectedVaangunarId = null
                                            selectedVaangunarPeyarMap = emptyMap()
                                            selectedVaangunarMunvariMap = emptyMap()
                                            customerSearchQuery = ""
                                        },
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Close,
                                        contentDescription = K.kaividuPtn.tr(),
                                        tint = colors.textSecondary,
                                        modifier = Modifier.size(18.dp)
                                    )
                                }
                            }
                        }
                    } else {
                        ElvanThiruthiAttai {
                            ElvanThiruthiUlleedu(
                                label = K.vaangunarPeyarThaedu.tr(),
                                value = customerSearchQuery,
                                onValueChange = { customerSearchQuery = it },
                                placeholder = K.vaangunarPeyarThaedu.tr(),
                                prefixIcon = {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Search,
                                        contentDescription = null,
                                        tint = colors.textSecondary,
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
                            )

                            val filteredMerchants = if (customerSearchQuery.isBlank()) {
                                merchants.take(4)
                            } else {
                                merchants.filter { m ->
                                    m.peyar.values.any { it.contains(customerSearchQuery, ignoreCase = true) } ||
                                    m.oor.values.any { it.contains(customerSearchQuery, ignoreCase = true) }
                                }.take(6)
                            }

                            if (filteredMerchants.isNotEmpty()) {
                                Column(
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalArrangement = Arrangement.spacedBy(6.dp)
                                ) {
                                    filteredMerchants.forEach { m ->
                                        val mName = m.peyar.values.firstOrNull().orEmpty()
                                        val mOor = m.oor.values.firstOrNull().orEmpty()

                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .clip(RoundedCornerShape(12.dp))
                                                .background(colors.iconBg)
                                                .clickable {
                                                    selectedVaangunarId = m.id
                                                    selectedVaangunarPeyarMap = m.peyar
                                                    selectedVaangunarMunvariMap = m.oor
                                                }
                                                .padding(horizontal = 14.dp, vertical = 10.dp),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Column {
                                                Text(
                                                    text = mName.preventBrokenLigatures(),
                                                    style = TextStyle(
                                                        fontFamily = ff,
                                                        fontSize = 14.sp,
                                                        fontWeight = FontWeight.SemiBold,
                                                        color = colors.textPrimary
                                                    )
                                                )
                                                if (mOor.isNotBlank()) {
                                                    Text(
                                                        text = mOor.preventBrokenLigatures(),
                                                        style = TextStyle(
                                                            fontFamily = ff,
                                                            fontSize = 12.sp,
                                                            color = colors.textSecondary
                                                        )
                                                    )
                                                }
                                            }

                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.ChevronRight,
                                                contentDescription = null,
                                                tint = colors.textSecondary,
                                                modifier = Modifier.size(18.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Section 2: Receipt Metadata (பற்றுச்சீட்டு விவரங்கள்)
            item(key = "metadata_section") {
                ElvanEditorSection(
                    index = 1,
                    title = K.patrucheettu.tr()
                ) {
                    ElvanThiruthiAttai {
                        if (profiles.size > 1) {
                            val activeProfile = profiles.find { it.id == selectedNiruvanamId }
                            val profileDisplayName = activeProfile?.kurumPeyar?.ifEmpty {
                                activeProfile.niruvanathinPeyar.values.firstOrNull().orEmpty()
                            } ?: K.niruvanaththaithThaernhedu.tr()

                            ElvanThiruthiKeezhvirivu(
                                label = K.niruvanam.tr(),
                                selectedText = profileDisplayName,
                                items = profiles.map { p ->
                                    val name = p.kurumPeyar.ifEmpty { p.niruvanathinPeyar.values.firstOrNull().orEmpty() }
                                    p.id.toString() to name
                                },
                                onSelected = { selectedNiruvanamId = it.toLongOrNull() }
                            )
                        }

                        ElvanThiruthiUlleedu(
                            label = K.en.tr(),
                            value = patruEn,
                            onValueChange = { patruEn = it },
                            placeholder = "PR-001"
                        )

                        ElvanThiruthiUlleedu(
                            label = K.pirandhaThaedhi.tr(),
                            value = DateUtils.formatEpochMillis(patruNaal),
                            onValueChange = {},
                            enabled = false,
                            suffixIcon = {
                                Icon(
                                    imageVector = MaterialSymbols.Rounded.CalendarToday,
                                    contentDescription = null,
                                    tint = colors.textSecondary,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        )
                    }
                }
            }

            // Section 3: Payment Details (செலுத்துதல் விவரங்கள்)
            item(key = "payment_details_section") {
                ElvanEditorSection(
                    index = 2,
                    title = "செலுத்துதல் விவரங்கள்"
                ) {
                    ElvanThiruthiAttai {
                        ElvanThiruthiUlleedu(
                            label = K.thogai.tr(),
                            value = thogai,
                            onValueChange = {
                                thogai = it
                                validationError = null
                            },
                            placeholder = "0.00",
                            prefixText = "₹ ",
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                            errorMessage = validationError
                        )

                        ElvanThiruthiKeezhvirivu(
                            label = "செலுத்தும் முறை",
                            selectedText = when (seluthumMurai) {
                                "roakkam" -> "ரொக்கம்"
                                "cheque" -> K.kaasoalai.tr()
                                "upi" -> "UPI"
                                else -> "வங்கி மாற்றம்"
                            },
                            items = listOf(
                                "vangiMaatram" to "வங்கி மாற்றம்",
                                "roakkam" to "ரொக்கம்",
                                "cheque" to K.kaasoalai.tr(),
                                "upi" to "UPI"
                            ),
                            onSelected = { seluthumMurai = it }
                        )

                        ElvanThiruthiUlleedu(
                            label = "பரிவர்த்தனை எண்",
                            value = parivarthanaiEn,
                            onValueChange = { parivarthanaiEn = it },
                            placeholder = "TRX12345678"
                        )

                        ElvanThiruthiUlleedu(
                            label = K.kurippu.tr(),
                            value = ullkurippu,
                            onValueChange = { ullkurippu = it },
                            placeholder = K.kurippu.tr(),
                            singleLine = false,
                            maxLines = 3
                        )
                    }
                }
            }

            // Delete Card (if editing existing)
            if (isEditing && receipt != null) {
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

    if (showDeleteConfirm && receipt != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = confirmDeleteTitle,
            onConfirm = {
                showDeleteConfirm = false
                PatrugalRepository.delete(receipt.id, currentMode)
                ElvanSnackbar.show(deletedMsg)
                onBack()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
