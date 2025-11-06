package com.example.all_in_one_scheduler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class UnlockReceiver : BroadcastReceiver(){
    override fun onReceive(context: Context, intent: Intent) {
        if(intent.action == Intent.ACTION_USER_PRESENT) {
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra("selectedIndex", 0)
            }
            context.startActivity(launchIntent)
        }
    }
}