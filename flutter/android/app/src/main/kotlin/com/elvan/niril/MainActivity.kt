package com.elvan.niril

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elvan.niril/print"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "printHtml") {
                val html = call.argument<String>("html")
                if (html != null) {
                    printHtmlContent(html)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "HTML string is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun printHtmlContent(html: String) {
        val intent = Intent(this, PrintPreviewActivity::class.java)
        intent.putExtra("html_content", html)
        startActivity(intent)
    }
}
