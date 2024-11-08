// android_version_helper.dart
import 'package:flutter/services.dart';

class AndroidVersionHelper {
  static const platform = MethodChannel('com.otomatiksclub/version');

  static Future<int> getAndroidSdkVersion() async {
    try {
      // Try to get the SDK version, returning 29 if it fails
      return await platform.invokeMethod<int>('getAndroidSdkVersion') ?? 29;
    } on PlatformException {
      return 29; // Default to 29 if a PlatformException occurs
    }
  }
}