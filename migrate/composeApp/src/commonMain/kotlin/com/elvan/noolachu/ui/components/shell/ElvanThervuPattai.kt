package com.elvan.noolachu.ui.components.shell

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
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
import com.elvan.noolachu.core.extensions.cssShadow
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * ElvanThervuPattai — Floating multi-selection action bar ported directly from
 * Flutter's `elvan_thervu_pattai.dart`. Replaces the bottom navbar during selection mode.
 */
@Composable
fun ElvanThervuPattai(
    selectedCount: Int,
    onSelectAll: () -> Unit,
    onDelete: () -> Unit,
    onCancel: () -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark

    Box(
        modifier = modifier
            .padding(bottom = 12.dp)
            .height(64.dp)
            .widthIn(min = 280.dp, max = 340.dp)
            .cssShadow(
                color = Color.Black,
                alpha = 0.05f,
                blurRadius = 16.dp,
                offsetY = 4.dp
            )
            .background(
                color = colors.floatingBg.copy(alpha = 0.88f),
                shape = CircleShape
            )
            .border(
                width = 0.5.dp,
                color = colors.floatingBorder.copy(alpha = 0.15f),
                shape = CircleShape
            ),
        contentAlignment = Alignment.Center
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 12.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Action 1: Select All / Count
            ThervuPattaiAction(
                icon = if (selectedCount > 0) MaterialSymbols.Rounded.CheckBox else MaterialSymbols.Rounded.CheckBoxOutlineBlank,
                label = if (selectedCount > 0) "$selectedCount ${K.thaerndhedu.tr()}" else K.anaithaiyumTheriPtn.tr(),
                isActive = selectedCount > 0,
                isDisabled = false,
                isDark = isDark,
                onClick = onSelectAll
            )

            // Action 2: Delete
            ThervuPattaiAction(
                icon = MaterialSymbols.Rounded.Delete,
                label = K.neekkuPtn.tr(),
                isActive = false,
                isDisabled = selectedCount == 0,
                isDark = isDark,
                onClick = { if (selectedCount > 0) onDelete() }
            )

            // Action 3: Cancel
            ThervuPattaiAction(
                icon = MaterialSymbols.Rounded.Close,
                label = K.kaividuPtn.tr(),
                isActive = false,
                isDisabled = false,
                isDark = isDark,
                onClick = onCancel
            )
        }
    }
}

@Composable
private fun ThervuPattaiAction(
    icon: ImageVector,
    label: String,
    isActive: Boolean,
    isDisabled: Boolean,
    isDark: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val ff = LocalAppFontFamily.current
    val contentColor = when {
        isDisabled -> if (isDark) Color.White.copy(alpha = 0.24f) else Color.Black.copy(alpha = 0.26f)
        isActive -> if (isDark) Color(0xFF8AD5B3) else Color(0xFF1B6B4F)
        else -> if (isDark) Color.White else Color(0xFF1D1D1F)
    }

    Column(
        modifier = modifier
            .width(84.dp)
            .fillMaxHeight()
            .clip(CircleShape)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = ripple(bounded = true),
                enabled = !isDisabled,
                onClick = onClick
            ),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = label,
            tint = contentColor,
            modifier = Modifier.size(23.dp)
        )
        Spacer(modifier = Modifier.height(2.dp))
        Text(
            text = label,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center,
            style = TextStyle(
                fontFamily = ff,
                fontSize = 10.sp,
                fontWeight = if (isActive) FontWeight.SemiBold else FontWeight.Normal,
                color = contentColor
            )
        )
    }
}
