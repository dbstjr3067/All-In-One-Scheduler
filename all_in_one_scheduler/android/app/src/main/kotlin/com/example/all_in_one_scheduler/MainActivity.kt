package com.example.all_in_one_scheduler

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity : FlutterActivity(){
    private val CHANNEL = "com.example.all_in_one_scheduler/unlock"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val selectedIndex = intent.getIntExtra("selectedIndex", -1)
        if (selectedIndex != -1) {
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL)
                .invokeMethod("fromUnlock", selectedIndex)
        }
    }
}
