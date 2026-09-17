package com.elvan.udukkai.ui.screens.uruvakku

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.mode.AppMode
import com.elvan.udukkai.core.mode.LocalAppMode
import com.elvan.udukkai.data.model.PattiyalTharavuru
import com.elvan.udukkai.data.model.PatrugalTharavuru
import com.elvan.udukkai.data.repository.PattiyalRepository
import com.elvan.udukkai.data.repository.PatrugalRepository
import com.elvan.udukkai.data.settings.NiruvanaTharavugalRepository
import com.elvan.udukkai.localization.K
import com.elvan.udukkai.localization.LocalAppLanguage
import com.elvan.udukkai.localization.tr
import com.elvan.udukkai.theme.Dimens
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors
import com.elvan.udukkai.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.udukkai.ui.navigation.MaterialSymbols
import com.elvan.udukkai.ui.screens.uruvakku.koorugal.*
import com.elvan.udukkai.theme.LocalShellColors

/**
 * Pixel-perfect port of Flutter's UruvakkuPage (Create tab).
 * Hosts:
 * 1. ElvanPillShifter ("பட்டியல்கள்" Invoices vs "பற்றுச்சீட்டுகள்" Receipts)
 * 2. Invoices list (Kooli / Pattu) or Receipts list with profile grouping and real-time search filtering.
 */
