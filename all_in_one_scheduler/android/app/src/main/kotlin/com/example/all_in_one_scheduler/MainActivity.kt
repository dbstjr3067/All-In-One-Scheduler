package com.example.all_in_one_scheduler

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import android.view.WindowManager
import android.os.Build
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity(){
    private val CHANNEL = "com.example.all_in_one_scheduler/unlock"

    //private val unlockReceiver = UnlockReceiver()

    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 8.1 이상 (권장 방식)
        /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setTurnScreenOn(true)   // 2. 화면이 꺼져 있다면 켜지도록 설정
        } else {
            // 이전 Android 버전 방식 (WindowManager Flags)
            window.addFlags(
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or // 1. 키가드(잠금 화면) 해제 시도
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON      // 2. 화면 켜기
            )
        }*/
        super.onCreate(savedInstanceState)
        handleIntent(intent)

        startUnlockService()
        //registerUnlockReceiver()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }
    override fun onDestroy() {
        super.onDestroy()
        /*try {
            unregisterReceiver(unlockReceiver)
            Log.d("MainActivity", "UnlockReceiver unregistered")
        } catch(e: IllegalArgumentException) {
            // 이미 등록되지 않은 경우 발생할 수 있음
            Log.e("MainActivity", "Receiver not registered or already unregistered: ${e.message}")
        }*/
    }

    private fun registerUnlockReceiver() {
        val filter = IntentFilter().apply {
            // ACTION_USER_PRESENT: 잠금 해제 시
            addAction(Intent.ACTION_USER_PRESENT)
            // ACTION_SCREEN_ON: 화면 켜짐 시 (잠금 미설정 폰 포함)
            addAction(Intent.ACTION_SCREEN_ON)
        }

        // 동적 등록
        //registerReceiver(unlockReceiver, filter)
        Log.d("MainActivity", "UnlockReceiver registered dynamically for USER_PRESENT and SCREEN_ON.")
    }
    private fun handleIntent(intent: Intent) {
        val selectedIndex = intent.getIntExtra("selectedIndex", -1)
        if (selectedIndex != -1) {
            flutterEngine?.let {
                MethodChannel(it.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("fromUnlock", selectedIndex)
                Log.d("MainActivity", "MethodChannel invoked with selectedIndex: $selectedIndex")
            }
        }
    }

    private fun startUnlockService() {
        val serviceIntent = Intent(this, ForegroundService::class.java)

        // 🚨 ContextCompat.startForegroundService 사용 (API 26+ 호환성)
        ContextCompat.startForegroundService(this, serviceIntent)
        Log.d("MainActivity", "ForegroundService started via ContextCompat.")
    }
}
