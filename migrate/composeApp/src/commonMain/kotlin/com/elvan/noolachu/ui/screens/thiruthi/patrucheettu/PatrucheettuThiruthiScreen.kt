package com.elvan.noolachu.ui.screens.thiruthi.patrucheettu

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.model.PatruPattiyalInaippuTharavuru
import com.elvan.noolachu.data.model.PatrugalTharavuru
import com.elvan.noolachu.data.model.SeluthiVagai
import com.elvan.noolachu.data.repository.PatrugalRepository
import com.elvan.noolachu.data.repository.PattiyalRepository
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
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
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiThalaippu
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiUlleedu
import com.elvan.noolachu.ui.screens.thiruthi.patrucheettu.koorugal.PatruPattiyalTheervuMaeladukku
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.koorugal.ElvanAavanaEnnKooru
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.koorugal.PattiyalNaalKooru
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight

/**
 * Receipt Editor Screen (பற்றுச்சீட்டு திருத்தி)
 * Complete 1:1 port of Flutter's `PatruThiruthi` (patru_thiruthi.dart).
 *
 * Architecture:
 * - Section 0: Business profile selector ribbon (locked if unselected)
 * - Section 1: Linked invoice picker (with multi-select bottom sheet & FIFO distribution)
 * - Section 2: Receipt data (date picker, locked customer card, auto-sequenced receipt number)
 * - Section 3: Payment details (amount with auto-calc, SeluthiVagai 5 modes, dynamic reference number, internal notes)
 * - Bottom Delete action (when editing) with ElvanAzhippuUrudhiMaeladukku
 * - Unsaved changes guard with 3-action sheet
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
        mutableStateOf(receipt?.niruvanamId ?: if (profiles.size == 1) profiles.first().id else null)
    }
    val selectedProfile = remember(selectedNiruvanamId, profiles) {
        profiles.firstOrNull { it.id == selectedNiruvanamId }
    }

    // Refresh dependencies on launch
    LaunchedEffect(Unit) {
        PattiyalRepository.loadAll(currentMode)
        PatrugalRepository.loadAll(currentMode)
    }

    // Linked Invoices
    val allInvoices = PattiyalRepository.invoices
    val selectedInvoices = remember { mutableStateListOf<PattiyalTharavuru>() }
    var isInvoicePickerOpen by remember { mutableStateOf(false) }

    // Initial load of linked invoices when editing
    var isInitialized by remember { mutableStateOf(false) }
    LaunchedEffect(receipt?.id, allInvoices) {
        if (receipt != null && !isInitialized && allInvoices.isNotEmpty()) {
            isInitialized = true
            val links = PatrugalRepository.getLinksForPatru(receipt.id, currentMode)
            val matching = links.mapNotNull { link ->
                allInvoices.firstOrNull { it.id == link.pattiyalId }
            }
            selectedInvoices.clear()
            selectedInvoices.addAll(matching)
        }
    }

    // Customer
    var selectedVaangunarId by remember { mutableStateOf(receipt?.vaangunarId) }
    var selectedVaangunarPeyarMap by remember {
        mutableStateOf(receipt?.vaangunarPeyar ?: emptyMap())
    }
    var selectedVaangunarMunvariMap by remember {
        mutableStateOf(receipt?.vaangunarMunvari ?: emptyMap())
    }

    // Receipt Data
    var patruNaal by remember { mutableStateOf(receipt?.patruNaal ?: System.currentTimeMillis()) }
    var vanakkam by remember { mutableStateOf(receipt?.vanakkam ?: 1) }
    var patruEn by remember { mutableStateOf(receipt?.patruEn.orEmpty()) }

    // Payment Details
    var thogai by remember {
        mutableStateOf(
            if (receipt != null && receipt.thogai > 0) {
                if (receipt.thogai % 1.0 == 0.0) receipt.thogai.toLong().toString() else receipt.thogai.toString()
            } else ""
        )
    }
    var seluthiVagai by remember {
        mutableStateOf(SeluthiVagai.fromStored(receipt?.seluthumMurai))
    }
    var suttruEn by remember { mutableStateOf(receipt?.parivarthanaiEn.orEmpty()) }
    var ullkurippu by remember { mutableStateOf(receipt?.ullkurippu.orEmpty()) }

    var hasUnsavedChanges by remember { mutableStateOf(false) }
    var showUnsavedDialog by remember { mutableStateOf(false) }
    var showDeleteConfirm by remember { mutableStateOf(false) }
    var isSaving by remember { mutableStateOf(false) }

    val amaippugalStr = K.amaippugal.tr()
    val pattiyalaiThaernheduMsg = K.pattiyalaiThaernhedu.tr()
    val vaangunarPeyarThaevaiMsg = K.vaangunarPeyarThaevai.tr()
    val thogaiInvalidMsg = K.thogaiChuzhiyaththaiVidaMigudhiyaagaIrukkaVaendum.tr()
    val duplicateMsg = K.patrucheettuEnYaerkanavaeUlladhu.tr()
    val savedMsg = K.patrucheettuChaemikkappattadhu.tr()
    val saveFailedMsg = K.chaemikkaIyalavillai.tr()
    val deletedSuccessMsg = K.azhippuvetri.tr()
    val confirmDeleteTitle = K.nirandharaAzhippuUrudhi.tr()

    // Helper: auto-calculate receipt number
    fun generatePatruEn() {
        if (isEditing) return
        val bizShort = selectedProfile?.kurumPeyar?.trim()?.ifEmpty { null }
            ?: selectedProfile?.niruvanathinPeyar?.get("en")?.split(" ")?.mapNotNull { it.firstOrNull()?.uppercaseChar() }?.joinToString("")?.take(4)?.ifEmpty { null }
            ?: "BIZ"

        val nextSeq = PatrugalRepository.getNextVanakkam(selectedNiruvanamId, currentMode)
        vanakkam = nextSeq
        patruEn = PatrugalRepository.formatPatruEn(bizShort, nextSeq)
    }

    // Auto-generate receipt number on profile selection if new
    LaunchedEffect(selectedNiruvanamId) {
        if (!isEditing && patruEn.isEmpty() && selectedNiruvanamId != null) {
            generatePatruEn()
        }
    }

    // Auto-fill customer and amount when invoices change
    fun onInvoicesUpdated(newList: List<PattiyalTharavuru>) {
        selectedInvoices.clear()
        selectedInvoices.addAll(newList)
        hasUnsavedChanges = true

        if (newList.isNotEmpty()) {
            val total = newList.sumOf { it.mothaThogai }
            thogai = if (total % 1.0 == 0.0) total.toLong().toString() else ((total * 100).toLong() / 100.0).toString()

            val first = newList.first()
            if (selectedVaangunarId == null || selectedVaangunarPeyarMap.isEmpty()) {
                selectedVaangunarId = first.vaangunarId
                selectedVaangunarPeyarMap = first.vaangunarPeyar
                selectedVaangunarMunvariMap = first.vaangunarMunvari
            }
        } else {
            thogai = ""
            selectedVaangunarId = null
            selectedVaangunarPeyarMap = emptyMap()
            selectedVaangunarMunvariMap = emptyMap()
        }
    }

    // Save logic with FIFO distribution
    fun handleSave() {
        if (selectedProfile == null || selectedProfile.kurumPeyar.trim().isEmpty()) {
            ElvanSnackbar.show("$amaippugalStr - Kurum Peyar is required.")
            return
        }

        if (selectedInvoices.isEmpty()) {
            ElvanSnackbar.show(pattiyalaiThaernheduMsg)
            return
        }

        val peyarTamil = selectedVaangunarPeyarMap["ta"] ?: selectedVaangunarPeyarMap.values.firstOrNull().orEmpty()
        if (peyarTamil.trim().isEmpty()) {
            ElvanSnackbar.show(vaangunarPeyarThaevaiMsg)
            return
        }

        val amount = thogai.trim().toDoubleOrNull() ?: 0.0
        if (amount <= 0.0) {
            ElvanSnackbar.show(thogaiInvalidMsg)
            return
        }

        // Duplicate check
        val isDuplicate = PatrugalRepository.isPatruEnDuplicate(
            selectedNiruvanamId,
            patruEn,
            excludeId = receipt?.id,
            mode = currentMode
        )
        if (isDuplicate) {
            ElvanSnackbar.show("$patruEn - $duplicateMsg")
            return
        }

        // FIFO allocation across selected invoices
        val links = mutableListOf<PatruPattiyalInaippuTharavuru>()
        var remaining = amount
        for (inv in selectedInvoices) {
            if (remaining <= 0.0) break
            val apply = remaining.coerceAtMost(inv.mothaThogai)
            if (apply > 0.0) {
                links.add(
                    PatruPattiyalInaippuTharavuru(
                        patruId = receipt?.id ?: 0L,
                        pattiyalId = inv.id,
                        poruthiyaThogai = apply
                    )
                )
                remaining -= apply
            }
        }

        // Validate links
        val validationErr = PatrugalRepository.validateLinks(links, receipt?.id, currentMode)
        if (validationErr != null) {
            ElvanSnackbar.show(validationErr)
            return
        }

        isSaving = true
        try {
            val now = System.currentTimeMillis()
            val defaultFinYear = DateUtils.formatEpochMillis(now).split("/").last()
            val entryToSave = PatrugalTharavuru(
                id = receipt?.id ?: 0L,
                niruvanamId = selectedNiruvanamId,
                patruEn = patruEn.trim(),
                finYear = receipt?.finYear ?: defaultFinYear,
                vanakkam = vanakkam,
                vaangunarId = selectedVaangunarId,
                vaangunarPeyar = selectedVaangunarPeyarMap,
                vaangunarMunvari = selectedVaangunarMunvariMap,
                patruNaal = patruNaal,
                thogai = amount,
                seluthumMurai = seluthiVagai.storedValue,
                vangiPeyar = receipt?.vangiPeyar,
                parivarthanaiEn = if (seluthiVagai.needsReference) suttruEn.trim() else null,
                ullkurippu = ullkurippu.trim(),
                createdAt = receipt?.createdAt ?: now,
                updatedAt = now,
                isDeleted = false
            )

            val savedId = PatrugalRepository.saveWithLinks(entryToSave, links, currentMode)
            if (savedId > 0L) {
                ElvanSnackbar.show(savedMsg)
                onBack()
            } else {
                ElvanSnackbar.show(saveFailedMsg)
            }
        } catch (e: Exception) {
            ElvanSnackbar.show("$saveFailedMsg ${e.message}")
        } finally {
            isSaving = false
        }
    }

    // Back navigation guard
    fun handleBackAttempt() {
        if (hasUnsavedChanges) {
            showUnsavedDialog = true
        } else {
            onBack()
        }
    }

    AppBackHandler(enabled = true) {
        handleBackAttempt()
    }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaPatrucheettuPtn.tr()
    val scrollState = rememberLazyListState()

    ElvanSubShell(
        title = pageTitle,
        onBack = { handleBackAttempt() },
        scrollState = scrollState,
        hasActions = true,
        actions = {
            ElvanCheyalPothan(
                label = K.chaemiPtn.tr(),
                onClick = { handleSave() },
                enabled = !isSaving
            )
        }
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            LazyColumn(
                state = scrollState,
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(
                    start = 16.dp,
                    end = 16.dp,
                    top = 16.dp,
                    bottom = 120.dp
                ),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                item(key = "top_spacer") {
                    Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
                }

                // Section 0: Business Profile Selector (when multiple profiles exist)
                val baseIndex = if (profiles.size > 1) {
                    item {
                        ElvanEditorSection(index = 1, title = K.niruvanam.tr()) {
                            ElvanThiruthiAttai {
                                ElvanThiruthiKeezhvirivu(
                                    label = K.niruvanaththaithThaernhedu.tr(),
                                    selectedText = selectedProfile?.kurumPeyar ?: K.niruvanamThaerodhu.tr(),
                                    items = profiles.map { it.kurumPeyar to it.kurumPeyar },
                                    onSelected = { pickedName ->
                                        val picked = profiles.firstOrNull { it.kurumPeyar == pickedName }
                                        selectedNiruvanamId = picked?.id
                                        generatePatruEn()
                                        hasUnsavedChanges = true
                                    }
                                )
                            }
                        }
                    }
                    2
                } else {
                    1
                }

                // Section 1: Linked Invoice Picker (Required)
                item {
                    ElvanEditorSection(index = baseIndex, title = K.endhapPattiyalukku.tr()) {
                        ElvanThiruthiAttai {
                            Column(modifier = Modifier.fillMaxWidth().padding(12.dp)) {
                                if (selectedInvoices.isEmpty()) {
                                    // Empty state: Tappable button to open modal
                                    Box(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(48.dp)
                                            .clip(RoundedCornerShape(999.dp))
                                            .background(if (colors.isDark) Color.White.copy(alpha = 0.08f) else Color(0xFFF1F3F4))
                                            .clickable { isInvoicePickerOpen = true }
                                            .padding(horizontal = 16.dp),
                                        contentAlignment = Alignment.CenterStart
                                    ) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Row(verticalAlignment = Alignment.CenterVertically) {
                                                Icon(
                                                    imageVector = MaterialSymbols.Rounded.Description,
                                                    contentDescription = null,
                                                    tint = colors.accent,
                                                    modifier = Modifier.size(18.dp)
                                                )
                                                Spacer(modifier = Modifier.width(8.dp))
                                                Text(
                                                    text = K.pattiyalgalaiThaernhedu.tr().preventBrokenLigatures(),
                                                    style = TextStyle(
                                                        fontFamily = ff,
                                                        fontSize = 14.sp,
                                                        color = colors.textPrimary
                                                    )
                                                )
                                            }
                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.ChevronRight,
                                                contentDescription = null,
                                                tint = colors.textSecondary
                                            )
                                        }
                                    }
                                } else {
                                    // List of selected invoices with remove button
                                    Column(
                                        modifier = Modifier.fillMaxWidth(),
                                        verticalArrangement = Arrangement.spacedBy(8.dp)
                                    ) {
                                        selectedInvoices.forEach { inv ->
                                            val formattedAmount = "₹ " + if (inv.mothaThogai % 1.0 == 0.0) {
                                                inv.mothaThogai.toLong().toString()
                                            } else {
                                                ((inv.mothaThogai * 100).toLong() / 100.0).toString()
                                            }

                                            Row(
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .clip(RoundedCornerShape(12.dp))
                                                    .background(colors.accent.copy(alpha = 0.08f))
                                                    .padding(horizontal = 14.dp, vertical = 10.dp),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                Column(modifier = Modifier.weight(1f)) {
                                                    Text(
                                                        text = inv.patrucheettuEn,
                                                        style = TextStyle(
                                                            fontFamily = ff,
                                                            fontSize = 14.sp,
                                                            fontWeight = FontWeight.SemiBold,
                                                            color = colors.textPrimary
                                                        )
                                                    )
                                                    Text(
                                                        text = formattedAmount,
                                                        style = TextStyle(
                                                            fontFamily = ff,
                                                            fontSize = 12.sp,
                                                            fontWeight = FontWeight.Medium,
                                                            color = colors.accent
                                                        )
                                                    )
                                                }

                                                IconButton(
                                                    onClick = {
                                                        val updated = selectedInvoices.filter { it.id != inv.id }
                                                        onInvoicesUpdated(updated)
                                                    },
                                                    modifier = Modifier.size(28.dp)
                                                ) {
                                                    Icon(
                                                        imageVector = MaterialSymbols.Rounded.Close,
                                                        contentDescription = "Remove",
                                                        tint = colors.textSecondary,
                                                        modifier = Modifier.size(18.dp)
                                                    )
                                                }
                                            }
                                        }

                                        // Button to add more / re-open picker
                                        OutlinedButton(
                                            onClick = { isInvoicePickerOpen = true },
                                            modifier = Modifier.fillMaxWidth().height(42.dp),
                                            shape = RoundedCornerShape(999.dp),
                                            colors = ButtonDefaults.outlinedButtonColors(
                                                contentColor = colors.accent
                                            )
                                        ) {
                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.Add,
                                                contentDescription = null,
                                                modifier = Modifier.size(16.dp)
                                            )
                                            Spacer(modifier = Modifier.width(6.dp))
                                            Text(
                                                text = K.pattiyalgalaiThaernhedu.tr().preventBrokenLigatures(),
                                                style = TextStyle(fontFamily = ff, fontSize = 13.sp, fontWeight = FontWeight.Medium)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Section 2: Receipt Data
                item {
                    ElvanEditorSection(index = baseIndex + 1, title = K.patrucheettuTharavugal.tr()) {
                        ElvanThiruthiAttai {
                            Column(
                                modifier = Modifier.fillMaxWidth().padding(12.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                // 1. Receipt Date
                                PattiyalNaalKooru(
                                    selectedDate = patruNaal,
                                    onDateChanged = {
                                        patruNaal = it
                                        hasUnsavedChanges = true
                                    },
                                    label = K.patrucheettuNaal.tr()
                                )

                                // 2. Customer Info (Locked from invoice)
                                Column(modifier = Modifier.fillMaxWidth()) {
                                    ElvanThiruthiThalaippu(label = K.vaangunar.tr())
                                    val customerName = selectedVaangunarPeyarMap["ta"]
                                        ?: selectedVaangunarPeyarMap.values.firstOrNull()
                                        ?: ""

                                    Box(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(45.dp)
                                            .clip(RoundedCornerShape(999.dp))
                                            .background(if (colors.isDark) Color.White.copy(alpha = 0.08f) else Color.White)
                                            .padding(horizontal = 16.dp),
                                        contentAlignment = Alignment.CenterStart
                                    ) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            if (customerName.isNotEmpty()) {
                                                Text(
                                                    text = customerName.preventBrokenLigatures(),
                                                    style = TextStyle(
                                                        fontFamily = ff,
                                                        fontSize = 14.sp,
                                                        fontWeight = FontWeight.Medium,
                                                        color = colors.textPrimary
                                                    ),
                                                    maxLines = 1,
                                                    overflow = TextOverflow.Ellipsis,
                                                    modifier = Modifier.weight(1f)
                                                )
                                                Icon(
                                                    imageVector = MaterialSymbols.Rounded.Lock,
                                                    contentDescription = "Locked",
                                                    tint = colors.textSecondary.copy(alpha = 0.4f),
                                                    modifier = Modifier.size(16.dp)
                                                )
                                            } else {
                                                Row(verticalAlignment = Alignment.CenterVertically) {
                                                    Icon(
                                                        imageVector = MaterialSymbols.Rounded.Info,
                                                        contentDescription = null,
                                                        tint = colors.textSecondary.copy(alpha = 0.5f),
                                                        modifier = Modifier.size(16.dp)
                                                    )
                                                    Spacer(modifier = Modifier.width(8.dp))
                                                    Text(
                                                        text = K.pattiyalThaervukkuPinVaangunarTharavugalNirappappadum.tr().preventBrokenLigatures(),
                                                        style = TextStyle(
                                                            fontFamily = ff,
                                                            fontSize = 12.sp,
                                                            color = colors.textSecondary.copy(alpha = 0.6f)
                                                        ),
                                                        maxLines = 1,
                                                        overflow = TextOverflow.Ellipsis
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }

                                // 3. Receipt Number (Editable capsule with pencil toggle)
                                val bizPrefix = selectedProfile?.kurumPeyar?.let { "RCP/$it/" } ?: "RCP/BIZ/"
                                ElvanAavanaEnnKooru(
                                    label = K.patrucheettuEn.tr(),
                                    prefix = bizPrefix,
                                    initialFullNumber = patruEn,
                                    onFullNumberChanged = {
                                        patruEn = it
                                        hasUnsavedChanges = true
                                    },
                                    onDirty = { hasUnsavedChanges = true }
                                )
                            }
                        }
                    }
                }

                // Section 3: Payment Details
                item {
                    ElvanEditorSection(index = baseIndex + 2, title = K.cheluthiyaTharavu.tr()) {
                        ElvanThiruthiAttai {
                            Column(
                                modifier = Modifier.fillMaxWidth().padding(12.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                // Amount field
                                ElvanThiruthiUlleedu(
                                    value = thogai,
                                    onValueChange = {
                                        thogai = it
                                        hasUnsavedChanges = true
                                    },
                                    label = K.thogaiVinmeen.tr(),
                                    prefixText = "₹ ",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
                                )

                                // Payment Mode Dropdown
                                ElvanThiruthiKeezhvirivu(
                                    label = K.cheluthumMuraiVinmeen.tr(),
                                    selectedText = seluthiVagai.label(),
                                    items = SeluthiVagai.allOptions(),
                                    onSelected = { pickedName ->
                                        val picked = SeluthiVagai.entries.firstOrNull { it.name == pickedName }
                                        if (picked != null) {
                                            seluthiVagai = picked
                                            hasUnsavedChanges = true
                                        }
                                    }
                                )

                                // Reference Number (only visible when required)
                                if (seluthiVagai.needsReference) {
                                    ElvanThiruthiUlleedu(
                                        value = suttruEn,
                                        onValueChange = {
                                            suttruEn = it
                                            hasUnsavedChanges = true
                                        },
                                        label = K.kurippuEnParimaatraEn.tr()
                                    )
                                }

                                // Internal Notes
                                ElvanThiruthiUlleedu(
                                    value = ullkurippu,
                                    onValueChange = {
                                        ullkurippu = it
                                        hasUnsavedChanges = true
                                    },
                                    label = K.kurippu.tr(),
                                    maxLines = 3,
                                    singleLine = false
                                )
                            }
                        }
                    }
                }

                // Delete Section (visible only when editing)
                if (isEditing) {
                    item {
                        ElvanThiruthiAttai(backgroundColor = MaterialTheme.colorScheme.error.copy(alpha = 0.08f)) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { showDeleteConfirm = true }
                                    .padding(12.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = K.azhikka.tr().preventBrokenLigatures(),
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

            // Bottom Floating Save Bar
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .background(colors.background.copy(alpha = 0.95f))
                    .padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                Button(
                    onClick = { handleSave() },
                    modifier = Modifier.fillMaxWidth().height(50.dp),
                    shape = RoundedCornerShape(999.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = colors.accent,
                        contentColor = Color.White
                    ),
                    enabled = !isSaving
                ) {
                    Text(
                        text = K.chaemiPtn.tr().preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    )
                }
            }
        }
    }

    // Modal 1: Invoice Picker Bottom Sheet
    if (isInvoicePickerOpen) {
        val selectableInvoices = if (selectedNiruvanamId != null) {
            allInvoices.filter { it.niruvanamId == selectedNiruvanamId }
        } else {
            allInvoices
        }

        PatruPattiyalTheervuMaeladukku(
            invoices = selectableInvoices,
            initialSelectedIds = selectedInvoices.map { it.id }.toSet(),
            onConfirmed = { pickedList ->
                onInvoicesUpdated(pickedList)
            },
            onDismissRequest = { isInvoicePickerOpen = false }
        )
    }

    // Modal 2: Delete Confirmation Modal
    if (showDeleteConfirm && receipt != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = "${receipt.patruEn} — $confirmDeleteTitle",
            onConfirm = {
                showDeleteConfirm = false
                val success = PatrugalRepository.delete(receipt.id, currentMode)
                if (success) {
                    ElvanSnackbar.show(deletedSuccessMsg)
                    onBack()
                } else {
                    ElvanSnackbar.show(saveFailedMsg)
                }
            },
            onDismissRequest = { showDeleteConfirm = false }
        )
    }

    // Modal 3: Unsaved Changes Action Sheet
    if (showUnsavedDialog) {
        ElvanActionSheet(
            title = K.chaemippuNiluvai.tr(),
            cancelText = K.thodarPtn.tr(),
            confirmText = K.chaemiPtn.tr(),
            tertiaryText = K.purakkaniPtn.tr(),
            onDismissRequest = { showUnsavedDialog = false },
            onConfirm = {
                showUnsavedDialog = false
                handleSave()
            },
            onTertiary = {
                showUnsavedDialog = false
                onBack()
            }
        )
    }
}
