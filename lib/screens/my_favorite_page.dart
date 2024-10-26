import 'package:flutter/material.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/post_list_widget.dart';

class MyFavoritePage extends StatefulWidget {
  const MyFavoritePage({super.key});

  @override
  MyFavoritePageState createState() => MyFavoritePageState();
}

class MyFavoritePageState extends State<MyFavoritePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Favorite'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Back button icon
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
        ),
        body: Container(
          color: Colors.grey[300],
          child: const Center(
            child: PostsListWidget(isMyFavorite: true),
          ),
        ),
      ),
    );
  }
}
