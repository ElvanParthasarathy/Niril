package com.elvan.noolachu.ui.screens.home

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.mode.ModeManager
import com.elvan.noolachu.data.database.DatabaseProvider
import com.elvan.noolachu.localization.*
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.ThemeManager
import com.elvan.noolachu.theme.ThemeMode
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.ExpressivePullToRefreshBox
import kotlinx.coroutines.delay
import com.elvan.noolachu.ui.components.kooli.KooliLaborItemCard
import com.elvan.noolachu.ui.components.pattu.PattuSilkProductCard
import com.elvan.noolachu.ui.components.shell.ElvanShell
import com.elvan.noolachu.ui.components.shell.ElvanTopBarIconButton
import com.elvan.noolachu.ui.components.shell.LocalElvanShellController
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.BottomNavBar
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.navigation.NavTab
import kotlinx.coroutines.launch

import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.ui.components.shell.ElvanSubShell
import com.elvan.noolachu.ui.components.shell.ElvanSectionContainer
import com.elvan.noolachu.ui.components.shell.ElvanSettingsSection
import com.elvan.noolachu.ui.components.shell.ElvanSettingsRow
import com.elvan.noolachu.ui.components.shell.ElvanPopupMenu
import com.elvan.noolachu.ui.components.shell.ElvanPopupMenuItem
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import com.elvan.noolachu.theme.Transitions
import com.elvan.noolachu.ui.screens.settings.SettingsScreen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen() {
    val currentMode = LocalAppMode.current
    val billingConfig = AchuMozhiManager.getConfig(currentMode)
    val scrollState = rememberLazyListState()
    var selectedTab by remember { mutableStateOf(NavTab.Home) }
    var isSettingsOpen by remember { mutableStateOf(false) }
    var isRefreshing by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val colors = rememberShellColors()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.background)
    ) {
        AnimatedContent(
            targetState = isSettingsOpen,
            modifier = Modifier
                .fillMaxSize()
                .background(colors.background),
            transitionSpec = {
                if (targetState) {
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
            label = "HomeToSettingsTransition"
        ) { settingsOpen ->
        if (settingsOpen) {
            SettingsScreen(
                onBack = { isSettingsOpen = false }
            )
        } else {
            ElvanShell(
        scrollState = scrollState,
        title = currentMode.displayName(),
        hasActions = true,
        actions = {
            // Button 1: Mode Switch (கூலி ⇄ பட்டு)
            ElvanTopBarIconButton(
                onClick = { ModeManager.toggleMode() }
            ) {
                Box(
                    modifier = Modifier
                        .size(24.dp)
                        .clip(RoundedCornerShape(6.dp))
                        .border(1.5.dp, colors.textPrimary, RoundedCornerShape(6.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = if (ModeManager.isKooli) "கூ" else "ப",
                        color = colors.textPrimary,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.offset(y = (-0.5).dp)
                    )
                }
            }

            // Button 2: Theme Toggle (Light ⇄ Dark)
            ElvanTopBarIconButton(
                onClick = { ThemeManager.toggleTheme() }
            ) {
                Icon(
                    imageVector = if (ThemeManager.isDark()) MaterialSymbols.Rounded.LightMode else MaterialSymbols.Rounded.DarkMode,
                    contentDescription = K.thoatram.tr(),
                    tint = colors.textPrimary,
                    modifier = Modifier.size(22.dp)
                )
            }

            // Button 3: 3-Dot More Menu (மேலும்)
            var menuExpanded by remember { mutableStateOf(false) }
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
                ElvanPopupMenu(
                    expanded = menuExpanded,
                    onDismissRequest = { menuExpanded = false },
                    colors = colors,
                    items = listOf(
                        ElvanPopupMenuItem(
                            title = K.amaippugal.tr(),
                            icon = MaterialSymbols.Rounded.Settings,
                            onClick = {
                                isSettingsOpen = true
                            }
                        ),
                        ElvanPopupMenuItem(
                            title = K.cheyaliMozhi.tr(),
                            icon = MaterialSymbols.Rounded.Translate,
                            onClick = {
                                LanguageManager.toggleLanguage()
                            }
                        ),
                        ElvanPopupMenuItem(
                            title = K.tharavuthalam.tr(),
                            icon = MaterialSymbols.Rounded.Storage,
                            onClick = {
                                isSettingsOpen = true
                            }
                        ),
                        ElvanPopupMenuItem(
                            title = K.kurithu.tr(),
                            icon = MaterialSymbols.Rounded.Info,
                            onClick = {
                                isSettingsOpen = true
                            }
                        )
                    )
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
                        scope.launch { scrollState.scrollToItem(0, 0) }
                        selectedTab = tab
                    }
                }
            )
        }
    ) {
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
                state = scrollState,
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
                                onClick = { isSettingsOpen = true },
                                colors = colors
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
}

