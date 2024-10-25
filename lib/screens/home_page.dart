import 'package:flutter/material.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/post_list_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      home: Scaffold(
        body: Container(
          color: Colors.grey[300],
          child: const Center(
            child: PostsListWidget(
              isAllPost: true,
            ),
          ),
        ),
      ),
    );
  }
}
