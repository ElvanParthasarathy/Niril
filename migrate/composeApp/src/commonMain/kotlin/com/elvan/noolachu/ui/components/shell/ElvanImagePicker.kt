package com.elvan.noolachu.ui.components.shell

import androidx.compose.runtime.Composable

/**
 * Platform image picker launcher supporting Gallery and Files.
 */
interface ImagePickerLauncher {
    fun launchGallery()
    fun launchFiles()
}

@Composable
expect fun rememberImagePicker(onImagePicked: (String) -> Unit): ImagePickerLauncher
