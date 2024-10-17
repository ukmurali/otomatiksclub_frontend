import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Utility function to show an error dialog.
/// 
/// [context] is the BuildContext required to display the dialog.
/// [message] is the error message that will be displayed in the dialog.
void showErrorDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Map<String, dynamic> convertUserFormat(Map<String, dynamic> input) {
    return {
      'mobile_number': input['mobile'] ?? '',
    };
  }

Future<void> storeValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

Future<String?> getValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> removeValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

Future<void> setStatus(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

Future<bool?> hasStatus(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}


