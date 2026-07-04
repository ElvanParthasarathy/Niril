package com.elvan.niril

import android.content.Context
import android.os.Bundle
import android.print.PrintAttributes
import android.print.PrintManager
import android.util.Log
import android.webkit.ConsoleMessage
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.viewinterop.AndroidView
import androidx.webkit.WebViewAssetLoader
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class ReactAppActivity : ComponentActivity() {

    companion object {
        private const val TAG = "ReactAppActivity"
    }

    private var webViewRef: WebView? = null
    private var pageToLoad: String = "index.html"
    private var payloadData: String = "{}"
    private var profileData: String = "{}"

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        pageToLoad = intent.getStringExtra("page") ?: "index.html"
        payloadData = ReactDataHolder.payload ?: "{}"
        profileData = ReactDataHolder.profile ?: "{}"
        
        // Clear to avoid memory leaks
        ReactDataHolder.payload = null
        ReactDataHolder.profile = null

        WebView.setWebContentsDebuggingEnabled(true)

        val defaultAssetsHandler = WebViewAssetLoader.AssetsPathHandler(this)
        val assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", object : WebViewAssetLoader.PathHandler {
                override fun handle(path: String): WebResourceResponse? {
                    val response = defaultAssetsHandler.handle(path)
                    if (response != null) {
                        if (path.endsWith(".woff")) {
                            response.mimeType = "font/woff"
                        } else if (path.endsWith(".ttf")) {
                            response.mimeType = "font/ttf"
                        }
                    }
                    return response
                }
            })
            .build()

        setContent {
            MaterialTheme(colorScheme = darkColorScheme()) {
                Scaffold(
                    topBar = {
                        CenterAlignedTopAppBar(
                            title = { Text("Preview") },
                            navigationIcon = {
                                IconButton(onClick = { finish() }) {
                                    Icon(
                                        imageVector = Icons.Default.ArrowBack,
                                        contentDescription = "Back"
                                    )
                                }
                            },
                            actions = {
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
                            .background(MaterialTheme.colorScheme.background)
                    ) {
                        AndroidView(
                            factory = { context ->
                                WebView(context).apply {
                                    setBackgroundColor(android.graphics.Color.TRANSPARENT)
                                    settings.apply {
                                        javaScriptEnabled = true
                                        domStorageEnabled = true
                                        allowFileAccess = true
                                        cacheMode = WebSettings.LOAD_NO_CACHE
                                        mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
                                        setSupportZoom(true)
                                        builtInZoomControls = true
                                        displayZoomControls = false
                                        useWideViewPort = true
                                        loadWithOverviewMode = true
                                    }

                                    webChromeClient = object : WebChromeClient() {
                                        override fun onConsoleMessage(msg: ConsoleMessage?): Boolean {
                                            msg?.let {
                                                Log.d(TAG, "[${it.messageLevel()}] ${it.message()} (${it.sourceId()}:${it.lineNumber()})")
                                            }
                                            return true
                                        }
                                    }

                                    webViewClient = object : WebViewClient() {
                                        override fun shouldInterceptRequest(
                                            view: WebView?,
                                            request: WebResourceRequest?
                                        ): WebResourceResponse? {
                                            return request?.url?.let { assetLoader.shouldInterceptRequest(it) }
                                                ?: super.shouldInterceptRequest(view, request)
                                        }

                                        override fun onReceivedError(
                                            view: WebView?,
                                            request: WebResourceRequest?,
                                            error: WebResourceError?
                                        ) {
                                            Log.e(TAG, "LOAD ERROR: ${error?.description}")
                                            super.onReceivedError(view, request, error)
                                        }

                                        override fun onPageFinished(view: WebView?, url: String?) {
                                            super.onPageFinished(view, url)
                                            Log.d(TAG, "Page loaded: $url")
                                            
                                            // Use a polling mechanism to ensure React is fully mounted and setReactData is available
                                            val script = """
                                                (function poll() {
                                                    if (window.setReactData) {
                                                        window.setReactData(String.raw`$payloadData`, String.raw`$profileData`);
                                                    } else {
                                                        setTimeout(poll, 50);
                                                    }
                                                })();
                                            """.trimIndent()
                                            view?.evaluateJavascript(script, null)
                                        }
                                    }

                                    webViewRef = this
                                }
                            },
                            update = { webView ->
                                webView.loadUrl("https://appassets.androidplatform.net/assets/react_app/$pageToLoad?native=true")
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
        val jobName = "Elvan Niril Document"
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
}
