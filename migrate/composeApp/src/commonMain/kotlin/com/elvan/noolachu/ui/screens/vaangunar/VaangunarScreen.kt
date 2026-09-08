package com.elvan.noolachu.ui.screens.vaangunar

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
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * VaangunarScreen — Displays list of customers using VaangunarRepository.filteredMerchants.
 * Supports mode-aware merchant cards: Coolie (80dp) and Silk (100dp).
 */
@Composable
fun VaangunarScreen(
    onMerchantClick: (VaangunarTharavuru) -> Unit,
    modifier: Modifier = Modifier,
    scrollState: LazyListState = rememberLazyListState(),
    mode: AppMode = LocalAppMode.current,
    colors: ShellColors = rememberShellColors()
) {
    val merchants = VaangunarRepository.filteredMerchants
    val ff = LocalAppFontFamily.current

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
                start = Dimens.ContentPadding,
                end = Dimens.ContentPadding,
                bottom = Dimens.ContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            items(merchants, key = { it.id }) { merchant ->
                if (mode == AppMode.KOOLI) {
                    CoolieMerchantCard(
                        merchant = merchant,
                        onClick = { onMerchantClick(merchant) },
                        colors = colors
                    )
                } else {
                    SilkMerchantCard(
                        merchant = merchant,
                        onClick = { onMerchantClick(merchant) },
                        colors = colors
                    )
                }
            }
        }
    }
}

/**
 * Coolie merchant card (80dp height): circular avatar with initial letter, customer name, town/city (oor).
 */
@Composable
private fun CoolieMerchantCard(
    merchant: VaangunarTharavuru,
    onClick: () -> Unit,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val shape = RoundedCornerShape(20.dp)

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

    val initialLetter = primaryName.trim().firstOrNull()?.toString()?.uppercase() ?: "V"

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(80.dp)
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
            // Circular Avatar with initial letter
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(colors.accent.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = initialLetter,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.accent
                    )
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            // Merchant Name and City
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
                    Spacer(modifier = Modifier.height(1.dp))
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

                if (primaryCity.isNotBlank()) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = primaryCity.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.5.sp,
                            color = colors.textSecondary.copy(alpha = 0.8f)
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
 * Silk merchant card (100dp height): circular avatar, customer name, town/city, GSTIN badge (if present), phone (if present).
 */
@Composable
private fun SilkMerchantCard(
    merchant: VaangunarTharavuru,
    onClick: () -> Unit,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    val currentLang = LocalAppLanguage.current
    val shape = RoundedCornerShape(20.dp)

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

    val initialLetter = primaryName.trim().firstOrNull()?.toString()?.uppercase() ?: "V"
    val hasGstin = merchant.gstin.isNotBlank()
    val hasPhone = merchant.tholaipaesi.isNotBlank()

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
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Circular Avatar with initial letter
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(colors.accent.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = initialLetter,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = colors.accent
                    )
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            // Details Column
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
                    Text(
                        text = secondaryName.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.sp,
                            color = colors.textSecondary
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (primaryCity.isNotBlank()) {
                    Spacer(modifier = Modifier.height(1.dp))
                    Text(
                        text = primaryCity.preventBrokenLigatures(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 12.sp,
                            color = colors.textSecondary.copy(alpha = 0.75f)
                        ),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                if (hasGstin || hasPhone) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        if (hasGstin) {
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(colors.iconBg)
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(
                                    text = merchant.gstin,
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = colors.textSecondary
                                    )
                                )
                            }
                        }

                        if (hasPhone) {
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(colors.iconBg)
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(
                                    text = merchant.tholaipaesi,
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 10.5.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = colors.textSecondary
                                    )
                                )
                            }
                        }
                    }
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
