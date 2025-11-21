package com.example.all_in_one_scheduler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.os.Handler
import android.os.Looper

class UnlockReceiver : BroadcastReceiver(){
    override fun onReceive(context: Context, intent: Intent) {
        if(intent.action == Intent.ACTION_USER_PRESENT) {
            Log.d("UnlockReceiver", "Received action: ${intent.action}")
            Handler(Looper.getMainLooper()).postDelayed({
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                    )
                    putExtra("selectedIndex", 0)
                }
                try {
                    context.startActivity(launchIntent)
                } catch (e: Exception) {
                    Log.e("UnlockReceiver", "Failed to launch MainActivity: ${e.message}")
                }
            }, 500)
        }
    }
}