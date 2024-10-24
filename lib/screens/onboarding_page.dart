import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/constants.dart';
import 'package:stem_club/widgets/custom_button.dart';
import 'package:stem_club/widgets/swiper_view.dart';
import 'package:stem_club/screens/login_page.dart'; // Import the LoginPage

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: const CustomAppBar(), // Use the custom AppBar widget
      backgroundColor: AppColors.appBackgroundColor,
      body: SingleChildScrollView(
        // To avoid overflow on smaller screens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Add some spacing at the top
            const Text(
              'Unleashing the Power of',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Robotics and Creativity!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40), // Spacing before swiper
            const SwiperView(
              imagePaths: [
                'assets/images/image1.png',
                'assets/images/image2.png',
                'assets/images/image3.png',
              ],
              captions: [
                'Welcome to ${AppConstants.appName}, where STEM-based creativity meets innovation!',
                'Experience hands-on learning that turns ideas into reality!',
                'Join our club and shape the future together!',
              ],
            ),
            const SizedBox(height: 40), // Spacing before the button
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: isWeb ? 400 : double.infinity, // Wider button for web
                  child: CustomButton(
                    buttonText: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    isWeb: isWeb,
                    isIcon: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBackgroundColor,
      automaticallyImplyLeading: false, // Disable default leading icon
      title: Image.asset(
        'assets/images/otomatiks_logo.png', // Replace with your image path
        height: 80.0, // Adjust height as needed
      ),
      centerTitle: true, // Ensure title is centered in the AppBar
    );
  }
}
