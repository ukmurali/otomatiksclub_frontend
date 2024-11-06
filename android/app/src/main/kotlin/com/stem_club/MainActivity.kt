package com.otomatiksclub

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine // Import for FlutterEngine
import io.flutter.plugin.common.MethodChannel // Import for MethodChannel
import androidx.annotation.NonNull // Import for NonNull annotation
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.otomatiksclub/version"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAndroidSdkVersion") {
                // Get the Android SDK version
                val sdkVersion = Build.VERSION.SDK_INT
                result.success(sdkVersion) // Return the SDK version to Flutter
            } else {
                result.notImplemented() // Handle other method calls
            }
        }
    }
}