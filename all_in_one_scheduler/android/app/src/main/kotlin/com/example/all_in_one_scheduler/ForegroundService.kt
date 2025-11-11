package com.example.all_in_one_scheduler

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import android.content.Context
import android.content.BroadcastReceiver
import android.content.pm.ServiceInfo

class ForegroundService : Service() {
    private val NOTIFICATION_CHANNEL_ID = "UNLOCK_SERVICE_CHANNEL"
    private val NOTIFICATION_ID = 1001
    private val unlockReceiver = UnlockReceiver()

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()
        //알림 생성
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("3 개의 루틴을 수행함")
            .setContentText("달성한 루틴을 체크하세요! 3/10")
            .setSmallIcon(R.mipmap.ic_launcher) // 앱 아이콘 사용
            .setPriority(NotificationCompat.PRIORITY_MIN) // 가장 낮은 우선순위
            .setSilent(true) // 소리/진동 없음
            .build()
        //포그라운드 서비스 시작
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 이상: 서비스 유형 명시
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        //포그라운드 서비스가 살아있는 동안 UnlockReceiver 동적 등록
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(unlockReceiver, filter)
        Log.d("FGService", "UnlockReceiver registered dynamically within Foreground Service.")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("FGService", "Service started/restarted.")
        // 서비스가 종료되더라도 시스템이 다시 시작하도록 요청
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        // 서비스 종료 시 Receiver도 해제
        unregisterReceiver(unlockReceiver)
        Log.d("FGService", "UnlockReceiver unregistered and Foreground Service stopped.")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "백그라운드 이벤트 서비스",
                NotificationManager.IMPORTANCE_LOW // 🚨 이 부분이 알림을 최소화합니다.
            )
            serviceChannel.setShowBadge(false) // 뱃지 표시 안 함
            serviceChannel.setSound(null, null) // 소리 없음

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

}