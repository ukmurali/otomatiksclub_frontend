import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/custom_card.dart';
import 'package:stem_club/utils/dialog_utils.dart'; // Import the utility class

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return MaterialApp(
      title: 'Welcome ${AppConstants.appName}',
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: isWeb ? 700 : double.infinity,
            child: Stack(
              children: [
                ListView(
                  padding:
                      const EdgeInsets.only(top: 80), // To create space for FAB
                  children: const [
                    CustomCard(
                      username: 'John Doe',
                      description: 'This is an amazing picture!',
                      mediaUrl: 'https://via.placeholder.com/150',
                      isImage: true,
                    ),
                    CustomCard(
                      username: 'Jane Smith',
                      description: 'Watch this cool video!',
                      mediaUrl:
                          'https://via.placeholder.com/150', // Replace with actual video URL
                      isImage: false,
                    ),
                  ],
                ),
                if (isWeb)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            DialogUtils.showCreatePostDialog(context); // Use the utility method
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Create Post',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            elevation: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
