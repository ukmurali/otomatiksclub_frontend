import 'package:flutter/material.dart';

class CustomSnackbar {
  // Static method to show a SnackBar
  static void showSnackBar(
      BuildContext context, String message, bool isSuccess) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600; // Arbitrary width to detect web/tablet

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        margin: isWeb
            ? EdgeInsets.symmetric(horizontal: screenWidth * 0.25, vertical: 10.0)
            : const EdgeInsets.all(10.0),
        duration: const Duration(seconds: 4),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Reduced padding
      ),
    );
  }
}