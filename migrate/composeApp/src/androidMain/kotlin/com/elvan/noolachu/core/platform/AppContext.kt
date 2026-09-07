package com.elvan.noolachu.core.platform

import android.content.Context

object AppContext {
    private var appContext: Context? = null

    var context: Context
        get() = appContext ?: throw IllegalStateException("AppContext is not initialized yet!")
        set(value) {
            appContext = value.applicationContext
        }

    val isInitialized: Boolean
        get() = appContext != null
}
