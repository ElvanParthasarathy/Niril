package com.elvan.noolachu.ui.screens.home

import androidx.compose.animation.*
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.data.database.DatabaseProvider
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.repository.PorulRepository
import com.elvan.noolachu.data.repository.VaangunarRepository
import com.elvan.noolachu.localization.*
import com.elvan.noolachu.theme.*
import com.elvan.noolachu.ui.components.ExpressivePullToRefreshBox
import com.elvan.noolachu.ui.components.kooli.KooliLaborItemCard
import com.elvan.noolachu.ui.components.pattu.PattuSilkProductCard
import com.elvan.noolachu.ui.components.shell.*
import com.elvan.noolachu.ui.navigation.AppSvgs
import com.elvan.noolachu.ui.navigation.BottomNavBar
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.navigation.NavTab
import com.elvan.noolachu.ui.screens.porul.PorulScreen
import com.elvan.noolachu.ui.screens.settings.SettingsScreen
import com.elvan.noolachu.ui.screens.thiruthi.porul.PorulThiruthiScreen
import com.elvan.noolachu.ui.screens.thiruthi.vaangunar.VaangunarThiruthiScreen
import com.elvan.noolachu.ui.screens.vaangunar.VaangunarScreen
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class ActiveSubpage {
    data object Settings : ActiveSubpage()
    data class ItemEditor(val item: PorulTharavuru? = null) : ActiveSubpage()
    data class MerchantEditor(val merchant: VaangunarTharavuru? = null) : ActiveSubpage()
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen() {
    val currentMode = LocalAppMode.current
    val billingConfig = AchuMozhiManager.getConfig(currentMode)
    val ff = LocalAppFontFamily.current

    val homeScrollState = rememberLazyListState()
    val createScrollState = rememberLazyListState()
    val productsScrollState = rememberLazyListState()
    val customersScrollState = rememberLazyListState()

    var selectedTab by remember { mutableStateOf(NavTab.Home) }
    var activeSubpage by remember { mutableStateOf<ActiveSubpage?>(null) }
    var isRefreshing by remember { mutableStateOf(false) }
    var isSearchActive by remember { mutableStateOf(false) }
    var menuExpanded by remember { mutableStateOf(false) }

    val scope = rememberCoroutineScope()
    val colors = rememberShellColors()

    // Intercept hardware/system back when a subpage is open
    AppBackHandler(enabled = activeSubpage != null) {
        activeSubpage = null
    }

    // Load repositories on launch and when currentMode changes
    LaunchedEffect(currentMode) {
        PorulRepository.loadAll(currentMode)
        VaangunarRepository.loadAll(currentMode)
    }

    // Reset search state on tab switch
    LaunchedEffect(selectedTab) {
        isSearchActive = false
        PorulRepository.searchQuery = ""
        VaangunarRepository.searchQuery = ""
    }

    val currentScrollState = when (selectedTab) {
        NavTab.Home -> homeScrollState
        NavTab.Create -> createScrollState
        NavTab.Products -> productsScrollState
        NavTab.Customers -> customersScrollState
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
                null -> {
                    ElvanShell(
                        scrollState = currentScrollState,
                        title = selectedTab.getLocalizedHeader(),
                        hasActions = true,
                        actions = {
                        val isProductsOrCustomers = selectedTab == NavTab.Products || selectedTab == NavTab.Customers

                        if (isProductsOrCustomers) {
                            AnimatedVisibility(
                                visible = isSearchActive,
                                enter = fadeIn() + expandHorizontally(),
                                exit = fadeOut() + shrinkHorizontally()
                            ) {
                                val query = if (selectedTab == NavTab.Products) PorulRepository.searchQuery else VaangunarRepository.searchQuery
                                Row(
                                    modifier = Modifier
                                        .height(38.dp)
                                        .widthIn(min = 150.dp, max = 220.dp)
                                        .clip(CircleShape)
                                        .background(colors.iconBg)
                                        .padding(horizontal = 10.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        imageVector = MaterialSymbols.Rounded.Search,
                                        contentDescription = null,
                                        tint = colors.textSecondary,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Box(modifier = Modifier.weight(1f)) {
                                        if (query.isEmpty()) {
                                            Text(
                                                text = K.thaeduga.tr(),
                                                style = TextStyle(
                                                    fontFamily = ff,
                                                    fontSize = 13.sp,
                                                    color = colors.textSecondary.copy(alpha = 0.6f)
                                                )
                                            )
                                        }
                                        BasicTextField(
                                            value = query,
                                            onValueChange = {
                                                if (selectedTab == NavTab.Products) {
                                                    PorulRepository.searchQuery = it
                                                } else {
                                                    VaangunarRepository.searchQuery = it
                                                }
                                            },
                                            textStyle = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 13.sp,
                                                color = colors.textPrimary
                                            ),
                                            singleLine = true,
                                            cursorBrush = SolidColor(colors.accent),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                    }

                                    IconButton(
                                        onClick = {
                                            if (query.isNotEmpty()) {
                                                if (selectedTab == NavTab.Products) {
                                                    PorulRepository.searchQuery = ""
                                                } else {
                                                    VaangunarRepository.searchQuery = ""
                                                }
                                            } else {
                                                isSearchActive = false
                                            }
                                        },
                                        modifier = Modifier.size(24.dp)
                                    ) {
                                        Icon(
                                            imageVector = MaterialSymbols.Rounded.Close,
                                            contentDescription = K.kaividu.tr(),
                                            tint = colors.textPrimary,
                                            modifier = Modifier.size(16.dp)
                                        )
                                    }
                                }
                            }

                            if (!isSearchActive) {
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
                                        if (selectedTab == NavTab.Products) {
                                            activeSubpage = ActiveSubpage.ItemEditor(null)
                                        } else {
                                            activeSubpage = ActiveSubpage.MerchantEditor(null)
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
                        }

                        // Button: 3-Dot More Menu (மேலும்)
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
                        BottomNavBar(
                            selectedTab = selectedTab,
                            onTabSelected = { tab, _ ->
                                if (selectedTab == tab) {
                                    shellController.toggleHeader()
                                } else {
                                    selectedTab = tab
                                }
                            }
                        )
                    }
                ) {
                    when (selectedTab) {
                        NavTab.Home -> {
                            ExpressivePullToRefreshBox(
                                isRefreshing = isRefreshing,
                                onRefresh = {
                                    scope.launch {
                                        isRefreshing = true
                                        delay(800)
                                        isRefreshing = false
                                    }
                                },
                                colors = colors
                            ) {
                                LazyColumn(
                                    state = homeScrollState,
                                    modifier = Modifier.fillMaxSize(),
                                    contentPadding = PaddingValues(
                                        bottom = Dimens.ContentPaddingBottom
                                    ),
                                    verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
                                ) {
                                    // Top spacer driven by One UI collapsible header
                                    item {
                                        Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
                                    }

                                    // 1. Mode Banner Card (Isolated DB)
                                    item {
                                        ElvanSectionContainer {
                                            val bannerShape = RoundedCornerShape(20.dp)
                                            Surface(
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .clip(bannerShape)
                                                    .border(0.5.dp, colors.border, bannerShape)
                                                    .clickable(
                                                        interactionSource = remember { MutableInteractionSource() },
                                                        indication = ShellDefaults.ripple(colors, bounded = true),
                                                        onClick = { ModeManager.toggleMode() }
                                                    ),
                                                shape = bannerShape,
                                                color = colors.surface,
                                                shadowElevation = 0.dp
                                            ) {
                                                Column(
                                                    modifier = Modifier.padding(20.dp),
                                                    horizontalAlignment = Alignment.CenterHorizontally
                                                ) {
                                                    Text(
                                                        text = currentMode.displayName().preventBrokenLigatures(),
                                                        fontSize = 24.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        color = colors.textPrimary
                                                    )
                                                    Spacer(modifier = Modifier.height(4.dp))
                                                    Text(
                                                        text = "${K.tharavuthalam.tr()}: ${DatabaseProvider.currentDatabaseName()} (${K.maatru.tr()})",
                                                        fontSize = 13.sp,
                                                        color = colors.textSecondary
                                                    )
                                                }
                                            }
                                        }
                                    }

                                    // 2. Mode Selector (Kooli vs Pattu)
                                    item {
                                        ElvanSectionContainer {
                                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                                Text(
                                                    text = "${K.endhachCheyalmurai.tr()}:",
                                                    fontWeight = FontWeight.SemiBold,
                                                    fontSize = 14.sp
                                                )

                                                Row(
                                                    modifier = Modifier.fillMaxWidth(),
                                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                                ) {
                                                    AppMode.entries.forEach { mode ->
                                                        val isSelected = currentMode == mode
                                                        if (isSelected) {
                                                            Button(
                                                                onClick = { ModeManager.setMode(mode) },
                                                                modifier = Modifier.weight(1f),
                                                                shape = RoundedCornerShape(14.dp)
                                                            ) {
                                                                Text(mode.displayName())
                                                            }
                                                        } else {
                                                            OutlinedButton(
                                                                onClick = { ModeManager.setMode(mode) },
                                                                modifier = Modifier.weight(1f),
                                                                shape = RoundedCornerShape(14.dp)
                                                            ) {
                                                                Text(mode.displayName())
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    item {
                                        ElvanSectionContainer {
                                            HorizontalDivider(color = colors.divider)
                                        }
                                    }

                                    // 3. UI Language Selector (Screen only)
                                    item {
                                        ElvanSectionContainer {
                                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                                Text(
                                                    text = "${K.cheyaliMozhi.tr()}:",
                                                    fontWeight = FontWeight.SemiBold,
                                                    fontSize = 14.sp
                                                )
                                                Row(
                                                    modifier = Modifier.fillMaxWidth(),
                                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                                ) {
                                                    Language.entries.forEach { lang ->
                                                        val isSelected = LanguageManager.currentLanguage == lang
                                                        FilterChip(
                                                            selected = isSelected,
                                                            onClick = { LanguageManager.setLanguage(lang) },
                                                            label = { Text(lang.displayName) }
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Theme Mode Selector (System, Light, Dark)
                                    item {
                                        ElvanSectionContainer {
                                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                                Text(
                                                    text = "${K.thoatram.tr()}:",
                                                    fontWeight = FontWeight.SemiBold,
                                                    fontSize = 14.sp
                                                )
                                                Row(
                                                    modifier = Modifier.fillMaxWidth(),
                                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                                ) {
                                                    ThemeMode.entries.forEach { mode ->
                                                        val isSelected = ThemeManager.currentThemeMode == mode
                                                        val label = when (mode) {
                                                            ThemeMode.SYSTEM -> K.thaaniyangki.tr()
                                                            ThemeMode.LIGHT -> K.olirNilai.tr()
                                                            ThemeMode.DARK -> K.irulNilai.tr()
                                                        }
                                                        FilterChip(
                                                            selected = isSelected,
                                                            onClick = { ThemeManager.setThemeMode(mode) },
                                                            label = { Text(label) }
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // 4. Print / Billing Language Selector (Brick Wall)
                                    item {
                                        ElvanSectionContainer {
                                            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                                Text(
                                                    text = "${K.pattiyalmozhi.tr()}:",
                                                    fontWeight = FontWeight.SemiBold,
                                                    fontSize = 14.sp
                                                )
                                                Row(
                                                    modifier = Modifier.fillMaxWidth(),
                                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                                ) {
                                                    BillingLanguage.entries.forEach { bLang ->
                                                        val isSelected = billingConfig.primaryLanguage == bLang
                                                        FilterChip(
                                                            selected = isSelected,
                                                            onClick = { AchuMozhiManager.setPrimaryLanguage(currentMode, bLang) },
                                                            label = { Text(bLang.displayName) }
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // 5. Live Bill Output Preview
                                    item {
                                        ElvanSectionContainer {
                                            val previewShape = RoundedCornerShape(20.dp)
                                            Surface(
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .clip(previewShape)
                                                    .border(0.5.dp, colors.border, previewShape),
                                                shape = previewShape,
                                                color = colors.surface,
                                                shadowElevation = 0.dp
                                            ) {
                                                Column(modifier = Modifier.padding(18.dp)) {
                                                    Text(
                                                        text = "${K.munvaraivu.tr()} (${K.pattiyalmozhi.tr()}):",
                                                        fontWeight = FontWeight.Bold,
                                                        fontSize = 14.sp,
                                                        color = colors.accent
                                                    )
                                                    Spacer(modifier = Modifier.height(8.dp))
                                                    Text(
                                                        text = "• ${K.thalaippu.tr()}: ${AchuMozhiManager.printTr(K.pattiyal, currentMode)}",
                                                        fontSize = 13.sp,
                                                        color = colors.textPrimary
                                                    )
                                                    Spacer(modifier = Modifier.height(2.dp))
                                                    Text(
                                                        text = "• ${K.vaangunar.tr()}: ${AchuMozhiManager.printTr(K.vaangunar, currentMode)}",
                                                        fontSize = 13.sp,
                                                        color = colors.textPrimary
                                                    )
                                                    Spacer(modifier = Modifier.height(2.dp))
                                                    Text(
                                                        text = "• ${K.thogai.tr()}: ${AchuMozhiManager.printTr(K.thogai, currentMode)}",
                                                        fontSize = 13.sp,
                                                        color = colors.textPrimary
                                                    )
                                                }
                                            }
                                        }
                                    }

                                    item {
                                        ElvanSectionContainer {
                                            HorizontalDivider(color = colors.divider)
                                        }
                                    }

                                    // 6. Mode-Specific Components (Kooli vs Pattu)
                                    item {
                                        ElvanSectionContainer {
                                            Text(
                                                text = "${currentMode.displayName().preventBrokenLigatures()} ${K.porul.tr()}:",
                                                fontWeight = FontWeight.SemiBold,
                                                fontSize = 14.sp,
                                                color = colors.textPrimary
                                            )
                                        }
                                    }

                                    item {
                                        ElvanSectionContainer {
                                            if (currentMode == AppMode.KOOLI) {
                                                KooliLaborItemCard(
                                                    workName = K.kooli.tr(),
                                                    wageRate = "45.00",
                                                    units = "120",
                                                    total = "5,400.00",
                                                    colors = colors,
                                                    onClick = { ModeManager.toggleMode() }
                                                )
                                            } else {
                                                PattuSilkProductCard(
                                                    productName = K.pattu.tr(),
                                                    hsnCode = "5007",
                                                    weightGrams = "650",
                                                    gstRate = "5",
                                                    price = "12,500.00",
                                                    colors = colors,
                                                    onClick = { ModeManager.toggleMode() }
                                                )
                                            }
                                        }
                                    }

                                    // 7. Settings Hub Entry
                                    item {
                                        ElvanSectionContainer {
                                            ElvanSettingsSection(colors = colors) {
                                                ElvanSettingsRow(
                                                    icon = MaterialSymbols.Rounded.Settings,
                                                    title = K.amaippugal.tr(),
                                                    description = "${K.thoatram.tr()} • ${K.cheyaliMozhi.tr()} • ${K.pattiyalmozhi.tr()} • ${K.tharavuthalam.tr()}",
                                                    onClick = { activeSubpage = ActiveSubpage.Settings },
                                                    colors = colors
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        NavTab.Create -> {
                            LazyColumn(
                                state = createScrollState,
                                modifier = Modifier.fillMaxSize(),
                                contentPadding = PaddingValues(
                                    bottom = Dimens.ContentPaddingBottom
                                ),
                                verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
                            ) {
                                item {
                                    Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
                                }

                                item {
                                    ElvanSectionContainer {
                                        Text(
                                            text = K.pudhiyaAakkam.tr(),
                                            fontSize = 16.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = colors.textPrimary,
                                            modifier = Modifier.padding(bottom = 4.dp)
                                        )
                                    }
                                }

                                item {
                                    ElvanSectionContainer {
                                        ElvanSettingsSection(colors = colors) {
                                            ElvanSettingsRow(
                                                icon = MaterialSymbols.Rounded.Description,
                                                title = K.pudhiyaPattiyal.tr(),
                                                description = K.pattiyalTharavugal.tr(),
                                                onClick = { /* Quick invoice creation */ },
                                                colors = colors
                                            )
                                            ElvanSettingsDivider(colors = colors)
                                            ElvanSettingsRow(
                                                icon = MaterialSymbols.Rounded.Notes,
                                                title = K.patrucheettu.tr(),
                                                description = K.cheluthiyaTharavu.tr(),
                                                onClick = { /* Quick receipt creation */ },
                                                colors = colors
                                            )
                                            ElvanSettingsDivider(colors = colors)
                                            ElvanSettingsRow(
                                                icon = MaterialSymbols.Rounded.Inventory2,
                                                title = K.porulaichChaerPtn.tr(),
                                                description = K.porulTharavugal.tr(),
                                                onClick = { activeSubpage = ActiveSubpage.ItemEditor(null) },
                                                colors = colors
                                            )
                                            ElvanSettingsDivider(colors = colors)
                                            ElvanSettingsRow(
                                                icon = MaterialSymbols.Rounded.Person,
                                                title = K.vaangunaraichChaer.tr(),
                                                description = K.vaangunarTharavugal.tr(),
                                                onClick = { activeSubpage = ActiveSubpage.MerchantEditor(null) },
                                                colors = colors
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        NavTab.Products -> {
                            PorulScreen(
                                scrollState = productsScrollState,
                                onItemClick = { activeSubpage = ActiveSubpage.ItemEditor(it) }
                            )
                        }

                        NavTab.Customers -> {
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
