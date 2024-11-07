import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<void> storeValue(String key, Map<String, dynamic> value) async {
  final prefs = await SharedPreferences.getInstance();
  String jsonValue = jsonEncode(value);
  await prefs.setString(key, jsonValue);
}

Future<Map<String, dynamic>?> getValue(String key) async {
  final prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString(key);

  // Return null if no value is found for the key
  if (value == null) {
    return null;
  }

  // Decode JSON string to Map if a value exists
  return jsonDecode(value) as Map<String, dynamic>?;
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

String getInitials(String username) {
  if (username.isNotEmpty) {
    List<String> nameParts = username.split(' ');
    return nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : username.substring(0, 2).toUpperCase();
  }
  return 'NA';
}

String formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  }
  return count.toString();
}

String getAgeGroup(String dob) {
  final currentDate = DateTime.now();

  // Parse the dob string to DateTime
  DateTime birthDate;
  try {
    birthDate = DateTime.parse(dob);
  } catch (e) {
    return "Invalid date format"; // Handle invalid date format
  }

  int age = currentDate.year - birthDate.year;

  // Adjust age if the current date is before the birth date this year
  if (currentDate
      .isBefore(DateTime(currentDate.year, birthDate.month, birthDate.day))) {
    age--;
  }

  if (age >= 5 && age <= 7) {
    return "Little Junior";
  } else if (age >= 8 && age <= 10) {
    return "Sub Junior";
  } else if (age >= 11 && age <= 13) {
    return "Junior";
  } else if (age >= 14 && age <= 17) {
    return "Senior";
  } else if (age >= 18) {
    return "Super Senior";
  } else {
    return "Age group not applicable";
  }
}
