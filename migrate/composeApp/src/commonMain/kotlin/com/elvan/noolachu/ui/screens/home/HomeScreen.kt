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
import androidx.compose.ui.graphics.Color
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
import com.elvan.noolachu.ui.screens.meetpagam.MeetpagamScreen
import com.elvan.noolachu.ui.screens.porul.PorulScreen
import com.elvan.noolachu.ui.screens.paarvai.PatrucheettuPaarvaiScreen
import com.elvan.noolachu.ui.screens.paarvai.PattiyalPaarvaiScreen
import com.elvan.noolachu.ui.screens.paarvai.PorulPaarvaiScreen
import com.elvan.noolachu.ui.screens.paarvai.VaangunarPaarvaiScreen
import com.elvan.noolachu.ui.screens.settings.SettingsScreen
import com.elvan.noolachu.ui.screens.thiruthi.patrucheettu.PatrucheettuThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.KooliPattiyalThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.PattiyalThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.pattiyal.PattuPattiyalThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.porul.PorulThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.vaangunar.VaangunarThiruthiScreen
import com.elvan.noolachu.ui.screens.uruvakku.UruvakkuScreen
import com.elvan.noolachu.ui.screens.vaangunar.VaangunarScreen
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

    val porulDeletedMsg = K.porulAzhikkappattadhu.tr()
    val vaangunarDeletedMsg = K.vaangunarAzhikkappattadhu.tr()
    val pattiyalgalLabel = K.pattiyalgal.tr()
    val patrucheettugalLabel = K.patrucheettugal.tr()
    val azhikkiradhuLabel = K.azhikkiradhu.tr()

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
                    if (currentMode == com.elvan.noolachu.core.mode.AppMode.PATTU) {
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
                        hasActions = !isSearchActive,
                        actions = {
                            if (selectedTab != NavTab.Home) {
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
                            }

                            // Add (+) Button — Available across all tabs including Home
                            ElvanTopBarIconButton(
                                onClick = {
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
                                }
                            ) {
                                Icon(
                                    imageVector = MaterialSymbols.Rounded.Add,
                                    contentDescription = K.chaer.tr(),
                                    tint = colors.textPrimary,
                                    modifier = Modifier.size(24.dp)
                                )
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
                                            isSelectionMode = false
                                            selectedItemIds = emptySet()
                                            PattiyalRepository.searchQuery = ""
                                            PatrugalRepository.searchQuery = ""
                                        },
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
                                            delay(600)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    PorulScreen(
                                        scrollState = productsScrollState,
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
                                            delay(600)
                                            isRefreshing = false
                                        }
                                    },
                                    colors = colors
                                ) {
                                    VaangunarScreen(
                                        scrollState = customersScrollState,
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
                NavTab.Products -> "${selectedItemIds.size} ${K.porulAzhikkappattadhu.tr()}"
                NavTab.Customers -> "${selectedItemIds.size} ${K.vaangunarAzhikkappattadhu.tr()}"
                NavTab.Create -> {
                    if (uruvakkuSegment == 0) {
                        "${selectedItemIds.size} ${K.pattiyalgal.tr()}"
                    } else {
                        "${selectedItemIds.size} ${K.patrucheettugal.tr()}"
                    }
                }
                else -> ""
            }
            ElvanActionSheet(
                title = deleteSheetTitle,
                cancelText = K.kaividuPtn.tr(),
                confirmText = K.neekkuPtn.tr(),
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
    }
}
