// create_post_dialog.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:stem_club/widgets/create_post_dialog_mobile.dart';
//import 'create_post_dialog_web.dart' if (dart.library.html) 'create_post_dialog_web.dart';

class CreatePostDialog extends StatelessWidget {
  const CreatePostDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const CreatePostDialogMobile();
    } else {
      return const CreatePostDialogMobile();
    }
  }
}
