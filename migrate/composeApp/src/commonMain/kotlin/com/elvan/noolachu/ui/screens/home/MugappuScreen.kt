package com.elvan.noolachu.ui.screens.home

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.utils.CurrencyUtils
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.repository.PattiyalRepository
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.screens.home.koorugal.*

/**
 * Pixel-perfect port of Flutter's MugappuPage (Home tab).
 * Hosts:
 * 1. VanakkamPill (Greeting pill with mode toggle badge)
 * 2. Bento Stats Grid:
 *    - Motha Kanakku (Total ₹ billing amount)
 *    - Niruvanangal (Active businesses)
 *    - Motha Pattiyalgal (Invoice count with per-business breakdown)
 * 3. RecentActivityHeader ("அண்மைய செயற்பாடுகள்" with "அனைத்தும்" link)
 * 4. Recent invoice cards (Kooli / Pattu) or MugappuEmptyState
 */
@Composable
fun MugappuScreen(
    scrollState: LazyListState,
    onSeeAll: () -> Unit,
    modifier: Modifier = Modifier,
    onInvoiceClick: (PattiyalTharavuru) -> Unit = {}
) {
    val mode = LocalAppMode.current
    val colors = rememberShellColors()

    val profiles = NiruvanaTharavugalRepository.getAllProfiles(mode)
    val recentBills = PattiyalRepository.recentInvoices
    val overallTotal = PattiyalRepository.overallTotal
    val companiesSummary = PattiyalRepository.getCompaniesSummary(profiles)
    val invoiceCountSummary = PattiyalRepository.getInvoiceCountSummary(profiles)

    LazyColumn(
        state = scrollState,
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            bottom = Dimens.ContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Collapsible Top Header spacer
        item(key = "home_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        // 1. Greeting Vanakkam Pill
        item(key = "vanakkam_pill") {
            VanakkamPill(colors = colors)
        }

        // 2. Bento Stats Grid
        item(key = "stats_bento_grid") {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                // Top row: 2 cards
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    ElvanStatsCard(
                        icon = MaterialSymbols.Rounded.CurrencyRupee,
                        label = K.mothaKanakku.tr(),
                        value = CurrencyUtils.formatInr(overallTotal),
                        colors = colors,
                        modifier = Modifier.weight(1f),
                        isFullWidth = false
                    )

                    ElvanStatsCard(
                        icon = MaterialSymbols.Rounded.Apartment,
                        label = K.niruvanangal.tr(),
                        value = companiesSummary,
                        colors = colors,
                        modifier = Modifier.weight(1f),
                        isFullWidth = false
                    )
                }

                // Full-width 3rd card: Invoice count with company breakdown
                ElvanStatsCard(
                    icon = MaterialSymbols.Rounded.Description,
                    label = K.mothaPattiyalgal.tr(),
                    value = invoiceCountSummary,
                    colors = colors,
                    modifier = Modifier.fillMaxWidth(),
                    isFullWidth = true
                )
            }
        }

        // 3. Recent Activity Header
        item(key = "recent_activity_header") {
            RecentActivityHeader(
                onSeeAll = onSeeAll,
                colors = colors
            )
        }

        // 4. Recent Invoices or Empty State
        if (recentBills.isEmpty()) {
            item(key = "recent_empty_state") {
                MugappuEmptyState(colors = colors)
            }
        } else {
            itemsIndexed(
                items = recentBills,
                key = { _, item -> "recent_inv_${item.id}" }
            ) { index, item ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                ) {
                    if (mode == AppMode.KOOLI) {
                        KooliMugappuAttai(
                            index = index,
                            pattiyal = item,
                            colors = colors,
                            onClick = { onInvoiceClick(item) }
                        )
                    } else {
                        PattuMugappuAttai(
                            index = index,
                            pattiyal = item,
                            colors = colors,
                            onClick = { onInvoiceClick(item) }
                        )
                    }
                }
            }
        }
    }
}
