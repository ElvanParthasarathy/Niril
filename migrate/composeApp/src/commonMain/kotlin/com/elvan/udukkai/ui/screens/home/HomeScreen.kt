package com.elvan.udukkai.ui.screens.home

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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.elvan.udukkai.core.mode.LocalAppMode
import com.elvan.udukkai.core.platform.AppBackHandler
import com.elvan.udukkai.core.platform.PlatformType
import com.elvan.udukkai.core.platform.currentPlatform
import com.elvan.udukkai.ui.screens.home.kanini.ElvanKaniniPakkapattai
import com.elvan.udukkai.data.model.PatrugalTharavuru
import com.elvan.udukkai.data.model.PattiyalTharavuru
import com.elvan.udukkai.data.model.PorulTharavuru
import com.elvan.udukkai.data.model.VaangunarTharavuru
import com.elvan.udukkai.data.repository.PattiyalRepository
import com.elvan.udukkai.data.repository.PatrugalRepository
import com.elvan.udukkai.data.repository.PorulRepository
import com.elvan.udukkai.data.repository.VaangunarRepository
import com.elvan.udukkai.data.settings.NiruvanaTharavugalRepository
import com.elvan.udukkai.data.mock.SodhanaiTharavuUruvakki
import com.elvan.udukkai.localization.K
import com.elvan.udukkai.localization.tr
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.rememberShellColors
import com.elvan.udukkai.ui.components.ExpressivePullToRefreshBox
import com.elvan.udukkai.ui.components.shell.*
import com.elvan.udukkai.ui.navigation.BottomNavBar
import com.elvan.udukkai.ui.navigation.ElvanThaedalPattai
import com.elvan.udukkai.ui.navigation.MaterialSymbols
import com.elvan.udukkai.ui.navigation.NavTab
import com.elvan.udukkai.ui.screens.meetpagam.MeetpagamScreen
import com.elvan.udukkai.ui.screens.porul.PorulScreen
import com.elvan.udukkai.ui.screens.paarvai.PatrucheettuPaarvaiScreen
import com.elvan.udukkai.ui.screens.paarvai.PattiyalPaarvaiScreen
import com.elvan.udukkai.ui.screens.paarvai.PorulPaarvaiScreen
import com.elvan.udukkai.ui.screens.paarvai.VaangunarPaarvaiScreen
import com.elvan.udukkai.ui.screens.settings.SettingsScreen
import com.elvan.udukkai.ui.screens.thiruthi.patrucheettu.PatrucheettuThiruthiScreen
import com.elvan.udukkai.ui.screens.thiruthi.pattiyal.KooliPattiyalThiruthiScreen
import com.elvan.udukkai.ui.screens.thiruthi.pattiyal.PattiyalThiruthiScreen
import com.elvan.udukkai.ui.screens.thiruthi.pattiyal.PattuPattiyalThiruthiScreen
import com.elvan.udukkai.ui.screens.thiruthi.porul.PorulThiruthiScreen
import com.elvan.udukkai.ui.screens.thiruthi.vaangunar.VaangunarThiruthiScreen
import androidx.compose.foundation.shape.CircleShape
import com.elvan.udukkai.ui.screens.uruvakku.UruvakkuScreen
import com.elvan.udukkai.ui.screens.uruvakku.koorugal.UruvakkuDateFilterSheet
import com.elvan.udukkai.ui.screens.vaangunar.VaangunarScreen
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class ActiveSubpage {
    data object Settings : ActiveSubpage()
    data object RecycleBin : ActiveSubpage()
    data class ItemEditor(val item: PorulTharavuru? = null) : ActiveSubpage()
    data class MerchantEditor(val merchant: VaangunarTharavuru? = null) : ActiveSubpage()
    data class InvoiceEditor(val invoice: PattiyalTharavuru? = null) : ActiveSubpage()
    data class ReceiptEditor(val receipt: PatrugalTharavuru? = null) : ActiveSubpage()
    data class CustomerView(val customer: VaangunarTharavuru) : ActiveSubpage()
    data class ProductView(val product: PorulTharavuru) : ActiveSubpage()
    data class InvoiceView(val invoice: PattiyalTharavuru) : ActiveSubpage()
    data class ReceiptView(val receipt: PatrugalTharavuru) : ActiveSubpage()
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
    var isSelectionMode by remember { mutableStateOf(false) }
    var selectedItemIds by remember { mutableStateOf<Set<Long>>(emptySet()) }
    var showBulkDeleteConfirm by remember { mutableStateOf(false) }
    var showDateFilterSheet by remember { mutableStateOf(false) }

    val onToggleItem: (Long) -> Unit = { id ->
        val newSet = if (selectedItemIds.contains(id)) selectedItemIds - id else selectedItemIds + id
        selectedItemIds = newSet
        if (newSet.isEmpty()) isSelectionMode = false
    }
    val onStartSelection: (Long) -> Unit = { id ->
        isSelectionMode = true
        selectedItemIds = setOf(id)
    }

    val scope = rememberCoroutineScope()
    val colors = rememberShellColors()

    val porulDeletedMsg = K.productDeleted.tr()
    val vaangunarDeletedMsg = K.customerDeleted.tr()
    val pattiyalgalLabel = K.invoices.tr()
    val patrucheettugalLabel = K.receipts.tr()
    val azhikkiradhuLabel = K.erasing.tr()

    // Intercept hardware/system back when a subpage is open, selection mode is active, or search is active
    AppBackHandler(enabled = activeSubpage != null || isSelectionMode || isSearchActive || showBulkDeleteConfirm) {
        if (showBulkDeleteConfirm) {
            showBulkDeleteConfirm = false
        } else if (activeSubpage != null) {
            activeSubpage = null
        } else if (isSelectionMode) {
            isSelectionMode = false
            selectedItemIds = emptySet()
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

        if (PattiyalRepository.invoices.isEmpty() && VaangunarRepository.merchants.isEmpty()) {
            SodhanaiTharavuUruvakki.seedAllData()
        }
    }

    // Reset search and selection state on tab switch
    LaunchedEffect(selectedTab) {
        isSearchActive = false
        isSelectionMode = false
        selectedItemIds = emptySet()
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

    val isDesktop = currentPlatform == PlatformType.DESKTOP

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.background)
    ) {
        val isWideScreen = isDesktop && maxWidth >= 768.dp

        LaunchedEffect(activeSubpage, isWideScreen) {
            ElvanSnackbar.isBottomBarVisible = (activeSubpage == null && !isWideScreen)
        }
        DisposableEffect(Unit) {
            onDispose { ElvanSnackbar.isBottomBarVisible = false }
        }

        Row(modifier = Modifier.fillMaxSize()) {
            if (isWideScreen) {
                ElvanKaniniPakkapattai(
                    selectedTab = selectedTab,
                    onTabSelected = { tab ->
                        selectedTab = tab
                        activeSubpage = null
                    },
                    onSettingsClick = {
                        activeSubpage = ActiveSubpage.Settings
                    },
                    colors = colors
                )
            }

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
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
                is ActiveSubpage.RecycleBin -> {
                    MeetpagamScreen(
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
                    if (currentMode == com.elvan.udukkai.core.mode.AppMode.PATTU) {
                        PattuPattiyalThiruthiScreen(
                            invoice = subpage.invoice,
                            onBack = { activeSubpage = null },
                            onRequestAddNewCustomer = {
                                activeSubpage = ActiveSubpage.MerchantEditor(null)
                            },
                            onRequestAddNewProduct = {
                                activeSubpage = ActiveSubpage.ItemEditor(null)
                            }
                        )
                    } else {
                        KooliPattiyalThiruthiScreen(
                            invoice = subpage.invoice,
                            onBack = { activeSubpage = null },
                            onRequestAddNewCustomer = {
                                activeSubpage = ActiveSubpage.MerchantEditor(null)
                            },
                            onRequestAddNewProduct = {
                                activeSubpage = ActiveSubpage.ItemEditor(null)
                            }
                        )
                    }
                }
                is ActiveSubpage.ReceiptEditor -> {
                    PatrucheettuThiruthiScreen(
                        receipt = subpage.receipt,
                        onBack = { activeSubpage = null }
                    )
                }
                is ActiveSubpage.CustomerView -> {
                    VaangunarPaarvaiScreen(
                        merchant = subpage.customer,
                        onBack = { activeSubpage = null },
                        onEdit = {
                            activeSubpage = ActiveSubpage.MerchantEditor(subpage.customer)
                        }
                    )
                }
                is ActiveSubpage.ProductView -> {
                    PorulPaarvaiScreen(
                        item = subpage.product,
                        onBack = { activeSubpage = null },
                        onEdit = {
                            activeSubpage = ActiveSubpage.ItemEditor(subpage.product)
                        }
                    )
                }
                is ActiveSubpage.InvoiceView -> {
                    PattiyalPaarvaiScreen(
                        invoice = subpage.invoice,
                        onBack = { activeSubpage = null },
                        onEdit = {
                            activeSubpage = ActiveSubpage.InvoiceEditor(subpage.invoice)
                        }
                    )
                }
                is ActiveSubpage.ReceiptView -> {
                    PatrucheettuPaarvaiScreen(
                        receipt = subpage.receipt,
                        onBack = { activeSubpage = null },
                        onEdit = {
                            activeSubpage = ActiveSubpage.ReceiptEditor(subpage.receipt)
                        }
                    )
                }
                null -> {
                    ElvanShell(
                        scrollState = currentScrollState,
                        title = selectedTab.getLocalizedHeader(),
                        showNavbar = !isWideScreen,
                        hasActions = !isSearchActive,
                        actions = {
                            if (selectedTab != NavTab.Home) {
                                // Search Icon Button
                                ElvanTopBarIconButton(
                                    onClick = { isSearchActive = true }
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Search,
                                        contentDescription = K.search.tr(),
                                        tint = colors.textPrimary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                            }

                            // Filter Circle Button (exclusive for Uruvakku: Search -> Filter -> 3-Dot)
                            if (selectedTab == NavTab.Create) {
                                val isFilterActive = PattiyalRepository.isDateFilterActive || PatrugalRepository.isDateFilterActive
                                ElvanTopBarIconButton(
                                    onClick = { showDateFilterSheet = true }
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.FilterList,
                                        contentDescription = "Filter",
                                        tint = if (isFilterActive) colors.accent else colors.textPrimary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                            }

                            // 3-Dot More Menu (மேலும்)
                            Box {
                                ElvanTopBarIconButton(
                                    onClick = {
                                        ElvanMenuState.isMenuOpen = true
                                        menuExpanded = true
                                    }
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.MoreVert,
                                        contentDescription = K.more.tr(),
                                        tint = colors.textPrimary,
                                        modifier = Modifier.size(22.dp)
                                    )
                                }
                                val settingsLabel = K.settings.tr()
                                val meetpagamLabel = K.recycleBin.tr()
                                val thaerndheduLabel = K.select.tr()
                                val menuItems = buildList {
                                    add(
                                        ElvanPopupMenuItem(
                                            title = settingsLabel,
                                            icon = MaterialSymbols.Rounded.Settings,
                                            onClick = {
                                                ElvanMenuState.isMenuOpen = false
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
                                                ElvanMenuState.isMenuOpen = false
                                                menuExpanded = false
                                                activeSubpage = ActiveSubpage.RecycleBin
                                            }
                                        )
                                    )
                                    if (selectedTab != NavTab.Home) {
                                        add(
                                            ElvanPopupMenuItem(
                                                title = thaerndheduLabel,
                                                icon = MaterialSymbols.Rounded.CheckCircleFill,
                                                onClick = {
                                                    ElvanMenuState.isMenuOpen = false
                                                    menuExpanded = false
                                                    isSelectionMode = true
                                                }
                                            )
                                        )
                                    }
                                }
                                ElvanPopupMenu(
                                    expanded = menuExpanded,
                                    onDismissRequest = {
                                        ElvanMenuState.isMenuOpen = false
                                        menuExpanded = false
                                    },
                                    colors = colors,
                                    items = menuItems
                                )
                            }
                        },
                        navbar = {
                            val shellController = LocalElvanShellController.current

                            if (isSelectionMode) {
                                Box(
                                    contentAlignment = Alignment.Center,
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    ElvanThervuPattai(
                                        selectedCount = selectedItemIds.size,
                                        onSelectAll = {
                                            val allIds: Set<Long> = when (selectedTab) {
                                                NavTab.Products -> PorulRepository.filteredItems.map { it.id }.toSet()
                                                NavTab.Customers -> VaangunarRepository.filteredMerchants.map { it.id }.toSet()
                                                NavTab.Create -> {
                                                    if (uruvakkuSegment == 0) {
                                                        PattiyalRepository.filteredInvoices.map { it.id }.toSet()
                                                    } else {
                                                        PatrugalRepository.filteredReceipts.map { it.id }.toSet()
                                                    }
                                                }
                                                else -> emptySet()
                                            }
                                            selectedItemIds = if (selectedItemIds.size == allIds.size) emptySet() else allIds
                                        },
                                        onDelete = {
                                            if (selectedItemIds.isNotEmpty()) {
                                                showBulkDeleteConfirm = true
                                            }
                                        },
                                        onCancel = {
                                            isSelectionMode = false
                                            selectedItemIds = emptySet()
                                        }
                                    )
                                }
                            } else {
                                Box(
                                    contentAlignment = Alignment.Center,
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    BottomNavBar(
                                        selectedTab = selectedTab,
                                        hideContent = isSearchActive,
                                        onAddClick = {
                                            when (selectedTab) {
                                                NavTab.Home -> {
                                                    activeSubpage = ActiveSubpage.InvoiceEditor(null)
                                                }
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
                                            }
                                        },
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
                                            delay(700)
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
                                        isRefreshing = isRefreshing,
                                        onInvoiceClick = { invoice ->
                                            activeSubpage = ActiveSubpage.InvoiceView(invoice)
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
                                            delay(700)
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
                                            isSelectionMode = false
                                            selectedItemIds = emptySet()
                                            PattiyalRepository.searchQuery = ""
                                            PatrugalRepository.searchQuery = ""
                                        },
                                        isRefreshing = isRefreshing,
                                        isSelectionMode = isSelectionMode,
                                        selectedItemIds = selectedItemIds,
                                        onToggleSelect = onToggleItem,
                                        onItemLongClick = onStartSelection,
                                        onInvoiceClick = { invoice ->
                                            activeSubpage = ActiveSubpage.InvoiceView(invoice)
                                        },
                                        onReceiptClick = { receipt ->
                                            activeSubpage = ActiveSubpage.ReceiptView(receipt)
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
                                            delay(700)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    PorulScreen(
                                        scrollState = productsScrollState,
                                        isRefreshing = isRefreshing,
                                        onItemClick = { activeSubpage = ActiveSubpage.ProductView(it) },
                                        isSelectionMode = isSelectionMode,
                                        selectedItemIds = selectedItemIds,
                                        onToggleSelect = onToggleItem,
                                        onItemLongClick = onStartSelection
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
                                            delay(700)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    VaangunarScreen(
                                        scrollState = customersScrollState,
                                        isRefreshing = isRefreshing,
                                        onMerchantClick = { activeSubpage = ActiveSubpage.CustomerView(it) },
                                        isSelectionMode = isSelectionMode,
                                        selectedItemIds = selectedItemIds,
                                        onToggleSelect = onToggleItem,
                                        onItemLongClick = onStartSelection
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        if (showBulkDeleteConfirm && selectedItemIds.isNotEmpty()) {
            val deleteSheetTitle = when (selectedTab) {
                NavTab.Products -> "${selectedItemIds.size} ${K.productDeleted.tr()}"
                NavTab.Customers -> "${selectedItemIds.size} ${K.customerDeleted.tr()}"
                NavTab.Create -> {
                    if (uruvakkuSegment == 0) {
                        "${selectedItemIds.size} ${K.invoices.tr()}"
                    } else {
                        "${selectedItemIds.size} ${K.receipts.tr()}"
                    }
                }
                else -> ""
            }
            ElvanActionSheet(
                title = deleteSheetTitle,
                cancelText = K.cancelBtn.tr(),
                confirmText = K.deleteBtn.tr(),
                confirmColor = Color(0xFFBA1A1A),
                onConfirm = {
                    when (selectedTab) {
                        NavTab.Products -> {
                            selectedItemIds.forEach { PorulRepository.delete(it, currentMode) }
                            ElvanSnackbar.show(porulDeletedMsg)
                        }
                        NavTab.Customers -> {
                            selectedItemIds.forEach { VaangunarRepository.delete(it, currentMode) }
                            ElvanSnackbar.show(vaangunarDeletedMsg)
                        }
                        NavTab.Create -> {
                            if (uruvakkuSegment == 0) {
                                selectedItemIds.forEach { PattiyalRepository.delete(it, currentMode) }
                                ElvanSnackbar.show("${selectedItemIds.size} $pattiyalgalLabel $azhikkiradhuLabel")
                            } else {
                                selectedItemIds.forEach { PatrugalRepository.delete(it, currentMode) }
                                ElvanSnackbar.show("${selectedItemIds.size} $patrucheettugalLabel $azhikkiradhuLabel")
                            }
                        }
                        else -> {}
                    }
                    isSelectionMode = false
                    selectedItemIds = emptySet()
                    showBulkDeleteConfirm = false
                },
                onDismissRequest = {
                    showBulkDeleteConfirm = false
                },
                colors = colors
            )
        }

        UruvakkuDateFilterSheet(
            isOpen = showDateFilterSheet,
            currentStartMillis = if (uruvakkuSegment == 0) PattiyalRepository.startDateFilter else PatrugalRepository.startDateFilter,
            currentEndMillis = if (uruvakkuSegment == 0) PattiyalRepository.endDateFilter else PatrugalRepository.endDateFilter,
            onDismissRequest = { showDateFilterSheet = false },
            onApplyFilter = { start, end, _ ->
                PattiyalRepository.setDateRange(start, end)
                PatrugalRepository.setDateRange(start, end)
            },
            colors = colors
        )
            }
        }
    }
}
