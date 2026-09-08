package com.elvan.noolachu.ui.screens.thiruthi.porul

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.repository.PorulRepository
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
 * ItemEditorModal — Modal bottom sheet to create or edit a product/service item.
 * Supports Coolie & Silk modes.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ItemEditorModal(
    item: PorulTharavuru? = null,
    onDismiss: () -> Unit,
    mode: AppMode = LocalAppMode.current,
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark
    val sheetBg = if (isDark) Color(0xFF111111) else Color.White
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

    val modalTitle = if (isEditing) K.maatriyamai.tr() else K.pudhiyaAakkam.tr()
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
            hsnCode = if (mode == AppMode.PATTU) hsnCode.trim() else "",
            vilai = if (mode == AppMode.PATTU) (vilai.trim().toDoubleOrNull() ?: 0.0) else 0.0,
            variVeetham = if (mode == AppMode.PATTU) (variVeetham.trim().toDoubleOrNull() ?: 0.0) else 0.0,
            alavuVagai = if (mode == AppMode.PATTU) alavuVagai else "quantity",
            alagu = if (mode == AppMode.PATTU) unit else "Nos",
            createdAt = item?.createdAt ?: System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )

        val savedId = PorulRepository.save(itemToSave, mode)
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
                // Section 1: Product Name (Tamil & English)
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

                // Silk Mode fields
                if (mode == AppMode.PATTU) {
                    // Section 2: Measurement & Units
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

                    // Section 3: Price, Tax & HSN
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
                                placeholder = "5007",
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                                colors = colors
                            )

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

    if (showDeleteConfirm && item != null) {
        ElvanAzhippuUrudhiMaeladukku(
            title = confirmDeleteTitle,
            onConfirm = {
                showDeleteConfirm = false
                PorulRepository.delete(item.id, mode)
                ElvanSnackbar.show(deletedMsg)
                onDismiss()
            },
            onDismissRequest = { showDeleteConfirm = false },
            colors = colors
        )
    }
}
