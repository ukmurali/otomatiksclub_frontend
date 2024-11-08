import 'package:flutter/material.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/my_activity_page.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      home: Scaffold(
        body: Container(
          color: Colors.grey[300],
          child: const Center(
            child: MyActivityWidget(),
          ),
        ),
      ),
    );
  }
}
