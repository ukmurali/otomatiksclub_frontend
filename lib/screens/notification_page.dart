import 'package:flutter/material.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/post_list_widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notification'),
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
