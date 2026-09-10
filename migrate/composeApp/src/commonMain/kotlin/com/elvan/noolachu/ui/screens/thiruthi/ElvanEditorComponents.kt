package com.elvan.noolachu.ui.screens.thiruthi

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.material3.ripple
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.mode.LocalAppMode
import com.elvan.noolachu.data.settings.NiruvanaTharavugalRepository
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.preventBrokenLigatures
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Numbered Section Header for Elvan Editors (Thiruthi).
 * Matches Flutter's `ElvanEditorSection`:
 * 24x24dp circle with 1-based index (1, 2, 3...) followed by a semi-bold title.
 */
@Composable
fun ElvanEditorSection(
    index: Int,
    title: String,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(bottom = 8.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Section Header Row
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(horizontal = 4.dp)
        ) {
            // Numbered Circle Badge
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(if (isDark) Color.White else Color.Black),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = (index + 1).toString(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp,
                        color = if (isDark) Color.Black else Color.White
                    )
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Section Title
            Text(
                text = title.preventBrokenLigatures(),
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = colors.textPrimary
                )
            )
        }

        // Section Content
        content()
    }
}

/**
 * Boxed Card Container for Elvan Editors.
 * Matches Flutter's `ElvanThiruthiAttai`:
 * Default `borderRadius = 24.dp`, no shadow, no border.
 * Light mode: `Color.White`, Dark mode: `Color.White.copy(alpha = 0.03f)`.
 */
@Composable
fun ElvanThiruthiAttai(
    modifier: Modifier = Modifier,
    borderRadius: Dp = 24.dp,
    padding: PaddingValues = PaddingValues(16.dp),
    backgroundColor: Color? = null,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark

    val bg = backgroundColor ?: if (isDark) Color.White.copy(alpha = 0.08f) else Color.White

    val shape = RoundedCornerShape(borderRadius)

    val clickableModifier = if (onClick != null) {
        Modifier.clickable(
            interactionSource = remember { MutableInteractionSource() },
            indication = ripple(bounded = true),
            onClick = onClick
        )
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .background(bg)
            .then(clickableModifier)
            .padding(padding)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            content()
        }
    }
}

/**
 * Small label displayed directly above editor text fields.
 * Matches Flutter's `ElvanThiruthiThalaippu`.
 */
@Composable
fun ElvanThiruthiThalaippu(
    label: String,
    modifier: Modifier = Modifier
) {
    val colors = rememberShellColors()
    val ff = LocalAppFontFamily.current

    Text(
        text = label.preventBrokenLigatures(),
        style = TextStyle(
            fontFamily = ff,
            fontSize = 12.5.sp,
            fontWeight = FontWeight.Medium,
            color = colors.textSecondary
        ),
        modifier = modifier.padding(start = 6.dp, bottom = 4.dp)
    )
}

/**
 * Pill-shaped input designed specifically for Elvan Editors (Thiruthi).
 * Matches Flutter's `ElvanThiruthiUlleedu`:
 * - Height: 45dp (for single-line)
 * - Corner radius: 999dp (pill) or 16dp (multiline)
 * - Clean vertical centering with no excessive Material padding
 * - Background: White (in light mode) or rgba(255,255,255,0.08) (in dark mode)
 */
@Composable
fun ElvanThiruthiUlleedu(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null,
    placeholder: String? = null,
    prefixText: String? = null,
    suffixText: String? = null,
    prefixIcon: @Composable (() -> Unit)? = null,
    suffixIcon: @Composable (() -> Unit)? = null,
    enabled: Boolean = true,
    singleLine: Boolean = true,
    maxLines: Int = 1,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    keyboardActions: KeyboardActions = KeyboardActions.Default,
    errorMessage: String? = null
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    val containerBg = if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.05f)
    val shape = if (singleLine) RoundedCornerShape(999.dp) else RoundedCornerShape(16.dp)

    Column(
        modifier = modifier.fillMaxWidth()
    ) {
        if (!label.isNullOrBlank()) {
            ElvanThiruthiThalaippu(label = label)
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .then(if (singleLine) Modifier.height(45.dp) else Modifier.heightIn(min = 45.dp, max = 120.dp))
                .clip(shape)
                .background(containerBg)
                .padding(horizontal = 16.dp, vertical = if (singleLine) 0.dp else 10.dp),
            contentAlignment = if (singleLine) Alignment.CenterStart else Alignment.TopStart
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = if (singleLine) Alignment.CenterVertically else Alignment.Top
            ) {
                if (prefixIcon != null) {
                    prefixIcon()
                    Spacer(modifier = Modifier.width(8.dp))
                }

                if (!prefixText.isNullOrEmpty()) {
                    Text(
                        text = prefixText,
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium,
                            color = colors.textSecondary
                        )
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                }

                Box(
                    modifier = Modifier.weight(1f),
                    contentAlignment = if (singleLine) Alignment.CenterStart else Alignment.TopStart
                ) {
                    if (value.isEmpty() && !placeholder.isNullOrEmpty()) {
                        Text(
                            text = placeholder,
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 14.sp,
                                color = colors.textSecondary.copy(alpha = 0.5f)
                            )
                        )
                    }

                    BasicTextField(
                        value = value,
                        onValueChange = onValueChange,
                        enabled = enabled,
                        singleLine = singleLine,
                        maxLines = maxLines,
                        keyboardOptions = keyboardOptions,
                        keyboardActions = keyboardActions,
                        cursorBrush = SolidColor(if (isDark) Color.White else Color.Black),
                        textStyle = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Normal,
                            color = if (enabled) colors.textPrimary else colors.textSecondary
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                if (!suffixText.isNullOrEmpty()) {
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = suffixText,
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium,
                            color = colors.textSecondary
                        )
                    )
                }

                if (suffixIcon != null) {
                    Spacer(modifier = Modifier.width(8.dp))
                    suffixIcon()
                }
            }
        }

        if (!errorMessage.isNullOrBlank()) {
            Text(
                text = errorMessage,
                style = TextStyle(
                    fontFamily = ff,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.error
                ),
                modifier = Modifier.padding(start = 12.dp, top = 4.dp)
            )
        }
    }
}

