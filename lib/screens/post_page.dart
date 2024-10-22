import 'package:flutter/material.dart';
import 'package:stem_club/api/post_Service/api_post_service.dart';
import 'package:stem_club/widgets/post_list_widget.dart';
class MyPostsPage extends StatelessWidget {

  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Posts',
      home: Scaffold(
        body: Center(
          child: PostsListWidget(
            fetchPosts: () async {
              return await ApiPostService.getAllPost(false);
            },
          ),
        ),
      ),
    );
  }
}