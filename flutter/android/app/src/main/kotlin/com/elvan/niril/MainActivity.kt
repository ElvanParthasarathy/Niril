package com.elvan.niril

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val PRINT_CHANNEL = "com.elvan.niril/print"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        io.flutter.plugin.common.MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRINT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "printReceipt") {
                val receiptJson = call.argument<String>("receiptJson")
                val profileJson = call.argument<String>("profileJson")
                val isDark = call.argument<Boolean>("isDark") ?: false

                val intent = android.content.Intent(this, CleanReceiptActivity::class.java).apply {
                    putExtra("receiptJson", receiptJson)
                    putExtra("profileJson", profileJson)
                    putExtra("isDark", isDark)
                }
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
