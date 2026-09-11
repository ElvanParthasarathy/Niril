package com.elvan.noolachu.ui.screens.paarvai

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.core.platform.AppBackHandler
import com.elvan.noolachu.core.utils.CurrencyUtils
import com.elvan.noolachu.core.utils.DateUtils
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.localization.AchuMozhiManager
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight

/**
 * Invoice View Screen (பட்டியல் பார்வை)
 * Ported 1:1 from Flutter's pattu_pattiyal_paarvai.dart & kooli_pattiyal_paarvai.dart.
 */
@Composable
fun PattiyalPaarvaiScreen(
    invoice: PattiyalTharavuru,
    onBack: () -> Unit,
    onEdit: () -> Unit,
    onPrint: (() -> Unit)? = null
) {
    val currentMode = LocalAppMode.current
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    val billingConfig = AchuMozhiManager.getConfig(currentMode)
    val isBilingual = if (currentMode == AppMode.KOOLI) true else billingConfig.isBilingual
    val primaryLang = billingConfig.primaryLanguage.code
    val secondaryLang = billingConfig.secondaryLanguage.code

    val customerName = invoice.vaangunarPeyar[primaryLang]
        ?: invoice.vaangunarPeyar[secondaryLang]
        ?: invoice.vaangunarPeyar.values.firstOrNull().orEmpty().ifEmpty { "-" }

    val secondaryCustomerName = if (isBilingual) (invoice.vaangunarPeyar[secondaryLang] ?: "") else ""

    val customerTown = invoice.vaangunarMunvari[primaryLang]
        ?: invoice.vaangunarMunvari[secondaryLang]
        ?: invoice.vaangunarMunvari.values.firstOrNull().orEmpty()

    AppBackHandler(enabled = true) {
        onBack()
    }

    val scrollState = rememberLazyListState()

    ElvanPaarvaiOadu(
        title = "${K.pattiyal.tr()} #${invoice.patrucheettuEn}",
        onBack = onBack,
        scrollState = scrollState,
        onEdit = onEdit,
        onPrint = onPrint
    ) {
        LazyColumn(
            state = scrollState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                bottom = Dimens.SubpageContentPaddingBottom
            ),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // One UI Collapsible Header top spacer
            item(key = "top_spacer") {
                Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
            }

            // Customer & Date Header Card
            item(key = "header_card") {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(20.dp))
                        .background(if (isDark) Color.White.copy(alpha = 0.05f) else Color.Black.copy(alpha = 0.03f))
                        .border(
                            width = 1.dp,
                            color = if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.06f),
                            shape = RoundedCornerShape(20.dp)
                        )
                        .padding(24.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = customerName.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 20.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = colors.textPrimary,
                                    letterSpacing = (-0.2).sp
                                )
                            )
                            if (isBilingual && secondaryCustomerName.isNotBlank() && secondaryCustomerName != customerName) {
                                Spacer(modifier = Modifier.height(2.dp))
                                Text(
                                    text = secondaryCustomerName.preventBrokenLigatures(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = if (isDark) Color.White.copy(alpha = 0.54f) else Color.Black.copy(alpha = 0.54f)
                                    )
                                )
                            }
                            if (customerTown.isNotBlank()) {
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = customerTown.preventBrokenLigatures(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 14.sp,
                                        color = colors.textSecondary
                                    )
                                )
                            }
                        }

                        Spacer(modifier = Modifier.width(16.dp))

                        Column(horizontalAlignment = Alignment.End) {
                            Text(
                                text = DateUtils.formatEpochMillis(invoice.pattiyalNaal),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 15.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    color = colors.textPrimary
                                )
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(
                                        if (currentMode == AppMode.PATTU) {
                                            if (isDark) Color(0xFF1E3A5F) else Color(0xFFE0EDFE)
                                        } else {
                                            if (isDark) Color(0xFF3B1E54) else Color(0xFFF3E8FF)
                                        }
                                    )
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = if (currentMode == AppMode.PATTU) K.nirilPattu.tr() else K.nirilKooli.tr(),
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = if (currentMode == AppMode.PATTU) {
                                            if (isDark) Color(0xFF93C5FD) else Color(0xFF1D4ED8)
                                        } else {
                                            if (isDark) Color(0xFFC4B5FD) else Color(0xFF7C3AED)
                                        }
                                    )
                                )
                            }
                        }
                    }
                }
            }

            // Kooli Specific Additional Charges Card
            if (currentMode == AppMode.KOOLI && (invoice.setharamGrams > 0 || invoice.thabaalThogai > 0 || invoice.ahimsaPattuThogai > 0)) {
                item(key = "kooli_charges_card") {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (isDark) Color.White.copy(alpha = 0.04f) else Color.Black.copy(alpha = 0.025f))
                            .border(
                                width = 1.dp,
                                color = if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.06f),
                                shape = RoundedCornerShape(16.dp)
                            )
                            .padding(18.dp)
                    ) {
                        Column(
                            modifier = Modifier.fillMaxWidth(),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            if (invoice.setharamGrams > 0) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = "${K.chaedhaaram.tr()} (Grams)",
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textSecondary)
                                    )
                                    Text(
                                        text = "${invoice.setharamGrams} g",
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = colors.textPrimary)
                                    )
                                }
                            }
                            if (invoice.thabaalThogai > 0) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = K.koriyarKattanam.tr(),
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textSecondary)
                                    )
                                    Text(
                                        text = CurrencyUtils.formatInr(invoice.thabaalThogai),
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = colors.textPrimary)
                                    )
                                }
                            }
                            if (invoice.ahimsaPattuThogai > 0) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = "அகிம்சா பட்டு",
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, color = colors.textSecondary)
                                    )
                                    Text(
                                        text = CurrencyUtils.formatInr(invoice.ahimsaPattuThogai),
                                        style = TextStyle(fontFamily = ff, fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = colors.textPrimary)
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // Total Amount Card
            item(key = "total_card") {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(20.dp))
                        .background(if (isDark) Color(0xFF1B6B4F).copy(alpha = 0.2f) else Color(0xFFE8F5E9))
                        .border(
                            width = 1.dp,
                            color = if (isDark) Color(0xFF1B6B4F).copy(alpha = 0.4f) else Color(0xFFA5D6A7),
                            shape = RoundedCornerShape(20.dp)
                        )
                        .padding(28.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = K.perumMotham.tr().preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Medium,
                                color = if (isDark) Color(0xFFA7F3D0) else Color(0xFF1B6B4F)
                            )
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = CurrencyUtils.formatInr(invoice.mothaThogai),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 34.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = if (isDark) Color(0xFF6EE7B7) else Color(0xFF047857)
                            )
                        )
                    }
                }
            }

            // Internal Notes / Comments
            if (invoice.ullkurippu.isNotBlank()) {
                item(key = "notes_card") {
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Text(
                            text = K.kurippu.tr().preventBrokenLigatures(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = colors.textPrimary
                            )
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(14.dp))
                                .background(if (isDark) Color.White.copy(alpha = 0.04f) else Color.Black.copy(alpha = 0.025f))
                                .border(
                                    width = 1.dp,
                                    color = if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.06f),
                                    shape = RoundedCornerShape(14.dp)
                                )
                                .padding(16.dp)
                        ) {
                            Text(
                                text = invoice.ullkurippu.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 14.sp,
                                    color = colors.textPrimary
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}
