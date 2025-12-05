package com.miracapp.namazvakti

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val BATTERY_CHANNEL = "com.miracapp.namazvakti/battery"
    private val DND_CHANNEL = "com.miracapp.namazvakti/dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Battery optimization channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestIgnoreBatteryOptimization" -> {
                    requestIgnoreBatteryOptimization()
                    result.success(true)
                }
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Do Not Disturb / Ringer Mode channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getRingerMode" -> {
                    result.success(getRingerMode())
                }
                "setRingerMode" -> {
                    val mode = call.argument<Int>("mode") ?: 0
                    val success = setRingerMode(mode)
                    result.success(success)
                }
                "checkDndPermission" -> {
                    result.success(checkDndPermission())
                }
                "requestDndPermission" -> {
                    requestDndPermission()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Battery optimization methods
    private fun requestIgnoreBatteryOptimization() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            val packageName = packageName
            
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    }
                    startActivity(intent)
                } catch (e: Exception) {
                    // If direct request fails, open battery optimization settings
                    try {
                        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        startActivity(intent)
                    } catch (ex: Exception) {
                        ex.printStackTrace()
                    }
                }
            }
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return true
    }
    
    // Do Not Disturb / Ringer Mode methods
    
    /**
     * Get current ringer mode
     * 0 = Silent, 1 = Vibrate, 2 = Normal
     */
    private fun getRingerMode(): Int {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return audioManager.ringerMode
    }
    
    /**
     * Set ringer mode
     * 0 = Silent, 1 = Vibrate, 2 = Normal
     */
    private fun setRingerMode(mode: Int): Boolean {
        return try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            
            // Check DND permission for Android M+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                if (!notificationManager.isNotificationPolicyAccessGranted) {
                    return false
                }
            }
            
            audioManager.ringerMode = when (mode) {
                0 -> AudioManager.RINGER_MODE_SILENT
                1 -> AudioManager.RINGER_MODE_VIBRATE
                else -> AudioManager.RINGER_MODE_NORMAL
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
    
    /**
     * Check if app has Do Not Disturb access permission
     */
    private fun checkDndPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.isNotificationPolicyAccessGranted
        } else {
            true // Permission not required for older versions
        }
    }
    
    /**
     * Request Do Not Disturb access permission
     */
    private fun requestDndPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                startActivity(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
