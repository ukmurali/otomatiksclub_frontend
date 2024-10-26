import 'package:flutter/material.dart';

class CustomSnackbar {
  // Static method to show a SnackBar
  static void showSnackBar(
      BuildContext context, String message, bool isSuccess) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600; // Arbitrary width to detect web/tablet

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white, // Text color
            fontSize: 14.0, // Font size
          ),
        ),
        backgroundColor:
            isSuccess ? Colors.green : Colors.red, // Success or error color
        behavior: SnackBarBehavior.floating, // Floating Snackbar
        elevation: 6.0, // Shadow for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        margin: isWeb
            ? EdgeInsets.symmetric(horizontal: screenWidth * 0.25, vertical: 10.0) // Web view width reduction
            : const EdgeInsets.all(10.0), // Default margin for mobile
        duration: const Duration(seconds: 4), // Custom display time
      ),
    );
  }
}