import 'package:flutter/material.dart';

class CustomSnackbar {
  // Static method to show a SnackBar
  static void showSnackBar(BuildContext context, String message, bool isSuccess) {
     ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isSuccess ?  Colors.green : Colors.red,
            ),
          );
  }
}
