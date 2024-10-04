// dialog_utils.dart

import 'package:flutter/material.dart';
import 'package:stem_club/widgets/create_post_dialog.dart';

class DialogUtils {
  static Future<void> showCreatePostDialog(BuildContext context) async {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return const CreatePostDialog();
      },
    );
  }
}
