package com.elvan.udukkai.ui.screens.uruvakku

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import com.elvan.udukkai.core.utils.DateGroupUtils
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

    var selectedProfileFilterIndex by remember { mutableIntStateOf(0) }

    LaunchedEffect(mode) {
        selectedProfileFilterIndex = 0
    }

    val allLabel = K.all.tr()
    val businessShifterItems = remember(profiles, allLabel) {
        if (profiles.isEmpty()) {
            emptyList()
        } else {
            val list = mutableListOf<PillShifterItem>()
            list.add(
                PillShifterItem(
                    label = allLabel
                )
            )
            profiles.forEach { p ->
                val shortName = p.kurumPeyar.ifEmpty {
                    p.niruvanathinPeyar.values.firstOrNull().orEmpty()
                }
                list.add(
                    PillShifterItem(
                        label = shortName
                    )
                )
            }
            list
        }
    }

    val safeProfileIndex = selectedProfileFilterIndex.coerceIn(0, (businessShifterItems.size - 1).coerceAtLeast(0))

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

    val activeProfile = NiruvanaTharavugalRepository.getProfile(mode)
    val isBilingual = mode == AppMode.KOOLI || activeProfile.iruMozhi
    val primaryLang = activeProfile.mudhanMozhi.ifEmpty { "ta" }

    val invoiceGroups = remember(invoices) {
        DateGroupUtils.groupItemsByDate(invoices) { it.pattiyalNaal }
    }

    val receiptGroups = remember(receipts) {
        DateGroupUtils.groupItemsByDate(receipts) { it.patruNaal }
    }

    val dateIndexMap = remember(selectedSegment, invoiceGroups, receiptGroups, businessShifterItems.size) {
        val map = mutableListOf<Long>()
        val headerCount = if (businessShifterItems.size > 1) 3 else 2
        val activeGroups = if (selectedSegment == 0) invoiceGroups else receiptGroups
        val firstDate = activeGroups.firstOrNull()?.dateMillis ?: System.currentTimeMillis()

        repeat(headerCount) {
            map.add(firstDate)
        }

        activeGroups.forEach { group ->
            // Date section header item
            map.add(group.dateMillis)
            // Cards in this group
            repeat(group.items.size) {
                map.add(group.dateMillis)
            }
        }
        map
    }

    val uiLang = LocalAppLanguage.current
    val dateProvider: (Int) -> String = remember(dateIndexMap, uiLang) {
        { idx ->
            val dateMillis = dateIndexMap.getOrNull(idx) ?: dateIndexMap.firstOrNull() ?: 0L
            if (dateMillis > 0L) {
                DateGroupUtils.formatPillDate(dateMillis, isBilingual = false, primaryLang = uiLang)
            } else {
                ""
            }
        }
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

    Box(modifier = modifier.fillMaxSize()) {
        LazyColumn(
            state = scrollState,
            modifier = Modifier.fillMaxSize(),
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
                        colors = colors,
                        isFullWidth = false
                    )
                }
            }

            // Business Profile Filter Shifter (below Invoices vs Receipts pill - End to End)
            if (businessShifterItems.size > 1) {
                item(key = "business_shifter") {
                    ElvanPillShifter(
                        items = businessShifterItems,
                        selectedIndex = safeProfileIndex,
                        onIndexSelected = { selectedProfileFilterIndex = it },
                        colors = colors,
                        isFullWidth = true,
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
                    invoiceGroups.forEach { group ->
                        item(key = "date_hdr_inv_${group.dayKey}") {
                            DateSectionHeader(
                                dateMillis = group.dateMillis,
                                colors = colors
                            )
                        }

                        items(
                            items = group.items,
                            key = { "inv_${it.data.id}" }
                        ) { indexedInvoice ->
                            val index = indexedInvoice.globalIndex
                            val invoice = indexedInvoice.data
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

                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp)
                            ) {
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
                    receiptGroups.forEach { group ->
                        item(key = "date_hdr_rec_${group.dayKey}") {
                            DateSectionHeader(
                                dateMillis = group.dateMillis,
                                colors = colors
                            )
                        }

                        items(
                            items = group.items,
                            key = { "receipt_${it.data.id}" }
                        ) { indexedReceipt ->
                            val index = indexedReceipt.globalIndex
                            val receipt = indexedReceipt.data
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

                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp)
                            ) {
                                PatruAttai(
                                    index = index,
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

        // Google Photos style Side Fast Scroller with floating date pill
        ElvanDateFastScroller(
            scrollState = scrollState,
            dateProvider = dateProvider,
            colors = colors,
            topPadding = 104.dp,
            bottomPadding = 104.dp
        )
    }
}
