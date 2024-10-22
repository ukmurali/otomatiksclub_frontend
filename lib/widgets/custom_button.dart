import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isWeb;
  final bool isIcon;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isWeb = false,
    this.isIcon = false,
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
          fontSize: isWeb ? 18 : 20,
          fontWeight: FontWeight.bold,
        ),
        minimumSize: const Size(100, 60),
        elevation: 12,
      ),
      child: isIcon ? Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Align items with space between them
        children: [
          const SizedBox.shrink(), // Placeholder to push text in the center
          Expanded(
            child: Center(
              child: Text(buttonText), // Center the text
            ),
          ),
          const Icon(Icons.arrow_forward, size: 28), // Right arrow icon
        ],
      ) : Text(buttonText),
    );
  }
}
