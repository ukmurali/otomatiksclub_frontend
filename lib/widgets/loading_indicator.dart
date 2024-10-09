// loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Lottie.asset(
          'loader.json', // Path to your Lottie file
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}