@Composable
fun UruvakkuScreen(
    scrollState: LazyListState,
    selectedSegment: Int,
    onSegmentSelected: (Int) -> Unit,
    modifier: Modifier = Modifier,
    isSelectionMode: Boolean = false,
    selectedItemIds: Set<Long> = emptySet(),
    onToggleSelect: ((Long) -> Unit)? = null,
    onItemLongClick: ((Long) -> Unit)? = null,
    onInvoiceClick: (PattiyalTharavuru) -> Unit = {},
    onReceiptClick: (PatrugalTharavuru) -> Unit = {}
) {
    val mode = LocalAppMode.current
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    val profiles = NiruvanaTharavugalRepository.getAllProfiles(mode)
    val hasMultipleProfiles = profiles.size > 1

    var selectedProfileFilterIndex by remember { mutableIntStateOf(0) }

    LaunchedEffect(mode) {
        selectedProfileFilterIndex = 0
    }

    val allLabel = K.all.tr().uppercase()
    val businessFilterItems = remember(profiles, allLabel) {
        if (profiles.isEmpty()) {
            emptyList()
        } else {
            val list = mutableListOf<VanigaPillItem>()
            list.add(
                VanigaPillItem(
                    label = allLabel,
                    icon = MaterialSymbols.Rounded.Apartment
                )
            )
            profiles.forEach { p ->
                val shortName = p.kurumPeyar.ifEmpty {
                    p.niruvanathinPeyar.values.firstOrNull().orEmpty()
                }.uppercase()
                list.add(
                    VanigaPillItem(
                        label = shortName,
                        icon = MaterialSymbols.Rounded.Apartment
                    )
                )
            }
            list
        }
    }

    val safeProfileIndex = selectedProfileFilterIndex.coerceIn(0, (businessFilterItems.size - 1).coerceAtLeast(0))

    val allInvoices = PattiyalRepository.filteredInvoices
    val invoices = remember(allInvoices, safeProfileIndex, profiles) {
        if (safeProfileIndex == 0 || profiles.isEmpty()) {
            allInvoices
        } else {
            val targetProfile = profiles.getOrNull(safeProfileIndex - 1)
            if (targetProfile != null) {
                allInvoices.filter { it.niruvanamId == targetProfile.id }
            } else {
                allInvoices
            }
        }
    }

    val allReceipts = PatrugalRepository.filteredReceipts
    val receipts = remember(allReceipts, safeProfileIndex, profiles) {
        if (safeProfileIndex == 0 || profiles.isEmpty()) {
            allReceipts
        } else {
            val targetProfile = profiles.getOrNull(safeProfileIndex - 1)
            if (targetProfile != null) {
                allReceipts.filter { it.niruvanamId == targetProfile.id }
            } else {
                allReceipts
            }
        }
    }

    fun getProfileName(profileId: Long?): String {
        if (profileId == null) return "பொது"
        val prof = profiles.find { it.id == profileId }
        return prof?.kurumPeyar?.ifEmpty {
            prof.niruvanathinPeyar.values.firstOrNull().orEmpty()
        } ?: "பொது"
    }

    val shifterItems = listOf(
        PillShifterItem(
            label = K.invoices.tr(),
            icon = MaterialSymbols.Rounded.Description,
            activeIcon = MaterialSymbols.Rounded.DescriptionFill
        ),
        PillShifterItem(
            label = K.receipts.tr(),
            icon = MaterialSymbols.Rounded.ReceiptLong,
            activeIcon = MaterialSymbols.Rounded.ReceiptLongFill
        )
    )

    LazyColumn(
        state = scrollState,
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            bottom = Dimens.ContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        // Collapsible Top Header spacer
        item(key = "uruvakku_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        // Segmented Pill Shifter (Invoices vs Receipts - Original Centered Style)
        item(key = "pill_shifter") {
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                ElvanPillShifter(
                    items = shifterItems,
                    selectedIndex = selectedSegment,
                    onIndexSelected = onSegmentSelected,
                    colors = colors
                )
            }
        }

        // Business Profile Filter Pill Shifter (below Invoices vs Receipts pill)
        if (selectedSegment == 0 && businessFilterItems.size > 1) {
            item(key = "business_pill_shifter") {
                ElvanVanigaPillShifter(
                    items = businessFilterItems,
                    selectedIndex = safeProfileIndex,
                    onIndexSelected = { selectedProfileFilterIndex = it },
                    colors = colors,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                )
            }
        }

        if (selectedSegment == 0) {
            if (invoices.isEmpty()) {
                item(key = "empty_invoices") {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 56.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = MaterialSymbols.Rounded.Description,
                                contentDescription = null,
                                tint = LocalShellColors.current.textQuaternary,
                                modifier = Modifier.size(48.dp)
                            )
                            Spacer(modifier = Modifier.height(14.dp))
                            Text(
                                text = K.noInvoicesYet.tr().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 15.sp,
                                    color = LocalShellColors.current.textTertiary
                                )
                            )
                        }
                    }
                }
            } else {
                itemsIndexed(
                    items = invoices,
                    key = { _, item -> "inv_${item.id}" }
                ) { index, invoice ->
                    // Profile section header if previous invoice was from a different profile
                    val showProfileHeader = hasMultipleProfiles && safeProfileIndex == 0 && (index == 0 || invoices[index - 1].niruvanamId != invoice.niruvanamId)

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                    ) {
                        if (showProfileHeader) {
                            Text(
                                text = getProfileName(invoice.niruvanamId).uppercase().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 0.5.sp,
                                    color = LocalShellColors.current.iconInactive
                                ),
                                modifier = Modifier.padding(start = 4.dp, top = 8.dp, bottom = 6.dp)
                            )
                        }

                        val isSelected = selectedItemIds.contains(invoice.id)
                        val onCardClick: () -> Unit = {
                            if (isSelectionMode) {
                                onToggleSelect?.invoke(invoice.id)
                            } else {
                                onInvoiceClick(invoice)
                            }
                        }
                        val onCardLongClick: () -> Unit = {
                            onItemLongClick?.invoke(invoice.id)
                        }

                        if (mode == AppMode.KOOLI) {
                            KooliPattiyalAttai(
                                index = index,
                                pattiyal = invoice,
                                colors = colors,
                                isSelectionMode = isSelectionMode,
                                isSelected = isSelected,
                                onClick = onCardClick,
                                onLongClick = onCardLongClick
                            )
                        } else {
                            PattuPattiyalAttai(
                                index = index,
                                pattiyal = invoice,
                                colors = colors,
                                isSelectionMode = isSelectionMode,
                                isSelected = isSelected,
                                onClick = onCardClick,
                                onLongClick = onCardLongClick
                            )
                        }
                    }
                }
            }
        } else {
            if (receipts.isEmpty()) {
                item(key = "empty_receipts") {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 56.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = MaterialSymbols.Rounded.ReceiptLong,
                                contentDescription = null,
                                tint = LocalShellColors.current.textQuaternary,
                                modifier = Modifier.size(48.dp)
                            )
                            Spacer(modifier = Modifier.height(14.dp))
                            Text(
                                text = K.noReceiptsYet.tr().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 15.sp,
                                    color = LocalShellColors.current.textTertiary
                                )
                            )
                        }
                    }
                }
            } else {
                itemsIndexed(
                    items = receipts,
                    key = { _, item -> "receipt_${item.id}" }
                ) { index, receipt ->
                    val showProfileHeader = hasMultipleProfiles && safeProfileIndex == 0 && (index == 0 || receipts[index - 1].niruvanamId != receipt.niruvanamId)

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                    ) {
                        if (showProfileHeader) {
                            Text(
                                text = getProfileName(receipt.niruvanamId).uppercase().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.5.sp,
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 0.5.sp,
                                    color = LocalShellColors.current.iconInactive
                                ),
                                modifier = Modifier.padding(start = 4.dp, top = 8.dp, bottom = 6.dp)
                            )
                        }

                        val isSelected = selectedItemIds.contains(receipt.id)
                        val onCardClick: () -> Unit = {
                            if (isSelectionMode) {
                                onToggleSelect?.invoke(receipt.id)
                            } else {
                                onReceiptClick(receipt)
                            }
                        }
                        val onCardLongClick: () -> Unit = {
                            onItemLongClick?.invoke(receipt.id)
                        }

                        PatruAttai(
                            receipt = receipt,
                            colors = colors,
                            isSelectionMode = isSelectionMode,
                            isSelected = isSelected,
                            onClick = onCardClick,
                            onLongClick = onCardLongClick
                        )
                    }
                }
            }
        }
    }
}
