package com.elvan.noolachu.ui.screens.settings.thiraigal

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.navil.NavilEngine
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.Dimens
import com.elvan.noolachu.theme.LocalAppFontFamily
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.ShellDefaults
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.ui.components.shell.ElvanSectionContainer
import com.elvan.noolachu.ui.components.shell.ElvanSettingsDivider
import com.elvan.noolachu.ui.components.shell.ElvanSnackbar
import com.elvan.noolachu.ui.components.shell.LocalElvanTopSpacerHeight
import com.elvan.noolachu.ui.navigation.MaterialSymbols

/**
 * Navil Mozhimatri Screen (நவில் மொழிமாற்றி திரை).
 * Interactive One UI component showcasing the pure Kotlin Tolkappiyam
 * Phonetic Transliteration Engine (Tamil -> English / Latin).
 */
@Composable
fun NavilMozhimatriScreen(
    scrollState: LazyListState = rememberLazyListState(),
    colors: ShellColors = rememberShellColors()
) {
    val ff = LocalAppFontFamily.current
    val clipboardManager = LocalClipboardManager.current
    val uriHandler = LocalUriHandler.current

    var inputText by remember { mutableStateOf("முயற்சி திருவினையாக்கும்") }

    val outputText = remember(inputText) {
        if (inputText.isNotBlank()) NavilEngine.transliterate(inputText) else ""
    }

    val words = remember(inputText) {
        inputText.trim().split("\\s+".toRegex()).filter { it.isNotBlank() }
    }

    val copiedSuccessMsg = K.padiedukkappattadhu.tr()

    val presets = remember {
        listOf(
            "முயற்சி" to "Muyarchi",
            "வான்புகழ்" to "Vaanpugazh",
            "பல்கலைக்கழகம்" to "Palgalakkazhagam",
            "எண்பது" to "Enbadhu",
            "மறுபிறவி" to "Marupiravi",
            "அஃறிணை" to "Ahtrinai",
            "கற்கள்" to "Karkal",
            "கண்கள்" to "Kangal",
            "மண்பானை" to "Manpaanai",
            "தொன்றுதொட்டு" to "Thondrothottu",
            "செந்தமிழ்" to "Senthamizh",
            "அன்பு" to "Anbu"
        )
    }

    val rules = remember {
        listOf(
            Triple("1. ஆய்த நெறி (தொல். 38)", "ஃ-ன் பின் வல்லினம் மெலியாது கடினமாகும்", "எஃகு → Ehku, அஃறிணை → Ahtrinai"),
            Triple("2. வல்லின மெய் மயக்கம்", "ட், ற் பின் வல்லினம் மெலியாது", "முயற்சி → Muyarchi, பொற்காசு → Porkaasu"),
            Triple("3. இன மெல்லின மயக்கம்", "இன மெல்லினத்தின் பின் வல்லினம் மெலிதல்", "சிங்கம் → Singam, பந்து → Pandhu"),
            Triple("4. வேற்று மெல்லின மயக்கம்", "வேற்று மெல்லினத்தின் பின் வல்லினம் மெலியாது", "நான்கு → Naanku, மண்பானை → Manpaanai"),
            Triple("5. பகாப்பதம் vs தொகைச்சொல்", "பகாப்பதம் மெலியும்; தொகைச்சொல் தலைப்பு கடினம்", "நண்பன் → Nanban, மென்பொருள் → Menporul"),
            Triple("6. எண் பெயர் நெறி (-பது)", "பத்தின் மடங்குகள் மெலிதல்", "எண்பது → Enbadhu, ஒன்பது → Onbadhu"),
            Triple("7. உயிர் இடை மெலிதல்", "உயிர்களுக்கு இடையே வல்லினம் மெலிதல்", "அகம் → Agam, படம் → Padam"),
            Triple("8. இடையின மெலிதல்", "ய், ர், ல், ழ், ள் பின் வல்லினம் மெலிதல்", "பல்கலை → Palgalai, வாழ்க → Vaazhga"),
            Triple("9. பன்மை விகுதி (-கள்)", "மெல்லினம்/இடையினம் பின் gal; வல்லினம் பின் kal", "கண்கள் → Kangal, கற்கள் → Karkal"),
            Triple("10. வருமொழி முதனிலை", "அடிச்சொல் முதன்மை வல்லினம் மெலியாது", "மறுபிறவி → Marupiravi, கண்டுபிடி → Kandupidi"),
            Triple("11. இடைச்சொற்கள்", "கூட மெலியாது; தான், போது மெலியும்", "அவள்கூட → Avalkooda, அவன்தான் → Avandhaan"),
            Triple("12. சொல் முதன்மை 'ச'", "சொல் முதலில் 'ச' affricate 'ch' ஒலிக்கும்", "சென்னை → Chennai, சரி → Chari"),
            Triple("13. மிகை ஒற்று நீக்கம்", "இலக்கணப் பிழை ஒற்று தானாக நீக்கப்படும்", "பொற்க்காசு → Porkaasu"),
            Triple("14. அசை பிரித்தல்", "யாப்பிலக்கண நேரசை, நிரையசை பிரித்தல்", "மு-யற்-சி, வான்-பு-கழ்")
        )
    }

    var expandedRuleIndex by remember { mutableStateOf<Int?>(null) }

    LazyColumn(
        state = scrollState,
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = Dimens.ContentPadding,
            end = Dimens.ContentPadding,
            bottom = Dimens.SubpageContentPaddingBottom
        ),
        verticalArrangement = Arrangement.spacedBy(Dimens.SectionSpacing)
    ) {
        item(key = "shell_top_spacer") {
            Spacer(modifier = Modifier.height(LocalElvanTopSpacerHeight.current))
        }

        // ── Card 1: Live Output Card (Latin / English) ──
        item(key = "output_card") {
            ElvanSectionContainer {
                Surface(
                    shape = RoundedCornerShape(24.dp),
                    color = colors.surface,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = K.navilVeliyidu.tr().uppercase(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    letterSpacing = 0.5.sp
                                ),
                                color = colors.textPrimary.copy(alpha = 0.5f)
                            )

                            // Action buttons: Copy
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                if (outputText.isNotEmpty()) {
                                    Surface(
                                        shape = CircleShape,
                                        color = colors.iconBg,
                                        modifier = Modifier
                                            .size(36.dp)
                                            .clip(CircleShape)
                                            .clickable(
                                                interactionSource = remember { MutableInteractionSource() },
                                                indication = ShellDefaults.ripple(colors, bounded = true),
                                                onClick = {
                                                    clipboardManager.setText(AnnotatedString(outputText))
                                                    ElvanSnackbar.show(copiedSuccessMsg)
                                                }
                                            )
                                    ) {
                                        Box(
                                            contentAlignment = Alignment.Center,
                                            modifier = Modifier.fillMaxSize()
                                        ) {
                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.ContentCopy,
                                                contentDescription = "Copy",
                                                tint = colors.textPrimary,
                                                modifier = Modifier.size(18.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(14.dp))

                        // Large Converted Output Text
                        Text(
                            text = if (outputText.isNotEmpty()) outputText else "—",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold,
                                lineHeight = 30.sp
                            ),
                            color = if (outputText.isNotEmpty()) colors.textPrimary else colors.textPrimary.copy(alpha = 0.35f)
                        )

                        Spacer(modifier = Modifier.height(14.dp))

                        // Stats Badge: Character count & word count
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(colors.textPrimary.copy(alpha = 0.06f))
                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = "${outputText.length} ${K.ezhezhuthukkal.tr()}",
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Medium
                                    ),
                                    color = colors.textSecondary
                                )
                            }

                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(colors.textPrimary.copy(alpha = 0.06f))
                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = "${words.size} ${K.cholEnnikkai.tr()}",
                                    style = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Medium
                                    ),
                                    color = colors.textSecondary
                                )
                            }
                        }
                    }
                }
            }
        }

        // ── Card 2: Interactive Tamil Input ──
        item(key = "input_card") {
            ElvanSectionContainer {
                Surface(
                    shape = RoundedCornerShape(24.dp),
                    color = colors.surface,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = K.thamizhUllidu.tr().uppercase(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    letterSpacing = 0.5.sp
                                ),
                                color = colors.textPrimary.copy(alpha = 0.5f)
                            )

                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                // Paste button
                                Surface(
                                    shape = CircleShape,
                                    color = colors.iconBg,
                                    modifier = Modifier
                                        .size(34.dp)
                                        .clip(CircleShape)
                                        .clickable(
                                            interactionSource = remember { MutableInteractionSource() },
                                            indication = ShellDefaults.ripple(colors, bounded = true),
                                            onClick = {
                                                clipboardManager.getText()?.text?.let { clipText ->
                                                    if (clipText.isNotBlank()) {
                                                        inputText = clipText
                                                    }
                                                }
                                            }
                                        )
                                ) {
                                    Box(
                                        contentAlignment = Alignment.Center,
                                        modifier = Modifier.fillMaxSize()
                                    ) {
                                        Icon(
                                            imageVector = MaterialSymbols.Rounded.ContentPaste,
                                            contentDescription = "Paste",
                                            tint = colors.textPrimary.copy(alpha = 0.7f),
                                            modifier = Modifier.size(16.dp)
                                        )
                                    }
                                }

                                // Clear button
                                if (inputText.isNotEmpty()) {
                                    Surface(
                                        shape = CircleShape,
                                        color = colors.iconBg,
                                        modifier = Modifier
                                            .size(34.dp)
                                            .clip(CircleShape)
                                            .clickable(
                                                interactionSource = remember { MutableInteractionSource() },
                                                indication = ShellDefaults.ripple(colors, bounded = true),
                                                onClick = { inputText = "" }
                                            )
                                    ) {
                                        Box(
                                            contentAlignment = Alignment.Center,
                                            modifier = Modifier.fillMaxSize()
                                        ) {
                                            Icon(
                                                imageVector = MaterialSymbols.Rounded.Close,
                                                contentDescription = "Clear",
                                                tint = colors.textPrimary.copy(alpha = 0.7f),
                                                modifier = Modifier.size(16.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        // Multi-line Input Box
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = colors.iconBg,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp, vertical = 14.dp)
                            ) {
                                if (inputText.isEmpty()) {
                                    Text(
                                        text = "தமிழில் உள்ளிடவும்...",
                                        style = TextStyle(
                                            fontFamily = ff,
                                            fontSize = 16.sp,
                                            fontWeight = FontWeight.Normal
                                        ),
                                        color = colors.textPrimary.copy(alpha = 0.35f)
                                    )
                                }

                                BasicTextField(
                                    value = inputText,
                                    onValueChange = { inputText = it },
                                    modifier = Modifier.fillMaxWidth(),
                                    textStyle = TextStyle(
                                        fontFamily = ff,
                                        fontSize = 16.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = colors.textPrimary,
                                        lineHeight = 24.sp
                                    ),
                                    cursorBrush = SolidColor(colors.accent)
                                )
                            }
                        }
                    }
                }
            }
        }

        // ── Card 3: Syllable Breakdown (அசை பிரித்தல்) ──
        if (words.isNotEmpty()) {
            item(key = "syllable_card") {
                ElvanSectionContainer {
                    Surface(
                        shape = RoundedCornerShape(24.dp),
                        color = colors.surface,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(20.dp)
                        ) {
                            Text(
                                text = K.asaiPirippu.tr().uppercase(),
                                style = TextStyle(
                                    fontFamily = ff,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.SemiBold,
                                    letterSpacing = 0.5.sp
                                ),
                                color = colors.textPrimary.copy(alpha = 0.5f)
                            )

                            Spacer(modifier = Modifier.height(14.dp))

                            words.take(5).forEachIndexed { wordIndex, word ->
                                val syllables = remember(word) { NavilEngine.splitSyllables(word) }
                                if (syllables.isNotEmpty()) {
                                    if (wordIndex > 0) {
                                        Spacer(modifier = Modifier.height(10.dp))
                                    }

                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                                        modifier = Modifier.fillMaxWidth()
                                    ) {
                                        Text(
                                            text = word,
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 13.sp,
                                                fontWeight = FontWeight.SemiBold
                                            ),
                                            color = colors.textSecondary,
                                            modifier = Modifier.widthIn(min = 60.dp, max = 90.dp)
                                        )

                                        LazyRow(
                                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                                            modifier = Modifier.weight(1f)
                                        ) {
                                            items(syllables) { syllable ->
                                                val romanSyllable = remember(syllable.raw) {
                                                    NavilEngine.transliterate(syllable.raw)
                                                }
                                                Box(
                                                    modifier = Modifier
                                                        .clip(RoundedCornerShape(8.dp))
                                                        .background(colors.accent.copy(alpha = 0.1f))
                                                        .border(
                                                            width = 0.5.dp,
                                                            color = colors.accent.copy(alpha = 0.25f),
                                                            shape = RoundedCornerShape(8.dp)
                                                        )
                                                        .padding(horizontal = 10.dp, vertical = 6.dp)
                                                ) {
                                                    Column(
                                                        horizontalAlignment = Alignment.CenterHorizontally
                                                    ) {
                                                        Text(
                                                            text = syllable.raw,
                                                            style = TextStyle(
                                                                fontFamily = ff,
                                                                fontSize = 14.sp,
                                                                fontWeight = FontWeight.Bold
                                                            ),
                                                            color = colors.textPrimary
                                                        )
                                                        Text(
                                                            text = romanSyllable,
                                                            style = TextStyle(
                                                                fontFamily = ff,
                                                                fontSize = 10.sp,
                                                                fontWeight = FontWeight.Medium
                                                            ),
                                                            color = colors.accent
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
            }
        }

        // ── Card 4: Quick Test Presets (எடுத்துக்காட்டுகள்) ──
        item(key = "presets_card") {
            ElvanSectionContainer {
                Surface(
                    shape = RoundedCornerShape(24.dp),
                    color = colors.surface,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp)
                    ) {
                        Text(
                            text = K.eduthukaattugal.tr().uppercase(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                letterSpacing = 0.5.sp
                            ),
                            color = colors.textPrimary.copy(alpha = 0.5f)
                        )

                        Spacer(modifier = Modifier.height(14.dp))

                        // Flowing chips row
                        LazyRow(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            items(presets) { (tamilPreset, romanPreset) ->
                                val isSelected = inputText == tamilPreset
                                Surface(
                                    shape = RoundedCornerShape(50),
                                    color = if (isSelected) colors.textPrimary else colors.iconBg,
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(50))
                                        .clickable(
                                            interactionSource = remember { MutableInteractionSource() },
                                            indication = ShellDefaults.ripple(colors, bounded = true),
                                            onClick = { inputText = tamilPreset }
                                        )
                                ) {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp)
                                    ) {
                                        Text(
                                            text = tamilPreset,
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 13.sp,
                                                fontWeight = FontWeight.SemiBold
                                            ),
                                            color = if (isSelected) colors.surface else colors.textPrimary
                                        )
                                        Text(
                                            text = "($romanPreset)",
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 11.sp,
                                                fontWeight = FontWeight.Normal
                                            ),
                                            color = if (isSelected) colors.surface.copy(alpha = 0.7f) else colors.textSecondary
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Card 5: Tolkappiyam Phonetic Rules Reference (தொல்காப்பிய நெறிகள்) ──
        item(key = "rules_card") {
            ElvanSectionContainer {
                Surface(
                    shape = RoundedCornerShape(24.dp),
                    color = colors.surface,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(20.dp)
                    ) {
                        Text(
                            text = K.tholkaappiyaNerigal.tr().uppercase(),
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                letterSpacing = 0.5.sp
                            ),
                            color = colors.textPrimary.copy(alpha = 0.5f)
                        )

                        Spacer(modifier = Modifier.height(12.dp))

                        rules.forEachIndexed { index, (title, desc, example) ->
                            val isExpanded = expandedRuleIndex == index

                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(12.dp))
                                    .clickable(
                                        interactionSource = remember { MutableInteractionSource() },
                                        indication = ShellDefaults.ripple(colors, bounded = true),
                                        onClick = {
                                            expandedRuleIndex = if (isExpanded) null else index
                                        }
                                    )
                                    .padding(vertical = 10.dp)
                            ) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = title,
                                        style = TextStyle(
                                            fontFamily = ff,
                                            fontSize = 14.sp,
                                            fontWeight = FontWeight.SemiBold
                                        ),
                                        color = colors.textPrimary,
                                        modifier = Modifier.weight(1f)
                                    )

                                    Icon(
                                        imageVector = if (isExpanded) MaterialSymbols.Rounded.KeyboardArrowDown else MaterialSymbols.Rounded.ChevronRight,
                                        contentDescription = null,
                                        tint = colors.textSecondary,
                                        modifier = Modifier.size(20.dp)
                                    )
                                }

                                if (isExpanded) {
                                    Spacer(modifier = Modifier.height(6.dp))
                                    Text(
                                        text = desc,
                                        style = TextStyle(
                                            fontFamily = ff,
                                            fontSize = 13.sp,
                                            fontWeight = FontWeight.Normal,
                                            lineHeight = 18.sp
                                        ),
                                        color = colors.textSecondary
                                    )

                                    Spacer(modifier = Modifier.height(6.dp))
                                    Box(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .clip(RoundedCornerShape(8.dp))
                                            .background(colors.accent.copy(alpha = 0.08f))
                                            .padding(horizontal = 12.dp, vertical = 6.dp)
                                    ) {
                                        Text(
                                            text = example,
                                            style = TextStyle(
                                                fontFamily = ff,
                                                fontSize = 12.5.sp,
                                                fontWeight = FontWeight.Medium
                                            ),
                                            color = colors.accent
                                        )
                                    }
                                }
                            }

                            if (index < rules.size - 1) {
                                ElvanSettingsDivider(colors = colors)
                            }
                        }
                    }
                }
            }
        }

        // ── Card 6: Clean Brand Footer & Web Link ──
        item(key = "brand_footer") {
            ElvanSectionContainer {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Elvan Navil Engine",
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        ),
                        color = colors.textPrimary
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = "தொல்காப்பிய மெய்யொலிப் பெயர்ப்பு நெறி",
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Normal
                        ),
                        color = colors.textSecondary
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Website Pill
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        modifier = Modifier
                            .clip(RoundedCornerShape(50))
                            .background(colors.textPrimary.copy(alpha = 0.08f))
                            .clickable { uriHandler.openUri("https://elvannavil.vercel.app") }
                            .padding(horizontal = 20.dp, vertical = 10.dp)
                    ) {
                        Text(
                            text = "elvannavil.vercel.app",
                            style = TextStyle(
                                fontFamily = ff,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.SemiBold
                            ),
                            color = colors.textPrimary
                        )
                        Icon(
                            imageVector = MaterialSymbols.Rounded.ArrowForward,
                            contentDescription = null,
                            tint = colors.textPrimary,
                            modifier = Modifier.size(15.dp)
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = K.allRightsReserved.tr(),
                        style = TextStyle(
                            fontFamily = ff,
                            fontSize = 11.5.sp,
                            fontWeight = FontWeight.Normal
                        ),
                        color = colors.textPrimary.copy(alpha = 0.35f),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}
