package com.elvan.noolachu.ui.components.shell

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale

/**
 * ElvanOavuruKaatchi — Replicates Flutter's `ElvanOavuruKaatchi` (`elvan_oavuru_kaatchi.dart`).
 * Renders an image from either a file path, content URI, or base64 encoded string.
 */
@Composable
expect fun ElvanOavuruKaatchi(
    value: String?,
    modifier: Modifier = Modifier,
    contentScale: ContentScale = ContentScale.Fit
)
