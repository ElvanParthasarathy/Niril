package com.elvan.noolachu.ui.screens.thiruthi.pattiyal

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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.core.utils.CurrencyUtils
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.repository.PattiyalRepository
import com.elvan.noolachu.data.repository.PorulRepository
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
import kotlin.math.floor

private data class InvoiceLineItem(
    val id: String = System.currentTimeMillis().toString() + (0..999).random(),
    var name: String = "",
    var hsn: String = "",
    var quantityOrWeight: String = "1",
    var rate: String = "0",
    var gstRate: String = "5"
)

/**
 * Invoice Editor Screen (பட்டியல் திருத்தி)
 * Handles both Kooli (weight billing) and Silk/Pattu (GST item billing) modes with One UI styling.
 */
@Composable
fun PattiyalThiruthiScreen(
    invoice: PattiyalTharavuru? = null,
    onBack: () -> Unit
) {
    val currentMode = LocalAppMode.current
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current
    val isEditing = invoice != null && invoice.id > 0L

    val profiles: List<NiruvanaTharavugal> = NiruvanaTharavugalRepository.getAllProfiles(currentMode)
    var selectedNiruvanamId by remember {
        mutableStateOf(invoice?.niruvanamId ?: profiles.firstOrNull()?.id)
    }

    val merchants = VaangunarRepository.merchants
    var selectedVaangunarId by remember { mutableStateOf(invoice?.vaangunarId) }
    var selectedVaangunarPeyarMap by remember {
        mutableStateOf(invoice?.vaangunarPeyar ?: emptyMap())
    }
    var selectedVaangunarMunvariMap by remember {
        mutableStateOf(invoice?.vaangunarMunvari ?: emptyMap())
    }

    var invoiceNumber by remember {
        mutableStateOf(
            invoice?.patrucheettuEn ?: "INV-${(System.currentTimeMillis() % 10000)}"
        )
    }
    var invoiceDate by remember { mutableStateOf(invoice?.pattiyalNaal ?: System.currentTimeMillis()) }

    // Line items list
    var lineItems by remember {
        mutableStateOf(
            mutableListOf(
                InvoiceLineItem(
                    name = if (currentMode == AppMode.KOOLI) "கூலி நெசவு" else "பட்டு புடவை",
                    quantityOrWeight = "1",
                    rate = if (invoice != null && invoice.mothaThogai > 0) invoice.mothaThogai.toString() else "0"
                )
            )
        )
    }

    // Coolie additional charges
    var setharamGrams by remember { mutableStateOf(if (invoice != null && invoice.setharamGrams > 0) invoice.setharamGrams.toString() else "") }
    var courierCharges by remember { mutableStateOf(if (invoice != null && invoice.thabaalThogai > 0) invoice.thabaalThogai.toString() else "") }
    var ahimsaCharges by remember { mutableStateOf(if (invoice != null && invoice.ahimsaPattuThogai > 0) invoice.ahimsaPattuThogai.toString() else "") }

    // Notes
    var notes by remember { mutableStateOf(invoice?.ullkurippu ?: "") }

    var showDeleteConfirm by remember { mutableStateOf(false) }
    var showMerchantPicker by remember { mutableStateOf(false) }
    var showProfilePicker by remember { mutableStateOf(false) }
    var showProductPicker by remember { mutableStateOf(false) }
    var validationError by remember { mutableStateOf<String?>(null) }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaPattiyalPtn.tr()
    val thogaiRequiredMsg = K.thogaiChuzhiyaththaiVidaMigudhiyaagaIrukkaVaendum.tr()
    val saveSuccessMsg = K.chaemippuvetri.tr()
    val saveFailedMsg = K.chaemikkaIyalavillai.tr()
    val deleteSuccessMsg = K.azhippuvetri.tr()
    val confirmDeleteTitle = K.nirandharaAzhippuUrudhi.tr()

    // Real-time calculated totals
    val subtotal = remember(lineItems) {
        lineItems.sumOf { item ->
            val qty = item.quantityOrWeight.toDoubleOrNull() ?: 0.0
            val r = item.rate.toDoubleOrNull() ?: 0.0
            if (currentMode == AppMode.KOOLI) {
                floor(qty * r)
            } else {
                qty * r
            }
        }
    }

    val taxOrAdditional = remember(lineItems, setharamGrams, courierCharges, ahimsaCharges, currentMode) {
        if (currentMode == AppMode.KOOLI) {
            val courier = courierCharges.toDoubleOrNull() ?: 0.0
            val ahimsa = ahimsaCharges.toDoubleOrNull() ?: 0.0
            courier + ahimsa
        } else {
            lineItems.sumOf { item ->
                val qty = item.quantityOrWeight.toDoubleOrNull() ?: 0.0
                val r = item.rate.toDoubleOrNull() ?: 0.0
                val gst = item.gstRate.toDoubleOrNull() ?: 0.0
                (qty * r) * (gst / 100.0)
            }
        }
    }

    val grandTotal = subtotal + taxOrAdditional

    fun handleSave() {
        if (grandTotal <= 0.0) {
            validationError = thogaiRequiredMsg
            ElvanSnackbar.show(thogaiRequiredMsg)
            return
        }

        val invoiceToSave = PattiyalTharavuru(
            id = invoice?.id ?: 0L,
            niruvanamId = selectedNiruvanamId,
            vaangunarId = selectedVaangunarId,
            vaangunarPeyar = selectedVaangunarPeyarMap,
            vaangunarMunvari = selectedVaangunarMunvariMap,
            patrucheettuEn = invoiceNumber.trim(),
            pattiyalNaal = invoiceDate,
            mothaThogai = grandTotal,
            variThogai = taxOrAdditional,
            setharamGrams = setharamGrams.toDoubleOrNull() ?: 0.0,
            thabaalThogai = courierCharges.toDoubleOrNull() ?: 0.0,
            ahimsaPattuThogai = ahimsaCharges.toDoubleOrNull() ?: 0.0,
            ullkurippu = notes.trim(),
            createdAt = invoice?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )

        val resultId = PattiyalRepository.save(invoiceToSave, currentMode)
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

            // Section 1: Business Profile
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

            // Section 3: Invoice Number & Date
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
                                value = invoiceNumber,
                                onValueChange = { invoiceNumber = it },
                                placeholder = "INV-001",
                                colors = colors
                            )

                            ElvanSettingsRow(
                                title = DateUtils.formatEpochMillis(invoiceDate),
                                description = K.pirandhaThaedhi.tr(),
                                icon = MaterialSymbols.Rounded.CalendarToday,
                                onClick = { invoiceDate = System.currentTimeMillis() },
                                colors = colors
                            )
                        }
                    }
                }
            }

            // Section 4: Line Items (உருப்படிகள்)
            item(key = "line_items_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.porutkal.tr(),
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(14.dp)
                        ) {
                            lineItems.forEachIndexed { index, item ->
                                Card(
                                    shape = RoundedCornerShape(16.dp),
                                    colors = CardDefaults.cardColors(containerColor = colors.iconBg),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Column(
                                        modifier = Modifier.padding(12.dp),
                                        verticalArrangement = Arrangement.spacedBy(10.dp)
                                    ) {
                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Text(
                                                text = "${K.porul.tr()} #${index + 1}",
                                                style = TextStyle(
                                                    fontFamily = ff,
                                                    fontWeight = FontWeight.Bold,
                                                    fontSize = 13.sp,
                                                    color = colors.accent
                                                )
                                            )
                                            if (lineItems.size > 1) {
                                                IconButton(
                                                    onClick = {
                                                        val updated = lineItems.toMutableList()
                                                        updated.removeAt(index)
                                                        lineItems = updated
                                                    },
                                                    modifier = Modifier.size(24.dp)
                                                ) {
                                                    Icon(
                                                        imageVector = MaterialSymbols.Rounded.Close,
                                                        contentDescription = K.neekkuPtn.tr(),
                                                        tint = MaterialTheme.colorScheme.error,
                                                        modifier = Modifier.size(18.dp)
                                                    )
                                                }
                                            }
                                        }

                                        ElvanSettingsTextField(
                                            label = K.peyaraiUlliduga.tr(),
                                            value = item.name,
                                            onValueChange = { newName ->
                                                val updated = lineItems.toMutableList()
                                                updated[index] = item.copy(name = newName)
                                                lineItems = updated
                                            },
                                            placeholder = if (currentMode == AppMode.KOOLI) "நெசவு வகை" else "பொருள் பெயர்",
                                            colors = colors
                                        )

                                        Row(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                                        ) {
                                            ElvanSettingsTextField(
                                                label = if (currentMode == AppMode.KOOLI) "${K.edai.tr()} (kg)" else K.alavu.tr(),
                                                value = item.quantityOrWeight,
                                                onValueChange = { newQty ->
                                                    val updated = lineItems.toMutableList()
                                                    updated[index] = item.copy(quantityOrWeight = newQty)
                                                    lineItems = updated
                                                },
                                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                                modifier = Modifier.weight(1f),
                                                colors = colors
                                            )

                                            ElvanSettingsTextField(
                                                label = "${K.vilai.tr()} (₹)",
                                                value = item.rate,
                                                onValueChange = { newRate ->
                                                    val updated = lineItems.toMutableList()
                                                    updated[index] = item.copy(rate = newRate)
                                                    lineItems = updated
                                                },
                                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                                modifier = Modifier.weight(1f),
                                                colors = colors
                                            )
                                        }

                                        if (currentMode == AppMode.PATTU) {
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                                            ) {
                                                ElvanSettingsTextField(
                                                    label = K.hsnSacKuriyeedu.tr(),
                                                    value = item.hsn,
                                                    onValueChange = { newHsn ->
                                                        val updated = lineItems.toMutableList()
                                                        updated[index] = item.copy(hsn = newHsn)
                                                        lineItems = updated
                                                    },
                                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                                    modifier = Modifier.weight(1f),
                                                    colors = colors
                                                )

                                                ElvanSettingsTextField(
                                                    label = "GST %",
                                                    value = item.gstRate,
                                                    onValueChange = { newGst ->
                                                        val updated = lineItems.toMutableList()
                                                        updated[index] = item.copy(gstRate = newGst)
                                                        lineItems = updated
                                                    },
                                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                                    modifier = Modifier.weight(1f),
                                                    colors = colors
                                                )
                                            }
                                        }
                                    }
                                }
                            }

                            // Actions row: Add new item or pick existing
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                OutlinedButton(
                                    onClick = {
                                        val updated = lineItems.toMutableList()
                                        updated.add(InvoiceLineItem(name = "", quantityOrWeight = "1", rate = "0"))
                                        lineItems = updated
                                    },
                                    modifier = Modifier.weight(1f),
                                    shape = RoundedCornerShape(100)
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Add,
                                        contentDescription = null,
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(K.chaerPtn.tr(), style = TextStyle(fontFamily = ff, fontSize = 13.sp))
                                }

                                OutlinedButton(
                                    onClick = { showProductPicker = true },
                                    modifier = Modifier.weight(1f),
                                    shape = RoundedCornerShape(100)
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.CustomNav.Products,
                                        contentDescription = null,
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(K.porulaichChaerPtn.tr(), style = TextStyle(fontFamily = ff, fontSize = 13.sp))
                                }
                            }
                        }
                    }
                }
            }

            // Section 5: Additional Charges (Kooli mode only)
            if (currentMode == AppMode.KOOLI) {
                item(key = "coolie_charges_section") {
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
                                    label = "${K.chaedhaaram.tr()} (${K.chaedhaaramGiraam.tr()})",
                                    value = setharamGrams,
                                    onValueChange = { setharamGrams = it },
                                    placeholder = "0",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                    colors = colors
                                )

                                ElvanSettingsTextField(
                                    label = K.koriyarKattanam.tr(),
                                    value = courierCharges,
                                    onValueChange = { courierCharges = it },
                                    placeholder = "0.00",
                                    prefixText = "₹ ",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                    colors = colors
                                )

                                ElvanSettingsTextField(
                                    label = "அகிம்சா பட்டுத் தொகை",
                                    value = ahimsaCharges,
                                    onValueChange = { ahimsaCharges = it },
                                    placeholder = "0.00",
                                    prefixText = "₹ ",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                    colors = colors
                                )
                            }
                        }
                    }
                }
            }

            // Section 6: Grand Total Summary Card
            item(key = "summary_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.mothangal.tr(),
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(
                                    text = K.ulmotham.tr().preventBrokenLigatures(),
                                    style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textSecondary)
                                )
                                Text(
                                    text = CurrencyUtils.formatInr(subtotal),
                                    style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = colors.textPrimary)
                                )
                            }

                            if (taxOrAdditional > 0) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = if (currentMode == AppMode.KOOLI) "கூடுதல் கட்டணங்கள்" else "GST வரி",
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textSecondary)
                                    )
                                    Text(
                                        text = CurrencyUtils.formatInr(taxOrAdditional),
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = colors.textPrimary)
                                    )
                                }
                            }

                            HorizontalDivider(color = colors.divider, modifier = Modifier.padding(vertical = 4.dp))

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = K.perumMotham.tr().preventBrokenLigatures(),
                                    style = TextStyle(fontFamily = ff, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = colors.textPrimary)
                                )
                                Text(
                                    text = CurrencyUtils.formatInr(grandTotal),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 20.sp,
                                        fontWeight = FontWeight.ExtraBold,
                                        color = colors.accent
                                    )
                                )
                            }
                        }
                    }
                }
            }

            // Section 7: Notes
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
                                value = notes,
                                onValueChange = { notes = it },
                                placeholder = "...",
                                singleLine = false,
                                colors = colors
                            )
                        }
                    }
                }
            }

            // Delete Section (if editing existing invoice)
            if (isEditing && invoice != null) {
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

    // Product Picker Modal (to add existing products to line items)
    if (showProductPicker) {
        val products = PorulRepository.items
        AlertDialog(
            onDismissRequest = { showProductPicker = false },
            title = {
                Text(
                    text = K.porutkal.tr().preventBrokenLigatures(),
                    style = TextStyle(fontFamily = ff, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                )
            },
            text = {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(max = 350.dp)
                ) {
                    if (products.isEmpty()) {
                        item {
                            Text(
                                text = "பொருட்கள் எதுவும் இல்லை",
                                style = TextStyle(fontFamily = ff, color = colors.textSecondary)
                            )
                        }
                    } else {
                        items(products.size) { idx ->
                            val p = products[idx]
                            val pName = p.porulPeyar.values.firstOrNull() ?: ""

                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(12.dp))
                                    .clickable {
                                        val updated = lineItems.toMutableList()
                                        updated.add(
                                            InvoiceLineItem(
                                                name = pName,
                                                hsn = p.hsnCode,
                                                quantityOrWeight = "1",
                                                rate = if (p.vilai > 0) p.vilai.toString() else "0",
                                                gstRate = if (p.variVeetham > 0) p.variVeetham.toString() else "5"
                                            )
                                        )
                                        lineItems = updated
                                        showProductPicker = false
                                    }
                                    .padding(vertical = 10.dp, horizontal = 8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = pName.preventBrokenLigatures(),
                                        style = TextStyle(fontFamily = ff, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                                    )
                                    if (p.vilai > 0) {
                                        Text(
                                            text = "₹${p.vilai}",
                                            style = TextStyle(fontFamily = ff, color = colors.accent, fontSize = 12.sp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            },
            confirmButton = {
                TextButton(onClick = { showProductPicker = false }) {
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
    if (showDeleteConfirm && invoice != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = confirmDeleteTitle,
            onConfirm = {
                showDeleteConfirm = false
                PattiyalRepository.delete(invoice.id, currentMode)
                ElvanSnackbar.show(deleteSuccessMsg)
                onBack()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
