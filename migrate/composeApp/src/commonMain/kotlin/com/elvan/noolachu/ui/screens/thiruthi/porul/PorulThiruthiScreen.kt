package com.elvan.noolachu.ui.screens.thiruthi.porul

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
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.repository.PorulRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.components.shell.maeladukkugal.ElvanAzhippuUrudhiMaeladukku
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * PorulThiruthiScreen — Full subpage to create or edit a product/service item.
 * Supports Coolie & Silk modes.
 */
@Composable
fun PorulThiruthiScreen(
    item: PorulTharavuru? = null,
    onBack: () -> Unit
) {
    val currentMode = LocalAppMode.current
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current
    val isEditing = item != null && item.id > 0L

    var nameTa by remember { mutableStateOf(item?.porulPeyar?.get("ta") ?: "") }
    var nameEn by remember { mutableStateOf(item?.porulPeyar?.get("en") ?: "") }
    var hsnCode by remember { mutableStateOf(item?.hsnCode ?: "") }
    var vilai by remember {
        mutableStateOf(
            if (item != null && item.vilai > 0) {
                if (item.vilai % 1.0 == 0.0) item.vilai.toLong().toString() else item.vilai.toString()
            } else ""
        )
    }
    var variVeetham by remember {
        mutableStateOf(
            if (item != null) {
                if (item.variVeetham % 1.0 == 0.0) item.variVeetham.toLong().toString() else item.variVeetham.toString()
            } else "5"
        )
    }
    var alavuVagai by remember { mutableStateOf(item?.alavuVagai?.ifEmpty { "quantity" } ?: "quantity") }

    var showDeleteConfirm by remember { mutableStateOf(false) }
    var validationError by remember { mutableStateOf<String?>(null) }

    val pageTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaAakkam.tr()
    val nameRequiredMsg = K.porulPeyarThaevai.tr()
    val savedMsg = K.porulChaemikkappattadhu.tr()
    val saveFailedMsg = K.chaemikkaIyalavillai.tr()
    val deletedMsg = K.porulAzhikkappattadhu.tr()
    val confirmDeleteTitle = K.nirandharaAzhippuUrudhi.tr()

    fun handleSave() {
        if (nameTa.trim().isEmpty() && nameEn.trim().isEmpty()) {
            validationError = nameRequiredMsg
            ElvanSnackbar.show(nameRequiredMsg)
            return
        }

        val nameMap = mutableMapOf<String, String>()
        if (nameTa.isNotBlank()) nameMap["ta"] = nameTa.trim()
        if (nameEn.isNotBlank()) nameMap["en"] = nameEn.trim()

        val unit = if (alavuVagai == "weight") "kg" else "Nos"

        val itemToSave = PorulTharavuru(
            id = item?.id ?: 0L,
            porulPeyar = nameMap,
            hsnCode = if (currentMode == AppMode.PATTU) hsnCode.trim() else "",
            vilai = if (currentMode == AppMode.PATTU) (vilai.trim().toDoubleOrNull() ?: 0.0) else 0.0,
            variVeetham = if (currentMode == AppMode.PATTU) (variVeetham.trim().toDoubleOrNull() ?: 0.0) else 0.0,
            alavuVagai = if (currentMode == AppMode.PATTU) alavuVagai else "quantity",
            alagu = if (currentMode == AppMode.PATTU) unit else "Nos",
            createdAt = item?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )

        val savedId = PorulRepository.save(itemToSave, currentMode)
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

    ElvanSubShell(
        title = pageTitle,
        onBack = onBack,
        hasActions = true,
        actions = {
            ElvanCheyalPothan(
                label = K.chaemiPtn.tr(),
                onClick = { handleSave() }
            )
        }
    ) {
        val scrollState = rememberLazyListState()

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

            // Section 1: Bilingual Product Name
            item(key = "product_name_section") {
                ElvanSectionContainer {
                    ElvanSettingsSection(
                        title = K.porulTharavugal.tr(),
                        colors = colors
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            ElvanSettingsTextField(
                                label = "${K.porul.tr()} (${K.thamizh.tr()})",
                                value = nameTa,
                                onValueChange = {
                                    nameTa = it
                                    validationError = null
                                },
                                placeholder = K.porul.tr(),
                                colors = colors
                            )

                            ElvanSettingsTextField(
                                label = "${K.porul.tr()} (${K.aangilam.tr()})",
                                value = nameEn,
                                onValueChange = {
                                    nameEn = it
                                    validationError = null
                                },
                                placeholder = "Product / Service name",
                                colors = colors
                            )

                            if (validationError != null) {
                                Text(
                                    text = validationError!!,
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
                }
            }

            // Silk Mode: Measurement & Price / Tax sections
            if (currentMode == AppMode.PATTU) {
                // Section: Measurement method
                item(key = "measurement_section") {
                    ElvanSectionContainer {
                        ElvanSettingsSection(
                            title = K.alaveeduMurai.tr(),
                            colors = colors
                        ) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                Text(
                                    text = K.alavuVagai.tr(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Medium
                                    ),
                                    color = colors.textPrimary.copy(alpha = 0.5f),
                                    modifier = Modifier.padding(start = 4.dp)
                                )

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    // Quantity option (Nos)
                                    val isQty = alavuVagai != "weight"
                                    Surface(
                                        modifier = Modifier
                                            .weight(1f)
                                            .height(44.dp)
                                            .clip(RoundedCornerShape(100))
                                            .clickable { alavuVagai = "quantity" },
                                        shape = RoundedCornerShape(100),
                                        color = if (isQty) colors.accent else colors.iconBg
                                    ) {
                                        Box(
                                            modifier = Modifier.fillMaxSize(),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(
                                                text = "${K.alavu.tr()} (Nos)",
                                                style = TextStyle(
                                                    fontFamily = ff,
                                                    fontSize = 13.sp,
                                                    fontWeight = if (isQty) FontWeight.Bold else FontWeight.Normal,
                                                    color = if (isQty) Color.White else colors.textPrimary
                                                )
                                            )
                                        }
                                    }

                                    // Weight option (kg)
                                    val isWeight = alavuVagai == "weight"
                                    Surface(
                                        modifier = Modifier
                                            .weight(1f)
                                            .height(44.dp)
                                            .clip(RoundedCornerShape(100))
                                            .clickable { alavuVagai = "weight" },
                                        shape = RoundedCornerShape(100),
                                        color = if (isWeight) colors.accent else colors.iconBg
                                    ) {
                                        Box(
                                            modifier = Modifier.fillMaxSize(),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(
                                                text = "${K.edai.tr()} (kg)",
                                                style = TextStyle(
                                                    fontFamily = ff,
                                                    fontSize = 13.sp,
                                                    fontWeight = if (isWeight) FontWeight.Bold else FontWeight.Normal,
                                                    color = if (isWeight) Color.White else colors.textPrimary
                                                )
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Section: Price, Tax & HSN
                item(key = "price_tax_section") {
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
                                    label = K.hsnSacKuriyeedu.tr(),
                                    value = hsnCode,
                                    onValueChange = { hsnCode = it },
                                    placeholder = "50020010",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                    colors = colors
                                )

                                // Suggested HSN Chips
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    listOf("50020010", "50040010", "50072010").forEach { code ->
                                        val isSelected = hsnCode.trim() == code
                                        FilterChip(
                                            selected = isSelected,
                                            onClick = { hsnCode = code },
                                            label = { Text(code) },
                                            shape = RoundedCornerShape(100)
                                        )
                                    }
                                }

                                ElvanSettingsTextField(
                                    label = K.vilai.tr(),
                                    value = vilai,
                                    onValueChange = { vilai = it },
                                    placeholder = "0.00",
                                    prefixText = "₹ ",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                    colors = colors
                                )

                                ElvanSettingsTextField(
                                    label = K.gstVeedham.tr(),
                                    value = variVeetham,
                                    onValueChange = { variVeetham = it },
                                    placeholder = "5",
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                    trailingIcon = {
                                        Text(
                                            text = "%",
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 14.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = colors.textSecondary
                                            )
                                        )
                                    },
                                    colors = colors
                                )

                                // Quick GST rate pills
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    listOf("0", "5", "12", "18").forEach { rate ->
                                        val isSelected = variVeetham.trim() == rate
                                        FilterChip(
                                            selected = isSelected,
                                            onClick = { variVeetham = rate },
                                            label = { Text("$rate%") },
                                            shape = RoundedCornerShape(100)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Delete Card (if editing existing)
            if (isEditing && item != null) {
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

    if (showDeleteConfirm && item != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = confirmDeleteTitle,
            onConfirm = {
                showDeleteConfirm = false
                PorulRepository.delete(item.id, currentMode)
                ElvanSnackbar.show(deletedMsg)
                onBack()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
