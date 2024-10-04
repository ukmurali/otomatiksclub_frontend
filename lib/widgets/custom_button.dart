import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isWeb;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        padding: isWeb
            ? const EdgeInsets.symmetric(horizontal: 60, vertical: 20)
            : const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        textStyle: TextStyle(
          fontSize: isWeb ? 18 : 16,
          fontWeight: FontWeight.bold,
        ),
        minimumSize: const Size(150, 50),
        elevation: 5,
      ),
      child: Text(buttonText),
    );
  }
}