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

class CleanInvoiceActivity : ComponentActivity() {
    private lateinit var webView: WebView

    @OptIn(ExperimentalMaterial3Api::class)
    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val invoiceJson = intent.getStringExtra("invoiceJson") ?: "{}"
        val profileJson = intent.getStringExtra("profileJson") ?: "{}"
        val intentIsDark = intent.getBooleanExtra("isDark", false)
        val invoiceType = intent.getStringExtra("invoiceType") ?: "GST"
        
        var invoiceNo = "Invoice"
        try {
            val obj = JSONObject(invoiceJson)
            if (obj.has("bill_no")) {
                invoiceNo = "#" + obj.getString("bill_no")
            } else if (obj.has("invoiceNo")) {
                invoiceNo = "#" + obj.getString("invoiceNo")
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
                                    printWebView(invoiceNo) 
                                }) {
                                    Text("🖨️")
                                }
                            },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = MaterialTheme.colorScheme.surface,
                                titleContentColor = MaterialTheme.colorScheme.onSurface,
                            )
                        )
                    }
                ) { innerPadding ->
                    AndroidView(
                        factory = { context ->
                            WebView(context).apply {
                                webView = this
                                settings.apply {
                                    javaScriptEnabled = true
                                    domStorageEnabled = true
                                    builtInZoomControls = true
                                    displayZoomControls = false
                                    useWideViewPort = true
                                    loadWithOverviewMode = true
                                }
                                
                                addJavascriptInterface(object : Any() {
                                    @JavascriptInterface
                                    fun getInvoiceData(): String = invoiceJson
                        
                                    @JavascriptInterface
                                    fun getProfileData(): String = profileJson
                                    
                                    @JavascriptInterface
                                    fun isDarkMode(): Boolean = isDark
                                    
                                    @JavascriptInterface
                                    fun isNativeApp(): Boolean = true

                                    @JavascriptInterface
                                    fun getInvoiceType(): String = invoiceType
                                    
                                    @JavascriptInterface
                                    fun closeInvoice() {
                                        finish()
                                    }
                                    
                                    @JavascriptInterface
                                    fun printInvoice() {
                                        runOnUiThread {
                                            printWebView(invoiceNo)
                                        }
                                    }
                                }, "FlutterBridge")
                        
                                webViewClient = WebViewClient()
                                val am = context.assets
                                val html = am.open("react_app/pattiyal.html").bufferedReader().readText()
                                loadDataWithBaseURL(
                                    "file:///android_asset/react_app/",
                                    html,
                                    "text/html",
                                    "UTF-8",
                                    null
                                )
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
