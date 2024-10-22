// loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(1.0),
      child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min, // This makes the column only take the space of its children
      children: [
        Lottie.asset(
          'assets/loading_bar.json', // Path to your Lottie file
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10), // Space between the animation and the text
        const Text(
          'Please wait a moment...', // Your loading text
          style: TextStyle(
            color: Colors.black, // Color of the text
            fontSize: 18, // Size of the text
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
      ],
    ),
  ),
    );
  }
}