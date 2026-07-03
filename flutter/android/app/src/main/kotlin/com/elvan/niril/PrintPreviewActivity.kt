package com.elvan.niril

import android.content.Context
import android.os.Bundle
import android.print.PrintAttributes
import android.print.PrintManager
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.viewinterop.AndroidView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class PrintPreviewActivity : ComponentActivity() {

    private var webViewRef: WebView? = null
    private var htmlContentToLoad: String = ""

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val rawHtml = intent.getStringExtra("html_content") ?: "<h1>No Content</h1>"

        // Do NOT double-wrap the HTML. The rawHtml already contains a fully formed <html> document
        // with an A4 paper container. We just inject a dark background to match the Activity's dark theme.
        htmlContentToLoad = rawHtml.replace("</head>", "<style>body { background-color: #121212 !important; padding: 20px 0; }</style></head>")

        setContent {
            MaterialTheme(colorScheme = darkColorScheme()) {
                Scaffold(
                    topBar = {
                        CenterAlignedTopAppBar(
                            title = { Text("Print Preview") },
                            navigationIcon = {
                                IconButton(onClick = { finish() }) {
                                    Icon(
                                        imageVector = Icons.Default.ArrowBack,
                                        contentDescription = "Back"
                                    )
                                }
                            },
                            actions = {
                                IconButton(onClick = { handleShare() }) {
                                    Icon(
                                        imageVector = Icons.Default.Share,
                                        contentDescription = "Share"
                                    )
                                }
                                IconButton(onClick = { handlePrint() }) {
                                    Text("Print", color = Color.White)
                                }
                            },
                            colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                                containerColor = Color(0xFF1E1E1E),
                                titleContentColor = Color.White,
                                actionIconContentColor = Color.White,
                                navigationIconContentColor = Color.White
                            )
                        )
                    }
                ) { innerPadding ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                            .background(Color(0xFF121212)) // Dark background matching the HTML body
                    ) {
                        AndroidView(
                            factory = { context ->
                                WebView(context).apply {
                                    settings.apply {
                                        javaScriptEnabled = true
                                        builtInZoomControls = true
                                        displayZoomControls = false
                                        useWideViewPort = true
                                        loadWithOverviewMode = true
                                        setSupportZoom(true)
                                        cacheMode = WebSettings.LOAD_NO_CACHE
                                    }
                                    setBackgroundColor(android.graphics.Color.TRANSPARENT)
                                    webViewClient = object : WebViewClient() {
                                        override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                                            return false
                                        }
                                    }
                                    webViewRef = this
                                }
                            },
                            update = { webView ->
                                webView.loadDataWithBaseURL(
                                    "file:///android_asset/flutter_assets/",
                                    htmlContentToLoad,
                                    "text/html",
                                    "UTF-8",
                                    null
                                )
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                }
            }
        }
    }

    private fun handlePrint() {
        val webView = webViewRef ?: return
        val printManager = getSystemService(Context.PRINT_SERVICE) as PrintManager
        val jobName = "Elvan Niril Print"
        val printAdapter = webView.createPrintDocumentAdapter(jobName)
        
        try {
            printManager.print(
                jobName,
                printAdapter,
                PrintAttributes.Builder().build()
            )
        } catch (e: Exception) {
            Toast.makeText(this, "Failed to print: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun handleShare() {
        Toast.makeText(this, "Native PDF Share requires a Flutter MethodChannel callback. Please implement in Flutter.", Toast.LENGTH_SHORT).show()
    }
}
