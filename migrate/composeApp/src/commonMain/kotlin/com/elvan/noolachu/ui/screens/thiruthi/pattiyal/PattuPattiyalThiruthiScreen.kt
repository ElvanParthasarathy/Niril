package com.elvan.noolachu.ui.screens.thiruthi.pattiyal

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.material3.ripple
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.repository.PattiyalRepository
import com.elvan.noolachu.data.settings.NiruvanaTharavugal
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanActionSheet
import com.elvan.noolachu.ui.components.shell.ElvanSelectionBottomSheet
import com.elvan.noolachu.ui.components.shell.ElvanSubShell
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.screens.thiruthi.ElvanEditorSection
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiAttai
import com.elvan.noolachu.ui.screens.thiruthi.ElvanThiruthiThalaippu
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.koorugal.*

/**
 * Pixel-Perfect Silk (GST) Invoice Editor — matches Flutter's `SilkInvoiceEditor` 1:1.
 * Features:
 * - Bottom-up sheet selectors for Customer, Product, Invoice Type, and Company.
 * - Real-time CGST/SGST (Intra-state) vs IGST (Inter-state) GST calculation engine.
 * - Smooth 300ms animated line items addition and deletion.
 * - Unsaved changes confirmation action sheet guard.
 */
@Composable
fun PattuPattiyalThiruthiScreen(
    invoice: PattiyalTharavuru? = null,
    onBack: () -> Unit,
    onRequestAddNewCustomer: () -> Unit = {},
    onRequestAddNewProduct: () -> Unit = {}
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current
    val isEditing = invoice != null && invoice.id > 0L

    val profiles: List<NiruvanaTharavugal> = NiruvanaTharavugalRepository.getAllProfiles(AppMode.PATTU)
    var selectedNiruvanamId by remember {
        mutableStateOf(invoice?.niruvanamId ?: profiles.firstOrNull()?.id)
    }
    val selectedProfile = profiles.firstOrNull { it.id == selectedNiruvanamId }

    // Customer
    var selectedVaangunarId by remember { mutableStateOf(invoice?.vaangunarId) }
    var selectedVaangunarPeyarMap by remember { mutableStateOf(invoice?.vaangunarPeyar ?: emptyMap()) }
    var selectedVaangunarMunvariMap by remember { mutableStateOf(invoice?.vaangunarMunvari ?: emptyMap()) }
    var customerState by remember { mutableStateOf("") }

    // Metadata
    var pattiyalVagai by remember { mutableStateOf(invoice?.pattiyalVagai?.ifEmpty { "tax-invoice" } ?: "tax-invoice") }
    var invoiceDate by remember { mutableStateOf(invoice?.pattiyalNaal ?: System.currentTimeMillis()) }
    var placeOfSupplyEn by remember { mutableStateOf("Tamil Nadu") }
    var placeOfSupplyTa by remember { mutableStateOf("தமிழ்நாடு") }

    val defaultInvoiceNumber = remember {
        invoice?.patrucheettuEn?.ifEmpty { "INV-${(System.currentTimeMillis() % 10000)}" }
            ?: "INV-${(System.currentTimeMillis() % 10000)}"
    }
    var invoiceNumber by remember { mutableStateOf(defaultInvoiceNumber) }

    // Line items
    var items by remember {
        mutableStateOf(
            listOf(
                PattuUrupadi(
                    porulPeyar = if (invoice != null && invoice.mothaThogai > 0) "பட்டு புடவை" else "",
                    alavu = 1.0,
                    vilai = if (invoice != null && invoice.mothaThogai > 0) invoice.mothaThogai else 0.0,
                    variVizhukkaadu = 5.0
                )
            )
        )
    }

    // Global discount
    var globalDiscountValue by remember { mutableStateOf(if (invoice != null && invoice.podhuThallupadiMathippu > 0) invoice.podhuThallupadiMathippu.toString() else "") }
    var globalDiscountType by remember { mutableStateOf(invoice?.podhuThallupadiVagai ?: "%") }

    // Guards & states
    var hasUnsavedChanges by remember { mutableStateOf(false) }
    var showUnsavedDialog by remember { mutableStateOf(false) }
    var isSaving by remember { mutableStateOf(false) }
    var isCompanySheetOpen by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Calculation Engine
    val businessState = selectedProfile?.maanilam?.get("en")
        ?: selectedProfile?.maanilam?.get("ta")
        ?: "Tamil Nadu"

    val totals = remember(items, globalDiscountValue, globalDiscountType, businessState, placeOfSupplyEn) {
        val discountDouble = globalDiscountValue.toDoubleOrNull() ?: 0.0
        PattuKanakku.calculate(
            items = items,
            globalDiscountValue = discountDouble,
            globalDiscountType = globalDiscountType,
            businessState = businessState,
            customerState = placeOfSupplyEn,
            country = "India"
        )
    }

    val handleBack = {
        if (hasUnsavedChanges) {
            showUnsavedDialog = true
        } else {
            onBack()
        }
    }

    AppBackHandler(enabled = true) {
        handleBack()
    }

    val vaangunarRequiredMsg = K.vaangunaraiThaerodhu.tr()
    val porulRequiredMsg = K.kuriaindhOruPorul.tr()
    val saveBtnLabel = K.chaemiPtn.tr()
    val addNewProductLabel = K.porulaichChaerPtn.tr()

    val handleSave: () -> Unit = {
        if (selectedVaangunarId == null && selectedVaangunarPeyarMap.isEmpty()) {
            errorMessage = vaangunarRequiredMsg
        } else {
            val validItems = items.filter { it.alavu > 0 && it.vilai > 0 }
            if (validItems.isEmpty()) {
                errorMessage = porulRequiredMsg
            } else {
                isSaving = true
                val newInvoice = PattiyalTharavuru(
                    id = invoice?.id ?: 0L,
                    niruvanamId = selectedNiruvanamId,
                    patrucheettuEn = invoiceNumber,
                    pattiyalVagai = pattiyalVagai,
                    vaangunarId = selectedVaangunarId,
                    vaangunarPeyar = selectedVaangunarPeyarMap,
                    vaangunarMunvari = selectedVaangunarMunvariMap,
                    pattiyalNaal = invoiceDate,
                    mothaThogai = totals.mothaMothangal,
                    thallupadi = totals.thallupadiMothangal,
                    podhuThallupadiMathippu = globalDiscountValue.toDoubleOrNull() ?: 0.0,
                    podhuThallupadiVagai = globalDiscountType,
                    variThogai = totals.variMothangal,
                    updatedAt = System.currentTimeMillis()
                )
                PattiyalRepository.save(newInvoice, AppMode.PATTU)
                hasUnsavedChanges = false
                isSaving = false
                onBack()
            }
        }
    }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaAakkam.tr()
    val scrollState = rememberLazyListState()

    ElvanSubShell(
        title = pageTitle,
        onBack = handleBack,
        scrollState = scrollState,
        hasActions = true,
        actions = {
            // Save Pill Button in Top Bar
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(999.dp))
                    .background(colors.textPrimary)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(bounded = true),
                        onClick = handleSave
                    )
                    .padding(horizontal = 20.dp, vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = saveBtnLabel.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = if (isDark) Color.Black else Color.White
                    )
                )
            }
        }
    ) {
        LazyColumn(
            state = scrollState,
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            contentPadding = PaddingValues(top = 16.dp, bottom = 48.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // ── Error Message Banner ──
            if (!errorMessage.isNullOrBlank()) {
                item(key = "error_banner") {
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = MaterialTheme.colorScheme.errorContainer,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = errorMessage!!.preventBrokenLigatures(),
                            color = MaterialTheme.colorScheme.onErrorContainer,
                            style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.Medium),
                            modifier = Modifier.padding(14.dp)
                        )
                    }
                }
            }

            // ── Section 0: Business Profile Selector (if multiple profiles exist) ──
            if (profiles.size > 1) {
                item(key = "profile_section") {
                    val companyName = selectedProfile?.kurumPeyar?.ifEmpty {
                        selectedProfile.niruvanathinPeyar.values.firstOrNull().orEmpty()
                    } ?: K.niruvanaththaithThaernhedu.tr()

                    ElvanEditorSection(index = 0, title = K.niruvanathTharavu.tr()) {
                        Column(modifier = Modifier.fillMaxWidth()) {
                            ElvanThiruthiThalaippu(label = K.niruvanam.tr())
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(45.dp)
                                    .clip(RoundedCornerShape(999.dp))
                                    .background(if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.05f))
                                    .clickable { isCompanySheetOpen = true }
                                    .padding(horizontal = 16.dp),
                                contentAlignment = Alignment.CenterStart
                            ) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = companyName.preventBrokenLigatures(),
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.Medium, color = colors.textPrimary)
                                    )
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.KeyboardArrowDown,
                                        contentDescription = null,
                                        tint = colors.textSecondary,
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }

            val baseIndex = if (profiles.size > 1) 1 else 0

            // ── Section 1: ① Billed To (பெறுநர்) ──
            item(key = "customer_section") {
                ElvanEditorSection(index = baseIndex, title = K.perunar.tr()) {
                    PattuVaangunargalKooru(
                        selectedVaangunarId = selectedVaangunarId,
                        onCustomerSelected = { customer ->
                            selectedVaangunarId = customer.id
                            selectedVaangunarPeyarMap = customer.peyar
                            selectedVaangunarMunvariMap = customer.oor
                            val sEn = customer.maanilam["en"].orEmpty()
                            val sTa = customer.maanilam["ta"] ?: customer.maanilam.values.firstOrNull().orEmpty()
                            customerState = sEn
                            if (sEn.isNotEmpty()) {
                                placeOfSupplyEn = sEn
                                placeOfSupplyTa = sTa
                            }
                            hasUnsavedChanges = true
                            errorMessage = null
                        },
                        onCustomerCleared = {
                            selectedVaangunarId = null
                            selectedVaangunarPeyarMap = emptyMap()
                            selectedVaangunarMunvariMap = emptyMap()
                            customerState = ""
                            hasUnsavedChanges = true
                        },
                        onRequestAddNewCustomer = onRequestAddNewCustomer
                    )
                }
            }

            // ── Section 2: ② Invoice Details (பட்டியல் தரவுகள்) ──
            item(key = "invoice_details_section") {
                ElvanEditorSection(index = baseIndex + 1, title = K.pattiyalTharavugal.tr()) {
                    ElvanThiruthiAttai(padding = PaddingValues(16.dp), borderRadius = 20.dp) {
                        // Invoice Number with pencil edit pill
                        val profilePrefix = if (selectedProfile != null && selectedProfile.kurumPeyar.isNotEmpty()) {
                            "${selectedProfile.kurumPeyar}-"
                        } else {
                            "INV-"
                        }

                        ElvanAavanaEnnKooru(
                            label = K.pattiyalEn.tr(),
                            prefix = profilePrefix,
                            initialFullNumber = invoiceNumber,
                            onFullNumberChanged = {
                                invoiceNumber = it
                                hasUnsavedChanges = true
                            },
                            onDirty = { hasUnsavedChanges = true }
                        )

                        // Date Picker Pill
                        PattiyalNaalKooru(
                            label = K.naal.tr(),
                            selectedDate = invoiceDate,
                            onDateChanged = {
                                invoiceDate = it
                                hasUnsavedChanges = true
                            }
                        )

                        // Place of Supply with Indian states selection
                        PattuVilippiIdam(
                            placeOfSupplyEn = placeOfSupplyEn,
                            placeOfSupplyTa = placeOfSupplyTa,
                            onSelected = { en, ta ->
                                placeOfSupplyEn = en
                                placeOfSupplyTa = ta
                                hasUnsavedChanges = true
                            },
                            onCleared = {
                                placeOfSupplyEn = ""
                                placeOfSupplyTa = ""
                                hasUnsavedChanges = true
                            }
                        )
                    }
                }
            }

            // ── Section 3: ③ Line Items (பொருட்கள்) ──
            item(key = "line_items_section") {
                ElvanEditorSection(index = baseIndex + 2, title = K.porutkal.tr()) {
                    ElvanAsaiPattiyal {
                        items.forEachIndexed { idx, lineItem ->
                            PattuUrupadiAttai(
                                item = lineItem,
                                index = idx,
                                itemCount = items.size,
                                onItemUpdated = { updated ->
                                    items = items.toMutableList().also { it[idx] = updated }
                                    hasUnsavedChanges = true
                                    errorMessage = null
                                },
                                onItemDeleted = {
                                    items = items.toMutableList().also { it.removeAt(idx) }
                                    hasUnsavedChanges = true
                                },
                                onItemCleared = {
                                    items = items.toMutableList().also { it[idx] = PattuUrupadi() }
                                    hasUnsavedChanges = true
                                },
                                onDirty = { hasUnsavedChanges = true },
                                onRequestAddNewProduct = onRequestAddNewProduct
                            )
                        }
                    }

                    // "+ Add New Item" pill button
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(46.dp)
                            .clip(RoundedCornerShape(999.dp))
                            .background(if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.05f))
                            .clickable {
                                items = items + PattuUrupadi()
                                hasUnsavedChanges = true
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = MaterialSymbols.Rounded.Add,
                                contentDescription = null,
                                tint = colors.accent,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "+ $addNewProductLabel".preventBrokenLigatures(),
                                style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = colors.accent)
                            )
                        }
                    }
                }
            }

            // ── Section 4: ④ Totals (மொத்தங்கள்) ──
            item(key = "totals_section") {
                ElvanEditorSection(index = baseIndex + 3, title = K.mothangal.tr()) {
                    // Global Discount Row (% / ₹)
                    PattuThallupadiKooru(
                        discountValue = globalDiscountValue,
                        discountType = globalDiscountType,
                        onValueChanged = {
                            globalDiscountValue = it
                            hasUnsavedChanges = true
                        },
                        onTypeChanged = {
                            globalDiscountType = it
                            hasUnsavedChanges = true
                        }
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Calculated Totals Box
                    PattuMothangalKooru(totals = totals)
                }
            }

            // ── Section 5: ⑤ Invoice Type (பட்டியல் வகை) ──
            item(key = "invoice_type_section") {
                ElvanEditorSection(index = baseIndex + 4, title = K.pattiyalVagai.tr()) {
                    PattuPattiyalVagaiKooru(
                        pattiyalVagai = pattiyalVagai,
                        onChanged = {
                            pattiyalVagai = it
                            hasUnsavedChanges = true
                        }
                    )
                }
            }
        }
    }

    // ── Company Profile Selection Bottom Sheet ──
    if (isCompanySheetOpen) {
        ElvanSelectionBottomSheet(
            title = K.niruvanam.tr(),
            items = profiles,
            currentValue = selectedProfile,
            showSearch = false,
            onDismissRequest = { isCompanySheetOpen = false },
            onSelected = { p ->
                selectedNiruvanamId = p.id
                hasUnsavedChanges = true
                isCompanySheetOpen = false
            },
            itemLabelBuilder = { p ->
                p.kurumPeyar.ifEmpty { p.niruvanathinPeyar.values.firstOrNull().orEmpty() }
            }
        )
    }

    // ── Unsaved Changes Guard Action Sheet ──
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
