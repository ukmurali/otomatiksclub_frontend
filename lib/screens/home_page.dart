import 'package:flutter/material.dart';
import 'package:stem_club/api/post_Service/api_post_service.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/post_list_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome ${AppConstants.appName}',
      home: Scaffold(
        body: Center(
          child: PostsListWidget(
            fetchPosts: () async {
              return await ApiPostService.getAllPost(true);
            },
          ),
        ),
      ),
    );
  }
}
