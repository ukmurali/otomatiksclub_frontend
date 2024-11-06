import 'package:flutter/material.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/widgets/card_banner_swiper.dart';
import 'package:otomatiksclub/widgets/post_list_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: AppConstants.appName,
        home: Scaffold(
          body: Container(
            color: Colors.grey[300],
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SwiperWidget(),
                  Expanded(
                    child: Center(
                      // Static Card at the top
                      child: PostsListWidget(isAllPost: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
