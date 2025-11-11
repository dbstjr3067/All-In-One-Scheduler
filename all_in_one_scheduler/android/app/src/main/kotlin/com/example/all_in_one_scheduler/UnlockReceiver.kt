package com.example.all_in_one_scheduler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class UnlockReceiver : BroadcastReceiver(){
    override fun onReceive(context: Context, intent: Intent) {
        if(intent.action == Intent.ACTION_USER_PRESENT) {
            Log.d("UnlockReceiver", "Received action: ${intent.action}")
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("selectedIndex", 0)
            }
            context.startActivity(launchIntent)
        }
    }
}