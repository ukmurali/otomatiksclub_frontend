import 'package:flutter/material.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/blog_list_widget.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late String role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic>? userData = await getValue(AppConstants.userKey);
    Map<String, dynamic> userMap = userData?['user'];
    setState(() {
      role = userMap['role'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: AppConstants.appName,
        home: Scaffold(
          body: Container(
            color: Colors.grey[300],
            child: SizedBox(
              width: double.infinity,
              child: Center(
                // Static Card at the top
                child: BlogsListWidget(role: role),
              ),
            ),
          ),
        ));
  }
}