/**
 * Reusable Bilingual Input Field.
 * Matches Flutter's `ElvanIrumozhiPulan`:
 * Checks `profile.iruMozhi` from settings:
 * - If false: Renders 1 single input for primary language (`profile.mudhanMozhi`).
 * - If true: Renders 2 inputs: Primary language and Secondary language (`profile.thunaiMozhi`).
 */
@Composable
fun ElvanIrumozhiPulan(
    label: String,
    value: Map<String, String>,
    onChanged: (Map<String, String>) -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    maxLines: Int = 1,
    placeholder: String? = null
) {
    val currentMode = LocalAppMode.current
    val profile = NiruvanaTharavugalRepository.getProfile(currentMode)

    val isBilingual = profile.iruMozhi
    val primaryLang = profile.mudhanMozhi.ifEmpty { "ta" }
    val secondaryLang = profile.thunaiMozhi.ifEmpty { "en" }

    val primaryLangLabel = if (primaryLang == "ta") K.thamizh.tr() else K.aangilam.tr()
    val secondaryLangLabel = if (secondaryLang == "en") K.aangilam.tr() else K.thamizh.tr()

    val primaryValue = value[primaryLang] ?: ""
    val secondaryValue = value[secondaryLang] ?: ""

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Primary Field
        ElvanThiruthiUlleedu(
            value = primaryValue,
            onValueChange = { newText ->
                val updated = value.toMutableMap()
                updated[primaryLang] = newText
                onChanged(updated)
            },
            label = "$label ($primaryLangLabel)",
            placeholder = placeholder,
            enabled = enabled,
            singleLine = maxLines == 1,
            maxLines = maxLines
        )

        // Secondary Field (shown only when bilingual mode is enabled in Settings)
        if (isBilingual) {
            ElvanThiruthiUlleedu(
                value = secondaryValue,
                onValueChange = { newText ->
                    val updated = value.toMutableMap()
                    updated[secondaryLang] = newText
                    onChanged(updated)
                },
                label = "$label ($secondaryLangLabel)",
                placeholder = placeholder,
                enabled = enabled,
                singleLine = maxLines == 1,
                maxLines = maxLines
            )
        }
    }
}

/**
 * Dropdown Pill Selector for Elvan Editors.
 * Matches Flutter's `ElvanThiruthiKeezhvirivu`.
 */
@Composable
fun ElvanThiruthiKeezhvirivu(
    label: String? = null,
    selectedText: String,
    items: List<Pair<String, String>>, // value to display label
    onSelected: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val colors = rememberShellColors()
    val isDark = colors.isDark
    val ff = LocalAppFontFamily.current

    var expanded by remember { mutableStateOf(false) }
    val containerBg = if (isDark) Color.White.copy(alpha = 0.08f) else Color.Black.copy(alpha = 0.05f)

    Column(modifier = modifier.fillMaxWidth()) {
        if (!label.isNullOrBlank()) {
            ElvanThiruthiThalaippu(label = label)
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(45.dp)
                .clip(RoundedCornerShape(999.dp))
                .background(containerBg)
                .clickable { expanded = true }
                .padding(horizontal = 16.dp),
            contentAlignment = Alignment.CenterStart
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = selectedText.preventBrokenLigatures(),
                    style = TextStyle(
                        fontFamily = ff,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = colors.textPrimary
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Icon(
                    imageVector = MaterialSymbols.Rounded.KeyboardArrowDown,
                    contentDescription = null,
                    tint = colors.textSecondary,
                    modifier = Modifier.size(22.dp)
                )
            }

            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false },
                modifier = Modifier.background(colors.floatingBg)
            ) {
                items.forEach { (valKey, displayLabel) ->
                    DropdownMenuItem(
                        text = {
                            Text(
                                text = displayLabel.preventBrokenLigatures(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 14.sp,
                                    color = colors.textPrimary
                                )
                            )
                        },
                        onClick = {
                            expanded = false
                            onSelected(valKey)
                        }
                    )
                }
            }
        }
    }
}
