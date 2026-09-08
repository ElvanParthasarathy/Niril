package com.elvan.noolachu.ui.screens.uruvakku

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.model.PatrugalTharavuru
import com.elvan.noolachu.data.repository.PattiyalRepository
import com.elvan.noolachu.data.repository.PatrugalRepository
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.screens.uruvakku.koorugal.*

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
    onInvoiceClick: (PattiyalTharavuru) -> Unit = {},
    onReceiptClick: (PatrugalTharavuru) -> Unit = {}
) {
    val mode = LocalAppMode.current
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    val profiles = NiruvanaTharavugalRepository.getAllProfiles(mode)
    val hasMultipleProfiles = profiles.size > 1

    fun getProfileName(profileId: Long?): String {
        if (profileId == null) return "பொது"
        val prof = profiles.find { it.id == profileId }
        return prof?.kurumPeyar?.ifEmpty {
            prof.niruvanathinPeyar.values.firstOrNull().orEmpty()
        } ?: "பொது"
    }

    val shifterItems = listOf(
        PillShifterItem(
            label = K.pattiyalgal.tr(),
            icon = MaterialSymbols.Rounded.Description
        ),
        PillShifterItem(
            label = K.patrucheettugal.tr(),
            icon = MaterialSymbols.Rounded.ReceiptLong
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

        // Segmented Pill Shifter
        item(key = "pill_shifter") {
            ElvanPillShifter(
                items = shifterItems,
                selectedIndex = selectedSegment,
                onIndexSelected = onSegmentSelected,
                colors = colors
            )
        }

        if (selectedSegment == 0) {
            // Invoices Segment
            val invoices = PattiyalRepository.filteredInvoices

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
                                tint = if (isDark) Color.White.copy(alpha = 0.24f) else Color.Black.copy(alpha = 0.26f),
                                modifier = Modifier.size(48.dp)
                            )
                            Spacer(modifier = Modifier.height(14.dp))
                            Text(
                                text = K.pattiyalgalIllai.tr().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 15.sp,
                                    color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
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
                    val showProfileHeader = hasMultipleProfiles && (index == 0 || invoices[index - 1].niruvanamId != invoice.niruvanamId)

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
                                    color = if (isDark) Color.White.copy(alpha = 0.45f) else Color.Black.copy(alpha = 0.45f)
                                ),
                                modifier = Modifier.padding(start = 4.dp, top = 8.dp, bottom = 6.dp)
                            )
                        }

                        if (mode == AppMode.KOOLI) {
                            KooliPattiyalAttai(
                                index = index,
                                pattiyal = invoice,
                                colors = colors,
                                onClick = { onInvoiceClick(invoice) }
                            )
                        } else {
                            PattuPattiyalAttai(
                                index = index,
                                pattiyal = invoice,
                                colors = colors,
                                onClick = { onInvoiceClick(invoice) }
                            )
                        }
                    }
                }
            }
        } else {
            // Payment Receipts Segment
            val receipts = PatrugalRepository.filteredReceipts

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
                                tint = if (isDark) Color.White.copy(alpha = 0.24f) else Color.Black.copy(alpha = 0.26f),
                                modifier = Modifier.size(48.dp)
                            )
                            Spacer(modifier = Modifier.height(14.dp))
                            Text(
                                text = K.patrucheettugalIllai.tr().preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 15.sp,
                                    color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
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
                    val showProfileHeader = hasMultipleProfiles && (index == 0 || receipts[index - 1].niruvanamId != receipt.niruvanamId)

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
                                    color = if (isDark) Color.White.copy(alpha = 0.45f) else Color.Black.copy(alpha = 0.45f)
                                ),
                                modifier = Modifier.padding(start = 4.dp, top = 8.dp, bottom = 6.dp)
                            )
                        }

                        PatruAttai(
                            receipt = receipt,
                            colors = colors,
                            onClick = { onReceiptClick(receipt) }
                        )
                    }
                }
            }
        }
    }
}
