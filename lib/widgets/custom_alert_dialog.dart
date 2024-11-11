import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';


class ActionDialog extends StatefulWidget {
  final String action;
  final String postId;
  final Function onApprove;
  final Function(String reason) onReject;

  ActionDialog({
    required this.action,
    required this.postId,
    required this.onApprove,
    required this.onReject,
  });

  @override
  _ActionDialogState createState() => _ActionDialogState();
}

class _ActionDialogState extends State<ActionDialog> {
  String? selectedReason;
  final List<String> frontendRejectionReasons = [
    'Duplicate Content',
    'Inappropriate content',
    'Off-Topic Content',
  ];

  final Map<String, String> reasonMapping = {
    'Duplicate Content': 'DUPLICATE_CONTENT',
    'Inappropriate content': 'INAPPROPRIATE_CONTENT',
    'Off-Topic Content': 'OFF_TOPIC_CONTENT',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Confirm ${widget.action}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Are you sure you want to ${widget.action} this post?"),
          if (widget.action == 'Reject') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedReason,
              hint: Text("Select a reason for rejection"),
              items: frontendRejectionReasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text("Cancel",
              style: TextStyle(
                color: AppColors.primaryColor,
              )),
        ),
        // Confirm button
        TextButton(
          onPressed: () {
            if (widget.action == 'Approve') {
              widget.onApprove();
              Navigator.of(context).pop();
            } else if (widget.action == 'Reject') {
              if (selectedReason == null) {
                // Show an error if no reason is selected
                CustomSnackbar.showSnackBar(
                  context,
                  'Please select a reason for rejection',
                  false,
                );
                return;
              }
              // Map the selected frontend reason to the backend reason
              final backendReason = reasonMapping[selectedReason];
              if (backendReason != null) {
                widget.onReject(backendReason);
                Navigator.of(context).pop();
              } else {
                CustomSnackbar.showSnackBar(
                  context,
                  'Invalid rejection reason',
                  false,
                );
              }
            }
          },
          child: const Text("Confirm",
              style: TextStyle(
                color: AppColors.primaryColor,
              )),
        ),
      ],
    );
  }
}
