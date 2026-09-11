package com.elvan.noolachu.ui.screens.porul

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.repository.PorulRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.LocalAppLanguage
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.ElvanPothuAttai
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * PorulScreen — Displays list of items using PorulRepository.filteredItems.
 * Supports mode-aware item cards: Coolie and Silk matching Flutter 1:1.
 */
@Composable
fun PorulScreen(
    onItemClick: (PorulTharavuru) -> Unit,
    modifier: Modifier = Modifier,
    scrollState: LazyListState = rememberLazyListState(),
    mode: AppMode = LocalAppMode.current,
    colors: ShellColors = rememberShellColors(),
    isSelectionMode: Boolean = false,
    selectedItemIds: Set<Long> = emptySet(),
    onToggleSelect: ((Long) -> Unit)? = null,
    onItemLongClick: ((Long) -> Unit)? = null
) {
    val items = PorulRepository.filteredItems
    val ff = LocalAppFontFamily.current

    if (items.isEmpty()) {
        LazyColumn(
            state = scrollState,
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                bottom = Dimens.ContentPaddingBottom
            )
        ) {
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            item(key = "empty_state") {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 56.dp, bottom = 32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Box(
                        modifier = Modifier
                            .size(76.dp)
                            .clip(CircleShape)
                            .background(colors.iconBg),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = MaterialSymbols.Rounded.Inventory2,
                            contentDescription = null,
                            modifier = Modifier.size(36.dp),
                            tint = colors.textSecondary.copy(alpha = 0.6f)
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = K.porulgalIllai.tr().preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.textPrimary
                        )
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    Text(
                        text = K.porulaiChaerkkavum.tr().preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            color = colors.textSecondary
                        )
                    )
                }
            }
        }
    } else {
        LazyColumn(
            state = scrollState,
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                bottom = Dimens.ContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            itemsIndexed(items, key = { _, item -> item.id }) { index, item ->
                val isSelected = selectedItemIds.contains(item.id)
                val onCardClick: () -> Unit = {
                    if (isSelectionMode) {
                        onToggleSelect?.invoke(item.id)
                    } else {
                        onItemClick(item)
                    }
                }
                val onCardLongClick: () -> Unit = {
                    onItemLongClick?.invoke(item.id)
                }
                if (mode == AppMode.KOOLI) {
                    CooliePorulCard(
                        index = index,
                        porul = item,
                        onClick = onCardClick,
                        onLongClick = onCardLongClick,
                        colors = colors,
                        isSelectionMode = isSelectionMode,
                        isSelected = isSelected
                    )
                } else {
                    SilkPorulCard(
                        index = index,
                        porul = item,
                        onClick = onCardClick,
                        onLongClick = onCardLongClick,
                        colors = colors,
                        isSelectionMode = isSelectionMode,
                        isSelected = isSelected
                    )
                }
            }
        }
    }
}

/**
 * Coolie product card: 28dp index badge, product name (15.2sp bold), secondary name (13sp medium).
 * Exact 1:1 port of Flutter's _CooliePorulCard.
 */
