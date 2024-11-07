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
      ],
    ),
  ),
    );
  }
}