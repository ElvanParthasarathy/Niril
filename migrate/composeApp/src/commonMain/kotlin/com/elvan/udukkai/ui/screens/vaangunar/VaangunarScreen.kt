package com.elvan.udukkai.ui.screens.vaangunar

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.udukkai.core.mode.AppMode
import com.elvan.udukkai.core.mode.LocalAppMode
import com.elvan.udukkai.data.model.VaangunarTharavuru
import com.elvan.udukkai.data.repository.VaangunarRepository
import com.elvan.udukkai.data.settings.NiruvanaTharavugalRepository
import com.elvan.udukkai.localization.K
import com.elvan.udukkai.localization.tr
import com.elvan.udukkai.theme.Dimens
import com.elvan.udukkai.theme.LocalAppFontFamily
import com.elvan.udukkai.theme.ShellColors
import com.elvan.udukkai.theme.preventBrokenLigatures
import com.elvan.udukkai.theme.rememberShellColors
import com.elvan.udukkai.ui.components.ElvanPothuAttai
import com.elvan.udukkai.ui.components.shell.ElvanActionSheet
import com.elvan.udukkai.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.udukkai.ui.navigation.MaterialSymbols

/**
 * Resolves a field dynamically based on bilingual settings, matching React's `getDynamicField` 1:1.
 * - In Coolie: isBilingual is always true.
 * - In Silk: isBilingual follows profile.iruMozhi.
 * - If single-language (!isBilingual) and !isPrimary: returns "" (shielded).
 * - If single-language and isPrimary, but primary is empty: falls back to secondary so customer is not blank.
 */
private fun getDynamicField(
    map: Map<String, String>,
    isPrimary: Boolean,
    isBilingual: Boolean,
    primaryLang: String,
    secondaryLang: String
): String {
    if (!isBilingual && !isPrimary) {
        return ""
    }
    val targetLang = if (isPrimary) primaryLang else secondaryLang
    val exactVal = map[targetLang]?.trim()
    if (!exactVal.isNullOrEmpty()) {
        return exactVal
    }

    // Safety fallback for single-language mode:
    if (!isBilingual && isPrimary) {
        val fallbackVal = map[secondaryLang]?.trim()
        if (!fallbackVal.isNullOrEmpty()) {
            return fallbackVal
        }
    }

    if (isPrimary) {
        return map.values.firstOrNull { it.isNotBlank() } ?: ""
    }
    return ""
}

/**
 * VaangunarScreen — Displays list of customers using VaangunarRepository.filteredMerchants.
 * Supports mode-aware customer cards: Coolie and Silk with 100% React visual and behavioral parity.
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
    var merchantToDelete by remember { mutableStateOf<VaangunarTharavuru?>(null) }

    if (merchants.isEmpty()) {
        LazyColumn(
            state = scrollState,
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = Dimens.ContentPadding,
                end = Dimens.ContentPadding,
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
                        text = K.noCustomersYet.tr().preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = colors.textPrimary
                        )
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    Text(
                        text = K.addFirstCustomer.tr().preventBrokenLigatures(),
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
                start = Dimens.ContentPadding,
                end = Dimens.ContentPadding,
                bottom = Dimens.ContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(Dimens.ItemSpacing)
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
                        isSelected = isSelected,
                        onDeleteSingle = { merchantToDelete = merchant }
                    )
                } else {
                    SilkVaangunarCard(
                        index = index,
                        merchant = merchant,
                        onClick = onCardClick,
                        onLongClick = onCardLongClick,
                        colors = colors,
                        isSelectionMode = isSelectionMode,
                        isSelected = isSelected,
                        onDeleteSingle = { merchantToDelete = merchant }
                    )
                }
            }
        }
    }

    if (merchantToDelete != null) {
        ElvanActionSheet(
            title = K.delete.tr(),
            cancelText = K.cancelBtn.tr(),
            confirmText = K.deleteBtn.tr(),
            confirmColor = Color(0xFFBA1A1A),
            onConfirm = {
                merchantToDelete?.let {
                    VaangunarRepository.delete(it.id, mode)
                }
                merchantToDelete = null
            },
            onDismissRequest = {
                merchantToDelete = null
            },
            colors = colors
        )
    }
}


/**
 * Coolie customer card: 28dp index badge, name, secondary name, town/city.
 * Exact 1:1 port of React's CoolieMerchants.tsx renderCard.
 */
