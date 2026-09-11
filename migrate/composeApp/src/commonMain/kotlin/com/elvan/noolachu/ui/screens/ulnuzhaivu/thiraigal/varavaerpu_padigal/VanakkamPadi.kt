package com.elvan.noolachu.ui.screens.ulnuzhaivu.thiraigal.varavaerpu_padigal

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal.AuthAnimatedElement
import kotlinx.coroutines.delay

@Composable
fun GreetingStep(
    onComplete: () -> Unit
) {
    var greetingIndex by remember { mutableStateOf(0) }
    val greetings = listOf("வணக்கம்!", "Hello!", "നമസ്കാരം!")

    LaunchedEffect(Unit) {
        for (i in greetings.indices) {
            greetingIndex = i
            delay(1200)
        }
        delay(800)
        onComplete()
    }

    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        AuthAnimatedElement(delayIndex = 0) {
            Text(
                text = greetings[greetingIndex],
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onBackground
            )
        }
    }
}

