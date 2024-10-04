import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/widgets/custom_text_form_field.dart';

class ClubDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final void Function(String) onSubmit;
  final List<String> suggestions; // List of club names for autocomplete

  const ClubDialog({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onSubmit,
    required this.suggestions,
  });

  @override
  _ClubDialogState createState() => _ClubDialogState();
}

class _ClubDialogState extends State<ClubDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _clubNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.suggestions.where((suggestion) => 
                suggestion.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (selectedValue) {
            _clubNameController.text = selectedValue;
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
            return CustomTextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              labelText: 'Club Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a club name';
                } else if (value.length < 3) {
                  return 'Club name must be at least 3 characters long';
                }
                return null;
              },
              onEditingComplete: onEditingComplete, 
              keyboardType: TextInputType.name, 
              readOnly: false, 
              showCounter: false,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor, // Text color
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSubmit(_clubNameController.text);
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.primaryColor, // Text color
          ),
          child: Text(widget.buttonText),
        ),
      ],
    );
  }
}