@Composable
private fun CoolieVaangunarCard(
    index: Int,
    merchant: VaangunarTharavuru,
    onClick: () -> Unit,
    colors: ShellColors,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onLongClick: (() -> Unit)? = null,
    onDeleteSingle: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val profile = NiruvanaTharavugalRepository.getProfile(AppMode.KOOLI)
    val isBilingual = true // Coolie mode is ALWAYS bilingual
    val primaryLang = profile.mudhanMozhi.ifEmpty { "ta" }
    val secondaryLang = profile.thunaiMozhi.ifEmpty { "en" }

    val primaryName = getDynamicField(merchant.peyar, isPrimary = true, isBilingual = isBilingual, primaryLang, secondaryLang)
        .ifEmpty { merchant.peyar.values.firstOrNull() ?: "-" }
    val secondaryName = getDynamicField(merchant.peyar, isPrimary = false, isBilingual = isBilingual, primaryLang, secondaryLang)

    val primaryCity = getDynamicField(merchant.oor, isPrimary = true, isBilingual = isBilingual, primaryLang, secondaryLang)
    val secondaryCity = getDynamicField(merchant.oor, isPrimary = false, isBilingual = isBilingual, primaryLang, secondaryLang)

    Box(
        modifier = Modifier.fillMaxWidth(),
        contentAlignment = Alignment.CenterStart
    ) {
        ElvanPothuAttai(
            onClick = onClick,
            onLongClick = onLongClick,
            isSelected = isSelectionMode && isSelected,
            padding = PaddingValues(
                horizontal = Dimens.CardPaddingHorizontal,
                vertical = Dimens.CardPaddingVertical
            ),
            borderRadius = Dimens.CardRadius
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top
            ) {
                // Index circle badge or Checkbox (28x28) matching React
                if (!isSelectionMode) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(CircleShape)
                            .background(
                                if (isDark) Color.White.copy(alpha = 0.12f)
                                else Color.Black.copy(alpha = 0.08f)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
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
                } else {
                    Box(
                        modifier = Modifier.size(28.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (isSelected) MaterialSymbols.Rounded.CheckBox else MaterialSymbols.Rounded.CheckBoxOutlineBlank,
                            contentDescription = null,
                            tint = if (isSelected) colors.accent else colors.textSecondary,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.width(12.dp))

                // Content Column
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.Center
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
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
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f, fill = false)
                        )
                        if (isSelectionMode) {
                            Spacer(modifier = Modifier.width(36.dp))
                        }
                    }

                    if (secondaryName.isNotBlank() && secondaryName != primaryName) {
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = secondaryName.preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = colors.textSecondary
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }

                    if (primaryCity.isNotBlank() || secondaryCity.isNotBlank()) {
                        Spacer(modifier = Modifier.height(4.dp))
                        if (primaryCity.isNotBlank()) {
                            Text(
                                text = primaryCity.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 13.6.sp,
                                    color = colors.textSecondary
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
                                    color = colors.textSecondary.copy(alpha = 0.8f)
                                ),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }
                }
            }
        }

        // Single delete Trash icon on right in selection mode, matching React
        if (isSelectionMode && onDeleteSingle != null) {
            IconButton(
                onClick = onDeleteSingle,
                modifier = Modifier
                    .align(Alignment.CenterEnd)
                    .padding(end = 12.dp)
                    .size(36.dp)
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.Delete,
                    contentDescription = K.delete.tr(),
                    tint = Color(0xFFEF4444),
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

/**
 * Silk customer card: 28dp index badge, name, secondary name (if bilingual),
 * inline town/city with bullet separator (`Primary • Secondary`), and GSTIN.
 * Exact 1:1 port of React's Vanigargal.tsx renderCard.
 */
@Composable
private fun SilkVaangunarCard(
    index: Int,
    merchant: VaangunarTharavuru,
    onClick: () -> Unit,
    colors: ShellColors,
    isSelectionMode: Boolean = false,
    isSelected: Boolean = false,
    onLongClick: (() -> Unit)? = null,
    onDeleteSingle: (() -> Unit)? = null
) {
    val ff = LocalAppFontFamily.current
    val isDark = colors.isDark

    val profile = NiruvanaTharavugalRepository.getProfile(AppMode.PATTU)
    val isBilingual = profile.iruMozhi
    val primaryLang = profile.mudhanMozhi.ifEmpty { "ta" }
    val secondaryLang = profile.thunaiMozhi.ifEmpty { "en" }

    val primaryName = getDynamicField(merchant.peyar, isPrimary = true, isBilingual = isBilingual, primaryLang, secondaryLang)
        .ifEmpty { merchant.peyar.values.firstOrNull() ?: "-" }
    val secondaryName = getDynamicField(merchant.peyar, isPrimary = false, isBilingual = isBilingual, primaryLang, secondaryLang)

    val primaryCity = getDynamicField(merchant.oor, isPrimary = true, isBilingual = isBilingual, primaryLang, secondaryLang)
    val secondaryCity = getDynamicField(merchant.oor, isPrimary = false, isBilingual = isBilingual, primaryLang, secondaryLang)

    val gstin = merchant.gstin.trim()

    Box(
        modifier = Modifier.fillMaxWidth(),
        contentAlignment = Alignment.CenterStart
    ) {
        ElvanPothuAttai(
            onClick = onClick,
            onLongClick = onLongClick,
            isSelected = isSelectionMode && isSelected,
            padding = PaddingValues(
                horizontal = Dimens.CardPaddingHorizontal,
                vertical = Dimens.CardPaddingVertical
            ),
            borderRadius = Dimens.CardRadius
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top
            ) {
                // Index circle badge or Checkbox (28x28) matching React
                if (!isSelectionMode) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(CircleShape)
                            .background(
                                if (isDark) Color.White.copy(alpha = 0.12f)
                                else Color.Black.copy(alpha = 0.08f)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
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
                } else {
                    Box(
                        modifier = Modifier.size(28.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (isSelected) MaterialSymbols.Rounded.CheckBox else MaterialSymbols.Rounded.CheckBoxOutlineBlank,
                            contentDescription = null,
                            tint = if (isSelected) colors.accent else colors.textSecondary,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.width(12.dp))

                // Content Column
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.Center
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
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
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f, fill = false)
                        )
                        if (isSelectionMode) {
                            Spacer(modifier = Modifier.width(36.dp))
                        }
                    }

                    // Secondary Name - ONLY when bilingual mode is enabled in Silk profile
                    if (isBilingual && secondaryName.isNotBlank() && secondaryName != primaryName) {
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = secondaryName.preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = colors.textSecondary
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }

                    // City / Oor - Inline bullet format matching React: `Primary • Secondary`
                    val cityText = if (isBilingual && secondaryCity.isNotBlank() && secondaryCity != primaryCity) {
                        if (primaryCity.isNotBlank()) "$primaryCity • $secondaryCity" else secondaryCity
                    } else {
                        primaryCity
                    }

                    if (cityText.isNotBlank() || gstin.isNotBlank()) {
                        Spacer(modifier = Modifier.height(4.dp))
                        if (cityText.isNotBlank()) {
                            Text(
                                text = cityText.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 13.6.sp,
                                    color = colors.textSecondary
                                ),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }

                        // GSTIN label with explicit `GSTIN: ` prefix matching React
                        if (gstin.isNotBlank()) {
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = "GSTIN: $gstin",
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.8.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = colors.textSecondary
                                ),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }
                }
            }
        }

        // Single delete Trash icon on right in selection mode, matching React
        if (isSelectionMode && onDeleteSingle != null) {
            IconButton(
                onClick = onDeleteSingle,
                modifier = Modifier
                    .align(Alignment.CenterEnd)
                    .padding(end = 12.dp)
                    .size(36.dp)
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.Delete,
                    contentDescription = K.delete.tr(),
                    tint = Color(0xFFEF4444),
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}
