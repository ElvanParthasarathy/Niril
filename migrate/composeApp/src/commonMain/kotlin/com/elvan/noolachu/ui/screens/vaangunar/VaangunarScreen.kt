package com.elvan.noolachu.ui.screens.vaangunar

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
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.repository.VaangunarRepository
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
 * VaangunarScreen — Displays list of customers using VaangunarRepository.filteredMerchants.
 * Supports mode-aware customer cards: Coolie and Silk matching Flutter 1:1.
 */
@Composable
fun VaangunarScreen(
    onMerchantClick: (VaangunarTharavuru) -> Unit,
    modifier: Modifier = Modifier,
    scrollState: LazyListState = rememberLazyListState(),
    mode: AppMode = LocalAppMode.current,
    colors: ShellColors = rememberShellColors(),
    isSelectionMode: Boolean = false,
    selectedItemIds: Set<Long> = emptySet(),
    onToggleSelect: ((Long) -> Unit)? = null,
    onItemLongClick: ((Long) -> Unit)? = null
) {
    val merchants = VaangunarRepository.filteredMerchants
    val ff = LocalAppFontFamily.current

    if (merchants.isEmpty()) {
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
                            imageVector = MaterialSymbols.Rounded.Person,
                            contentDescription = null,
                            modifier = Modifier.size(36.dp),
                            tint = colors.textSecondary.copy(alpha = 0.6f)
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = K.vaangunargalIllai.tr().preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.textPrimary
                        )
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    Text(
                        text = K.vaangunaraiChaerkkavum.tr().preventBrokenLigatures(),
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

            itemsIndexed(merchants, key = { _, merchant -> merchant.id }) { index, merchant ->
                val isSelected = selectedItemIds.contains(merchant.id)
                val onCardClick: () -> Unit = {
                    if (isSelectionMode) {
                        onToggleSelect?.invoke(merchant.id)
                    } else {
                        onMerchantClick(merchant)
                    }
                }
                val onCardLongClick: () -> Unit = {
                    onItemLongClick?.invoke(merchant.id)
                }
                if (mode == AppMode.KOOLI) {
                    CoolieVaangunarCard(
                        index = index,
                        merchant = merchant,
                        onClick = onCardClick,
                        onLongClick = onCardLongClick,
                        colors = colors,
                        isSelectionMode = isSelectionMode,
                        isSelected = isSelected
                    )
                } else {
                    SilkVaangunarCard(
                        index = index,
                        merchant = merchant,
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
 * Coolie customer card: 28dp index badge, name, secondary name, town/city.
 * Exact 1:1 port of Flutter's _CoolieVaangunargalCard.
 */
@Composable
private fun CoolieVaangunarCard(
    index: Int,
    merchant: VaangunarTharavuru,
    onClick: () -> Unit,
    colors: ShellColors,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onLongClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val isDark = colors.isDark

    val primaryName = merchant.peyar[currentLang]
        ?: merchant.peyar["ta"]
        ?: merchant.peyar["en"]
        ?: merchant.peyar.values.firstOrNull()
        ?: ""

    val secondaryName = if (currentLang == "ta") merchant.peyar["en"] ?: "" else merchant.peyar["ta"] ?: ""

    val primaryCity = merchant.oor[currentLang]
        ?: merchant.oor["ta"]
        ?: merchant.oor["en"]
        ?: merchant.oor.values.firstOrNull()
        ?: ""

    val secondaryCity = if (currentLang == "ta") merchant.oor["en"] ?: "" else merchant.oor["ta"] ?: ""

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

            // Content Column
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = primaryName.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.2.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                if (secondaryName.isNotBlank() && secondaryName != primaryName) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondaryName.preventBrokenLigatures(),
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

                if (primaryCity.isNotBlank()) {
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = primaryCity.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.6.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (secondaryCity.isNotBlank() && secondaryCity != primaryCity) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondaryCity.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.8.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.24f) else Color.Black.copy(alpha = 0.24f)
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
 * Silk customer card: 28dp index badge, name, secondary name, town/city, GSTIN and phone.
 * Exact 1:1 port of Flutter's _PattuVaangunargalCard.
 */
@Composable
private fun SilkVaangunarCard(
    index: Int,
    merchant: VaangunarTharavuru,
    onClick: () -> Unit,
    colors: ShellColors,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onLongClick: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val isDark = colors.isDark

    val primaryName = merchant.peyar[currentLang]
        ?: merchant.peyar["ta"]
        ?: merchant.peyar["en"]
        ?: merchant.peyar.values.firstOrNull()
        ?: ""

    val secondaryName = if (currentLang == "ta") merchant.peyar["en"] ?: "" else merchant.peyar["ta"] ?: ""

    val primaryCity = merchant.oor[currentLang]
        ?: merchant.oor["ta"]
        ?: merchant.oor["en"]
        ?: merchant.oor.values.firstOrNull()
        ?: ""

    val secondaryCity = if (currentLang == "ta") merchant.oor["en"] ?: "" else merchant.oor["ta"] ?: ""

    val gstin = merchant.gstin.trim()
    val phone = merchant.tholaipaesi.trim()

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

            // Content Column
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = primaryName.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.2.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.textPrimary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                if (secondaryName.isNotBlank() && secondaryName != primaryName) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondaryName.preventBrokenLigatures(),
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

                if (primaryCity.isNotBlank()) {
                    Spacer(modifier = Modifier.height(3.dp))
                    Text(
                        text = primaryCity.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.6.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (secondaryCity.isNotBlank() && secondaryCity != primaryCity) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondaryCity.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.8.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.24f) else Color.Black.copy(alpha = 0.24f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (gstin.isNotBlank() || phone.isNotBlank()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    val gstinPhoneText = listOf(gstin, phone).filter { it.isNotBlank() }.joinToString(" · ")
                    Text(
                        text = gstinPhoneText,
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.6.sp,
                            color = if (isDark) Color.White.copy(alpha = 0.38f) else Color.Black.copy(alpha = 0.38f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}
