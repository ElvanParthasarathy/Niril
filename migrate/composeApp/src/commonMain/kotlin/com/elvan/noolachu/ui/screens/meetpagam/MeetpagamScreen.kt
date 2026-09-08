package com.elvan.noolachu.ui.screens.meetpagam

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.ripple
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru
import com.elvan.noolachu.data.repository.PorulRepository
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
import com.elvan.noolachu.ui.components.shell.ElvanSnackbar
import com.elvan.noolachu.ui.components.shell.ElvanSubShell
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * MeetpagamScreen — Recycle Bin Screen ported 1:1 from Flutter's `MeetpagamThirai`.
 * Mode-aware: displays soft-deleted items and merchants with restore / permanent delete capabilities.
 */
@Composable
fun MeetpagamScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val mode = LocalAppMode.current
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current
    val restoreSuccessMsg = K.meeteduppuVetri.tr()

    // Auto-purge items older than 30 days on launch
    LaunchedEffect(mode) {
        PorulRepository.purgeExpired(days = 30, mode = mode)
        VaangunarRepository.purgeExpired(days = 30, mode = mode)
        PorulRepository.loadDeleted(mode)
        VaangunarRepository.loadDeleted(mode)
    }

    val deletedPorulgal = PorulRepository.deletedItems
    val deletedVaangunargal = VaangunarRepository.deletedMerchants

    var itemToDeletePermanently by remember { mutableStateOf<PorulTharavuru?>(null) }
    var merchantToDeletePermanently by remember { mutableStateOf<VaangunarTharavuru?>(null) }

    AppBackHandler(enabled = true) {
        onBack()
    }

    val scrollState = rememberLazyListState()

    ElvanSubShell(
        title = K.meetpagam.tr(),
        onBack = onBack,
        scrollState = scrollState,
        hasActions = false
    ) {
        LazyColumn(
            state = scrollState,
            modifier = modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                bottom = Dimens.SubpageContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            if (deletedPorulgal.isEmpty() && deletedVaangunargal.isEmpty()) {
                item(key = "empty_state") {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 80.dp),
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
                                imageVector = MaterialSymbols.Rounded.Delete,
                                contentDescription = null,
                                modifier = Modifier.size(36.dp),
                                tint = colors.textSecondary.copy(alpha = 0.5f)
                            )
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = K.meetpagamKaaliyanadhu.tr().preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Medium,
                                color = colors.textSecondary
                            )
                        )
                    }
                }
            } else {
                // 30-Day Auto-Purge Notice Banner
                item(key = "auto_delete_banner") {
                    MeetpagamAutoPurgeBanner(isDark = isDark)
                }

                // Section: Deleted Products
                if (deletedPorulgal.isNotEmpty()) {
                    item(key = "header_products") {
                        MeetpagamSectionHeader(
                            title = K.azhikkappattaPorulgal.tr(),
                            count = deletedPorulgal.size,
                            colors = colors
                        )
                    }

                    items(deletedPorulgal, key = { "porul_${it.id}" }) { porul ->
                        val currentLang = LocalAppLanguage.current
                        val primaryText = porul.porulPeyar[currentLang]
                            ?: porul.porulPeyar["ta"]
                            ?: porul.porulPeyar["en"]
                            ?: porul.porulPeyar.values.firstOrNull()
                            ?: ""
                        val secondaryText = if (currentLang == "ta") porul.porulPeyar["en"] else porul.porulPeyar["ta"]

                        MeetpagamCard(
                            primaryText = primaryText,
                            secondaryText = secondaryText,
                            icon = MaterialSymbols.Rounded.Inventory2,
                            colors = colors,
                            onRestore = {
                                val success = PorulRepository.restore(porul.id, mode)
                                if (success) {
                                    ElvanSnackbar.show(restoreSuccessMsg)
                                }
                            },
                            onPermanentDelete = {
                                itemToDeletePermanently = porul
                            }
                        )
                    }
                }

                // Section: Deleted Merchants
                if (deletedVaangunargal.isNotEmpty()) {
                    item(key = "header_merchants") {
                        MeetpagamSectionHeader(
                            title = K.azhikkappattaVaangunargal.tr(),
                            count = deletedVaangunargal.size,
                            colors = colors
                        )
                    }

                    items(deletedVaangunargal, key = { "merchant_${it.id}" }) { merchant ->
                        val currentLang = LocalAppLanguage.current
                        val primaryText = merchant.peyar[currentLang]
                            ?: merchant.peyar["ta"]
                            ?: merchant.peyar["en"]
                            ?: merchant.peyar.values.firstOrNull()
                            ?: ""
                        val city = merchant.oor[currentLang] ?: merchant.oor.values.firstOrNull()

                        MeetpagamCard(
                            primaryText = primaryText,
                            secondaryText = city,
                            icon = MaterialSymbols.Rounded.Person,
                            colors = colors,
                            onRestore = {
                                val success = VaangunarRepository.restore(merchant.id, mode)
                                if (success) {
                                    ElvanSnackbar.show(restoreSuccessMsg)
                                }
                            },
                            onPermanentDelete = {
                                merchantToDeletePermanently = merchant
                            }
                        )
                    }
                }
            }
        }
    }

    // Confirmation dialog for permanent delete (Product)
    itemToDeletePermanently?.let { item ->
        AlertDialog(
            onDismissRequest = { itemToDeletePermanently = null },
            title = {
                Text(
                    text = K.nirandharaAzhippuUrudhi.tr().preventBrokenLigatures(),
                    style = TextStyle(fontFamily = ff, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        PorulRepository.permanentDelete(item.id, mode)
                        itemToDeletePermanently = null
                    }
                ) {
                    Text(
                        text = K.neekkuPtn.tr(),
                        color = Color(0xFFBA1A1A),
                        fontWeight = FontWeight.Bold
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { itemToDeletePermanently = null }) {
                    Text(text = K.kaividuPtn.tr())
                }
            }
        )
    }

    // Confirmation dialog for permanent delete (Merchant)
    merchantToDeletePermanently?.let { merchant ->
        AlertDialog(
            onDismissRequest = { merchantToDeletePermanently = null },
            title = {
                Text(
                    text = K.nirandharaAzhippuUrudhi.tr().preventBrokenLigatures(),
                    style = TextStyle(fontFamily = ff, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        VaangunarRepository.permanentDelete(merchant.id, mode)
                        merchantToDeletePermanently = null
                    }
                ) {
                    Text(
                        text = K.neekkuPtn.tr(),
                        color = Color(0xFFBA1A1A),
                        fontWeight = FontWeight.Bold
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { merchantToDeletePermanently = null }) {
                    Text(text = K.kaividuPtn.tr())
                }
            }
        )
    }
}

@Composable
private fun MeetpagamAutoPurgeBanner(isDark: Boolean) {
    val ff = LocalAppFontFamily.current
    val amberBg = if (isDark) Color(0xFFF59E0B).copy(alpha = 0.08f) else Color(0xFFF59E0B).copy(alpha = 0.10f)
    val amberBorder = Color(0xFFF59E0B).copy(alpha = 0.20f)
    val amberText = if (isDark) Color(0xFFFCD34D) else Color(0xFFB45309)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(amberBg, RoundedCornerShape(12.dp))
            .border(0.5.dp, amberBorder, RoundedCornerShape(12.dp))
            .padding(horizontal = 14.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = MaterialSymbols.Rounded.Schedule,
            contentDescription = null,
            modifier = Modifier.size(16.dp),
            tint = amberText
        )
        Spacer(modifier = Modifier.width(10.dp))
        Text(
            text = K.meetpagam30Naal.tr().preventBrokenLigatures(),
            style = TextStyle(
                fontFamily = ff,
                fontSize = 12.sp,
                color = amberText
            ),
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
private fun MeetpagamSectionHeader(
    title: String,
    count: Int,
    colors: ShellColors
) {
    val ff = LocalAppFontFamily.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 8.dp, bottom = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title.preventBrokenLigatures(),
            style = TextStyle(
                fontFamily = ff,
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 0.5.sp,
                color = colors.textSecondary
            )
        )
        Spacer(modifier = Modifier.width(8.dp))
        Box(
            modifier = Modifier
                .clip(CircleShape)
                .background(colors.iconBg)
                .padding(horizontal = 8.dp, vertical = 2.dp)
        ) {
            Text(
                text = count.toString(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = colors.textSecondary
                )
            )
        }
    }
}

@Composable
private fun MeetpagamCard(
    primaryText: String,
    secondaryText: String?,
    icon: ImageVector,
    colors: ShellColors,
    onRestore: () -> Unit,
    onPermanentDelete: () -> Unit
) {
    val ff = LocalAppFontFamily.current

    ElvanPothuAttai(
        padding = PaddingValues(16.dp),
        borderRadius = 20.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(colors.iconBg),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = colors.textSecondary
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = primaryText.preventBrokenLigatures(),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = colors.textPrimary
                    )
                )
                if (!secondaryText.isNullOrEmpty()) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = secondaryText.preventBrokenLigatures(),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.sp,
                            color = colors.textSecondary
                        )
                    )
                }
            }

            Spacer(modifier = Modifier.width(8.dp))

            // Restore Action Button
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(bounded = true),
                        onClick = onRestore
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.Restore,
                    contentDescription = K.meeteduppuVetri.tr(),
                    tint = Color(0xFF1B6B4F),
                    modifier = Modifier.size(20.dp)
                )
            }

            Spacer(modifier = Modifier.width(4.dp))

            // Permanent Delete Action Button
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = ripple(bounded = true),
                        onClick = onPermanentDelete
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.DeleteForever,
                    contentDescription = K.nirandharaAzhippu.tr(),
                    tint = Color(0xFFBA1A1A).copy(alpha = 0.7f),
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}