@Composable
private fun CooliePorulCard(
    index: Int,
    porul: PorulTharavuru,
    onClick: () -> Unit,
    colors: ShellColors,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onLongClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val isDark = colors.isDark

    val primary = porul.porulPeyar[currentLang]
        ?: porul.porulPeyar["ta"]
        ?: porul.porulPeyar["en"]
        ?: porul.porulPeyar.values.firstOrNull()
        ?: ""

    val secondary = if (currentLang == "ta") porul.porulPeyar["en"] ?: "" else porul.porulPeyar["ta"] ?: ""

    ElvanPothuAttai(
        onClick = onClick,
        onLongClick = onLongClick,
        isSelected = isSelected,
        padding = PaddingValues(16.dp),
        borderRadius = 24.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top
        ) {
            // Index circle or Selection Checkbox (28x28)
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        if (isSelectionMode && isSelected) colors.accent
                        else if (isDark) Color.White.copy(alpha = 0.12f)
                        else Color.Black.copy(alpha = 0.08f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isSelectionMode) {
                    Icon(
                        imageVector = if (isSelected) MaterialSymbols.Rounded.Check else MaterialSymbols.Rounded.CheckBoxOutlineBlank,
                        contentDescription = null,
                        tint = if (isSelected) Color.White else colors.textSecondary,
                        modifier = Modifier.size(16.dp)
                    )
                } else {
                    Text(
                        text = (index + 1).toString().padStart(2, '0'),
                        style = TextStyle(
                            fontFamily = ff,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 11.2.sp,
                            color = if (isDark) Color.White else Color.Black,
                            lineHeight = 11.2.sp
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Product name column
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = primary.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.2.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                if (secondary.isNotBlank() && secondary != primary) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondary.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium,
                            color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

/**
 * Silk product card: 28dp index badge, product name, secondary name, Row 2 (HSN + GST % + Rate).
 * Exact 1:1 port of Flutter's _PattuPorulCard.
 */
@Composable
private fun SilkPorulCard(
    index: Int,
    porul: PorulTharavuru,
    onClick: () -> Unit,
    colors: ShellColors,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onLongClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val isDark = colors.isDark

    val primary = porul.porulPeyar[currentLang]
        ?: porul.porulPeyar["ta"]
        ?: porul.porulPeyar["en"]
        ?: porul.porulPeyar.values.firstOrNull()
        ?: ""

    val secondary = if (currentLang == "ta") porul.porulPeyar["en"] ?: "" else porul.porulPeyar["ta"] ?: ""

    ElvanPothuAttai(
        onClick = onClick,
        onLongClick = onLongClick,
        isSelected = isSelected,
        padding = PaddingValues(16.dp),
        borderRadius = 24.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top
        ) {
            // Index circle or Selection Checkbox (28x28)
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        if (isSelectionMode && isSelected) colors.accent
                        else if (isDark) Color.White.copy(alpha = 0.12f)
                        else Color.Black.copy(alpha = 0.08f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isSelectionMode) {
                    Icon(
                        imageVector = if (isSelected) MaterialSymbols.Rounded.Check else MaterialSymbols.Rounded.CheckBoxOutlineBlank,
                        contentDescription = null,
                        tint = if (isSelected) Color.White else colors.textSecondary,
                        modifier = Modifier.size(16.dp)
                    )
                } else {
                    Text(
                        text = (index + 1).toString().padStart(2, '0'),
                        style = TextStyle(
                            fontFamily = ff,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 11.2.sp,
                            color = if (isDark) Color.White else Color.Black,
                            lineHeight = 11.2.sp
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Product details Column
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = primary.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.2.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                if (secondary.isNotBlank() && secondary != primary) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondary.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium,
                            color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                Spacer(modifier = Modifier.height(6.dp))

                // Row 2: HSN + Tax % + Rate
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (porul.hsnCode.isNotBlank()) {
                        Text(
                            text = "HSN: ${porul.hsnCode}",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 13.6.sp,
                                color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
                            )
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                    }

                    val gstRate = if (porul.variVeetham % 1.0 == 0.0) porul.variVeetham.toLong().toString() else porul.variVeetham.toString()
                    Text(
                        text = "GST: $gstRate%",
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.6.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
                        )
                    )

                    Spacer(modifier = Modifier.weight(1f))

                    if (porul.vilai > 0.0) {
                        val formatted = if (porul.vilai % 1.0 == 0.0) porul.vilai.toLong().toString() else porul.vilai.toString()
                        Text(
                            text = "₹$formatted",
                            style = TextStyle(
                                fontFamily = ff,
                                fontWeight = FontWeight.ExtraBold,
                                fontSize = 15.sp,
                                color = colors.accent
                            )
                        )
                    }
                }
            }
        }
    }
}
