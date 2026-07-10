package com.elvan.niril

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import android.print.PrintManager
import android.print.PrintAttributes
import android.content.Context
import org.json.JSONObject

class CleanReceiptActivity : ComponentActivity() {
    private lateinit var webView: WebView

    @OptIn(ExperimentalMaterial3Api::class)
    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val receiptJson = intent.getStringExtra("receiptJson") ?: "{}"
        val profileJson = intent.getStringExtra("profileJson") ?: "{}"
        val intentIsDark = intent.getBooleanExtra("isDark", false)
        val receiptType = intent.getStringExtra("receiptType") ?: "GST"
        
        var receiptNo = "Receipt"
        try {
            val obj = JSONObject(receiptJson)
            if (obj.has("receiptNo")) {
                receiptNo = "#" + obj.getString("receiptNo")
            }
        } catch (e: Exception) {}

        setContent {
            // Use Android system dark theme or flutter's intent flag
            val isDark = isSystemInDarkTheme() || intentIsDark

            MaterialTheme(
                colorScheme = if (isDark) darkColorScheme(background = androidx.compose.ui.graphics.Color.Black) else lightColorScheme(background = androidx.compose.ui.graphics.Color.White)
            ) {
                Scaffold(
                    topBar = {
                        TopAppBar(
                            title = { Text(receiptNo, style = MaterialTheme.typography.titleLarge) },
                            navigationIcon = {
                                IconButton(onClick = { finish() }) {
                                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                                }
                            },
                            actions = {
                                IconButton(onClick = { 
                                    printWebView(receiptNo) 
                                }) {
                                    Text("🖨️")
                                }
                            },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = MaterialTheme.colorScheme.background,
                                titleContentColor = MaterialTheme.colorScheme.onBackground,
                                navigationIconContentColor = MaterialTheme.colorScheme.onBackground,
                                actionIconContentColor = MaterialTheme.colorScheme.onBackground
                            )
                        )
                    }
                ) { innerPadding ->
                    AndroidView(
                        factory = { context ->
                            WebView(context).apply {
                                webView = this
                                setBackgroundColor(android.graphics.Color.TRANSPARENT)
                                settings.apply {
                                    javaScriptEnabled = true
                                    domStorageEnabled = true
                                    allowFileAccess = true
                                    allowFileAccessFromFileURLs = true
                                    allowUniversalAccessFromFileURLs = true
                                    
                                    // Enable Native Android Zoom
                                    setSupportZoom(true)
                                    builtInZoomControls = true
                                    displayZoomControls = false
                                    useWideViewPort = true
                                    loadWithOverviewMode = true
                                }
                                
                                addJavascriptInterface(object : Any() {
                                    @JavascriptInterface
                                    fun getReceiptData(): String = receiptJson
                        
                                    @JavascriptInterface
                                    fun getProfileData(): String = profileJson
                                    
                                    @JavascriptInterface
                                    fun isDarkMode(): Boolean = isDark
                                    
                                    @JavascriptInterface
                                    fun isNativeApp(): Boolean = true

                                    @JavascriptInterface
                                    fun getReceiptType(): String = receiptType
                                    
                                    @JavascriptInterface
                                    fun closeReceipt() {
                                        finish()
                                    }
                                    
                                    @JavascriptInterface
                                    fun printReceipt() {
                                        runOnUiThread {
                                            printWebView(receiptNo)
                                        }
                                    }
                                }, "FlutterBridge")
                        
                                webViewClient = WebViewClient()
                                loadUrl("file:///android_asset/react_app/patrucheettu.html")
                            }
                        },
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                    )
                }
            }
        }
    }

    private fun printWebView(receiptNo: String) {
        val printManager = getSystemService(Context.PRINT_SERVICE) as PrintManager
        val printAdapter = webView.createPrintDocumentAdapter("Receipt_$receiptNo")
        val jobName = "Receipt_$receiptNo"
        
        printManager.print(
            jobName,
            printAdapter,
            PrintAttributes.Builder().build()
        )
    }
}
