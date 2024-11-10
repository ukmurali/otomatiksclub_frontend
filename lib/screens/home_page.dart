import 'package:flutter/material.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/card_banner_swiper.dart';
import 'package:otomatiksclub/widgets/post_list_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
              child: Column(
                children: [
                  const SwiperWidget(),
                  Expanded(
                    child: Center(
                      // Static Card at the top
                      child: PostsListWidget(isAllPost: true, role: role),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
