package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.core.extensions.cssShadow
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.ThemeManager
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.*

/**
 * Welcome Landing Page matching Flutter's WelcomePage (nalvaravu_thirai.dart) 1:1.
 */
@Composable
fun NalvaravuThirai(
    onNavigateToLogin: () -> Unit
) {
    val isDark = ThemeManager.isDark()
    val logoBg = if (isDark) Color.White else Color(0xFF111111)
    val logoTint = if (isDark) Color.Black else Color.White
    val textSecondary = if (isDark) Color.White.copy(alpha = 0.4f) else Color(0xFF999999)

    AuthLayout(showBranding = true) {
        // 1. LOGO SECTION matching Flutter 1:1 (96x96, radius 28dp, soft shadow, storage/database icon)
        AuthAnimatedElement(delayIndex = 0) {
            Box(
                modifier = Modifier
                    .size(96.dp)
                    .cssShadow(
                        color = if (isDark) Color.White else Color.Black,
                        alpha = if (isDark) 0.15f else 0.08f,
                        blurRadius = 40.dp,
                        offsetY = 20.dp
                    )
                    .clip(RoundedCornerShape(28.dp))
                    .background(logoBg, RoundedCornerShape(28.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = MaterialSymbols.Rounded.Storage,
                    contentDescription = "Niril Database",
                    tint = logoTint,
                    modifier = Modifier.size(48.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(40.dp))

        // 2. TEXT SECTION (Title: "நிறிளிற்கு நல்வரவு", Subtitle: "உங்கள் பட்டியல்கள் & GST, எளிதாக்கப்பட்டது.")
        AuthHeader(
            title = K.nirilirkuNalvaravu.tr(),
            subtitle = K.pattiyalgstelidhu.tr()
        )

        Spacer(modifier = Modifier.height(40.dp))

        // 3. INTRO SUBTEXT matching Flutter
        AuthAnimatedElement(delayIndex = 2) {
            Text(
                text = K.nirilthodanga.tr(),
                textAlign = TextAlign.Center,
                fontSize = 12.sp,
                lineHeight = 18.sp,
                color = textSecondary
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // 4. ACTION BUTTON matching Flutter (K.thodangugaPtn -> "தொடங்குக" / "Get Started")
        AuthButton(
            text = K.thodangugaPtn.tr(),
            onClick = onNavigateToLogin
        )
    }
}
