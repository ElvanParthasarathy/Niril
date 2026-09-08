package com.elvan.noolachu.ui.screens.home

import androidx.compose.animation.*
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.data.model.PatrugalTharavuru
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.repository.PattiyalRepository
import com.elvan.noolachu.data.repository.PatrugalRepository
import com.elvan.noolachu.data.repository.PorulRepository
import com.elvan.noolachu.data.repository.VaangunarRepository
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.ExpressivePullToRefreshBox
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.BottomNavBar
import com.elvan.noolachu.ui.navigation.ElvanThaedalPattai
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.navigation.NavTab
import com.elvan.noolachu.ui.screens.porul.PorulScreen
import com.elvan.noolachu.ui.screens.settings.SettingsScreen
import com.elvan.noolachu.ui.screens.thiruthi.patrucheettu.PatrucheettuThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.PattiyalThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.porul.PorulThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.vaangunar.VaangunarThiruthiScreen
import com.elvan.noolachu.ui.screens.uruvakku.UruvakkuScreen
import com.elvan.noolachu.ui.screens.vaangunar.VaangunarScreen
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class ActiveSubpage {
    data object Settings : ActiveSubpage()
    data class ItemEditor(val item: PorulTharavuru? = null) : ActiveSubpage()
    data class MerchantEditor(val merchant: VaangunarTharavuru? = null) : ActiveSubpage()
    data class InvoiceEditor(val invoice: PattiyalTharavuru? = null) : ActiveSubpage()
    data class ReceiptEditor(val receipt: PatrugalTharavuru? = null) : ActiveSubpage()
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen() {
    val currentMode = LocalAppMode.current
    val ff = LocalAppFontFamily.current

    val homeScrollState = rememberLazyListState()
    val createScrollState = rememberLazyListState()
    val productsScrollState = rememberLazyListState()
    val customersScrollState = rememberLazyListState()

    var selectedTab by remember { mutableStateOf(NavTab.Home) }
    var uruvakkuSegment by remember { mutableStateOf(0) } // 0 = Invoices, 1 = Receipts
    var activeSubpage by remember { mutableStateOf<ActiveSubpage?>(null) }
    var isRefreshing by remember { mutableStateOf(false) }
    var isSearchActive by remember { mutableStateOf(false) }
    var menuExpanded by remember { mutableStateOf(false) }

    val scope = rememberCoroutineScope()
    val colors = rememberShellColors()

    // Intercept hardware/system back when a subpage is open or search is active
    AppBackHandler(enabled = activeSubpage != null || isSearchActive) {
        if (activeSubpage != null) {
            activeSubpage = null
        } else if (isSearchActive) {
            isSearchActive = false
            PattiyalRepository.searchQuery = ""
            PatrugalRepository.searchQuery = ""
            PorulRepository.searchQuery = ""
            VaangunarRepository.searchQuery = ""
        }
    }

    // Load all repositories on launch and when currentMode changes
    LaunchedEffect(currentMode) {
        PattiyalRepository.loadAll(currentMode)
        PatrugalRepository.loadAll(currentMode)
        PorulRepository.loadAll(currentMode)
        VaangunarRepository.loadAll(currentMode)
        NiruvanaTharavugalRepository.refreshFromDatabase()
    }

    // Reset search state on tab switch
    LaunchedEffect(selectedTab) {
        isSearchActive = false
        PattiyalRepository.searchQuery = ""
        PatrugalRepository.searchQuery = ""
        PorulRepository.searchQuery = ""
        VaangunarRepository.searchQuery = ""
    }

    val currentScrollState = when (selectedTab) {
        NavTab.Home -> homeScrollState
        NavTab.Create -> createScrollState
        NavTab.Products -> productsScrollState
        NavTab.Customers -> customersScrollState
    }

    val currentSearchQuery = when (selectedTab) {
        NavTab.Home -> ""
        NavTab.Create -> if (uruvakkuSegment == 0) PattiyalRepository.searchQuery else PatrugalRepository.searchQuery
        NavTab.Products -> PorulRepository.searchQuery
        NavTab.Customers -> VaangunarRepository.searchQuery
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.background)
    ) {
        AnimatedContent(
            targetState = activeSubpage,
            modifier = Modifier
                .fillMaxSize()
                .background(colors.background),
            transitionSpec = {
                if (targetState != null) {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Left,
                        animationSpec = spring(stiffness = Spring.StiffnessLow, dampingRatio = Spring.DampingRatioNoBouncy)
                    ) togetherWith fadeOut(targetAlpha = 0.9f, animationSpec = tween(durationMillis = 50))
                } else {
                    fadeIn(initialAlpha = 0.9f) togetherWith slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Right,
                        animationSpec = spring(stiffness = Spring.StiffnessLow, dampingRatio = Spring.DampingRatioNoBouncy)
                    )
                }
            },
            label = "HomeToSubpageTransition"
        ) { subpage ->
            when (subpage) {
                is ActiveSubpage.Settings -> {
                    SettingsScreen(
                        onBack = { activeSubpage = null }
                    )
                }
                is ActiveSubpage.ItemEditor -> {
                    PorulThiruthiScreen(
                        item = subpage.item,
                        onBack = { activeSubpage = null }
                    )
                }
                is ActiveSubpage.MerchantEditor -> {
                    VaangunarThiruthiScreen(
                        merchant = subpage.merchant,
                        onBack = { activeSubpage = null }
                    )
                }
                is ActiveSubpage.InvoiceEditor -> {
                    PattiyalThiruthiScreen(
                        invoice = subpage.invoice,
                        onBack = { activeSubpage = null }
                    )
                }
                is ActiveSubpage.ReceiptEditor -> {
                    PatrucheettuThiruthiScreen(
                        receipt = subpage.receipt,
                        onBack = { activeSubpage = null }
                    )
                }
                null -> {
                    ElvanShell(
                        scrollState = currentScrollState,
                        title = selectedTab.getLocalizedHeader(),
                        hasActions = !isSearchActive,
                        actions = {
                            val hasSearchAndAdd = selectedTab != NavTab.Home

                            if (hasSearchAndAdd) {
                                // Search Icon Button
                                ElvanTopBarIconButton(
                                    onClick = { isSearchActive = true }
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Search,
                                        contentDescription = K.thaeduga.tr(),
                                        tint = colors.textPrimary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }

                                // Add (+) Button
                                ElvanTopBarIconButton(
                                    onClick = {
                                        when (selectedTab) {
                                            NavTab.Products -> {
                                                activeSubpage = ActiveSubpage.ItemEditor(null)
                                            }
                                            NavTab.Customers -> {
                                                activeSubpage = ActiveSubpage.MerchantEditor(null)
                                            }
                                            NavTab.Create -> {
                                                if (uruvakkuSegment == 0) {
                                                    activeSubpage = ActiveSubpage.InvoiceEditor(null)
                                                } else {
                                                    activeSubpage = ActiveSubpage.ReceiptEditor(null)
                                                }
                                            }
                                            else -> {}
                                        }
                                    }
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Add,
                                        contentDescription = K.chaer.tr(),
                                        tint = colors.textPrimary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                            }

                            // 3-Dot More Menu (மேலும்) (26dp)
                            Box {
                                ElvanTopBarIconButton(
                                    onClick = { menuExpanded = true }
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.MoreVert,
                                        contentDescription = K.melum.tr(),
                                        tint = colors.textPrimary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                                val settingsLabel = K.amaippugal.tr()
                                val meetpagamLabel = K.meetpagam.tr()
                                val thaerndheduLabel = K.thaerndhedu.tr()
                                val menuItems = buildList {
                                    add(
                                        ElvanPopupMenuItem(
                                            title = settingsLabel,
                                            icon = MaterialSymbols.Rounded.Settings,
                                            onClick = {
                                                menuExpanded = false
                                                activeSubpage = ActiveSubpage.Settings
                                            }
                                        )
                                    )
                                    add(
                                        ElvanPopupMenuItem(
                                            title = meetpagamLabel,
                                            icon = MaterialSymbols.Rounded.Delete,
                                            onClick = {
                                                menuExpanded = false
                                                ElvanSnackbar.show(meetpagamLabel)
                                            }
                                        )
                                    )
                                    if (selectedTab != NavTab.Home) {
                                        add(
                                            ElvanPopupMenuItem(
                                                title = thaerndheduLabel,
                                                icon = MaterialSymbols.Rounded.CheckCircleFill,
                                                onClick = {
                                                    menuExpanded = false
                                                    ElvanSnackbar.show(thaerndheduLabel)
                                                }
                                            )
                                        )
                                    }
                                }
                                ElvanPopupMenu(
                                    expanded = menuExpanded,
                                    onDismissRequest = { menuExpanded = false },
                                    colors = colors,
                                    items = menuItems
                                )
                            }
                        },
                        navbar = {
                            val shellController = LocalElvanShellController.current

                            Box(
                                contentAlignment = Alignment.Center,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                BottomNavBar(
                                    selectedTab = selectedTab,
                                    hideContent = isSearchActive,
                                    onTabSelected = { tab, _ ->
                                        if (selectedTab == tab) {
                                            shellController.toggleHeader()
                                        } else {
                                            selectedTab = tab
                                        }
                                    }
                                )

                                ElvanThaedalPattai(
                                    visible = isSearchActive,
                                    query = currentSearchQuery,
                                    onQueryChange = { newQuery ->
                                        when (selectedTab) {
                                            NavTab.Create -> {
                                                if (uruvakkuSegment == 0) {
                                                    PattiyalRepository.searchQuery = newQuery
                                                } else {
                                                    PatrugalRepository.searchQuery = newQuery
                                                }
                                            }
                                            NavTab.Products -> {
                                                PorulRepository.searchQuery = newQuery
                                            }
                                            NavTab.Customers -> {
                                                VaangunarRepository.searchQuery = newQuery
                                            }
                                            else -> {}
                                        }
                                    },
                                    onClose = {
                                        isSearchActive = false
                                        PattiyalRepository.searchQuery = ""
                                        PatrugalRepository.searchQuery = ""
                                        PorulRepository.searchQuery = ""
                                        VaangunarRepository.searchQuery = ""
                                    },
                                    colors = colors
                                )
                            }
                        }
                    ) {
                        when (selectedTab) {
                            NavTab.Home -> {
                                ExpressivePullToRefreshBox(
                                    isRefreshing = isRefreshing,
                                    onRefresh = {
                                        scope.launch {
                                            isRefreshing = true
                                            PattiyalRepository.loadAll(currentMode)
                                            PatrugalRepository.loadAll(currentMode)
                                            NiruvanaTharavugalRepository.refreshFromDatabase()
                                            delay(600)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    MugappuScreen(
                                        scrollState = homeScrollState,
                                        onSeeAll = {
                                            selectedTab = NavTab.Create
                                            uruvakkuSegment = 0
                                        },
                                        onInvoiceClick = { invoice ->
                                            activeSubpage = ActiveSubpage.InvoiceEditor(invoice)
                                        }
                                    )
                                }
                            }

                            NavTab.Create -> {
                                ExpressivePullToRefreshBox(
                                    isRefreshing = isRefreshing,
                                    onRefresh = {
                                        scope.launch {
                                            isRefreshing = true
                                            PattiyalRepository.loadAll(currentMode)
                                            PatrugalRepository.loadAll(currentMode)
                                            delay(600)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    UruvakkuScreen(
                                        scrollState = createScrollState,
                                        selectedSegment = uruvakkuSegment,
                                        onSegmentSelected = { newSegment ->
                                            uruvakkuSegment = newSegment
                                            isSearchActive = false
                                            PattiyalRepository.searchQuery = ""
                                            PatrugalRepository.searchQuery = ""
                                        },
                                        onInvoiceClick = { invoice ->
                                            activeSubpage = ActiveSubpage.InvoiceEditor(invoice)
                                        },
                                        onReceiptClick = { receipt ->
                                            activeSubpage = ActiveSubpage.ReceiptEditor(receipt)
                                        }
                                    )
                                }
                            }

                            NavTab.Products -> {
                                ExpressivePullToRefreshBox(
                                    isRefreshing = isRefreshing,
                                    onRefresh = {
                                        scope.launch {
                                            isRefreshing = true
                                            PorulRepository.loadAll(currentMode)
                                            delay(600)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    PorulScreen(
                                        scrollState = productsScrollState,
                                        onItemClick = { activeSubpage = ActiveSubpage.ItemEditor(it) }
                                    )
                                }
                            }

                            NavTab.Customers -> {
                                ExpressivePullToRefreshBox(
                                    isRefreshing = isRefreshing,
                                    onRefresh = {
                                        scope.launch {
                                            isRefreshing = true
                                            VaangunarRepository.loadAll(currentMode)
                                            delay(600)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    VaangunarScreen(
                                        scrollState = customersScrollState,
                                        onMerchantClick = { activeSubpage = ActiveSubpage.MerchantEditor(it) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
