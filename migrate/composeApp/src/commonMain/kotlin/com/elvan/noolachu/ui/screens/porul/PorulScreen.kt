package com.elvan.noolachu.ui.screens.porul

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
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
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * PorulScreen — Displays list of items using PorulRepository.filteredItems.
 * Supports mode-aware item cards: Coolie (72dp) and Silk (100dp).
 */
@Composable
fun PorulScreen(
    onItemClick: (PorulTharavuru) -> Unit,
    modifier: Modifier = Modifier,
    scrollState: LazyListState = rememberLazyListState(),
    mode: AppMode = LocalAppMode.current,
    colors: ShellColors = rememberShellColors()
) {
    val items = PorulRepository.filteredItems
    val ff = LocalAppFontFamily.current

    if (items.isEmpty()) {
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
                start = Dimens.ContentPadding,
                end = Dimens.ContentPadding,
                bottom = Dimens.ContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            items(items, key = { it.id }) { item ->
                if (mode == AppMode.KOOLI) {
                    CoolieItemCard(
                        item = item,
                        onClick = { onItemClick(item) },
                        colors = colors
                    )
                } else {
                    SilkItemCard(
                        item = item,
                        onClick = { onItemClick(item) },
                        colors = colors
                    )
                }
            }
        }
    }
}

/**
 * Coolie item card (72dp height): item name, subtle wage glyph, clean border and surface styling.
 */
@Composable
private fun CoolieItemCard(
    item: PorulTharavuru,
    onClick: () -> Unit,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val shape = RoundedCornerShape(20.dp)

    val primaryName = item.porulPeyar[currentLang]
        ?: item.porulPeyar["ta"]
        ?: item.porulPeyar["en"]
        ?: item.porulPeyar.values.firstOrNull()
        ?: ""

    val secondaryName = if (currentLang == "ta") item.porulPeyar["en"] ?: "" else item.porulPeyar["ta"] ?: ""

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(72.dp)
            .clip(shape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ShellDefaults.ripple(colors, bounded = true),
                onClick = onClick
            ),
        shape = shape,
        color = colors.surface,
        border = BorderStroke(0.5.dp, colors.border),
        shadowElevation = 0.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Subtle wage glyph
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(colors.accent.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.Handyman,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = colors.accent
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            // Item Name
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = primaryName.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.sp,
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
                            fontSize = 12.5.sp,
                            color = colors.textSecondary
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            Icon(
                imageVector = MaterialSymbols.Rounded.ChevronRight,
                contentDescription = null,
                tint = colors.textSecondary.copy(alpha = 0.4f),
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

/**
 * Silk item card (100dp height): item name, HSN badge, GST % badge, price, unit (/ Nos or / kg).
 */
@Composable
private fun SilkItemCard(
    item: PorulTharavuru,
    onClick: () -> Unit,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val shape = RoundedCornerShape(20.dp)

    val primaryName = item.porulPeyar[currentLang]
        ?: item.porulPeyar["ta"]
        ?: item.porulPeyar["en"]
        ?: item.porulPeyar.values.firstOrNull()
        ?: ""

    val secondaryName = if (currentLang == "ta") item.porulPeyar["en"] ?: "" else item.porulPeyar["ta"] ?: ""

    val priceDisplay = if (item.vilai > 0.0) {
        val formatted = if (item.vilai % 1.0 == 0.0) item.vilai.toLong().toString() else item.vilai.toString()
        "₹$formatted"
    } else ""

    val unitDisplay = if (item.alagu.isNotBlank()) {
        "/ ${item.alagu}"
    } else if (item.alavuVagai == "weight") {
        "/ kg"
    } else {
        "/ Nos"
    }

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(100.dp)
            .clip(shape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ShellDefaults.ripple(colors, bounded = true),
                onClick = onClick
            ),
        shape = shape,
        color = colors.surface,
        border = BorderStroke(0.5.dp, colors.border),
        shadowElevation = 0.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Row 1: Names & Price
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column(modifier = Modifier.weight(1f)) {
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
                        Text(
                            text = secondaryName.preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 12.5.sp,
                                color = colors.textSecondary
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                if (priceDisplay.isNotBlank()) {
                    Row(
                        verticalAlignment = Alignment.Bottom,
                        modifier = Modifier.padding(start = 8.dp)
                    ) {
                        Text(
                            text = priceDisplay,
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = colors.accent
                            )
                        )
                        Spacer(modifier = Modifier.width(3.dp))
                        Text(
                            text = unitDisplay,
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 11.5.sp,
                                color = colors.textSecondary
                            ),
                            modifier = Modifier.padding(bottom = 1.dp)
                        )
                    }
                }
            }

            // Row 2: Badges (HSN badge, GST % badge)
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                if (item.hsnCode.isNotBlank()) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(colors.iconBg)
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text(
                            text = "HSN: ${item.hsnCode}",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Medium,
                                color = colors.textSecondary
                            )
                        )
                    }
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(colors.iconBg)
                        .padding(horizontal = 8.dp, vertical = 3.dp)
                ) {
                    val rate = if (item.variVeetham % 1.0 == 0.0) item.variVeetham.toLong().toString() else item.variVeetham.toString()
                    Text(
                        text = "GST: $rate%",
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                            color = colors.textSecondary
                        )
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                Icon(
                    imageVector = MaterialSymbols.Rounded.ChevronRight,
                    contentDescription = null,
                    tint = colors.textSecondary.copy(alpha = 0.4f),
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}
