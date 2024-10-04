import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stem_club/colors/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool showCounter;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final int? maxLines;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.onChanged, // Add the onChanged parameter
    this.maxLength,
    required this.readOnly,
    this.onTap,
    required this.showCounter,
    this.focusNode,
    this.onEditingComplete,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primaryColor, // Change the cursor color
      keyboardType: keyboardType, // Use number keyboard
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor, // Change the border color
            width: 2.0,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Change the error border color
            width: 2.0,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.primaryColor, // Change the label color
        ),
      ),
      onChanged: onChanged, // Use the onChanged parameter
      validator: validator,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      maxLines: maxLines,
      buildCounter: showCounter
          ? null // Show default counter
          : (context,
                  {required currentLength, required isFocused, maxLength}) =>
              null, // Hide counter
    );
  }
}
